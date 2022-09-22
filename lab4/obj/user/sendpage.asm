
obj/user/sendpage:     file format elf32-i386


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
  80003a:	e8 68 10 00 00       	call   8010a7 <fork>
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
  800060:	e8 53 13 00 00       	call   8013b8 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 40 18 80 00 	movl   $0x801840,(%esp)
  80007b:	e8 7c 02 00 00       	call   8002fc <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 e7 07 00 00       	call   800874 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 c9 08 00 00       	call   80096f <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 54 18 80 00 	movl   $0x801854,(%esp)
  8000b1:	e8 46 02 00 00       	call   8002fc <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 b1 07 00 00       	call   800874 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 ad 09 00 00       	call   800a8a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 25 13 00 00       	call   801425 <ipc_send>
		return;
  800100:	e9 d8 00 00 00       	jmp    8001dd <umain+0x1a9>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010a:	8b 00                	mov    (%eax),%eax
  80010c:	8b 40 48             	mov    0x48(%eax),%eax
  80010f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011e:	00 
  80011f:	89 04 24             	mov    %eax,(%esp)
  800122:	e8 72 0b 00 00       	call   800c99 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800127:	a1 04 20 80 00       	mov    0x802004,%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 40 07 00 00       	call   800874 <strlen>
  800134:	40                   	inc    %eax
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	a1 04 20 80 00       	mov    0x802004,%eax
  80013e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800142:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800149:	e8 3c 09 00 00       	call   800a8a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800155:	00 
  800156:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015d:	00 
  80015e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800165:	00 
  800166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 b4 12 00 00       	call   801425 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800171:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800178:	00 
  800179:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800180:	00 
  800181:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 2c 12 00 00       	call   8013b8 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018c:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800193:	00 
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019b:	c7 04 24 40 18 80 00 	movl   $0x801840,(%esp)
  8001a2:	e8 55 01 00 00       	call   8002fc <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a7:	a1 00 20 80 00       	mov    0x802000,%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 c0 06 00 00       	call   800874 <strlen>
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c8:	e8 a2 07 00 00       	call   80096f <strncmp>
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	75 0c                	jne    8001dd <umain+0x1a9>
		cprintf("parent received correct message\n");
  8001d1:	c7 04 24 74 18 80 00 	movl   $0x801874,(%esp)
  8001d8:	e8 1f 01 00 00       	call   8002fc <cprintf>
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
  8001ee:	e8 68 0a 00 00       	call   800c5b <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  80020c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80020f:	a3 0c 20 80 00       	mov    %eax,0x80200c
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800218:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  80021f:	e8 d8 00 00 00       	call   8002fc <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800224:	85 f6                	test   %esi,%esi
  800226:	7e 07                	jle    80022f <libmain+0x4f>
		binaryname = argv[0];
  800228:	8b 03                	mov    (%ebx),%eax
  80022a:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  80022f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800233:	89 34 24             	mov    %esi,(%esp)
  800236:	e8 f9 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80023b:	e8 08 00 00 00       	call   800248 <exit>
}
  800240:	83 c4 20             	add    $0x20,%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    
	...

00800248 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80024e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800255:	e8 af 09 00 00       	call   800c09 <sys_env_destroy>
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	53                   	push   %ebx
  800260:	83 ec 14             	sub    $0x14,%esp
  800263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800266:	8b 03                	mov    (%ebx),%eax
  800268:	8b 55 08             	mov    0x8(%ebp),%edx
  80026b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80026f:	40                   	inc    %eax
  800270:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800272:	3d ff 00 00 00       	cmp    $0xff,%eax
  800277:	75 19                	jne    800292 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800279:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800280:	00 
  800281:	8d 43 08             	lea    0x8(%ebx),%eax
  800284:	89 04 24             	mov    %eax,(%esp)
  800287:	e8 40 09 00 00       	call   800bcc <sys_cputs>
		b->idx = 0;
  80028c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800292:	ff 43 04             	incl   0x4(%ebx)
}
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	5b                   	pop    %ebx
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ab:	00 00 00 
	b.cnt = 0;
  8002ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	c7 04 24 5c 02 80 00 	movl   $0x80025c,(%esp)
  8002d7:	e8 82 01 00 00       	call   80045e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002dc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ec:	89 04 24             	mov    %eax,(%esp)
  8002ef:	e8 d8 08 00 00       	call   800bcc <sys_cputs>

	return b.cnt;
}
  8002f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800302:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800305:	89 44 24 04          	mov    %eax,0x4(%esp)
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	e8 87 ff ff ff       	call   80029b <vcprintf>
	va_end(ap);

	return cnt;
}
  800314:	c9                   	leave  
  800315:	c3                   	ret    
	...

00800318 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 3c             	sub    $0x3c,%esp
  800321:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800324:	89 d7                	mov    %edx,%edi
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80032c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800332:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800335:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800338:	85 c0                	test   %eax,%eax
  80033a:	75 08                	jne    800344 <printnum+0x2c>
  80033c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800342:	77 57                	ja     80039b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800344:	89 74 24 10          	mov    %esi,0x10(%esp)
  800348:	4b                   	dec    %ebx
  800349:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80034d:	8b 45 10             	mov    0x10(%ebp),%eax
  800350:	89 44 24 08          	mov    %eax,0x8(%esp)
  800354:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800358:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80035c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800363:	00 
  800364:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800371:	e8 6a 12 00 00       	call   8015e0 <__udivdi3>
  800376:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80037a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	89 54 24 04          	mov    %edx,0x4(%esp)
  800385:	89 fa                	mov    %edi,%edx
  800387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038a:	e8 89 ff ff ff       	call   800318 <printnum>
  80038f:	eb 0f                	jmp    8003a0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	89 34 24             	mov    %esi,(%esp)
  800398:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	4b                   	dec    %ebx
  80039c:	85 db                	test   %ebx,%ebx
  80039e:	7f f1                	jg     800391 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003b6:	00 
  8003b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ba:	89 04 24             	mov    %eax,(%esp)
  8003bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	e8 37 13 00 00       	call   801700 <__umoddi3>
  8003c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003cd:	0f be 80 ec 18 80 00 	movsbl 0x8018ec(%eax),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003da:	83 c4 3c             	add    $0x3c,%esp
  8003dd:	5b                   	pop    %ebx
  8003de:	5e                   	pop    %esi
  8003df:	5f                   	pop    %edi
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e5:	83 fa 01             	cmp    $0x1,%edx
  8003e8:	7e 0e                	jle    8003f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ef:	89 08                	mov    %ecx,(%eax)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	8b 52 04             	mov    0x4(%edx),%edx
  8003f6:	eb 22                	jmp    80041a <getuint+0x38>
	else if (lflag)
  8003f8:	85 d2                	test   %edx,%edx
  8003fa:	74 10                	je     80040c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
  80040a:	eb 0e                	jmp    80041a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800411:	89 08                	mov    %ecx,(%eax)
  800413:	8b 02                	mov    (%edx),%eax
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041a:	5d                   	pop    %ebp
  80041b:	c3                   	ret    

0080041c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800422:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800425:	8b 10                	mov    (%eax),%edx
  800427:	3b 50 04             	cmp    0x4(%eax),%edx
  80042a:	73 08                	jae    800434 <sprintputch+0x18>
		*b->buf++ = ch;
  80042c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042f:	88 0a                	mov    %cl,(%edx)
  800431:	42                   	inc    %edx
  800432:	89 10                	mov    %edx,(%eax)
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80043c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 10             	mov    0x10(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 04 24             	mov    %eax,(%esp)
  800457:	e8 02 00 00 00       	call   80045e <vprintfmt>
	va_end(ap);
}
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	57                   	push   %edi
  800462:	56                   	push   %esi
  800463:	53                   	push   %ebx
  800464:	83 ec 4c             	sub    $0x4c,%esp
  800467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046a:	8b 75 10             	mov    0x10(%ebp),%esi
  80046d:	eb 12                	jmp    800481 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80046f:	85 c0                	test   %eax,%eax
  800471:	0f 84 6b 03 00 00    	je     8007e2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800477:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800481:	0f b6 06             	movzbl (%esi),%eax
  800484:	46                   	inc    %esi
  800485:	83 f8 25             	cmp    $0x25,%eax
  800488:	75 e5                	jne    80046f <vprintfmt+0x11>
  80048a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80048e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800495:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80049a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a6:	eb 26                	jmp    8004ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004ab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004af:	eb 1d                	jmp    8004ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004b8:	eb 14                	jmp    8004ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004c4:	eb 08                	jmp    8004ce <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	0f b6 06             	movzbl (%esi),%eax
  8004d1:	8d 56 01             	lea    0x1(%esi),%edx
  8004d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d7:	8a 16                	mov    (%esi),%dl
  8004d9:	83 ea 23             	sub    $0x23,%edx
  8004dc:	80 fa 55             	cmp    $0x55,%dl
  8004df:	0f 87 e1 02 00 00    	ja     8007c6 <vprintfmt+0x368>
  8004e5:	0f b6 d2             	movzbl %dl,%edx
  8004e8:	ff 24 95 c0 19 80 00 	jmp    *0x8019c0(,%edx,4)
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004fa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004fe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800501:	8d 50 d0             	lea    -0x30(%eax),%edx
  800504:	83 fa 09             	cmp    $0x9,%edx
  800507:	77 2a                	ja     800533 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800509:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80050a:	eb eb                	jmp    8004f7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8d 50 04             	lea    0x4(%eax),%edx
  800512:	89 55 14             	mov    %edx,0x14(%ebp)
  800515:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80051a:	eb 17                	jmp    800533 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800520:	78 98                	js     8004ba <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800525:	eb a7                	jmp    8004ce <vprintfmt+0x70>
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80052a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800531:	eb 9b                	jmp    8004ce <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800533:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800537:	79 95                	jns    8004ce <vprintfmt+0x70>
  800539:	eb 8b                	jmp    8004c6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053f:	eb 8d                	jmp    8004ce <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800559:	e9 23 ff ff ff       	jmp    800481 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	85 c0                	test   %eax,%eax
  80056b:	79 02                	jns    80056f <vprintfmt+0x111>
  80056d:	f7 d8                	neg    %eax
  80056f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800571:	83 f8 08             	cmp    $0x8,%eax
  800574:	7f 0b                	jg     800581 <vprintfmt+0x123>
  800576:	8b 04 85 20 1b 80 00 	mov    0x801b20(,%eax,4),%eax
  80057d:	85 c0                	test   %eax,%eax
  80057f:	75 23                	jne    8005a4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800581:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800585:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  80058c:	00 
  80058d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	e8 9a fe ff ff       	call   800436 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059f:	e9 dd fe ff ff       	jmp    800481 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a8:	c7 44 24 08 0d 19 80 	movl   $0x80190d,0x8(%esp)
  8005af:	00 
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b7:	89 14 24             	mov    %edx,(%esp)
  8005ba:	e8 77 fe ff ff       	call   800436 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c2:	e9 ba fe ff ff       	jmp    800481 <vprintfmt+0x23>
  8005c7:	89 f9                	mov    %edi,%ecx
  8005c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 30                	mov    (%eax),%esi
  8005da:	85 f6                	test   %esi,%esi
  8005dc:	75 05                	jne    8005e3 <vprintfmt+0x185>
				p = "(null)";
  8005de:	be fd 18 80 00       	mov    $0x8018fd,%esi
			if (width > 0 && padc != '-')
  8005e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e7:	0f 8e 84 00 00 00    	jle    800671 <vprintfmt+0x213>
  8005ed:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005f1:	74 7e                	je     800671 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f7:	89 34 24             	mov    %esi,(%esp)
  8005fa:	e8 8b 02 00 00       	call   80088a <strnlen>
  8005ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800602:	29 c2                	sub    %eax,%edx
  800604:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800607:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80060b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80060e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800611:	89 de                	mov    %ebx,%esi
  800613:	89 d3                	mov    %edx,%ebx
  800615:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800617:	eb 0b                	jmp    800624 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800619:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061d:	89 3c 24             	mov    %edi,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800623:	4b                   	dec    %ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f f1                	jg     800619 <vprintfmt+0x1bb>
  800628:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80062b:	89 f3                	mov    %esi,%ebx
  80062d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800633:	85 c0                	test   %eax,%eax
  800635:	79 05                	jns    80063c <vprintfmt+0x1de>
  800637:	b8 00 00 00 00       	mov    $0x0,%eax
  80063c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063f:	29 c2                	sub    %eax,%edx
  800641:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800644:	eb 2b                	jmp    800671 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064a:	74 18                	je     800664 <vprintfmt+0x206>
  80064c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80064f:	83 fa 5e             	cmp    $0x5e,%edx
  800652:	76 10                	jbe    800664 <vprintfmt+0x206>
					putch('?', putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	eb 0a                	jmp    80066e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	89 04 24             	mov    %eax,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066e:	ff 4d e4             	decl   -0x1c(%ebp)
  800671:	0f be 06             	movsbl (%esi),%eax
  800674:	46                   	inc    %esi
  800675:	85 c0                	test   %eax,%eax
  800677:	74 21                	je     80069a <vprintfmt+0x23c>
  800679:	85 ff                	test   %edi,%edi
  80067b:	78 c9                	js     800646 <vprintfmt+0x1e8>
  80067d:	4f                   	dec    %edi
  80067e:	79 c6                	jns    800646 <vprintfmt+0x1e8>
  800680:	8b 7d 08             	mov    0x8(%ebp),%edi
  800683:	89 de                	mov    %ebx,%esi
  800685:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800688:	eb 18                	jmp    8006a2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800695:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800697:	4b                   	dec    %ebx
  800698:	eb 08                	jmp    8006a2 <vprintfmt+0x244>
  80069a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069d:	89 de                	mov    %ebx,%esi
  80069f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a2:	85 db                	test   %ebx,%ebx
  8006a4:	7f e4                	jg     80068a <vprintfmt+0x22c>
  8006a6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006a9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ae:	e9 ce fd ff ff       	jmp    800481 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b3:	83 f9 01             	cmp    $0x1,%ecx
  8006b6:	7e 10                	jle    8006c8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 08             	lea    0x8(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 30                	mov    (%eax),%esi
  8006c3:	8b 78 04             	mov    0x4(%eax),%edi
  8006c6:	eb 26                	jmp    8006ee <vprintfmt+0x290>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	74 12                	je     8006de <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 30                	mov    (%eax),%esi
  8006d7:	89 f7                	mov    %esi,%edi
  8006d9:	c1 ff 1f             	sar    $0x1f,%edi
  8006dc:	eb 10                	jmp    8006ee <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 30                	mov    (%eax),%esi
  8006e9:	89 f7                	mov    %esi,%edi
  8006eb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ee:	85 ff                	test   %edi,%edi
  8006f0:	78 0a                	js     8006fc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f7:	e9 8c 00 00 00       	jmp    800788 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80070a:	f7 de                	neg    %esi
  80070c:	83 d7 00             	adc    $0x0,%edi
  80070f:	f7 df                	neg    %edi
			}
			base = 10;
  800711:	b8 0a 00 00 00       	mov    $0xa,%eax
  800716:	eb 70                	jmp    800788 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800718:	89 ca                	mov    %ecx,%edx
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
  80071d:	e8 c0 fc ff ff       	call   8003e2 <getuint>
  800722:	89 c6                	mov    %eax,%esi
  800724:	89 d7                	mov    %edx,%edi
			base = 10;
  800726:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80072b:	eb 5b                	jmp    800788 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80072d:	89 ca                	mov    %ecx,%edx
  80072f:	8d 45 14             	lea    0x14(%ebp),%eax
  800732:	e8 ab fc ff ff       	call   8003e2 <getuint>
  800737:	89 c6                	mov    %eax,%esi
  800739:	89 d7                	mov    %edx,%edi
			base = 8;
  80073b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800740:	eb 46                	jmp    800788 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800742:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800746:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800750:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800754:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8d 50 04             	lea    0x4(%eax),%edx
  800764:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800767:	8b 30                	mov    (%eax),%esi
  800769:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800773:	eb 13                	jmp    800788 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800775:	89 ca                	mov    %ecx,%edx
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	e8 63 fc ff ff       	call   8003e2 <getuint>
  80077f:	89 c6                	mov    %eax,%esi
  800781:	89 d7                	mov    %edx,%edi
			base = 16;
  800783:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800788:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80078c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800790:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800793:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800797:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079b:	89 34 24             	mov    %esi,(%esp)
  80079e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a2:	89 da                	mov    %ebx,%edx
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	e8 6c fb ff ff       	call   800318 <printnum>
			break;
  8007ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007af:	e9 cd fc ff ff       	jmp    800481 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b8:	89 04 24             	mov    %eax,(%esp)
  8007bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c1:	e9 bb fc ff ff       	jmp    800481 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ca:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d4:	eb 01                	jmp    8007d7 <vprintfmt+0x379>
  8007d6:	4e                   	dec    %esi
  8007d7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007db:	75 f9                	jne    8007d6 <vprintfmt+0x378>
  8007dd:	e9 9f fc ff ff       	jmp    800481 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007e2:	83 c4 4c             	add    $0x4c,%esp
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5f                   	pop    %edi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 28             	sub    $0x28,%esp
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800800:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800807:	85 c0                	test   %eax,%eax
  800809:	74 30                	je     80083b <vsnprintf+0x51>
  80080b:	85 d2                	test   %edx,%edx
  80080d:	7e 33                	jle    800842 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800816:	8b 45 10             	mov    0x10(%ebp),%eax
  800819:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800820:	89 44 24 04          	mov    %eax,0x4(%esp)
  800824:	c7 04 24 1c 04 80 00 	movl   $0x80041c,(%esp)
  80082b:	e8 2e fc ff ff       	call   80045e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800830:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800833:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800839:	eb 0c                	jmp    800847 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800840:	eb 05                	jmp    800847 <vsnprintf+0x5d>
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800852:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
  800859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 7b ff ff ff       	call   8007ea <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
  800871:	00 00                	add    %al,(%eax)
	...

00800874 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	eb 01                	jmp    800882 <strlen+0xe>
		n++;
  800881:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800886:	75 f9                	jne    800881 <strlen+0xd>
		n++;
	return n;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
  800898:	eb 01                	jmp    80089b <strnlen+0x11>
		n++;
  80089a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089b:	39 d0                	cmp    %edx,%eax
  80089d:	74 06                	je     8008a5 <strnlen+0x1b>
  80089f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a3:	75 f5                	jne    80089a <strnlen+0x10>
		n++;
	return n;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008b9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008bc:	42                   	inc    %edx
  8008bd:	84 c9                	test   %cl,%cl
  8008bf:	75 f5                	jne    8008b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c1:	5b                   	pop    %ebx
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ce:	89 1c 24             	mov    %ebx,(%esp)
  8008d1:	e8 9e ff ff ff       	call   800874 <strlen>
	strcpy(dst + len, src);
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008dd:	01 d8                	add    %ebx,%eax
  8008df:	89 04 24             	mov    %eax,(%esp)
  8008e2:	e8 c0 ff ff ff       	call   8008a7 <strcpy>
	return dst;
}
  8008e7:	89 d8                	mov    %ebx,%eax
  8008e9:	83 c4 08             	add    $0x8,%esp
  8008ec:	5b                   	pop    %ebx
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800902:	eb 0c                	jmp    800910 <strncpy+0x21>
		*dst++ = *src;
  800904:	8a 1a                	mov    (%edx),%bl
  800906:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800909:	80 3a 01             	cmpb   $0x1,(%edx)
  80090c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090f:	41                   	inc    %ecx
  800910:	39 f1                	cmp    %esi,%ecx
  800912:	75 f0                	jne    800904 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 75 08             	mov    0x8(%ebp),%esi
  800920:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800923:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800926:	85 d2                	test   %edx,%edx
  800928:	75 0a                	jne    800934 <strlcpy+0x1c>
  80092a:	89 f0                	mov    %esi,%eax
  80092c:	eb 1a                	jmp    800948 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092e:	88 18                	mov    %bl,(%eax)
  800930:	40                   	inc    %eax
  800931:	41                   	inc    %ecx
  800932:	eb 02                	jmp    800936 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800934:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800936:	4a                   	dec    %edx
  800937:	74 0a                	je     800943 <strlcpy+0x2b>
  800939:	8a 19                	mov    (%ecx),%bl
  80093b:	84 db                	test   %bl,%bl
  80093d:	75 ef                	jne    80092e <strlcpy+0x16>
  80093f:	89 c2                	mov    %eax,%edx
  800941:	eb 02                	jmp    800945 <strlcpy+0x2d>
  800943:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800945:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800948:	29 f0                	sub    %esi,%eax
}
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800957:	eb 02                	jmp    80095b <strcmp+0xd>
		p++, q++;
  800959:	41                   	inc    %ecx
  80095a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095b:	8a 01                	mov    (%ecx),%al
  80095d:	84 c0                	test   %al,%al
  80095f:	74 04                	je     800965 <strcmp+0x17>
  800961:	3a 02                	cmp    (%edx),%al
  800963:	74 f4                	je     800959 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800965:	0f b6 c0             	movzbl %al,%eax
  800968:	0f b6 12             	movzbl (%edx),%edx
  80096b:	29 d0                	sub    %edx,%eax
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800979:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80097c:	eb 03                	jmp    800981 <strncmp+0x12>
		n--, p++, q++;
  80097e:	4a                   	dec    %edx
  80097f:	40                   	inc    %eax
  800980:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800981:	85 d2                	test   %edx,%edx
  800983:	74 14                	je     800999 <strncmp+0x2a>
  800985:	8a 18                	mov    (%eax),%bl
  800987:	84 db                	test   %bl,%bl
  800989:	74 04                	je     80098f <strncmp+0x20>
  80098b:	3a 19                	cmp    (%ecx),%bl
  80098d:	74 ef                	je     80097e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098f:	0f b6 00             	movzbl (%eax),%eax
  800992:	0f b6 11             	movzbl (%ecx),%edx
  800995:	29 d0                	sub    %edx,%eax
  800997:	eb 05                	jmp    80099e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009aa:	eb 05                	jmp    8009b1 <strchr+0x10>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	74 0c                	je     8009bc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b0:	40                   	inc    %eax
  8009b1:	8a 10                	mov    (%eax),%dl
  8009b3:	84 d2                	test   %dl,%dl
  8009b5:	75 f5                	jne    8009ac <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009c7:	eb 05                	jmp    8009ce <strfind+0x10>
		if (*s == c)
  8009c9:	38 ca                	cmp    %cl,%dl
  8009cb:	74 07                	je     8009d4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009cd:	40                   	inc    %eax
  8009ce:	8a 10                	mov    (%eax),%dl
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 f5                	jne    8009c9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 30                	je     800a19 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 25                	jne    800a16 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 20                	jne    800a16 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f9:	89 d3                	mov    %edx,%ebx
  8009fb:	c1 e3 08             	shl    $0x8,%ebx
  8009fe:	89 d6                	mov    %edx,%esi
  800a00:	c1 e6 18             	shl    $0x18,%esi
  800a03:	89 d0                	mov    %edx,%eax
  800a05:	c1 e0 10             	shl    $0x10,%eax
  800a08:	09 f0                	or     %esi,%eax
  800a0a:	09 d0                	or     %edx,%eax
  800a0c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a0e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a11:	fc                   	cld    
  800a12:	f3 ab                	rep stos %eax,%es:(%edi)
  800a14:	eb 03                	jmp    800a19 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a16:	fc                   	cld    
  800a17:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a19:	89 f8                	mov    %edi,%eax
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5f                   	pop    %edi
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2e:	39 c6                	cmp    %eax,%esi
  800a30:	73 34                	jae    800a66 <memmove+0x46>
  800a32:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a35:	39 d0                	cmp    %edx,%eax
  800a37:	73 2d                	jae    800a66 <memmove+0x46>
		s += n;
		d += n;
  800a39:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3c:	f6 c2 03             	test   $0x3,%dl
  800a3f:	75 1b                	jne    800a5c <memmove+0x3c>
  800a41:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a47:	75 13                	jne    800a5c <memmove+0x3c>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	75 0e                	jne    800a5c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a4e:	83 ef 04             	sub    $0x4,%edi
  800a51:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a54:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a57:	fd                   	std    
  800a58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5a:	eb 07                	jmp    800a63 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5c:	4f                   	dec    %edi
  800a5d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a60:	fd                   	std    
  800a61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a63:	fc                   	cld    
  800a64:	eb 20                	jmp    800a86 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6c:	75 13                	jne    800a81 <memmove+0x61>
  800a6e:	a8 03                	test   $0x3,%al
  800a70:	75 0f                	jne    800a81 <memmove+0x61>
  800a72:	f6 c1 03             	test   $0x3,%cl
  800a75:	75 0a                	jne    800a81 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a77:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	fc                   	cld    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 05                	jmp    800a86 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a90:	8b 45 10             	mov    0x10(%ebp),%eax
  800a93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	89 04 24             	mov    %eax,(%esp)
  800aa4:	e8 77 ff ff ff       	call   800a20 <memmove>
}
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aba:	ba 00 00 00 00       	mov    $0x0,%edx
  800abf:	eb 16                	jmp    800ad7 <memcmp+0x2c>
		if (*s1 != *s2)
  800ac1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ac4:	42                   	inc    %edx
  800ac5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ac9:	38 c8                	cmp    %cl,%al
  800acb:	74 0a                	je     800ad7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800acd:	0f b6 c0             	movzbl %al,%eax
  800ad0:	0f b6 c9             	movzbl %cl,%ecx
  800ad3:	29 c8                	sub    %ecx,%eax
  800ad5:	eb 09                	jmp    800ae0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad7:	39 da                	cmp    %ebx,%edx
  800ad9:	75 e6                	jne    800ac1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aee:	89 c2                	mov    %eax,%edx
  800af0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af3:	eb 05                	jmp    800afa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af5:	38 08                	cmp    %cl,(%eax)
  800af7:	74 05                	je     800afe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af9:	40                   	inc    %eax
  800afa:	39 d0                	cmp    %edx,%eax
  800afc:	72 f7                	jb     800af5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0c:	eb 01                	jmp    800b0f <strtol+0xf>
		s++;
  800b0e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0f:	8a 02                	mov    (%edx),%al
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f9                	je     800b0e <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f5                	je     800b0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 08                	jne    800b25 <strtol+0x25>
		s++;
  800b1d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b23:	eb 13                	jmp    800b38 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b25:	3c 2d                	cmp    $0x2d,%al
  800b27:	75 0a                	jne    800b33 <strtol+0x33>
		s++, neg = 1;
  800b29:	8d 52 01             	lea    0x1(%edx),%edx
  800b2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b31:	eb 05                	jmp    800b38 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	85 db                	test   %ebx,%ebx
  800b3a:	74 05                	je     800b41 <strtol+0x41>
  800b3c:	83 fb 10             	cmp    $0x10,%ebx
  800b3f:	75 28                	jne    800b69 <strtol+0x69>
  800b41:	8a 02                	mov    (%edx),%al
  800b43:	3c 30                	cmp    $0x30,%al
  800b45:	75 10                	jne    800b57 <strtol+0x57>
  800b47:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b4b:	75 0a                	jne    800b57 <strtol+0x57>
		s += 2, base = 16;
  800b4d:	83 c2 02             	add    $0x2,%edx
  800b50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b55:	eb 12                	jmp    800b69 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b57:	85 db                	test   %ebx,%ebx
  800b59:	75 0e                	jne    800b69 <strtol+0x69>
  800b5b:	3c 30                	cmp    $0x30,%al
  800b5d:	75 05                	jne    800b64 <strtol+0x64>
		s++, base = 8;
  800b5f:	42                   	inc    %edx
  800b60:	b3 08                	mov    $0x8,%bl
  800b62:	eb 05                	jmp    800b69 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b64:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b70:	8a 0a                	mov    (%edx),%cl
  800b72:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b75:	80 fb 09             	cmp    $0x9,%bl
  800b78:	77 08                	ja     800b82 <strtol+0x82>
			dig = *s - '0';
  800b7a:	0f be c9             	movsbl %cl,%ecx
  800b7d:	83 e9 30             	sub    $0x30,%ecx
  800b80:	eb 1e                	jmp    800ba0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b82:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b85:	80 fb 19             	cmp    $0x19,%bl
  800b88:	77 08                	ja     800b92 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b8a:	0f be c9             	movsbl %cl,%ecx
  800b8d:	83 e9 57             	sub    $0x57,%ecx
  800b90:	eb 0e                	jmp    800ba0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b92:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b95:	80 fb 19             	cmp    $0x19,%bl
  800b98:	77 12                	ja     800bac <strtol+0xac>
			dig = *s - 'A' + 10;
  800b9a:	0f be c9             	movsbl %cl,%ecx
  800b9d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ba0:	39 f1                	cmp    %esi,%ecx
  800ba2:	7d 0c                	jge    800bb0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ba4:	42                   	inc    %edx
  800ba5:	0f af c6             	imul   %esi,%eax
  800ba8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800baa:	eb c4                	jmp    800b70 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bac:	89 c1                	mov    %eax,%ecx
  800bae:	eb 02                	jmp    800bb2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb6:	74 05                	je     800bbd <strtol+0xbd>
		*endptr = (char *) s;
  800bb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bbb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bbd:	85 ff                	test   %edi,%edi
  800bbf:	74 04                	je     800bc5 <strtol+0xc5>
  800bc1:	89 c8                	mov    %ecx,%eax
  800bc3:	f7 d8                	neg    %eax
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    
	...

00800bcc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 c3                	mov    %eax,%ebx
  800bdf:	89 c7                	mov    %eax,%edi
  800be1:	89 c6                	mov    %eax,%esi
  800be3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_cgetc>:

int
sys_cgetc(void)
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
  800bf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c17:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 cb                	mov    %ecx,%ebx
  800c21:	89 cf                	mov    %ecx,%edi
  800c23:	89 ce                	mov    %ecx,%esi
  800c25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 28                	jle    800c53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c36:	00 
  800c37:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c46:	00 
  800c47:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  800c4e:	e8 7d 08 00 00       	call   8014d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c53:	83 c4 2c             	add    $0x2c,%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_yield>:

void
sys_yield(void)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	be 00 00 00 00       	mov    $0x0,%esi
  800ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 f7                	mov    %esi,%edi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 28                	jle    800ce5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd8:	00 
  800cd9:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  800ce0:	e8 eb 07 00 00       	call   8014d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce5:	83 c4 2c             	add    $0x2c,%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7e 28                	jle    800d38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d1b:	00 
  800d1c:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  800d23:	00 
  800d24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2b:	00 
  800d2c:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  800d33:	e8 98 07 00 00       	call   8014d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d38:	83 c4 2c             	add    $0x2c,%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 28                	jle    800d8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d6e:	00 
  800d6f:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  800d76:	00 
  800d77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7e:	00 
  800d7f:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  800d86:	e8 45 07 00 00       	call   8014d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8b:	83 c4 2c             	add    $0x2c,%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da1:	b8 08 00 00 00       	mov    $0x8,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	89 df                	mov    %ebx,%edi
  800dae:	89 de                	mov    %ebx,%esi
  800db0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db2:	85 c0                	test   %eax,%eax
  800db4:	7e 28                	jle    800dde <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  800dc9:	00 
  800dca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd1:	00 
  800dd2:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  800dd9:	e8 f2 06 00 00       	call   8014d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dde:	83 c4 2c             	add    $0x2c,%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	b8 09 00 00 00       	mov    $0x9,%eax
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 df                	mov    %ebx,%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7e 28                	jle    800e31 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e14:	00 
  800e15:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  800e1c:	00 
  800e1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e24:	00 
  800e25:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  800e2c:	e8 9f 06 00 00       	call   8014d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e31:	83 c4 2c             	add    $0x2c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3f:	be 00 00 00 00       	mov    $0x0,%esi
  800e44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e52:	8b 55 08             	mov    0x8(%ebp),%edx
  800e55:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	89 cb                	mov    %ecx,%ebx
  800e74:	89 cf                	mov    %ecx,%edi
  800e76:	89 ce                	mov    %ecx,%esi
  800e78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	7e 28                	jle    800ea6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e82:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e89:	00 
  800e8a:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  800e91:	00 
  800e92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e99:	00 
  800e9a:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  800ea1:	e8 2a 06 00 00       	call   8014d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea6:	83 c4 2c             	add    $0x2c,%esp
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    
	...

00800eb0 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 3c             	sub    $0x3c,%esp
  800eb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800ebc:	89 d6                	mov    %edx,%esi
  800ebe:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800ec1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800ecb:	e8 8b fd ff ff       	call   800c5b <sys_getenvid>
  800ed0:	89 c7                	mov    %eax,%edi
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ed5:	25 02 08 00 00       	and    $0x802,%eax
  800eda:	83 f8 01             	cmp    $0x1,%eax
  800edd:	19 db                	sbb    %ebx,%ebx
  800edf:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800ee5:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800eeb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800eef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ef3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800efa:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efe:	89 3c 24             	mov    %edi,(%esp)
  800f01:	e8 e7 fd ff ff       	call   800ced <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 1c                	jns    800f26 <duppage+0x76>
  800f0a:	c7 44 24 08 6f 1b 80 	movl   $0x801b6f,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800f19:	00 
  800f1a:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  800f21:	e8 aa 05 00 00       	call   8014d0 <_panic>
	if ((perm|~pte)&PTE_COW){
  800f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f29:	f7 d0                	not    %eax
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	f6 c4 08             	test   $0x8,%ah
  800f30:	74 38                	je     800f6a <duppage+0xba>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800f32:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800f36:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f3a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f42:	89 3c 24             	mov    %edi,(%esp)
  800f45:	e8 a3 fd ff ff       	call   800ced <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 1c                	jns    800f6a <duppage+0xba>
  800f4e:	c7 44 24 08 6f 1b 80 	movl   $0x801b6f,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  800f65:	e8 66 05 00 00       	call   8014d0 <_panic>
	}
	return 0;
	panic("duppage not implemented");
	return 0;
}
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	83 c4 3c             	add    $0x3c,%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 20             	sub    $0x20,%esp
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f82:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800f84:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f88:	75 1c                	jne    800fa6 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800f8a:	c7 44 24 08 8b 1b 80 	movl   $0x801b8b,0x8(%esp)
  800f91:	00 
  800f92:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f99:	00 
  800f9a:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  800fa1:	e8 2a 05 00 00       	call   8014d0 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800fa6:	89 f0                	mov    %esi,%eax
  800fa8:	c1 e8 0c             	shr    $0xc,%eax
  800fab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb2:	f6 c4 08             	test   $0x8,%ah
  800fb5:	75 1c                	jne    800fd3 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800fb7:	c7 44 24 08 8b 1b 80 	movl   $0x801b8b,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  800fce:	e8 fd 04 00 00       	call   8014d0 <_panic>
	envid_t envid = sys_getenvid();
  800fd3:	e8 83 fc ff ff       	call   800c5b <sys_getenvid>
  800fd8:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800fda:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe9:	00 
  800fea:	89 04 24             	mov    %eax,(%esp)
  800fed:	e8 a7 fc ff ff       	call   800c99 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 1c                	jns    801012 <pgfault+0x9b>
  800ff6:	c7 44 24 08 8b 1b 80 	movl   $0x801b8b,0x8(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801005:	00 
  801006:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  80100d:	e8 be 04 00 00       	call   8014d0 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  801012:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  801018:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80101f:	00 
  801020:	89 74 24 04          	mov    %esi,0x4(%esp)
  801024:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80102b:	e8 5a fa ff ff       	call   800a8a <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801030:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801037:	00 
  801038:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80103c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801040:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801047:	00 
  801048:	89 1c 24             	mov    %ebx,(%esp)
  80104b:	e8 9d fc ff ff       	call   800ced <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801050:	85 c0                	test   %eax,%eax
  801052:	79 1c                	jns    801070 <pgfault+0xf9>
  801054:	c7 44 24 08 8b 1b 80 	movl   $0x801b8b,0x8(%esp)
  80105b:	00 
  80105c:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801063:	00 
  801064:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  80106b:	e8 60 04 00 00       	call   8014d0 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801070:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801077:	00 
  801078:	89 1c 24             	mov    %ebx,(%esp)
  80107b:	e8 c0 fc ff ff       	call   800d40 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801080:	85 c0                	test   %eax,%eax
  801082:	79 1c                	jns    8010a0 <pgfault+0x129>
  801084:	c7 44 24 08 8b 1b 80 	movl   $0x801b8b,0x8(%esp)
  80108b:	00 
  80108c:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801093:	00 
  801094:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  80109b:	e8 30 04 00 00       	call   8014d0 <_panic>
	return;
	panic("pgfault not implemented");
}
  8010a0:	83 c4 20             	add    $0x20,%esp
  8010a3:	5b                   	pop    %ebx
  8010a4:	5e                   	pop    %esi
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010b0:	c7 04 24 77 0f 80 00 	movl   $0x800f77,(%esp)
  8010b7:	e8 6c 04 00 00       	call   801528 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010bc:	bf 07 00 00 00       	mov    $0x7,%edi
  8010c1:	89 f8                	mov    %edi,%eax
  8010c3:	cd 30                	int    $0x30
  8010c5:	89 c7                	mov    %eax,%edi
  8010c7:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	79 1c                	jns    8010e9 <fork+0x42>
		panic("fork : error!\n");
  8010cd:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8010dc:	00 
  8010dd:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  8010e4:	e8 e7 03 00 00       	call   8014d0 <_panic>
	if (envid==0){
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	75 28                	jne    801115 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  8010ed:	8b 1d 0c 20 80 00    	mov    0x80200c,%ebx
  8010f3:	e8 63 fb ff ff       	call   800c5b <sys_getenvid>
  8010f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801104:	c1 e0 07             	shl    $0x7,%eax
  801107:	29 d0                	sub    %edx,%eax
  801109:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80110e:	89 03                	mov    %eax,(%ebx)
		return envid;
  801110:	e9 f2 00 00 00       	jmp    801207 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801115:	e8 41 fb ff ff       	call   800c5b <sys_getenvid>
  80111a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801122:	89 d8                	mov    %ebx,%eax
  801124:	c1 e8 16             	shr    $0x16,%eax
  801127:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112e:	a8 01                	test   $0x1,%al
  801130:	74 17                	je     801149 <fork+0xa2>
  801132:	89 da                	mov    %ebx,%edx
  801134:	c1 ea 0c             	shr    $0xc,%edx
  801137:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80113e:	a8 01                	test   $0x1,%al
  801140:	74 07                	je     801149 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801142:	89 f0                	mov    %esi,%eax
  801144:	e8 67 fd ff ff       	call   800eb0 <duppage>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801149:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80114f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801155:	75 cb                	jne    801122 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801157:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801166:	ee 
  801167:	89 3c 24             	mov    %edi,(%esp)
  80116a:	e8 2a fb ff ff       	call   800c99 <sys_page_alloc>
  80116f:	85 c0                	test   %eax,%eax
  801171:	79 1c                	jns    80118f <fork+0xe8>
  801173:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  80118a:	e8 41 03 00 00       	call   8014d0 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  80118f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801192:	25 ff 03 00 00       	and    $0x3ff,%eax
  801197:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80119e:	c1 e0 07             	shl    $0x7,%eax
  8011a1:	29 d0                	sub    %edx,%eax
  8011a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a8:	8b 40 64             	mov    0x64(%eax),%eax
  8011ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011af:	89 3c 24             	mov    %edi,(%esp)
  8011b2:	e8 2f fc ff ff       	call   800de6 <sys_env_set_pgfault_upcall>
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	79 1c                	jns    8011d7 <fork+0x130>
  8011bb:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8011ca:	00 
  8011cb:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  8011d2:	e8 f9 02 00 00       	call   8014d0 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8011d7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011de:	00 
  8011df:	89 3c 24             	mov    %edi,(%esp)
  8011e2:	e8 ac fb ff ff       	call   800d93 <sys_env_set_status>
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	79 1c                	jns    801207 <fork+0x160>
  8011eb:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  8011fa:	00 
  8011fb:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  801202:	e8 c9 02 00 00       	call   8014d0 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801207:	89 f8                	mov    %edi,%eax
  801209:	83 c4 2c             	add    $0x2c,%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sfork>:

// Challenge!
int
sfork(void)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  80121a:	c7 04 24 77 0f 80 00 	movl   $0x800f77,(%esp)
  801221:	e8 02 03 00 00       	call   801528 <set_pgfault_handler>
  801226:	ba 07 00 00 00       	mov    $0x7,%edx
  80122b:	89 d0                	mov    %edx,%eax
  80122d:	cd 30                	int    $0x30
  80122f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801232:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801234:	89 44 24 04          	mov    %eax,0x4(%esp)
  801238:	c7 04 24 9c 1b 80 00 	movl   $0x801b9c,(%esp)
  80123f:	e8 b8 f0 ff ff       	call   8002fc <cprintf>
	if (envid<0)
  801244:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801248:	79 1c                	jns    801266 <sfork+0x55>
		panic("sfork : error!\n");
  80124a:	c7 44 24 08 a7 1b 80 	movl   $0x801ba7,0x8(%esp)
  801251:	00 
  801252:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801259:	00 
  80125a:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  801261:	e8 6a 02 00 00       	call   8014d0 <_panic>
	if (envid==0){
  801266:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80126a:	75 28                	jne    801294 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  80126c:	8b 1d 0c 20 80 00    	mov    0x80200c,%ebx
  801272:	e8 e4 f9 ff ff       	call   800c5b <sys_getenvid>
  801277:	25 ff 03 00 00       	and    $0x3ff,%eax
  80127c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801283:	c1 e0 07             	shl    $0x7,%eax
  801286:	29 d0                	sub    %edx,%eax
  801288:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80128d:	89 03                	mov    %eax,(%ebx)
		return envid;
  80128f:	e9 18 01 00 00       	jmp    8013ac <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801294:	e8 c2 f9 ff ff       	call   800c5b <sys_getenvid>
  801299:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80129b:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8012a0:	89 d8                	mov    %ebx,%eax
  8012a2:	c1 e8 16             	shr    $0x16,%eax
  8012a5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ac:	a8 01                	test   $0x1,%al
  8012ae:	74 2c                	je     8012dc <sfork+0xcb>
  8012b0:	89 d8                	mov    %ebx,%eax
  8012b2:	c1 e8 0c             	shr    $0xc,%eax
  8012b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bc:	a8 01                	test   $0x1,%al
  8012be:	74 1c                	je     8012dc <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8012c0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012c7:	00 
  8012c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012cc:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012d4:	89 3c 24             	mov    %edi,(%esp)
  8012d7:	e8 11 fa ff ff       	call   800ced <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8012dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012e2:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8012e8:	75 b6                	jne    8012a0 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8012ea:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8012ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f2:	e8 b9 fb ff ff       	call   800eb0 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  8012f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801306:	ee 
  801307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130a:	89 04 24             	mov    %eax,(%esp)
  80130d:	e8 87 f9 ff ff       	call   800c99 <sys_page_alloc>
  801312:	85 c0                	test   %eax,%eax
  801314:	79 1c                	jns    801332 <sfork+0x121>
  801316:	c7 44 24 08 a7 1b 80 	movl   $0x801ba7,0x8(%esp)
  80131d:	00 
  80131e:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801325:	00 
  801326:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  80132d:	e8 9e 01 00 00       	call   8014d0 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801332:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801338:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  80133f:	c1 e7 07             	shl    $0x7,%edi
  801342:	29 d7                	sub    %edx,%edi
  801344:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80134a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801351:	89 04 24             	mov    %eax,(%esp)
  801354:	e8 8d fa ff ff       	call   800de6 <sys_env_set_pgfault_upcall>
  801359:	85 c0                	test   %eax,%eax
  80135b:	79 1c                	jns    801379 <sfork+0x168>
  80135d:	c7 44 24 08 a7 1b 80 	movl   $0x801ba7,0x8(%esp)
  801364:	00 
  801365:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  80136c:	00 
  80136d:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  801374:	e8 57 01 00 00       	call   8014d0 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801379:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801380:	00 
  801381:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	e8 07 fa ff ff       	call   800d93 <sys_env_set_status>
  80138c:	85 c0                	test   %eax,%eax
  80138e:	79 1c                	jns    8013ac <sfork+0x19b>
  801390:	c7 44 24 08 a7 1b 80 	movl   $0x801ba7,0x8(%esp)
  801397:	00 
  801398:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80139f:	00 
  8013a0:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  8013a7:	e8 24 01 00 00       	call   8014d0 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8013ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013af:	83 c4 3c             	add    $0x3c,%esp
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5f                   	pop    %edi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    
	...

008013b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	56                   	push   %esi
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 10             	sub    $0x10,%esp
  8013c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	
	if (pg==NULL)pg=(void *)UTOP;
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	75 05                	jne    8013d2 <ipc_recv+0x1a>
  8013cd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  8013d2:	89 04 24             	mov    %eax,(%esp)
  8013d5:	e8 82 fa ff ff       	call   800e5c <sys_ipc_recv>
	// cprintf("%x\n",err);
	if (err < 0){
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	79 16                	jns    8013f4 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  8013de:	85 db                	test   %ebx,%ebx
  8013e0:	74 06                	je     8013e8 <ipc_recv+0x30>
  8013e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8013e8:	85 f6                	test   %esi,%esi
  8013ea:	74 32                	je     80141e <ipc_recv+0x66>
  8013ec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8013f2:	eb 2a                	jmp    80141e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8013f4:	85 db                	test   %ebx,%ebx
  8013f6:	74 0c                	je     801404 <ipc_recv+0x4c>
  8013f8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013fd:	8b 00                	mov    (%eax),%eax
  8013ff:	8b 40 74             	mov    0x74(%eax),%eax
  801402:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801404:	85 f6                	test   %esi,%esi
  801406:	74 0c                	je     801414 <ipc_recv+0x5c>
  801408:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80140d:	8b 00                	mov    (%eax),%eax
  80140f:	8b 40 78             	mov    0x78(%eax),%eax
  801412:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801414:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801419:	8b 00                	mov    (%eax),%eax
  80141b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	57                   	push   %edi
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	83 ec 1c             	sub    $0x1c,%esp
  80142e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801431:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801434:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801437:	85 db                	test   %ebx,%ebx
  801439:	75 05                	jne    801440 <ipc_send+0x1b>
  80143b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801440:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801444:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801448:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	e8 e2 f9 ff ff       	call   800e39 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801457:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80145a:	75 07                	jne    801463 <ipc_send+0x3e>
  80145c:	e8 19 f8 ff ff       	call   800c7a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801461:	eb dd                	jmp    801440 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801463:	85 c0                	test   %eax,%eax
  801465:	79 1c                	jns    801483 <ipc_send+0x5e>
  801467:	c7 44 24 08 b7 1b 80 	movl   $0x801bb7,0x8(%esp)
  80146e:	00 
  80146f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801476:	00 
  801477:	c7 04 24 c9 1b 80 00 	movl   $0x801bc9,(%esp)
  80147e:	e8 4d 00 00 00       	call   8014d0 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801483:	83 c4 1c             	add    $0x1c,%esp
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801492:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801497:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	c1 e2 07             	shl    $0x7,%edx
  8014a3:	29 ca                	sub    %ecx,%edx
  8014a5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014ab:	8b 52 50             	mov    0x50(%edx),%edx
  8014ae:	39 da                	cmp    %ebx,%edx
  8014b0:	75 0f                	jne    8014c1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8014b2:	c1 e0 07             	shl    $0x7,%eax
  8014b5:	29 c8                	sub    %ecx,%eax
  8014b7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014bc:	8b 40 40             	mov    0x40(%eax),%eax
  8014bf:	eb 0c                	jmp    8014cd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014c1:	40                   	inc    %eax
  8014c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014c7:	75 ce                	jne    801497 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014c9:	66 b8 00 00          	mov    $0x0,%ax
}
  8014cd:	5b                   	pop    %ebx
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8014d8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014db:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8014e1:	e8 75 f7 ff ff       	call   800c5b <sys_getenvid>
  8014e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fc:	c7 04 24 d4 1b 80 00 	movl   $0x801bd4,(%esp)
  801503:	e8 f4 ed ff ff       	call   8002fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801508:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150c:	8b 45 10             	mov    0x10(%ebp),%eax
  80150f:	89 04 24             	mov    %eax,(%esp)
  801512:	e8 84 ed ff ff       	call   80029b <vcprintf>
	cprintf("\n");
  801517:	c7 04 24 b5 1b 80 00 	movl   $0x801bb5,(%esp)
  80151e:	e8 d9 ed ff ff       	call   8002fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801523:	cc                   	int3   
  801524:	eb fd                	jmp    801523 <_panic+0x53>
	...

00801528 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	53                   	push   %ebx
  80152c:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80152f:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801536:	75 6f                	jne    8015a7 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  801538:	e8 1e f7 ff ff       	call   800c5b <sys_getenvid>
  80153d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80153f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801546:	00 
  801547:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80154e:	ee 
  80154f:	89 04 24             	mov    %eax,(%esp)
  801552:	e8 42 f7 ff ff       	call   800c99 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  801557:	85 c0                	test   %eax,%eax
  801559:	79 1c                	jns    801577 <set_pgfault_handler+0x4f>
  80155b:	c7 44 24 08 f8 1b 80 	movl   $0x801bf8,0x8(%esp)
  801562:	00 
  801563:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80156a:	00 
  80156b:	c7 04 24 54 1c 80 00 	movl   $0x801c54,(%esp)
  801572:	e8 59 ff ff ff       	call   8014d0 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801577:	c7 44 24 04 b8 15 80 	movl   $0x8015b8,0x4(%esp)
  80157e:	00 
  80157f:	89 1c 24             	mov    %ebx,(%esp)
  801582:	e8 5f f8 ff ff       	call   800de6 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  801587:	85 c0                	test   %eax,%eax
  801589:	79 1c                	jns    8015a7 <set_pgfault_handler+0x7f>
  80158b:	c7 44 24 08 20 1c 80 	movl   $0x801c20,0x8(%esp)
  801592:	00 
  801593:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80159a:	00 
  80159b:	c7 04 24 54 1c 80 00 	movl   $0x801c54,(%esp)
  8015a2:	e8 29 ff ff ff       	call   8014d0 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015aa:	a3 10 20 80 00       	mov    %eax,0x802010
}
  8015af:	83 c4 14             	add    $0x14,%esp
  8015b2:	5b                   	pop    %ebx
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    
  8015b5:	00 00                	add    %al,(%eax)
	...

008015b8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8015b8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8015b9:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8015be:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8015c0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8015c3:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8015c7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8015cc:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8015d0:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8015d2:	83 c4 08             	add    $0x8,%esp
	popal
  8015d5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8015d6:	83 c4 04             	add    $0x4,%esp
	popfl
  8015d9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8015da:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8015dd:	c3                   	ret    
	...

008015e0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8015e0:	55                   	push   %ebp
  8015e1:	57                   	push   %edi
  8015e2:	56                   	push   %esi
  8015e3:	83 ec 10             	sub    $0x10,%esp
  8015e6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8015ea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8015ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8015f6:	89 cd                	mov    %ecx,%ebp
  8015f8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	75 2c                	jne    80162c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801600:	39 f9                	cmp    %edi,%ecx
  801602:	77 68                	ja     80166c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801604:	85 c9                	test   %ecx,%ecx
  801606:	75 0b                	jne    801613 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801608:	b8 01 00 00 00       	mov    $0x1,%eax
  80160d:	31 d2                	xor    %edx,%edx
  80160f:	f7 f1                	div    %ecx
  801611:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801613:	31 d2                	xor    %edx,%edx
  801615:	89 f8                	mov    %edi,%eax
  801617:	f7 f1                	div    %ecx
  801619:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80161b:	89 f0                	mov    %esi,%eax
  80161d:	f7 f1                	div    %ecx
  80161f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801621:	89 f0                	mov    %esi,%eax
  801623:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	5e                   	pop    %esi
  801629:	5f                   	pop    %edi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80162c:	39 f8                	cmp    %edi,%eax
  80162e:	77 2c                	ja     80165c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801630:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801633:	83 f6 1f             	xor    $0x1f,%esi
  801636:	75 4c                	jne    801684 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801638:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80163a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80163f:	72 0a                	jb     80164b <__udivdi3+0x6b>
  801641:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801645:	0f 87 ad 00 00 00    	ja     8016f8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80164b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801650:	89 f0                	mov    %esi,%eax
  801652:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	5e                   	pop    %esi
  801658:	5f                   	pop    %edi
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    
  80165b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80165c:	31 ff                	xor    %edi,%edi
  80165e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801660:	89 f0                	mov    %esi,%eax
  801662:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	5e                   	pop    %esi
  801668:	5f                   	pop    %edi
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    
  80166b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80166c:	89 fa                	mov    %edi,%edx
  80166e:	89 f0                	mov    %esi,%eax
  801670:	f7 f1                	div    %ecx
  801672:	89 c6                	mov    %eax,%esi
  801674:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801676:	89 f0                	mov    %esi,%eax
  801678:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    
  801681:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801684:	89 f1                	mov    %esi,%ecx
  801686:	d3 e0                	shl    %cl,%eax
  801688:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80168c:	b8 20 00 00 00       	mov    $0x20,%eax
  801691:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801693:	89 ea                	mov    %ebp,%edx
  801695:	88 c1                	mov    %al,%cl
  801697:	d3 ea                	shr    %cl,%edx
  801699:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80169d:	09 ca                	or     %ecx,%edx
  80169f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8016a3:	89 f1                	mov    %esi,%ecx
  8016a5:	d3 e5                	shl    %cl,%ebp
  8016a7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8016ab:	89 fd                	mov    %edi,%ebp
  8016ad:	88 c1                	mov    %al,%cl
  8016af:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8016b1:	89 fa                	mov    %edi,%edx
  8016b3:	89 f1                	mov    %esi,%ecx
  8016b5:	d3 e2                	shl    %cl,%edx
  8016b7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016bb:	88 c1                	mov    %al,%cl
  8016bd:	d3 ef                	shr    %cl,%edi
  8016bf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8016c1:	89 f8                	mov    %edi,%eax
  8016c3:	89 ea                	mov    %ebp,%edx
  8016c5:	f7 74 24 08          	divl   0x8(%esp)
  8016c9:	89 d1                	mov    %edx,%ecx
  8016cb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8016cd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8016d1:	39 d1                	cmp    %edx,%ecx
  8016d3:	72 17                	jb     8016ec <__udivdi3+0x10c>
  8016d5:	74 09                	je     8016e0 <__udivdi3+0x100>
  8016d7:	89 fe                	mov    %edi,%esi
  8016d9:	31 ff                	xor    %edi,%edi
  8016db:	e9 41 ff ff ff       	jmp    801621 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8016e0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8016e4:	89 f1                	mov    %esi,%ecx
  8016e6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8016e8:	39 c2                	cmp    %eax,%edx
  8016ea:	73 eb                	jae    8016d7 <__udivdi3+0xf7>
		{
		  q0--;
  8016ec:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8016ef:	31 ff                	xor    %edi,%edi
  8016f1:	e9 2b ff ff ff       	jmp    801621 <__udivdi3+0x41>
  8016f6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8016f8:	31 f6                	xor    %esi,%esi
  8016fa:	e9 22 ff ff ff       	jmp    801621 <__udivdi3+0x41>
	...

00801700 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801700:	55                   	push   %ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	83 ec 20             	sub    $0x20,%esp
  801706:	8b 44 24 30          	mov    0x30(%esp),%eax
  80170a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80170e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801712:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801716:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80171a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80171e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801720:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801722:	85 ed                	test   %ebp,%ebp
  801724:	75 16                	jne    80173c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801726:	39 f1                	cmp    %esi,%ecx
  801728:	0f 86 a6 00 00 00    	jbe    8017d4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80172e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801730:	89 d0                	mov    %edx,%eax
  801732:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801734:	83 c4 20             	add    $0x20,%esp
  801737:	5e                   	pop    %esi
  801738:	5f                   	pop    %edi
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    
  80173b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80173c:	39 f5                	cmp    %esi,%ebp
  80173e:	0f 87 ac 00 00 00    	ja     8017f0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801744:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801747:	83 f0 1f             	xor    $0x1f,%eax
  80174a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80174e:	0f 84 a8 00 00 00    	je     8017fc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801754:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801758:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80175a:	bf 20 00 00 00       	mov    $0x20,%edi
  80175f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801763:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801767:	89 f9                	mov    %edi,%ecx
  801769:	d3 e8                	shr    %cl,%eax
  80176b:	09 e8                	or     %ebp,%eax
  80176d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801771:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801775:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801779:	d3 e0                	shl    %cl,%eax
  80177b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80177f:	89 f2                	mov    %esi,%edx
  801781:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801783:	8b 44 24 14          	mov    0x14(%esp),%eax
  801787:	d3 e0                	shl    %cl,%eax
  801789:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80178d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801791:	89 f9                	mov    %edi,%ecx
  801793:	d3 e8                	shr    %cl,%eax
  801795:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801797:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801799:	89 f2                	mov    %esi,%edx
  80179b:	f7 74 24 18          	divl   0x18(%esp)
  80179f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8017a1:	f7 64 24 0c          	mull   0xc(%esp)
  8017a5:	89 c5                	mov    %eax,%ebp
  8017a7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8017a9:	39 d6                	cmp    %edx,%esi
  8017ab:	72 67                	jb     801814 <__umoddi3+0x114>
  8017ad:	74 75                	je     801824 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8017af:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8017b3:	29 e8                	sub    %ebp,%eax
  8017b5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8017b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8017bb:	d3 e8                	shr    %cl,%eax
  8017bd:	89 f2                	mov    %esi,%edx
  8017bf:	89 f9                	mov    %edi,%ecx
  8017c1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8017c3:	09 d0                	or     %edx,%eax
  8017c5:	89 f2                	mov    %esi,%edx
  8017c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8017cb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8017cd:	83 c4 20             	add    $0x20,%esp
  8017d0:	5e                   	pop    %esi
  8017d1:	5f                   	pop    %edi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8017d4:	85 c9                	test   %ecx,%ecx
  8017d6:	75 0b                	jne    8017e3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8017d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8017dd:	31 d2                	xor    %edx,%edx
  8017df:	f7 f1                	div    %ecx
  8017e1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8017e3:	89 f0                	mov    %esi,%eax
  8017e5:	31 d2                	xor    %edx,%edx
  8017e7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8017e9:	89 f8                	mov    %edi,%eax
  8017eb:	e9 3e ff ff ff       	jmp    80172e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8017f0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8017f2:	83 c4 20             	add    $0x20,%esp
  8017f5:	5e                   	pop    %esi
  8017f6:	5f                   	pop    %edi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    
  8017f9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8017fc:	39 f5                	cmp    %esi,%ebp
  8017fe:	72 04                	jb     801804 <__umoddi3+0x104>
  801800:	39 f9                	cmp    %edi,%ecx
  801802:	77 06                	ja     80180a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801804:	89 f2                	mov    %esi,%edx
  801806:	29 cf                	sub    %ecx,%edi
  801808:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80180a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80180c:	83 c4 20             	add    $0x20,%esp
  80180f:	5e                   	pop    %esi
  801810:	5f                   	pop    %edi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    
  801813:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801814:	89 d1                	mov    %edx,%ecx
  801816:	89 c5                	mov    %eax,%ebp
  801818:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80181c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801820:	eb 8d                	jmp    8017af <__umoddi3+0xaf>
  801822:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801824:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801828:	72 ea                	jb     801814 <__umoddi3+0x114>
  80182a:	89 f1                	mov    %esi,%ecx
  80182c:	eb 81                	jmp    8017af <__umoddi3+0xaf>
