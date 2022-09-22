
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 2c 0b 00 00       	call   800b6f <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 40 16 80 00 	movl   $0x801640,(%esp)
  800052:	e8 b9 01 00 00       	call   800210 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	53                   	push   %ebx
  800081:	83 ec 44             	sub    $0x44,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8a 45 0c             	mov    0xc(%ebp),%al
  80008a:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 f3 06 00 00       	call   800788 <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 51 16 80 	movl   $0x801651,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 9c 06 00 00       	call   80075d <snprintf>
	if (fork() == 0) {
  8000c1:	e8 f5 0e 00 00       	call   800fbb <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 82 00 00 00       	call   80015c <exit>
	}
}
  8000da:	83 c4 44             	add    $0x44,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 20             	sub    $0x20,%esp
  8000fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800102:	e8 68 0a 00 00       	call   800b6f <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	29 d0                	sub    %edx,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800123:	a3 04 20 80 00       	mov    %eax,0x802004
  800128:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  80012c:	c7 04 24 03 19 80 00 	movl   $0x801903,(%esp)
  800133:	e8 d8 00 00 00       	call   800210 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800138:	85 f6                	test   %esi,%esi
  80013a:	7e 07                	jle    800143 <libmain+0x4f>
		binaryname = argv[0];
  80013c:	8b 03                	mov    (%ebx),%eax
  80013e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800143:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800147:	89 34 24             	mov    %esi,(%esp)
  80014a:	e8 91 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  80014f:	e8 08 00 00 00       	call   80015c <exit>
}
  800154:	83 c4 20             	add    $0x20,%esp
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    
	...

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800169:	e8 af 09 00 00       	call   800b1d <sys_env_destroy>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 14             	sub    $0x14,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800183:	40                   	inc    %eax
  800184:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800186:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018b:	75 19                	jne    8001a6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80018d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800194:	00 
  800195:	8d 43 08             	lea    0x8(%ebx),%eax
  800198:	89 04 24             	mov    %eax,(%esp)
  80019b:	e8 40 09 00 00       	call   800ae0 <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001a6:	ff 43 04             	incl   0x4(%ebx)
}
  8001a9:	83 c4 14             	add    $0x14,%esp
  8001ac:	5b                   	pop    %ebx
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	c7 04 24 70 01 80 00 	movl   $0x800170,(%esp)
  8001eb:	e8 82 01 00 00       	call   800372 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800200:	89 04 24             	mov    %eax,(%esp)
  800203:	e8 d8 08 00 00       	call   800ae0 <sys_cputs>

	return b.cnt;
}
  800208:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021d:	8b 45 08             	mov    0x8(%ebp),%eax
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	e8 87 ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    
	...

0080022c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 3c             	sub    $0x3c,%esp
  800235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800238:	89 d7                	mov    %edx,%edi
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800240:	8b 45 0c             	mov    0xc(%ebp),%eax
  800243:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800246:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800249:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024c:	85 c0                	test   %eax,%eax
  80024e:	75 08                	jne    800258 <printnum+0x2c>
  800250:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800253:	39 45 10             	cmp    %eax,0x10(%ebp)
  800256:	77 57                	ja     8002af <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	89 74 24 10          	mov    %esi,0x10(%esp)
  80025c:	4b                   	dec    %ebx
  80025d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800261:	8b 45 10             	mov    0x10(%ebp),%eax
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80026c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800270:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800277:	00 
  800278:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800281:	89 44 24 04          	mov    %eax,0x4(%esp)
  800285:	e8 52 11 00 00       	call   8013dc <__udivdi3>
  80028a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	89 54 24 04          	mov    %edx,0x4(%esp)
  800299:	89 fa                	mov    %edi,%edx
  80029b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029e:	e8 89 ff ff ff       	call   80022c <printnum>
  8002a3:	eb 0f                	jmp    8002b4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a9:	89 34 24             	mov    %esi,(%esp)
  8002ac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002af:	4b                   	dec    %ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f f1                	jg     8002a5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ca:	00 
  8002cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d8:	e8 1f 12 00 00       	call   8014fc <__umoddi3>
  8002dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e1:	0f be 80 60 16 80 00 	movsbl 0x801660(%eax),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ee:	83 c4 3c             	add    $0x3c,%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f9:	83 fa 01             	cmp    $0x1,%edx
  8002fc:	7e 0e                	jle    80030c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 08             	lea    0x8(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	8b 52 04             	mov    0x4(%edx),%edx
  80030a:	eb 22                	jmp    80032e <getuint+0x38>
	else if (lflag)
  80030c:	85 d2                	test   %edx,%edx
  80030e:	74 10                	je     800320 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 0e                	jmp    80032e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 04             	lea    0x4(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800336:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 08                	jae    800348 <sprintputch+0x18>
		*b->buf++ = ch;
  800340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800343:	88 0a                	mov    %cl,(%edx)
  800345:	42                   	inc    %edx
  800346:	89 10                	mov    %edx,(%eax)
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800350:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800353:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800357:	8b 45 10             	mov    0x10(%ebp),%eax
  80035a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	e8 02 00 00 00       	call   800372 <vprintfmt>
	va_end(ap);
}
  800370:	c9                   	leave  
  800371:	c3                   	ret    

00800372 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
  800378:	83 ec 4c             	sub    $0x4c,%esp
  80037b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037e:	8b 75 10             	mov    0x10(%ebp),%esi
  800381:	eb 12                	jmp    800395 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800383:	85 c0                	test   %eax,%eax
  800385:	0f 84 6b 03 00 00    	je     8006f6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80038b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800395:	0f b6 06             	movzbl (%esi),%eax
  800398:	46                   	inc    %esi
  800399:	83 f8 25             	cmp    $0x25,%eax
  80039c:	75 e5                	jne    800383 <vprintfmt+0x11>
  80039e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003a2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003a9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ae:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ba:	eb 26                	jmp    8003e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003c3:	eb 1d                	jmp    8003e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003cc:	eb 14                	jmp    8003e2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d8:	eb 08                	jmp    8003e2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	0f b6 06             	movzbl (%esi),%eax
  8003e5:	8d 56 01             	lea    0x1(%esi),%edx
  8003e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003eb:	8a 16                	mov    (%esi),%dl
  8003ed:	83 ea 23             	sub    $0x23,%edx
  8003f0:	80 fa 55             	cmp    $0x55,%dl
  8003f3:	0f 87 e1 02 00 00    	ja     8006da <vprintfmt+0x368>
  8003f9:	0f b6 d2             	movzbl %dl,%edx
  8003fc:	ff 24 95 20 17 80 00 	jmp    *0x801720(,%edx,4)
  800403:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800406:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80040e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800412:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800415:	8d 50 d0             	lea    -0x30(%eax),%edx
  800418:	83 fa 09             	cmp    $0x9,%edx
  80041b:	77 2a                	ja     800447 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80041e:	eb eb                	jmp    80040b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80042e:	eb 17                	jmp    800447 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800430:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800434:	78 98                	js     8003ce <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800439:	eb a7                	jmp    8003e2 <vprintfmt+0x70>
  80043b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800445:	eb 9b                	jmp    8003e2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044b:	79 95                	jns    8003e2 <vprintfmt+0x70>
  80044d:	eb 8b                	jmp    8003da <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800453:	eb 8d                	jmp    8003e2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046d:	e9 23 ff ff ff       	jmp    800395 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 50 04             	lea    0x4(%eax),%edx
  800478:	89 55 14             	mov    %edx,0x14(%ebp)
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	85 c0                	test   %eax,%eax
  80047f:	79 02                	jns    800483 <vprintfmt+0x111>
  800481:	f7 d8                	neg    %eax
  800483:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800485:	83 f8 08             	cmp    $0x8,%eax
  800488:	7f 0b                	jg     800495 <vprintfmt+0x123>
  80048a:	8b 04 85 80 18 80 00 	mov    0x801880(,%eax,4),%eax
  800491:	85 c0                	test   %eax,%eax
  800493:	75 23                	jne    8004b8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800495:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800499:	c7 44 24 08 78 16 80 	movl   $0x801678,0x8(%esp)
  8004a0:	00 
  8004a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	e8 9a fe ff ff       	call   80034a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b3:	e9 dd fe ff ff       	jmp    800395 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004bc:	c7 44 24 08 81 16 80 	movl   $0x801681,0x8(%esp)
  8004c3:	00 
  8004c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cb:	89 14 24             	mov    %edx,(%esp)
  8004ce:	e8 77 fe ff ff       	call   80034a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d6:	e9 ba fe ff ff       	jmp    800395 <vprintfmt+0x23>
  8004db:	89 f9                	mov    %edi,%ecx
  8004dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 50 04             	lea    0x4(%eax),%edx
  8004e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ec:	8b 30                	mov    (%eax),%esi
  8004ee:	85 f6                	test   %esi,%esi
  8004f0:	75 05                	jne    8004f7 <vprintfmt+0x185>
				p = "(null)";
  8004f2:	be 71 16 80 00       	mov    $0x801671,%esi
			if (width > 0 && padc != '-')
  8004f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fb:	0f 8e 84 00 00 00    	jle    800585 <vprintfmt+0x213>
  800501:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800505:	74 7e                	je     800585 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800507:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80050b:	89 34 24             	mov    %esi,(%esp)
  80050e:	e8 8b 02 00 00       	call   80079e <strnlen>
  800513:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800516:	29 c2                	sub    %eax,%edx
  800518:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80051b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80051f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800522:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800525:	89 de                	mov    %ebx,%esi
  800527:	89 d3                	mov    %edx,%ebx
  800529:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	eb 0b                	jmp    800538 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80052d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800531:	89 3c 24             	mov    %edi,(%esp)
  800534:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	4b                   	dec    %ebx
  800538:	85 db                	test   %ebx,%ebx
  80053a:	7f f1                	jg     80052d <vprintfmt+0x1bb>
  80053c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80053f:	89 f3                	mov    %esi,%ebx
  800541:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800547:	85 c0                	test   %eax,%eax
  800549:	79 05                	jns    800550 <vprintfmt+0x1de>
  80054b:	b8 00 00 00 00       	mov    $0x0,%eax
  800550:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800553:	29 c2                	sub    %eax,%edx
  800555:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800558:	eb 2b                	jmp    800585 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055e:	74 18                	je     800578 <vprintfmt+0x206>
  800560:	8d 50 e0             	lea    -0x20(%eax),%edx
  800563:	83 fa 5e             	cmp    $0x5e,%edx
  800566:	76 10                	jbe    800578 <vprintfmt+0x206>
					putch('?', putdat);
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	eb 0a                	jmp    800582 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800578:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800582:	ff 4d e4             	decl   -0x1c(%ebp)
  800585:	0f be 06             	movsbl (%esi),%eax
  800588:	46                   	inc    %esi
  800589:	85 c0                	test   %eax,%eax
  80058b:	74 21                	je     8005ae <vprintfmt+0x23c>
  80058d:	85 ff                	test   %edi,%edi
  80058f:	78 c9                	js     80055a <vprintfmt+0x1e8>
  800591:	4f                   	dec    %edi
  800592:	79 c6                	jns    80055a <vprintfmt+0x1e8>
  800594:	8b 7d 08             	mov    0x8(%ebp),%edi
  800597:	89 de                	mov    %ebx,%esi
  800599:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80059c:	eb 18                	jmp    8005b6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ab:	4b                   	dec    %ebx
  8005ac:	eb 08                	jmp    8005b6 <vprintfmt+0x244>
  8005ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b1:	89 de                	mov    %ebx,%esi
  8005b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005b6:	85 db                	test   %ebx,%ebx
  8005b8:	7f e4                	jg     80059e <vprintfmt+0x22c>
  8005ba:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005bd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c2:	e9 ce fd ff ff       	jmp    800395 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c7:	83 f9 01             	cmp    $0x1,%ecx
  8005ca:	7e 10                	jle    8005dc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 08             	lea    0x8(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 30                	mov    (%eax),%esi
  8005d7:	8b 78 04             	mov    0x4(%eax),%edi
  8005da:	eb 26                	jmp    800602 <vprintfmt+0x290>
	else if (lflag)
  8005dc:	85 c9                	test   %ecx,%ecx
  8005de:	74 12                	je     8005f2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 30                	mov    (%eax),%esi
  8005eb:	89 f7                	mov    %esi,%edi
  8005ed:	c1 ff 1f             	sar    $0x1f,%edi
  8005f0:	eb 10                	jmp    800602 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 30                	mov    (%eax),%esi
  8005fd:	89 f7                	mov    %esi,%edi
  8005ff:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800602:	85 ff                	test   %edi,%edi
  800604:	78 0a                	js     800610 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060b:	e9 8c 00 00 00       	jmp    80069c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80061e:	f7 de                	neg    %esi
  800620:	83 d7 00             	adc    $0x0,%edi
  800623:	f7 df                	neg    %edi
			}
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	eb 70                	jmp    80069c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062c:	89 ca                	mov    %ecx,%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 c0 fc ff ff       	call   8002f6 <getuint>
  800636:	89 c6                	mov    %eax,%esi
  800638:	89 d7                	mov    %edx,%edi
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80063f:	eb 5b                	jmp    80069c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800641:	89 ca                	mov    %ecx,%edx
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	e8 ab fc ff ff       	call   8002f6 <getuint>
  80064b:	89 c6                	mov    %eax,%esi
  80064d:	89 d7                	mov    %edx,%edi
			base = 8;
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800654:	eb 46                	jmp    80069c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800656:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800661:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067b:	8b 30                	mov    (%eax),%esi
  80067d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800682:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800687:	eb 13                	jmp    80069c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 63 fc ff ff       	call   8002f6 <getuint>
  800693:	89 c6                	mov    %eax,%esi
  800695:	89 d7                	mov    %edx,%edi
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006af:	89 34 24             	mov    %esi,(%esp)
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b6:	89 da                	mov    %ebx,%edx
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	e8 6c fb ff ff       	call   80022c <printnum>
			break;
  8006c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c3:	e9 cd fc ff ff       	jmp    800395 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d5:	e9 bb fc ff ff       	jmp    800395 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e8:	eb 01                	jmp    8006eb <vprintfmt+0x379>
  8006ea:	4e                   	dec    %esi
  8006eb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ef:	75 f9                	jne    8006ea <vprintfmt+0x378>
  8006f1:	e9 9f fc ff ff       	jmp    800395 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006f6:	83 c4 4c             	add    $0x4c,%esp
  8006f9:	5b                   	pop    %ebx
  8006fa:	5e                   	pop    %esi
  8006fb:	5f                   	pop    %edi
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	83 ec 28             	sub    $0x28,%esp
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800711:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	74 30                	je     80074f <vsnprintf+0x51>
  80071f:	85 d2                	test   %edx,%edx
  800721:	7e 33                	jle    800756 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
  80072d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800731:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800734:	89 44 24 04          	mov    %eax,0x4(%esp)
  800738:	c7 04 24 30 03 80 00 	movl   $0x800330,(%esp)
  80073f:	e8 2e fc ff ff       	call   800372 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	eb 0c                	jmp    80075b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800754:	eb 05                	jmp    80075b <vsnprintf+0x5d>
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	89 04 24             	mov    %eax,(%esp)
  80077e:	e8 7b ff ff ff       	call   8006fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    
  800785:	00 00                	add    %al,(%eax)
	...

00800788 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	eb 01                	jmp    800796 <strlen+0xe>
		n++;
  800795:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079a:	75 f9                	jne    800795 <strlen+0xd>
		n++;
	return n;
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ac:	eb 01                	jmp    8007af <strnlen+0x11>
		n++;
  8007ae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007af:	39 d0                	cmp    %edx,%eax
  8007b1:	74 06                	je     8007b9 <strnlen+0x1b>
  8007b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b7:	75 f5                	jne    8007ae <strnlen+0x10>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007d0:	42                   	inc    %edx
  8007d1:	84 c9                	test   %cl,%cl
  8007d3:	75 f5                	jne    8007ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e2:	89 1c 24             	mov    %ebx,(%esp)
  8007e5:	e8 9e ff ff ff       	call   800788 <strlen>
	strcpy(dst + len, src);
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f1:	01 d8                	add    %ebx,%eax
  8007f3:	89 04 24             	mov    %eax,(%esp)
  8007f6:	e8 c0 ff ff ff       	call   8007bb <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	83 c4 08             	add    $0x8,%esp
  800800:	5b                   	pop    %ebx
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	b9 00 00 00 00       	mov    $0x0,%ecx
  800816:	eb 0c                	jmp    800824 <strncpy+0x21>
		*dst++ = *src;
  800818:	8a 1a                	mov    (%edx),%bl
  80081a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081d:	80 3a 01             	cmpb   $0x1,(%edx)
  800820:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	41                   	inc    %ecx
  800824:	39 f1                	cmp    %esi,%ecx
  800826:	75 f0                	jne    800818 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800837:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083a:	85 d2                	test   %edx,%edx
  80083c:	75 0a                	jne    800848 <strlcpy+0x1c>
  80083e:	89 f0                	mov    %esi,%eax
  800840:	eb 1a                	jmp    80085c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800842:	88 18                	mov    %bl,(%eax)
  800844:	40                   	inc    %eax
  800845:	41                   	inc    %ecx
  800846:	eb 02                	jmp    80084a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80084a:	4a                   	dec    %edx
  80084b:	74 0a                	je     800857 <strlcpy+0x2b>
  80084d:	8a 19                	mov    (%ecx),%bl
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ef                	jne    800842 <strlcpy+0x16>
  800853:	89 c2                	mov    %eax,%edx
  800855:	eb 02                	jmp    800859 <strlcpy+0x2d>
  800857:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80085c:	29 f0                	sub    %esi,%eax
}
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086b:	eb 02                	jmp    80086f <strcmp+0xd>
		p++, q++;
  80086d:	41                   	inc    %ecx
  80086e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086f:	8a 01                	mov    (%ecx),%al
  800871:	84 c0                	test   %al,%al
  800873:	74 04                	je     800879 <strcmp+0x17>
  800875:	3a 02                	cmp    (%edx),%al
  800877:	74 f4                	je     80086d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 c0             	movzbl %al,%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800890:	eb 03                	jmp    800895 <strncmp+0x12>
		n--, p++, q++;
  800892:	4a                   	dec    %edx
  800893:	40                   	inc    %eax
  800894:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800895:	85 d2                	test   %edx,%edx
  800897:	74 14                	je     8008ad <strncmp+0x2a>
  800899:	8a 18                	mov    (%eax),%bl
  80089b:	84 db                	test   %bl,%bl
  80089d:	74 04                	je     8008a3 <strncmp+0x20>
  80089f:	3a 19                	cmp    (%ecx),%bl
  8008a1:	74 ef                	je     800892 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a3:	0f b6 00             	movzbl (%eax),%eax
  8008a6:	0f b6 11             	movzbl (%ecx),%edx
  8008a9:	29 d0                	sub    %edx,%eax
  8008ab:	eb 05                	jmp    8008b2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008be:	eb 05                	jmp    8008c5 <strchr+0x10>
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 0c                	je     8008d0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	40                   	inc    %eax
  8008c5:	8a 10                	mov    (%eax),%dl
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f5                	jne    8008c0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008db:	eb 05                	jmp    8008e2 <strfind+0x10>
		if (*s == c)
  8008dd:	38 ca                	cmp    %cl,%dl
  8008df:	74 07                	je     8008e8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008e1:	40                   	inc    %eax
  8008e2:	8a 10                	mov    (%eax),%dl
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	75 f5                	jne    8008dd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f9:	85 c9                	test   %ecx,%ecx
  8008fb:	74 30                	je     80092d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800903:	75 25                	jne    80092a <memset+0x40>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 20                	jne    80092a <memset+0x40>
		c &= 0xFF;
  80090a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090d:	89 d3                	mov    %edx,%ebx
  80090f:	c1 e3 08             	shl    $0x8,%ebx
  800912:	89 d6                	mov    %edx,%esi
  800914:	c1 e6 18             	shl    $0x18,%esi
  800917:	89 d0                	mov    %edx,%eax
  800919:	c1 e0 10             	shl    $0x10,%eax
  80091c:	09 f0                	or     %esi,%eax
  80091e:	09 d0                	or     %edx,%eax
  800920:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800922:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800925:	fc                   	cld    
  800926:	f3 ab                	rep stos %eax,%es:(%edi)
  800928:	eb 03                	jmp    80092d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800942:	39 c6                	cmp    %eax,%esi
  800944:	73 34                	jae    80097a <memmove+0x46>
  800946:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800949:	39 d0                	cmp    %edx,%eax
  80094b:	73 2d                	jae    80097a <memmove+0x46>
		s += n;
		d += n;
  80094d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	75 1b                	jne    800970 <memmove+0x3c>
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 13                	jne    800970 <memmove+0x3c>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 0e                	jne    800970 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800962:	83 ef 04             	sub    $0x4,%edi
  800965:	8d 72 fc             	lea    -0x4(%edx),%esi
  800968:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096b:	fd                   	std    
  80096c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096e:	eb 07                	jmp    800977 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800970:	4f                   	dec    %edi
  800971:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800974:	fd                   	std    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800977:	fc                   	cld    
  800978:	eb 20                	jmp    80099a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800980:	75 13                	jne    800995 <memmove+0x61>
  800982:	a8 03                	test   $0x3,%al
  800984:	75 0f                	jne    800995 <memmove+0x61>
  800986:	f6 c1 03             	test   $0x3,%cl
  800989:	75 0a                	jne    800995 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098e:	89 c7                	mov    %eax,%edi
  800990:	fc                   	cld    
  800991:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800993:	eb 05                	jmp    80099a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099a:	5e                   	pop    %esi
  80099b:	5f                   	pop    %edi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	89 04 24             	mov    %eax,(%esp)
  8009b8:	e8 77 ff ff ff       	call   800934 <memmove>
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d3:	eb 16                	jmp    8009eb <memcmp+0x2c>
		if (*s1 != *s2)
  8009d5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009d8:	42                   	inc    %edx
  8009d9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009dd:	38 c8                	cmp    %cl,%al
  8009df:	74 0a                	je     8009eb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c0             	movzbl %al,%eax
  8009e4:	0f b6 c9             	movzbl %cl,%ecx
  8009e7:	29 c8                	sub    %ecx,%eax
  8009e9:	eb 09                	jmp    8009f4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009eb:	39 da                	cmp    %ebx,%edx
  8009ed:	75 e6                	jne    8009d5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a02:	89 c2                	mov    %eax,%edx
  800a04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a07:	eb 05                	jmp    800a0e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	38 08                	cmp    %cl,(%eax)
  800a0b:	74 05                	je     800a12 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0d:	40                   	inc    %eax
  800a0e:	39 d0                	cmp    %edx,%eax
  800a10:	72 f7                	jb     800a09 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 01                	jmp    800a23 <strtol+0xf>
		s++;
  800a22:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a23:	8a 02                	mov    (%edx),%al
  800a25:	3c 20                	cmp    $0x20,%al
  800a27:	74 f9                	je     800a22 <strtol+0xe>
  800a29:	3c 09                	cmp    $0x9,%al
  800a2b:	74 f5                	je     800a22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2d:	3c 2b                	cmp    $0x2b,%al
  800a2f:	75 08                	jne    800a39 <strtol+0x25>
		s++;
  800a31:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a32:	bf 00 00 00 00       	mov    $0x0,%edi
  800a37:	eb 13                	jmp    800a4c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	75 0a                	jne    800a47 <strtol+0x33>
		s++, neg = 1;
  800a3d:	8d 52 01             	lea    0x1(%edx),%edx
  800a40:	bf 01 00 00 00       	mov    $0x1,%edi
  800a45:	eb 05                	jmp    800a4c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	74 05                	je     800a55 <strtol+0x41>
  800a50:	83 fb 10             	cmp    $0x10,%ebx
  800a53:	75 28                	jne    800a7d <strtol+0x69>
  800a55:	8a 02                	mov    (%edx),%al
  800a57:	3c 30                	cmp    $0x30,%al
  800a59:	75 10                	jne    800a6b <strtol+0x57>
  800a5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a5f:	75 0a                	jne    800a6b <strtol+0x57>
		s += 2, base = 16;
  800a61:	83 c2 02             	add    $0x2,%edx
  800a64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a69:	eb 12                	jmp    800a7d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a6b:	85 db                	test   %ebx,%ebx
  800a6d:	75 0e                	jne    800a7d <strtol+0x69>
  800a6f:	3c 30                	cmp    $0x30,%al
  800a71:	75 05                	jne    800a78 <strtol+0x64>
		s++, base = 8;
  800a73:	42                   	inc    %edx
  800a74:	b3 08                	mov    $0x8,%bl
  800a76:	eb 05                	jmp    800a7d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a78:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a82:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a84:	8a 0a                	mov    (%edx),%cl
  800a86:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a89:	80 fb 09             	cmp    $0x9,%bl
  800a8c:	77 08                	ja     800a96 <strtol+0x82>
			dig = *s - '0';
  800a8e:	0f be c9             	movsbl %cl,%ecx
  800a91:	83 e9 30             	sub    $0x30,%ecx
  800a94:	eb 1e                	jmp    800ab4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a96:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 08                	ja     800aa6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a9e:	0f be c9             	movsbl %cl,%ecx
  800aa1:	83 e9 57             	sub    $0x57,%ecx
  800aa4:	eb 0e                	jmp    800ab4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aa6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aa9:	80 fb 19             	cmp    $0x19,%bl
  800aac:	77 12                	ja     800ac0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aae:	0f be c9             	movsbl %cl,%ecx
  800ab1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab4:	39 f1                	cmp    %esi,%ecx
  800ab6:	7d 0c                	jge    800ac4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ab8:	42                   	inc    %edx
  800ab9:	0f af c6             	imul   %esi,%eax
  800abc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800abe:	eb c4                	jmp    800a84 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ac0:	89 c1                	mov    %eax,%ecx
  800ac2:	eb 02                	jmp    800ac6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aca:	74 05                	je     800ad1 <strtol+0xbd>
		*endptr = (char *) s;
  800acc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800acf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ad1:	85 ff                	test   %edi,%edi
  800ad3:	74 04                	je     800ad9 <strtol+0xc5>
  800ad5:	89 c8                	mov    %ecx,%eax
  800ad7:	f7 d8                	neg    %eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    
	...

00800ae0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	89 c7                	mov    %eax,%edi
  800af5:	89 c6                	mov    %eax,%esi
  800af7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cgetc>:

int
sys_cgetc(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b30:	8b 55 08             	mov    0x8(%ebp),%edx
  800b33:	89 cb                	mov    %ecx,%ebx
  800b35:	89 cf                	mov    %ecx,%edi
  800b37:	89 ce                	mov    %ecx,%esi
  800b39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 28                	jle    800b67 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b43:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b4a:	00 
  800b4b:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800b52:	00 
  800b53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b5a:	00 
  800b5b:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800b62:	e8 65 07 00 00       	call   8012cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b67:	83 c4 2c             	add    $0x2c,%esp
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b75:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7f:	89 d1                	mov    %edx,%ecx
  800b81:	89 d3                	mov    %edx,%ebx
  800b83:	89 d7                	mov    %edx,%edi
  800b85:	89 d6                	mov    %edx,%esi
  800b87:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <sys_yield>:

void
sys_yield(void)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9e:	89 d1                	mov    %edx,%ecx
  800ba0:	89 d3                	mov    %edx,%ebx
  800ba2:	89 d7                	mov    %edx,%edi
  800ba4:	89 d6                	mov    %edx,%esi
  800ba6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	be 00 00 00 00       	mov    $0x0,%esi
  800bbb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 f7                	mov    %esi,%edi
  800bcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	7e 28                	jle    800bf9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bdc:	00 
  800bdd:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800be4:	00 
  800be5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bec:	00 
  800bed:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800bf4:	e8 d3 06 00 00       	call   8012cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf9:	83 c4 2c             	add    $0x2c,%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 28                	jle    800c4c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c2f:	00 
  800c30:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800c37:	00 
  800c38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3f:	00 
  800c40:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800c47:	e8 80 06 00 00       	call   8012cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4c:	83 c4 2c             	add    $0x2c,%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c62:	b8 06 00 00 00       	mov    $0x6,%eax
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	89 df                	mov    %ebx,%edi
  800c6f:	89 de                	mov    %ebx,%esi
  800c71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 28                	jle    800c9f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c82:	00 
  800c83:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800c8a:	00 
  800c8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c92:	00 
  800c93:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800c9a:	e8 2d 06 00 00       	call   8012cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9f:	83 c4 2c             	add    $0x2c,%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 28                	jle    800cf2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cce:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800cdd:	00 
  800cde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce5:	00 
  800ce6:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800ced:	e8 da 05 00 00       	call   8012cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf2:	83 c4 2c             	add    $0x2c,%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 28                	jle    800d45 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d21:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d28:	00 
  800d29:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800d30:	00 
  800d31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d38:	00 
  800d39:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800d40:	e8 87 05 00 00       	call   8012cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d45:	83 c4 2c             	add    $0x2c,%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	be 00 00 00 00       	mov    $0x0,%esi
  800d58:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800d79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 cb                	mov    %ecx,%ebx
  800d88:	89 cf                	mov    %ecx,%edi
  800d8a:	89 ce                	mov    %ecx,%esi
  800d8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 28                	jle    800dba <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d96:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800da5:	00 
  800da6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dad:	00 
  800dae:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800db5:	e8 12 05 00 00       	call   8012cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dba:	83 c4 2c             	add    $0x2c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
	...

00800dc4 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 3c             	sub    $0x3c,%esp
  800dcd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800dd0:	89 d6                	mov    %edx,%esi
  800dd2:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800dd5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800ddf:	e8 8b fd ff ff       	call   800b6f <sys_getenvid>
  800de4:	89 c7                	mov    %eax,%edi
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800de9:	25 02 08 00 00       	and    $0x802,%eax
  800dee:	83 f8 01             	cmp    $0x1,%eax
  800df1:	19 db                	sbb    %ebx,%ebx
  800df3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800df9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800dff:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e03:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e12:	89 3c 24             	mov    %edi,(%esp)
  800e15:	e8 e7 fd ff ff       	call   800c01 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 1c                	jns    800e3a <duppage+0x76>
  800e1e:	c7 44 24 08 cf 18 80 	movl   $0x8018cf,0x8(%esp)
  800e25:	00 
  800e26:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800e2d:	00 
  800e2e:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800e35:	e8 92 04 00 00       	call   8012cc <_panic>
	if ((perm|~pte)&PTE_COW){
  800e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e3d:	f7 d0                	not    %eax
  800e3f:	09 d8                	or     %ebx,%eax
  800e41:	f6 c4 08             	test   $0x8,%ah
  800e44:	74 38                	je     800e7e <duppage+0xba>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800e46:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e4a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e52:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e56:	89 3c 24             	mov    %edi,(%esp)
  800e59:	e8 a3 fd ff ff       	call   800c01 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	79 1c                	jns    800e7e <duppage+0xba>
  800e62:	c7 44 24 08 cf 18 80 	movl   $0x8018cf,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800e79:	e8 4e 04 00 00       	call   8012cc <_panic>
	}
	return 0;
	panic("duppage not implemented");
	return 0;
}
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	83 c4 3c             	add    $0x3c,%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
  800e90:	83 ec 20             	sub    $0x20,%esp
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e96:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800e98:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e9c:	75 1c                	jne    800eba <pgfault+0x2f>
		panic("pgfault: error!\n");
  800e9e:	c7 44 24 08 eb 18 80 	movl   $0x8018eb,0x8(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800ead:	00 
  800eae:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800eb5:	e8 12 04 00 00       	call   8012cc <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	c1 e8 0c             	shr    $0xc,%eax
  800ebf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec6:	f6 c4 08             	test   $0x8,%ah
  800ec9:	75 1c                	jne    800ee7 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800ecb:	c7 44 24 08 eb 18 80 	movl   $0x8018eb,0x8(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800eda:	00 
  800edb:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800ee2:	e8 e5 03 00 00       	call   8012cc <_panic>
	envid_t envid = sys_getenvid();
  800ee7:	e8 83 fc ff ff       	call   800b6f <sys_getenvid>
  800eec:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800eee:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800efd:	00 
  800efe:	89 04 24             	mov    %eax,(%esp)
  800f01:	e8 a7 fc ff ff       	call   800bad <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 1c                	jns    800f26 <pgfault+0x9b>
  800f0a:	c7 44 24 08 eb 18 80 	movl   $0x8018eb,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f19:	00 
  800f1a:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800f21:	e8 a6 03 00 00       	call   8012cc <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800f26:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800f2c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f33:	00 
  800f34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f38:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f3f:	e8 5a fa ff ff       	call   80099e <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800f44:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f4b:	00 
  800f4c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f54:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f5b:	00 
  800f5c:	89 1c 24             	mov    %ebx,(%esp)
  800f5f:	e8 9d fc ff ff       	call   800c01 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 1c                	jns    800f84 <pgfault+0xf9>
  800f68:	c7 44 24 08 eb 18 80 	movl   $0x8018eb,0x8(%esp)
  800f6f:	00 
  800f70:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  800f77:	00 
  800f78:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800f7f:	e8 48 03 00 00       	call   8012cc <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  800f84:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f8b:	00 
  800f8c:	89 1c 24             	mov    %ebx,(%esp)
  800f8f:	e8 c0 fc ff ff       	call   800c54 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 1c                	jns    800fb4 <pgfault+0x129>
  800f98:	c7 44 24 08 eb 18 80 	movl   $0x8018eb,0x8(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800fa7:	00 
  800fa8:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800faf:	e8 18 03 00 00       	call   8012cc <_panic>
	return;
	panic("pgfault not implemented");
}
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fc4:	c7 04 24 8b 0e 80 00 	movl   $0x800e8b,(%esp)
  800fcb:	e8 54 03 00 00       	call   801324 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd0:	bf 07 00 00 00       	mov    $0x7,%edi
  800fd5:	89 f8                	mov    %edi,%eax
  800fd7:	cd 30                	int    $0x30
  800fd9:	89 c7                	mov    %eax,%edi
  800fdb:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	79 1c                	jns    800ffd <fork+0x42>
		panic("fork : error!\n");
  800fe1:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  800ff8:	e8 cf 02 00 00       	call   8012cc <_panic>
	if (envid==0){
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	75 28                	jne    801029 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801001:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  801007:	e8 63 fb ff ff       	call   800b6f <sys_getenvid>
  80100c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801011:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801018:	c1 e0 07             	shl    $0x7,%eax
  80101b:	29 d0                	sub    %edx,%eax
  80101d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801022:	89 03                	mov    %eax,(%ebx)
		return envid;
  801024:	e9 f2 00 00 00       	jmp    80111b <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801029:	e8 41 fb ff ff       	call   800b6f <sys_getenvid>
  80102e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801031:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801036:	89 d8                	mov    %ebx,%eax
  801038:	c1 e8 16             	shr    $0x16,%eax
  80103b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801042:	a8 01                	test   $0x1,%al
  801044:	74 17                	je     80105d <fork+0xa2>
  801046:	89 da                	mov    %ebx,%edx
  801048:	c1 ea 0c             	shr    $0xc,%edx
  80104b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801052:	a8 01                	test   $0x1,%al
  801054:	74 07                	je     80105d <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801056:	89 f0                	mov    %esi,%eax
  801058:	e8 67 fd ff ff       	call   800dc4 <duppage>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80105d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801063:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801069:	75 cb                	jne    801036 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  80106b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80107a:	ee 
  80107b:	89 3c 24             	mov    %edi,(%esp)
  80107e:	e8 2a fb ff ff       	call   800bad <sys_page_alloc>
  801083:	85 c0                	test   %eax,%eax
  801085:	79 1c                	jns    8010a3 <fork+0xe8>
  801087:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  80109e:	e8 29 02 00 00       	call   8012cc <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8010a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010b2:	c1 e0 07             	shl    $0x7,%eax
  8010b5:	29 d0                	sub    %edx,%eax
  8010b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010bc:	8b 40 64             	mov    0x64(%eax),%eax
  8010bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c3:	89 3c 24             	mov    %edi,(%esp)
  8010c6:	e8 2f fc ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 1c                	jns    8010eb <fork+0x130>
  8010cf:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  8010d6:	00 
  8010d7:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8010de:	00 
  8010df:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  8010e6:	e8 e1 01 00 00       	call   8012cc <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8010eb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8010f2:	00 
  8010f3:	89 3c 24             	mov    %edi,(%esp)
  8010f6:	e8 ac fb ff ff       	call   800ca7 <sys_env_set_status>
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	79 1c                	jns    80111b <fork+0x160>
  8010ff:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  801106:	00 
  801107:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  80110e:	00 
  80110f:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  801116:	e8 b1 01 00 00       	call   8012cc <_panic>
	return envid_child;
	panic("fork not implemented");
}
  80111b:	89 f8                	mov    %edi,%eax
  80111d:	83 c4 2c             	add    $0x2c,%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <sfork>:

// Challenge!
int
sfork(void)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  80112e:	c7 04 24 8b 0e 80 00 	movl   $0x800e8b,(%esp)
  801135:	e8 ea 01 00 00       	call   801324 <set_pgfault_handler>
  80113a:	ba 07 00 00 00       	mov    $0x7,%edx
  80113f:	89 d0                	mov    %edx,%eax
  801141:	cd 30                	int    $0x30
  801143:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801146:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114c:	c7 04 24 fc 18 80 00 	movl   $0x8018fc,(%esp)
  801153:	e8 b8 f0 ff ff       	call   800210 <cprintf>
	if (envid<0)
  801158:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80115c:	79 1c                	jns    80117a <sfork+0x55>
		panic("sfork : error!\n");
  80115e:	c7 44 24 08 07 19 80 	movl   $0x801907,0x8(%esp)
  801165:	00 
  801166:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80116d:	00 
  80116e:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  801175:	e8 52 01 00 00       	call   8012cc <_panic>
	if (envid==0){
  80117a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80117e:	75 28                	jne    8011a8 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801180:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  801186:	e8 e4 f9 ff ff       	call   800b6f <sys_getenvid>
  80118b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801190:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801197:	c1 e0 07             	shl    $0x7,%eax
  80119a:	29 d0                	sub    %edx,%eax
  80119c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a1:	89 03                	mov    %eax,(%ebx)
		return envid;
  8011a3:	e9 18 01 00 00       	jmp    8012c0 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8011a8:	e8 c2 f9 ff ff       	call   800b6f <sys_getenvid>
  8011ad:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8011af:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8011b4:	89 d8                	mov    %ebx,%eax
  8011b6:	c1 e8 16             	shr    $0x16,%eax
  8011b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c0:	a8 01                	test   $0x1,%al
  8011c2:	74 2c                	je     8011f0 <sfork+0xcb>
  8011c4:	89 d8                	mov    %ebx,%eax
  8011c6:	c1 e8 0c             	shr    $0xc,%eax
  8011c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d0:	a8 01                	test   $0x1,%al
  8011d2:	74 1c                	je     8011f0 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8011d4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011db:	00 
  8011dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011e0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011e8:	89 3c 24             	mov    %edi,(%esp)
  8011eb:	e8 11 fa ff ff       	call   800c01 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8011f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011f6:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8011fc:	75 b6                	jne    8011b4 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8011fe:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801203:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801206:	e8 b9 fb ff ff       	call   800dc4 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  80120b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801212:	00 
  801213:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80121a:	ee 
  80121b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80121e:	89 04 24             	mov    %eax,(%esp)
  801221:	e8 87 f9 ff ff       	call   800bad <sys_page_alloc>
  801226:	85 c0                	test   %eax,%eax
  801228:	79 1c                	jns    801246 <sfork+0x121>
  80122a:	c7 44 24 08 07 19 80 	movl   $0x801907,0x8(%esp)
  801231:	00 
  801232:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801239:	00 
  80123a:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  801241:	e8 86 00 00 00       	call   8012cc <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801246:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  80124c:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801253:	c1 e7 07             	shl    $0x7,%edi
  801256:	29 d7                	sub    %edx,%edi
  801258:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80125e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801265:	89 04 24             	mov    %eax,(%esp)
  801268:	e8 8d fa ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  80126d:	85 c0                	test   %eax,%eax
  80126f:	79 1c                	jns    80128d <sfork+0x168>
  801271:	c7 44 24 08 07 19 80 	movl   $0x801907,0x8(%esp)
  801278:	00 
  801279:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801280:	00 
  801281:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  801288:	e8 3f 00 00 00       	call   8012cc <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80128d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801294:	00 
  801295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801298:	89 04 24             	mov    %eax,(%esp)
  80129b:	e8 07 fa ff ff       	call   800ca7 <sys_env_set_status>
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	79 1c                	jns    8012c0 <sfork+0x19b>
  8012a4:	c7 44 24 08 07 19 80 	movl   $0x801907,0x8(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8012b3:	00 
  8012b4:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  8012bb:	e8 0c 00 00 00       	call   8012cc <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8012c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c3:	83 c4 3c             	add    $0x3c,%esp
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5f                   	pop    %edi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    
	...

008012cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012d7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8012dd:	e8 8d f8 ff ff       	call   800b6f <sys_getenvid>
  8012e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	c7 04 24 18 19 80 00 	movl   $0x801918,(%esp)
  8012ff:	e8 0c ef ff ff       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801304:	89 74 24 04          	mov    %esi,0x4(%esp)
  801308:	8b 45 10             	mov    0x10(%ebp),%eax
  80130b:	89 04 24             	mov    %eax,(%esp)
  80130e:	e8 9c ee ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801313:	c7 04 24 15 19 80 00 	movl   $0x801915,(%esp)
  80131a:	e8 f1 ee ff ff       	call   800210 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80131f:	cc                   	int3   
  801320:	eb fd                	jmp    80131f <_panic+0x53>
	...

00801324 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80132b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801332:	75 6f                	jne    8013a3 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  801334:	e8 36 f8 ff ff       	call   800b6f <sys_getenvid>
  801339:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80133b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801342:	00 
  801343:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80134a:	ee 
  80134b:	89 04 24             	mov    %eax,(%esp)
  80134e:	e8 5a f8 ff ff       	call   800bad <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  801353:	85 c0                	test   %eax,%eax
  801355:	79 1c                	jns    801373 <set_pgfault_handler+0x4f>
  801357:	c7 44 24 08 3c 19 80 	movl   $0x80193c,0x8(%esp)
  80135e:	00 
  80135f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801366:	00 
  801367:	c7 04 24 98 19 80 00 	movl   $0x801998,(%esp)
  80136e:	e8 59 ff ff ff       	call   8012cc <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801373:	c7 44 24 04 b4 13 80 	movl   $0x8013b4,0x4(%esp)
  80137a:	00 
  80137b:	89 1c 24             	mov    %ebx,(%esp)
  80137e:	e8 77 f9 ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  801383:	85 c0                	test   %eax,%eax
  801385:	79 1c                	jns    8013a3 <set_pgfault_handler+0x7f>
  801387:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  80138e:	00 
  80138f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801396:	00 
  801397:	c7 04 24 98 19 80 00 	movl   $0x801998,(%esp)
  80139e:	e8 29 ff ff ff       	call   8012cc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013ab:	83 c4 14             	add    $0x14,%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    
  8013b1:	00 00                	add    %al,(%eax)
	...

008013b4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013b4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013b5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013ba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013bc:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8013bf:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8013c3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8013c8:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8013cc:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8013ce:	83 c4 08             	add    $0x8,%esp
	popal
  8013d1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8013d2:	83 c4 04             	add    $0x4,%esp
	popfl
  8013d5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8013d6:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8013d9:	c3                   	ret    
	...

008013dc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8013dc:	55                   	push   %ebp
  8013dd:	57                   	push   %edi
  8013de:	56                   	push   %esi
  8013df:	83 ec 10             	sub    $0x10,%esp
  8013e2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013e6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8013ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8013f2:	89 cd                	mov    %ecx,%ebp
  8013f4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	75 2c                	jne    801428 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8013fc:	39 f9                	cmp    %edi,%ecx
  8013fe:	77 68                	ja     801468 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801400:	85 c9                	test   %ecx,%ecx
  801402:	75 0b                	jne    80140f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801404:	b8 01 00 00 00       	mov    $0x1,%eax
  801409:	31 d2                	xor    %edx,%edx
  80140b:	f7 f1                	div    %ecx
  80140d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80140f:	31 d2                	xor    %edx,%edx
  801411:	89 f8                	mov    %edi,%eax
  801413:	f7 f1                	div    %ecx
  801415:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801417:	89 f0                	mov    %esi,%eax
  801419:	f7 f1                	div    %ecx
  80141b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80141d:	89 f0                	mov    %esi,%eax
  80141f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801428:	39 f8                	cmp    %edi,%eax
  80142a:	77 2c                	ja     801458 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80142c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80142f:	83 f6 1f             	xor    $0x1f,%esi
  801432:	75 4c                	jne    801480 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801434:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801436:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80143b:	72 0a                	jb     801447 <__udivdi3+0x6b>
  80143d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801441:	0f 87 ad 00 00 00    	ja     8014f4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801447:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80144c:	89 f0                	mov    %esi,%eax
  80144e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	5e                   	pop    %esi
  801454:	5f                   	pop    %edi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    
  801457:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801458:	31 ff                	xor    %edi,%edi
  80145a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80145c:	89 f0                	mov    %esi,%eax
  80145e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    
  801467:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801468:	89 fa                	mov    %edi,%edx
  80146a:	89 f0                	mov    %esi,%eax
  80146c:	f7 f1                	div    %ecx
  80146e:	89 c6                	mov    %eax,%esi
  801470:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801472:	89 f0                	mov    %esi,%eax
  801474:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	5e                   	pop    %esi
  80147a:	5f                   	pop    %edi
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    
  80147d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801480:	89 f1                	mov    %esi,%ecx
  801482:	d3 e0                	shl    %cl,%eax
  801484:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801488:	b8 20 00 00 00       	mov    $0x20,%eax
  80148d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80148f:	89 ea                	mov    %ebp,%edx
  801491:	88 c1                	mov    %al,%cl
  801493:	d3 ea                	shr    %cl,%edx
  801495:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801499:	09 ca                	or     %ecx,%edx
  80149b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80149f:	89 f1                	mov    %esi,%ecx
  8014a1:	d3 e5                	shl    %cl,%ebp
  8014a3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8014a7:	89 fd                	mov    %edi,%ebp
  8014a9:	88 c1                	mov    %al,%cl
  8014ab:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8014ad:	89 fa                	mov    %edi,%edx
  8014af:	89 f1                	mov    %esi,%ecx
  8014b1:	d3 e2                	shl    %cl,%edx
  8014b3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014b7:	88 c1                	mov    %al,%cl
  8014b9:	d3 ef                	shr    %cl,%edi
  8014bb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014bd:	89 f8                	mov    %edi,%eax
  8014bf:	89 ea                	mov    %ebp,%edx
  8014c1:	f7 74 24 08          	divl   0x8(%esp)
  8014c5:	89 d1                	mov    %edx,%ecx
  8014c7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8014c9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014cd:	39 d1                	cmp    %edx,%ecx
  8014cf:	72 17                	jb     8014e8 <__udivdi3+0x10c>
  8014d1:	74 09                	je     8014dc <__udivdi3+0x100>
  8014d3:	89 fe                	mov    %edi,%esi
  8014d5:	31 ff                	xor    %edi,%edi
  8014d7:	e9 41 ff ff ff       	jmp    80141d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8014dc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014e0:	89 f1                	mov    %esi,%ecx
  8014e2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014e4:	39 c2                	cmp    %eax,%edx
  8014e6:	73 eb                	jae    8014d3 <__udivdi3+0xf7>
		{
		  q0--;
  8014e8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8014eb:	31 ff                	xor    %edi,%edi
  8014ed:	e9 2b ff ff ff       	jmp    80141d <__udivdi3+0x41>
  8014f2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014f4:	31 f6                	xor    %esi,%esi
  8014f6:	e9 22 ff ff ff       	jmp    80141d <__udivdi3+0x41>
	...

008014fc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8014fc:	55                   	push   %ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	83 ec 20             	sub    $0x20,%esp
  801502:	8b 44 24 30          	mov    0x30(%esp),%eax
  801506:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80150a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80150e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801512:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801516:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80151a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80151c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80151e:	85 ed                	test   %ebp,%ebp
  801520:	75 16                	jne    801538 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801522:	39 f1                	cmp    %esi,%ecx
  801524:	0f 86 a6 00 00 00    	jbe    8015d0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80152a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80152c:	89 d0                	mov    %edx,%eax
  80152e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801530:	83 c4 20             	add    $0x20,%esp
  801533:	5e                   	pop    %esi
  801534:	5f                   	pop    %edi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    
  801537:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801538:	39 f5                	cmp    %esi,%ebp
  80153a:	0f 87 ac 00 00 00    	ja     8015ec <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801540:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801543:	83 f0 1f             	xor    $0x1f,%eax
  801546:	89 44 24 10          	mov    %eax,0x10(%esp)
  80154a:	0f 84 a8 00 00 00    	je     8015f8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801550:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801554:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801556:	bf 20 00 00 00       	mov    $0x20,%edi
  80155b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80155f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801563:	89 f9                	mov    %edi,%ecx
  801565:	d3 e8                	shr    %cl,%eax
  801567:	09 e8                	or     %ebp,%eax
  801569:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80156d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801571:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801575:	d3 e0                	shl    %cl,%eax
  801577:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80157b:	89 f2                	mov    %esi,%edx
  80157d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80157f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801583:	d3 e0                	shl    %cl,%eax
  801585:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801589:	8b 44 24 14          	mov    0x14(%esp),%eax
  80158d:	89 f9                	mov    %edi,%ecx
  80158f:	d3 e8                	shr    %cl,%eax
  801591:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801593:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801595:	89 f2                	mov    %esi,%edx
  801597:	f7 74 24 18          	divl   0x18(%esp)
  80159b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80159d:	f7 64 24 0c          	mull   0xc(%esp)
  8015a1:	89 c5                	mov    %eax,%ebp
  8015a3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015a5:	39 d6                	cmp    %edx,%esi
  8015a7:	72 67                	jb     801610 <__umoddi3+0x114>
  8015a9:	74 75                	je     801620 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8015ab:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8015af:	29 e8                	sub    %ebp,%eax
  8015b1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8015b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015b7:	d3 e8                	shr    %cl,%eax
  8015b9:	89 f2                	mov    %esi,%edx
  8015bb:	89 f9                	mov    %edi,%ecx
  8015bd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8015bf:	09 d0                	or     %edx,%eax
  8015c1:	89 f2                	mov    %esi,%edx
  8015c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015c7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015c9:	83 c4 20             	add    $0x20,%esp
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8015d0:	85 c9                	test   %ecx,%ecx
  8015d2:	75 0b                	jne    8015df <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8015d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d9:	31 d2                	xor    %edx,%edx
  8015db:	f7 f1                	div    %ecx
  8015dd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8015df:	89 f0                	mov    %esi,%eax
  8015e1:	31 d2                	xor    %edx,%edx
  8015e3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015e5:	89 f8                	mov    %edi,%eax
  8015e7:	e9 3e ff ff ff       	jmp    80152a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8015ec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015ee:	83 c4 20             	add    $0x20,%esp
  8015f1:	5e                   	pop    %esi
  8015f2:	5f                   	pop    %edi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    
  8015f5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015f8:	39 f5                	cmp    %esi,%ebp
  8015fa:	72 04                	jb     801600 <__umoddi3+0x104>
  8015fc:	39 f9                	cmp    %edi,%ecx
  8015fe:	77 06                	ja     801606 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801600:	89 f2                	mov    %esi,%edx
  801602:	29 cf                	sub    %ecx,%edi
  801604:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801606:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801608:	83 c4 20             	add    $0x20,%esp
  80160b:	5e                   	pop    %esi
  80160c:	5f                   	pop    %edi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    
  80160f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801610:	89 d1                	mov    %edx,%ecx
  801612:	89 c5                	mov    %eax,%ebp
  801614:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801618:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80161c:	eb 8d                	jmp    8015ab <__umoddi3+0xaf>
  80161e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801620:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801624:	72 ea                	jb     801610 <__umoddi3+0x114>
  801626:	89 f1                	mov    %esi,%ecx
  801628:	eb 81                	jmp    8015ab <__umoddi3+0xaf>
