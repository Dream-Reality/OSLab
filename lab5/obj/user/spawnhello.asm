
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 67 00 00 00       	call   800098 <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 00                	mov    (%eax),%eax
  800041:	8b 40 48             	mov    0x48(%eax),%eax
  800044:	89 44 24 04          	mov    %eax,0x4(%esp)
  800048:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  80004f:	e8 b0 01 00 00       	call   800204 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800054:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80005b:	00 
  80005c:	c7 44 24 04 3e 26 80 	movl   $0x80263e,0x4(%esp)
  800063:	00 
  800064:	c7 04 24 3e 26 80 00 	movl   $0x80263e,(%esp)
  80006b:	e8 5e 1c 00 00       	call   801cce <spawnl>
  800070:	85 c0                	test   %eax,%eax
  800072:	79 20                	jns    800094 <umain+0x60>
		panic("spawn(hello) failed: %e", r);
  800074:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800078:	c7 44 24 08 44 26 80 	movl   $0x802644,0x8(%esp)
  80007f:	00 
  800080:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800087:	00 
  800088:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  80008f:	e8 78 00 00 00       	call   80010c <_panic>
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	56                   	push   %esi
  80009c:	53                   	push   %ebx
  80009d:	83 ec 20             	sub    $0x20,%esp
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8000a6:	e8 b8 0a 00 00       	call   800b63 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b7:	c1 e0 07             	shl    $0x7,%eax
  8000ba:	29 d0                	sub    %edx,%eax
  8000bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c7:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cc:	85 f6                	test   %esi,%esi
  8000ce:	7e 07                	jle    8000d7 <libmain+0x3f>
		binaryname = argv[0];
  8000d0:	8b 03                	mov    (%ebx),%eax
  8000d2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000db:	89 34 24             	mov    %esi,(%esp)
  8000de:	e8 51 ff ff ff       	call   800034 <umain>

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
	close_all();
  8000f6:	e8 fa 0e 00 00       	call   800ff5 <close_all>
	sys_env_destroy(0);
  8000fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800102:	e8 0a 0a 00 00       	call   800b11 <sys_env_destroy>
}
  800107:	c9                   	leave  
  800108:	c3                   	ret    
  800109:	00 00                	add    %al,(%eax)
	...

0080010c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800114:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800117:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80011d:	e8 41 0a 00 00       	call   800b63 <sys_getenvid>
  800122:	8b 55 0c             	mov    0xc(%ebp),%edx
  800125:	89 54 24 10          	mov    %edx,0x10(%esp)
  800129:	8b 55 08             	mov    0x8(%ebp),%edx
  80012c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800130:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	c7 04 24 78 26 80 00 	movl   $0x802678,(%esp)
  80013f:	e8 c0 00 00 00       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800144:	89 74 24 04          	mov    %esi,0x4(%esp)
  800148:	8b 45 10             	mov    0x10(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
  80014e:	e8 50 00 00 00       	call   8001a3 <vcprintf>
	cprintf("\n");
  800153:	c7 04 24 63 2b 80 00 	movl   $0x802b63,(%esp)
  80015a:	e8 a5 00 00 00       	call   800204 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015f:	cc                   	int3   
  800160:	eb fd                	jmp    80015f <_panic+0x53>
	...

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 14             	sub    $0x14,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 03                	mov    (%ebx),%eax
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800177:	40                   	inc    %eax
  800178:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017f:	75 19                	jne    80019a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800181:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800188:	00 
  800189:	8d 43 08             	lea    0x8(%ebx),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 40 09 00 00       	call   800ad4 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019a:	ff 43 04             	incl   0x4(%ebx)
}
  80019d:	83 c4 14             	add    $0x14,%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	c7 04 24 64 01 80 00 	movl   $0x800164,(%esp)
  8001df:	e8 82 01 00 00       	call   800366 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 d8 08 00 00       	call   800ad4 <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	e8 87 ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	85 c0                	test   %eax,%eax
  800242:	75 08                	jne    80024c <printnum+0x2c>
  800244:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 57                	ja     8002a3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800250:	4b                   	dec    %ebx
  800251:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800260:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800264:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026b:	00 
  80026c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	e8 36 21 00 00       	call   8023b4 <__udivdi3>
  80027e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800282:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028d:	89 fa                	mov    %edi,%edx
  80028f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800292:	e8 89 ff ff ff       	call   800220 <printnum>
  800297:	eb 0f                	jmp    8002a8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029d:	89 34 24             	mov    %esi,(%esp)
  8002a0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a3:	4b                   	dec    %ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f f1                	jg     800299 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002be:	00 
  8002bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	e8 03 22 00 00       	call   8024d4 <__umoddi3>
  8002d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d5:	0f be 80 9b 26 80 00 	movsbl 0x80269b(%eax),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e2:	83 c4 3c             	add    $0x3c,%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7e 0e                	jle    800300 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x38>
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 10                	je     800314 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 08                	jae    80033c <sprintputch+0x18>
		*b->buf++ = ch;
  800334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800337:	88 0a                	mov    %cl,(%edx)
  800339:	42                   	inc    %edx
  80033a:	89 10                	mov    %edx,(%eax)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034b:	8b 45 10             	mov    0x10(%ebp),%eax
  80034e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
  800355:	89 44 24 04          	mov    %eax,0x4(%esp)
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	e8 02 00 00 00       	call   800366 <vprintfmt>
	va_end(ap);
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 4c             	sub    $0x4c,%esp
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800372:	8b 75 10             	mov    0x10(%ebp),%esi
  800375:	eb 12                	jmp    800389 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800377:	85 c0                	test   %eax,%eax
  800379:	0f 84 6b 03 00 00    	je     8006ea <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80037f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800389:	0f b6 06             	movzbl (%esi),%eax
  80038c:	46                   	inc    %esi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e5                	jne    800377 <vprintfmt+0x11>
  800392:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800396:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80039d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ae:	eb 26                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003b7:	eb 1d                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c0:	eb 14                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cc:	eb 08                	jmp    8003d6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	0f b6 06             	movzbl (%esi),%eax
  8003d9:	8d 56 01             	lea    0x1(%esi),%edx
  8003dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003df:	8a 16                	mov    (%esi),%dl
  8003e1:	83 ea 23             	sub    $0x23,%edx
  8003e4:	80 fa 55             	cmp    $0x55,%dl
  8003e7:	0f 87 e1 02 00 00    	ja     8006ce <vprintfmt+0x368>
  8003ed:	0f b6 d2             	movzbl %dl,%edx
  8003f0:	ff 24 95 e0 27 80 00 	jmp    *0x8027e0(,%edx,4)
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800402:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800406:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800409:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040c:	83 fa 09             	cmp    $0x9,%edx
  80040f:	77 2a                	ja     80043b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800412:	eb eb                	jmp    8003ff <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800422:	eb 17                	jmp    80043b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800424:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800428:	78 98                	js     8003c2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042d:	eb a7                	jmp    8003d6 <vprintfmt+0x70>
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800432:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800439:	eb 9b                	jmp    8003d6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043f:	79 95                	jns    8003d6 <vprintfmt+0x70>
  800441:	eb 8b                	jmp    8003ce <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800443:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800447:	eb 8d                	jmp    8003d6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800461:	e9 23 ff ff ff       	jmp    800389 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	79 02                	jns    800477 <vprintfmt+0x111>
  800475:	f7 d8                	neg    %eax
  800477:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800479:	83 f8 0f             	cmp    $0xf,%eax
  80047c:	7f 0b                	jg     800489 <vprintfmt+0x123>
  80047e:	8b 04 85 40 29 80 00 	mov    0x802940(,%eax,4),%eax
  800485:	85 c0                	test   %eax,%eax
  800487:	75 23                	jne    8004ac <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800489:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048d:	c7 44 24 08 b3 26 80 	movl   $0x8026b3,0x8(%esp)
  800494:	00 
  800495:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 9a fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a7:	e9 dd fe ff ff       	jmp    800389 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b0:	c7 44 24 08 71 2a 80 	movl   $0x802a71,0x8(%esp)
  8004b7:	00 
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	89 14 24             	mov    %edx,(%esp)
  8004c2:	e8 77 fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ca:	e9 ba fe ff ff       	jmp    800389 <vprintfmt+0x23>
  8004cf:	89 f9                	mov    %edi,%ecx
  8004d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	8b 30                	mov    (%eax),%esi
  8004e2:	85 f6                	test   %esi,%esi
  8004e4:	75 05                	jne    8004eb <vprintfmt+0x185>
				p = "(null)";
  8004e6:	be ac 26 80 00       	mov    $0x8026ac,%esi
			if (width > 0 && padc != '-')
  8004eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ef:	0f 8e 84 00 00 00    	jle    800579 <vprintfmt+0x213>
  8004f5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f9:	74 7e                	je     800579 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ff:	89 34 24             	mov    %esi,(%esp)
  800502:	e8 8b 02 00 00       	call   800792 <strnlen>
  800507:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80050f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800513:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800516:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800519:	89 de                	mov    %ebx,%esi
  80051b:	89 d3                	mov    %edx,%ebx
  80051d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0b                	jmp    80052c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800521:	89 74 24 04          	mov    %esi,0x4(%esp)
  800525:	89 3c 24             	mov    %edi,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	4b                   	dec    %ebx
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	7f f1                	jg     800521 <vprintfmt+0x1bb>
  800530:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800533:	89 f3                	mov    %esi,%ebx
  800535:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800538:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053b:	85 c0                	test   %eax,%eax
  80053d:	79 05                	jns    800544 <vprintfmt+0x1de>
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800547:	29 c2                	sub    %eax,%edx
  800549:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054c:	eb 2b                	jmp    800579 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800552:	74 18                	je     80056c <vprintfmt+0x206>
  800554:	8d 50 e0             	lea    -0x20(%eax),%edx
  800557:	83 fa 5e             	cmp    $0x5e,%edx
  80055a:	76 10                	jbe    80056c <vprintfmt+0x206>
					putch('?', putdat);
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
  80056a:	eb 0a                	jmp    800576 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	ff 4d e4             	decl   -0x1c(%ebp)
  800579:	0f be 06             	movsbl (%esi),%eax
  80057c:	46                   	inc    %esi
  80057d:	85 c0                	test   %eax,%eax
  80057f:	74 21                	je     8005a2 <vprintfmt+0x23c>
  800581:	85 ff                	test   %edi,%edi
  800583:	78 c9                	js     80054e <vprintfmt+0x1e8>
  800585:	4f                   	dec    %edi
  800586:	79 c6                	jns    80054e <vprintfmt+0x1e8>
  800588:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058b:	89 de                	mov    %ebx,%esi
  80058d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800590:	eb 18                	jmp    8005aa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800592:	89 74 24 04          	mov    %esi,0x4(%esp)
  800596:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	4b                   	dec    %ebx
  8005a0:	eb 08                	jmp    8005aa <vprintfmt+0x244>
  8005a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a5:	89 de                	mov    %ebx,%esi
  8005a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005aa:	85 db                	test   %ebx,%ebx
  8005ac:	7f e4                	jg     800592 <vprintfmt+0x22c>
  8005ae:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b6:	e9 ce fd ff ff       	jmp    800389 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 f9 01             	cmp    $0x1,%ecx
  8005be:	7e 10                	jle    8005d0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	8b 78 04             	mov    0x4(%eax),%edi
  8005ce:	eb 26                	jmp    8005f6 <vprintfmt+0x290>
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 12                	je     8005e6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 30                	mov    (%eax),%esi
  8005df:	89 f7                	mov    %esi,%edi
  8005e1:	c1 ff 1f             	sar    $0x1f,%edi
  8005e4:	eb 10                	jmp    8005f6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 30                	mov    (%eax),%esi
  8005f1:	89 f7                	mov    %esi,%edi
  8005f3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f6:	85 ff                	test   %edi,%edi
  8005f8:	78 0a                	js     800604 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ff:	e9 8c 00 00 00       	jmp    800690 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800612:	f7 de                	neg    %esi
  800614:	83 d7 00             	adc    $0x0,%edi
  800617:	f7 df                	neg    %edi
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	eb 70                	jmp    800690 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 c0 fc ff ff       	call   8002ea <getuint>
  80062a:	89 c6                	mov    %eax,%esi
  80062c:	89 d7                	mov    %edx,%edi
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800633:	eb 5b                	jmp    800690 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800635:	89 ca                	mov    %ecx,%edx
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 ab fc ff ff       	call   8002ea <getuint>
  80063f:	89 c6                	mov    %eax,%esi
  800641:	89 d7                	mov    %edx,%edi
			base = 8;
  800643:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800648:	eb 46                	jmp    800690 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066f:	8b 30                	mov    (%eax),%esi
  800671:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800676:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067b:	eb 13                	jmp    800690 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 63 fc ff ff       	call   8002ea <getuint>
  800687:	89 c6                	mov    %eax,%esi
  800689:	89 d7                	mov    %edx,%edi
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800694:	89 54 24 10          	mov    %edx,0x10(%esp)
  800698:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a3:	89 34 24             	mov    %esi,(%esp)
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	e8 6c fb ff ff       	call   800220 <printnum>
			break;
  8006b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b7:	e9 cd fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c9:	e9 bb fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	eb 01                	jmp    8006df <vprintfmt+0x379>
  8006de:	4e                   	dec    %esi
  8006df:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e3:	75 f9                	jne    8006de <vprintfmt+0x378>
  8006e5:	e9 9f fc ff ff       	jmp    800389 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ea:	83 c4 4c             	add    $0x4c,%esp
  8006ed:	5b                   	pop    %ebx
  8006ee:	5e                   	pop    %esi
  8006ef:	5f                   	pop    %edi
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 28             	sub    $0x28,%esp
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800701:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800705:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800708:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 30                	je     800743 <vsnprintf+0x51>
  800713:	85 d2                	test   %edx,%edx
  800715:	7e 33                	jle    80074a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071e:	8b 45 10             	mov    0x10(%ebp),%eax
  800721:	89 44 24 08          	mov    %eax,0x8(%esp)
  800725:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	c7 04 24 24 03 80 00 	movl   $0x800324,(%esp)
  800733:	e8 2e fc ff ff       	call   800366 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	eb 0c                	jmp    80074f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800748:	eb 05                	jmp    80074f <vsnprintf+0x5d>
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074f:	c9                   	leave  
  800750:	c3                   	ret    

00800751 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 7b ff ff ff       	call   8006f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800777:	c9                   	leave  
  800778:	c3                   	ret    
  800779:	00 00                	add    %al,(%eax)
	...

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	eb 01                	jmp    80078a <strlen+0xe>
		n++;
  800789:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078e:	75 f9                	jne    800789 <strlen+0xd>
		n++;
	return n;
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	eb 01                	jmp    8007a3 <strnlen+0x11>
		n++;
  8007a2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	39 d0                	cmp    %edx,%eax
  8007a5:	74 06                	je     8007ad <strnlen+0x1b>
  8007a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ab:	75 f5                	jne    8007a2 <strnlen+0x10>
		n++;
	return n;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007be:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c4:	42                   	inc    %edx
  8007c5:	84 c9                	test   %cl,%cl
  8007c7:	75 f5                	jne    8007be <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d6:	89 1c 24             	mov    %ebx,(%esp)
  8007d9:	e8 9e ff ff ff       	call   80077c <strlen>
	strcpy(dst + len, src);
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e5:	01 d8                	add    %ebx,%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	e8 c0 ff ff ff       	call   8007af <strcpy>
	return dst;
}
  8007ef:	89 d8                	mov    %ebx,%eax
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080a:	eb 0c                	jmp    800818 <strncpy+0x21>
		*dst++ = *src;
  80080c:	8a 1a                	mov    (%edx),%bl
  80080e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800811:	80 3a 01             	cmpb   $0x1,(%edx)
  800814:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800817:	41                   	inc    %ecx
  800818:	39 f1                	cmp    %esi,%ecx
  80081a:	75 f0                	jne    80080c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 75 08             	mov    0x8(%ebp),%esi
  800828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082e:	85 d2                	test   %edx,%edx
  800830:	75 0a                	jne    80083c <strlcpy+0x1c>
  800832:	89 f0                	mov    %esi,%eax
  800834:	eb 1a                	jmp    800850 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	88 18                	mov    %bl,(%eax)
  800838:	40                   	inc    %eax
  800839:	41                   	inc    %ecx
  80083a:	eb 02                	jmp    80083e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80083e:	4a                   	dec    %edx
  80083f:	74 0a                	je     80084b <strlcpy+0x2b>
  800841:	8a 19                	mov    (%ecx),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	75 ef                	jne    800836 <strlcpy+0x16>
  800847:	89 c2                	mov    %eax,%edx
  800849:	eb 02                	jmp    80084d <strlcpy+0x2d>
  80084b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 02                	jmp    800863 <strcmp+0xd>
		p++, q++;
  800861:	41                   	inc    %ecx
  800862:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800863:	8a 01                	mov    (%ecx),%al
  800865:	84 c0                	test   %al,%al
  800867:	74 04                	je     80086d <strcmp+0x17>
  800869:	3a 02                	cmp    (%edx),%al
  80086b:	74 f4                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 c0             	movzbl %al,%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800884:	eb 03                	jmp    800889 <strncmp+0x12>
		n--, p++, q++;
  800886:	4a                   	dec    %edx
  800887:	40                   	inc    %eax
  800888:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 14                	je     8008a1 <strncmp+0x2a>
  80088d:	8a 18                	mov    (%eax),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	74 04                	je     800897 <strncmp+0x20>
  800893:	3a 19                	cmp    (%ecx),%bl
  800895:	74 ef                	je     800886 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 00             	movzbl (%eax),%eax
  80089a:	0f b6 11             	movzbl (%ecx),%edx
  80089d:	29 d0                	sub    %edx,%eax
  80089f:	eb 05                	jmp    8008a6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b2:	eb 05                	jmp    8008b9 <strchr+0x10>
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 0c                	je     8008c4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b8:	40                   	inc    %eax
  8008b9:	8a 10                	mov    (%eax),%dl
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f5                	jne    8008b4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cf:	eb 05                	jmp    8008d6 <strfind+0x10>
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 07                	je     8008dc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d5:	40                   	inc    %eax
  8008d6:	8a 10                	mov    (%eax),%dl
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f5                	jne    8008d1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	57                   	push   %edi
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 30                	je     800921 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 25                	jne    80091e <memset+0x40>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 20                	jne    80091e <memset+0x40>
		c &= 0xFF;
  8008fe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 08             	shl    $0x8,%ebx
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 18             	shl    $0x18,%esi
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	c1 e0 10             	shl    $0x10,%eax
  800910:	09 f0                	or     %esi,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800916:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800919:	fc                   	cld    
  80091a:	f3 ab                	rep stos %eax,%es:(%edi)
  80091c:	eb 03                	jmp    800921 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 34                	jae    80096e <memmove+0x46>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 d0                	cmp    %edx,%eax
  80093f:	73 2d                	jae    80096e <memmove+0x46>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	f6 c2 03             	test   $0x3,%dl
  800947:	75 1b                	jne    800964 <memmove+0x3c>
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 13                	jne    800964 <memmove+0x3c>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 07                	jmp    80096b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800964:	4f                   	dec    %edi
  800965:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800968:	fd                   	std    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096b:	fc                   	cld    
  80096c:	eb 20                	jmp    80098e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800974:	75 13                	jne    800989 <memmove+0x61>
  800976:	a8 03                	test   $0x3,%al
  800978:	75 0f                	jne    800989 <memmove+0x61>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0a                	jne    800989 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800998:	8b 45 10             	mov    0x10(%ebp),%eax
  80099b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 77 ff ff ff       	call   800928 <memmove>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c7:	eb 16                	jmp    8009df <memcmp+0x2c>
		if (*s1 != *s2)
  8009c9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009cc:	42                   	inc    %edx
  8009cd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009d1:	38 c8                	cmp    %cl,%al
  8009d3:	74 0a                	je     8009df <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c0             	movzbl %al,%eax
  8009d8:	0f b6 c9             	movzbl %cl,%ecx
  8009db:	29 c8                	sub    %ecx,%eax
  8009dd:	eb 09                	jmp    8009e8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009df:	39 da                	cmp    %ebx,%edx
  8009e1:	75 e6                	jne    8009c9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f6:	89 c2                	mov    %eax,%edx
  8009f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fb:	eb 05                	jmp    800a02 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	38 08                	cmp    %cl,(%eax)
  8009ff:	74 05                	je     800a06 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	40                   	inc    %eax
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	72 f7                	jb     8009fd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	eb 01                	jmp    800a17 <strtol+0xf>
		s++;
  800a16:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	8a 02                	mov    (%edx),%al
  800a19:	3c 20                	cmp    $0x20,%al
  800a1b:	74 f9                	je     800a16 <strtol+0xe>
  800a1d:	3c 09                	cmp    $0x9,%al
  800a1f:	74 f5                	je     800a16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a21:	3c 2b                	cmp    $0x2b,%al
  800a23:	75 08                	jne    800a2d <strtol+0x25>
		s++;
  800a25:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	eb 13                	jmp    800a40 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2d:	3c 2d                	cmp    $0x2d,%al
  800a2f:	75 0a                	jne    800a3b <strtol+0x33>
		s++, neg = 1;
  800a31:	8d 52 01             	lea    0x1(%edx),%edx
  800a34:	bf 01 00 00 00       	mov    $0x1,%edi
  800a39:	eb 05                	jmp    800a40 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	74 05                	je     800a49 <strtol+0x41>
  800a44:	83 fb 10             	cmp    $0x10,%ebx
  800a47:	75 28                	jne    800a71 <strtol+0x69>
  800a49:	8a 02                	mov    (%edx),%al
  800a4b:	3c 30                	cmp    $0x30,%al
  800a4d:	75 10                	jne    800a5f <strtol+0x57>
  800a4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a53:	75 0a                	jne    800a5f <strtol+0x57>
		s += 2, base = 16;
  800a55:	83 c2 02             	add    $0x2,%edx
  800a58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5d:	eb 12                	jmp    800a71 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	75 0e                	jne    800a71 <strtol+0x69>
  800a63:	3c 30                	cmp    $0x30,%al
  800a65:	75 05                	jne    800a6c <strtol+0x64>
		s++, base = 8;
  800a67:	42                   	inc    %edx
  800a68:	b3 08                	mov    $0x8,%bl
  800a6a:	eb 05                	jmp    800a71 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a78:	8a 0a                	mov    (%edx),%cl
  800a7a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a7d:	80 fb 09             	cmp    $0x9,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x82>
			dig = *s - '0';
  800a82:	0f be c9             	movsbl %cl,%ecx
  800a85:	83 e9 30             	sub    $0x30,%ecx
  800a88:	eb 1e                	jmp    800aa8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a8a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 57             	sub    $0x57,%ecx
  800a98:	eb 0e                	jmp    800aa8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a9d:	80 fb 19             	cmp    $0x19,%bl
  800aa0:	77 12                	ja     800ab4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa8:	39 f1                	cmp    %esi,%ecx
  800aaa:	7d 0c                	jge    800ab8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aac:	42                   	inc    %edx
  800aad:	0f af c6             	imul   %esi,%eax
  800ab0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab2:	eb c4                	jmp    800a78 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab4:	89 c1                	mov    %eax,%ecx
  800ab6:	eb 02                	jmp    800aba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abe:	74 05                	je     800ac5 <strtol+0xbd>
		*endptr = (char *) s;
  800ac0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	74 04                	je     800acd <strtol+0xc5>
  800ac9:	89 c8                	mov    %ecx,%eax
  800acb:	f7 d8                	neg    %eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    
	...

00800ad4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	89 c6                	mov    %eax,%esi
  800aeb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 cb                	mov    %ecx,%ebx
  800b29:	89 cf                	mov    %ecx,%edi
  800b2b:	89 ce                	mov    %ecx,%esi
  800b2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	7e 28                	jle    800b5b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b37:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800b46:	00 
  800b47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4e:	00 
  800b4f:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800b56:	e8 b1 f5 ff ff       	call   80010c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5b:	83 c4 2c             	add    $0x2c,%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b73:	89 d1                	mov    %edx,%ecx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	89 d7                	mov    %edx,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_yield>:

void
sys_yield(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	be 00 00 00 00       	mov    $0x0,%esi
  800baf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 f7                	mov    %esi,%edi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 28                	jle    800bed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800bd8:	00 
  800bd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be0:	00 
  800be1:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800be8:	e8 1f f5 ff ff       	call   80010c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bed:	83 c4 2c             	add    $0x2c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 28                	jle    800c40 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c23:	00 
  800c24:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800c2b:	00 
  800c2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c33:	00 
  800c34:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800c3b:	e8 cc f4 ff ff       	call   80010c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	83 c4 2c             	add    $0x2c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 28                	jle    800c93 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c76:	00 
  800c77:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c86:	00 
  800c87:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800c8e:	e8 79 f4 ff ff       	call   80010c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c93:	83 c4 2c             	add    $0x2c,%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 df                	mov    %ebx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 28                	jle    800ce6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc9:	00 
  800cca:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800cd1:	00 
  800cd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd9:	00 
  800cda:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800ce1:	e8 26 f4 ff ff       	call   80010c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce6:	83 c4 2c             	add    $0x2c,%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 09 00 00 00       	mov    $0x9,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 28                	jle    800d39 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d15:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800d24:	00 
  800d25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2c:	00 
  800d2d:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800d34:	e8 d3 f3 ff ff       	call   80010c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d39:	83 c4 2c             	add    $0x2c,%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 df                	mov    %ebx,%edi
  800d5c:	89 de                	mov    %ebx,%esi
  800d5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 28                	jle    800d8c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d68:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d6f:	00 
  800d70:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800d77:	00 
  800d78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7f:	00 
  800d80:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800d87:	e8 80 f3 ff ff       	call   80010c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8c:	83 c4 2c             	add    $0x2c,%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	be 00 00 00 00       	mov    $0x0,%esi
  800d9f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 cb                	mov    %ecx,%ebx
  800dcf:	89 cf                	mov    %ecx,%edi
  800dd1:	89 ce                	mov    %ecx,%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800dfc:	e8 0b f3 ff ff       	call   80010c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	83 c4 2c             	add    $0x2c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    
  800e09:	00 00                	add    %al,(%eax)
	...

00800e0c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	05 00 00 00 30       	add    $0x30000000,%eax
  800e17:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	89 04 24             	mov    %eax,(%esp)
  800e28:	e8 df ff ff ff       	call   800e0c <fd2num>
  800e2d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e32:	c1 e0 0c             	shl    $0xc,%eax
}
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    

00800e37 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	53                   	push   %ebx
  800e3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e3e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e43:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e45:	89 c2                	mov    %eax,%edx
  800e47:	c1 ea 16             	shr    $0x16,%edx
  800e4a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e51:	f6 c2 01             	test   $0x1,%dl
  800e54:	74 11                	je     800e67 <fd_alloc+0x30>
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	c1 ea 0c             	shr    $0xc,%edx
  800e5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e62:	f6 c2 01             	test   $0x1,%dl
  800e65:	75 09                	jne    800e70 <fd_alloc+0x39>
			*fd_store = fd;
  800e67:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e69:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6e:	eb 17                	jmp    800e87 <fd_alloc+0x50>
  800e70:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e75:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e7a:	75 c7                	jne    800e43 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e82:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e87:	5b                   	pop    %ebx
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e90:	83 f8 1f             	cmp    $0x1f,%eax
  800e93:	77 36                	ja     800ecb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e95:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e9a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	c1 ea 16             	shr    $0x16,%edx
  800ea2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea9:	f6 c2 01             	test   $0x1,%dl
  800eac:	74 24                	je     800ed2 <fd_lookup+0x48>
  800eae:	89 c2                	mov    %eax,%edx
  800eb0:	c1 ea 0c             	shr    $0xc,%edx
  800eb3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eba:	f6 c2 01             	test   $0x1,%dl
  800ebd:	74 1a                	je     800ed9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ebf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec2:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec9:	eb 13                	jmp    800ede <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ecb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed0:	eb 0c                	jmp    800ede <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed7:	eb 05                	jmp    800ede <fd_lookup+0x54>
  800ed9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 14             	sub    $0x14,%esp
  800ee7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800eed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef2:	eb 0e                	jmp    800f02 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ef4:	39 08                	cmp    %ecx,(%eax)
  800ef6:	75 09                	jne    800f01 <dev_lookup+0x21>
			*dev = devtab[i];
  800ef8:	89 03                	mov    %eax,(%ebx)
			return 0;
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 35                	jmp    800f36 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f01:	42                   	inc    %edx
  800f02:	8b 04 95 48 2a 80 00 	mov    0x802a48(,%edx,4),%eax
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	75 e7                	jne    800ef4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f0d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f12:	8b 00                	mov    (%eax),%eax
  800f14:	8b 40 48             	mov    0x48(%eax),%eax
  800f17:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f1f:	c7 04 24 cc 29 80 00 	movl   $0x8029cc,(%esp)
  800f26:	e8 d9 f2 ff ff       	call   800204 <cprintf>
	*dev = 0;
  800f2b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f36:	83 c4 14             	add    $0x14,%esp
  800f39:	5b                   	pop    %ebx
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	83 ec 30             	sub    $0x30,%esp
  800f44:	8b 75 08             	mov    0x8(%ebp),%esi
  800f47:	8a 45 0c             	mov    0xc(%ebp),%al
  800f4a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f4d:	89 34 24             	mov    %esi,(%esp)
  800f50:	e8 b7 fe ff ff       	call   800e0c <fd2num>
  800f55:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f58:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f5c:	89 04 24             	mov    %eax,(%esp)
  800f5f:	e8 26 ff ff ff       	call   800e8a <fd_lookup>
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 05                	js     800f6f <fd_close+0x33>
	    || fd != fd2)
  800f6a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f6d:	74 0d                	je     800f7c <fd_close+0x40>
		return (must_exist ? r : 0);
  800f6f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f73:	75 46                	jne    800fbb <fd_close+0x7f>
  800f75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7a:	eb 3f                	jmp    800fbb <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f83:	8b 06                	mov    (%esi),%eax
  800f85:	89 04 24             	mov    %eax,(%esp)
  800f88:	e8 53 ff ff ff       	call   800ee0 <dev_lookup>
  800f8d:	89 c3                	mov    %eax,%ebx
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 18                	js     800fab <fd_close+0x6f>
		if (dev->dev_close)
  800f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f96:	8b 40 10             	mov    0x10(%eax),%eax
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	74 09                	je     800fa6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f9d:	89 34 24             	mov    %esi,(%esp)
  800fa0:	ff d0                	call   *%eax
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	eb 05                	jmp    800fab <fd_close+0x6f>
		else
			r = 0;
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fab:	89 74 24 04          	mov    %esi,0x4(%esp)
  800faf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb6:	e8 8d fc ff ff       	call   800c48 <sys_page_unmap>
	return r;
}
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	83 c4 30             	add    $0x30,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd4:	89 04 24             	mov    %eax,(%esp)
  800fd7:	e8 ae fe ff ff       	call   800e8a <fd_lookup>
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 13                	js     800ff3 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800fe0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fe7:	00 
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 49 ff ff ff       	call   800f3c <fd_close>
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <close_all>:

void
close_all(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801001:	89 1c 24             	mov    %ebx,(%esp)
  801004:	e8 bb ff ff ff       	call   800fc4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801009:	43                   	inc    %ebx
  80100a:	83 fb 20             	cmp    $0x20,%ebx
  80100d:	75 f2                	jne    801001 <close_all+0xc>
		close(i);
}
  80100f:	83 c4 14             	add    $0x14,%esp
  801012:	5b                   	pop    %ebx
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
  80101b:	83 ec 4c             	sub    $0x4c,%esp
  80101e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801021:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801024:	89 44 24 04          	mov    %eax,0x4(%esp)
  801028:	8b 45 08             	mov    0x8(%ebp),%eax
  80102b:	89 04 24             	mov    %eax,(%esp)
  80102e:	e8 57 fe ff ff       	call   800e8a <fd_lookup>
  801033:	89 c3                	mov    %eax,%ebx
  801035:	85 c0                	test   %eax,%eax
  801037:	0f 88 e1 00 00 00    	js     80111e <dup+0x109>
		return r;
	close(newfdnum);
  80103d:	89 3c 24             	mov    %edi,(%esp)
  801040:	e8 7f ff ff ff       	call   800fc4 <close>

	newfd = INDEX2FD(newfdnum);
  801045:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80104b:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80104e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801051:	89 04 24             	mov    %eax,(%esp)
  801054:	e8 c3 fd ff ff       	call   800e1c <fd2data>
  801059:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80105b:	89 34 24             	mov    %esi,(%esp)
  80105e:	e8 b9 fd ff ff       	call   800e1c <fd2data>
  801063:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801066:	89 d8                	mov    %ebx,%eax
  801068:	c1 e8 16             	shr    $0x16,%eax
  80106b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801072:	a8 01                	test   $0x1,%al
  801074:	74 46                	je     8010bc <dup+0xa7>
  801076:	89 d8                	mov    %ebx,%eax
  801078:	c1 e8 0c             	shr    $0xc,%eax
  80107b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801082:	f6 c2 01             	test   $0x1,%dl
  801085:	74 35                	je     8010bc <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801087:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108e:	25 07 0e 00 00       	and    $0xe07,%eax
  801093:	89 44 24 10          	mov    %eax,0x10(%esp)
  801097:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80109a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a5:	00 
  8010a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b1:	e8 3f fb ff ff       	call   800bf5 <sys_page_map>
  8010b6:	89 c3                	mov    %eax,%ebx
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 3b                	js     8010f7 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	c1 ea 0c             	shr    $0xc,%edx
  8010c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e0:	00 
  8010e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ec:	e8 04 fb ff ff       	call   800bf5 <sys_page_map>
  8010f1:	89 c3                	mov    %eax,%ebx
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 25                	jns    80111c <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801102:	e8 41 fb ff ff       	call   800c48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801107:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80110a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801115:	e8 2e fb ff ff       	call   800c48 <sys_page_unmap>
	return r;
  80111a:	eb 02                	jmp    80111e <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80111c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80111e:	89 d8                	mov    %ebx,%eax
  801120:	83 c4 4c             	add    $0x4c,%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	53                   	push   %ebx
  80112c:	83 ec 24             	sub    $0x24,%esp
  80112f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801132:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801135:	89 44 24 04          	mov    %eax,0x4(%esp)
  801139:	89 1c 24             	mov    %ebx,(%esp)
  80113c:	e8 49 fd ff ff       	call   800e8a <fd_lookup>
  801141:	85 c0                	test   %eax,%eax
  801143:	78 6f                	js     8011b4 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801145:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114f:	8b 00                	mov    (%eax),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 87 fd ff ff       	call   800ee0 <dev_lookup>
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 57                	js     8011b4 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80115d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801160:	8b 50 08             	mov    0x8(%eax),%edx
  801163:	83 e2 03             	and    $0x3,%edx
  801166:	83 fa 01             	cmp    $0x1,%edx
  801169:	75 25                	jne    801190 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
  801170:	8b 00                	mov    (%eax),%eax
  801172:	8b 40 48             	mov    0x48(%eax),%eax
  801175:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117d:	c7 04 24 0d 2a 80 00 	movl   $0x802a0d,(%esp)
  801184:	e8 7b f0 ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  801189:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118e:	eb 24                	jmp    8011b4 <read+0x8c>
	}
	if (!dev->dev_read)
  801190:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801193:	8b 52 08             	mov    0x8(%edx),%edx
  801196:	85 d2                	test   %edx,%edx
  801198:	74 15                	je     8011af <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80119a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80119d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011a8:	89 04 24             	mov    %eax,(%esp)
  8011ab:	ff d2                	call   *%edx
  8011ad:	eb 05                	jmp    8011b4 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011b4:	83 c4 24             	add    $0x24,%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 1c             	sub    $0x1c,%esp
  8011c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ce:	eb 23                	jmp    8011f3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d0:	89 f0                	mov    %esi,%eax
  8011d2:	29 d8                	sub    %ebx,%eax
  8011d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011db:	01 d8                	add    %ebx,%eax
  8011dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e1:	89 3c 24             	mov    %edi,(%esp)
  8011e4:	e8 3f ff ff ff       	call   801128 <read>
		if (m < 0)
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 10                	js     8011fd <readn+0x43>
			return m;
		if (m == 0)
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	74 0a                	je     8011fb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f1:	01 c3                	add    %eax,%ebx
  8011f3:	39 f3                	cmp    %esi,%ebx
  8011f5:	72 d9                	jb     8011d0 <readn+0x16>
  8011f7:	89 d8                	mov    %ebx,%eax
  8011f9:	eb 02                	jmp    8011fd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011fb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011fd:	83 c4 1c             	add    $0x1c,%esp
  801200:	5b                   	pop    %ebx
  801201:	5e                   	pop    %esi
  801202:	5f                   	pop    %edi
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	53                   	push   %ebx
  801209:	83 ec 24             	sub    $0x24,%esp
  80120c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801212:	89 44 24 04          	mov    %eax,0x4(%esp)
  801216:	89 1c 24             	mov    %ebx,(%esp)
  801219:	e8 6c fc ff ff       	call   800e8a <fd_lookup>
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 6a                	js     80128c <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801225:	89 44 24 04          	mov    %eax,0x4(%esp)
  801229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122c:	8b 00                	mov    (%eax),%eax
  80122e:	89 04 24             	mov    %eax,(%esp)
  801231:	e8 aa fc ff ff       	call   800ee0 <dev_lookup>
  801236:	85 c0                	test   %eax,%eax
  801238:	78 52                	js     80128c <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801241:	75 25                	jne    801268 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801243:	a1 04 40 80 00       	mov    0x804004,%eax
  801248:	8b 00                	mov    (%eax),%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801251:	89 44 24 04          	mov    %eax,0x4(%esp)
  801255:	c7 04 24 29 2a 80 00 	movl   $0x802a29,(%esp)
  80125c:	e8 a3 ef ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  801261:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801266:	eb 24                	jmp    80128c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801268:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126b:	8b 52 0c             	mov    0xc(%edx),%edx
  80126e:	85 d2                	test   %edx,%edx
  801270:	74 15                	je     801287 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801272:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801275:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801279:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	ff d2                	call   *%edx
  801285:	eb 05                	jmp    80128c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801287:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80128c:	83 c4 24             	add    $0x24,%esp
  80128f:	5b                   	pop    %ebx
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <seek>:

int
seek(int fdnum, off_t offset)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801298:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129f:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a2:	89 04 24             	mov    %eax,(%esp)
  8012a5:	e8 e0 fb ff ff       	call   800e8a <fd_lookup>
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 0e                	js     8012bc <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 24             	sub    $0x24,%esp
  8012c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	89 1c 24             	mov    %ebx,(%esp)
  8012d2:	e8 b3 fb ff ff       	call   800e8a <fd_lookup>
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 63                	js     80133e <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e5:	8b 00                	mov    (%eax),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 f1 fb ff ff       	call   800ee0 <dev_lookup>
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 4b                	js     80133e <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fa:	75 25                	jne    801321 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801301:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801303:	8b 40 48             	mov    0x48(%eax),%eax
  801306:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130e:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801315:	e8 ea ee ff ff       	call   800204 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80131a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131f:	eb 1d                	jmp    80133e <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801321:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801324:	8b 52 18             	mov    0x18(%edx),%edx
  801327:	85 d2                	test   %edx,%edx
  801329:	74 0e                	je     801339 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	ff d2                	call   *%edx
  801337:	eb 05                	jmp    80133e <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801339:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80133e:	83 c4 24             	add    $0x24,%esp
  801341:	5b                   	pop    %ebx
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	53                   	push   %ebx
  801348:	83 ec 24             	sub    $0x24,%esp
  80134b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801351:	89 44 24 04          	mov    %eax,0x4(%esp)
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
  801358:	89 04 24             	mov    %eax,(%esp)
  80135b:	e8 2a fb ff ff       	call   800e8a <fd_lookup>
  801360:	85 c0                	test   %eax,%eax
  801362:	78 52                	js     8013b6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	8b 00                	mov    (%eax),%eax
  801370:	89 04 24             	mov    %eax,(%esp)
  801373:	e8 68 fb ff ff       	call   800ee0 <dev_lookup>
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 3a                	js     8013b6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801383:	74 2c                	je     8013b1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801385:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801388:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138f:	00 00 00 
	stat->st_isdir = 0;
  801392:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801399:	00 00 00 
	stat->st_dev = dev;
  80139c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a9:	89 14 24             	mov    %edx,(%esp)
  8013ac:	ff 50 14             	call   *0x14(%eax)
  8013af:	eb 05                	jmp    8013b6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013b6:	83 c4 24             	add    $0x24,%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013cb:	00 
  8013cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cf:	89 04 24             	mov    %eax,(%esp)
  8013d2:	e8 88 02 00 00       	call   80165f <open>
  8013d7:	89 c3                	mov    %eax,%ebx
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 1b                	js     8013f8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e4:	89 1c 24             	mov    %ebx,(%esp)
  8013e7:	e8 58 ff ff ff       	call   801344 <fstat>
  8013ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ee:	89 1c 24             	mov    %ebx,(%esp)
  8013f1:	e8 ce fb ff ff       	call   800fc4 <close>
	return r;
  8013f6:	89 f3                	mov    %esi,%ebx
}
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    
  801401:	00 00                	add    %al,(%eax)
	...

00801404 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	83 ec 10             	sub    $0x10,%esp
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801410:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801417:	75 11                	jne    80142a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801419:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801420:	e8 06 0f 00 00       	call   80232b <ipc_find_env>
  801425:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801431:	00 
  801432:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801439:	00 
  80143a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80143e:	a1 00 40 80 00       	mov    0x804000,%eax
  801443:	89 04 24             	mov    %eax,(%esp)
  801446:	e8 7a 0e 00 00       	call   8022c5 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  80144b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801452:	00 
  801453:	89 74 24 04          	mov    %esi,0x4(%esp)
  801457:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145e:	e8 f5 0d 00 00       	call   802258 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	5b                   	pop    %ebx
  801467:	5e                   	pop    %esi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801470:	8b 45 08             	mov    0x8(%ebp),%eax
  801473:	8b 40 0c             	mov    0xc(%eax),%eax
  801476:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80147b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801483:	ba 00 00 00 00       	mov    $0x0,%edx
  801488:	b8 02 00 00 00       	mov    $0x2,%eax
  80148d:	e8 72 ff ff ff       	call   801404 <fsipc>
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8014af:	e8 50 ff ff ff       	call   801404 <fsipc>
}
  8014b4:	c9                   	leave  
  8014b5:	c3                   	ret    

008014b6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	53                   	push   %ebx
  8014ba:	83 ec 14             	sub    $0x14,%esp
  8014bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d5:	e8 2a ff ff ff       	call   801404 <fsipc>
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 2b                	js     801509 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014de:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014e5:	00 
  8014e6:	89 1c 24             	mov    %ebx,(%esp)
  8014e9:	e8 c1 f2 ff ff       	call   8007af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801504:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801509:	83 c4 14             	add    $0x14,%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 14             	sub    $0x14,%esp
  801516:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
  80151c:	8b 40 0c             	mov    0xc(%eax),%eax
  80151f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801524:	89 d8                	mov    %ebx,%eax
  801526:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80152c:	76 05                	jbe    801533 <devfile_write+0x24>
  80152e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801533:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801538:	89 44 24 08          	mov    %eax,0x8(%esp)
  80153c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801543:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80154a:	e8 43 f4 ff ff       	call   800992 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 04 00 00 00       	mov    $0x4,%eax
  801559:	e8 a6 fe ff ff       	call   801404 <fsipc>
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 53                	js     8015b5 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801562:	39 c3                	cmp    %eax,%ebx
  801564:	73 24                	jae    80158a <devfile_write+0x7b>
  801566:	c7 44 24 0c 58 2a 80 	movl   $0x802a58,0xc(%esp)
  80156d:	00 
  80156e:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  801575:	00 
  801576:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  80157d:	00 
  80157e:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  801585:	e8 82 eb ff ff       	call   80010c <_panic>
	assert(r <= PGSIZE);
  80158a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158f:	7e 24                	jle    8015b5 <devfile_write+0xa6>
  801591:	c7 44 24 0c 7f 2a 80 	movl   $0x802a7f,0xc(%esp)
  801598:	00 
  801599:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  8015a0:	00 
  8015a1:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8015a8:	00 
  8015a9:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  8015b0:	e8 57 eb ff ff       	call   80010c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  8015b5:	83 c4 14             	add    $0x14,%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    

008015bb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	56                   	push   %esi
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 10             	sub    $0x10,%esp
  8015c3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015cc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015d1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8015e1:	e8 1e fe ff ff       	call   801404 <fsipc>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 6a                	js     801656 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8015ec:	39 c6                	cmp    %eax,%esi
  8015ee:	73 24                	jae    801614 <devfile_read+0x59>
  8015f0:	c7 44 24 0c 58 2a 80 	movl   $0x802a58,0xc(%esp)
  8015f7:	00 
  8015f8:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  8015ff:	00 
  801600:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801607:	00 
  801608:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  80160f:	e8 f8 ea ff ff       	call   80010c <_panic>
	assert(r <= PGSIZE);
  801614:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801619:	7e 24                	jle    80163f <devfile_read+0x84>
  80161b:	c7 44 24 0c 7f 2a 80 	movl   $0x802a7f,0xc(%esp)
  801622:	00 
  801623:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  80162a:	00 
  80162b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801632:	00 
  801633:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  80163a:	e8 cd ea ff ff       	call   80010c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80163f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801643:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80164a:	00 
  80164b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164e:	89 04 24             	mov    %eax,(%esp)
  801651:	e8 d2 f2 ff ff       	call   800928 <memmove>
	return r;
}
  801656:	89 d8                	mov    %ebx,%eax
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	5b                   	pop    %ebx
  80165c:	5e                   	pop    %esi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    

0080165f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	56                   	push   %esi
  801663:	53                   	push   %ebx
  801664:	83 ec 20             	sub    $0x20,%esp
  801667:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80166a:	89 34 24             	mov    %esi,(%esp)
  80166d:	e8 0a f1 ff ff       	call   80077c <strlen>
  801672:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801677:	7f 60                	jg     8016d9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167c:	89 04 24             	mov    %eax,(%esp)
  80167f:	e8 b3 f7 ff ff       	call   800e37 <fd_alloc>
  801684:	89 c3                	mov    %eax,%ebx
  801686:	85 c0                	test   %eax,%eax
  801688:	78 54                	js     8016de <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80168a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80168e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801695:	e8 15 f1 ff ff       	call   8007af <strcpy>
	fsipcbuf.open.req_omode = mode;
  80169a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8016aa:	e8 55 fd ff ff       	call   801404 <fsipc>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	79 15                	jns    8016ca <open+0x6b>
		fd_close(fd, 0);
  8016b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016bc:	00 
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	89 04 24             	mov    %eax,(%esp)
  8016c3:	e8 74 f8 ff ff       	call   800f3c <fd_close>
		return r;
  8016c8:	eb 14                	jmp    8016de <open+0x7f>
	}

	return fd2num(fd);
  8016ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cd:	89 04 24             	mov    %eax,(%esp)
  8016d0:	e8 37 f7 ff ff       	call   800e0c <fd2num>
  8016d5:	89 c3                	mov    %eax,%ebx
  8016d7:	eb 05                	jmp    8016de <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016d9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016de:	89 d8                	mov    %ebx,%eax
  8016e0:	83 c4 20             	add    $0x20,%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5e                   	pop    %esi
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f7:	e8 08 fd ff ff       	call   801404 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    
	...

00801700 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80170c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801713:	00 
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	89 04 24             	mov    %eax,(%esp)
  80171a:	e8 40 ff ff ff       	call   80165f <open>
  80171f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801725:	85 c0                	test   %eax,%eax
  801727:	0f 88 77 05 00 00    	js     801ca4 <spawn+0x5a4>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80172d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801734:	00 
  801735:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80173b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 6d fa ff ff       	call   8011ba <readn>
  80174d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801752:	75 0c                	jne    801760 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801754:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80175b:	45 4c 46 
  80175e:	74 3b                	je     80179b <spawn+0x9b>
		close(fd);
  801760:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801766:	89 04 24             	mov    %eax,(%esp)
  801769:	e8 56 f8 ff ff       	call   800fc4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80176e:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801775:	46 
  801776:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  80177c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801780:	c7 04 24 8b 2a 80 00 	movl   $0x802a8b,(%esp)
  801787:	e8 78 ea ff ff       	call   800204 <cprintf>
		return -E_NOT_EXEC;
  80178c:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801793:	ff ff ff 
  801796:	e9 15 05 00 00       	jmp    801cb0 <spawn+0x5b0>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80179b:	ba 07 00 00 00       	mov    $0x7,%edx
  8017a0:	89 d0                	mov    %edx,%eax
  8017a2:	cd 30                	int    $0x30
  8017a4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8017aa:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	0f 88 f8 04 00 00    	js     801cb0 <spawn+0x5b0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8017b8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8017bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8017c4:	c1 e0 07             	shl    $0x7,%eax
  8017c7:	29 d0                	sub    %edx,%eax
  8017c9:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  8017cf:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8017d5:	b9 11 00 00 00       	mov    $0x11,%ecx
  8017da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8017dc:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8017e2:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017e8:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8017ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017f5:	eb 0d                	jmp    801804 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8017f7:	89 04 24             	mov    %eax,(%esp)
  8017fa:	e8 7d ef ff ff       	call   80077c <strlen>
  8017ff:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801803:	46                   	inc    %esi
  801804:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801806:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80180d:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801810:	85 c0                	test   %eax,%eax
  801812:	75 e3                	jne    8017f7 <spawn+0xf7>
  801814:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80181a:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801820:	bf 00 10 40 00       	mov    $0x401000,%edi
  801825:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801827:	89 f8                	mov    %edi,%eax
  801829:	83 e0 fc             	and    $0xfffffffc,%eax
  80182c:	f7 d2                	not    %edx
  80182e:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801831:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801837:	89 d0                	mov    %edx,%eax
  801839:	83 e8 08             	sub    $0x8,%eax
  80183c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801841:	0f 86 7a 04 00 00    	jbe    801cc1 <spawn+0x5c1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801847:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80184e:	00 
  80184f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801856:	00 
  801857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80185e:	e8 3e f3 ff ff       	call   800ba1 <sys_page_alloc>
  801863:	85 c0                	test   %eax,%eax
  801865:	0f 88 5b 04 00 00    	js     801cc6 <spawn+0x5c6>
  80186b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801870:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801876:	8b 75 0c             	mov    0xc(%ebp),%esi
  801879:	eb 2e                	jmp    8018a9 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80187b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801881:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801887:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80188a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	89 3c 24             	mov    %edi,(%esp)
  801894:	e8 16 ef ff ff       	call   8007af <strcpy>
		string_store += strlen(argv[i]) + 1;
  801899:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 d8 ee ff ff       	call   80077c <strlen>
  8018a4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8018a8:	43                   	inc    %ebx
  8018a9:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8018af:	7c ca                	jl     80187b <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8018b1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8018b7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018bd:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8018c4:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8018ca:	74 24                	je     8018f0 <spawn+0x1f0>
  8018cc:	c7 44 24 0c 00 2b 80 	movl   $0x802b00,0xc(%esp)
  8018d3:	00 
  8018d4:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  8018db:	00 
  8018dc:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  8018e3:	00 
  8018e4:	c7 04 24 a5 2a 80 00 	movl   $0x802aa5,(%esp)
  8018eb:	e8 1c e8 ff ff       	call   80010c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8018f0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8018f6:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8018fb:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801901:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801904:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80190a:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80190d:	89 d0                	mov    %edx,%eax
  80190f:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801914:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80191a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801921:	00 
  801922:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801929:	ee 
  80192a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801930:	89 44 24 08          	mov    %eax,0x8(%esp)
  801934:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80193b:	00 
  80193c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801943:	e8 ad f2 ff ff       	call   800bf5 <sys_page_map>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 1a                	js     801968 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80194e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801955:	00 
  801956:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195d:	e8 e6 f2 ff ff       	call   800c48 <sys_page_unmap>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	85 c0                	test   %eax,%eax
  801966:	79 1f                	jns    801987 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801968:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80196f:	00 
  801970:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801977:	e8 cc f2 ff ff       	call   800c48 <sys_page_unmap>
	return r;
  80197c:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801982:	e9 29 03 00 00       	jmp    801cb0 <spawn+0x5b0>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801987:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80198d:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801993:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801999:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8019a0:	00 00 00 
  8019a3:	e9 bb 01 00 00       	jmp    801b63 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8019a8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019ae:	83 38 01             	cmpl   $0x1,(%eax)
  8019b1:	0f 85 9f 01 00 00    	jne    801b56 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8019b7:	89 c2                	mov    %eax,%edx
  8019b9:	8b 40 18             	mov    0x18(%eax),%eax
  8019bc:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8019bf:	83 f8 01             	cmp    $0x1,%eax
  8019c2:	19 c0                	sbb    %eax,%eax
  8019c4:	83 e0 fe             	and    $0xfffffffe,%eax
  8019c7:	83 c0 07             	add    $0x7,%eax
  8019ca:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8019d0:	8b 52 04             	mov    0x4(%edx),%edx
  8019d3:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  8019d9:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019df:	8b 40 10             	mov    0x10(%eax),%eax
  8019e2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8019e8:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8019ee:	8b 52 14             	mov    0x14(%edx),%edx
  8019f1:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8019f7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019fd:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801a00:	89 f8                	mov    %edi,%eax
  801a02:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a07:	74 16                	je     801a1f <spawn+0x31f>
		va -= i;
  801a09:	29 c7                	sub    %eax,%edi
		memsz += i;
  801a0b:	01 c2                	add    %eax,%edx
  801a0d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801a13:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801a19:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a24:	e9 1f 01 00 00       	jmp    801b48 <spawn+0x448>
		if (i >= filesz) {
  801a29:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  801a2f:	72 2b                	jb     801a5c <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801a31:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801a37:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a3b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a3f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a45:	89 04 24             	mov    %eax,(%esp)
  801a48:	e8 54 f1 ff ff       	call   800ba1 <sys_page_alloc>
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	0f 89 e7 00 00 00    	jns    801b3c <spawn+0x43c>
  801a55:	89 c6                	mov    %eax,%esi
  801a57:	e9 24 02 00 00       	jmp    801c80 <spawn+0x580>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a5c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a63:	00 
  801a64:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a6b:	00 
  801a6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a73:	e8 29 f1 ff ff       	call   800ba1 <sys_page_alloc>
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	0f 88 f6 01 00 00    	js     801c76 <spawn+0x576>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801a80:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801a86:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 f8 f7 ff ff       	call   801292 <seek>
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	0f 88 d8 01 00 00    	js     801c7a <spawn+0x57a>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801aa2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aa8:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801aaa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aaf:	76 05                	jbe    801ab6 <spawn+0x3b6>
  801ab1:	b8 00 10 00 00       	mov    $0x1000,%eax
  801ab6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aba:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ac1:	00 
  801ac2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ac8:	89 04 24             	mov    %eax,(%esp)
  801acb:	e8 ea f6 ff ff       	call   8011ba <readn>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	0f 88 a6 01 00 00    	js     801c7e <spawn+0x57e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ad8:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801ade:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ae2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ae6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801aec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801af7:	00 
  801af8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aff:	e8 f1 f0 ff ff       	call   800bf5 <sys_page_map>
  801b04:	85 c0                	test   %eax,%eax
  801b06:	79 20                	jns    801b28 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801b08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0c:	c7 44 24 08 b1 2a 80 	movl   $0x802ab1,0x8(%esp)
  801b13:	00 
  801b14:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801b1b:	00 
  801b1c:	c7 04 24 a5 2a 80 00 	movl   $0x802aa5,(%esp)
  801b23:	e8 e4 e5 ff ff       	call   80010c <_panic>
			sys_page_unmap(0, UTEMP);
  801b28:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b2f:	00 
  801b30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b37:	e8 0c f1 ff ff       	call   800c48 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b3c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b42:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801b48:	89 de                	mov    %ebx,%esi
  801b4a:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801b50:	0f 82 d3 fe ff ff    	jb     801a29 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b56:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801b5c:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801b63:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801b6a:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801b70:	0f 8c 32 fe ff ff    	jl     8019a8 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801b76:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 40 f4 ff ff       	call   800fc4 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  801b84:	be 00 00 00 00       	mov    $0x0,%esi
  801b89:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(va)] & PTE_P)&&(uvpt[PGNUM(va)] & PTE_P)&&(uvpt[PGNUM(va)]&PTE_U)&&(uvpt[PGNUM(va)]&PTE_SHARE)){
  801b8f:	89 f0                	mov    %esi,%eax
  801b91:	c1 e8 16             	shr    $0x16,%eax
  801b94:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b9b:	a8 01                	test   $0x1,%al
  801b9d:	74 49                	je     801be8 <spawn+0x4e8>
  801b9f:	89 f0                	mov    %esi,%eax
  801ba1:	c1 e8 0c             	shr    $0xc,%eax
  801ba4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801bab:	f6 c2 01             	test   $0x1,%dl
  801bae:	74 38                	je     801be8 <spawn+0x4e8>
  801bb0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801bb7:	f6 c2 04             	test   $0x4,%dl
  801bba:	74 2c                	je     801be8 <spawn+0x4e8>
  801bbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bc3:	f6 c4 04             	test   $0x4,%ah
  801bc6:	74 20                	je     801be8 <spawn+0x4e8>
			if ((r = sys_page_map(0,(void*)va,child,(void*)va,PTE_SYSCALL))<0);
  801bc8:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  801bcf:	00 
  801bd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bd4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be3:	e8 0d f0 ff ff       	call   800bf5 <sys_page_map>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  801be8:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801bee:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  801bf4:	75 99                	jne    801b8f <spawn+0x48f>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801bf6:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801bfd:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801c00:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c10:	89 04 24             	mov    %eax,(%esp)
  801c13:	e8 d6 f0 ff ff       	call   800cee <sys_env_set_trapframe>
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	79 20                	jns    801c3c <spawn+0x53c>
		panic("sys_env_set_trapframe: %e", r);
  801c1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c20:	c7 44 24 08 ce 2a 80 	movl   $0x802ace,0x8(%esp)
  801c27:	00 
  801c28:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801c2f:	00 
  801c30:	c7 04 24 a5 2a 80 00 	movl   $0x802aa5,(%esp)
  801c37:	e8 d0 e4 ff ff       	call   80010c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c3c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c43:	00 
  801c44:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c4a:	89 04 24             	mov    %eax,(%esp)
  801c4d:	e8 49 f0 ff ff       	call   800c9b <sys_env_set_status>
  801c52:	85 c0                	test   %eax,%eax
  801c54:	79 5a                	jns    801cb0 <spawn+0x5b0>
		panic("sys_env_set_status: %e", r);
  801c56:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5a:	c7 44 24 08 e8 2a 80 	movl   $0x802ae8,0x8(%esp)
  801c61:	00 
  801c62:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801c69:	00 
  801c6a:	c7 04 24 a5 2a 80 00 	movl   $0x802aa5,(%esp)
  801c71:	e8 96 e4 ff ff       	call   80010c <_panic>
  801c76:	89 c6                	mov    %eax,%esi
  801c78:	eb 06                	jmp    801c80 <spawn+0x580>
  801c7a:	89 c6                	mov    %eax,%esi
  801c7c:	eb 02                	jmp    801c80 <spawn+0x580>
  801c7e:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801c80:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c86:	89 04 24             	mov    %eax,(%esp)
  801c89:	e8 83 ee ff ff       	call   800b11 <sys_env_destroy>
	close(fd);
  801c8e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c94:	89 04 24             	mov    %eax,(%esp)
  801c97:	e8 28 f3 ff ff       	call   800fc4 <close>
	return r;
  801c9c:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801ca2:	eb 0c                	jmp    801cb0 <spawn+0x5b0>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ca4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801caa:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801cb0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801cb6:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801cbc:	5b                   	pop    %ebx
  801cbd:	5e                   	pop    %esi
  801cbe:	5f                   	pop    %edi
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801cc1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801cc6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801ccc:	eb e2                	jmp    801cb0 <spawn+0x5b0>

00801cce <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801cd7:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801cda:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801cdf:	eb 03                	jmp    801ce4 <spawnl+0x16>
		argc++;
  801ce1:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ce2:	89 d0                	mov    %edx,%eax
  801ce4:	8d 50 04             	lea    0x4(%eax),%edx
  801ce7:	83 38 00             	cmpl   $0x0,(%eax)
  801cea:	75 f5                	jne    801ce1 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801cec:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801cf3:	83 e0 f0             	and    $0xfffffff0,%eax
  801cf6:	29 c4                	sub    %eax,%esp
  801cf8:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801cfc:	83 e7 f0             	and    $0xfffffff0,%edi
  801cff:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801d01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d04:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801d06:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801d0d:	00 

	va_start(vl, arg0);
  801d0e:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
  801d16:	eb 09                	jmp    801d21 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801d18:	40                   	inc    %eax
  801d19:	8b 1a                	mov    (%edx),%ebx
  801d1b:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801d1e:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d21:	39 c8                	cmp    %ecx,%eax
  801d23:	75 f3                	jne    801d18 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d25:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	89 04 24             	mov    %eax,(%esp)
  801d2f:	e8 cc f9 ff ff       	call   801700 <spawn>
}
  801d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 10             	sub    $0x10,%esp
  801d44:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	89 04 24             	mov    %eax,(%esp)
  801d4d:	e8 ca f0 ff ff       	call   800e1c <fd2data>
  801d52:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d54:	c7 44 24 04 28 2b 80 	movl   $0x802b28,0x4(%esp)
  801d5b:	00 
  801d5c:	89 34 24             	mov    %esi,(%esp)
  801d5f:	e8 4b ea ff ff       	call   8007af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d64:	8b 43 04             	mov    0x4(%ebx),%eax
  801d67:	2b 03                	sub    (%ebx),%eax
  801d69:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d6f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d76:	00 00 00 
	stat->st_dev = &devpipe;
  801d79:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801d80:	30 80 00 
	return 0;
}
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	53                   	push   %ebx
  801d93:	83 ec 14             	sub    $0x14,%esp
  801d96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da4:	e8 9f ee ff ff       	call   800c48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801da9:	89 1c 24             	mov    %ebx,(%esp)
  801dac:	e8 6b f0 ff ff       	call   800e1c <fd2data>
  801db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbc:	e8 87 ee ff ff       	call   800c48 <sys_page_unmap>
}
  801dc1:	83 c4 14             	add    $0x14,%esp
  801dc4:	5b                   	pop    %ebx
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	57                   	push   %edi
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 2c             	sub    $0x2c,%esp
  801dd0:	89 c7                	mov    %eax,%edi
  801dd2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801dd5:	a1 04 40 80 00       	mov    0x804004,%eax
  801dda:	8b 00                	mov    (%eax),%eax
  801ddc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ddf:	89 3c 24             	mov    %edi,(%esp)
  801de2:	e8 89 05 00 00       	call   802370 <pageref>
  801de7:	89 c6                	mov    %eax,%esi
  801de9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dec:	89 04 24             	mov    %eax,(%esp)
  801def:	e8 7c 05 00 00       	call   802370 <pageref>
  801df4:	39 c6                	cmp    %eax,%esi
  801df6:	0f 94 c0             	sete   %al
  801df9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801dfc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e02:	8b 12                	mov    (%edx),%edx
  801e04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e07:	39 cb                	cmp    %ecx,%ebx
  801e09:	75 08                	jne    801e13 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e0b:	83 c4 2c             	add    $0x2c,%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e13:	83 f8 01             	cmp    $0x1,%eax
  801e16:	75 bd                	jne    801dd5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e18:	8b 42 58             	mov    0x58(%edx),%eax
  801e1b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801e22:	00 
  801e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e2b:	c7 04 24 2f 2b 80 00 	movl   $0x802b2f,(%esp)
  801e32:	e8 cd e3 ff ff       	call   800204 <cprintf>
  801e37:	eb 9c                	jmp    801dd5 <_pipeisclosed+0xe>

00801e39 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	57                   	push   %edi
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 1c             	sub    $0x1c,%esp
  801e42:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e45:	89 34 24             	mov    %esi,(%esp)
  801e48:	e8 cf ef ff ff       	call   800e1c <fd2data>
  801e4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e4f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e54:	eb 3c                	jmp    801e92 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e56:	89 da                	mov    %ebx,%edx
  801e58:	89 f0                	mov    %esi,%eax
  801e5a:	e8 68 ff ff ff       	call   801dc7 <_pipeisclosed>
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	75 38                	jne    801e9b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e63:	e8 1a ed ff ff       	call   800b82 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e68:	8b 43 04             	mov    0x4(%ebx),%eax
  801e6b:	8b 13                	mov    (%ebx),%edx
  801e6d:	83 c2 20             	add    $0x20,%edx
  801e70:	39 d0                	cmp    %edx,%eax
  801e72:	73 e2                	jae    801e56 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e77:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e7a:	89 c2                	mov    %eax,%edx
  801e7c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e82:	79 05                	jns    801e89 <devpipe_write+0x50>
  801e84:	4a                   	dec    %edx
  801e85:	83 ca e0             	or     $0xffffffe0,%edx
  801e88:	42                   	inc    %edx
  801e89:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e8d:	40                   	inc    %eax
  801e8e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e91:	47                   	inc    %edi
  801e92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e95:	75 d1                	jne    801e68 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e97:	89 f8                	mov    %edi,%eax
  801e99:	eb 05                	jmp    801ea0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ea0:	83 c4 1c             	add    $0x1c,%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5f                   	pop    %edi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    

00801ea8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	57                   	push   %edi
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	83 ec 1c             	sub    $0x1c,%esp
  801eb1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801eb4:	89 3c 24             	mov    %edi,(%esp)
  801eb7:	e8 60 ef ff ff       	call   800e1c <fd2data>
  801ebc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ebe:	be 00 00 00 00       	mov    $0x0,%esi
  801ec3:	eb 3a                	jmp    801eff <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ec5:	85 f6                	test   %esi,%esi
  801ec7:	74 04                	je     801ecd <devpipe_read+0x25>
				return i;
  801ec9:	89 f0                	mov    %esi,%eax
  801ecb:	eb 40                	jmp    801f0d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ecd:	89 da                	mov    %ebx,%edx
  801ecf:	89 f8                	mov    %edi,%eax
  801ed1:	e8 f1 fe ff ff       	call   801dc7 <_pipeisclosed>
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	75 2e                	jne    801f08 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eda:	e8 a3 ec ff ff       	call   800b82 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801edf:	8b 03                	mov    (%ebx),%eax
  801ee1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ee4:	74 df                	je     801ec5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ee6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801eeb:	79 05                	jns    801ef2 <devpipe_read+0x4a>
  801eed:	48                   	dec    %eax
  801eee:	83 c8 e0             	or     $0xffffffe0,%eax
  801ef1:	40                   	inc    %eax
  801ef2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ef6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801efc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801efe:	46                   	inc    %esi
  801eff:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f02:	75 db                	jne    801edf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f04:	89 f0                	mov    %esi,%eax
  801f06:	eb 05                	jmp    801f0d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f0d:	83 c4 1c             	add    $0x1c,%esp
  801f10:	5b                   	pop    %ebx
  801f11:	5e                   	pop    %esi
  801f12:	5f                   	pop    %edi
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    

00801f15 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	57                   	push   %edi
  801f19:	56                   	push   %esi
  801f1a:	53                   	push   %ebx
  801f1b:	83 ec 3c             	sub    $0x3c,%esp
  801f1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f24:	89 04 24             	mov    %eax,(%esp)
  801f27:	e8 0b ef ff ff       	call   800e37 <fd_alloc>
  801f2c:	89 c3                	mov    %eax,%ebx
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	0f 88 45 01 00 00    	js     80207b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f3d:	00 
  801f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4c:	e8 50 ec ff ff       	call   800ba1 <sys_page_alloc>
  801f51:	89 c3                	mov    %eax,%ebx
  801f53:	85 c0                	test   %eax,%eax
  801f55:	0f 88 20 01 00 00    	js     80207b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f5b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f5e:	89 04 24             	mov    %eax,(%esp)
  801f61:	e8 d1 ee ff ff       	call   800e37 <fd_alloc>
  801f66:	89 c3                	mov    %eax,%ebx
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	0f 88 f8 00 00 00    	js     802068 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f70:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f77:	00 
  801f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f86:	e8 16 ec ff ff       	call   800ba1 <sys_page_alloc>
  801f8b:	89 c3                	mov    %eax,%ebx
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	0f 88 d3 00 00 00    	js     802068 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f98:	89 04 24             	mov    %eax,(%esp)
  801f9b:	e8 7c ee ff ff       	call   800e1c <fd2data>
  801fa0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fa9:	00 
  801faa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb5:	e8 e7 eb ff ff       	call   800ba1 <sys_page_alloc>
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	0f 88 91 00 00 00    	js     802055 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fc7:	89 04 24             	mov    %eax,(%esp)
  801fca:	e8 4d ee ff ff       	call   800e1c <fd2data>
  801fcf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801fd6:	00 
  801fd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fe2:	00 
  801fe3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fee:	e8 02 ec ff ff       	call   800bf5 <sys_page_map>
  801ff3:	89 c3                	mov    %eax,%ebx
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	78 4c                	js     802045 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ff9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802002:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802004:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802007:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80200e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802014:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802017:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802019:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80201c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802023:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802026:	89 04 24             	mov    %eax,(%esp)
  802029:	e8 de ed ff ff       	call   800e0c <fd2num>
  80202e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802030:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802033:	89 04 24             	mov    %eax,(%esp)
  802036:	e8 d1 ed ff ff       	call   800e0c <fd2num>
  80203b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80203e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802043:	eb 36                	jmp    80207b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802045:	89 74 24 04          	mov    %esi,0x4(%esp)
  802049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802050:	e8 f3 eb ff ff       	call   800c48 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802055:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80205c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802063:	e8 e0 eb ff ff       	call   800c48 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802068:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80206b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802076:	e8 cd eb ff ff       	call   800c48 <sys_page_unmap>
    err:
	return r;
}
  80207b:	89 d8                	mov    %ebx,%eax
  80207d:	83 c4 3c             	add    $0x3c,%esp
  802080:	5b                   	pop    %ebx
  802081:	5e                   	pop    %esi
  802082:	5f                   	pop    %edi
  802083:	5d                   	pop    %ebp
  802084:	c3                   	ret    

00802085 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802092:	8b 45 08             	mov    0x8(%ebp),%eax
  802095:	89 04 24             	mov    %eax,(%esp)
  802098:	e8 ed ed ff ff       	call   800e8a <fd_lookup>
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 15                	js     8020b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a4:	89 04 24             	mov    %eax,(%esp)
  8020a7:	e8 70 ed ff ff       	call   800e1c <fd2data>
	return _pipeisclosed(fd, p);
  8020ac:	89 c2                	mov    %eax,%edx
  8020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b1:	e8 11 fd ff ff       	call   801dc7 <_pipeisclosed>
}
  8020b6:	c9                   	leave  
  8020b7:	c3                   	ret    

008020b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    

008020c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8020c8:	c7 44 24 04 47 2b 80 	movl   $0x802b47,0x4(%esp)
  8020cf:	00 
  8020d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d3:	89 04 24             	mov    %eax,(%esp)
  8020d6:	e8 d4 e6 ff ff       	call   8007af <strcpy>
	return 0;
}
  8020db:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e0:	c9                   	leave  
  8020e1:	c3                   	ret    

008020e2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	57                   	push   %edi
  8020e6:	56                   	push   %esi
  8020e7:	53                   	push   %ebx
  8020e8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020f3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020f9:	eb 30                	jmp    80212b <devcons_write+0x49>
		m = n - tot;
  8020fb:	8b 75 10             	mov    0x10(%ebp),%esi
  8020fe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802100:	83 fe 7f             	cmp    $0x7f,%esi
  802103:	76 05                	jbe    80210a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802105:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80210a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80210e:	03 45 0c             	add    0xc(%ebp),%eax
  802111:	89 44 24 04          	mov    %eax,0x4(%esp)
  802115:	89 3c 24             	mov    %edi,(%esp)
  802118:	e8 0b e8 ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  80211d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802121:	89 3c 24             	mov    %edi,(%esp)
  802124:	e8 ab e9 ff ff       	call   800ad4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802129:	01 f3                	add    %esi,%ebx
  80212b:	89 d8                	mov    %ebx,%eax
  80212d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802130:	72 c9                	jb     8020fb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802132:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    

0080213d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802143:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802147:	75 07                	jne    802150 <devcons_read+0x13>
  802149:	eb 25                	jmp    802170 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80214b:	e8 32 ea ff ff       	call   800b82 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802150:	e8 9d e9 ff ff       	call   800af2 <sys_cgetc>
  802155:	85 c0                	test   %eax,%eax
  802157:	74 f2                	je     80214b <devcons_read+0xe>
  802159:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80215b:	85 c0                	test   %eax,%eax
  80215d:	78 1d                	js     80217c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80215f:	83 f8 04             	cmp    $0x4,%eax
  802162:	74 13                	je     802177 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802164:	8b 45 0c             	mov    0xc(%ebp),%eax
  802167:	88 10                	mov    %dl,(%eax)
	return 1;
  802169:	b8 01 00 00 00       	mov    $0x1,%eax
  80216e:	eb 0c                	jmp    80217c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802170:	b8 00 00 00 00       	mov    $0x0,%eax
  802175:	eb 05                	jmp    80217c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802177:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80217c:	c9                   	leave  
  80217d:	c3                   	ret    

0080217e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80217e:	55                   	push   %ebp
  80217f:	89 e5                	mov    %esp,%ebp
  802181:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802184:	8b 45 08             	mov    0x8(%ebp),%eax
  802187:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80218a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802191:	00 
  802192:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802195:	89 04 24             	mov    %eax,(%esp)
  802198:	e8 37 e9 ff ff       	call   800ad4 <sys_cputs>
}
  80219d:	c9                   	leave  
  80219e:	c3                   	ret    

0080219f <getchar>:

int
getchar(void)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021ac:	00 
  8021ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021bb:	e8 68 ef ff ff       	call   801128 <read>
	if (r < 0)
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	78 0f                	js     8021d3 <getchar+0x34>
		return r;
	if (r < 1)
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	7e 06                	jle    8021ce <getchar+0x2f>
		return -E_EOF;
	return c;
  8021c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021cc:	eb 05                	jmp    8021d3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    

008021d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e5:	89 04 24             	mov    %eax,(%esp)
  8021e8:	e8 9d ec ff ff       	call   800e8a <fd_lookup>
  8021ed:	85 c0                	test   %eax,%eax
  8021ef:	78 11                	js     802202 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021fa:	39 10                	cmp    %edx,(%eax)
  8021fc:	0f 94 c0             	sete   %al
  8021ff:	0f b6 c0             	movzbl %al,%eax
}
  802202:	c9                   	leave  
  802203:	c3                   	ret    

00802204 <opencons>:

int
opencons(void)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80220a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80220d:	89 04 24             	mov    %eax,(%esp)
  802210:	e8 22 ec ff ff       	call   800e37 <fd_alloc>
  802215:	85 c0                	test   %eax,%eax
  802217:	78 3c                	js     802255 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802219:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802220:	00 
  802221:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802224:	89 44 24 04          	mov    %eax,0x4(%esp)
  802228:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80222f:	e8 6d e9 ff ff       	call   800ba1 <sys_page_alloc>
  802234:	85 c0                	test   %eax,%eax
  802236:	78 1d                	js     802255 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802238:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80223e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802241:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802243:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802246:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80224d:	89 04 24             	mov    %eax,(%esp)
  802250:	e8 b7 eb ff ff       	call   800e0c <fd2num>
}
  802255:	c9                   	leave  
  802256:	c3                   	ret    
	...

00802258 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	56                   	push   %esi
  80225c:	53                   	push   %ebx
  80225d:	83 ec 10             	sub    $0x10,%esp
  802260:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802263:	8b 45 0c             	mov    0xc(%ebp),%eax
  802266:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802269:	85 c0                	test   %eax,%eax
  80226b:	75 05                	jne    802272 <ipc_recv+0x1a>
  80226d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802272:	89 04 24             	mov    %eax,(%esp)
  802275:	e8 3d eb ff ff       	call   800db7 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80227a:	85 c0                	test   %eax,%eax
  80227c:	79 16                	jns    802294 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  80227e:	85 db                	test   %ebx,%ebx
  802280:	74 06                	je     802288 <ipc_recv+0x30>
  802282:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  802288:	85 f6                	test   %esi,%esi
  80228a:	74 32                	je     8022be <ipc_recv+0x66>
  80228c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802292:	eb 2a                	jmp    8022be <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802294:	85 db                	test   %ebx,%ebx
  802296:	74 0c                	je     8022a4 <ipc_recv+0x4c>
  802298:	a1 04 40 80 00       	mov    0x804004,%eax
  80229d:	8b 00                	mov    (%eax),%eax
  80229f:	8b 40 74             	mov    0x74(%eax),%eax
  8022a2:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8022a4:	85 f6                	test   %esi,%esi
  8022a6:	74 0c                	je     8022b4 <ipc_recv+0x5c>
  8022a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8022ad:	8b 00                	mov    (%eax),%eax
  8022af:	8b 40 78             	mov    0x78(%eax),%eax
  8022b2:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8022b4:	a1 04 40 80 00       	mov    0x804004,%eax
  8022b9:	8b 00                	mov    (%eax),%eax
  8022bb:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	5b                   	pop    %ebx
  8022c2:	5e                   	pop    %esi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	57                   	push   %edi
  8022c9:	56                   	push   %esi
  8022ca:	53                   	push   %ebx
  8022cb:	83 ec 1c             	sub    $0x1c,%esp
  8022ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8022d7:	85 db                	test   %ebx,%ebx
  8022d9:	75 05                	jne    8022e0 <ipc_send+0x1b>
  8022db:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8022e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8022e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ef:	89 04 24             	mov    %eax,(%esp)
  8022f2:	e8 9d ea ff ff       	call   800d94 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8022f7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022fa:	75 07                	jne    802303 <ipc_send+0x3e>
  8022fc:	e8 81 e8 ff ff       	call   800b82 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  802301:	eb dd                	jmp    8022e0 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  802303:	85 c0                	test   %eax,%eax
  802305:	79 1c                	jns    802323 <ipc_send+0x5e>
  802307:	c7 44 24 08 53 2b 80 	movl   $0x802b53,0x8(%esp)
  80230e:	00 
  80230f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802316:	00 
  802317:	c7 04 24 65 2b 80 00 	movl   $0x802b65,(%esp)
  80231e:	e8 e9 dd ff ff       	call   80010c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802323:	83 c4 1c             	add    $0x1c,%esp
  802326:	5b                   	pop    %ebx
  802327:	5e                   	pop    %esi
  802328:	5f                   	pop    %edi
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    

0080232b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	53                   	push   %ebx
  80232f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802337:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80233e:	89 c2                	mov    %eax,%edx
  802340:	c1 e2 07             	shl    $0x7,%edx
  802343:	29 ca                	sub    %ecx,%edx
  802345:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80234b:	8b 52 50             	mov    0x50(%edx),%edx
  80234e:	39 da                	cmp    %ebx,%edx
  802350:	75 0f                	jne    802361 <ipc_find_env+0x36>
			return envs[i].env_id;
  802352:	c1 e0 07             	shl    $0x7,%eax
  802355:	29 c8                	sub    %ecx,%eax
  802357:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80235c:	8b 40 40             	mov    0x40(%eax),%eax
  80235f:	eb 0c                	jmp    80236d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802361:	40                   	inc    %eax
  802362:	3d 00 04 00 00       	cmp    $0x400,%eax
  802367:	75 ce                	jne    802337 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802369:	66 b8 00 00          	mov    $0x0,%ax
}
  80236d:	5b                   	pop    %ebx
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    

00802370 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  802376:	89 c2                	mov    %eax,%edx
  802378:	c1 ea 16             	shr    $0x16,%edx
  80237b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802382:	f6 c2 01             	test   $0x1,%dl
  802385:	74 1e                	je     8023a5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802387:	c1 e8 0c             	shr    $0xc,%eax
  80238a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802391:	a8 01                	test   $0x1,%al
  802393:	74 17                	je     8023ac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802395:	c1 e8 0c             	shr    $0xc,%eax
  802398:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80239f:	ef 
  8023a0:	0f b7 c0             	movzwl %ax,%eax
  8023a3:	eb 0c                	jmp    8023b1 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023aa:	eb 05                	jmp    8023b1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023ac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
	...

008023b4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023b4:	55                   	push   %ebp
  8023b5:	57                   	push   %edi
  8023b6:	56                   	push   %esi
  8023b7:	83 ec 10             	sub    $0x10,%esp
  8023ba:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023be:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023c6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023ca:	89 cd                	mov    %ecx,%ebp
  8023cc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023d0:	85 c0                	test   %eax,%eax
  8023d2:	75 2c                	jne    802400 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023d4:	39 f9                	cmp    %edi,%ecx
  8023d6:	77 68                	ja     802440 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023d8:	85 c9                	test   %ecx,%ecx
  8023da:	75 0b                	jne    8023e7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e1:	31 d2                	xor    %edx,%edx
  8023e3:	f7 f1                	div    %ecx
  8023e5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023e7:	31 d2                	xor    %edx,%edx
  8023e9:	89 f8                	mov    %edi,%eax
  8023eb:	f7 f1                	div    %ecx
  8023ed:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023ef:	89 f0                	mov    %esi,%eax
  8023f1:	f7 f1                	div    %ecx
  8023f3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	5e                   	pop    %esi
  8023fd:	5f                   	pop    %edi
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802400:	39 f8                	cmp    %edi,%eax
  802402:	77 2c                	ja     802430 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802404:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802407:	83 f6 1f             	xor    $0x1f,%esi
  80240a:	75 4c                	jne    802458 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80240c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80240e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802413:	72 0a                	jb     80241f <__udivdi3+0x6b>
  802415:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802419:	0f 87 ad 00 00 00    	ja     8024cc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80241f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802424:	89 f0                	mov    %esi,%eax
  802426:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802428:	83 c4 10             	add    $0x10,%esp
  80242b:	5e                   	pop    %esi
  80242c:	5f                   	pop    %edi
  80242d:	5d                   	pop    %ebp
  80242e:	c3                   	ret    
  80242f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802430:	31 ff                	xor    %edi,%edi
  802432:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802434:	89 f0                	mov    %esi,%eax
  802436:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802438:	83 c4 10             	add    $0x10,%esp
  80243b:	5e                   	pop    %esi
  80243c:	5f                   	pop    %edi
  80243d:	5d                   	pop    %ebp
  80243e:	c3                   	ret    
  80243f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802440:	89 fa                	mov    %edi,%edx
  802442:	89 f0                	mov    %esi,%eax
  802444:	f7 f1                	div    %ecx
  802446:	89 c6                	mov    %eax,%esi
  802448:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80244a:	89 f0                	mov    %esi,%eax
  80244c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    
  802455:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802458:	89 f1                	mov    %esi,%ecx
  80245a:	d3 e0                	shl    %cl,%eax
  80245c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802460:	b8 20 00 00 00       	mov    $0x20,%eax
  802465:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802467:	89 ea                	mov    %ebp,%edx
  802469:	88 c1                	mov    %al,%cl
  80246b:	d3 ea                	shr    %cl,%edx
  80246d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802471:	09 ca                	or     %ecx,%edx
  802473:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802477:	89 f1                	mov    %esi,%ecx
  802479:	d3 e5                	shl    %cl,%ebp
  80247b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80247f:	89 fd                	mov    %edi,%ebp
  802481:	88 c1                	mov    %al,%cl
  802483:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802485:	89 fa                	mov    %edi,%edx
  802487:	89 f1                	mov    %esi,%ecx
  802489:	d3 e2                	shl    %cl,%edx
  80248b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80248f:	88 c1                	mov    %al,%cl
  802491:	d3 ef                	shr    %cl,%edi
  802493:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802495:	89 f8                	mov    %edi,%eax
  802497:	89 ea                	mov    %ebp,%edx
  802499:	f7 74 24 08          	divl   0x8(%esp)
  80249d:	89 d1                	mov    %edx,%ecx
  80249f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8024a1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024a5:	39 d1                	cmp    %edx,%ecx
  8024a7:	72 17                	jb     8024c0 <__udivdi3+0x10c>
  8024a9:	74 09                	je     8024b4 <__udivdi3+0x100>
  8024ab:	89 fe                	mov    %edi,%esi
  8024ad:	31 ff                	xor    %edi,%edi
  8024af:	e9 41 ff ff ff       	jmp    8023f5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024b4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024b8:	89 f1                	mov    %esi,%ecx
  8024ba:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024bc:	39 c2                	cmp    %eax,%edx
  8024be:	73 eb                	jae    8024ab <__udivdi3+0xf7>
		{
		  q0--;
  8024c0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024c3:	31 ff                	xor    %edi,%edi
  8024c5:	e9 2b ff ff ff       	jmp    8023f5 <__udivdi3+0x41>
  8024ca:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024cc:	31 f6                	xor    %esi,%esi
  8024ce:	e9 22 ff ff ff       	jmp    8023f5 <__udivdi3+0x41>
	...

008024d4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024d4:	55                   	push   %ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	83 ec 20             	sub    $0x20,%esp
  8024da:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024de:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024e2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8024e6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8024ea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ee:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024f2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8024f4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024f6:	85 ed                	test   %ebp,%ebp
  8024f8:	75 16                	jne    802510 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8024fa:	39 f1                	cmp    %esi,%ecx
  8024fc:	0f 86 a6 00 00 00    	jbe    8025a8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802502:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802504:	89 d0                	mov    %edx,%eax
  802506:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802508:	83 c4 20             	add    $0x20,%esp
  80250b:	5e                   	pop    %esi
  80250c:	5f                   	pop    %edi
  80250d:	5d                   	pop    %ebp
  80250e:	c3                   	ret    
  80250f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802510:	39 f5                	cmp    %esi,%ebp
  802512:	0f 87 ac 00 00 00    	ja     8025c4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802518:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80251b:	83 f0 1f             	xor    $0x1f,%eax
  80251e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802522:	0f 84 a8 00 00 00    	je     8025d0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802528:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80252c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80252e:	bf 20 00 00 00       	mov    $0x20,%edi
  802533:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802537:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80253b:	89 f9                	mov    %edi,%ecx
  80253d:	d3 e8                	shr    %cl,%eax
  80253f:	09 e8                	or     %ebp,%eax
  802541:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802545:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802549:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80254d:	d3 e0                	shl    %cl,%eax
  80254f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802553:	89 f2                	mov    %esi,%edx
  802555:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802557:	8b 44 24 14          	mov    0x14(%esp),%eax
  80255b:	d3 e0                	shl    %cl,%eax
  80255d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802561:	8b 44 24 14          	mov    0x14(%esp),%eax
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e8                	shr    %cl,%eax
  802569:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80256b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80256d:	89 f2                	mov    %esi,%edx
  80256f:	f7 74 24 18          	divl   0x18(%esp)
  802573:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802575:	f7 64 24 0c          	mull   0xc(%esp)
  802579:	89 c5                	mov    %eax,%ebp
  80257b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80257d:	39 d6                	cmp    %edx,%esi
  80257f:	72 67                	jb     8025e8 <__umoddi3+0x114>
  802581:	74 75                	je     8025f8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802583:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802587:	29 e8                	sub    %ebp,%eax
  802589:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80258b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80258f:	d3 e8                	shr    %cl,%eax
  802591:	89 f2                	mov    %esi,%edx
  802593:	89 f9                	mov    %edi,%ecx
  802595:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802597:	09 d0                	or     %edx,%eax
  802599:	89 f2                	mov    %esi,%edx
  80259b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80259f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025a1:	83 c4 20             	add    $0x20,%esp
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025a8:	85 c9                	test   %ecx,%ecx
  8025aa:	75 0b                	jne    8025b7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b1:	31 d2                	xor    %edx,%edx
  8025b3:	f7 f1                	div    %ecx
  8025b5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025b7:	89 f0                	mov    %esi,%eax
  8025b9:	31 d2                	xor    %edx,%edx
  8025bb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025bd:	89 f8                	mov    %edi,%eax
  8025bf:	e9 3e ff ff ff       	jmp    802502 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025c4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c6:	83 c4 20             	add    $0x20,%esp
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025d0:	39 f5                	cmp    %esi,%ebp
  8025d2:	72 04                	jb     8025d8 <__umoddi3+0x104>
  8025d4:	39 f9                	cmp    %edi,%ecx
  8025d6:	77 06                	ja     8025de <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025d8:	89 f2                	mov    %esi,%edx
  8025da:	29 cf                	sub    %ecx,%edi
  8025dc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025de:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025e0:	83 c4 20             	add    $0x20,%esp
  8025e3:	5e                   	pop    %esi
  8025e4:	5f                   	pop    %edi
  8025e5:	5d                   	pop    %ebp
  8025e6:	c3                   	ret    
  8025e7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025e8:	89 d1                	mov    %edx,%ecx
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025f0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025f4:	eb 8d                	jmp    802583 <__umoddi3+0xaf>
  8025f6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025f8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025fc:	72 ea                	jb     8025e8 <__umoddi3+0x114>
  8025fe:	89 f1                	mov    %esi,%ecx
  802600:	eb 81                	jmp    802583 <__umoddi3+0xaf>
