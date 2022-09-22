
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 f5 10 00 00       	call   801134 <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 df 13 00 00       	call   801444 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  80007b:	e8 74 02 00 00       	call   8002f4 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 30 80 00       	mov    0x803004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 df 07 00 00       	call   80086c <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 30 80 00       	mov    0x803004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 c1 08 00 00       	call   800967 <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  8000b1:	e8 3e 02 00 00       	call   8002f4 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 30 80 00       	mov    0x803000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 a9 07 00 00       	call   80086c <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 30 80 00       	mov    0x803000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 a5 09 00 00       	call   800a82 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 b1 13 00 00       	call   8014b1 <ipc_send>
		return;
  800100:	e9 d8 00 00 00       	jmp    8001dd <umain+0x1a9>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 04 40 80 00       	mov    0x804004,%eax
  80010a:	8b 00                	mov    (%eax),%eax
  80010c:	8b 40 48             	mov    0x48(%eax),%eax
  80010f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011e:	00 
  80011f:	89 04 24             	mov    %eax,(%esp)
  800122:	e8 6a 0b 00 00       	call   800c91 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800127:	a1 04 30 80 00       	mov    0x803004,%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 38 07 00 00       	call   80086c <strlen>
  800134:	40                   	inc    %eax
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	a1 04 30 80 00       	mov    0x803004,%eax
  80013e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800142:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800149:	e8 34 09 00 00       	call   800a82 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800155:	00 
  800156:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015d:	00 
  80015e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800165:	00 
  800166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 40 13 00 00       	call   8014b1 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800171:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800178:	00 
  800179:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800180:	00 
  800181:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 b8 12 00 00       	call   801444 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018c:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800193:	00 
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019b:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  8001a2:	e8 4d 01 00 00       	call   8002f4 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a7:	a1 00 30 80 00       	mov    0x803000,%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 b8 06 00 00       	call   80086c <strlen>
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	a1 00 30 80 00       	mov    0x803000,%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c8:	e8 9a 07 00 00       	call   800967 <strncmp>
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	75 0c                	jne    8001dd <umain+0x1a9>
		cprintf("parent received correct message\n");
  8001d1:	c7 04 24 54 27 80 00 	movl   $0x802754,(%esp)
  8001d8:	e8 17 01 00 00       	call   8002f4 <cprintf>
	return;
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    
	...

008001e0 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 20             	sub    $0x20,%esp
  8001e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8001ee:	e8 60 0a 00 00       	call   800c53 <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  80020c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80020f:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800214:	85 f6                	test   %esi,%esi
  800216:	7e 07                	jle    80021f <libmain+0x3f>
		binaryname = argv[0];
  800218:	8b 03                	mov    (%ebx),%eax
  80021a:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  80021f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800223:	89 34 24             	mov    %esi,(%esp)
  800226:	e8 09 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80022b:	e8 08 00 00 00       	call   800238 <exit>
}
  800230:	83 c4 20             	add    $0x20,%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    
	...

00800238 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80023e:	e8 02 15 00 00       	call   801745 <close_all>
	sys_env_destroy(0);
  800243:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80024a:	e8 b2 09 00 00       	call   800c01 <sys_env_destroy>
}
  80024f:	c9                   	leave  
  800250:	c3                   	ret    
  800251:	00 00                	add    %al,(%eax)
	...

00800254 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	53                   	push   %ebx
  800258:	83 ec 14             	sub    $0x14,%esp
  80025b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025e:	8b 03                	mov    (%ebx),%eax
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800267:	40                   	inc    %eax
  800268:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80026a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026f:	75 19                	jne    80028a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800271:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800278:	00 
  800279:	8d 43 08             	lea    0x8(%ebx),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 40 09 00 00       	call   800bc4 <sys_cputs>
		b->idx = 0;
  800284:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80028a:	ff 43 04             	incl   0x4(%ebx)
}
  80028d:	83 c4 14             	add    $0x14,%esp
  800290:	5b                   	pop    %ebx
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80029c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002a3:	00 00 00 
	b.cnt = 0;
  8002a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	c7 04 24 54 02 80 00 	movl   $0x800254,(%esp)
  8002cf:	e8 82 01 00 00       	call   800456 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	e8 d8 08 00 00       	call   800bc4 <sys_cputs>

	return b.cnt;
}
  8002ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	e8 87 ff ff ff       	call   800293 <vcprintf>
	va_end(ap);

	return cnt;
}
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    
	...

00800310 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 3c             	sub    $0x3c,%esp
  800319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031c:	89 d7                	mov    %edx,%edi
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
  800327:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80032d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800330:	85 c0                	test   %eax,%eax
  800332:	75 08                	jne    80033c <printnum+0x2c>
  800334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800337:	39 45 10             	cmp    %eax,0x10(%ebp)
  80033a:	77 57                	ja     800393 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800340:	4b                   	dec    %ebx
  800341:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800345:	8b 45 10             	mov    0x10(%ebp),%eax
  800348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800350:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800354:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035b:	00 
  80035c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	e8 52 21 00 00       	call   8024c0 <__udivdi3>
  80036e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800372:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800376:	89 04 24             	mov    %eax,(%esp)
  800379:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037d:	89 fa                	mov    %edi,%edx
  80037f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800382:	e8 89 ff ff ff       	call   800310 <printnum>
  800387:	eb 0f                	jmp    800398 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800389:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038d:	89 34 24             	mov    %esi,(%esp)
  800390:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800393:	4b                   	dec    %ebx
  800394:	85 db                	test   %ebx,%ebx
  800396:	7f f1                	jg     800389 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800398:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ae:	00 
  8003af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b2:	89 04 24             	mov    %eax,(%esp)
  8003b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bc:	e8 1f 22 00 00       	call   8025e0 <__umoddi3>
  8003c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c5:	0f be 80 cc 27 80 00 	movsbl 0x8027cc(%eax),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003d2:	83 c4 3c             	add    $0x3c,%esp
  8003d5:	5b                   	pop    %ebx
  8003d6:	5e                   	pop    %esi
  8003d7:	5f                   	pop    %edi
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003dd:	83 fa 01             	cmp    $0x1,%edx
  8003e0:	7e 0e                	jle    8003f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	8b 52 04             	mov    0x4(%edx),%edx
  8003ee:	eb 22                	jmp    800412 <getuint+0x38>
	else if (lflag)
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	74 10                	je     800404 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f9:	89 08                	mov    %ecx,(%eax)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800402:	eb 0e                	jmp    800412 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 4a 04             	lea    0x4(%edx),%ecx
  800409:	89 08                	mov    %ecx,(%eax)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800412:	5d                   	pop    %ebp
  800413:	c3                   	ret    

00800414 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80041a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80041d:	8b 10                	mov    (%eax),%edx
  80041f:	3b 50 04             	cmp    0x4(%eax),%edx
  800422:	73 08                	jae    80042c <sprintputch+0x18>
		*b->buf++ = ch;
  800424:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800427:	88 0a                	mov    %cl,(%edx)
  800429:	42                   	inc    %edx
  80042a:	89 10                	mov    %edx,(%eax)
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800437:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043b:	8b 45 10             	mov    0x10(%ebp),%eax
  80043e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800442:	8b 45 0c             	mov    0xc(%ebp),%eax
  800445:	89 44 24 04          	mov    %eax,0x4(%esp)
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	e8 02 00 00 00       	call   800456 <vprintfmt>
	va_end(ap);
}
  800454:	c9                   	leave  
  800455:	c3                   	ret    

00800456 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	57                   	push   %edi
  80045a:	56                   	push   %esi
  80045b:	53                   	push   %ebx
  80045c:	83 ec 4c             	sub    $0x4c,%esp
  80045f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800462:	8b 75 10             	mov    0x10(%ebp),%esi
  800465:	eb 12                	jmp    800479 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800467:	85 c0                	test   %eax,%eax
  800469:	0f 84 6b 03 00 00    	je     8007da <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80046f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800479:	0f b6 06             	movzbl (%esi),%eax
  80047c:	46                   	inc    %esi
  80047d:	83 f8 25             	cmp    $0x25,%eax
  800480:	75 e5                	jne    800467 <vprintfmt+0x11>
  800482:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800486:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80048d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800492:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800499:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049e:	eb 26                	jmp    8004c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004a7:	eb 1d                	jmp    8004c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ac:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004b0:	eb 14                	jmp    8004c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004bc:	eb 08                	jmp    8004c6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004be:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	0f b6 06             	movzbl (%esi),%eax
  8004c9:	8d 56 01             	lea    0x1(%esi),%edx
  8004cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004cf:	8a 16                	mov    (%esi),%dl
  8004d1:	83 ea 23             	sub    $0x23,%edx
  8004d4:	80 fa 55             	cmp    $0x55,%dl
  8004d7:	0f 87 e1 02 00 00    	ja     8007be <vprintfmt+0x368>
  8004dd:	0f b6 d2             	movzbl %dl,%edx
  8004e0:	ff 24 95 00 29 80 00 	jmp    *0x802900(,%edx,4)
  8004e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ea:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ef:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004f2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004f6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004f9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004fc:	83 fa 09             	cmp    $0x9,%edx
  8004ff:	77 2a                	ja     80052b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800501:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800502:	eb eb                	jmp    8004ef <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800512:	eb 17                	jmp    80052b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800514:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800518:	78 98                	js     8004b2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051d:	eb a7                	jmp    8004c6 <vprintfmt+0x70>
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800522:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800529:	eb 9b                	jmp    8004c6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80052b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052f:	79 95                	jns    8004c6 <vprintfmt+0x70>
  800531:	eb 8b                	jmp    8004be <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800533:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800537:	eb 8d                	jmp    8004c6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800551:	e9 23 ff ff ff       	jmp    800479 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	85 c0                	test   %eax,%eax
  800563:	79 02                	jns    800567 <vprintfmt+0x111>
  800565:	f7 d8                	neg    %eax
  800567:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800569:	83 f8 0f             	cmp    $0xf,%eax
  80056c:	7f 0b                	jg     800579 <vprintfmt+0x123>
  80056e:	8b 04 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%eax
  800575:	85 c0                	test   %eax,%eax
  800577:	75 23                	jne    80059c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800579:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057d:	c7 44 24 08 e4 27 80 	movl   $0x8027e4,0x8(%esp)
  800584:	00 
  800585:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	89 04 24             	mov    %eax,(%esp)
  80058f:	e8 9a fe ff ff       	call   80042e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800597:	e9 dd fe ff ff       	jmp    800479 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80059c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a0:	c7 44 24 08 f5 2b 80 	movl   $0x802bf5,0x8(%esp)
  8005a7:	00 
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8005af:	89 14 24             	mov    %edx,(%esp)
  8005b2:	e8 77 fe ff ff       	call   80042e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ba:	e9 ba fe ff ff       	jmp    800479 <vprintfmt+0x23>
  8005bf:	89 f9                	mov    %edi,%ecx
  8005c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 30                	mov    (%eax),%esi
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	75 05                	jne    8005db <vprintfmt+0x185>
				p = "(null)";
  8005d6:	be dd 27 80 00       	mov    $0x8027dd,%esi
			if (width > 0 && padc != '-')
  8005db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005df:	0f 8e 84 00 00 00    	jle    800669 <vprintfmt+0x213>
  8005e5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005e9:	74 7e                	je     800669 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ef:	89 34 24             	mov    %esi,(%esp)
  8005f2:	e8 8b 02 00 00       	call   800882 <strnlen>
  8005f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005fa:	29 c2                	sub    %eax,%edx
  8005fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005ff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800603:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800606:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800609:	89 de                	mov    %ebx,%esi
  80060b:	89 d3                	mov    %edx,%ebx
  80060d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	eb 0b                	jmp    80061c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800611:	89 74 24 04          	mov    %esi,0x4(%esp)
  800615:	89 3c 24             	mov    %edi,(%esp)
  800618:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061b:	4b                   	dec    %ebx
  80061c:	85 db                	test   %ebx,%ebx
  80061e:	7f f1                	jg     800611 <vprintfmt+0x1bb>
  800620:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800623:	89 f3                	mov    %esi,%ebx
  800625:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062b:	85 c0                	test   %eax,%eax
  80062d:	79 05                	jns    800634 <vprintfmt+0x1de>
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800637:	29 c2                	sub    %eax,%edx
  800639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80063c:	eb 2b                	jmp    800669 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800642:	74 18                	je     80065c <vprintfmt+0x206>
  800644:	8d 50 e0             	lea    -0x20(%eax),%edx
  800647:	83 fa 5e             	cmp    $0x5e,%edx
  80064a:	76 10                	jbe    80065c <vprintfmt+0x206>
					putch('?', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
  80065a:	eb 0a                	jmp    800666 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	ff 4d e4             	decl   -0x1c(%ebp)
  800669:	0f be 06             	movsbl (%esi),%eax
  80066c:	46                   	inc    %esi
  80066d:	85 c0                	test   %eax,%eax
  80066f:	74 21                	je     800692 <vprintfmt+0x23c>
  800671:	85 ff                	test   %edi,%edi
  800673:	78 c9                	js     80063e <vprintfmt+0x1e8>
  800675:	4f                   	dec    %edi
  800676:	79 c6                	jns    80063e <vprintfmt+0x1e8>
  800678:	8b 7d 08             	mov    0x8(%ebp),%edi
  80067b:	89 de                	mov    %ebx,%esi
  80067d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800680:	eb 18                	jmp    80069a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800682:	89 74 24 04          	mov    %esi,0x4(%esp)
  800686:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80068d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068f:	4b                   	dec    %ebx
  800690:	eb 08                	jmp    80069a <vprintfmt+0x244>
  800692:	8b 7d 08             	mov    0x8(%ebp),%edi
  800695:	89 de                	mov    %ebx,%esi
  800697:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80069a:	85 db                	test   %ebx,%ebx
  80069c:	7f e4                	jg     800682 <vprintfmt+0x22c>
  80069e:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006a1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a6:	e9 ce fd ff ff       	jmp    800479 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ab:	83 f9 01             	cmp    $0x1,%ecx
  8006ae:	7e 10                	jle    8006c0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 08             	lea    0x8(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 30                	mov    (%eax),%esi
  8006bb:	8b 78 04             	mov    0x4(%eax),%edi
  8006be:	eb 26                	jmp    8006e6 <vprintfmt+0x290>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	74 12                	je     8006d6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cd:	8b 30                	mov    (%eax),%esi
  8006cf:	89 f7                	mov    %esi,%edi
  8006d1:	c1 ff 1f             	sar    $0x1f,%edi
  8006d4:	eb 10                	jmp    8006e6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006df:	8b 30                	mov    (%eax),%esi
  8006e1:	89 f7                	mov    %esi,%edi
  8006e3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e6:	85 ff                	test   %edi,%edi
  8006e8:	78 0a                	js     8006f4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ef:	e9 8c 00 00 00       	jmp    800780 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800702:	f7 de                	neg    %esi
  800704:	83 d7 00             	adc    $0x0,%edi
  800707:	f7 df                	neg    %edi
			}
			base = 10;
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070e:	eb 70                	jmp    800780 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800710:	89 ca                	mov    %ecx,%edx
  800712:	8d 45 14             	lea    0x14(%ebp),%eax
  800715:	e8 c0 fc ff ff       	call   8003da <getuint>
  80071a:	89 c6                	mov    %eax,%esi
  80071c:	89 d7                	mov    %edx,%edi
			base = 10;
  80071e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800723:	eb 5b                	jmp    800780 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800725:	89 ca                	mov    %ecx,%edx
  800727:	8d 45 14             	lea    0x14(%ebp),%eax
  80072a:	e8 ab fc ff ff       	call   8003da <getuint>
  80072f:	89 c6                	mov    %eax,%esi
  800731:	89 d7                	mov    %edx,%edi
			base = 8;
  800733:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800738:	eb 46                	jmp    800780 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800745:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8d 50 04             	lea    0x4(%eax),%edx
  80075c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075f:	8b 30                	mov    (%eax),%esi
  800761:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800766:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80076b:	eb 13                	jmp    800780 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076d:	89 ca                	mov    %ecx,%edx
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
  800772:	e8 63 fc ff ff       	call   8003da <getuint>
  800777:	89 c6                	mov    %eax,%esi
  800779:	89 d7                	mov    %edx,%edi
			base = 16;
  80077b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800780:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800784:	89 54 24 10          	mov    %edx,0x10(%esp)
  800788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80078b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800793:	89 34 24             	mov    %esi,(%esp)
  800796:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079a:	89 da                	mov    %ebx,%edx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	e8 6c fb ff ff       	call   800310 <printnum>
			break;
  8007a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007a7:	e9 cd fc ff ff       	jmp    800479 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b0:	89 04 24             	mov    %eax,(%esp)
  8007b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b9:	e9 bb fc ff ff       	jmp    800479 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cc:	eb 01                	jmp    8007cf <vprintfmt+0x379>
  8007ce:	4e                   	dec    %esi
  8007cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d3:	75 f9                	jne    8007ce <vprintfmt+0x378>
  8007d5:	e9 9f fc ff ff       	jmp    800479 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007da:	83 c4 4c             	add    $0x4c,%esp
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5f                   	pop    %edi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 28             	sub    $0x28,%esp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 30                	je     800833 <vsnprintf+0x51>
  800803:	85 d2                	test   %edx,%edx
  800805:	7e 33                	jle    80083a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080e:	8b 45 10             	mov    0x10(%ebp),%eax
  800811:	89 44 24 08          	mov    %eax,0x8(%esp)
  800815:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	c7 04 24 14 04 80 00 	movl   $0x800414,(%esp)
  800823:	e8 2e fc ff ff       	call   800456 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	eb 0c                	jmp    80083f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800838:	eb 05                	jmp    80083f <vsnprintf+0x5d>
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084e:	8b 45 10             	mov    0x10(%ebp),%eax
  800851:	89 44 24 08          	mov    %eax,0x8(%esp)
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 7b ff ff ff       	call   8007e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    
  800869:	00 00                	add    %al,(%eax)
	...

0080086c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
  800877:	eb 01                	jmp    80087a <strlen+0xe>
		n++;
  800879:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80087a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087e:	75 f9                	jne    800879 <strlen+0xd>
		n++;
	return n;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
  800890:	eb 01                	jmp    800893 <strnlen+0x11>
		n++;
  800892:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800893:	39 d0                	cmp    %edx,%eax
  800895:	74 06                	je     80089d <strnlen+0x1b>
  800897:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80089b:	75 f5                	jne    800892 <strnlen+0x10>
		n++;
	return n;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	53                   	push   %ebx
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008b1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b4:	42                   	inc    %edx
  8008b5:	84 c9                	test   %cl,%cl
  8008b7:	75 f5                	jne    8008ae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	53                   	push   %ebx
  8008c0:	83 ec 08             	sub    $0x8,%esp
  8008c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c6:	89 1c 24             	mov    %ebx,(%esp)
  8008c9:	e8 9e ff ff ff       	call   80086c <strlen>
	strcpy(dst + len, src);
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d5:	01 d8                	add    %ebx,%eax
  8008d7:	89 04 24             	mov    %eax,(%esp)
  8008da:	e8 c0 ff ff ff       	call   80089f <strcpy>
	return dst;
}
  8008df:	89 d8                	mov    %ebx,%eax
  8008e1:	83 c4 08             	add    $0x8,%esp
  8008e4:	5b                   	pop    %ebx
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fa:	eb 0c                	jmp    800908 <strncpy+0x21>
		*dst++ = *src;
  8008fc:	8a 1a                	mov    (%edx),%bl
  8008fe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800901:	80 3a 01             	cmpb   $0x1,(%edx)
  800904:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	41                   	inc    %ecx
  800908:	39 f1                	cmp    %esi,%ecx
  80090a:	75 f0                	jne    8008fc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 75 08             	mov    0x8(%ebp),%esi
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091e:	85 d2                	test   %edx,%edx
  800920:	75 0a                	jne    80092c <strlcpy+0x1c>
  800922:	89 f0                	mov    %esi,%eax
  800924:	eb 1a                	jmp    800940 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800926:	88 18                	mov    %bl,(%eax)
  800928:	40                   	inc    %eax
  800929:	41                   	inc    %ecx
  80092a:	eb 02                	jmp    80092e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80092e:	4a                   	dec    %edx
  80092f:	74 0a                	je     80093b <strlcpy+0x2b>
  800931:	8a 19                	mov    (%ecx),%bl
  800933:	84 db                	test   %bl,%bl
  800935:	75 ef                	jne    800926 <strlcpy+0x16>
  800937:	89 c2                	mov    %eax,%edx
  800939:	eb 02                	jmp    80093d <strlcpy+0x2d>
  80093b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80093d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800940:	29 f0                	sub    %esi,%eax
}
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094f:	eb 02                	jmp    800953 <strcmp+0xd>
		p++, q++;
  800951:	41                   	inc    %ecx
  800952:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800953:	8a 01                	mov    (%ecx),%al
  800955:	84 c0                	test   %al,%al
  800957:	74 04                	je     80095d <strcmp+0x17>
  800959:	3a 02                	cmp    (%edx),%al
  80095b:	74 f4                	je     800951 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095d:	0f b6 c0             	movzbl %al,%eax
  800960:	0f b6 12             	movzbl (%edx),%edx
  800963:	29 d0                	sub    %edx,%eax
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800971:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800974:	eb 03                	jmp    800979 <strncmp+0x12>
		n--, p++, q++;
  800976:	4a                   	dec    %edx
  800977:	40                   	inc    %eax
  800978:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800979:	85 d2                	test   %edx,%edx
  80097b:	74 14                	je     800991 <strncmp+0x2a>
  80097d:	8a 18                	mov    (%eax),%bl
  80097f:	84 db                	test   %bl,%bl
  800981:	74 04                	je     800987 <strncmp+0x20>
  800983:	3a 19                	cmp    (%ecx),%bl
  800985:	74 ef                	je     800976 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800987:	0f b6 00             	movzbl (%eax),%eax
  80098a:	0f b6 11             	movzbl (%ecx),%edx
  80098d:	29 d0                	sub    %edx,%eax
  80098f:	eb 05                	jmp    800996 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800996:	5b                   	pop    %ebx
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009a2:	eb 05                	jmp    8009a9 <strchr+0x10>
		if (*s == c)
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 0c                	je     8009b4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	40                   	inc    %eax
  8009a9:	8a 10                	mov    (%eax),%dl
  8009ab:	84 d2                	test   %dl,%dl
  8009ad:	75 f5                	jne    8009a4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009bf:	eb 05                	jmp    8009c6 <strfind+0x10>
		if (*s == c)
  8009c1:	38 ca                	cmp    %cl,%dl
  8009c3:	74 07                	je     8009cc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009c5:	40                   	inc    %eax
  8009c6:	8a 10                	mov    (%eax),%dl
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	75 f5                	jne    8009c1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	57                   	push   %edi
  8009d2:	56                   	push   %esi
  8009d3:	53                   	push   %ebx
  8009d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009dd:	85 c9                	test   %ecx,%ecx
  8009df:	74 30                	je     800a11 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e7:	75 25                	jne    800a0e <memset+0x40>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 20                	jne    800a0e <memset+0x40>
		c &= 0xFF;
  8009ee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f1:	89 d3                	mov    %edx,%ebx
  8009f3:	c1 e3 08             	shl    $0x8,%ebx
  8009f6:	89 d6                	mov    %edx,%esi
  8009f8:	c1 e6 18             	shl    $0x18,%esi
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	c1 e0 10             	shl    $0x10,%eax
  800a00:	09 f0                	or     %esi,%eax
  800a02:	09 d0                	or     %edx,%eax
  800a04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a09:	fc                   	cld    
  800a0a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0c:	eb 03                	jmp    800a11 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0e:	fc                   	cld    
  800a0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a11:	89 f8                	mov    %edi,%eax
  800a13:	5b                   	pop    %ebx
  800a14:	5e                   	pop    %esi
  800a15:	5f                   	pop    %edi
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a26:	39 c6                	cmp    %eax,%esi
  800a28:	73 34                	jae    800a5e <memmove+0x46>
  800a2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2d:	39 d0                	cmp    %edx,%eax
  800a2f:	73 2d                	jae    800a5e <memmove+0x46>
		s += n;
		d += n;
  800a31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	f6 c2 03             	test   $0x3,%dl
  800a37:	75 1b                	jne    800a54 <memmove+0x3c>
  800a39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3f:	75 13                	jne    800a54 <memmove+0x3c>
  800a41:	f6 c1 03             	test   $0x3,%cl
  800a44:	75 0e                	jne    800a54 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a46:	83 ef 04             	sub    $0x4,%edi
  800a49:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4f:	fd                   	std    
  800a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a52:	eb 07                	jmp    800a5b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a54:	4f                   	dec    %edi
  800a55:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a58:	fd                   	std    
  800a59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5b:	fc                   	cld    
  800a5c:	eb 20                	jmp    800a7e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a64:	75 13                	jne    800a79 <memmove+0x61>
  800a66:	a8 03                	test   $0x3,%al
  800a68:	75 0f                	jne    800a79 <memmove+0x61>
  800a6a:	f6 c1 03             	test   $0x3,%cl
  800a6d:	75 0a                	jne    800a79 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a72:	89 c7                	mov    %eax,%edi
  800a74:	fc                   	cld    
  800a75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a77:	eb 05                	jmp    800a7e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a79:	89 c7                	mov    %eax,%edi
  800a7b:	fc                   	cld    
  800a7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a88:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	89 04 24             	mov    %eax,(%esp)
  800a9c:	e8 77 ff ff ff       	call   800a18 <memmove>
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab7:	eb 16                	jmp    800acf <memcmp+0x2c>
		if (*s1 != *s2)
  800ab9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800abc:	42                   	inc    %edx
  800abd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ac1:	38 c8                	cmp    %cl,%al
  800ac3:	74 0a                	je     800acf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ac5:	0f b6 c0             	movzbl %al,%eax
  800ac8:	0f b6 c9             	movzbl %cl,%ecx
  800acb:	29 c8                	sub    %ecx,%eax
  800acd:	eb 09                	jmp    800ad8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	39 da                	cmp    %ebx,%edx
  800ad1:	75 e6                	jne    800ab9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae6:	89 c2                	mov    %eax,%edx
  800ae8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aeb:	eb 05                	jmp    800af2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aed:	38 08                	cmp    %cl,(%eax)
  800aef:	74 05                	je     800af6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af1:	40                   	inc    %eax
  800af2:	39 d0                	cmp    %edx,%eax
  800af4:	72 f7                	jb     800aed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	eb 01                	jmp    800b07 <strtol+0xf>
		s++;
  800b06:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b07:	8a 02                	mov    (%edx),%al
  800b09:	3c 20                	cmp    $0x20,%al
  800b0b:	74 f9                	je     800b06 <strtol+0xe>
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	74 f5                	je     800b06 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b11:	3c 2b                	cmp    $0x2b,%al
  800b13:	75 08                	jne    800b1d <strtol+0x25>
		s++;
  800b15:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1b:	eb 13                	jmp    800b30 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b1d:	3c 2d                	cmp    $0x2d,%al
  800b1f:	75 0a                	jne    800b2b <strtol+0x33>
		s++, neg = 1;
  800b21:	8d 52 01             	lea    0x1(%edx),%edx
  800b24:	bf 01 00 00 00       	mov    $0x1,%edi
  800b29:	eb 05                	jmp    800b30 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	74 05                	je     800b39 <strtol+0x41>
  800b34:	83 fb 10             	cmp    $0x10,%ebx
  800b37:	75 28                	jne    800b61 <strtol+0x69>
  800b39:	8a 02                	mov    (%edx),%al
  800b3b:	3c 30                	cmp    $0x30,%al
  800b3d:	75 10                	jne    800b4f <strtol+0x57>
  800b3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b43:	75 0a                	jne    800b4f <strtol+0x57>
		s += 2, base = 16;
  800b45:	83 c2 02             	add    $0x2,%edx
  800b48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4d:	eb 12                	jmp    800b61 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b4f:	85 db                	test   %ebx,%ebx
  800b51:	75 0e                	jne    800b61 <strtol+0x69>
  800b53:	3c 30                	cmp    $0x30,%al
  800b55:	75 05                	jne    800b5c <strtol+0x64>
		s++, base = 8;
  800b57:	42                   	inc    %edx
  800b58:	b3 08                	mov    $0x8,%bl
  800b5a:	eb 05                	jmp    800b61 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b68:	8a 0a                	mov    (%edx),%cl
  800b6a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b6d:	80 fb 09             	cmp    $0x9,%bl
  800b70:	77 08                	ja     800b7a <strtol+0x82>
			dig = *s - '0';
  800b72:	0f be c9             	movsbl %cl,%ecx
  800b75:	83 e9 30             	sub    $0x30,%ecx
  800b78:	eb 1e                	jmp    800b98 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b7a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b7d:	80 fb 19             	cmp    $0x19,%bl
  800b80:	77 08                	ja     800b8a <strtol+0x92>
			dig = *s - 'a' + 10;
  800b82:	0f be c9             	movsbl %cl,%ecx
  800b85:	83 e9 57             	sub    $0x57,%ecx
  800b88:	eb 0e                	jmp    800b98 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b8a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 12                	ja     800ba4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b92:	0f be c9             	movsbl %cl,%ecx
  800b95:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b98:	39 f1                	cmp    %esi,%ecx
  800b9a:	7d 0c                	jge    800ba8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b9c:	42                   	inc    %edx
  800b9d:	0f af c6             	imul   %esi,%eax
  800ba0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ba2:	eb c4                	jmp    800b68 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ba4:	89 c1                	mov    %eax,%ecx
  800ba6:	eb 02                	jmp    800baa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800baa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bae:	74 05                	je     800bb5 <strtol+0xbd>
		*endptr = (char *) s;
  800bb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb5:	85 ff                	test   %edi,%edi
  800bb7:	74 04                	je     800bbd <strtol+0xc5>
  800bb9:	89 c8                	mov    %ecx,%eax
  800bbb:	f7 d8                	neg    %eax
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    
	...

00800bc4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	89 c3                	mov    %eax,%ebx
  800bd7:	89 c7                	mov    %eax,%edi
  800bd9:	89 c6                	mov    %eax,%esi
  800bdb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_cgetc>:

int
sys_cgetc(void)
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
  800bed:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 cb                	mov    %ecx,%ebx
  800c19:	89 cf                	mov    %ecx,%edi
  800c1b:	89 ce                	mov    %ecx,%esi
  800c1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 28                	jle    800c4b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c27:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c2e:	00 
  800c2f:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800c36:	00 
  800c37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3e:	00 
  800c3f:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800c46:	e8 21 17 00 00       	call   80236c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4b:	83 c4 2c             	add    $0x2c,%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c59:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c63:	89 d1                	mov    %edx,%ecx
  800c65:	89 d3                	mov    %edx,%ebx
  800c67:	89 d7                	mov    %edx,%edi
  800c69:	89 d6                	mov    %edx,%esi
  800c6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_yield>:

void
sys_yield(void)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c82:	89 d1                	mov    %edx,%ecx
  800c84:	89 d3                	mov    %edx,%ebx
  800c86:	89 d7                	mov    %edx,%edi
  800c88:	89 d6                	mov    %edx,%esi
  800c8a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	be 00 00 00 00       	mov    $0x0,%esi
  800c9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 f7                	mov    %esi,%edi
  800caf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7e 28                	jle    800cdd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd0:	00 
  800cd1:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800cd8:	e8 8f 16 00 00       	call   80236c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cdd:	83 c4 2c             	add    $0x2c,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 28                	jle    800d30 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d13:	00 
  800d14:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800d1b:	00 
  800d1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d23:	00 
  800d24:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800d2b:	e8 3c 16 00 00       	call   80236c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d30:	83 c4 2c             	add    $0x2c,%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7e 28                	jle    800d83 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d66:	00 
  800d67:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800d6e:	00 
  800d6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d76:	00 
  800d77:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800d7e:	e8 e9 15 00 00       	call   80236c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d83:	83 c4 2c             	add    $0x2c,%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d99:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 df                	mov    %ebx,%edi
  800da6:	89 de                	mov    %ebx,%esi
  800da8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7e 28                	jle    800dd6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800db9:	00 
  800dba:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc9:	00 
  800dca:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800dd1:	e8 96 15 00 00       	call   80236c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd6:	83 c4 2c             	add    $0x2c,%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 09 00 00 00       	mov    $0x9,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 28                	jle    800e29 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e05:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e0c:	00 
  800e0d:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800e14:	00 
  800e15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1c:	00 
  800e1d:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800e24:	e8 43 15 00 00       	call   80236c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e29:	83 c4 2c             	add    $0x2c,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e47:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4a:	89 df                	mov    %ebx,%edi
  800e4c:	89 de                	mov    %ebx,%esi
  800e4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e50:	85 c0                	test   %eax,%eax
  800e52:	7e 28                	jle    800e7c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e58:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e5f:	00 
  800e60:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800e67:	00 
  800e68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6f:	00 
  800e70:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800e77:	e8 f0 14 00 00       	call   80236c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7c:	83 c4 2c             	add    $0x2c,%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	be 00 00 00 00       	mov    $0x0,%esi
  800e8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	89 cb                	mov    %ecx,%ebx
  800ebf:	89 cf                	mov    %ecx,%edi
  800ec1:	89 ce                	mov    %ecx,%esi
  800ec3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	7e 28                	jle    800ef1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800eec:	e8 7b 14 00 00       	call   80236c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef1:	83 c4 2c             	add    $0x2c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	00 00                	add    %al,(%eax)
	...

00800efc <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 3c             	sub    $0x3c,%esp
  800f05:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800f08:	89 d6                	mov    %edx,%esi
  800f0a:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800f0d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f14:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800f17:	e8 37 fd ff ff       	call   800c53 <sys_getenvid>
  800f1c:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800f1e:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800f25:	74 31                	je     800f58 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800f27:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800f2e:	00 
  800f2f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3e:	89 3c 24             	mov    %edi,(%esp)
  800f41:	e8 9f fd ff ff       	call   800ce5 <sys_page_map>
  800f46:	85 c0                	test   %eax,%eax
  800f48:	0f 8e ae 00 00 00    	jle    800ffc <duppage+0x100>
  800f4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f53:	e9 a4 00 00 00       	jmp    800ffc <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800f58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f5b:	25 02 08 00 00       	and    $0x802,%eax
  800f60:	83 f8 01             	cmp    $0x1,%eax
  800f63:	19 db                	sbb    %ebx,%ebx
  800f65:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800f6b:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800f71:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800f75:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f79:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f84:	89 3c 24             	mov    %edi,(%esp)
  800f87:	e8 59 fd ff ff       	call   800ce5 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 1c                	jns    800fac <duppage+0xb0>
  800f90:	c7 44 24 08 ea 2a 80 	movl   $0x802aea,0x8(%esp)
  800f97:	00 
  800f98:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800f9f:	00 
  800fa0:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  800fa7:	e8 c0 13 00 00       	call   80236c <_panic>
	if ((perm|~pte)&PTE_COW){
  800fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800faf:	f7 d0                	not    %eax
  800fb1:	09 d8                	or     %ebx,%eax
  800fb3:	f6 c4 08             	test   $0x8,%ah
  800fb6:	74 38                	je     800ff0 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800fb8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800fbc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fc0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc8:	89 3c 24             	mov    %edi,(%esp)
  800fcb:	e8 15 fd ff ff       	call   800ce5 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 23                	jns    800ff7 <duppage+0xfb>
  800fd4:	c7 44 24 08 ea 2a 80 	movl   $0x802aea,0x8(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800fe3:	00 
  800fe4:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  800feb:	e8 7c 13 00 00       	call   80236c <_panic>
	}
	return 0;
  800ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff5:	eb 05                	jmp    800ffc <duppage+0x100>
  800ff7:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  800ffc:	83 c4 3c             	add    $0x3c,%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	83 ec 20             	sub    $0x20,%esp
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80100f:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  801011:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801015:	75 1c                	jne    801033 <pgfault+0x2f>
		panic("pgfault: error!\n");
  801017:	c7 44 24 08 06 2b 80 	movl   $0x802b06,0x8(%esp)
  80101e:	00 
  80101f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801026:	00 
  801027:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  80102e:	e8 39 13 00 00       	call   80236c <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  801033:	89 f0                	mov    %esi,%eax
  801035:	c1 e8 0c             	shr    $0xc,%eax
  801038:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103f:	f6 c4 08             	test   $0x8,%ah
  801042:	75 1c                	jne    801060 <pgfault+0x5c>
		panic("pgfault: error!\n");
  801044:	c7 44 24 08 06 2b 80 	movl   $0x802b06,0x8(%esp)
  80104b:	00 
  80104c:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801053:	00 
  801054:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  80105b:	e8 0c 13 00 00       	call   80236c <_panic>
	envid_t envid = sys_getenvid();
  801060:	e8 ee fb ff ff       	call   800c53 <sys_getenvid>
  801065:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  801067:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80106e:	00 
  80106f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801076:	00 
  801077:	89 04 24             	mov    %eax,(%esp)
  80107a:	e8 12 fc ff ff       	call   800c91 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 1c                	jns    80109f <pgfault+0x9b>
  801083:	c7 44 24 08 06 2b 80 	movl   $0x802b06,0x8(%esp)
  80108a:	00 
  80108b:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801092:	00 
  801093:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  80109a:	e8 cd 12 00 00       	call   80236c <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  80109f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  8010a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010ac:	00 
  8010ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010b1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010b8:	e8 c5 f9 ff ff       	call   800a82 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  8010bd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010c4:	00 
  8010c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010cd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010d4:	00 
  8010d5:	89 1c 24             	mov    %ebx,(%esp)
  8010d8:	e8 08 fc ff ff       	call   800ce5 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	79 1c                	jns    8010fd <pgfault+0xf9>
  8010e1:	c7 44 24 08 06 2b 80 	movl   $0x802b06,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  8010f8:	e8 6f 12 00 00       	call   80236c <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  8010fd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801104:	00 
  801105:	89 1c 24             	mov    %ebx,(%esp)
  801108:	e8 2b fc ff ff       	call   800d38 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  80110d:	85 c0                	test   %eax,%eax
  80110f:	79 1c                	jns    80112d <pgfault+0x129>
  801111:	c7 44 24 08 06 2b 80 	movl   $0x802b06,0x8(%esp)
  801118:	00 
  801119:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801120:	00 
  801121:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  801128:	e8 3f 12 00 00       	call   80236c <_panic>
	return;
	panic("pgfault not implemented");
}
  80112d:	83 c4 20             	add    $0x20,%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80113d:	c7 04 24 04 10 80 00 	movl   $0x801004,(%esp)
  801144:	e8 7b 12 00 00       	call   8023c4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801149:	bf 07 00 00 00       	mov    $0x7,%edi
  80114e:	89 f8                	mov    %edi,%eax
  801150:	cd 30                	int    $0x30
  801152:	89 c7                	mov    %eax,%edi
  801154:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  801156:	85 c0                	test   %eax,%eax
  801158:	79 1c                	jns    801176 <fork+0x42>
		panic("fork : error!\n");
  80115a:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  801161:	00 
  801162:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  801169:	00 
  80116a:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  801171:	e8 f6 11 00 00       	call   80236c <_panic>
	if (envid==0){
  801176:	85 c0                	test   %eax,%eax
  801178:	75 28                	jne    8011a2 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  80117a:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801180:	e8 ce fa ff ff       	call   800c53 <sys_getenvid>
  801185:	25 ff 03 00 00       	and    $0x3ff,%eax
  80118a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801191:	c1 e0 07             	shl    $0x7,%eax
  801194:	29 d0                	sub    %edx,%eax
  801196:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80119b:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  80119d:	e9 f2 00 00 00       	jmp    801294 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  8011a2:	e8 ac fa ff ff       	call   800c53 <sys_getenvid>
  8011a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8011aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  8011af:	89 d8                	mov    %ebx,%eax
  8011b1:	c1 e8 16             	shr    $0x16,%eax
  8011b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011bb:	a8 01                	test   $0x1,%al
  8011bd:	74 17                	je     8011d6 <fork+0xa2>
  8011bf:	89 da                	mov    %ebx,%edx
  8011c1:	c1 ea 0c             	shr    $0xc,%edx
  8011c4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8011cb:	a8 01                	test   $0x1,%al
  8011cd:	74 07                	je     8011d6 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  8011cf:	89 f0                	mov    %esi,%eax
  8011d1:	e8 26 fd ff ff       	call   800efc <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8011d6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011dc:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011e2:	75 cb                	jne    8011af <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  8011e4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011f3:	ee 
  8011f4:	89 3c 24             	mov    %edi,(%esp)
  8011f7:	e8 95 fa ff ff       	call   800c91 <sys_page_alloc>
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	79 1c                	jns    80121c <fork+0xe8>
  801200:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  801207:	00 
  801208:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80120f:	00 
  801210:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  801217:	e8 50 11 00 00       	call   80236c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  80121c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80121f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801224:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80122b:	c1 e0 07             	shl    $0x7,%eax
  80122e:	29 d0                	sub    %edx,%eax
  801230:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801235:	8b 40 64             	mov    0x64(%eax),%eax
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	89 3c 24             	mov    %edi,(%esp)
  80123f:	e8 ed fb ff ff       	call   800e31 <sys_env_set_pgfault_upcall>
  801244:	85 c0                	test   %eax,%eax
  801246:	79 1c                	jns    801264 <fork+0x130>
  801248:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  80124f:	00 
  801250:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801257:	00 
  801258:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  80125f:	e8 08 11 00 00       	call   80236c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801264:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80126b:	00 
  80126c:	89 3c 24             	mov    %edi,(%esp)
  80126f:	e8 17 fb ff ff       	call   800d8b <sys_env_set_status>
  801274:	85 c0                	test   %eax,%eax
  801276:	79 1c                	jns    801294 <fork+0x160>
  801278:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  80127f:	00 
  801280:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801287:	00 
  801288:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  80128f:	e8 d8 10 00 00       	call   80236c <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801294:	89 f8                	mov    %edi,%eax
  801296:	83 c4 2c             	add    $0x2c,%esp
  801299:	5b                   	pop    %ebx
  80129a:	5e                   	pop    %esi
  80129b:	5f                   	pop    %edi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <sfork>:

// Challenge!
int
sfork(void)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8012a7:	c7 04 24 04 10 80 00 	movl   $0x801004,(%esp)
  8012ae:	e8 11 11 00 00       	call   8023c4 <set_pgfault_handler>
  8012b3:	ba 07 00 00 00       	mov    $0x7,%edx
  8012b8:	89 d0                	mov    %edx,%eax
  8012ba:	cd 30                	int    $0x30
  8012bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bf:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  8012c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c5:	c7 04 24 17 2b 80 00 	movl   $0x802b17,(%esp)
  8012cc:	e8 23 f0 ff ff       	call   8002f4 <cprintf>
	if (envid<0)
  8012d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012d5:	79 1c                	jns    8012f3 <sfork+0x55>
		panic("sfork : error!\n");
  8012d7:	c7 44 24 08 22 2b 80 	movl   $0x802b22,0x8(%esp)
  8012de:	00 
  8012df:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8012e6:	00 
  8012e7:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  8012ee:	e8 79 10 00 00       	call   80236c <_panic>
	if (envid==0){
  8012f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012f7:	75 28                	jne    801321 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  8012f9:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8012ff:	e8 4f f9 ff ff       	call   800c53 <sys_getenvid>
  801304:	25 ff 03 00 00       	and    $0x3ff,%eax
  801309:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801310:	c1 e0 07             	shl    $0x7,%eax
  801313:	29 d0                	sub    %edx,%eax
  801315:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80131a:	89 03                	mov    %eax,(%ebx)
		return envid;
  80131c:	e9 18 01 00 00       	jmp    801439 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801321:	e8 2d f9 ff ff       	call   800c53 <sys_getenvid>
  801326:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801328:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  80132d:	89 d8                	mov    %ebx,%eax
  80132f:	c1 e8 16             	shr    $0x16,%eax
  801332:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801339:	a8 01                	test   $0x1,%al
  80133b:	74 2c                	je     801369 <sfork+0xcb>
  80133d:	89 d8                	mov    %ebx,%eax
  80133f:	c1 e8 0c             	shr    $0xc,%eax
  801342:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801349:	a8 01                	test   $0x1,%al
  80134b:	74 1c                	je     801369 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  80134d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801354:	00 
  801355:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801359:	89 74 24 08          	mov    %esi,0x8(%esp)
  80135d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801361:	89 3c 24             	mov    %edi,(%esp)
  801364:	e8 7c f9 ff ff       	call   800ce5 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801369:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80136f:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801375:	75 b6                	jne    80132d <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  801377:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  80137c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80137f:	e8 78 fb ff ff       	call   800efc <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801384:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80138b:	00 
  80138c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801393:	ee 
  801394:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801397:	89 04 24             	mov    %eax,(%esp)
  80139a:	e8 f2 f8 ff ff       	call   800c91 <sys_page_alloc>
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	79 1c                	jns    8013bf <sfork+0x121>
  8013a3:	c7 44 24 08 22 2b 80 	movl   $0x802b22,0x8(%esp)
  8013aa:	00 
  8013ab:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8013b2:	00 
  8013b3:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  8013ba:	e8 ad 0f 00 00       	call   80236c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  8013bf:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  8013c5:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  8013cc:	c1 e7 07             	shl    $0x7,%edi
  8013cf:	29 d7                	sub    %edx,%edi
  8013d1:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  8013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013de:	89 04 24             	mov    %eax,(%esp)
  8013e1:	e8 4b fa ff ff       	call   800e31 <sys_env_set_pgfault_upcall>
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	79 1c                	jns    801406 <sfork+0x168>
  8013ea:	c7 44 24 08 22 2b 80 	movl   $0x802b22,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  801401:	e8 66 0f 00 00       	call   80236c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801406:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80140d:	00 
  80140e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 72 f9 ff ff       	call   800d8b <sys_env_set_status>
  801419:	85 c0                	test   %eax,%eax
  80141b:	79 1c                	jns    801439 <sfork+0x19b>
  80141d:	c7 44 24 08 22 2b 80 	movl   $0x802b22,0x8(%esp)
  801424:	00 
  801425:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  80142c:	00 
  80142d:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  801434:	e8 33 0f 00 00       	call   80236c <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  801439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80143c:	83 c4 3c             	add    $0x3c,%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 10             	sub    $0x10,%esp
  80144c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80144f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801452:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801455:	85 c0                	test   %eax,%eax
  801457:	75 05                	jne    80145e <ipc_recv+0x1a>
  801459:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  80145e:	89 04 24             	mov    %eax,(%esp)
  801461:	e8 41 fa ff ff       	call   800ea7 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801466:	85 c0                	test   %eax,%eax
  801468:	79 16                	jns    801480 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  80146a:	85 db                	test   %ebx,%ebx
  80146c:	74 06                	je     801474 <ipc_recv+0x30>
  80146e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801474:	85 f6                	test   %esi,%esi
  801476:	74 32                	je     8014aa <ipc_recv+0x66>
  801478:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80147e:	eb 2a                	jmp    8014aa <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801480:	85 db                	test   %ebx,%ebx
  801482:	74 0c                	je     801490 <ipc_recv+0x4c>
  801484:	a1 04 40 80 00       	mov    0x804004,%eax
  801489:	8b 00                	mov    (%eax),%eax
  80148b:	8b 40 74             	mov    0x74(%eax),%eax
  80148e:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801490:	85 f6                	test   %esi,%esi
  801492:	74 0c                	je     8014a0 <ipc_recv+0x5c>
  801494:	a1 04 40 80 00       	mov    0x804004,%eax
  801499:	8b 00                	mov    (%eax),%eax
  80149b:	8b 40 78             	mov    0x78(%eax),%eax
  80149e:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8014a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a5:	8b 00                	mov    (%eax),%eax
  8014a7:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	57                   	push   %edi
  8014b5:	56                   	push   %esi
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 1c             	sub    $0x1c,%esp
  8014ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014c0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8014c3:	85 db                	test   %ebx,%ebx
  8014c5:	75 05                	jne    8014cc <ipc_send+0x1b>
  8014c7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8014cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 a1 f9 ff ff       	call   800e84 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8014e3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014e6:	75 07                	jne    8014ef <ipc_send+0x3e>
  8014e8:	e8 85 f7 ff ff       	call   800c72 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8014ed:	eb dd                	jmp    8014cc <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	79 1c                	jns    80150f <ipc_send+0x5e>
  8014f3:	c7 44 24 08 32 2b 80 	movl   $0x802b32,0x8(%esp)
  8014fa:	00 
  8014fb:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801502:	00 
  801503:	c7 04 24 44 2b 80 00 	movl   $0x802b44,(%esp)
  80150a:	e8 5d 0e 00 00       	call   80236c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  80150f:	83 c4 1c             	add    $0x1c,%esp
  801512:	5b                   	pop    %ebx
  801513:	5e                   	pop    %esi
  801514:	5f                   	pop    %edi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	53                   	push   %ebx
  80151b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801523:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	c1 e2 07             	shl    $0x7,%edx
  80152f:	29 ca                	sub    %ecx,%edx
  801531:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801537:	8b 52 50             	mov    0x50(%edx),%edx
  80153a:	39 da                	cmp    %ebx,%edx
  80153c:	75 0f                	jne    80154d <ipc_find_env+0x36>
			return envs[i].env_id;
  80153e:	c1 e0 07             	shl    $0x7,%eax
  801541:	29 c8                	sub    %ecx,%eax
  801543:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801548:	8b 40 40             	mov    0x40(%eax),%eax
  80154b:	eb 0c                	jmp    801559 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80154d:	40                   	inc    %eax
  80154e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801553:	75 ce                	jne    801523 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801555:	66 b8 00 00          	mov    $0x0,%ax
}
  801559:	5b                   	pop    %ebx
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80155f:	8b 45 08             	mov    0x8(%ebp),%eax
  801562:	05 00 00 00 30       	add    $0x30000000,%eax
  801567:	c1 e8 0c             	shr    $0xc,%eax
}
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801572:	8b 45 08             	mov    0x8(%ebp),%eax
  801575:	89 04 24             	mov    %eax,(%esp)
  801578:	e8 df ff ff ff       	call   80155c <fd2num>
  80157d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801582:	c1 e0 0c             	shl    $0xc,%eax
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	53                   	push   %ebx
  80158b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80158e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801593:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801595:	89 c2                	mov    %eax,%edx
  801597:	c1 ea 16             	shr    $0x16,%edx
  80159a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015a1:	f6 c2 01             	test   $0x1,%dl
  8015a4:	74 11                	je     8015b7 <fd_alloc+0x30>
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	c1 ea 0c             	shr    $0xc,%edx
  8015ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015b2:	f6 c2 01             	test   $0x1,%dl
  8015b5:	75 09                	jne    8015c0 <fd_alloc+0x39>
			*fd_store = fd;
  8015b7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8015b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015be:	eb 17                	jmp    8015d7 <fd_alloc+0x50>
  8015c0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015c5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015ca:	75 c7                	jne    801593 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8015d2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015d7:	5b                   	pop    %ebx
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015e0:	83 f8 1f             	cmp    $0x1f,%eax
  8015e3:	77 36                	ja     80161b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015e5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8015ea:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	c1 ea 16             	shr    $0x16,%edx
  8015f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015f9:	f6 c2 01             	test   $0x1,%dl
  8015fc:	74 24                	je     801622 <fd_lookup+0x48>
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	c1 ea 0c             	shr    $0xc,%edx
  801603:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80160a:	f6 c2 01             	test   $0x1,%dl
  80160d:	74 1a                	je     801629 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80160f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801612:	89 02                	mov    %eax,(%edx)
	return 0;
  801614:	b8 00 00 00 00       	mov    $0x0,%eax
  801619:	eb 13                	jmp    80162e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80161b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801620:	eb 0c                	jmp    80162e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801622:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801627:	eb 05                	jmp    80162e <fd_lookup+0x54>
  801629:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80163a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80163d:	ba 00 00 00 00       	mov    $0x0,%edx
  801642:	eb 0e                	jmp    801652 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801644:	39 08                	cmp    %ecx,(%eax)
  801646:	75 09                	jne    801651 <dev_lookup+0x21>
			*dev = devtab[i];
  801648:	89 03                	mov    %eax,(%ebx)
			return 0;
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
  80164f:	eb 35                	jmp    801686 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801651:	42                   	inc    %edx
  801652:	8b 04 95 cc 2b 80 00 	mov    0x802bcc(,%edx,4),%eax
  801659:	85 c0                	test   %eax,%eax
  80165b:	75 e7                	jne    801644 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80165d:	a1 04 40 80 00       	mov    0x804004,%eax
  801662:	8b 00                	mov    (%eax),%eax
  801664:	8b 40 48             	mov    0x48(%eax),%eax
  801667:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80166b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166f:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801676:	e8 79 ec ff ff       	call   8002f4 <cprintf>
	*dev = 0;
  80167b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801681:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801686:	83 c4 14             	add    $0x14,%esp
  801689:	5b                   	pop    %ebx
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 30             	sub    $0x30,%esp
  801694:	8b 75 08             	mov    0x8(%ebp),%esi
  801697:	8a 45 0c             	mov    0xc(%ebp),%al
  80169a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80169d:	89 34 24             	mov    %esi,(%esp)
  8016a0:	e8 b7 fe ff ff       	call   80155c <fd2num>
  8016a5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016ac:	89 04 24             	mov    %eax,(%esp)
  8016af:	e8 26 ff ff ff       	call   8015da <fd_lookup>
  8016b4:	89 c3                	mov    %eax,%ebx
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 05                	js     8016bf <fd_close+0x33>
	    || fd != fd2)
  8016ba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8016bd:	74 0d                	je     8016cc <fd_close+0x40>
		return (must_exist ? r : 0);
  8016bf:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8016c3:	75 46                	jne    80170b <fd_close+0x7f>
  8016c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ca:	eb 3f                	jmp    80170b <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d3:	8b 06                	mov    (%esi),%eax
  8016d5:	89 04 24             	mov    %eax,(%esp)
  8016d8:	e8 53 ff ff ff       	call   801630 <dev_lookup>
  8016dd:	89 c3                	mov    %eax,%ebx
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 18                	js     8016fb <fd_close+0x6f>
		if (dev->dev_close)
  8016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e6:	8b 40 10             	mov    0x10(%eax),%eax
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	74 09                	je     8016f6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016ed:	89 34 24             	mov    %esi,(%esp)
  8016f0:	ff d0                	call   *%eax
  8016f2:	89 c3                	mov    %eax,%ebx
  8016f4:	eb 05                	jmp    8016fb <fd_close+0x6f>
		else
			r = 0;
  8016f6:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801706:	e8 2d f6 ff ff       	call   800d38 <sys_page_unmap>
	return r;
}
  80170b:	89 d8                	mov    %ebx,%eax
  80170d:	83 c4 30             	add    $0x30,%esp
  801710:	5b                   	pop    %ebx
  801711:	5e                   	pop    %esi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	8b 45 08             	mov    0x8(%ebp),%eax
  801724:	89 04 24             	mov    %eax,(%esp)
  801727:	e8 ae fe ff ff       	call   8015da <fd_lookup>
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 13                	js     801743 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801730:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801737:	00 
  801738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173b:	89 04 24             	mov    %eax,(%esp)
  80173e:	e8 49 ff ff ff       	call   80168c <fd_close>
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <close_all>:

void
close_all(void)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80174c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801751:	89 1c 24             	mov    %ebx,(%esp)
  801754:	e8 bb ff ff ff       	call   801714 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801759:	43                   	inc    %ebx
  80175a:	83 fb 20             	cmp    $0x20,%ebx
  80175d:	75 f2                	jne    801751 <close_all+0xc>
		close(i);
}
  80175f:	83 c4 14             	add    $0x14,%esp
  801762:	5b                   	pop    %ebx
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	57                   	push   %edi
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	83 ec 4c             	sub    $0x4c,%esp
  80176e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801771:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801774:	89 44 24 04          	mov    %eax,0x4(%esp)
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 57 fe ff ff       	call   8015da <fd_lookup>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	85 c0                	test   %eax,%eax
  801787:	0f 88 e1 00 00 00    	js     80186e <dup+0x109>
		return r;
	close(newfdnum);
  80178d:	89 3c 24             	mov    %edi,(%esp)
  801790:	e8 7f ff ff ff       	call   801714 <close>

	newfd = INDEX2FD(newfdnum);
  801795:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80179b:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80179e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a1:	89 04 24             	mov    %eax,(%esp)
  8017a4:	e8 c3 fd ff ff       	call   80156c <fd2data>
  8017a9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017ab:	89 34 24             	mov    %esi,(%esp)
  8017ae:	e8 b9 fd ff ff       	call   80156c <fd2data>
  8017b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017b6:	89 d8                	mov    %ebx,%eax
  8017b8:	c1 e8 16             	shr    $0x16,%eax
  8017bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017c2:	a8 01                	test   $0x1,%al
  8017c4:	74 46                	je     80180c <dup+0xa7>
  8017c6:	89 d8                	mov    %ebx,%eax
  8017c8:	c1 e8 0c             	shr    $0xc,%eax
  8017cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017d2:	f6 c2 01             	test   $0x1,%dl
  8017d5:	74 35                	je     80180c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017de:	25 07 0e 00 00       	and    $0xe07,%eax
  8017e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017f5:	00 
  8017f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801801:	e8 df f4 ff ff       	call   800ce5 <sys_page_map>
  801806:	89 c3                	mov    %eax,%ebx
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 3b                	js     801847 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80180c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80180f:	89 c2                	mov    %eax,%edx
  801811:	c1 ea 0c             	shr    $0xc,%edx
  801814:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80181b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801821:	89 54 24 10          	mov    %edx,0x10(%esp)
  801825:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801829:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801830:	00 
  801831:	89 44 24 04          	mov    %eax,0x4(%esp)
  801835:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183c:	e8 a4 f4 ff ff       	call   800ce5 <sys_page_map>
  801841:	89 c3                	mov    %eax,%ebx
  801843:	85 c0                	test   %eax,%eax
  801845:	79 25                	jns    80186c <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801847:	89 74 24 04          	mov    %esi,0x4(%esp)
  80184b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801852:	e8 e1 f4 ff ff       	call   800d38 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801857:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80185a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801865:	e8 ce f4 ff ff       	call   800d38 <sys_page_unmap>
	return r;
  80186a:	eb 02                	jmp    80186e <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80186c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80186e:	89 d8                	mov    %ebx,%eax
  801870:	83 c4 4c             	add    $0x4c,%esp
  801873:	5b                   	pop    %ebx
  801874:	5e                   	pop    %esi
  801875:	5f                   	pop    %edi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 24             	sub    $0x24,%esp
  80187f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801882:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801885:	89 44 24 04          	mov    %eax,0x4(%esp)
  801889:	89 1c 24             	mov    %ebx,(%esp)
  80188c:	e8 49 fd ff ff       	call   8015da <fd_lookup>
  801891:	85 c0                	test   %eax,%eax
  801893:	78 6f                	js     801904 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801898:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189f:	8b 00                	mov    (%eax),%eax
  8018a1:	89 04 24             	mov    %eax,(%esp)
  8018a4:	e8 87 fd ff ff       	call   801630 <dev_lookup>
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	78 57                	js     801904 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b0:	8b 50 08             	mov    0x8(%eax),%edx
  8018b3:	83 e2 03             	and    $0x3,%edx
  8018b6:	83 fa 01             	cmp    $0x1,%edx
  8018b9:	75 25                	jne    8018e0 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c0:	8b 00                	mov    (%eax),%eax
  8018c2:	8b 40 48             	mov    0x48(%eax),%eax
  8018c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cd:	c7 04 24 91 2b 80 00 	movl   $0x802b91,(%esp)
  8018d4:	e8 1b ea ff ff       	call   8002f4 <cprintf>
		return -E_INVAL;
  8018d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018de:	eb 24                	jmp    801904 <read+0x8c>
	}
	if (!dev->dev_read)
  8018e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e3:	8b 52 08             	mov    0x8(%edx),%edx
  8018e6:	85 d2                	test   %edx,%edx
  8018e8:	74 15                	je     8018ff <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018f8:	89 04 24             	mov    %eax,(%esp)
  8018fb:	ff d2                	call   *%edx
  8018fd:	eb 05                	jmp    801904 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801904:	83 c4 24             	add    $0x24,%esp
  801907:	5b                   	pop    %ebx
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	57                   	push   %edi
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	83 ec 1c             	sub    $0x1c,%esp
  801913:	8b 7d 08             	mov    0x8(%ebp),%edi
  801916:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801919:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191e:	eb 23                	jmp    801943 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801920:	89 f0                	mov    %esi,%eax
  801922:	29 d8                	sub    %ebx,%eax
  801924:	89 44 24 08          	mov    %eax,0x8(%esp)
  801928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192b:	01 d8                	add    %ebx,%eax
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	89 3c 24             	mov    %edi,(%esp)
  801934:	e8 3f ff ff ff       	call   801878 <read>
		if (m < 0)
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 10                	js     80194d <readn+0x43>
			return m;
		if (m == 0)
  80193d:	85 c0                	test   %eax,%eax
  80193f:	74 0a                	je     80194b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801941:	01 c3                	add    %eax,%ebx
  801943:	39 f3                	cmp    %esi,%ebx
  801945:	72 d9                	jb     801920 <readn+0x16>
  801947:	89 d8                	mov    %ebx,%eax
  801949:	eb 02                	jmp    80194d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80194b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80194d:	83 c4 1c             	add    $0x1c,%esp
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5f                   	pop    %edi
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	53                   	push   %ebx
  801959:	83 ec 24             	sub    $0x24,%esp
  80195c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801962:	89 44 24 04          	mov    %eax,0x4(%esp)
  801966:	89 1c 24             	mov    %ebx,(%esp)
  801969:	e8 6c fc ff ff       	call   8015da <fd_lookup>
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 6a                	js     8019dc <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197c:	8b 00                	mov    (%eax),%eax
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	e8 aa fc ff ff       	call   801630 <dev_lookup>
  801986:	85 c0                	test   %eax,%eax
  801988:	78 52                	js     8019dc <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801991:	75 25                	jne    8019b8 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801993:	a1 04 40 80 00       	mov    0x804004,%eax
  801998:	8b 00                	mov    (%eax),%eax
  80199a:	8b 40 48             	mov    0x48(%eax),%eax
  80199d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a5:	c7 04 24 ad 2b 80 00 	movl   $0x802bad,(%esp)
  8019ac:	e8 43 e9 ff ff       	call   8002f4 <cprintf>
		return -E_INVAL;
  8019b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b6:	eb 24                	jmp    8019dc <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8019be:	85 d2                	test   %edx,%edx
  8019c0:	74 15                	je     8019d7 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019d0:	89 04 24             	mov    %eax,(%esp)
  8019d3:	ff d2                	call   *%edx
  8019d5:	eb 05                	jmp    8019dc <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8019d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8019dc:	83 c4 24             	add    $0x24,%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	89 04 24             	mov    %eax,(%esp)
  8019f5:	e8 e0 fb ff ff       	call   8015da <fd_lookup>
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 0e                	js     801a0c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a04:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	53                   	push   %ebx
  801a12:	83 ec 24             	sub    $0x24,%esp
  801a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1f:	89 1c 24             	mov    %ebx,(%esp)
  801a22:	e8 b3 fb ff ff       	call   8015da <fd_lookup>
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 63                	js     801a8e <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a35:	8b 00                	mov    (%eax),%eax
  801a37:	89 04 24             	mov    %eax,(%esp)
  801a3a:	e8 f1 fb ff ff       	call   801630 <dev_lookup>
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 4b                	js     801a8e <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a46:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a4a:	75 25                	jne    801a71 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a51:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a53:	8b 40 48             	mov    0x48(%eax),%eax
  801a56:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5e:	c7 04 24 70 2b 80 00 	movl   $0x802b70,(%esp)
  801a65:	e8 8a e8 ff ff       	call   8002f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a6f:	eb 1d                	jmp    801a8e <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801a71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a74:	8b 52 18             	mov    0x18(%edx),%edx
  801a77:	85 d2                	test   %edx,%edx
  801a79:	74 0e                	je     801a89 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a82:	89 04 24             	mov    %eax,(%esp)
  801a85:	ff d2                	call   *%edx
  801a87:	eb 05                	jmp    801a8e <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a89:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a8e:	83 c4 24             	add    $0x24,%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	53                   	push   %ebx
  801a98:	83 ec 24             	sub    $0x24,%esp
  801a9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	89 04 24             	mov    %eax,(%esp)
  801aab:	e8 2a fb ff ff       	call   8015da <fd_lookup>
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 52                	js     801b06 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abe:	8b 00                	mov    (%eax),%eax
  801ac0:	89 04 24             	mov    %eax,(%esp)
  801ac3:	e8 68 fb ff ff       	call   801630 <dev_lookup>
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	78 3a                	js     801b06 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ad3:	74 2c                	je     801b01 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ad5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ad8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801adf:	00 00 00 
	stat->st_isdir = 0;
  801ae2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ae9:	00 00 00 
	stat->st_dev = dev;
  801aec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801af2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801af6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801af9:	89 14 24             	mov    %edx,(%esp)
  801afc:	ff 50 14             	call   *0x14(%eax)
  801aff:	eb 05                	jmp    801b06 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b06:	83 c4 24             	add    $0x24,%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b1b:	00 
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	89 04 24             	mov    %eax,(%esp)
  801b22:	e8 88 02 00 00       	call   801daf <open>
  801b27:	89 c3                	mov    %eax,%ebx
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 1b                	js     801b48 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b34:	89 1c 24             	mov    %ebx,(%esp)
  801b37:	e8 58 ff ff ff       	call   801a94 <fstat>
  801b3c:	89 c6                	mov    %eax,%esi
	close(fd);
  801b3e:	89 1c 24             	mov    %ebx,(%esp)
  801b41:	e8 ce fb ff ff       	call   801714 <close>
	return r;
  801b46:	89 f3                	mov    %esi,%ebx
}
  801b48:	89 d8                	mov    %ebx,%eax
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    
  801b51:	00 00                	add    %al,(%eax)
	...

00801b54 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	83 ec 10             	sub    $0x10,%esp
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b60:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b67:	75 11                	jne    801b7a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b70:	e8 a2 f9 ff ff       	call   801517 <ipc_find_env>
  801b75:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b7a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b81:	00 
  801b82:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b89:	00 
  801b8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b8e:	a1 00 40 80 00       	mov    0x804000,%eax
  801b93:	89 04 24             	mov    %eax,(%esp)
  801b96:	e8 16 f9 ff ff       	call   8014b1 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801b9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ba2:	00 
  801ba3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ba7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bae:	e8 91 f8 ff ff       	call   801444 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc3:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd8:	b8 02 00 00 00       	mov    $0x2,%eax
  801bdd:	e8 72 ff ff ff       	call   801b54 <fsipc>
}
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfa:	b8 06 00 00 00       	mov    $0x6,%eax
  801bff:	e8 50 ff ff ff       	call   801b54 <fsipc>
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	53                   	push   %ebx
  801c0a:	83 ec 14             	sub    $0x14,%esp
  801c0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	8b 40 0c             	mov    0xc(%eax),%eax
  801c16:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	b8 05 00 00 00       	mov    $0x5,%eax
  801c25:	e8 2a ff ff ff       	call   801b54 <fsipc>
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 2b                	js     801c59 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c2e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c35:	00 
  801c36:	89 1c 24             	mov    %ebx,(%esp)
  801c39:	e8 61 ec ff ff       	call   80089f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c3e:	a1 80 50 80 00       	mov    0x805080,%eax
  801c43:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c49:	a1 84 50 80 00       	mov    0x805084,%eax
  801c4e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c59:	83 c4 14             	add    $0x14,%esp
  801c5c:	5b                   	pop    %ebx
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	53                   	push   %ebx
  801c63:	83 ec 14             	sub    $0x14,%esp
  801c66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c6f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801c7c:	76 05                	jbe    801c83 <devfile_write+0x24>
  801c7e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801c83:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801c88:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c93:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801c9a:	e8 e3 ed ff ff       	call   800a82 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca4:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca9:	e8 a6 fe ff ff       	call   801b54 <fsipc>
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 53                	js     801d05 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801cb2:	39 c3                	cmp    %eax,%ebx
  801cb4:	73 24                	jae    801cda <devfile_write+0x7b>
  801cb6:	c7 44 24 0c dc 2b 80 	movl   $0x802bdc,0xc(%esp)
  801cbd:	00 
  801cbe:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  801cc5:	00 
  801cc6:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801ccd:	00 
  801cce:	c7 04 24 f8 2b 80 00 	movl   $0x802bf8,(%esp)
  801cd5:	e8 92 06 00 00       	call   80236c <_panic>
	assert(r <= PGSIZE);
  801cda:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cdf:	7e 24                	jle    801d05 <devfile_write+0xa6>
  801ce1:	c7 44 24 0c 03 2c 80 	movl   $0x802c03,0xc(%esp)
  801ce8:	00 
  801ce9:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  801cf0:	00 
  801cf1:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801cf8:	00 
  801cf9:	c7 04 24 f8 2b 80 00 	movl   $0x802bf8,(%esp)
  801d00:	e8 67 06 00 00       	call   80236c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801d05:	83 c4 14             	add    $0x14,%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 10             	sub    $0x10,%esp
  801d13:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d21:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d27:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2c:	b8 03 00 00 00       	mov    $0x3,%eax
  801d31:	e8 1e fe ff ff       	call   801b54 <fsipc>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 6a                	js     801da6 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d3c:	39 c6                	cmp    %eax,%esi
  801d3e:	73 24                	jae    801d64 <devfile_read+0x59>
  801d40:	c7 44 24 0c dc 2b 80 	movl   $0x802bdc,0xc(%esp)
  801d47:	00 
  801d48:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  801d4f:	00 
  801d50:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801d57:	00 
  801d58:	c7 04 24 f8 2b 80 00 	movl   $0x802bf8,(%esp)
  801d5f:	e8 08 06 00 00       	call   80236c <_panic>
	assert(r <= PGSIZE);
  801d64:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d69:	7e 24                	jle    801d8f <devfile_read+0x84>
  801d6b:	c7 44 24 0c 03 2c 80 	movl   $0x802c03,0xc(%esp)
  801d72:	00 
  801d73:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  801d7a:	00 
  801d7b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801d82:	00 
  801d83:	c7 04 24 f8 2b 80 00 	movl   $0x802bf8,(%esp)
  801d8a:	e8 dd 05 00 00       	call   80236c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d93:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d9a:	00 
  801d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 72 ec ff ff       	call   800a18 <memmove>
	return r;
}
  801da6:	89 d8                	mov    %ebx,%eax
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5e                   	pop    %esi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 20             	sub    $0x20,%esp
  801db7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801dba:	89 34 24             	mov    %esi,(%esp)
  801dbd:	e8 aa ea ff ff       	call   80086c <strlen>
  801dc2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dc7:	7f 60                	jg     801e29 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcc:	89 04 24             	mov    %eax,(%esp)
  801dcf:	e8 b3 f7 ff ff       	call   801587 <fd_alloc>
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 54                	js     801e2e <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801dda:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dde:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801de5:	e8 b5 ea ff ff       	call   80089f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801dea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ded:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801df2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801df5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfa:	e8 55 fd ff ff       	call   801b54 <fsipc>
  801dff:	89 c3                	mov    %eax,%ebx
  801e01:	85 c0                	test   %eax,%eax
  801e03:	79 15                	jns    801e1a <open+0x6b>
		fd_close(fd, 0);
  801e05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e0c:	00 
  801e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e10:	89 04 24             	mov    %eax,(%esp)
  801e13:	e8 74 f8 ff ff       	call   80168c <fd_close>
		return r;
  801e18:	eb 14                	jmp    801e2e <open+0x7f>
	}

	return fd2num(fd);
  801e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1d:	89 04 24             	mov    %eax,(%esp)
  801e20:	e8 37 f7 ff ff       	call   80155c <fd2num>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	eb 05                	jmp    801e2e <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e29:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e2e:	89 d8                	mov    %ebx,%eax
  801e30:	83 c4 20             	add    $0x20,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5d                   	pop    %ebp
  801e36:	c3                   	ret    

00801e37 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e42:	b8 08 00 00 00       	mov    $0x8,%eax
  801e47:	e8 08 fd ff ff       	call   801b54 <fsipc>
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    
	...

00801e50 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	56                   	push   %esi
  801e54:	53                   	push   %ebx
  801e55:	83 ec 10             	sub    $0x10,%esp
  801e58:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	89 04 24             	mov    %eax,(%esp)
  801e61:	e8 06 f7 ff ff       	call   80156c <fd2data>
  801e66:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e68:	c7 44 24 04 0f 2c 80 	movl   $0x802c0f,0x4(%esp)
  801e6f:	00 
  801e70:	89 34 24             	mov    %esi,(%esp)
  801e73:	e8 27 ea ff ff       	call   80089f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e78:	8b 43 04             	mov    0x4(%ebx),%eax
  801e7b:	2b 03                	sub    (%ebx),%eax
  801e7d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e83:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e8a:	00 00 00 
	stat->st_dev = &devpipe;
  801e8d:	c7 86 88 00 00 00 28 	movl   $0x803028,0x88(%esi)
  801e94:	30 80 00 
	return 0;
}
  801e97:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    

00801ea3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	53                   	push   %ebx
  801ea7:	83 ec 14             	sub    $0x14,%esp
  801eaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ead:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb8:	e8 7b ee ff ff       	call   800d38 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ebd:	89 1c 24             	mov    %ebx,(%esp)
  801ec0:	e8 a7 f6 ff ff       	call   80156c <fd2data>
  801ec5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed0:	e8 63 ee ff ff       	call   800d38 <sys_page_unmap>
}
  801ed5:	83 c4 14             	add    $0x14,%esp
  801ed8:	5b                   	pop    %ebx
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    

00801edb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	57                   	push   %edi
  801edf:	56                   	push   %esi
  801ee0:	53                   	push   %ebx
  801ee1:	83 ec 2c             	sub    $0x2c,%esp
  801ee4:	89 c7                	mov    %eax,%edi
  801ee6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ee9:	a1 04 40 80 00       	mov    0x804004,%eax
  801eee:	8b 00                	mov    (%eax),%eax
  801ef0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ef3:	89 3c 24             	mov    %edi,(%esp)
  801ef6:	e8 81 05 00 00       	call   80247c <pageref>
  801efb:	89 c6                	mov    %eax,%esi
  801efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f00:	89 04 24             	mov    %eax,(%esp)
  801f03:	e8 74 05 00 00       	call   80247c <pageref>
  801f08:	39 c6                	cmp    %eax,%esi
  801f0a:	0f 94 c0             	sete   %al
  801f0d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f10:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f16:	8b 12                	mov    (%edx),%edx
  801f18:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f1b:	39 cb                	cmp    %ecx,%ebx
  801f1d:	75 08                	jne    801f27 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f1f:	83 c4 2c             	add    $0x2c,%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f27:	83 f8 01             	cmp    $0x1,%eax
  801f2a:	75 bd                	jne    801ee9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f2c:	8b 42 58             	mov    0x58(%edx),%eax
  801f2f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801f36:	00 
  801f37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f3f:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801f46:	e8 a9 e3 ff ff       	call   8002f4 <cprintf>
  801f4b:	eb 9c                	jmp    801ee9 <_pipeisclosed+0xe>

00801f4d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	57                   	push   %edi
  801f51:	56                   	push   %esi
  801f52:	53                   	push   %ebx
  801f53:	83 ec 1c             	sub    $0x1c,%esp
  801f56:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f59:	89 34 24             	mov    %esi,(%esp)
  801f5c:	e8 0b f6 ff ff       	call   80156c <fd2data>
  801f61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f63:	bf 00 00 00 00       	mov    $0x0,%edi
  801f68:	eb 3c                	jmp    801fa6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f6a:	89 da                	mov    %ebx,%edx
  801f6c:	89 f0                	mov    %esi,%eax
  801f6e:	e8 68 ff ff ff       	call   801edb <_pipeisclosed>
  801f73:	85 c0                	test   %eax,%eax
  801f75:	75 38                	jne    801faf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f77:	e8 f6 ec ff ff       	call   800c72 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f7f:	8b 13                	mov    (%ebx),%edx
  801f81:	83 c2 20             	add    $0x20,%edx
  801f84:	39 d0                	cmp    %edx,%eax
  801f86:	73 e2                	jae    801f6a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f8e:	89 c2                	mov    %eax,%edx
  801f90:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f96:	79 05                	jns    801f9d <devpipe_write+0x50>
  801f98:	4a                   	dec    %edx
  801f99:	83 ca e0             	or     $0xffffffe0,%edx
  801f9c:	42                   	inc    %edx
  801f9d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa1:	40                   	inc    %eax
  801fa2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa5:	47                   	inc    %edi
  801fa6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fa9:	75 d1                	jne    801f7c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fab:	89 f8                	mov    %edi,%eax
  801fad:	eb 05                	jmp    801fb4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fb4:	83 c4 1c             	add    $0x1c,%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5f                   	pop    %edi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	57                   	push   %edi
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 1c             	sub    $0x1c,%esp
  801fc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fc8:	89 3c 24             	mov    %edi,(%esp)
  801fcb:	e8 9c f5 ff ff       	call   80156c <fd2data>
  801fd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd2:	be 00 00 00 00       	mov    $0x0,%esi
  801fd7:	eb 3a                	jmp    802013 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fd9:	85 f6                	test   %esi,%esi
  801fdb:	74 04                	je     801fe1 <devpipe_read+0x25>
				return i;
  801fdd:	89 f0                	mov    %esi,%eax
  801fdf:	eb 40                	jmp    802021 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe1:	89 da                	mov    %ebx,%edx
  801fe3:	89 f8                	mov    %edi,%eax
  801fe5:	e8 f1 fe ff ff       	call   801edb <_pipeisclosed>
  801fea:	85 c0                	test   %eax,%eax
  801fec:	75 2e                	jne    80201c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fee:	e8 7f ec ff ff       	call   800c72 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ff3:	8b 03                	mov    (%ebx),%eax
  801ff5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ff8:	74 df                	je     801fd9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ffa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fff:	79 05                	jns    802006 <devpipe_read+0x4a>
  802001:	48                   	dec    %eax
  802002:	83 c8 e0             	or     $0xffffffe0,%eax
  802005:	40                   	inc    %eax
  802006:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80200a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802010:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802012:	46                   	inc    %esi
  802013:	3b 75 10             	cmp    0x10(%ebp),%esi
  802016:	75 db                	jne    801ff3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802018:	89 f0                	mov    %esi,%eax
  80201a:	eb 05                	jmp    802021 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802021:	83 c4 1c             	add    $0x1c,%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	57                   	push   %edi
  80202d:	56                   	push   %esi
  80202e:	53                   	push   %ebx
  80202f:	83 ec 3c             	sub    $0x3c,%esp
  802032:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802035:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802038:	89 04 24             	mov    %eax,(%esp)
  80203b:	e8 47 f5 ff ff       	call   801587 <fd_alloc>
  802040:	89 c3                	mov    %eax,%ebx
  802042:	85 c0                	test   %eax,%eax
  802044:	0f 88 45 01 00 00    	js     80218f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802051:	00 
  802052:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802055:	89 44 24 04          	mov    %eax,0x4(%esp)
  802059:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802060:	e8 2c ec ff ff       	call   800c91 <sys_page_alloc>
  802065:	89 c3                	mov    %eax,%ebx
  802067:	85 c0                	test   %eax,%eax
  802069:	0f 88 20 01 00 00    	js     80218f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80206f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802072:	89 04 24             	mov    %eax,(%esp)
  802075:	e8 0d f5 ff ff       	call   801587 <fd_alloc>
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	85 c0                	test   %eax,%eax
  80207e:	0f 88 f8 00 00 00    	js     80217c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802084:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80208b:	00 
  80208c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80208f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802093:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209a:	e8 f2 eb ff ff       	call   800c91 <sys_page_alloc>
  80209f:	89 c3                	mov    %eax,%ebx
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	0f 88 d3 00 00 00    	js     80217c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ac:	89 04 24             	mov    %eax,(%esp)
  8020af:	e8 b8 f4 ff ff       	call   80156c <fd2data>
  8020b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020bd:	00 
  8020be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c9:	e8 c3 eb ff ff       	call   800c91 <sys_page_alloc>
  8020ce:	89 c3                	mov    %eax,%ebx
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	0f 88 91 00 00 00    	js     802169 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	e8 89 f4 ff ff       	call   80156c <fd2data>
  8020e3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8020ea:	00 
  8020eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020f6:	00 
  8020f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802102:	e8 de eb ff ff       	call   800ce5 <sys_page_map>
  802107:	89 c3                	mov    %eax,%ebx
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 4c                	js     802159 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80210d:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802116:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80211b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802122:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802128:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80212b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80212d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802130:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80213a:	89 04 24             	mov    %eax,(%esp)
  80213d:	e8 1a f4 ff ff       	call   80155c <fd2num>
  802142:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802144:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802147:	89 04 24             	mov    %eax,(%esp)
  80214a:	e8 0d f4 ff ff       	call   80155c <fd2num>
  80214f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802152:	bb 00 00 00 00       	mov    $0x0,%ebx
  802157:	eb 36                	jmp    80218f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802159:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802164:	e8 cf eb ff ff       	call   800d38 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802169:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80216c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 bc eb ff ff       	call   800d38 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80217c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80217f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218a:	e8 a9 eb ff ff       	call   800d38 <sys_page_unmap>
    err:
	return r;
}
  80218f:	89 d8                	mov    %ebx,%eax
  802191:	83 c4 3c             	add    $0x3c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	89 04 24             	mov    %eax,(%esp)
  8021ac:	e8 29 f4 ff ff       	call   8015da <fd_lookup>
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	78 15                	js     8021ca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b8:	89 04 24             	mov    %eax,(%esp)
  8021bb:	e8 ac f3 ff ff       	call   80156c <fd2data>
	return _pipeisclosed(fd, p);
  8021c0:	89 c2                	mov    %eax,%edx
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	e8 11 fd ff ff       	call   801edb <_pipeisclosed>
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021dc:	c7 44 24 04 2e 2c 80 	movl   $0x802c2e,0x4(%esp)
  8021e3:	00 
  8021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e7:	89 04 24             	mov    %eax,(%esp)
  8021ea:	e8 b0 e6 ff ff       	call   80089f <strcpy>
	return 0;
}
  8021ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f4:	c9                   	leave  
  8021f5:	c3                   	ret    

008021f6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	57                   	push   %edi
  8021fa:	56                   	push   %esi
  8021fb:	53                   	push   %ebx
  8021fc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802202:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802207:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80220d:	eb 30                	jmp    80223f <devcons_write+0x49>
		m = n - tot;
  80220f:	8b 75 10             	mov    0x10(%ebp),%esi
  802212:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802214:	83 fe 7f             	cmp    $0x7f,%esi
  802217:	76 05                	jbe    80221e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802219:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80221e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802222:	03 45 0c             	add    0xc(%ebp),%eax
  802225:	89 44 24 04          	mov    %eax,0x4(%esp)
  802229:	89 3c 24             	mov    %edi,(%esp)
  80222c:	e8 e7 e7 ff ff       	call   800a18 <memmove>
		sys_cputs(buf, m);
  802231:	89 74 24 04          	mov    %esi,0x4(%esp)
  802235:	89 3c 24             	mov    %edi,(%esp)
  802238:	e8 87 e9 ff ff       	call   800bc4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80223d:	01 f3                	add    %esi,%ebx
  80223f:	89 d8                	mov    %ebx,%eax
  802241:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802244:	72 c9                	jb     80220f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802246:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80224c:	5b                   	pop    %ebx
  80224d:	5e                   	pop    %esi
  80224e:	5f                   	pop    %edi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    

00802251 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802257:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80225b:	75 07                	jne    802264 <devcons_read+0x13>
  80225d:	eb 25                	jmp    802284 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80225f:	e8 0e ea ff ff       	call   800c72 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802264:	e8 79 e9 ff ff       	call   800be2 <sys_cgetc>
  802269:	85 c0                	test   %eax,%eax
  80226b:	74 f2                	je     80225f <devcons_read+0xe>
  80226d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 1d                	js     802290 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802273:	83 f8 04             	cmp    $0x4,%eax
  802276:	74 13                	je     80228b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227b:	88 10                	mov    %dl,(%eax)
	return 1;
  80227d:	b8 01 00 00 00       	mov    $0x1,%eax
  802282:	eb 0c                	jmp    802290 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802284:	b8 00 00 00 00       	mov    $0x0,%eax
  802289:	eb 05                	jmp    802290 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80228b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80229e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8022a5:	00 
  8022a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a9:	89 04 24             	mov    %eax,(%esp)
  8022ac:	e8 13 e9 ff ff       	call   800bc4 <sys_cputs>
}
  8022b1:	c9                   	leave  
  8022b2:	c3                   	ret    

008022b3 <getchar>:

int
getchar(void)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022c0:	00 
  8022c1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022cf:	e8 a4 f5 ff ff       	call   801878 <read>
	if (r < 0)
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 0f                	js     8022e7 <getchar+0x34>
		return r;
	if (r < 1)
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	7e 06                	jle    8022e2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8022dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e0:	eb 05                	jmp    8022e7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f9:	89 04 24             	mov    %eax,(%esp)
  8022fc:	e8 d9 f2 ff ff       	call   8015da <fd_lookup>
  802301:	85 c0                	test   %eax,%eax
  802303:	78 11                	js     802316 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802305:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802308:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80230e:	39 10                	cmp    %edx,(%eax)
  802310:	0f 94 c0             	sete   %al
  802313:	0f b6 c0             	movzbl %al,%eax
}
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <opencons>:

int
opencons(void)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802321:	89 04 24             	mov    %eax,(%esp)
  802324:	e8 5e f2 ff ff       	call   801587 <fd_alloc>
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 3c                	js     802369 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80232d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802334:	00 
  802335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802343:	e8 49 e9 ff ff       	call   800c91 <sys_page_alloc>
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 1d                	js     802369 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80234c:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802361:	89 04 24             	mov    %eax,(%esp)
  802364:	e8 f3 f1 ff ff       	call   80155c <fd2num>
}
  802369:	c9                   	leave  
  80236a:	c3                   	ret    
	...

0080236c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	56                   	push   %esi
  802370:	53                   	push   %ebx
  802371:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802374:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802377:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  80237d:	e8 d1 e8 ff ff       	call   800c53 <sys_getenvid>
  802382:	8b 55 0c             	mov    0xc(%ebp),%edx
  802385:	89 54 24 10          	mov    %edx,0x10(%esp)
  802389:	8b 55 08             	mov    0x8(%ebp),%edx
  80238c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802390:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802394:	89 44 24 04          	mov    %eax,0x4(%esp)
  802398:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  80239f:	e8 50 df ff ff       	call   8002f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8023a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8023ab:	89 04 24             	mov    %eax,(%esp)
  8023ae:	e8 e0 de ff ff       	call   800293 <vcprintf>
	cprintf("\n");
  8023b3:	c7 04 24 30 2b 80 00 	movl   $0x802b30,(%esp)
  8023ba:	e8 35 df ff ff       	call   8002f4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023bf:	cc                   	int3   
  8023c0:	eb fd                	jmp    8023bf <_panic+0x53>
	...

008023c4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	53                   	push   %ebx
  8023c8:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023cb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8023d2:	75 6f                	jne    802443 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8023d4:	e8 7a e8 ff ff       	call   800c53 <sys_getenvid>
  8023d9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8023db:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023e2:	00 
  8023e3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023ea:	ee 
  8023eb:	89 04 24             	mov    %eax,(%esp)
  8023ee:	e8 9e e8 ff ff       	call   800c91 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	79 1c                	jns    802413 <set_pgfault_handler+0x4f>
  8023f7:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  8023fe:	00 
  8023ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802406:	00 
  802407:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  80240e:	e8 59 ff ff ff       	call   80236c <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  802413:	c7 44 24 04 54 24 80 	movl   $0x802454,0x4(%esp)
  80241a:	00 
  80241b:	89 1c 24             	mov    %ebx,(%esp)
  80241e:	e8 0e ea ff ff       	call   800e31 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  802423:	85 c0                	test   %eax,%eax
  802425:	79 1c                	jns    802443 <set_pgfault_handler+0x7f>
  802427:	c7 44 24 08 88 2c 80 	movl   $0x802c88,0x8(%esp)
  80242e:	00 
  80242f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  802436:	00 
  802437:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  80243e:	e8 29 ff ff ff       	call   80236c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802443:	8b 45 08             	mov    0x8(%ebp),%eax
  802446:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80244b:	83 c4 14             	add    $0x14,%esp
  80244e:	5b                   	pop    %ebx
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    
  802451:	00 00                	add    %al,(%eax)
	...

00802454 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802454:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802455:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80245a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80245c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80245f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  802463:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  802468:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  80246c:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80246e:	83 c4 08             	add    $0x8,%esp
	popal
  802471:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  802472:	83 c4 04             	add    $0x4,%esp
	popfl
  802475:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  802476:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802479:	c3                   	ret    
	...

0080247c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  802482:	89 c2                	mov    %eax,%edx
  802484:	c1 ea 16             	shr    $0x16,%edx
  802487:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80248e:	f6 c2 01             	test   $0x1,%dl
  802491:	74 1e                	je     8024b1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802493:	c1 e8 0c             	shr    $0xc,%eax
  802496:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80249d:	a8 01                	test   $0x1,%al
  80249f:	74 17                	je     8024b8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024a1:	c1 e8 0c             	shr    $0xc,%eax
  8024a4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024ab:	ef 
  8024ac:	0f b7 c0             	movzwl %ax,%eax
  8024af:	eb 0c                	jmp    8024bd <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b6:	eb 05                	jmp    8024bd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024b8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024bd:	5d                   	pop    %ebp
  8024be:	c3                   	ret    
	...

008024c0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	83 ec 10             	sub    $0x10,%esp
  8024c6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8024ca:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8024d6:	89 cd                	mov    %ecx,%ebp
  8024d8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	75 2c                	jne    80250c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8024e0:	39 f9                	cmp    %edi,%ecx
  8024e2:	77 68                	ja     80254c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024e4:	85 c9                	test   %ecx,%ecx
  8024e6:	75 0b                	jne    8024f3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ed:	31 d2                	xor    %edx,%edx
  8024ef:	f7 f1                	div    %ecx
  8024f1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	89 f8                	mov    %edi,%eax
  8024f7:	f7 f1                	div    %ecx
  8024f9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024fb:	89 f0                	mov    %esi,%eax
  8024fd:	f7 f1                	div    %ecx
  8024ff:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802501:	89 f0                	mov    %esi,%eax
  802503:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802505:	83 c4 10             	add    $0x10,%esp
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80250c:	39 f8                	cmp    %edi,%eax
  80250e:	77 2c                	ja     80253c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802510:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802513:	83 f6 1f             	xor    $0x1f,%esi
  802516:	75 4c                	jne    802564 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802518:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80251a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80251f:	72 0a                	jb     80252b <__udivdi3+0x6b>
  802521:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802525:	0f 87 ad 00 00 00    	ja     8025d8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80252b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802530:	89 f0                	mov    %esi,%eax
  802532:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802534:	83 c4 10             	add    $0x10,%esp
  802537:	5e                   	pop    %esi
  802538:	5f                   	pop    %edi
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    
  80253b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80253c:	31 ff                	xor    %edi,%edi
  80253e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802540:	89 f0                	mov    %esi,%eax
  802542:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802544:	83 c4 10             	add    $0x10,%esp
  802547:	5e                   	pop    %esi
  802548:	5f                   	pop    %edi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    
  80254b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80254c:	89 fa                	mov    %edi,%edx
  80254e:	89 f0                	mov    %esi,%eax
  802550:	f7 f1                	div    %ecx
  802552:	89 c6                	mov    %eax,%esi
  802554:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802556:	89 f0                	mov    %esi,%eax
  802558:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80255a:	83 c4 10             	add    $0x10,%esp
  80255d:	5e                   	pop    %esi
  80255e:	5f                   	pop    %edi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    
  802561:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802564:	89 f1                	mov    %esi,%ecx
  802566:	d3 e0                	shl    %cl,%eax
  802568:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80256c:	b8 20 00 00 00       	mov    $0x20,%eax
  802571:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802573:	89 ea                	mov    %ebp,%edx
  802575:	88 c1                	mov    %al,%cl
  802577:	d3 ea                	shr    %cl,%edx
  802579:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80257d:	09 ca                	or     %ecx,%edx
  80257f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802583:	89 f1                	mov    %esi,%ecx
  802585:	d3 e5                	shl    %cl,%ebp
  802587:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80258b:	89 fd                	mov    %edi,%ebp
  80258d:	88 c1                	mov    %al,%cl
  80258f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802591:	89 fa                	mov    %edi,%edx
  802593:	89 f1                	mov    %esi,%ecx
  802595:	d3 e2                	shl    %cl,%edx
  802597:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80259b:	88 c1                	mov    %al,%cl
  80259d:	d3 ef                	shr    %cl,%edi
  80259f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025a1:	89 f8                	mov    %edi,%eax
  8025a3:	89 ea                	mov    %ebp,%edx
  8025a5:	f7 74 24 08          	divl   0x8(%esp)
  8025a9:	89 d1                	mov    %edx,%ecx
  8025ab:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8025ad:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025b1:	39 d1                	cmp    %edx,%ecx
  8025b3:	72 17                	jb     8025cc <__udivdi3+0x10c>
  8025b5:	74 09                	je     8025c0 <__udivdi3+0x100>
  8025b7:	89 fe                	mov    %edi,%esi
  8025b9:	31 ff                	xor    %edi,%edi
  8025bb:	e9 41 ff ff ff       	jmp    802501 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8025c0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025c4:	89 f1                	mov    %esi,%ecx
  8025c6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025c8:	39 c2                	cmp    %eax,%edx
  8025ca:	73 eb                	jae    8025b7 <__udivdi3+0xf7>
		{
		  q0--;
  8025cc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025cf:	31 ff                	xor    %edi,%edi
  8025d1:	e9 2b ff ff ff       	jmp    802501 <__udivdi3+0x41>
  8025d6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025d8:	31 f6                	xor    %esi,%esi
  8025da:	e9 22 ff ff ff       	jmp    802501 <__udivdi3+0x41>
	...

008025e0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	83 ec 20             	sub    $0x20,%esp
  8025e6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025ea:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025ee:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025f2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8025f6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025fa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8025fe:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802600:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802602:	85 ed                	test   %ebp,%ebp
  802604:	75 16                	jne    80261c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802606:	39 f1                	cmp    %esi,%ecx
  802608:	0f 86 a6 00 00 00    	jbe    8026b4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80260e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802610:	89 d0                	mov    %edx,%eax
  802612:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802614:	83 c4 20             	add    $0x20,%esp
  802617:	5e                   	pop    %esi
  802618:	5f                   	pop    %edi
  802619:	5d                   	pop    %ebp
  80261a:	c3                   	ret    
  80261b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80261c:	39 f5                	cmp    %esi,%ebp
  80261e:	0f 87 ac 00 00 00    	ja     8026d0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802624:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802627:	83 f0 1f             	xor    $0x1f,%eax
  80262a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80262e:	0f 84 a8 00 00 00    	je     8026dc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802634:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802638:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80263a:	bf 20 00 00 00       	mov    $0x20,%edi
  80263f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802643:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802647:	89 f9                	mov    %edi,%ecx
  802649:	d3 e8                	shr    %cl,%eax
  80264b:	09 e8                	or     %ebp,%eax
  80264d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802651:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802655:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802659:	d3 e0                	shl    %cl,%eax
  80265b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80265f:	89 f2                	mov    %esi,%edx
  802661:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802663:	8b 44 24 14          	mov    0x14(%esp),%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80266d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802671:	89 f9                	mov    %edi,%ecx
  802673:	d3 e8                	shr    %cl,%eax
  802675:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802677:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802679:	89 f2                	mov    %esi,%edx
  80267b:	f7 74 24 18          	divl   0x18(%esp)
  80267f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802681:	f7 64 24 0c          	mull   0xc(%esp)
  802685:	89 c5                	mov    %eax,%ebp
  802687:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802689:	39 d6                	cmp    %edx,%esi
  80268b:	72 67                	jb     8026f4 <__umoddi3+0x114>
  80268d:	74 75                	je     802704 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80268f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802693:	29 e8                	sub    %ebp,%eax
  802695:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802697:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	89 f2                	mov    %esi,%edx
  80269f:	89 f9                	mov    %edi,%ecx
  8026a1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8026a3:	09 d0                	or     %edx,%eax
  8026a5:	89 f2                	mov    %esi,%edx
  8026a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026ab:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026ad:	83 c4 20             	add    $0x20,%esp
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026b4:	85 c9                	test   %ecx,%ecx
  8026b6:	75 0b                	jne    8026c3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8026bd:	31 d2                	xor    %edx,%edx
  8026bf:	f7 f1                	div    %ecx
  8026c1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026c3:	89 f0                	mov    %esi,%eax
  8026c5:	31 d2                	xor    %edx,%edx
  8026c7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026c9:	89 f8                	mov    %edi,%eax
  8026cb:	e9 3e ff ff ff       	jmp    80260e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8026d0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026d2:	83 c4 20             	add    $0x20,%esp
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026dc:	39 f5                	cmp    %esi,%ebp
  8026de:	72 04                	jb     8026e4 <__umoddi3+0x104>
  8026e0:	39 f9                	cmp    %edi,%ecx
  8026e2:	77 06                	ja     8026ea <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026e4:	89 f2                	mov    %esi,%edx
  8026e6:	29 cf                	sub    %ecx,%edi
  8026e8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026ea:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026ec:	83 c4 20             	add    $0x20,%esp
  8026ef:	5e                   	pop    %esi
  8026f0:	5f                   	pop    %edi
  8026f1:	5d                   	pop    %ebp
  8026f2:	c3                   	ret    
  8026f3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026f4:	89 d1                	mov    %edx,%ecx
  8026f6:	89 c5                	mov    %eax,%ebp
  8026f8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026fc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802700:	eb 8d                	jmp    80268f <__umoddi3+0xaf>
  802702:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802704:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802708:	72 ea                	jb     8026f4 <__umoddi3+0x114>
  80270a:	89 f1                	mov    %esi,%ecx
  80270c:	eb 81                	jmp    80268f <__umoddi3+0xaf>
