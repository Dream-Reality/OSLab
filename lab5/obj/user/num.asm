
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 8f 01 00 00       	call   8001c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800043:	8d 5d e7             	lea    -0x19(%ebp),%ebx
  800046:	eb 7f                	jmp    8000c7 <num+0x93>
		if (bol) {
  800048:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004f:	74 25                	je     800076 <num+0x42>
			printf("%5d ", ++line);
  800051:	a1 00 40 80 00       	mov    0x804000,%eax
  800056:	40                   	inc    %eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 40 22 80 00 	movl   $0x802240,(%esp)
  800067:	e8 d1 18 00 00       	call   80193d <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 9f 12 00 00       	call   80132d <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 24                	je     8000b7 <num+0x83>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80009b:	c7 44 24 08 45 22 80 	movl   $0x802245,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000aa:	00 
  8000ab:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  8000b2:	e8 7d 01 00 00       	call   800234 <_panic>
		if (c == '\n')
  8000b7:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8000bb:	75 0a                	jne    8000c7 <num+0x93>
			bol = 1;
  8000bd:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c4:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000ce:	00 
  8000cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d3:	89 34 24             	mov    %esi,(%esp)
  8000d6:	e8 75 11 00 00       	call   801250 <read>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	0f 8f 65 ff ff ff    	jg     800048 <num+0x14>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	79 24                	jns    80010b <num+0xd7>
		panic("error reading %s: %e", s, n);
  8000e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000ef:	c7 44 24 08 6b 22 80 	movl   $0x80226b,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  800106:	e8 29 01 00 00       	call   800234 <_panic>
}
  80010b:	83 c4 3c             	add    $0x3c,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <umain>:

void
umain(int argc, char **argv)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 3c             	sub    $0x3c,%esp
	int f, i;

	binaryname = "num";
  80011c:	c7 05 04 30 80 00 80 	movl   $0x802280,0x803004
  800123:	22 80 00 
	if (argc == 1)
  800126:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012a:	74 0d                	je     800139 <umain+0x26>
	if (n < 0)
		panic("error reading %s: %e", s, n);
}

void
umain(int argc, char **argv)
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80012f:	83 c3 04             	add    $0x4,%ebx
  800132:	bf 01 00 00 00       	mov    $0x1,%edi
  800137:	eb 74                	jmp    8001ad <umain+0x9a>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800139:	c7 44 24 04 84 22 80 	movl   $0x802284,0x4(%esp)
  800140:	00 
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <num>
  80014d:	eb 63                	jmp    8001b2 <umain+0x9f>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80014f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800159:	00 
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 23 16 00 00       	call   801787 <open>
  800164:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	79 29                	jns    800193 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800171:	8b 02                	mov    (%edx),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	c7 44 24 08 8c 22 80 	movl   $0x80228c,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  80018e:	e8 a1 00 00 00       	call   800234 <_panic>
			else {
				num(f, argv[i]);
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <num>
				close(f);
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 43 0f 00 00       	call   8010ec <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001a9:	47                   	inc    %edi
  8001aa:	83 c3 04             	add    $0x4,%ebx
  8001ad:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b0:	7c 9d                	jl     80014f <umain+0x3c>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001b2:	e8 61 00 00 00       	call   800218 <exit>
}
  8001b7:	83 c4 3c             	add    $0x3c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    
	...

008001c0 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 20             	sub    $0x20,%esp
  8001c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8001ce:	e8 b8 0a 00 00       	call   800c8b <sys_getenvid>
  8001d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001df:	c1 e0 07             	shl    $0x7,%eax
  8001e2:	29 d0                	sub    %edx,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	a3 08 40 80 00       	mov    %eax,0x804008
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f4:	85 f6                	test   %esi,%esi
  8001f6:	7e 07                	jle    8001ff <libmain+0x3f>
		binaryname = argv[0];
  8001f8:	8b 03                	mov    (%ebx),%eax
  8001fa:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800203:	89 34 24             	mov    %esi,(%esp)
  800206:	e8 08 ff ff ff       	call   800113 <umain>

	// exit gracefully
	exit();
  80020b:	e8 08 00 00 00       	call   800218 <exit>
}
  800210:	83 c4 20             	add    $0x20,%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    
	...

00800218 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80021e:	e8 fa 0e 00 00       	call   80111d <close_all>
	sys_env_destroy(0);
  800223:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80022a:	e8 0a 0a 00 00       	call   800c39 <sys_env_destroy>
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    
  800231:	00 00                	add    %al,(%eax)
	...

00800234 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80023c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023f:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800245:	e8 41 0a 00 00       	call   800c8b <sys_getenvid>
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800251:	8b 55 08             	mov    0x8(%ebp),%edx
  800254:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800258:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80025c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800260:	c7 04 24 a8 22 80 00 	movl   $0x8022a8,(%esp)
  800267:	e8 c0 00 00 00       	call   80032c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800270:	8b 45 10             	mov    0x10(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	e8 50 00 00 00       	call   8002cb <vcprintf>
	cprintf("\n");
  80027b:	c7 04 24 ea 26 80 00 	movl   $0x8026ea,(%esp)
  800282:	e8 a5 00 00 00       	call   80032c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x53>
	...

0080028c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	53                   	push   %ebx
  800290:	83 ec 14             	sub    $0x14,%esp
  800293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800296:	8b 03                	mov    (%ebx),%eax
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029f:	40                   	inc    %eax
  8002a0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 19                	jne    8002c2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002b0:	00 
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 40 09 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  8002bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002c2:	ff 43 04             	incl   0x4(%ebx)
}
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002db:	00 00 00 
	b.cnt = 0;
  8002de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800300:	c7 04 24 8c 02 80 00 	movl   $0x80028c,(%esp)
  800307:	e8 82 01 00 00       	call   80048e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800312:	89 44 24 04          	mov    %eax,0x4(%esp)
  800316:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	e8 d8 08 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  800324:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800332:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	e8 87 ff ff ff       	call   8002cb <vcprintf>
	va_end(ap);

	return cnt;
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    
	...

00800348 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	83 ec 3c             	sub    $0x3c,%esp
  800351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800354:	89 d7                	mov    %edx,%edi
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80035c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800362:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800365:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800368:	85 c0                	test   %eax,%eax
  80036a:	75 08                	jne    800374 <printnum+0x2c>
  80036c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800372:	77 57                	ja     8003cb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800374:	89 74 24 10          	mov    %esi,0x10(%esp)
  800378:	4b                   	dec    %ebx
  800379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80037d:	8b 45 10             	mov    0x10(%ebp),%eax
  800380:	89 44 24 08          	mov    %eax,0x8(%esp)
  800384:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800388:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80038c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800393:	00 
  800394:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a1:	e8 32 1c 00 00       	call   801fd8 <__udivdi3>
  8003a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b5:	89 fa                	mov    %edi,%edx
  8003b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ba:	e8 89 ff ff ff       	call   800348 <printnum>
  8003bf:	eb 0f                	jmp    8003d0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c5:	89 34 24             	mov    %esi,(%esp)
  8003c8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003cb:	4b                   	dec    %ebx
  8003cc:	85 db                	test   %ebx,%ebx
  8003ce:	7f f1                	jg     8003c1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e6:	00 
  8003e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f4:	e8 ff 1c 00 00       	call   8020f8 <__umoddi3>
  8003f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fd:	0f be 80 cb 22 80 00 	movsbl 0x8022cb(%eax),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80040a:	83 c4 3c             	add    $0x3c,%esp
  80040d:	5b                   	pop    %ebx
  80040e:	5e                   	pop    %esi
  80040f:	5f                   	pop    %edi
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800415:	83 fa 01             	cmp    $0x1,%edx
  800418:	7e 0e                	jle    800428 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80041a:	8b 10                	mov    (%eax),%edx
  80041c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041f:	89 08                	mov    %ecx,(%eax)
  800421:	8b 02                	mov    (%edx),%eax
  800423:	8b 52 04             	mov    0x4(%edx),%edx
  800426:	eb 22                	jmp    80044a <getuint+0x38>
	else if (lflag)
  800428:	85 d2                	test   %edx,%edx
  80042a:	74 10                	je     80043c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80042c:	8b 10                	mov    (%eax),%edx
  80042e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800431:	89 08                	mov    %ecx,(%eax)
  800433:	8b 02                	mov    (%edx),%eax
  800435:	ba 00 00 00 00       	mov    $0x0,%edx
  80043a:	eb 0e                	jmp    80044a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800452:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800455:	8b 10                	mov    (%eax),%edx
  800457:	3b 50 04             	cmp    0x4(%eax),%edx
  80045a:	73 08                	jae    800464 <sprintputch+0x18>
		*b->buf++ = ch;
  80045c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045f:	88 0a                	mov    %cl,(%edx)
  800461:	42                   	inc    %edx
  800462:	89 10                	mov    %edx,(%eax)
}
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80046c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800473:	8b 45 10             	mov    0x10(%ebp),%eax
  800476:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800481:	8b 45 08             	mov    0x8(%ebp),%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	e8 02 00 00 00       	call   80048e <vprintfmt>
	va_end(ap);
}
  80048c:	c9                   	leave  
  80048d:	c3                   	ret    

0080048e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	57                   	push   %edi
  800492:	56                   	push   %esi
  800493:	53                   	push   %ebx
  800494:	83 ec 4c             	sub    $0x4c,%esp
  800497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049a:	8b 75 10             	mov    0x10(%ebp),%esi
  80049d:	eb 12                	jmp    8004b1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	0f 84 6b 03 00 00    	je     800812 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b1:	0f b6 06             	movzbl (%esi),%eax
  8004b4:	46                   	inc    %esi
  8004b5:	83 f8 25             	cmp    $0x25,%eax
  8004b8:	75 e5                	jne    80049f <vprintfmt+0x11>
  8004ba:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004be:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004ca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d6:	eb 26                	jmp    8004fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004db:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004df:	eb 1d                	jmp    8004fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e8:	eb 14                	jmp    8004fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f4:	eb 08                	jmp    8004fe <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	0f b6 06             	movzbl (%esi),%eax
  800501:	8d 56 01             	lea    0x1(%esi),%edx
  800504:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800507:	8a 16                	mov    (%esi),%dl
  800509:	83 ea 23             	sub    $0x23,%edx
  80050c:	80 fa 55             	cmp    $0x55,%dl
  80050f:	0f 87 e1 02 00 00    	ja     8007f6 <vprintfmt+0x368>
  800515:	0f b6 d2             	movzbl %dl,%edx
  800518:	ff 24 95 00 24 80 00 	jmp    *0x802400(,%edx,4)
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800522:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800527:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80052a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80052e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800531:	8d 50 d0             	lea    -0x30(%eax),%edx
  800534:	83 fa 09             	cmp    $0x9,%edx
  800537:	77 2a                	ja     800563 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800539:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80053a:	eb eb                	jmp    800527 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 04             	lea    0x4(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80054a:	eb 17                	jmp    800563 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80054c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800550:	78 98                	js     8004ea <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800555:	eb a7                	jmp    8004fe <vprintfmt+0x70>
  800557:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80055a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800561:	eb 9b                	jmp    8004fe <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800567:	79 95                	jns    8004fe <vprintfmt+0x70>
  800569:	eb 8b                	jmp    8004f6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056f:	eb 8d                	jmp    8004fe <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800589:	e9 23 ff ff ff       	jmp    8004b1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 02                	jns    80059f <vprintfmt+0x111>
  80059d:	f7 d8                	neg    %eax
  80059f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a1:	83 f8 0f             	cmp    $0xf,%eax
  8005a4:	7f 0b                	jg     8005b1 <vprintfmt+0x123>
  8005a6:	8b 04 85 60 25 80 00 	mov    0x802560(,%eax,4),%eax
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	75 23                	jne    8005d4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b5:	c7 44 24 08 e3 22 80 	movl   $0x8022e3,0x8(%esp)
  8005bc:	00 
  8005bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	e8 9a fe ff ff       	call   800466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cf:	e9 dd fe ff ff       	jmp    8004b1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d8:	c7 44 24 08 95 26 80 	movl   $0x802695,0x8(%esp)
  8005df:	00 
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e7:	89 14 24             	mov    %edx,(%esp)
  8005ea:	e8 77 fe ff ff       	call   800466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f2:	e9 ba fe ff ff       	jmp    8004b1 <vprintfmt+0x23>
  8005f7:	89 f9                	mov    %edi,%ecx
  8005f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 30                	mov    (%eax),%esi
  80060a:	85 f6                	test   %esi,%esi
  80060c:	75 05                	jne    800613 <vprintfmt+0x185>
				p = "(null)";
  80060e:	be dc 22 80 00       	mov    $0x8022dc,%esi
			if (width > 0 && padc != '-')
  800613:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800617:	0f 8e 84 00 00 00    	jle    8006a1 <vprintfmt+0x213>
  80061d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800621:	74 7e                	je     8006a1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800623:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800627:	89 34 24             	mov    %esi,(%esp)
  80062a:	e8 8b 02 00 00       	call   8008ba <strnlen>
  80062f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800632:	29 c2                	sub    %eax,%edx
  800634:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800637:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80063b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80063e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800641:	89 de                	mov    %ebx,%esi
  800643:	89 d3                	mov    %edx,%ebx
  800645:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800647:	eb 0b                	jmp    800654 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064d:	89 3c 24             	mov    %edi,(%esp)
  800650:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800653:	4b                   	dec    %ebx
  800654:	85 db                	test   %ebx,%ebx
  800656:	7f f1                	jg     800649 <vprintfmt+0x1bb>
  800658:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80065b:	89 f3                	mov    %esi,%ebx
  80065d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800663:	85 c0                	test   %eax,%eax
  800665:	79 05                	jns    80066c <vprintfmt+0x1de>
  800667:	b8 00 00 00 00       	mov    $0x0,%eax
  80066c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066f:	29 c2                	sub    %eax,%edx
  800671:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800674:	eb 2b                	jmp    8006a1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800676:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067a:	74 18                	je     800694 <vprintfmt+0x206>
  80067c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80067f:	83 fa 5e             	cmp    $0x5e,%edx
  800682:	76 10                	jbe    800694 <vprintfmt+0x206>
					putch('?', putdat);
  800684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800688:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
  800692:	eb 0a                	jmp    80069e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	89 04 24             	mov    %eax,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069e:	ff 4d e4             	decl   -0x1c(%ebp)
  8006a1:	0f be 06             	movsbl (%esi),%eax
  8006a4:	46                   	inc    %esi
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	74 21                	je     8006ca <vprintfmt+0x23c>
  8006a9:	85 ff                	test   %edi,%edi
  8006ab:	78 c9                	js     800676 <vprintfmt+0x1e8>
  8006ad:	4f                   	dec    %edi
  8006ae:	79 c6                	jns    800676 <vprintfmt+0x1e8>
  8006b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b3:	89 de                	mov    %ebx,%esi
  8006b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b8:	eb 18                	jmp    8006d2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c7:	4b                   	dec    %ebx
  8006c8:	eb 08                	jmp    8006d2 <vprintfmt+0x244>
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	89 de                	mov    %ebx,%esi
  8006cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006d2:	85 db                	test   %ebx,%ebx
  8006d4:	7f e4                	jg     8006ba <vprintfmt+0x22c>
  8006d6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006de:	e9 ce fd ff ff       	jmp    8004b1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e3:	83 f9 01             	cmp    $0x1,%ecx
  8006e6:	7e 10                	jle    8006f8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 08             	lea    0x8(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 30                	mov    (%eax),%esi
  8006f3:	8b 78 04             	mov    0x4(%eax),%edi
  8006f6:	eb 26                	jmp    80071e <vprintfmt+0x290>
	else if (lflag)
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	74 12                	je     80070e <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 30                	mov    (%eax),%esi
  800707:	89 f7                	mov    %esi,%edi
  800709:	c1 ff 1f             	sar    $0x1f,%edi
  80070c:	eb 10                	jmp    80071e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8d 50 04             	lea    0x4(%eax),%edx
  800714:	89 55 14             	mov    %edx,0x14(%ebp)
  800717:	8b 30                	mov    (%eax),%esi
  800719:	89 f7                	mov    %esi,%edi
  80071b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071e:	85 ff                	test   %edi,%edi
  800720:	78 0a                	js     80072c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800722:	b8 0a 00 00 00       	mov    $0xa,%eax
  800727:	e9 8c 00 00 00       	jmp    8007b8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80072c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800730:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800737:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80073a:	f7 de                	neg    %esi
  80073c:	83 d7 00             	adc    $0x0,%edi
  80073f:	f7 df                	neg    %edi
			}
			base = 10;
  800741:	b8 0a 00 00 00       	mov    $0xa,%eax
  800746:	eb 70                	jmp    8007b8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800748:	89 ca                	mov    %ecx,%edx
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
  80074d:	e8 c0 fc ff ff       	call   800412 <getuint>
  800752:	89 c6                	mov    %eax,%esi
  800754:	89 d7                	mov    %edx,%edi
			base = 10;
  800756:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80075b:	eb 5b                	jmp    8007b8 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80075d:	89 ca                	mov    %ecx,%edx
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 ab fc ff ff       	call   800412 <getuint>
  800767:	89 c6                	mov    %eax,%esi
  800769:	89 d7                	mov    %edx,%edi
			base = 8;
  80076b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800770:	eb 46                	jmp    8007b8 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800776:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80077d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800784:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8d 50 04             	lea    0x4(%eax),%edx
  800794:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800797:	8b 30                	mov    (%eax),%esi
  800799:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007a3:	eb 13                	jmp    8007b8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a5:	89 ca                	mov    %ecx,%edx
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007aa:	e8 63 fc ff ff       	call   800412 <getuint>
  8007af:	89 c6                	mov    %eax,%esi
  8007b1:	89 d7                	mov    %edx,%edi
			base = 16;
  8007b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cb:	89 34 24             	mov    %esi,(%esp)
  8007ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d2:	89 da                	mov    %ebx,%edx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	e8 6c fb ff ff       	call   800348 <printnum>
			break;
  8007dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007df:	e9 cd fc ff ff       	jmp    8004b1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e8:	89 04 24             	mov    %eax,(%esp)
  8007eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f1:	e9 bb fc ff ff       	jmp    8004b1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800801:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800804:	eb 01                	jmp    800807 <vprintfmt+0x379>
  800806:	4e                   	dec    %esi
  800807:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80080b:	75 f9                	jne    800806 <vprintfmt+0x378>
  80080d:	e9 9f fc ff ff       	jmp    8004b1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800812:	83 c4 4c             	add    $0x4c,%esp
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5f                   	pop    %edi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	83 ec 28             	sub    $0x28,%esp
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800826:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800829:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800830:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800837:	85 c0                	test   %eax,%eax
  800839:	74 30                	je     80086b <vsnprintf+0x51>
  80083b:	85 d2                	test   %edx,%edx
  80083d:	7e 33                	jle    800872 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
  800849:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800850:	89 44 24 04          	mov    %eax,0x4(%esp)
  800854:	c7 04 24 4c 04 80 00 	movl   $0x80044c,(%esp)
  80085b:	e8 2e fc ff ff       	call   80048e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800860:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800863:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800869:	eb 0c                	jmp    800877 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80086b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800870:	eb 05                	jmp    800877 <vsnprintf+0x5d>
  800872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800882:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800886:	8b 45 10             	mov    0x10(%ebp),%eax
  800889:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	89 04 24             	mov    %eax,(%esp)
  80089a:	e8 7b ff ff ff       	call   80081a <vsnprintf>
	va_end(ap);

	return rc;
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    
  8008a1:	00 00                	add    %al,(%eax)
	...

008008a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb 01                	jmp    8008b2 <strlen+0xe>
		n++;
  8008b1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b6:	75 f9                	jne    8008b1 <strlen+0xd>
		n++;
	return n;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 01                	jmp    8008cb <strnlen+0x11>
		n++;
  8008ca:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cb:	39 d0                	cmp    %edx,%eax
  8008cd:	74 06                	je     8008d5 <strnlen+0x1b>
  8008cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d3:	75 f5                	jne    8008ca <strnlen+0x10>
		n++;
	return n;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008ec:	42                   	inc    %edx
  8008ed:	84 c9                	test   %cl,%cl
  8008ef:	75 f5                	jne    8008e6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	53                   	push   %ebx
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fe:	89 1c 24             	mov    %ebx,(%esp)
  800901:	e8 9e ff ff ff       	call   8008a4 <strlen>
	strcpy(dst + len, src);
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
  800909:	89 54 24 04          	mov    %edx,0x4(%esp)
  80090d:	01 d8                	add    %ebx,%eax
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	e8 c0 ff ff ff       	call   8008d7 <strcpy>
	return dst;
}
  800917:	89 d8                	mov    %ebx,%eax
  800919:	83 c4 08             	add    $0x8,%esp
  80091c:	5b                   	pop    %ebx
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	eb 0c                	jmp    800940 <strncpy+0x21>
		*dst++ = *src;
  800934:	8a 1a                	mov    (%edx),%bl
  800936:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800939:	80 3a 01             	cmpb   $0x1,(%edx)
  80093c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093f:	41                   	inc    %ecx
  800940:	39 f1                	cmp    %esi,%ecx
  800942:	75 f0                	jne    800934 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 75 08             	mov    0x8(%ebp),%esi
  800950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800953:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800956:	85 d2                	test   %edx,%edx
  800958:	75 0a                	jne    800964 <strlcpy+0x1c>
  80095a:	89 f0                	mov    %esi,%eax
  80095c:	eb 1a                	jmp    800978 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095e:	88 18                	mov    %bl,(%eax)
  800960:	40                   	inc    %eax
  800961:	41                   	inc    %ecx
  800962:	eb 02                	jmp    800966 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800964:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800966:	4a                   	dec    %edx
  800967:	74 0a                	je     800973 <strlcpy+0x2b>
  800969:	8a 19                	mov    (%ecx),%bl
  80096b:	84 db                	test   %bl,%bl
  80096d:	75 ef                	jne    80095e <strlcpy+0x16>
  80096f:	89 c2                	mov    %eax,%edx
  800971:	eb 02                	jmp    800975 <strlcpy+0x2d>
  800973:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800975:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800978:	29 f0                	sub    %esi,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800987:	eb 02                	jmp    80098b <strcmp+0xd>
		p++, q++;
  800989:	41                   	inc    %ecx
  80098a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80098b:	8a 01                	mov    (%ecx),%al
  80098d:	84 c0                	test   %al,%al
  80098f:	74 04                	je     800995 <strcmp+0x17>
  800991:	3a 02                	cmp    (%edx),%al
  800993:	74 f4                	je     800989 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800995:	0f b6 c0             	movzbl %al,%eax
  800998:	0f b6 12             	movzbl (%edx),%edx
  80099b:	29 d0                	sub    %edx,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009ac:	eb 03                	jmp    8009b1 <strncmp+0x12>
		n--, p++, q++;
  8009ae:	4a                   	dec    %edx
  8009af:	40                   	inc    %eax
  8009b0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b1:	85 d2                	test   %edx,%edx
  8009b3:	74 14                	je     8009c9 <strncmp+0x2a>
  8009b5:	8a 18                	mov    (%eax),%bl
  8009b7:	84 db                	test   %bl,%bl
  8009b9:	74 04                	je     8009bf <strncmp+0x20>
  8009bb:	3a 19                	cmp    (%ecx),%bl
  8009bd:	74 ef                	je     8009ae <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bf:	0f b6 00             	movzbl (%eax),%eax
  8009c2:	0f b6 11             	movzbl (%ecx),%edx
  8009c5:	29 d0                	sub    %edx,%eax
  8009c7:	eb 05                	jmp    8009ce <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009da:	eb 05                	jmp    8009e1 <strchr+0x10>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	74 0c                	je     8009ec <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e0:	40                   	inc    %eax
  8009e1:	8a 10                	mov    (%eax),%dl
  8009e3:	84 d2                	test   %dl,%dl
  8009e5:	75 f5                	jne    8009dc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f7:	eb 05                	jmp    8009fe <strfind+0x10>
		if (*s == c)
  8009f9:	38 ca                	cmp    %cl,%dl
  8009fb:	74 07                	je     800a04 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009fd:	40                   	inc    %eax
  8009fe:	8a 10                	mov    (%eax),%dl
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f5                	jne    8009f9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a15:	85 c9                	test   %ecx,%ecx
  800a17:	74 30                	je     800a49 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1f:	75 25                	jne    800a46 <memset+0x40>
  800a21:	f6 c1 03             	test   $0x3,%cl
  800a24:	75 20                	jne    800a46 <memset+0x40>
		c &= 0xFF;
  800a26:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a29:	89 d3                	mov    %edx,%ebx
  800a2b:	c1 e3 08             	shl    $0x8,%ebx
  800a2e:	89 d6                	mov    %edx,%esi
  800a30:	c1 e6 18             	shl    $0x18,%esi
  800a33:	89 d0                	mov    %edx,%eax
  800a35:	c1 e0 10             	shl    $0x10,%eax
  800a38:	09 f0                	or     %esi,%eax
  800a3a:	09 d0                	or     %edx,%eax
  800a3c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a41:	fc                   	cld    
  800a42:	f3 ab                	rep stos %eax,%es:(%edi)
  800a44:	eb 03                	jmp    800a49 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a46:	fc                   	cld    
  800a47:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a49:	89 f8                	mov    %edi,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5e:	39 c6                	cmp    %eax,%esi
  800a60:	73 34                	jae    800a96 <memmove+0x46>
  800a62:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a65:	39 d0                	cmp    %edx,%eax
  800a67:	73 2d                	jae    800a96 <memmove+0x46>
		s += n;
		d += n;
  800a69:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6c:	f6 c2 03             	test   $0x3,%dl
  800a6f:	75 1b                	jne    800a8c <memmove+0x3c>
  800a71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a77:	75 13                	jne    800a8c <memmove+0x3c>
  800a79:	f6 c1 03             	test   $0x3,%cl
  800a7c:	75 0e                	jne    800a8c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7e:	83 ef 04             	sub    $0x4,%edi
  800a81:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a84:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a87:	fd                   	std    
  800a88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8a:	eb 07                	jmp    800a93 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a8c:	4f                   	dec    %edi
  800a8d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a90:	fd                   	std    
  800a91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a93:	fc                   	cld    
  800a94:	eb 20                	jmp    800ab6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9c:	75 13                	jne    800ab1 <memmove+0x61>
  800a9e:	a8 03                	test   $0x3,%al
  800aa0:	75 0f                	jne    800ab1 <memmove+0x61>
  800aa2:	f6 c1 03             	test   $0x3,%cl
  800aa5:	75 0a                	jne    800ab1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	fc                   	cld    
  800aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aaf:	eb 05                	jmp    800ab6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	fc                   	cld    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	89 04 24             	mov    %eax,(%esp)
  800ad4:	e8 77 ff ff ff       	call   800a50 <memmove>
}
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	eb 16                	jmp    800b07 <memcmp+0x2c>
		if (*s1 != *s2)
  800af1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800af4:	42                   	inc    %edx
  800af5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800af9:	38 c8                	cmp    %cl,%al
  800afb:	74 0a                	je     800b07 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800afd:	0f b6 c0             	movzbl %al,%eax
  800b00:	0f b6 c9             	movzbl %cl,%ecx
  800b03:	29 c8                	sub    %ecx,%eax
  800b05:	eb 09                	jmp    800b10 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b07:	39 da                	cmp    %ebx,%edx
  800b09:	75 e6                	jne    800af1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b23:	eb 05                	jmp    800b2a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b25:	38 08                	cmp    %cl,(%eax)
  800b27:	74 05                	je     800b2e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b29:	40                   	inc    %eax
  800b2a:	39 d0                	cmp    %edx,%eax
  800b2c:	72 f7                	jb     800b25 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3c:	eb 01                	jmp    800b3f <strtol+0xf>
		s++;
  800b3e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3f:	8a 02                	mov    (%edx),%al
  800b41:	3c 20                	cmp    $0x20,%al
  800b43:	74 f9                	je     800b3e <strtol+0xe>
  800b45:	3c 09                	cmp    $0x9,%al
  800b47:	74 f5                	je     800b3e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b49:	3c 2b                	cmp    $0x2b,%al
  800b4b:	75 08                	jne    800b55 <strtol+0x25>
		s++;
  800b4d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b53:	eb 13                	jmp    800b68 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b55:	3c 2d                	cmp    $0x2d,%al
  800b57:	75 0a                	jne    800b63 <strtol+0x33>
		s++, neg = 1;
  800b59:	8d 52 01             	lea    0x1(%edx),%edx
  800b5c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b61:	eb 05                	jmp    800b68 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	74 05                	je     800b71 <strtol+0x41>
  800b6c:	83 fb 10             	cmp    $0x10,%ebx
  800b6f:	75 28                	jne    800b99 <strtol+0x69>
  800b71:	8a 02                	mov    (%edx),%al
  800b73:	3c 30                	cmp    $0x30,%al
  800b75:	75 10                	jne    800b87 <strtol+0x57>
  800b77:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7b:	75 0a                	jne    800b87 <strtol+0x57>
		s += 2, base = 16;
  800b7d:	83 c2 02             	add    $0x2,%edx
  800b80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b85:	eb 12                	jmp    800b99 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b87:	85 db                	test   %ebx,%ebx
  800b89:	75 0e                	jne    800b99 <strtol+0x69>
  800b8b:	3c 30                	cmp    $0x30,%al
  800b8d:	75 05                	jne    800b94 <strtol+0x64>
		s++, base = 8;
  800b8f:	42                   	inc    %edx
  800b90:	b3 08                	mov    $0x8,%bl
  800b92:	eb 05                	jmp    800b99 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b94:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba0:	8a 0a                	mov    (%edx),%cl
  800ba2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba5:	80 fb 09             	cmp    $0x9,%bl
  800ba8:	77 08                	ja     800bb2 <strtol+0x82>
			dig = *s - '0';
  800baa:	0f be c9             	movsbl %cl,%ecx
  800bad:	83 e9 30             	sub    $0x30,%ecx
  800bb0:	eb 1e                	jmp    800bd0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bb2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb5:	80 fb 19             	cmp    $0x19,%bl
  800bb8:	77 08                	ja     800bc2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bba:	0f be c9             	movsbl %cl,%ecx
  800bbd:	83 e9 57             	sub    $0x57,%ecx
  800bc0:	eb 0e                	jmp    800bd0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bc2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc5:	80 fb 19             	cmp    $0x19,%bl
  800bc8:	77 12                	ja     800bdc <strtol+0xac>
			dig = *s - 'A' + 10;
  800bca:	0f be c9             	movsbl %cl,%ecx
  800bcd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bd0:	39 f1                	cmp    %esi,%ecx
  800bd2:	7d 0c                	jge    800be0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bd4:	42                   	inc    %edx
  800bd5:	0f af c6             	imul   %esi,%eax
  800bd8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bda:	eb c4                	jmp    800ba0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bdc:	89 c1                	mov    %eax,%ecx
  800bde:	eb 02                	jmp    800be2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800be2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be6:	74 05                	je     800bed <strtol+0xbd>
		*endptr = (char *) s;
  800be8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800beb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bed:	85 ff                	test   %edi,%edi
  800bef:	74 04                	je     800bf5 <strtol+0xc5>
  800bf1:	89 c8                	mov    %ecx,%eax
  800bf3:	f7 d8                	neg    %eax
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
	...

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	89 c6                	mov    %eax,%esi
  800c13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 28                	jle    800c83 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c66:	00 
  800c67:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800c7e:	e8 b1 f5 ff ff       	call   800234 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c83:	83 c4 2c             	add    $0x2c,%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	ba 00 00 00 00       	mov    $0x0,%edx
  800c96:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9b:	89 d1                	mov    %edx,%ecx
  800c9d:	89 d3                	mov    %edx,%ebx
  800c9f:	89 d7                	mov    %edx,%edi
  800ca1:	89 d6                	mov    %edx,%esi
  800ca3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_yield>:

void
sys_yield(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	be 00 00 00 00       	mov    $0x0,%esi
  800cd7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 f7                	mov    %esi,%edi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 28                	jle    800d15 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800d00:	00 
  800d01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d08:	00 
  800d09:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800d10:	e8 1f f5 ff ff       	call   800234 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d15:	83 c4 2c             	add    $0x2c,%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 28                	jle    800d68 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d44:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800d53:	00 
  800d54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5b:	00 
  800d5c:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800d63:	e8 cc f4 ff ff       	call   800234 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d68:	83 c4 2c             	add    $0x2c,%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 df                	mov    %ebx,%edi
  800d8b:	89 de                	mov    %ebx,%esi
  800d8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 28                	jle    800dbb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d97:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800da6:	00 
  800da7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dae:	00 
  800daf:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800db6:	e8 79 f4 ff ff       	call   800234 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dbb:	83 c4 2c             	add    $0x2c,%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800e09:	e8 26 f4 ff ff       	call   800234 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0e:	83 c4 2c             	add    $0x2c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e24:	b8 09 00 00 00       	mov    $0x9,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 df                	mov    %ebx,%edi
  800e31:	89 de                	mov    %ebx,%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800e5c:	e8 d3 f3 ff ff       	call   800234 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	89 df                	mov    %ebx,%edi
  800e84:	89 de                	mov    %ebx,%esi
  800e86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 28                	jle    800eb4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e90:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e97:	00 
  800e98:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800eaf:	e8 80 f3 ff ff       	call   800234 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb4:	83 c4 2c             	add    $0x2c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	be 00 00 00 00       	mov    $0x0,%esi
  800ec7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ecc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eed:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 cb                	mov    %ecx,%ebx
  800ef7:	89 cf                	mov    %ecx,%edi
  800ef9:	89 ce                	mov    %ecx,%esi
  800efb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	7e 28                	jle    800f29 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f05:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  800f14:	00 
  800f15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1c:	00 
  800f1d:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  800f24:	e8 0b f3 ff ff       	call   800234 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f29:	83 c4 2c             	add    $0x2c,%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    
  800f31:	00 00                	add    %al,(%eax)
	...

00800f34 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f3f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	e8 df ff ff ff       	call   800f34 <fd2num>
  800f55:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f5a:	c1 e0 0c             	shl    $0xc,%eax
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	53                   	push   %ebx
  800f63:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f66:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f6b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	c1 ea 16             	shr    $0x16,%edx
  800f72:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f79:	f6 c2 01             	test   $0x1,%dl
  800f7c:	74 11                	je     800f8f <fd_alloc+0x30>
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 0c             	shr    $0xc,%edx
  800f83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	75 09                	jne    800f98 <fd_alloc+0x39>
			*fd_store = fd;
  800f8f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
  800f96:	eb 17                	jmp    800faf <fd_alloc+0x50>
  800f98:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f9d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fa2:	75 c7                	jne    800f6b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fa4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800faa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fb8:	83 f8 1f             	cmp    $0x1f,%eax
  800fbb:	77 36                	ja     800ff3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fbd:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fc2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fc5:	89 c2                	mov    %eax,%edx
  800fc7:	c1 ea 16             	shr    $0x16,%edx
  800fca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fd1:	f6 c2 01             	test   $0x1,%dl
  800fd4:	74 24                	je     800ffa <fd_lookup+0x48>
  800fd6:	89 c2                	mov    %eax,%edx
  800fd8:	c1 ea 0c             	shr    $0xc,%edx
  800fdb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe2:	f6 c2 01             	test   $0x1,%dl
  800fe5:	74 1a                	je     801001 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fea:	89 02                	mov    %eax,(%edx)
	return 0;
  800fec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff1:	eb 13                	jmp    801006 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff8:	eb 0c                	jmp    801006 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ffa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fff:	eb 05                	jmp    801006 <fd_lookup+0x54>
  801001:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	53                   	push   %ebx
  80100c:	83 ec 14             	sub    $0x14,%esp
  80100f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801012:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801015:	ba 00 00 00 00       	mov    $0x0,%edx
  80101a:	eb 0e                	jmp    80102a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80101c:	39 08                	cmp    %ecx,(%eax)
  80101e:	75 09                	jne    801029 <dev_lookup+0x21>
			*dev = devtab[i];
  801020:	89 03                	mov    %eax,(%ebx)
			return 0;
  801022:	b8 00 00 00 00       	mov    $0x0,%eax
  801027:	eb 35                	jmp    80105e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801029:	42                   	inc    %edx
  80102a:	8b 04 95 6c 26 80 00 	mov    0x80266c(,%edx,4),%eax
  801031:	85 c0                	test   %eax,%eax
  801033:	75 e7                	jne    80101c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801035:	a1 08 40 80 00       	mov    0x804008,%eax
  80103a:	8b 00                	mov    (%eax),%eax
  80103c:	8b 40 48             	mov    0x48(%eax),%eax
  80103f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801043:	89 44 24 04          	mov    %eax,0x4(%esp)
  801047:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  80104e:	e8 d9 f2 ff ff       	call   80032c <cprintf>
	*dev = 0;
  801053:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801059:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80105e:	83 c4 14             	add    $0x14,%esp
  801061:	5b                   	pop    %ebx
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	83 ec 30             	sub    $0x30,%esp
  80106c:	8b 75 08             	mov    0x8(%ebp),%esi
  80106f:	8a 45 0c             	mov    0xc(%ebp),%al
  801072:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801075:	89 34 24             	mov    %esi,(%esp)
  801078:	e8 b7 fe ff ff       	call   800f34 <fd2num>
  80107d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801080:	89 54 24 04          	mov    %edx,0x4(%esp)
  801084:	89 04 24             	mov    %eax,(%esp)
  801087:	e8 26 ff ff ff       	call   800fb2 <fd_lookup>
  80108c:	89 c3                	mov    %eax,%ebx
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 05                	js     801097 <fd_close+0x33>
	    || fd != fd2)
  801092:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801095:	74 0d                	je     8010a4 <fd_close+0x40>
		return (must_exist ? r : 0);
  801097:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80109b:	75 46                	jne    8010e3 <fd_close+0x7f>
  80109d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a2:	eb 3f                	jmp    8010e3 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ab:	8b 06                	mov    (%esi),%eax
  8010ad:	89 04 24             	mov    %eax,(%esp)
  8010b0:	e8 53 ff ff ff       	call   801008 <dev_lookup>
  8010b5:	89 c3                	mov    %eax,%ebx
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 18                	js     8010d3 <fd_close+0x6f>
		if (dev->dev_close)
  8010bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010be:	8b 40 10             	mov    0x10(%eax),%eax
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	74 09                	je     8010ce <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010c5:	89 34 24             	mov    %esi,(%esp)
  8010c8:	ff d0                	call   *%eax
  8010ca:	89 c3                	mov    %eax,%ebx
  8010cc:	eb 05                	jmp    8010d3 <fd_close+0x6f>
		else
			r = 0;
  8010ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010de:	e8 8d fc ff ff       	call   800d70 <sys_page_unmap>
	return r;
}
  8010e3:	89 d8                	mov    %ebx,%eax
  8010e5:	83 c4 30             	add    $0x30,%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	89 04 24             	mov    %eax,(%esp)
  8010ff:	e8 ae fe ff ff       	call   800fb2 <fd_lookup>
  801104:	85 c0                	test   %eax,%eax
  801106:	78 13                	js     80111b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801108:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80110f:	00 
  801110:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801113:	89 04 24             	mov    %eax,(%esp)
  801116:	e8 49 ff ff ff       	call   801064 <fd_close>
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <close_all>:

void
close_all(void)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	53                   	push   %ebx
  801121:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801124:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801129:	89 1c 24             	mov    %ebx,(%esp)
  80112c:	e8 bb ff ff ff       	call   8010ec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801131:	43                   	inc    %ebx
  801132:	83 fb 20             	cmp    $0x20,%ebx
  801135:	75 f2                	jne    801129 <close_all+0xc>
		close(i);
}
  801137:	83 c4 14             	add    $0x14,%esp
  80113a:	5b                   	pop    %ebx
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 4c             	sub    $0x4c,%esp
  801146:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801149:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	89 04 24             	mov    %eax,(%esp)
  801156:	e8 57 fe ff ff       	call   800fb2 <fd_lookup>
  80115b:	89 c3                	mov    %eax,%ebx
  80115d:	85 c0                	test   %eax,%eax
  80115f:	0f 88 e1 00 00 00    	js     801246 <dup+0x109>
		return r;
	close(newfdnum);
  801165:	89 3c 24             	mov    %edi,(%esp)
  801168:	e8 7f ff ff ff       	call   8010ec <close>

	newfd = INDEX2FD(newfdnum);
  80116d:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801173:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801176:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801179:	89 04 24             	mov    %eax,(%esp)
  80117c:	e8 c3 fd ff ff       	call   800f44 <fd2data>
  801181:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801183:	89 34 24             	mov    %esi,(%esp)
  801186:	e8 b9 fd ff ff       	call   800f44 <fd2data>
  80118b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	c1 e8 16             	shr    $0x16,%eax
  801193:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80119a:	a8 01                	test   $0x1,%al
  80119c:	74 46                	je     8011e4 <dup+0xa7>
  80119e:	89 d8                	mov    %ebx,%eax
  8011a0:	c1 e8 0c             	shr    $0xc,%eax
  8011a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011aa:	f6 c2 01             	test   $0x1,%dl
  8011ad:	74 35                	je     8011e4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cd:	00 
  8011ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d9:	e8 3f fb ff ff       	call   800d1d <sys_page_map>
  8011de:	89 c3                	mov    %eax,%ebx
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 3b                	js     80121f <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011fd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801201:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801208:	00 
  801209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801214:	e8 04 fb ff ff       	call   800d1d <sys_page_map>
  801219:	89 c3                	mov    %eax,%ebx
  80121b:	85 c0                	test   %eax,%eax
  80121d:	79 25                	jns    801244 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80121f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801223:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122a:	e8 41 fb ff ff       	call   800d70 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80122f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123d:	e8 2e fb ff ff       	call   800d70 <sys_page_unmap>
	return r;
  801242:	eb 02                	jmp    801246 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801244:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801246:	89 d8                	mov    %ebx,%eax
  801248:	83 c4 4c             	add    $0x4c,%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	53                   	push   %ebx
  801254:	83 ec 24             	sub    $0x24,%esp
  801257:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	89 1c 24             	mov    %ebx,(%esp)
  801264:	e8 49 fd ff ff       	call   800fb2 <fd_lookup>
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 6f                	js     8012dc <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801270:	89 44 24 04          	mov    %eax,0x4(%esp)
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	8b 00                	mov    (%eax),%eax
  801279:	89 04 24             	mov    %eax,(%esp)
  80127c:	e8 87 fd ff ff       	call   801008 <dev_lookup>
  801281:	85 c0                	test   %eax,%eax
  801283:	78 57                	js     8012dc <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	8b 50 08             	mov    0x8(%eax),%edx
  80128b:	83 e2 03             	and    $0x3,%edx
  80128e:	83 fa 01             	cmp    $0x1,%edx
  801291:	75 25                	jne    8012b8 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801293:	a1 08 40 80 00       	mov    0x804008,%eax
  801298:	8b 00                	mov    (%eax),%eax
  80129a:	8b 40 48             	mov    0x48(%eax),%eax
  80129d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  8012ac:	e8 7b f0 ff ff       	call   80032c <cprintf>
		return -E_INVAL;
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	eb 24                	jmp    8012dc <read+0x8c>
	}
	if (!dev->dev_read)
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	8b 52 08             	mov    0x8(%edx),%edx
  8012be:	85 d2                	test   %edx,%edx
  8012c0:	74 15                	je     8012d7 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	ff d2                	call   *%edx
  8012d5:	eb 05                	jmp    8012dc <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012dc:	83 c4 24             	add    $0x24,%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 1c             	sub    $0x1c,%esp
  8012eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f6:	eb 23                	jmp    80131b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012f8:	89 f0                	mov    %esi,%eax
  8012fa:	29 d8                	sub    %ebx,%eax
  8012fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801300:	8b 45 0c             	mov    0xc(%ebp),%eax
  801303:	01 d8                	add    %ebx,%eax
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	89 3c 24             	mov    %edi,(%esp)
  80130c:	e8 3f ff ff ff       	call   801250 <read>
		if (m < 0)
  801311:	85 c0                	test   %eax,%eax
  801313:	78 10                	js     801325 <readn+0x43>
			return m;
		if (m == 0)
  801315:	85 c0                	test   %eax,%eax
  801317:	74 0a                	je     801323 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801319:	01 c3                	add    %eax,%ebx
  80131b:	39 f3                	cmp    %esi,%ebx
  80131d:	72 d9                	jb     8012f8 <readn+0x16>
  80131f:	89 d8                	mov    %ebx,%eax
  801321:	eb 02                	jmp    801325 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801323:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801325:	83 c4 1c             	add    $0x1c,%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 24             	sub    $0x24,%esp
  801334:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133e:	89 1c 24             	mov    %ebx,(%esp)
  801341:	e8 6c fc ff ff       	call   800fb2 <fd_lookup>
  801346:	85 c0                	test   %eax,%eax
  801348:	78 6a                	js     8013b4 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	8b 00                	mov    (%eax),%eax
  801356:	89 04 24             	mov    %eax,(%esp)
  801359:	e8 aa fc ff ff       	call   801008 <dev_lookup>
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 52                	js     8013b4 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801365:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801369:	75 25                	jne    801390 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80136b:	a1 08 40 80 00       	mov    0x804008,%eax
  801370:	8b 00                	mov    (%eax),%eax
  801372:	8b 40 48             	mov    0x48(%eax),%eax
  801375:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137d:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  801384:	e8 a3 ef ff ff       	call   80032c <cprintf>
		return -E_INVAL;
  801389:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138e:	eb 24                	jmp    8013b4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801393:	8b 52 0c             	mov    0xc(%edx),%edx
  801396:	85 d2                	test   %edx,%edx
  801398:	74 15                	je     8013af <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80139a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80139d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013a8:	89 04 24             	mov    %eax,(%esp)
  8013ab:	ff d2                	call   *%edx
  8013ad:	eb 05                	jmp    8013b4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013b4:	83 c4 24             	add    $0x24,%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	e8 e0 fb ff ff       	call   800fb2 <fd_lookup>
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 0e                	js     8013e4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e4:	c9                   	leave  
  8013e5:	c3                   	ret    

008013e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 24             	sub    $0x24,%esp
  8013ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f7:	89 1c 24             	mov    %ebx,(%esp)
  8013fa:	e8 b3 fb ff ff       	call   800fb2 <fd_lookup>
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 63                	js     801466 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801403:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	8b 00                	mov    (%eax),%eax
  80140f:	89 04 24             	mov    %eax,(%esp)
  801412:	e8 f1 fb ff ff       	call   801008 <dev_lookup>
  801417:	85 c0                	test   %eax,%eax
  801419:	78 4b                	js     801466 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801422:	75 25                	jne    801449 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801424:	a1 08 40 80 00       	mov    0x804008,%eax
  801429:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80142b:	8b 40 48             	mov    0x48(%eax),%eax
  80142e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801432:	89 44 24 04          	mov    %eax,0x4(%esp)
  801436:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  80143d:	e8 ea ee ff ff       	call   80032c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801447:	eb 1d                	jmp    801466 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801449:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80144c:	8b 52 18             	mov    0x18(%edx),%edx
  80144f:	85 d2                	test   %edx,%edx
  801451:	74 0e                	je     801461 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801453:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801456:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80145a:	89 04 24             	mov    %eax,(%esp)
  80145d:	ff d2                	call   *%edx
  80145f:	eb 05                	jmp    801466 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801461:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801466:	83 c4 24             	add    $0x24,%esp
  801469:	5b                   	pop    %ebx
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 24             	sub    $0x24,%esp
  801473:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801476:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	89 04 24             	mov    %eax,(%esp)
  801483:	e8 2a fb ff ff       	call   800fb2 <fd_lookup>
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 52                	js     8014de <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801496:	8b 00                	mov    (%eax),%eax
  801498:	89 04 24             	mov    %eax,(%esp)
  80149b:	e8 68 fb ff ff       	call   801008 <dev_lookup>
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 3a                	js     8014de <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014ab:	74 2c                	je     8014d9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014ad:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014b0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014b7:	00 00 00 
	stat->st_isdir = 0;
  8014ba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014c1:	00 00 00 
	stat->st_dev = dev;
  8014c4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d1:	89 14 24             	mov    %edx,(%esp)
  8014d4:	ff 50 14             	call   *0x14(%eax)
  8014d7:	eb 05                	jmp    8014de <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014de:	83 c4 24             	add    $0x24,%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014f3:	00 
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	89 04 24             	mov    %eax,(%esp)
  8014fa:	e8 88 02 00 00       	call   801787 <open>
  8014ff:	89 c3                	mov    %eax,%ebx
  801501:	85 c0                	test   %eax,%eax
  801503:	78 1b                	js     801520 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801505:	8b 45 0c             	mov    0xc(%ebp),%eax
  801508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150c:	89 1c 24             	mov    %ebx,(%esp)
  80150f:	e8 58 ff ff ff       	call   80146c <fstat>
  801514:	89 c6                	mov    %eax,%esi
	close(fd);
  801516:	89 1c 24             	mov    %ebx,(%esp)
  801519:	e8 ce fb ff ff       	call   8010ec <close>
	return r;
  80151e:	89 f3                	mov    %esi,%ebx
}
  801520:	89 d8                	mov    %ebx,%eax
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	5b                   	pop    %ebx
  801526:	5e                   	pop    %esi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    
  801529:	00 00                	add    %al,(%eax)
	...

0080152c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
  801531:	83 ec 10             	sub    $0x10,%esp
  801534:	89 c3                	mov    %eax,%ebx
  801536:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801538:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80153f:	75 11                	jne    801552 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801541:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801548:	e8 02 0a 00 00       	call   801f4f <ipc_find_env>
  80154d:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801552:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801559:	00 
  80155a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801561:	00 
  801562:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801566:	a1 04 40 80 00       	mov    0x804004,%eax
  80156b:	89 04 24             	mov    %eax,(%esp)
  80156e:	e8 76 09 00 00       	call   801ee9 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801573:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80157a:	00 
  80157b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801586:	e8 f1 08 00 00       	call   801e7c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801598:	8b 45 08             	mov    0x8(%ebp),%eax
  80159b:	8b 40 0c             	mov    0xc(%eax),%eax
  80159e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8015b5:	e8 72 ff ff ff       	call   80152c <fsipc>
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8015d7:	e8 50 ff ff ff       	call   80152c <fsipc>
}
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 14             	sub    $0x14,%esp
  8015e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8015fd:	e8 2a ff ff ff       	call   80152c <fsipc>
  801602:	85 c0                	test   %eax,%eax
  801604:	78 2b                	js     801631 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801606:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80160d:	00 
  80160e:	89 1c 24             	mov    %ebx,(%esp)
  801611:	e8 c1 f2 ff ff       	call   8008d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801616:	a1 80 50 80 00       	mov    0x805080,%eax
  80161b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801621:	a1 84 50 80 00       	mov    0x805084,%eax
  801626:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80162c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801631:	83 c4 14             	add    $0x14,%esp
  801634:	5b                   	pop    %ebx
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 14             	sub    $0x14,%esp
  80163e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	8b 40 0c             	mov    0xc(%eax),%eax
  801647:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  80164c:	89 d8                	mov    %ebx,%eax
  80164e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801654:	76 05                	jbe    80165b <devfile_write+0x24>
  801656:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80165b:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801660:	89 44 24 08          	mov    %eax,0x8(%esp)
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
  801667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801672:	e8 43 f4 ff ff       	call   800aba <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801677:	ba 00 00 00 00       	mov    $0x0,%edx
  80167c:	b8 04 00 00 00       	mov    $0x4,%eax
  801681:	e8 a6 fe ff ff       	call   80152c <fsipc>
  801686:	85 c0                	test   %eax,%eax
  801688:	78 53                	js     8016dd <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  80168a:	39 c3                	cmp    %eax,%ebx
  80168c:	73 24                	jae    8016b2 <devfile_write+0x7b>
  80168e:	c7 44 24 0c 7c 26 80 	movl   $0x80267c,0xc(%esp)
  801695:	00 
  801696:	c7 44 24 08 83 26 80 	movl   $0x802683,0x8(%esp)
  80169d:	00 
  80169e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8016a5:	00 
  8016a6:	c7 04 24 98 26 80 00 	movl   $0x802698,(%esp)
  8016ad:	e8 82 eb ff ff       	call   800234 <_panic>
	assert(r <= PGSIZE);
  8016b2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016b7:	7e 24                	jle    8016dd <devfile_write+0xa6>
  8016b9:	c7 44 24 0c a3 26 80 	movl   $0x8026a3,0xc(%esp)
  8016c0:	00 
  8016c1:	c7 44 24 08 83 26 80 	movl   $0x802683,0x8(%esp)
  8016c8:	00 
  8016c9:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8016d0:	00 
  8016d1:	c7 04 24 98 26 80 00 	movl   $0x802698,(%esp)
  8016d8:	e8 57 eb ff ff       	call   800234 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  8016dd:	83 c4 14             	add    $0x14,%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 10             	sub    $0x10,%esp
  8016eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 03 00 00 00       	mov    $0x3,%eax
  801709:	e8 1e fe ff ff       	call   80152c <fsipc>
  80170e:	89 c3                	mov    %eax,%ebx
  801710:	85 c0                	test   %eax,%eax
  801712:	78 6a                	js     80177e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801714:	39 c6                	cmp    %eax,%esi
  801716:	73 24                	jae    80173c <devfile_read+0x59>
  801718:	c7 44 24 0c 7c 26 80 	movl   $0x80267c,0xc(%esp)
  80171f:	00 
  801720:	c7 44 24 08 83 26 80 	movl   $0x802683,0x8(%esp)
  801727:	00 
  801728:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80172f:	00 
  801730:	c7 04 24 98 26 80 00 	movl   $0x802698,(%esp)
  801737:	e8 f8 ea ff ff       	call   800234 <_panic>
	assert(r <= PGSIZE);
  80173c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801741:	7e 24                	jle    801767 <devfile_read+0x84>
  801743:	c7 44 24 0c a3 26 80 	movl   $0x8026a3,0xc(%esp)
  80174a:	00 
  80174b:	c7 44 24 08 83 26 80 	movl   $0x802683,0x8(%esp)
  801752:	00 
  801753:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  80175a:	00 
  80175b:	c7 04 24 98 26 80 00 	movl   $0x802698,(%esp)
  801762:	e8 cd ea ff ff       	call   800234 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801772:	00 
  801773:	8b 45 0c             	mov    0xc(%ebp),%eax
  801776:	89 04 24             	mov    %eax,(%esp)
  801779:	e8 d2 f2 ff ff       	call   800a50 <memmove>
	return r;
}
  80177e:	89 d8                	mov    %ebx,%eax
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
  80178c:	83 ec 20             	sub    $0x20,%esp
  80178f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801792:	89 34 24             	mov    %esi,(%esp)
  801795:	e8 0a f1 ff ff       	call   8008a4 <strlen>
  80179a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80179f:	7f 60                	jg     801801 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a4:	89 04 24             	mov    %eax,(%esp)
  8017a7:	e8 b3 f7 ff ff       	call   800f5f <fd_alloc>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 54                	js     801806 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017bd:	e8 15 f1 ff ff       	call   8008d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d2:	e8 55 fd ff ff       	call   80152c <fsipc>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	79 15                	jns    8017f2 <open+0x6b>
		fd_close(fd, 0);
  8017dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017e4:	00 
  8017e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	e8 74 f8 ff ff       	call   801064 <fd_close>
		return r;
  8017f0:	eb 14                	jmp    801806 <open+0x7f>
	}

	return fd2num(fd);
  8017f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f5:	89 04 24             	mov    %eax,(%esp)
  8017f8:	e8 37 f7 ff ff       	call   800f34 <fd2num>
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	eb 05                	jmp    801806 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801801:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801806:	89 d8                	mov    %ebx,%eax
  801808:	83 c4 20             	add    $0x20,%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5e                   	pop    %esi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
  80181a:	b8 08 00 00 00       	mov    $0x8,%eax
  80181f:	e8 08 fd ff ff       	call   80152c <fsipc>
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    
	...

00801828 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	53                   	push   %ebx
  80182c:	83 ec 14             	sub    $0x14,%esp
  80182f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801831:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801835:	7e 32                	jle    801869 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801837:	8b 40 04             	mov    0x4(%eax),%eax
  80183a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183e:	8d 43 10             	lea    0x10(%ebx),%eax
  801841:	89 44 24 04          	mov    %eax,0x4(%esp)
  801845:	8b 03                	mov    (%ebx),%eax
  801847:	89 04 24             	mov    %eax,(%esp)
  80184a:	e8 de fa ff ff       	call   80132d <write>
		if (result > 0)
  80184f:	85 c0                	test   %eax,%eax
  801851:	7e 03                	jle    801856 <writebuf+0x2e>
			b->result += result;
  801853:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801856:	39 43 04             	cmp    %eax,0x4(%ebx)
  801859:	74 0e                	je     801869 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	85 c0                	test   %eax,%eax
  80185f:	7e 05                	jle    801866 <writebuf+0x3e>
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801869:	83 c4 14             	add    $0x14,%esp
  80186c:	5b                   	pop    %ebx
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <putch>:

static void
putch(int ch, void *thunk)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	53                   	push   %ebx
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801879:	8b 43 04             	mov    0x4(%ebx),%eax
  80187c:	8b 55 08             	mov    0x8(%ebp),%edx
  80187f:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801883:	40                   	inc    %eax
  801884:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801887:	3d 00 01 00 00       	cmp    $0x100,%eax
  80188c:	75 0e                	jne    80189c <putch+0x2d>
		writebuf(b);
  80188e:	89 d8                	mov    %ebx,%eax
  801890:	e8 93 ff ff ff       	call   801828 <writebuf>
		b->idx = 0;
  801895:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80189c:	83 c4 04             	add    $0x4,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018b4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018bb:	00 00 00 
	b.result = 0;
  8018be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018c5:	00 00 00 
	b.error = 1;
  8018c8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018cf:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  8018f1:	e8 98 eb ff ff       	call   80048e <vprintfmt>
	if (b.idx > 0)
  8018f6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018fd:	7e 0b                	jle    80190a <vfprintf+0x68>
		writebuf(&b);
  8018ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801905:	e8 1e ff ff ff       	call   801828 <writebuf>

	return (b.result ? b.result : b.error);
  80190a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801910:	85 c0                	test   %eax,%eax
  801912:	75 06                	jne    80191a <vfprintf+0x78>
  801914:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801922:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801925:	89 44 24 08          	mov    %eax,0x8(%esp)
  801929:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	89 04 24             	mov    %eax,(%esp)
  801936:	e8 67 ff ff ff       	call   8018a2 <vfprintf>
	va_end(ap);

	return cnt;
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <printf>:

int
printf(const char *fmt, ...)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801943:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801946:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801951:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801958:	e8 45 ff ff ff       	call   8018a2 <vfprintf>
	va_end(ap);

	return cnt;
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    
	...

00801960 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	83 ec 10             	sub    $0x10,%esp
  801968:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	89 04 24             	mov    %eax,(%esp)
  801971:	e8 ce f5 ff ff       	call   800f44 <fd2data>
  801976:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801978:	c7 44 24 04 af 26 80 	movl   $0x8026af,0x4(%esp)
  80197f:	00 
  801980:	89 34 24             	mov    %esi,(%esp)
  801983:	e8 4f ef ff ff       	call   8008d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801988:	8b 43 04             	mov    0x4(%ebx),%eax
  80198b:	2b 03                	sub    (%ebx),%eax
  80198d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801993:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80199a:	00 00 00 
	stat->st_dev = &devpipe;
  80199d:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  8019a4:	30 80 00 
	return 0;
}
  8019a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5e                   	pop    %esi
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	53                   	push   %ebx
  8019b7:	83 ec 14             	sub    $0x14,%esp
  8019ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c8:	e8 a3 f3 ff ff       	call   800d70 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cd:	89 1c 24             	mov    %ebx,(%esp)
  8019d0:	e8 6f f5 ff ff       	call   800f44 <fd2data>
  8019d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e0:	e8 8b f3 ff ff       	call   800d70 <sys_page_unmap>
}
  8019e5:	83 c4 14             	add    $0x14,%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	57                   	push   %edi
  8019ef:	56                   	push   %esi
  8019f0:	53                   	push   %ebx
  8019f1:	83 ec 2c             	sub    $0x2c,%esp
  8019f4:	89 c7                	mov    %eax,%edi
  8019f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8019fe:	8b 00                	mov    (%eax),%eax
  801a00:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a03:	89 3c 24             	mov    %edi,(%esp)
  801a06:	e8 89 05 00 00       	call   801f94 <pageref>
  801a0b:	89 c6                	mov    %eax,%esi
  801a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a10:	89 04 24             	mov    %eax,(%esp)
  801a13:	e8 7c 05 00 00       	call   801f94 <pageref>
  801a18:	39 c6                	cmp    %eax,%esi
  801a1a:	0f 94 c0             	sete   %al
  801a1d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a20:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a26:	8b 12                	mov    (%edx),%edx
  801a28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a2b:	39 cb                	cmp    %ecx,%ebx
  801a2d:	75 08                	jne    801a37 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a2f:	83 c4 2c             	add    $0x2c,%esp
  801a32:	5b                   	pop    %ebx
  801a33:	5e                   	pop    %esi
  801a34:	5f                   	pop    %edi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a37:	83 f8 01             	cmp    $0x1,%eax
  801a3a:	75 bd                	jne    8019f9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3c:	8b 42 58             	mov    0x58(%edx),%eax
  801a3f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801a46:	00 
  801a47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a4f:	c7 04 24 b6 26 80 00 	movl   $0x8026b6,(%esp)
  801a56:	e8 d1 e8 ff ff       	call   80032c <cprintf>
  801a5b:	eb 9c                	jmp    8019f9 <_pipeisclosed+0xe>

00801a5d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 1c             	sub    $0x1c,%esp
  801a66:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a69:	89 34 24             	mov    %esi,(%esp)
  801a6c:	e8 d3 f4 ff ff       	call   800f44 <fd2data>
  801a71:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a73:	bf 00 00 00 00       	mov    $0x0,%edi
  801a78:	eb 3c                	jmp    801ab6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7a:	89 da                	mov    %ebx,%edx
  801a7c:	89 f0                	mov    %esi,%eax
  801a7e:	e8 68 ff ff ff       	call   8019eb <_pipeisclosed>
  801a83:	85 c0                	test   %eax,%eax
  801a85:	75 38                	jne    801abf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a87:	e8 1e f2 ff ff       	call   800caa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8f:	8b 13                	mov    (%ebx),%edx
  801a91:	83 c2 20             	add    $0x20,%edx
  801a94:	39 d0                	cmp    %edx,%eax
  801a96:	73 e2                	jae    801a7a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a9b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a9e:	89 c2                	mov    %eax,%edx
  801aa0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801aa6:	79 05                	jns    801aad <devpipe_write+0x50>
  801aa8:	4a                   	dec    %edx
  801aa9:	83 ca e0             	or     $0xffffffe0,%edx
  801aac:	42                   	inc    %edx
  801aad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab1:	40                   	inc    %eax
  801ab2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab5:	47                   	inc    %edi
  801ab6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab9:	75 d1                	jne    801a8c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801abb:	89 f8                	mov    %edi,%eax
  801abd:	eb 05                	jmp    801ac4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801abf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac4:	83 c4 1c             	add    $0x1c,%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5f                   	pop    %edi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	57                   	push   %edi
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 1c             	sub    $0x1c,%esp
  801ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ad8:	89 3c 24             	mov    %edi,(%esp)
  801adb:	e8 64 f4 ff ff       	call   800f44 <fd2data>
  801ae0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae2:	be 00 00 00 00       	mov    $0x0,%esi
  801ae7:	eb 3a                	jmp    801b23 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ae9:	85 f6                	test   %esi,%esi
  801aeb:	74 04                	je     801af1 <devpipe_read+0x25>
				return i;
  801aed:	89 f0                	mov    %esi,%eax
  801aef:	eb 40                	jmp    801b31 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af1:	89 da                	mov    %ebx,%edx
  801af3:	89 f8                	mov    %edi,%eax
  801af5:	e8 f1 fe ff ff       	call   8019eb <_pipeisclosed>
  801afa:	85 c0                	test   %eax,%eax
  801afc:	75 2e                	jne    801b2c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801afe:	e8 a7 f1 ff ff       	call   800caa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b03:	8b 03                	mov    (%ebx),%eax
  801b05:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b08:	74 df                	je     801ae9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b0a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b0f:	79 05                	jns    801b16 <devpipe_read+0x4a>
  801b11:	48                   	dec    %eax
  801b12:	83 c8 e0             	or     $0xffffffe0,%eax
  801b15:	40                   	inc    %eax
  801b16:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b20:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	46                   	inc    %esi
  801b23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b26:	75 db                	jne    801b03 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b28:	89 f0                	mov    %esi,%eax
  801b2a:	eb 05                	jmp    801b31 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b31:	83 c4 1c             	add    $0x1c,%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5f                   	pop    %edi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	57                   	push   %edi
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 3c             	sub    $0x3c,%esp
  801b42:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b48:	89 04 24             	mov    %eax,(%esp)
  801b4b:	e8 0f f4 ff ff       	call   800f5f <fd_alloc>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	85 c0                	test   %eax,%eax
  801b54:	0f 88 45 01 00 00    	js     801c9f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b61:	00 
  801b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b70:	e8 54 f1 ff ff       	call   800cc9 <sys_page_alloc>
  801b75:	89 c3                	mov    %eax,%ebx
  801b77:	85 c0                	test   %eax,%eax
  801b79:	0f 88 20 01 00 00    	js     801c9f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b82:	89 04 24             	mov    %eax,(%esp)
  801b85:	e8 d5 f3 ff ff       	call   800f5f <fd_alloc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	0f 88 f8 00 00 00    	js     801c8c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b94:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b9b:	00 
  801b9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801baa:	e8 1a f1 ff ff       	call   800cc9 <sys_page_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 d3 00 00 00    	js     801c8c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 80 f3 ff ff       	call   800f44 <fd2data>
  801bc4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bcd:	00 
  801bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd9:	e8 eb f0 ff ff       	call   800cc9 <sys_page_alloc>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 91 00 00 00    	js     801c79 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 51 f3 ff ff       	call   800f44 <fd2data>
  801bf3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801bfa:	00 
  801bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c06:	00 
  801c07:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c12:	e8 06 f1 ff ff       	call   800d1d <sys_page_map>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 4c                	js     801c69 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c1d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c26:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c32:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c3b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c4a:	89 04 24             	mov    %eax,(%esp)
  801c4d:	e8 e2 f2 ff ff       	call   800f34 <fd2num>
  801c52:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c57:	89 04 24             	mov    %eax,(%esp)
  801c5a:	e8 d5 f2 ff ff       	call   800f34 <fd2num>
  801c5f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c67:	eb 36                	jmp    801c9f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801c69:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c74:	e8 f7 f0 ff ff       	call   800d70 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c79:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c87:	e8 e4 f0 ff ff       	call   800d70 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9a:	e8 d1 f0 ff ff       	call   800d70 <sys_page_unmap>
    err:
	return r;
}
  801c9f:	89 d8                	mov    %ebx,%eax
  801ca1:	83 c4 3c             	add    $0x3c,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801caf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	89 04 24             	mov    %eax,(%esp)
  801cbc:	e8 f1 f2 ff ff       	call   800fb2 <fd_lookup>
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	78 15                	js     801cda <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc8:	89 04 24             	mov    %eax,(%esp)
  801ccb:	e8 74 f2 ff ff       	call   800f44 <fd2data>
	return _pipeisclosed(fd, p);
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd5:	e8 11 fd ff ff       	call   8019eb <_pipeisclosed>
}
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801cec:	c7 44 24 04 ce 26 80 	movl   $0x8026ce,0x4(%esp)
  801cf3:	00 
  801cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf7:	89 04 24             	mov    %eax,(%esp)
  801cfa:	e8 d8 eb ff ff       	call   8008d7 <strcpy>
	return 0;
}
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	57                   	push   %edi
  801d0a:	56                   	push   %esi
  801d0b:	53                   	push   %ebx
  801d0c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d12:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d17:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1d:	eb 30                	jmp    801d4f <devcons_write+0x49>
		m = n - tot;
  801d1f:	8b 75 10             	mov    0x10(%ebp),%esi
  801d22:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d24:	83 fe 7f             	cmp    $0x7f,%esi
  801d27:	76 05                	jbe    801d2e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801d29:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d2e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d32:	03 45 0c             	add    0xc(%ebp),%eax
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	89 3c 24             	mov    %edi,(%esp)
  801d3c:	e8 0f ed ff ff       	call   800a50 <memmove>
		sys_cputs(buf, m);
  801d41:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d45:	89 3c 24             	mov    %edi,(%esp)
  801d48:	e8 af ee ff ff       	call   800bfc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4d:	01 f3                	add    %esi,%ebx
  801d4f:	89 d8                	mov    %ebx,%eax
  801d51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d54:	72 c9                	jb     801d1f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d56:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6b:	75 07                	jne    801d74 <devcons_read+0x13>
  801d6d:	eb 25                	jmp    801d94 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d6f:	e8 36 ef ff ff       	call   800caa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d74:	e8 a1 ee ff ff       	call   800c1a <sys_cgetc>
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	74 f2                	je     801d6f <devcons_read+0xe>
  801d7d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 1d                	js     801da0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d83:	83 f8 04             	cmp    $0x4,%eax
  801d86:	74 13                	je     801d9b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8b:	88 10                	mov    %dl,(%eax)
	return 1;
  801d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d92:	eb 0c                	jmp    801da0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
  801d99:	eb 05                	jmp    801da0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801db5:	00 
  801db6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db9:	89 04 24             	mov    %eax,(%esp)
  801dbc:	e8 3b ee ff ff       	call   800bfc <sys_cputs>
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <getchar>:

int
getchar(void)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801dd0:	00 
  801dd1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddf:	e8 6c f4 ff ff       	call   801250 <read>
	if (r < 0)
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 0f                	js     801df7 <getchar+0x34>
		return r;
	if (r < 1)
  801de8:	85 c0                	test   %eax,%eax
  801dea:	7e 06                	jle    801df2 <getchar+0x2f>
		return -E_EOF;
	return c;
  801dec:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df0:	eb 05                	jmp    801df7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801df2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	89 04 24             	mov    %eax,(%esp)
  801e0c:	e8 a1 f1 ff ff       	call   800fb2 <fd_lookup>
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 11                	js     801e26 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e18:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e1e:	39 10                	cmp    %edx,(%eax)
  801e20:	0f 94 c0             	sete   %al
  801e23:	0f b6 c0             	movzbl %al,%eax
}
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <opencons>:

int
opencons(void)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e31:	89 04 24             	mov    %eax,(%esp)
  801e34:	e8 26 f1 ff ff       	call   800f5f <fd_alloc>
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 3c                	js     801e79 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e44:	00 
  801e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e53:	e8 71 ee ff ff       	call   800cc9 <sys_page_alloc>
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	78 1d                	js     801e79 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e5c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e65:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 bb f0 ff ff       	call   800f34 <fd2num>
}
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    
	...

00801e7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 10             	sub    $0x10,%esp
  801e84:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	75 05                	jne    801e96 <ipc_recv+0x1a>
  801e91:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 41 f0 ff ff       	call   800edf <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	79 16                	jns    801eb8 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801ea2:	85 db                	test   %ebx,%ebx
  801ea4:	74 06                	je     801eac <ipc_recv+0x30>
  801ea6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801eac:	85 f6                	test   %esi,%esi
  801eae:	74 32                	je     801ee2 <ipc_recv+0x66>
  801eb0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801eb6:	eb 2a                	jmp    801ee2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801eb8:	85 db                	test   %ebx,%ebx
  801eba:	74 0c                	je     801ec8 <ipc_recv+0x4c>
  801ebc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec1:	8b 00                	mov    (%eax),%eax
  801ec3:	8b 40 74             	mov    0x74(%eax),%eax
  801ec6:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ec8:	85 f6                	test   %esi,%esi
  801eca:	74 0c                	je     801ed8 <ipc_recv+0x5c>
  801ecc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed1:	8b 00                	mov    (%eax),%eax
  801ed3:	8b 40 78             	mov    0x78(%eax),%eax
  801ed6:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801ed8:	a1 08 40 80 00       	mov    0x804008,%eax
  801edd:	8b 00                	mov    (%eax),%eax
  801edf:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	57                   	push   %edi
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 1c             	sub    $0x1c,%esp
  801ef2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	75 05                	jne    801f04 <ipc_send+0x1b>
  801eff:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801f04:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f10:	8b 45 08             	mov    0x8(%ebp),%eax
  801f13:	89 04 24             	mov    %eax,(%esp)
  801f16:	e8 a1 ef ff ff       	call   800ebc <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801f1b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1e:	75 07                	jne    801f27 <ipc_send+0x3e>
  801f20:	e8 85 ed ff ff       	call   800caa <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801f25:	eb dd                	jmp    801f04 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801f27:	85 c0                	test   %eax,%eax
  801f29:	79 1c                	jns    801f47 <ipc_send+0x5e>
  801f2b:	c7 44 24 08 da 26 80 	movl   $0x8026da,0x8(%esp)
  801f32:	00 
  801f33:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801f3a:	00 
  801f3b:	c7 04 24 ec 26 80 00 	movl   $0x8026ec,(%esp)
  801f42:	e8 ed e2 ff ff       	call   800234 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801f47:	83 c4 1c             	add    $0x1c,%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	53                   	push   %ebx
  801f53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801f56:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f62:	89 c2                	mov    %eax,%edx
  801f64:	c1 e2 07             	shl    $0x7,%edx
  801f67:	29 ca                	sub    %ecx,%edx
  801f69:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f6f:	8b 52 50             	mov    0x50(%edx),%edx
  801f72:	39 da                	cmp    %ebx,%edx
  801f74:	75 0f                	jne    801f85 <ipc_find_env+0x36>
			return envs[i].env_id;
  801f76:	c1 e0 07             	shl    $0x7,%eax
  801f79:	29 c8                	sub    %ecx,%eax
  801f7b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f80:	8b 40 40             	mov    0x40(%eax),%eax
  801f83:	eb 0c                	jmp    801f91 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f85:	40                   	inc    %eax
  801f86:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f8b:	75 ce                	jne    801f5b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f8d:	66 b8 00 00          	mov    $0x0,%ax
}
  801f91:	5b                   	pop    %ebx
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    

00801f94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801f9a:	89 c2                	mov    %eax,%edx
  801f9c:	c1 ea 16             	shr    $0x16,%edx
  801f9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fa6:	f6 c2 01             	test   $0x1,%dl
  801fa9:	74 1e                	je     801fc9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fab:	c1 e8 0c             	shr    $0xc,%eax
  801fae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fb5:	a8 01                	test   $0x1,%al
  801fb7:	74 17                	je     801fd0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb9:	c1 e8 0c             	shr    $0xc,%eax
  801fbc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fc3:	ef 
  801fc4:	0f b7 c0             	movzwl %ax,%eax
  801fc7:	eb 0c                	jmp    801fd5 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fce:	eb 05                	jmp    801fd5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fd0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    
	...

00801fd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fd8:	55                   	push   %ebp
  801fd9:	57                   	push   %edi
  801fda:	56                   	push   %esi
  801fdb:	83 ec 10             	sub    $0x10,%esp
  801fde:	8b 74 24 20          	mov    0x20(%esp),%esi
  801fe2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fe6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801fee:	89 cd                	mov    %ecx,%ebp
  801ff0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	75 2c                	jne    802024 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ff8:	39 f9                	cmp    %edi,%ecx
  801ffa:	77 68                	ja     802064 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ffc:	85 c9                	test   %ecx,%ecx
  801ffe:	75 0b                	jne    80200b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802000:	b8 01 00 00 00       	mov    $0x1,%eax
  802005:	31 d2                	xor    %edx,%edx
  802007:	f7 f1                	div    %ecx
  802009:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80200b:	31 d2                	xor    %edx,%edx
  80200d:	89 f8                	mov    %edi,%eax
  80200f:	f7 f1                	div    %ecx
  802011:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802013:	89 f0                	mov    %esi,%eax
  802015:	f7 f1                	div    %ecx
  802017:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802019:	89 f0                	mov    %esi,%eax
  80201b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802024:	39 f8                	cmp    %edi,%eax
  802026:	77 2c                	ja     802054 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802028:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80202b:	83 f6 1f             	xor    $0x1f,%esi
  80202e:	75 4c                	jne    80207c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802030:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802032:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802037:	72 0a                	jb     802043 <__udivdi3+0x6b>
  802039:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80203d:	0f 87 ad 00 00 00    	ja     8020f0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802043:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802048:	89 f0                	mov    %esi,%eax
  80204a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    
  802053:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802054:	31 ff                	xor    %edi,%edi
  802056:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802058:	89 f0                	mov    %esi,%eax
  80205a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	5e                   	pop    %esi
  802060:	5f                   	pop    %edi
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    
  802063:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802064:	89 fa                	mov    %edi,%edx
  802066:	89 f0                	mov    %esi,%eax
  802068:	f7 f1                	div    %ecx
  80206a:	89 c6                	mov    %eax,%esi
  80206c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80206e:	89 f0                	mov    %esi,%eax
  802070:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80207c:	89 f1                	mov    %esi,%ecx
  80207e:	d3 e0                	shl    %cl,%eax
  802080:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802084:	b8 20 00 00 00       	mov    $0x20,%eax
  802089:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80208b:	89 ea                	mov    %ebp,%edx
  80208d:	88 c1                	mov    %al,%cl
  80208f:	d3 ea                	shr    %cl,%edx
  802091:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802095:	09 ca                	or     %ecx,%edx
  802097:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80209b:	89 f1                	mov    %esi,%ecx
  80209d:	d3 e5                	shl    %cl,%ebp
  80209f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8020a3:	89 fd                	mov    %edi,%ebp
  8020a5:	88 c1                	mov    %al,%cl
  8020a7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8020a9:	89 fa                	mov    %edi,%edx
  8020ab:	89 f1                	mov    %esi,%ecx
  8020ad:	d3 e2                	shl    %cl,%edx
  8020af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020b3:	88 c1                	mov    %al,%cl
  8020b5:	d3 ef                	shr    %cl,%edi
  8020b7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020b9:	89 f8                	mov    %edi,%eax
  8020bb:	89 ea                	mov    %ebp,%edx
  8020bd:	f7 74 24 08          	divl   0x8(%esp)
  8020c1:	89 d1                	mov    %edx,%ecx
  8020c3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8020c5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020c9:	39 d1                	cmp    %edx,%ecx
  8020cb:	72 17                	jb     8020e4 <__udivdi3+0x10c>
  8020cd:	74 09                	je     8020d8 <__udivdi3+0x100>
  8020cf:	89 fe                	mov    %edi,%esi
  8020d1:	31 ff                	xor    %edi,%edi
  8020d3:	e9 41 ff ff ff       	jmp    802019 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020dc:	89 f1                	mov    %esi,%ecx
  8020de:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020e0:	39 c2                	cmp    %eax,%edx
  8020e2:	73 eb                	jae    8020cf <__udivdi3+0xf7>
		{
		  q0--;
  8020e4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020e7:	31 ff                	xor    %edi,%edi
  8020e9:	e9 2b ff ff ff       	jmp    802019 <__udivdi3+0x41>
  8020ee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020f0:	31 f6                	xor    %esi,%esi
  8020f2:	e9 22 ff ff ff       	jmp    802019 <__udivdi3+0x41>
	...

008020f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020f8:	55                   	push   %ebp
  8020f9:	57                   	push   %edi
  8020fa:	56                   	push   %esi
  8020fb:	83 ec 20             	sub    $0x20,%esp
  8020fe:	8b 44 24 30          	mov    0x30(%esp),%eax
  802102:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802106:	89 44 24 14          	mov    %eax,0x14(%esp)
  80210a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80210e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802112:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802116:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802118:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80211a:	85 ed                	test   %ebp,%ebp
  80211c:	75 16                	jne    802134 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80211e:	39 f1                	cmp    %esi,%ecx
  802120:	0f 86 a6 00 00 00    	jbe    8021cc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802126:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802128:	89 d0                	mov    %edx,%eax
  80212a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80212c:	83 c4 20             	add    $0x20,%esp
  80212f:	5e                   	pop    %esi
  802130:	5f                   	pop    %edi
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    
  802133:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802134:	39 f5                	cmp    %esi,%ebp
  802136:	0f 87 ac 00 00 00    	ja     8021e8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80213c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80213f:	83 f0 1f             	xor    $0x1f,%eax
  802142:	89 44 24 10          	mov    %eax,0x10(%esp)
  802146:	0f 84 a8 00 00 00    	je     8021f4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80214c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802150:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802152:	bf 20 00 00 00       	mov    $0x20,%edi
  802157:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80215b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80215f:	89 f9                	mov    %edi,%ecx
  802161:	d3 e8                	shr    %cl,%eax
  802163:	09 e8                	or     %ebp,%eax
  802165:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802169:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80216d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802171:	d3 e0                	shl    %cl,%eax
  802173:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802177:	89 f2                	mov    %esi,%edx
  802179:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80217b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80217f:	d3 e0                	shl    %cl,%eax
  802181:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802185:	8b 44 24 14          	mov    0x14(%esp),%eax
  802189:	89 f9                	mov    %edi,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80218f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802191:	89 f2                	mov    %esi,%edx
  802193:	f7 74 24 18          	divl   0x18(%esp)
  802197:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	89 c5                	mov    %eax,%ebp
  80219f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021a1:	39 d6                	cmp    %edx,%esi
  8021a3:	72 67                	jb     80220c <__umoddi3+0x114>
  8021a5:	74 75                	je     80221c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021ab:	29 e8                	sub    %ebp,%eax
  8021ad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021af:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021b3:	d3 e8                	shr    %cl,%eax
  8021b5:	89 f2                	mov    %esi,%edx
  8021b7:	89 f9                	mov    %edi,%ecx
  8021b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021bb:	09 d0                	or     %edx,%eax
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021c3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c5:	83 c4 20             	add    $0x20,%esp
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021cc:	85 c9                	test   %ecx,%ecx
  8021ce:	75 0b                	jne    8021db <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d5:	31 d2                	xor    %edx,%edx
  8021d7:	f7 f1                	div    %ecx
  8021d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021db:	89 f0                	mov    %esi,%eax
  8021dd:	31 d2                	xor    %edx,%edx
  8021df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021e1:	89 f8                	mov    %edi,%eax
  8021e3:	e9 3e ff ff ff       	jmp    802126 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021ea:	83 c4 20             	add    $0x20,%esp
  8021ed:	5e                   	pop    %esi
  8021ee:	5f                   	pop    %edi
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    
  8021f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021f4:	39 f5                	cmp    %esi,%ebp
  8021f6:	72 04                	jb     8021fc <__umoddi3+0x104>
  8021f8:	39 f9                	cmp    %edi,%ecx
  8021fa:	77 06                	ja     802202 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021fc:	89 f2                	mov    %esi,%edx
  8021fe:	29 cf                	sub    %ecx,%edi
  802200:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802202:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802204:	83 c4 20             	add    $0x20,%esp
  802207:	5e                   	pop    %esi
  802208:	5f                   	pop    %edi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    
  80220b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80220c:	89 d1                	mov    %edx,%ecx
  80220e:	89 c5                	mov    %eax,%ebp
  802210:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802214:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802218:	eb 8d                	jmp    8021a7 <__umoddi3+0xaf>
  80221a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80221c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802220:	72 ea                	jb     80220c <__umoddi3+0x114>
  802222:	89 f1                	mov    %esi,%ecx
  802224:	eb 81                	jmp    8021a7 <__umoddi3+0xaf>
