
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  80004b:	e8 14 02 00 00       	call   800264 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 92 0b 00 00       	call   800c01 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 00 21 80 	movl   $0x802100,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ea 20 80 00 	movl   $0x8020ea,(%esp)
  800092:	e8 d5 00 00 00       	call   80016c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 2c 21 80 	movl   $0x80212c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 fe 06 00 00       	call   8007b1 <snprintf>
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
  8000c6:	e8 a1 0d 00 00       	call   800e6c <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  8000da:	e8 85 01 00 00       	call   800264 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  8000ee:	e8 71 01 00 00       	call   800264 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 20             	sub    $0x20,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800106:	e8 b8 0a 00 00       	call   800bc3 <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800127:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	85 f6                	test   %esi,%esi
  80012e:	7e 07                	jle    800137 <libmain+0x3f>
		binaryname = argv[0];
  800130:	8b 03                	mov    (%ebx),%eax
  800132:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 76 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800143:	e8 08 00 00 00       	call   800150 <exit>
}
  800148:	83 c4 20             	add    $0x20,%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800156:	e8 b2 0f 00 00       	call   80110d <close_all>
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 0a 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80017d:	e8 41 0a 00 00       	call   800bc3 <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 58 21 80 00 	movl   $0x802158,(%esp)
  80019f:	e8 c0 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 50 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 12 26 80 00 	movl   $0x802612,(%esp)
  8001ba:	e8 a5 00 00 00       	call   800264 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	40                   	inc    %eax
  8001d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 19                	jne    8001fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e8:	00 
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 40 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fa:	ff 43 04             	incl   0x4(%ebx)
}
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	5b                   	pop    %ebx
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800213:	00 00 00 
	b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  80023f:	e8 82 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800244:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 d8 08 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 87 ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	75 08                	jne    8002ac <printnum+0x2c>
  8002a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002aa:	77 57                	ja     800303 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b0:	4b                   	dec    %ebx
  8002b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cb:	00 
  8002cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	e8 b2 1b 00 00       	call   801e90 <__udivdi3>
  8002de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	89 fa                	mov    %edi,%edx
  8002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f2:	e8 89 ff ff ff       	call   800280 <printnum>
  8002f7:	eb 0f                	jmp    800308 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fd:	89 34 24             	mov    %esi,(%esp)
  800300:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800303:	4b                   	dec    %ebx
  800304:	85 db                	test   %ebx,%ebx
  800306:	7f f1                	jg     8002f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800310:	8b 45 10             	mov    0x10(%ebp),%eax
  800313:	89 44 24 08          	mov    %eax,0x8(%esp)
  800317:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031e:	00 
  80031f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	e8 7f 1c 00 00       	call   801fb0 <__umoddi3>
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	0f be 80 7b 21 80 00 	movsbl 0x80217b(%eax),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800342:	83 c4 3c             	add    $0x3c,%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 08             	lea    0x8(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x38>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	3b 50 04             	cmp    0x4(%eax),%edx
  800392:	73 08                	jae    80039c <sprintputch+0x18>
		*b->buf++ = ch;
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 0a                	mov    %cl,(%edx)
  800399:	42                   	inc    %edx
  80039a:	89 10                	mov    %edx,(%eax)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 02 00 00 00       	call   8003c6 <vprintfmt>
	va_end(ap);
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 4c             	sub    $0x4c,%esp
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 6b 03 00 00    	je     80074a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	46                   	inc    %esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e5                	jne    8003d7 <vprintfmt+0x11>
  8003f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	eb 26                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800413:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800417:	eb 1d                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800420:	eb 14                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800425:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042c:	eb 08                	jmp    800436 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800431:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	0f b6 06             	movzbl (%esi),%eax
  800439:	8d 56 01             	lea    0x1(%esi),%edx
  80043c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043f:	8a 16                	mov    (%esi),%dl
  800441:	83 ea 23             	sub    $0x23,%edx
  800444:	80 fa 55             	cmp    $0x55,%dl
  800447:	0f 87 e1 02 00 00    	ja     80072e <vprintfmt+0x368>
  80044d:	0f b6 d2             	movzbl %dl,%edx
  800450:	ff 24 95 c0 22 80 00 	jmp    *0x8022c0(,%edx,4)
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800462:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800466:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046c:	83 fa 09             	cmp    $0x9,%edx
  80046f:	77 2a                	ja     80049b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800471:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800472:	eb eb                	jmp    80045f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800482:	eb 17                	jmp    80049b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800488:	78 98                	js     800422 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048d:	eb a7                	jmp    800436 <vprintfmt+0x70>
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800492:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800499:	eb 9b                	jmp    800436 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049f:	79 95                	jns    800436 <vprintfmt+0x70>
  8004a1:	eb 8b                	jmp    80042e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a7:	eb 8d                	jmp    800436 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b6:	8b 00                	mov    (%eax),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 23 ff ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 02                	jns    8004d7 <vprintfmt+0x111>
  8004d5:	f7 d8                	neg    %eax
  8004d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 0f             	cmp    $0xf,%eax
  8004dc:	7f 0b                	jg     8004e9 <vprintfmt+0x123>
  8004de:	8b 04 85 20 24 80 00 	mov    0x802420(,%eax,4),%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 23                	jne    80050c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ed:	c7 44 24 08 93 21 80 	movl   $0x802193,0x8(%esp)
  8004f4:	00 
  8004f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	e8 9a fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800507:	e9 dd fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	c7 44 24 08 bd 25 80 	movl   $0x8025bd,0x8(%esp)
  800517:	00 
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 55 08             	mov    0x8(%ebp),%edx
  80051f:	89 14 24             	mov    %edx,(%esp)
  800522:	e8 77 fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 ba fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
  80052f:	89 f9                	mov    %edi,%ecx
  800531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 30                	mov    (%eax),%esi
  800542:	85 f6                	test   %esi,%esi
  800544:	75 05                	jne    80054b <vprintfmt+0x185>
				p = "(null)";
  800546:	be 8c 21 80 00       	mov    $0x80218c,%esi
			if (width > 0 && padc != '-')
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	0f 8e 84 00 00 00    	jle    8005d9 <vprintfmt+0x213>
  800555:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800559:	74 7e                	je     8005d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 8b 02 00 00       	call   8007f2 <strnlen>
  800567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800573:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800576:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800579:	89 de                	mov    %ebx,%esi
  80057b:	89 d3                	mov    %edx,%ebx
  80057d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	89 3c 24             	mov    %edi,(%esp)
  800588:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	4b                   	dec    %ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f f1                	jg     800581 <vprintfmt+0x1bb>
  800590:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800593:	89 f3                	mov    %esi,%ebx
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059b:	85 c0                	test   %eax,%eax
  80059d:	79 05                	jns    8005a4 <vprintfmt+0x1de>
  80059f:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a7:	29 c2                	sub    %eax,%edx
  8005a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ac:	eb 2b                	jmp    8005d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b2:	74 18                	je     8005cc <vprintfmt+0x206>
  8005b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ba:	76 10                	jbe    8005cc <vprintfmt+0x206>
					putch('?', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
  8005ca:	eb 0a                	jmp    8005d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	46                   	inc    %esi
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	74 21                	je     800602 <vprintfmt+0x23c>
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	78 c9                	js     8005ae <vprintfmt+0x1e8>
  8005e5:	4f                   	dec    %edi
  8005e6:	79 c6                	jns    8005ae <vprintfmt+0x1e8>
  8005e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005eb:	89 de                	mov    %ebx,%esi
  8005ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f0:	eb 18                	jmp    80060a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	4b                   	dec    %ebx
  800600:	eb 08                	jmp    80060a <vprintfmt+0x244>
  800602:	8b 7d 08             	mov    0x8(%ebp),%edi
  800605:	89 de                	mov    %ebx,%esi
  800607:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	7f e4                	jg     8005f2 <vprintfmt+0x22c>
  80060e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800611:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800616:	e9 ce fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7e 10                	jle    800630 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 08             	lea    0x8(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	8b 78 04             	mov    0x4(%eax),%edi
  80062e:	eb 26                	jmp    800656 <vprintfmt+0x290>
	else if (lflag)
  800630:	85 c9                	test   %ecx,%ecx
  800632:	74 12                	je     800646 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 30                	mov    (%eax),%esi
  80063f:	89 f7                	mov    %esi,%edi
  800641:	c1 ff 1f             	sar    $0x1f,%edi
  800644:	eb 10                	jmp    800656 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 30                	mov    (%eax),%esi
  800651:	89 f7                	mov    %esi,%edi
  800653:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800656:	85 ff                	test   %edi,%edi
  800658:	78 0a                	js     800664 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 8c 00 00 00       	jmp    8006f0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800672:	f7 de                	neg    %esi
  800674:	83 d7 00             	adc    $0x0,%edi
  800677:	f7 df                	neg    %edi
			}
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	eb 70                	jmp    8006f0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 c0 fc ff ff       	call   80034a <getuint>
  80068a:	89 c6                	mov    %eax,%esi
  80068c:	89 d7                	mov    %edx,%edi
			base = 10;
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800693:	eb 5b                	jmp    8006f0 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 ab fc ff ff       	call   80034a <getuint>
  80069f:	89 c6                	mov    %eax,%esi
  8006a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a8:	eb 46                	jmp    8006f0 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 63 fc ff ff       	call   80034a <getuint>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800703:	89 34 24             	mov    %esi,(%esp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 6c fb ff ff       	call   800280 <printnum>
			break;
  800714:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800717:	e9 cd fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 bb fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	eb 01                	jmp    80073f <vprintfmt+0x379>
  80073e:	4e                   	dec    %esi
  80073f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800743:	75 f9                	jne    80073e <vprintfmt+0x378>
  800745:	e9 9f fc ff ff       	jmp    8003e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 4c             	add    $0x4c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 33                	jle    8007aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800793:	e8 2e fc ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 0c                	jmp    8007af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb 05                	jmp    8007af <vsnprintf+0x5d>
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 7b ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800821:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f5                	jne    80081e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	89 1c 24             	mov    %ebx,(%esp)
  800839:	e8 9e ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 54 24 04          	mov    %edx,0x4(%esp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 c0 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 0c                	jmp    800878 <strncpy+0x21>
		*dst++ = *src;
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 3a 01             	cmpb   $0x1,(%edx)
  800874:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	41                   	inc    %ecx
  800878:	39 f1                	cmp    %esi,%ecx
  80087a:	75 f0                	jne    80086c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1c>
  800892:	89 f0                	mov    %esi,%eax
  800894:	eb 1a                	jmp    8008b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	88 18                	mov    %bl,(%eax)
  800898:	40                   	inc    %eax
  800899:	41                   	inc    %ecx
  80089a:	eb 02                	jmp    80089e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089e:	4a                   	dec    %edx
  80089f:	74 0a                	je     8008ab <strlcpy+0x2b>
  8008a1:	8a 19                	mov    (%ecx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strlcpy+0x16>
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 02                	jmp    8008ad <strlcpy+0x2d>
  8008ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 02                	jmp    8008c3 <strcmp+0xd>
		p++, q++;
  8008c1:	41                   	inc    %ecx
  8008c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	8a 01                	mov    (%ecx),%al
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x17>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 f4                	je     8008c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 03                	jmp    8008e9 <strncmp+0x12>
		n--, p++, q++;
  8008e6:	4a                   	dec    %edx
  8008e7:	40                   	inc    %eax
  8008e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 14                	je     800901 <strncmp+0x2a>
  8008ed:	8a 18                	mov    (%eax),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	74 04                	je     8008f7 <strncmp+0x20>
  8008f3:	3a 19                	cmp    (%ecx),%bl
  8008f5:	74 ef                	je     8008e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb 05                	jmp    800906 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	eb 05                	jmp    800919 <strchr+0x10>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0c                	je     800924 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092f:	eb 05                	jmp    800936 <strfind+0x10>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 07                	je     80093c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800935:	40                   	inc    %eax
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f5                	jne    800931 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 30                	je     800981 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 25                	jne    80097e <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 20                	jne    80097e <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 d0                	or     %edx,%eax
  800974:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb 03                	jmp    800981 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 34                	jae    8009ce <memmove+0x46>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2d                	jae    8009ce <memmove+0x46>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x3c>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x3c>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 07                	jmp    8009cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	4f                   	dec    %edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 20                	jmp    8009ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	75 13                	jne    8009e9 <memmove+0x61>
  8009d6:	a8 03                	test   $0x3,%al
  8009d8:	75 0f                	jne    8009e9 <memmove+0x61>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 77 ff ff ff       	call   800988 <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	eb 16                	jmp    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
  800a29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a2c:	42                   	inc    %edx
  800a2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a31:	38 c8                	cmp    %cl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 c9             	movzbl %cl,%ecx
  800a3b:	29 c8                	sub    %ecx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 e6                	jne    800a29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 05                	jmp    800a62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	40                   	inc    %eax
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	72 f7                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 01                	jmp    800a77 <strtol+0xf>
		s++;
  800a76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f9                	je     800a76 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f5                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 08                	jne    800a8d <strtol+0x25>
		s++;
  800a85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x33>
		s++, neg = 1;
  800a91:	8d 52 01             	lea    0x1(%edx),%edx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi
  800a99:	eb 05                	jmp    800aa0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 05                	je     800aa9 <strtol+0x41>
  800aa4:	83 fb 10             	cmp    $0x10,%ebx
  800aa7:	75 28                	jne    800ad1 <strtol+0x69>
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 10                	jne    800abf <strtol+0x57>
  800aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab3:	75 0a                	jne    800abf <strtol+0x57>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 12                	jmp    800ad1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 0e                	jne    800ad1 <strtol+0x69>
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 05                	jne    800acc <strtol+0x64>
		s++, base = 8;
  800ac7:	42                   	inc    %edx
  800ac8:	b3 08                	mov    $0x8,%bl
  800aca:	eb 05                	jmp    800ad1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 0a                	mov    (%edx),%cl
  800ada:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x82>
			dig = *s - '0';
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 30             	sub    $0x30,%ecx
  800ae8:	eb 1e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x92>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 12                	ja     800b14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b08:	39 f1                	cmp    %esi,%ecx
  800b0a:	7d 0c                	jge    800b18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b0c:	42                   	inc    %edx
  800b0d:	0f af c6             	imul   %esi,%eax
  800b10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb c4                	jmp    800ad8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	89 c1                	mov    %eax,%ecx
  800b16:	eb 02                	jmp    800b1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 05                	je     800b25 <strtol+0xbd>
		*endptr = (char *) s;
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b25:	85 ff                	test   %edi,%edi
  800b27:	74 04                	je     800b2d <strtol+0xc5>
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 28                	jle    800bbb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bae:	00 
  800baf:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800bb6:	e8 b1 f5 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	83 c4 2c             	add    $0x2c,%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800c48:	e8 1f f5 ff ff       	call   80016c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 75 18             	mov    0x18(%ebp),%esi
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 28                	jle    800ca0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c83:	00 
  800c84:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c93:	00 
  800c94:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800c9b:	e8 cc f4 ff ff       	call   80016c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca0:	83 c4 2c             	add    $0x2c,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800cee:	e8 79 f4 ff ff       	call   80016c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 28                	jle    800d46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d29:	00 
  800d2a:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800d31:	00 
  800d32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d39:	00 
  800d3a:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800d41:	e8 26 f4 ff ff       	call   80016c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	83 c4 2c             	add    $0x2c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800d94:	e8 d3 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 df                	mov    %ebx,%edi
  800dbc:	89 de                	mov    %ebx,%esi
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 28                	jle    800dec <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800de7:	e8 80 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dec:	83 c4 2c             	add    $0x2c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	be 00 00 00 00       	mov    $0x0,%esi
  800dff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 cb                	mov    %ecx,%ebx
  800e2f:	89 cf                	mov    %ecx,%edi
  800e31:	89 ce                	mov    %ecx,%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 7f 24 80 	movl   $0x80247f,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800e5c:	e8 0b f3 ff ff       	call   80016c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	00 00                	add    %al,(%eax)
	...

00800e6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e73:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e7a:	75 6f                	jne    800eeb <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  800e7c:	e8 42 fd ff ff       	call   800bc3 <sys_getenvid>
  800e81:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800e83:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e92:	ee 
  800e93:	89 04 24             	mov    %eax,(%esp)
  800e96:	e8 66 fd ff ff       	call   800c01 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	79 1c                	jns    800ebb <set_pgfault_handler+0x4f>
  800e9f:	c7 44 24 08 ac 24 80 	movl   $0x8024ac,0x8(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eae:	00 
  800eaf:	c7 04 24 05 25 80 00 	movl   $0x802505,(%esp)
  800eb6:	e8 b1 f2 ff ff       	call   80016c <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800ebb:	c7 44 24 04 fc 0e 80 	movl   $0x800efc,0x4(%esp)
  800ec2:	00 
  800ec3:	89 1c 24             	mov    %ebx,(%esp)
  800ec6:	e8 d6 fe ff ff       	call   800da1 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	79 1c                	jns    800eeb <set_pgfault_handler+0x7f>
  800ecf:	c7 44 24 08 d4 24 80 	movl   $0x8024d4,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 05 25 80 00 	movl   $0x802505,(%esp)
  800ee6:	e8 81 f2 ff ff       	call   80016c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800eee:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800ef3:	83 c4 14             	add    $0x14,%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	00 00                	add    %al,(%eax)
	...

00800efc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800efc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800efd:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800f02:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f04:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  800f07:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  800f0b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  800f10:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  800f14:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  800f16:	83 c4 08             	add    $0x8,%esp
	popal
  800f19:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  800f1a:	83 c4 04             	add    $0x4,%esp
	popfl
  800f1d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  800f1e:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800f21:	c3                   	ret    
	...

00800f24 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f27:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f2f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3d:	89 04 24             	mov    %eax,(%esp)
  800f40:	e8 df ff ff ff       	call   800f24 <fd2num>
  800f45:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f4a:	c1 e0 0c             	shl    $0xc,%eax
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	53                   	push   %ebx
  800f53:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f56:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f5b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f5d:	89 c2                	mov    %eax,%edx
  800f5f:	c1 ea 16             	shr    $0x16,%edx
  800f62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	74 11                	je     800f7f <fd_alloc+0x30>
  800f6e:	89 c2                	mov    %eax,%edx
  800f70:	c1 ea 0c             	shr    $0xc,%edx
  800f73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7a:	f6 c2 01             	test   $0x1,%dl
  800f7d:	75 09                	jne    800f88 <fd_alloc+0x39>
			*fd_store = fd;
  800f7f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
  800f86:	eb 17                	jmp    800f9f <fd_alloc+0x50>
  800f88:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f8d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f92:	75 c7                	jne    800f5b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f9a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f9f:	5b                   	pop    %ebx
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fa8:	83 f8 1f             	cmp    $0x1f,%eax
  800fab:	77 36                	ja     800fe3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fad:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fb2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb5:	89 c2                	mov    %eax,%edx
  800fb7:	c1 ea 16             	shr    $0x16,%edx
  800fba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc1:	f6 c2 01             	test   $0x1,%dl
  800fc4:	74 24                	je     800fea <fd_lookup+0x48>
  800fc6:	89 c2                	mov    %eax,%edx
  800fc8:	c1 ea 0c             	shr    $0xc,%edx
  800fcb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd2:	f6 c2 01             	test   $0x1,%dl
  800fd5:	74 1a                	je     800ff1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fda:	89 02                	mov    %eax,(%edx)
	return 0;
  800fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe1:	eb 13                	jmp    800ff6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe8:	eb 0c                	jmp    800ff6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fef:	eb 05                	jmp    800ff6 <fd_lookup+0x54>
  800ff1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 14             	sub    $0x14,%esp
  800fff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801002:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801005:	ba 00 00 00 00       	mov    $0x0,%edx
  80100a:	eb 0e                	jmp    80101a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80100c:	39 08                	cmp    %ecx,(%eax)
  80100e:	75 09                	jne    801019 <dev_lookup+0x21>
			*dev = devtab[i];
  801010:	89 03                	mov    %eax,(%ebx)
			return 0;
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
  801017:	eb 35                	jmp    80104e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801019:	42                   	inc    %edx
  80101a:	8b 04 95 94 25 80 00 	mov    0x802594(,%edx,4),%eax
  801021:	85 c0                	test   %eax,%eax
  801023:	75 e7                	jne    80100c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801025:	a1 04 40 80 00       	mov    0x804004,%eax
  80102a:	8b 00                	mov    (%eax),%eax
  80102c:	8b 40 48             	mov    0x48(%eax),%eax
  80102f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801033:	89 44 24 04          	mov    %eax,0x4(%esp)
  801037:	c7 04 24 14 25 80 00 	movl   $0x802514,(%esp)
  80103e:	e8 21 f2 ff ff       	call   800264 <cprintf>
	*dev = 0;
  801043:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801049:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80104e:	83 c4 14             	add    $0x14,%esp
  801051:	5b                   	pop    %ebx
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 30             	sub    $0x30,%esp
  80105c:	8b 75 08             	mov    0x8(%ebp),%esi
  80105f:	8a 45 0c             	mov    0xc(%ebp),%al
  801062:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801065:	89 34 24             	mov    %esi,(%esp)
  801068:	e8 b7 fe ff ff       	call   800f24 <fd2num>
  80106d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801070:	89 54 24 04          	mov    %edx,0x4(%esp)
  801074:	89 04 24             	mov    %eax,(%esp)
  801077:	e8 26 ff ff ff       	call   800fa2 <fd_lookup>
  80107c:	89 c3                	mov    %eax,%ebx
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 05                	js     801087 <fd_close+0x33>
	    || fd != fd2)
  801082:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801085:	74 0d                	je     801094 <fd_close+0x40>
		return (must_exist ? r : 0);
  801087:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80108b:	75 46                	jne    8010d3 <fd_close+0x7f>
  80108d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801092:	eb 3f                	jmp    8010d3 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801094:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	8b 06                	mov    (%esi),%eax
  80109d:	89 04 24             	mov    %eax,(%esp)
  8010a0:	e8 53 ff ff ff       	call   800ff8 <dev_lookup>
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 18                	js     8010c3 <fd_close+0x6f>
		if (dev->dev_close)
  8010ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ae:	8b 40 10             	mov    0x10(%eax),%eax
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	74 09                	je     8010be <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010b5:	89 34 24             	mov    %esi,(%esp)
  8010b8:	ff d0                	call   *%eax
  8010ba:	89 c3                	mov    %eax,%ebx
  8010bc:	eb 05                	jmp    8010c3 <fd_close+0x6f>
		else
			r = 0;
  8010be:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ce:	e8 d5 fb ff ff       	call   800ca8 <sys_page_unmap>
	return r;
}
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	83 c4 30             	add    $0x30,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	89 04 24             	mov    %eax,(%esp)
  8010ef:	e8 ae fe ff ff       	call   800fa2 <fd_lookup>
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 13                	js     80110b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ff:	00 
  801100:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	e8 49 ff ff ff       	call   801054 <fd_close>
}
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <close_all>:

void
close_all(void)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	53                   	push   %ebx
  801111:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801114:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801119:	89 1c 24             	mov    %ebx,(%esp)
  80111c:	e8 bb ff ff ff       	call   8010dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801121:	43                   	inc    %ebx
  801122:	83 fb 20             	cmp    $0x20,%ebx
  801125:	75 f2                	jne    801119 <close_all+0xc>
		close(i);
}
  801127:	83 c4 14             	add    $0x14,%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	57                   	push   %edi
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 4c             	sub    $0x4c,%esp
  801136:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801139:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80113c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	89 04 24             	mov    %eax,(%esp)
  801146:	e8 57 fe ff ff       	call   800fa2 <fd_lookup>
  80114b:	89 c3                	mov    %eax,%ebx
  80114d:	85 c0                	test   %eax,%eax
  80114f:	0f 88 e1 00 00 00    	js     801236 <dup+0x109>
		return r;
	close(newfdnum);
  801155:	89 3c 24             	mov    %edi,(%esp)
  801158:	e8 7f ff ff ff       	call   8010dc <close>

	newfd = INDEX2FD(newfdnum);
  80115d:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801163:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801169:	89 04 24             	mov    %eax,(%esp)
  80116c:	e8 c3 fd ff ff       	call   800f34 <fd2data>
  801171:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801173:	89 34 24             	mov    %esi,(%esp)
  801176:	e8 b9 fd ff ff       	call   800f34 <fd2data>
  80117b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80117e:	89 d8                	mov    %ebx,%eax
  801180:	c1 e8 16             	shr    $0x16,%eax
  801183:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80118a:	a8 01                	test   $0x1,%al
  80118c:	74 46                	je     8011d4 <dup+0xa7>
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	c1 e8 0c             	shr    $0xc,%eax
  801193:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80119a:	f6 c2 01             	test   $0x1,%dl
  80119d:	74 35                	je     8011d4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80119f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011bd:	00 
  8011be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c9:	e8 87 fa ff ff       	call   800c55 <sys_page_map>
  8011ce:	89 c3                	mov    %eax,%ebx
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 3b                	js     80120f <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	c1 ea 0c             	shr    $0xc,%edx
  8011dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011f8:	00 
  8011f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801204:	e8 4c fa ff ff       	call   800c55 <sys_page_map>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	85 c0                	test   %eax,%eax
  80120d:	79 25                	jns    801234 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80120f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801213:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121a:	e8 89 fa ff ff       	call   800ca8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80121f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122d:	e8 76 fa ff ff       	call   800ca8 <sys_page_unmap>
	return r;
  801232:	eb 02                	jmp    801236 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801234:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801236:	89 d8                	mov    %ebx,%eax
  801238:	83 c4 4c             	add    $0x4c,%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	83 ec 24             	sub    $0x24,%esp
  801247:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801251:	89 1c 24             	mov    %ebx,(%esp)
  801254:	e8 49 fd ff ff       	call   800fa2 <fd_lookup>
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 6f                	js     8012cc <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801260:	89 44 24 04          	mov    %eax,0x4(%esp)
  801264:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801267:	8b 00                	mov    (%eax),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 87 fd ff ff       	call   800ff8 <dev_lookup>
  801271:	85 c0                	test   %eax,%eax
  801273:	78 57                	js     8012cc <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	8b 50 08             	mov    0x8(%eax),%edx
  80127b:	83 e2 03             	and    $0x3,%edx
  80127e:	83 fa 01             	cmp    $0x1,%edx
  801281:	75 25                	jne    8012a8 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801283:	a1 04 40 80 00       	mov    0x804004,%eax
  801288:	8b 00                	mov    (%eax),%eax
  80128a:	8b 40 48             	mov    0x48(%eax),%eax
  80128d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801291:	89 44 24 04          	mov    %eax,0x4(%esp)
  801295:	c7 04 24 58 25 80 00 	movl   $0x802558,(%esp)
  80129c:	e8 c3 ef ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  8012a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a6:	eb 24                	jmp    8012cc <read+0x8c>
	}
	if (!dev->dev_read)
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	8b 52 08             	mov    0x8(%edx),%edx
  8012ae:	85 d2                	test   %edx,%edx
  8012b0:	74 15                	je     8012c7 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012c0:	89 04 24             	mov    %eax,(%esp)
  8012c3:	ff d2                	call   *%edx
  8012c5:	eb 05                	jmp    8012cc <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012cc:	83 c4 24             	add    $0x24,%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
  8012db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e6:	eb 23                	jmp    80130b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012e8:	89 f0                	mov    %esi,%eax
  8012ea:	29 d8                	sub    %ebx,%eax
  8012ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f3:	01 d8                	add    %ebx,%eax
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	89 3c 24             	mov    %edi,(%esp)
  8012fc:	e8 3f ff ff ff       	call   801240 <read>
		if (m < 0)
  801301:	85 c0                	test   %eax,%eax
  801303:	78 10                	js     801315 <readn+0x43>
			return m;
		if (m == 0)
  801305:	85 c0                	test   %eax,%eax
  801307:	74 0a                	je     801313 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801309:	01 c3                	add    %eax,%ebx
  80130b:	39 f3                	cmp    %esi,%ebx
  80130d:	72 d9                	jb     8012e8 <readn+0x16>
  80130f:	89 d8                	mov    %ebx,%eax
  801311:	eb 02                	jmp    801315 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801313:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801315:	83 c4 1c             	add    $0x1c,%esp
  801318:	5b                   	pop    %ebx
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	53                   	push   %ebx
  801321:	83 ec 24             	sub    $0x24,%esp
  801324:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801327:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132e:	89 1c 24             	mov    %ebx,(%esp)
  801331:	e8 6c fc ff ff       	call   800fa2 <fd_lookup>
  801336:	85 c0                	test   %eax,%eax
  801338:	78 6a                	js     8013a4 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801344:	8b 00                	mov    (%eax),%eax
  801346:	89 04 24             	mov    %eax,(%esp)
  801349:	e8 aa fc ff ff       	call   800ff8 <dev_lookup>
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 52                	js     8013a4 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801355:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801359:	75 25                	jne    801380 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80135b:	a1 04 40 80 00       	mov    0x804004,%eax
  801360:	8b 00                	mov    (%eax),%eax
  801362:	8b 40 48             	mov    0x48(%eax),%eax
  801365:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136d:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  801374:	e8 eb ee ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  801379:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137e:	eb 24                	jmp    8013a4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801380:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801383:	8b 52 0c             	mov    0xc(%edx),%edx
  801386:	85 d2                	test   %edx,%edx
  801388:	74 15                	je     80139f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80138a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80138d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801394:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801398:	89 04 24             	mov    %eax,(%esp)
  80139b:	ff d2                	call   *%edx
  80139d:	eb 05                	jmp    8013a4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80139f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013a4:	83 c4 24             	add    $0x24,%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	e8 e0 fb ff ff       	call   800fa2 <fd_lookup>
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 0e                	js     8013d4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 24             	sub    $0x24,%esp
  8013dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e7:	89 1c 24             	mov    %ebx,(%esp)
  8013ea:	e8 b3 fb ff ff       	call   800fa2 <fd_lookup>
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 63                	js     801456 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fd:	8b 00                	mov    (%eax),%eax
  8013ff:	89 04 24             	mov    %eax,(%esp)
  801402:	e8 f1 fb ff ff       	call   800ff8 <dev_lookup>
  801407:	85 c0                	test   %eax,%eax
  801409:	78 4b                	js     801456 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801412:	75 25                	jne    801439 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801414:	a1 04 40 80 00       	mov    0x804004,%eax
  801419:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80141b:	8b 40 48             	mov    0x48(%eax),%eax
  80141e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801422:	89 44 24 04          	mov    %eax,0x4(%esp)
  801426:	c7 04 24 34 25 80 00 	movl   $0x802534,(%esp)
  80142d:	e8 32 ee ff ff       	call   800264 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801432:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801437:	eb 1d                	jmp    801456 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801439:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143c:	8b 52 18             	mov    0x18(%edx),%edx
  80143f:	85 d2                	test   %edx,%edx
  801441:	74 0e                	je     801451 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801443:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801446:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80144a:	89 04 24             	mov    %eax,(%esp)
  80144d:	ff d2                	call   *%edx
  80144f:	eb 05                	jmp    801456 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801451:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801456:	83 c4 24             	add    $0x24,%esp
  801459:	5b                   	pop    %ebx
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	53                   	push   %ebx
  801460:	83 ec 24             	sub    $0x24,%esp
  801463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801466:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801469:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146d:	8b 45 08             	mov    0x8(%ebp),%eax
  801470:	89 04 24             	mov    %eax,(%esp)
  801473:	e8 2a fb ff ff       	call   800fa2 <fd_lookup>
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 52                	js     8014ce <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801486:	8b 00                	mov    (%eax),%eax
  801488:	89 04 24             	mov    %eax,(%esp)
  80148b:	e8 68 fb ff ff       	call   800ff8 <dev_lookup>
  801490:	85 c0                	test   %eax,%eax
  801492:	78 3a                	js     8014ce <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801494:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801497:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80149b:	74 2c                	je     8014c9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80149d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014a7:	00 00 00 
	stat->st_isdir = 0;
  8014aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014b1:	00 00 00 
	stat->st_dev = dev;
  8014b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c1:	89 14 24             	mov    %edx,(%esp)
  8014c4:	ff 50 14             	call   *0x14(%eax)
  8014c7:	eb 05                	jmp    8014ce <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014ce:	83 c4 24             	add    $0x24,%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    

008014d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	56                   	push   %esi
  8014d8:	53                   	push   %ebx
  8014d9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014e3:	00 
  8014e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e7:	89 04 24             	mov    %eax,(%esp)
  8014ea:	e8 88 02 00 00       	call   801777 <open>
  8014ef:	89 c3                	mov    %eax,%ebx
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 1b                	js     801510 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fc:	89 1c 24             	mov    %ebx,(%esp)
  8014ff:	e8 58 ff ff ff       	call   80145c <fstat>
  801504:	89 c6                	mov    %eax,%esi
	close(fd);
  801506:	89 1c 24             	mov    %ebx,(%esp)
  801509:	e8 ce fb ff ff       	call   8010dc <close>
	return r;
  80150e:	89 f3                	mov    %esi,%ebx
}
  801510:	89 d8                	mov    %ebx,%eax
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    
  801519:	00 00                	add    %al,(%eax)
	...

0080151c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	83 ec 10             	sub    $0x10,%esp
  801524:	89 c3                	mov    %eax,%ebx
  801526:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801528:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80152f:	75 11                	jne    801542 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801531:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801538:	e8 ca 08 00 00       	call   801e07 <ipc_find_env>
  80153d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801542:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801549:	00 
  80154a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801551:	00 
  801552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801556:	a1 00 40 80 00       	mov    0x804000,%eax
  80155b:	89 04 24             	mov    %eax,(%esp)
  80155e:	e8 3e 08 00 00       	call   801da1 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801563:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80156a:	00 
  80156b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801576:	e8 b9 07 00 00       	call   801d34 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	8b 40 0c             	mov    0xc(%eax),%eax
  80158e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801593:	8b 45 0c             	mov    0xc(%ebp),%eax
  801596:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8015a5:	e8 72 ff ff ff       	call   80151c <fsipc>
}
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8015c7:	e8 50 ff ff ff       	call   80151c <fsipc>
}
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 14             	sub    $0x14,%esp
  8015d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015db:	8b 40 0c             	mov    0xc(%eax),%eax
  8015de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ed:	e8 2a ff ff ff       	call   80151c <fsipc>
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 2b                	js     801621 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015f6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015fd:	00 
  8015fe:	89 1c 24             	mov    %ebx,(%esp)
  801601:	e8 09 f2 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801606:	a1 80 50 80 00       	mov    0x805080,%eax
  80160b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801611:	a1 84 50 80 00       	mov    0x805084,%eax
  801616:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80161c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801621:	83 c4 14             	add    $0x14,%esp
  801624:	5b                   	pop    %ebx
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	53                   	push   %ebx
  80162b:	83 ec 14             	sub    $0x14,%esp
  80162e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801631:	8b 45 08             	mov    0x8(%ebp),%eax
  801634:	8b 40 0c             	mov    0xc(%eax),%eax
  801637:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  80163c:	89 d8                	mov    %ebx,%eax
  80163e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801644:	76 05                	jbe    80164b <devfile_write+0x24>
  801646:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80164b:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801650:	89 44 24 08          	mov    %eax,0x8(%esp)
  801654:	8b 45 0c             	mov    0xc(%ebp),%eax
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801662:	e8 8b f3 ff ff       	call   8009f2 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
  80166c:	b8 04 00 00 00       	mov    $0x4,%eax
  801671:	e8 a6 fe ff ff       	call   80151c <fsipc>
  801676:	85 c0                	test   %eax,%eax
  801678:	78 53                	js     8016cd <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  80167a:	39 c3                	cmp    %eax,%ebx
  80167c:	73 24                	jae    8016a2 <devfile_write+0x7b>
  80167e:	c7 44 24 0c a4 25 80 	movl   $0x8025a4,0xc(%esp)
  801685:	00 
  801686:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  80168d:	00 
  80168e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801695:	00 
  801696:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80169d:	e8 ca ea ff ff       	call   80016c <_panic>
	assert(r <= PGSIZE);
  8016a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016a7:	7e 24                	jle    8016cd <devfile_write+0xa6>
  8016a9:	c7 44 24 0c cb 25 80 	movl   $0x8025cb,0xc(%esp)
  8016b0:	00 
  8016b1:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  8016b8:	00 
  8016b9:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8016c0:	00 
  8016c1:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  8016c8:	e8 9f ea ff ff       	call   80016c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  8016cd:	83 c4 14             	add    $0x14,%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 10             	sub    $0x10,%esp
  8016db:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016e9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8016f9:	e8 1e fe ff ff       	call   80151c <fsipc>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	85 c0                	test   %eax,%eax
  801702:	78 6a                	js     80176e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801704:	39 c6                	cmp    %eax,%esi
  801706:	73 24                	jae    80172c <devfile_read+0x59>
  801708:	c7 44 24 0c a4 25 80 	movl   $0x8025a4,0xc(%esp)
  80170f:	00 
  801710:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  801717:	00 
  801718:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80171f:	00 
  801720:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  801727:	e8 40 ea ff ff       	call   80016c <_panic>
	assert(r <= PGSIZE);
  80172c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801731:	7e 24                	jle    801757 <devfile_read+0x84>
  801733:	c7 44 24 0c cb 25 80 	movl   $0x8025cb,0xc(%esp)
  80173a:	00 
  80173b:	c7 44 24 08 ab 25 80 	movl   $0x8025ab,0x8(%esp)
  801742:	00 
  801743:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  80174a:	00 
  80174b:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  801752:	e8 15 ea ff ff       	call   80016c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801757:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801762:	00 
  801763:	8b 45 0c             	mov    0xc(%ebp),%eax
  801766:	89 04 24             	mov    %eax,(%esp)
  801769:	e8 1a f2 ff ff       	call   800988 <memmove>
	return r;
}
  80176e:	89 d8                	mov    %ebx,%eax
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	56                   	push   %esi
  80177b:	53                   	push   %ebx
  80177c:	83 ec 20             	sub    $0x20,%esp
  80177f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801782:	89 34 24             	mov    %esi,(%esp)
  801785:	e8 52 f0 ff ff       	call   8007dc <strlen>
  80178a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80178f:	7f 60                	jg     8017f1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801794:	89 04 24             	mov    %eax,(%esp)
  801797:	e8 b3 f7 ff ff       	call   800f4f <fd_alloc>
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 54                	js     8017f6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017ad:	e8 5d f0 ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c2:	e8 55 fd ff ff       	call   80151c <fsipc>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	79 15                	jns    8017e2 <open+0x6b>
		fd_close(fd, 0);
  8017cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017d4:	00 
  8017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d8:	89 04 24             	mov    %eax,(%esp)
  8017db:	e8 74 f8 ff ff       	call   801054 <fd_close>
		return r;
  8017e0:	eb 14                	jmp    8017f6 <open+0x7f>
	}

	return fd2num(fd);
  8017e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e5:	89 04 24             	mov    %eax,(%esp)
  8017e8:	e8 37 f7 ff ff       	call   800f24 <fd2num>
  8017ed:	89 c3                	mov    %eax,%ebx
  8017ef:	eb 05                	jmp    8017f6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017f1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017f6:	89 d8                	mov    %ebx,%eax
  8017f8:	83 c4 20             	add    $0x20,%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801805:	ba 00 00 00 00       	mov    $0x0,%edx
  80180a:	b8 08 00 00 00       	mov    $0x8,%eax
  80180f:	e8 08 fd ff ff       	call   80151c <fsipc>
}
  801814:	c9                   	leave  
  801815:	c3                   	ret    
	...

00801818 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	83 ec 10             	sub    $0x10,%esp
  801820:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	e8 06 f7 ff ff       	call   800f34 <fd2data>
  80182e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801830:	c7 44 24 04 d7 25 80 	movl   $0x8025d7,0x4(%esp)
  801837:	00 
  801838:	89 34 24             	mov    %esi,(%esp)
  80183b:	e8 cf ef ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801840:	8b 43 04             	mov    0x4(%ebx),%eax
  801843:	2b 03                	sub    (%ebx),%eax
  801845:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80184b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801852:	00 00 00 
	stat->st_dev = &devpipe;
  801855:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80185c:	30 80 00 
	return 0;
}
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	53                   	push   %ebx
  80186f:	83 ec 14             	sub    $0x14,%esp
  801872:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801875:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801879:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801880:	e8 23 f4 ff ff       	call   800ca8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801885:	89 1c 24             	mov    %ebx,(%esp)
  801888:	e8 a7 f6 ff ff       	call   800f34 <fd2data>
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801898:	e8 0b f4 ff ff       	call   800ca8 <sys_page_unmap>
}
  80189d:	83 c4 14             	add    $0x14,%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	57                   	push   %edi
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 2c             	sub    $0x2c,%esp
  8018ac:	89 c7                	mov    %eax,%edi
  8018ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018b6:	8b 00                	mov    (%eax),%eax
  8018b8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018bb:	89 3c 24             	mov    %edi,(%esp)
  8018be:	e8 89 05 00 00       	call   801e4c <pageref>
  8018c3:	89 c6                	mov    %eax,%esi
  8018c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c8:	89 04 24             	mov    %eax,(%esp)
  8018cb:	e8 7c 05 00 00       	call   801e4c <pageref>
  8018d0:	39 c6                	cmp    %eax,%esi
  8018d2:	0f 94 c0             	sete   %al
  8018d5:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018d8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018de:	8b 12                	mov    (%edx),%edx
  8018e0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018e3:	39 cb                	cmp    %ecx,%ebx
  8018e5:	75 08                	jne    8018ef <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018e7:	83 c4 2c             	add    $0x2c,%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5f                   	pop    %edi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018ef:	83 f8 01             	cmp    $0x1,%eax
  8018f2:	75 bd                	jne    8018b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f4:	8b 42 58             	mov    0x58(%edx),%eax
  8018f7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8018fe:	00 
  8018ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801903:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801907:	c7 04 24 de 25 80 00 	movl   $0x8025de,(%esp)
  80190e:	e8 51 e9 ff ff       	call   800264 <cprintf>
  801913:	eb 9c                	jmp    8018b1 <_pipeisclosed+0xe>

00801915 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	57                   	push   %edi
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	83 ec 1c             	sub    $0x1c,%esp
  80191e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801921:	89 34 24             	mov    %esi,(%esp)
  801924:	e8 0b f6 ff ff       	call   800f34 <fd2data>
  801929:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192b:	bf 00 00 00 00       	mov    $0x0,%edi
  801930:	eb 3c                	jmp    80196e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801932:	89 da                	mov    %ebx,%edx
  801934:	89 f0                	mov    %esi,%eax
  801936:	e8 68 ff ff ff       	call   8018a3 <_pipeisclosed>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	75 38                	jne    801977 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193f:	e8 9e f2 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801944:	8b 43 04             	mov    0x4(%ebx),%eax
  801947:	8b 13                	mov    (%ebx),%edx
  801949:	83 c2 20             	add    $0x20,%edx
  80194c:	39 d0                	cmp    %edx,%eax
  80194e:	73 e2                	jae    801932 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801950:	8b 55 0c             	mov    0xc(%ebp),%edx
  801953:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801956:	89 c2                	mov    %eax,%edx
  801958:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80195e:	79 05                	jns    801965 <devpipe_write+0x50>
  801960:	4a                   	dec    %edx
  801961:	83 ca e0             	or     $0xffffffe0,%edx
  801964:	42                   	inc    %edx
  801965:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801969:	40                   	inc    %eax
  80196a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80196d:	47                   	inc    %edi
  80196e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801971:	75 d1                	jne    801944 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801973:	89 f8                	mov    %edi,%eax
  801975:	eb 05                	jmp    80197c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80197c:	83 c4 1c             	add    $0x1c,%esp
  80197f:	5b                   	pop    %ebx
  801980:	5e                   	pop    %esi
  801981:	5f                   	pop    %edi
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	57                   	push   %edi
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
  80198a:	83 ec 1c             	sub    $0x1c,%esp
  80198d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801990:	89 3c 24             	mov    %edi,(%esp)
  801993:	e8 9c f5 ff ff       	call   800f34 <fd2data>
  801998:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199a:	be 00 00 00 00       	mov    $0x0,%esi
  80199f:	eb 3a                	jmp    8019db <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019a1:	85 f6                	test   %esi,%esi
  8019a3:	74 04                	je     8019a9 <devpipe_read+0x25>
				return i;
  8019a5:	89 f0                	mov    %esi,%eax
  8019a7:	eb 40                	jmp    8019e9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019a9:	89 da                	mov    %ebx,%edx
  8019ab:	89 f8                	mov    %edi,%eax
  8019ad:	e8 f1 fe ff ff       	call   8018a3 <_pipeisclosed>
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	75 2e                	jne    8019e4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019b6:	e8 27 f2 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019bb:	8b 03                	mov    (%ebx),%eax
  8019bd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019c0:	74 df                	je     8019a1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019c2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019c7:	79 05                	jns    8019ce <devpipe_read+0x4a>
  8019c9:	48                   	dec    %eax
  8019ca:	83 c8 e0             	or     $0xffffffe0,%eax
  8019cd:	40                   	inc    %eax
  8019ce:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019d8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019da:	46                   	inc    %esi
  8019db:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019de:	75 db                	jne    8019bb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019e0:	89 f0                	mov    %esi,%eax
  8019e2:	eb 05                	jmp    8019e9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019e9:	83 c4 1c             	add    $0x1c,%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5f                   	pop    %edi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	57                   	push   %edi
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 3c             	sub    $0x3c,%esp
  8019fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a00:	89 04 24             	mov    %eax,(%esp)
  801a03:	e8 47 f5 ff ff       	call   800f4f <fd_alloc>
  801a08:	89 c3                	mov    %eax,%ebx
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	0f 88 45 01 00 00    	js     801b57 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a19:	00 
  801a1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a28:	e8 d4 f1 ff ff       	call   800c01 <sys_page_alloc>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	0f 88 20 01 00 00    	js     801b57 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a37:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a3a:	89 04 24             	mov    %eax,(%esp)
  801a3d:	e8 0d f5 ff ff       	call   800f4f <fd_alloc>
  801a42:	89 c3                	mov    %eax,%ebx
  801a44:	85 c0                	test   %eax,%eax
  801a46:	0f 88 f8 00 00 00    	js     801b44 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a53:	00 
  801a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a62:	e8 9a f1 ff ff       	call   800c01 <sys_page_alloc>
  801a67:	89 c3                	mov    %eax,%ebx
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	0f 88 d3 00 00 00    	js     801b44 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a74:	89 04 24             	mov    %eax,(%esp)
  801a77:	e8 b8 f4 ff ff       	call   800f34 <fd2data>
  801a7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a85:	00 
  801a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a91:	e8 6b f1 ff ff       	call   800c01 <sys_page_alloc>
  801a96:	89 c3                	mov    %eax,%ebx
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	0f 88 91 00 00 00    	js     801b31 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801aa3:	89 04 24             	mov    %eax,(%esp)
  801aa6:	e8 89 f4 ff ff       	call   800f34 <fd2data>
  801aab:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ab2:	00 
  801ab3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801abe:	00 
  801abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aca:	e8 86 f1 ff ff       	call   800c55 <sys_page_map>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 4c                	js     801b21 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ad5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ade:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ae0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801aea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801af3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801af5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801af8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	e8 1a f4 ff ff       	call   800f24 <fd2num>
  801b0a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b0f:	89 04 24             	mov    %eax,(%esp)
  801b12:	e8 0d f4 ff ff       	call   800f24 <fd2num>
  801b17:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1f:	eb 36                	jmp    801b57 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801b21:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2c:	e8 77 f1 ff ff       	call   800ca8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801b31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3f:	e8 64 f1 ff ff       	call   800ca8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801b44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b52:	e8 51 f1 ff ff       	call   800ca8 <sys_page_unmap>
    err:
	return r;
}
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	83 c4 3c             	add    $0x3c,%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5f                   	pop    %edi
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	89 04 24             	mov    %eax,(%esp)
  801b74:	e8 29 f4 ff ff       	call   800fa2 <fd_lookup>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	78 15                	js     801b92 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	89 04 24             	mov    %eax,(%esp)
  801b83:	e8 ac f3 ff ff       	call   800f34 <fd2data>
	return _pipeisclosed(fd, p);
  801b88:	89 c2                	mov    %eax,%edx
  801b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8d:	e8 11 fd ff ff       	call   8018a3 <_pipeisclosed>
}
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ba4:	c7 44 24 04 f6 25 80 	movl   $0x8025f6,0x4(%esp)
  801bab:	00 
  801bac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801baf:	89 04 24             	mov    %eax,(%esp)
  801bb2:	e8 58 ec ff ff       	call   80080f <strcpy>
	return 0;
}
  801bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bcf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd5:	eb 30                	jmp    801c07 <devcons_write+0x49>
		m = n - tot;
  801bd7:	8b 75 10             	mov    0x10(%ebp),%esi
  801bda:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801bdc:	83 fe 7f             	cmp    $0x7f,%esi
  801bdf:	76 05                	jbe    801be6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801be1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801be6:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bea:	03 45 0c             	add    0xc(%ebp),%eax
  801bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf1:	89 3c 24             	mov    %edi,(%esp)
  801bf4:	e8 8f ed ff ff       	call   800988 <memmove>
		sys_cputs(buf, m);
  801bf9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bfd:	89 3c 24             	mov    %edi,(%esp)
  801c00:	e8 2f ef ff ff       	call   800b34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c05:	01 f3                	add    %esi,%ebx
  801c07:	89 d8                	mov    %ebx,%eax
  801c09:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c0c:	72 c9                	jb     801bd7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c0e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c23:	75 07                	jne    801c2c <devcons_read+0x13>
  801c25:	eb 25                	jmp    801c4c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c27:	e8 b6 ef ff ff       	call   800be2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c2c:	e8 21 ef ff ff       	call   800b52 <sys_cgetc>
  801c31:	85 c0                	test   %eax,%eax
  801c33:	74 f2                	je     801c27 <devcons_read+0xe>
  801c35:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c37:	85 c0                	test   %eax,%eax
  801c39:	78 1d                	js     801c58 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c3b:	83 f8 04             	cmp    $0x4,%eax
  801c3e:	74 13                	je     801c53 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c43:	88 10                	mov    %dl,(%eax)
	return 1;
  801c45:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4a:	eb 0c                	jmp    801c58 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c51:	eb 05                	jmp    801c58 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c53:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c66:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c6d:	00 
  801c6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c71:	89 04 24             	mov    %eax,(%esp)
  801c74:	e8 bb ee ff ff       	call   800b34 <sys_cputs>
}
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <getchar>:

int
getchar(void)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c81:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c88:	00 
  801c89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c97:	e8 a4 f5 ff ff       	call   801240 <read>
	if (r < 0)
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 0f                	js     801caf <getchar+0x34>
		return r;
	if (r < 1)
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	7e 06                	jle    801caa <getchar+0x2f>
		return -E_EOF;
	return c;
  801ca4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ca8:	eb 05                	jmp    801caf <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801caa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc1:	89 04 24             	mov    %eax,(%esp)
  801cc4:	e8 d9 f2 ff ff       	call   800fa2 <fd_lookup>
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 11                	js     801cde <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd6:	39 10                	cmp    %edx,(%eax)
  801cd8:	0f 94 c0             	sete   %al
  801cdb:	0f b6 c0             	movzbl %al,%eax
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <opencons>:

int
opencons(void)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce9:	89 04 24             	mov    %eax,(%esp)
  801cec:	e8 5e f2 ff ff       	call   800f4f <fd_alloc>
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	78 3c                	js     801d31 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cfc:	00 
  801cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0b:	e8 f1 ee ff ff       	call   800c01 <sys_page_alloc>
  801d10:	85 c0                	test   %eax,%eax
  801d12:	78 1d                	js     801d31 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d14:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d29:	89 04 24             	mov    %eax,(%esp)
  801d2c:	e8 f3 f1 ff ff       	call   800f24 <fd2num>
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    
	...

00801d34 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	56                   	push   %esi
  801d38:	53                   	push   %ebx
  801d39:	83 ec 10             	sub    $0x10,%esp
  801d3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d42:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801d45:	85 c0                	test   %eax,%eax
  801d47:	75 05                	jne    801d4e <ipc_recv+0x1a>
  801d49:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801d4e:	89 04 24             	mov    %eax,(%esp)
  801d51:	e8 c1 f0 ff ff       	call   800e17 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801d56:	85 c0                	test   %eax,%eax
  801d58:	79 16                	jns    801d70 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801d5a:	85 db                	test   %ebx,%ebx
  801d5c:	74 06                	je     801d64 <ipc_recv+0x30>
  801d5e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801d64:	85 f6                	test   %esi,%esi
  801d66:	74 32                	je     801d9a <ipc_recv+0x66>
  801d68:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801d6e:	eb 2a                	jmp    801d9a <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801d70:	85 db                	test   %ebx,%ebx
  801d72:	74 0c                	je     801d80 <ipc_recv+0x4c>
  801d74:	a1 04 40 80 00       	mov    0x804004,%eax
  801d79:	8b 00                	mov    (%eax),%eax
  801d7b:	8b 40 74             	mov    0x74(%eax),%eax
  801d7e:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d80:	85 f6                	test   %esi,%esi
  801d82:	74 0c                	je     801d90 <ipc_recv+0x5c>
  801d84:	a1 04 40 80 00       	mov    0x804004,%eax
  801d89:	8b 00                	mov    (%eax),%eax
  801d8b:	8b 40 78             	mov    0x78(%eax),%eax
  801d8e:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801d90:	a1 04 40 80 00       	mov    0x804004,%eax
  801d95:	8b 00                	mov    (%eax),%eax
  801d97:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    

00801da1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	57                   	push   %edi
  801da5:	56                   	push   %esi
  801da6:	53                   	push   %ebx
  801da7:	83 ec 1c             	sub    $0x1c,%esp
  801daa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801db3:	85 db                	test   %ebx,%ebx
  801db5:	75 05                	jne    801dbc <ipc_send+0x1b>
  801db7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801dbc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dc0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	89 04 24             	mov    %eax,(%esp)
  801dce:	e8 21 f0 ff ff       	call   800df4 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801dd3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dd6:	75 07                	jne    801ddf <ipc_send+0x3e>
  801dd8:	e8 05 ee ff ff       	call   800be2 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801ddd:	eb dd                	jmp    801dbc <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	79 1c                	jns    801dff <ipc_send+0x5e>
  801de3:	c7 44 24 08 02 26 80 	movl   $0x802602,0x8(%esp)
  801dea:	00 
  801deb:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801df2:	00 
  801df3:	c7 04 24 14 26 80 00 	movl   $0x802614,(%esp)
  801dfa:	e8 6d e3 ff ff       	call   80016c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801dff:	83 c4 1c             	add    $0x1c,%esp
  801e02:	5b                   	pop    %ebx
  801e03:	5e                   	pop    %esi
  801e04:	5f                   	pop    %edi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	53                   	push   %ebx
  801e0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801e0e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e13:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	c1 e2 07             	shl    $0x7,%edx
  801e1f:	29 ca                	sub    %ecx,%edx
  801e21:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e27:	8b 52 50             	mov    0x50(%edx),%edx
  801e2a:	39 da                	cmp    %ebx,%edx
  801e2c:	75 0f                	jne    801e3d <ipc_find_env+0x36>
			return envs[i].env_id;
  801e2e:	c1 e0 07             	shl    $0x7,%eax
  801e31:	29 c8                	sub    %ecx,%eax
  801e33:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e38:	8b 40 40             	mov    0x40(%eax),%eax
  801e3b:	eb 0c                	jmp    801e49 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e3d:	40                   	inc    %eax
  801e3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e43:	75 ce                	jne    801e13 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e45:	66 b8 00 00          	mov    $0x0,%ax
}
  801e49:	5b                   	pop    %ebx
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801e52:	89 c2                	mov    %eax,%edx
  801e54:	c1 ea 16             	shr    $0x16,%edx
  801e57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e5e:	f6 c2 01             	test   $0x1,%dl
  801e61:	74 1e                	je     801e81 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e63:	c1 e8 0c             	shr    $0xc,%eax
  801e66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e6d:	a8 01                	test   $0x1,%al
  801e6f:	74 17                	je     801e88 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e71:	c1 e8 0c             	shr    $0xc,%eax
  801e74:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e7b:	ef 
  801e7c:	0f b7 c0             	movzwl %ax,%eax
  801e7f:	eb 0c                	jmp    801e8d <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e81:	b8 00 00 00 00       	mov    $0x0,%eax
  801e86:	eb 05                	jmp    801e8d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    
	...

00801e90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e90:	55                   	push   %ebp
  801e91:	57                   	push   %edi
  801e92:	56                   	push   %esi
  801e93:	83 ec 10             	sub    $0x10,%esp
  801e96:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e9a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801ea6:	89 cd                	mov    %ecx,%ebp
  801ea8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801eac:	85 c0                	test   %eax,%eax
  801eae:	75 2c                	jne    801edc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801eb0:	39 f9                	cmp    %edi,%ecx
  801eb2:	77 68                	ja     801f1c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801eb4:	85 c9                	test   %ecx,%ecx
  801eb6:	75 0b                	jne    801ec3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801eb8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebd:	31 d2                	xor    %edx,%edx
  801ebf:	f7 f1                	div    %ecx
  801ec1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ec3:	31 d2                	xor    %edx,%edx
  801ec5:	89 f8                	mov    %edi,%eax
  801ec7:	f7 f1                	div    %ecx
  801ec9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ecb:	89 f0                	mov    %esi,%eax
  801ecd:	f7 f1                	div    %ecx
  801ecf:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ed1:	89 f0                	mov    %esi,%eax
  801ed3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	5e                   	pop    %esi
  801ed9:	5f                   	pop    %edi
  801eda:	5d                   	pop    %ebp
  801edb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801edc:	39 f8                	cmp    %edi,%eax
  801ede:	77 2c                	ja     801f0c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ee0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801ee3:	83 f6 1f             	xor    $0x1f,%esi
  801ee6:	75 4c                	jne    801f34 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ee8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801eea:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801eef:	72 0a                	jb     801efb <__udivdi3+0x6b>
  801ef1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ef5:	0f 87 ad 00 00 00    	ja     801fa8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801efb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f00:	89 f0                	mov    %esi,%eax
  801f02:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	5e                   	pop    %esi
  801f08:	5f                   	pop    %edi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
  801f0b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f0c:	31 ff                	xor    %edi,%edi
  801f0e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f10:	89 f0                	mov    %esi,%eax
  801f12:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	5e                   	pop    %esi
  801f18:	5f                   	pop    %edi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    
  801f1b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f1c:	89 fa                	mov    %edi,%edx
  801f1e:	89 f0                	mov    %esi,%eax
  801f20:	f7 f1                	div    %ecx
  801f22:	89 c6                	mov    %eax,%esi
  801f24:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f26:	89 f0                	mov    %esi,%eax
  801f28:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	5e                   	pop    %esi
  801f2e:	5f                   	pop    %edi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    
  801f31:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f34:	89 f1                	mov    %esi,%ecx
  801f36:	d3 e0                	shl    %cl,%eax
  801f38:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f3c:	b8 20 00 00 00       	mov    $0x20,%eax
  801f41:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801f43:	89 ea                	mov    %ebp,%edx
  801f45:	88 c1                	mov    %al,%cl
  801f47:	d3 ea                	shr    %cl,%edx
  801f49:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801f4d:	09 ca                	or     %ecx,%edx
  801f4f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801f53:	89 f1                	mov    %esi,%ecx
  801f55:	d3 e5                	shl    %cl,%ebp
  801f57:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801f5b:	89 fd                	mov    %edi,%ebp
  801f5d:	88 c1                	mov    %al,%cl
  801f5f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801f61:	89 fa                	mov    %edi,%edx
  801f63:	89 f1                	mov    %esi,%ecx
  801f65:	d3 e2                	shl    %cl,%edx
  801f67:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f6b:	88 c1                	mov    %al,%cl
  801f6d:	d3 ef                	shr    %cl,%edi
  801f6f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f71:	89 f8                	mov    %edi,%eax
  801f73:	89 ea                	mov    %ebp,%edx
  801f75:	f7 74 24 08          	divl   0x8(%esp)
  801f79:	89 d1                	mov    %edx,%ecx
  801f7b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801f7d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f81:	39 d1                	cmp    %edx,%ecx
  801f83:	72 17                	jb     801f9c <__udivdi3+0x10c>
  801f85:	74 09                	je     801f90 <__udivdi3+0x100>
  801f87:	89 fe                	mov    %edi,%esi
  801f89:	31 ff                	xor    %edi,%edi
  801f8b:	e9 41 ff ff ff       	jmp    801ed1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f90:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f94:	89 f1                	mov    %esi,%ecx
  801f96:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f98:	39 c2                	cmp    %eax,%edx
  801f9a:	73 eb                	jae    801f87 <__udivdi3+0xf7>
		{
		  q0--;
  801f9c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f9f:	31 ff                	xor    %edi,%edi
  801fa1:	e9 2b ff ff ff       	jmp    801ed1 <__udivdi3+0x41>
  801fa6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fa8:	31 f6                	xor    %esi,%esi
  801faa:	e9 22 ff ff ff       	jmp    801ed1 <__udivdi3+0x41>
	...

00801fb0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	83 ec 20             	sub    $0x20,%esp
  801fb6:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fba:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fbe:	89 44 24 14          	mov    %eax,0x14(%esp)
  801fc2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801fc6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fca:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801fce:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801fd0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fd2:	85 ed                	test   %ebp,%ebp
  801fd4:	75 16                	jne    801fec <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801fd6:	39 f1                	cmp    %esi,%ecx
  801fd8:	0f 86 a6 00 00 00    	jbe    802084 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fde:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801fe0:	89 d0                	mov    %edx,%eax
  801fe2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fe4:	83 c4 20             	add    $0x20,%esp
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    
  801feb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fec:	39 f5                	cmp    %esi,%ebp
  801fee:	0f 87 ac 00 00 00    	ja     8020a0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ff4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801ff7:	83 f0 1f             	xor    $0x1f,%eax
  801ffa:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ffe:	0f 84 a8 00 00 00    	je     8020ac <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802004:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802008:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80200a:	bf 20 00 00 00       	mov    $0x20,%edi
  80200f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802013:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802017:	89 f9                	mov    %edi,%ecx
  802019:	d3 e8                	shr    %cl,%eax
  80201b:	09 e8                	or     %ebp,%eax
  80201d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802021:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802025:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802029:	d3 e0                	shl    %cl,%eax
  80202b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80202f:	89 f2                	mov    %esi,%edx
  802031:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802033:	8b 44 24 14          	mov    0x14(%esp),%eax
  802037:	d3 e0                	shl    %cl,%eax
  802039:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80203d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e8                	shr    %cl,%eax
  802045:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802047:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802049:	89 f2                	mov    %esi,%edx
  80204b:	f7 74 24 18          	divl   0x18(%esp)
  80204f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802051:	f7 64 24 0c          	mull   0xc(%esp)
  802055:	89 c5                	mov    %eax,%ebp
  802057:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802059:	39 d6                	cmp    %edx,%esi
  80205b:	72 67                	jb     8020c4 <__umoddi3+0x114>
  80205d:	74 75                	je     8020d4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80205f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802063:	29 e8                	sub    %ebp,%eax
  802065:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802067:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	89 f2                	mov    %esi,%edx
  80206f:	89 f9                	mov    %edi,%ecx
  802071:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802073:	09 d0                	or     %edx,%eax
  802075:	89 f2                	mov    %esi,%edx
  802077:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80207b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80207d:	83 c4 20             	add    $0x20,%esp
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802084:	85 c9                	test   %ecx,%ecx
  802086:	75 0b                	jne    802093 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802088:	b8 01 00 00 00       	mov    $0x1,%eax
  80208d:	31 d2                	xor    %edx,%edx
  80208f:	f7 f1                	div    %ecx
  802091:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802093:	89 f0                	mov    %esi,%eax
  802095:	31 d2                	xor    %edx,%edx
  802097:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802099:	89 f8                	mov    %edi,%eax
  80209b:	e9 3e ff ff ff       	jmp    801fde <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8020a0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020a2:	83 c4 20             	add    $0x20,%esp
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020ac:	39 f5                	cmp    %esi,%ebp
  8020ae:	72 04                	jb     8020b4 <__umoddi3+0x104>
  8020b0:	39 f9                	cmp    %edi,%ecx
  8020b2:	77 06                	ja     8020ba <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020b4:	89 f2                	mov    %esi,%edx
  8020b6:	29 cf                	sub    %ecx,%edi
  8020b8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8020ba:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020bc:	83 c4 20             	add    $0x20,%esp
  8020bf:	5e                   	pop    %esi
  8020c0:	5f                   	pop    %edi
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    
  8020c3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020c4:	89 d1                	mov    %edx,%ecx
  8020c6:	89 c5                	mov    %eax,%ebp
  8020c8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8020cc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8020d0:	eb 8d                	jmp    80205f <__umoddi3+0xaf>
  8020d2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020d4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8020d8:	72 ea                	jb     8020c4 <__umoddi3+0x114>
  8020da:	89 f1                	mov    %esi,%ecx
  8020dc:	eb 81                	jmp    80205f <__umoddi3+0xaf>
