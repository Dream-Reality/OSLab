
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
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
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 e0 	movl   $0x8026e0,0x803000
  800046:	26 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 e6 26 80 00 	movl   $0x8026e6,(%esp)
  800050:	e8 73 02 00 00       	call   8002c8 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 f5 26 80 00 	movl   $0x8026f5,(%esp)
  80005c:	e8 67 02 00 00       	call   8002c8 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  800070:	e8 ae 16 00 00       	call   801723 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 0e 27 80 	movl   $0x80270e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 24 27 80 00 	movl   $0x802724,(%esp)
  800096:	e8 35 01 00 00       	call   8001d0 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 31 27 80 00 	movl   $0x802731,(%esp)
  8000a2:	e8 21 02 00 00       	call   8002c8 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 dd 0a 00 00       	call   800b98 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 1d 11 00 00       	call   8011ec <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);
	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 44 27 80 00 	movl   $0x802744,(%esp)
  8000da:	e8 e9 01 00 00       	call   8002c8 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 a1 0f 00 00       	call   801088 <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 58 27 80 00 	movl   $0x802758,(%esp)
  8000ee:	e8 d5 01 00 00       	call   8002c8 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 6c 27 80 	movl   $0x80276c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 75 27 80 	movl   $0x802775,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 7f 27 80 	movl   $0x80277f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 7e 27 80 00 	movl   $0x80277e,(%esp)
  80011a:	e8 73 1c 00 00       	call   801d92 <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 84 27 80 	movl   $0x802784,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 24 27 80 00 	movl   $0x802724,(%esp)
  80013e:	e8 8d 00 00 00       	call   8001d0 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 9b 27 80 00 	movl   $0x80279b,(%esp)
  80014a:	e8 79 01 00 00       	call   8002c8 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
  800164:	8b 75 08             	mov    0x8(%ebp),%esi
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80016a:	e8 b8 0a 00 00       	call   800c27 <sys_getenvid>
  80016f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80017b:	c1 e0 07             	shl    $0x7,%eax
  80017e:	29 d0                	sub    %edx,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800188:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80018b:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800190:	85 f6                	test   %esi,%esi
  800192:	7e 07                	jle    80019b <libmain+0x3f>
		binaryname = argv[0];
  800194:	8b 03                	mov    (%ebx),%eax
  800196:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80019b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019f:	89 34 24             	mov    %esi,(%esp)
  8001a2:	e8 8d fe ff ff       	call   800034 <umain>

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
	close_all();
  8001ba:	e8 fa 0e 00 00       	call   8010b9 <close_all>
	sys_env_destroy(0);
  8001bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c6:	e8 0a 0a 00 00       	call   800bd5 <sys_env_destroy>
}
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    
  8001cd:	00 00                	add    %al,(%eax)
	...

008001d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001d8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001db:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e1:	e8 41 0a 00 00       	call   800c27 <sys_getenvid>
  8001e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fc:	c7 04 24 b8 27 80 00 	movl   $0x8027b8,(%esp)
  800203:	e8 c0 00 00 00       	call   8002c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800208:	89 74 24 04          	mov    %esi,0x4(%esp)
  80020c:	8b 45 10             	mov    0x10(%ebp),%eax
  80020f:	89 04 24             	mov    %eax,(%esp)
  800212:	e8 50 00 00 00       	call   800267 <vcprintf>
	cprintf("\n");
  800217:	c7 04 24 a3 2c 80 00 	movl   $0x802ca3,(%esp)
  80021e:	e8 a5 00 00 00       	call   8002c8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800223:	cc                   	int3   
  800224:	eb fd                	jmp    800223 <_panic+0x53>
	...

00800228 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	53                   	push   %ebx
  80022c:	83 ec 14             	sub    $0x14,%esp
  80022f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800232:	8b 03                	mov    (%ebx),%eax
  800234:	8b 55 08             	mov    0x8(%ebp),%edx
  800237:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023b:	40                   	inc    %eax
  80023c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80023e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800243:	75 19                	jne    80025e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800245:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80024c:	00 
  80024d:	8d 43 08             	lea    0x8(%ebx),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 40 09 00 00       	call   800b98 <sys_cputs>
		b->idx = 0;
  800258:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80025e:	ff 43 04             	incl   0x4(%ebx)
}
  800261:	83 c4 14             	add    $0x14,%esp
  800264:	5b                   	pop    %ebx
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800270:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800277:	00 00 00 
	b.cnt = 0;
  80027a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800281:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028b:	8b 45 08             	mov    0x8(%ebp),%eax
  80028e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800292:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	c7 04 24 28 02 80 00 	movl   $0x800228,(%esp)
  8002a3:	e8 82 01 00 00       	call   80042a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	e8 d8 08 00 00       	call   800b98 <sys_cputs>

	return b.cnt;
}
  8002c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	e8 87 ff ff ff       	call   800267 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    
	...

008002e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	57                   	push   %edi
  8002e8:	56                   	push   %esi
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 3c             	sub    $0x3c,%esp
  8002ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f0:	89 d7                	mov    %edx,%edi
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800301:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800304:	85 c0                	test   %eax,%eax
  800306:	75 08                	jne    800310 <printnum+0x2c>
  800308:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80030e:	77 57                	ja     800367 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800310:	89 74 24 10          	mov    %esi,0x10(%esp)
  800314:	4b                   	dec    %ebx
  800315:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800319:	8b 45 10             	mov    0x10(%ebp),%eax
  80031c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800320:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800324:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800328:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032f:	00 
  800330:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	e8 36 21 00 00       	call   802478 <__udivdi3>
  800342:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800346:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034a:	89 04 24             	mov    %eax,(%esp)
  80034d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800351:	89 fa                	mov    %edi,%edx
  800353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800356:	e8 89 ff ff ff       	call   8002e4 <printnum>
  80035b:	eb 0f                	jmp    80036c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80035d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800361:	89 34 24             	mov    %esi,(%esp)
  800364:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800367:	4b                   	dec    %ebx
  800368:	85 db                	test   %ebx,%ebx
  80036a:	7f f1                	jg     80035d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800370:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800374:	8b 45 10             	mov    0x10(%ebp),%eax
  800377:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800382:	00 
  800383:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800386:	89 04 24             	mov    %eax,(%esp)
  800389:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800390:	e8 03 22 00 00       	call   802598 <__umoddi3>
  800395:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800399:	0f be 80 db 27 80 00 	movsbl 0x8027db(%eax),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003a6:	83 c4 3c             	add    $0x3c,%esp
  8003a9:	5b                   	pop    %ebx
  8003aa:	5e                   	pop    %esi
  8003ab:	5f                   	pop    %edi
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b1:	83 fa 01             	cmp    $0x1,%edx
  8003b4:	7e 0e                	jle    8003c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b6:	8b 10                	mov    (%eax),%edx
  8003b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bb:	89 08                	mov    %ecx,(%eax)
  8003bd:	8b 02                	mov    (%edx),%eax
  8003bf:	8b 52 04             	mov    0x4(%edx),%edx
  8003c2:	eb 22                	jmp    8003e6 <getuint+0x38>
	else if (lflag)
  8003c4:	85 d2                	test   %edx,%edx
  8003c6:	74 10                	je     8003d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 02                	mov    (%edx),%eax
  8003d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d6:	eb 0e                	jmp    8003e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d8:	8b 10                	mov    (%eax),%edx
  8003da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003dd:	89 08                	mov    %ecx,(%eax)
  8003df:	8b 02                	mov    (%edx),%eax
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ee:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f6:	73 08                	jae    800400 <sprintputch+0x18>
		*b->buf++ = ch;
  8003f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fb:	88 0a                	mov    %cl,(%edx)
  8003fd:	42                   	inc    %edx
  8003fe:	89 10                	mov    %edx,(%eax)
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800408:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040f:	8b 45 10             	mov    0x10(%ebp),%eax
  800412:	89 44 24 08          	mov    %eax,0x8(%esp)
  800416:	8b 45 0c             	mov    0xc(%ebp),%eax
  800419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 02 00 00 00       	call   80042a <vprintfmt>
	va_end(ap);
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 4c             	sub    $0x4c,%esp
  800433:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800436:	8b 75 10             	mov    0x10(%ebp),%esi
  800439:	eb 12                	jmp    80044d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043b:	85 c0                	test   %eax,%eax
  80043d:	0f 84 6b 03 00 00    	je     8007ae <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800443:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800447:	89 04 24             	mov    %eax,(%esp)
  80044a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044d:	0f b6 06             	movzbl (%esi),%eax
  800450:	46                   	inc    %esi
  800451:	83 f8 25             	cmp    $0x25,%eax
  800454:	75 e5                	jne    80043b <vprintfmt+0x11>
  800456:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80045a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800461:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800466:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80046d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800472:	eb 26                	jmp    80049a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800477:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80047b:	eb 1d                	jmp    80049a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800480:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800484:	eb 14                	jmp    80049a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800489:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800490:	eb 08                	jmp    80049a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800492:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800495:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	0f b6 06             	movzbl (%esi),%eax
  80049d:	8d 56 01             	lea    0x1(%esi),%edx
  8004a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a3:	8a 16                	mov    (%esi),%dl
  8004a5:	83 ea 23             	sub    $0x23,%edx
  8004a8:	80 fa 55             	cmp    $0x55,%dl
  8004ab:	0f 87 e1 02 00 00    	ja     800792 <vprintfmt+0x368>
  8004b1:	0f b6 d2             	movzbl %dl,%edx
  8004b4:	ff 24 95 20 29 80 00 	jmp    *0x802920(,%edx,4)
  8004bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004be:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004c6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ca:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004cd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d0:	83 fa 09             	cmp    $0x9,%edx
  8004d3:	77 2a                	ja     8004ff <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d6:	eb eb                	jmp    8004c3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e6:	eb 17                	jmp    8004ff <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ec:	78 98                	js     800486 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f1:	eb a7                	jmp    80049a <vprintfmt+0x70>
  8004f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004fd:	eb 9b                	jmp    80049a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800503:	79 95                	jns    80049a <vprintfmt+0x70>
  800505:	eb 8b                	jmp    800492 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800507:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050b:	eb 8d                	jmp    80049a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800525:	e9 23 ff ff ff       	jmp    80044d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 50 04             	lea    0x4(%eax),%edx
  800530:	89 55 14             	mov    %edx,0x14(%ebp)
  800533:	8b 00                	mov    (%eax),%eax
  800535:	85 c0                	test   %eax,%eax
  800537:	79 02                	jns    80053b <vprintfmt+0x111>
  800539:	f7 d8                	neg    %eax
  80053b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053d:	83 f8 0f             	cmp    $0xf,%eax
  800540:	7f 0b                	jg     80054d <vprintfmt+0x123>
  800542:	8b 04 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%eax
  800549:	85 c0                	test   %eax,%eax
  80054b:	75 23                	jne    800570 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80054d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800551:	c7 44 24 08 f3 27 80 	movl   $0x8027f3,0x8(%esp)
  800558:	00 
  800559:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	e8 9a fe ff ff       	call   800402 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056b:	e9 dd fe ff ff       	jmp    80044d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800570:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800574:	c7 44 24 08 b1 2b 80 	movl   $0x802bb1,0x8(%esp)
  80057b:	00 
  80057c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800580:	8b 55 08             	mov    0x8(%ebp),%edx
  800583:	89 14 24             	mov    %edx,(%esp)
  800586:	e8 77 fe ff ff       	call   800402 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058e:	e9 ba fe ff ff       	jmp    80044d <vprintfmt+0x23>
  800593:	89 f9                	mov    %edi,%ecx
  800595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800598:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 50 04             	lea    0x4(%eax),%edx
  8005a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a4:	8b 30                	mov    (%eax),%esi
  8005a6:	85 f6                	test   %esi,%esi
  8005a8:	75 05                	jne    8005af <vprintfmt+0x185>
				p = "(null)";
  8005aa:	be ec 27 80 00       	mov    $0x8027ec,%esi
			if (width > 0 && padc != '-')
  8005af:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b3:	0f 8e 84 00 00 00    	jle    80063d <vprintfmt+0x213>
  8005b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005bd:	74 7e                	je     80063d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c3:	89 34 24             	mov    %esi,(%esp)
  8005c6:	e8 8b 02 00 00       	call   800856 <strnlen>
  8005cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ce:	29 c2                	sub    %eax,%edx
  8005d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005d3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005d7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005da:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005dd:	89 de                	mov    %ebx,%esi
  8005df:	89 d3                	mov    %edx,%ebx
  8005e1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	eb 0b                	jmp    8005f0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e9:	89 3c 24             	mov    %edi,(%esp)
  8005ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	4b                   	dec    %ebx
  8005f0:	85 db                	test   %ebx,%ebx
  8005f2:	7f f1                	jg     8005e5 <vprintfmt+0x1bb>
  8005f4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f7:	89 f3                	mov    %esi,%ebx
  8005f9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ff:	85 c0                	test   %eax,%eax
  800601:	79 05                	jns    800608 <vprintfmt+0x1de>
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060b:	29 c2                	sub    %eax,%edx
  80060d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800610:	eb 2b                	jmp    80063d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800612:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800616:	74 18                	je     800630 <vprintfmt+0x206>
  800618:	8d 50 e0             	lea    -0x20(%eax),%edx
  80061b:	83 fa 5e             	cmp    $0x5e,%edx
  80061e:	76 10                	jbe    800630 <vprintfmt+0x206>
					putch('?', putdat);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
  80062e:	eb 0a                	jmp    80063a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063a:	ff 4d e4             	decl   -0x1c(%ebp)
  80063d:	0f be 06             	movsbl (%esi),%eax
  800640:	46                   	inc    %esi
  800641:	85 c0                	test   %eax,%eax
  800643:	74 21                	je     800666 <vprintfmt+0x23c>
  800645:	85 ff                	test   %edi,%edi
  800647:	78 c9                	js     800612 <vprintfmt+0x1e8>
  800649:	4f                   	dec    %edi
  80064a:	79 c6                	jns    800612 <vprintfmt+0x1e8>
  80064c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064f:	89 de                	mov    %ebx,%esi
  800651:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800654:	eb 18                	jmp    80066e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800661:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800663:	4b                   	dec    %ebx
  800664:	eb 08                	jmp    80066e <vprintfmt+0x244>
  800666:	8b 7d 08             	mov    0x8(%ebp),%edi
  800669:	89 de                	mov    %ebx,%esi
  80066b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80066e:	85 db                	test   %ebx,%ebx
  800670:	7f e4                	jg     800656 <vprintfmt+0x22c>
  800672:	89 7d 08             	mov    %edi,0x8(%ebp)
  800675:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067a:	e9 ce fd ff ff       	jmp    80044d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067f:	83 f9 01             	cmp    $0x1,%ecx
  800682:	7e 10                	jle    800694 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 08             	lea    0x8(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	8b 30                	mov    (%eax),%esi
  80068f:	8b 78 04             	mov    0x4(%eax),%edi
  800692:	eb 26                	jmp    8006ba <vprintfmt+0x290>
	else if (lflag)
  800694:	85 c9                	test   %ecx,%ecx
  800696:	74 12                	je     8006aa <vprintfmt+0x280>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 30                	mov    (%eax),%esi
  8006a3:	89 f7                	mov    %esi,%edi
  8006a5:	c1 ff 1f             	sar    $0x1f,%edi
  8006a8:	eb 10                	jmp    8006ba <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b3:	8b 30                	mov    (%eax),%esi
  8006b5:	89 f7                	mov    %esi,%edi
  8006b7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ba:	85 ff                	test   %edi,%edi
  8006bc:	78 0a                	js     8006c8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c3:	e9 8c 00 00 00       	jmp    800754 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d6:	f7 de                	neg    %esi
  8006d8:	83 d7 00             	adc    $0x0,%edi
  8006db:	f7 df                	neg    %edi
			}
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	eb 70                	jmp    800754 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e4:	89 ca                	mov    %ecx,%edx
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 c0 fc ff ff       	call   8003ae <getuint>
  8006ee:	89 c6                	mov    %eax,%esi
  8006f0:	89 d7                	mov    %edx,%edi
			base = 10;
  8006f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006f7:	eb 5b                	jmp    800754 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006f9:	89 ca                	mov    %ecx,%edx
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 ab fc ff ff       	call   8003ae <getuint>
  800703:	89 c6                	mov    %eax,%esi
  800705:	89 d7                	mov    %edx,%edi
			base = 8;
  800707:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80070c:	eb 46                	jmp    800754 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800733:	8b 30                	mov    (%eax),%esi
  800735:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80073f:	eb 13                	jmp    800754 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800741:	89 ca                	mov    %ecx,%edx
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 63 fc ff ff       	call   8003ae <getuint>
  80074b:	89 c6                	mov    %eax,%esi
  80074d:	89 d7                	mov    %edx,%edi
			base = 16;
  80074f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800754:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800758:	89 54 24 10          	mov    %edx,0x10(%esp)
  80075c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80075f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800763:	89 44 24 08          	mov    %eax,0x8(%esp)
  800767:	89 34 24             	mov    %esi,(%esp)
  80076a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076e:	89 da                	mov    %ebx,%edx
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	e8 6c fb ff ff       	call   8002e4 <printnum>
			break;
  800778:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077b:	e9 cd fc ff ff       	jmp    80044d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078d:	e9 bb fc ff ff       	jmp    80044d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800796:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80079d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a0:	eb 01                	jmp    8007a3 <vprintfmt+0x379>
  8007a2:	4e                   	dec    %esi
  8007a3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007a7:	75 f9                	jne    8007a2 <vprintfmt+0x378>
  8007a9:	e9 9f fc ff ff       	jmp    80044d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007ae:	83 c4 4c             	add    $0x4c,%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	83 ec 28             	sub    $0x28,%esp
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	74 30                	je     800807 <vsnprintf+0x51>
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	7e 33                	jle    80080e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f0:	c7 04 24 e8 03 80 00 	movl   $0x8003e8,(%esp)
  8007f7:	e8 2e fc ff ff       	call   80042a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800805:	eb 0c                	jmp    800813 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080c:	eb 05                	jmp    800813 <vsnprintf+0x5d>
  80080e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800822:	8b 45 10             	mov    0x10(%ebp),%eax
  800825:	89 44 24 08          	mov    %eax,0x8(%esp)
  800829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 7b ff ff ff       	call   8007b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    
  80083d:	00 00                	add    %al,(%eax)
	...

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	eb 01                	jmp    80084e <strlen+0xe>
		n++;
  80084d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800852:	75 f9                	jne    80084d <strlen+0xd>
		n++;
	return n;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
  800864:	eb 01                	jmp    800867 <strnlen+0x11>
		n++;
  800866:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800867:	39 d0                	cmp    %edx,%eax
  800869:	74 06                	je     800871 <strnlen+0x1b>
  80086b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086f:	75 f5                	jne    800866 <strnlen+0x10>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087d:	ba 00 00 00 00       	mov    $0x0,%edx
  800882:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800885:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800888:	42                   	inc    %edx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 f5                	jne    800882 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089a:	89 1c 24             	mov    %ebx,(%esp)
  80089d:	e8 9e ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	89 04 24             	mov    %eax,(%esp)
  8008ae:	e8 c0 ff ff ff       	call   800873 <strcpy>
	return dst;
}
  8008b3:	89 d8                	mov    %ebx,%eax
  8008b5:	83 c4 08             	add    $0x8,%esp
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ce:	eb 0c                	jmp    8008dc <strncpy+0x21>
		*dst++ = *src;
  8008d0:	8a 1a                	mov    (%edx),%bl
  8008d2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	41                   	inc    %ecx
  8008dc:	39 f1                	cmp    %esi,%ecx
  8008de:	75 f0                	jne    8008d0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f2:	85 d2                	test   %edx,%edx
  8008f4:	75 0a                	jne    800900 <strlcpy+0x1c>
  8008f6:	89 f0                	mov    %esi,%eax
  8008f8:	eb 1a                	jmp    800914 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fa:	88 18                	mov    %bl,(%eax)
  8008fc:	40                   	inc    %eax
  8008fd:	41                   	inc    %ecx
  8008fe:	eb 02                	jmp    800902 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800900:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800902:	4a                   	dec    %edx
  800903:	74 0a                	je     80090f <strlcpy+0x2b>
  800905:	8a 19                	mov    (%ecx),%bl
  800907:	84 db                	test   %bl,%bl
  800909:	75 ef                	jne    8008fa <strlcpy+0x16>
  80090b:	89 c2                	mov    %eax,%edx
  80090d:	eb 02                	jmp    800911 <strlcpy+0x2d>
  80090f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800911:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800914:	29 f0                	sub    %esi,%eax
}
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800923:	eb 02                	jmp    800927 <strcmp+0xd>
		p++, q++;
  800925:	41                   	inc    %ecx
  800926:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800927:	8a 01                	mov    (%ecx),%al
  800929:	84 c0                	test   %al,%al
  80092b:	74 04                	je     800931 <strcmp+0x17>
  80092d:	3a 02                	cmp    (%edx),%al
  80092f:	74 f4                	je     800925 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800931:	0f b6 c0             	movzbl %al,%eax
  800934:	0f b6 12             	movzbl (%edx),%edx
  800937:	29 d0                	sub    %edx,%eax
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800945:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800948:	eb 03                	jmp    80094d <strncmp+0x12>
		n--, p++, q++;
  80094a:	4a                   	dec    %edx
  80094b:	40                   	inc    %eax
  80094c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094d:	85 d2                	test   %edx,%edx
  80094f:	74 14                	je     800965 <strncmp+0x2a>
  800951:	8a 18                	mov    (%eax),%bl
  800953:	84 db                	test   %bl,%bl
  800955:	74 04                	je     80095b <strncmp+0x20>
  800957:	3a 19                	cmp    (%ecx),%bl
  800959:	74 ef                	je     80094a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095b:	0f b6 00             	movzbl (%eax),%eax
  80095e:	0f b6 11             	movzbl (%ecx),%edx
  800961:	29 d0                	sub    %edx,%eax
  800963:	eb 05                	jmp    80096a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096a:	5b                   	pop    %ebx
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800976:	eb 05                	jmp    80097d <strchr+0x10>
		if (*s == c)
  800978:	38 ca                	cmp    %cl,%dl
  80097a:	74 0c                	je     800988 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097c:	40                   	inc    %eax
  80097d:	8a 10                	mov    (%eax),%dl
  80097f:	84 d2                	test   %dl,%dl
  800981:	75 f5                	jne    800978 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800993:	eb 05                	jmp    80099a <strfind+0x10>
		if (*s == c)
  800995:	38 ca                	cmp    %cl,%dl
  800997:	74 07                	je     8009a0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800999:	40                   	inc    %eax
  80099a:	8a 10                	mov    (%eax),%dl
  80099c:	84 d2                	test   %dl,%dl
  80099e:	75 f5                	jne    800995 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b1:	85 c9                	test   %ecx,%ecx
  8009b3:	74 30                	je     8009e5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bb:	75 25                	jne    8009e2 <memset+0x40>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 20                	jne    8009e2 <memset+0x40>
		c &= 0xFF;
  8009c2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c5:	89 d3                	mov    %edx,%ebx
  8009c7:	c1 e3 08             	shl    $0x8,%ebx
  8009ca:	89 d6                	mov    %edx,%esi
  8009cc:	c1 e6 18             	shl    $0x18,%esi
  8009cf:	89 d0                	mov    %edx,%eax
  8009d1:	c1 e0 10             	shl    $0x10,%eax
  8009d4:	09 f0                	or     %esi,%eax
  8009d6:	09 d0                	or     %edx,%eax
  8009d8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009da:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009dd:	fc                   	cld    
  8009de:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e0:	eb 03                	jmp    8009e5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e2:	fc                   	cld    
  8009e3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e5:	89 f8                	mov    %edi,%eax
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fa:	39 c6                	cmp    %eax,%esi
  8009fc:	73 34                	jae    800a32 <memmove+0x46>
  8009fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 2d                	jae    800a32 <memmove+0x46>
		s += n;
		d += n;
  800a05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	f6 c2 03             	test   $0x3,%dl
  800a0b:	75 1b                	jne    800a28 <memmove+0x3c>
  800a0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a13:	75 13                	jne    800a28 <memmove+0x3c>
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 0e                	jne    800a28 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1a:	83 ef 04             	sub    $0x4,%edi
  800a1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a20:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a23:	fd                   	std    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb 07                	jmp    800a2f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a28:	4f                   	dec    %edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 20                	jmp    800a52 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a38:	75 13                	jne    800a4d <memmove+0x61>
  800a3a:	a8 03                	test   $0x3,%al
  800a3c:	75 0f                	jne    800a4d <memmove+0x61>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 0a                	jne    800a4d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4b:	eb 05                	jmp    800a52 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	89 04 24             	mov    %eax,(%esp)
  800a70:	e8 77 ff ff ff       	call   8009ec <memmove>
}
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a86:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8b:	eb 16                	jmp    800aa3 <memcmp+0x2c>
		if (*s1 != *s2)
  800a8d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a90:	42                   	inc    %edx
  800a91:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a95:	38 c8                	cmp    %cl,%al
  800a97:	74 0a                	je     800aa3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 c9             	movzbl %cl,%ecx
  800a9f:	29 c8                	sub    %ecx,%eax
  800aa1:	eb 09                	jmp    800aac <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa3:	39 da                	cmp    %ebx,%edx
  800aa5:	75 e6                	jne    800a8d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abf:	eb 05                	jmp    800ac6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac1:	38 08                	cmp    %cl,(%eax)
  800ac3:	74 05                	je     800aca <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac5:	40                   	inc    %eax
  800ac6:	39 d0                	cmp    %edx,%eax
  800ac8:	72 f7                	jb     800ac1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad8:	eb 01                	jmp    800adb <strtol+0xf>
		s++;
  800ada:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adb:	8a 02                	mov    (%edx),%al
  800add:	3c 20                	cmp    $0x20,%al
  800adf:	74 f9                	je     800ada <strtol+0xe>
  800ae1:	3c 09                	cmp    $0x9,%al
  800ae3:	74 f5                	je     800ada <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae5:	3c 2b                	cmp    $0x2b,%al
  800ae7:	75 08                	jne    800af1 <strtol+0x25>
		s++;
  800ae9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aea:	bf 00 00 00 00       	mov    $0x0,%edi
  800aef:	eb 13                	jmp    800b04 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af1:	3c 2d                	cmp    $0x2d,%al
  800af3:	75 0a                	jne    800aff <strtol+0x33>
		s++, neg = 1;
  800af5:	8d 52 01             	lea    0x1(%edx),%edx
  800af8:	bf 01 00 00 00       	mov    $0x1,%edi
  800afd:	eb 05                	jmp    800b04 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b04:	85 db                	test   %ebx,%ebx
  800b06:	74 05                	je     800b0d <strtol+0x41>
  800b08:	83 fb 10             	cmp    $0x10,%ebx
  800b0b:	75 28                	jne    800b35 <strtol+0x69>
  800b0d:	8a 02                	mov    (%edx),%al
  800b0f:	3c 30                	cmp    $0x30,%al
  800b11:	75 10                	jne    800b23 <strtol+0x57>
  800b13:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b17:	75 0a                	jne    800b23 <strtol+0x57>
		s += 2, base = 16;
  800b19:	83 c2 02             	add    $0x2,%edx
  800b1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b21:	eb 12                	jmp    800b35 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b23:	85 db                	test   %ebx,%ebx
  800b25:	75 0e                	jne    800b35 <strtol+0x69>
  800b27:	3c 30                	cmp    $0x30,%al
  800b29:	75 05                	jne    800b30 <strtol+0x64>
		s++, base = 8;
  800b2b:	42                   	inc    %edx
  800b2c:	b3 08                	mov    $0x8,%bl
  800b2e:	eb 05                	jmp    800b35 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b30:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3c:	8a 0a                	mov    (%edx),%cl
  800b3e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	77 08                	ja     800b4e <strtol+0x82>
			dig = *s - '0';
  800b46:	0f be c9             	movsbl %cl,%ecx
  800b49:	83 e9 30             	sub    $0x30,%ecx
  800b4c:	eb 1e                	jmp    800b6c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b4e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 08                	ja     800b5e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b56:	0f be c9             	movsbl %cl,%ecx
  800b59:	83 e9 57             	sub    $0x57,%ecx
  800b5c:	eb 0e                	jmp    800b6c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b5e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b61:	80 fb 19             	cmp    $0x19,%bl
  800b64:	77 12                	ja     800b78 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b66:	0f be c9             	movsbl %cl,%ecx
  800b69:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6c:	39 f1                	cmp    %esi,%ecx
  800b6e:	7d 0c                	jge    800b7c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b70:	42                   	inc    %edx
  800b71:	0f af c6             	imul   %esi,%eax
  800b74:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b76:	eb c4                	jmp    800b3c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b78:	89 c1                	mov    %eax,%ecx
  800b7a:	eb 02                	jmp    800b7e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b82:	74 05                	je     800b89 <strtol+0xbd>
		*endptr = (char *) s;
  800b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b87:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b89:	85 ff                	test   %edi,%edi
  800b8b:	74 04                	je     800b91 <strtol+0xc5>
  800b8d:	89 c8                	mov    %ecx,%eax
  800b8f:	f7 d8                	neg    %eax
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    
	...

00800b98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 c3                	mov    %eax,%ebx
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	89 c6                	mov    %eax,%esi
  800baf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be3:	b8 03 00 00 00       	mov    $0x3,%eax
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 cb                	mov    %ecx,%ebx
  800bed:	89 cf                	mov    %ecx,%edi
  800bef:	89 ce                	mov    %ecx,%esi
  800bf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 28                	jle    800c1f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800c1a:	e8 b1 f5 ff ff       	call   8001d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1f:	83 c4 2c             	add    $0x2c,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 02 00 00 00       	mov    $0x2,%eax
  800c37:	89 d1                	mov    %edx,%ecx
  800c39:	89 d3                	mov    %edx,%ebx
  800c3b:	89 d7                	mov    %edx,%edi
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_yield>:

void
sys_yield(void)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c56:	89 d1                	mov    %edx,%ecx
  800c58:	89 d3                	mov    %edx,%ebx
  800c5a:	89 d7                	mov    %edx,%edi
  800c5c:	89 d6                	mov    %edx,%esi
  800c5e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c6e:	be 00 00 00 00       	mov    $0x0,%esi
  800c73:	b8 04 00 00 00       	mov    $0x4,%eax
  800c78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 f7                	mov    %esi,%edi
  800c83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 28                	jle    800cb1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c94:	00 
  800c95:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca4:	00 
  800ca5:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800cac:	e8 1f f5 ff ff       	call   8001d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb1:	83 c4 2c             	add    $0x2c,%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 28                	jle    800d04 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ce7:	00 
  800ce8:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800cef:	00 
  800cf0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf7:	00 
  800cf8:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800cff:	e8 cc f4 ff ff       	call   8001d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d04:	83 c4 2c             	add    $0x2c,%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 28                	jle    800d57 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d33:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800d42:	00 
  800d43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4a:	00 
  800d4b:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800d52:	e8 79 f4 ff ff       	call   8001d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d57:	83 c4 2c             	add    $0x2c,%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 28                	jle    800daa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d86:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800d95:	00 
  800d96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9d:	00 
  800d9e:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800da5:	e8 26 f4 ff ff       	call   8001d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800daa:	83 c4 2c             	add    $0x2c,%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 df                	mov    %ebx,%edi
  800dcd:	89 de                	mov    %ebx,%esi
  800dcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7e 28                	jle    800dfd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de0:	00 
  800de1:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800de8:	00 
  800de9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df0:	00 
  800df1:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800df8:	e8 d3 f3 ff ff       	call   8001d0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfd:	83 c4 2c             	add    $0x2c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 28                	jle    800e50 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e33:	00 
  800e34:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e43:	00 
  800e44:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800e4b:	e8 80 f3 ff ff       	call   8001d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e50:	83 c4 2c             	add    $0x2c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	be 00 00 00 00       	mov    $0x0,%esi
  800e63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5f                   	pop    %edi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e89:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e91:	89 cb                	mov    %ecx,%ebx
  800e93:	89 cf                	mov    %ecx,%edi
  800e95:	89 ce                	mov    %ecx,%esi
  800e97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	7e 28                	jle    800ec5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 08 df 2a 80 	movl   $0x802adf,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800ec0:	e8 0b f3 ff ff       	call   8001d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec5:	83 c4 2c             	add    $0x2c,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
  800ecd:	00 00                	add    %al,(%eax)
	...

00800ed0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	05 00 00 00 30       	add    $0x30000000,%eax
  800edb:	c1 e8 0c             	shr    $0xc,%eax
}
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	89 04 24             	mov    %eax,(%esp)
  800eec:	e8 df ff ff ff       	call   800ed0 <fd2num>
  800ef1:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ef6:	c1 e0 0c             	shl    $0xc,%eax
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f02:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f07:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f09:	89 c2                	mov    %eax,%edx
  800f0b:	c1 ea 16             	shr    $0x16,%edx
  800f0e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f15:	f6 c2 01             	test   $0x1,%dl
  800f18:	74 11                	je     800f2b <fd_alloc+0x30>
  800f1a:	89 c2                	mov    %eax,%edx
  800f1c:	c1 ea 0c             	shr    $0xc,%edx
  800f1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f26:	f6 c2 01             	test   $0x1,%dl
  800f29:	75 09                	jne    800f34 <fd_alloc+0x39>
			*fd_store = fd;
  800f2b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	eb 17                	jmp    800f4b <fd_alloc+0x50>
  800f34:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f39:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f3e:	75 c7                	jne    800f07 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f46:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f4b:	5b                   	pop    %ebx
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f54:	83 f8 1f             	cmp    $0x1f,%eax
  800f57:	77 36                	ja     800f8f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f59:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f5e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	c1 ea 16             	shr    $0x16,%edx
  800f66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6d:	f6 c2 01             	test   $0x1,%dl
  800f70:	74 24                	je     800f96 <fd_lookup+0x48>
  800f72:	89 c2                	mov    %eax,%edx
  800f74:	c1 ea 0c             	shr    $0xc,%edx
  800f77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7e:	f6 c2 01             	test   $0x1,%dl
  800f81:	74 1a                	je     800f9d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f86:	89 02                	mov    %eax,(%edx)
	return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8d:	eb 13                	jmp    800fa2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f94:	eb 0c                	jmp    800fa2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9b:	eb 05                	jmp    800fa2 <fd_lookup+0x54>
  800f9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 14             	sub    $0x14,%esp
  800fab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb6:	eb 0e                	jmp    800fc6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fb8:	39 08                	cmp    %ecx,(%eax)
  800fba:	75 09                	jne    800fc5 <dev_lookup+0x21>
			*dev = devtab[i];
  800fbc:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	eb 35                	jmp    800ffa <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc5:	42                   	inc    %edx
  800fc6:	8b 04 95 88 2b 80 00 	mov    0x802b88(,%edx,4),%eax
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	75 e7                	jne    800fb8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd1:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd6:	8b 00                	mov    (%eax),%eax
  800fd8:	8b 40 48             	mov    0x48(%eax),%eax
  800fdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe3:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  800fea:	e8 d9 f2 ff ff       	call   8002c8 <cprintf>
	*dev = 0;
  800fef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ff5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ffa:	83 c4 14             	add    $0x14,%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	56                   	push   %esi
  801004:	53                   	push   %ebx
  801005:	83 ec 30             	sub    $0x30,%esp
  801008:	8b 75 08             	mov    0x8(%ebp),%esi
  80100b:	8a 45 0c             	mov    0xc(%ebp),%al
  80100e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801011:	89 34 24             	mov    %esi,(%esp)
  801014:	e8 b7 fe ff ff       	call   800ed0 <fd2num>
  801019:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80101c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801020:	89 04 24             	mov    %eax,(%esp)
  801023:	e8 26 ff ff ff       	call   800f4e <fd_lookup>
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 05                	js     801033 <fd_close+0x33>
	    || fd != fd2)
  80102e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801031:	74 0d                	je     801040 <fd_close+0x40>
		return (must_exist ? r : 0);
  801033:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801037:	75 46                	jne    80107f <fd_close+0x7f>
  801039:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103e:	eb 3f                	jmp    80107f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801040:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801043:	89 44 24 04          	mov    %eax,0x4(%esp)
  801047:	8b 06                	mov    (%esi),%eax
  801049:	89 04 24             	mov    %eax,(%esp)
  80104c:	e8 53 ff ff ff       	call   800fa4 <dev_lookup>
  801051:	89 c3                	mov    %eax,%ebx
  801053:	85 c0                	test   %eax,%eax
  801055:	78 18                	js     80106f <fd_close+0x6f>
		if (dev->dev_close)
  801057:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105a:	8b 40 10             	mov    0x10(%eax),%eax
  80105d:	85 c0                	test   %eax,%eax
  80105f:	74 09                	je     80106a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801061:	89 34 24             	mov    %esi,(%esp)
  801064:	ff d0                	call   *%eax
  801066:	89 c3                	mov    %eax,%ebx
  801068:	eb 05                	jmp    80106f <fd_close+0x6f>
		else
			r = 0;
  80106a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80106f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107a:	e8 8d fc ff ff       	call   800d0c <sys_page_unmap>
	return r;
}
  80107f:	89 d8                	mov    %ebx,%eax
  801081:	83 c4 30             	add    $0x30,%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801091:	89 44 24 04          	mov    %eax,0x4(%esp)
  801095:	8b 45 08             	mov    0x8(%ebp),%eax
  801098:	89 04 24             	mov    %eax,(%esp)
  80109b:	e8 ae fe ff ff       	call   800f4e <fd_lookup>
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 13                	js     8010b7 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010a4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ab:	00 
  8010ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 49 ff ff ff       	call   801000 <fd_close>
}
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <close_all>:

void
close_all(void)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c5:	89 1c 24             	mov    %ebx,(%esp)
  8010c8:	e8 bb ff ff ff       	call   801088 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010cd:	43                   	inc    %ebx
  8010ce:	83 fb 20             	cmp    $0x20,%ebx
  8010d1:	75 f2                	jne    8010c5 <close_all+0xc>
		close(i);
}
  8010d3:	83 c4 14             	add    $0x14,%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 4c             	sub    $0x4c,%esp
  8010e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	89 04 24             	mov    %eax,(%esp)
  8010f2:	e8 57 fe ff ff       	call   800f4e <fd_lookup>
  8010f7:	89 c3                	mov    %eax,%ebx
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	0f 88 e1 00 00 00    	js     8011e2 <dup+0x109>
		return r;
	close(newfdnum);
  801101:	89 3c 24             	mov    %edi,(%esp)
  801104:	e8 7f ff ff ff       	call   801088 <close>

	newfd = INDEX2FD(newfdnum);
  801109:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80110f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 c3 fd ff ff       	call   800ee0 <fd2data>
  80111d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80111f:	89 34 24             	mov    %esi,(%esp)
  801122:	e8 b9 fd ff ff       	call   800ee0 <fd2data>
  801127:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	c1 e8 16             	shr    $0x16,%eax
  80112f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801136:	a8 01                	test   $0x1,%al
  801138:	74 46                	je     801180 <dup+0xa7>
  80113a:	89 d8                	mov    %ebx,%eax
  80113c:	c1 e8 0c             	shr    $0xc,%eax
  80113f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801146:	f6 c2 01             	test   $0x1,%dl
  801149:	74 35                	je     801180 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801152:	25 07 0e 00 00       	and    $0xe07,%eax
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80115e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801162:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801169:	00 
  80116a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80116e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801175:	e8 3f fb ff ff       	call   800cb9 <sys_page_map>
  80117a:	89 c3                	mov    %eax,%ebx
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 3b                	js     8011bb <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801183:	89 c2                	mov    %eax,%edx
  801185:	c1 ea 0c             	shr    $0xc,%edx
  801188:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801195:	89 54 24 10          	mov    %edx,0x10(%esp)
  801199:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80119d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a4:	00 
  8011a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b0:	e8 04 fb ff ff       	call   800cb9 <sys_page_map>
  8011b5:	89 c3                	mov    %eax,%ebx
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	79 25                	jns    8011e0 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c6:	e8 41 fb ff ff       	call   800d0c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d9:	e8 2e fb ff ff       	call   800d0c <sys_page_unmap>
	return r;
  8011de:	eb 02                	jmp    8011e2 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011e0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011e2:	89 d8                	mov    %ebx,%eax
  8011e4:	83 c4 4c             	add    $0x4c,%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 24             	sub    $0x24,%esp
  8011f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fd:	89 1c 24             	mov    %ebx,(%esp)
  801200:	e8 49 fd ff ff       	call   800f4e <fd_lookup>
  801205:	85 c0                	test   %eax,%eax
  801207:	78 6f                	js     801278 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801213:	8b 00                	mov    (%eax),%eax
  801215:	89 04 24             	mov    %eax,(%esp)
  801218:	e8 87 fd ff ff       	call   800fa4 <dev_lookup>
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 57                	js     801278 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801224:	8b 50 08             	mov    0x8(%eax),%edx
  801227:	83 e2 03             	and    $0x3,%edx
  80122a:	83 fa 01             	cmp    $0x1,%edx
  80122d:	75 25                	jne    801254 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80122f:	a1 04 40 80 00       	mov    0x804004,%eax
  801234:	8b 00                	mov    (%eax),%eax
  801236:	8b 40 48             	mov    0x48(%eax),%eax
  801239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801241:	c7 04 24 4d 2b 80 00 	movl   $0x802b4d,(%esp)
  801248:	e8 7b f0 ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801252:	eb 24                	jmp    801278 <read+0x8c>
	}
	if (!dev->dev_read)
  801254:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801257:	8b 52 08             	mov    0x8(%edx),%edx
  80125a:	85 d2                	test   %edx,%edx
  80125c:	74 15                	je     801273 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80125e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801261:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801268:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80126c:	89 04 24             	mov    %eax,(%esp)
  80126f:	ff d2                	call   *%edx
  801271:	eb 05                	jmp    801278 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801273:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801278:	83 c4 24             	add    $0x24,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 1c             	sub    $0x1c,%esp
  801287:	8b 7d 08             	mov    0x8(%ebp),%edi
  80128a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801292:	eb 23                	jmp    8012b7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801294:	89 f0                	mov    %esi,%eax
  801296:	29 d8                	sub    %ebx,%eax
  801298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80129c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129f:	01 d8                	add    %ebx,%eax
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	89 3c 24             	mov    %edi,(%esp)
  8012a8:	e8 3f ff ff ff       	call   8011ec <read>
		if (m < 0)
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 10                	js     8012c1 <readn+0x43>
			return m;
		if (m == 0)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	74 0a                	je     8012bf <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b5:	01 c3                	add    %eax,%ebx
  8012b7:	39 f3                	cmp    %esi,%ebx
  8012b9:	72 d9                	jb     801294 <readn+0x16>
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	eb 02                	jmp    8012c1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012bf:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012c1:	83 c4 1c             	add    $0x1c,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 24             	sub    $0x24,%esp
  8012d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012da:	89 1c 24             	mov    %ebx,(%esp)
  8012dd:	e8 6c fc ff ff       	call   800f4e <fd_lookup>
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 6a                	js     801350 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	8b 00                	mov    (%eax),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 aa fc ff ff       	call   800fa4 <dev_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 52                	js     801350 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801301:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801305:	75 25                	jne    80132c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801307:	a1 04 40 80 00       	mov    0x804004,%eax
  80130c:	8b 00                	mov    (%eax),%eax
  80130e:	8b 40 48             	mov    0x48(%eax),%eax
  801311:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	c7 04 24 69 2b 80 00 	movl   $0x802b69,(%esp)
  801320:	e8 a3 ef ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  801325:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132a:	eb 24                	jmp    801350 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132f:	8b 52 0c             	mov    0xc(%edx),%edx
  801332:	85 d2                	test   %edx,%edx
  801334:	74 15                	je     80134b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801336:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801340:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801344:	89 04 24             	mov    %eax,(%esp)
  801347:	ff d2                	call   *%edx
  801349:	eb 05                	jmp    801350 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80134b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801350:	83 c4 24             	add    $0x24,%esp
  801353:	5b                   	pop    %ebx
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <seek>:

int
seek(int fdnum, off_t offset)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80135f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	89 04 24             	mov    %eax,(%esp)
  801369:	e8 e0 fb ff ff       	call   800f4e <fd_lookup>
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 0e                	js     801380 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801372:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801375:	8b 55 0c             	mov    0xc(%ebp),%edx
  801378:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 24             	sub    $0x24,%esp
  801389:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801393:	89 1c 24             	mov    %ebx,(%esp)
  801396:	e8 b3 fb ff ff       	call   800f4e <fd_lookup>
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 63                	js     801402 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	8b 00                	mov    (%eax),%eax
  8013ab:	89 04 24             	mov    %eax,(%esp)
  8013ae:	e8 f1 fb ff ff       	call   800fa4 <dev_lookup>
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 4b                	js     801402 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013be:	75 25                	jne    8013e5 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c5:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d2:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  8013d9:	e8 ea ee ff ff       	call   8002c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e3:	eb 1d                	jmp    801402 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8013e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e8:	8b 52 18             	mov    0x18(%edx),%edx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	74 0e                	je     8013fd <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	ff d2                	call   *%edx
  8013fb:	eb 05                	jmp    801402 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801402:	83 c4 24             	add    $0x24,%esp
  801405:	5b                   	pop    %ebx
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	53                   	push   %ebx
  80140c:	83 ec 24             	sub    $0x24,%esp
  80140f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801412:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801415:	89 44 24 04          	mov    %eax,0x4(%esp)
  801419:	8b 45 08             	mov    0x8(%ebp),%eax
  80141c:	89 04 24             	mov    %eax,(%esp)
  80141f:	e8 2a fb ff ff       	call   800f4e <fd_lookup>
  801424:	85 c0                	test   %eax,%eax
  801426:	78 52                	js     80147a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801432:	8b 00                	mov    (%eax),%eax
  801434:	89 04 24             	mov    %eax,(%esp)
  801437:	e8 68 fb ff ff       	call   800fa4 <dev_lookup>
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 3a                	js     80147a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801443:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801447:	74 2c                	je     801475 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801449:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80144c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801453:	00 00 00 
	stat->st_isdir = 0;
  801456:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80145d:	00 00 00 
	stat->st_dev = dev;
  801460:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801466:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80146d:	89 14 24             	mov    %edx,(%esp)
  801470:	ff 50 14             	call   *0x14(%eax)
  801473:	eb 05                	jmp    80147a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801475:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80147a:	83 c4 24             	add    $0x24,%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801488:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80148f:	00 
  801490:	8b 45 08             	mov    0x8(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 88 02 00 00       	call   801723 <open>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 1b                	js     8014bc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	89 1c 24             	mov    %ebx,(%esp)
  8014ab:	e8 58 ff ff ff       	call   801408 <fstat>
  8014b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b2:	89 1c 24             	mov    %ebx,(%esp)
  8014b5:	e8 ce fb ff ff       	call   801088 <close>
	return r;
  8014ba:	89 f3                	mov    %esi,%ebx
}
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    
  8014c5:	00 00                	add    %al,(%eax)
	...

008014c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	56                   	push   %esi
  8014cc:	53                   	push   %ebx
  8014cd:	83 ec 10             	sub    $0x10,%esp
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014db:	75 11                	jne    8014ee <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014e4:	e8 06 0f 00 00       	call   8023ef <ipc_find_env>
  8014e9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ee:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014f5:	00 
  8014f6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014fd:	00 
  8014fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801502:	a1 00 40 80 00       	mov    0x804000,%eax
  801507:	89 04 24             	mov    %eax,(%esp)
  80150a:	e8 7a 0e 00 00       	call   802389 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  80150f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801516:	00 
  801517:	89 74 24 04          	mov    %esi,0x4(%esp)
  80151b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801522:	e8 f5 0d 00 00       	call   80231c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	8b 40 0c             	mov    0xc(%eax),%eax
  80153a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80153f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801542:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	b8 02 00 00 00       	mov    $0x2,%eax
  801551:	e8 72 ff ff ff       	call   8014c8 <fsipc>
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80155e:	8b 45 08             	mov    0x8(%ebp),%eax
  801561:	8b 40 0c             	mov    0xc(%eax),%eax
  801564:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 06 00 00 00       	mov    $0x6,%eax
  801573:	e8 50 ff ff ff       	call   8014c8 <fsipc>
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 14             	sub    $0x14,%esp
  801581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	8b 40 0c             	mov    0xc(%eax),%eax
  80158a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158f:	ba 00 00 00 00       	mov    $0x0,%edx
  801594:	b8 05 00 00 00       	mov    $0x5,%eax
  801599:	e8 2a ff ff ff       	call   8014c8 <fsipc>
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 2b                	js     8015cd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015a2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015a9:	00 
  8015aa:	89 1c 24             	mov    %ebx,(%esp)
  8015ad:	e8 c1 f2 ff ff       	call   800873 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8015c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cd:	83 c4 14             	add    $0x14,%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 14             	sub    $0x14,%esp
  8015da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8015f0:	76 05                	jbe    8015f7 <devfile_write+0x24>
  8015f2:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8015f7:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  8015fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801600:	8b 45 0c             	mov    0xc(%ebp),%eax
  801603:	89 44 24 04          	mov    %eax,0x4(%esp)
  801607:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80160e:	e8 43 f4 ff ff       	call   800a56 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	b8 04 00 00 00       	mov    $0x4,%eax
  80161d:	e8 a6 fe ff ff       	call   8014c8 <fsipc>
  801622:	85 c0                	test   %eax,%eax
  801624:	78 53                	js     801679 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801626:	39 c3                	cmp    %eax,%ebx
  801628:	73 24                	jae    80164e <devfile_write+0x7b>
  80162a:	c7 44 24 0c 98 2b 80 	movl   $0x802b98,0xc(%esp)
  801631:	00 
  801632:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801639:	00 
  80163a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801641:	00 
  801642:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  801649:	e8 82 eb ff ff       	call   8001d0 <_panic>
	assert(r <= PGSIZE);
  80164e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801653:	7e 24                	jle    801679 <devfile_write+0xa6>
  801655:	c7 44 24 0c bf 2b 80 	movl   $0x802bbf,0xc(%esp)
  80165c:	00 
  80165d:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801664:	00 
  801665:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80166c:	00 
  80166d:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  801674:	e8 57 eb ff ff       	call   8001d0 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801679:	83 c4 14             	add    $0x14,%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 10             	sub    $0x10,%esp
  801687:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	8b 40 0c             	mov    0xc(%eax),%eax
  801690:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801695:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80169b:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8016a5:	e8 1e fe ff ff       	call   8014c8 <fsipc>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 6a                	js     80171a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016b0:	39 c6                	cmp    %eax,%esi
  8016b2:	73 24                	jae    8016d8 <devfile_read+0x59>
  8016b4:	c7 44 24 0c 98 2b 80 	movl   $0x802b98,0xc(%esp)
  8016bb:	00 
  8016bc:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  8016c3:	00 
  8016c4:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8016cb:	00 
  8016cc:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8016d3:	e8 f8 ea ff ff       	call   8001d0 <_panic>
	assert(r <= PGSIZE);
  8016d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016dd:	7e 24                	jle    801703 <devfile_read+0x84>
  8016df:	c7 44 24 0c bf 2b 80 	movl   $0x802bbf,0xc(%esp)
  8016e6:	00 
  8016e7:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  8016ee:	00 
  8016ef:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8016f6:	00 
  8016f7:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8016fe:	e8 cd ea ff ff       	call   8001d0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801703:	89 44 24 08          	mov    %eax,0x8(%esp)
  801707:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80170e:	00 
  80170f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801712:	89 04 24             	mov    %eax,(%esp)
  801715:	e8 d2 f2 ff ff       	call   8009ec <memmove>
	return r;
}
  80171a:	89 d8                	mov    %ebx,%eax
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	56                   	push   %esi
  801727:	53                   	push   %ebx
  801728:	83 ec 20             	sub    $0x20,%esp
  80172b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80172e:	89 34 24             	mov    %esi,(%esp)
  801731:	e8 0a f1 ff ff       	call   800840 <strlen>
  801736:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80173b:	7f 60                	jg     80179d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80173d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801740:	89 04 24             	mov    %eax,(%esp)
  801743:	e8 b3 f7 ff ff       	call   800efb <fd_alloc>
  801748:	89 c3                	mov    %eax,%ebx
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 54                	js     8017a2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80174e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801752:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801759:	e8 15 f1 ff ff       	call   800873 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80175e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801761:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801766:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801769:	b8 01 00 00 00       	mov    $0x1,%eax
  80176e:	e8 55 fd ff ff       	call   8014c8 <fsipc>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	85 c0                	test   %eax,%eax
  801777:	79 15                	jns    80178e <open+0x6b>
		fd_close(fd, 0);
  801779:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801780:	00 
  801781:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801784:	89 04 24             	mov    %eax,(%esp)
  801787:	e8 74 f8 ff ff       	call   801000 <fd_close>
		return r;
  80178c:	eb 14                	jmp    8017a2 <open+0x7f>
	}

	return fd2num(fd);
  80178e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 37 f7 ff ff       	call   800ed0 <fd2num>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	eb 05                	jmp    8017a2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80179d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017a2:	89 d8                	mov    %ebx,%eax
  8017a4:	83 c4 20             	add    $0x20,%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8017bb:	e8 08 fd ff ff       	call   8014c8 <fsipc>
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    
	...

008017c4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	57                   	push   %edi
  8017c8:	56                   	push   %esi
  8017c9:	53                   	push   %ebx
  8017ca:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8017d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017d7:	00 
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	89 04 24             	mov    %eax,(%esp)
  8017de:	e8 40 ff ff ff       	call   801723 <open>
  8017e3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	0f 88 77 05 00 00    	js     801d68 <spawn+0x5a4>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8017f1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8017f8:	00 
  8017f9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801809:	89 04 24             	mov    %eax,(%esp)
  80180c:	e8 6d fa ff ff       	call   80127e <readn>
  801811:	3d 00 02 00 00       	cmp    $0x200,%eax
  801816:	75 0c                	jne    801824 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801818:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80181f:	45 4c 46 
  801822:	74 3b                	je     80185f <spawn+0x9b>
		close(fd);
  801824:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	e8 56 f8 ff ff       	call   801088 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801832:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801839:	46 
  80183a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801840:	89 44 24 04          	mov    %eax,0x4(%esp)
  801844:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  80184b:	e8 78 ea ff ff       	call   8002c8 <cprintf>
		return -E_NOT_EXEC;
  801850:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801857:	ff ff ff 
  80185a:	e9 15 05 00 00       	jmp    801d74 <spawn+0x5b0>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80185f:	ba 07 00 00 00       	mov    $0x7,%edx
  801864:	89 d0                	mov    %edx,%eax
  801866:	cd 30                	int    $0x30
  801868:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80186e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801874:	85 c0                	test   %eax,%eax
  801876:	0f 88 f8 04 00 00    	js     801d74 <spawn+0x5b0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80187c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801881:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801888:	c1 e0 07             	shl    $0x7,%eax
  80188b:	29 d0                	sub    %edx,%eax
  80188d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801893:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801899:	b9 11 00 00 00       	mov    $0x11,%ecx
  80189e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018a0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018a6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018ac:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8018b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018b9:	eb 0d                	jmp    8018c8 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 7d ef ff ff       	call   800840 <strlen>
  8018c3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018c7:	46                   	inc    %esi
  8018c8:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8018ca:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018d1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	75 e3                	jne    8018bb <spawn+0xf7>
  8018d8:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  8018de:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8018e4:	bf 00 10 40 00       	mov    $0x401000,%edi
  8018e9:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8018eb:	89 f8                	mov    %edi,%eax
  8018ed:	83 e0 fc             	and    $0xfffffffc,%eax
  8018f0:	f7 d2                	not    %edx
  8018f2:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8018f5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8018fb:	89 d0                	mov    %edx,%eax
  8018fd:	83 e8 08             	sub    $0x8,%eax
  801900:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801905:	0f 86 7a 04 00 00    	jbe    801d85 <spawn+0x5c1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80190b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801912:	00 
  801913:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80191a:	00 
  80191b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801922:	e8 3e f3 ff ff       	call   800c65 <sys_page_alloc>
  801927:	85 c0                	test   %eax,%eax
  801929:	0f 88 5b 04 00 00    	js     801d8a <spawn+0x5c6>
  80192f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801934:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  80193a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80193d:	eb 2e                	jmp    80196d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80193f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801945:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80194b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80194e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801951:	89 44 24 04          	mov    %eax,0x4(%esp)
  801955:	89 3c 24             	mov    %edi,(%esp)
  801958:	e8 16 ef ff ff       	call   800873 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80195d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801960:	89 04 24             	mov    %eax,(%esp)
  801963:	e8 d8 ee ff ff       	call   800840 <strlen>
  801968:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80196c:	43                   	inc    %ebx
  80196d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801973:	7c ca                	jl     80193f <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801975:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80197b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801981:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801988:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80198e:	74 24                	je     8019b4 <spawn+0x1f0>
  801990:	c7 44 24 0c 40 2c 80 	movl   $0x802c40,0xc(%esp)
  801997:	00 
  801998:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  80199f:	00 
  8019a0:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  8019a7:	00 
  8019a8:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8019af:	e8 1c e8 ff ff       	call   8001d0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019b4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019ba:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8019bf:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019c5:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8019c8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019ce:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8019d1:	89 d0                	mov    %edx,%eax
  8019d3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8019d8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8019de:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019e5:	00 
  8019e6:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8019ed:	ee 
  8019ee:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8019f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019ff:	00 
  801a00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a07:	e8 ad f2 ff ff       	call   800cb9 <sys_page_map>
  801a0c:	89 c3                	mov    %eax,%ebx
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 1a                	js     801a2c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a12:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a19:	00 
  801a1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a21:	e8 e6 f2 ff ff       	call   800d0c <sys_page_unmap>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	79 1f                	jns    801a4b <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a2c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a33:	00 
  801a34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3b:	e8 cc f2 ff ff       	call   800d0c <sys_page_unmap>
	return r;
  801a40:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801a46:	e9 29 03 00 00       	jmp    801d74 <spawn+0x5b0>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a4b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801a51:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801a57:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a5d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801a64:	00 00 00 
  801a67:	e9 bb 01 00 00       	jmp    801c27 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801a6c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a72:	83 38 01             	cmpl   $0x1,(%eax)
  801a75:	0f 85 9f 01 00 00    	jne    801c1a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a7b:	89 c2                	mov    %eax,%edx
  801a7d:	8b 40 18             	mov    0x18(%eax),%eax
  801a80:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801a83:	83 f8 01             	cmp    $0x1,%eax
  801a86:	19 c0                	sbb    %eax,%eax
  801a88:	83 e0 fe             	and    $0xfffffffe,%eax
  801a8b:	83 c0 07             	add    $0x7,%eax
  801a8e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a94:	8b 52 04             	mov    0x4(%edx),%edx
  801a97:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801a9d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801aa3:	8b 40 10             	mov    0x10(%eax),%eax
  801aa6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801aac:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ab2:	8b 52 14             	mov    0x14(%edx),%edx
  801ab5:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801abb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ac1:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ac4:	89 f8                	mov    %edi,%eax
  801ac6:	25 ff 0f 00 00       	and    $0xfff,%eax
  801acb:	74 16                	je     801ae3 <spawn+0x31f>
		va -= i;
  801acd:	29 c7                	sub    %eax,%edi
		memsz += i;
  801acf:	01 c2                	add    %eax,%edx
  801ad1:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801ad7:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801add:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ae3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae8:	e9 1f 01 00 00       	jmp    801c0c <spawn+0x448>
		if (i >= filesz) {
  801aed:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  801af3:	72 2b                	jb     801b20 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801af5:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801afb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801aff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b03:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b09:	89 04 24             	mov    %eax,(%esp)
  801b0c:	e8 54 f1 ff ff       	call   800c65 <sys_page_alloc>
  801b11:	85 c0                	test   %eax,%eax
  801b13:	0f 89 e7 00 00 00    	jns    801c00 <spawn+0x43c>
  801b19:	89 c6                	mov    %eax,%esi
  801b1b:	e9 24 02 00 00       	jmp    801d44 <spawn+0x580>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b20:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b27:	00 
  801b28:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b2f:	00 
  801b30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b37:	e8 29 f1 ff ff       	call   800c65 <sys_page_alloc>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	0f 88 f6 01 00 00    	js     801d3a <spawn+0x576>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b44:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801b4a:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b50:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b56:	89 04 24             	mov    %eax,(%esp)
  801b59:	e8 f8 f7 ff ff       	call   801356 <seek>
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	0f 88 d8 01 00 00    	js     801d3e <spawn+0x57a>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b66:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b6c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b73:	76 05                	jbe    801b7a <spawn+0x3b6>
  801b75:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b85:	00 
  801b86:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b8c:	89 04 24             	mov    %eax,(%esp)
  801b8f:	e8 ea f6 ff ff       	call   80127e <readn>
  801b94:	85 c0                	test   %eax,%eax
  801b96:	0f 88 a6 01 00 00    	js     801d42 <spawn+0x57e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b9c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801ba2:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ba6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801baa:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801bb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bbb:	00 
  801bbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc3:	e8 f1 f0 ff ff       	call   800cb9 <sys_page_map>
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	79 20                	jns    801bec <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801bcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bd0:	c7 44 24 08 f1 2b 80 	movl   $0x802bf1,0x8(%esp)
  801bd7:	00 
  801bd8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801bdf:	00 
  801be0:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  801be7:	e8 e4 e5 ff ff       	call   8001d0 <_panic>
			sys_page_unmap(0, UTEMP);
  801bec:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bf3:	00 
  801bf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfb:	e8 0c f1 ff ff       	call   800d0c <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c00:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c06:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801c0c:	89 de                	mov    %ebx,%esi
  801c0e:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801c14:	0f 82 d3 fe ff ff    	jb     801aed <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c1a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801c20:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801c27:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c2e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801c34:	0f 8c 32 fe ff ff    	jl     801a6c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c3a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c40:	89 04 24             	mov    %eax,(%esp)
  801c43:	e8 40 f4 ff ff       	call   801088 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  801c48:	be 00 00 00 00       	mov    $0x0,%esi
  801c4d:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(va)] & PTE_P)&&(uvpt[PGNUM(va)] & PTE_P)&&(uvpt[PGNUM(va)]&PTE_U)&&(uvpt[PGNUM(va)]&PTE_SHARE)){
  801c53:	89 f0                	mov    %esi,%eax
  801c55:	c1 e8 16             	shr    $0x16,%eax
  801c58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c5f:	a8 01                	test   $0x1,%al
  801c61:	74 49                	je     801cac <spawn+0x4e8>
  801c63:	89 f0                	mov    %esi,%eax
  801c65:	c1 e8 0c             	shr    $0xc,%eax
  801c68:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c6f:	f6 c2 01             	test   $0x1,%dl
  801c72:	74 38                	je     801cac <spawn+0x4e8>
  801c74:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c7b:	f6 c2 04             	test   $0x4,%dl
  801c7e:	74 2c                	je     801cac <spawn+0x4e8>
  801c80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c87:	f6 c4 04             	test   $0x4,%ah
  801c8a:	74 20                	je     801cac <spawn+0x4e8>
			if ((r = sys_page_map(0,(void*)va,child,(void*)va,PTE_SYSCALL))<0);
  801c8c:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  801c93:	00 
  801c94:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca7:	e8 0d f0 ff ff       	call   800cb9 <sys_page_map>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  801cac:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cb2:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  801cb8:	75 99                	jne    801c53 <spawn+0x48f>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801cba:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801cc1:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801cc4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801cca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cce:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cd4:	89 04 24             	mov    %eax,(%esp)
  801cd7:	e8 d6 f0 ff ff       	call   800db2 <sys_env_set_trapframe>
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	79 20                	jns    801d00 <spawn+0x53c>
		panic("sys_env_set_trapframe: %e", r);
  801ce0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ce4:	c7 44 24 08 0e 2c 80 	movl   $0x802c0e,0x8(%esp)
  801ceb:	00 
  801cec:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801cf3:	00 
  801cf4:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  801cfb:	e8 d0 e4 ff ff       	call   8001d0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d00:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801d07:	00 
  801d08:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d0e:	89 04 24             	mov    %eax,(%esp)
  801d11:	e8 49 f0 ff ff       	call   800d5f <sys_env_set_status>
  801d16:	85 c0                	test   %eax,%eax
  801d18:	79 5a                	jns    801d74 <spawn+0x5b0>
		panic("sys_env_set_status: %e", r);
  801d1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1e:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  801d25:	00 
  801d26:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801d2d:	00 
  801d2e:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  801d35:	e8 96 e4 ff ff       	call   8001d0 <_panic>
  801d3a:	89 c6                	mov    %eax,%esi
  801d3c:	eb 06                	jmp    801d44 <spawn+0x580>
  801d3e:	89 c6                	mov    %eax,%esi
  801d40:	eb 02                	jmp    801d44 <spawn+0x580>
  801d42:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801d44:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d4a:	89 04 24             	mov    %eax,(%esp)
  801d4d:	e8 83 ee ff ff       	call   800bd5 <sys_env_destroy>
	close(fd);
  801d52:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d58:	89 04 24             	mov    %eax,(%esp)
  801d5b:	e8 28 f3 ff ff       	call   801088 <close>
	return r;
  801d60:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801d66:	eb 0c                	jmp    801d74 <spawn+0x5b0>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d68:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d6e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d74:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d7a:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d85:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801d8a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801d90:	eb e2                	jmp    801d74 <spawn+0x5b0>

00801d92 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801d9b:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801da3:	eb 03                	jmp    801da8 <spawnl+0x16>
		argc++;
  801da5:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801da6:	89 d0                	mov    %edx,%eax
  801da8:	8d 50 04             	lea    0x4(%eax),%edx
  801dab:	83 38 00             	cmpl   $0x0,(%eax)
  801dae:	75 f5                	jne    801da5 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801db0:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801db7:	83 e0 f0             	and    $0xfffffff0,%eax
  801dba:	29 c4                	sub    %eax,%esp
  801dbc:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801dc0:	83 e7 f0             	and    $0xfffffff0,%edi
  801dc3:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc8:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801dca:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801dd1:	00 

	va_start(vl, arg0);
  801dd2:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dda:	eb 09                	jmp    801de5 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801ddc:	40                   	inc    %eax
  801ddd:	8b 1a                	mov    (%edx),%ebx
  801ddf:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801de2:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801de5:	39 c8                	cmp    %ecx,%eax
  801de7:	75 f3                	jne    801ddc <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801de9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	89 04 24             	mov    %eax,(%esp)
  801df3:	e8 cc f9 ff ff       	call   8017c4 <spawn>
}
  801df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5e                   	pop    %esi
  801dfd:	5f                   	pop    %edi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	56                   	push   %esi
  801e04:	53                   	push   %ebx
  801e05:	83 ec 10             	sub    $0x10,%esp
  801e08:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	89 04 24             	mov    %eax,(%esp)
  801e11:	e8 ca f0 ff ff       	call   800ee0 <fd2data>
  801e16:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e18:	c7 44 24 04 68 2c 80 	movl   $0x802c68,0x4(%esp)
  801e1f:	00 
  801e20:	89 34 24             	mov    %esi,(%esp)
  801e23:	e8 4b ea ff ff       	call   800873 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e28:	8b 43 04             	mov    0x4(%ebx),%eax
  801e2b:	2b 03                	sub    (%ebx),%eax
  801e2d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e33:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e3a:	00 00 00 
	stat->st_dev = &devpipe;
  801e3d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801e44:	30 80 00 
	return 0;
}
  801e47:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	53                   	push   %ebx
  801e57:	83 ec 14             	sub    $0x14,%esp
  801e5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e68:	e8 9f ee ff ff       	call   800d0c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e6d:	89 1c 24             	mov    %ebx,(%esp)
  801e70:	e8 6b f0 ff ff       	call   800ee0 <fd2data>
  801e75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e80:	e8 87 ee ff ff       	call   800d0c <sys_page_unmap>
}
  801e85:	83 c4 14             	add    $0x14,%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    

00801e8b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	57                   	push   %edi
  801e8f:	56                   	push   %esi
  801e90:	53                   	push   %ebx
  801e91:	83 ec 2c             	sub    $0x2c,%esp
  801e94:	89 c7                	mov    %eax,%edi
  801e96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e99:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9e:	8b 00                	mov    (%eax),%eax
  801ea0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ea3:	89 3c 24             	mov    %edi,(%esp)
  801ea6:	e8 89 05 00 00       	call   802434 <pageref>
  801eab:	89 c6                	mov    %eax,%esi
  801ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb0:	89 04 24             	mov    %eax,(%esp)
  801eb3:	e8 7c 05 00 00       	call   802434 <pageref>
  801eb8:	39 c6                	cmp    %eax,%esi
  801eba:	0f 94 c0             	sete   %al
  801ebd:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ec0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ec6:	8b 12                	mov    (%edx),%edx
  801ec8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ecb:	39 cb                	cmp    %ecx,%ebx
  801ecd:	75 08                	jne    801ed7 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ecf:	83 c4 2c             	add    $0x2c,%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5e                   	pop    %esi
  801ed4:	5f                   	pop    %edi
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ed7:	83 f8 01             	cmp    $0x1,%eax
  801eda:	75 bd                	jne    801e99 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801edc:	8b 42 58             	mov    0x58(%edx),%eax
  801edf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801ee6:	00 
  801ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eef:	c7 04 24 6f 2c 80 00 	movl   $0x802c6f,(%esp)
  801ef6:	e8 cd e3 ff ff       	call   8002c8 <cprintf>
  801efb:	eb 9c                	jmp    801e99 <_pipeisclosed+0xe>

00801efd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	57                   	push   %edi
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
  801f03:	83 ec 1c             	sub    $0x1c,%esp
  801f06:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f09:	89 34 24             	mov    %esi,(%esp)
  801f0c:	e8 cf ef ff ff       	call   800ee0 <fd2data>
  801f11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f13:	bf 00 00 00 00       	mov    $0x0,%edi
  801f18:	eb 3c                	jmp    801f56 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f1a:	89 da                	mov    %ebx,%edx
  801f1c:	89 f0                	mov    %esi,%eax
  801f1e:	e8 68 ff ff ff       	call   801e8b <_pipeisclosed>
  801f23:	85 c0                	test   %eax,%eax
  801f25:	75 38                	jne    801f5f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f27:	e8 1a ed ff ff       	call   800c46 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f2f:	8b 13                	mov    (%ebx),%edx
  801f31:	83 c2 20             	add    $0x20,%edx
  801f34:	39 d0                	cmp    %edx,%eax
  801f36:	73 e2                	jae    801f1a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f46:	79 05                	jns    801f4d <devpipe_write+0x50>
  801f48:	4a                   	dec    %edx
  801f49:	83 ca e0             	or     $0xffffffe0,%edx
  801f4c:	42                   	inc    %edx
  801f4d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f51:	40                   	inc    %eax
  801f52:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f55:	47                   	inc    %edi
  801f56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f59:	75 d1                	jne    801f2c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f5b:	89 f8                	mov    %edi,%eax
  801f5d:	eb 05                	jmp    801f64 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f64:	83 c4 1c             	add    $0x1c,%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	57                   	push   %edi
  801f70:	56                   	push   %esi
  801f71:	53                   	push   %ebx
  801f72:	83 ec 1c             	sub    $0x1c,%esp
  801f75:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f78:	89 3c 24             	mov    %edi,(%esp)
  801f7b:	e8 60 ef ff ff       	call   800ee0 <fd2data>
  801f80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f82:	be 00 00 00 00       	mov    $0x0,%esi
  801f87:	eb 3a                	jmp    801fc3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f89:	85 f6                	test   %esi,%esi
  801f8b:	74 04                	je     801f91 <devpipe_read+0x25>
				return i;
  801f8d:	89 f0                	mov    %esi,%eax
  801f8f:	eb 40                	jmp    801fd1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f91:	89 da                	mov    %ebx,%edx
  801f93:	89 f8                	mov    %edi,%eax
  801f95:	e8 f1 fe ff ff       	call   801e8b <_pipeisclosed>
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	75 2e                	jne    801fcc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f9e:	e8 a3 ec ff ff       	call   800c46 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fa3:	8b 03                	mov    (%ebx),%eax
  801fa5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fa8:	74 df                	je     801f89 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801faa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801faf:	79 05                	jns    801fb6 <devpipe_read+0x4a>
  801fb1:	48                   	dec    %eax
  801fb2:	83 c8 e0             	or     $0xffffffe0,%eax
  801fb5:	40                   	inc    %eax
  801fb6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801fba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801fc0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc2:	46                   	inc    %esi
  801fc3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fc6:	75 db                	jne    801fa3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fc8:	89 f0                	mov    %esi,%eax
  801fca:	eb 05                	jmp    801fd1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fd1:	83 c4 1c             	add    $0x1c,%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	57                   	push   %edi
  801fdd:	56                   	push   %esi
  801fde:	53                   	push   %ebx
  801fdf:	83 ec 3c             	sub    $0x3c,%esp
  801fe2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fe5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fe8:	89 04 24             	mov    %eax,(%esp)
  801feb:	e8 0b ef ff ff       	call   800efb <fd_alloc>
  801ff0:	89 c3                	mov    %eax,%ebx
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	0f 88 45 01 00 00    	js     80213f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ffa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802001:	00 
  802002:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802005:	89 44 24 04          	mov    %eax,0x4(%esp)
  802009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802010:	e8 50 ec ff ff       	call   800c65 <sys_page_alloc>
  802015:	89 c3                	mov    %eax,%ebx
  802017:	85 c0                	test   %eax,%eax
  802019:	0f 88 20 01 00 00    	js     80213f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80201f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802022:	89 04 24             	mov    %eax,(%esp)
  802025:	e8 d1 ee ff ff       	call   800efb <fd_alloc>
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	85 c0                	test   %eax,%eax
  80202e:	0f 88 f8 00 00 00    	js     80212c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802034:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80203b:	00 
  80203c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80203f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802043:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204a:	e8 16 ec ff ff       	call   800c65 <sys_page_alloc>
  80204f:	89 c3                	mov    %eax,%ebx
  802051:	85 c0                	test   %eax,%eax
  802053:	0f 88 d3 00 00 00    	js     80212c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80205c:	89 04 24             	mov    %eax,(%esp)
  80205f:	e8 7c ee ff ff       	call   800ee0 <fd2data>
  802064:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802066:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80206d:	00 
  80206e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802079:	e8 e7 eb ff ff       	call   800c65 <sys_page_alloc>
  80207e:	89 c3                	mov    %eax,%ebx
  802080:	85 c0                	test   %eax,%eax
  802082:	0f 88 91 00 00 00    	js     802119 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802088:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 4d ee ff ff       	call   800ee0 <fd2data>
  802093:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80209a:	00 
  80209b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020a6:	00 
  8020a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b2:	e8 02 ec ff ff       	call   800cb9 <sys_page_map>
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	78 4c                	js     802109 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020bd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020c6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020d2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020db:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020e0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ea:	89 04 24             	mov    %eax,(%esp)
  8020ed:	e8 de ed ff ff       	call   800ed0 <fd2num>
  8020f2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020f7:	89 04 24             	mov    %eax,(%esp)
  8020fa:	e8 d1 ed ff ff       	call   800ed0 <fd2num>
  8020ff:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802102:	bb 00 00 00 00       	mov    $0x0,%ebx
  802107:	eb 36                	jmp    80213f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802109:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802114:	e8 f3 eb ff ff       	call   800d0c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802119:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80211c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802120:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802127:	e8 e0 eb ff ff       	call   800d0c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80212c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213a:	e8 cd eb ff ff       	call   800d0c <sys_page_unmap>
    err:
	return r;
}
  80213f:	89 d8                	mov    %ebx,%eax
  802141:	83 c4 3c             	add    $0x3c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802152:	89 44 24 04          	mov    %eax,0x4(%esp)
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 ed ed ff ff       	call   800f4e <fd_lookup>
  802161:	85 c0                	test   %eax,%eax
  802163:	78 15                	js     80217a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802168:	89 04 24             	mov    %eax,(%esp)
  80216b:	e8 70 ed ff ff       	call   800ee0 <fd2data>
	return _pipeisclosed(fd, p);
  802170:	89 c2                	mov    %eax,%edx
  802172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802175:	e8 11 fd ff ff       	call   801e8b <_pipeisclosed>
}
  80217a:	c9                   	leave  
  80217b:	c3                   	ret    

0080217c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    

00802186 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80218c:	c7 44 24 04 87 2c 80 	movl   $0x802c87,0x4(%esp)
  802193:	00 
  802194:	8b 45 0c             	mov    0xc(%ebp),%eax
  802197:	89 04 24             	mov    %eax,(%esp)
  80219a:	e8 d4 e6 ff ff       	call   800873 <strcpy>
	return 0;
}
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	57                   	push   %edi
  8021aa:	56                   	push   %esi
  8021ab:	53                   	push   %ebx
  8021ac:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021bd:	eb 30                	jmp    8021ef <devcons_write+0x49>
		m = n - tot;
  8021bf:	8b 75 10             	mov    0x10(%ebp),%esi
  8021c2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8021c4:	83 fe 7f             	cmp    $0x7f,%esi
  8021c7:	76 05                	jbe    8021ce <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8021c9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021d2:	03 45 0c             	add    0xc(%ebp),%eax
  8021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d9:	89 3c 24             	mov    %edi,(%esp)
  8021dc:	e8 0b e8 ff ff       	call   8009ec <memmove>
		sys_cputs(buf, m);
  8021e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e5:	89 3c 24             	mov    %edi,(%esp)
  8021e8:	e8 ab e9 ff ff       	call   800b98 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ed:	01 f3                	add    %esi,%ebx
  8021ef:	89 d8                	mov    %ebx,%eax
  8021f1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021f4:	72 c9                	jb     8021bf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021f6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5f                   	pop    %edi
  8021ff:	5d                   	pop    %ebp
  802200:	c3                   	ret    

00802201 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802207:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80220b:	75 07                	jne    802214 <devcons_read+0x13>
  80220d:	eb 25                	jmp    802234 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80220f:	e8 32 ea ff ff       	call   800c46 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802214:	e8 9d e9 ff ff       	call   800bb6 <sys_cgetc>
  802219:	85 c0                	test   %eax,%eax
  80221b:	74 f2                	je     80220f <devcons_read+0xe>
  80221d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80221f:	85 c0                	test   %eax,%eax
  802221:	78 1d                	js     802240 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802223:	83 f8 04             	cmp    $0x4,%eax
  802226:	74 13                	je     80223b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222b:	88 10                	mov    %dl,(%eax)
	return 1;
  80222d:	b8 01 00 00 00       	mov    $0x1,%eax
  802232:	eb 0c                	jmp    802240 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802234:	b8 00 00 00 00       	mov    $0x0,%eax
  802239:	eb 05                	jmp    802240 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80223b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802240:	c9                   	leave  
  802241:	c3                   	ret    

00802242 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802248:	8b 45 08             	mov    0x8(%ebp),%eax
  80224b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80224e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802255:	00 
  802256:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802259:	89 04 24             	mov    %eax,(%esp)
  80225c:	e8 37 e9 ff ff       	call   800b98 <sys_cputs>
}
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <getchar>:

int
getchar(void)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802269:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802270:	00 
  802271:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802274:	89 44 24 04          	mov    %eax,0x4(%esp)
  802278:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227f:	e8 68 ef ff ff       	call   8011ec <read>
	if (r < 0)
  802284:	85 c0                	test   %eax,%eax
  802286:	78 0f                	js     802297 <getchar+0x34>
		return r;
	if (r < 1)
  802288:	85 c0                	test   %eax,%eax
  80228a:	7e 06                	jle    802292 <getchar+0x2f>
		return -E_EOF;
	return c;
  80228c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802290:	eb 05                	jmp    802297 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802292:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802297:	c9                   	leave  
  802298:	c3                   	ret    

00802299 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802299:	55                   	push   %ebp
  80229a:	89 e5                	mov    %esp,%ebp
  80229c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80229f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a9:	89 04 24             	mov    %eax,(%esp)
  8022ac:	e8 9d ec ff ff       	call   800f4e <fd_lookup>
  8022b1:	85 c0                	test   %eax,%eax
  8022b3:	78 11                	js     8022c6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022be:	39 10                	cmp    %edx,(%eax)
  8022c0:	0f 94 c0             	sete   %al
  8022c3:	0f b6 c0             	movzbl %al,%eax
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <opencons>:

int
opencons(void)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d1:	89 04 24             	mov    %eax,(%esp)
  8022d4:	e8 22 ec ff ff       	call   800efb <fd_alloc>
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 3c                	js     802319 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022e4:	00 
  8022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f3:	e8 6d e9 ff ff       	call   800c65 <sys_page_alloc>
  8022f8:	85 c0                	test   %eax,%eax
  8022fa:	78 1d                	js     802319 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022fc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802302:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802305:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802307:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802311:	89 04 24             	mov    %eax,(%esp)
  802314:	e8 b7 eb ff ff       	call   800ed0 <fd2num>
}
  802319:	c9                   	leave  
  80231a:	c3                   	ret    
	...

0080231c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	56                   	push   %esi
  802320:	53                   	push   %ebx
  802321:	83 ec 10             	sub    $0x10,%esp
  802324:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80232d:	85 c0                	test   %eax,%eax
  80232f:	75 05                	jne    802336 <ipc_recv+0x1a>
  802331:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802336:	89 04 24             	mov    %eax,(%esp)
  802339:	e8 3d eb ff ff       	call   800e7b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80233e:	85 c0                	test   %eax,%eax
  802340:	79 16                	jns    802358 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802342:	85 db                	test   %ebx,%ebx
  802344:	74 06                	je     80234c <ipc_recv+0x30>
  802346:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  80234c:	85 f6                	test   %esi,%esi
  80234e:	74 32                	je     802382 <ipc_recv+0x66>
  802350:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802356:	eb 2a                	jmp    802382 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802358:	85 db                	test   %ebx,%ebx
  80235a:	74 0c                	je     802368 <ipc_recv+0x4c>
  80235c:	a1 04 40 80 00       	mov    0x804004,%eax
  802361:	8b 00                	mov    (%eax),%eax
  802363:	8b 40 74             	mov    0x74(%eax),%eax
  802366:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802368:	85 f6                	test   %esi,%esi
  80236a:	74 0c                	je     802378 <ipc_recv+0x5c>
  80236c:	a1 04 40 80 00       	mov    0x804004,%eax
  802371:	8b 00                	mov    (%eax),%eax
  802373:	8b 40 78             	mov    0x78(%eax),%eax
  802376:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  802378:	a1 04 40 80 00       	mov    0x804004,%eax
  80237d:	8b 00                	mov    (%eax),%eax
  80237f:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	5b                   	pop    %ebx
  802386:	5e                   	pop    %esi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    

00802389 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802389:	55                   	push   %ebp
  80238a:	89 e5                	mov    %esp,%ebp
  80238c:	57                   	push   %edi
  80238d:	56                   	push   %esi
  80238e:	53                   	push   %ebx
  80238f:	83 ec 1c             	sub    $0x1c,%esp
  802392:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802395:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802398:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80239b:	85 db                	test   %ebx,%ebx
  80239d:	75 05                	jne    8023a4 <ipc_send+0x1b>
  80239f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8023a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8023a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b3:	89 04 24             	mov    %eax,(%esp)
  8023b6:	e8 9d ea ff ff       	call   800e58 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8023bb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023be:	75 07                	jne    8023c7 <ipc_send+0x3e>
  8023c0:	e8 81 e8 ff ff       	call   800c46 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8023c5:	eb dd                	jmp    8023a4 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8023c7:	85 c0                	test   %eax,%eax
  8023c9:	79 1c                	jns    8023e7 <ipc_send+0x5e>
  8023cb:	c7 44 24 08 93 2c 80 	movl   $0x802c93,0x8(%esp)
  8023d2:	00 
  8023d3:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8023da:	00 
  8023db:	c7 04 24 a5 2c 80 00 	movl   $0x802ca5,(%esp)
  8023e2:	e8 e9 dd ff ff       	call   8001d0 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8023e7:	83 c4 1c             	add    $0x1c,%esp
  8023ea:	5b                   	pop    %ebx
  8023eb:	5e                   	pop    %esi
  8023ec:	5f                   	pop    %edi
  8023ed:	5d                   	pop    %ebp
  8023ee:	c3                   	ret    

008023ef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	53                   	push   %ebx
  8023f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8023f6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023fb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802402:	89 c2                	mov    %eax,%edx
  802404:	c1 e2 07             	shl    $0x7,%edx
  802407:	29 ca                	sub    %ecx,%edx
  802409:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80240f:	8b 52 50             	mov    0x50(%edx),%edx
  802412:	39 da                	cmp    %ebx,%edx
  802414:	75 0f                	jne    802425 <ipc_find_env+0x36>
			return envs[i].env_id;
  802416:	c1 e0 07             	shl    $0x7,%eax
  802419:	29 c8                	sub    %ecx,%eax
  80241b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802420:	8b 40 40             	mov    0x40(%eax),%eax
  802423:	eb 0c                	jmp    802431 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802425:	40                   	inc    %eax
  802426:	3d 00 04 00 00       	cmp    $0x400,%eax
  80242b:	75 ce                	jne    8023fb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80242d:	66 b8 00 00          	mov    $0x0,%ax
}
  802431:	5b                   	pop    %ebx
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    

00802434 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802434:	55                   	push   %ebp
  802435:	89 e5                	mov    %esp,%ebp
  802437:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80243a:	89 c2                	mov    %eax,%edx
  80243c:	c1 ea 16             	shr    $0x16,%edx
  80243f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802446:	f6 c2 01             	test   $0x1,%dl
  802449:	74 1e                	je     802469 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80244b:	c1 e8 0c             	shr    $0xc,%eax
  80244e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802455:	a8 01                	test   $0x1,%al
  802457:	74 17                	je     802470 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802459:	c1 e8 0c             	shr    $0xc,%eax
  80245c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802463:	ef 
  802464:	0f b7 c0             	movzwl %ax,%eax
  802467:	eb 0c                	jmp    802475 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802469:	b8 00 00 00 00       	mov    $0x0,%eax
  80246e:	eb 05                	jmp    802475 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802470:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802475:	5d                   	pop    %ebp
  802476:	c3                   	ret    
	...

00802478 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802478:	55                   	push   %ebp
  802479:	57                   	push   %edi
  80247a:	56                   	push   %esi
  80247b:	83 ec 10             	sub    $0x10,%esp
  80247e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802482:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80248e:	89 cd                	mov    %ecx,%ebp
  802490:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802494:	85 c0                	test   %eax,%eax
  802496:	75 2c                	jne    8024c4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802498:	39 f9                	cmp    %edi,%ecx
  80249a:	77 68                	ja     802504 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80249c:	85 c9                	test   %ecx,%ecx
  80249e:	75 0b                	jne    8024ab <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a5:	31 d2                	xor    %edx,%edx
  8024a7:	f7 f1                	div    %ecx
  8024a9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024ab:	31 d2                	xor    %edx,%edx
  8024ad:	89 f8                	mov    %edi,%eax
  8024af:	f7 f1                	div    %ecx
  8024b1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024b3:	89 f0                	mov    %esi,%eax
  8024b5:	f7 f1                	div    %ecx
  8024b7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024b9:	89 f0                	mov    %esi,%eax
  8024bb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024bd:	83 c4 10             	add    $0x10,%esp
  8024c0:	5e                   	pop    %esi
  8024c1:	5f                   	pop    %edi
  8024c2:	5d                   	pop    %ebp
  8024c3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024c4:	39 f8                	cmp    %edi,%eax
  8024c6:	77 2c                	ja     8024f4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024c8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8024cb:	83 f6 1f             	xor    $0x1f,%esi
  8024ce:	75 4c                	jne    80251c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024d0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024d2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024d7:	72 0a                	jb     8024e3 <__udivdi3+0x6b>
  8024d9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8024dd:	0f 87 ad 00 00 00    	ja     802590 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024e3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024e8:	89 f0                	mov    %esi,%eax
  8024ea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024ec:	83 c4 10             	add    $0x10,%esp
  8024ef:	5e                   	pop    %esi
  8024f0:	5f                   	pop    %edi
  8024f1:	5d                   	pop    %ebp
  8024f2:	c3                   	ret    
  8024f3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024f8:	89 f0                	mov    %esi,%eax
  8024fa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024fc:	83 c4 10             	add    $0x10,%esp
  8024ff:	5e                   	pop    %esi
  802500:	5f                   	pop    %edi
  802501:	5d                   	pop    %ebp
  802502:	c3                   	ret    
  802503:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802504:	89 fa                	mov    %edi,%edx
  802506:	89 f0                	mov    %esi,%eax
  802508:	f7 f1                	div    %ecx
  80250a:	89 c6                	mov    %eax,%esi
  80250c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80250e:	89 f0                	mov    %esi,%eax
  802510:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802512:	83 c4 10             	add    $0x10,%esp
  802515:	5e                   	pop    %esi
  802516:	5f                   	pop    %edi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    
  802519:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80251c:	89 f1                	mov    %esi,%ecx
  80251e:	d3 e0                	shl    %cl,%eax
  802520:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802524:	b8 20 00 00 00       	mov    $0x20,%eax
  802529:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80252b:	89 ea                	mov    %ebp,%edx
  80252d:	88 c1                	mov    %al,%cl
  80252f:	d3 ea                	shr    %cl,%edx
  802531:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802535:	09 ca                	or     %ecx,%edx
  802537:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80253b:	89 f1                	mov    %esi,%ecx
  80253d:	d3 e5                	shl    %cl,%ebp
  80253f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802543:	89 fd                	mov    %edi,%ebp
  802545:	88 c1                	mov    %al,%cl
  802547:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802549:	89 fa                	mov    %edi,%edx
  80254b:	89 f1                	mov    %esi,%ecx
  80254d:	d3 e2                	shl    %cl,%edx
  80254f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802553:	88 c1                	mov    %al,%cl
  802555:	d3 ef                	shr    %cl,%edi
  802557:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802559:	89 f8                	mov    %edi,%eax
  80255b:	89 ea                	mov    %ebp,%edx
  80255d:	f7 74 24 08          	divl   0x8(%esp)
  802561:	89 d1                	mov    %edx,%ecx
  802563:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802565:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802569:	39 d1                	cmp    %edx,%ecx
  80256b:	72 17                	jb     802584 <__udivdi3+0x10c>
  80256d:	74 09                	je     802578 <__udivdi3+0x100>
  80256f:	89 fe                	mov    %edi,%esi
  802571:	31 ff                	xor    %edi,%edi
  802573:	e9 41 ff ff ff       	jmp    8024b9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802578:	8b 54 24 04          	mov    0x4(%esp),%edx
  80257c:	89 f1                	mov    %esi,%ecx
  80257e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802580:	39 c2                	cmp    %eax,%edx
  802582:	73 eb                	jae    80256f <__udivdi3+0xf7>
		{
		  q0--;
  802584:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802587:	31 ff                	xor    %edi,%edi
  802589:	e9 2b ff ff ff       	jmp    8024b9 <__udivdi3+0x41>
  80258e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802590:	31 f6                	xor    %esi,%esi
  802592:	e9 22 ff ff ff       	jmp    8024b9 <__udivdi3+0x41>
	...

00802598 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802598:	55                   	push   %ebp
  802599:	57                   	push   %edi
  80259a:	56                   	push   %esi
  80259b:	83 ec 20             	sub    $0x20,%esp
  80259e:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025a2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025a6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025aa:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8025ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025b2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8025b6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8025b8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025ba:	85 ed                	test   %ebp,%ebp
  8025bc:	75 16                	jne    8025d4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8025be:	39 f1                	cmp    %esi,%ecx
  8025c0:	0f 86 a6 00 00 00    	jbe    80266c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025c6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8025c8:	89 d0                	mov    %edx,%eax
  8025ca:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025cc:	83 c4 20             	add    $0x20,%esp
  8025cf:	5e                   	pop    %esi
  8025d0:	5f                   	pop    %edi
  8025d1:	5d                   	pop    %ebp
  8025d2:	c3                   	ret    
  8025d3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025d4:	39 f5                	cmp    %esi,%ebp
  8025d6:	0f 87 ac 00 00 00    	ja     802688 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025dc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8025df:	83 f0 1f             	xor    $0x1f,%eax
  8025e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025e6:	0f 84 a8 00 00 00    	je     802694 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025ec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025f0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025f2:	bf 20 00 00 00       	mov    $0x20,%edi
  8025f7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8025fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025ff:	89 f9                	mov    %edi,%ecx
  802601:	d3 e8                	shr    %cl,%eax
  802603:	09 e8                	or     %ebp,%eax
  802605:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802609:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80260d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802611:	d3 e0                	shl    %cl,%eax
  802613:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802617:	89 f2                	mov    %esi,%edx
  802619:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80261b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80261f:	d3 e0                	shl    %cl,%eax
  802621:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802625:	8b 44 24 14          	mov    0x14(%esp),%eax
  802629:	89 f9                	mov    %edi,%ecx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80262f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802631:	89 f2                	mov    %esi,%edx
  802633:	f7 74 24 18          	divl   0x18(%esp)
  802637:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802639:	f7 64 24 0c          	mull   0xc(%esp)
  80263d:	89 c5                	mov    %eax,%ebp
  80263f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802641:	39 d6                	cmp    %edx,%esi
  802643:	72 67                	jb     8026ac <__umoddi3+0x114>
  802645:	74 75                	je     8026bc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802647:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80264b:	29 e8                	sub    %ebp,%eax
  80264d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80264f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802653:	d3 e8                	shr    %cl,%eax
  802655:	89 f2                	mov    %esi,%edx
  802657:	89 f9                	mov    %edi,%ecx
  802659:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80265b:	09 d0                	or     %edx,%eax
  80265d:	89 f2                	mov    %esi,%edx
  80265f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802663:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802665:	83 c4 20             	add    $0x20,%esp
  802668:	5e                   	pop    %esi
  802669:	5f                   	pop    %edi
  80266a:	5d                   	pop    %ebp
  80266b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80266c:	85 c9                	test   %ecx,%ecx
  80266e:	75 0b                	jne    80267b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802670:	b8 01 00 00 00       	mov    $0x1,%eax
  802675:	31 d2                	xor    %edx,%edx
  802677:	f7 f1                	div    %ecx
  802679:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80267b:	89 f0                	mov    %esi,%eax
  80267d:	31 d2                	xor    %edx,%edx
  80267f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802681:	89 f8                	mov    %edi,%eax
  802683:	e9 3e ff ff ff       	jmp    8025c6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802688:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80268a:	83 c4 20             	add    $0x20,%esp
  80268d:	5e                   	pop    %esi
  80268e:	5f                   	pop    %edi
  80268f:	5d                   	pop    %ebp
  802690:	c3                   	ret    
  802691:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802694:	39 f5                	cmp    %esi,%ebp
  802696:	72 04                	jb     80269c <__umoddi3+0x104>
  802698:	39 f9                	cmp    %edi,%ecx
  80269a:	77 06                	ja     8026a2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80269c:	89 f2                	mov    %esi,%edx
  80269e:	29 cf                	sub    %ecx,%edi
  8026a0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026a2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026a4:	83 c4 20             	add    $0x20,%esp
  8026a7:	5e                   	pop    %esi
  8026a8:	5f                   	pop    %edi
  8026a9:	5d                   	pop    %ebp
  8026aa:	c3                   	ret    
  8026ab:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026ac:	89 d1                	mov    %edx,%ecx
  8026ae:	89 c5                	mov    %eax,%ebp
  8026b0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026b4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8026b8:	eb 8d                	jmp    802647 <__umoddi3+0xaf>
  8026ba:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026bc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8026c0:	72 ea                	jb     8026ac <__umoddi3+0x114>
  8026c2:	89 f1                	mov    %esi,%ecx
  8026c4:	eb 81                	jmp    802647 <__umoddi3+0xaf>
