
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 e0 20 80 00 	movl   $0x8020e0,(%esp)
  80004b:	e8 00 02 00 00       	call   800250 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 7e 0b 00 00       	call   800bed <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 00 21 80 	movl   $0x802100,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ea 20 80 00 	movl   $0x8020ea,(%esp)
  800092:	e8 c1 00 00 00       	call   800158 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 2c 21 80 	movl   $0x80212c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 ea 06 00 00       	call   80079d <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 8d 0d 00 00       	call   800e58 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 41 0a 00 00       	call   800b20 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 20             	sub    $0x20,%esp
  8000ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8000f2:	e8 b8 0a 00 00       	call   800baf <sys_getenvid>
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800103:	c1 e0 07             	shl    $0x7,%eax
  800106:	29 d0                	sub    %edx,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800110:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800113:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 f6                	test   %esi,%esi
  80011a:	7e 07                	jle    800123 <libmain+0x3f>
		binaryname = argv[0];
  80011c:	8b 03                	mov    (%ebx),%eax
  80011e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800123:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800127:	89 34 24             	mov    %esi,(%esp)
  80012a:	e8 8a ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80012f:	e8 08 00 00 00       	call   80013c <exit>
}
  800134:	83 c4 20             	add    $0x20,%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    
	...

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800142:	e8 b2 0f 00 00       	call   8010f9 <close_all>
	sys_env_destroy(0);
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 0a 0a 00 00       	call   800b5d <sys_env_destroy>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    
  800155:	00 00                	add    %al,(%eax)
	...

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800160:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800163:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800169:	e8 41 0a 00 00       	call   800baf <sys_getenvid>
  80016e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800171:	89 54 24 10          	mov    %edx,0x10(%esp)
  800175:	8b 55 08             	mov    0x8(%ebp),%edx
  800178:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80017c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	c7 04 24 58 21 80 00 	movl   $0x802158,(%esp)
  80018b:	e8 c0 00 00 00       	call   800250 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800190:	89 74 24 04          	mov    %esi,0x4(%esp)
  800194:	8b 45 10             	mov    0x10(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 50 00 00 00       	call   8001ef <vcprintf>
	cprintf("\n");
  80019f:	c7 04 24 12 26 80 00 	movl   $0x802612,(%esp)
  8001a6:	e8 a5 00 00 00       	call   800250 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ab:	cc                   	int3   
  8001ac:	eb fd                	jmp    8001ab <_panic+0x53>
	...

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	40                   	inc    %eax
  8001c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cb:	75 19                	jne    8001e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d4:	00 
  8001d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 40 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  8001e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e6:	ff 43 04             	incl   0x4(%ebx)
}
  8001e9:	83 c4 14             	add    $0x14,%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ff:	00 00 00 
	b.cnt = 0;
  800202:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800209:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800213:	8b 45 08             	mov    0x8(%ebp),%eax
  800216:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022b:	e8 82 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800230:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 d8 08 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  800248:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800256:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 87 ff ff ff       	call   8001ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    
	...

0080026c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800278:	89 d7                	mov    %edx,%edi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800286:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800289:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	85 c0                	test   %eax,%eax
  80028e:	75 08                	jne    800298 <printnum+0x2c>
  800290:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800293:	39 45 10             	cmp    %eax,0x10(%ebp)
  800296:	77 57                	ja     8002ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800298:	89 74 24 10          	mov    %esi,0x10(%esp)
  80029c:	4b                   	dec    %ebx
  80029d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b7:	00 
  8002b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bb:	89 04 24             	mov    %eax,(%esp)
  8002be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	e8 b2 1b 00 00       	call   801e7c <__udivdi3>
  8002ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d9:	89 fa                	mov    %edi,%edx
  8002db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002de:	e8 89 ff ff ff       	call   80026c <printnum>
  8002e3:	eb 0f                	jmp    8002f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ef:	4b                   	dec    %ebx
  8002f0:	85 db                	test   %ebx,%ebx
  8002f2:	7f f1                	jg     8002e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030a:	00 
  80030b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	e8 7f 1c 00 00       	call   801f9c <__umoddi3>
  80031d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800321:	0f be 80 7b 21 80 00 	movsbl 0x80217b(%eax),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032e:	83 c4 3c             	add    $0x3c,%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800339:	83 fa 01             	cmp    $0x1,%edx
  80033c:	7e 0e                	jle    80034c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 08             	lea    0x8(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	8b 52 04             	mov    0x4(%edx),%edx
  80034a:	eb 22                	jmp    80036e <getuint+0x38>
	else if (lflag)
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 10                	je     800360 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 0e                	jmp    80036e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800376:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 08                	jae    800388 <sprintputch+0x18>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	42                   	inc    %edx
  800386:	89 10                	mov    %edx,(%eax)
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800393:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800397:	8b 45 10             	mov    0x10(%ebp),%eax
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 02 00 00 00       	call   8003b2 <vprintfmt>
	va_end(ap);
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 4c             	sub    $0x4c,%esp
  8003bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003be:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c1:	eb 12                	jmp    8003d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	0f 84 6b 03 00 00    	je     800736 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d5:	0f b6 06             	movzbl (%esi),%eax
  8003d8:	46                   	inc    %esi
  8003d9:	83 f8 25             	cmp    $0x25,%eax
  8003dc:	75 e5                	jne    8003c3 <vprintfmt+0x11>
  8003de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	eb 26                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800403:	eb 1d                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800408:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80040c:	eb 14                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800411:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800418:	eb 08                	jmp    800422 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80041d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	0f b6 06             	movzbl (%esi),%eax
  800425:	8d 56 01             	lea    0x1(%esi),%edx
  800428:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042b:	8a 16                	mov    (%esi),%dl
  80042d:	83 ea 23             	sub    $0x23,%edx
  800430:	80 fa 55             	cmp    $0x55,%dl
  800433:	0f 87 e1 02 00 00    	ja     80071a <vprintfmt+0x368>
  800439:	0f b6 d2             	movzbl %dl,%edx
  80043c:	ff 24 95 c0 22 80 00 	jmp    *0x8022c0(,%edx,4)
  800443:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800446:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800452:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800455:	8d 50 d0             	lea    -0x30(%eax),%edx
  800458:	83 fa 09             	cmp    $0x9,%edx
  80045b:	77 2a                	ja     800487 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb eb                	jmp    80044b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046e:	eb 17                	jmp    800487 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	78 98                	js     80040e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800479:	eb a7                	jmp    800422 <vprintfmt+0x70>
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800485:	eb 9b                	jmp    800422 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800487:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048b:	79 95                	jns    800422 <vprintfmt+0x70>
  80048d:	eb 8b                	jmp    80041a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800493:	eb 8d                	jmp    800422 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ad:	e9 23 ff ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	79 02                	jns    8004c3 <vprintfmt+0x111>
  8004c1:	f7 d8                	neg    %eax
  8004c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c5:	83 f8 0f             	cmp    $0xf,%eax
  8004c8:	7f 0b                	jg     8004d5 <vprintfmt+0x123>
  8004ca:	8b 04 85 20 24 80 00 	mov    0x802420(,%eax,4),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 23                	jne    8004f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d9:	c7 44 24 08 93 21 80 	movl   $0x802193,0x8(%esp)
  8004e0:	00 
  8004e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 9a fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f3:	e9 dd fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	c7 44 24 08 bd 25 80 	movl   $0x8025bd,0x8(%esp)
  800503:	00 
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 14 24             	mov    %edx,(%esp)
  80050e:	e8 77 fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ba fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
  80051b:	89 f9                	mov    %edi,%ecx
  80051d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800520:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 30                	mov    (%eax),%esi
  80052e:	85 f6                	test   %esi,%esi
  800530:	75 05                	jne    800537 <vprintfmt+0x185>
				p = "(null)";
  800532:	be 8c 21 80 00       	mov    $0x80218c,%esi
			if (width > 0 && padc != '-')
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	0f 8e 84 00 00 00    	jle    8005c5 <vprintfmt+0x213>
  800541:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800545:	74 7e                	je     8005c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054b:	89 34 24             	mov    %esi,(%esp)
  80054e:	e8 8b 02 00 00       	call   8007de <strnlen>
  800553:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800556:	29 c2                	sub    %eax,%edx
  800558:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80055b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800562:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800565:	89 de                	mov    %ebx,%esi
  800567:	89 d3                	mov    %edx,%ebx
  800569:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	eb 0b                	jmp    800578 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80056d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800571:	89 3c 24             	mov    %edi,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	4b                   	dec    %ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f f1                	jg     80056d <vprintfmt+0x1bb>
  80057c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057f:	89 f3                	mov    %esi,%ebx
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	79 05                	jns    800590 <vprintfmt+0x1de>
  80058b:	b8 00 00 00 00       	mov    $0x0,%eax
  800590:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800593:	29 c2                	sub    %eax,%edx
  800595:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800598:	eb 2b                	jmp    8005c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059e:	74 18                	je     8005b8 <vprintfmt+0x206>
  8005a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a3:	83 fa 5e             	cmp    $0x5e,%edx
  8005a6:	76 10                	jbe    8005b8 <vprintfmt+0x206>
					putch('?', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	eb 0a                	jmp    8005c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	46                   	inc    %esi
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	74 21                	je     8005ee <vprintfmt+0x23c>
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	78 c9                	js     80059a <vprintfmt+0x1e8>
  8005d1:	4f                   	dec    %edi
  8005d2:	79 c6                	jns    80059a <vprintfmt+0x1e8>
  8005d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d7:	89 de                	mov    %ebx,%esi
  8005d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005dc:	eb 18                	jmp    8005f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x244>
  8005ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f1:	89 de                	mov    %ebx,%esi
  8005f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f6:	85 db                	test   %ebx,%ebx
  8005f8:	7f e4                	jg     8005de <vprintfmt+0x22c>
  8005fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800602:	e9 ce fd ff ff       	jmp    8003d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800607:	83 f9 01             	cmp    $0x1,%ecx
  80060a:	7e 10                	jle    80061c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 08             	lea    0x8(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 30                	mov    (%eax),%esi
  800617:	8b 78 04             	mov    0x4(%eax),%edi
  80061a:	eb 26                	jmp    800642 <vprintfmt+0x290>
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 12                	je     800632 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	89 f7                	mov    %esi,%edi
  80062d:	c1 ff 1f             	sar    $0x1f,%edi
  800630:	eb 10                	jmp    800642 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 30                	mov    (%eax),%esi
  80063d:	89 f7                	mov    %esi,%edi
  80063f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	85 ff                	test   %edi,%edi
  800644:	78 0a                	js     800650 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 8c 00 00 00       	jmp    8006dc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065e:	f7 de                	neg    %esi
  800660:	83 d7 00             	adc    $0x0,%edi
  800663:	f7 df                	neg    %edi
			}
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	eb 70                	jmp    8006dc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	89 ca                	mov    %ecx,%edx
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 c0 fc ff ff       	call   800336 <getuint>
  800676:	89 c6                	mov    %eax,%esi
  800678:	89 d7                	mov    %edx,%edi
			base = 10;
  80067a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067f:	eb 5b                	jmp    8006dc <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 ab fc ff ff       	call   800336 <getuint>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	89 d7                	mov    %edx,%edi
			base = 8;
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800694:	eb 46                	jmp    8006dc <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bb:	8b 30                	mov    (%eax),%esi
  8006bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c7:	eb 13                	jmp    8006dc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 63 fc ff ff       	call   800336 <getuint>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ef:	89 34 24             	mov    %esi,(%esp)
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	89 da                	mov    %ebx,%edx
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	e8 6c fb ff ff       	call   80026c <printnum>
			break;
  800700:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800703:	e9 cd fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800715:	e9 bb fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800725:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	eb 01                	jmp    80072b <vprintfmt+0x379>
  80072a:	4e                   	dec    %esi
  80072b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072f:	75 f9                	jne    80072a <vprintfmt+0x378>
  800731:	e9 9f fc ff ff       	jmp    8003d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800736:	83 c4 4c             	add    $0x4c,%esp
  800739:	5b                   	pop    %ebx
  80073a:	5e                   	pop    %esi
  80073b:	5f                   	pop    %edi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 28             	sub    $0x28,%esp
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800751:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800754:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075b:	85 c0                	test   %eax,%eax
  80075d:	74 30                	je     80078f <vsnprintf+0x51>
  80075f:	85 d2                	test   %edx,%edx
  800761:	7e 33                	jle    800796 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	c7 04 24 70 03 80 00 	movl   $0x800370,(%esp)
  80077f:	e8 2e fc ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800784:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800787:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078d:	eb 0c                	jmp    80079b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800794:	eb 05                	jmp    80079b <vsnprintf+0x5d>
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 7b ff ff ff       	call   80073e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    
  8007c5:	00 00                	add    %al,(%eax)
	...

008007c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	eb 01                	jmp    8007d6 <strlen+0xe>
		n++;
  8007d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f9                	jne    8007d5 <strlen+0xd>
		n++;
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 01                	jmp    8007ef <strnlen+0x11>
		n++;
  8007ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	39 d0                	cmp    %edx,%eax
  8007f1:	74 06                	je     8007f9 <strnlen+0x1b>
  8007f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f7:	75 f5                	jne    8007ee <strnlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80080d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800810:	42                   	inc    %edx
  800811:	84 c9                	test   %cl,%cl
  800813:	75 f5                	jne    80080a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	89 1c 24             	mov    %ebx,(%esp)
  800825:	e8 9e ff ff ff       	call   8007c8 <strlen>
	strcpy(dst + len, src);
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800831:	01 d8                	add    %ebx,%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 c0 ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	83 c4 08             	add    $0x8,%esp
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	eb 0c                	jmp    800864 <strncpy+0x21>
		*dst++ = *src;
  800858:	8a 1a                	mov    (%edx),%bl
  80085a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085d:	80 3a 01             	cmpb   $0x1,(%edx)
  800860:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	41                   	inc    %ecx
  800864:	39 f1                	cmp    %esi,%ecx
  800866:	75 f0                	jne    800858 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	75 0a                	jne    800888 <strlcpy+0x1c>
  80087e:	89 f0                	mov    %esi,%eax
  800880:	eb 1a                	jmp    80089c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	88 18                	mov    %bl,(%eax)
  800884:	40                   	inc    %eax
  800885:	41                   	inc    %ecx
  800886:	eb 02                	jmp    80088a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800888:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80088a:	4a                   	dec    %edx
  80088b:	74 0a                	je     800897 <strlcpy+0x2b>
  80088d:	8a 19                	mov    (%ecx),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strlcpy+0x16>
  800893:	89 c2                	mov    %eax,%edx
  800895:	eb 02                	jmp    800899 <strlcpy+0x2d>
  800897:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 02                	jmp    8008af <strcmp+0xd>
		p++, q++;
  8008ad:	41                   	inc    %ecx
  8008ae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008af:	8a 01                	mov    (%ecx),%al
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x17>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 f4                	je     8008ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 03                	jmp    8008d5 <strncmp+0x12>
		n--, p++, q++;
  8008d2:	4a                   	dec    %edx
  8008d3:	40                   	inc    %eax
  8008d4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	74 14                	je     8008ed <strncmp+0x2a>
  8008d9:	8a 18                	mov    (%eax),%bl
  8008db:	84 db                	test   %bl,%bl
  8008dd:	74 04                	je     8008e3 <strncmp+0x20>
  8008df:	3a 19                	cmp    (%ecx),%bl
  8008e1:	74 ef                	je     8008d2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	0f b6 11             	movzbl (%ecx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb 05                	jmp    8008f2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	eb 05                	jmp    800905 <strchr+0x10>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 0c                	je     800910 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800904:	40                   	inc    %eax
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f5                	jne    800900 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091b:	eb 05                	jmp    800922 <strfind+0x10>
		if (*s == c)
  80091d:	38 ca                	cmp    %cl,%dl
  80091f:	74 07                	je     800928 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800921:	40                   	inc    %eax
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	75 f5                	jne    80091d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 30                	je     80096d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 25                	jne    80096a <memset+0x40>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 20                	jne    80096a <memset+0x40>
		c &= 0xFF;
  80094a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094d:	89 d3                	mov    %edx,%ebx
  80094f:	c1 e3 08             	shl    $0x8,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	c1 e6 18             	shl    $0x18,%esi
  800957:	89 d0                	mov    %edx,%eax
  800959:	c1 e0 10             	shl    $0x10,%eax
  80095c:	09 f0                	or     %esi,%eax
  80095e:	09 d0                	or     %edx,%eax
  800960:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800962:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 03                	jmp    80096d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800982:	39 c6                	cmp    %eax,%esi
  800984:	73 34                	jae    8009ba <memmove+0x46>
  800986:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 2d                	jae    8009ba <memmove+0x46>
		s += n;
		d += n;
  80098d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	f6 c2 03             	test   $0x3,%dl
  800993:	75 1b                	jne    8009b0 <memmove+0x3c>
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 13                	jne    8009b0 <memmove+0x3c>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 0e                	jne    8009b0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a2:	83 ef 04             	sub    $0x4,%edi
  8009a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 07                	jmp    8009b7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b0:	4f                   	dec    %edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 20                	jmp    8009da <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c0:	75 13                	jne    8009d5 <memmove+0x61>
  8009c2:	a8 03                	test   $0x3,%al
  8009c4:	75 0f                	jne    8009d5 <memmove+0x61>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 77 ff ff ff       	call   800974 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a13:	eb 16                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a18:	42                   	inc    %edx
  800a19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a1d:	38 c8                	cmp    %cl,%al
  800a1f:	74 0a                	je     800a2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c0             	movzbl %al,%eax
  800a24:	0f b6 c9             	movzbl %cl,%ecx
  800a27:	29 c8                	sub    %ecx,%eax
  800a29:	eb 09                	jmp    800a34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	75 e6                	jne    800a15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	eb 05                	jmp    800a4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	38 08                	cmp    %cl,(%eax)
  800a4b:	74 05                	je     800a52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4d:	40                   	inc    %eax
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	72 f7                	jb     800a49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 01                	jmp    800a63 <strtol+0xf>
		s++;
  800a62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	8a 02                	mov    (%edx),%al
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f9                	je     800a62 <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f5                	je     800a62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	75 08                	jne    800a79 <strtol+0x25>
		s++;
  800a71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
  800a77:	eb 13                	jmp    800a8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a79:	3c 2d                	cmp    $0x2d,%al
  800a7b:	75 0a                	jne    800a87 <strtol+0x33>
		s++, neg = 1;
  800a7d:	8d 52 01             	lea    0x1(%edx),%edx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb 05                	jmp    800a8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 05                	je     800a95 <strtol+0x41>
  800a90:	83 fb 10             	cmp    $0x10,%ebx
  800a93:	75 28                	jne    800abd <strtol+0x69>
  800a95:	8a 02                	mov    (%edx),%al
  800a97:	3c 30                	cmp    $0x30,%al
  800a99:	75 10                	jne    800aab <strtol+0x57>
  800a9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9f:	75 0a                	jne    800aab <strtol+0x57>
		s += 2, base = 16;
  800aa1:	83 c2 02             	add    $0x2,%edx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 12                	jmp    800abd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 0e                	jne    800abd <strtol+0x69>
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 05                	jne    800ab8 <strtol+0x64>
		s++, base = 8;
  800ab3:	42                   	inc    %edx
  800ab4:	b3 08                	mov    $0x8,%bl
  800ab6:	eb 05                	jmp    800abd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac4:	8a 0a                	mov    (%edx),%cl
  800ac6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac9:	80 fb 09             	cmp    $0x9,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x82>
			dig = *s - '0';
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 30             	sub    $0x30,%ecx
  800ad4:	eb 1e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 57             	sub    $0x57,%ecx
  800ae4:	eb 0e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 12                	ja     800b00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af4:	39 f1                	cmp    %esi,%ecx
  800af6:	7d 0c                	jge    800b04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af8:	42                   	inc    %edx
  800af9:	0f af c6             	imul   %esi,%eax
  800afc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afe:	eb c4                	jmp    800ac4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	89 c1                	mov    %eax,%ecx
  800b02:	eb 02                	jmp    800b06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 05                	je     800b11 <strtol+0xbd>
		*endptr = (char *) s;
  800b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b11:	85 ff                	test   %edi,%edi
  800b13:	74 04                	je     800b19 <strtol+0xc5>
  800b15:	89 c8                	mov    %ecx,%eax
  800b17:	f7 d8                	neg    %eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    
	...

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	89 cb                	mov    %ecx,%ebx
  800b75:	89 cf                	mov    %ecx,%edi
  800b77:	89 ce                	mov    %ecx,%esi
  800b79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 28                	jle    800ba7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b8a:	00 
  800b8b:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800b92:	00 
  800b93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9a:	00 
  800b9b:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800ba2:	e8 b1 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	83 c4 2c             	add    $0x2c,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 28                	jle    800c39 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c1c:	00 
  800c1d:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800c24:	00 
  800c25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2c:	00 
  800c2d:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800c34:	e8 1f f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c39:	83 c4 2c             	add    $0x2c,%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 28                	jle    800c8c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c6f:	00 
  800c70:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800c77:	00 
  800c78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7f:	00 
  800c80:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800c87:	e8 cc f4 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8c:	83 c4 2c             	add    $0x2c,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800cda:	e8 79 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800d2d:	e8 26 f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800d80:	e8 d3 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800dd3:	e8 80 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	be 00 00 00 00       	mov    $0x0,%esi
  800deb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e11:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 cb                	mov    %ecx,%ebx
  800e1b:	89 cf                	mov    %ecx,%edi
  800e1d:	89 ce                	mov    %ecx,%esi
  800e1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 28                	jle    800e4d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e29:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e30:	00 
  800e31:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800e38:	00 
  800e39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e40:	00 
  800e41:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800e48:	e8 0b f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4d:	83 c4 2c             	add    $0x2c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	00 00                	add    %al,(%eax)
	...

00800e58 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e5f:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e66:	75 6f                	jne    800ed7 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  800e68:	e8 42 fd ff ff       	call   800baf <sys_getenvid>
  800e6d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800e6f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e7e:	ee 
  800e7f:	89 04 24             	mov    %eax,(%esp)
  800e82:	e8 66 fd ff ff       	call   800bed <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 1c                	jns    800ea7 <set_pgfault_handler+0x4f>
  800e8b:	c7 44 24 08 ac 24 80 	movl   $0x8024ac,0x8(%esp)
  800e92:	00 
  800e93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9a:	00 
  800e9b:	c7 04 24 05 25 80 00 	movl   $0x802505,(%esp)
  800ea2:	e8 b1 f2 ff ff       	call   800158 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800ea7:	c7 44 24 04 e8 0e 80 	movl   $0x800ee8,0x4(%esp)
  800eae:	00 
  800eaf:	89 1c 24             	mov    %ebx,(%esp)
  800eb2:	e8 d6 fe ff ff       	call   800d8d <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	79 1c                	jns    800ed7 <set_pgfault_handler+0x7f>
  800ebb:	c7 44 24 08 d4 24 80 	movl   $0x8024d4,0x8(%esp)
  800ec2:	00 
  800ec3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800eca:	00 
  800ecb:	c7 04 24 05 25 80 00 	movl   $0x802505,(%esp)
  800ed2:	e8 81 f2 ff ff       	call   800158 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800edf:	83 c4 14             	add    $0x14,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	00 00                	add    %al,(%eax)
	...

00800ee8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ee8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ee9:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800eee:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ef0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  800ef3:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  800ef7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  800efc:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  800f00:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  800f02:	83 c4 08             	add    $0x8,%esp
	popal
  800f05:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  800f06:	83 c4 04             	add    $0x4,%esp
	popfl
  800f09:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  800f0a:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800f0d:	c3                   	ret    
	...

00800f10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	05 00 00 00 30       	add    $0x30000000,%eax
  800f1b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f26:	8b 45 08             	mov    0x8(%ebp),%eax
  800f29:	89 04 24             	mov    %eax,(%esp)
  800f2c:	e8 df ff ff ff       	call   800f10 <fd2num>
  800f31:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f36:	c1 e0 0c             	shl    $0xc,%eax
}
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	53                   	push   %ebx
  800f3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f42:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f47:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f49:	89 c2                	mov    %eax,%edx
  800f4b:	c1 ea 16             	shr    $0x16,%edx
  800f4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	74 11                	je     800f6b <fd_alloc+0x30>
  800f5a:	89 c2                	mov    %eax,%edx
  800f5c:	c1 ea 0c             	shr    $0xc,%edx
  800f5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f66:	f6 c2 01             	test   $0x1,%dl
  800f69:	75 09                	jne    800f74 <fd_alloc+0x39>
			*fd_store = fd;
  800f6b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f72:	eb 17                	jmp    800f8b <fd_alloc+0x50>
  800f74:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f79:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f7e:	75 c7                	jne    800f47 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f86:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f8b:	5b                   	pop    %ebx
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f94:	83 f8 1f             	cmp    $0x1f,%eax
  800f97:	77 36                	ja     800fcf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f99:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f9e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa1:	89 c2                	mov    %eax,%edx
  800fa3:	c1 ea 16             	shr    $0x16,%edx
  800fa6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fad:	f6 c2 01             	test   $0x1,%dl
  800fb0:	74 24                	je     800fd6 <fd_lookup+0x48>
  800fb2:	89 c2                	mov    %eax,%edx
  800fb4:	c1 ea 0c             	shr    $0xc,%edx
  800fb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbe:	f6 c2 01             	test   $0x1,%dl
  800fc1:	74 1a                	je     800fdd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc6:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcd:	eb 13                	jmp    800fe2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd4:	eb 0c                	jmp    800fe2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fdb:	eb 05                	jmp    800fe2 <fd_lookup+0x54>
  800fdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 14             	sub    $0x14,%esp
  800feb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff6:	eb 0e                	jmp    801006 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ff8:	39 08                	cmp    %ecx,(%eax)
  800ffa:	75 09                	jne    801005 <dev_lookup+0x21>
			*dev = devtab[i];
  800ffc:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ffe:	b8 00 00 00 00       	mov    $0x0,%eax
  801003:	eb 35                	jmp    80103a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801005:	42                   	inc    %edx
  801006:	8b 04 95 94 25 80 00 	mov    0x802594(,%edx,4),%eax
  80100d:	85 c0                	test   %eax,%eax
  80100f:	75 e7                	jne    800ff8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801011:	a1 04 40 80 00       	mov    0x804004,%eax
  801016:	8b 00                	mov    (%eax),%eax
  801018:	8b 40 48             	mov    0x48(%eax),%eax
  80101b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801023:	c7 04 24 14 25 80 00 	movl   $0x802514,(%esp)
  80102a:	e8 21 f2 ff ff       	call   800250 <cprintf>
	*dev = 0;
  80102f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801035:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80103a:	83 c4 14             	add    $0x14,%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	56                   	push   %esi
  801044:	53                   	push   %ebx
  801045:	83 ec 30             	sub    $0x30,%esp
  801048:	8b 75 08             	mov    0x8(%ebp),%esi
  80104b:	8a 45 0c             	mov    0xc(%ebp),%al
  80104e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801051:	89 34 24             	mov    %esi,(%esp)
  801054:	e8 b7 fe ff ff       	call   800f10 <fd2num>
  801059:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80105c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801060:	89 04 24             	mov    %eax,(%esp)
  801063:	e8 26 ff ff ff       	call   800f8e <fd_lookup>
  801068:	89 c3                	mov    %eax,%ebx
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 05                	js     801073 <fd_close+0x33>
	    || fd != fd2)
  80106e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801071:	74 0d                	je     801080 <fd_close+0x40>
		return (must_exist ? r : 0);
  801073:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801077:	75 46                	jne    8010bf <fd_close+0x7f>
  801079:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107e:	eb 3f                	jmp    8010bf <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801080:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801083:	89 44 24 04          	mov    %eax,0x4(%esp)
  801087:	8b 06                	mov    (%esi),%eax
  801089:	89 04 24             	mov    %eax,(%esp)
  80108c:	e8 53 ff ff ff       	call   800fe4 <dev_lookup>
  801091:	89 c3                	mov    %eax,%ebx
  801093:	85 c0                	test   %eax,%eax
  801095:	78 18                	js     8010af <fd_close+0x6f>
		if (dev->dev_close)
  801097:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80109a:	8b 40 10             	mov    0x10(%eax),%eax
  80109d:	85 c0                	test   %eax,%eax
  80109f:	74 09                	je     8010aa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010a1:	89 34 24             	mov    %esi,(%esp)
  8010a4:	ff d0                	call   *%eax
  8010a6:	89 c3                	mov    %eax,%ebx
  8010a8:	eb 05                	jmp    8010af <fd_close+0x6f>
		else
			r = 0;
  8010aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ba:	e8 d5 fb ff ff       	call   800c94 <sys_page_unmap>
	return r;
}
  8010bf:	89 d8                	mov    %ebx,%eax
  8010c1:	83 c4 30             	add    $0x30,%esp
  8010c4:	5b                   	pop    %ebx
  8010c5:	5e                   	pop    %esi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d8:	89 04 24             	mov    %eax,(%esp)
  8010db:	e8 ae fe ff ff       	call   800f8e <fd_lookup>
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 13                	js     8010f7 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010e4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010eb:	00 
  8010ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ef:	89 04 24             	mov    %eax,(%esp)
  8010f2:	e8 49 ff ff ff       	call   801040 <fd_close>
}
  8010f7:	c9                   	leave  
  8010f8:	c3                   	ret    

008010f9 <close_all>:

void
close_all(void)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801105:	89 1c 24             	mov    %ebx,(%esp)
  801108:	e8 bb ff ff ff       	call   8010c8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80110d:	43                   	inc    %ebx
  80110e:	83 fb 20             	cmp    $0x20,%ebx
  801111:	75 f2                	jne    801105 <close_all+0xc>
		close(i);
}
  801113:	83 c4 14             	add    $0x14,%esp
  801116:	5b                   	pop    %ebx
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 4c             	sub    $0x4c,%esp
  801122:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801125:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	89 04 24             	mov    %eax,(%esp)
  801132:	e8 57 fe ff ff       	call   800f8e <fd_lookup>
  801137:	89 c3                	mov    %eax,%ebx
  801139:	85 c0                	test   %eax,%eax
  80113b:	0f 88 e1 00 00 00    	js     801222 <dup+0x109>
		return r;
	close(newfdnum);
  801141:	89 3c 24             	mov    %edi,(%esp)
  801144:	e8 7f ff ff ff       	call   8010c8 <close>

	newfd = INDEX2FD(newfdnum);
  801149:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80114f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801152:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801155:	89 04 24             	mov    %eax,(%esp)
  801158:	e8 c3 fd ff ff       	call   800f20 <fd2data>
  80115d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80115f:	89 34 24             	mov    %esi,(%esp)
  801162:	e8 b9 fd ff ff       	call   800f20 <fd2data>
  801167:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80116a:	89 d8                	mov    %ebx,%eax
  80116c:	c1 e8 16             	shr    $0x16,%eax
  80116f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801176:	a8 01                	test   $0x1,%al
  801178:	74 46                	je     8011c0 <dup+0xa7>
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	c1 e8 0c             	shr    $0xc,%eax
  80117f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801186:	f6 c2 01             	test   $0x1,%dl
  801189:	74 35                	je     8011c0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80118b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801192:	25 07 0e 00 00       	and    $0xe07,%eax
  801197:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80119e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a9:	00 
  8011aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b5:	e8 87 fa ff ff       	call   800c41 <sys_page_map>
  8011ba:	89 c3                	mov    %eax,%ebx
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 3b                	js     8011fb <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c3:	89 c2                	mov    %eax,%edx
  8011c5:	c1 ea 0c             	shr    $0xc,%edx
  8011c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cf:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011d9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e4:	00 
  8011e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f0:	e8 4c fa ff ff       	call   800c41 <sys_page_map>
  8011f5:	89 c3                	mov    %eax,%ebx
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	79 25                	jns    801220 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801206:	e8 89 fa ff ff       	call   800c94 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80120b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80120e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801212:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801219:	e8 76 fa ff ff       	call   800c94 <sys_page_unmap>
	return r;
  80121e:	eb 02                	jmp    801222 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801220:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801222:	89 d8                	mov    %ebx,%eax
  801224:	83 c4 4c             	add    $0x4c,%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	53                   	push   %ebx
  801230:	83 ec 24             	sub    $0x24,%esp
  801233:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801236:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123d:	89 1c 24             	mov    %ebx,(%esp)
  801240:	e8 49 fd ff ff       	call   800f8e <fd_lookup>
  801245:	85 c0                	test   %eax,%eax
  801247:	78 6f                	js     8012b8 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801249:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801253:	8b 00                	mov    (%eax),%eax
  801255:	89 04 24             	mov    %eax,(%esp)
  801258:	e8 87 fd ff ff       	call   800fe4 <dev_lookup>
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 57                	js     8012b8 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	8b 50 08             	mov    0x8(%eax),%edx
  801267:	83 e2 03             	and    $0x3,%edx
  80126a:	83 fa 01             	cmp    $0x1,%edx
  80126d:	75 25                	jne    801294 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80126f:	a1 04 40 80 00       	mov    0x804004,%eax
  801274:	8b 00                	mov    (%eax),%eax
  801276:	8b 40 48             	mov    0x48(%eax),%eax
  801279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80127d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801281:	c7 04 24 58 25 80 00 	movl   $0x802558,(%esp)
  801288:	e8 c3 ef ff ff       	call   800250 <cprintf>
		return -E_INVAL;
  80128d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801292:	eb 24                	jmp    8012b8 <read+0x8c>
	}
	if (!dev->dev_read)
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	8b 52 08             	mov    0x8(%edx),%edx
  80129a:	85 d2                	test   %edx,%edx
  80129c:	74 15                	je     8012b3 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80129e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ac:	89 04 24             	mov    %eax,(%esp)
  8012af:	ff d2                	call   *%edx
  8012b1:	eb 05                	jmp    8012b8 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012b8:	83 c4 24             	add    $0x24,%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d2:	eb 23                	jmp    8012f7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d4:	89 f0                	mov    %esi,%eax
  8012d6:	29 d8                	sub    %ebx,%eax
  8012d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012df:	01 d8                	add    %ebx,%eax
  8012e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e5:	89 3c 24             	mov    %edi,(%esp)
  8012e8:	e8 3f ff ff ff       	call   80122c <read>
		if (m < 0)
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 10                	js     801301 <readn+0x43>
			return m;
		if (m == 0)
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	74 0a                	je     8012ff <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f5:	01 c3                	add    %eax,%ebx
  8012f7:	39 f3                	cmp    %esi,%ebx
  8012f9:	72 d9                	jb     8012d4 <readn+0x16>
  8012fb:	89 d8                	mov    %ebx,%eax
  8012fd:	eb 02                	jmp    801301 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012ff:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801301:	83 c4 1c             	add    $0x1c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 24             	sub    $0x24,%esp
  801310:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801313:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131a:	89 1c 24             	mov    %ebx,(%esp)
  80131d:	e8 6c fc ff ff       	call   800f8e <fd_lookup>
  801322:	85 c0                	test   %eax,%eax
  801324:	78 6a                	js     801390 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801326:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	8b 00                	mov    (%eax),%eax
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	e8 aa fc ff ff       	call   800fe4 <dev_lookup>
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 52                	js     801390 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801341:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801345:	75 25                	jne    80136c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801347:	a1 04 40 80 00       	mov    0x804004,%eax
  80134c:	8b 00                	mov    (%eax),%eax
  80134e:	8b 40 48             	mov    0x48(%eax),%eax
  801351:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801355:	89 44 24 04          	mov    %eax,0x4(%esp)
  801359:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  801360:	e8 eb ee ff ff       	call   800250 <cprintf>
		return -E_INVAL;
  801365:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136a:	eb 24                	jmp    801390 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80136c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80136f:	8b 52 0c             	mov    0xc(%edx),%edx
  801372:	85 d2                	test   %edx,%edx
  801374:	74 15                	je     80138b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801376:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801379:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801380:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	ff d2                	call   *%edx
  801389:	eb 05                	jmp    801390 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80138b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801390:	83 c4 24             	add    $0x24,%esp
  801393:	5b                   	pop    %ebx
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <seek>:

int
seek(int fdnum, off_t offset)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80139c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80139f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a6:	89 04 24             	mov    %eax,(%esp)
  8013a9:	e8 e0 fb ff ff       	call   800f8e <fd_lookup>
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 0e                	js     8013c0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	53                   	push   %ebx
  8013c6:	83 ec 24             	sub    $0x24,%esp
  8013c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d3:	89 1c 24             	mov    %ebx,(%esp)
  8013d6:	e8 b3 fb ff ff       	call   800f8e <fd_lookup>
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 63                	js     801442 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e9:	8b 00                	mov    (%eax),%eax
  8013eb:	89 04 24             	mov    %eax,(%esp)
  8013ee:	e8 f1 fb ff ff       	call   800fe4 <dev_lookup>
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 4b                	js     801442 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013fe:	75 25                	jne    801425 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801400:	a1 04 40 80 00       	mov    0x804004,%eax
  801405:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801407:	8b 40 48             	mov    0x48(%eax),%eax
  80140a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80140e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801412:	c7 04 24 34 25 80 00 	movl   $0x802534,(%esp)
  801419:	e8 32 ee ff ff       	call   800250 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801423:	eb 1d                	jmp    801442 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801425:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801428:	8b 52 18             	mov    0x18(%edx),%edx
  80142b:	85 d2                	test   %edx,%edx
  80142d:	74 0e                	je     80143d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80142f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801432:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801436:	89 04 24             	mov    %eax,(%esp)
  801439:	ff d2                	call   *%edx
  80143b:	eb 05                	jmp    801442 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80143d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801442:	83 c4 24             	add    $0x24,%esp
  801445:	5b                   	pop    %ebx
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	53                   	push   %ebx
  80144c:	83 ec 24             	sub    $0x24,%esp
  80144f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801452:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801455:	89 44 24 04          	mov    %eax,0x4(%esp)
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	89 04 24             	mov    %eax,(%esp)
  80145f:	e8 2a fb ff ff       	call   800f8e <fd_lookup>
  801464:	85 c0                	test   %eax,%eax
  801466:	78 52                	js     8014ba <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	8b 00                	mov    (%eax),%eax
  801474:	89 04 24             	mov    %eax,(%esp)
  801477:	e8 68 fb ff ff       	call   800fe4 <dev_lookup>
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 3a                	js     8014ba <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801483:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801487:	74 2c                	je     8014b5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801489:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80148c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801493:	00 00 00 
	stat->st_isdir = 0;
  801496:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80149d:	00 00 00 
	stat->st_dev = dev;
  8014a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ad:	89 14 24             	mov    %edx,(%esp)
  8014b0:	ff 50 14             	call   *0x14(%eax)
  8014b3:	eb 05                	jmp    8014ba <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014ba:	83 c4 24             	add    $0x24,%esp
  8014bd:	5b                   	pop    %ebx
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014cf:	00 
  8014d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d3:	89 04 24             	mov    %eax,(%esp)
  8014d6:	e8 88 02 00 00       	call   801763 <open>
  8014db:	89 c3                	mov    %eax,%ebx
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 1b                	js     8014fc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	89 1c 24             	mov    %ebx,(%esp)
  8014eb:	e8 58 ff ff ff       	call   801448 <fstat>
  8014f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8014f2:	89 1c 24             	mov    %ebx,(%esp)
  8014f5:	e8 ce fb ff ff       	call   8010c8 <close>
	return r;
  8014fa:	89 f3                	mov    %esi,%ebx
}
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    
  801505:	00 00                	add    %al,(%eax)
	...

00801508 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	83 ec 10             	sub    $0x10,%esp
  801510:	89 c3                	mov    %eax,%ebx
  801512:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801514:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80151b:	75 11                	jne    80152e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80151d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801524:	e8 ca 08 00 00       	call   801df3 <ipc_find_env>
  801529:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80152e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801535:	00 
  801536:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80153d:	00 
  80153e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801542:	a1 00 40 80 00       	mov    0x804000,%eax
  801547:	89 04 24             	mov    %eax,(%esp)
  80154a:	e8 3e 08 00 00       	call   801d8d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  80154f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801556:	00 
  801557:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801562:	e8 b9 07 00 00       	call   801d20 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801574:	8b 45 08             	mov    0x8(%ebp),%eax
  801577:	8b 40 0c             	mov    0xc(%eax),%eax
  80157a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80157f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801582:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801587:	ba 00 00 00 00       	mov    $0x0,%edx
  80158c:	b8 02 00 00 00       	mov    $0x2,%eax
  801591:	e8 72 ff ff ff       	call   801508 <fsipc>
}
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80159e:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8015b3:	e8 50 ff ff ff       	call   801508 <fsipc>
}
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 14             	sub    $0x14,%esp
  8015c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ca:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d9:	e8 2a ff ff ff       	call   801508 <fsipc>
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 2b                	js     80160d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015e2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015e9:	00 
  8015ea:	89 1c 24             	mov    %ebx,(%esp)
  8015ed:	e8 09 f2 ff ff       	call   8007fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8015f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801602:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801608:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160d:	83 c4 14             	add    $0x14,%esp
  801610:	5b                   	pop    %ebx
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	53                   	push   %ebx
  801617:	83 ec 14             	sub    $0x14,%esp
  80161a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80161d:	8b 45 08             	mov    0x8(%ebp),%eax
  801620:	8b 40 0c             	mov    0xc(%eax),%eax
  801623:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801628:	89 d8                	mov    %ebx,%eax
  80162a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801630:	76 05                	jbe    801637 <devfile_write+0x24>
  801632:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801637:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  80163c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801640:	8b 45 0c             	mov    0xc(%ebp),%eax
  801643:	89 44 24 04          	mov    %eax,0x4(%esp)
  801647:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80164e:	e8 8b f3 ff ff       	call   8009de <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801653:	ba 00 00 00 00       	mov    $0x0,%edx
  801658:	b8 04 00 00 00       	mov    $0x4,%eax
  80165d:	e8 a6 fe ff ff       	call   801508 <fsipc>
  801662:	85 c0                	test   %eax,%eax
  801664:	78 53                	js     8016b9 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801666:	39 c3                	cmp    %eax,%ebx
  801668:	73 24                	jae    80168e <devfile_write+0x7b>
  80166a:	c7 44 24 0c a4 25 80 	movl   $0x8025a4,0xc(%esp)
  801671:	00 
  801672:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  801679:	00 
  80167a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801681:	00 
  801682:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  801689:	e8 ca ea ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80168e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801693:	7e 24                	jle    8016b9 <devfile_write+0xa6>
  801695:	c7 44 24 0c cb 25 80 	movl   $0x8025cb,0xc(%esp)
  80169c:	00 
  80169d:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  8016a4:	00 
  8016a5:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8016ac:	00 
  8016ad:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  8016b4:	e8 9f ea ff ff       	call   800158 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  8016b9:	83 c4 14             	add    $0x14,%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 10             	sub    $0x10,%esp
  8016c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016db:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8016e5:	e8 1e fe ff ff       	call   801508 <fsipc>
  8016ea:	89 c3                	mov    %eax,%ebx
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 6a                	js     80175a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016f0:	39 c6                	cmp    %eax,%esi
  8016f2:	73 24                	jae    801718 <devfile_read+0x59>
  8016f4:	c7 44 24 0c a4 25 80 	movl   $0x8025a4,0xc(%esp)
  8016fb:	00 
  8016fc:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  801703:	00 
  801704:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80170b:	00 
  80170c:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  801713:	e8 40 ea ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  801718:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80171d:	7e 24                	jle    801743 <devfile_read+0x84>
  80171f:	c7 44 24 0c cb 25 80 	movl   $0x8025cb,0xc(%esp)
  801726:	00 
  801727:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  80172e:	00 
  80172f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801736:	00 
  801737:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80173e:	e8 15 ea ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801743:	89 44 24 08          	mov    %eax,0x8(%esp)
  801747:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80174e:	00 
  80174f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 1a f2 ff ff       	call   800974 <memmove>
	return r;
}
  80175a:	89 d8                	mov    %ebx,%eax
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 20             	sub    $0x20,%esp
  80176b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80176e:	89 34 24             	mov    %esi,(%esp)
  801771:	e8 52 f0 ff ff       	call   8007c8 <strlen>
  801776:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80177b:	7f 60                	jg     8017dd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801780:	89 04 24             	mov    %eax,(%esp)
  801783:	e8 b3 f7 ff ff       	call   800f3b <fd_alloc>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 54                	js     8017e2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80178e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801792:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801799:	e8 5d f0 ff ff       	call   8007fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  80179e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ae:	e8 55 fd ff ff       	call   801508 <fsipc>
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	79 15                	jns    8017ce <open+0x6b>
		fd_close(fd, 0);
  8017b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c0:	00 
  8017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c4:	89 04 24             	mov    %eax,(%esp)
  8017c7:	e8 74 f8 ff ff       	call   801040 <fd_close>
		return r;
  8017cc:	eb 14                	jmp    8017e2 <open+0x7f>
	}

	return fd2num(fd);
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	89 04 24             	mov    %eax,(%esp)
  8017d4:	e8 37 f7 ff ff       	call   800f10 <fd2num>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	eb 05                	jmp    8017e2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017dd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017e2:	89 d8                	mov    %ebx,%eax
  8017e4:	83 c4 20             	add    $0x20,%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8017fb:	e8 08 fd ff ff       	call   801508 <fsipc>
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    
	...

00801804 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	83 ec 10             	sub    $0x10,%esp
  80180c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 06 f7 ff ff       	call   800f20 <fd2data>
  80181a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80181c:	c7 44 24 04 d7 25 80 	movl   $0x8025d7,0x4(%esp)
  801823:	00 
  801824:	89 34 24             	mov    %esi,(%esp)
  801827:	e8 cf ef ff ff       	call   8007fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80182c:	8b 43 04             	mov    0x4(%ebx),%eax
  80182f:	2b 03                	sub    (%ebx),%eax
  801831:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801837:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80183e:	00 00 00 
	stat->st_dev = &devpipe;
  801841:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801848:	30 80 00 
	return 0;
}
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 14             	sub    $0x14,%esp
  80185e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801861:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186c:	e8 23 f4 ff ff       	call   800c94 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801871:	89 1c 24             	mov    %ebx,(%esp)
  801874:	e8 a7 f6 ff ff       	call   800f20 <fd2data>
  801879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801884:	e8 0b f4 ff ff       	call   800c94 <sys_page_unmap>
}
  801889:	83 c4 14             	add    $0x14,%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	57                   	push   %edi
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	83 ec 2c             	sub    $0x2c,%esp
  801898:	89 c7                	mov    %eax,%edi
  80189a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80189d:	a1 04 40 80 00       	mov    0x804004,%eax
  8018a2:	8b 00                	mov    (%eax),%eax
  8018a4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018a7:	89 3c 24             	mov    %edi,(%esp)
  8018aa:	e8 89 05 00 00       	call   801e38 <pageref>
  8018af:	89 c6                	mov    %eax,%esi
  8018b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b4:	89 04 24             	mov    %eax,(%esp)
  8018b7:	e8 7c 05 00 00       	call   801e38 <pageref>
  8018bc:	39 c6                	cmp    %eax,%esi
  8018be:	0f 94 c0             	sete   %al
  8018c1:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018c4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018ca:	8b 12                	mov    (%edx),%edx
  8018cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018cf:	39 cb                	cmp    %ecx,%ebx
  8018d1:	75 08                	jne    8018db <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018d3:	83 c4 2c             	add    $0x2c,%esp
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5f                   	pop    %edi
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018db:	83 f8 01             	cmp    $0x1,%eax
  8018de:	75 bd                	jne    80189d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018e0:	8b 42 58             	mov    0x58(%edx),%eax
  8018e3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8018ea:	00 
  8018eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018f3:	c7 04 24 de 25 80 00 	movl   $0x8025de,(%esp)
  8018fa:	e8 51 e9 ff ff       	call   800250 <cprintf>
  8018ff:	eb 9c                	jmp    80189d <_pipeisclosed+0xe>

00801901 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	57                   	push   %edi
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	83 ec 1c             	sub    $0x1c,%esp
  80190a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80190d:	89 34 24             	mov    %esi,(%esp)
  801910:	e8 0b f6 ff ff       	call   800f20 <fd2data>
  801915:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801917:	bf 00 00 00 00       	mov    $0x0,%edi
  80191c:	eb 3c                	jmp    80195a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80191e:	89 da                	mov    %ebx,%edx
  801920:	89 f0                	mov    %esi,%eax
  801922:	e8 68 ff ff ff       	call   80188f <_pipeisclosed>
  801927:	85 c0                	test   %eax,%eax
  801929:	75 38                	jne    801963 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80192b:	e8 9e f2 ff ff       	call   800bce <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801930:	8b 43 04             	mov    0x4(%ebx),%eax
  801933:	8b 13                	mov    (%ebx),%edx
  801935:	83 c2 20             	add    $0x20,%edx
  801938:	39 d0                	cmp    %edx,%eax
  80193a:	73 e2                	jae    80191e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80193c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801942:	89 c2                	mov    %eax,%edx
  801944:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80194a:	79 05                	jns    801951 <devpipe_write+0x50>
  80194c:	4a                   	dec    %edx
  80194d:	83 ca e0             	or     $0xffffffe0,%edx
  801950:	42                   	inc    %edx
  801951:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801955:	40                   	inc    %eax
  801956:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801959:	47                   	inc    %edi
  80195a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80195d:	75 d1                	jne    801930 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80195f:	89 f8                	mov    %edi,%eax
  801961:	eb 05                	jmp    801968 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801963:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801968:	83 c4 1c             	add    $0x1c,%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5f                   	pop    %edi
  80196e:	5d                   	pop    %ebp
  80196f:	c3                   	ret    

00801970 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	57                   	push   %edi
  801974:	56                   	push   %esi
  801975:	53                   	push   %ebx
  801976:	83 ec 1c             	sub    $0x1c,%esp
  801979:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80197c:	89 3c 24             	mov    %edi,(%esp)
  80197f:	e8 9c f5 ff ff       	call   800f20 <fd2data>
  801984:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801986:	be 00 00 00 00       	mov    $0x0,%esi
  80198b:	eb 3a                	jmp    8019c7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80198d:	85 f6                	test   %esi,%esi
  80198f:	74 04                	je     801995 <devpipe_read+0x25>
				return i;
  801991:	89 f0                	mov    %esi,%eax
  801993:	eb 40                	jmp    8019d5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801995:	89 da                	mov    %ebx,%edx
  801997:	89 f8                	mov    %edi,%eax
  801999:	e8 f1 fe ff ff       	call   80188f <_pipeisclosed>
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	75 2e                	jne    8019d0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019a2:	e8 27 f2 ff ff       	call   800bce <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019a7:	8b 03                	mov    (%ebx),%eax
  8019a9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019ac:	74 df                	je     80198d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ae:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019b3:	79 05                	jns    8019ba <devpipe_read+0x4a>
  8019b5:	48                   	dec    %eax
  8019b6:	83 c8 e0             	or     $0xffffffe0,%eax
  8019b9:	40                   	inc    %eax
  8019ba:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019c4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c6:	46                   	inc    %esi
  8019c7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ca:	75 db                	jne    8019a7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019cc:	89 f0                	mov    %esi,%eax
  8019ce:	eb 05                	jmp    8019d5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019d5:	83 c4 1c             	add    $0x1c,%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5f                   	pop    %edi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	57                   	push   %edi
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	83 ec 3c             	sub    $0x3c,%esp
  8019e6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019ec:	89 04 24             	mov    %eax,(%esp)
  8019ef:	e8 47 f5 ff ff       	call   800f3b <fd_alloc>
  8019f4:	89 c3                	mov    %eax,%ebx
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	0f 88 45 01 00 00    	js     801b43 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a05:	00 
  801a06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a14:	e8 d4 f1 ff ff       	call   800bed <sys_page_alloc>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	0f 88 20 01 00 00    	js     801b43 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a23:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 0d f5 ff ff       	call   800f3b <fd_alloc>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	85 c0                	test   %eax,%eax
  801a32:	0f 88 f8 00 00 00    	js     801b30 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a38:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a3f:	00 
  801a40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a4e:	e8 9a f1 ff ff       	call   800bed <sys_page_alloc>
  801a53:	89 c3                	mov    %eax,%ebx
  801a55:	85 c0                	test   %eax,%eax
  801a57:	0f 88 d3 00 00 00    	js     801b30 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a60:	89 04 24             	mov    %eax,(%esp)
  801a63:	e8 b8 f4 ff ff       	call   800f20 <fd2data>
  801a68:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a6a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a71:	00 
  801a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7d:	e8 6b f1 ff ff       	call   800bed <sys_page_alloc>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	85 c0                	test   %eax,%eax
  801a86:	0f 88 91 00 00 00    	js     801b1d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 89 f4 ff ff       	call   800f20 <fd2data>
  801a97:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a9e:	00 
  801a9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aa3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aaa:	00 
  801aab:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab6:	e8 86 f1 ff ff       	call   800c41 <sys_page_map>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 4c                	js     801b0d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ac1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801acc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801acf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ad6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801adc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801adf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ae1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ae4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aee:	89 04 24             	mov    %eax,(%esp)
  801af1:	e8 1a f4 ff ff       	call   800f10 <fd2num>
  801af6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801af8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801afb:	89 04 24             	mov    %eax,(%esp)
  801afe:	e8 0d f4 ff ff       	call   800f10 <fd2num>
  801b03:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b06:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b0b:	eb 36                	jmp    801b43 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801b0d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b18:	e8 77 f1 ff ff       	call   800c94 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801b1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2b:	e8 64 f1 ff ff       	call   800c94 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801b30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3e:	e8 51 f1 ff ff       	call   800c94 <sys_page_unmap>
    err:
	return r;
}
  801b43:	89 d8                	mov    %ebx,%eax
  801b45:	83 c4 3c             	add    $0x3c,%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5f                   	pop    %edi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	89 04 24             	mov    %eax,(%esp)
  801b60:	e8 29 f4 ff ff       	call   800f8e <fd_lookup>
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 15                	js     801b7e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	89 04 24             	mov    %eax,(%esp)
  801b6f:	e8 ac f3 ff ff       	call   800f20 <fd2data>
	return _pipeisclosed(fd, p);
  801b74:	89 c2                	mov    %eax,%edx
  801b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b79:	e8 11 fd ff ff       	call   80188f <_pipeisclosed>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801b90:	c7 44 24 04 f6 25 80 	movl   $0x8025f6,0x4(%esp)
  801b97:	00 
  801b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9b:	89 04 24             	mov    %eax,(%esp)
  801b9e:	e8 58 ec ff ff       	call   8007fb <strcpy>
	return 0;
}
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	57                   	push   %edi
  801bae:	56                   	push   %esi
  801baf:	53                   	push   %ebx
  801bb0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc1:	eb 30                	jmp    801bf3 <devcons_write+0x49>
		m = n - tot;
  801bc3:	8b 75 10             	mov    0x10(%ebp),%esi
  801bc6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801bc8:	83 fe 7f             	cmp    $0x7f,%esi
  801bcb:	76 05                	jbe    801bd2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801bcd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801bd2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bd6:	03 45 0c             	add    0xc(%ebp),%eax
  801bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdd:	89 3c 24             	mov    %edi,(%esp)
  801be0:	e8 8f ed ff ff       	call   800974 <memmove>
		sys_cputs(buf, m);
  801be5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801be9:	89 3c 24             	mov    %edi,(%esp)
  801bec:	e8 2f ef ff ff       	call   800b20 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf1:	01 f3                	add    %esi,%ebx
  801bf3:	89 d8                	mov    %ebx,%eax
  801bf5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf8:	72 c9                	jb     801bc3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfa:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0f:	75 07                	jne    801c18 <devcons_read+0x13>
  801c11:	eb 25                	jmp    801c38 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c13:	e8 b6 ef ff ff       	call   800bce <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c18:	e8 21 ef ff ff       	call   800b3e <sys_cgetc>
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	74 f2                	je     801c13 <devcons_read+0xe>
  801c21:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c23:	85 c0                	test   %eax,%eax
  801c25:	78 1d                	js     801c44 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c27:	83 f8 04             	cmp    $0x4,%eax
  801c2a:	74 13                	je     801c3f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2f:	88 10                	mov    %dl,(%eax)
	return 1;
  801c31:	b8 01 00 00 00       	mov    $0x1,%eax
  801c36:	eb 0c                	jmp    801c44 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3d:	eb 05                	jmp    801c44 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c3f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c52:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c59:	00 
  801c5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c5d:	89 04 24             	mov    %eax,(%esp)
  801c60:	e8 bb ee ff ff       	call   800b20 <sys_cputs>
}
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <getchar>:

int
getchar(void)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c6d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c74:	00 
  801c75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c83:	e8 a4 f5 ff ff       	call   80122c <read>
	if (r < 0)
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	78 0f                	js     801c9b <getchar+0x34>
		return r;
	if (r < 1)
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	7e 06                	jle    801c96 <getchar+0x2f>
		return -E_EOF;
	return c;
  801c90:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c94:	eb 05                	jmp    801c9b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c96:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	89 04 24             	mov    %eax,(%esp)
  801cb0:	e8 d9 f2 ff ff       	call   800f8e <fd_lookup>
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 11                	js     801cca <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cc2:	39 10                	cmp    %edx,(%eax)
  801cc4:	0f 94 c0             	sete   %al
  801cc7:	0f b6 c0             	movzbl %al,%eax
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <opencons>:

int
opencons(void)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	89 04 24             	mov    %eax,(%esp)
  801cd8:	e8 5e f2 ff ff       	call   800f3b <fd_alloc>
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 3c                	js     801d1d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ce8:	00 
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf7:	e8 f1 ee ff ff       	call   800bed <sys_page_alloc>
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 1d                	js     801d1d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d00:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d15:	89 04 24             	mov    %eax,(%esp)
  801d18:	e8 f3 f1 ff ff       	call   800f10 <fd2num>
}
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    
	...

00801d20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	56                   	push   %esi
  801d24:	53                   	push   %ebx
  801d25:	83 ec 10             	sub    $0x10,%esp
  801d28:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801d31:	85 c0                	test   %eax,%eax
  801d33:	75 05                	jne    801d3a <ipc_recv+0x1a>
  801d35:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801d3a:	89 04 24             	mov    %eax,(%esp)
  801d3d:	e8 c1 f0 ff ff       	call   800e03 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801d42:	85 c0                	test   %eax,%eax
  801d44:	79 16                	jns    801d5c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801d46:	85 db                	test   %ebx,%ebx
  801d48:	74 06                	je     801d50 <ipc_recv+0x30>
  801d4a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801d50:	85 f6                	test   %esi,%esi
  801d52:	74 32                	je     801d86 <ipc_recv+0x66>
  801d54:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801d5a:	eb 2a                	jmp    801d86 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801d5c:	85 db                	test   %ebx,%ebx
  801d5e:	74 0c                	je     801d6c <ipc_recv+0x4c>
  801d60:	a1 04 40 80 00       	mov    0x804004,%eax
  801d65:	8b 00                	mov    (%eax),%eax
  801d67:	8b 40 74             	mov    0x74(%eax),%eax
  801d6a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d6c:	85 f6                	test   %esi,%esi
  801d6e:	74 0c                	je     801d7c <ipc_recv+0x5c>
  801d70:	a1 04 40 80 00       	mov    0x804004,%eax
  801d75:	8b 00                	mov    (%eax),%eax
  801d77:	8b 40 78             	mov    0x78(%eax),%eax
  801d7a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801d7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801d81:	8b 00                	mov    (%eax),%eax
  801d83:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5d                   	pop    %ebp
  801d8c:	c3                   	ret    

00801d8d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	57                   	push   %edi
  801d91:	56                   	push   %esi
  801d92:	53                   	push   %ebx
  801d93:	83 ec 1c             	sub    $0x1c,%esp
  801d96:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d9c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801d9f:	85 db                	test   %ebx,%ebx
  801da1:	75 05                	jne    801da8 <ipc_send+0x1b>
  801da3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801da8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	89 04 24             	mov    %eax,(%esp)
  801dba:	e8 21 f0 ff ff       	call   800de0 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801dbf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dc2:	75 07                	jne    801dcb <ipc_send+0x3e>
  801dc4:	e8 05 ee ff ff       	call   800bce <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801dc9:	eb dd                	jmp    801da8 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	79 1c                	jns    801deb <ipc_send+0x5e>
  801dcf:	c7 44 24 08 02 26 80 	movl   $0x802602,0x8(%esp)
  801dd6:	00 
  801dd7:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801dde:	00 
  801ddf:	c7 04 24 14 26 80 00 	movl   $0x802614,(%esp)
  801de6:	e8 6d e3 ff ff       	call   800158 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801deb:	83 c4 1c             	add    $0x1c,%esp
  801dee:	5b                   	pop    %ebx
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    

00801df3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	53                   	push   %ebx
  801df7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801dfa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dff:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	c1 e2 07             	shl    $0x7,%edx
  801e0b:	29 ca                	sub    %ecx,%edx
  801e0d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e13:	8b 52 50             	mov    0x50(%edx),%edx
  801e16:	39 da                	cmp    %ebx,%edx
  801e18:	75 0f                	jne    801e29 <ipc_find_env+0x36>
			return envs[i].env_id;
  801e1a:	c1 e0 07             	shl    $0x7,%eax
  801e1d:	29 c8                	sub    %ecx,%eax
  801e1f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e24:	8b 40 40             	mov    0x40(%eax),%eax
  801e27:	eb 0c                	jmp    801e35 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e29:	40                   	inc    %eax
  801e2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e2f:	75 ce                	jne    801dff <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e31:	66 b8 00 00          	mov    $0x0,%ax
}
  801e35:	5b                   	pop    %ebx
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	c1 ea 16             	shr    $0x16,%edx
  801e43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e4a:	f6 c2 01             	test   $0x1,%dl
  801e4d:	74 1e                	je     801e6d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e4f:	c1 e8 0c             	shr    $0xc,%eax
  801e52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e59:	a8 01                	test   $0x1,%al
  801e5b:	74 17                	je     801e74 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e5d:	c1 e8 0c             	shr    $0xc,%eax
  801e60:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e67:	ef 
  801e68:	0f b7 c0             	movzwl %ax,%eax
  801e6b:	eb 0c                	jmp    801e79 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e72:	eb 05                	jmp    801e79 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e74:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    
	...

00801e7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e7c:	55                   	push   %ebp
  801e7d:	57                   	push   %edi
  801e7e:	56                   	push   %esi
  801e7f:	83 ec 10             	sub    $0x10,%esp
  801e82:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e86:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e8e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801e92:	89 cd                	mov    %ecx,%ebp
  801e94:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	75 2c                	jne    801ec8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e9c:	39 f9                	cmp    %edi,%ecx
  801e9e:	77 68                	ja     801f08 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ea0:	85 c9                	test   %ecx,%ecx
  801ea2:	75 0b                	jne    801eaf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ea4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea9:	31 d2                	xor    %edx,%edx
  801eab:	f7 f1                	div    %ecx
  801ead:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801eaf:	31 d2                	xor    %edx,%edx
  801eb1:	89 f8                	mov    %edi,%eax
  801eb3:	f7 f1                	div    %ecx
  801eb5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801eb7:	89 f0                	mov    %esi,%eax
  801eb9:	f7 f1                	div    %ecx
  801ebb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ebd:	89 f0                	mov    %esi,%eax
  801ebf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ec8:	39 f8                	cmp    %edi,%eax
  801eca:	77 2c                	ja     801ef8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ecc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801ecf:	83 f6 1f             	xor    $0x1f,%esi
  801ed2:	75 4c                	jne    801f20 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ed4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ed6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801edb:	72 0a                	jb     801ee7 <__udivdi3+0x6b>
  801edd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ee1:	0f 87 ad 00 00 00    	ja     801f94 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ee7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801eec:	89 f0                	mov    %esi,%eax
  801eee:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    
  801ef7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ef8:	31 ff                	xor    %edi,%edi
  801efa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801efc:	89 f0                	mov    %esi,%eax
  801efe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	5e                   	pop    %esi
  801f04:	5f                   	pop    %edi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    
  801f07:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f08:	89 fa                	mov    %edi,%edx
  801f0a:	89 f0                	mov    %esi,%eax
  801f0c:	f7 f1                	div    %ecx
  801f0e:	89 c6                	mov    %eax,%esi
  801f10:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f12:	89 f0                	mov    %esi,%eax
  801f14:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    
  801f1d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f20:	89 f1                	mov    %esi,%ecx
  801f22:	d3 e0                	shl    %cl,%eax
  801f24:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f28:	b8 20 00 00 00       	mov    $0x20,%eax
  801f2d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801f2f:	89 ea                	mov    %ebp,%edx
  801f31:	88 c1                	mov    %al,%cl
  801f33:	d3 ea                	shr    %cl,%edx
  801f35:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801f39:	09 ca                	or     %ecx,%edx
  801f3b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801f3f:	89 f1                	mov    %esi,%ecx
  801f41:	d3 e5                	shl    %cl,%ebp
  801f43:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801f47:	89 fd                	mov    %edi,%ebp
  801f49:	88 c1                	mov    %al,%cl
  801f4b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801f4d:	89 fa                	mov    %edi,%edx
  801f4f:	89 f1                	mov    %esi,%ecx
  801f51:	d3 e2                	shl    %cl,%edx
  801f53:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f57:	88 c1                	mov    %al,%cl
  801f59:	d3 ef                	shr    %cl,%edi
  801f5b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f5d:	89 f8                	mov    %edi,%eax
  801f5f:	89 ea                	mov    %ebp,%edx
  801f61:	f7 74 24 08          	divl   0x8(%esp)
  801f65:	89 d1                	mov    %edx,%ecx
  801f67:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801f69:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f6d:	39 d1                	cmp    %edx,%ecx
  801f6f:	72 17                	jb     801f88 <__udivdi3+0x10c>
  801f71:	74 09                	je     801f7c <__udivdi3+0x100>
  801f73:	89 fe                	mov    %edi,%esi
  801f75:	31 ff                	xor    %edi,%edi
  801f77:	e9 41 ff ff ff       	jmp    801ebd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f7c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f80:	89 f1                	mov    %esi,%ecx
  801f82:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f84:	39 c2                	cmp    %eax,%edx
  801f86:	73 eb                	jae    801f73 <__udivdi3+0xf7>
		{
		  q0--;
  801f88:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f8b:	31 ff                	xor    %edi,%edi
  801f8d:	e9 2b ff ff ff       	jmp    801ebd <__udivdi3+0x41>
  801f92:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f94:	31 f6                	xor    %esi,%esi
  801f96:	e9 22 ff ff ff       	jmp    801ebd <__udivdi3+0x41>
	...

00801f9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f9c:	55                   	push   %ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	83 ec 20             	sub    $0x20,%esp
  801fa2:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fa6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801faa:	89 44 24 14          	mov    %eax,0x14(%esp)
  801fae:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801fb2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fb6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801fba:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801fbc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fbe:	85 ed                	test   %ebp,%ebp
  801fc0:	75 16                	jne    801fd8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801fc2:	39 f1                	cmp    %esi,%ecx
  801fc4:	0f 86 a6 00 00 00    	jbe    802070 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fca:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801fcc:	89 d0                	mov    %edx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fd0:	83 c4 20             	add    $0x20,%esp
  801fd3:	5e                   	pop    %esi
  801fd4:	5f                   	pop    %edi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    
  801fd7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fd8:	39 f5                	cmp    %esi,%ebp
  801fda:	0f 87 ac 00 00 00    	ja     80208c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fe0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801fe3:	83 f0 1f             	xor    $0x1f,%eax
  801fe6:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fea:	0f 84 a8 00 00 00    	je     802098 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ff0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ff4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ff6:	bf 20 00 00 00       	mov    $0x20,%edi
  801ffb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801fff:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802003:	89 f9                	mov    %edi,%ecx
  802005:	d3 e8                	shr    %cl,%eax
  802007:	09 e8                	or     %ebp,%eax
  802009:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80200d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802011:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802015:	d3 e0                	shl    %cl,%eax
  802017:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80201b:	89 f2                	mov    %esi,%edx
  80201d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80201f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802023:	d3 e0                	shl    %cl,%eax
  802025:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802029:	8b 44 24 14          	mov    0x14(%esp),%eax
  80202d:	89 f9                	mov    %edi,%ecx
  80202f:	d3 e8                	shr    %cl,%eax
  802031:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802033:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802035:	89 f2                	mov    %esi,%edx
  802037:	f7 74 24 18          	divl   0x18(%esp)
  80203b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80203d:	f7 64 24 0c          	mull   0xc(%esp)
  802041:	89 c5                	mov    %eax,%ebp
  802043:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802045:	39 d6                	cmp    %edx,%esi
  802047:	72 67                	jb     8020b0 <__umoddi3+0x114>
  802049:	74 75                	je     8020c0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80204b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80204f:	29 e8                	sub    %ebp,%eax
  802051:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802053:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802057:	d3 e8                	shr    %cl,%eax
  802059:	89 f2                	mov    %esi,%edx
  80205b:	89 f9                	mov    %edi,%ecx
  80205d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80205f:	09 d0                	or     %edx,%eax
  802061:	89 f2                	mov    %esi,%edx
  802063:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802067:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802069:	83 c4 20             	add    $0x20,%esp
  80206c:	5e                   	pop    %esi
  80206d:	5f                   	pop    %edi
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802070:	85 c9                	test   %ecx,%ecx
  802072:	75 0b                	jne    80207f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802074:	b8 01 00 00 00       	mov    $0x1,%eax
  802079:	31 d2                	xor    %edx,%edx
  80207b:	f7 f1                	div    %ecx
  80207d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80207f:	89 f0                	mov    %esi,%eax
  802081:	31 d2                	xor    %edx,%edx
  802083:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802085:	89 f8                	mov    %edi,%eax
  802087:	e9 3e ff ff ff       	jmp    801fca <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80208c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80208e:	83 c4 20             	add    $0x20,%esp
  802091:	5e                   	pop    %esi
  802092:	5f                   	pop    %edi
  802093:	5d                   	pop    %ebp
  802094:	c3                   	ret    
  802095:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802098:	39 f5                	cmp    %esi,%ebp
  80209a:	72 04                	jb     8020a0 <__umoddi3+0x104>
  80209c:	39 f9                	cmp    %edi,%ecx
  80209e:	77 06                	ja     8020a6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020a0:	89 f2                	mov    %esi,%edx
  8020a2:	29 cf                	sub    %ecx,%edi
  8020a4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8020a6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020a8:	83 c4 20             	add    $0x20,%esp
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    
  8020af:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020b0:	89 d1                	mov    %edx,%ecx
  8020b2:	89 c5                	mov    %eax,%ebp
  8020b4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8020b8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8020bc:	eb 8d                	jmp    80204b <__umoddi3+0xaf>
  8020be:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020c0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8020c4:	72 ea                	jb     8020b0 <__umoddi3+0x114>
  8020c6:	89 f1                	mov    %esi,%ecx
  8020c8:	eb 81                	jmp    80204b <__umoddi3+0xaf>
