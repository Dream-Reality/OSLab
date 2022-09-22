
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  80003a:	c7 04 24 00 23 80 00 	movl   $0x802300,(%esp)
  800041:	e8 02 02 00 00       	call   800248 <cprintf>
	exit();
  800046:	e8 41 01 00 00       	call   80018c <exit>
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800063:	8b 45 0c             	mov    0xc(%ebp),%eax
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	8d 45 08             	lea    0x8(%ebp),%eax
  80006d:	89 04 24             	mov    %eax,(%esp)
  800070:	e8 db 0d 00 00       	call   800e50 <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800075:	bf 00 00 00 00       	mov    $0x0,%edi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80007a:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  800080:	eb 11                	jmp    800093 <umain+0x46>
		if (i == '1')
  800082:	83 f8 31             	cmp    $0x31,%eax
  800085:	74 07                	je     80008e <umain+0x41>
			usefprint = 1;
		else
			usage();
  800087:	e8 a8 ff ff ff       	call   800034 <usage>
  80008c:	eb 05                	jmp    800093 <umain+0x46>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  80008e:	bf 01 00 00 00       	mov    $0x1,%edi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800093:	89 1c 24             	mov    %ebx,(%esp)
  800096:	e8 ee 0d 00 00       	call   800e89 <argnext>
  80009b:	85 c0                	test   %eax,%eax
  80009d:	79 e3                	jns    800082 <umain+0x35>
  80009f:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a4:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	e8 2a 14 00 00       	call   8014e0 <fstat>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	78 66                	js     800120 <umain+0xd3>
			if (usefprint)
  8000ba:	85 ff                	test   %edi,%edi
  8000bc:	74 36                	je     8000f4 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000c1:	8b 40 04             	mov    0x4(%eax),%eax
  8000c4:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000cb:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d2:	89 44 24 10          	mov    %eax,0x10(%esp)
					i, st.st_name, st.st_isdir,
  8000d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000de:	c7 44 24 04 14 23 80 	movl   $0x802314,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ed:	e8 9e 18 00 00       	call   801990 <fprintf>
  8000f2:	eb 2c                	jmp    800120 <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f7:	8b 40 04             	mov    0x4(%eax),%eax
  8000fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800101:	89 44 24 10          	mov    %eax,0x10(%esp)
  800105:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800108:	89 44 24 0c          	mov    %eax,0xc(%esp)
					i, st.st_name, st.st_isdir,
  80010c:	89 74 24 08          	mov    %esi,0x8(%esp)
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  800110:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800114:	c7 04 24 14 23 80 00 	movl   $0x802314,(%esp)
  80011b:	e8 28 01 00 00       	call   800248 <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  800120:	43                   	inc    %ebx
  800121:	83 fb 20             	cmp    $0x20,%ebx
  800124:	75 84                	jne    8000aa <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800126:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	83 ec 20             	sub    $0x20,%esp
  80013c:	8b 75 08             	mov    0x8(%ebp),%esi
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800142:	e8 60 0a 00 00       	call   800ba7 <sys_getenvid>
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800153:	c1 e0 07             	shl    $0x7,%eax
  800156:	29 d0                	sub    %edx,%eax
  800158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800160:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800163:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800168:	85 f6                	test   %esi,%esi
  80016a:	7e 07                	jle    800173 <libmain+0x3f>
		binaryname = argv[0];
  80016c:	8b 03                	mov    (%ebx),%eax
  80016e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800173:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800177:	89 34 24             	mov    %esi,(%esp)
  80017a:	e8 ce fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  80017f:	e8 08 00 00 00       	call   80018c <exit>
}
  800184:	83 c4 20             	add    $0x20,%esp
  800187:	5b                   	pop    %ebx
  800188:	5e                   	pop    %esi
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    
	...

0080018c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800192:	e8 fa 0f 00 00       	call   801191 <close_all>
	sys_env_destroy(0);
  800197:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019e:	e8 b2 09 00 00       	call   800b55 <sys_env_destroy>
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    
  8001a5:	00 00                	add    %al,(%eax)
	...

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 03                	mov    (%ebx),%eax
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bb:	40                   	inc    %eax
  8001bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 19                	jne    8001de <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cc:	00 
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 40 09 00 00       	call   800b18 <sys_cputs>
		b->idx = 0;
  8001d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001de:	ff 43 04             	incl   0x4(%ebx)
}
  8001e1:	83 c4 14             	add    $0x14,%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f7:	00 00 00 
	b.cnt = 0;
  8001fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800201:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020b:	8b 45 08             	mov    0x8(%ebp),%eax
  80020e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800212:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800218:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021c:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800223:	e8 82 01 00 00       	call   8003aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800228:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800232:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 d8 08 00 00       	call   800b18 <sys_cputs>

	return b.cnt;
}
  800240:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	8b 45 08             	mov    0x8(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 87 ff ff ff       	call   8001e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    
	...

00800264 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 3c             	sub    $0x3c,%esp
  80026d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800270:	89 d7                	mov    %edx,%edi
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800281:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800284:	85 c0                	test   %eax,%eax
  800286:	75 08                	jne    800290 <printnum+0x2c>
  800288:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028e:	77 57                	ja     8002e7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800290:	89 74 24 10          	mov    %esi,0x10(%esp)
  800294:	4b                   	dec    %ebx
  800295:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800299:	8b 45 10             	mov    0x10(%ebp),%eax
  80029c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002af:	00 
  8002b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	e8 e2 1d 00 00       	call   8020a4 <__udivdi3>
  8002c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d1:	89 fa                	mov    %edi,%edx
  8002d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d6:	e8 89 ff ff ff       	call   800264 <printnum>
  8002db:	eb 0f                	jmp    8002ec <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e1:	89 34 24             	mov    %esi,(%esp)
  8002e4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e7:	4b                   	dec    %ebx
  8002e8:	85 db                	test   %ebx,%ebx
  8002ea:	7f f1                	jg     8002dd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800302:	00 
  800303:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800306:	89 04 24             	mov    %eax,(%esp)
  800309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	e8 af 1e 00 00       	call   8021c4 <__umoddi3>
  800315:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800319:	0f be 80 46 23 80 00 	movsbl 0x802346(%eax),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800326:	83 c4 3c             	add    $0x3c,%esp
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800331:	83 fa 01             	cmp    $0x1,%edx
  800334:	7e 0e                	jle    800344 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	8b 52 04             	mov    0x4(%edx),%edx
  800342:	eb 22                	jmp    800366 <getuint+0x38>
	else if (lflag)
  800344:	85 d2                	test   %edx,%edx
  800346:	74 10                	je     800358 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800348:	8b 10                	mov    (%eax),%edx
  80034a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb 0e                	jmp    800366 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800371:	8b 10                	mov    (%eax),%edx
  800373:	3b 50 04             	cmp    0x4(%eax),%edx
  800376:	73 08                	jae    800380 <sprintputch+0x18>
		*b->buf++ = ch;
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	88 0a                	mov    %cl,(%edx)
  80037d:	42                   	inc    %edx
  80037e:	89 10                	mov    %edx,(%eax)
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800388:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038f:	8b 45 10             	mov    0x10(%ebp),%eax
  800392:	89 44 24 08          	mov    %eax,0x8(%esp)
  800396:	8b 45 0c             	mov    0xc(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 02 00 00 00       	call   8003aa <vprintfmt>
	va_end(ap);
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	57                   	push   %edi
  8003ae:	56                   	push   %esi
  8003af:	53                   	push   %ebx
  8003b0:	83 ec 4c             	sub    $0x4c,%esp
  8003b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b9:	eb 12                	jmp    8003cd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	0f 84 6b 03 00 00    	je     80072e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003cd:	0f b6 06             	movzbl (%esi),%eax
  8003d0:	46                   	inc    %esi
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e5                	jne    8003bb <vprintfmt+0x11>
  8003d6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003da:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	eb 26                	jmp    80041a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003fb:	eb 1d                	jmp    80041a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800400:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800404:	eb 14                	jmp    80041a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800409:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800410:	eb 08                	jmp    80041a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800412:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800415:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	0f b6 06             	movzbl (%esi),%eax
  80041d:	8d 56 01             	lea    0x1(%esi),%edx
  800420:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800423:	8a 16                	mov    (%esi),%dl
  800425:	83 ea 23             	sub    $0x23,%edx
  800428:	80 fa 55             	cmp    $0x55,%dl
  80042b:	0f 87 e1 02 00 00    	ja     800712 <vprintfmt+0x368>
  800431:	0f b6 d2             	movzbl %dl,%edx
  800434:	ff 24 95 80 24 80 00 	jmp    *0x802480(,%edx,4)
  80043b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800443:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800446:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80044a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80044d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800450:	83 fa 09             	cmp    $0x9,%edx
  800453:	77 2a                	ja     80047f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800455:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800456:	eb eb                	jmp    800443 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 50 04             	lea    0x4(%eax),%edx
  80045e:	89 55 14             	mov    %edx,0x14(%ebp)
  800461:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800466:	eb 17                	jmp    80047f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800468:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046c:	78 98                	js     800406 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800471:	eb a7                	jmp    80041a <vprintfmt+0x70>
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800476:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80047d:	eb 9b                	jmp    80041a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80047f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800483:	79 95                	jns    80041a <vprintfmt+0x70>
  800485:	eb 8b                	jmp    800412 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800487:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048b:	eb 8d                	jmp    80041a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a5:	e9 23 ff ff ff       	jmp    8003cd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	8b 00                	mov    (%eax),%eax
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	79 02                	jns    8004bb <vprintfmt+0x111>
  8004b9:	f7 d8                	neg    %eax
  8004bb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bd:	83 f8 0f             	cmp    $0xf,%eax
  8004c0:	7f 0b                	jg     8004cd <vprintfmt+0x123>
  8004c2:	8b 04 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%eax
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	75 23                	jne    8004f0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d1:	c7 44 24 08 5e 23 80 	movl   $0x80235e,0x8(%esp)
  8004d8:	00 
  8004d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 9a fe ff ff       	call   800382 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004eb:	e9 dd fe ff ff       	jmp    8003cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f4:	c7 44 24 08 11 27 80 	movl   $0x802711,0x8(%esp)
  8004fb:	00 
  8004fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800500:	8b 55 08             	mov    0x8(%ebp),%edx
  800503:	89 14 24             	mov    %edx,(%esp)
  800506:	e8 77 fe ff ff       	call   800382 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050e:	e9 ba fe ff ff       	jmp    8003cd <vprintfmt+0x23>
  800513:	89 f9                	mov    %edi,%ecx
  800515:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800518:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 30                	mov    (%eax),%esi
  800526:	85 f6                	test   %esi,%esi
  800528:	75 05                	jne    80052f <vprintfmt+0x185>
				p = "(null)";
  80052a:	be 57 23 80 00       	mov    $0x802357,%esi
			if (width > 0 && padc != '-')
  80052f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800533:	0f 8e 84 00 00 00    	jle    8005bd <vprintfmt+0x213>
  800539:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80053d:	74 7e                	je     8005bd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800543:	89 34 24             	mov    %esi,(%esp)
  800546:	e8 8b 02 00 00       	call   8007d6 <strnlen>
  80054b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054e:	29 c2                	sub    %eax,%edx
  800550:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800553:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800557:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80055a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80055d:	89 de                	mov    %ebx,%esi
  80055f:	89 d3                	mov    %edx,%ebx
  800561:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	eb 0b                	jmp    800570 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800565:	89 74 24 04          	mov    %esi,0x4(%esp)
  800569:	89 3c 24             	mov    %edi,(%esp)
  80056c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	4b                   	dec    %ebx
  800570:	85 db                	test   %ebx,%ebx
  800572:	7f f1                	jg     800565 <vprintfmt+0x1bb>
  800574:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800577:	89 f3                	mov    %esi,%ebx
  800579:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80057c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057f:	85 c0                	test   %eax,%eax
  800581:	79 05                	jns    800588 <vprintfmt+0x1de>
  800583:	b8 00 00 00 00       	mov    $0x0,%eax
  800588:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058b:	29 c2                	sub    %eax,%edx
  80058d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800590:	eb 2b                	jmp    8005bd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800592:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800596:	74 18                	je     8005b0 <vprintfmt+0x206>
  800598:	8d 50 e0             	lea    -0x20(%eax),%edx
  80059b:	83 fa 5e             	cmp    $0x5e,%edx
  80059e:	76 10                	jbe    8005b0 <vprintfmt+0x206>
					putch('?', putdat);
  8005a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ab:	ff 55 08             	call   *0x8(%ebp)
  8005ae:	eb 0a                	jmp    8005ba <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	ff 4d e4             	decl   -0x1c(%ebp)
  8005bd:	0f be 06             	movsbl (%esi),%eax
  8005c0:	46                   	inc    %esi
  8005c1:	85 c0                	test   %eax,%eax
  8005c3:	74 21                	je     8005e6 <vprintfmt+0x23c>
  8005c5:	85 ff                	test   %edi,%edi
  8005c7:	78 c9                	js     800592 <vprintfmt+0x1e8>
  8005c9:	4f                   	dec    %edi
  8005ca:	79 c6                	jns    800592 <vprintfmt+0x1e8>
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cf:	89 de                	mov    %ebx,%esi
  8005d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d4:	eb 18                	jmp    8005ee <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005da:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e3:	4b                   	dec    %ebx
  8005e4:	eb 08                	jmp    8005ee <vprintfmt+0x244>
  8005e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e9:	89 de                	mov    %ebx,%esi
  8005eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ee:	85 db                	test   %ebx,%ebx
  8005f0:	7f e4                	jg     8005d6 <vprintfmt+0x22c>
  8005f2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fa:	e9 ce fd ff ff       	jmp    8003cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ff:	83 f9 01             	cmp    $0x1,%ecx
  800602:	7e 10                	jle    800614 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 08             	lea    0x8(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 30                	mov    (%eax),%esi
  80060f:	8b 78 04             	mov    0x4(%eax),%edi
  800612:	eb 26                	jmp    80063a <vprintfmt+0x290>
	else if (lflag)
  800614:	85 c9                	test   %ecx,%ecx
  800616:	74 12                	je     80062a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 30                	mov    (%eax),%esi
  800623:	89 f7                	mov    %esi,%edi
  800625:	c1 ff 1f             	sar    $0x1f,%edi
  800628:	eb 10                	jmp    80063a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 30                	mov    (%eax),%esi
  800635:	89 f7                	mov    %esi,%edi
  800637:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063a:	85 ff                	test   %edi,%edi
  80063c:	78 0a                	js     800648 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 8c 00 00 00       	jmp    8006d4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800656:	f7 de                	neg    %esi
  800658:	83 d7 00             	adc    $0x0,%edi
  80065b:	f7 df                	neg    %edi
			}
			base = 10;
  80065d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800662:	eb 70                	jmp    8006d4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800664:	89 ca                	mov    %ecx,%edx
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 c0 fc ff ff       	call   80032e <getuint>
  80066e:	89 c6                	mov    %eax,%esi
  800670:	89 d7                	mov    %edx,%edi
			base = 10;
  800672:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800677:	eb 5b                	jmp    8006d4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 ab fc ff ff       	call   80032e <getuint>
  800683:	89 c6                	mov    %eax,%esi
  800685:	89 d7                	mov    %edx,%edi
			base = 8;
  800687:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80068c:	eb 46                	jmp    8006d4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80068e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800692:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800699:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b3:	8b 30                	mov    (%eax),%esi
  8006b5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bf:	eb 13                	jmp    8006d4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c1:	89 ca                	mov    %ecx,%edx
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	e8 63 fc ff ff       	call   80032e <getuint>
  8006cb:	89 c6                	mov    %eax,%esi
  8006cd:	89 d7                	mov    %edx,%edi
			base = 16;
  8006cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006d8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e7:	89 34 24             	mov    %esi,(%esp)
  8006ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ee:	89 da                	mov    %ebx,%edx
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	e8 6c fb ff ff       	call   800264 <printnum>
			break;
  8006f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006fb:	e9 cd fc ff ff       	jmp    8003cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070d:	e9 bb fc ff ff       	jmp    8003cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800716:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800720:	eb 01                	jmp    800723 <vprintfmt+0x379>
  800722:	4e                   	dec    %esi
  800723:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800727:	75 f9                	jne    800722 <vprintfmt+0x378>
  800729:	e9 9f fc ff ff       	jmp    8003cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80072e:	83 c4 4c             	add    $0x4c,%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	83 ec 28             	sub    $0x28,%esp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 30                	je     800787 <vsnprintf+0x51>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 33                	jle    80078e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	c7 04 24 68 03 80 00 	movl   $0x800368,(%esp)
  800777:	e8 2e fc ff ff       	call   8003aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800785:	eb 0c                	jmp    800793 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078c:	eb 05                	jmp    800793 <vsnprintf+0x5d>
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	89 04 24             	mov    %eax,(%esp)
  8007b6:	e8 7b ff ff ff       	call   800736 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    
  8007bd:	00 00                	add    %al,(%eax)
	...

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 01                	jmp    8007ce <strlen+0xe>
		n++;
  8007cd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d2:	75 f9                	jne    8007cd <strlen+0xd>
		n++;
	return n;
}
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	eb 01                	jmp    8007e7 <strnlen+0x11>
		n++;
  8007e6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	39 d0                	cmp    %edx,%eax
  8007e9:	74 06                	je     8007f1 <strnlen+0x1b>
  8007eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ef:	75 f5                	jne    8007e6 <strnlen+0x10>
		n++;
	return n;
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800802:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800805:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800808:	42                   	inc    %edx
  800809:	84 c9                	test   %cl,%cl
  80080b:	75 f5                	jne    800802 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081a:	89 1c 24             	mov    %ebx,(%esp)
  80081d:	e8 9e ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	89 54 24 04          	mov    %edx,0x4(%esp)
  800829:	01 d8                	add    %ebx,%eax
  80082b:	89 04 24             	mov    %eax,(%esp)
  80082e:	e8 c0 ff ff ff       	call   8007f3 <strcpy>
	return dst;
}
  800833:	89 d8                	mov    %ebx,%eax
  800835:	83 c4 08             	add    $0x8,%esp
  800838:	5b                   	pop    %ebx
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
  800846:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084e:	eb 0c                	jmp    80085c <strncpy+0x21>
		*dst++ = *src;
  800850:	8a 1a                	mov    (%edx),%bl
  800852:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800855:	80 3a 01             	cmpb   $0x1,(%edx)
  800858:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085b:	41                   	inc    %ecx
  80085c:	39 f1                	cmp    %esi,%ecx
  80085e:	75 f0                	jne    800850 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	85 d2                	test   %edx,%edx
  800874:	75 0a                	jne    800880 <strlcpy+0x1c>
  800876:	89 f0                	mov    %esi,%eax
  800878:	eb 1a                	jmp    800894 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087a:	88 18                	mov    %bl,(%eax)
  80087c:	40                   	inc    %eax
  80087d:	41                   	inc    %ecx
  80087e:	eb 02                	jmp    800882 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800880:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800882:	4a                   	dec    %edx
  800883:	74 0a                	je     80088f <strlcpy+0x2b>
  800885:	8a 19                	mov    (%ecx),%bl
  800887:	84 db                	test   %bl,%bl
  800889:	75 ef                	jne    80087a <strlcpy+0x16>
  80088b:	89 c2                	mov    %eax,%edx
  80088d:	eb 02                	jmp    800891 <strlcpy+0x2d>
  80088f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800891:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800894:	29 f0                	sub    %esi,%eax
}
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a3:	eb 02                	jmp    8008a7 <strcmp+0xd>
		p++, q++;
  8008a5:	41                   	inc    %ecx
  8008a6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a7:	8a 01                	mov    (%ecx),%al
  8008a9:	84 c0                	test   %al,%al
  8008ab:	74 04                	je     8008b1 <strcmp+0x17>
  8008ad:	3a 02                	cmp    (%edx),%al
  8008af:	74 f4                	je     8008a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 c0             	movzbl %al,%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008c8:	eb 03                	jmp    8008cd <strncmp+0x12>
		n--, p++, q++;
  8008ca:	4a                   	dec    %edx
  8008cb:	40                   	inc    %eax
  8008cc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	74 14                	je     8008e5 <strncmp+0x2a>
  8008d1:	8a 18                	mov    (%eax),%bl
  8008d3:	84 db                	test   %bl,%bl
  8008d5:	74 04                	je     8008db <strncmp+0x20>
  8008d7:	3a 19                	cmp    (%ecx),%bl
  8008d9:	74 ef                	je     8008ca <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 00             	movzbl (%eax),%eax
  8008de:	0f b6 11             	movzbl (%ecx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
  8008e3:	eb 05                	jmp    8008ea <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f6:	eb 05                	jmp    8008fd <strchr+0x10>
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 0c                	je     800908 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fc:	40                   	inc    %eax
  8008fd:	8a 10                	mov    (%eax),%dl
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f5                	jne    8008f8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800913:	eb 05                	jmp    80091a <strfind+0x10>
		if (*s == c)
  800915:	38 ca                	cmp    %cl,%dl
  800917:	74 07                	je     800920 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800919:	40                   	inc    %eax
  80091a:	8a 10                	mov    (%eax),%dl
  80091c:	84 d2                	test   %dl,%dl
  80091e:	75 f5                	jne    800915 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 30                	je     800965 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800935:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093b:	75 25                	jne    800962 <memset+0x40>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 20                	jne    800962 <memset+0x40>
		c &= 0xFF;
  800942:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800945:	89 d3                	mov    %edx,%ebx
  800947:	c1 e3 08             	shl    $0x8,%ebx
  80094a:	89 d6                	mov    %edx,%esi
  80094c:	c1 e6 18             	shl    $0x18,%esi
  80094f:	89 d0                	mov    %edx,%eax
  800951:	c1 e0 10             	shl    $0x10,%eax
  800954:	09 f0                	or     %esi,%eax
  800956:	09 d0                	or     %edx,%eax
  800958:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80095d:	fc                   	cld    
  80095e:	f3 ab                	rep stos %eax,%es:(%edi)
  800960:	eb 03                	jmp    800965 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800962:	fc                   	cld    
  800963:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800965:	89 f8                	mov    %edi,%eax
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 75 0c             	mov    0xc(%ebp),%esi
  800977:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097a:	39 c6                	cmp    %eax,%esi
  80097c:	73 34                	jae    8009b2 <memmove+0x46>
  80097e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800981:	39 d0                	cmp    %edx,%eax
  800983:	73 2d                	jae    8009b2 <memmove+0x46>
		s += n;
		d += n;
  800985:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 1b                	jne    8009a8 <memmove+0x3c>
  80098d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800993:	75 13                	jne    8009a8 <memmove+0x3c>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 0e                	jne    8009a8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099a:	83 ef 04             	sub    $0x4,%edi
  80099d:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a3:	fd                   	std    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 07                	jmp    8009af <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a8:	4f                   	dec    %edi
  8009a9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ac:	fd                   	std    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009af:	fc                   	cld    
  8009b0:	eb 20                	jmp    8009d2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b8:	75 13                	jne    8009cd <memmove+0x61>
  8009ba:	a8 03                	test   $0x3,%al
  8009bc:	75 0f                	jne    8009cd <memmove+0x61>
  8009be:	f6 c1 03             	test   $0x3,%cl
  8009c1:	75 0a                	jne    8009cd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 05                	jmp    8009d2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	89 04 24             	mov    %eax,(%esp)
  8009f0:	e8 77 ff ff ff       	call   80096c <memmove>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a06:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0b:	eb 16                	jmp    800a23 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a10:	42                   	inc    %edx
  800a11:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a15:	38 c8                	cmp    %cl,%al
  800a17:	74 0a                	je     800a23 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a19:	0f b6 c0             	movzbl %al,%eax
  800a1c:	0f b6 c9             	movzbl %cl,%ecx
  800a1f:	29 c8                	sub    %ecx,%eax
  800a21:	eb 09                	jmp    800a2c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a23:	39 da                	cmp    %ebx,%edx
  800a25:	75 e6                	jne    800a0d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3f:	eb 05                	jmp    800a46 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a41:	38 08                	cmp    %cl,(%eax)
  800a43:	74 05                	je     800a4a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a45:	40                   	inc    %eax
  800a46:	39 d0                	cmp    %edx,%eax
  800a48:	72 f7                	jb     800a41 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a58:	eb 01                	jmp    800a5b <strtol+0xf>
		s++;
  800a5a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5b:	8a 02                	mov    (%edx),%al
  800a5d:	3c 20                	cmp    $0x20,%al
  800a5f:	74 f9                	je     800a5a <strtol+0xe>
  800a61:	3c 09                	cmp    $0x9,%al
  800a63:	74 f5                	je     800a5a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a65:	3c 2b                	cmp    $0x2b,%al
  800a67:	75 08                	jne    800a71 <strtol+0x25>
		s++;
  800a69:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6f:	eb 13                	jmp    800a84 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a71:	3c 2d                	cmp    $0x2d,%al
  800a73:	75 0a                	jne    800a7f <strtol+0x33>
		s++, neg = 1;
  800a75:	8d 52 01             	lea    0x1(%edx),%edx
  800a78:	bf 01 00 00 00       	mov    $0x1,%edi
  800a7d:	eb 05                	jmp    800a84 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	74 05                	je     800a8d <strtol+0x41>
  800a88:	83 fb 10             	cmp    $0x10,%ebx
  800a8b:	75 28                	jne    800ab5 <strtol+0x69>
  800a8d:	8a 02                	mov    (%edx),%al
  800a8f:	3c 30                	cmp    $0x30,%al
  800a91:	75 10                	jne    800aa3 <strtol+0x57>
  800a93:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a97:	75 0a                	jne    800aa3 <strtol+0x57>
		s += 2, base = 16;
  800a99:	83 c2 02             	add    $0x2,%edx
  800a9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa1:	eb 12                	jmp    800ab5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	75 0e                	jne    800ab5 <strtol+0x69>
  800aa7:	3c 30                	cmp    $0x30,%al
  800aa9:	75 05                	jne    800ab0 <strtol+0x64>
		s++, base = 8;
  800aab:	42                   	inc    %edx
  800aac:	b3 08                	mov    $0x8,%bl
  800aae:	eb 05                	jmp    800ab5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abc:	8a 0a                	mov    (%edx),%cl
  800abe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac1:	80 fb 09             	cmp    $0x9,%bl
  800ac4:	77 08                	ja     800ace <strtol+0x82>
			dig = *s - '0';
  800ac6:	0f be c9             	movsbl %cl,%ecx
  800ac9:	83 e9 30             	sub    $0x30,%ecx
  800acc:	eb 1e                	jmp    800aec <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ace:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 57             	sub    $0x57,%ecx
  800adc:	eb 0e                	jmp    800aec <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 12                	ja     800af8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aec:	39 f1                	cmp    %esi,%ecx
  800aee:	7d 0c                	jge    800afc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af0:	42                   	inc    %edx
  800af1:	0f af c6             	imul   %esi,%eax
  800af4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af6:	eb c4                	jmp    800abc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	89 c1                	mov    %eax,%ecx
  800afa:	eb 02                	jmp    800afe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b02:	74 05                	je     800b09 <strtol+0xbd>
		*endptr = (char *) s;
  800b04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b07:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b09:	85 ff                	test   %edi,%edi
  800b0b:	74 04                	je     800b11 <strtol+0xc5>
  800b0d:	89 c8                	mov    %ecx,%eax
  800b0f:	f7 d8                	neg    %eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
	...

00800b18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	89 c3                	mov    %eax,%ebx
  800b2b:	89 c7                	mov    %eax,%edi
  800b2d:	89 c6                	mov    %eax,%esi
  800b2f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 01 00 00 00       	mov    $0x1,%eax
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	89 d7                	mov    %edx,%edi
  800b4c:	89 d6                	mov    %edx,%esi
  800b4e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b63:	b8 03 00 00 00       	mov    $0x3,%eax
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	89 cb                	mov    %ecx,%ebx
  800b6d:	89 cf                	mov    %ecx,%edi
  800b6f:	89 ce                	mov    %ecx,%esi
  800b71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	7e 28                	jle    800b9f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b82:	00 
  800b83:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800b8a:	00 
  800b8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b92:	00 
  800b93:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800b9a:	e8 51 13 00 00       	call   801ef0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9f:	83 c4 2c             	add    $0x2c,%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_yield>:

void
sys_yield(void)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd6:	89 d1                	mov    %edx,%ecx
  800bd8:	89 d3                	mov    %edx,%ebx
  800bda:	89 d7                	mov    %edx,%edi
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	be 00 00 00 00       	mov    $0x0,%esi
  800bf3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 f7                	mov    %esi,%edi
  800c03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7e 28                	jle    800c31 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c14:	00 
  800c15:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800c1c:	00 
  800c1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c24:	00 
  800c25:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800c2c:	e8 bf 12 00 00       	call   801ef0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c31:	83 c4 2c             	add    $0x2c,%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 28                	jle    800c84 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c60:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c67:	00 
  800c68:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800c6f:	00 
  800c70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c77:	00 
  800c78:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800c7f:	e8 6c 12 00 00       	call   801ef0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c84:	83 c4 2c             	add    $0x2c,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 28                	jle    800cd7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cba:	00 
  800cbb:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cca:	00 
  800ccb:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800cd2:	e8 19 12 00 00       	call   801ef0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd7:	83 c4 2c             	add    $0x2c,%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 28                	jle    800d2a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d06:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800d15:	00 
  800d16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1d:	00 
  800d1e:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800d25:	e8 c6 11 00 00       	call   801ef0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2a:	83 c4 2c             	add    $0x2c,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d40:	b8 09 00 00 00       	mov    $0x9,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 df                	mov    %ebx,%edi
  800d4d:	89 de                	mov    %ebx,%esi
  800d4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 28                	jle    800d7d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d59:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d60:	00 
  800d61:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800d68:	00 
  800d69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d70:	00 
  800d71:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800d78:	e8 73 11 00 00       	call   801ef0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7d:	83 c4 2c             	add    $0x2c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7e 28                	jle    800dd0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dac:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800db3:	00 
  800db4:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc3:	00 
  800dc4:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800dcb:	e8 20 11 00 00       	call   801ef0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd0:	83 c4 2c             	add    $0x2c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dde:	be 00 00 00 00       	mov    $0x0,%esi
  800de3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 cb                	mov    %ecx,%ebx
  800e13:	89 cf                	mov    %ecx,%edi
  800e15:	89 ce                	mov    %ecx,%esi
  800e17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800e40:	e8 ab 10 00 00       	call   801ef0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e45:	83 c4 2c             	add    $0x2c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    
  800e4d:	00 00                	add    %al,(%eax)
	...

00800e50 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e5c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e5e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e61:	83 3a 01             	cmpl   $0x1,(%edx)
  800e64:	7e 0b                	jle    800e71 <argstart+0x21>
  800e66:	85 c9                	test   %ecx,%ecx
  800e68:	75 0e                	jne    800e78 <argstart+0x28>
  800e6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6f:	eb 0c                	jmp    800e7d <argstart+0x2d>
  800e71:	ba 00 00 00 00       	mov    $0x0,%edx
  800e76:	eb 05                	jmp    800e7d <argstart+0x2d>
  800e78:	ba 8d 27 80 00       	mov    $0x80278d,%edx
  800e7d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e80:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <argnext>:

int
argnext(struct Argstate *args)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 14             	sub    $0x14,%esp
  800e90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e93:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e9a:	8b 43 08             	mov    0x8(%ebx),%eax
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	74 6c                	je     800f0d <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  800ea1:	80 38 00             	cmpb   $0x0,(%eax)
  800ea4:	75 4d                	jne    800ef3 <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800ea6:	8b 0b                	mov    (%ebx),%ecx
  800ea8:	83 39 01             	cmpl   $0x1,(%ecx)
  800eab:	74 52                	je     800eff <argnext+0x76>
		    || args->argv[1][0] != '-'
  800ead:	8b 53 04             	mov    0x4(%ebx),%edx
  800eb0:	8b 42 04             	mov    0x4(%edx),%eax
  800eb3:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eb6:	75 47                	jne    800eff <argnext+0x76>
		    || args->argv[1][1] == '\0')
  800eb8:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ebc:	74 41                	je     800eff <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800ebe:	40                   	inc    %eax
  800ebf:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ec2:	8b 01                	mov    (%ecx),%eax
  800ec4:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ecb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ecf:	8d 42 08             	lea    0x8(%edx),%eax
  800ed2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed6:	83 c2 04             	add    $0x4,%edx
  800ed9:	89 14 24             	mov    %edx,(%esp)
  800edc:	e8 8b fa ff ff       	call   80096c <memmove>
		(*args->argc)--;
  800ee1:	8b 03                	mov    (%ebx),%eax
  800ee3:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ee5:	8b 43 08             	mov    0x8(%ebx),%eax
  800ee8:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eeb:	75 06                	jne    800ef3 <argnext+0x6a>
  800eed:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ef1:	74 0c                	je     800eff <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ef3:	8b 53 08             	mov    0x8(%ebx),%edx
  800ef6:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800ef9:	42                   	inc    %edx
  800efa:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800efd:	eb 13                	jmp    800f12 <argnext+0x89>

    endofargs:
	args->curarg = 0;
  800eff:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f0b:	eb 05                	jmp    800f12 <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f12:	83 c4 14             	add    $0x14,%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 14             	sub    $0x14,%esp
  800f1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f22:	8b 43 08             	mov    0x8(%ebx),%eax
  800f25:	85 c0                	test   %eax,%eax
  800f27:	74 59                	je     800f82 <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  800f29:	80 38 00             	cmpb   $0x0,(%eax)
  800f2c:	74 0c                	je     800f3a <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f2e:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f31:	c7 43 08 8d 27 80 00 	movl   $0x80278d,0x8(%ebx)
  800f38:	eb 43                	jmp    800f7d <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  800f3a:	8b 03                	mov    (%ebx),%eax
  800f3c:	83 38 01             	cmpl   $0x1,(%eax)
  800f3f:	7e 2e                	jle    800f6f <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  800f41:	8b 53 04             	mov    0x4(%ebx),%edx
  800f44:	8b 4a 04             	mov    0x4(%edx),%ecx
  800f47:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f4a:	8b 00                	mov    (%eax),%eax
  800f4c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f53:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f57:	8d 42 08             	lea    0x8(%edx),%eax
  800f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5e:	83 c2 04             	add    $0x4,%edx
  800f61:	89 14 24             	mov    %edx,(%esp)
  800f64:	e8 03 fa ff ff       	call   80096c <memmove>
		(*args->argc)--;
  800f69:	8b 03                	mov    (%ebx),%eax
  800f6b:	ff 08                	decl   (%eax)
  800f6d:	eb 0e                	jmp    800f7d <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  800f6f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f76:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f7d:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f80:	eb 05                	jmp    800f87 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f87:	83 c4 14             	add    $0x14,%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 18             	sub    $0x18,%esp
  800f93:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f96:	8b 42 0c             	mov    0xc(%edx),%eax
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	75 08                	jne    800fa5 <argvalue+0x18>
  800f9d:	89 14 24             	mov    %edx,(%esp)
  800fa0:	e8 73 ff ff ff       	call   800f18 <argnextvalue>
}
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    
	...

00800fa8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	05 00 00 00 30       	add    $0x30000000,%eax
  800fb3:	c1 e8 0c             	shr    $0xc,%eax
}
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc1:	89 04 24             	mov    %eax,(%esp)
  800fc4:	e8 df ff ff ff       	call   800fa8 <fd2num>
  800fc9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800fce:	c1 e0 0c             	shl    $0xc,%eax
}
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	53                   	push   %ebx
  800fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fda:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fdf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	c1 ea 16             	shr    $0x16,%edx
  800fe6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fed:	f6 c2 01             	test   $0x1,%dl
  800ff0:	74 11                	je     801003 <fd_alloc+0x30>
  800ff2:	89 c2                	mov    %eax,%edx
  800ff4:	c1 ea 0c             	shr    $0xc,%edx
  800ff7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ffe:	f6 c2 01             	test   $0x1,%dl
  801001:	75 09                	jne    80100c <fd_alloc+0x39>
			*fd_store = fd;
  801003:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	eb 17                	jmp    801023 <fd_alloc+0x50>
  80100c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801011:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801016:	75 c7                	jne    800fdf <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801018:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80101e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801023:	5b                   	pop    %ebx
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80102c:	83 f8 1f             	cmp    $0x1f,%eax
  80102f:	77 36                	ja     801067 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801031:	05 00 00 0d 00       	add    $0xd0000,%eax
  801036:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801039:	89 c2                	mov    %eax,%edx
  80103b:	c1 ea 16             	shr    $0x16,%edx
  80103e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801045:	f6 c2 01             	test   $0x1,%dl
  801048:	74 24                	je     80106e <fd_lookup+0x48>
  80104a:	89 c2                	mov    %eax,%edx
  80104c:	c1 ea 0c             	shr    $0xc,%edx
  80104f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801056:	f6 c2 01             	test   $0x1,%dl
  801059:	74 1a                	je     801075 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80105b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105e:	89 02                	mov    %eax,(%edx)
	return 0;
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
  801065:	eb 13                	jmp    80107a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801067:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80106c:	eb 0c                	jmp    80107a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80106e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801073:	eb 05                	jmp    80107a <fd_lookup+0x54>
  801075:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	53                   	push   %ebx
  801080:	83 ec 14             	sub    $0x14,%esp
  801083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801086:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801089:	ba 00 00 00 00       	mov    $0x0,%edx
  80108e:	eb 0e                	jmp    80109e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801090:	39 08                	cmp    %ecx,(%eax)
  801092:	75 09                	jne    80109d <dev_lookup+0x21>
			*dev = devtab[i];
  801094:	89 03                	mov    %eax,(%ebx)
			return 0;
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
  80109b:	eb 35                	jmp    8010d2 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80109d:	42                   	inc    %edx
  80109e:	8b 04 95 e8 26 80 00 	mov    0x8026e8(,%edx,4),%eax
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	75 e7                	jne    801090 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ae:	8b 00                	mov    (%eax),%eax
  8010b0:	8b 40 48             	mov    0x48(%eax),%eax
  8010b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bb:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  8010c2:	e8 81 f1 ff ff       	call   800248 <cprintf>
	*dev = 0;
  8010c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010d2:	83 c4 14             	add    $0x14,%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 30             	sub    $0x30,%esp
  8010e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e3:	8a 45 0c             	mov    0xc(%ebp),%al
  8010e6:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010e9:	89 34 24             	mov    %esi,(%esp)
  8010ec:	e8 b7 fe ff ff       	call   800fa8 <fd2num>
  8010f1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010f8:	89 04 24             	mov    %eax,(%esp)
  8010fb:	e8 26 ff ff ff       	call   801026 <fd_lookup>
  801100:	89 c3                	mov    %eax,%ebx
  801102:	85 c0                	test   %eax,%eax
  801104:	78 05                	js     80110b <fd_close+0x33>
	    || fd != fd2)
  801106:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801109:	74 0d                	je     801118 <fd_close+0x40>
		return (must_exist ? r : 0);
  80110b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80110f:	75 46                	jne    801157 <fd_close+0x7f>
  801111:	bb 00 00 00 00       	mov    $0x0,%ebx
  801116:	eb 3f                	jmp    801157 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801118:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111f:	8b 06                	mov    (%esi),%eax
  801121:	89 04 24             	mov    %eax,(%esp)
  801124:	e8 53 ff ff ff       	call   80107c <dev_lookup>
  801129:	89 c3                	mov    %eax,%ebx
  80112b:	85 c0                	test   %eax,%eax
  80112d:	78 18                	js     801147 <fd_close+0x6f>
		if (dev->dev_close)
  80112f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801132:	8b 40 10             	mov    0x10(%eax),%eax
  801135:	85 c0                	test   %eax,%eax
  801137:	74 09                	je     801142 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801139:	89 34 24             	mov    %esi,(%esp)
  80113c:	ff d0                	call   *%eax
  80113e:	89 c3                	mov    %eax,%ebx
  801140:	eb 05                	jmp    801147 <fd_close+0x6f>
		else
			r = 0;
  801142:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801147:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801152:	e8 35 fb ff ff       	call   800c8c <sys_page_unmap>
	return r;
}
  801157:	89 d8                	mov    %ebx,%eax
  801159:	83 c4 30             	add    $0x30,%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801166:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116d:	8b 45 08             	mov    0x8(%ebp),%eax
  801170:	89 04 24             	mov    %eax,(%esp)
  801173:	e8 ae fe ff ff       	call   801026 <fd_lookup>
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 13                	js     80118f <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80117c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801183:	00 
  801184:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801187:	89 04 24             	mov    %eax,(%esp)
  80118a:	e8 49 ff ff ff       	call   8010d8 <fd_close>
}
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <close_all>:

void
close_all(void)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	53                   	push   %ebx
  801195:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801198:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80119d:	89 1c 24             	mov    %ebx,(%esp)
  8011a0:	e8 bb ff ff ff       	call   801160 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011a5:	43                   	inc    %ebx
  8011a6:	83 fb 20             	cmp    $0x20,%ebx
  8011a9:	75 f2                	jne    80119d <close_all+0xc>
		close(i);
}
  8011ab:	83 c4 14             	add    $0x14,%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	57                   	push   %edi
  8011b5:	56                   	push   %esi
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 4c             	sub    $0x4c,%esp
  8011ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	e8 57 fe ff ff       	call   801026 <fd_lookup>
  8011cf:	89 c3                	mov    %eax,%ebx
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	0f 88 e1 00 00 00    	js     8012ba <dup+0x109>
		return r;
	close(newfdnum);
  8011d9:	89 3c 24             	mov    %edi,(%esp)
  8011dc:	e8 7f ff ff ff       	call   801160 <close>

	newfd = INDEX2FD(newfdnum);
  8011e1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8011e7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8011ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ed:	89 04 24             	mov    %eax,(%esp)
  8011f0:	e8 c3 fd ff ff       	call   800fb8 <fd2data>
  8011f5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011f7:	89 34 24             	mov    %esi,(%esp)
  8011fa:	e8 b9 fd ff ff       	call   800fb8 <fd2data>
  8011ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801202:	89 d8                	mov    %ebx,%eax
  801204:	c1 e8 16             	shr    $0x16,%eax
  801207:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80120e:	a8 01                	test   $0x1,%al
  801210:	74 46                	je     801258 <dup+0xa7>
  801212:	89 d8                	mov    %ebx,%eax
  801214:	c1 e8 0c             	shr    $0xc,%eax
  801217:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80121e:	f6 c2 01             	test   $0x1,%dl
  801221:	74 35                	je     801258 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801223:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80122a:	25 07 0e 00 00       	and    $0xe07,%eax
  80122f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801233:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801236:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801241:	00 
  801242:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801246:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124d:	e8 e7 f9 ff ff       	call   800c39 <sys_page_map>
  801252:	89 c3                	mov    %eax,%ebx
  801254:	85 c0                	test   %eax,%eax
  801256:	78 3b                	js     801293 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801267:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80126d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801271:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801275:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80127c:	00 
  80127d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801281:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801288:	e8 ac f9 ff ff       	call   800c39 <sys_page_map>
  80128d:	89 c3                	mov    %eax,%ebx
  80128f:	85 c0                	test   %eax,%eax
  801291:	79 25                	jns    8012b8 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801293:	89 74 24 04          	mov    %esi,0x4(%esp)
  801297:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129e:	e8 e9 f9 ff ff       	call   800c8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b1:	e8 d6 f9 ff ff       	call   800c8c <sys_page_unmap>
	return r;
  8012b6:	eb 02                	jmp    8012ba <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012b8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012ba:	89 d8                	mov    %ebx,%eax
  8012bc:	83 c4 4c             	add    $0x4c,%esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 24             	sub    $0x24,%esp
  8012cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d5:	89 1c 24             	mov    %ebx,(%esp)
  8012d8:	e8 49 fd ff ff       	call   801026 <fd_lookup>
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 6f                	js     801350 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012eb:	8b 00                	mov    (%eax),%eax
  8012ed:	89 04 24             	mov    %eax,(%esp)
  8012f0:	e8 87 fd ff ff       	call   80107c <dev_lookup>
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 57                	js     801350 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fc:	8b 50 08             	mov    0x8(%eax),%edx
  8012ff:	83 e2 03             	and    $0x3,%edx
  801302:	83 fa 01             	cmp    $0x1,%edx
  801305:	75 25                	jne    80132c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801307:	a1 04 40 80 00       	mov    0x804004,%eax
  80130c:	8b 00                	mov    (%eax),%eax
  80130e:	8b 40 48             	mov    0x48(%eax),%eax
  801311:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	c7 04 24 ad 26 80 00 	movl   $0x8026ad,(%esp)
  801320:	e8 23 ef ff ff       	call   800248 <cprintf>
		return -E_INVAL;
  801325:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132a:	eb 24                	jmp    801350 <read+0x8c>
	}
	if (!dev->dev_read)
  80132c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132f:	8b 52 08             	mov    0x8(%edx),%edx
  801332:	85 d2                	test   %edx,%edx
  801334:	74 15                	je     80134b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801336:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801340:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801344:	89 04 24             	mov    %eax,(%esp)
  801347:	ff d2                	call   *%edx
  801349:	eb 05                	jmp    801350 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80134b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801350:	83 c4 24             	add    $0x24,%esp
  801353:	5b                   	pop    %ebx
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	57                   	push   %edi
  80135a:	56                   	push   %esi
  80135b:	53                   	push   %ebx
  80135c:	83 ec 1c             	sub    $0x1c,%esp
  80135f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801362:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801365:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136a:	eb 23                	jmp    80138f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80136c:	89 f0                	mov    %esi,%eax
  80136e:	29 d8                	sub    %ebx,%eax
  801370:	89 44 24 08          	mov    %eax,0x8(%esp)
  801374:	8b 45 0c             	mov    0xc(%ebp),%eax
  801377:	01 d8                	add    %ebx,%eax
  801379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137d:	89 3c 24             	mov    %edi,(%esp)
  801380:	e8 3f ff ff ff       	call   8012c4 <read>
		if (m < 0)
  801385:	85 c0                	test   %eax,%eax
  801387:	78 10                	js     801399 <readn+0x43>
			return m;
		if (m == 0)
  801389:	85 c0                	test   %eax,%eax
  80138b:	74 0a                	je     801397 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138d:	01 c3                	add    %eax,%ebx
  80138f:	39 f3                	cmp    %esi,%ebx
  801391:	72 d9                	jb     80136c <readn+0x16>
  801393:	89 d8                	mov    %ebx,%eax
  801395:	eb 02                	jmp    801399 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801397:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801399:	83 c4 1c             	add    $0x1c,%esp
  80139c:	5b                   	pop    %ebx
  80139d:	5e                   	pop    %esi
  80139e:	5f                   	pop    %edi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 24             	sub    $0x24,%esp
  8013a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b2:	89 1c 24             	mov    %ebx,(%esp)
  8013b5:	e8 6c fc ff ff       	call   801026 <fd_lookup>
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 6a                	js     801428 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c8:	8b 00                	mov    (%eax),%eax
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	e8 aa fc ff ff       	call   80107c <dev_lookup>
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 52                	js     801428 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013dd:	75 25                	jne    801404 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013df:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e4:	8b 00                	mov    (%eax),%eax
  8013e6:	8b 40 48             	mov    0x48(%eax),%eax
  8013e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f1:	c7 04 24 c9 26 80 00 	movl   $0x8026c9,(%esp)
  8013f8:	e8 4b ee ff ff       	call   800248 <cprintf>
		return -E_INVAL;
  8013fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801402:	eb 24                	jmp    801428 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801404:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801407:	8b 52 0c             	mov    0xc(%edx),%edx
  80140a:	85 d2                	test   %edx,%edx
  80140c:	74 15                	je     801423 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80140e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801411:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801415:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801418:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80141c:	89 04 24             	mov    %eax,(%esp)
  80141f:	ff d2                	call   *%edx
  801421:	eb 05                	jmp    801428 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801423:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801428:	83 c4 24             	add    $0x24,%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <seek>:

int
seek(int fdnum, off_t offset)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801434:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	89 04 24             	mov    %eax,(%esp)
  801441:	e8 e0 fb ff ff       	call   801026 <fd_lookup>
  801446:	85 c0                	test   %eax,%eax
  801448:	78 0e                	js     801458 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80144a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80144d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801450:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 24             	sub    $0x24,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	89 1c 24             	mov    %ebx,(%esp)
  80146e:	e8 b3 fb ff ff       	call   801026 <fd_lookup>
  801473:	85 c0                	test   %eax,%eax
  801475:	78 63                	js     8014da <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801481:	8b 00                	mov    (%eax),%eax
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	e8 f1 fb ff ff       	call   80107c <dev_lookup>
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 4b                	js     8014da <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801496:	75 25                	jne    8014bd <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801498:	a1 04 40 80 00       	mov    0x804004,%eax
  80149d:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80149f:	8b 40 48             	mov    0x48(%eax),%eax
  8014a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014aa:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8014b1:	e8 92 ed ff ff       	call   800248 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014bb:	eb 1d                	jmp    8014da <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8014bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c0:	8b 52 18             	mov    0x18(%edx),%edx
  8014c3:	85 d2                	test   %edx,%edx
  8014c5:	74 0e                	je     8014d5 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ce:	89 04 24             	mov    %eax,(%esp)
  8014d1:	ff d2                	call   *%edx
  8014d3:	eb 05                	jmp    8014da <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014da:	83 c4 24             	add    $0x24,%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 24             	sub    $0x24,%esp
  8014e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f4:	89 04 24             	mov    %eax,(%esp)
  8014f7:	e8 2a fb ff ff       	call   801026 <fd_lookup>
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 52                	js     801552 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801500:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801503:	89 44 24 04          	mov    %eax,0x4(%esp)
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	8b 00                	mov    (%eax),%eax
  80150c:	89 04 24             	mov    %eax,(%esp)
  80150f:	e8 68 fb ff ff       	call   80107c <dev_lookup>
  801514:	85 c0                	test   %eax,%eax
  801516:	78 3a                	js     801552 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80151f:	74 2c                	je     80154d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801521:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801524:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80152b:	00 00 00 
	stat->st_isdir = 0;
  80152e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801535:	00 00 00 
	stat->st_dev = dev;
  801538:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80153e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801542:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801545:	89 14 24             	mov    %edx,(%esp)
  801548:	ff 50 14             	call   *0x14(%eax)
  80154b:	eb 05                	jmp    801552 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80154d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801552:	83 c4 24             	add    $0x24,%esp
  801555:	5b                   	pop    %ebx
  801556:	5d                   	pop    %ebp
  801557:	c3                   	ret    

00801558 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801560:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801567:	00 
  801568:	8b 45 08             	mov    0x8(%ebp),%eax
  80156b:	89 04 24             	mov    %eax,(%esp)
  80156e:	e8 88 02 00 00       	call   8017fb <open>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	85 c0                	test   %eax,%eax
  801577:	78 1b                	js     801594 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801579:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801580:	89 1c 24             	mov    %ebx,(%esp)
  801583:	e8 58 ff ff ff       	call   8014e0 <fstat>
  801588:	89 c6                	mov    %eax,%esi
	close(fd);
  80158a:	89 1c 24             	mov    %ebx,(%esp)
  80158d:	e8 ce fb ff ff       	call   801160 <close>
	return r;
  801592:	89 f3                	mov    %esi,%ebx
}
  801594:	89 d8                	mov    %ebx,%eax
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	5b                   	pop    %ebx
  80159a:	5e                   	pop    %esi
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    
  80159d:	00 00                	add    %al,(%eax)
	...

008015a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 10             	sub    $0x10,%esp
  8015a8:	89 c3                	mov    %eax,%ebx
  8015aa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015ac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015b3:	75 11                	jne    8015c6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015bc:	e8 5a 0a 00 00       	call   80201b <ipc_find_env>
  8015c1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015c6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015cd:	00 
  8015ce:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015d5:	00 
  8015d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015da:	a1 00 40 80 00       	mov    0x804000,%eax
  8015df:	89 04 24             	mov    %eax,(%esp)
  8015e2:	e8 ce 09 00 00       	call   801fb5 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8015e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ee:	00 
  8015ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fa:	e8 49 09 00 00       	call   801f48 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80160c:	8b 45 08             	mov    0x8(%ebp),%eax
  80160f:	8b 40 0c             	mov    0xc(%eax),%eax
  801612:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801617:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	b8 02 00 00 00       	mov    $0x2,%eax
  801629:	e8 72 ff ff ff       	call   8015a0 <fsipc>
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801636:	8b 45 08             	mov    0x8(%ebp),%eax
  801639:	8b 40 0c             	mov    0xc(%eax),%eax
  80163c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801641:	ba 00 00 00 00       	mov    $0x0,%edx
  801646:	b8 06 00 00 00       	mov    $0x6,%eax
  80164b:	e8 50 ff ff ff       	call   8015a0 <fsipc>
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 14             	sub    $0x14,%esp
  801659:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80165c:	8b 45 08             	mov    0x8(%ebp),%eax
  80165f:	8b 40 0c             	mov    0xc(%eax),%eax
  801662:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
  80166c:	b8 05 00 00 00       	mov    $0x5,%eax
  801671:	e8 2a ff ff ff       	call   8015a0 <fsipc>
  801676:	85 c0                	test   %eax,%eax
  801678:	78 2b                	js     8016a5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80167a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801681:	00 
  801682:	89 1c 24             	mov    %ebx,(%esp)
  801685:	e8 69 f1 ff ff       	call   8007f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80168a:	a1 80 50 80 00       	mov    0x805080,%eax
  80168f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801695:	a1 84 50 80 00       	mov    0x805084,%eax
  80169a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a5:	83 c4 14             	add    $0x14,%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 14             	sub    $0x14,%esp
  8016b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8016c8:	76 05                	jbe    8016cf <devfile_write+0x24>
  8016ca:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8016cf:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  8016d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016df:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8016e6:	e8 eb f2 ff ff       	call   8009d6 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  8016eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8016f5:	e8 a6 fe ff ff       	call   8015a0 <fsipc>
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 53                	js     801751 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  8016fe:	39 c3                	cmp    %eax,%ebx
  801700:	73 24                	jae    801726 <devfile_write+0x7b>
  801702:	c7 44 24 0c f8 26 80 	movl   $0x8026f8,0xc(%esp)
  801709:	00 
  80170a:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  801711:	00 
  801712:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801719:	00 
  80171a:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  801721:	e8 ca 07 00 00       	call   801ef0 <_panic>
	assert(r <= PGSIZE);
  801726:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80172b:	7e 24                	jle    801751 <devfile_write+0xa6>
  80172d:	c7 44 24 0c 1f 27 80 	movl   $0x80271f,0xc(%esp)
  801734:	00 
  801735:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  80173c:	00 
  80173d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801744:	00 
  801745:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  80174c:	e8 9f 07 00 00       	call   801ef0 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801751:	83 c4 14             	add    $0x14,%esp
  801754:	5b                   	pop    %ebx
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
  80175c:	83 ec 10             	sub    $0x10,%esp
  80175f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80176d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 03 00 00 00       	mov    $0x3,%eax
  80177d:	e8 1e fe ff ff       	call   8015a0 <fsipc>
  801782:	89 c3                	mov    %eax,%ebx
  801784:	85 c0                	test   %eax,%eax
  801786:	78 6a                	js     8017f2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801788:	39 c6                	cmp    %eax,%esi
  80178a:	73 24                	jae    8017b0 <devfile_read+0x59>
  80178c:	c7 44 24 0c f8 26 80 	movl   $0x8026f8,0xc(%esp)
  801793:	00 
  801794:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  80179b:	00 
  80179c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8017a3:	00 
  8017a4:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  8017ab:	e8 40 07 00 00       	call   801ef0 <_panic>
	assert(r <= PGSIZE);
  8017b0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b5:	7e 24                	jle    8017db <devfile_read+0x84>
  8017b7:	c7 44 24 0c 1f 27 80 	movl   $0x80271f,0xc(%esp)
  8017be:	00 
  8017bf:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  8017c6:	00 
  8017c7:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8017ce:	00 
  8017cf:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  8017d6:	e8 15 07 00 00       	call   801ef0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017df:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017e6:	00 
  8017e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ea:	89 04 24             	mov    %eax,(%esp)
  8017ed:	e8 7a f1 ff ff       	call   80096c <memmove>
	return r;
}
  8017f2:	89 d8                	mov    %ebx,%eax
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5e                   	pop    %esi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	83 ec 20             	sub    $0x20,%esp
  801803:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801806:	89 34 24             	mov    %esi,(%esp)
  801809:	e8 b2 ef ff ff       	call   8007c0 <strlen>
  80180e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801813:	7f 60                	jg     801875 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	e8 b3 f7 ff ff       	call   800fd3 <fd_alloc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	85 c0                	test   %eax,%eax
  801824:	78 54                	js     80187a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801831:	e8 bd ef ff ff       	call   8007f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80183e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801841:	b8 01 00 00 00       	mov    $0x1,%eax
  801846:	e8 55 fd ff ff       	call   8015a0 <fsipc>
  80184b:	89 c3                	mov    %eax,%ebx
  80184d:	85 c0                	test   %eax,%eax
  80184f:	79 15                	jns    801866 <open+0x6b>
		fd_close(fd, 0);
  801851:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801858:	00 
  801859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185c:	89 04 24             	mov    %eax,(%esp)
  80185f:	e8 74 f8 ff ff       	call   8010d8 <fd_close>
		return r;
  801864:	eb 14                	jmp    80187a <open+0x7f>
	}

	return fd2num(fd);
  801866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801869:	89 04 24             	mov    %eax,(%esp)
  80186c:	e8 37 f7 ff ff       	call   800fa8 <fd2num>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	eb 05                	jmp    80187a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801875:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	83 c4 20             	add    $0x20,%esp
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801889:	ba 00 00 00 00       	mov    $0x0,%edx
  80188e:	b8 08 00 00 00       	mov    $0x8,%eax
  801893:	e8 08 fd ff ff       	call   8015a0 <fsipc>
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    
	...

0080189c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	53                   	push   %ebx
  8018a0:	83 ec 14             	sub    $0x14,%esp
  8018a3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8018a5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018a9:	7e 32                	jle    8018dd <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018ab:	8b 40 04             	mov    0x4(%eax),%eax
  8018ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b2:	8d 43 10             	lea    0x10(%ebx),%eax
  8018b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b9:	8b 03                	mov    (%ebx),%eax
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 de fa ff ff       	call   8013a1 <write>
		if (result > 0)
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	7e 03                	jle    8018ca <writebuf+0x2e>
			b->result += result;
  8018c7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018ca:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018cd:	74 0e                	je     8018dd <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8018cf:	89 c2                	mov    %eax,%edx
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	7e 05                	jle    8018da <writebuf+0x3e>
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8018dd:	83 c4 14             	add    $0x14,%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <putch>:

static void
putch(int ch, void *thunk)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	53                   	push   %ebx
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018ed:	8b 43 04             	mov    0x4(%ebx),%eax
  8018f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f3:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8018f7:	40                   	inc    %eax
  8018f8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8018fb:	3d 00 01 00 00       	cmp    $0x100,%eax
  801900:	75 0e                	jne    801910 <putch+0x2d>
		writebuf(b);
  801902:	89 d8                	mov    %ebx,%eax
  801904:	e8 93 ff ff ff       	call   80189c <writebuf>
		b->idx = 0;
  801909:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801910:	83 c4 04             	add    $0x4,%esp
  801913:	5b                   	pop    %ebx
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801928:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80192f:	00 00 00 
	b.result = 0;
  801932:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801939:	00 00 00 
	b.error = 1;
  80193c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801943:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801946:	8b 45 10             	mov    0x10(%ebp),%eax
  801949:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80194d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801950:	89 44 24 08          	mov    %eax,0x8(%esp)
  801954:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80195a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195e:	c7 04 24 e3 18 80 00 	movl   $0x8018e3,(%esp)
  801965:	e8 40 ea ff ff       	call   8003aa <vprintfmt>
	if (b.idx > 0)
  80196a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801971:	7e 0b                	jle    80197e <vfprintf+0x68>
		writebuf(&b);
  801973:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801979:	e8 1e ff ff ff       	call   80189c <writebuf>

	return (b.result ? b.result : b.error);
  80197e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801984:	85 c0                	test   %eax,%eax
  801986:	75 06                	jne    80198e <vfprintf+0x78>
  801988:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801996:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801999:	89 44 24 08          	mov    %eax,0x8(%esp)
  80199d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a7:	89 04 24             	mov    %eax,(%esp)
  8019aa:	e8 67 ff ff ff       	call   801916 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <printf>:

int
printf(const char *fmt, ...)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019cc:	e8 45 ff ff ff       	call   801916 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    
	...

008019d4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 10             	sub    $0x10,%esp
  8019dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	89 04 24             	mov    %eax,(%esp)
  8019e5:	e8 ce f5 ff ff       	call   800fb8 <fd2data>
  8019ea:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019ec:	c7 44 24 04 2b 27 80 	movl   $0x80272b,0x4(%esp)
  8019f3:	00 
  8019f4:	89 34 24             	mov    %esi,(%esp)
  8019f7:	e8 f7 ed ff ff       	call   8007f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ff:	2b 03                	sub    (%ebx),%eax
  801a01:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a07:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a0e:	00 00 00 
	stat->st_dev = &devpipe;
  801a11:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a18:	30 80 00 
	return 0;
}
  801a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	5b                   	pop    %ebx
  801a24:	5e                   	pop    %esi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	53                   	push   %ebx
  801a2b:	83 ec 14             	sub    $0x14,%esp
  801a2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3c:	e8 4b f2 ff ff       	call   800c8c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a41:	89 1c 24             	mov    %ebx,(%esp)
  801a44:	e8 6f f5 ff ff       	call   800fb8 <fd2data>
  801a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a54:	e8 33 f2 ff ff       	call   800c8c <sys_page_unmap>
}
  801a59:	83 c4 14             	add    $0x14,%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 2c             	sub    $0x2c,%esp
  801a68:	89 c7                	mov    %eax,%edi
  801a6a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a72:	8b 00                	mov    (%eax),%eax
  801a74:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a77:	89 3c 24             	mov    %edi,(%esp)
  801a7a:	e8 e1 05 00 00       	call   802060 <pageref>
  801a7f:	89 c6                	mov    %eax,%esi
  801a81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	e8 d4 05 00 00       	call   802060 <pageref>
  801a8c:	39 c6                	cmp    %eax,%esi
  801a8e:	0f 94 c0             	sete   %al
  801a91:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a94:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a9a:	8b 12                	mov    (%edx),%edx
  801a9c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a9f:	39 cb                	cmp    %ecx,%ebx
  801aa1:	75 08                	jne    801aab <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801aa3:	83 c4 2c             	add    $0x2c,%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801aab:	83 f8 01             	cmp    $0x1,%eax
  801aae:	75 bd                	jne    801a6d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ab0:	8b 42 58             	mov    0x58(%edx),%eax
  801ab3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801aba:	00 
  801abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801abf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ac3:	c7 04 24 32 27 80 00 	movl   $0x802732,(%esp)
  801aca:	e8 79 e7 ff ff       	call   800248 <cprintf>
  801acf:	eb 9c                	jmp    801a6d <_pipeisclosed+0xe>

00801ad1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	57                   	push   %edi
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 1c             	sub    $0x1c,%esp
  801ada:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801add:	89 34 24             	mov    %esi,(%esp)
  801ae0:	e8 d3 f4 ff ff       	call   800fb8 <fd2data>
  801ae5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae7:	bf 00 00 00 00       	mov    $0x0,%edi
  801aec:	eb 3c                	jmp    801b2a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aee:	89 da                	mov    %ebx,%edx
  801af0:	89 f0                	mov    %esi,%eax
  801af2:	e8 68 ff ff ff       	call   801a5f <_pipeisclosed>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	75 38                	jne    801b33 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801afb:	e8 c6 f0 ff ff       	call   800bc6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b00:	8b 43 04             	mov    0x4(%ebx),%eax
  801b03:	8b 13                	mov    (%ebx),%edx
  801b05:	83 c2 20             	add    $0x20,%edx
  801b08:	39 d0                	cmp    %edx,%eax
  801b0a:	73 e2                	jae    801aee <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b0f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b1a:	79 05                	jns    801b21 <devpipe_write+0x50>
  801b1c:	4a                   	dec    %edx
  801b1d:	83 ca e0             	or     $0xffffffe0,%edx
  801b20:	42                   	inc    %edx
  801b21:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b25:	40                   	inc    %eax
  801b26:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b29:	47                   	inc    %edi
  801b2a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b2d:	75 d1                	jne    801b00 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b2f:	89 f8                	mov    %edi,%eax
  801b31:	eb 05                	jmp    801b38 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b33:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b38:	83 c4 1c             	add    $0x1c,%esp
  801b3b:	5b                   	pop    %ebx
  801b3c:	5e                   	pop    %esi
  801b3d:	5f                   	pop    %edi
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    

00801b40 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	57                   	push   %edi
  801b44:	56                   	push   %esi
  801b45:	53                   	push   %ebx
  801b46:	83 ec 1c             	sub    $0x1c,%esp
  801b49:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b4c:	89 3c 24             	mov    %edi,(%esp)
  801b4f:	e8 64 f4 ff ff       	call   800fb8 <fd2data>
  801b54:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b56:	be 00 00 00 00       	mov    $0x0,%esi
  801b5b:	eb 3a                	jmp    801b97 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b5d:	85 f6                	test   %esi,%esi
  801b5f:	74 04                	je     801b65 <devpipe_read+0x25>
				return i;
  801b61:	89 f0                	mov    %esi,%eax
  801b63:	eb 40                	jmp    801ba5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b65:	89 da                	mov    %ebx,%edx
  801b67:	89 f8                	mov    %edi,%eax
  801b69:	e8 f1 fe ff ff       	call   801a5f <_pipeisclosed>
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	75 2e                	jne    801ba0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b72:	e8 4f f0 ff ff       	call   800bc6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b77:	8b 03                	mov    (%ebx),%eax
  801b79:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b7c:	74 df                	je     801b5d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b83:	79 05                	jns    801b8a <devpipe_read+0x4a>
  801b85:	48                   	dec    %eax
  801b86:	83 c8 e0             	or     $0xffffffe0,%eax
  801b89:	40                   	inc    %eax
  801b8a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b91:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b94:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b96:	46                   	inc    %esi
  801b97:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b9a:	75 db                	jne    801b77 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	eb 05                	jmp    801ba5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba5:	83 c4 1c             	add    $0x1c,%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5f                   	pop    %edi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	57                   	push   %edi
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 3c             	sub    $0x3c,%esp
  801bb6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 0f f4 ff ff       	call   800fd3 <fd_alloc>
  801bc4:	89 c3                	mov    %eax,%ebx
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	0f 88 45 01 00 00    	js     801d13 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bce:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bd5:	00 
  801bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be4:	e8 fc ef ff ff       	call   800be5 <sys_page_alloc>
  801be9:	89 c3                	mov    %eax,%ebx
  801beb:	85 c0                	test   %eax,%eax
  801bed:	0f 88 20 01 00 00    	js     801d13 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bf3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bf6:	89 04 24             	mov    %eax,(%esp)
  801bf9:	e8 d5 f3 ff ff       	call   800fd3 <fd_alloc>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	85 c0                	test   %eax,%eax
  801c02:	0f 88 f8 00 00 00    	js     801d00 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c08:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c0f:	00 
  801c10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1e:	e8 c2 ef ff ff       	call   800be5 <sys_page_alloc>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	85 c0                	test   %eax,%eax
  801c27:	0f 88 d3 00 00 00    	js     801d00 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c30:	89 04 24             	mov    %eax,(%esp)
  801c33:	e8 80 f3 ff ff       	call   800fb8 <fd2data>
  801c38:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c41:	00 
  801c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4d:	e8 93 ef ff ff       	call   800be5 <sys_page_alloc>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	85 c0                	test   %eax,%eax
  801c56:	0f 88 91 00 00 00    	js     801ced <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c5f:	89 04 24             	mov    %eax,(%esp)
  801c62:	e8 51 f3 ff ff       	call   800fb8 <fd2data>
  801c67:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c6e:	00 
  801c6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c7a:	00 
  801c7b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c86:	e8 ae ef ff ff       	call   800c39 <sys_page_map>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	78 4c                	js     801cdd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c91:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c9a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c9f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ca6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801caf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cb4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cbe:	89 04 24             	mov    %eax,(%esp)
  801cc1:	e8 e2 f2 ff ff       	call   800fa8 <fd2num>
  801cc6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801cc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	e8 d5 f2 ff ff       	call   800fa8 <fd2num>
  801cd3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cdb:	eb 36                	jmp    801d13 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801cdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ce1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce8:	e8 9f ef ff ff       	call   800c8c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cfb:	e8 8c ef ff ff       	call   800c8c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801d00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0e:	e8 79 ef ff ff       	call   800c8c <sys_page_unmap>
    err:
	return r;
}
  801d13:	89 d8                	mov    %ebx,%eax
  801d15:	83 c4 3c             	add    $0x3c,%esp
  801d18:	5b                   	pop    %ebx
  801d19:	5e                   	pop    %esi
  801d1a:	5f                   	pop    %edi
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	89 04 24             	mov    %eax,(%esp)
  801d30:	e8 f1 f2 ff ff       	call   801026 <fd_lookup>
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 15                	js     801d4e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 74 f2 ff ff       	call   800fb8 <fd2data>
	return _pipeisclosed(fd, p);
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d49:	e8 11 fd ff ff       	call   801a5f <_pipeisclosed>
}
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d60:	c7 44 24 04 4a 27 80 	movl   $0x80274a,0x4(%esp)
  801d67:	00 
  801d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6b:	89 04 24             	mov    %eax,(%esp)
  801d6e:	e8 80 ea ff ff       	call   8007f3 <strcpy>
	return 0;
}
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d86:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d91:	eb 30                	jmp    801dc3 <devcons_write+0x49>
		m = n - tot;
  801d93:	8b 75 10             	mov    0x10(%ebp),%esi
  801d96:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d98:	83 fe 7f             	cmp    $0x7f,%esi
  801d9b:	76 05                	jbe    801da2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801d9d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801da2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801da6:	03 45 0c             	add    0xc(%ebp),%eax
  801da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dad:	89 3c 24             	mov    %edi,(%esp)
  801db0:	e8 b7 eb ff ff       	call   80096c <memmove>
		sys_cputs(buf, m);
  801db5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db9:	89 3c 24             	mov    %edi,(%esp)
  801dbc:	e8 57 ed ff ff       	call   800b18 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc1:	01 f3                	add    %esi,%ebx
  801dc3:	89 d8                	mov    %ebx,%eax
  801dc5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc8:	72 c9                	jb     801d93 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dca:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ddb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ddf:	75 07                	jne    801de8 <devcons_read+0x13>
  801de1:	eb 25                	jmp    801e08 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de3:	e8 de ed ff ff       	call   800bc6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de8:	e8 49 ed ff ff       	call   800b36 <sys_cgetc>
  801ded:	85 c0                	test   %eax,%eax
  801def:	74 f2                	je     801de3 <devcons_read+0xe>
  801df1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801df3:	85 c0                	test   %eax,%eax
  801df5:	78 1d                	js     801e14 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df7:	83 f8 04             	cmp    $0x4,%eax
  801dfa:	74 13                	je     801e0f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dff:	88 10                	mov    %dl,(%eax)
	return 1;
  801e01:	b8 01 00 00 00       	mov    $0x1,%eax
  801e06:	eb 0c                	jmp    801e14 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0d:	eb 05                	jmp    801e14 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e22:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e29:	00 
  801e2a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2d:	89 04 24             	mov    %eax,(%esp)
  801e30:	e8 e3 ec ff ff       	call   800b18 <sys_cputs>
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <getchar>:

int
getchar(void)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e3d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e44:	00 
  801e45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e53:	e8 6c f4 ff ff       	call   8012c4 <read>
	if (r < 0)
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	78 0f                	js     801e6b <getchar+0x34>
		return r;
	if (r < 1)
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	7e 06                	jle    801e66 <getchar+0x2f>
		return -E_EOF;
	return c;
  801e60:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e64:	eb 05                	jmp    801e6b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e66:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7d:	89 04 24             	mov    %eax,(%esp)
  801e80:	e8 a1 f1 ff ff       	call   801026 <fd_lookup>
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 11                	js     801e9a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e92:	39 10                	cmp    %edx,(%eax)
  801e94:	0f 94 c0             	sete   %al
  801e97:	0f b6 c0             	movzbl %al,%eax
}
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <opencons>:

int
opencons(void)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea5:	89 04 24             	mov    %eax,(%esp)
  801ea8:	e8 26 f1 ff ff       	call   800fd3 <fd_alloc>
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 3c                	js     801eed <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb8:	00 
  801eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec7:	e8 19 ed ff ff       	call   800be5 <sys_page_alloc>
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 1d                	js     801eed <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee5:	89 04 24             	mov    %eax,(%esp)
  801ee8:	e8 bb f0 ff ff       	call   800fa8 <fd2num>
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    
	...

00801ef0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	56                   	push   %esi
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801ef8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801efb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801f01:	e8 a1 ec ff ff       	call   800ba7 <sys_getenvid>
  801f06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f09:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  801f10:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f14:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1c:	c7 04 24 58 27 80 00 	movl   $0x802758,(%esp)
  801f23:	e8 20 e3 ff ff       	call   800248 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f2f:	89 04 24             	mov    %eax,(%esp)
  801f32:	e8 b0 e2 ff ff       	call   8001e7 <vcprintf>
	cprintf("\n");
  801f37:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  801f3e:	e8 05 e3 ff ff       	call   800248 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f43:	cc                   	int3   
  801f44:	eb fd                	jmp    801f43 <_panic+0x53>
	...

00801f48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 10             	sub    $0x10,%esp
  801f50:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f56:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	75 05                	jne    801f62 <ipc_recv+0x1a>
  801f5d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801f62:	89 04 24             	mov    %eax,(%esp)
  801f65:	e8 91 ee ff ff       	call   800dfb <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	79 16                	jns    801f84 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801f6e:	85 db                	test   %ebx,%ebx
  801f70:	74 06                	je     801f78 <ipc_recv+0x30>
  801f72:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801f78:	85 f6                	test   %esi,%esi
  801f7a:	74 32                	je     801fae <ipc_recv+0x66>
  801f7c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f82:	eb 2a                	jmp    801fae <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f84:	85 db                	test   %ebx,%ebx
  801f86:	74 0c                	je     801f94 <ipc_recv+0x4c>
  801f88:	a1 04 40 80 00       	mov    0x804004,%eax
  801f8d:	8b 00                	mov    (%eax),%eax
  801f8f:	8b 40 74             	mov    0x74(%eax),%eax
  801f92:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f94:	85 f6                	test   %esi,%esi
  801f96:	74 0c                	je     801fa4 <ipc_recv+0x5c>
  801f98:	a1 04 40 80 00       	mov    0x804004,%eax
  801f9d:	8b 00                	mov    (%eax),%eax
  801f9f:	8b 40 78             	mov    0x78(%eax),%eax
  801fa2:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801fa4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa9:	8b 00                	mov    (%eax),%eax
  801fab:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	5b                   	pop    %ebx
  801fb2:	5e                   	pop    %esi
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	57                   	push   %edi
  801fb9:	56                   	push   %esi
  801fba:	53                   	push   %ebx
  801fbb:	83 ec 1c             	sub    $0x1c,%esp
  801fbe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801fc7:	85 db                	test   %ebx,%ebx
  801fc9:	75 05                	jne    801fd0 <ipc_send+0x1b>
  801fcb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801fd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801fd4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdf:	89 04 24             	mov    %eax,(%esp)
  801fe2:	e8 f1 ed ff ff       	call   800dd8 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801fe7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fea:	75 07                	jne    801ff3 <ipc_send+0x3e>
  801fec:	e8 d5 eb ff ff       	call   800bc6 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801ff1:	eb dd                	jmp    801fd0 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	79 1c                	jns    802013 <ipc_send+0x5e>
  801ff7:	c7 44 24 08 7c 27 80 	movl   $0x80277c,0x8(%esp)
  801ffe:	00 
  801fff:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802006:	00 
  802007:	c7 04 24 8e 27 80 00 	movl   $0x80278e,(%esp)
  80200e:	e8 dd fe ff ff       	call   801ef0 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802013:	83 c4 1c             	add    $0x1c,%esp
  802016:	5b                   	pop    %ebx
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	53                   	push   %ebx
  80201f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802027:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80202e:	89 c2                	mov    %eax,%edx
  802030:	c1 e2 07             	shl    $0x7,%edx
  802033:	29 ca                	sub    %ecx,%edx
  802035:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80203b:	8b 52 50             	mov    0x50(%edx),%edx
  80203e:	39 da                	cmp    %ebx,%edx
  802040:	75 0f                	jne    802051 <ipc_find_env+0x36>
			return envs[i].env_id;
  802042:	c1 e0 07             	shl    $0x7,%eax
  802045:	29 c8                	sub    %ecx,%eax
  802047:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80204c:	8b 40 40             	mov    0x40(%eax),%eax
  80204f:	eb 0c                	jmp    80205d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802051:	40                   	inc    %eax
  802052:	3d 00 04 00 00       	cmp    $0x400,%eax
  802057:	75 ce                	jne    802027 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802059:	66 b8 00 00          	mov    $0x0,%ax
}
  80205d:	5b                   	pop    %ebx
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  802066:	89 c2                	mov    %eax,%edx
  802068:	c1 ea 16             	shr    $0x16,%edx
  80206b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802072:	f6 c2 01             	test   $0x1,%dl
  802075:	74 1e                	je     802095 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802077:	c1 e8 0c             	shr    $0xc,%eax
  80207a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802081:	a8 01                	test   $0x1,%al
  802083:	74 17                	je     80209c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802085:	c1 e8 0c             	shr    $0xc,%eax
  802088:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80208f:	ef 
  802090:	0f b7 c0             	movzwl %ax,%eax
  802093:	eb 0c                	jmp    8020a1 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802095:	b8 00 00 00 00       	mov    $0x0,%eax
  80209a:	eb 05                	jmp    8020a1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80209c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    
	...

008020a4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020a4:	55                   	push   %ebp
  8020a5:	57                   	push   %edi
  8020a6:	56                   	push   %esi
  8020a7:	83 ec 10             	sub    $0x10,%esp
  8020aa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8020ae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020b6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8020ba:	89 cd                	mov    %ecx,%ebp
  8020bc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	75 2c                	jne    8020f0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020c4:	39 f9                	cmp    %edi,%ecx
  8020c6:	77 68                	ja     802130 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020c8:	85 c9                	test   %ecx,%ecx
  8020ca:	75 0b                	jne    8020d7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d1:	31 d2                	xor    %edx,%edx
  8020d3:	f7 f1                	div    %ecx
  8020d5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020d7:	31 d2                	xor    %edx,%edx
  8020d9:	89 f8                	mov    %edi,%eax
  8020db:	f7 f1                	div    %ecx
  8020dd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020df:	89 f0                	mov    %esi,%eax
  8020e1:	f7 f1                	div    %ecx
  8020e3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020e5:	89 f0                	mov    %esi,%eax
  8020e7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020e9:	83 c4 10             	add    $0x10,%esp
  8020ec:	5e                   	pop    %esi
  8020ed:	5f                   	pop    %edi
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020f0:	39 f8                	cmp    %edi,%eax
  8020f2:	77 2c                	ja     802120 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020f4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8020f7:	83 f6 1f             	xor    $0x1f,%esi
  8020fa:	75 4c                	jne    802148 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020fc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020fe:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802103:	72 0a                	jb     80210f <__udivdi3+0x6b>
  802105:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802109:	0f 87 ad 00 00 00    	ja     8021bc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80210f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802114:	89 f0                	mov    %esi,%eax
  802116:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802118:	83 c4 10             	add    $0x10,%esp
  80211b:	5e                   	pop    %esi
  80211c:	5f                   	pop    %edi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    
  80211f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802120:	31 ff                	xor    %edi,%edi
  802122:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802124:	89 f0                	mov    %esi,%eax
  802126:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	5e                   	pop    %esi
  80212c:	5f                   	pop    %edi
  80212d:	5d                   	pop    %ebp
  80212e:	c3                   	ret    
  80212f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802130:	89 fa                	mov    %edi,%edx
  802132:	89 f0                	mov    %esi,%eax
  802134:	f7 f1                	div    %ecx
  802136:	89 c6                	mov    %eax,%esi
  802138:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80213a:	89 f0                	mov    %esi,%eax
  80213c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802148:	89 f1                	mov    %esi,%ecx
  80214a:	d3 e0                	shl    %cl,%eax
  80214c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802150:	b8 20 00 00 00       	mov    $0x20,%eax
  802155:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802157:	89 ea                	mov    %ebp,%edx
  802159:	88 c1                	mov    %al,%cl
  80215b:	d3 ea                	shr    %cl,%edx
  80215d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802161:	09 ca                	or     %ecx,%edx
  802163:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802167:	89 f1                	mov    %esi,%ecx
  802169:	d3 e5                	shl    %cl,%ebp
  80216b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80216f:	89 fd                	mov    %edi,%ebp
  802171:	88 c1                	mov    %al,%cl
  802173:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802175:	89 fa                	mov    %edi,%edx
  802177:	89 f1                	mov    %esi,%ecx
  802179:	d3 e2                	shl    %cl,%edx
  80217b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80217f:	88 c1                	mov    %al,%cl
  802181:	d3 ef                	shr    %cl,%edi
  802183:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802185:	89 f8                	mov    %edi,%eax
  802187:	89 ea                	mov    %ebp,%edx
  802189:	f7 74 24 08          	divl   0x8(%esp)
  80218d:	89 d1                	mov    %edx,%ecx
  80218f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802191:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802195:	39 d1                	cmp    %edx,%ecx
  802197:	72 17                	jb     8021b0 <__udivdi3+0x10c>
  802199:	74 09                	je     8021a4 <__udivdi3+0x100>
  80219b:	89 fe                	mov    %edi,%esi
  80219d:	31 ff                	xor    %edi,%edi
  80219f:	e9 41 ff ff ff       	jmp    8020e5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021a4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021a8:	89 f1                	mov    %esi,%ecx
  8021aa:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021ac:	39 c2                	cmp    %eax,%edx
  8021ae:	73 eb                	jae    80219b <__udivdi3+0xf7>
		{
		  q0--;
  8021b0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021b3:	31 ff                	xor    %edi,%edi
  8021b5:	e9 2b ff ff ff       	jmp    8020e5 <__udivdi3+0x41>
  8021ba:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021bc:	31 f6                	xor    %esi,%esi
  8021be:	e9 22 ff ff ff       	jmp    8020e5 <__udivdi3+0x41>
	...

008021c4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021c4:	55                   	push   %ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	83 ec 20             	sub    $0x20,%esp
  8021ca:	8b 44 24 30          	mov    0x30(%esp),%eax
  8021ce:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021d2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8021d6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8021da:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021de:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021e2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8021e4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021e6:	85 ed                	test   %ebp,%ebp
  8021e8:	75 16                	jne    802200 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8021ea:	39 f1                	cmp    %esi,%ecx
  8021ec:	0f 86 a6 00 00 00    	jbe    802298 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021f2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021f4:	89 d0                	mov    %edx,%eax
  8021f6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021f8:	83 c4 20             	add    $0x20,%esp
  8021fb:	5e                   	pop    %esi
  8021fc:	5f                   	pop    %edi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    
  8021ff:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802200:	39 f5                	cmp    %esi,%ebp
  802202:	0f 87 ac 00 00 00    	ja     8022b4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802208:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80220b:	83 f0 1f             	xor    $0x1f,%eax
  80220e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802212:	0f 84 a8 00 00 00    	je     8022c0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802218:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80221c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80221e:	bf 20 00 00 00       	mov    $0x20,%edi
  802223:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802227:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80222b:	89 f9                	mov    %edi,%ecx
  80222d:	d3 e8                	shr    %cl,%eax
  80222f:	09 e8                	or     %ebp,%eax
  802231:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802235:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802239:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80223d:	d3 e0                	shl    %cl,%eax
  80223f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802243:	89 f2                	mov    %esi,%edx
  802245:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802247:	8b 44 24 14          	mov    0x14(%esp),%eax
  80224b:	d3 e0                	shl    %cl,%eax
  80224d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802251:	8b 44 24 14          	mov    0x14(%esp),%eax
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e8                	shr    %cl,%eax
  802259:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80225b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	f7 74 24 18          	divl   0x18(%esp)
  802263:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802265:	f7 64 24 0c          	mull   0xc(%esp)
  802269:	89 c5                	mov    %eax,%ebp
  80226b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80226d:	39 d6                	cmp    %edx,%esi
  80226f:	72 67                	jb     8022d8 <__umoddi3+0x114>
  802271:	74 75                	je     8022e8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802273:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802277:	29 e8                	sub    %ebp,%eax
  802279:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80227b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80227f:	d3 e8                	shr    %cl,%eax
  802281:	89 f2                	mov    %esi,%edx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802287:	09 d0                	or     %edx,%eax
  802289:	89 f2                	mov    %esi,%edx
  80228b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80228f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802291:	83 c4 20             	add    $0x20,%esp
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802298:	85 c9                	test   %ecx,%ecx
  80229a:	75 0b                	jne    8022a7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80229c:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a1:	31 d2                	xor    %edx,%edx
  8022a3:	f7 f1                	div    %ecx
  8022a5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022a7:	89 f0                	mov    %esi,%eax
  8022a9:	31 d2                	xor    %edx,%edx
  8022ab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022ad:	89 f8                	mov    %edi,%eax
  8022af:	e9 3e ff ff ff       	jmp    8021f2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022b4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022b6:	83 c4 20             	add    $0x20,%esp
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022c0:	39 f5                	cmp    %esi,%ebp
  8022c2:	72 04                	jb     8022c8 <__umoddi3+0x104>
  8022c4:	39 f9                	cmp    %edi,%ecx
  8022c6:	77 06                	ja     8022ce <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022c8:	89 f2                	mov    %esi,%edx
  8022ca:	29 cf                	sub    %ecx,%edi
  8022cc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022ce:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022d0:	83 c4 20             	add    $0x20,%esp
  8022d3:	5e                   	pop    %esi
  8022d4:	5f                   	pop    %edi
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    
  8022d7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022d8:	89 d1                	mov    %edx,%ecx
  8022da:	89 c5                	mov    %eax,%ebp
  8022dc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8022e0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8022e4:	eb 8d                	jmp    802273 <__umoddi3+0xaf>
  8022e6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022e8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8022ec:	72 ea                	jb     8022d8 <__umoddi3+0x114>
  8022ee:	89 f1                	mov    %esi,%ecx
  8022f0:	eb 81                	jmp    802273 <__umoddi3+0xaf>
