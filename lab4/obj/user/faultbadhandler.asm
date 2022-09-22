
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 db 0a 00 00       	call   800b31 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 14 0c 00 00       	call   800c7e <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 20             	sub    $0x20,%esp
  800080:	8b 75 08             	mov    0x8(%ebp),%esi
  800083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800086:	e8 68 0a 00 00       	call   800af3 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	29 d0                	sub    %edx,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a7:	a3 04 20 80 00       	mov    %eax,0x802004
  8000ac:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  8000b0:	c7 04 24 00 10 80 00 	movl   $0x801000,(%esp)
  8000b7:	e8 d8 00 00 00       	call   800194 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 f6                	test   %esi,%esi
  8000be:	7e 07                	jle    8000c7 <libmain+0x4f>
		binaryname = argv[0];
  8000c0:	8b 03                	mov    (%ebx),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 34 24             	mov    %esi,(%esp)
  8000ce:	e8 61 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d3:	e8 08 00 00 00       	call   8000e0 <exit>
}
  8000d8:	83 c4 20             	add    $0x20,%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    
	...

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ed:	e8 af 09 00 00       	call   800aa1 <sys_env_destroy>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 14             	sub    $0x14,%esp
  8000fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fe:	8b 03                	mov    (%ebx),%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800107:	40                   	inc    %eax
  800108:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 19                	jne    80012a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800111:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800118:	00 
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 40 09 00 00       	call   800a64 <sys_cputs>
		b->idx = 0;
  800124:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012a:	ff 43 04             	incl   0x4(%ebx)
}
  80012d:	83 c4 14             	add    $0x14,%esp
  800130:	5b                   	pop    %ebx
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80013c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800143:	00 00 00 
	b.cnt = 0;
  800146:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800150:	8b 45 0c             	mov    0xc(%ebp),%eax
  800153:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800157:	8b 45 08             	mov    0x8(%ebp),%eax
  80015a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	c7 04 24 f4 00 80 00 	movl   $0x8000f4,(%esp)
  80016f:	e8 82 01 00 00       	call   8002f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800174:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 d8 08 00 00       	call   800a64 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a4:	89 04 24             	mov    %eax,(%esp)
  8001a7:	e8 87 ff ff ff       	call   800133 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    
	...

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 3c             	sub    $0x3c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d7                	mov    %edx,%edi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d0:	85 c0                	test   %eax,%eax
  8001d2:	75 08                	jne    8001dc <printnum+0x2c>
  8001d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001da:	77 57                	ja     800233 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001e0:	4b                   	dec    %ebx
  8001e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ec:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fb:	00 
  8001fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	e8 92 0b 00 00       	call   800da0 <__udivdi3>
  80020e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800212:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800216:	89 04 24             	mov    %eax,(%esp)
  800219:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021d:	89 fa                	mov    %edi,%edx
  80021f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800222:	e8 89 ff ff ff       	call   8001b0 <printnum>
  800227:	eb 0f                	jmp    800238 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800229:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022d:	89 34 24             	mov    %esi,(%esp)
  800230:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800233:	4b                   	dec    %ebx
  800234:	85 db                	test   %ebx,%ebx
  800236:	7f f1                	jg     800229 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800238:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800240:	8b 45 10             	mov    0x10(%ebp),%eax
  800243:	89 44 24 08          	mov    %eax,0x8(%esp)
  800247:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024e:	00 
  80024f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	e8 5f 0c 00 00       	call   800ec0 <__umoddi3>
  800261:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800265:	0f be 80 0e 10 80 00 	movsbl 0x80100e(%eax),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800272:	83 c4 3c             	add    $0x3c,%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027d:	83 fa 01             	cmp    $0x1,%edx
  800280:	7e 0e                	jle    800290 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 08             	lea    0x8(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	8b 52 04             	mov    0x4(%edx),%edx
  80028e:	eb 22                	jmp    8002b2 <getuint+0x38>
	else if (lflag)
  800290:	85 d2                	test   %edx,%edx
  800292:	74 10                	je     8002a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 04             	lea    0x4(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a2:	eb 0e                	jmp    8002b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c2:	73 08                	jae    8002cc <sprintputch+0x18>
		*b->buf++ = ch;
  8002c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c7:	88 0a                	mov    %cl,(%edx)
  8002c9:	42                   	inc    %edx
  8002ca:	89 10                	mov    %edx,(%eax)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002db:	8b 45 10             	mov    0x10(%ebp),%eax
  8002de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	89 04 24             	mov    %eax,(%esp)
  8002ef:	e8 02 00 00 00       	call   8002f6 <vprintfmt>
	va_end(ap);
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 4c             	sub    $0x4c,%esp
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800302:	8b 75 10             	mov    0x10(%ebp),%esi
  800305:	eb 12                	jmp    800319 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800307:	85 c0                	test   %eax,%eax
  800309:	0f 84 6b 03 00 00    	je     80067a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80030f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800319:	0f b6 06             	movzbl (%esi),%eax
  80031c:	46                   	inc    %esi
  80031d:	83 f8 25             	cmp    $0x25,%eax
  800320:	75 e5                	jne    800307 <vprintfmt+0x11>
  800322:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800326:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80032d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800332:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	eb 26                	jmp    800366 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800347:	eb 1d                	jmp    800366 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800350:	eb 14                	jmp    800366 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800355:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035c:	eb 08                	jmp    800366 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80035e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800361:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	0f b6 06             	movzbl (%esi),%eax
  800369:	8d 56 01             	lea    0x1(%esi),%edx
  80036c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80036f:	8a 16                	mov    (%esi),%dl
  800371:	83 ea 23             	sub    $0x23,%edx
  800374:	80 fa 55             	cmp    $0x55,%dl
  800377:	0f 87 e1 02 00 00    	ja     80065e <vprintfmt+0x368>
  80037d:	0f b6 d2             	movzbl %dl,%edx
  800380:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  800387:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800392:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800396:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800399:	8d 50 d0             	lea    -0x30(%eax),%edx
  80039c:	83 fa 09             	cmp    $0x9,%edx
  80039f:	77 2a                	ja     8003cb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a2:	eb eb                	jmp    80038f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 50 04             	lea    0x4(%eax),%edx
  8003aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ad:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b2:	eb 17                	jmp    8003cb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b8:	78 98                	js     800352 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003bd:	eb a7                	jmp    800366 <vprintfmt+0x70>
  8003bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003c9:	eb 9b                	jmp    800366 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cf:	79 95                	jns    800366 <vprintfmt+0x70>
  8003d1:	eb 8b                	jmp    80035e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d7:	eb 8d                	jmp    800366 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 50 04             	lea    0x4(%eax),%edx
  8003df:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e6:	8b 00                	mov    (%eax),%eax
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f1:	e9 23 ff ff ff       	jmp    800319 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 50 04             	lea    0x4(%eax),%edx
  8003fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	85 c0                	test   %eax,%eax
  800403:	79 02                	jns    800407 <vprintfmt+0x111>
  800405:	f7 d8                	neg    %eax
  800407:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800409:	83 f8 08             	cmp    $0x8,%eax
  80040c:	7f 0b                	jg     800419 <vprintfmt+0x123>
  80040e:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800415:	85 c0                	test   %eax,%eax
  800417:	75 23                	jne    80043c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800419:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041d:	c7 44 24 08 26 10 80 	movl   $0x801026,0x8(%esp)
  800424:	00 
  800425:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	e8 9a fe ff ff       	call   8002ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800437:	e9 dd fe ff ff       	jmp    800319 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80043c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800440:	c7 44 24 08 2f 10 80 	movl   $0x80102f,0x8(%esp)
  800447:	00 
  800448:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044c:	8b 55 08             	mov    0x8(%ebp),%edx
  80044f:	89 14 24             	mov    %edx,(%esp)
  800452:	e8 77 fe ff ff       	call   8002ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045a:	e9 ba fe ff ff       	jmp    800319 <vprintfmt+0x23>
  80045f:	89 f9                	mov    %edi,%ecx
  800461:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800464:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 50 04             	lea    0x4(%eax),%edx
  80046d:	89 55 14             	mov    %edx,0x14(%ebp)
  800470:	8b 30                	mov    (%eax),%esi
  800472:	85 f6                	test   %esi,%esi
  800474:	75 05                	jne    80047b <vprintfmt+0x185>
				p = "(null)";
  800476:	be 1f 10 80 00       	mov    $0x80101f,%esi
			if (width > 0 && padc != '-')
  80047b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047f:	0f 8e 84 00 00 00    	jle    800509 <vprintfmt+0x213>
  800485:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800489:	74 7e                	je     800509 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80048f:	89 34 24             	mov    %esi,(%esp)
  800492:	e8 8b 02 00 00       	call   800722 <strnlen>
  800497:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049a:	29 c2                	sub    %eax,%edx
  80049c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80049f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004a9:	89 de                	mov    %ebx,%esi
  8004ab:	89 d3                	mov    %edx,%ebx
  8004ad:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	eb 0b                	jmp    8004bc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b5:	89 3c 24             	mov    %edi,(%esp)
  8004b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	4b                   	dec    %ebx
  8004bc:	85 db                	test   %ebx,%ebx
  8004be:	7f f1                	jg     8004b1 <vprintfmt+0x1bb>
  8004c0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c3:	89 f3                	mov    %esi,%ebx
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	79 05                	jns    8004d4 <vprintfmt+0x1de>
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d7:	29 c2                	sub    %eax,%edx
  8004d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004dc:	eb 2b                	jmp    800509 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004de:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e2:	74 18                	je     8004fc <vprintfmt+0x206>
  8004e4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004e7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ea:	76 10                	jbe    8004fc <vprintfmt+0x206>
					putch('?', putdat);
  8004ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	eb 0a                	jmp    800506 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800506:	ff 4d e4             	decl   -0x1c(%ebp)
  800509:	0f be 06             	movsbl (%esi),%eax
  80050c:	46                   	inc    %esi
  80050d:	85 c0                	test   %eax,%eax
  80050f:	74 21                	je     800532 <vprintfmt+0x23c>
  800511:	85 ff                	test   %edi,%edi
  800513:	78 c9                	js     8004de <vprintfmt+0x1e8>
  800515:	4f                   	dec    %edi
  800516:	79 c6                	jns    8004de <vprintfmt+0x1e8>
  800518:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051b:	89 de                	mov    %ebx,%esi
  80051d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800520:	eb 18                	jmp    80053a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800522:	89 74 24 04          	mov    %esi,0x4(%esp)
  800526:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80052d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052f:	4b                   	dec    %ebx
  800530:	eb 08                	jmp    80053a <vprintfmt+0x244>
  800532:	8b 7d 08             	mov    0x8(%ebp),%edi
  800535:	89 de                	mov    %ebx,%esi
  800537:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053a:	85 db                	test   %ebx,%ebx
  80053c:	7f e4                	jg     800522 <vprintfmt+0x22c>
  80053e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800541:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800546:	e9 ce fd ff ff       	jmp    800319 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054b:	83 f9 01             	cmp    $0x1,%ecx
  80054e:	7e 10                	jle    800560 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 50 08             	lea    0x8(%eax),%edx
  800556:	89 55 14             	mov    %edx,0x14(%ebp)
  800559:	8b 30                	mov    (%eax),%esi
  80055b:	8b 78 04             	mov    0x4(%eax),%edi
  80055e:	eb 26                	jmp    800586 <vprintfmt+0x290>
	else if (lflag)
  800560:	85 c9                	test   %ecx,%ecx
  800562:	74 12                	je     800576 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 30                	mov    (%eax),%esi
  80056f:	89 f7                	mov    %esi,%edi
  800571:	c1 ff 1f             	sar    $0x1f,%edi
  800574:	eb 10                	jmp    800586 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 30                	mov    (%eax),%esi
  800581:	89 f7                	mov    %esi,%edi
  800583:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800586:	85 ff                	test   %edi,%edi
  800588:	78 0a                	js     800594 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058f:	e9 8c 00 00 00       	jmp    800620 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800594:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800598:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80059f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a2:	f7 de                	neg    %esi
  8005a4:	83 d7 00             	adc    $0x0,%edi
  8005a7:	f7 df                	neg    %edi
			}
			base = 10;
  8005a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ae:	eb 70                	jmp    800620 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b0:	89 ca                	mov    %ecx,%edx
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b5:	e8 c0 fc ff ff       	call   80027a <getuint>
  8005ba:	89 c6                	mov    %eax,%esi
  8005bc:	89 d7                	mov    %edx,%edi
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c3:	eb 5b                	jmp    800620 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005c5:	89 ca                	mov    %ecx,%edx
  8005c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ca:	e8 ab fc ff ff       	call   80027a <getuint>
  8005cf:	89 c6                	mov    %eax,%esi
  8005d1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005d3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005d8:	eb 46                	jmp    800620 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 04             	lea    0x4(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ff:	8b 30                	mov    (%eax),%esi
  800601:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800606:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060b:	eb 13                	jmp    800620 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060d:	89 ca                	mov    %ecx,%edx
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	e8 63 fc ff ff       	call   80027a <getuint>
  800617:	89 c6                	mov    %eax,%esi
  800619:	89 d7                	mov    %edx,%edi
			base = 16;
  80061b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800620:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800624:	89 54 24 10          	mov    %edx,0x10(%esp)
  800628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800633:	89 34 24             	mov    %esi,(%esp)
  800636:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063a:	89 da                	mov    %ebx,%edx
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	e8 6c fb ff ff       	call   8001b0 <printnum>
			break;
  800644:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800647:	e9 cd fc ff ff       	jmp    800319 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800659:	e9 bb fc ff ff       	jmp    800319 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800662:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800669:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066c:	eb 01                	jmp    80066f <vprintfmt+0x379>
  80066e:	4e                   	dec    %esi
  80066f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800673:	75 f9                	jne    80066e <vprintfmt+0x378>
  800675:	e9 9f fc ff ff       	jmp    800319 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80067a:	83 c4 4c             	add    $0x4c,%esp
  80067d:	5b                   	pop    %ebx
  80067e:	5e                   	pop    %esi
  80067f:	5f                   	pop    %edi
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 28             	sub    $0x28,%esp
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800691:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800695:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800698:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	74 30                	je     8006d3 <vsnprintf+0x51>
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	7e 33                	jle    8006da <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bc:	c7 04 24 b4 02 80 00 	movl   $0x8002b4,(%esp)
  8006c3:	e8 2e fc ff ff       	call   8002f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	eb 0c                	jmp    8006df <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d8:	eb 05                	jmp    8006df <vsnprintf+0x5d>
  8006da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    

008006e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	e8 7b ff ff ff       	call   800682 <vsnprintf>
	va_end(ap);

	return rc;
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    
  800709:	00 00                	add    %al,(%eax)
	...

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 01                	jmp    80071a <strlen+0xe>
		n++;
  800719:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071e:	75 f9                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	eb 01                	jmp    800733 <strnlen+0x11>
		n++;
  800732:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	39 d0                	cmp    %edx,%eax
  800735:	74 06                	je     80073d <strnlen+0x1b>
  800737:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80073b:	75 f5                	jne    800732 <strnlen+0x10>
		n++;
	return n;
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
  80074e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800751:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800754:	42                   	inc    %edx
  800755:	84 c9                	test   %cl,%cl
  800757:	75 f5                	jne    80074e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800759:	5b                   	pop    %ebx
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800766:	89 1c 24             	mov    %ebx,(%esp)
  800769:	e8 9e ff ff ff       	call   80070c <strlen>
	strcpy(dst + len, src);
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	89 54 24 04          	mov    %edx,0x4(%esp)
  800775:	01 d8                	add    %ebx,%eax
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	e8 c0 ff ff ff       	call   80073f <strcpy>
	return dst;
}
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	83 c4 08             	add    $0x8,%esp
  800784:	5b                   	pop    %ebx
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800795:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079a:	eb 0c                	jmp    8007a8 <strncpy+0x21>
		*dst++ = *src;
  80079c:	8a 1a                	mov    (%edx),%bl
  80079e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a7:	41                   	inc    %ecx
  8007a8:	39 f1                	cmp    %esi,%ecx
  8007aa:	75 f0                	jne    80079c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ac:	5b                   	pop    %ebx
  8007ad:	5e                   	pop    %esi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	75 0a                	jne    8007cc <strlcpy+0x1c>
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	eb 1a                	jmp    8007e0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c6:	88 18                	mov    %bl,(%eax)
  8007c8:	40                   	inc    %eax
  8007c9:	41                   	inc    %ecx
  8007ca:	eb 02                	jmp    8007ce <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ce:	4a                   	dec    %edx
  8007cf:	74 0a                	je     8007db <strlcpy+0x2b>
  8007d1:	8a 19                	mov    (%ecx),%bl
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ef                	jne    8007c6 <strlcpy+0x16>
  8007d7:	89 c2                	mov    %eax,%edx
  8007d9:	eb 02                	jmp    8007dd <strlcpy+0x2d>
  8007db:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007dd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007e0:	29 f0                	sub    %esi,%eax
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ef:	eb 02                	jmp    8007f3 <strcmp+0xd>
		p++, q++;
  8007f1:	41                   	inc    %ecx
  8007f2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f3:	8a 01                	mov    (%ecx),%al
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 04                	je     8007fd <strcmp+0x17>
  8007f9:	3a 02                	cmp    (%edx),%al
  8007fb:	74 f4                	je     8007f1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 c0             	movzbl %al,%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800814:	eb 03                	jmp    800819 <strncmp+0x12>
		n--, p++, q++;
  800816:	4a                   	dec    %edx
  800817:	40                   	inc    %eax
  800818:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 14                	je     800831 <strncmp+0x2a>
  80081d:	8a 18                	mov    (%eax),%bl
  80081f:	84 db                	test   %bl,%bl
  800821:	74 04                	je     800827 <strncmp+0x20>
  800823:	3a 19                	cmp    (%ecx),%bl
  800825:	74 ef                	je     800816 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800827:	0f b6 00             	movzbl (%eax),%eax
  80082a:	0f b6 11             	movzbl (%ecx),%edx
  80082d:	29 d0                	sub    %edx,%eax
  80082f:	eb 05                	jmp    800836 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800836:	5b                   	pop    %ebx
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800842:	eb 05                	jmp    800849 <strchr+0x10>
		if (*s == c)
  800844:	38 ca                	cmp    %cl,%dl
  800846:	74 0c                	je     800854 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800848:	40                   	inc    %eax
  800849:	8a 10                	mov    (%eax),%dl
  80084b:	84 d2                	test   %dl,%dl
  80084d:	75 f5                	jne    800844 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085f:	eb 05                	jmp    800866 <strfind+0x10>
		if (*s == c)
  800861:	38 ca                	cmp    %cl,%dl
  800863:	74 07                	je     80086c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800865:	40                   	inc    %eax
  800866:	8a 10                	mov    (%eax),%dl
  800868:	84 d2                	test   %dl,%dl
  80086a:	75 f5                	jne    800861 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	57                   	push   %edi
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 7d 08             	mov    0x8(%ebp),%edi
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087d:	85 c9                	test   %ecx,%ecx
  80087f:	74 30                	je     8008b1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800881:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800887:	75 25                	jne    8008ae <memset+0x40>
  800889:	f6 c1 03             	test   $0x3,%cl
  80088c:	75 20                	jne    8008ae <memset+0x40>
		c &= 0xFF;
  80088e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800891:	89 d3                	mov    %edx,%ebx
  800893:	c1 e3 08             	shl    $0x8,%ebx
  800896:	89 d6                	mov    %edx,%esi
  800898:	c1 e6 18             	shl    $0x18,%esi
  80089b:	89 d0                	mov    %edx,%eax
  80089d:	c1 e0 10             	shl    $0x10,%eax
  8008a0:	09 f0                	or     %esi,%eax
  8008a2:	09 d0                	or     %edx,%eax
  8008a4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a9:	fc                   	cld    
  8008aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ac:	eb 03                	jmp    8008b1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ae:	fc                   	cld    
  8008af:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b1:	89 f8                	mov    %edi,%eax
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5f                   	pop    %edi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c6:	39 c6                	cmp    %eax,%esi
  8008c8:	73 34                	jae    8008fe <memmove+0x46>
  8008ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cd:	39 d0                	cmp    %edx,%eax
  8008cf:	73 2d                	jae    8008fe <memmove+0x46>
		s += n;
		d += n;
  8008d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d4:	f6 c2 03             	test   $0x3,%dl
  8008d7:	75 1b                	jne    8008f4 <memmove+0x3c>
  8008d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008df:	75 13                	jne    8008f4 <memmove+0x3c>
  8008e1:	f6 c1 03             	test   $0x3,%cl
  8008e4:	75 0e                	jne    8008f4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e6:	83 ef 04             	sub    $0x4,%edi
  8008e9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ef:	fd                   	std    
  8008f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f2:	eb 07                	jmp    8008fb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f4:	4f                   	dec    %edi
  8008f5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f8:	fd                   	std    
  8008f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fb:	fc                   	cld    
  8008fc:	eb 20                	jmp    80091e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800904:	75 13                	jne    800919 <memmove+0x61>
  800906:	a8 03                	test   $0x3,%al
  800908:	75 0f                	jne    800919 <memmove+0x61>
  80090a:	f6 c1 03             	test   $0x3,%cl
  80090d:	75 0a                	jne    800919 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800912:	89 c7                	mov    %eax,%edi
  800914:	fc                   	cld    
  800915:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800917:	eb 05                	jmp    80091e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800919:	89 c7                	mov    %eax,%edi
  80091b:	fc                   	cld    
  80091c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091e:	5e                   	pop    %esi
  80091f:	5f                   	pop    %edi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800928:	8b 45 10             	mov    0x10(%ebp),%eax
  80092b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	89 44 24 04          	mov    %eax,0x4(%esp)
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	89 04 24             	mov    %eax,(%esp)
  80093c:	e8 77 ff ff ff       	call   8008b8 <memmove>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	ba 00 00 00 00       	mov    $0x0,%edx
  800957:	eb 16                	jmp    80096f <memcmp+0x2c>
		if (*s1 != *s2)
  800959:	8a 04 17             	mov    (%edi,%edx,1),%al
  80095c:	42                   	inc    %edx
  80095d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800961:	38 c8                	cmp    %cl,%al
  800963:	74 0a                	je     80096f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800965:	0f b6 c0             	movzbl %al,%eax
  800968:	0f b6 c9             	movzbl %cl,%ecx
  80096b:	29 c8                	sub    %ecx,%eax
  80096d:	eb 09                	jmp    800978 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 da                	cmp    %ebx,%edx
  800971:	75 e6                	jne    800959 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800986:	89 c2                	mov    %eax,%edx
  800988:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098b:	eb 05                	jmp    800992 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098d:	38 08                	cmp    %cl,(%eax)
  80098f:	74 05                	je     800996 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800991:	40                   	inc    %eax
  800992:	39 d0                	cmp    %edx,%eax
  800994:	72 f7                	jb     80098d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a4:	eb 01                	jmp    8009a7 <strtol+0xf>
		s++;
  8009a6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	8a 02                	mov    (%edx),%al
  8009a9:	3c 20                	cmp    $0x20,%al
  8009ab:	74 f9                	je     8009a6 <strtol+0xe>
  8009ad:	3c 09                	cmp    $0x9,%al
  8009af:	74 f5                	je     8009a6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b1:	3c 2b                	cmp    $0x2b,%al
  8009b3:	75 08                	jne    8009bd <strtol+0x25>
		s++;
  8009b5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bb:	eb 13                	jmp    8009d0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009bd:	3c 2d                	cmp    $0x2d,%al
  8009bf:	75 0a                	jne    8009cb <strtol+0x33>
		s++, neg = 1;
  8009c1:	8d 52 01             	lea    0x1(%edx),%edx
  8009c4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c9:	eb 05                	jmp    8009d0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d0:	85 db                	test   %ebx,%ebx
  8009d2:	74 05                	je     8009d9 <strtol+0x41>
  8009d4:	83 fb 10             	cmp    $0x10,%ebx
  8009d7:	75 28                	jne    800a01 <strtol+0x69>
  8009d9:	8a 02                	mov    (%edx),%al
  8009db:	3c 30                	cmp    $0x30,%al
  8009dd:	75 10                	jne    8009ef <strtol+0x57>
  8009df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009e3:	75 0a                	jne    8009ef <strtol+0x57>
		s += 2, base = 16;
  8009e5:	83 c2 02             	add    $0x2,%edx
  8009e8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ed:	eb 12                	jmp    800a01 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009ef:	85 db                	test   %ebx,%ebx
  8009f1:	75 0e                	jne    800a01 <strtol+0x69>
  8009f3:	3c 30                	cmp    $0x30,%al
  8009f5:	75 05                	jne    8009fc <strtol+0x64>
		s++, base = 8;
  8009f7:	42                   	inc    %edx
  8009f8:	b3 08                	mov    $0x8,%bl
  8009fa:	eb 05                	jmp    800a01 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009fc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
  800a06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a08:	8a 0a                	mov    (%edx),%cl
  800a0a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a0d:	80 fb 09             	cmp    $0x9,%bl
  800a10:	77 08                	ja     800a1a <strtol+0x82>
			dig = *s - '0';
  800a12:	0f be c9             	movsbl %cl,%ecx
  800a15:	83 e9 30             	sub    $0x30,%ecx
  800a18:	eb 1e                	jmp    800a38 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a1a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a22:	0f be c9             	movsbl %cl,%ecx
  800a25:	83 e9 57             	sub    $0x57,%ecx
  800a28:	eb 0e                	jmp    800a38 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a2a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a2d:	80 fb 19             	cmp    $0x19,%bl
  800a30:	77 12                	ja     800a44 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a32:	0f be c9             	movsbl %cl,%ecx
  800a35:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a38:	39 f1                	cmp    %esi,%ecx
  800a3a:	7d 0c                	jge    800a48 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a3c:	42                   	inc    %edx
  800a3d:	0f af c6             	imul   %esi,%eax
  800a40:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a42:	eb c4                	jmp    800a08 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a44:	89 c1                	mov    %eax,%ecx
  800a46:	eb 02                	jmp    800a4a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a48:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4e:	74 05                	je     800a55 <strtol+0xbd>
		*endptr = (char *) s;
  800a50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a53:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a55:	85 ff                	test   %edi,%edi
  800a57:	74 04                	je     800a5d <strtol+0xc5>
  800a59:	89 c8                	mov    %ecx,%eax
  800a5b:	f7 d8                	neg    %eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    
	...

00800a64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	89 c7                	mov    %eax,%edi
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a92:	89 d1                	mov    %edx,%ecx
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 cb                	mov    %ecx,%ebx
  800ab9:	89 cf                	mov    %ecx,%edi
  800abb:	89 ce                	mov    %ecx,%esi
  800abd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	7e 28                	jle    800aeb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ace:	00 
  800acf:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800ad6:	00 
  800ad7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ade:	00 
  800adf:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800ae6:	e8 5d 02 00 00       	call   800d48 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aeb:	83 c4 2c             	add    $0x2c,%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 02 00 00 00       	mov    $0x2,%eax
  800b03:	89 d1                	mov    %edx,%ecx
  800b05:	89 d3                	mov    %edx,%ebx
  800b07:	89 d7                	mov    %edx,%edi
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_yield>:

void
sys_yield(void)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b22:	89 d1                	mov    %edx,%ecx
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	be 00 00 00 00       	mov    $0x0,%esi
  800b3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 f7                	mov    %esi,%edi
  800b4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	7e 28                	jle    800b7d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b59:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b60:	00 
  800b61:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800b68:	00 
  800b69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b70:	00 
  800b71:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800b78:	e8 cb 01 00 00       	call   800d48 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7d:	83 c4 2c             	add    $0x2c,%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b93:	8b 75 18             	mov    0x18(%ebp),%esi
  800b96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7e 28                	jle    800bd0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bac:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bb3:	00 
  800bb4:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800bbb:	00 
  800bbc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc3:	00 
  800bc4:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800bcb:	e8 78 01 00 00       	call   800d48 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd0:	83 c4 2c             	add    $0x2c,%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be6:	b8 06 00 00 00       	mov    $0x6,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 df                	mov    %ebx,%edi
  800bf3:	89 de                	mov    %ebx,%esi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 28                	jle    800c23 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bff:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800c1e:	e8 25 01 00 00       	call   800d48 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c23:	83 c4 2c             	add    $0x2c,%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 28                	jle    800c76 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c52:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c59:	00 
  800c5a:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800c61:	00 
  800c62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c69:	00 
  800c6a:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800c71:	e8 d2 00 00 00       	call   800d48 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c76:	83 c4 2c             	add    $0x2c,%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 df                	mov    %ebx,%edi
  800c99:	89 de                	mov    %ebx,%esi
  800c9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7e 28                	jle    800cc9 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cac:	00 
  800cad:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800cb4:	00 
  800cb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cbc:	00 
  800cbd:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800cc4:	e8 7f 00 00 00       	call   800d48 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc9:	83 c4 2c             	add    $0x2c,%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	be 00 00 00 00       	mov    $0x0,%esi
  800cdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d02:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 cb                	mov    %ecx,%ebx
  800d0c:	89 cf                	mov    %ecx,%edi
  800d0e:	89 ce                	mov    %ecx,%esi
  800d10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 28                	jle    800d3e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d21:	00 
  800d22:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800d29:	00 
  800d2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d31:	00 
  800d32:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800d39:	e8 0a 00 00 00       	call   800d48 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3e:	83 c4 2c             	add    $0x2c,%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
	...

00800d48 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d50:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d53:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d59:	e8 95 fd ff ff       	call   800af3 <sys_getenvid>
  800d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d61:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d74:	c7 04 24 90 12 80 00 	movl   $0x801290,(%esp)
  800d7b:	e8 14 f4 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d84:	8b 45 10             	mov    0x10(%ebp),%eax
  800d87:	89 04 24             	mov    %eax,(%esp)
  800d8a:	e8 a4 f3 ff ff       	call   800133 <vcprintf>
	cprintf("\n");
  800d8f:	c7 04 24 02 10 80 00 	movl   $0x801002,(%esp)
  800d96:	e8 f9 f3 ff ff       	call   800194 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d9b:	cc                   	int3   
  800d9c:	eb fd                	jmp    800d9b <_panic+0x53>
	...

00800da0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	83 ec 10             	sub    $0x10,%esp
  800da6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800daa:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dae:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800db6:	89 cd                	mov    %ecx,%ebp
  800db8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	75 2c                	jne    800dec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dc0:	39 f9                	cmp    %edi,%ecx
  800dc2:	77 68                	ja     800e2c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dc4:	85 c9                	test   %ecx,%ecx
  800dc6:	75 0b                	jne    800dd3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dc8:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcd:	31 d2                	xor    %edx,%edx
  800dcf:	f7 f1                	div    %ecx
  800dd1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dd3:	31 d2                	xor    %edx,%edx
  800dd5:	89 f8                	mov    %edi,%eax
  800dd7:	f7 f1                	div    %ecx
  800dd9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	f7 f1                	div    %ecx
  800ddf:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de1:	89 f0                	mov    %esi,%eax
  800de3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de5:	83 c4 10             	add    $0x10,%esp
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dec:	39 f8                	cmp    %edi,%eax
  800dee:	77 2c                	ja     800e1c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800df0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800df3:	83 f6 1f             	xor    $0x1f,%esi
  800df6:	75 4c                	jne    800e44 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800df8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dfa:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dff:	72 0a                	jb     800e0b <__udivdi3+0x6b>
  800e01:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e05:	0f 87 ad 00 00 00    	ja     800eb8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e0b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e10:	89 f0                	mov    %esi,%eax
  800e12:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    
  800e1b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e1c:	31 ff                	xor    %edi,%edi
  800e1e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e20:	89 f0                	mov    %esi,%eax
  800e22:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    
  800e2b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e2c:	89 fa                	mov    %edi,%edx
  800e2e:	89 f0                	mov    %esi,%eax
  800e30:	f7 f1                	div    %ecx
  800e32:	89 c6                	mov    %eax,%esi
  800e34:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e36:	89 f0                	mov    %esi,%eax
  800e38:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
  800e41:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e44:	89 f1                	mov    %esi,%ecx
  800e46:	d3 e0                	shl    %cl,%eax
  800e48:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e4c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e51:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e53:	89 ea                	mov    %ebp,%edx
  800e55:	88 c1                	mov    %al,%cl
  800e57:	d3 ea                	shr    %cl,%edx
  800e59:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e5d:	09 ca                	or     %ecx,%edx
  800e5f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e63:	89 f1                	mov    %esi,%ecx
  800e65:	d3 e5                	shl    %cl,%ebp
  800e67:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e6b:	89 fd                	mov    %edi,%ebp
  800e6d:	88 c1                	mov    %al,%cl
  800e6f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e71:	89 fa                	mov    %edi,%edx
  800e73:	89 f1                	mov    %esi,%ecx
  800e75:	d3 e2                	shl    %cl,%edx
  800e77:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e7b:	88 c1                	mov    %al,%cl
  800e7d:	d3 ef                	shr    %cl,%edi
  800e7f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e81:	89 f8                	mov    %edi,%eax
  800e83:	89 ea                	mov    %ebp,%edx
  800e85:	f7 74 24 08          	divl   0x8(%esp)
  800e89:	89 d1                	mov    %edx,%ecx
  800e8b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e8d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e91:	39 d1                	cmp    %edx,%ecx
  800e93:	72 17                	jb     800eac <__udivdi3+0x10c>
  800e95:	74 09                	je     800ea0 <__udivdi3+0x100>
  800e97:	89 fe                	mov    %edi,%esi
  800e99:	31 ff                	xor    %edi,%edi
  800e9b:	e9 41 ff ff ff       	jmp    800de1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ea0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea4:	89 f1                	mov    %esi,%ecx
  800ea6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea8:	39 c2                	cmp    %eax,%edx
  800eaa:	73 eb                	jae    800e97 <__udivdi3+0xf7>
		{
		  q0--;
  800eac:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eaf:	31 ff                	xor    %edi,%edi
  800eb1:	e9 2b ff ff ff       	jmp    800de1 <__udivdi3+0x41>
  800eb6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eb8:	31 f6                	xor    %esi,%esi
  800eba:	e9 22 ff ff ff       	jmp    800de1 <__udivdi3+0x41>
	...

00800ec0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	83 ec 20             	sub    $0x20,%esp
  800ec6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800eca:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ece:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ed2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800ed6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eda:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ede:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ee0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ee2:	85 ed                	test   %ebp,%ebp
  800ee4:	75 16                	jne    800efc <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800ee6:	39 f1                	cmp    %esi,%ecx
  800ee8:	0f 86 a6 00 00 00    	jbe    800f94 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eee:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ef0:	89 d0                	mov    %edx,%eax
  800ef2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ef4:	83 c4 20             	add    $0x20,%esp
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    
  800efb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800efc:	39 f5                	cmp    %esi,%ebp
  800efe:	0f 87 ac 00 00 00    	ja     800fb0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f04:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f07:	83 f0 1f             	xor    $0x1f,%eax
  800f0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0e:	0f 84 a8 00 00 00    	je     800fbc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f14:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f18:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f1a:	bf 20 00 00 00       	mov    $0x20,%edi
  800f1f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f23:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f27:	89 f9                	mov    %edi,%ecx
  800f29:	d3 e8                	shr    %cl,%eax
  800f2b:	09 e8                	or     %ebp,%eax
  800f2d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f35:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f39:	d3 e0                	shl    %cl,%eax
  800f3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f43:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f47:	d3 e0                	shl    %cl,%eax
  800f49:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f4d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f51:	89 f9                	mov    %edi,%ecx
  800f53:	d3 e8                	shr    %cl,%eax
  800f55:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f57:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f59:	89 f2                	mov    %esi,%edx
  800f5b:	f7 74 24 18          	divl   0x18(%esp)
  800f5f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f61:	f7 64 24 0c          	mull   0xc(%esp)
  800f65:	89 c5                	mov    %eax,%ebp
  800f67:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f69:	39 d6                	cmp    %edx,%esi
  800f6b:	72 67                	jb     800fd4 <__umoddi3+0x114>
  800f6d:	74 75                	je     800fe4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f6f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f73:	29 e8                	sub    %ebp,%eax
  800f75:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f77:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f7b:	d3 e8                	shr    %cl,%eax
  800f7d:	89 f2                	mov    %esi,%edx
  800f7f:	89 f9                	mov    %edi,%ecx
  800f81:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f83:	09 d0                	or     %edx,%eax
  800f85:	89 f2                	mov    %esi,%edx
  800f87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f8b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f8d:	83 c4 20             	add    $0x20,%esp
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f94:	85 c9                	test   %ecx,%ecx
  800f96:	75 0b                	jne    800fa3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f98:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	f7 f1                	div    %ecx
  800fa1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fa3:	89 f0                	mov    %esi,%eax
  800fa5:	31 d2                	xor    %edx,%edx
  800fa7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	e9 3e ff ff ff       	jmp    800eee <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fb0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    
  800fb9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fbc:	39 f5                	cmp    %esi,%ebp
  800fbe:	72 04                	jb     800fc4 <__umoddi3+0x104>
  800fc0:	39 f9                	cmp    %edi,%ecx
  800fc2:	77 06                	ja     800fca <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fc4:	89 f2                	mov    %esi,%edx
  800fc6:	29 cf                	sub    %ecx,%edi
  800fc8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fca:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fcc:	83 c4 20             	add    $0x20,%esp
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    
  800fd3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fd4:	89 d1                	mov    %edx,%ecx
  800fd6:	89 c5                	mov    %eax,%ebp
  800fd8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fdc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fe0:	eb 8d                	jmp    800f6f <__umoddi3+0xaf>
  800fe2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fe8:	72 ea                	jb     800fd4 <__umoddi3+0x114>
  800fea:	89 f1                	mov    %esi,%ecx
  800fec:	eb 81                	jmp    800f6f <__umoddi3+0xaf>
