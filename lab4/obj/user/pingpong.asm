
obj/user/pingpong:     file format elf32-i386


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

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 7d 0f 00 00       	call   800fbf <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 23 0b 00 00       	call   800b73 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  80005f:	e8 b0 01 00 00       	call   800214 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 b6 12 00 00       	call   80133d <ipc_send>
	}
	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 2e 12 00 00       	call   8012d0 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 c7 0a 00 00       	call   800b73 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 76 17 80 00 	movl   $0x801776,(%esp)
  8000bf:	e8 50 01 00 00       	call   800214 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 54 12 00 00       	call   80133d <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
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
  800106:	e8 68 0a 00 00       	call   800b73 <sys_getenvid>
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
  800130:	c7 04 24 85 17 80 00 	movl   $0x801785,(%esp)
  800137:	e8 d8 00 00 00       	call   800214 <cprintf>
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
  80014e:	e8 e1 fe ff ff       	call   800034 <umain>

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
  80016d:	e8 af 09 00 00       	call   800b21 <sys_env_destroy>
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	53                   	push   %ebx
  800178:	83 ec 14             	sub    $0x14,%esp
  80017b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017e:	8b 03                	mov    (%ebx),%eax
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800187:	40                   	inc    %eax
  800188:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018f:	75 19                	jne    8001aa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800191:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800198:	00 
  800199:	8d 43 08             	lea    0x8(%ebx),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 40 09 00 00       	call   800ae4 <sys_cputs>
		b->idx = 0;
  8001a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001aa:	ff 43 04             	incl   0x4(%ebx)
}
  8001ad:	83 c4 14             	add    $0x14,%esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c3:	00 00 00 
	b.cnt = 0;
  8001c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e8:	c7 04 24 74 01 80 00 	movl   $0x800174,(%esp)
  8001ef:	e8 82 01 00 00       	call   800376 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800204:	89 04 24             	mov    %eax,(%esp)
  800207:	e8 d8 08 00 00       	call   800ae4 <sys_cputs>

	return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	e8 87 ff ff ff       	call   8001b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    
	...

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 3c             	sub    $0x3c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d7                	mov    %edx,%edi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
  800247:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80024d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	85 c0                	test   %eax,%eax
  800252:	75 08                	jne    80025c <printnum+0x2c>
  800254:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800257:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025a:	77 57                	ja     8002b3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800260:	4b                   	dec    %ebx
  800261:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800265:	8b 45 10             	mov    0x10(%ebp),%eax
  800268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800270:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800274:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027b:	00 
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	e8 6a 12 00 00       	call   8014f8 <__udivdi3>
  80028e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800292:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800296:	89 04 24             	mov    %eax,(%esp)
  800299:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029d:	89 fa                	mov    %edi,%edx
  80029f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a2:	e8 89 ff ff ff       	call   800230 <printnum>
  8002a7:	eb 0f                	jmp    8002b8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ad:	89 34 24             	mov    %esi,(%esp)
  8002b0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b3:	4b                   	dec    %ebx
  8002b4:	85 db                	test   %ebx,%ebx
  8002b6:	7f f1                	jg     8002a9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002bc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ce:	00 
  8002cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dc:	e8 37 13 00 00       	call   801618 <__umoddi3>
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	0f be 80 93 17 80 00 	movsbl 0x801793(%eax),%eax
  8002ec:	89 04 24             	mov    %eax,(%esp)
  8002ef:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002f2:	83 c4 3c             	add    $0x3c,%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fd:	83 fa 01             	cmp    $0x1,%edx
  800300:	7e 0e                	jle    800310 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 08             	lea    0x8(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	8b 52 04             	mov    0x4(%edx),%edx
  80030e:	eb 22                	jmp    800332 <getuint+0x38>
	else if (lflag)
  800310:	85 d2                	test   %edx,%edx
  800312:	74 10                	je     800324 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
  800322:	eb 0e                	jmp    800332 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 04             	lea    0x4(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	3b 50 04             	cmp    0x4(%eax),%edx
  800342:	73 08                	jae    80034c <sprintputch+0x18>
		*b->buf++ = ch;
  800344:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800347:	88 0a                	mov    %cl,(%edx)
  800349:	42                   	inc    %edx
  80034a:	89 10                	mov    %edx,(%eax)
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800354:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800357:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035b:	8b 45 10             	mov    0x10(%ebp),%eax
  80035e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800362:	8b 45 0c             	mov    0xc(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	e8 02 00 00 00       	call   800376 <vprintfmt>
	va_end(ap);
}
  800374:	c9                   	leave  
  800375:	c3                   	ret    

00800376 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 4c             	sub    $0x4c,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800382:	8b 75 10             	mov    0x10(%ebp),%esi
  800385:	eb 12                	jmp    800399 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800387:	85 c0                	test   %eax,%eax
  800389:	0f 84 6b 03 00 00    	je     8006fa <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80038f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	0f b6 06             	movzbl (%esi),%eax
  80039c:	46                   	inc    %esi
  80039d:	83 f8 25             	cmp    $0x25,%eax
  8003a0:	75 e5                	jne    800387 <vprintfmt+0x11>
  8003a2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003b2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003be:	eb 26                	jmp    8003e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003c7:	eb 1d                	jmp    8003e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003d0:	eb 14                	jmp    8003e6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003dc:	eb 08                	jmp    8003e6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	0f b6 06             	movzbl (%esi),%eax
  8003e9:	8d 56 01             	lea    0x1(%esi),%edx
  8003ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003ef:	8a 16                	mov    (%esi),%dl
  8003f1:	83 ea 23             	sub    $0x23,%edx
  8003f4:	80 fa 55             	cmp    $0x55,%dl
  8003f7:	0f 87 e1 02 00 00    	ja     8006de <vprintfmt+0x368>
  8003fd:	0f b6 d2             	movzbl %dl,%edx
  800400:	ff 24 95 60 18 80 00 	jmp    *0x801860(,%edx,4)
  800407:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800412:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800416:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800419:	8d 50 d0             	lea    -0x30(%eax),%edx
  80041c:	83 fa 09             	cmp    $0x9,%edx
  80041f:	77 2a                	ja     80044b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800421:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800422:	eb eb                	jmp    80040f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800432:	eb 17                	jmp    80044b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800438:	78 98                	js     8003d2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043d:	eb a7                	jmp    8003e6 <vprintfmt+0x70>
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800442:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800449:	eb 9b                	jmp    8003e6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80044b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044f:	79 95                	jns    8003e6 <vprintfmt+0x70>
  800451:	eb 8b                	jmp    8003de <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800453:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800457:	eb 8d                	jmp    8003e6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800466:	8b 00                	mov    (%eax),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800471:	e9 23 ff ff ff       	jmp    800399 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	85 c0                	test   %eax,%eax
  800483:	79 02                	jns    800487 <vprintfmt+0x111>
  800485:	f7 d8                	neg    %eax
  800487:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800489:	83 f8 08             	cmp    $0x8,%eax
  80048c:	7f 0b                	jg     800499 <vprintfmt+0x123>
  80048e:	8b 04 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%eax
  800495:	85 c0                	test   %eax,%eax
  800497:	75 23                	jne    8004bc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800499:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049d:	c7 44 24 08 ab 17 80 	movl   $0x8017ab,0x8(%esp)
  8004a4:	00 
  8004a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	e8 9a fe ff ff       	call   80034e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b7:	e9 dd fe ff ff       	jmp    800399 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c0:	c7 44 24 08 b4 17 80 	movl   $0x8017b4,0x8(%esp)
  8004c7:	00 
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	89 14 24             	mov    %edx,(%esp)
  8004d2:	e8 77 fe ff ff       	call   80034e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004da:	e9 ba fe ff ff       	jmp    800399 <vprintfmt+0x23>
  8004df:	89 f9                	mov    %edi,%ecx
  8004e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 50 04             	lea    0x4(%eax),%edx
  8004ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f0:	8b 30                	mov    (%eax),%esi
  8004f2:	85 f6                	test   %esi,%esi
  8004f4:	75 05                	jne    8004fb <vprintfmt+0x185>
				p = "(null)";
  8004f6:	be a4 17 80 00       	mov    $0x8017a4,%esi
			if (width > 0 && padc != '-')
  8004fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ff:	0f 8e 84 00 00 00    	jle    800589 <vprintfmt+0x213>
  800505:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800509:	74 7e                	je     800589 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80050f:	89 34 24             	mov    %esi,(%esp)
  800512:	e8 8b 02 00 00       	call   8007a2 <strnlen>
  800517:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80051a:	29 c2                	sub    %eax,%edx
  80051c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80051f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800523:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800526:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800529:	89 de                	mov    %ebx,%esi
  80052b:	89 d3                	mov    %edx,%ebx
  80052d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	eb 0b                	jmp    80053c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800531:	89 74 24 04          	mov    %esi,0x4(%esp)
  800535:	89 3c 24             	mov    %edi,(%esp)
  800538:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	4b                   	dec    %ebx
  80053c:	85 db                	test   %ebx,%ebx
  80053e:	7f f1                	jg     800531 <vprintfmt+0x1bb>
  800540:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800543:	89 f3                	mov    %esi,%ebx
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800548:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054b:	85 c0                	test   %eax,%eax
  80054d:	79 05                	jns    800554 <vprintfmt+0x1de>
  80054f:	b8 00 00 00 00       	mov    $0x0,%eax
  800554:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800557:	29 c2                	sub    %eax,%edx
  800559:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80055c:	eb 2b                	jmp    800589 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800562:	74 18                	je     80057c <vprintfmt+0x206>
  800564:	8d 50 e0             	lea    -0x20(%eax),%edx
  800567:	83 fa 5e             	cmp    $0x5e,%edx
  80056a:	76 10                	jbe    80057c <vprintfmt+0x206>
					putch('?', putdat);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	eb 0a                	jmp    800586 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80057c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	ff 4d e4             	decl   -0x1c(%ebp)
  800589:	0f be 06             	movsbl (%esi),%eax
  80058c:	46                   	inc    %esi
  80058d:	85 c0                	test   %eax,%eax
  80058f:	74 21                	je     8005b2 <vprintfmt+0x23c>
  800591:	85 ff                	test   %edi,%edi
  800593:	78 c9                	js     80055e <vprintfmt+0x1e8>
  800595:	4f                   	dec    %edi
  800596:	79 c6                	jns    80055e <vprintfmt+0x1e8>
  800598:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059b:	89 de                	mov    %ebx,%esi
  80059d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a0:	eb 18                	jmp    8005ba <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ad:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005af:	4b                   	dec    %ebx
  8005b0:	eb 08                	jmp    8005ba <vprintfmt+0x244>
  8005b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b5:	89 de                	mov    %ebx,%esi
  8005b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ba:	85 db                	test   %ebx,%ebx
  8005bc:	7f e4                	jg     8005a2 <vprintfmt+0x22c>
  8005be:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005c1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c6:	e9 ce fd ff ff       	jmp    800399 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cb:	83 f9 01             	cmp    $0x1,%ecx
  8005ce:	7e 10                	jle    8005e0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 08             	lea    0x8(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 30                	mov    (%eax),%esi
  8005db:	8b 78 04             	mov    0x4(%eax),%edi
  8005de:	eb 26                	jmp    800606 <vprintfmt+0x290>
	else if (lflag)
  8005e0:	85 c9                	test   %ecx,%ecx
  8005e2:	74 12                	je     8005f6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 30                	mov    (%eax),%esi
  8005ef:	89 f7                	mov    %esi,%edi
  8005f1:	c1 ff 1f             	sar    $0x1f,%edi
  8005f4:	eb 10                	jmp    800606 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 04             	lea    0x4(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ff:	8b 30                	mov    (%eax),%esi
  800601:	89 f7                	mov    %esi,%edi
  800603:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800606:	85 ff                	test   %edi,%edi
  800608:	78 0a                	js     800614 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060f:	e9 8c 00 00 00       	jmp    8006a0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800622:	f7 de                	neg    %esi
  800624:	83 d7 00             	adc    $0x0,%edi
  800627:	f7 df                	neg    %edi
			}
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062e:	eb 70                	jmp    8006a0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800630:	89 ca                	mov    %ecx,%edx
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 c0 fc ff ff       	call   8002fa <getuint>
  80063a:	89 c6                	mov    %eax,%esi
  80063c:	89 d7                	mov    %edx,%edi
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800643:	eb 5b                	jmp    8006a0 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800645:	89 ca                	mov    %ecx,%edx
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 ab fc ff ff       	call   8002fa <getuint>
  80064f:	89 c6                	mov    %eax,%esi
  800651:	89 d7                	mov    %edx,%edi
			base = 8;
  800653:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800658:	eb 46                	jmp    8006a0 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80065a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800665:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 50 04             	lea    0x4(%eax),%edx
  80067c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067f:	8b 30                	mov    (%eax),%esi
  800681:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800686:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068b:	eb 13                	jmp    8006a0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068d:	89 ca                	mov    %ecx,%edx
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 63 fc ff ff       	call   8002fa <getuint>
  800697:	89 c6                	mov    %eax,%esi
  800699:	89 d7                	mov    %edx,%edi
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006a4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b3:	89 34 24             	mov    %esi,(%esp)
  8006b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ba:	89 da                	mov    %ebx,%edx
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	e8 6c fb ff ff       	call   800230 <printnum>
			break;
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c7:	e9 cd fc ff ff       	jmp    800399 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d0:	89 04 24             	mov    %eax,(%esp)
  8006d3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d9:	e9 bb fc ff ff       	jmp    800399 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ec:	eb 01                	jmp    8006ef <vprintfmt+0x379>
  8006ee:	4e                   	dec    %esi
  8006ef:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f3:	75 f9                	jne    8006ee <vprintfmt+0x378>
  8006f5:	e9 9f fc ff ff       	jmp    800399 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006fa:	83 c4 4c             	add    $0x4c,%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 28             	sub    $0x28,%esp
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800711:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800715:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800718:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071f:	85 c0                	test   %eax,%eax
  800721:	74 30                	je     800753 <vsnprintf+0x51>
  800723:	85 d2                	test   %edx,%edx
  800725:	7e 33                	jle    80075a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072e:	8b 45 10             	mov    0x10(%ebp),%eax
  800731:	89 44 24 08          	mov    %eax,0x8(%esp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	c7 04 24 34 03 80 00 	movl   $0x800334,(%esp)
  800743:	e8 2e fc ff ff       	call   800376 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800748:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800751:	eb 0c                	jmp    80075f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800753:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800758:	eb 05                	jmp    80075f <vsnprintf+0x5d>
  80075a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800767:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076e:	8b 45 10             	mov    0x10(%ebp),%eax
  800771:	89 44 24 08          	mov    %eax,0x8(%esp)
  800775:	8b 45 0c             	mov    0xc(%ebp),%eax
  800778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	89 04 24             	mov    %eax,(%esp)
  800782:	e8 7b ff ff ff       	call   800702 <vsnprintf>
	va_end(ap);

	return rc;
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    
  800789:	00 00                	add    %al,(%eax)
	...

0080078c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
  800797:	eb 01                	jmp    80079a <strlen+0xe>
		n++;
  800799:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079e:	75 f9                	jne    800799 <strlen+0xd>
		n++;
	return n;
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b0:	eb 01                	jmp    8007b3 <strnlen+0x11>
		n++;
  8007b2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	39 d0                	cmp    %edx,%eax
  8007b5:	74 06                	je     8007bd <strnlen+0x1b>
  8007b7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bb:	75 f5                	jne    8007b2 <strnlen+0x10>
		n++;
	return n;
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ce:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007d4:	42                   	inc    %edx
  8007d5:	84 c9                	test   %cl,%cl
  8007d7:	75 f5                	jne    8007ce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d9:	5b                   	pop    %ebx
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e6:	89 1c 24             	mov    %ebx,(%esp)
  8007e9:	e8 9e ff ff ff       	call   80078c <strlen>
	strcpy(dst + len, src);
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f5:	01 d8                	add    %ebx,%eax
  8007f7:	89 04 24             	mov    %eax,(%esp)
  8007fa:	e8 c0 ff ff ff       	call   8007bf <strcpy>
	return dst;
}
  8007ff:	89 d8                	mov    %ebx,%eax
  800801:	83 c4 08             	add    $0x8,%esp
  800804:	5b                   	pop    %ebx
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081a:	eb 0c                	jmp    800828 <strncpy+0x21>
		*dst++ = *src;
  80081c:	8a 1a                	mov    (%edx),%bl
  80081e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800821:	80 3a 01             	cmpb   $0x1,(%edx)
  800824:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800827:	41                   	inc    %ecx
  800828:	39 f1                	cmp    %esi,%ecx
  80082a:	75 f0                	jne    80081c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	56                   	push   %esi
  800834:	53                   	push   %ebx
  800835:	8b 75 08             	mov    0x8(%ebp),%esi
  800838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083e:	85 d2                	test   %edx,%edx
  800840:	75 0a                	jne    80084c <strlcpy+0x1c>
  800842:	89 f0                	mov    %esi,%eax
  800844:	eb 1a                	jmp    800860 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800846:	88 18                	mov    %bl,(%eax)
  800848:	40                   	inc    %eax
  800849:	41                   	inc    %ecx
  80084a:	eb 02                	jmp    80084e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80084e:	4a                   	dec    %edx
  80084f:	74 0a                	je     80085b <strlcpy+0x2b>
  800851:	8a 19                	mov    (%ecx),%bl
  800853:	84 db                	test   %bl,%bl
  800855:	75 ef                	jne    800846 <strlcpy+0x16>
  800857:	89 c2                	mov    %eax,%edx
  800859:	eb 02                	jmp    80085d <strlcpy+0x2d>
  80085b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80085d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800860:	29 f0                	sub    %esi,%eax
}
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086f:	eb 02                	jmp    800873 <strcmp+0xd>
		p++, q++;
  800871:	41                   	inc    %ecx
  800872:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800873:	8a 01                	mov    (%ecx),%al
  800875:	84 c0                	test   %al,%al
  800877:	74 04                	je     80087d <strcmp+0x17>
  800879:	3a 02                	cmp    (%edx),%al
  80087b:	74 f4                	je     800871 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 c0             	movzbl %al,%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800891:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800894:	eb 03                	jmp    800899 <strncmp+0x12>
		n--, p++, q++;
  800896:	4a                   	dec    %edx
  800897:	40                   	inc    %eax
  800898:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800899:	85 d2                	test   %edx,%edx
  80089b:	74 14                	je     8008b1 <strncmp+0x2a>
  80089d:	8a 18                	mov    (%eax),%bl
  80089f:	84 db                	test   %bl,%bl
  8008a1:	74 04                	je     8008a7 <strncmp+0x20>
  8008a3:	3a 19                	cmp    (%ecx),%bl
  8008a5:	74 ef                	je     800896 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 00             	movzbl (%eax),%eax
  8008aa:	0f b6 11             	movzbl (%ecx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
  8008af:	eb 05                	jmp    8008b6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c2:	eb 05                	jmp    8008c9 <strchr+0x10>
		if (*s == c)
  8008c4:	38 ca                	cmp    %cl,%dl
  8008c6:	74 0c                	je     8008d4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c8:	40                   	inc    %eax
  8008c9:	8a 10                	mov    (%eax),%dl
  8008cb:	84 d2                	test   %dl,%dl
  8008cd:	75 f5                	jne    8008c4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008df:	eb 05                	jmp    8008e6 <strfind+0x10>
		if (*s == c)
  8008e1:	38 ca                	cmp    %cl,%dl
  8008e3:	74 07                	je     8008ec <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008e5:	40                   	inc    %eax
  8008e6:	8a 10                	mov    (%eax),%dl
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f5                	jne    8008e1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fd:	85 c9                	test   %ecx,%ecx
  8008ff:	74 30                	je     800931 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800901:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800907:	75 25                	jne    80092e <memset+0x40>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 20                	jne    80092e <memset+0x40>
		c &= 0xFF;
  80090e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800911:	89 d3                	mov    %edx,%ebx
  800913:	c1 e3 08             	shl    $0x8,%ebx
  800916:	89 d6                	mov    %edx,%esi
  800918:	c1 e6 18             	shl    $0x18,%esi
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 10             	shl    $0x10,%eax
  800920:	09 f0                	or     %esi,%eax
  800922:	09 d0                	or     %edx,%eax
  800924:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800926:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800929:	fc                   	cld    
  80092a:	f3 ab                	rep stos %eax,%es:(%edi)
  80092c:	eb 03                	jmp    800931 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092e:	fc                   	cld    
  80092f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800931:	89 f8                	mov    %edi,%eax
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5f                   	pop    %edi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8b 75 0c             	mov    0xc(%ebp),%esi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800946:	39 c6                	cmp    %eax,%esi
  800948:	73 34                	jae    80097e <memmove+0x46>
  80094a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094d:	39 d0                	cmp    %edx,%eax
  80094f:	73 2d                	jae    80097e <memmove+0x46>
		s += n;
		d += n;
  800951:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	f6 c2 03             	test   $0x3,%dl
  800957:	75 1b                	jne    800974 <memmove+0x3c>
  800959:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095f:	75 13                	jne    800974 <memmove+0x3c>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 0e                	jne    800974 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800966:	83 ef 04             	sub    $0x4,%edi
  800969:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096f:	fd                   	std    
  800970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800972:	eb 07                	jmp    80097b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800974:	4f                   	dec    %edi
  800975:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	fd                   	std    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097b:	fc                   	cld    
  80097c:	eb 20                	jmp    80099e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800984:	75 13                	jne    800999 <memmove+0x61>
  800986:	a8 03                	test   $0x3,%al
  800988:	75 0f                	jne    800999 <memmove+0x61>
  80098a:	f6 c1 03             	test   $0x3,%cl
  80098d:	75 0a                	jne    800999 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800992:	89 c7                	mov    %eax,%edi
  800994:	fc                   	cld    
  800995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800997:	eb 05                	jmp    80099e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800999:	89 c7                	mov    %eax,%edi
  80099b:	fc                   	cld    
  80099c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	89 04 24             	mov    %eax,(%esp)
  8009bc:	e8 77 ff ff ff       	call   800938 <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d7:	eb 16                	jmp    8009ef <memcmp+0x2c>
		if (*s1 != *s2)
  8009d9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009dc:	42                   	inc    %edx
  8009dd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009e1:	38 c8                	cmp    %cl,%al
  8009e3:	74 0a                	je     8009ef <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009e5:	0f b6 c0             	movzbl %al,%eax
  8009e8:	0f b6 c9             	movzbl %cl,%ecx
  8009eb:	29 c8                	sub    %ecx,%eax
  8009ed:	eb 09                	jmp    8009f8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	39 da                	cmp    %ebx,%edx
  8009f1:	75 e6                	jne    8009d9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5f                   	pop    %edi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a06:	89 c2                	mov    %eax,%edx
  800a08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0b:	eb 05                	jmp    800a12 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0d:	38 08                	cmp    %cl,(%eax)
  800a0f:	74 05                	je     800a16 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a11:	40                   	inc    %eax
  800a12:	39 d0                	cmp    %edx,%eax
  800a14:	72 f7                	jb     800a0d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a24:	eb 01                	jmp    800a27 <strtol+0xf>
		s++;
  800a26:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a27:	8a 02                	mov    (%edx),%al
  800a29:	3c 20                	cmp    $0x20,%al
  800a2b:	74 f9                	je     800a26 <strtol+0xe>
  800a2d:	3c 09                	cmp    $0x9,%al
  800a2f:	74 f5                	je     800a26 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a31:	3c 2b                	cmp    $0x2b,%al
  800a33:	75 08                	jne    800a3d <strtol+0x25>
		s++;
  800a35:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a36:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3b:	eb 13                	jmp    800a50 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3d:	3c 2d                	cmp    $0x2d,%al
  800a3f:	75 0a                	jne    800a4b <strtol+0x33>
		s++, neg = 1;
  800a41:	8d 52 01             	lea    0x1(%edx),%edx
  800a44:	bf 01 00 00 00       	mov    $0x1,%edi
  800a49:	eb 05                	jmp    800a50 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a50:	85 db                	test   %ebx,%ebx
  800a52:	74 05                	je     800a59 <strtol+0x41>
  800a54:	83 fb 10             	cmp    $0x10,%ebx
  800a57:	75 28                	jne    800a81 <strtol+0x69>
  800a59:	8a 02                	mov    (%edx),%al
  800a5b:	3c 30                	cmp    $0x30,%al
  800a5d:	75 10                	jne    800a6f <strtol+0x57>
  800a5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a63:	75 0a                	jne    800a6f <strtol+0x57>
		s += 2, base = 16;
  800a65:	83 c2 02             	add    $0x2,%edx
  800a68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6d:	eb 12                	jmp    800a81 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	75 0e                	jne    800a81 <strtol+0x69>
  800a73:	3c 30                	cmp    $0x30,%al
  800a75:	75 05                	jne    800a7c <strtol+0x64>
		s++, base = 8;
  800a77:	42                   	inc    %edx
  800a78:	b3 08                	mov    $0x8,%bl
  800a7a:	eb 05                	jmp    800a81 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
  800a86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a88:	8a 0a                	mov    (%edx),%cl
  800a8a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a8d:	80 fb 09             	cmp    $0x9,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x82>
			dig = *s - '0';
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 30             	sub    $0x30,%ecx
  800a98:	eb 1e                	jmp    800ab8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a9a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a9d:	80 fb 19             	cmp    $0x19,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x92>
			dig = *s - 'a' + 10;
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 57             	sub    $0x57,%ecx
  800aa8:	eb 0e                	jmp    800ab8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aaa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aad:	80 fb 19             	cmp    $0x19,%bl
  800ab0:	77 12                	ja     800ac4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ab2:	0f be c9             	movsbl %cl,%ecx
  800ab5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab8:	39 f1                	cmp    %esi,%ecx
  800aba:	7d 0c                	jge    800ac8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800abc:	42                   	inc    %edx
  800abd:	0f af c6             	imul   %esi,%eax
  800ac0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ac2:	eb c4                	jmp    800a88 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ac4:	89 c1                	mov    %eax,%ecx
  800ac6:	eb 02                	jmp    800aca <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ace:	74 05                	je     800ad5 <strtol+0xbd>
		*endptr = (char *) s;
  800ad0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	74 04                	je     800add <strtol+0xc5>
  800ad9:	89 c8                	mov    %ecx,%eax
  800adb:	f7 d8                	neg    %eax
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    
	...

00800ae4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	89 c3                	mov    %eax,%ebx
  800af7:	89 c7                	mov    %eax,%edi
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	89 cb                	mov    %ecx,%ebx
  800b39:	89 cf                	mov    %ecx,%edi
  800b3b:	89 ce                	mov    %ecx,%esi
  800b3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7e 28                	jle    800b6b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b47:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b4e:	00 
  800b4f:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800b56:	00 
  800b57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b5e:	00 
  800b5f:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800b66:	e8 7d 08 00 00       	call   8013e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6b:	83 c4 2c             	add    $0x2c,%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b83:	89 d1                	mov    %edx,%ecx
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	89 d7                	mov    %edx,%edi
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_yield>:

void
sys_yield(void)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	be 00 00 00 00       	mov    $0x0,%esi
  800bbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	89 f7                	mov    %esi,%edi
  800bcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7e 28                	jle    800bfd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800be0:	00 
  800be1:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800be8:	00 
  800be9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf0:	00 
  800bf1:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800bf8:	e8 eb 07 00 00       	call   8013e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfd:	83 c4 2c             	add    $0x2c,%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c13:	8b 75 18             	mov    0x18(%ebp),%esi
  800c16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 28                	jle    800c50 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c33:	00 
  800c34:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800c3b:	00 
  800c3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c43:	00 
  800c44:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800c4b:	e8 98 07 00 00       	call   8013e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c50:	83 c4 2c             	add    $0x2c,%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c66:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 df                	mov    %ebx,%edi
  800c73:	89 de                	mov    %ebx,%esi
  800c75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 28                	jle    800ca3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c86:	00 
  800c87:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800c8e:	00 
  800c8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c96:	00 
  800c97:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800c9e:	e8 45 07 00 00       	call   8013e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca3:	83 c4 2c             	add    $0x2c,%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	89 df                	mov    %ebx,%edi
  800cc6:	89 de                	mov    %ebx,%esi
  800cc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	7e 28                	jle    800cf6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cd9:	00 
  800cda:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800ce1:	00 
  800ce2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce9:	00 
  800cea:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800cf1:	e8 f2 06 00 00       	call   8013e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf6:	83 c4 2c             	add    $0x2c,%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 28                	jle    800d49 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d25:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d2c:	00 
  800d2d:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800d34:	00 
  800d35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3c:	00 
  800d3d:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800d44:	e8 9f 06 00 00       	call   8013e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d49:	83 c4 2c             	add    $0x2c,%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	be 00 00 00 00       	mov    $0x0,%esi
  800d5c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d82:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	89 cb                	mov    %ecx,%ebx
  800d8c:	89 cf                	mov    %ecx,%edi
  800d8e:	89 ce                	mov    %ecx,%esi
  800d90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 28                	jle    800dbe <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800da1:	00 
  800da2:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800da9:	00 
  800daa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db1:	00 
  800db2:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800db9:	e8 2a 06 00 00       	call   8013e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbe:	83 c4 2c             	add    $0x2c,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    
	...

00800dc8 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 3c             	sub    $0x3c,%esp
  800dd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800dd4:	89 d6                	mov    %edx,%esi
  800dd6:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800dd9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800de3:	e8 8b fd ff ff       	call   800b73 <sys_getenvid>
  800de8:	89 c7                	mov    %eax,%edi
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ded:	25 02 08 00 00       	and    $0x802,%eax
  800df2:	83 f8 01             	cmp    $0x1,%eax
  800df5:	19 db                	sbb    %ebx,%ebx
  800df7:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800dfd:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800e03:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e07:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e12:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e16:	89 3c 24             	mov    %edi,(%esp)
  800e19:	e8 e7 fd ff ff       	call   800c05 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	79 1c                	jns    800e3e <duppage+0x76>
  800e22:	c7 44 24 08 0f 1a 80 	movl   $0x801a0f,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800e31:	00 
  800e32:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800e39:	e8 aa 05 00 00       	call   8013e8 <_panic>
	if ((perm|~pte)&PTE_COW){
  800e3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e41:	f7 d0                	not    %eax
  800e43:	09 d8                	or     %ebx,%eax
  800e45:	f6 c4 08             	test   $0x8,%ah
  800e48:	74 38                	je     800e82 <duppage+0xba>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800e4a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e4e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e52:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5a:	89 3c 24             	mov    %edi,(%esp)
  800e5d:	e8 a3 fd ff ff       	call   800c05 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800e62:	85 c0                	test   %eax,%eax
  800e64:	79 1c                	jns    800e82 <duppage+0xba>
  800e66:	c7 44 24 08 0f 1a 80 	movl   $0x801a0f,0x8(%esp)
  800e6d:	00 
  800e6e:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800e75:	00 
  800e76:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800e7d:	e8 66 05 00 00       	call   8013e8 <_panic>
	}
	return 0;
	panic("duppage not implemented");
	return 0;
}
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
  800e87:	83 c4 3c             	add    $0x3c,%esp
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 20             	sub    $0x20,%esp
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e9a:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800e9c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea0:	75 1c                	jne    800ebe <pgfault+0x2f>
		panic("pgfault: error!\n");
  800ea2:	c7 44 24 08 2b 1a 80 	movl   $0x801a2b,0x8(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800eb1:	00 
  800eb2:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800eb9:	e8 2a 05 00 00       	call   8013e8 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800ebe:	89 f0                	mov    %esi,%eax
  800ec0:	c1 e8 0c             	shr    $0xc,%eax
  800ec3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eca:	f6 c4 08             	test   $0x8,%ah
  800ecd:	75 1c                	jne    800eeb <pgfault+0x5c>
		panic("pgfault: error!\n");
  800ecf:	c7 44 24 08 2b 1a 80 	movl   $0x801a2b,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800ee6:	e8 fd 04 00 00       	call   8013e8 <_panic>
	envid_t envid = sys_getenvid();
  800eeb:	e8 83 fc ff ff       	call   800b73 <sys_getenvid>
  800ef0:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800ef2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ef9:	00 
  800efa:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f01:	00 
  800f02:	89 04 24             	mov    %eax,(%esp)
  800f05:	e8 a7 fc ff ff       	call   800bb1 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	79 1c                	jns    800f2a <pgfault+0x9b>
  800f0e:	c7 44 24 08 2b 1a 80 	movl   $0x801a2b,0x8(%esp)
  800f15:	00 
  800f16:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f1d:	00 
  800f1e:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800f25:	e8 be 04 00 00       	call   8013e8 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800f2a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800f30:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f37:	00 
  800f38:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3c:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f43:	e8 5a fa ff ff       	call   8009a2 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800f48:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f4f:	00 
  800f50:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f58:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f5f:	00 
  800f60:	89 1c 24             	mov    %ebx,(%esp)
  800f63:	e8 9d fc ff ff       	call   800c05 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	79 1c                	jns    800f88 <pgfault+0xf9>
  800f6c:	c7 44 24 08 2b 1a 80 	movl   $0x801a2b,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800f83:	e8 60 04 00 00       	call   8013e8 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  800f88:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f8f:	00 
  800f90:	89 1c 24             	mov    %ebx,(%esp)
  800f93:	e8 c0 fc ff ff       	call   800c58 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 1c                	jns    800fb8 <pgfault+0x129>
  800f9c:	c7 44 24 08 2b 1a 80 	movl   $0x801a2b,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800fb3:	e8 30 04 00 00       	call   8013e8 <_panic>
	return;
	panic("pgfault not implemented");
}
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fc8:	c7 04 24 8f 0e 80 00 	movl   $0x800e8f,(%esp)
  800fcf:	e8 6c 04 00 00       	call   801440 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd4:	bf 07 00 00 00       	mov    $0x7,%edi
  800fd9:	89 f8                	mov    %edi,%eax
  800fdb:	cd 30                	int    $0x30
  800fdd:	89 c7                	mov    %eax,%edi
  800fdf:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 1c                	jns    801001 <fork+0x42>
		panic("fork : error!\n");
  800fe5:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800fec:	00 
  800fed:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800ff4:	00 
  800ff5:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  800ffc:	e8 e7 03 00 00       	call   8013e8 <_panic>
	if (envid==0){
  801001:	85 c0                	test   %eax,%eax
  801003:	75 28                	jne    80102d <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801005:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80100b:	e8 63 fb ff ff       	call   800b73 <sys_getenvid>
  801010:	25 ff 03 00 00       	and    $0x3ff,%eax
  801015:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80101c:	c1 e0 07             	shl    $0x7,%eax
  80101f:	29 d0                	sub    %edx,%eax
  801021:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801026:	89 03                	mov    %eax,(%ebx)
		return envid;
  801028:	e9 f2 00 00 00       	jmp    80111f <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  80102d:	e8 41 fb ff ff       	call   800b73 <sys_getenvid>
  801032:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801035:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	c1 e8 16             	shr    $0x16,%eax
  80103f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801046:	a8 01                	test   $0x1,%al
  801048:	74 17                	je     801061 <fork+0xa2>
  80104a:	89 da                	mov    %ebx,%edx
  80104c:	c1 ea 0c             	shr    $0xc,%edx
  80104f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801056:	a8 01                	test   $0x1,%al
  801058:	74 07                	je     801061 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  80105a:	89 f0                	mov    %esi,%eax
  80105c:	e8 67 fd ff ff       	call   800dc8 <duppage>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801061:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801067:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80106d:	75 cb                	jne    80103a <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  80106f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801076:	00 
  801077:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80107e:	ee 
  80107f:	89 3c 24             	mov    %edi,(%esp)
  801082:	e8 2a fb ff ff       	call   800bb1 <sys_page_alloc>
  801087:	85 c0                	test   %eax,%eax
  801089:	79 1c                	jns    8010a7 <fork+0xe8>
  80108b:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  801092:	00 
  801093:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  80109a:	00 
  80109b:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  8010a2:	e8 41 03 00 00       	call   8013e8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8010a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010b6:	c1 e0 07             	shl    $0x7,%eax
  8010b9:	29 d0                	sub    %edx,%eax
  8010bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c0:	8b 40 64             	mov    0x64(%eax),%eax
  8010c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c7:	89 3c 24             	mov    %edi,(%esp)
  8010ca:	e8 2f fc ff ff       	call   800cfe <sys_env_set_pgfault_upcall>
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	79 1c                	jns    8010ef <fork+0x130>
  8010d3:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  8010ea:	e8 f9 02 00 00       	call   8013e8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8010ef:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8010f6:	00 
  8010f7:	89 3c 24             	mov    %edi,(%esp)
  8010fa:	e8 ac fb ff ff       	call   800cab <sys_env_set_status>
  8010ff:	85 c0                	test   %eax,%eax
  801101:	79 1c                	jns    80111f <fork+0x160>
  801103:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  80110a:	00 
  80110b:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  801112:	00 
  801113:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  80111a:	e8 c9 02 00 00       	call   8013e8 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  80111f:	89 f8                	mov    %edi,%eax
  801121:	83 c4 2c             	add    $0x2c,%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <sfork>:

// Challenge!
int
sfork(void)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	57                   	push   %edi
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
  80112f:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  801132:	c7 04 24 8f 0e 80 00 	movl   $0x800e8f,(%esp)
  801139:	e8 02 03 00 00       	call   801440 <set_pgfault_handler>
  80113e:	ba 07 00 00 00       	mov    $0x7,%edx
  801143:	89 d0                	mov    %edx,%eax
  801145:	cd 30                	int    $0x30
  801147:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80114a:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  80114c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801150:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  801157:	e8 b8 f0 ff ff       	call   800214 <cprintf>
	if (envid<0)
  80115c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801160:	79 1c                	jns    80117e <sfork+0x55>
		panic("sfork : error!\n");
  801162:	c7 44 24 08 47 1a 80 	movl   $0x801a47,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  801179:	e8 6a 02 00 00       	call   8013e8 <_panic>
	if (envid==0){
  80117e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801182:	75 28                	jne    8011ac <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801184:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80118a:	e8 e4 f9 ff ff       	call   800b73 <sys_getenvid>
  80118f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801194:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80119b:	c1 e0 07             	shl    $0x7,%eax
  80119e:	29 d0                	sub    %edx,%eax
  8011a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a5:	89 03                	mov    %eax,(%ebx)
		return envid;
  8011a7:	e9 18 01 00 00       	jmp    8012c4 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8011ac:	e8 c2 f9 ff ff       	call   800b73 <sys_getenvid>
  8011b1:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8011b3:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	c1 e8 16             	shr    $0x16,%eax
  8011bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c4:	a8 01                	test   $0x1,%al
  8011c6:	74 2c                	je     8011f4 <sfork+0xcb>
  8011c8:	89 d8                	mov    %ebx,%eax
  8011ca:	c1 e8 0c             	shr    $0xc,%eax
  8011cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d4:	a8 01                	test   $0x1,%al
  8011d6:	74 1c                	je     8011f4 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8011d8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011df:	00 
  8011e0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011e4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ec:	89 3c 24             	mov    %edi,(%esp)
  8011ef:	e8 11 fa ff ff       	call   800c05 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8011f4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011fa:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801200:	75 b6                	jne    8011b8 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  801202:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120a:	e8 b9 fb ff ff       	call   800dc8 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  80120f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801216:	00 
  801217:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80121e:	ee 
  80121f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801222:	89 04 24             	mov    %eax,(%esp)
  801225:	e8 87 f9 ff ff       	call   800bb1 <sys_page_alloc>
  80122a:	85 c0                	test   %eax,%eax
  80122c:	79 1c                	jns    80124a <sfork+0x121>
  80122e:	c7 44 24 08 47 1a 80 	movl   $0x801a47,0x8(%esp)
  801235:	00 
  801236:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  80123d:	00 
  80123e:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  801245:	e8 9e 01 00 00       	call   8013e8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  80124a:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801250:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801257:	c1 e7 07             	shl    $0x7,%edi
  80125a:	29 d7                	sub    %edx,%edi
  80125c:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 8d fa ff ff       	call   800cfe <sys_env_set_pgfault_upcall>
  801271:	85 c0                	test   %eax,%eax
  801273:	79 1c                	jns    801291 <sfork+0x168>
  801275:	c7 44 24 08 47 1a 80 	movl   $0x801a47,0x8(%esp)
  80127c:	00 
  80127d:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801284:	00 
  801285:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  80128c:	e8 57 01 00 00       	call   8013e8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801291:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801298:	00 
  801299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80129c:	89 04 24             	mov    %eax,(%esp)
  80129f:	e8 07 fa ff ff       	call   800cab <sys_env_set_status>
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	79 1c                	jns    8012c4 <sfork+0x19b>
  8012a8:	c7 44 24 08 47 1a 80 	movl   $0x801a47,0x8(%esp)
  8012af:	00 
  8012b0:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8012b7:	00 
  8012b8:	c7 04 24 20 1a 80 00 	movl   $0x801a20,(%esp)
  8012bf:	e8 24 01 00 00       	call   8013e8 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8012c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c7:	83 c4 3c             	add    $0x3c,%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5f                   	pop    %edi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    
	...

008012d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	56                   	push   %esi
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 10             	sub    $0x10,%esp
  8012d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012de:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	
	if (pg==NULL)pg=(void *)UTOP;
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	75 05                	jne    8012ea <ipc_recv+0x1a>
  8012e5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  8012ea:	89 04 24             	mov    %eax,(%esp)
  8012ed:	e8 82 fa ff ff       	call   800d74 <sys_ipc_recv>
	// cprintf("%x\n",err);
	if (err < 0){
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	79 16                	jns    80130c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  8012f6:	85 db                	test   %ebx,%ebx
  8012f8:	74 06                	je     801300 <ipc_recv+0x30>
  8012fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801300:	85 f6                	test   %esi,%esi
  801302:	74 32                	je     801336 <ipc_recv+0x66>
  801304:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80130a:	eb 2a                	jmp    801336 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80130c:	85 db                	test   %ebx,%ebx
  80130e:	74 0c                	je     80131c <ipc_recv+0x4c>
  801310:	a1 04 20 80 00       	mov    0x802004,%eax
  801315:	8b 00                	mov    (%eax),%eax
  801317:	8b 40 74             	mov    0x74(%eax),%eax
  80131a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80131c:	85 f6                	test   %esi,%esi
  80131e:	74 0c                	je     80132c <ipc_recv+0x5c>
  801320:	a1 04 20 80 00       	mov    0x802004,%eax
  801325:	8b 00                	mov    (%eax),%eax
  801327:	8b 40 78             	mov    0x78(%eax),%eax
  80132a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  80132c:	a1 04 20 80 00       	mov    0x802004,%eax
  801331:	8b 00                	mov    (%eax),%eax
  801333:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	57                   	push   %edi
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
  801343:	83 ec 1c             	sub    $0x1c,%esp
  801346:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80134f:	85 db                	test   %ebx,%ebx
  801351:	75 05                	jne    801358 <ipc_send+0x1b>
  801353:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801358:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80135c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801360:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
  801367:	89 04 24             	mov    %eax,(%esp)
  80136a:	e8 e2 f9 ff ff       	call   800d51 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80136f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801372:	75 07                	jne    80137b <ipc_send+0x3e>
  801374:	e8 19 f8 ff ff       	call   800b92 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801379:	eb dd                	jmp    801358 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  80137b:	85 c0                	test   %eax,%eax
  80137d:	79 1c                	jns    80139b <ipc_send+0x5e>
  80137f:	c7 44 24 08 57 1a 80 	movl   $0x801a57,0x8(%esp)
  801386:	00 
  801387:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80138e:	00 
  80138f:	c7 04 24 69 1a 80 00 	movl   $0x801a69,(%esp)
  801396:	e8 4d 00 00 00       	call   8013e8 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  80139b:	83 c4 1c             	add    $0x1c,%esp
  80139e:	5b                   	pop    %ebx
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013af:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	c1 e2 07             	shl    $0x7,%edx
  8013bb:	29 ca                	sub    %ecx,%edx
  8013bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013c3:	8b 52 50             	mov    0x50(%edx),%edx
  8013c6:	39 da                	cmp    %ebx,%edx
  8013c8:	75 0f                	jne    8013d9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8013ca:	c1 e0 07             	shl    $0x7,%eax
  8013cd:	29 c8                	sub    %ecx,%eax
  8013cf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013d4:	8b 40 40             	mov    0x40(%eax),%eax
  8013d7:	eb 0c                	jmp    8013e5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013d9:	40                   	inc    %eax
  8013da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013df:	75 ce                	jne    8013af <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013e1:	66 b8 00 00          	mov    $0x0,%ax
}
  8013e5:	5b                   	pop    %ebx
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013f0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013f3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013f9:	e8 75 f7 ff ff       	call   800b73 <sys_getenvid>
  8013fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801401:	89 54 24 10          	mov    %edx,0x10(%esp)
  801405:	8b 55 08             	mov    0x8(%ebp),%edx
  801408:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80140c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801410:	89 44 24 04          	mov    %eax,0x4(%esp)
  801414:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  80141b:	e8 f4 ed ff ff       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801420:	89 74 24 04          	mov    %esi,0x4(%esp)
  801424:	8b 45 10             	mov    0x10(%ebp),%eax
  801427:	89 04 24             	mov    %eax,(%esp)
  80142a:	e8 84 ed ff ff       	call   8001b3 <vcprintf>
	cprintf("\n");
  80142f:	c7 04 24 55 1a 80 00 	movl   $0x801a55,(%esp)
  801436:	e8 d9 ed ff ff       	call   800214 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80143b:	cc                   	int3   
  80143c:	eb fd                	jmp    80143b <_panic+0x53>
	...

00801440 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	53                   	push   %ebx
  801444:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  801447:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80144e:	75 6f                	jne    8014bf <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  801450:	e8 1e f7 ff ff       	call   800b73 <sys_getenvid>
  801455:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  801457:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80145e:	00 
  80145f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801466:	ee 
  801467:	89 04 24             	mov    %eax,(%esp)
  80146a:	e8 42 f7 ff ff       	call   800bb1 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  80146f:	85 c0                	test   %eax,%eax
  801471:	79 1c                	jns    80148f <set_pgfault_handler+0x4f>
  801473:	c7 44 24 08 98 1a 80 	movl   $0x801a98,0x8(%esp)
  80147a:	00 
  80147b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801482:	00 
  801483:	c7 04 24 f4 1a 80 00 	movl   $0x801af4,(%esp)
  80148a:	e8 59 ff ff ff       	call   8013e8 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80148f:	c7 44 24 04 d0 14 80 	movl   $0x8014d0,0x4(%esp)
  801496:	00 
  801497:	89 1c 24             	mov    %ebx,(%esp)
  80149a:	e8 5f f8 ff ff       	call   800cfe <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	79 1c                	jns    8014bf <set_pgfault_handler+0x7f>
  8014a3:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  8014aa:	00 
  8014ab:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8014b2:	00 
  8014b3:	c7 04 24 f4 1a 80 00 	movl   $0x801af4,(%esp)
  8014ba:	e8 29 ff ff ff       	call   8013e8 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8014c7:	83 c4 14             	add    $0x14,%esp
  8014ca:	5b                   	pop    %ebx
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    
  8014cd:	00 00                	add    %al,(%eax)
	...

008014d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014d1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8014d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014d8:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8014db:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8014df:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8014e4:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8014e8:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8014ea:	83 c4 08             	add    $0x8,%esp
	popal
  8014ed:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8014ee:	83 c4 04             	add    $0x4,%esp
	popfl
  8014f1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8014f2:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8014f5:	c3                   	ret    
	...

008014f8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8014f8:	55                   	push   %ebp
  8014f9:	57                   	push   %edi
  8014fa:	56                   	push   %esi
  8014fb:	83 ec 10             	sub    $0x10,%esp
  8014fe:	8b 74 24 20          	mov    0x20(%esp),%esi
  801502:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80150e:	89 cd                	mov    %ecx,%ebp
  801510:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801514:	85 c0                	test   %eax,%eax
  801516:	75 2c                	jne    801544 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801518:	39 f9                	cmp    %edi,%ecx
  80151a:	77 68                	ja     801584 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80151c:	85 c9                	test   %ecx,%ecx
  80151e:	75 0b                	jne    80152b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801520:	b8 01 00 00 00       	mov    $0x1,%eax
  801525:	31 d2                	xor    %edx,%edx
  801527:	f7 f1                	div    %ecx
  801529:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80152b:	31 d2                	xor    %edx,%edx
  80152d:	89 f8                	mov    %edi,%eax
  80152f:	f7 f1                	div    %ecx
  801531:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801533:	89 f0                	mov    %esi,%eax
  801535:	f7 f1                	div    %ecx
  801537:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801539:	89 f0                	mov    %esi,%eax
  80153b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801544:	39 f8                	cmp    %edi,%eax
  801546:	77 2c                	ja     801574 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801548:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80154b:	83 f6 1f             	xor    $0x1f,%esi
  80154e:	75 4c                	jne    80159c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801550:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801552:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801557:	72 0a                	jb     801563 <__udivdi3+0x6b>
  801559:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80155d:	0f 87 ad 00 00 00    	ja     801610 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801563:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801568:	89 f0                	mov    %esi,%eax
  80156a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    
  801573:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801574:	31 ff                	xor    %edi,%edi
  801576:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801578:	89 f0                	mov    %esi,%eax
  80157a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    
  801583:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801584:	89 fa                	mov    %edi,%edx
  801586:	89 f0                	mov    %esi,%eax
  801588:	f7 f1                	div    %ecx
  80158a:	89 c6                	mov    %eax,%esi
  80158c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80158e:	89 f0                	mov    %esi,%eax
  801590:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	5e                   	pop    %esi
  801596:	5f                   	pop    %edi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    
  801599:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80159c:	89 f1                	mov    %esi,%ecx
  80159e:	d3 e0                	shl    %cl,%eax
  8015a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8015a4:	b8 20 00 00 00       	mov    $0x20,%eax
  8015a9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8015ab:	89 ea                	mov    %ebp,%edx
  8015ad:	88 c1                	mov    %al,%cl
  8015af:	d3 ea                	shr    %cl,%edx
  8015b1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8015b5:	09 ca                	or     %ecx,%edx
  8015b7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8015bb:	89 f1                	mov    %esi,%ecx
  8015bd:	d3 e5                	shl    %cl,%ebp
  8015bf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8015c3:	89 fd                	mov    %edi,%ebp
  8015c5:	88 c1                	mov    %al,%cl
  8015c7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8015c9:	89 fa                	mov    %edi,%edx
  8015cb:	89 f1                	mov    %esi,%ecx
  8015cd:	d3 e2                	shl    %cl,%edx
  8015cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015d3:	88 c1                	mov    %al,%cl
  8015d5:	d3 ef                	shr    %cl,%edi
  8015d7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015d9:	89 f8                	mov    %edi,%eax
  8015db:	89 ea                	mov    %ebp,%edx
  8015dd:	f7 74 24 08          	divl   0x8(%esp)
  8015e1:	89 d1                	mov    %edx,%ecx
  8015e3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8015e5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015e9:	39 d1                	cmp    %edx,%ecx
  8015eb:	72 17                	jb     801604 <__udivdi3+0x10c>
  8015ed:	74 09                	je     8015f8 <__udivdi3+0x100>
  8015ef:	89 fe                	mov    %edi,%esi
  8015f1:	31 ff                	xor    %edi,%edi
  8015f3:	e9 41 ff ff ff       	jmp    801539 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8015f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015fc:	89 f1                	mov    %esi,%ecx
  8015fe:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801600:	39 c2                	cmp    %eax,%edx
  801602:	73 eb                	jae    8015ef <__udivdi3+0xf7>
		{
		  q0--;
  801604:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801607:	31 ff                	xor    %edi,%edi
  801609:	e9 2b ff ff ff       	jmp    801539 <__udivdi3+0x41>
  80160e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801610:	31 f6                	xor    %esi,%esi
  801612:	e9 22 ff ff ff       	jmp    801539 <__udivdi3+0x41>
	...

00801618 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801618:	55                   	push   %ebp
  801619:	57                   	push   %edi
  80161a:	56                   	push   %esi
  80161b:	83 ec 20             	sub    $0x20,%esp
  80161e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801622:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801626:	89 44 24 14          	mov    %eax,0x14(%esp)
  80162a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80162e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801632:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801636:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801638:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80163a:	85 ed                	test   %ebp,%ebp
  80163c:	75 16                	jne    801654 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80163e:	39 f1                	cmp    %esi,%ecx
  801640:	0f 86 a6 00 00 00    	jbe    8016ec <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801646:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801648:	89 d0                	mov    %edx,%eax
  80164a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80164c:	83 c4 20             	add    $0x20,%esp
  80164f:	5e                   	pop    %esi
  801650:	5f                   	pop    %edi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    
  801653:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801654:	39 f5                	cmp    %esi,%ebp
  801656:	0f 87 ac 00 00 00    	ja     801708 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80165c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80165f:	83 f0 1f             	xor    $0x1f,%eax
  801662:	89 44 24 10          	mov    %eax,0x10(%esp)
  801666:	0f 84 a8 00 00 00    	je     801714 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80166c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801670:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801672:	bf 20 00 00 00       	mov    $0x20,%edi
  801677:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80167b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80167f:	89 f9                	mov    %edi,%ecx
  801681:	d3 e8                	shr    %cl,%eax
  801683:	09 e8                	or     %ebp,%eax
  801685:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801689:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80168d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801691:	d3 e0                	shl    %cl,%eax
  801693:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801697:	89 f2                	mov    %esi,%edx
  801699:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80169b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80169f:	d3 e0                	shl    %cl,%eax
  8016a1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8016a5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016a9:	89 f9                	mov    %edi,%ecx
  8016ab:	d3 e8                	shr    %cl,%eax
  8016ad:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8016af:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	f7 74 24 18          	divl   0x18(%esp)
  8016b7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8016b9:	f7 64 24 0c          	mull   0xc(%esp)
  8016bd:	89 c5                	mov    %eax,%ebp
  8016bf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8016c1:	39 d6                	cmp    %edx,%esi
  8016c3:	72 67                	jb     80172c <__umoddi3+0x114>
  8016c5:	74 75                	je     80173c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8016c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8016cb:	29 e8                	sub    %ebp,%eax
  8016cd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8016cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016d3:	d3 e8                	shr    %cl,%eax
  8016d5:	89 f2                	mov    %esi,%edx
  8016d7:	89 f9                	mov    %edi,%ecx
  8016d9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8016db:	09 d0                	or     %edx,%eax
  8016dd:	89 f2                	mov    %esi,%edx
  8016df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016e3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016e5:	83 c4 20             	add    $0x20,%esp
  8016e8:	5e                   	pop    %esi
  8016e9:	5f                   	pop    %edi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8016ec:	85 c9                	test   %ecx,%ecx
  8016ee:	75 0b                	jne    8016fb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8016f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f5:	31 d2                	xor    %edx,%edx
  8016f7:	f7 f1                	div    %ecx
  8016f9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8016fb:	89 f0                	mov    %esi,%eax
  8016fd:	31 d2                	xor    %edx,%edx
  8016ff:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801701:	89 f8                	mov    %edi,%eax
  801703:	e9 3e ff ff ff       	jmp    801646 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801708:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80170a:	83 c4 20             	add    $0x20,%esp
  80170d:	5e                   	pop    %esi
  80170e:	5f                   	pop    %edi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    
  801711:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801714:	39 f5                	cmp    %esi,%ebp
  801716:	72 04                	jb     80171c <__umoddi3+0x104>
  801718:	39 f9                	cmp    %edi,%ecx
  80171a:	77 06                	ja     801722 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80171c:	89 f2                	mov    %esi,%edx
  80171e:	29 cf                	sub    %ecx,%edi
  801720:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801722:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801724:	83 c4 20             	add    $0x20,%esp
  801727:	5e                   	pop    %esi
  801728:	5f                   	pop    %edi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    
  80172b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80172c:	89 d1                	mov    %edx,%ecx
  80172e:	89 c5                	mov    %eax,%ebp
  801730:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801734:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801738:	eb 8d                	jmp    8016c7 <__umoddi3+0xaf>
  80173a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80173c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801740:	72 ea                	jb     80172c <__umoddi3+0x114>
  801742:	89 f1                	mov    %esi,%ecx
  801744:	eb 81                	jmp    8016c7 <__umoddi3+0xaf>
