
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 10 80 00       	mov    0x801000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 71 00 00 00       	call   8000c0 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800062:	c7 05 08 10 80 00 00 	movl   $0x0,0x801008
  800069:	00 00 00 
	thisenv = envs + ENVX(sys_getenvid());
  80006c:	e8 de 00 00 00       	call   80014f <sys_getenvid>
  800071:	25 ff 03 00 00       	and    $0x3ff,%eax
  800076:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800079:	c1 e0 05             	shl    $0x5,%eax
  80007c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800081:	a3 08 10 80 00       	mov    %eax,0x801008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800086:	85 f6                	test   %esi,%esi
  800088:	7e 07                	jle    800091 <libmain+0x3d>
		binaryname = argv[0];
  80008a:	8b 03                	mov    (%ebx),%eax
  80008c:	a3 04 10 80 00       	mov    %eax,0x801004

	// call user main routine
	umain(argc, argv);
  800091:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 97 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009d:	e8 0a 00 00 00       	call   8000ac <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 3f 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	89 cb                	mov    %ecx,%ebx
  800115:	89 cf                	mov    %ecx,%edi
  800117:	89 ce                	mov    %ecx,%esi
  800119:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	7e 28                	jle    800147 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800123:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012a:	00 
  80012b:	c7 44 24 08 a0 0d 80 	movl   $0x800da0,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 bd 0d 80 00 	movl   $0x800dbd,(%esp)
  800142:	e8 29 00 00 00       	call   800170 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800147:	83 c4 2c             	add    $0x2c,%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    
	...

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800178:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017b:	8b 1d 04 10 80 00    	mov    0x801004,%ebx
  800181:	e8 c9 ff ff ff       	call   80014f <sys_getenvid>
  800186:	8b 55 0c             	mov    0xc(%ebp),%edx
  800189:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800194:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 cc 0d 80 00 	movl   $0x800dcc,(%esp)
  8001a3:	e8 c0 00 00 00       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 50 00 00 00       	call   800207 <vcprintf>
	cprintf("\n");
  8001b7:	c7 04 24 94 0d 80 00 	movl   $0x800d94,(%esp)
  8001be:	e8 a5 00 00 00       	call   800268 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c3:	cc                   	int3   
  8001c4:	eb fd                	jmp    8001c3 <_panic+0x53>
	...

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 03                	mov    (%ebx),%eax
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001db:	40                   	inc    %eax
  8001dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	75 19                	jne    8001fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ec:	00 
  8001ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 c8 fe ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8001f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fe:	ff 43 04             	incl   0x4(%ebx)
}
  800201:	83 c4 14             	add    $0x14,%esp
  800204:	5b                   	pop    %ebx
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800210:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800217:	00 00 00 
	b.cnt = 0;
  80021a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800221:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800243:	e8 82 01 00 00       	call   8003ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800248:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 60 fe ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 87 ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    
	...

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 3c             	sub    $0x3c,%esp
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	89 d7                	mov    %edx,%edi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a4:	85 c0                	test   %eax,%eax
  8002a6:	75 08                	jne    8002b0 <printnum+0x2c>
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 57                	ja     800307 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b4:	4b                   	dec    %ebx
  8002b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	e8 56 08 00 00       	call   800b38 <__udivdi3>
  8002e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f1:	89 fa                	mov    %edi,%edx
  8002f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f6:	e8 89 ff ff ff       	call   800284 <printnum>
  8002fb:	eb 0f                	jmp    80030c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	89 34 24             	mov    %esi,(%esp)
  800304:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800307:	4b                   	dec    %ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f f1                	jg     8002fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 10             	mov    0x10(%ebp),%eax
  800317:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800322:	00 
  800323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	e8 23 09 00 00       	call   800c58 <__umoddi3>
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	0f be 80 f0 0d 80 00 	movsbl 0x800df0(%eax),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800346:	83 c4 3c             	add    $0x3c,%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800351:	83 fa 01             	cmp    $0x1,%edx
  800354:	7e 0e                	jle    800364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	8b 52 04             	mov    0x4(%edx),%edx
  800362:	eb 22                	jmp    800386 <getuint+0x38>
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 10                	je     800378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 0e                	jmp    800386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800391:	8b 10                	mov    (%eax),%edx
  800393:	3b 50 04             	cmp    0x4(%eax),%edx
  800396:	73 08                	jae    8003a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 0a                	mov    %cl,(%edx)
  80039d:	42                   	inc    %edx
  80039e:	89 10                	mov    %edx,(%eax)
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003af:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 02 00 00 00       	call   8003ca <vprintfmt>
	va_end(ap);
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 4c             	sub    $0x4c,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 6b 03 00 00    	je     80074e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	0f b6 06             	movzbl (%esi),%eax
  8003f0:	46                   	inc    %esi
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 e5                	jne    8003db <vprintfmt+0x11>
  8003f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800401:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800406:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	eb 26                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800417:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041b:	eb 1d                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800424:	eb 14                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800430:	eb 08                	jmp    80043a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800432:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	0f b6 06             	movzbl (%esi),%eax
  80043d:	8d 56 01             	lea    0x1(%esi),%edx
  800440:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800443:	8a 16                	mov    (%esi),%dl
  800445:	83 ea 23             	sub    $0x23,%edx
  800448:	80 fa 55             	cmp    $0x55,%dl
  80044b:	0f 87 e1 02 00 00    	ja     800732 <vprintfmt+0x368>
  800451:	0f b6 d2             	movzbl %dl,%edx
  800454:	ff 24 95 80 0e 80 00 	jmp    *0x800e80(,%edx,4)
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800463:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800466:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800470:	83 fa 09             	cmp    $0x9,%edx
  800473:	77 2a                	ja     80049f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800475:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800476:	eb eb                	jmp    800463 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800486:	eb 17                	jmp    80049f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048c:	78 98                	js     800426 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800491:	eb a7                	jmp    80043a <vprintfmt+0x70>
  800493:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800496:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80049d:	eb 9b                	jmp    80043a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a3:	79 95                	jns    80043a <vprintfmt+0x70>
  8004a5:	eb 8b                	jmp    800432 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ab:	eb 8d                	jmp    80043a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c5:	e9 23 ff ff ff       	jmp    8003ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 50 04             	lea    0x4(%eax),%edx
  8004d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	79 02                	jns    8004db <vprintfmt+0x111>
  8004d9:	f7 d8                	neg    %eax
  8004db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004dd:	83 f8 06             	cmp    $0x6,%eax
  8004e0:	7f 0b                	jg     8004ed <vprintfmt+0x123>
  8004e2:	8b 04 85 d8 0f 80 00 	mov    0x800fd8(,%eax,4),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 23                	jne    800510 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f1:	c7 44 24 08 08 0e 80 	movl   $0x800e08,0x8(%esp)
  8004f8:	00 
  8004f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 9a fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050b:	e9 dd fe ff ff       	jmp    8003ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800514:	c7 44 24 08 11 0e 80 	movl   $0x800e11,0x8(%esp)
  80051b:	00 
  80051c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	89 14 24             	mov    %edx,(%esp)
  800526:	e8 77 fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052e:	e9 ba fe ff ff       	jmp    8003ed <vprintfmt+0x23>
  800533:	89 f9                	mov    %edi,%ecx
  800535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 30                	mov    (%eax),%esi
  800546:	85 f6                	test   %esi,%esi
  800548:	75 05                	jne    80054f <vprintfmt+0x185>
				p = "(null)";
  80054a:	be 01 0e 80 00       	mov    $0x800e01,%esi
			if (width > 0 && padc != '-')
  80054f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800553:	0f 8e 84 00 00 00    	jle    8005dd <vprintfmt+0x213>
  800559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80055d:	74 7e                	je     8005dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800563:	89 34 24             	mov    %esi,(%esp)
  800566:	e8 8b 02 00 00       	call   8007f6 <strnlen>
  80056b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800573:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800577:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80057a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80057d:	89 de                	mov    %ebx,%esi
  80057f:	89 d3                	mov    %edx,%ebx
  800581:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0b                	jmp    800590 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	4b                   	dec    %ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f f1                	jg     800585 <vprintfmt+0x1bb>
  800594:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800597:	89 f3                	mov    %esi,%ebx
  800599:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80059c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	79 05                	jns    8005a8 <vprintfmt+0x1de>
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ab:	29 c2                	sub    %eax,%edx
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b0:	eb 2b                	jmp    8005dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b6:	74 18                	je     8005d0 <vprintfmt+0x206>
  8005b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005bb:	83 fa 5e             	cmp    $0x5e,%edx
  8005be:	76 10                	jbe    8005d0 <vprintfmt+0x206>
					putch('?', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
  8005ce:	eb 0a                	jmp    8005da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	ff 4d e4             	decl   -0x1c(%ebp)
  8005dd:	0f be 06             	movsbl (%esi),%eax
  8005e0:	46                   	inc    %esi
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	74 21                	je     800606 <vprintfmt+0x23c>
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	78 c9                	js     8005b2 <vprintfmt+0x1e8>
  8005e9:	4f                   	dec    %edi
  8005ea:	79 c6                	jns    8005b2 <vprintfmt+0x1e8>
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ef:	89 de                	mov    %ebx,%esi
  8005f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f4:	eb 18                	jmp    80060e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800601:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800603:	4b                   	dec    %ebx
  800604:	eb 08                	jmp    80060e <vprintfmt+0x244>
  800606:	8b 7d 08             	mov    0x8(%ebp),%edi
  800609:	89 de                	mov    %ebx,%esi
  80060b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060e:	85 db                	test   %ebx,%ebx
  800610:	7f e4                	jg     8005f6 <vprintfmt+0x22c>
  800612:	89 7d 08             	mov    %edi,0x8(%ebp)
  800615:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	e9 ce fd ff ff       	jmp    8003ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 10                	jle    800634 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 08             	lea    0x8(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
  80062f:	8b 78 04             	mov    0x4(%eax),%edi
  800632:	eb 26                	jmp    80065a <vprintfmt+0x290>
	else if (lflag)
  800634:	85 c9                	test   %ecx,%ecx
  800636:	74 12                	je     80064a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 30                	mov    (%eax),%esi
  800643:	89 f7                	mov    %esi,%edi
  800645:	c1 ff 1f             	sar    $0x1f,%edi
  800648:	eb 10                	jmp    80065a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	89 f7                	mov    %esi,%edi
  800657:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065a:	85 ff                	test   %edi,%edi
  80065c:	78 0a                	js     800668 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 8c 00 00 00       	jmp    8006f4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800676:	f7 de                	neg    %esi
  800678:	83 d7 00             	adc    $0x0,%edi
  80067b:	f7 df                	neg    %edi
			}
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800682:	eb 70                	jmp    8006f4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 c0 fc ff ff       	call   80034e <getuint>
  80068e:	89 c6                	mov    %eax,%esi
  800690:	89 d7                	mov    %edx,%edi
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800697:	eb 5b                	jmp    8006f4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 ab fc ff ff       	call   80034e <getuint>
  8006a3:	89 c6                	mov    %eax,%esi
  8006a5:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006ac:	eb 46                	jmp    8006f4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006df:	eb 13                	jmp    8006f4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 63 fc ff ff       	call   80034e <getuint>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800703:	89 44 24 08          	mov    %eax,0x8(%esp)
  800707:	89 34 24             	mov    %esi,(%esp)
  80070a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070e:	89 da                	mov    %ebx,%edx
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	e8 6c fb ff ff       	call   800284 <printnum>
			break;
  800718:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071b:	e9 cd fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072d:	e9 bb fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800740:	eb 01                	jmp    800743 <vprintfmt+0x379>
  800742:	4e                   	dec    %esi
  800743:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800747:	75 f9                	jne    800742 <vprintfmt+0x378>
  800749:	e9 9f fc ff ff       	jmp    8003ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074e:	83 c4 4c             	add    $0x4c,%esp
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	5f                   	pop    %edi
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 28             	sub    $0x28,%esp
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800765:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800769:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800773:	85 c0                	test   %eax,%eax
  800775:	74 30                	je     8007a7 <vsnprintf+0x51>
  800777:	85 d2                	test   %edx,%edx
  800779:	7e 33                	jle    8007ae <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	89 44 24 08          	mov    %eax,0x8(%esp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800797:	e8 2e fc ff ff       	call   8003ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a5:	eb 0c                	jmp    8007b3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ac:	eb 05                	jmp    8007b3 <vsnprintf+0x5d>
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	e8 7b ff ff ff       	call   800756 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 01                	jmp    8007ee <strlen+0xe>
		n++;
  8007ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f2:	75 f9                	jne    8007ed <strlen+0xd>
		n++;
	return n;
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800804:	eb 01                	jmp    800807 <strnlen+0x11>
		n++;
  800806:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	39 d0                	cmp    %edx,%eax
  800809:	74 06                	je     800811 <strnlen+0x1b>
  80080b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080f:	75 f5                	jne    800806 <strnlen+0x10>
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800825:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800828:	42                   	inc    %edx
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 f5                	jne    800822 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	89 1c 24             	mov    %ebx,(%esp)
  80083d:	e8 9e ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	89 54 24 04          	mov    %edx,0x4(%esp)
  800849:	01 d8                	add    %ebx,%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 c0 ff ff ff       	call   800813 <strcpy>
	return dst;
}
  800853:	89 d8                	mov    %ebx,%eax
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086e:	eb 0c                	jmp    80087c <strncpy+0x21>
		*dst++ = *src;
  800870:	8a 1a                	mov    (%edx),%bl
  800872:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800875:	80 3a 01             	cmpb   $0x1,(%edx)
  800878:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087b:	41                   	inc    %ecx
  80087c:	39 f1                	cmp    %esi,%ecx
  80087e:	75 f0                	jne    800870 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	75 0a                	jne    8008a0 <strlcpy+0x1c>
  800896:	89 f0                	mov    %esi,%eax
  800898:	eb 1a                	jmp    8008b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089a:	88 18                	mov    %bl,(%eax)
  80089c:	40                   	inc    %eax
  80089d:	41                   	inc    %ecx
  80089e:	eb 02                	jmp    8008a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008a2:	4a                   	dec    %edx
  8008a3:	74 0a                	je     8008af <strlcpy+0x2b>
  8008a5:	8a 19                	mov    (%ecx),%bl
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	75 ef                	jne    80089a <strlcpy+0x16>
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	eb 02                	jmp    8008b1 <strlcpy+0x2d>
  8008af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b4:	29 f0                	sub    %esi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c3:	eb 02                	jmp    8008c7 <strcmp+0xd>
		p++, q++;
  8008c5:	41                   	inc    %ecx
  8008c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c7:	8a 01                	mov    (%ecx),%al
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 04                	je     8008d1 <strcmp+0x17>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 f4                	je     8008c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e8:	eb 03                	jmp    8008ed <strncmp+0x12>
		n--, p++, q++;
  8008ea:	4a                   	dec    %edx
  8008eb:	40                   	inc    %eax
  8008ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	74 14                	je     800905 <strncmp+0x2a>
  8008f1:	8a 18                	mov    (%eax),%bl
  8008f3:	84 db                	test   %bl,%bl
  8008f5:	74 04                	je     8008fb <strncmp+0x20>
  8008f7:	3a 19                	cmp    (%ecx),%bl
  8008f9:	74 ef                	je     8008ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 00             	movzbl (%eax),%eax
  8008fe:	0f b6 11             	movzbl (%ecx),%edx
  800901:	29 d0                	sub    %edx,%eax
  800903:	eb 05                	jmp    80090a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090a:	5b                   	pop    %ebx
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800916:	eb 05                	jmp    80091d <strchr+0x10>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 0c                	je     800928 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091c:	40                   	inc    %eax
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f5                	jne    800918 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800933:	eb 05                	jmp    80093a <strfind+0x10>
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 07                	je     800940 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800939:	40                   	inc    %eax
  80093a:	8a 10                	mov    (%eax),%dl
  80093c:	84 d2                	test   %dl,%dl
  80093e:	75 f5                	jne    800935 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 30                	je     800985 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 25                	jne    800982 <memset+0x40>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 20                	jne    800982 <memset+0x40>
		c &= 0xFF;
  800962:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800965:	89 d3                	mov    %edx,%ebx
  800967:	c1 e3 08             	shl    $0x8,%ebx
  80096a:	89 d6                	mov    %edx,%esi
  80096c:	c1 e6 18             	shl    $0x18,%esi
  80096f:	89 d0                	mov    %edx,%eax
  800971:	c1 e0 10             	shl    $0x10,%eax
  800974:	09 f0                	or     %esi,%eax
  800976:	09 d0                	or     %edx,%eax
  800978:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80097d:	fc                   	cld    
  80097e:	f3 ab                	rep stos %eax,%es:(%edi)
  800980:	eb 03                	jmp    800985 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800982:	fc                   	cld    
  800983:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800985:	89 f8                	mov    %edi,%eax
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 75 0c             	mov    0xc(%ebp),%esi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099a:	39 c6                	cmp    %eax,%esi
  80099c:	73 34                	jae    8009d2 <memmove+0x46>
  80099e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a1:	39 d0                	cmp    %edx,%eax
  8009a3:	73 2d                	jae    8009d2 <memmove+0x46>
		s += n;
		d += n;
  8009a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	f6 c2 03             	test   $0x3,%dl
  8009ab:	75 1b                	jne    8009c8 <memmove+0x3c>
  8009ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b3:	75 13                	jne    8009c8 <memmove+0x3c>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0e                	jne    8009c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ba:	83 ef 04             	sub    $0x4,%edi
  8009bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 07                	jmp    8009cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c8:	4f                   	dec    %edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 20                	jmp    8009f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	75 13                	jne    8009ed <memmove+0x61>
  8009da:	a8 03                	test   $0x3,%al
  8009dc:	75 0f                	jne    8009ed <memmove+0x61>
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 0a                	jne    8009ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb 05                	jmp    8009f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 77 ff ff ff       	call   80098c <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	eb 16                	jmp    800a43 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a30:	42                   	inc    %edx
  800a31:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a35:	38 c8                	cmp    %cl,%al
  800a37:	74 0a                	je     800a43 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	0f b6 c9             	movzbl %cl,%ecx
  800a3f:	29 c8                	sub    %ecx,%eax
  800a41:	eb 09                	jmp    800a4c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	75 e6                	jne    800a2d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5f:	eb 05                	jmp    800a66 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	74 05                	je     800a6a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	40                   	inc    %eax
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	72 f7                	jb     800a61 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 01                	jmp    800a7b <strtol+0xf>
		s++;
  800a7a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7b:	8a 02                	mov    (%edx),%al
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f9                	je     800a7a <strtol+0xe>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f5                	je     800a7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	75 08                	jne    800a91 <strtol+0x25>
		s++;
  800a89:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8f:	eb 13                	jmp    800aa4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a91:	3c 2d                	cmp    $0x2d,%al
  800a93:	75 0a                	jne    800a9f <strtol+0x33>
		s++, neg = 1;
  800a95:	8d 52 01             	lea    0x1(%edx),%edx
  800a98:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9d:	eb 05                	jmp    800aa4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	74 05                	je     800aad <strtol+0x41>
  800aa8:	83 fb 10             	cmp    $0x10,%ebx
  800aab:	75 28                	jne    800ad5 <strtol+0x69>
  800aad:	8a 02                	mov    (%edx),%al
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 10                	jne    800ac3 <strtol+0x57>
  800ab3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab7:	75 0a                	jne    800ac3 <strtol+0x57>
		s += 2, base = 16;
  800ab9:	83 c2 02             	add    $0x2,%edx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb 12                	jmp    800ad5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	75 0e                	jne    800ad5 <strtol+0x69>
  800ac7:	3c 30                	cmp    $0x30,%al
  800ac9:	75 05                	jne    800ad0 <strtol+0x64>
		s++, base = 8;
  800acb:	42                   	inc    %edx
  800acc:	b3 08                	mov    $0x8,%bl
  800ace:	eb 05                	jmp    800ad5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adc:	8a 0a                	mov    (%edx),%cl
  800ade:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x82>
			dig = *s - '0';
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 30             	sub    $0x30,%ecx
  800aec:	eb 1e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 08                	ja     800afe <strtol+0x92>
			dig = *s - 'a' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 57             	sub    $0x57,%ecx
  800afc:	eb 0e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 12                	ja     800b18 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0c:	39 f1                	cmp    %esi,%ecx
  800b0e:	7d 0c                	jge    800b1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b10:	42                   	inc    %edx
  800b11:	0f af c6             	imul   %esi,%eax
  800b14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb c4                	jmp    800adc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	89 c1                	mov    %eax,%ecx
  800b1a:	eb 02                	jmp    800b1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b22:	74 05                	je     800b29 <strtol+0xbd>
		*endptr = (char *) s;
  800b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b29:	85 ff                	test   %edi,%edi
  800b2b:	74 04                	je     800b31 <strtol+0xc5>
  800b2d:	89 c8                	mov    %ecx,%eax
  800b2f:	f7 d8                	neg    %eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
	...

00800b38 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b38:	55                   	push   %ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	83 ec 10             	sub    $0x10,%esp
  800b3e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b4a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800b4e:	89 cd                	mov    %ecx,%ebp
  800b50:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b54:	85 c0                	test   %eax,%eax
  800b56:	75 2c                	jne    800b84 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b58:	39 f9                	cmp    %edi,%ecx
  800b5a:	77 68                	ja     800bc4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b5c:	85 c9                	test   %ecx,%ecx
  800b5e:	75 0b                	jne    800b6b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b60:	b8 01 00 00 00       	mov    $0x1,%eax
  800b65:	31 d2                	xor    %edx,%edx
  800b67:	f7 f1                	div    %ecx
  800b69:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b6b:	31 d2                	xor    %edx,%edx
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	f7 f1                	div    %ecx
  800b71:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b73:	89 f0                	mov    %esi,%eax
  800b75:	f7 f1                	div    %ecx
  800b77:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b79:	89 f0                	mov    %esi,%eax
  800b7b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b7d:	83 c4 10             	add    $0x10,%esp
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b84:	39 f8                	cmp    %edi,%eax
  800b86:	77 2c                	ja     800bb4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b88:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800b8b:	83 f6 1f             	xor    $0x1f,%esi
  800b8e:	75 4c                	jne    800bdc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b90:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800b92:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b97:	72 0a                	jb     800ba3 <__udivdi3+0x6b>
  800b99:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b9d:	0f 87 ad 00 00 00    	ja     800c50 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ba3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ba8:	89 f0                	mov    %esi,%eax
  800baa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
  800bb3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800bb4:	31 ff                	xor    %edi,%edi
  800bb6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bb8:	89 f0                	mov    %esi,%eax
  800bba:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    
  800bc3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc4:	89 fa                	mov    %edi,%edx
  800bc6:	89 f0                	mov    %esi,%eax
  800bc8:	f7 f1                	div    %ecx
  800bca:	89 c6                	mov    %eax,%esi
  800bcc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bce:	89 f0                	mov    %esi,%eax
  800bd0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
  800bd9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bdc:	89 f1                	mov    %esi,%ecx
  800bde:	d3 e0                	shl    %cl,%eax
  800be0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800be4:	b8 20 00 00 00       	mov    $0x20,%eax
  800be9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800beb:	89 ea                	mov    %ebp,%edx
  800bed:	88 c1                	mov    %al,%cl
  800bef:	d3 ea                	shr    %cl,%edx
  800bf1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bf5:	09 ca                	or     %ecx,%edx
  800bf7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800bfb:	89 f1                	mov    %esi,%ecx
  800bfd:	d3 e5                	shl    %cl,%ebp
  800bff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800c03:	89 fd                	mov    %edi,%ebp
  800c05:	88 c1                	mov    %al,%cl
  800c07:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800c09:	89 fa                	mov    %edi,%edx
  800c0b:	89 f1                	mov    %esi,%ecx
  800c0d:	d3 e2                	shl    %cl,%edx
  800c0f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c13:	88 c1                	mov    %al,%cl
  800c15:	d3 ef                	shr    %cl,%edi
  800c17:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c19:	89 f8                	mov    %edi,%eax
  800c1b:	89 ea                	mov    %ebp,%edx
  800c1d:	f7 74 24 08          	divl   0x8(%esp)
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800c25:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c29:	39 d1                	cmp    %edx,%ecx
  800c2b:	72 17                	jb     800c44 <__udivdi3+0x10c>
  800c2d:	74 09                	je     800c38 <__udivdi3+0x100>
  800c2f:	89 fe                	mov    %edi,%esi
  800c31:	31 ff                	xor    %edi,%edi
  800c33:	e9 41 ff ff ff       	jmp    800b79 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c38:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c3c:	89 f1                	mov    %esi,%ecx
  800c3e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c40:	39 c2                	cmp    %eax,%edx
  800c42:	73 eb                	jae    800c2f <__udivdi3+0xf7>
		{
		  q0--;
  800c44:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c47:	31 ff                	xor    %edi,%edi
  800c49:	e9 2b ff ff ff       	jmp    800b79 <__udivdi3+0x41>
  800c4e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c50:	31 f6                	xor    %esi,%esi
  800c52:	e9 22 ff ff ff       	jmp    800b79 <__udivdi3+0x41>
	...

00800c58 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c58:	55                   	push   %ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	83 ec 20             	sub    $0x20,%esp
  800c5e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c62:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c66:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c6a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800c6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c72:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c76:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800c78:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c7a:	85 ed                	test   %ebp,%ebp
  800c7c:	75 16                	jne    800c94 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800c7e:	39 f1                	cmp    %esi,%ecx
  800c80:	0f 86 a6 00 00 00    	jbe    800d2c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c86:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c88:	89 d0                	mov    %edx,%eax
  800c8a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c8c:	83 c4 20             	add    $0x20,%esp
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
  800c93:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c94:	39 f5                	cmp    %esi,%ebp
  800c96:	0f 87 ac 00 00 00    	ja     800d48 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c9c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800c9f:	83 f0 1f             	xor    $0x1f,%eax
  800ca2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca6:	0f 84 a8 00 00 00    	je     800d54 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cac:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cb0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cb2:	bf 20 00 00 00       	mov    $0x20,%edi
  800cb7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cbb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cbf:	89 f9                	mov    %edi,%ecx
  800cc1:	d3 e8                	shr    %cl,%eax
  800cc3:	09 e8                	or     %ebp,%eax
  800cc5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800cc9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ccd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cd1:	d3 e0                	shl    %cl,%eax
  800cd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd7:	89 f2                	mov    %esi,%edx
  800cd9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cdb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cdf:	d3 e0                	shl    %cl,%eax
  800ce1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ce9:	89 f9                	mov    %edi,%ecx
  800ceb:	d3 e8                	shr    %cl,%eax
  800ced:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cef:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cf1:	89 f2                	mov    %esi,%edx
  800cf3:	f7 74 24 18          	divl   0x18(%esp)
  800cf7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cf9:	f7 64 24 0c          	mull   0xc(%esp)
  800cfd:	89 c5                	mov    %eax,%ebp
  800cff:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d01:	39 d6                	cmp    %edx,%esi
  800d03:	72 67                	jb     800d6c <__umoddi3+0x114>
  800d05:	74 75                	je     800d7c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d07:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d0b:	29 e8                	sub    %ebp,%eax
  800d0d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d0f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 f2                	mov    %esi,%edx
  800d17:	89 f9                	mov    %edi,%ecx
  800d19:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d1b:	09 d0                	or     %edx,%eax
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d23:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d25:	83 c4 20             	add    $0x20,%esp
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d2c:	85 c9                	test   %ecx,%ecx
  800d2e:	75 0b                	jne    800d3b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d30:	b8 01 00 00 00       	mov    $0x1,%eax
  800d35:	31 d2                	xor    %edx,%edx
  800d37:	f7 f1                	div    %ecx
  800d39:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	31 d2                	xor    %edx,%edx
  800d3f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d41:	89 f8                	mov    %edi,%eax
  800d43:	e9 3e ff ff ff       	jmp    800c86 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d48:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d4a:	83 c4 20             	add    $0x20,%esp
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
  800d51:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d54:	39 f5                	cmp    %esi,%ebp
  800d56:	72 04                	jb     800d5c <__umoddi3+0x104>
  800d58:	39 f9                	cmp    %edi,%ecx
  800d5a:	77 06                	ja     800d62 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d5c:	89 f2                	mov    %esi,%edx
  800d5e:	29 cf                	sub    %ecx,%edi
  800d60:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d62:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d64:	83 c4 20             	add    $0x20,%esp
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    
  800d6b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d6c:	89 d1                	mov    %edx,%ecx
  800d6e:	89 c5                	mov    %eax,%ebp
  800d70:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d74:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d78:	eb 8d                	jmp    800d07 <__umoddi3+0xaf>
  800d7a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d7c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d80:	72 ea                	jb     800d6c <__umoddi3+0x114>
  800d82:	89 f1                	mov    %esi,%ecx
  800d84:	eb 81                	jmp    800d07 <__umoddi3+0xaf>
