
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 c0 10 80 00 	movl   $0x8010c0,(%esp)
  800054:	e8 4b 01 00 00       	call   8001a4 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 a5 0a 00 00       	call   800b03 <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 4b 0a 00 00       	call   800ab1 <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 de 0c 00 00       	call   800d58 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 20             	sub    $0x20,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800096:	e8 68 0a 00 00       	call   800b03 <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a7:	c1 e0 07             	shl    $0x7,%eax
  8000aa:	29 d0                	sub    %edx,%eax
  8000ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004
  8000bc:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  8000c0:	c7 04 24 d8 10 80 00 	movl   $0x8010d8,(%esp)
  8000c7:	e8 d8 00 00 00       	call   8001a4 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cc:	85 f6                	test   %esi,%esi
  8000ce:	7e 07                	jle    8000d7 <libmain+0x4f>
		binaryname = argv[0];
  8000d0:	8b 03                	mov    (%ebx),%eax
  8000d2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000db:	89 34 24             	mov    %esi,(%esp)
  8000de:	e8 85 ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000e3:	e8 08 00 00 00       	call   8000f0 <exit>
}
  8000e8:	83 c4 20             	add    $0x20,%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 af 09 00 00       	call   800ab1 <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	40                   	inc    %eax
  800118:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011f:	75 19                	jne    80013a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800121:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800128:	00 
  800129:	8d 43 08             	lea    0x8(%ebx),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 40 09 00 00       	call   800a74 <sys_cputs>
		b->idx = 0;
  800134:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013a:	ff 43 04             	incl   0x4(%ebx)
}
  80013d:	83 c4 14             	add    $0x14,%esp
  800140:	5b                   	pop    %ebx
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	8b 45 0c             	mov    0xc(%ebp),%eax
  800163:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800167:	8b 45 08             	mov    0x8(%ebp),%eax
  80016a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  80017f:	e8 82 01 00 00       	call   800306 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800184:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 d8 08 00 00       	call   800a74 <sys_cputs>

	return b.cnt;
}
  80019c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b4:	89 04 24             	mov    %eax,(%esp)
  8001b7:	e8 87 ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	75 08                	jne    8001ec <printnum+0x2c>
  8001e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 57                	ja     800243 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001f0:	4b                   	dec    %ebx
  8001f1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800200:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800204:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020b:	00 
  80020c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020f:	89 04 24             	mov    %eax,(%esp)
  800212:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800215:	89 44 24 04          	mov    %eax,0x4(%esp)
  800219:	e8 4a 0c 00 00       	call   800e68 <__udivdi3>
  80021e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800222:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022d:	89 fa                	mov    %edi,%edx
  80022f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800232:	e8 89 ff ff ff       	call   8001c0 <printnum>
  800237:	eb 0f                	jmp    800248 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023d:	89 34 24             	mov    %esi,(%esp)
  800240:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800243:	4b                   	dec    %ebx
  800244:	85 db                	test   %ebx,%ebx
  800246:	7f f1                	jg     800239 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800248:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800250:	8b 45 10             	mov    0x10(%ebp),%eax
  800253:	89 44 24 08          	mov    %eax,0x8(%esp)
  800257:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025e:	00 
  80025f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	e8 17 0d 00 00       	call   800f88 <__umoddi3>
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	0f be 80 e6 10 80 00 	movsbl 0x8010e6(%eax),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800282:	83 c4 3c             	add    $0x3c,%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028d:	83 fa 01             	cmp    $0x1,%edx
  800290:	7e 0e                	jle    8002a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 08             	lea    0x8(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	8b 52 04             	mov    0x4(%edx),%edx
  80029e:	eb 22                	jmp    8002c2 <getuint+0x38>
	else if (lflag)
  8002a0:	85 d2                	test   %edx,%edx
  8002a2:	74 10                	je     8002b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b2:	eb 0e                	jmp    8002c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ca:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 08                	jae    8002dc <sprintputch+0x18>
		*b->buf++ = ch;
  8002d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d7:	88 0a                	mov    %cl,(%edx)
  8002d9:	42                   	inc    %edx
  8002da:	89 10                	mov    %edx,(%eax)
}
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fc:	89 04 24             	mov    %eax,(%esp)
  8002ff:	e8 02 00 00 00       	call   800306 <vprintfmt>
	va_end(ap);
}
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 4c             	sub    $0x4c,%esp
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800312:	8b 75 10             	mov    0x10(%ebp),%esi
  800315:	eb 12                	jmp    800329 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800317:	85 c0                	test   %eax,%eax
  800319:	0f 84 6b 03 00 00    	je     80068a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80031f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	0f b6 06             	movzbl (%esi),%eax
  80032c:	46                   	inc    %esi
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e5                	jne    800317 <vprintfmt+0x11>
  800332:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800336:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80033d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800342:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800349:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034e:	eb 26                	jmp    800376 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800353:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800357:	eb 1d                	jmp    800376 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800360:	eb 14                	jmp    800376 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800365:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036c:	eb 08                	jmp    800376 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80036e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800371:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	0f b6 06             	movzbl (%esi),%eax
  800379:	8d 56 01             	lea    0x1(%esi),%edx
  80037c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80037f:	8a 16                	mov    (%esi),%dl
  800381:	83 ea 23             	sub    $0x23,%edx
  800384:	80 fa 55             	cmp    $0x55,%dl
  800387:	0f 87 e1 02 00 00    	ja     80066e <vprintfmt+0x368>
  80038d:	0f b6 d2             	movzbl %dl,%edx
  800390:	ff 24 95 a0 11 80 00 	jmp    *0x8011a0(,%edx,4)
  800397:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80039a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003a2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003a6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ac:	83 fa 09             	cmp    $0x9,%edx
  8003af:	77 2a                	ja     8003db <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b2:	eb eb                	jmp    80039f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c2:	eb 17                	jmp    8003db <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c8:	78 98                	js     800362 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003cd:	eb a7                	jmp    800376 <vprintfmt+0x70>
  8003cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003d9:	eb 9b                	jmp    800376 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003df:	79 95                	jns    800376 <vprintfmt+0x70>
  8003e1:	eb 8b                	jmp    80036e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e7:	eb 8d                	jmp    800376 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 50 04             	lea    0x4(%eax),%edx
  8003ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800401:	e9 23 ff ff ff       	jmp    800329 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 50 04             	lea    0x4(%eax),%edx
  80040c:	89 55 14             	mov    %edx,0x14(%ebp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	85 c0                	test   %eax,%eax
  800413:	79 02                	jns    800417 <vprintfmt+0x111>
  800415:	f7 d8                	neg    %eax
  800417:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800419:	83 f8 08             	cmp    $0x8,%eax
  80041c:	7f 0b                	jg     800429 <vprintfmt+0x123>
  80041e:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  800425:	85 c0                	test   %eax,%eax
  800427:	75 23                	jne    80044c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800429:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042d:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  800434:	00 
  800435:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800439:	8b 45 08             	mov    0x8(%ebp),%eax
  80043c:	89 04 24             	mov    %eax,(%esp)
  80043f:	e8 9a fe ff ff       	call   8002de <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800447:	e9 dd fe ff ff       	jmp    800329 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80044c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800450:	c7 44 24 08 07 11 80 	movl   $0x801107,0x8(%esp)
  800457:	00 
  800458:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045c:	8b 55 08             	mov    0x8(%ebp),%edx
  80045f:	89 14 24             	mov    %edx,(%esp)
  800462:	e8 77 fe ff ff       	call   8002de <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046a:	e9 ba fe ff ff       	jmp    800329 <vprintfmt+0x23>
  80046f:	89 f9                	mov    %edi,%ecx
  800471:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800474:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	8b 30                	mov    (%eax),%esi
  800482:	85 f6                	test   %esi,%esi
  800484:	75 05                	jne    80048b <vprintfmt+0x185>
				p = "(null)";
  800486:	be f7 10 80 00       	mov    $0x8010f7,%esi
			if (width > 0 && padc != '-')
  80048b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048f:	0f 8e 84 00 00 00    	jle    800519 <vprintfmt+0x213>
  800495:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800499:	74 7e                	je     800519 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80049f:	89 34 24             	mov    %esi,(%esp)
  8004a2:	e8 8b 02 00 00       	call   800732 <strnlen>
  8004a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004aa:	29 c2                	sub    %eax,%edx
  8004ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004af:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004b3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004b6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004b9:	89 de                	mov    %ebx,%esi
  8004bb:	89 d3                	mov    %edx,%ebx
  8004bd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	eb 0b                	jmp    8004cc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c5:	89 3c 24             	mov    %edi,(%esp)
  8004c8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	4b                   	dec    %ebx
  8004cc:	85 db                	test   %ebx,%ebx
  8004ce:	7f f1                	jg     8004c1 <vprintfmt+0x1bb>
  8004d0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004d3:	89 f3                	mov    %esi,%ebx
  8004d5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	79 05                	jns    8004e4 <vprintfmt+0x1de>
  8004df:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004e7:	29 c2                	sub    %eax,%edx
  8004e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ec:	eb 2b                	jmp    800519 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f2:	74 18                	je     80050c <vprintfmt+0x206>
  8004f4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004f7:	83 fa 5e             	cmp    $0x5e,%edx
  8004fa:	76 10                	jbe    80050c <vprintfmt+0x206>
					putch('?', putdat);
  8004fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800500:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
  80050a:	eb 0a                	jmp    800516 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80050c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800510:	89 04 24             	mov    %eax,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800516:	ff 4d e4             	decl   -0x1c(%ebp)
  800519:	0f be 06             	movsbl (%esi),%eax
  80051c:	46                   	inc    %esi
  80051d:	85 c0                	test   %eax,%eax
  80051f:	74 21                	je     800542 <vprintfmt+0x23c>
  800521:	85 ff                	test   %edi,%edi
  800523:	78 c9                	js     8004ee <vprintfmt+0x1e8>
  800525:	4f                   	dec    %edi
  800526:	79 c6                	jns    8004ee <vprintfmt+0x1e8>
  800528:	8b 7d 08             	mov    0x8(%ebp),%edi
  80052b:	89 de                	mov    %ebx,%esi
  80052d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800530:	eb 18                	jmp    80054a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800532:	89 74 24 04          	mov    %esi,0x4(%esp)
  800536:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80053d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053f:	4b                   	dec    %ebx
  800540:	eb 08                	jmp    80054a <vprintfmt+0x244>
  800542:	8b 7d 08             	mov    0x8(%ebp),%edi
  800545:	89 de                	mov    %ebx,%esi
  800547:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054a:	85 db                	test   %ebx,%ebx
  80054c:	7f e4                	jg     800532 <vprintfmt+0x22c>
  80054e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800551:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800556:	e9 ce fd ff ff       	jmp    800329 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055b:	83 f9 01             	cmp    $0x1,%ecx
  80055e:	7e 10                	jle    800570 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 08             	lea    0x8(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 30                	mov    (%eax),%esi
  80056b:	8b 78 04             	mov    0x4(%eax),%edi
  80056e:	eb 26                	jmp    800596 <vprintfmt+0x290>
	else if (lflag)
  800570:	85 c9                	test   %ecx,%ecx
  800572:	74 12                	je     800586 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 30                	mov    (%eax),%esi
  80057f:	89 f7                	mov    %esi,%edi
  800581:	c1 ff 1f             	sar    $0x1f,%edi
  800584:	eb 10                	jmp    800596 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 30                	mov    (%eax),%esi
  800591:	89 f7                	mov    %esi,%edi
  800593:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800596:	85 ff                	test   %edi,%edi
  800598:	78 0a                	js     8005a4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059f:	e9 8c 00 00 00       	jmp    800630 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b2:	f7 de                	neg    %esi
  8005b4:	83 d7 00             	adc    $0x0,%edi
  8005b7:	f7 df                	neg    %edi
			}
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	eb 70                	jmp    800630 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c0:	89 ca                	mov    %ecx,%edx
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c5:	e8 c0 fc ff ff       	call   80028a <getuint>
  8005ca:	89 c6                	mov    %eax,%esi
  8005cc:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005d3:	eb 5b                	jmp    800630 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005d5:	89 ca                	mov    %ecx,%edx
  8005d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005da:	e8 ab fc ff ff       	call   80028a <getuint>
  8005df:	89 c6                	mov    %eax,%esi
  8005e1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005e3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005e8:	eb 46                	jmp    800630 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005f5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060f:	8b 30                	mov    (%eax),%esi
  800611:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800616:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80061b:	eb 13                	jmp    800630 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061d:	89 ca                	mov    %ecx,%edx
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 63 fc ff ff       	call   80028a <getuint>
  800627:	89 c6                	mov    %eax,%esi
  800629:	89 d7                	mov    %edx,%edi
			base = 16;
  80062b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800630:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800634:	89 54 24 10          	mov    %edx,0x10(%esp)
  800638:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80063f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800643:	89 34 24             	mov    %esi,(%esp)
  800646:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064a:	89 da                	mov    %ebx,%edx
  80064c:	8b 45 08             	mov    0x8(%ebp),%eax
  80064f:	e8 6c fb ff ff       	call   8001c0 <printnum>
			break;
  800654:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800657:	e9 cd fc ff ff       	jmp    800329 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800669:	e9 bb fc ff ff       	jmp    800329 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800672:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800679:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067c:	eb 01                	jmp    80067f <vprintfmt+0x379>
  80067e:	4e                   	dec    %esi
  80067f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800683:	75 f9                	jne    80067e <vprintfmt+0x378>
  800685:	e9 9f fc ff ff       	jmp    800329 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80068a:	83 c4 4c             	add    $0x4c,%esp
  80068d:	5b                   	pop    %ebx
  80068e:	5e                   	pop    %esi
  80068f:	5f                   	pop    %edi
  800690:	5d                   	pop    %ebp
  800691:	c3                   	ret    

00800692 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	83 ec 28             	sub    $0x28,%esp
  800698:	8b 45 08             	mov    0x8(%ebp),%eax
  80069b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	74 30                	je     8006e3 <vsnprintf+0x51>
  8006b3:	85 d2                	test   %edx,%edx
  8006b5:	7e 33                	jle    8006ea <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006be:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cc:	c7 04 24 c4 02 80 00 	movl   $0x8002c4,(%esp)
  8006d3:	e8 2e fc ff ff       	call   800306 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	eb 0c                	jmp    8006ef <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e8:	eb 05                	jmp    8006ef <vsnprintf+0x5d>
  8006ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800701:	89 44 24 08          	mov    %eax,0x8(%esp)
  800705:	8b 45 0c             	mov    0xc(%ebp),%eax
  800708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	89 04 24             	mov    %eax,(%esp)
  800712:	e8 7b ff ff ff       	call   800692 <vsnprintf>
	va_end(ap);

	return rc;
}
  800717:	c9                   	leave  
  800718:	c3                   	ret    
  800719:	00 00                	add    %al,(%eax)
	...

0080071c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	b8 00 00 00 00       	mov    $0x0,%eax
  800727:	eb 01                	jmp    80072a <strlen+0xe>
		n++;
  800729:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072e:	75 f9                	jne    800729 <strlen+0xd>
		n++;
	return n;
}
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	eb 01                	jmp    800743 <strnlen+0x11>
		n++;
  800742:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	39 d0                	cmp    %edx,%eax
  800745:	74 06                	je     80074d <strnlen+0x1b>
  800747:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80074b:	75 f5                	jne    800742 <strnlen+0x10>
		n++;
	return n;
}
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800759:	ba 00 00 00 00       	mov    $0x0,%edx
  80075e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800761:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800764:	42                   	inc    %edx
  800765:	84 c9                	test   %cl,%cl
  800767:	75 f5                	jne    80075e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800769:	5b                   	pop    %ebx
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	53                   	push   %ebx
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800776:	89 1c 24             	mov    %ebx,(%esp)
  800779:	e8 9e ff ff ff       	call   80071c <strlen>
	strcpy(dst + len, src);
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800781:	89 54 24 04          	mov    %edx,0x4(%esp)
  800785:	01 d8                	add    %ebx,%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	e8 c0 ff ff ff       	call   80074f <strcpy>
	return dst;
}
  80078f:	89 d8                	mov    %ebx,%eax
  800791:	83 c4 08             	add    $0x8,%esp
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007aa:	eb 0c                	jmp    8007b8 <strncpy+0x21>
		*dst++ = *src;
  8007ac:	8a 1a                	mov    (%edx),%bl
  8007ae:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007b4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b7:	41                   	inc    %ecx
  8007b8:	39 f1                	cmp    %esi,%ecx
  8007ba:	75 f0                	jne    8007ac <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	75 0a                	jne    8007dc <strlcpy+0x1c>
  8007d2:	89 f0                	mov    %esi,%eax
  8007d4:	eb 1a                	jmp    8007f0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d6:	88 18                	mov    %bl,(%eax)
  8007d8:	40                   	inc    %eax
  8007d9:	41                   	inc    %ecx
  8007da:	eb 02                	jmp    8007de <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007dc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007de:	4a                   	dec    %edx
  8007df:	74 0a                	je     8007eb <strlcpy+0x2b>
  8007e1:	8a 19                	mov    (%ecx),%bl
  8007e3:	84 db                	test   %bl,%bl
  8007e5:	75 ef                	jne    8007d6 <strlcpy+0x16>
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	eb 02                	jmp    8007ed <strlcpy+0x2d>
  8007eb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007ed:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007f0:	29 f0                	sub    %esi,%eax
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ff:	eb 02                	jmp    800803 <strcmp+0xd>
		p++, q++;
  800801:	41                   	inc    %ecx
  800802:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800803:	8a 01                	mov    (%ecx),%al
  800805:	84 c0                	test   %al,%al
  800807:	74 04                	je     80080d <strcmp+0x17>
  800809:	3a 02                	cmp    (%edx),%al
  80080b:	74 f4                	je     800801 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080d:	0f b6 c0             	movzbl %al,%eax
  800810:	0f b6 12             	movzbl (%edx),%edx
  800813:	29 d0                	sub    %edx,%eax
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800824:	eb 03                	jmp    800829 <strncmp+0x12>
		n--, p++, q++;
  800826:	4a                   	dec    %edx
  800827:	40                   	inc    %eax
  800828:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800829:	85 d2                	test   %edx,%edx
  80082b:	74 14                	je     800841 <strncmp+0x2a>
  80082d:	8a 18                	mov    (%eax),%bl
  80082f:	84 db                	test   %bl,%bl
  800831:	74 04                	je     800837 <strncmp+0x20>
  800833:	3a 19                	cmp    (%ecx),%bl
  800835:	74 ef                	je     800826 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800837:	0f b6 00             	movzbl (%eax),%eax
  80083a:	0f b6 11             	movzbl (%ecx),%edx
  80083d:	29 d0                	sub    %edx,%eax
  80083f:	eb 05                	jmp    800846 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800846:	5b                   	pop    %ebx
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800852:	eb 05                	jmp    800859 <strchr+0x10>
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	74 0c                	je     800864 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800858:	40                   	inc    %eax
  800859:	8a 10                	mov    (%eax),%dl
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f5                	jne    800854 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086f:	eb 05                	jmp    800876 <strfind+0x10>
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 07                	je     80087c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800875:	40                   	inc    %eax
  800876:	8a 10                	mov    (%eax),%dl
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f5                	jne    800871 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 7d 08             	mov    0x8(%ebp),%edi
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088d:	85 c9                	test   %ecx,%ecx
  80088f:	74 30                	je     8008c1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800891:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800897:	75 25                	jne    8008be <memset+0x40>
  800899:	f6 c1 03             	test   $0x3,%cl
  80089c:	75 20                	jne    8008be <memset+0x40>
		c &= 0xFF;
  80089e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a1:	89 d3                	mov    %edx,%ebx
  8008a3:	c1 e3 08             	shl    $0x8,%ebx
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	c1 e6 18             	shl    $0x18,%esi
  8008ab:	89 d0                	mov    %edx,%eax
  8008ad:	c1 e0 10             	shl    $0x10,%eax
  8008b0:	09 f0                	or     %esi,%eax
  8008b2:	09 d0                	or     %edx,%eax
  8008b4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b9:	fc                   	cld    
  8008ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bc:	eb 03                	jmp    8008c1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008be:	fc                   	cld    
  8008bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d6:	39 c6                	cmp    %eax,%esi
  8008d8:	73 34                	jae    80090e <memmove+0x46>
  8008da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	73 2d                	jae    80090e <memmove+0x46>
		s += n;
		d += n;
  8008e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e4:	f6 c2 03             	test   $0x3,%dl
  8008e7:	75 1b                	jne    800904 <memmove+0x3c>
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 13                	jne    800904 <memmove+0x3c>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 0e                	jne    800904 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f6:	83 ef 04             	sub    $0x4,%edi
  8008f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ff:	fd                   	std    
  800900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800902:	eb 07                	jmp    80090b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800904:	4f                   	dec    %edi
  800905:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800908:	fd                   	std    
  800909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090b:	fc                   	cld    
  80090c:	eb 20                	jmp    80092e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800914:	75 13                	jne    800929 <memmove+0x61>
  800916:	a8 03                	test   $0x3,%al
  800918:	75 0f                	jne    800929 <memmove+0x61>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 0a                	jne    800929 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800922:	89 c7                	mov    %eax,%edi
  800924:	fc                   	cld    
  800925:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800927:	eb 05                	jmp    80092e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800929:	89 c7                	mov    %eax,%edi
  80092b:	fc                   	cld    
  80092c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800938:	8b 45 10             	mov    0x10(%ebp),%eax
  80093b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	89 44 24 04          	mov    %eax,0x4(%esp)
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	89 04 24             	mov    %eax,(%esp)
  80094c:	e8 77 ff ff ff       	call   8008c8 <memmove>
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	57                   	push   %edi
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	eb 16                	jmp    80097f <memcmp+0x2c>
		if (*s1 != *s2)
  800969:	8a 04 17             	mov    (%edi,%edx,1),%al
  80096c:	42                   	inc    %edx
  80096d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800971:	38 c8                	cmp    %cl,%al
  800973:	74 0a                	je     80097f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800975:	0f b6 c0             	movzbl %al,%eax
  800978:	0f b6 c9             	movzbl %cl,%ecx
  80097b:	29 c8                	sub    %ecx,%eax
  80097d:	eb 09                	jmp    800988 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097f:	39 da                	cmp    %ebx,%edx
  800981:	75 e6                	jne    800969 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800996:	89 c2                	mov    %eax,%edx
  800998:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80099b:	eb 05                	jmp    8009a2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	38 08                	cmp    %cl,(%eax)
  80099f:	74 05                	je     8009a6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a1:	40                   	inc    %eax
  8009a2:	39 d0                	cmp    %edx,%eax
  8009a4:	72 f7                	jb     80099d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b4:	eb 01                	jmp    8009b7 <strtol+0xf>
		s++;
  8009b6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b7:	8a 02                	mov    (%edx),%al
  8009b9:	3c 20                	cmp    $0x20,%al
  8009bb:	74 f9                	je     8009b6 <strtol+0xe>
  8009bd:	3c 09                	cmp    $0x9,%al
  8009bf:	74 f5                	je     8009b6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c1:	3c 2b                	cmp    $0x2b,%al
  8009c3:	75 08                	jne    8009cd <strtol+0x25>
		s++;
  8009c5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cb:	eb 13                	jmp    8009e0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cd:	3c 2d                	cmp    $0x2d,%al
  8009cf:	75 0a                	jne    8009db <strtol+0x33>
		s++, neg = 1;
  8009d1:	8d 52 01             	lea    0x1(%edx),%edx
  8009d4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d9:	eb 05                	jmp    8009e0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009db:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e0:	85 db                	test   %ebx,%ebx
  8009e2:	74 05                	je     8009e9 <strtol+0x41>
  8009e4:	83 fb 10             	cmp    $0x10,%ebx
  8009e7:	75 28                	jne    800a11 <strtol+0x69>
  8009e9:	8a 02                	mov    (%edx),%al
  8009eb:	3c 30                	cmp    $0x30,%al
  8009ed:	75 10                	jne    8009ff <strtol+0x57>
  8009ef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f3:	75 0a                	jne    8009ff <strtol+0x57>
		s += 2, base = 16;
  8009f5:	83 c2 02             	add    $0x2,%edx
  8009f8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fd:	eb 12                	jmp    800a11 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009ff:	85 db                	test   %ebx,%ebx
  800a01:	75 0e                	jne    800a11 <strtol+0x69>
  800a03:	3c 30                	cmp    $0x30,%al
  800a05:	75 05                	jne    800a0c <strtol+0x64>
		s++, base = 8;
  800a07:	42                   	inc    %edx
  800a08:	b3 08                	mov    $0x8,%bl
  800a0a:	eb 05                	jmp    800a11 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a18:	8a 0a                	mov    (%edx),%cl
  800a1a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a1d:	80 fb 09             	cmp    $0x9,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x82>
			dig = *s - '0';
  800a22:	0f be c9             	movsbl %cl,%ecx
  800a25:	83 e9 30             	sub    $0x30,%ecx
  800a28:	eb 1e                	jmp    800a48 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a2a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a2d:	80 fb 19             	cmp    $0x19,%bl
  800a30:	77 08                	ja     800a3a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a32:	0f be c9             	movsbl %cl,%ecx
  800a35:	83 e9 57             	sub    $0x57,%ecx
  800a38:	eb 0e                	jmp    800a48 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a3a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a3d:	80 fb 19             	cmp    $0x19,%bl
  800a40:	77 12                	ja     800a54 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a42:	0f be c9             	movsbl %cl,%ecx
  800a45:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a48:	39 f1                	cmp    %esi,%ecx
  800a4a:	7d 0c                	jge    800a58 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a4c:	42                   	inc    %edx
  800a4d:	0f af c6             	imul   %esi,%eax
  800a50:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a52:	eb c4                	jmp    800a18 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a54:	89 c1                	mov    %eax,%ecx
  800a56:	eb 02                	jmp    800a5a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a58:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5e:	74 05                	je     800a65 <strtol+0xbd>
		*endptr = (char *) s;
  800a60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a63:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a65:	85 ff                	test   %edi,%edi
  800a67:	74 04                	je     800a6d <strtol+0xc5>
  800a69:	89 c8                	mov    %ecx,%eax
  800a6b:	f7 d8                	neg    %eax
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    
	...

00800a74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa2:	89 d1                	mov    %edx,%ecx
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	89 d7                	mov    %edx,%edi
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 cb                	mov    %ecx,%ebx
  800ac9:	89 cf                	mov    %ecx,%edi
  800acb:	89 ce                	mov    %ecx,%esi
  800acd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	7e 28                	jle    800afb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ad7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ade:	00 
  800adf:	c7 44 24 08 24 13 80 	movl   $0x801324,0x8(%esp)
  800ae6:	00 
  800ae7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aee:	00 
  800aef:	c7 04 24 41 13 80 00 	movl   $0x801341,(%esp)
  800af6:	e8 15 03 00 00       	call   800e10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afb:	83 c4 2c             	add    $0x2c,%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b13:	89 d1                	mov    %edx,%ecx
  800b15:	89 d3                	mov    %edx,%ebx
  800b17:	89 d7                	mov    %edx,%edi
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_yield>:

void
sys_yield(void)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	be 00 00 00 00       	mov    $0x0,%esi
  800b4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	89 f7                	mov    %esi,%edi
  800b5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 28                	jle    800b8d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b69:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b70:	00 
  800b71:	c7 44 24 08 24 13 80 	movl   $0x801324,0x8(%esp)
  800b78:	00 
  800b79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b80:	00 
  800b81:	c7 04 24 41 13 80 00 	movl   $0x801341,(%esp)
  800b88:	e8 83 02 00 00       	call   800e10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8d:	83 c4 2c             	add    $0x2c,%esp
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7e 28                	jle    800be0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bbc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bc3:	00 
  800bc4:	c7 44 24 08 24 13 80 	movl   $0x801324,0x8(%esp)
  800bcb:	00 
  800bcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd3:	00 
  800bd4:	c7 04 24 41 13 80 00 	movl   $0x801341,(%esp)
  800bdb:	e8 30 02 00 00       	call   800e10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be0:	83 c4 2c             	add    $0x2c,%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 df                	mov    %ebx,%edi
  800c03:	89 de                	mov    %ebx,%esi
  800c05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7e 28                	jle    800c33 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c16:	00 
  800c17:	c7 44 24 08 24 13 80 	movl   $0x801324,0x8(%esp)
  800c1e:	00 
  800c1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c26:	00 
  800c27:	c7 04 24 41 13 80 00 	movl   $0x801341,(%esp)
  800c2e:	e8 dd 01 00 00       	call   800e10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c33:	83 c4 2c             	add    $0x2c,%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 28                	jle    800c86 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c62:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c69:	00 
  800c6a:	c7 44 24 08 24 13 80 	movl   $0x801324,0x8(%esp)
  800c71:	00 
  800c72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c79:	00 
  800c7a:	c7 04 24 41 13 80 00 	movl   $0x801341,(%esp)
  800c81:	e8 8a 01 00 00       	call   800e10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c86:	83 c4 2c             	add    $0x2c,%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 28                	jle    800cd9 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 08 24 13 80 	movl   $0x801324,0x8(%esp)
  800cc4:	00 
  800cc5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccc:	00 
  800ccd:	c7 04 24 41 13 80 00 	movl   $0x801341,(%esp)
  800cd4:	e8 37 01 00 00       	call   800e10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd9:	83 c4 2c             	add    $0x2c,%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	be 00 00 00 00       	mov    $0x0,%esi
  800cec:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 cb                	mov    %ecx,%ebx
  800d1c:	89 cf                	mov    %ecx,%edi
  800d1e:	89 ce                	mov    %ecx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 28                	jle    800d4e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d31:	00 
  800d32:	c7 44 24 08 24 13 80 	movl   $0x801324,0x8(%esp)
  800d39:	00 
  800d3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d41:	00 
  800d42:	c7 04 24 41 13 80 00 	movl   $0x801341,(%esp)
  800d49:	e8 c2 00 00 00       	call   800e10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4e:	83 c4 2c             	add    $0x2c,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
	...

00800d58 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d5f:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d66:	75 6f                	jne    800dd7 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  800d68:	e8 96 fd ff ff       	call   800b03 <sys_getenvid>
  800d6d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800d6f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800d76:	00 
  800d77:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800d7e:	ee 
  800d7f:	89 04 24             	mov    %eax,(%esp)
  800d82:	e8 ba fd ff ff       	call   800b41 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  800d87:	85 c0                	test   %eax,%eax
  800d89:	79 1c                	jns    800da7 <set_pgfault_handler+0x4f>
  800d8b:	c7 44 24 08 50 13 80 	movl   $0x801350,0x8(%esp)
  800d92:	00 
  800d93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9a:	00 
  800d9b:	c7 04 24 a9 13 80 00 	movl   $0x8013a9,(%esp)
  800da2:	e8 69 00 00 00       	call   800e10 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800da7:	c7 44 24 04 e8 0d 80 	movl   $0x800de8,0x4(%esp)
  800dae:	00 
  800daf:	89 1c 24             	mov    %ebx,(%esp)
  800db2:	e8 d7 fe ff ff       	call   800c8e <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  800db7:	85 c0                	test   %eax,%eax
  800db9:	79 1c                	jns    800dd7 <set_pgfault_handler+0x7f>
  800dbb:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800dca:	00 
  800dcb:	c7 04 24 a9 13 80 00 	movl   $0x8013a9,(%esp)
  800dd2:	e8 39 00 00 00       	call   800e10 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ddf:	83 c4 14             	add    $0x14,%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	00 00                	add    %al,(%eax)
	...

00800de8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800de8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800de9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800dee:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800df0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  800df3:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  800df7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  800dfc:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  800e00:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  800e02:	83 c4 08             	add    $0x8,%esp
	popal
  800e05:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  800e06:	83 c4 04             	add    $0x4,%esp
	popfl
  800e09:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  800e0a:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800e0d:	c3                   	ret    
	...

00800e10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e18:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e1b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e21:	e8 dd fc ff ff       	call   800b03 <sys_getenvid>
  800e26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e29:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e34:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3c:	c7 04 24 b8 13 80 00 	movl   $0x8013b8,(%esp)
  800e43:	e8 5c f3 ff ff       	call   8001a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e48:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4f:	89 04 24             	mov    %eax,(%esp)
  800e52:	e8 ec f2 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  800e57:	c7 04 24 da 10 80 00 	movl   $0x8010da,(%esp)
  800e5e:	e8 41 f3 ff ff       	call   8001a4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e63:	cc                   	int3   
  800e64:	eb fd                	jmp    800e63 <_panic+0x53>
	...

00800e68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e68:	55                   	push   %ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	83 ec 10             	sub    $0x10,%esp
  800e6e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e7e:	89 cd                	mov    %ecx,%ebp
  800e80:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	75 2c                	jne    800eb4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e88:	39 f9                	cmp    %edi,%ecx
  800e8a:	77 68                	ja     800ef4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e8c:	85 c9                	test   %ecx,%ecx
  800e8e:	75 0b                	jne    800e9b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e90:	b8 01 00 00 00       	mov    $0x1,%eax
  800e95:	31 d2                	xor    %edx,%edx
  800e97:	f7 f1                	div    %ecx
  800e99:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	89 f8                	mov    %edi,%eax
  800e9f:	f7 f1                	div    %ecx
  800ea1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea3:	89 f0                	mov    %esi,%eax
  800ea5:	f7 f1                	div    %ecx
  800ea7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eb4:	39 f8                	cmp    %edi,%eax
  800eb6:	77 2c                	ja     800ee4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800eb8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800ebb:	83 f6 1f             	xor    $0x1f,%esi
  800ebe:	75 4c                	jne    800f0c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ec2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec7:	72 0a                	jb     800ed3 <__udivdi3+0x6b>
  800ec9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ecd:	0f 87 ad 00 00 00    	ja     800f80 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ed3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ed8:	89 f0                	mov    %esi,%eax
  800eda:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
  800ee3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ee4:	31 ff                	xor    %edi,%edi
  800ee6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ee8:	89 f0                	mov    %esi,%eax
  800eea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    
  800ef3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ef4:	89 fa                	mov    %edi,%edx
  800ef6:	89 f0                	mov    %esi,%eax
  800ef8:	f7 f1                	div    %ecx
  800efa:	89 c6                	mov    %eax,%esi
  800efc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800efe:	89 f0                	mov    %esi,%eax
  800f00:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f0c:	89 f1                	mov    %esi,%ecx
  800f0e:	d3 e0                	shl    %cl,%eax
  800f10:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f14:	b8 20 00 00 00       	mov    $0x20,%eax
  800f19:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f1b:	89 ea                	mov    %ebp,%edx
  800f1d:	88 c1                	mov    %al,%cl
  800f1f:	d3 ea                	shr    %cl,%edx
  800f21:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f25:	09 ca                	or     %ecx,%edx
  800f27:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f2b:	89 f1                	mov    %esi,%ecx
  800f2d:	d3 e5                	shl    %cl,%ebp
  800f2f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800f33:	89 fd                	mov    %edi,%ebp
  800f35:	88 c1                	mov    %al,%cl
  800f37:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800f39:	89 fa                	mov    %edi,%edx
  800f3b:	89 f1                	mov    %esi,%ecx
  800f3d:	d3 e2                	shl    %cl,%edx
  800f3f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f43:	88 c1                	mov    %al,%cl
  800f45:	d3 ef                	shr    %cl,%edi
  800f47:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f49:	89 f8                	mov    %edi,%eax
  800f4b:	89 ea                	mov    %ebp,%edx
  800f4d:	f7 74 24 08          	divl   0x8(%esp)
  800f51:	89 d1                	mov    %edx,%ecx
  800f53:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f55:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f59:	39 d1                	cmp    %edx,%ecx
  800f5b:	72 17                	jb     800f74 <__udivdi3+0x10c>
  800f5d:	74 09                	je     800f68 <__udivdi3+0x100>
  800f5f:	89 fe                	mov    %edi,%esi
  800f61:	31 ff                	xor    %edi,%edi
  800f63:	e9 41 ff ff ff       	jmp    800ea9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f68:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f6c:	89 f1                	mov    %esi,%ecx
  800f6e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f70:	39 c2                	cmp    %eax,%edx
  800f72:	73 eb                	jae    800f5f <__udivdi3+0xf7>
		{
		  q0--;
  800f74:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f77:	31 ff                	xor    %edi,%edi
  800f79:	e9 2b ff ff ff       	jmp    800ea9 <__udivdi3+0x41>
  800f7e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f80:	31 f6                	xor    %esi,%esi
  800f82:	e9 22 ff ff ff       	jmp    800ea9 <__udivdi3+0x41>
	...

00800f88 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f88:	55                   	push   %ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	83 ec 20             	sub    $0x20,%esp
  800f8e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f92:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f96:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f9a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fa2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800fa6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800fa8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800faa:	85 ed                	test   %ebp,%ebp
  800fac:	75 16                	jne    800fc4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800fae:	39 f1                	cmp    %esi,%ecx
  800fb0:	0f 86 a6 00 00 00    	jbe    80105c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fb6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800fb8:	89 d0                	mov    %edx,%eax
  800fba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    
  800fc3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fc4:	39 f5                	cmp    %esi,%ebp
  800fc6:	0f 87 ac 00 00 00    	ja     801078 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fcc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800fcf:	83 f0 1f             	xor    $0x1f,%eax
  800fd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd6:	0f 84 a8 00 00 00    	je     801084 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fdc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fe0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fe2:	bf 20 00 00 00       	mov    $0x20,%edi
  800fe7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800feb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fef:	89 f9                	mov    %edi,%ecx
  800ff1:	d3 e8                	shr    %cl,%eax
  800ff3:	09 e8                	or     %ebp,%eax
  800ff5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800ff9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ffd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801001:	d3 e0                	shl    %cl,%eax
  801003:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801007:	89 f2                	mov    %esi,%edx
  801009:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80100b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80100f:	d3 e0                	shl    %cl,%eax
  801011:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801015:	8b 44 24 14          	mov    0x14(%esp),%eax
  801019:	89 f9                	mov    %edi,%ecx
  80101b:	d3 e8                	shr    %cl,%eax
  80101d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80101f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801021:	89 f2                	mov    %esi,%edx
  801023:	f7 74 24 18          	divl   0x18(%esp)
  801027:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801029:	f7 64 24 0c          	mull   0xc(%esp)
  80102d:	89 c5                	mov    %eax,%ebp
  80102f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801031:	39 d6                	cmp    %edx,%esi
  801033:	72 67                	jb     80109c <__umoddi3+0x114>
  801035:	74 75                	je     8010ac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801037:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80103b:	29 e8                	sub    %ebp,%eax
  80103d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80103f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801043:	d3 e8                	shr    %cl,%eax
  801045:	89 f2                	mov    %esi,%edx
  801047:	89 f9                	mov    %edi,%ecx
  801049:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80104b:	09 d0                	or     %edx,%eax
  80104d:	89 f2                	mov    %esi,%edx
  80104f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801053:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801055:	83 c4 20             	add    $0x20,%esp
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80105c:	85 c9                	test   %ecx,%ecx
  80105e:	75 0b                	jne    80106b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801060:	b8 01 00 00 00       	mov    $0x1,%eax
  801065:	31 d2                	xor    %edx,%edx
  801067:	f7 f1                	div    %ecx
  801069:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80106b:	89 f0                	mov    %esi,%eax
  80106d:	31 d2                	xor    %edx,%edx
  80106f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801071:	89 f8                	mov    %edi,%eax
  801073:	e9 3e ff ff ff       	jmp    800fb6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801078:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80107a:	83 c4 20             	add    $0x20,%esp
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    
  801081:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801084:	39 f5                	cmp    %esi,%ebp
  801086:	72 04                	jb     80108c <__umoddi3+0x104>
  801088:	39 f9                	cmp    %edi,%ecx
  80108a:	77 06                	ja     801092 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80108c:	89 f2                	mov    %esi,%edx
  80108e:	29 cf                	sub    %ecx,%edi
  801090:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801092:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801094:	83 c4 20             	add    $0x20,%esp
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    
  80109b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80109c:	89 d1                	mov    %edx,%ecx
  80109e:	89 c5                	mov    %eax,%ebp
  8010a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8010a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8010a8:	eb 8d                	jmp    801037 <__umoddi3+0xaf>
  8010aa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8010b0:	72 ea                	jb     80109c <__umoddi3+0x114>
  8010b2:	89 f1                	mov    %esi,%ecx
  8010b4:	eb 81                	jmp    801037 <__umoddi3+0xaf>
