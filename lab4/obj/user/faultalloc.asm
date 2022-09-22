
obj/user/faultalloc:     file format elf32-i386


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
  800044:	c7 04 24 40 11 80 00 	movl   $0x801140,(%esp)
  80004b:	e8 1c 02 00 00       	call   80026c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 9a 0b 00 00       	call   800c09 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 60 11 80 	movl   $0x801160,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 4a 11 80 00 	movl   $0x80114a,(%esp)
  800092:	e8 dd 00 00 00       	call   800174 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 8c 11 80 	movl   $0x80118c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 06 07 00 00       	call   8007b9 <snprintf>
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
  8000c6:	e8 55 0d 00 00       	call   800e20 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 5c 11 80 00 	movl   $0x80115c,(%esp)
  8000da:	e8 8d 01 00 00       	call   80026c <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 5c 11 80 00 	movl   $0x80115c,(%esp)
  8000ee:	e8 79 01 00 00       	call   80026c <cprintf>
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
  800106:	e8 c0 0a 00 00       	call   800bcb <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800127:	a3 04 20 80 00       	mov    %eax,0x802004
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800130:	c7 04 24 46 11 80 00 	movl   $0x801146,(%esp)
  800137:	e8 30 01 00 00       	call   80026c <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013c:	85 f6                	test   %esi,%esi
  80013e:	7e 07                	jle    800147 <libmain+0x4f>
		binaryname = argv[0];
  800140:	8b 03                	mov    (%ebx),%eax
  800142:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800147:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80014b:	89 34 24             	mov    %esi,(%esp)
  80014e:	e8 66 ff ff ff       	call   8000b9 <umain>

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
	sys_env_destroy(0);
  800166:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016d:	e8 07 0a 00 00       	call   800b79 <sys_env_destroy>
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80017c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800185:	e8 41 0a 00 00       	call   800bcb <sys_getenvid>
  80018a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800191:	8b 55 08             	mov    0x8(%ebp),%edx
  800194:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800198:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a0:	c7 04 24 b8 11 80 00 	movl   $0x8011b8,(%esp)
  8001a7:	e8 c0 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 50 00 00 00       	call   80020b <vcprintf>
	cprintf("\n");
  8001bb:	c7 04 24 5e 11 80 00 	movl   $0x80115e,(%esp)
  8001c2:	e8 a5 00 00 00       	call   80026c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c7:	cc                   	int3   
  8001c8:	eb fd                	jmp    8001c7 <_panic+0x53>
	...

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 14             	sub    $0x14,%esp
  8001d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d6:	8b 03                	mov    (%ebx),%eax
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001df:	40                   	inc    %eax
  8001e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e7:	75 19                	jne    800202 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f0:	00 
  8001f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 40 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  8001fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800202:	ff 43 04             	incl   0x4(%ebx)
}
  800205:	83 c4 14             	add    $0x14,%esp
  800208:	5b                   	pop    %ebx
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800214:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021b:	00 00 00 
	b.cnt = 0;
  80021e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800225:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022f:	8b 45 08             	mov    0x8(%ebp),%eax
  800232:	89 44 24 08          	mov    %eax,0x8(%esp)
  800236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	c7 04 24 cc 01 80 00 	movl   $0x8001cc,(%esp)
  800247:	e8 82 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 d8 08 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	8b 45 08             	mov    0x8(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 87 ff ff ff       	call   80020b <vcprintf>
	va_end(ap);

	return cnt;
}
  800284:	c9                   	leave  
  800285:	c3                   	ret    
	...

00800288 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 3c             	sub    $0x3c,%esp
  800291:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800294:	89 d7                	mov    %edx,%edi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	75 08                	jne    8002b4 <printnum+0x2c>
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b2:	77 57                	ja     80030b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b8:	4b                   	dec    %ebx
  8002b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d3:	00 
  8002d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	e8 f2 0b 00 00       	call   800ed8 <__udivdi3>
  8002e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 fa                	mov    %edi,%edx
  8002f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fa:	e8 89 ff ff ff       	call   800288 <printnum>
  8002ff:	eb 0f                	jmp    800310 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	89 34 24             	mov    %esi,(%esp)
  800308:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030b:	4b                   	dec    %ebx
  80030c:	85 db                	test   %ebx,%ebx
  80030e:	7f f1                	jg     800301 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800310:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800314:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800318:	8b 45 10             	mov    0x10(%ebp),%eax
  80031b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800326:	00 
  800327:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800330:	89 44 24 04          	mov    %eax,0x4(%esp)
  800334:	e8 bf 0c 00 00       	call   800ff8 <__umoddi3>
  800339:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033d:	0f be 80 db 11 80 00 	movsbl 0x8011db(%eax),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034a:	83 c4 3c             	add    $0x3c,%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800355:	83 fa 01             	cmp    $0x1,%edx
  800358:	7e 0e                	jle    800368 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	8b 52 04             	mov    0x4(%edx),%edx
  800366:	eb 22                	jmp    80038a <getuint+0x38>
	else if (lflag)
  800368:	85 d2                	test   %edx,%edx
  80036a:	74 10                	je     80037c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
  80037a:	eb 0e                	jmp    80038a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800392:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800395:	8b 10                	mov    (%eax),%edx
  800397:	3b 50 04             	cmp    0x4(%eax),%edx
  80039a:	73 08                	jae    8003a4 <sprintputch+0x18>
		*b->buf++ = ch;
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	88 0a                	mov    %cl,(%edx)
  8003a1:	42                   	inc    %edx
  8003a2:	89 10                	mov    %edx,(%eax)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 02 00 00 00       	call   8003ce <vprintfmt>
	va_end(ap);
}
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 4c             	sub    $0x4c,%esp
  8003d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003da:	8b 75 10             	mov    0x10(%ebp),%esi
  8003dd:	eb 12                	jmp    8003f1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	0f 84 6b 03 00 00    	je     800752 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f1:	0f b6 06             	movzbl (%esi),%eax
  8003f4:	46                   	inc    %esi
  8003f5:	83 f8 25             	cmp    $0x25,%eax
  8003f8:	75 e5                	jne    8003df <vprintfmt+0x11>
  8003fa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800405:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800411:	b9 00 00 00 00       	mov    $0x0,%ecx
  800416:	eb 26                	jmp    80043e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041f:	eb 1d                	jmp    80043e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800424:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800428:	eb 14                	jmp    80043e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80042d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800434:	eb 08                	jmp    80043e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800436:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800439:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	0f b6 06             	movzbl (%esi),%eax
  800441:	8d 56 01             	lea    0x1(%esi),%edx
  800444:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800447:	8a 16                	mov    (%esi),%dl
  800449:	83 ea 23             	sub    $0x23,%edx
  80044c:	80 fa 55             	cmp    $0x55,%dl
  80044f:	0f 87 e1 02 00 00    	ja     800736 <vprintfmt+0x368>
  800455:	0f b6 d2             	movzbl %dl,%edx
  800458:	ff 24 95 a0 12 80 00 	jmp    *0x8012a0(,%edx,4)
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800462:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800467:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800471:	8d 50 d0             	lea    -0x30(%eax),%edx
  800474:	83 fa 09             	cmp    $0x9,%edx
  800477:	77 2a                	ja     8004a3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800479:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047a:	eb eb                	jmp    800467 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048a:	eb 17                	jmp    8004a3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80048c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800490:	78 98                	js     80042a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800495:	eb a7                	jmp    80043e <vprintfmt+0x70>
  800497:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a1:	eb 9b                	jmp    80043e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a7:	79 95                	jns    80043e <vprintfmt+0x70>
  8004a9:	eb 8b                	jmp    800436 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ab:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004af:	eb 8d                	jmp    80043e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 04 24             	mov    %eax,(%esp)
  8004c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c9:	e9 23 ff ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	79 02                	jns    8004df <vprintfmt+0x111>
  8004dd:	f7 d8                	neg    %eax
  8004df:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e1:	83 f8 08             	cmp    $0x8,%eax
  8004e4:	7f 0b                	jg     8004f1 <vprintfmt+0x123>
  8004e6:	8b 04 85 00 14 80 00 	mov    0x801400(,%eax,4),%eax
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	75 23                	jne    800514 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f5:	c7 44 24 08 f3 11 80 	movl   $0x8011f3,0x8(%esp)
  8004fc:	00 
  8004fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800501:	8b 45 08             	mov    0x8(%ebp),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	e8 9a fe ff ff       	call   8003a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050f:	e9 dd fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800514:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800518:	c7 44 24 08 fc 11 80 	movl   $0x8011fc,0x8(%esp)
  80051f:	00 
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	8b 55 08             	mov    0x8(%ebp),%edx
  800527:	89 14 24             	mov    %edx,(%esp)
  80052a:	e8 77 fe ff ff       	call   8003a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800532:	e9 ba fe ff ff       	jmp    8003f1 <vprintfmt+0x23>
  800537:	89 f9                	mov    %edi,%ecx
  800539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 30                	mov    (%eax),%esi
  80054a:	85 f6                	test   %esi,%esi
  80054c:	75 05                	jne    800553 <vprintfmt+0x185>
				p = "(null)";
  80054e:	be ec 11 80 00       	mov    $0x8011ec,%esi
			if (width > 0 && padc != '-')
  800553:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800557:	0f 8e 84 00 00 00    	jle    8005e1 <vprintfmt+0x213>
  80055d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800561:	74 7e                	je     8005e1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800567:	89 34 24             	mov    %esi,(%esp)
  80056a:	e8 8b 02 00 00       	call   8007fa <strnlen>
  80056f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800572:	29 c2                	sub    %eax,%edx
  800574:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800577:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80057b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80057e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800581:	89 de                	mov    %ebx,%esi
  800583:	89 d3                	mov    %edx,%ebx
  800585:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	eb 0b                	jmp    800594 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800589:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058d:	89 3c 24             	mov    %edi,(%esp)
  800590:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	4b                   	dec    %ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f f1                	jg     800589 <vprintfmt+0x1bb>
  800598:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059b:	89 f3                	mov    %esi,%ebx
  80059d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	79 05                	jns    8005ac <vprintfmt+0x1de>
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005af:	29 c2                	sub    %eax,%edx
  8005b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b4:	eb 2b                	jmp    8005e1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ba:	74 18                	je     8005d4 <vprintfmt+0x206>
  8005bc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005bf:	83 fa 5e             	cmp    $0x5e,%edx
  8005c2:	76 10                	jbe    8005d4 <vprintfmt+0x206>
					putch('?', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
  8005d2:	eb 0a                	jmp    8005de <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005de:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e1:	0f be 06             	movsbl (%esi),%eax
  8005e4:	46                   	inc    %esi
  8005e5:	85 c0                	test   %eax,%eax
  8005e7:	74 21                	je     80060a <vprintfmt+0x23c>
  8005e9:	85 ff                	test   %edi,%edi
  8005eb:	78 c9                	js     8005b6 <vprintfmt+0x1e8>
  8005ed:	4f                   	dec    %edi
  8005ee:	79 c6                	jns    8005b6 <vprintfmt+0x1e8>
  8005f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f3:	89 de                	mov    %ebx,%esi
  8005f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f8:	eb 18                	jmp    800612 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800605:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800607:	4b                   	dec    %ebx
  800608:	eb 08                	jmp    800612 <vprintfmt+0x244>
  80060a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80060d:	89 de                	mov    %ebx,%esi
  80060f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800612:	85 db                	test   %ebx,%ebx
  800614:	7f e4                	jg     8005fa <vprintfmt+0x22c>
  800616:	89 7d 08             	mov    %edi,0x8(%ebp)
  800619:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061e:	e9 ce fd ff ff       	jmp    8003f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 10                	jle    800638 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 08             	lea    0x8(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 30                	mov    (%eax),%esi
  800633:	8b 78 04             	mov    0x4(%eax),%edi
  800636:	eb 26                	jmp    80065e <vprintfmt+0x290>
	else if (lflag)
  800638:	85 c9                	test   %ecx,%ecx
  80063a:	74 12                	je     80064e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 30                	mov    (%eax),%esi
  800647:	89 f7                	mov    %esi,%edi
  800649:	c1 ff 1f             	sar    $0x1f,%edi
  80064c:	eb 10                	jmp    80065e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 30                	mov    (%eax),%esi
  800659:	89 f7                	mov    %esi,%edi
  80065b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065e:	85 ff                	test   %edi,%edi
  800660:	78 0a                	js     80066c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800662:	b8 0a 00 00 00       	mov    $0xa,%eax
  800667:	e9 8c 00 00 00       	jmp    8006f8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80066c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800670:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067a:	f7 de                	neg    %esi
  80067c:	83 d7 00             	adc    $0x0,%edi
  80067f:	f7 df                	neg    %edi
			}
			base = 10;
  800681:	b8 0a 00 00 00       	mov    $0xa,%eax
  800686:	eb 70                	jmp    8006f8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800688:	89 ca                	mov    %ecx,%edx
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 c0 fc ff ff       	call   800352 <getuint>
  800692:	89 c6                	mov    %eax,%esi
  800694:	89 d7                	mov    %edx,%edi
			base = 10;
  800696:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069b:	eb 5b                	jmp    8006f8 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80069d:	89 ca                	mov    %ecx,%edx
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 ab fc ff ff       	call   800352 <getuint>
  8006a7:	89 c6                	mov    %eax,%esi
  8006a9:	89 d7                	mov    %edx,%edi
			base = 8;
  8006ab:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006b0:	eb 46                	jmp    8006f8 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 04             	lea    0x4(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d7:	8b 30                	mov    (%eax),%esi
  8006d9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e3:	eb 13                	jmp    8006f8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	89 ca                	mov    %ecx,%edx
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 63 fc ff ff       	call   800352 <getuint>
  8006ef:	89 c6                	mov    %eax,%esi
  8006f1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800700:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800703:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800707:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070b:	89 34 24             	mov    %esi,(%esp)
  80070e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800712:	89 da                	mov    %ebx,%edx
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	e8 6c fb ff ff       	call   800288 <printnum>
			break;
  80071c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071f:	e9 cd fc ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800731:	e9 bb fc ff ff       	jmp    8003f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800744:	eb 01                	jmp    800747 <vprintfmt+0x379>
  800746:	4e                   	dec    %esi
  800747:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074b:	75 f9                	jne    800746 <vprintfmt+0x378>
  80074d:	e9 9f fc ff ff       	jmp    8003f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800752:	83 c4 4c             	add    $0x4c,%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 28             	sub    $0x28,%esp
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800769:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800777:	85 c0                	test   %eax,%eax
  800779:	74 30                	je     8007ab <vsnprintf+0x51>
  80077b:	85 d2                	test   %edx,%edx
  80077d:	7e 33                	jle    8007b2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800786:	8b 45 10             	mov    0x10(%ebp),%eax
  800789:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800790:	89 44 24 04          	mov    %eax,0x4(%esp)
  800794:	c7 04 24 8c 03 80 00 	movl   $0x80038c,(%esp)
  80079b:	e8 2e fc ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	eb 0c                	jmp    8007b7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b0:	eb 05                	jmp    8007b7 <vsnprintf+0x5d>
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	e8 7b ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
  8007e1:	00 00                	add    %al,(%eax)
	...

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	eb 01                	jmp    8007f2 <strlen+0xe>
		n++;
  8007f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f6:	75 f9                	jne    8007f1 <strlen+0xd>
		n++;
	return n;
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 01                	jmp    80080b <strnlen+0x11>
		n++;
  80080a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 d0                	cmp    %edx,%eax
  80080d:	74 06                	je     800815 <strnlen+0x1b>
  80080f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800813:	75 f5                	jne    80080a <strnlen+0x10>
		n++;
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800829:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80082c:	42                   	inc    %edx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 f5                	jne    800826 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	89 1c 24             	mov    %ebx,(%esp)
  800841:	e8 9e ff ff ff       	call   8007e4 <strlen>
	strcpy(dst + len, src);
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 c0 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  800857:	89 d8                	mov    %ebx,%eax
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	eb 0c                	jmp    800880 <strncpy+0x21>
		*dst++ = *src;
  800874:	8a 1a                	mov    (%edx),%bl
  800876:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800879:	80 3a 01             	cmpb   $0x1,(%edx)
  80087c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087f:	41                   	inc    %ecx
  800880:	39 f1                	cmp    %esi,%ecx
  800882:	75 f0                	jne    800874 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	8b 75 08             	mov    0x8(%ebp),%esi
  800890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800893:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800896:	85 d2                	test   %edx,%edx
  800898:	75 0a                	jne    8008a4 <strlcpy+0x1c>
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	eb 1a                	jmp    8008b8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089e:	88 18                	mov    %bl,(%eax)
  8008a0:	40                   	inc    %eax
  8008a1:	41                   	inc    %ecx
  8008a2:	eb 02                	jmp    8008a6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008a6:	4a                   	dec    %edx
  8008a7:	74 0a                	je     8008b3 <strlcpy+0x2b>
  8008a9:	8a 19                	mov    (%ecx),%bl
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	75 ef                	jne    80089e <strlcpy+0x16>
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	eb 02                	jmp    8008b5 <strlcpy+0x2d>
  8008b3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b8:	29 f0                	sub    %esi,%eax
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c7:	eb 02                	jmp    8008cb <strcmp+0xd>
		p++, q++;
  8008c9:	41                   	inc    %ecx
  8008ca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cb:	8a 01                	mov    (%ecx),%al
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 04                	je     8008d5 <strcmp+0x17>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	74 f4                	je     8008c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d5:	0f b6 c0             	movzbl %al,%eax
  8008d8:	0f b6 12             	movzbl (%edx),%edx
  8008db:	29 d0                	sub    %edx,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008ec:	eb 03                	jmp    8008f1 <strncmp+0x12>
		n--, p++, q++;
  8008ee:	4a                   	dec    %edx
  8008ef:	40                   	inc    %eax
  8008f0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	74 14                	je     800909 <strncmp+0x2a>
  8008f5:	8a 18                	mov    (%eax),%bl
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	74 04                	je     8008ff <strncmp+0x20>
  8008fb:	3a 19                	cmp    (%ecx),%bl
  8008fd:	74 ef                	je     8008ee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 00             	movzbl (%eax),%eax
  800902:	0f b6 11             	movzbl (%ecx),%edx
  800905:	29 d0                	sub    %edx,%eax
  800907:	eb 05                	jmp    80090e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091a:	eb 05                	jmp    800921 <strchr+0x10>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 0c                	je     80092c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800920:	40                   	inc    %eax
  800921:	8a 10                	mov    (%eax),%dl
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f5                	jne    80091c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800937:	eb 05                	jmp    80093e <strfind+0x10>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 07                	je     800944 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093d:	40                   	inc    %eax
  80093e:	8a 10                	mov    (%eax),%dl
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f5                	jne    800939 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	57                   	push   %edi
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800955:	85 c9                	test   %ecx,%ecx
  800957:	74 30                	je     800989 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800959:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095f:	75 25                	jne    800986 <memset+0x40>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 20                	jne    800986 <memset+0x40>
		c &= 0xFF;
  800966:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800969:	89 d3                	mov    %edx,%ebx
  80096b:	c1 e3 08             	shl    $0x8,%ebx
  80096e:	89 d6                	mov    %edx,%esi
  800970:	c1 e6 18             	shl    $0x18,%esi
  800973:	89 d0                	mov    %edx,%eax
  800975:	c1 e0 10             	shl    $0x10,%eax
  800978:	09 f0                	or     %esi,%eax
  80097a:	09 d0                	or     %edx,%eax
  80097c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800981:	fc                   	cld    
  800982:	f3 ab                	rep stos %eax,%es:(%edi)
  800984:	eb 03                	jmp    800989 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800986:	fc                   	cld    
  800987:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800989:	89 f8                	mov    %edi,%eax
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099e:	39 c6                	cmp    %eax,%esi
  8009a0:	73 34                	jae    8009d6 <memmove+0x46>
  8009a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a5:	39 d0                	cmp    %edx,%eax
  8009a7:	73 2d                	jae    8009d6 <memmove+0x46>
		s += n;
		d += n;
  8009a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	f6 c2 03             	test   $0x3,%dl
  8009af:	75 1b                	jne    8009cc <memmove+0x3c>
  8009b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b7:	75 13                	jne    8009cc <memmove+0x3c>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 0e                	jne    8009cc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 07                	jmp    8009d3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cc:	4f                   	dec    %edi
  8009cd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d0:	fd                   	std    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d3:	fc                   	cld    
  8009d4:	eb 20                	jmp    8009f6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009dc:	75 13                	jne    8009f1 <memmove+0x61>
  8009de:	a8 03                	test   $0x3,%al
  8009e0:	75 0f                	jne    8009f1 <memmove+0x61>
  8009e2:	f6 c1 03             	test   $0x3,%cl
  8009e5:	75 0a                	jne    8009f1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ea:	89 c7                	mov    %eax,%edi
  8009ec:	fc                   	cld    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 05                	jmp    8009f6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
  800a03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	89 04 24             	mov    %eax,(%esp)
  800a14:	e8 77 ff ff ff       	call   800990 <memmove>
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	eb 16                	jmp    800a47 <memcmp+0x2c>
		if (*s1 != *s2)
  800a31:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a34:	42                   	inc    %edx
  800a35:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a39:	38 c8                	cmp    %cl,%al
  800a3b:	74 0a                	je     800a47 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a3d:	0f b6 c0             	movzbl %al,%eax
  800a40:	0f b6 c9             	movzbl %cl,%ecx
  800a43:	29 c8                	sub    %ecx,%eax
  800a45:	eb 09                	jmp    800a50 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a47:	39 da                	cmp    %ebx,%edx
  800a49:	75 e6                	jne    800a31 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a63:	eb 05                	jmp    800a6a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a65:	38 08                	cmp    %cl,(%eax)
  800a67:	74 05                	je     800a6e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a69:	40                   	inc    %eax
  800a6a:	39 d0                	cmp    %edx,%eax
  800a6c:	72 f7                	jb     800a65 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 01                	jmp    800a7f <strtol+0xf>
		s++;
  800a7e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7f:	8a 02                	mov    (%edx),%al
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f9                	je     800a7e <strtol+0xe>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f5                	je     800a7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	75 08                	jne    800a95 <strtol+0x25>
		s++;
  800a8d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a93:	eb 13                	jmp    800aa8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a95:	3c 2d                	cmp    $0x2d,%al
  800a97:	75 0a                	jne    800aa3 <strtol+0x33>
		s++, neg = 1;
  800a99:	8d 52 01             	lea    0x1(%edx),%edx
  800a9c:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa1:	eb 05                	jmp    800aa8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	74 05                	je     800ab1 <strtol+0x41>
  800aac:	83 fb 10             	cmp    $0x10,%ebx
  800aaf:	75 28                	jne    800ad9 <strtol+0x69>
  800ab1:	8a 02                	mov    (%edx),%al
  800ab3:	3c 30                	cmp    $0x30,%al
  800ab5:	75 10                	jne    800ac7 <strtol+0x57>
  800ab7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abb:	75 0a                	jne    800ac7 <strtol+0x57>
		s += 2, base = 16;
  800abd:	83 c2 02             	add    $0x2,%edx
  800ac0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac5:	eb 12                	jmp    800ad9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	75 0e                	jne    800ad9 <strtol+0x69>
  800acb:	3c 30                	cmp    $0x30,%al
  800acd:	75 05                	jne    800ad4 <strtol+0x64>
		s++, base = 8;
  800acf:	42                   	inc    %edx
  800ad0:	b3 08                	mov    $0x8,%bl
  800ad2:	eb 05                	jmp    800ad9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae0:	8a 0a                	mov    (%edx),%cl
  800ae2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae5:	80 fb 09             	cmp    $0x9,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0x82>
			dig = *s - '0';
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 30             	sub    $0x30,%ecx
  800af0:	eb 1e                	jmp    800b10 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 08                	ja     800b02 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afa:	0f be c9             	movsbl %cl,%ecx
  800afd:	83 e9 57             	sub    $0x57,%ecx
  800b00:	eb 0e                	jmp    800b10 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 12                	ja     800b1c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0a:	0f be c9             	movsbl %cl,%ecx
  800b0d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b10:	39 f1                	cmp    %esi,%ecx
  800b12:	7d 0c                	jge    800b20 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b14:	42                   	inc    %edx
  800b15:	0f af c6             	imul   %esi,%eax
  800b18:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1a:	eb c4                	jmp    800ae0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1c:	89 c1                	mov    %eax,%ecx
  800b1e:	eb 02                	jmp    800b22 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b20:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b26:	74 05                	je     800b2d <strtol+0xbd>
		*endptr = (char *) s;
  800b28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b2d:	85 ff                	test   %edi,%edi
  800b2f:	74 04                	je     800b35 <strtol+0xc5>
  800b31:	89 c8                	mov    %ecx,%eax
  800b33:	f7 d8                	neg    %eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
	...

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 28                	jle    800bc3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800bae:	00 
  800baf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb6:	00 
  800bb7:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800bbe:	e8 b1 f5 ff ff       	call   800174 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc3:	83 c4 2c             	add    $0x2c,%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdb:	89 d1                	mov    %edx,%ecx
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	89 d7                	mov    %edx,%edi
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_yield>:

void
sys_yield(void)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	be 00 00 00 00       	mov    $0x0,%esi
  800c17:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 f7                	mov    %esi,%edi
  800c27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 28                	jle    800c55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c38:	00 
  800c39:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800c40:	00 
  800c41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c48:	00 
  800c49:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800c50:	e8 1f f5 ff ff       	call   800174 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c55:	83 c4 2c             	add    $0x2c,%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 28                	jle    800ca8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800c93:	00 
  800c94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9b:	00 
  800c9c:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800ca3:	e8 cc f4 ff ff       	call   800174 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca8:	83 c4 2c             	add    $0x2c,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 df                	mov    %ebx,%edi
  800ccb:	89 de                	mov    %ebx,%esi
  800ccd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 28                	jle    800cfb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cde:	00 
  800cdf:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cee:	00 
  800cef:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800cf6:	e8 79 f4 ff ff       	call   800174 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfb:	83 c4 2c             	add    $0x2c,%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 08 00 00 00       	mov    $0x8,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 28                	jle    800d4e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d31:	00 
  800d32:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d39:	00 
  800d3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d41:	00 
  800d42:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d49:	e8 26 f4 ff ff       	call   800174 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4e:	83 c4 2c             	add    $0x2c,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d64:	b8 09 00 00 00       	mov    $0x9,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	89 df                	mov    %ebx,%edi
  800d71:	89 de                	mov    %ebx,%esi
  800d73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7e 28                	jle    800da1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d84:	00 
  800d85:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d94:	00 
  800d95:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d9c:	e8 d3 f3 ff ff       	call   800174 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da1:	83 c4 2c             	add    $0x2c,%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	be 00 00 00 00       	mov    $0x0,%esi
  800db4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	89 cb                	mov    %ecx,%ebx
  800de4:	89 cf                	mov    %ecx,%edi
  800de6:	89 ce                	mov    %ecx,%esi
  800de8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7e 28                	jle    800e16 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800df9:	00 
  800dfa:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800e01:	00 
  800e02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e09:	00 
  800e0a:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800e11:	e8 5e f3 ff ff       	call   800174 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e16:	83 c4 2c             	add    $0x2c,%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
	...

00800e20 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	53                   	push   %ebx
  800e24:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e27:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e2e:	75 6f                	jne    800e9f <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  800e30:	e8 96 fd ff ff       	call   800bcb <sys_getenvid>
  800e35:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800e37:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e46:	ee 
  800e47:	89 04 24             	mov    %eax,(%esp)
  800e4a:	e8 ba fd ff ff       	call   800c09 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	79 1c                	jns    800e6f <set_pgfault_handler+0x4f>
  800e53:	c7 44 24 08 50 14 80 	movl   $0x801450,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 ac 14 80 00 	movl   $0x8014ac,(%esp)
  800e6a:	e8 05 f3 ff ff       	call   800174 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800e6f:	c7 44 24 04 b0 0e 80 	movl   $0x800eb0,0x4(%esp)
  800e76:	00 
  800e77:	89 1c 24             	mov    %ebx,(%esp)
  800e7a:	e8 d7 fe ff ff       	call   800d56 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 1c                	jns    800e9f <set_pgfault_handler+0x7f>
  800e83:	c7 44 24 08 78 14 80 	movl   $0x801478,0x8(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800e92:	00 
  800e93:	c7 04 24 ac 14 80 00 	movl   $0x8014ac,(%esp)
  800e9a:	e8 d5 f2 ff ff       	call   800174 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ea7:	83 c4 14             	add    $0x14,%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    
  800ead:	00 00                	add    %al,(%eax)
	...

00800eb0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800eb0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eb1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800eb6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800eb8:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  800ebb:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  800ebf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  800ec4:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  800ec8:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  800eca:	83 c4 08             	add    $0x8,%esp
	popal
  800ecd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  800ece:	83 c4 04             	add    $0x4,%esp
	popfl
  800ed1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  800ed2:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800ed5:	c3                   	ret    
	...

00800ed8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800ed8:	55                   	push   %ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	83 ec 10             	sub    $0x10,%esp
  800ede:	8b 74 24 20          	mov    0x20(%esp),%esi
  800ee2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800eee:	89 cd                	mov    %ecx,%ebp
  800ef0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	75 2c                	jne    800f24 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ef8:	39 f9                	cmp    %edi,%ecx
  800efa:	77 68                	ja     800f64 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800efc:	85 c9                	test   %ecx,%ecx
  800efe:	75 0b                	jne    800f0b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f00:	b8 01 00 00 00       	mov    $0x1,%eax
  800f05:	31 d2                	xor    %edx,%edx
  800f07:	f7 f1                	div    %ecx
  800f09:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	89 f8                	mov    %edi,%eax
  800f0f:	f7 f1                	div    %ecx
  800f11:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	f7 f1                	div    %ecx
  800f17:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f24:	39 f8                	cmp    %edi,%eax
  800f26:	77 2c                	ja     800f54 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f28:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800f2b:	83 f6 1f             	xor    $0x1f,%esi
  800f2e:	75 4c                	jne    800f7c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f30:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f32:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f37:	72 0a                	jb     800f43 <__udivdi3+0x6b>
  800f39:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f3d:	0f 87 ad 00 00 00    	ja     800ff0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f43:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f48:	89 f0                	mov    %esi,%eax
  800f4a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    
  800f53:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f54:	31 ff                	xor    %edi,%edi
  800f56:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f58:	89 f0                	mov    %esi,%eax
  800f5a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f64:	89 fa                	mov    %edi,%edx
  800f66:	89 f0                	mov    %esi,%eax
  800f68:	f7 f1                	div    %ecx
  800f6a:	89 c6                	mov    %eax,%esi
  800f6c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f7c:	89 f1                	mov    %esi,%ecx
  800f7e:	d3 e0                	shl    %cl,%eax
  800f80:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f84:	b8 20 00 00 00       	mov    $0x20,%eax
  800f89:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f8b:	89 ea                	mov    %ebp,%edx
  800f8d:	88 c1                	mov    %al,%cl
  800f8f:	d3 ea                	shr    %cl,%edx
  800f91:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f95:	09 ca                	or     %ecx,%edx
  800f97:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f9b:	89 f1                	mov    %esi,%ecx
  800f9d:	d3 e5                	shl    %cl,%ebp
  800f9f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800fa3:	89 fd                	mov    %edi,%ebp
  800fa5:	88 c1                	mov    %al,%cl
  800fa7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800fa9:	89 fa                	mov    %edi,%edx
  800fab:	89 f1                	mov    %esi,%ecx
  800fad:	d3 e2                	shl    %cl,%edx
  800faf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb3:	88 c1                	mov    %al,%cl
  800fb5:	d3 ef                	shr    %cl,%edi
  800fb7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	89 ea                	mov    %ebp,%edx
  800fbd:	f7 74 24 08          	divl   0x8(%esp)
  800fc1:	89 d1                	mov    %edx,%ecx
  800fc3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800fc5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc9:	39 d1                	cmp    %edx,%ecx
  800fcb:	72 17                	jb     800fe4 <__udivdi3+0x10c>
  800fcd:	74 09                	je     800fd8 <__udivdi3+0x100>
  800fcf:	89 fe                	mov    %edi,%esi
  800fd1:	31 ff                	xor    %edi,%edi
  800fd3:	e9 41 ff ff ff       	jmp    800f19 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800fd8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fdc:	89 f1                	mov    %esi,%ecx
  800fde:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe0:	39 c2                	cmp    %eax,%edx
  800fe2:	73 eb                	jae    800fcf <__udivdi3+0xf7>
		{
		  q0--;
  800fe4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fe7:	31 ff                	xor    %edi,%edi
  800fe9:	e9 2b ff ff ff       	jmp    800f19 <__udivdi3+0x41>
  800fee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ff0:	31 f6                	xor    %esi,%esi
  800ff2:	e9 22 ff ff ff       	jmp    800f19 <__udivdi3+0x41>
	...

00800ff8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ff8:	55                   	push   %ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	83 ec 20             	sub    $0x20,%esp
  800ffe:	8b 44 24 30          	mov    0x30(%esp),%eax
  801002:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801006:	89 44 24 14          	mov    %eax,0x14(%esp)
  80100a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80100e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801012:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801016:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801018:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80101a:	85 ed                	test   %ebp,%ebp
  80101c:	75 16                	jne    801034 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80101e:	39 f1                	cmp    %esi,%ecx
  801020:	0f 86 a6 00 00 00    	jbe    8010cc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801026:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801028:	89 d0                	mov    %edx,%eax
  80102a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80102c:	83 c4 20             	add    $0x20,%esp
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    
  801033:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801034:	39 f5                	cmp    %esi,%ebp
  801036:	0f 87 ac 00 00 00    	ja     8010e8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80103c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80103f:	83 f0 1f             	xor    $0x1f,%eax
  801042:	89 44 24 10          	mov    %eax,0x10(%esp)
  801046:	0f 84 a8 00 00 00    	je     8010f4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80104c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801050:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801052:	bf 20 00 00 00       	mov    $0x20,%edi
  801057:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80105b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80105f:	89 f9                	mov    %edi,%ecx
  801061:	d3 e8                	shr    %cl,%eax
  801063:	09 e8                	or     %ebp,%eax
  801065:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801069:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80106d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801071:	d3 e0                	shl    %cl,%eax
  801073:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801077:	89 f2                	mov    %esi,%edx
  801079:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80107b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80107f:	d3 e0                	shl    %cl,%eax
  801081:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801085:	8b 44 24 14          	mov    0x14(%esp),%eax
  801089:	89 f9                	mov    %edi,%ecx
  80108b:	d3 e8                	shr    %cl,%eax
  80108d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80108f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801091:	89 f2                	mov    %esi,%edx
  801093:	f7 74 24 18          	divl   0x18(%esp)
  801097:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801099:	f7 64 24 0c          	mull   0xc(%esp)
  80109d:	89 c5                	mov    %eax,%ebp
  80109f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	72 67                	jb     80110c <__umoddi3+0x114>
  8010a5:	74 75                	je     80111c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010ab:	29 e8                	sub    %ebp,%eax
  8010ad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010af:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010b3:	d3 e8                	shr    %cl,%eax
  8010b5:	89 f2                	mov    %esi,%edx
  8010b7:	89 f9                	mov    %edi,%ecx
  8010b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8010bb:	09 d0                	or     %edx,%eax
  8010bd:	89 f2                	mov    %esi,%edx
  8010bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010c3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010c5:	83 c4 20             	add    $0x20,%esp
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010cc:	85 c9                	test   %ecx,%ecx
  8010ce:	75 0b                	jne    8010db <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d5:	31 d2                	xor    %edx,%edx
  8010d7:	f7 f1                	div    %ecx
  8010d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010db:	89 f0                	mov    %esi,%eax
  8010dd:	31 d2                	xor    %edx,%edx
  8010df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010e1:	89 f8                	mov    %edi,%eax
  8010e3:	e9 3e ff ff ff       	jmp    801026 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8010e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010ea:	83 c4 20             	add    $0x20,%esp
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    
  8010f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8010f4:	39 f5                	cmp    %esi,%ebp
  8010f6:	72 04                	jb     8010fc <__umoddi3+0x104>
  8010f8:	39 f9                	cmp    %edi,%ecx
  8010fa:	77 06                	ja     801102 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8010fc:	89 f2                	mov    %esi,%edx
  8010fe:	29 cf                	sub    %ecx,%edi
  801100:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801102:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    
  80110b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80110c:	89 d1                	mov    %edx,%ecx
  80110e:	89 c5                	mov    %eax,%ebp
  801110:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801114:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801118:	eb 8d                	jmp    8010a7 <__umoddi3+0xaf>
  80111a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80111c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801120:	72 ea                	jb     80110c <__umoddi3+0x114>
  801122:	89 f1                	mov    %esi,%ecx
  801124:	eb 81                	jmp    8010a7 <__umoddi3+0xaf>
