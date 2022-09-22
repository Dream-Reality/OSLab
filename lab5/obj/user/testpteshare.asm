
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80004a:	e8 84 08 00 00       	call   8008d3 <strcpy>
	exit();
  80004f:	e8 c0 01 00 00       	call   800214 <exit>
}
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	53                   	push   %ebx
  80005a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800061:	74 05                	je     800068 <umain+0x12>
		childofspawn();
  800063:	e8 cc ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800068:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800077:	a0 
  800078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007f:	e8 41 0c 00 00       	call   800cc5 <sys_page_alloc>
  800084:	85 c0                	test   %eax,%eax
  800086:	79 20                	jns    8000a8 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008c:	c7 44 24 08 ac 2d 80 	movl   $0x802dac,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 bf 2d 80 00 	movl   $0x802dbf,(%esp)
  8000a3:	e8 88 01 00 00       	call   800230 <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a8:	e8 bb 10 00 00       	call   801168 <fork>
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	79 20                	jns    8000d3 <umain+0x7d>
		panic("fork: %e", r);
  8000b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b7:	c7 44 24 08 d3 2d 80 	movl   $0x802dd3,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 bf 2d 80 00 	movl   $0x802dbf,(%esp)
  8000ce:	e8 5d 01 00 00       	call   800230 <_panic>
	if (r == 0) {
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 1a                	jne    8000f1 <umain+0x9b>
		strcpy(VA, msg);
  8000d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e7:	e8 e7 07 00 00       	call   8008d3 <strcpy>
		exit();
  8000ec:	e8 23 01 00 00       	call   800214 <exit>
	}
	wait(r);
  8000f1:	89 1c 24             	mov    %ebx,(%esp)
  8000f4:	e8 2b 26 00 00       	call   802724 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800109:	e8 6c 08 00 00       	call   80097a <strcmp>
  80010e:	85 c0                	test   %eax,%eax
  800110:	75 07                	jne    800119 <umain+0xc3>
  800112:	b8 a0 2d 80 00       	mov    $0x802da0,%eax
  800117:	eb 05                	jmp    80011e <umain+0xc8>
  800119:	b8 a6 2d 80 00       	mov    $0x802da6,%eax
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  800129:	e8 fa 01 00 00       	call   800328 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800135:	00 
  800136:	c7 44 24 08 f7 2d 80 	movl   $0x802df7,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 fc 2d 80 	movl   $0x802dfc,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 fb 2d 80 00 	movl   $0x802dfb,(%esp)
  80014d:	e8 e8 21 00 00       	call   80233a <spawnl>
  800152:	85 c0                	test   %eax,%eax
  800154:	79 20                	jns    800176 <umain+0x120>
		panic("spawn: %e", r);
  800156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015a:	c7 44 24 08 09 2e 80 	movl   $0x802e09,0x8(%esp)
  800161:	00 
  800162:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800169:	00 
  80016a:	c7 04 24 bf 2d 80 00 	movl   $0x802dbf,(%esp)
  800171:	e8 ba 00 00 00       	call   800230 <_panic>
	wait(r);
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 a6 25 00 00       	call   802724 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017e:	a1 00 40 80 00       	mov    0x804000,%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018e:	e8 e7 07 00 00       	call   80097a <strcmp>
  800193:	85 c0                	test   %eax,%eax
  800195:	75 07                	jne    80019e <umain+0x148>
  800197:	b8 a0 2d 80 00       	mov    $0x802da0,%eax
  80019c:	eb 05                	jmp    8001a3 <umain+0x14d>
  80019e:	b8 a6 2d 80 00       	mov    $0x802da6,%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 13 2e 80 00 	movl   $0x802e13,(%esp)
  8001ae:	e8 75 01 00 00       	call   800328 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001b3:	cc                   	int3   

	breakpoint();
}
  8001b4:	83 c4 14             	add    $0x14,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    
	...

008001bc <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 20             	sub    $0x20,%esp
  8001c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8001ca:	e8 b8 0a 00 00       	call   800c87 <sys_getenvid>
  8001cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001db:	c1 e0 07             	shl    $0x7,%eax
  8001de:	29 d0                	sub    %edx,%eax
  8001e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8001e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001eb:	a3 04 50 80 00       	mov    %eax,0x805004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f0:	85 f6                	test   %esi,%esi
  8001f2:	7e 07                	jle    8001fb <libmain+0x3f>
		binaryname = argv[0];
  8001f4:	8b 03                	mov    (%ebx),%eax
  8001f6:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001ff:	89 34 24             	mov    %esi,(%esp)
  800202:	e8 4f fe ff ff       	call   800056 <umain>

	// exit gracefully
	exit();
  800207:	e8 08 00 00 00       	call   800214 <exit>
}
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
	...

00800214 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80021a:	e8 42 14 00 00       	call   801661 <close_all>
	sys_env_destroy(0);
  80021f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800226:	e8 0a 0a 00 00       	call   800c35 <sys_env_destroy>
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  800241:	e8 41 0a 00 00       	call   800c87 <sys_getenvid>
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 54 24 10          	mov    %edx,0x10(%esp)
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	c7 04 24 58 2e 80 00 	movl   $0x802e58,(%esp)
  800263:	e8 c0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	89 74 24 04          	mov    %esi,0x4(%esp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 50 00 00 00       	call   8002c7 <vcprintf>
	cprintf("\n");
  800277:	c7 04 24 f0 31 80 00 	movl   $0x8031f0,(%esp)
  80027e:	e8 a5 00 00 00       	call   800328 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x53>
	...

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	53                   	push   %ebx
  80028c:	83 ec 14             	sub    $0x14,%esp
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800292:	8b 03                	mov    (%ebx),%eax
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029b:	40                   	inc    %eax
  80029c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a3:	75 19                	jne    8002be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002ac:	00 
  8002ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 40 09 00 00       	call   800bf8 <sys_cputs>
		b->idx = 0;
  8002b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002be:	ff 43 04             	incl   0x4(%ebx)
}
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d7:	00 00 00 
	b.cnt = 0;
  8002da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  800303:	e8 82 01 00 00       	call   80048a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800308:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 d8 08 00 00       	call   800bf8 <sys_cputs>

	return b.cnt;
}
  800320:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 87 ff ff ff       	call   8002c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    
	...

00800344 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 3c             	sub    $0x3c,%esp
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	89 d7                	mov    %edx,%edi
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800361:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800364:	85 c0                	test   %eax,%eax
  800366:	75 08                	jne    800370 <printnum+0x2c>
  800368:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036e:	77 57                	ja     8003c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800370:	89 74 24 10          	mov    %esi,0x10(%esp)
  800374:	4b                   	dec    %ebx
  800375:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800384:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	e8 a2 27 00 00       	call   802b44 <__udivdi3>
  8003a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b1:	89 fa                	mov    %edi,%edx
  8003b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b6:	e8 89 ff ff ff       	call   800344 <printnum>
  8003bb:	eb 0f                	jmp    8003cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	89 34 24             	mov    %esi,(%esp)
  8003c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	4b                   	dec    %ebx
  8003c8:	85 db                	test   %ebx,%ebx
  8003ca:	7f f1                	jg     8003bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e2:	00 
  8003e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	e8 6f 28 00 00       	call   802c64 <__umoddi3>
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	0f be 80 7b 2e 80 00 	movsbl 0x802e7b(%eax),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800406:	83 c4 3c             	add    $0x3c,%esp
  800409:	5b                   	pop    %ebx
  80040a:	5e                   	pop    %esi
  80040b:	5f                   	pop    %edi
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800411:	83 fa 01             	cmp    $0x1,%edx
  800414:	7e 0e                	jle    800424 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	8b 52 04             	mov    0x4(%edx),%edx
  800422:	eb 22                	jmp    800446 <getuint+0x38>
	else if (lflag)
  800424:	85 d2                	test   %edx,%edx
  800426:	74 10                	je     800438 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 02                	mov    (%edx),%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 0e                	jmp    800446 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800438:	8b 10                	mov    (%eax),%edx
  80043a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 02                	mov    (%edx),%eax
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800451:	8b 10                	mov    (%eax),%edx
  800453:	3b 50 04             	cmp    0x4(%eax),%edx
  800456:	73 08                	jae    800460 <sprintputch+0x18>
		*b->buf++ = ch;
  800458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045b:	88 0a                	mov    %cl,(%edx)
  80045d:	42                   	inc    %edx
  80045e:	89 10                	mov    %edx,(%eax)
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046f:	8b 45 10             	mov    0x10(%ebp),%eax
  800472:	89 44 24 08          	mov    %eax,0x8(%esp)
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 02 00 00 00       	call   80048a <vprintfmt>
	va_end(ap);
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 4c             	sub    $0x4c,%esp
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800496:	8b 75 10             	mov    0x10(%ebp),%esi
  800499:	eb 12                	jmp    8004ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049b:	85 c0                	test   %eax,%eax
  80049d:	0f 84 6b 03 00 00    	je     80080e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ad:	0f b6 06             	movzbl (%esi),%eax
  8004b0:	46                   	inc    %esi
  8004b1:	83 f8 25             	cmp    $0x25,%eax
  8004b4:	75 e5                	jne    80049b <vprintfmt+0x11>
  8004b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d2:	eb 26                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004db:	eb 1d                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e4:	eb 14                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	0f b6 06             	movzbl (%esi),%eax
  8004fd:	8d 56 01             	lea    0x1(%esi),%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	8a 16                	mov    (%esi),%dl
  800505:	83 ea 23             	sub    $0x23,%edx
  800508:	80 fa 55             	cmp    $0x55,%dl
  80050b:	0f 87 e1 02 00 00    	ja     8007f2 <vprintfmt+0x368>
  800511:	0f b6 d2             	movzbl %dl,%edx
  800514:	ff 24 95 c0 2f 80 00 	jmp    *0x802fc0(,%edx,4)
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800523:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800526:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80052a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80052d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800530:	83 fa 09             	cmp    $0x9,%edx
  800533:	77 2a                	ja     80055f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800535:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800536:	eb eb                	jmp    800523 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800546:	eb 17                	jmp    80055f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800548:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054c:	78 98                	js     8004e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800551:	eb a7                	jmp    8004fa <vprintfmt+0x70>
  800553:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800556:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80055d:	eb 9b                	jmp    8004fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800563:	79 95                	jns    8004fa <vprintfmt+0x70>
  800565:	eb 8b                	jmp    8004f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800567:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056b:	eb 8d                	jmp    8004fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800585:	e9 23 ff ff ff       	jmp    8004ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	79 02                	jns    80059b <vprintfmt+0x111>
  800599:	f7 d8                	neg    %eax
  80059b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059d:	83 f8 0f             	cmp    $0xf,%eax
  8005a0:	7f 0b                	jg     8005ad <vprintfmt+0x123>
  8005a2:	8b 04 85 20 31 80 00 	mov    0x803120(,%eax,4),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	75 23                	jne    8005d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b1:	c7 44 24 08 93 2e 80 	movl   $0x802e93,0x8(%esp)
  8005b8:	00 
  8005b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 9a fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cb:	e9 dd fe ff ff       	jmp    8004ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d4:	c7 44 24 08 99 32 80 	movl   $0x803299,0x8(%esp)
  8005db:	00 
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e3:	89 14 24             	mov    %edx,(%esp)
  8005e6:	e8 77 fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ee:	e9 ba fe ff ff       	jmp    8004ad <vprintfmt+0x23>
  8005f3:	89 f9                	mov    %edi,%ecx
  8005f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 30                	mov    (%eax),%esi
  800606:	85 f6                	test   %esi,%esi
  800608:	75 05                	jne    80060f <vprintfmt+0x185>
				p = "(null)";
  80060a:	be 8c 2e 80 00       	mov    $0x802e8c,%esi
			if (width > 0 && padc != '-')
  80060f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800613:	0f 8e 84 00 00 00    	jle    80069d <vprintfmt+0x213>
  800619:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80061d:	74 7e                	je     80069d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 8b 02 00 00       	call   8008b6 <strnlen>
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	29 c2                	sub    %eax,%edx
  800630:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800633:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800637:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80063a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	89 d3                	mov    %edx,%ebx
  800641:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	eb 0b                	jmp    800650 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	89 3c 24             	mov    %edi,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	4b                   	dec    %ebx
  800650:	85 db                	test   %ebx,%ebx
  800652:	7f f1                	jg     800645 <vprintfmt+0x1bb>
  800654:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800657:	89 f3                	mov    %esi,%ebx
  800659:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80065c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	79 05                	jns    800668 <vprintfmt+0x1de>
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	29 c2                	sub    %eax,%edx
  80066d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800670:	eb 2b                	jmp    80069d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800672:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800676:	74 18                	je     800690 <vprintfmt+0x206>
  800678:	8d 50 e0             	lea    -0x20(%eax),%edx
  80067b:	83 fa 5e             	cmp    $0x5e,%edx
  80067e:	76 10                	jbe    800690 <vprintfmt+0x206>
					putch('?', putdat);
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	eb 0a                	jmp    80069a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	ff 4d e4             	decl   -0x1c(%ebp)
  80069d:	0f be 06             	movsbl (%esi),%eax
  8006a0:	46                   	inc    %esi
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 21                	je     8006c6 <vprintfmt+0x23c>
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	78 c9                	js     800672 <vprintfmt+0x1e8>
  8006a9:	4f                   	dec    %edi
  8006aa:	79 c6                	jns    800672 <vprintfmt+0x1e8>
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	89 de                	mov    %ebx,%esi
  8006b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b4:	eb 18                	jmp    8006ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c3:	4b                   	dec    %ebx
  8006c4:	eb 08                	jmp    8006ce <vprintfmt+0x244>
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	89 de                	mov    %ebx,%esi
  8006cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ce:	85 db                	test   %ebx,%ebx
  8006d0:	7f e4                	jg     8006b6 <vprintfmt+0x22c>
  8006d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006da:	e9 ce fd ff ff       	jmp    8004ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7e 10                	jle    8006f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 08             	lea    0x8(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 30                	mov    (%eax),%esi
  8006ef:	8b 78 04             	mov    0x4(%eax),%edi
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x290>
	else if (lflag)
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	74 12                	je     80070a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
  800703:	89 f7                	mov    %esi,%edi
  800705:	c1 ff 1f             	sar    $0x1f,%edi
  800708:	eb 10                	jmp    80071a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 30                	mov    (%eax),%esi
  800715:	89 f7                	mov    %esi,%edi
  800717:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071a:	85 ff                	test   %edi,%edi
  80071c:	78 0a                	js     800728 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800723:	e9 8c 00 00 00       	jmp    8007b4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800736:	f7 de                	neg    %esi
  800738:	83 d7 00             	adc    $0x0,%edi
  80073b:	f7 df                	neg    %edi
			}
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	eb 70                	jmp    8007b4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 c0 fc ff ff       	call   80040e <getuint>
  80074e:	89 c6                	mov    %eax,%esi
  800750:	89 d7                	mov    %edx,%edi
			base = 10;
  800752:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800757:	eb 5b                	jmp    8007b4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800759:	89 ca                	mov    %ecx,%edx
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 ab fc ff ff       	call   80040e <getuint>
  800763:	89 c6                	mov    %eax,%esi
  800765:	89 d7                	mov    %edx,%edi
			base = 8;
  800767:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80076c:	eb 46                	jmp    8007b4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80076e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800772:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800779:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 50 04             	lea    0x4(%eax),%edx
  800790:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800793:	8b 30                	mov    (%eax),%esi
  800795:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80079f:	eb 13                	jmp    8007b4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a1:	89 ca                	mov    %ecx,%edx
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 63 fc ff ff       	call   80040e <getuint>
  8007ab:	89 c6                	mov    %eax,%esi
  8007ad:	89 d7                	mov    %edx,%edi
			base = 16;
  8007af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c7:	89 34 24             	mov    %esi,(%esp)
  8007ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ce:	89 da                	mov    %ebx,%edx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	e8 6c fb ff ff       	call   800344 <printnum>
			break;
  8007d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007db:	e9 cd fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ed:	e9 bb fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800800:	eb 01                	jmp    800803 <vprintfmt+0x379>
  800802:	4e                   	dec    %esi
  800803:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800807:	75 f9                	jne    800802 <vprintfmt+0x378>
  800809:	e9 9f fc ff ff       	jmp    8004ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80080e:	83 c4 4c             	add    $0x4c,%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 28             	sub    $0x28,%esp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800822:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800825:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800829:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800833:	85 c0                	test   %eax,%eax
  800835:	74 30                	je     800867 <vsnprintf+0x51>
  800837:	85 d2                	test   %edx,%edx
  800839:	7e 33                	jle    80086e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	c7 04 24 48 04 80 00 	movl   $0x800448,(%esp)
  800857:	e8 2e fc ff ff       	call   80048a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800865:	eb 0c                	jmp    800873 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086c:	eb 05                	jmp    800873 <vsnprintf+0x5d>
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 7b ff ff ff       	call   800816 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
  80089d:	00 00                	add    %al,(%eax)
	...

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	eb 01                	jmp    8008ae <strlen+0xe>
		n++;
  8008ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b2:	75 f9                	jne    8008ad <strlen+0xd>
		n++;
	return n;
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 01                	jmp    8008c7 <strnlen+0x11>
		n++;
  8008c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c7:	39 d0                	cmp    %edx,%eax
  8008c9:	74 06                	je     8008d1 <strnlen+0x1b>
  8008cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cf:	75 f5                	jne    8008c6 <strnlen+0x10>
		n++;
	return n;
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e8:	42                   	inc    %edx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	75 f5                	jne    8008e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fa:	89 1c 24             	mov    %ebx,(%esp)
  8008fd:	e8 9e ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 54 24 04          	mov    %edx,0x4(%esp)
  800909:	01 d8                	add    %ebx,%eax
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	e8 c0 ff ff ff       	call   8008d3 <strcpy>
	return dst;
}
  800913:	89 d8                	mov    %ebx,%eax
  800915:	83 c4 08             	add    $0x8,%esp
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800929:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092e:	eb 0c                	jmp    80093c <strncpy+0x21>
		*dst++ = *src;
  800930:	8a 1a                	mov    (%edx),%bl
  800932:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800935:	80 3a 01             	cmpb   $0x1,(%edx)
  800938:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	41                   	inc    %ecx
  80093c:	39 f1                	cmp    %esi,%ecx
  80093e:	75 f0                	jne    800930 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 75 08             	mov    0x8(%ebp),%esi
  80094c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800952:	85 d2                	test   %edx,%edx
  800954:	75 0a                	jne    800960 <strlcpy+0x1c>
  800956:	89 f0                	mov    %esi,%eax
  800958:	eb 1a                	jmp    800974 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095a:	88 18                	mov    %bl,(%eax)
  80095c:	40                   	inc    %eax
  80095d:	41                   	inc    %ecx
  80095e:	eb 02                	jmp    800962 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800962:	4a                   	dec    %edx
  800963:	74 0a                	je     80096f <strlcpy+0x2b>
  800965:	8a 19                	mov    (%ecx),%bl
  800967:	84 db                	test   %bl,%bl
  800969:	75 ef                	jne    80095a <strlcpy+0x16>
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	eb 02                	jmp    800971 <strlcpy+0x2d>
  80096f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800971:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800974:	29 f0                	sub    %esi,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800983:	eb 02                	jmp    800987 <strcmp+0xd>
		p++, q++;
  800985:	41                   	inc    %ecx
  800986:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800987:	8a 01                	mov    (%ecx),%al
  800989:	84 c0                	test   %al,%al
  80098b:	74 04                	je     800991 <strcmp+0x17>
  80098d:	3a 02                	cmp    (%edx),%al
  80098f:	74 f4                	je     800985 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 12             	movzbl (%edx),%edx
  800997:	29 d0                	sub    %edx,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009a8:	eb 03                	jmp    8009ad <strncmp+0x12>
		n--, p++, q++;
  8009aa:	4a                   	dec    %edx
  8009ab:	40                   	inc    %eax
  8009ac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	74 14                	je     8009c5 <strncmp+0x2a>
  8009b1:	8a 18                	mov    (%eax),%bl
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	74 04                	je     8009bb <strncmp+0x20>
  8009b7:	3a 19                	cmp    (%ecx),%bl
  8009b9:	74 ef                	je     8009aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 00             	movzbl (%eax),%eax
  8009be:	0f b6 11             	movzbl (%ecx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
  8009c3:	eb 05                	jmp    8009ca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d6:	eb 05                	jmp    8009dd <strchr+0x10>
		if (*s == c)
  8009d8:	38 ca                	cmp    %cl,%dl
  8009da:	74 0c                	je     8009e8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009dc:	40                   	inc    %eax
  8009dd:	8a 10                	mov    (%eax),%dl
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	75 f5                	jne    8009d8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f3:	eb 05                	jmp    8009fa <strfind+0x10>
		if (*s == c)
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	74 07                	je     800a00 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	8a 10                	mov    (%eax),%dl
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	75 f5                	jne    8009f5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 30                	je     800a45 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 25                	jne    800a42 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 20                	jne    800a42 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a25:	89 d3                	mov    %edx,%ebx
  800a27:	c1 e3 08             	shl    $0x8,%ebx
  800a2a:	89 d6                	mov    %edx,%esi
  800a2c:	c1 e6 18             	shl    $0x18,%esi
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	c1 e0 10             	shl    $0x10,%eax
  800a34:	09 f0                	or     %esi,%eax
  800a36:	09 d0                	or     %edx,%eax
  800a38:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a3d:	fc                   	cld    
  800a3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a40:	eb 03                	jmp    800a45 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a42:	fc                   	cld    
  800a43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a45:	89 f8                	mov    %edi,%eax
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 34                	jae    800a92 <memmove+0x46>
  800a5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a61:	39 d0                	cmp    %edx,%eax
  800a63:	73 2d                	jae    800a92 <memmove+0x46>
		s += n;
		d += n;
  800a65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	f6 c2 03             	test   $0x3,%dl
  800a6b:	75 1b                	jne    800a88 <memmove+0x3c>
  800a6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a73:	75 13                	jne    800a88 <memmove+0x3c>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 0e                	jne    800a88 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb 07                	jmp    800a8f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a88:	4f                   	dec    %edi
  800a89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8f:	fc                   	cld    
  800a90:	eb 20                	jmp    800ab2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a98:	75 13                	jne    800aad <memmove+0x61>
  800a9a:	a8 03                	test   $0x3,%al
  800a9c:	75 0f                	jne    800aad <memmove+0x61>
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 0a                	jne    800aad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aab:	eb 05                	jmp    800ab2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aad:	89 c7                	mov    %eax,%edi
  800aaf:	fc                   	cld    
  800ab0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	89 04 24             	mov    %eax,(%esp)
  800ad0:	e8 77 ff ff ff       	call   800a4c <memmove>
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	eb 16                	jmp    800b03 <memcmp+0x2c>
		if (*s1 != *s2)
  800aed:	8a 04 17             	mov    (%edi,%edx,1),%al
  800af0:	42                   	inc    %edx
  800af1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800af5:	38 c8                	cmp    %cl,%al
  800af7:	74 0a                	je     800b03 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 c9             	movzbl %cl,%ecx
  800aff:	29 c8                	sub    %ecx,%eax
  800b01:	eb 09                	jmp    800b0c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b03:	39 da                	cmp    %ebx,%edx
  800b05:	75 e6                	jne    800aed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1f:	eb 05                	jmp    800b26 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b21:	38 08                	cmp    %cl,(%eax)
  800b23:	74 05                	je     800b2a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b25:	40                   	inc    %eax
  800b26:	39 d0                	cmp    %edx,%eax
  800b28:	72 f7                	jb     800b21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	eb 01                	jmp    800b3b <strtol+0xf>
		s++;
  800b3a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3b:	8a 02                	mov    (%edx),%al
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f9                	je     800b3a <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f5                	je     800b3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 08                	jne    800b51 <strtol+0x25>
		s++;
  800b49:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4f:	eb 13                	jmp    800b64 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b51:	3c 2d                	cmp    $0x2d,%al
  800b53:	75 0a                	jne    800b5f <strtol+0x33>
		s++, neg = 1;
  800b55:	8d 52 01             	lea    0x1(%edx),%edx
  800b58:	bf 01 00 00 00       	mov    $0x1,%edi
  800b5d:	eb 05                	jmp    800b64 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	74 05                	je     800b6d <strtol+0x41>
  800b68:	83 fb 10             	cmp    $0x10,%ebx
  800b6b:	75 28                	jne    800b95 <strtol+0x69>
  800b6d:	8a 02                	mov    (%edx),%al
  800b6f:	3c 30                	cmp    $0x30,%al
  800b71:	75 10                	jne    800b83 <strtol+0x57>
  800b73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b77:	75 0a                	jne    800b83 <strtol+0x57>
		s += 2, base = 16;
  800b79:	83 c2 02             	add    $0x2,%edx
  800b7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b81:	eb 12                	jmp    800b95 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b83:	85 db                	test   %ebx,%ebx
  800b85:	75 0e                	jne    800b95 <strtol+0x69>
  800b87:	3c 30                	cmp    $0x30,%al
  800b89:	75 05                	jne    800b90 <strtol+0x64>
		s++, base = 8;
  800b8b:	42                   	inc    %edx
  800b8c:	b3 08                	mov    $0x8,%bl
  800b8e:	eb 05                	jmp    800b95 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9c:	8a 0a                	mov    (%edx),%cl
  800b9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba1:	80 fb 09             	cmp    $0x9,%bl
  800ba4:	77 08                	ja     800bae <strtol+0x82>
			dig = *s - '0';
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 30             	sub    $0x30,%ecx
  800bac:	eb 1e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 57             	sub    $0x57,%ecx
  800bbc:	eb 0e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 12                	ja     800bd8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcc:	39 f1                	cmp    %esi,%ecx
  800bce:	7d 0c                	jge    800bdc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bd0:	42                   	inc    %edx
  800bd1:	0f af c6             	imul   %esi,%eax
  800bd4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd6:	eb c4                	jmp    800b9c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd8:	89 c1                	mov    %eax,%ecx
  800bda:	eb 02                	jmp    800bde <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be2:	74 05                	je     800be9 <strtol+0xbd>
		*endptr = (char *) s;
  800be4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be9:	85 ff                	test   %edi,%edi
  800beb:	74 04                	je     800bf1 <strtol+0xc5>
  800bed:	89 c8                	mov    %ecx,%eax
  800bef:	f7 d8                	neg    %eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
	...

00800bf8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 c3                	mov    %eax,%ebx
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	89 c6                	mov    %eax,%esi
  800c0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	b8 01 00 00 00       	mov    $0x1,%eax
  800c26:	89 d1                	mov    %edx,%ecx
  800c28:	89 d3                	mov    %edx,%ebx
  800c2a:	89 d7                	mov    %edx,%edi
  800c2c:	89 d6                	mov    %edx,%esi
  800c2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c43:	b8 03 00 00 00       	mov    $0x3,%eax
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 cb                	mov    %ecx,%ebx
  800c4d:	89 cf                	mov    %ecx,%edi
  800c4f:	89 ce                	mov    %ecx,%esi
  800c51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800c7a:	e8 b1 f5 ff ff       	call   800230 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	83 c4 2c             	add    $0x2c,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 02 00 00 00       	mov    $0x2,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_yield>:

void
sys_yield(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 f7                	mov    %esi,%edi
  800ce3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 28                	jle    800d11 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ced:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800cfc:	00 
  800cfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d04:	00 
  800d05:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800d0c:	e8 1f f5 ff ff       	call   800230 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d11:	83 c4 2c             	add    $0x2c,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	b8 05 00 00 00       	mov    $0x5,%eax
  800d27:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 28                	jle    800d64 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d40:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d47:	00 
  800d48:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800d4f:	00 
  800d50:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d57:	00 
  800d58:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800d5f:	e8 cc f4 ff ff       	call   800230 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d64:	83 c4 2c             	add    $0x2c,%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 28                	jle    800db7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d93:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800da2:	00 
  800da3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800daa:	00 
  800dab:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800db2:	e8 79 f4 ff ff       	call   800230 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	83 c4 2c             	add    $0x2c,%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 28                	jle    800e0a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800e05:	e8 26 f4 ff ff       	call   800230 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0a:	83 c4 2c             	add    $0x2c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	b8 09 00 00 00       	mov    $0x9,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800e58:	e8 d3 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5d:	83 c4 2c             	add    $0x2c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 28                	jle    800eb0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e93:	00 
  800e94:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea3:	00 
  800ea4:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800eab:	e8 80 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb0:	83 c4 2c             	add    $0x2c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	be 00 00 00 00       	mov    $0x0,%esi
  800ec3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 cb                	mov    %ecx,%ebx
  800ef3:	89 cf                	mov    %ecx,%edi
  800ef5:	89 ce                	mov    %ecx,%esi
  800ef7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 28                	jle    800f25 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f01:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f08:	00 
  800f09:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 9c 31 80 00 	movl   $0x80319c,(%esp)
  800f20:	e8 0b f3 ff ff       	call   800230 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f25:	83 c4 2c             	add    $0x2c,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	00 00                	add    %al,(%eax)
	...

00800f30 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 3c             	sub    $0x3c,%esp
  800f39:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800f41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800f4b:	e8 37 fd ff ff       	call   800c87 <sys_getenvid>
  800f50:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800f52:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800f59:	74 31                	je     800f8c <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800f5b:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800f62:	00 
  800f63:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f67:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f72:	89 3c 24             	mov    %edi,(%esp)
  800f75:	e8 9f fd ff ff       	call   800d19 <sys_page_map>
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	0f 8e ae 00 00 00    	jle    801030 <duppage+0x100>
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
  800f87:	e9 a4 00 00 00       	jmp    801030 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f8f:	25 02 08 00 00       	and    $0x802,%eax
  800f94:	83 f8 01             	cmp    $0x1,%eax
  800f97:	19 db                	sbb    %ebx,%ebx
  800f99:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800f9f:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800fa5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800fa9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb8:	89 3c 24             	mov    %edi,(%esp)
  800fbb:	e8 59 fd ff ff       	call   800d19 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	79 1c                	jns    800fe0 <duppage+0xb0>
  800fc4:	c7 44 24 08 aa 31 80 	movl   $0x8031aa,0x8(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800fd3:	00 
  800fd4:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  800fdb:	e8 50 f2 ff ff       	call   800230 <_panic>
	if ((perm|~pte)&PTE_COW){
  800fe0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe3:	f7 d0                	not    %eax
  800fe5:	09 d8                	or     %ebx,%eax
  800fe7:	f6 c4 08             	test   $0x8,%ah
  800fea:	74 38                	je     801024 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800fec:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800ff0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ff4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ff8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ffc:	89 3c 24             	mov    %edi,(%esp)
  800fff:	e8 15 fd ff ff       	call   800d19 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  801004:	85 c0                	test   %eax,%eax
  801006:	79 23                	jns    80102b <duppage+0xfb>
  801008:	c7 44 24 08 aa 31 80 	movl   $0x8031aa,0x8(%esp)
  80100f:	00 
  801010:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801017:	00 
  801018:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  80101f:	e8 0c f2 ff ff       	call   800230 <_panic>
	}
	return 0;
  801024:	b8 00 00 00 00       	mov    $0x0,%eax
  801029:	eb 05                	jmp    801030 <duppage+0x100>
  80102b:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  801030:	83 c4 3c             	add    $0x3c,%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 20             	sub    $0x20,%esp
  801040:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801043:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  801045:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801049:	75 1c                	jne    801067 <pgfault+0x2f>
		panic("pgfault: error!\n");
  80104b:	c7 44 24 08 c6 31 80 	movl   $0x8031c6,0x8(%esp)
  801052:	00 
  801053:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80105a:	00 
  80105b:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  801062:	e8 c9 f1 ff ff       	call   800230 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  801067:	89 f0                	mov    %esi,%eax
  801069:	c1 e8 0c             	shr    $0xc,%eax
  80106c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801073:	f6 c4 08             	test   $0x8,%ah
  801076:	75 1c                	jne    801094 <pgfault+0x5c>
		panic("pgfault: error!\n");
  801078:	c7 44 24 08 c6 31 80 	movl   $0x8031c6,0x8(%esp)
  80107f:	00 
  801080:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801087:	00 
  801088:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  80108f:	e8 9c f1 ff ff       	call   800230 <_panic>
	envid_t envid = sys_getenvid();
  801094:	e8 ee fb ff ff       	call   800c87 <sys_getenvid>
  801099:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  80109b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010aa:	00 
  8010ab:	89 04 24             	mov    %eax,(%esp)
  8010ae:	e8 12 fc ff ff       	call   800cc5 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 1c                	jns    8010d3 <pgfault+0x9b>
  8010b7:	c7 44 24 08 c6 31 80 	movl   $0x8031c6,0x8(%esp)
  8010be:	00 
  8010bf:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8010c6:	00 
  8010c7:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  8010ce:	e8 5d f1 ff ff       	call   800230 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  8010d3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  8010d9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010e0:	00 
  8010e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010ec:	e8 c5 f9 ff ff       	call   800ab6 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  8010f1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010f8:	00 
  8010f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801101:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801108:	00 
  801109:	89 1c 24             	mov    %ebx,(%esp)
  80110c:	e8 08 fc ff ff       	call   800d19 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801111:	85 c0                	test   %eax,%eax
  801113:	79 1c                	jns    801131 <pgfault+0xf9>
  801115:	c7 44 24 08 c6 31 80 	movl   $0x8031c6,0x8(%esp)
  80111c:	00 
  80111d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801124:	00 
  801125:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  80112c:	e8 ff f0 ff ff       	call   800230 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801131:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801138:	00 
  801139:	89 1c 24             	mov    %ebx,(%esp)
  80113c:	e8 2b fc ff ff       	call   800d6c <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801141:	85 c0                	test   %eax,%eax
  801143:	79 1c                	jns    801161 <pgfault+0x129>
  801145:	c7 44 24 08 c6 31 80 	movl   $0x8031c6,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  80115c:	e8 cf f0 ff ff       	call   800230 <_panic>
	return;
	panic("pgfault not implemented");
}
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801171:	c7 04 24 38 10 80 00 	movl   $0x801038,(%esp)
  801178:	e8 b3 17 00 00       	call   802930 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80117d:	bf 07 00 00 00       	mov    $0x7,%edi
  801182:	89 f8                	mov    %edi,%eax
  801184:	cd 30                	int    $0x30
  801186:	89 c7                	mov    %eax,%edi
  801188:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  80118a:	85 c0                	test   %eax,%eax
  80118c:	79 1c                	jns    8011aa <fork+0x42>
		panic("fork : error!\n");
  80118e:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  801195:	00 
  801196:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80119d:	00 
  80119e:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  8011a5:	e8 86 f0 ff ff       	call   800230 <_panic>
	if (envid==0){
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	75 28                	jne    8011d6 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  8011ae:	8b 1d 04 50 80 00    	mov    0x805004,%ebx
  8011b4:	e8 ce fa ff ff       	call   800c87 <sys_getenvid>
  8011b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011c5:	c1 e0 07             	shl    $0x7,%eax
  8011c8:	29 d0                	sub    %edx,%eax
  8011ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011cf:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  8011d1:	e9 f2 00 00 00       	jmp    8012c8 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  8011d6:	e8 ac fa ff ff       	call   800c87 <sys_getenvid>
  8011db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8011de:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  8011e3:	89 d8                	mov    %ebx,%eax
  8011e5:	c1 e8 16             	shr    $0x16,%eax
  8011e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ef:	a8 01                	test   $0x1,%al
  8011f1:	74 17                	je     80120a <fork+0xa2>
  8011f3:	89 da                	mov    %ebx,%edx
  8011f5:	c1 ea 0c             	shr    $0xc,%edx
  8011f8:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8011ff:	a8 01                	test   $0x1,%al
  801201:	74 07                	je     80120a <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801203:	89 f0                	mov    %esi,%eax
  801205:	e8 26 fd ff ff       	call   800f30 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80120a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801210:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801216:	75 cb                	jne    8011e3 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801218:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80121f:	00 
  801220:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801227:	ee 
  801228:	89 3c 24             	mov    %edi,(%esp)
  80122b:	e8 95 fa ff ff       	call   800cc5 <sys_page_alloc>
  801230:	85 c0                	test   %eax,%eax
  801232:	79 1c                	jns    801250 <fork+0xe8>
  801234:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  80123b:	00 
  80123c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801243:	00 
  801244:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  80124b:	e8 e0 ef ff ff       	call   800230 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  801250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801253:	25 ff 03 00 00       	and    $0x3ff,%eax
  801258:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80125f:	c1 e0 07             	shl    $0x7,%eax
  801262:	29 d0                	sub    %edx,%eax
  801264:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801269:	8b 40 64             	mov    0x64(%eax),%eax
  80126c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801270:	89 3c 24             	mov    %edi,(%esp)
  801273:	e8 ed fb ff ff       	call   800e65 <sys_env_set_pgfault_upcall>
  801278:	85 c0                	test   %eax,%eax
  80127a:	79 1c                	jns    801298 <fork+0x130>
  80127c:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  801293:	e8 98 ef ff ff       	call   800230 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801298:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80129f:	00 
  8012a0:	89 3c 24             	mov    %edi,(%esp)
  8012a3:	e8 17 fb ff ff       	call   800dbf <sys_env_set_status>
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	79 1c                	jns    8012c8 <fork+0x160>
  8012ac:	c7 44 24 08 e3 31 80 	movl   $0x8031e3,0x8(%esp)
  8012b3:	00 
  8012b4:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012bb:	00 
  8012bc:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  8012c3:	e8 68 ef ff ff       	call   800230 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  8012c8:	89 f8                	mov    %edi,%eax
  8012ca:	83 c4 2c             	add    $0x2c,%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <sfork>:

// Challenge!
int
sfork(void)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8012db:	c7 04 24 38 10 80 00 	movl   $0x801038,(%esp)
  8012e2:	e8 49 16 00 00       	call   802930 <set_pgfault_handler>
  8012e7:	ba 07 00 00 00       	mov    $0x7,%edx
  8012ec:	89 d0                	mov    %edx,%eax
  8012ee:	cd 30                	int    $0x30
  8012f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f3:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	c7 04 24 d7 31 80 00 	movl   $0x8031d7,(%esp)
  801300:	e8 23 f0 ff ff       	call   800328 <cprintf>
	if (envid<0)
  801305:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801309:	79 1c                	jns    801327 <sfork+0x55>
		panic("sfork : error!\n");
  80130b:	c7 44 24 08 e2 31 80 	movl   $0x8031e2,0x8(%esp)
  801312:	00 
  801313:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  80131a:	00 
  80131b:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  801322:	e8 09 ef ff ff       	call   800230 <_panic>
	if (envid==0){
  801327:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80132b:	75 28                	jne    801355 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  80132d:	8b 1d 04 50 80 00    	mov    0x805004,%ebx
  801333:	e8 4f f9 ff ff       	call   800c87 <sys_getenvid>
  801338:	25 ff 03 00 00       	and    $0x3ff,%eax
  80133d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801344:	c1 e0 07             	shl    $0x7,%eax
  801347:	29 d0                	sub    %edx,%eax
  801349:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80134e:	89 03                	mov    %eax,(%ebx)
		return envid;
  801350:	e9 18 01 00 00       	jmp    80146d <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801355:	e8 2d f9 ff ff       	call   800c87 <sys_getenvid>
  80135a:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80135c:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801361:	89 d8                	mov    %ebx,%eax
  801363:	c1 e8 16             	shr    $0x16,%eax
  801366:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80136d:	a8 01                	test   $0x1,%al
  80136f:	74 2c                	je     80139d <sfork+0xcb>
  801371:	89 d8                	mov    %ebx,%eax
  801373:	c1 e8 0c             	shr    $0xc,%eax
  801376:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137d:	a8 01                	test   $0x1,%al
  80137f:	74 1c                	je     80139d <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801381:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801388:	00 
  801389:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80138d:	89 74 24 08          	mov    %esi,0x8(%esp)
  801391:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801395:	89 3c 24             	mov    %edi,(%esp)
  801398:	e8 7c f9 ff ff       	call   800d19 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80139d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013a3:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8013a9:	75 b6                	jne    801361 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8013ab:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8013b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b3:	e8 78 fb ff ff       	call   800f30 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  8013b8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013c7:	ee 
  8013c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 f2 f8 ff ff       	call   800cc5 <sys_page_alloc>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	79 1c                	jns    8013f3 <sfork+0x121>
  8013d7:	c7 44 24 08 e2 31 80 	movl   $0x8031e2,0x8(%esp)
  8013de:	00 
  8013df:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8013e6:	00 
  8013e7:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  8013ee:	e8 3d ee ff ff       	call   800230 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  8013f3:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  8013f9:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801400:	c1 e7 07             	shl    $0x7,%edi
  801403:	29 d7                	sub    %edx,%edi
  801405:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80140b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	e8 4b fa ff ff       	call   800e65 <sys_env_set_pgfault_upcall>
  80141a:	85 c0                	test   %eax,%eax
  80141c:	79 1c                	jns    80143a <sfork+0x168>
  80141e:	c7 44 24 08 e2 31 80 	movl   $0x8031e2,0x8(%esp)
  801425:	00 
  801426:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  80142d:	00 
  80142e:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  801435:	e8 f6 ed ff ff       	call   800230 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80143a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801441:	00 
  801442:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801445:	89 04 24             	mov    %eax,(%esp)
  801448:	e8 72 f9 ff ff       	call   800dbf <sys_env_set_status>
  80144d:	85 c0                	test   %eax,%eax
  80144f:	79 1c                	jns    80146d <sfork+0x19b>
  801451:	c7 44 24 08 e2 31 80 	movl   $0x8031e2,0x8(%esp)
  801458:	00 
  801459:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801460:	00 
  801461:	c7 04 24 bb 31 80 00 	movl   $0x8031bb,(%esp)
  801468:	e8 c3 ed ff ff       	call   800230 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  80146d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801470:	83 c4 3c             	add    $0x3c,%esp
  801473:	5b                   	pop    %ebx
  801474:	5e                   	pop    %esi
  801475:	5f                   	pop    %edi
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	05 00 00 00 30       	add    $0x30000000,%eax
  801483:	c1 e8 0c             	shr    $0xc,%eax
}
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80148e:	8b 45 08             	mov    0x8(%ebp),%eax
  801491:	89 04 24             	mov    %eax,(%esp)
  801494:	e8 df ff ff ff       	call   801478 <fd2num>
  801499:	05 20 00 0d 00       	add    $0xd0020,%eax
  80149e:	c1 e0 0c             	shl    $0xc,%eax
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014af:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	c1 ea 16             	shr    $0x16,%edx
  8014b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014bd:	f6 c2 01             	test   $0x1,%dl
  8014c0:	74 11                	je     8014d3 <fd_alloc+0x30>
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	c1 ea 0c             	shr    $0xc,%edx
  8014c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ce:	f6 c2 01             	test   $0x1,%dl
  8014d1:	75 09                	jne    8014dc <fd_alloc+0x39>
			*fd_store = fd;
  8014d3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014da:	eb 17                	jmp    8014f3 <fd_alloc+0x50>
  8014dc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014e6:	75 c7                	jne    8014af <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014ee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014f3:	5b                   	pop    %ebx
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014fc:	83 f8 1f             	cmp    $0x1f,%eax
  8014ff:	77 36                	ja     801537 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801501:	05 00 00 0d 00       	add    $0xd0000,%eax
  801506:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801509:	89 c2                	mov    %eax,%edx
  80150b:	c1 ea 16             	shr    $0x16,%edx
  80150e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801515:	f6 c2 01             	test   $0x1,%dl
  801518:	74 24                	je     80153e <fd_lookup+0x48>
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	c1 ea 0c             	shr    $0xc,%edx
  80151f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801526:	f6 c2 01             	test   $0x1,%dl
  801529:	74 1a                	je     801545 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80152b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152e:	89 02                	mov    %eax,(%edx)
	return 0;
  801530:	b8 00 00 00 00       	mov    $0x0,%eax
  801535:	eb 13                	jmp    80154a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801537:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153c:	eb 0c                	jmp    80154a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80153e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801543:	eb 05                	jmp    80154a <fd_lookup+0x54>
  801545:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	53                   	push   %ebx
  801550:	83 ec 14             	sub    $0x14,%esp
  801553:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801559:	ba 00 00 00 00       	mov    $0x0,%edx
  80155e:	eb 0e                	jmp    80156e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801560:	39 08                	cmp    %ecx,(%eax)
  801562:	75 09                	jne    80156d <dev_lookup+0x21>
			*dev = devtab[i];
  801564:	89 03                	mov    %eax,(%ebx)
			return 0;
  801566:	b8 00 00 00 00       	mov    $0x0,%eax
  80156b:	eb 35                	jmp    8015a2 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80156d:	42                   	inc    %edx
  80156e:	8b 04 95 70 32 80 00 	mov    0x803270(,%edx,4),%eax
  801575:	85 c0                	test   %eax,%eax
  801577:	75 e7                	jne    801560 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801579:	a1 04 50 80 00       	mov    0x805004,%eax
  80157e:	8b 00                	mov    (%eax),%eax
  801580:	8b 40 48             	mov    0x48(%eax),%eax
  801583:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158b:	c7 04 24 f4 31 80 00 	movl   $0x8031f4,(%esp)
  801592:	e8 91 ed ff ff       	call   800328 <cprintf>
	*dev = 0;
  801597:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80159d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015a2:	83 c4 14             	add    $0x14,%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    

008015a8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 30             	sub    $0x30,%esp
  8015b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b3:	8a 45 0c             	mov    0xc(%ebp),%al
  8015b6:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015b9:	89 34 24             	mov    %esi,(%esp)
  8015bc:	e8 b7 fe ff ff       	call   801478 <fd2num>
  8015c1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c8:	89 04 24             	mov    %eax,(%esp)
  8015cb:	e8 26 ff ff ff       	call   8014f6 <fd_lookup>
  8015d0:	89 c3                	mov    %eax,%ebx
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 05                	js     8015db <fd_close+0x33>
	    || fd != fd2)
  8015d6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015d9:	74 0d                	je     8015e8 <fd_close+0x40>
		return (must_exist ? r : 0);
  8015db:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015df:	75 46                	jne    801627 <fd_close+0x7f>
  8015e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e6:	eb 3f                	jmp    801627 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ef:	8b 06                	mov    (%esi),%eax
  8015f1:	89 04 24             	mov    %eax,(%esp)
  8015f4:	e8 53 ff ff ff       	call   80154c <dev_lookup>
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 18                	js     801617 <fd_close+0x6f>
		if (dev->dev_close)
  8015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801602:	8b 40 10             	mov    0x10(%eax),%eax
  801605:	85 c0                	test   %eax,%eax
  801607:	74 09                	je     801612 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801609:	89 34 24             	mov    %esi,(%esp)
  80160c:	ff d0                	call   *%eax
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	eb 05                	jmp    801617 <fd_close+0x6f>
		else
			r = 0;
  801612:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801617:	89 74 24 04          	mov    %esi,0x4(%esp)
  80161b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801622:	e8 45 f7 ff ff       	call   800d6c <sys_page_unmap>
	return r;
}
  801627:	89 d8                	mov    %ebx,%eax
  801629:	83 c4 30             	add    $0x30,%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	8b 45 08             	mov    0x8(%ebp),%eax
  801640:	89 04 24             	mov    %eax,(%esp)
  801643:	e8 ae fe ff ff       	call   8014f6 <fd_lookup>
  801648:	85 c0                	test   %eax,%eax
  80164a:	78 13                	js     80165f <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80164c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801653:	00 
  801654:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 49 ff ff ff       	call   8015a8 <fd_close>
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <close_all>:

void
close_all(void)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	53                   	push   %ebx
  801665:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801668:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80166d:	89 1c 24             	mov    %ebx,(%esp)
  801670:	e8 bb ff ff ff       	call   801630 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801675:	43                   	inc    %ebx
  801676:	83 fb 20             	cmp    $0x20,%ebx
  801679:	75 f2                	jne    80166d <close_all+0xc>
		close(i);
}
  80167b:	83 c4 14             	add    $0x14,%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	57                   	push   %edi
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	83 ec 4c             	sub    $0x4c,%esp
  80168a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80168d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801690:	89 44 24 04          	mov    %eax,0x4(%esp)
  801694:	8b 45 08             	mov    0x8(%ebp),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 57 fe ff ff       	call   8014f6 <fd_lookup>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	0f 88 e1 00 00 00    	js     80178a <dup+0x109>
		return r;
	close(newfdnum);
  8016a9:	89 3c 24             	mov    %edi,(%esp)
  8016ac:	e8 7f ff ff ff       	call   801630 <close>

	newfd = INDEX2FD(newfdnum);
  8016b1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016b7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 c3 fd ff ff       	call   801488 <fd2data>
  8016c5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016c7:	89 34 24             	mov    %esi,(%esp)
  8016ca:	e8 b9 fd ff ff       	call   801488 <fd2data>
  8016cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016d2:	89 d8                	mov    %ebx,%eax
  8016d4:	c1 e8 16             	shr    $0x16,%eax
  8016d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016de:	a8 01                	test   $0x1,%al
  8016e0:	74 46                	je     801728 <dup+0xa7>
  8016e2:	89 d8                	mov    %ebx,%eax
  8016e4:	c1 e8 0c             	shr    $0xc,%eax
  8016e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ee:	f6 c2 01             	test   $0x1,%dl
  8016f1:	74 35                	je     801728 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801703:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801706:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80170a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801711:	00 
  801712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801716:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171d:	e8 f7 f5 ff ff       	call   800d19 <sys_page_map>
  801722:	89 c3                	mov    %eax,%ebx
  801724:	85 c0                	test   %eax,%eax
  801726:	78 3b                	js     801763 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172b:	89 c2                	mov    %eax,%edx
  80172d:	c1 ea 0c             	shr    $0xc,%edx
  801730:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801737:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80173d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801741:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801745:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80174c:	00 
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801758:	e8 bc f5 ff ff       	call   800d19 <sys_page_map>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	85 c0                	test   %eax,%eax
  801761:	79 25                	jns    801788 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801763:	89 74 24 04          	mov    %esi,0x4(%esp)
  801767:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176e:	e8 f9 f5 ff ff       	call   800d6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801773:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801781:	e8 e6 f5 ff ff       	call   800d6c <sys_page_unmap>
	return r;
  801786:	eb 02                	jmp    80178a <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801788:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80178a:	89 d8                	mov    %ebx,%eax
  80178c:	83 c4 4c             	add    $0x4c,%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5f                   	pop    %edi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	53                   	push   %ebx
  801798:	83 ec 24             	sub    $0x24,%esp
  80179b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a5:	89 1c 24             	mov    %ebx,(%esp)
  8017a8:	e8 49 fd ff ff       	call   8014f6 <fd_lookup>
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 6f                	js     801820 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	8b 00                	mov    (%eax),%eax
  8017bd:	89 04 24             	mov    %eax,(%esp)
  8017c0:	e8 87 fd ff ff       	call   80154c <dev_lookup>
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 57                	js     801820 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cc:	8b 50 08             	mov    0x8(%eax),%edx
  8017cf:	83 e2 03             	and    $0x3,%edx
  8017d2:	83 fa 01             	cmp    $0x1,%edx
  8017d5:	75 25                	jne    8017fc <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d7:	a1 04 50 80 00       	mov    0x805004,%eax
  8017dc:	8b 00                	mov    (%eax),%eax
  8017de:	8b 40 48             	mov    0x48(%eax),%eax
  8017e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e9:	c7 04 24 35 32 80 00 	movl   $0x803235,(%esp)
  8017f0:	e8 33 eb ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  8017f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017fa:	eb 24                	jmp    801820 <read+0x8c>
	}
	if (!dev->dev_read)
  8017fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ff:	8b 52 08             	mov    0x8(%edx),%edx
  801802:	85 d2                	test   %edx,%edx
  801804:	74 15                	je     80181b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801806:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801809:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80180d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801810:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801814:	89 04 24             	mov    %eax,(%esp)
  801817:	ff d2                	call   *%edx
  801819:	eb 05                	jmp    801820 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80181b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801820:	83 c4 24             	add    $0x24,%esp
  801823:	5b                   	pop    %ebx
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	57                   	push   %edi
  80182a:	56                   	push   %esi
  80182b:	53                   	push   %ebx
  80182c:	83 ec 1c             	sub    $0x1c,%esp
  80182f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801832:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801835:	bb 00 00 00 00       	mov    $0x0,%ebx
  80183a:	eb 23                	jmp    80185f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80183c:	89 f0                	mov    %esi,%eax
  80183e:	29 d8                	sub    %ebx,%eax
  801840:	89 44 24 08          	mov    %eax,0x8(%esp)
  801844:	8b 45 0c             	mov    0xc(%ebp),%eax
  801847:	01 d8                	add    %ebx,%eax
  801849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184d:	89 3c 24             	mov    %edi,(%esp)
  801850:	e8 3f ff ff ff       	call   801794 <read>
		if (m < 0)
  801855:	85 c0                	test   %eax,%eax
  801857:	78 10                	js     801869 <readn+0x43>
			return m;
		if (m == 0)
  801859:	85 c0                	test   %eax,%eax
  80185b:	74 0a                	je     801867 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80185d:	01 c3                	add    %eax,%ebx
  80185f:	39 f3                	cmp    %esi,%ebx
  801861:	72 d9                	jb     80183c <readn+0x16>
  801863:	89 d8                	mov    %ebx,%eax
  801865:	eb 02                	jmp    801869 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801867:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801869:	83 c4 1c             	add    $0x1c,%esp
  80186c:	5b                   	pop    %ebx
  80186d:	5e                   	pop    %esi
  80186e:	5f                   	pop    %edi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	53                   	push   %ebx
  801875:	83 ec 24             	sub    $0x24,%esp
  801878:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801882:	89 1c 24             	mov    %ebx,(%esp)
  801885:	e8 6c fc ff ff       	call   8014f6 <fd_lookup>
  80188a:	85 c0                	test   %eax,%eax
  80188c:	78 6a                	js     8018f8 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801891:	89 44 24 04          	mov    %eax,0x4(%esp)
  801895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801898:	8b 00                	mov    (%eax),%eax
  80189a:	89 04 24             	mov    %eax,(%esp)
  80189d:	e8 aa fc ff ff       	call   80154c <dev_lookup>
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 52                	js     8018f8 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ad:	75 25                	jne    8018d4 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018af:	a1 04 50 80 00       	mov    0x805004,%eax
  8018b4:	8b 00                	mov    (%eax),%eax
  8018b6:	8b 40 48             	mov    0x48(%eax),%eax
  8018b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	c7 04 24 51 32 80 00 	movl   $0x803251,(%esp)
  8018c8:	e8 5b ea ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  8018cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018d2:	eb 24                	jmp    8018f8 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018da:	85 d2                	test   %edx,%edx
  8018dc:	74 15                	je     8018f3 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ec:	89 04 24             	mov    %eax,(%esp)
  8018ef:	ff d2                	call   *%edx
  8018f1:	eb 05                	jmp    8018f8 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018f8:	83 c4 24             	add    $0x24,%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801904:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	89 04 24             	mov    %eax,(%esp)
  801911:	e8 e0 fb ff ff       	call   8014f6 <fd_lookup>
  801916:	85 c0                	test   %eax,%eax
  801918:	78 0e                	js     801928 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80191a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80191d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801920:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	53                   	push   %ebx
  80192e:	83 ec 24             	sub    $0x24,%esp
  801931:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801934:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193b:	89 1c 24             	mov    %ebx,(%esp)
  80193e:	e8 b3 fb ff ff       	call   8014f6 <fd_lookup>
  801943:	85 c0                	test   %eax,%eax
  801945:	78 63                	js     8019aa <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801951:	8b 00                	mov    (%eax),%eax
  801953:	89 04 24             	mov    %eax,(%esp)
  801956:	e8 f1 fb ff ff       	call   80154c <dev_lookup>
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 4b                	js     8019aa <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80195f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801962:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801966:	75 25                	jne    80198d <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801968:	a1 04 50 80 00       	mov    0x805004,%eax
  80196d:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80196f:	8b 40 48             	mov    0x48(%eax),%eax
  801972:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197a:	c7 04 24 14 32 80 00 	movl   $0x803214,(%esp)
  801981:	e8 a2 e9 ff ff       	call   800328 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801986:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80198b:	eb 1d                	jmp    8019aa <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80198d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801990:	8b 52 18             	mov    0x18(%edx),%edx
  801993:	85 d2                	test   %edx,%edx
  801995:	74 0e                	je     8019a5 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801997:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80199a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	ff d2                	call   *%edx
  8019a3:	eb 05                	jmp    8019aa <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019aa:	83 c4 24             	add    $0x24,%esp
  8019ad:	5b                   	pop    %ebx
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 24             	sub    $0x24,%esp
  8019b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c4:	89 04 24             	mov    %eax,(%esp)
  8019c7:	e8 2a fb ff ff       	call   8014f6 <fd_lookup>
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 52                	js     801a22 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019da:	8b 00                	mov    (%eax),%eax
  8019dc:	89 04 24             	mov    %eax,(%esp)
  8019df:	e8 68 fb ff ff       	call   80154c <dev_lookup>
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 3a                	js     801a22 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019ef:	74 2c                	je     801a1d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019fb:	00 00 00 
	stat->st_isdir = 0;
  8019fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a05:	00 00 00 
	stat->st_dev = dev;
  801a08:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a12:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a15:	89 14 24             	mov    %edx,(%esp)
  801a18:	ff 50 14             	call   *0x14(%eax)
  801a1b:	eb 05                	jmp    801a22 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a1d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a22:	83 c4 24             	add    $0x24,%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a37:	00 
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	89 04 24             	mov    %eax,(%esp)
  801a3e:	e8 88 02 00 00       	call   801ccb <open>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 1b                	js     801a64 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a50:	89 1c 24             	mov    %ebx,(%esp)
  801a53:	e8 58 ff ff ff       	call   8019b0 <fstat>
  801a58:	89 c6                	mov    %eax,%esi
	close(fd);
  801a5a:	89 1c 24             	mov    %ebx,(%esp)
  801a5d:	e8 ce fb ff ff       	call   801630 <close>
	return r;
  801a62:	89 f3                	mov    %esi,%ebx
}
  801a64:	89 d8                	mov    %ebx,%eax
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    
  801a6d:	00 00                	add    %al,(%eax)
	...

00801a70 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	83 ec 10             	sub    $0x10,%esp
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a7c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a83:	75 11                	jne    801a96 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a8c:	e8 2a 10 00 00       	call   802abb <ipc_find_env>
  801a91:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a9d:	00 
  801a9e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801aa5:	00 
  801aa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aaa:	a1 00 50 80 00       	mov    0x805000,%eax
  801aaf:	89 04 24             	mov    %eax,(%esp)
  801ab2:	e8 9e 0f 00 00       	call   802a55 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801ab7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801abe:	00 
  801abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aca:	e8 19 0f 00 00       	call   8029e8 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801adc:	8b 45 08             	mov    0x8(%ebp),%eax
  801adf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aea:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	b8 02 00 00 00       	mov    $0x2,%eax
  801af9:	e8 72 ff ff ff       	call   801a70 <fsipc>
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b06:	8b 45 08             	mov    0x8(%ebp),%eax
  801b09:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b11:	ba 00 00 00 00       	mov    $0x0,%edx
  801b16:	b8 06 00 00 00       	mov    $0x6,%eax
  801b1b:	e8 50 ff ff ff       	call   801a70 <fsipc>
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	53                   	push   %ebx
  801b26:	83 ec 14             	sub    $0x14,%esp
  801b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b32:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b37:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3c:	b8 05 00 00 00       	mov    $0x5,%eax
  801b41:	e8 2a ff ff ff       	call   801a70 <fsipc>
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 2b                	js     801b75 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b4a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b51:	00 
  801b52:	89 1c 24             	mov    %ebx,(%esp)
  801b55:	e8 79 ed ff ff       	call   8008d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b5a:	a1 80 60 80 00       	mov    0x806080,%eax
  801b5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b65:	a1 84 60 80 00       	mov    0x806084,%eax
  801b6a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b75:	83 c4 14             	add    $0x14,%esp
  801b78:	5b                   	pop    %ebx
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	53                   	push   %ebx
  801b7f:	83 ec 14             	sub    $0x14,%esp
  801b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801b90:	89 d8                	mov    %ebx,%eax
  801b92:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801b98:	76 05                	jbe    801b9f <devfile_write+0x24>
  801b9a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801b9f:	a3 04 60 80 00       	mov    %eax,0x806004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801ba4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801baf:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801bb6:	e8 fb ee ff ff       	call   800ab6 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc0:	b8 04 00 00 00       	mov    $0x4,%eax
  801bc5:	e8 a6 fe ff ff       	call   801a70 <fsipc>
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	78 53                	js     801c21 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801bce:	39 c3                	cmp    %eax,%ebx
  801bd0:	73 24                	jae    801bf6 <devfile_write+0x7b>
  801bd2:	c7 44 24 0c 80 32 80 	movl   $0x803280,0xc(%esp)
  801bd9:	00 
  801bda:	c7 44 24 08 87 32 80 	movl   $0x803287,0x8(%esp)
  801be1:	00 
  801be2:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801be9:	00 
  801bea:	c7 04 24 9c 32 80 00 	movl   $0x80329c,(%esp)
  801bf1:	e8 3a e6 ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  801bf6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bfb:	7e 24                	jle    801c21 <devfile_write+0xa6>
  801bfd:	c7 44 24 0c a7 32 80 	movl   $0x8032a7,0xc(%esp)
  801c04:	00 
  801c05:	c7 44 24 08 87 32 80 	movl   $0x803287,0x8(%esp)
  801c0c:	00 
  801c0d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801c14:	00 
  801c15:	c7 04 24 9c 32 80 00 	movl   $0x80329c,(%esp)
  801c1c:	e8 0f e6 ff ff       	call   800230 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801c21:	83 c4 14             	add    $0x14,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	83 ec 10             	sub    $0x10,%esp
  801c2f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	8b 40 0c             	mov    0xc(%eax),%eax
  801c38:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c3d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c43:	ba 00 00 00 00       	mov    $0x0,%edx
  801c48:	b8 03 00 00 00       	mov    $0x3,%eax
  801c4d:	e8 1e fe ff ff       	call   801a70 <fsipc>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 6a                	js     801cc2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c58:	39 c6                	cmp    %eax,%esi
  801c5a:	73 24                	jae    801c80 <devfile_read+0x59>
  801c5c:	c7 44 24 0c 80 32 80 	movl   $0x803280,0xc(%esp)
  801c63:	00 
  801c64:	c7 44 24 08 87 32 80 	movl   $0x803287,0x8(%esp)
  801c6b:	00 
  801c6c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801c73:	00 
  801c74:	c7 04 24 9c 32 80 00 	movl   $0x80329c,(%esp)
  801c7b:	e8 b0 e5 ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  801c80:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c85:	7e 24                	jle    801cab <devfile_read+0x84>
  801c87:	c7 44 24 0c a7 32 80 	movl   $0x8032a7,0xc(%esp)
  801c8e:	00 
  801c8f:	c7 44 24 08 87 32 80 	movl   $0x803287,0x8(%esp)
  801c96:	00 
  801c97:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801c9e:	00 
  801c9f:	c7 04 24 9c 32 80 00 	movl   $0x80329c,(%esp)
  801ca6:	e8 85 e5 ff ff       	call   800230 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801caf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cb6:	00 
  801cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cba:	89 04 24             	mov    %eax,(%esp)
  801cbd:	e8 8a ed ff ff       	call   800a4c <memmove>
	return r;
}
  801cc2:	89 d8                	mov    %ebx,%eax
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	56                   	push   %esi
  801ccf:	53                   	push   %ebx
  801cd0:	83 ec 20             	sub    $0x20,%esp
  801cd3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cd6:	89 34 24             	mov    %esi,(%esp)
  801cd9:	e8 c2 eb ff ff       	call   8008a0 <strlen>
  801cde:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ce3:	7f 60                	jg     801d45 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ce5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce8:	89 04 24             	mov    %eax,(%esp)
  801ceb:	e8 b3 f7 ff ff       	call   8014a3 <fd_alloc>
  801cf0:	89 c3                	mov    %eax,%ebx
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 54                	js     801d4a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d01:	e8 cd eb ff ff       	call   8008d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d09:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d11:	b8 01 00 00 00       	mov    $0x1,%eax
  801d16:	e8 55 fd ff ff       	call   801a70 <fsipc>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	79 15                	jns    801d36 <open+0x6b>
		fd_close(fd, 0);
  801d21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d28:	00 
  801d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2c:	89 04 24             	mov    %eax,(%esp)
  801d2f:	e8 74 f8 ff ff       	call   8015a8 <fd_close>
		return r;
  801d34:	eb 14                	jmp    801d4a <open+0x7f>
	}

	return fd2num(fd);
  801d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d39:	89 04 24             	mov    %eax,(%esp)
  801d3c:	e8 37 f7 ff ff       	call   801478 <fd2num>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	eb 05                	jmp    801d4a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d45:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d4a:	89 d8                	mov    %ebx,%eax
  801d4c:	83 c4 20             	add    $0x20,%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d59:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5e:	b8 08 00 00 00       	mov    $0x8,%eax
  801d63:	e8 08 fd ff ff       	call   801a70 <fsipc>
}
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    
	...

00801d6c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	57                   	push   %edi
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801d78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d7f:	00 
  801d80:	8b 45 08             	mov    0x8(%ebp),%eax
  801d83:	89 04 24             	mov    %eax,(%esp)
  801d86:	e8 40 ff ff ff       	call   801ccb <open>
  801d8b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 77 05 00 00    	js     802310 <spawn+0x5a4>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801d99:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801da0:	00 
  801da1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dab:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801db1:	89 04 24             	mov    %eax,(%esp)
  801db4:	e8 6d fa ff ff       	call   801826 <readn>
  801db9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801dbe:	75 0c                	jne    801dcc <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801dc0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801dc7:	45 4c 46 
  801dca:	74 3b                	je     801e07 <spawn+0x9b>
		close(fd);
  801dcc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dd2:	89 04 24             	mov    %eax,(%esp)
  801dd5:	e8 56 f8 ff ff       	call   801630 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801dda:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801de1:	46 
  801de2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801de8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dec:	c7 04 24 b3 32 80 00 	movl   $0x8032b3,(%esp)
  801df3:	e8 30 e5 ff ff       	call   800328 <cprintf>
		return -E_NOT_EXEC;
  801df8:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801dff:	ff ff ff 
  801e02:	e9 15 05 00 00       	jmp    80231c <spawn+0x5b0>
  801e07:	ba 07 00 00 00       	mov    $0x7,%edx
  801e0c:	89 d0                	mov    %edx,%eax
  801e0e:	cd 30                	int    $0x30
  801e10:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801e16:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	0f 88 f8 04 00 00    	js     80231c <spawn+0x5b0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801e24:	25 ff 03 00 00       	and    $0x3ff,%eax
  801e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801e30:	c1 e0 07             	shl    $0x7,%eax
  801e33:	29 d0                	sub    %edx,%eax
  801e35:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801e3b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801e41:	b9 11 00 00 00       	mov    $0x11,%ecx
  801e46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801e48:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801e4e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e54:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e5e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e61:	eb 0d                	jmp    801e70 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801e63:	89 04 24             	mov    %eax,(%esp)
  801e66:	e8 35 ea ff ff       	call   8008a0 <strlen>
  801e6b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e6f:	46                   	inc    %esi
  801e70:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801e72:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e79:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	75 e3                	jne    801e63 <spawn+0xf7>
  801e80:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801e86:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801e8c:	bf 00 10 40 00       	mov    $0x401000,%edi
  801e91:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e93:	89 f8                	mov    %edi,%eax
  801e95:	83 e0 fc             	and    $0xfffffffc,%eax
  801e98:	f7 d2                	not    %edx
  801e9a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801e9d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ea3:	89 d0                	mov    %edx,%eax
  801ea5:	83 e8 08             	sub    $0x8,%eax
  801ea8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ead:	0f 86 7a 04 00 00    	jbe    80232d <spawn+0x5c1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801eb3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801eba:	00 
  801ebb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ec2:	00 
  801ec3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eca:	e8 f6 ed ff ff       	call   800cc5 <sys_page_alloc>
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	0f 88 5b 04 00 00    	js     802332 <spawn+0x5c6>
  801ed7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801edc:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801ee2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee5:	eb 2e                	jmp    801f15 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ee7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801eed:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ef3:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801ef6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801ef9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efd:	89 3c 24             	mov    %edi,(%esp)
  801f00:	e8 ce e9 ff ff       	call   8008d3 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801f05:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 90 e9 ff ff       	call   8008a0 <strlen>
  801f10:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801f14:	43                   	inc    %ebx
  801f15:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801f1b:	7c ca                	jl     801ee7 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801f1d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801f23:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f29:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801f30:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801f36:	74 24                	je     801f5c <spawn+0x1f0>
  801f38:	c7 44 24 0c 28 33 80 	movl   $0x803328,0xc(%esp)
  801f3f:	00 
  801f40:	c7 44 24 08 87 32 80 	movl   $0x803287,0x8(%esp)
  801f47:	00 
  801f48:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801f4f:	00 
  801f50:	c7 04 24 cd 32 80 00 	movl   $0x8032cd,(%esp)
  801f57:	e8 d4 e2 ff ff       	call   800230 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801f5c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f62:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801f67:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801f6d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801f70:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f76:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801f79:	89 d0                	mov    %edx,%eax
  801f7b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801f80:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801f86:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801f8d:	00 
  801f8e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801f95:	ee 
  801f96:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fa7:	00 
  801fa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801faf:	e8 65 ed ff ff       	call   800d19 <sys_page_map>
  801fb4:	89 c3                	mov    %eax,%ebx
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 1a                	js     801fd4 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801fba:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fc1:	00 
  801fc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc9:	e8 9e ed ff ff       	call   800d6c <sys_page_unmap>
  801fce:	89 c3                	mov    %eax,%ebx
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	79 1f                	jns    801ff3 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801fd4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fdb:	00 
  801fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe3:	e8 84 ed ff ff       	call   800d6c <sys_page_unmap>
	return r;
  801fe8:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801fee:	e9 29 03 00 00       	jmp    80231c <spawn+0x5b0>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ff3:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801ff9:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801fff:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802005:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80200c:	00 00 00 
  80200f:	e9 bb 01 00 00       	jmp    8021cf <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  802014:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80201a:	83 38 01             	cmpl   $0x1,(%eax)
  80201d:	0f 85 9f 01 00 00    	jne    8021c2 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802023:	89 c2                	mov    %eax,%edx
  802025:	8b 40 18             	mov    0x18(%eax),%eax
  802028:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80202b:	83 f8 01             	cmp    $0x1,%eax
  80202e:	19 c0                	sbb    %eax,%eax
  802030:	83 e0 fe             	and    $0xfffffffe,%eax
  802033:	83 c0 07             	add    $0x7,%eax
  802036:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80203c:	8b 52 04             	mov    0x4(%edx),%edx
  80203f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802045:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80204b:	8b 40 10             	mov    0x10(%eax),%eax
  80204e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802054:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80205a:	8b 52 14             	mov    0x14(%edx),%edx
  80205d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802063:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802069:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80206c:	89 f8                	mov    %edi,%eax
  80206e:	25 ff 0f 00 00       	and    $0xfff,%eax
  802073:	74 16                	je     80208b <spawn+0x31f>
		va -= i;
  802075:	29 c7                	sub    %eax,%edi
		memsz += i;
  802077:	01 c2                	add    %eax,%edx
  802079:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  80207f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802085:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80208b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802090:	e9 1f 01 00 00       	jmp    8021b4 <spawn+0x448>
		if (i >= filesz) {
  802095:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  80209b:	72 2b                	jb     8020c8 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80209d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8020a3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020ab:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 0c ec ff ff       	call   800cc5 <sys_page_alloc>
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	0f 89 e7 00 00 00    	jns    8021a8 <spawn+0x43c>
  8020c1:	89 c6                	mov    %eax,%esi
  8020c3:	e9 24 02 00 00       	jmp    8022ec <spawn+0x580>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020c8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020cf:	00 
  8020d0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020d7:	00 
  8020d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020df:	e8 e1 eb ff ff       	call   800cc5 <sys_page_alloc>
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	0f 88 f6 01 00 00    	js     8022e2 <spawn+0x576>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8020ec:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8020f2:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020fe:	89 04 24             	mov    %eax,(%esp)
  802101:	e8 f8 f7 ff ff       	call   8018fe <seek>
  802106:	85 c0                	test   %eax,%eax
  802108:	0f 88 d8 01 00 00    	js     8022e6 <spawn+0x57a>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80210e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802114:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802116:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80211b:	76 05                	jbe    802122 <spawn+0x3b6>
  80211d:	b8 00 10 00 00       	mov    $0x1000,%eax
  802122:	89 44 24 08          	mov    %eax,0x8(%esp)
  802126:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80212d:	00 
  80212e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802134:	89 04 24             	mov    %eax,(%esp)
  802137:	e8 ea f6 ff ff       	call   801826 <readn>
  80213c:	85 c0                	test   %eax,%eax
  80213e:	0f 88 a6 01 00 00    	js     8022ea <spawn+0x57e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802144:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80214a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80214e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802152:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802158:	89 44 24 08          	mov    %eax,0x8(%esp)
  80215c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802163:	00 
  802164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216b:	e8 a9 eb ff ff       	call   800d19 <sys_page_map>
  802170:	85 c0                	test   %eax,%eax
  802172:	79 20                	jns    802194 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802174:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802178:	c7 44 24 08 d9 32 80 	movl   $0x8032d9,0x8(%esp)
  80217f:	00 
  802180:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  802187:	00 
  802188:	c7 04 24 cd 32 80 00 	movl   $0x8032cd,(%esp)
  80218f:	e8 9c e0 ff ff       	call   800230 <_panic>
			sys_page_unmap(0, UTEMP);
  802194:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80219b:	00 
  80219c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a3:	e8 c4 eb ff ff       	call   800d6c <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8021a8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8021ae:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8021b4:	89 de                	mov    %ebx,%esi
  8021b6:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  8021bc:	0f 82 d3 fe ff ff    	jb     802095 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8021c2:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  8021c8:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8021cf:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8021d6:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  8021dc:	0f 8c 32 fe ff ff    	jl     802014 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8021e2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8021e8:	89 04 24             	mov    %eax,(%esp)
  8021eb:	e8 40 f4 ff ff       	call   801630 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  8021f0:	be 00 00 00 00       	mov    $0x0,%esi
  8021f5:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(va)] & PTE_P)&&(uvpt[PGNUM(va)] & PTE_P)&&(uvpt[PGNUM(va)]&PTE_U)&&(uvpt[PGNUM(va)]&PTE_SHARE)){
  8021fb:	89 f0                	mov    %esi,%eax
  8021fd:	c1 e8 16             	shr    $0x16,%eax
  802200:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802207:	a8 01                	test   $0x1,%al
  802209:	74 49                	je     802254 <spawn+0x4e8>
  80220b:	89 f0                	mov    %esi,%eax
  80220d:	c1 e8 0c             	shr    $0xc,%eax
  802210:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802217:	f6 c2 01             	test   $0x1,%dl
  80221a:	74 38                	je     802254 <spawn+0x4e8>
  80221c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802223:	f6 c2 04             	test   $0x4,%dl
  802226:	74 2c                	je     802254 <spawn+0x4e8>
  802228:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80222f:	f6 c4 04             	test   $0x4,%ah
  802232:	74 20                	je     802254 <spawn+0x4e8>
			if ((r = sys_page_map(0,(void*)va,child,(void*)va,PTE_SYSCALL))<0);
  802234:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  80223b:	00 
  80223c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802240:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80224f:	e8 c5 ea ff ff       	call   800d19 <sys_page_map>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  802254:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80225a:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  802260:	75 99                	jne    8021fb <spawn+0x48f>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802262:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802269:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80226c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802272:	89 44 24 04          	mov    %eax,0x4(%esp)
  802276:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80227c:	89 04 24             	mov    %eax,(%esp)
  80227f:	e8 8e eb ff ff       	call   800e12 <sys_env_set_trapframe>
  802284:	85 c0                	test   %eax,%eax
  802286:	79 20                	jns    8022a8 <spawn+0x53c>
		panic("sys_env_set_trapframe: %e", r);
  802288:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228c:	c7 44 24 08 f6 32 80 	movl   $0x8032f6,0x8(%esp)
  802293:	00 
  802294:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  80229b:	00 
  80229c:	c7 04 24 cd 32 80 00 	movl   $0x8032cd,(%esp)
  8022a3:	e8 88 df ff ff       	call   800230 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8022a8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8022af:	00 
  8022b0:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8022b6:	89 04 24             	mov    %eax,(%esp)
  8022b9:	e8 01 eb ff ff       	call   800dbf <sys_env_set_status>
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	79 5a                	jns    80231c <spawn+0x5b0>
		panic("sys_env_set_status: %e", r);
  8022c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022c6:	c7 44 24 08 10 33 80 	movl   $0x803310,0x8(%esp)
  8022cd:	00 
  8022ce:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8022d5:	00 
  8022d6:	c7 04 24 cd 32 80 00 	movl   $0x8032cd,(%esp)
  8022dd:	e8 4e df ff ff       	call   800230 <_panic>
  8022e2:	89 c6                	mov    %eax,%esi
  8022e4:	eb 06                	jmp    8022ec <spawn+0x580>
  8022e6:	89 c6                	mov    %eax,%esi
  8022e8:	eb 02                	jmp    8022ec <spawn+0x580>
  8022ea:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  8022ec:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8022f2:	89 04 24             	mov    %eax,(%esp)
  8022f5:	e8 3b e9 ff ff       	call   800c35 <sys_env_destroy>
	close(fd);
  8022fa:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802300:	89 04 24             	mov    %eax,(%esp)
  802303:	e8 28 f3 ff ff       	call   801630 <close>
	return r;
  802308:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  80230e:	eb 0c                	jmp    80231c <spawn+0x5b0>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802310:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802316:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80231c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802322:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80232d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802332:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802338:	eb e2                	jmp    80231c <spawn+0x5b0>

0080233a <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	57                   	push   %edi
  80233e:	56                   	push   %esi
  80233f:	53                   	push   %ebx
  802340:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802343:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802346:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80234b:	eb 03                	jmp    802350 <spawnl+0x16>
		argc++;
  80234d:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80234e:	89 d0                	mov    %edx,%eax
  802350:	8d 50 04             	lea    0x4(%eax),%edx
  802353:	83 38 00             	cmpl   $0x0,(%eax)
  802356:	75 f5                	jne    80234d <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802358:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  80235f:	83 e0 f0             	and    $0xfffffff0,%eax
  802362:	29 c4                	sub    %eax,%esp
  802364:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802368:	83 e7 f0             	and    $0xfffffff0,%edi
  80236b:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  80236d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802370:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802372:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802379:	00 

	va_start(vl, arg0);
  80237a:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80237d:	b8 00 00 00 00       	mov    $0x0,%eax
  802382:	eb 09                	jmp    80238d <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802384:	40                   	inc    %eax
  802385:	8b 1a                	mov    (%edx),%ebx
  802387:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  80238a:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80238d:	39 c8                	cmp    %ecx,%eax
  80238f:	75 f3                	jne    802384 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802395:	8b 45 08             	mov    0x8(%ebp),%eax
  802398:	89 04 24             	mov    %eax,(%esp)
  80239b:	e8 cc f9 ff ff       	call   801d6c <spawn>
}
  8023a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023a3:	5b                   	pop    %ebx
  8023a4:	5e                   	pop    %esi
  8023a5:	5f                   	pop    %edi
  8023a6:	5d                   	pop    %ebp
  8023a7:	c3                   	ret    

008023a8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	56                   	push   %esi
  8023ac:	53                   	push   %ebx
  8023ad:	83 ec 10             	sub    $0x10,%esp
  8023b0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b6:	89 04 24             	mov    %eax,(%esp)
  8023b9:	e8 ca f0 ff ff       	call   801488 <fd2data>
  8023be:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8023c0:	c7 44 24 04 4e 33 80 	movl   $0x80334e,0x4(%esp)
  8023c7:	00 
  8023c8:	89 34 24             	mov    %esi,(%esp)
  8023cb:	e8 03 e5 ff ff       	call   8008d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8023d0:	8b 43 04             	mov    0x4(%ebx),%eax
  8023d3:	2b 03                	sub    (%ebx),%eax
  8023d5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8023db:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8023e2:	00 00 00 
	stat->st_dev = &devpipe;
  8023e5:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  8023ec:	40 80 00 
	return 0;
}
  8023ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	5b                   	pop    %ebx
  8023f8:	5e                   	pop    %esi
  8023f9:	5d                   	pop    %ebp
  8023fa:	c3                   	ret    

008023fb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023fb:	55                   	push   %ebp
  8023fc:	89 e5                	mov    %esp,%ebp
  8023fe:	53                   	push   %ebx
  8023ff:	83 ec 14             	sub    $0x14,%esp
  802402:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802405:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802409:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802410:	e8 57 e9 ff ff       	call   800d6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802415:	89 1c 24             	mov    %ebx,(%esp)
  802418:	e8 6b f0 ff ff       	call   801488 <fd2data>
  80241d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802421:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802428:	e8 3f e9 ff ff       	call   800d6c <sys_page_unmap>
}
  80242d:	83 c4 14             	add    $0x14,%esp
  802430:	5b                   	pop    %ebx
  802431:	5d                   	pop    %ebp
  802432:	c3                   	ret    

00802433 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802433:	55                   	push   %ebp
  802434:	89 e5                	mov    %esp,%ebp
  802436:	57                   	push   %edi
  802437:	56                   	push   %esi
  802438:	53                   	push   %ebx
  802439:	83 ec 2c             	sub    $0x2c,%esp
  80243c:	89 c7                	mov    %eax,%edi
  80243e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802441:	a1 04 50 80 00       	mov    0x805004,%eax
  802446:	8b 00                	mov    (%eax),%eax
  802448:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80244b:	89 3c 24             	mov    %edi,(%esp)
  80244e:	e8 ad 06 00 00       	call   802b00 <pageref>
  802453:	89 c6                	mov    %eax,%esi
  802455:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802458:	89 04 24             	mov    %eax,(%esp)
  80245b:	e8 a0 06 00 00       	call   802b00 <pageref>
  802460:	39 c6                	cmp    %eax,%esi
  802462:	0f 94 c0             	sete   %al
  802465:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802468:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80246e:	8b 12                	mov    (%edx),%edx
  802470:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802473:	39 cb                	cmp    %ecx,%ebx
  802475:	75 08                	jne    80247f <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802477:	83 c4 2c             	add    $0x2c,%esp
  80247a:	5b                   	pop    %ebx
  80247b:	5e                   	pop    %esi
  80247c:	5f                   	pop    %edi
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80247f:	83 f8 01             	cmp    $0x1,%eax
  802482:	75 bd                	jne    802441 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802484:	8b 42 58             	mov    0x58(%edx),%eax
  802487:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80248e:	00 
  80248f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802493:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802497:	c7 04 24 55 33 80 00 	movl   $0x803355,(%esp)
  80249e:	e8 85 de ff ff       	call   800328 <cprintf>
  8024a3:	eb 9c                	jmp    802441 <_pipeisclosed+0xe>

008024a5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024a5:	55                   	push   %ebp
  8024a6:	89 e5                	mov    %esp,%ebp
  8024a8:	57                   	push   %edi
  8024a9:	56                   	push   %esi
  8024aa:	53                   	push   %ebx
  8024ab:	83 ec 1c             	sub    $0x1c,%esp
  8024ae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024b1:	89 34 24             	mov    %esi,(%esp)
  8024b4:	e8 cf ef ff ff       	call   801488 <fd2data>
  8024b9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8024c0:	eb 3c                	jmp    8024fe <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024c2:	89 da                	mov    %ebx,%edx
  8024c4:	89 f0                	mov    %esi,%eax
  8024c6:	e8 68 ff ff ff       	call   802433 <_pipeisclosed>
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	75 38                	jne    802507 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8024cf:	e8 d2 e7 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8024d7:	8b 13                	mov    (%ebx),%edx
  8024d9:	83 c2 20             	add    $0x20,%edx
  8024dc:	39 d0                	cmp    %edx,%eax
  8024de:	73 e2                	jae    8024c2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8024e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024e3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8024e6:	89 c2                	mov    %eax,%edx
  8024e8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8024ee:	79 05                	jns    8024f5 <devpipe_write+0x50>
  8024f0:	4a                   	dec    %edx
  8024f1:	83 ca e0             	or     $0xffffffe0,%edx
  8024f4:	42                   	inc    %edx
  8024f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024f9:	40                   	inc    %eax
  8024fa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024fd:	47                   	inc    %edi
  8024fe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802501:	75 d1                	jne    8024d4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802503:	89 f8                	mov    %edi,%eax
  802505:	eb 05                	jmp    80250c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802507:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    

00802514 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802514:	55                   	push   %ebp
  802515:	89 e5                	mov    %esp,%ebp
  802517:	57                   	push   %edi
  802518:	56                   	push   %esi
  802519:	53                   	push   %ebx
  80251a:	83 ec 1c             	sub    $0x1c,%esp
  80251d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802520:	89 3c 24             	mov    %edi,(%esp)
  802523:	e8 60 ef ff ff       	call   801488 <fd2data>
  802528:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80252a:	be 00 00 00 00       	mov    $0x0,%esi
  80252f:	eb 3a                	jmp    80256b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802531:	85 f6                	test   %esi,%esi
  802533:	74 04                	je     802539 <devpipe_read+0x25>
				return i;
  802535:	89 f0                	mov    %esi,%eax
  802537:	eb 40                	jmp    802579 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802539:	89 da                	mov    %ebx,%edx
  80253b:	89 f8                	mov    %edi,%eax
  80253d:	e8 f1 fe ff ff       	call   802433 <_pipeisclosed>
  802542:	85 c0                	test   %eax,%eax
  802544:	75 2e                	jne    802574 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802546:	e8 5b e7 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80254b:	8b 03                	mov    (%ebx),%eax
  80254d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802550:	74 df                	je     802531 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802552:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802557:	79 05                	jns    80255e <devpipe_read+0x4a>
  802559:	48                   	dec    %eax
  80255a:	83 c8 e0             	or     $0xffffffe0,%eax
  80255d:	40                   	inc    %eax
  80255e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802562:	8b 55 0c             	mov    0xc(%ebp),%edx
  802565:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802568:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80256a:	46                   	inc    %esi
  80256b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80256e:	75 db                	jne    80254b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802570:	89 f0                	mov    %esi,%eax
  802572:	eb 05                	jmp    802579 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802574:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802579:	83 c4 1c             	add    $0x1c,%esp
  80257c:	5b                   	pop    %ebx
  80257d:	5e                   	pop    %esi
  80257e:	5f                   	pop    %edi
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    

00802581 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802581:	55                   	push   %ebp
  802582:	89 e5                	mov    %esp,%ebp
  802584:	57                   	push   %edi
  802585:	56                   	push   %esi
  802586:	53                   	push   %ebx
  802587:	83 ec 3c             	sub    $0x3c,%esp
  80258a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80258d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802590:	89 04 24             	mov    %eax,(%esp)
  802593:	e8 0b ef ff ff       	call   8014a3 <fd_alloc>
  802598:	89 c3                	mov    %eax,%ebx
  80259a:	85 c0                	test   %eax,%eax
  80259c:	0f 88 45 01 00 00    	js     8026e7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025a9:	00 
  8025aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025b8:	e8 08 e7 ff ff       	call   800cc5 <sys_page_alloc>
  8025bd:	89 c3                	mov    %eax,%ebx
  8025bf:	85 c0                	test   %eax,%eax
  8025c1:	0f 88 20 01 00 00    	js     8026e7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8025c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8025ca:	89 04 24             	mov    %eax,(%esp)
  8025cd:	e8 d1 ee ff ff       	call   8014a3 <fd_alloc>
  8025d2:	89 c3                	mov    %eax,%ebx
  8025d4:	85 c0                	test   %eax,%eax
  8025d6:	0f 88 f8 00 00 00    	js     8026d4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025dc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025e3:	00 
  8025e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025f2:	e8 ce e6 ff ff       	call   800cc5 <sys_page_alloc>
  8025f7:	89 c3                	mov    %eax,%ebx
  8025f9:	85 c0                	test   %eax,%eax
  8025fb:	0f 88 d3 00 00 00    	js     8026d4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802601:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802604:	89 04 24             	mov    %eax,(%esp)
  802607:	e8 7c ee ff ff       	call   801488 <fd2data>
  80260c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80260e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802615:	00 
  802616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80261a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802621:	e8 9f e6 ff ff       	call   800cc5 <sys_page_alloc>
  802626:	89 c3                	mov    %eax,%ebx
  802628:	85 c0                	test   %eax,%eax
  80262a:	0f 88 91 00 00 00    	js     8026c1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802630:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802633:	89 04 24             	mov    %eax,(%esp)
  802636:	e8 4d ee ff ff       	call   801488 <fd2data>
  80263b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802642:	00 
  802643:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802647:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80264e:	00 
  80264f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802653:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265a:	e8 ba e6 ff ff       	call   800d19 <sys_page_map>
  80265f:	89 c3                	mov    %eax,%ebx
  802661:	85 c0                	test   %eax,%eax
  802663:	78 4c                	js     8026b1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802665:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80266b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80266e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802673:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80267a:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802680:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802683:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802685:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802688:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80268f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802692:	89 04 24             	mov    %eax,(%esp)
  802695:	e8 de ed ff ff       	call   801478 <fd2num>
  80269a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80269c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80269f:	89 04 24             	mov    %eax,(%esp)
  8026a2:	e8 d1 ed ff ff       	call   801478 <fd2num>
  8026a7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8026aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026af:	eb 36                	jmp    8026e7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8026b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026bc:	e8 ab e6 ff ff       	call   800d6c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8026c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026cf:	e8 98 e6 ff ff       	call   800d6c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8026d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026e2:	e8 85 e6 ff ff       	call   800d6c <sys_page_unmap>
    err:
	return r;
}
  8026e7:	89 d8                	mov    %ebx,%eax
  8026e9:	83 c4 3c             	add    $0x3c,%esp
  8026ec:	5b                   	pop    %ebx
  8026ed:	5e                   	pop    %esi
  8026ee:	5f                   	pop    %edi
  8026ef:	5d                   	pop    %ebp
  8026f0:	c3                   	ret    

008026f1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8026f1:	55                   	push   %ebp
  8026f2:	89 e5                	mov    %esp,%ebp
  8026f4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802701:	89 04 24             	mov    %eax,(%esp)
  802704:	e8 ed ed ff ff       	call   8014f6 <fd_lookup>
  802709:	85 c0                	test   %eax,%eax
  80270b:	78 15                	js     802722 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80270d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802710:	89 04 24             	mov    %eax,(%esp)
  802713:	e8 70 ed ff ff       	call   801488 <fd2data>
	return _pipeisclosed(fd, p);
  802718:	89 c2                	mov    %eax,%edx
  80271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271d:	e8 11 fd ff ff       	call   802433 <_pipeisclosed>
}
  802722:	c9                   	leave  
  802723:	c3                   	ret    

00802724 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802724:	55                   	push   %ebp
  802725:	89 e5                	mov    %esp,%ebp
  802727:	56                   	push   %esi
  802728:	53                   	push   %ebx
  802729:	83 ec 10             	sub    $0x10,%esp
  80272c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80272f:	85 f6                	test   %esi,%esi
  802731:	75 24                	jne    802757 <wait+0x33>
  802733:	c7 44 24 0c 6d 33 80 	movl   $0x80336d,0xc(%esp)
  80273a:	00 
  80273b:	c7 44 24 08 87 32 80 	movl   $0x803287,0x8(%esp)
  802742:	00 
  802743:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80274a:	00 
  80274b:	c7 04 24 78 33 80 00 	movl   $0x803378,(%esp)
  802752:	e8 d9 da ff ff       	call   800230 <_panic>
	e = &envs[ENVX(envid)];
  802757:	89 f3                	mov    %esi,%ebx
  802759:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80275f:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  802766:	c1 e3 07             	shl    $0x7,%ebx
  802769:	29 c3                	sub    %eax,%ebx
  80276b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802771:	eb 05                	jmp    802778 <wait+0x54>
		sys_yield();
  802773:	e8 2e e5 ff ff       	call   800ca6 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802778:	8b 43 48             	mov    0x48(%ebx),%eax
  80277b:	39 f0                	cmp    %esi,%eax
  80277d:	75 07                	jne    802786 <wait+0x62>
  80277f:	8b 43 54             	mov    0x54(%ebx),%eax
  802782:	85 c0                	test   %eax,%eax
  802784:	75 ed                	jne    802773 <wait+0x4f>
		sys_yield();
}
  802786:	83 c4 10             	add    $0x10,%esp
  802789:	5b                   	pop    %ebx
  80278a:	5e                   	pop    %esi
  80278b:	5d                   	pop    %ebp
  80278c:	c3                   	ret    
  80278d:	00 00                	add    %al,(%eax)
	...

00802790 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802790:	55                   	push   %ebp
  802791:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802793:	b8 00 00 00 00       	mov    $0x0,%eax
  802798:	5d                   	pop    %ebp
  802799:	c3                   	ret    

0080279a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80279a:	55                   	push   %ebp
  80279b:	89 e5                	mov    %esp,%ebp
  80279d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8027a0:	c7 44 24 04 83 33 80 	movl   $0x803383,0x4(%esp)
  8027a7:	00 
  8027a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ab:	89 04 24             	mov    %eax,(%esp)
  8027ae:	e8 20 e1 ff ff       	call   8008d3 <strcpy>
	return 0;
}
  8027b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8027b8:	c9                   	leave  
  8027b9:	c3                   	ret    

008027ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027ba:	55                   	push   %ebp
  8027bb:	89 e5                	mov    %esp,%ebp
  8027bd:	57                   	push   %edi
  8027be:	56                   	push   %esi
  8027bf:	53                   	push   %ebx
  8027c0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027d1:	eb 30                	jmp    802803 <devcons_write+0x49>
		m = n - tot;
  8027d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8027d6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8027d8:	83 fe 7f             	cmp    $0x7f,%esi
  8027db:	76 05                	jbe    8027e2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8027dd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8027e2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027e6:	03 45 0c             	add    0xc(%ebp),%eax
  8027e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ed:	89 3c 24             	mov    %edi,(%esp)
  8027f0:	e8 57 e2 ff ff       	call   800a4c <memmove>
		sys_cputs(buf, m);
  8027f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027f9:	89 3c 24             	mov    %edi,(%esp)
  8027fc:	e8 f7 e3 ff ff       	call   800bf8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802801:	01 f3                	add    %esi,%ebx
  802803:	89 d8                	mov    %ebx,%eax
  802805:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802808:	72 c9                	jb     8027d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80280a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802810:	5b                   	pop    %ebx
  802811:	5e                   	pop    %esi
  802812:	5f                   	pop    %edi
  802813:	5d                   	pop    %ebp
  802814:	c3                   	ret    

00802815 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802815:	55                   	push   %ebp
  802816:	89 e5                	mov    %esp,%ebp
  802818:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80281b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80281f:	75 07                	jne    802828 <devcons_read+0x13>
  802821:	eb 25                	jmp    802848 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802823:	e8 7e e4 ff ff       	call   800ca6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802828:	e8 e9 e3 ff ff       	call   800c16 <sys_cgetc>
  80282d:	85 c0                	test   %eax,%eax
  80282f:	74 f2                	je     802823 <devcons_read+0xe>
  802831:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802833:	85 c0                	test   %eax,%eax
  802835:	78 1d                	js     802854 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802837:	83 f8 04             	cmp    $0x4,%eax
  80283a:	74 13                	je     80284f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80283c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80283f:	88 10                	mov    %dl,(%eax)
	return 1;
  802841:	b8 01 00 00 00       	mov    $0x1,%eax
  802846:	eb 0c                	jmp    802854 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802848:	b8 00 00 00 00       	mov    $0x0,%eax
  80284d:	eb 05                	jmp    802854 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80284f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802854:	c9                   	leave  
  802855:	c3                   	ret    

00802856 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802856:	55                   	push   %ebp
  802857:	89 e5                	mov    %esp,%ebp
  802859:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80285c:	8b 45 08             	mov    0x8(%ebp),%eax
  80285f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802862:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802869:	00 
  80286a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80286d:	89 04 24             	mov    %eax,(%esp)
  802870:	e8 83 e3 ff ff       	call   800bf8 <sys_cputs>
}
  802875:	c9                   	leave  
  802876:	c3                   	ret    

00802877 <getchar>:

int
getchar(void)
{
  802877:	55                   	push   %ebp
  802878:	89 e5                	mov    %esp,%ebp
  80287a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80287d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802884:	00 
  802885:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80288c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802893:	e8 fc ee ff ff       	call   801794 <read>
	if (r < 0)
  802898:	85 c0                	test   %eax,%eax
  80289a:	78 0f                	js     8028ab <getchar+0x34>
		return r;
	if (r < 1)
  80289c:	85 c0                	test   %eax,%eax
  80289e:	7e 06                	jle    8028a6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8028a0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8028a4:	eb 05                	jmp    8028ab <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8028a6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8028ab:	c9                   	leave  
  8028ac:	c3                   	ret    

008028ad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8028ad:	55                   	push   %ebp
  8028ae:	89 e5                	mov    %esp,%ebp
  8028b0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8028bd:	89 04 24             	mov    %eax,(%esp)
  8028c0:	e8 31 ec ff ff       	call   8014f6 <fd_lookup>
  8028c5:	85 c0                	test   %eax,%eax
  8028c7:	78 11                	js     8028da <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028cc:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8028d2:	39 10                	cmp    %edx,(%eax)
  8028d4:	0f 94 c0             	sete   %al
  8028d7:	0f b6 c0             	movzbl %al,%eax
}
  8028da:	c9                   	leave  
  8028db:	c3                   	ret    

008028dc <opencons>:

int
opencons(void)
{
  8028dc:	55                   	push   %ebp
  8028dd:	89 e5                	mov    %esp,%ebp
  8028df:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028e5:	89 04 24             	mov    %eax,(%esp)
  8028e8:	e8 b6 eb ff ff       	call   8014a3 <fd_alloc>
  8028ed:	85 c0                	test   %eax,%eax
  8028ef:	78 3c                	js     80292d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028f1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028f8:	00 
  8028f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802900:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802907:	e8 b9 e3 ff ff       	call   800cc5 <sys_page_alloc>
  80290c:	85 c0                	test   %eax,%eax
  80290e:	78 1d                	js     80292d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802910:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802919:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80291b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80291e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802925:	89 04 24             	mov    %eax,(%esp)
  802928:	e8 4b eb ff ff       	call   801478 <fd2num>
}
  80292d:	c9                   	leave  
  80292e:	c3                   	ret    
	...

00802930 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802930:	55                   	push   %ebp
  802931:	89 e5                	mov    %esp,%ebp
  802933:	53                   	push   %ebx
  802934:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802937:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80293e:	75 6f                	jne    8029af <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  802940:	e8 42 e3 ff ff       	call   800c87 <sys_getenvid>
  802945:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  802947:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80294e:	00 
  80294f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802956:	ee 
  802957:	89 04 24             	mov    %eax,(%esp)
  80295a:	e8 66 e3 ff ff       	call   800cc5 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  80295f:	85 c0                	test   %eax,%eax
  802961:	79 1c                	jns    80297f <set_pgfault_handler+0x4f>
  802963:	c7 44 24 08 90 33 80 	movl   $0x803390,0x8(%esp)
  80296a:	00 
  80296b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802972:	00 
  802973:	c7 04 24 ec 33 80 00 	movl   $0x8033ec,(%esp)
  80297a:	e8 b1 d8 ff ff       	call   800230 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80297f:	c7 44 24 04 c0 29 80 	movl   $0x8029c0,0x4(%esp)
  802986:	00 
  802987:	89 1c 24             	mov    %ebx,(%esp)
  80298a:	e8 d6 e4 ff ff       	call   800e65 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80298f:	85 c0                	test   %eax,%eax
  802991:	79 1c                	jns    8029af <set_pgfault_handler+0x7f>
  802993:	c7 44 24 08 b8 33 80 	movl   $0x8033b8,0x8(%esp)
  80299a:	00 
  80299b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8029a2:	00 
  8029a3:	c7 04 24 ec 33 80 00 	movl   $0x8033ec,(%esp)
  8029aa:	e8 81 d8 ff ff       	call   800230 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8029af:	8b 45 08             	mov    0x8(%ebp),%eax
  8029b2:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8029b7:	83 c4 14             	add    $0x14,%esp
  8029ba:	5b                   	pop    %ebx
  8029bb:	5d                   	pop    %ebp
  8029bc:	c3                   	ret    
  8029bd:	00 00                	add    %al,(%eax)
	...

008029c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8029c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8029c1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8029c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8029c8:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8029cb:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8029cf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8029d4:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8029d8:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8029da:	83 c4 08             	add    $0x8,%esp
	popal
  8029dd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8029de:	83 c4 04             	add    $0x4,%esp
	popfl
  8029e1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8029e2:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8029e5:	c3                   	ret    
	...

008029e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8029e8:	55                   	push   %ebp
  8029e9:	89 e5                	mov    %esp,%ebp
  8029eb:	56                   	push   %esi
  8029ec:	53                   	push   %ebx
  8029ed:	83 ec 10             	sub    $0x10,%esp
  8029f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8029f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029f6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8029f9:	85 c0                	test   %eax,%eax
  8029fb:	75 05                	jne    802a02 <ipc_recv+0x1a>
  8029fd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802a02:	89 04 24             	mov    %eax,(%esp)
  802a05:	e8 d1 e4 ff ff       	call   800edb <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  802a0a:	85 c0                	test   %eax,%eax
  802a0c:	79 16                	jns    802a24 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802a0e:	85 db                	test   %ebx,%ebx
  802a10:	74 06                	je     802a18 <ipc_recv+0x30>
  802a12:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  802a18:	85 f6                	test   %esi,%esi
  802a1a:	74 32                	je     802a4e <ipc_recv+0x66>
  802a1c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802a22:	eb 2a                	jmp    802a4e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802a24:	85 db                	test   %ebx,%ebx
  802a26:	74 0c                	je     802a34 <ipc_recv+0x4c>
  802a28:	a1 04 50 80 00       	mov    0x805004,%eax
  802a2d:	8b 00                	mov    (%eax),%eax
  802a2f:	8b 40 74             	mov    0x74(%eax),%eax
  802a32:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802a34:	85 f6                	test   %esi,%esi
  802a36:	74 0c                	je     802a44 <ipc_recv+0x5c>
  802a38:	a1 04 50 80 00       	mov    0x805004,%eax
  802a3d:	8b 00                	mov    (%eax),%eax
  802a3f:	8b 40 78             	mov    0x78(%eax),%eax
  802a42:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  802a44:	a1 04 50 80 00       	mov    0x805004,%eax
  802a49:	8b 00                	mov    (%eax),%eax
  802a4b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  802a4e:	83 c4 10             	add    $0x10,%esp
  802a51:	5b                   	pop    %ebx
  802a52:	5e                   	pop    %esi
  802a53:	5d                   	pop    %ebp
  802a54:	c3                   	ret    

00802a55 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a55:	55                   	push   %ebp
  802a56:	89 e5                	mov    %esp,%ebp
  802a58:	57                   	push   %edi
  802a59:	56                   	push   %esi
  802a5a:	53                   	push   %ebx
  802a5b:	83 ec 1c             	sub    $0x1c,%esp
  802a5e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a64:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802a67:	85 db                	test   %ebx,%ebx
  802a69:	75 05                	jne    802a70 <ipc_send+0x1b>
  802a6b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  802a70:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802a74:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a7f:	89 04 24             	mov    %eax,(%esp)
  802a82:	e8 31 e4 ff ff       	call   800eb8 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  802a87:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a8a:	75 07                	jne    802a93 <ipc_send+0x3e>
  802a8c:	e8 15 e2 ff ff       	call   800ca6 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  802a91:	eb dd                	jmp    802a70 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  802a93:	85 c0                	test   %eax,%eax
  802a95:	79 1c                	jns    802ab3 <ipc_send+0x5e>
  802a97:	c7 44 24 08 fa 33 80 	movl   $0x8033fa,0x8(%esp)
  802a9e:	00 
  802a9f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802aa6:	00 
  802aa7:	c7 04 24 0c 34 80 00 	movl   $0x80340c,(%esp)
  802aae:	e8 7d d7 ff ff       	call   800230 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802ab3:	83 c4 1c             	add    $0x1c,%esp
  802ab6:	5b                   	pop    %ebx
  802ab7:	5e                   	pop    %esi
  802ab8:	5f                   	pop    %edi
  802ab9:	5d                   	pop    %ebp
  802aba:	c3                   	ret    

00802abb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802abb:	55                   	push   %ebp
  802abc:	89 e5                	mov    %esp,%ebp
  802abe:	53                   	push   %ebx
  802abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802ac7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802ace:	89 c2                	mov    %eax,%edx
  802ad0:	c1 e2 07             	shl    $0x7,%edx
  802ad3:	29 ca                	sub    %ecx,%edx
  802ad5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802adb:	8b 52 50             	mov    0x50(%edx),%edx
  802ade:	39 da                	cmp    %ebx,%edx
  802ae0:	75 0f                	jne    802af1 <ipc_find_env+0x36>
			return envs[i].env_id;
  802ae2:	c1 e0 07             	shl    $0x7,%eax
  802ae5:	29 c8                	sub    %ecx,%eax
  802ae7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802aec:	8b 40 40             	mov    0x40(%eax),%eax
  802aef:	eb 0c                	jmp    802afd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802af1:	40                   	inc    %eax
  802af2:	3d 00 04 00 00       	cmp    $0x400,%eax
  802af7:	75 ce                	jne    802ac7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802af9:	66 b8 00 00          	mov    $0x0,%ax
}
  802afd:	5b                   	pop    %ebx
  802afe:	5d                   	pop    %ebp
  802aff:	c3                   	ret    

00802b00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802b00:	55                   	push   %ebp
  802b01:	89 e5                	mov    %esp,%ebp
  802b03:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  802b06:	89 c2                	mov    %eax,%edx
  802b08:	c1 ea 16             	shr    $0x16,%edx
  802b0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802b12:	f6 c2 01             	test   $0x1,%dl
  802b15:	74 1e                	je     802b35 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802b17:	c1 e8 0c             	shr    $0xc,%eax
  802b1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802b21:	a8 01                	test   $0x1,%al
  802b23:	74 17                	je     802b3c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802b25:	c1 e8 0c             	shr    $0xc,%eax
  802b28:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802b2f:	ef 
  802b30:	0f b7 c0             	movzwl %ax,%eax
  802b33:	eb 0c                	jmp    802b41 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802b35:	b8 00 00 00 00       	mov    $0x0,%eax
  802b3a:	eb 05                	jmp    802b41 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802b3c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802b41:	5d                   	pop    %ebp
  802b42:	c3                   	ret    
	...

00802b44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802b44:	55                   	push   %ebp
  802b45:	57                   	push   %edi
  802b46:	56                   	push   %esi
  802b47:	83 ec 10             	sub    $0x10,%esp
  802b4a:	8b 74 24 20          	mov    0x20(%esp),%esi
  802b4e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802b52:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b56:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802b5a:	89 cd                	mov    %ecx,%ebp
  802b5c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802b60:	85 c0                	test   %eax,%eax
  802b62:	75 2c                	jne    802b90 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802b64:	39 f9                	cmp    %edi,%ecx
  802b66:	77 68                	ja     802bd0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b68:	85 c9                	test   %ecx,%ecx
  802b6a:	75 0b                	jne    802b77 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b6c:	b8 01 00 00 00       	mov    $0x1,%eax
  802b71:	31 d2                	xor    %edx,%edx
  802b73:	f7 f1                	div    %ecx
  802b75:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b77:	31 d2                	xor    %edx,%edx
  802b79:	89 f8                	mov    %edi,%eax
  802b7b:	f7 f1                	div    %ecx
  802b7d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b7f:	89 f0                	mov    %esi,%eax
  802b81:	f7 f1                	div    %ecx
  802b83:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b85:	89 f0                	mov    %esi,%eax
  802b87:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b89:	83 c4 10             	add    $0x10,%esp
  802b8c:	5e                   	pop    %esi
  802b8d:	5f                   	pop    %edi
  802b8e:	5d                   	pop    %ebp
  802b8f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b90:	39 f8                	cmp    %edi,%eax
  802b92:	77 2c                	ja     802bc0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b94:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802b97:	83 f6 1f             	xor    $0x1f,%esi
  802b9a:	75 4c                	jne    802be8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b9c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b9e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802ba3:	72 0a                	jb     802baf <__udivdi3+0x6b>
  802ba5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802ba9:	0f 87 ad 00 00 00    	ja     802c5c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802baf:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802bb4:	89 f0                	mov    %esi,%eax
  802bb6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802bb8:	83 c4 10             	add    $0x10,%esp
  802bbb:	5e                   	pop    %esi
  802bbc:	5f                   	pop    %edi
  802bbd:	5d                   	pop    %ebp
  802bbe:	c3                   	ret    
  802bbf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802bc0:	31 ff                	xor    %edi,%edi
  802bc2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802bc4:	89 f0                	mov    %esi,%eax
  802bc6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802bc8:	83 c4 10             	add    $0x10,%esp
  802bcb:	5e                   	pop    %esi
  802bcc:	5f                   	pop    %edi
  802bcd:	5d                   	pop    %ebp
  802bce:	c3                   	ret    
  802bcf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802bd0:	89 fa                	mov    %edi,%edx
  802bd2:	89 f0                	mov    %esi,%eax
  802bd4:	f7 f1                	div    %ecx
  802bd6:	89 c6                	mov    %eax,%esi
  802bd8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802bda:	89 f0                	mov    %esi,%eax
  802bdc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802bde:	83 c4 10             	add    $0x10,%esp
  802be1:	5e                   	pop    %esi
  802be2:	5f                   	pop    %edi
  802be3:	5d                   	pop    %ebp
  802be4:	c3                   	ret    
  802be5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802be8:	89 f1                	mov    %esi,%ecx
  802bea:	d3 e0                	shl    %cl,%eax
  802bec:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802bf0:	b8 20 00 00 00       	mov    $0x20,%eax
  802bf5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802bf7:	89 ea                	mov    %ebp,%edx
  802bf9:	88 c1                	mov    %al,%cl
  802bfb:	d3 ea                	shr    %cl,%edx
  802bfd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802c01:	09 ca                	or     %ecx,%edx
  802c03:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802c07:	89 f1                	mov    %esi,%ecx
  802c09:	d3 e5                	shl    %cl,%ebp
  802c0b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802c0f:	89 fd                	mov    %edi,%ebp
  802c11:	88 c1                	mov    %al,%cl
  802c13:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802c15:	89 fa                	mov    %edi,%edx
  802c17:	89 f1                	mov    %esi,%ecx
  802c19:	d3 e2                	shl    %cl,%edx
  802c1b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802c1f:	88 c1                	mov    %al,%cl
  802c21:	d3 ef                	shr    %cl,%edi
  802c23:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802c25:	89 f8                	mov    %edi,%eax
  802c27:	89 ea                	mov    %ebp,%edx
  802c29:	f7 74 24 08          	divl   0x8(%esp)
  802c2d:	89 d1                	mov    %edx,%ecx
  802c2f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802c31:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c35:	39 d1                	cmp    %edx,%ecx
  802c37:	72 17                	jb     802c50 <__udivdi3+0x10c>
  802c39:	74 09                	je     802c44 <__udivdi3+0x100>
  802c3b:	89 fe                	mov    %edi,%esi
  802c3d:	31 ff                	xor    %edi,%edi
  802c3f:	e9 41 ff ff ff       	jmp    802b85 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802c44:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c48:	89 f1                	mov    %esi,%ecx
  802c4a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c4c:	39 c2                	cmp    %eax,%edx
  802c4e:	73 eb                	jae    802c3b <__udivdi3+0xf7>
		{
		  q0--;
  802c50:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802c53:	31 ff                	xor    %edi,%edi
  802c55:	e9 2b ff ff ff       	jmp    802b85 <__udivdi3+0x41>
  802c5a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802c5c:	31 f6                	xor    %esi,%esi
  802c5e:	e9 22 ff ff ff       	jmp    802b85 <__udivdi3+0x41>
	...

00802c64 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802c64:	55                   	push   %ebp
  802c65:	57                   	push   %edi
  802c66:	56                   	push   %esi
  802c67:	83 ec 20             	sub    $0x20,%esp
  802c6a:	8b 44 24 30          	mov    0x30(%esp),%eax
  802c6e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802c72:	89 44 24 14          	mov    %eax,0x14(%esp)
  802c76:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802c7a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802c7e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802c82:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802c84:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802c86:	85 ed                	test   %ebp,%ebp
  802c88:	75 16                	jne    802ca0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802c8a:	39 f1                	cmp    %esi,%ecx
  802c8c:	0f 86 a6 00 00 00    	jbe    802d38 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802c92:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802c94:	89 d0                	mov    %edx,%eax
  802c96:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802c98:	83 c4 20             	add    $0x20,%esp
  802c9b:	5e                   	pop    %esi
  802c9c:	5f                   	pop    %edi
  802c9d:	5d                   	pop    %ebp
  802c9e:	c3                   	ret    
  802c9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802ca0:	39 f5                	cmp    %esi,%ebp
  802ca2:	0f 87 ac 00 00 00    	ja     802d54 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802ca8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802cab:	83 f0 1f             	xor    $0x1f,%eax
  802cae:	89 44 24 10          	mov    %eax,0x10(%esp)
  802cb2:	0f 84 a8 00 00 00    	je     802d60 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802cb8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802cbc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802cbe:	bf 20 00 00 00       	mov    $0x20,%edi
  802cc3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802cc7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ccb:	89 f9                	mov    %edi,%ecx
  802ccd:	d3 e8                	shr    %cl,%eax
  802ccf:	09 e8                	or     %ebp,%eax
  802cd1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802cd5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802cd9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802cdd:	d3 e0                	shl    %cl,%eax
  802cdf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ce3:	89 f2                	mov    %esi,%edx
  802ce5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802ce7:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ceb:	d3 e0                	shl    %cl,%eax
  802ced:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802cf1:	8b 44 24 14          	mov    0x14(%esp),%eax
  802cf5:	89 f9                	mov    %edi,%ecx
  802cf7:	d3 e8                	shr    %cl,%eax
  802cf9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802cfb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802cfd:	89 f2                	mov    %esi,%edx
  802cff:	f7 74 24 18          	divl   0x18(%esp)
  802d03:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802d05:	f7 64 24 0c          	mull   0xc(%esp)
  802d09:	89 c5                	mov    %eax,%ebp
  802d0b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802d0d:	39 d6                	cmp    %edx,%esi
  802d0f:	72 67                	jb     802d78 <__umoddi3+0x114>
  802d11:	74 75                	je     802d88 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802d13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802d17:	29 e8                	sub    %ebp,%eax
  802d19:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802d1b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802d1f:	d3 e8                	shr    %cl,%eax
  802d21:	89 f2                	mov    %esi,%edx
  802d23:	89 f9                	mov    %edi,%ecx
  802d25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802d27:	09 d0                	or     %edx,%eax
  802d29:	89 f2                	mov    %esi,%edx
  802d2b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802d2f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d31:	83 c4 20             	add    $0x20,%esp
  802d34:	5e                   	pop    %esi
  802d35:	5f                   	pop    %edi
  802d36:	5d                   	pop    %ebp
  802d37:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802d38:	85 c9                	test   %ecx,%ecx
  802d3a:	75 0b                	jne    802d47 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  802d41:	31 d2                	xor    %edx,%edx
  802d43:	f7 f1                	div    %ecx
  802d45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802d47:	89 f0                	mov    %esi,%eax
  802d49:	31 d2                	xor    %edx,%edx
  802d4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d4d:	89 f8                	mov    %edi,%eax
  802d4f:	e9 3e ff ff ff       	jmp    802c92 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802d54:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d56:	83 c4 20             	add    $0x20,%esp
  802d59:	5e                   	pop    %esi
  802d5a:	5f                   	pop    %edi
  802d5b:	5d                   	pop    %ebp
  802d5c:	c3                   	ret    
  802d5d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d60:	39 f5                	cmp    %esi,%ebp
  802d62:	72 04                	jb     802d68 <__umoddi3+0x104>
  802d64:	39 f9                	cmp    %edi,%ecx
  802d66:	77 06                	ja     802d6e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d68:	89 f2                	mov    %esi,%edx
  802d6a:	29 cf                	sub    %ecx,%edi
  802d6c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802d6e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802d70:	83 c4 20             	add    $0x20,%esp
  802d73:	5e                   	pop    %esi
  802d74:	5f                   	pop    %edi
  802d75:	5d                   	pop    %ebp
  802d76:	c3                   	ret    
  802d77:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802d78:	89 d1                	mov    %edx,%ecx
  802d7a:	89 c5                	mov    %eax,%ebp
  802d7c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802d80:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802d84:	eb 8d                	jmp    802d13 <__umoddi3+0xaf>
  802d86:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802d88:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802d8c:	72 ea                	jb     802d78 <__umoddi3+0x114>
  802d8e:	89 f1                	mov    %esi,%ecx
  802d90:	eb 81                	jmp    802d13 <__umoddi3+0xaf>
