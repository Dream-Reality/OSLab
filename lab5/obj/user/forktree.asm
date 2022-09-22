
obj/user/forktree.debug:     file format elf32-i386


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
  80003e:	e8 24 0b 00 00       	call   800b67 <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  800052:	e8 b1 01 00 00       	call   800208 <cprintf>

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
  800090:	e8 eb 06 00 00       	call   800780 <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 51 26 80 	movl   $0x802651,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 94 06 00 00       	call   800755 <snprintf>
	if (fork() == 0) {
  8000c1:	e8 82 0f 00 00       	call   801048 <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 72 00 00 00       	call   80014c <exit>
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
  8000e6:	c7 04 24 d1 29 80 00 	movl   $0x8029d1,(%esp)
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
  800102:	e8 60 0a 00 00       	call   800b67 <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	29 d0                	sub    %edx,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800123:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800128:	85 f6                	test   %esi,%esi
  80012a:	7e 07                	jle    800133 <libmain+0x3f>
		binaryname = argv[0];
  80012c:	8b 03                	mov    (%ebx),%eax
  80012e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800133:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800137:	89 34 24             	mov    %esi,(%esp)
  80013a:	e8 a1 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  80013f:	e8 08 00 00 00       	call   80014c <exit>
}
  800144:	83 c4 20             	add    $0x20,%esp
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800152:	e8 ea 13 00 00       	call   801541 <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 b2 09 00 00       	call   800b15 <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 14             	sub    $0x14,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 19                	jne    80019e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800185:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018c:	00 
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 40 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019e:	ff 43 04             	incl   0x4(%ebx)
}
  8001a1:	83 c4 14             	add    $0x14,%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	c7 04 24 68 01 80 00 	movl   $0x800168,(%esp)
  8001e3:	e8 82 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 d8 08 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	89 44 24 04          	mov    %eax,0x4(%esp)
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	e8 87 ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    
	...

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 3c             	sub    $0x3c,%esp
  80022d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800230:	89 d7                	mov    %edx,%edi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800241:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	85 c0                	test   %eax,%eax
  800246:	75 08                	jne    800250 <printnum+0x2c>
  800248:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024e:	77 57                	ja     8002a7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	89 74 24 10          	mov    %esi,0x10(%esp)
  800254:	4b                   	dec    %ebx
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	8b 45 10             	mov    0x10(%ebp),%eax
  80025c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800260:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800264:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	e8 52 21 00 00       	call   8023d4 <__udivdi3>
  800282:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800291:	89 fa                	mov    %edi,%edx
  800293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800296:	e8 89 ff ff ff       	call   800224 <printnum>
  80029b:	eb 0f                	jmp    8002ac <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a1:	89 34 24             	mov    %esi,(%esp)
  8002a4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	4b                   	dec    %ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f f1                	jg     80029d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c2:	00 
  8002c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	e8 1f 22 00 00       	call   8024f4 <__umoddi3>
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e6:	83 c4 3c             	add    $0x3c,%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f1:	83 fa 01             	cmp    $0x1,%edx
  8002f4:	7e 0e                	jle    800304 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	8b 52 04             	mov    0x4(%edx),%edx
  800302:	eb 22                	jmp    800326 <getuint+0x38>
	else if (lflag)
  800304:	85 d2                	test   %edx,%edx
  800306:	74 10                	je     800318 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 0e                	jmp    800326 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800331:	8b 10                	mov    (%eax),%edx
  800333:	3b 50 04             	cmp    0x4(%eax),%edx
  800336:	73 08                	jae    800340 <sprintputch+0x18>
		*b->buf++ = ch;
  800338:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033b:	88 0a                	mov    %cl,(%edx)
  80033d:	42                   	inc    %edx
  80033e:	89 10                	mov    %edx,(%eax)
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800348:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034f:	8b 45 10             	mov    0x10(%ebp),%eax
  800352:	89 44 24 08          	mov    %eax,0x8(%esp)
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	e8 02 00 00 00       	call   80036a <vprintfmt>
	va_end(ap);
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 4c             	sub    $0x4c,%esp
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800376:	8b 75 10             	mov    0x10(%ebp),%esi
  800379:	eb 12                	jmp    80038d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037b:	85 c0                	test   %eax,%eax
  80037d:	0f 84 6b 03 00 00    	je     8006ee <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800383:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	0f b6 06             	movzbl (%esi),%eax
  800390:	46                   	inc    %esi
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e5                	jne    80037b <vprintfmt+0x11>
  800396:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80039a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b2:	eb 26                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003bb:	eb 1d                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c4:	eb 14                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d0:	eb 08                	jmp    8003da <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	0f b6 06             	movzbl (%esi),%eax
  8003dd:	8d 56 01             	lea    0x1(%esi),%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003e3:	8a 16                	mov    (%esi),%dl
  8003e5:	83 ea 23             	sub    $0x23,%edx
  8003e8:	80 fa 55             	cmp    $0x55,%dl
  8003eb:	0f 87 e1 02 00 00    	ja     8006d2 <vprintfmt+0x368>
  8003f1:	0f b6 d2             	movzbl %dl,%edx
  8003f4:	ff 24 95 a0 27 80 00 	jmp    *0x8027a0(,%edx,4)
  8003fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fe:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800403:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800406:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80040a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80040d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800410:	83 fa 09             	cmp    $0x9,%edx
  800413:	77 2a                	ja     80043f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800415:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800416:	eb eb                	jmp    800403 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800426:	eb 17                	jmp    80043f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800428:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042c:	78 98                	js     8003c6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800431:	eb a7                	jmp    8003da <vprintfmt+0x70>
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800436:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80043d:	eb 9b                	jmp    8003da <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800443:	79 95                	jns    8003da <vprintfmt+0x70>
  800445:	eb 8b                	jmp    8003d2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044b:	eb 8d                	jmp    8003da <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800465:	e9 23 ff ff ff       	jmp    80038d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	85 c0                	test   %eax,%eax
  800477:	79 02                	jns    80047b <vprintfmt+0x111>
  800479:	f7 d8                	neg    %eax
  80047b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 0f             	cmp    $0xf,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x123>
  800482:	8b 04 85 00 29 80 00 	mov    0x802900(,%eax,4),%eax
  800489:	85 c0                	test   %eax,%eax
  80048b:	75 23                	jne    8004b0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80048d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800491:	c7 44 24 08 78 26 80 	movl   $0x802678,0x8(%esp)
  800498:	00 
  800499:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 9a fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ab:	e9 dd fe ff ff       	jmp    80038d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b4:	c7 44 24 08 79 2a 80 	movl   $0x802a79,0x8(%esp)
  8004bb:	00 
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c3:	89 14 24             	mov    %edx,(%esp)
  8004c6:	e8 77 fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ce:	e9 ba fe ff ff       	jmp    80038d <vprintfmt+0x23>
  8004d3:	89 f9                	mov    %edi,%ecx
  8004d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 30                	mov    (%eax),%esi
  8004e6:	85 f6                	test   %esi,%esi
  8004e8:	75 05                	jne    8004ef <vprintfmt+0x185>
				p = "(null)";
  8004ea:	be 71 26 80 00       	mov    $0x802671,%esi
			if (width > 0 && padc != '-')
  8004ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f3:	0f 8e 84 00 00 00    	jle    80057d <vprintfmt+0x213>
  8004f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004fd:	74 7e                	je     80057d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800503:	89 34 24             	mov    %esi,(%esp)
  800506:	e8 8b 02 00 00       	call   800796 <strnlen>
  80050b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050e:	29 c2                	sub    %eax,%edx
  800510:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800513:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800517:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80051a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80051d:	89 de                	mov    %ebx,%esi
  80051f:	89 d3                	mov    %edx,%ebx
  800521:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	eb 0b                	jmp    800530 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800525:	89 74 24 04          	mov    %esi,0x4(%esp)
  800529:	89 3c 24             	mov    %edi,(%esp)
  80052c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <vprintfmt+0x1bb>
  800534:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800537:	89 f3                	mov    %esi,%ebx
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80053c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053f:	85 c0                	test   %eax,%eax
  800541:	79 05                	jns    800548 <vprintfmt+0x1de>
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054b:	29 c2                	sub    %eax,%edx
  80054d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800550:	eb 2b                	jmp    80057d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800556:	74 18                	je     800570 <vprintfmt+0x206>
  800558:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055b:	83 fa 5e             	cmp    $0x5e,%edx
  80055e:	76 10                	jbe    800570 <vprintfmt+0x206>
					putch('?', putdat);
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	eb 0a                	jmp    80057a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	ff 4d e4             	decl   -0x1c(%ebp)
  80057d:	0f be 06             	movsbl (%esi),%eax
  800580:	46                   	inc    %esi
  800581:	85 c0                	test   %eax,%eax
  800583:	74 21                	je     8005a6 <vprintfmt+0x23c>
  800585:	85 ff                	test   %edi,%edi
  800587:	78 c9                	js     800552 <vprintfmt+0x1e8>
  800589:	4f                   	dec    %edi
  80058a:	79 c6                	jns    800552 <vprintfmt+0x1e8>
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 de                	mov    %ebx,%esi
  800591:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800594:	eb 18                	jmp    8005ae <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a3:	4b                   	dec    %ebx
  8005a4:	eb 08                	jmp    8005ae <vprintfmt+0x244>
  8005a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a9:	89 de                	mov    %ebx,%esi
  8005ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f e4                	jg     800596 <vprintfmt+0x22c>
  8005b2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ba:	e9 ce fd ff ff       	jmp    80038d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bf:	83 f9 01             	cmp    $0x1,%ecx
  8005c2:	7e 10                	jle    8005d4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 30                	mov    (%eax),%esi
  8005cf:	8b 78 04             	mov    0x4(%eax),%edi
  8005d2:	eb 26                	jmp    8005fa <vprintfmt+0x290>
	else if (lflag)
  8005d4:	85 c9                	test   %ecx,%ecx
  8005d6:	74 12                	je     8005ea <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 30                	mov    (%eax),%esi
  8005e3:	89 f7                	mov    %esi,%edi
  8005e5:	c1 ff 1f             	sar    $0x1f,%edi
  8005e8:	eb 10                	jmp    8005fa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 30                	mov    (%eax),%esi
  8005f5:	89 f7                	mov    %esi,%edi
  8005f7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	78 0a                	js     800608 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800603:	e9 8c 00 00 00       	jmp    800694 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800616:	f7 de                	neg    %esi
  800618:	83 d7 00             	adc    $0x0,%edi
  80061b:	f7 df                	neg    %edi
			}
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	eb 70                	jmp    800694 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 c0 fc ff ff       	call   8002ee <getuint>
  80062e:	89 c6                	mov    %eax,%esi
  800630:	89 d7                	mov    %edx,%edi
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800637:	eb 5b                	jmp    800694 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 ab fc ff ff       	call   8002ee <getuint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			base = 8;
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80064c:	eb 46                	jmp    800694 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80064e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800652:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800659:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800673:	8b 30                	mov    (%eax),%esi
  800675:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067f:	eb 13                	jmp    800694 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 63 fc ff ff       	call   8002ee <getuint>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	89 d7                	mov    %edx,%edi
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800694:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800698:	89 54 24 10          	mov    %edx,0x10(%esp)
  80069c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a7:	89 34 24             	mov    %esi,(%esp)
  8006aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	e8 6c fb ff ff       	call   800224 <printnum>
			break;
  8006b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006bb:	e9 cd fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cd:	e9 bb fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e0:	eb 01                	jmp    8006e3 <vprintfmt+0x379>
  8006e2:	4e                   	dec    %esi
  8006e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e7:	75 f9                	jne    8006e2 <vprintfmt+0x378>
  8006e9:	e9 9f fc ff ff       	jmp    80038d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	83 c4 4c             	add    $0x4c,%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 28             	sub    $0x28,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 30                	je     800747 <vsnprintf+0x51>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 33                	jle    80074e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800722:	8b 45 10             	mov    0x10(%ebp),%eax
  800725:	89 44 24 08          	mov    %eax,0x8(%esp)
  800729:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  800737:	e8 2e fc ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800745:	eb 0c                	jmp    800753 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074c:	eb 05                	jmp    800753 <vsnprintf+0x5d>
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 7b ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
  80077d:	00 00                	add    %al,(%eax)
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 01                	jmp    80078e <strlen+0xe>
		n++;
  80078d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f9                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 01                	jmp    8007a7 <strnlen+0x11>
		n++;
  8007a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 d0                	cmp    %edx,%eax
  8007a9:	74 06                	je     8007b1 <strnlen+0x1b>
  8007ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007af:	75 f5                	jne    8007a6 <strnlen+0x10>
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c8:	42                   	inc    %edx
  8007c9:	84 c9                	test   %cl,%cl
  8007cb:	75 f5                	jne    8007c2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007da:	89 1c 24             	mov    %ebx,(%esp)
  8007dd:	e8 9e ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	89 04 24             	mov    %eax,(%esp)
  8007ee:	e8 c0 ff ff ff       	call   8007b3 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080e:	eb 0c                	jmp    80081c <strncpy+0x21>
		*dst++ = *src;
  800810:	8a 1a                	mov    (%edx),%bl
  800812:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 3a 01             	cmpb   $0x1,(%edx)
  800818:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	41                   	inc    %ecx
  80081c:	39 f1                	cmp    %esi,%ecx
  80081e:	75 f0                	jne    800810 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800832:	85 d2                	test   %edx,%edx
  800834:	75 0a                	jne    800840 <strlcpy+0x1c>
  800836:	89 f0                	mov    %esi,%eax
  800838:	eb 1a                	jmp    800854 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083a:	88 18                	mov    %bl,(%eax)
  80083c:	40                   	inc    %eax
  80083d:	41                   	inc    %ecx
  80083e:	eb 02                	jmp    800842 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800842:	4a                   	dec    %edx
  800843:	74 0a                	je     80084f <strlcpy+0x2b>
  800845:	8a 19                	mov    (%ecx),%bl
  800847:	84 db                	test   %bl,%bl
  800849:	75 ef                	jne    80083a <strlcpy+0x16>
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	eb 02                	jmp    800851 <strlcpy+0x2d>
  80084f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800851:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800854:	29 f0                	sub    %esi,%eax
}
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800863:	eb 02                	jmp    800867 <strcmp+0xd>
		p++, q++;
  800865:	41                   	inc    %ecx
  800866:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	8a 01                	mov    (%ecx),%al
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x17>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 f4                	je     800865 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800885:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800888:	eb 03                	jmp    80088d <strncmp+0x12>
		n--, p++, q++;
  80088a:	4a                   	dec    %edx
  80088b:	40                   	inc    %eax
  80088c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088d:	85 d2                	test   %edx,%edx
  80088f:	74 14                	je     8008a5 <strncmp+0x2a>
  800891:	8a 18                	mov    (%eax),%bl
  800893:	84 db                	test   %bl,%bl
  800895:	74 04                	je     80089b <strncmp+0x20>
  800897:	3a 19                	cmp    (%ecx),%bl
  800899:	74 ef                	je     80088a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089b:	0f b6 00             	movzbl (%eax),%eax
  80089e:	0f b6 11             	movzbl (%ecx),%edx
  8008a1:	29 d0                	sub    %edx,%eax
  8008a3:	eb 05                	jmp    8008aa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b6:	eb 05                	jmp    8008bd <strchr+0x10>
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 0c                	je     8008c8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bc:	40                   	inc    %eax
  8008bd:	8a 10                	mov    (%eax),%dl
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f5                	jne    8008b8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d3:	eb 05                	jmp    8008da <strfind+0x10>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 07                	je     8008e0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d9:	40                   	inc    %eax
  8008da:	8a 10                	mov    (%eax),%dl
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f5                	jne    8008d5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f1:	85 c9                	test   %ecx,%ecx
  8008f3:	74 30                	je     800925 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fb:	75 25                	jne    800922 <memset+0x40>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 20                	jne    800922 <memset+0x40>
		c &= 0xFF;
  800902:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800905:	89 d3                	mov    %edx,%ebx
  800907:	c1 e3 08             	shl    $0x8,%ebx
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	c1 e6 18             	shl    $0x18,%esi
  80090f:	89 d0                	mov    %edx,%eax
  800911:	c1 e0 10             	shl    $0x10,%eax
  800914:	09 f0                	or     %esi,%eax
  800916:	09 d0                	or     %edx,%eax
  800918:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091d:	fc                   	cld    
  80091e:	f3 ab                	rep stos %eax,%es:(%edi)
  800920:	eb 03                	jmp    800925 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 34                	jae    800972 <memmove+0x46>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 d0                	cmp    %edx,%eax
  800943:	73 2d                	jae    800972 <memmove+0x46>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	f6 c2 03             	test   $0x3,%dl
  80094b:	75 1b                	jne    800968 <memmove+0x3c>
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 13                	jne    800968 <memmove+0x3c>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0e                	jne    800968 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 07                	jmp    80096f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800968:	4f                   	dec    %edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 20                	jmp    800992 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	75 13                	jne    80098d <memmove+0x61>
  80097a:	a8 03                	test   $0x3,%al
  80097c:	75 0f                	jne    80098d <memmove+0x61>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	75 0a                	jne    80098d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800983:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 05                	jmp    800992 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099c:	8b 45 10             	mov    0x10(%ebp),%eax
  80099f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	89 04 24             	mov    %eax,(%esp)
  8009b0:	e8 77 ff ff ff       	call   80092c <memmove>
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	eb 16                	jmp    8009e3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cd:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009d0:	42                   	inc    %edx
  8009d1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009d5:	38 c8                	cmp    %cl,%al
  8009d7:	74 0a                	je     8009e3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 c9             	movzbl %cl,%ecx
  8009df:	29 c8                	sub    %ecx,%eax
  8009e1:	eb 09                	jmp    8009ec <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e3:	39 da                	cmp    %ebx,%edx
  8009e5:	75 e6                	jne    8009cd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ff:	eb 05                	jmp    800a06 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	38 08                	cmp    %cl,(%eax)
  800a03:	74 05                	je     800a0a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a05:	40                   	inc    %eax
  800a06:	39 d0                	cmp    %edx,%eax
  800a08:	72 f7                	jb     800a01 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	eb 01                	jmp    800a1b <strtol+0xf>
		s++;
  800a1a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	8a 02                	mov    (%edx),%al
  800a1d:	3c 20                	cmp    $0x20,%al
  800a1f:	74 f9                	je     800a1a <strtol+0xe>
  800a21:	3c 09                	cmp    $0x9,%al
  800a23:	74 f5                	je     800a1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a25:	3c 2b                	cmp    $0x2b,%al
  800a27:	75 08                	jne    800a31 <strtol+0x25>
		s++;
  800a29:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2f:	eb 13                	jmp    800a44 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	75 0a                	jne    800a3f <strtol+0x33>
		s++, neg = 1;
  800a35:	8d 52 01             	lea    0x1(%edx),%edx
  800a38:	bf 01 00 00 00       	mov    $0x1,%edi
  800a3d:	eb 05                	jmp    800a44 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	74 05                	je     800a4d <strtol+0x41>
  800a48:	83 fb 10             	cmp    $0x10,%ebx
  800a4b:	75 28                	jne    800a75 <strtol+0x69>
  800a4d:	8a 02                	mov    (%edx),%al
  800a4f:	3c 30                	cmp    $0x30,%al
  800a51:	75 10                	jne    800a63 <strtol+0x57>
  800a53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a57:	75 0a                	jne    800a63 <strtol+0x57>
		s += 2, base = 16;
  800a59:	83 c2 02             	add    $0x2,%edx
  800a5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a61:	eb 12                	jmp    800a75 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a63:	85 db                	test   %ebx,%ebx
  800a65:	75 0e                	jne    800a75 <strtol+0x69>
  800a67:	3c 30                	cmp    $0x30,%al
  800a69:	75 05                	jne    800a70 <strtol+0x64>
		s++, base = 8;
  800a6b:	42                   	inc    %edx
  800a6c:	b3 08                	mov    $0x8,%bl
  800a6e:	eb 05                	jmp    800a75 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7c:	8a 0a                	mov    (%edx),%cl
  800a7e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a81:	80 fb 09             	cmp    $0x9,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x82>
			dig = *s - '0';
  800a86:	0f be c9             	movsbl %cl,%ecx
  800a89:	83 e9 30             	sub    $0x30,%ecx
  800a8c:	eb 1e                	jmp    800aac <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a96:	0f be c9             	movsbl %cl,%ecx
  800a99:	83 e9 57             	sub    $0x57,%ecx
  800a9c:	eb 0e                	jmp    800aac <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 12                	ja     800ab8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aa6:	0f be c9             	movsbl %cl,%ecx
  800aa9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aac:	39 f1                	cmp    %esi,%ecx
  800aae:	7d 0c                	jge    800abc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ab0:	42                   	inc    %edx
  800ab1:	0f af c6             	imul   %esi,%eax
  800ab4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab6:	eb c4                	jmp    800a7c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab8:	89 c1                	mov    %eax,%ecx
  800aba:	eb 02                	jmp    800abe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac2:	74 05                	je     800ac9 <strtol+0xbd>
		*endptr = (char *) s;
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac9:	85 ff                	test   %edi,%edi
  800acb:	74 04                	je     800ad1 <strtol+0xc5>
  800acd:	89 c8                	mov    %ecx,%eax
  800acf:	f7 d8                	neg    %eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
	...

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 cb                	mov    %ecx,%ebx
  800b2d:	89 cf                	mov    %ecx,%edi
  800b2f:	89 ce                	mov    %ecx,%esi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 28                	jle    800b5f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b42:	00 
  800b43:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800b4a:	00 
  800b4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b52:	00 
  800b53:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800b5a:	e8 09 16 00 00       	call   802168 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5f:	83 c4 2c             	add    $0x2c,%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 02 00 00 00       	mov    $0x2,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_yield>:

void
sys_yield(void)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b96:	89 d1                	mov    %edx,%ecx
  800b98:	89 d3                	mov    %edx,%ebx
  800b9a:	89 d7                	mov    %edx,%edi
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	be 00 00 00 00       	mov    $0x0,%esi
  800bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 f7                	mov    %esi,%edi
  800bc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7e 28                	jle    800bf1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd4:	00 
  800bd5:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800bdc:	00 
  800bdd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be4:	00 
  800be5:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800bec:	e8 77 15 00 00       	call   802168 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	83 c4 2c             	add    $0x2c,%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 05 00 00 00       	mov    $0x5,%eax
  800c07:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 28                	jle    800c44 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c20:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c27:	00 
  800c28:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800c2f:	00 
  800c30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c37:	00 
  800c38:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800c3f:	e8 24 15 00 00       	call   802168 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c44:	83 c4 2c             	add    $0x2c,%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 28                	jle    800c97 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800c82:	00 
  800c83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8a:	00 
  800c8b:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800c92:	e8 d1 14 00 00       	call   802168 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c97:	83 c4 2c             	add    $0x2c,%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cad:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	89 df                	mov    %ebx,%edi
  800cba:	89 de                	mov    %ebx,%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 28                	jle    800cea <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ccd:	00 
  800cce:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdd:	00 
  800cde:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800ce5:	e8 7e 14 00 00       	call   802168 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cea:	83 c4 2c             	add    $0x2c,%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	b8 09 00 00 00       	mov    $0x9,%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 28                	jle    800d3d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d19:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d20:	00 
  800d21:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d28:	00 
  800d29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d30:	00 
  800d31:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d38:	e8 2b 14 00 00       	call   802168 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3d:	83 c4 2c             	add    $0x2c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7e 28                	jle    800d90 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d73:	00 
  800d74:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d83:	00 
  800d84:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d8b:	e8 d8 13 00 00       	call   802168 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d90:	83 c4 2c             	add    $0x2c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	be 00 00 00 00       	mov    $0x0,%esi
  800da3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 cb                	mov    %ecx,%ebx
  800dd3:	89 cf                	mov    %ecx,%edi
  800dd5:	89 ce                	mov    %ecx,%esi
  800dd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e00:	e8 63 13 00 00       	call   802168 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    
  800e0d:	00 00                	add    %al,(%eax)
	...

00800e10 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 3c             	sub    $0x3c,%esp
  800e19:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800e1c:	89 d6                	mov    %edx,%esi
  800e1e:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800e21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e28:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800e2b:	e8 37 fd ff ff       	call   800b67 <sys_getenvid>
  800e30:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800e32:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800e39:	74 31                	je     800e6c <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800e3b:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800e42:	00 
  800e43:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e52:	89 3c 24             	mov    %edi,(%esp)
  800e55:	e8 9f fd ff ff       	call   800bf9 <sys_page_map>
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	0f 8e ae 00 00 00    	jle    800f10 <duppage+0x100>
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
  800e67:	e9 a4 00 00 00       	jmp    800f10 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e6f:	25 02 08 00 00       	and    $0x802,%eax
  800e74:	83 f8 01             	cmp    $0x1,%eax
  800e77:	19 db                	sbb    %ebx,%ebx
  800e79:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800e7f:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800e85:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e89:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e98:	89 3c 24             	mov    %edi,(%esp)
  800e9b:	e8 59 fd ff ff       	call   800bf9 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	79 1c                	jns    800ec0 <duppage+0xb0>
  800ea4:	c7 44 24 08 8a 29 80 	movl   $0x80298a,0x8(%esp)
  800eab:	00 
  800eac:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800eb3:	00 
  800eb4:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  800ebb:	e8 a8 12 00 00       	call   802168 <_panic>
	if ((perm|~pte)&PTE_COW){
  800ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ec3:	f7 d0                	not    %eax
  800ec5:	09 d8                	or     %ebx,%eax
  800ec7:	f6 c4 08             	test   $0x8,%ah
  800eca:	74 38                	je     800f04 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800ecc:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800ed0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ed4:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ed8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800edc:	89 3c 24             	mov    %edi,(%esp)
  800edf:	e8 15 fd ff ff       	call   800bf9 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	79 23                	jns    800f0b <duppage+0xfb>
  800ee8:	c7 44 24 08 8a 29 80 	movl   $0x80298a,0x8(%esp)
  800eef:	00 
  800ef0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800ef7:	00 
  800ef8:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  800eff:	e8 64 12 00 00       	call   802168 <_panic>
	}
	return 0;
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
  800f09:	eb 05                	jmp    800f10 <duppage+0x100>
  800f0b:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  800f10:	83 c4 3c             	add    $0x3c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 20             	sub    $0x20,%esp
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f23:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800f25:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f29:	75 1c                	jne    800f47 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800f2b:	c7 44 24 08 a6 29 80 	movl   $0x8029a6,0x8(%esp)
  800f32:	00 
  800f33:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f3a:	00 
  800f3b:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  800f42:	e8 21 12 00 00       	call   802168 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	c1 e8 0c             	shr    $0xc,%eax
  800f4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f53:	f6 c4 08             	test   $0x8,%ah
  800f56:	75 1c                	jne    800f74 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800f58:	c7 44 24 08 a6 29 80 	movl   $0x8029a6,0x8(%esp)
  800f5f:	00 
  800f60:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f67:	00 
  800f68:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  800f6f:	e8 f4 11 00 00       	call   802168 <_panic>
	envid_t envid = sys_getenvid();
  800f74:	e8 ee fb ff ff       	call   800b67 <sys_getenvid>
  800f79:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800f7b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f8a:	00 
  800f8b:	89 04 24             	mov    %eax,(%esp)
  800f8e:	e8 12 fc ff ff       	call   800ba5 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800f93:	85 c0                	test   %eax,%eax
  800f95:	79 1c                	jns    800fb3 <pgfault+0x9b>
  800f97:	c7 44 24 08 a6 29 80 	movl   $0x8029a6,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  800fae:	e8 b5 11 00 00       	call   802168 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800fb3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800fb9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fc0:	00 
  800fc1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fcc:	e8 c5 f9 ff ff       	call   800996 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800fd1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fd8:	00 
  800fd9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fdd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fe1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe8:	00 
  800fe9:	89 1c 24             	mov    %ebx,(%esp)
  800fec:	e8 08 fc ff ff       	call   800bf9 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	79 1c                	jns    801011 <pgfault+0xf9>
  800ff5:	c7 44 24 08 a6 29 80 	movl   $0x8029a6,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  80100c:	e8 57 11 00 00       	call   802168 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801011:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801018:	00 
  801019:	89 1c 24             	mov    %ebx,(%esp)
  80101c:	e8 2b fc ff ff       	call   800c4c <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801021:	85 c0                	test   %eax,%eax
  801023:	79 1c                	jns    801041 <pgfault+0x129>
  801025:	c7 44 24 08 a6 29 80 	movl   $0x8029a6,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  80103c:	e8 27 11 00 00       	call   802168 <_panic>
	return;
	panic("pgfault not implemented");
}
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	53                   	push   %ebx
  80104e:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801051:	c7 04 24 18 0f 80 00 	movl   $0x800f18,(%esp)
  801058:	e8 63 11 00 00       	call   8021c0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80105d:	bf 07 00 00 00       	mov    $0x7,%edi
  801062:	89 f8                	mov    %edi,%eax
  801064:	cd 30                	int    $0x30
  801066:	89 c7                	mov    %eax,%edi
  801068:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  80106a:	85 c0                	test   %eax,%eax
  80106c:	79 1c                	jns    80108a <fork+0x42>
		panic("fork : error!\n");
  80106e:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  801085:	e8 de 10 00 00       	call   802168 <_panic>
	if (envid==0){
  80108a:	85 c0                	test   %eax,%eax
  80108c:	75 28                	jne    8010b6 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  80108e:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801094:	e8 ce fa ff ff       	call   800b67 <sys_getenvid>
  801099:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010a5:	c1 e0 07             	shl    $0x7,%eax
  8010a8:	29 d0                	sub    %edx,%eax
  8010aa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010af:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  8010b1:	e9 f2 00 00 00       	jmp    8011a8 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  8010b6:	e8 ac fa ff ff       	call   800b67 <sys_getenvid>
  8010bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010be:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  8010c3:	89 d8                	mov    %ebx,%eax
  8010c5:	c1 e8 16             	shr    $0x16,%eax
  8010c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010cf:	a8 01                	test   $0x1,%al
  8010d1:	74 17                	je     8010ea <fork+0xa2>
  8010d3:	89 da                	mov    %ebx,%edx
  8010d5:	c1 ea 0c             	shr    $0xc,%edx
  8010d8:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010df:	a8 01                	test   $0x1,%al
  8010e1:	74 07                	je     8010ea <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  8010e3:	89 f0                	mov    %esi,%eax
  8010e5:	e8 26 fd ff ff       	call   800e10 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010f6:	75 cb                	jne    8010c3 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  8010f8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ff:	00 
  801100:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801107:	ee 
  801108:	89 3c 24             	mov    %edi,(%esp)
  80110b:	e8 95 fa ff ff       	call   800ba5 <sys_page_alloc>
  801110:	85 c0                	test   %eax,%eax
  801112:	79 1c                	jns    801130 <fork+0xe8>
  801114:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  80111b:	00 
  80111c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801123:	00 
  801124:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  80112b:	e8 38 10 00 00       	call   802168 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  801130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801133:	25 ff 03 00 00       	and    $0x3ff,%eax
  801138:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80113f:	c1 e0 07             	shl    $0x7,%eax
  801142:	29 d0                	sub    %edx,%eax
  801144:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801149:	8b 40 64             	mov    0x64(%eax),%eax
  80114c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801150:	89 3c 24             	mov    %edi,(%esp)
  801153:	e8 ed fb ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
  801158:	85 c0                	test   %eax,%eax
  80115a:	79 1c                	jns    801178 <fork+0x130>
  80115c:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801163:	00 
  801164:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80116b:	00 
  80116c:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  801173:	e8 f0 0f 00 00       	call   802168 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801178:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80117f:	00 
  801180:	89 3c 24             	mov    %edi,(%esp)
  801183:	e8 17 fb ff ff       	call   800c9f <sys_env_set_status>
  801188:	85 c0                	test   %eax,%eax
  80118a:	79 1c                	jns    8011a8 <fork+0x160>
  80118c:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801193:	00 
  801194:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80119b:	00 
  80119c:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  8011a3:	e8 c0 0f 00 00       	call   802168 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  8011a8:	89 f8                	mov    %edi,%eax
  8011aa:	83 c4 2c             	add    $0x2c,%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	57                   	push   %edi
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8011bb:	c7 04 24 18 0f 80 00 	movl   $0x800f18,(%esp)
  8011c2:	e8 f9 0f 00 00       	call   8021c0 <set_pgfault_handler>
  8011c7:	ba 07 00 00 00       	mov    $0x7,%edx
  8011cc:	89 d0                	mov    %edx,%eax
  8011ce:	cd 30                	int    $0x30
  8011d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011d3:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  8011d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d9:	c7 04 24 b7 29 80 00 	movl   $0x8029b7,(%esp)
  8011e0:	e8 23 f0 ff ff       	call   800208 <cprintf>
	if (envid<0)
  8011e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011e9:	79 1c                	jns    801207 <sfork+0x55>
		panic("sfork : error!\n");
  8011eb:	c7 44 24 08 c2 29 80 	movl   $0x8029c2,0x8(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8011fa:	00 
  8011fb:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  801202:	e8 61 0f 00 00       	call   802168 <_panic>
	if (envid==0){
  801207:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80120b:	75 28                	jne    801235 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  80120d:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801213:	e8 4f f9 ff ff       	call   800b67 <sys_getenvid>
  801218:	25 ff 03 00 00       	and    $0x3ff,%eax
  80121d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801224:	c1 e0 07             	shl    $0x7,%eax
  801227:	29 d0                	sub    %edx,%eax
  801229:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80122e:	89 03                	mov    %eax,(%ebx)
		return envid;
  801230:	e9 18 01 00 00       	jmp    80134d <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801235:	e8 2d f9 ff ff       	call   800b67 <sys_getenvid>
  80123a:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80123c:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801241:	89 d8                	mov    %ebx,%eax
  801243:	c1 e8 16             	shr    $0x16,%eax
  801246:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80124d:	a8 01                	test   $0x1,%al
  80124f:	74 2c                	je     80127d <sfork+0xcb>
  801251:	89 d8                	mov    %ebx,%eax
  801253:	c1 e8 0c             	shr    $0xc,%eax
  801256:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80125d:	a8 01                	test   $0x1,%al
  80125f:	74 1c                	je     80127d <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801261:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801268:	00 
  801269:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80126d:	89 74 24 08          	mov    %esi,0x8(%esp)
  801271:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801275:	89 3c 24             	mov    %edi,(%esp)
  801278:	e8 7c f9 ff ff       	call   800bf9 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80127d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801283:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801289:	75 b6                	jne    801241 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  80128b:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801293:	e8 78 fb ff ff       	call   800e10 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801298:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80129f:	00 
  8012a0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012a7:	ee 
  8012a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ab:	89 04 24             	mov    %eax,(%esp)
  8012ae:	e8 f2 f8 ff ff       	call   800ba5 <sys_page_alloc>
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	79 1c                	jns    8012d3 <sfork+0x121>
  8012b7:	c7 44 24 08 c2 29 80 	movl   $0x8029c2,0x8(%esp)
  8012be:	00 
  8012bf:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8012c6:	00 
  8012c7:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  8012ce:	e8 95 0e 00 00       	call   802168 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  8012d3:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  8012d9:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  8012e0:	c1 e7 07             	shl    $0x7,%edi
  8012e3:	29 d7                	sub    %edx,%edi
  8012e5:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 4b fa ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	79 1c                	jns    80131a <sfork+0x168>
  8012fe:	c7 44 24 08 c2 29 80 	movl   $0x8029c2,0x8(%esp)
  801305:	00 
  801306:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  80130d:	00 
  80130e:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  801315:	e8 4e 0e 00 00       	call   802168 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80131a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801321:	00 
  801322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	e8 72 f9 ff ff       	call   800c9f <sys_env_set_status>
  80132d:	85 c0                	test   %eax,%eax
  80132f:	79 1c                	jns    80134d <sfork+0x19b>
  801331:	c7 44 24 08 c2 29 80 	movl   $0x8029c2,0x8(%esp)
  801338:	00 
  801339:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801340:	00 
  801341:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  801348:	e8 1b 0e 00 00       	call   802168 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  80134d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801350:	83 c4 3c             	add    $0x3c,%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	05 00 00 00 30       	add    $0x30000000,%eax
  801363:	c1 e8 0c             	shr    $0xc,%eax
}
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    

00801368 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	89 04 24             	mov    %eax,(%esp)
  801374:	e8 df ff ff ff       	call   801358 <fd2num>
  801379:	05 20 00 0d 00       	add    $0xd0020,%eax
  80137e:	c1 e0 0c             	shl    $0xc,%eax
}
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	53                   	push   %ebx
  801387:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80138a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80138f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801391:	89 c2                	mov    %eax,%edx
  801393:	c1 ea 16             	shr    $0x16,%edx
  801396:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80139d:	f6 c2 01             	test   $0x1,%dl
  8013a0:	74 11                	je     8013b3 <fd_alloc+0x30>
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	c1 ea 0c             	shr    $0xc,%edx
  8013a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ae:	f6 c2 01             	test   $0x1,%dl
  8013b1:	75 09                	jne    8013bc <fd_alloc+0x39>
			*fd_store = fd;
  8013b3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ba:	eb 17                	jmp    8013d3 <fd_alloc+0x50>
  8013bc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c6:	75 c7                	jne    80138f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013ce:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d3:	5b                   	pop    %ebx
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013dc:	83 f8 1f             	cmp    $0x1f,%eax
  8013df:	77 36                	ja     801417 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e1:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013e6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	c1 ea 16             	shr    $0x16,%edx
  8013ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f5:	f6 c2 01             	test   $0x1,%dl
  8013f8:	74 24                	je     80141e <fd_lookup+0x48>
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	c1 ea 0c             	shr    $0xc,%edx
  8013ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801406:	f6 c2 01             	test   $0x1,%dl
  801409:	74 1a                	je     801425 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80140b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140e:	89 02                	mov    %eax,(%edx)
	return 0;
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
  801415:	eb 13                	jmp    80142a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141c:	eb 0c                	jmp    80142a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801423:	eb 05                	jmp    80142a <fd_lookup+0x54>
  801425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 14             	sub    $0x14,%esp
  801433:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801436:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801439:	ba 00 00 00 00       	mov    $0x0,%edx
  80143e:	eb 0e                	jmp    80144e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801440:	39 08                	cmp    %ecx,(%eax)
  801442:	75 09                	jne    80144d <dev_lookup+0x21>
			*dev = devtab[i];
  801444:	89 03                	mov    %eax,(%ebx)
			return 0;
  801446:	b8 00 00 00 00       	mov    $0x0,%eax
  80144b:	eb 35                	jmp    801482 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80144d:	42                   	inc    %edx
  80144e:	8b 04 95 50 2a 80 00 	mov    0x802a50(,%edx,4),%eax
  801455:	85 c0                	test   %eax,%eax
  801457:	75 e7                	jne    801440 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801459:	a1 04 40 80 00       	mov    0x804004,%eax
  80145e:	8b 00                	mov    (%eax),%eax
  801460:	8b 40 48             	mov    0x48(%eax),%eax
  801463:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	c7 04 24 d4 29 80 00 	movl   $0x8029d4,(%esp)
  801472:	e8 91 ed ff ff       	call   800208 <cprintf>
	*dev = 0;
  801477:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801482:	83 c4 14             	add    $0x14,%esp
  801485:	5b                   	pop    %ebx
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	56                   	push   %esi
  80148c:	53                   	push   %ebx
  80148d:	83 ec 30             	sub    $0x30,%esp
  801490:	8b 75 08             	mov    0x8(%ebp),%esi
  801493:	8a 45 0c             	mov    0xc(%ebp),%al
  801496:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801499:	89 34 24             	mov    %esi,(%esp)
  80149c:	e8 b7 fe ff ff       	call   801358 <fd2num>
  8014a1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a8:	89 04 24             	mov    %eax,(%esp)
  8014ab:	e8 26 ff ff ff       	call   8013d6 <fd_lookup>
  8014b0:	89 c3                	mov    %eax,%ebx
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 05                	js     8014bb <fd_close+0x33>
	    || fd != fd2)
  8014b6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014b9:	74 0d                	je     8014c8 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014bb:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014bf:	75 46                	jne    801507 <fd_close+0x7f>
  8014c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c6:	eb 3f                	jmp    801507 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cf:	8b 06                	mov    (%esi),%eax
  8014d1:	89 04 24             	mov    %eax,(%esp)
  8014d4:	e8 53 ff ff ff       	call   80142c <dev_lookup>
  8014d9:	89 c3                	mov    %eax,%ebx
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 18                	js     8014f7 <fd_close+0x6f>
		if (dev->dev_close)
  8014df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e2:	8b 40 10             	mov    0x10(%eax),%eax
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	74 09                	je     8014f2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e9:	89 34 24             	mov    %esi,(%esp)
  8014ec:	ff d0                	call   *%eax
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	eb 05                	jmp    8014f7 <fd_close+0x6f>
		else
			r = 0;
  8014f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801502:	e8 45 f7 ff ff       	call   800c4c <sys_page_unmap>
	return r;
}
  801507:	89 d8                	mov    %ebx,%eax
  801509:	83 c4 30             	add    $0x30,%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    

00801510 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	8b 45 08             	mov    0x8(%ebp),%eax
  801520:	89 04 24             	mov    %eax,(%esp)
  801523:	e8 ae fe ff ff       	call   8013d6 <fd_lookup>
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 13                	js     80153f <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80152c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801533:	00 
  801534:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801537:	89 04 24             	mov    %eax,(%esp)
  80153a:	e8 49 ff ff ff       	call   801488 <fd_close>
}
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <close_all>:

void
close_all(void)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801548:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80154d:	89 1c 24             	mov    %ebx,(%esp)
  801550:	e8 bb ff ff ff       	call   801510 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801555:	43                   	inc    %ebx
  801556:	83 fb 20             	cmp    $0x20,%ebx
  801559:	75 f2                	jne    80154d <close_all+0xc>
		close(i);
}
  80155b:	83 c4 14             	add    $0x14,%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    

00801561 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	57                   	push   %edi
  801565:	56                   	push   %esi
  801566:	53                   	push   %ebx
  801567:	83 ec 4c             	sub    $0x4c,%esp
  80156a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80156d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801570:	89 44 24 04          	mov    %eax,0x4(%esp)
  801574:	8b 45 08             	mov    0x8(%ebp),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 57 fe ff ff       	call   8013d6 <fd_lookup>
  80157f:	89 c3                	mov    %eax,%ebx
  801581:	85 c0                	test   %eax,%eax
  801583:	0f 88 e1 00 00 00    	js     80166a <dup+0x109>
		return r;
	close(newfdnum);
  801589:	89 3c 24             	mov    %edi,(%esp)
  80158c:	e8 7f ff ff ff       	call   801510 <close>

	newfd = INDEX2FD(newfdnum);
  801591:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801597:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80159a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159d:	89 04 24             	mov    %eax,(%esp)
  8015a0:	e8 c3 fd ff ff       	call   801368 <fd2data>
  8015a5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015a7:	89 34 24             	mov    %esi,(%esp)
  8015aa:	e8 b9 fd ff ff       	call   801368 <fd2data>
  8015af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015b2:	89 d8                	mov    %ebx,%eax
  8015b4:	c1 e8 16             	shr    $0x16,%eax
  8015b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015be:	a8 01                	test   $0x1,%al
  8015c0:	74 46                	je     801608 <dup+0xa7>
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	c1 e8 0c             	shr    $0xc,%eax
  8015c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ce:	f6 c2 01             	test   $0x1,%dl
  8015d1:	74 35                	je     801608 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015da:	25 07 0e 00 00       	and    $0xe07,%eax
  8015df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f1:	00 
  8015f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fd:	e8 f7 f5 ff ff       	call   800bf9 <sys_page_map>
  801602:	89 c3                	mov    %eax,%ebx
  801604:	85 c0                	test   %eax,%eax
  801606:	78 3b                	js     801643 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801608:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	c1 ea 0c             	shr    $0xc,%edx
  801610:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801617:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80161d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801621:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801625:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80162c:	00 
  80162d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801631:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801638:	e8 bc f5 ff ff       	call   800bf9 <sys_page_map>
  80163d:	89 c3                	mov    %eax,%ebx
  80163f:	85 c0                	test   %eax,%eax
  801641:	79 25                	jns    801668 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801643:	89 74 24 04          	mov    %esi,0x4(%esp)
  801647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164e:	e8 f9 f5 ff ff       	call   800c4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801653:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801661:	e8 e6 f5 ff ff       	call   800c4c <sys_page_unmap>
	return r;
  801666:	eb 02                	jmp    80166a <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801668:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80166a:	89 d8                	mov    %ebx,%eax
  80166c:	83 c4 4c             	add    $0x4c,%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5f                   	pop    %edi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	53                   	push   %ebx
  801678:	83 ec 24             	sub    $0x24,%esp
  80167b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801681:	89 44 24 04          	mov    %eax,0x4(%esp)
  801685:	89 1c 24             	mov    %ebx,(%esp)
  801688:	e8 49 fd ff ff       	call   8013d6 <fd_lookup>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 6f                	js     801700 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801691:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801694:	89 44 24 04          	mov    %eax,0x4(%esp)
  801698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169b:	8b 00                	mov    (%eax),%eax
  80169d:	89 04 24             	mov    %eax,(%esp)
  8016a0:	e8 87 fd ff ff       	call   80142c <dev_lookup>
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 57                	js     801700 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	8b 50 08             	mov    0x8(%eax),%edx
  8016af:	83 e2 03             	and    $0x3,%edx
  8016b2:	83 fa 01             	cmp    $0x1,%edx
  8016b5:	75 25                	jne    8016dc <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bc:	8b 00                	mov    (%eax),%eax
  8016be:	8b 40 48             	mov    0x48(%eax),%eax
  8016c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c9:	c7 04 24 15 2a 80 00 	movl   $0x802a15,(%esp)
  8016d0:	e8 33 eb ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  8016d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016da:	eb 24                	jmp    801700 <read+0x8c>
	}
	if (!dev->dev_read)
  8016dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016df:	8b 52 08             	mov    0x8(%edx),%edx
  8016e2:	85 d2                	test   %edx,%edx
  8016e4:	74 15                	je     8016fb <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016f4:	89 04 24             	mov    %eax,(%esp)
  8016f7:	ff d2                	call   *%edx
  8016f9:	eb 05                	jmp    801700 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801700:	83 c4 24             	add    $0x24,%esp
  801703:	5b                   	pop    %ebx
  801704:	5d                   	pop    %ebp
  801705:	c3                   	ret    

00801706 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	57                   	push   %edi
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	83 ec 1c             	sub    $0x1c,%esp
  80170f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801712:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801715:	bb 00 00 00 00       	mov    $0x0,%ebx
  80171a:	eb 23                	jmp    80173f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80171c:	89 f0                	mov    %esi,%eax
  80171e:	29 d8                	sub    %ebx,%eax
  801720:	89 44 24 08          	mov    %eax,0x8(%esp)
  801724:	8b 45 0c             	mov    0xc(%ebp),%eax
  801727:	01 d8                	add    %ebx,%eax
  801729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172d:	89 3c 24             	mov    %edi,(%esp)
  801730:	e8 3f ff ff ff       	call   801674 <read>
		if (m < 0)
  801735:	85 c0                	test   %eax,%eax
  801737:	78 10                	js     801749 <readn+0x43>
			return m;
		if (m == 0)
  801739:	85 c0                	test   %eax,%eax
  80173b:	74 0a                	je     801747 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80173d:	01 c3                	add    %eax,%ebx
  80173f:	39 f3                	cmp    %esi,%ebx
  801741:	72 d9                	jb     80171c <readn+0x16>
  801743:	89 d8                	mov    %ebx,%eax
  801745:	eb 02                	jmp    801749 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801747:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801749:	83 c4 1c             	add    $0x1c,%esp
  80174c:	5b                   	pop    %ebx
  80174d:	5e                   	pop    %esi
  80174e:	5f                   	pop    %edi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 24             	sub    $0x24,%esp
  801758:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801762:	89 1c 24             	mov    %ebx,(%esp)
  801765:	e8 6c fc ff ff       	call   8013d6 <fd_lookup>
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 6a                	js     8017d8 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801771:	89 44 24 04          	mov    %eax,0x4(%esp)
  801775:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801778:	8b 00                	mov    (%eax),%eax
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	e8 aa fc ff ff       	call   80142c <dev_lookup>
  801782:	85 c0                	test   %eax,%eax
  801784:	78 52                	js     8017d8 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801786:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801789:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80178d:	75 25                	jne    8017b4 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80178f:	a1 04 40 80 00       	mov    0x804004,%eax
  801794:	8b 00                	mov    (%eax),%eax
  801796:	8b 40 48             	mov    0x48(%eax),%eax
  801799:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	c7 04 24 31 2a 80 00 	movl   $0x802a31,(%esp)
  8017a8:	e8 5b ea ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  8017ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b2:	eb 24                	jmp    8017d8 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ba:	85 d2                	test   %edx,%edx
  8017bc:	74 15                	je     8017d3 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017cc:	89 04 24             	mov    %eax,(%esp)
  8017cf:	ff d2                	call   *%edx
  8017d1:	eb 05                	jmp    8017d8 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017d8:	83 c4 24             	add    $0x24,%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <seek>:

int
seek(int fdnum, off_t offset)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	89 04 24             	mov    %eax,(%esp)
  8017f1:	e8 e0 fb ff ff       	call   8013d6 <fd_lookup>
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 0e                	js     801808 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801800:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801803:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801808:	c9                   	leave  
  801809:	c3                   	ret    

0080180a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 24             	sub    $0x24,%esp
  801811:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801814:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181b:	89 1c 24             	mov    %ebx,(%esp)
  80181e:	e8 b3 fb ff ff       	call   8013d6 <fd_lookup>
  801823:	85 c0                	test   %eax,%eax
  801825:	78 63                	js     80188a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801831:	8b 00                	mov    (%eax),%eax
  801833:	89 04 24             	mov    %eax,(%esp)
  801836:	e8 f1 fb ff ff       	call   80142c <dev_lookup>
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 4b                	js     80188a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80183f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801842:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801846:	75 25                	jne    80186d <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801848:	a1 04 40 80 00       	mov    0x804004,%eax
  80184d:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80184f:	8b 40 48             	mov    0x48(%eax),%eax
  801852:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801856:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185a:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  801861:	e8 a2 e9 ff ff       	call   800208 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80186b:	eb 1d                	jmp    80188a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80186d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801870:	8b 52 18             	mov    0x18(%edx),%edx
  801873:	85 d2                	test   %edx,%edx
  801875:	74 0e                	je     801885 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80187a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	ff d2                	call   *%edx
  801883:	eb 05                	jmp    80188a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801885:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80188a:	83 c4 24             	add    $0x24,%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	53                   	push   %ebx
  801894:	83 ec 24             	sub    $0x24,%esp
  801897:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	89 04 24             	mov    %eax,(%esp)
  8018a7:	e8 2a fb ff ff       	call   8013d6 <fd_lookup>
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	78 52                	js     801902 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ba:	8b 00                	mov    (%eax),%eax
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	e8 68 fb ff ff       	call   80142c <dev_lookup>
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 3a                	js     801902 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018cf:	74 2c                	je     8018fd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018db:	00 00 00 
	stat->st_isdir = 0;
  8018de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e5:	00 00 00 
	stat->st_dev = dev;
  8018e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018f5:	89 14 24             	mov    %edx,(%esp)
  8018f8:	ff 50 14             	call   *0x14(%eax)
  8018fb:	eb 05                	jmp    801902 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801902:	83 c4 24             	add    $0x24,%esp
  801905:	5b                   	pop    %ebx
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801910:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801917:	00 
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	89 04 24             	mov    %eax,(%esp)
  80191e:	e8 88 02 00 00       	call   801bab <open>
  801923:	89 c3                	mov    %eax,%ebx
  801925:	85 c0                	test   %eax,%eax
  801927:	78 1b                	js     801944 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801929:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801930:	89 1c 24             	mov    %ebx,(%esp)
  801933:	e8 58 ff ff ff       	call   801890 <fstat>
  801938:	89 c6                	mov    %eax,%esi
	close(fd);
  80193a:	89 1c 24             	mov    %ebx,(%esp)
  80193d:	e8 ce fb ff ff       	call   801510 <close>
	return r;
  801942:	89 f3                	mov    %esi,%ebx
}
  801944:	89 d8                	mov    %ebx,%eax
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	5b                   	pop    %ebx
  80194a:	5e                   	pop    %esi
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    
  80194d:	00 00                	add    %al,(%eax)
	...

00801950 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	83 ec 10             	sub    $0x10,%esp
  801958:	89 c3                	mov    %eax,%ebx
  80195a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80195c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801963:	75 11                	jne    801976 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801965:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80196c:	e8 da 09 00 00       	call   80234b <ipc_find_env>
  801971:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801976:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80197d:	00 
  80197e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801985:	00 
  801986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198a:	a1 00 40 80 00       	mov    0x804000,%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 4e 09 00 00       	call   8022e5 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801997:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80199e:	00 
  80199f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019aa:	e8 c9 08 00 00       	call   802278 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d9:	e8 72 ff ff ff       	call   801950 <fsipc>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8019fb:	e8 50 ff ff ff       	call   801950 <fsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	53                   	push   %ebx
  801a06:	83 ec 14             	sub    $0x14,%esp
  801a09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a12:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a17:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a21:	e8 2a ff ff ff       	call   801950 <fsipc>
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 2b                	js     801a55 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a2a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a31:	00 
  801a32:	89 1c 24             	mov    %ebx,(%esp)
  801a35:	e8 79 ed ff ff       	call   8007b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a3a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a45:	a1 84 50 80 00       	mov    0x805084,%eax
  801a4a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a55:	83 c4 14             	add    $0x14,%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 14             	sub    $0x14,%esp
  801a62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a65:	8b 45 08             	mov    0x8(%ebp),%eax
  801a68:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801a70:	89 d8                	mov    %ebx,%eax
  801a72:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a78:	76 05                	jbe    801a7f <devfile_write+0x24>
  801a7a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801a7f:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801a84:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801a96:	e8 fb ee ff ff       	call   800996 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa0:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa5:	e8 a6 fe ff ff       	call   801950 <fsipc>
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 53                	js     801b01 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801aae:	39 c3                	cmp    %eax,%ebx
  801ab0:	73 24                	jae    801ad6 <devfile_write+0x7b>
  801ab2:	c7 44 24 0c 60 2a 80 	movl   $0x802a60,0xc(%esp)
  801ab9:	00 
  801aba:	c7 44 24 08 67 2a 80 	movl   $0x802a67,0x8(%esp)
  801ac1:	00 
  801ac2:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801ac9:	00 
  801aca:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  801ad1:	e8 92 06 00 00       	call   802168 <_panic>
	assert(r <= PGSIZE);
  801ad6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801adb:	7e 24                	jle    801b01 <devfile_write+0xa6>
  801add:	c7 44 24 0c 87 2a 80 	movl   $0x802a87,0xc(%esp)
  801ae4:	00 
  801ae5:	c7 44 24 08 67 2a 80 	movl   $0x802a67,0x8(%esp)
  801aec:	00 
  801aed:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801af4:	00 
  801af5:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  801afc:	e8 67 06 00 00       	call   802168 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801b01:	83 c4 14             	add    $0x14,%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	83 ec 10             	sub    $0x10,%esp
  801b0f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	8b 40 0c             	mov    0xc(%eax),%eax
  801b18:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b1d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b23:	ba 00 00 00 00       	mov    $0x0,%edx
  801b28:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2d:	e8 1e fe ff ff       	call   801950 <fsipc>
  801b32:	89 c3                	mov    %eax,%ebx
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 6a                	js     801ba2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b38:	39 c6                	cmp    %eax,%esi
  801b3a:	73 24                	jae    801b60 <devfile_read+0x59>
  801b3c:	c7 44 24 0c 60 2a 80 	movl   $0x802a60,0xc(%esp)
  801b43:	00 
  801b44:	c7 44 24 08 67 2a 80 	movl   $0x802a67,0x8(%esp)
  801b4b:	00 
  801b4c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801b53:	00 
  801b54:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  801b5b:	e8 08 06 00 00       	call   802168 <_panic>
	assert(r <= PGSIZE);
  801b60:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b65:	7e 24                	jle    801b8b <devfile_read+0x84>
  801b67:	c7 44 24 0c 87 2a 80 	movl   $0x802a87,0xc(%esp)
  801b6e:	00 
  801b6f:	c7 44 24 08 67 2a 80 	movl   $0x802a67,0x8(%esp)
  801b76:	00 
  801b77:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801b7e:	00 
  801b7f:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  801b86:	e8 dd 05 00 00       	call   802168 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b96:	00 
  801b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 8a ed ff ff       	call   80092c <memmove>
	return r;
}
  801ba2:	89 d8                	mov    %ebx,%eax
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	56                   	push   %esi
  801baf:	53                   	push   %ebx
  801bb0:	83 ec 20             	sub    $0x20,%esp
  801bb3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bb6:	89 34 24             	mov    %esi,(%esp)
  801bb9:	e8 c2 eb ff ff       	call   800780 <strlen>
  801bbe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bc3:	7f 60                	jg     801c25 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc8:	89 04 24             	mov    %eax,(%esp)
  801bcb:	e8 b3 f7 ff ff       	call   801383 <fd_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	78 54                	js     801c2a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bda:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801be1:	e8 cd eb ff ff       	call   8007b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801be6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	e8 55 fd ff ff       	call   801950 <fsipc>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	79 15                	jns    801c16 <open+0x6b>
		fd_close(fd, 0);
  801c01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c08:	00 
  801c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0c:	89 04 24             	mov    %eax,(%esp)
  801c0f:	e8 74 f8 ff ff       	call   801488 <fd_close>
		return r;
  801c14:	eb 14                	jmp    801c2a <open+0x7f>
	}

	return fd2num(fd);
  801c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c19:	89 04 24             	mov    %eax,(%esp)
  801c1c:	e8 37 f7 ff ff       	call   801358 <fd2num>
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	eb 05                	jmp    801c2a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c25:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c2a:	89 d8                	mov    %ebx,%eax
  801c2c:	83 c4 20             	add    $0x20,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c39:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c43:	e8 08 fd ff ff       	call   801950 <fsipc>
}
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    
	...

00801c4c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	83 ec 10             	sub    $0x10,%esp
  801c54:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c57:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5a:	89 04 24             	mov    %eax,(%esp)
  801c5d:	e8 06 f7 ff ff       	call   801368 <fd2data>
  801c62:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c64:	c7 44 24 04 93 2a 80 	movl   $0x802a93,0x4(%esp)
  801c6b:	00 
  801c6c:	89 34 24             	mov    %esi,(%esp)
  801c6f:	e8 3f eb ff ff       	call   8007b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c74:	8b 43 04             	mov    0x4(%ebx),%eax
  801c77:	2b 03                	sub    (%ebx),%eax
  801c79:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c7f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c86:	00 00 00 
	stat->st_dev = &devpipe;
  801c89:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c90:	30 80 00 
	return 0;
}
  801c93:	b8 00 00 00 00       	mov    $0x0,%eax
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	5b                   	pop    %ebx
  801c9c:	5e                   	pop    %esi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	53                   	push   %ebx
  801ca3:	83 ec 14             	sub    $0x14,%esp
  801ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb4:	e8 93 ef ff ff       	call   800c4c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cb9:	89 1c 24             	mov    %ebx,(%esp)
  801cbc:	e8 a7 f6 ff ff       	call   801368 <fd2data>
  801cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ccc:	e8 7b ef ff ff       	call   800c4c <sys_page_unmap>
}
  801cd1:	83 c4 14             	add    $0x14,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	57                   	push   %edi
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 2c             	sub    $0x2c,%esp
  801ce0:	89 c7                	mov    %eax,%edi
  801ce2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce5:	a1 04 40 80 00       	mov    0x804004,%eax
  801cea:	8b 00                	mov    (%eax),%eax
  801cec:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cef:	89 3c 24             	mov    %edi,(%esp)
  801cf2:	e8 99 06 00 00       	call   802390 <pageref>
  801cf7:	89 c6                	mov    %eax,%esi
  801cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cfc:	89 04 24             	mov    %eax,(%esp)
  801cff:	e8 8c 06 00 00       	call   802390 <pageref>
  801d04:	39 c6                	cmp    %eax,%esi
  801d06:	0f 94 c0             	sete   %al
  801d09:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d12:	8b 12                	mov    (%edx),%edx
  801d14:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d17:	39 cb                	cmp    %ecx,%ebx
  801d19:	75 08                	jne    801d23 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d1b:	83 c4 2c             	add    $0x2c,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d23:	83 f8 01             	cmp    $0x1,%eax
  801d26:	75 bd                	jne    801ce5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d28:	8b 42 58             	mov    0x58(%edx),%eax
  801d2b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d32:	00 
  801d33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d3b:	c7 04 24 9a 2a 80 00 	movl   $0x802a9a,(%esp)
  801d42:	e8 c1 e4 ff ff       	call   800208 <cprintf>
  801d47:	eb 9c                	jmp    801ce5 <_pipeisclosed+0xe>

00801d49 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 1c             	sub    $0x1c,%esp
  801d52:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d55:	89 34 24             	mov    %esi,(%esp)
  801d58:	e8 0b f6 ff ff       	call   801368 <fd2data>
  801d5d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d64:	eb 3c                	jmp    801da2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d66:	89 da                	mov    %ebx,%edx
  801d68:	89 f0                	mov    %esi,%eax
  801d6a:	e8 68 ff ff ff       	call   801cd7 <_pipeisclosed>
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	75 38                	jne    801dab <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d73:	e8 0e ee ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d78:	8b 43 04             	mov    0x4(%ebx),%eax
  801d7b:	8b 13                	mov    (%ebx),%edx
  801d7d:	83 c2 20             	add    $0x20,%edx
  801d80:	39 d0                	cmp    %edx,%eax
  801d82:	73 e2                	jae    801d66 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d87:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d8a:	89 c2                	mov    %eax,%edx
  801d8c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d92:	79 05                	jns    801d99 <devpipe_write+0x50>
  801d94:	4a                   	dec    %edx
  801d95:	83 ca e0             	or     $0xffffffe0,%edx
  801d98:	42                   	inc    %edx
  801d99:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d9d:	40                   	inc    %eax
  801d9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da1:	47                   	inc    %edi
  801da2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801da5:	75 d1                	jne    801d78 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801da7:	89 f8                	mov    %edi,%eax
  801da9:	eb 05                	jmp    801db0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801db0:	83 c4 1c             	add    $0x1c,%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5f                   	pop    %edi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	57                   	push   %edi
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
  801dbe:	83 ec 1c             	sub    $0x1c,%esp
  801dc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dc4:	89 3c 24             	mov    %edi,(%esp)
  801dc7:	e8 9c f5 ff ff       	call   801368 <fd2data>
  801dcc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dce:	be 00 00 00 00       	mov    $0x0,%esi
  801dd3:	eb 3a                	jmp    801e0f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dd5:	85 f6                	test   %esi,%esi
  801dd7:	74 04                	je     801ddd <devpipe_read+0x25>
				return i;
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	eb 40                	jmp    801e1d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ddd:	89 da                	mov    %ebx,%edx
  801ddf:	89 f8                	mov    %edi,%eax
  801de1:	e8 f1 fe ff ff       	call   801cd7 <_pipeisclosed>
  801de6:	85 c0                	test   %eax,%eax
  801de8:	75 2e                	jne    801e18 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dea:	e8 97 ed ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801def:	8b 03                	mov    (%ebx),%eax
  801df1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801df4:	74 df                	je     801dd5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dfb:	79 05                	jns    801e02 <devpipe_read+0x4a>
  801dfd:	48                   	dec    %eax
  801dfe:	83 c8 e0             	or     $0xffffffe0,%eax
  801e01:	40                   	inc    %eax
  801e02:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e09:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e0c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0e:	46                   	inc    %esi
  801e0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e12:	75 db                	jne    801def <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e14:	89 f0                	mov    %esi,%eax
  801e16:	eb 05                	jmp    801e1d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e1d:	83 c4 1c             	add    $0x1c,%esp
  801e20:	5b                   	pop    %ebx
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	57                   	push   %edi
  801e29:	56                   	push   %esi
  801e2a:	53                   	push   %ebx
  801e2b:	83 ec 3c             	sub    $0x3c,%esp
  801e2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e34:	89 04 24             	mov    %eax,(%esp)
  801e37:	e8 47 f5 ff ff       	call   801383 <fd_alloc>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	0f 88 45 01 00 00    	js     801f8b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e4d:	00 
  801e4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5c:	e8 44 ed ff ff       	call   800ba5 <sys_page_alloc>
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	85 c0                	test   %eax,%eax
  801e65:	0f 88 20 01 00 00    	js     801f8b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e6b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 0d f5 ff ff       	call   801383 <fd_alloc>
  801e76:	89 c3                	mov    %eax,%ebx
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	0f 88 f8 00 00 00    	js     801f78 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e80:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e87:	00 
  801e88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e96:	e8 0a ed ff ff       	call   800ba5 <sys_page_alloc>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 d3 00 00 00    	js     801f78 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ea5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea8:	89 04 24             	mov    %eax,(%esp)
  801eab:	e8 b8 f4 ff ff       	call   801368 <fd2data>
  801eb0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb9:	00 
  801eba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ebe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec5:	e8 db ec ff ff       	call   800ba5 <sys_page_alloc>
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	0f 88 91 00 00 00    	js     801f65 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ed7:	89 04 24             	mov    %eax,(%esp)
  801eda:	e8 89 f4 ff ff       	call   801368 <fd2data>
  801edf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ee6:	00 
  801ee7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ef2:	00 
  801ef3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efe:	e8 f6 ec ff ff       	call   800bf9 <sys_page_map>
  801f03:	89 c3                	mov    %eax,%ebx
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 4c                	js     801f55 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f36:	89 04 24             	mov    %eax,(%esp)
  801f39:	e8 1a f4 ff ff       	call   801358 <fd2num>
  801f3e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 0d f4 ff ff       	call   801358 <fd2num>
  801f4b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f53:	eb 36                	jmp    801f8b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f55:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f60:	e8 e7 ec ff ff       	call   800c4c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f73:	e8 d4 ec ff ff       	call   800c4c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f86:	e8 c1 ec ff ff       	call   800c4c <sys_page_unmap>
    err:
	return r;
}
  801f8b:	89 d8                	mov    %ebx,%eax
  801f8d:	83 c4 3c             	add    $0x3c,%esp
  801f90:	5b                   	pop    %ebx
  801f91:	5e                   	pop    %esi
  801f92:	5f                   	pop    %edi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	89 04 24             	mov    %eax,(%esp)
  801fa8:	e8 29 f4 ff ff       	call   8013d6 <fd_lookup>
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 15                	js     801fc6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	89 04 24             	mov    %eax,(%esp)
  801fb7:	e8 ac f3 ff ff       	call   801368 <fd2data>
	return _pipeisclosed(fd, p);
  801fbc:	89 c2                	mov    %eax,%edx
  801fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc1:	e8 11 fd ff ff       	call   801cd7 <_pipeisclosed>
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fd8:	c7 44 24 04 b2 2a 80 	movl   $0x802ab2,0x4(%esp)
  801fdf:	00 
  801fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe3:	89 04 24             	mov    %eax,(%esp)
  801fe6:	e8 c8 e7 ff ff       	call   8007b3 <strcpy>
	return 0;
}
  801feb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff0:	c9                   	leave  
  801ff1:	c3                   	ret    

00801ff2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802003:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802009:	eb 30                	jmp    80203b <devcons_write+0x49>
		m = n - tot;
  80200b:	8b 75 10             	mov    0x10(%ebp),%esi
  80200e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802010:	83 fe 7f             	cmp    $0x7f,%esi
  802013:	76 05                	jbe    80201a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802015:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80201a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80201e:	03 45 0c             	add    0xc(%ebp),%eax
  802021:	89 44 24 04          	mov    %eax,0x4(%esp)
  802025:	89 3c 24             	mov    %edi,(%esp)
  802028:	e8 ff e8 ff ff       	call   80092c <memmove>
		sys_cputs(buf, m);
  80202d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802031:	89 3c 24             	mov    %edi,(%esp)
  802034:	e8 9f ea ff ff       	call   800ad8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802039:	01 f3                	add    %esi,%ebx
  80203b:	89 d8                	mov    %ebx,%eax
  80203d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802040:	72 c9                	jb     80200b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802042:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802053:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802057:	75 07                	jne    802060 <devcons_read+0x13>
  802059:	eb 25                	jmp    802080 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80205b:	e8 26 eb ff ff       	call   800b86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802060:	e8 91 ea ff ff       	call   800af6 <sys_cgetc>
  802065:	85 c0                	test   %eax,%eax
  802067:	74 f2                	je     80205b <devcons_read+0xe>
  802069:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 1d                	js     80208c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80206f:	83 f8 04             	cmp    $0x4,%eax
  802072:	74 13                	je     802087 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802074:	8b 45 0c             	mov    0xc(%ebp),%eax
  802077:	88 10                	mov    %dl,(%eax)
	return 1;
  802079:	b8 01 00 00 00       	mov    $0x1,%eax
  80207e:	eb 0c                	jmp    80208c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802080:	b8 00 00 00 00       	mov    $0x0,%eax
  802085:	eb 05                	jmp    80208c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80209a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020a1:	00 
  8020a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 2b ea ff ff       	call   800ad8 <sys_cputs>
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <getchar>:

int
getchar(void)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020bc:	00 
  8020bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020cb:	e8 a4 f5 ff ff       	call   801674 <read>
	if (r < 0)
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 0f                	js     8020e3 <getchar+0x34>
		return r;
	if (r < 1)
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	7e 06                	jle    8020de <getchar+0x2f>
		return -E_EOF;
	return c;
  8020d8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020dc:	eb 05                	jmp    8020e3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020de:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f5:	89 04 24             	mov    %eax,(%esp)
  8020f8:	e8 d9 f2 ff ff       	call   8013d6 <fd_lookup>
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	78 11                	js     802112 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802101:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802104:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210a:	39 10                	cmp    %edx,(%eax)
  80210c:	0f 94 c0             	sete   %al
  80210f:	0f b6 c0             	movzbl %al,%eax
}
  802112:	c9                   	leave  
  802113:	c3                   	ret    

00802114 <opencons>:

int
opencons(void)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80211a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211d:	89 04 24             	mov    %eax,(%esp)
  802120:	e8 5e f2 ff ff       	call   801383 <fd_alloc>
  802125:	85 c0                	test   %eax,%eax
  802127:	78 3c                	js     802165 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802129:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802130:	00 
  802131:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802134:	89 44 24 04          	mov    %eax,0x4(%esp)
  802138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213f:	e8 61 ea ff ff       	call   800ba5 <sys_page_alloc>
  802144:	85 c0                	test   %eax,%eax
  802146:	78 1d                	js     802165 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802148:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80214e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802151:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802156:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80215d:	89 04 24             	mov    %eax,(%esp)
  802160:	e8 f3 f1 ff ff       	call   801358 <fd2num>
}
  802165:	c9                   	leave  
  802166:	c3                   	ret    
	...

00802168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	56                   	push   %esi
  80216c:	53                   	push   %ebx
  80216d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802170:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802173:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802179:	e8 e9 e9 ff ff       	call   800b67 <sys_getenvid>
  80217e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802181:	89 54 24 10          	mov    %edx,0x10(%esp)
  802185:	8b 55 08             	mov    0x8(%ebp),%edx
  802188:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80218c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802190:	89 44 24 04          	mov    %eax,0x4(%esp)
  802194:	c7 04 24 c0 2a 80 00 	movl   $0x802ac0,(%esp)
  80219b:	e8 68 e0 ff ff       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a7:	89 04 24             	mov    %eax,(%esp)
  8021aa:	e8 f8 df ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  8021af:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  8021b6:	e8 4d e0 ff ff       	call   800208 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021bb:	cc                   	int3   
  8021bc:	eb fd                	jmp    8021bb <_panic+0x53>
	...

008021c0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021c7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021ce:	75 6f                	jne    80223f <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8021d0:	e8 92 e9 ff ff       	call   800b67 <sys_getenvid>
  8021d5:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8021d7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021de:	00 
  8021df:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021e6:	ee 
  8021e7:	89 04 24             	mov    %eax,(%esp)
  8021ea:	e8 b6 e9 ff ff       	call   800ba5 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	79 1c                	jns    80220f <set_pgfault_handler+0x4f>
  8021f3:	c7 44 24 08 e4 2a 80 	movl   $0x802ae4,0x8(%esp)
  8021fa:	00 
  8021fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802202:	00 
  802203:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  80220a:	e8 59 ff ff ff       	call   802168 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80220f:	c7 44 24 04 50 22 80 	movl   $0x802250,0x4(%esp)
  802216:	00 
  802217:	89 1c 24             	mov    %ebx,(%esp)
  80221a:	e8 26 eb ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80221f:	85 c0                	test   %eax,%eax
  802221:	79 1c                	jns    80223f <set_pgfault_handler+0x7f>
  802223:	c7 44 24 08 0c 2b 80 	movl   $0x802b0c,0x8(%esp)
  80222a:	00 
  80222b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  802232:	00 
  802233:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  80223a:	e8 29 ff ff ff       	call   802168 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80223f:	8b 45 08             	mov    0x8(%ebp),%eax
  802242:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802247:	83 c4 14             	add    $0x14,%esp
  80224a:	5b                   	pop    %ebx
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	00 00                	add    %al,(%eax)
	...

00802250 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802250:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802251:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802256:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802258:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80225b:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  80225f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  802264:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  802268:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80226a:	83 c4 08             	add    $0x8,%esp
	popal
  80226d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  80226e:	83 c4 04             	add    $0x4,%esp
	popfl
  802271:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  802272:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802275:	c3                   	ret    
	...

00802278 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	83 ec 10             	sub    $0x10,%esp
  802280:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802283:	8b 45 0c             	mov    0xc(%ebp),%eax
  802286:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802289:	85 c0                	test   %eax,%eax
  80228b:	75 05                	jne    802292 <ipc_recv+0x1a>
  80228d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802292:	89 04 24             	mov    %eax,(%esp)
  802295:	e8 21 eb ff ff       	call   800dbb <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80229a:	85 c0                	test   %eax,%eax
  80229c:	79 16                	jns    8022b4 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  80229e:	85 db                	test   %ebx,%ebx
  8022a0:	74 06                	je     8022a8 <ipc_recv+0x30>
  8022a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8022a8:	85 f6                	test   %esi,%esi
  8022aa:	74 32                	je     8022de <ipc_recv+0x66>
  8022ac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8022b2:	eb 2a                	jmp    8022de <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8022b4:	85 db                	test   %ebx,%ebx
  8022b6:	74 0c                	je     8022c4 <ipc_recv+0x4c>
  8022b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8022bd:	8b 00                	mov    (%eax),%eax
  8022bf:	8b 40 74             	mov    0x74(%eax),%eax
  8022c2:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8022c4:	85 f6                	test   %esi,%esi
  8022c6:	74 0c                	je     8022d4 <ipc_recv+0x5c>
  8022c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8022cd:	8b 00                	mov    (%eax),%eax
  8022cf:	8b 40 78             	mov    0x78(%eax),%eax
  8022d2:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8022d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8022d9:	8b 00                	mov    (%eax),%eax
  8022db:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	5b                   	pop    %ebx
  8022e2:	5e                   	pop    %esi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    

008022e5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	57                   	push   %edi
  8022e9:	56                   	push   %esi
  8022ea:	53                   	push   %ebx
  8022eb:	83 ec 1c             	sub    $0x1c,%esp
  8022ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022f4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8022f7:	85 db                	test   %ebx,%ebx
  8022f9:	75 05                	jne    802300 <ipc_send+0x1b>
  8022fb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  802300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802304:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
  80230f:	89 04 24             	mov    %eax,(%esp)
  802312:	e8 81 ea ff ff       	call   800d98 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  802317:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80231a:	75 07                	jne    802323 <ipc_send+0x3e>
  80231c:	e8 65 e8 ff ff       	call   800b86 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  802321:	eb dd                	jmp    802300 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  802323:	85 c0                	test   %eax,%eax
  802325:	79 1c                	jns    802343 <ipc_send+0x5e>
  802327:	c7 44 24 08 4e 2b 80 	movl   $0x802b4e,0x8(%esp)
  80232e:	00 
  80232f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802336:	00 
  802337:	c7 04 24 60 2b 80 00 	movl   $0x802b60,(%esp)
  80233e:	e8 25 fe ff ff       	call   802168 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802343:	83 c4 1c             	add    $0x1c,%esp
  802346:	5b                   	pop    %ebx
  802347:	5e                   	pop    %esi
  802348:	5f                   	pop    %edi
  802349:	5d                   	pop    %ebp
  80234a:	c3                   	ret    

0080234b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	53                   	push   %ebx
  80234f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802352:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802357:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80235e:	89 c2                	mov    %eax,%edx
  802360:	c1 e2 07             	shl    $0x7,%edx
  802363:	29 ca                	sub    %ecx,%edx
  802365:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80236b:	8b 52 50             	mov    0x50(%edx),%edx
  80236e:	39 da                	cmp    %ebx,%edx
  802370:	75 0f                	jne    802381 <ipc_find_env+0x36>
			return envs[i].env_id;
  802372:	c1 e0 07             	shl    $0x7,%eax
  802375:	29 c8                	sub    %ecx,%eax
  802377:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80237c:	8b 40 40             	mov    0x40(%eax),%eax
  80237f:	eb 0c                	jmp    80238d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802381:	40                   	inc    %eax
  802382:	3d 00 04 00 00       	cmp    $0x400,%eax
  802387:	75 ce                	jne    802357 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802389:	66 b8 00 00          	mov    $0x0,%ax
}
  80238d:	5b                   	pop    %ebx
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    

00802390 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  802396:	89 c2                	mov    %eax,%edx
  802398:	c1 ea 16             	shr    $0x16,%edx
  80239b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023a2:	f6 c2 01             	test   $0x1,%dl
  8023a5:	74 1e                	je     8023c5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023a7:	c1 e8 0c             	shr    $0xc,%eax
  8023aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023b1:	a8 01                	test   $0x1,%al
  8023b3:	74 17                	je     8023cc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023b5:	c1 e8 0c             	shr    $0xc,%eax
  8023b8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023bf:	ef 
  8023c0:	0f b7 c0             	movzwl %ax,%eax
  8023c3:	eb 0c                	jmp    8023d1 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ca:	eb 05                	jmp    8023d1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023cc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    
	...

008023d4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023d4:	55                   	push   %ebp
  8023d5:	57                   	push   %edi
  8023d6:	56                   	push   %esi
  8023d7:	83 ec 10             	sub    $0x10,%esp
  8023da:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023de:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023ea:	89 cd                	mov    %ecx,%ebp
  8023ec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	75 2c                	jne    802420 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023f4:	39 f9                	cmp    %edi,%ecx
  8023f6:	77 68                	ja     802460 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023f8:	85 c9                	test   %ecx,%ecx
  8023fa:	75 0b                	jne    802407 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023fc:	b8 01 00 00 00       	mov    $0x1,%eax
  802401:	31 d2                	xor    %edx,%edx
  802403:	f7 f1                	div    %ecx
  802405:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802407:	31 d2                	xor    %edx,%edx
  802409:	89 f8                	mov    %edi,%eax
  80240b:	f7 f1                	div    %ecx
  80240d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80240f:	89 f0                	mov    %esi,%eax
  802411:	f7 f1                	div    %ecx
  802413:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802415:	89 f0                	mov    %esi,%eax
  802417:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802419:	83 c4 10             	add    $0x10,%esp
  80241c:	5e                   	pop    %esi
  80241d:	5f                   	pop    %edi
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802420:	39 f8                	cmp    %edi,%eax
  802422:	77 2c                	ja     802450 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802424:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802427:	83 f6 1f             	xor    $0x1f,%esi
  80242a:	75 4c                	jne    802478 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80242c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80242e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802433:	72 0a                	jb     80243f <__udivdi3+0x6b>
  802435:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802439:	0f 87 ad 00 00 00    	ja     8024ec <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80243f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802444:	89 f0                	mov    %esi,%eax
  802446:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802448:	83 c4 10             	add    $0x10,%esp
  80244b:	5e                   	pop    %esi
  80244c:	5f                   	pop    %edi
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    
  80244f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802450:	31 ff                	xor    %edi,%edi
  802452:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802454:	89 f0                	mov    %esi,%eax
  802456:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    
  80245f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802460:	89 fa                	mov    %edi,%edx
  802462:	89 f0                	mov    %esi,%eax
  802464:	f7 f1                	div    %ecx
  802466:	89 c6                	mov    %eax,%esi
  802468:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80246a:	89 f0                	mov    %esi,%eax
  80246c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80246e:	83 c4 10             	add    $0x10,%esp
  802471:	5e                   	pop    %esi
  802472:	5f                   	pop    %edi
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    
  802475:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802478:	89 f1                	mov    %esi,%ecx
  80247a:	d3 e0                	shl    %cl,%eax
  80247c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802480:	b8 20 00 00 00       	mov    $0x20,%eax
  802485:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802487:	89 ea                	mov    %ebp,%edx
  802489:	88 c1                	mov    %al,%cl
  80248b:	d3 ea                	shr    %cl,%edx
  80248d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802491:	09 ca                	or     %ecx,%edx
  802493:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802497:	89 f1                	mov    %esi,%ecx
  802499:	d3 e5                	shl    %cl,%ebp
  80249b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80249f:	89 fd                	mov    %edi,%ebp
  8024a1:	88 c1                	mov    %al,%cl
  8024a3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8024a5:	89 fa                	mov    %edi,%edx
  8024a7:	89 f1                	mov    %esi,%ecx
  8024a9:	d3 e2                	shl    %cl,%edx
  8024ab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024af:	88 c1                	mov    %al,%cl
  8024b1:	d3 ef                	shr    %cl,%edi
  8024b3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024b5:	89 f8                	mov    %edi,%eax
  8024b7:	89 ea                	mov    %ebp,%edx
  8024b9:	f7 74 24 08          	divl   0x8(%esp)
  8024bd:	89 d1                	mov    %edx,%ecx
  8024bf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8024c1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024c5:	39 d1                	cmp    %edx,%ecx
  8024c7:	72 17                	jb     8024e0 <__udivdi3+0x10c>
  8024c9:	74 09                	je     8024d4 <__udivdi3+0x100>
  8024cb:	89 fe                	mov    %edi,%esi
  8024cd:	31 ff                	xor    %edi,%edi
  8024cf:	e9 41 ff ff ff       	jmp    802415 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024d4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024d8:	89 f1                	mov    %esi,%ecx
  8024da:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024dc:	39 c2                	cmp    %eax,%edx
  8024de:	73 eb                	jae    8024cb <__udivdi3+0xf7>
		{
		  q0--;
  8024e0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024e3:	31 ff                	xor    %edi,%edi
  8024e5:	e9 2b ff ff ff       	jmp    802415 <__udivdi3+0x41>
  8024ea:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024ec:	31 f6                	xor    %esi,%esi
  8024ee:	e9 22 ff ff ff       	jmp    802415 <__udivdi3+0x41>
	...

008024f4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024f4:	55                   	push   %ebp
  8024f5:	57                   	push   %edi
  8024f6:	56                   	push   %esi
  8024f7:	83 ec 20             	sub    $0x20,%esp
  8024fa:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024fe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802502:	89 44 24 14          	mov    %eax,0x14(%esp)
  802506:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80250a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80250e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802512:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802514:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802516:	85 ed                	test   %ebp,%ebp
  802518:	75 16                	jne    802530 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80251a:	39 f1                	cmp    %esi,%ecx
  80251c:	0f 86 a6 00 00 00    	jbe    8025c8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802522:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802524:	89 d0                	mov    %edx,%eax
  802526:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802528:	83 c4 20             	add    $0x20,%esp
  80252b:	5e                   	pop    %esi
  80252c:	5f                   	pop    %edi
  80252d:	5d                   	pop    %ebp
  80252e:	c3                   	ret    
  80252f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802530:	39 f5                	cmp    %esi,%ebp
  802532:	0f 87 ac 00 00 00    	ja     8025e4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802538:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80253b:	83 f0 1f             	xor    $0x1f,%eax
  80253e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802542:	0f 84 a8 00 00 00    	je     8025f0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802548:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80254c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80254e:	bf 20 00 00 00       	mov    $0x20,%edi
  802553:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802557:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80255b:	89 f9                	mov    %edi,%ecx
  80255d:	d3 e8                	shr    %cl,%eax
  80255f:	09 e8                	or     %ebp,%eax
  802561:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802565:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802569:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80256d:	d3 e0                	shl    %cl,%eax
  80256f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802573:	89 f2                	mov    %esi,%edx
  802575:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802577:	8b 44 24 14          	mov    0x14(%esp),%eax
  80257b:	d3 e0                	shl    %cl,%eax
  80257d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802581:	8b 44 24 14          	mov    0x14(%esp),%eax
  802585:	89 f9                	mov    %edi,%ecx
  802587:	d3 e8                	shr    %cl,%eax
  802589:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80258b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80258d:	89 f2                	mov    %esi,%edx
  80258f:	f7 74 24 18          	divl   0x18(%esp)
  802593:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802595:	f7 64 24 0c          	mull   0xc(%esp)
  802599:	89 c5                	mov    %eax,%ebp
  80259b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80259d:	39 d6                	cmp    %edx,%esi
  80259f:	72 67                	jb     802608 <__umoddi3+0x114>
  8025a1:	74 75                	je     802618 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025a3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025a7:	29 e8                	sub    %ebp,%eax
  8025a9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8025ab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025af:	d3 e8                	shr    %cl,%eax
  8025b1:	89 f2                	mov    %esi,%edx
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8025b7:	09 d0                	or     %edx,%eax
  8025b9:	89 f2                	mov    %esi,%edx
  8025bb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025bf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c1:	83 c4 20             	add    $0x20,%esp
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025c8:	85 c9                	test   %ecx,%ecx
  8025ca:	75 0b                	jne    8025d7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d1:	31 d2                	xor    %edx,%edx
  8025d3:	f7 f1                	div    %ecx
  8025d5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025d7:	89 f0                	mov    %esi,%eax
  8025d9:	31 d2                	xor    %edx,%edx
  8025db:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025dd:	89 f8                	mov    %edi,%eax
  8025df:	e9 3e ff ff ff       	jmp    802522 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025e4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025e6:	83 c4 20             	add    $0x20,%esp
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    
  8025ed:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025f0:	39 f5                	cmp    %esi,%ebp
  8025f2:	72 04                	jb     8025f8 <__umoddi3+0x104>
  8025f4:	39 f9                	cmp    %edi,%ecx
  8025f6:	77 06                	ja     8025fe <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025f8:	89 f2                	mov    %esi,%edx
  8025fa:	29 cf                	sub    %ecx,%edi
  8025fc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025fe:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802600:	83 c4 20             	add    $0x20,%esp
  802603:	5e                   	pop    %esi
  802604:	5f                   	pop    %edi
  802605:	5d                   	pop    %ebp
  802606:	c3                   	ret    
  802607:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802608:	89 d1                	mov    %edx,%ecx
  80260a:	89 c5                	mov    %eax,%ebp
  80260c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802610:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802614:	eb 8d                	jmp    8025a3 <__umoddi3+0xaf>
  802616:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802618:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80261c:	72 ea                	jb     802608 <__umoddi3+0x114>
  80261e:	89 f1                	mov    %esi,%ecx
  802620:	eb 81                	jmp    8025a3 <__umoddi3+0xaf>
