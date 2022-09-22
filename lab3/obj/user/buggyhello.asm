
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 6e 00 00 00       	call   8000bc <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005e:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800065:	00 00 00 
	thisenv = envs + ENVX(sys_getenvid());
  800068:	e8 de 00 00 00       	call   80014b <sys_getenvid>
  80006d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800072:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800075:	c1 e0 05             	shl    $0x5,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 10 80 00       	mov    %eax,0x801004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x3d>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 3f 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	b8 03 00 00 00       	mov    $0x3,%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800117:	85 c0                	test   %eax,%eax
  800119:	7e 28                	jle    800143 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800126:	00 
  800127:	c7 44 24 08 8e 0d 80 	movl   $0x800d8e,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 ab 0d 80 00 	movl   $0x800dab,(%esp)
  80013e:	e8 29 00 00 00       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800143:	83 c4 2c             	add    $0x2c,%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    
	...

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  80017d:	e8 c9 ff ff ff       	call   80014b <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 bc 0d 80 00 	movl   $0x800dbc,(%esp)
  80019f:	e8 c0 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 50 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 e0 0d 80 00 	movl   $0x800de0,(%esp)
  8001ba:	e8 a5 00 00 00       	call   800264 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	40                   	inc    %eax
  8001d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 19                	jne    8001fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e8:	00 
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 c8 fe ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  8001f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fa:	ff 43 04             	incl   0x4(%ebx)
}
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	5b                   	pop    %ebx
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800213:	00 00 00 
	b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  80023f:	e8 82 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800244:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 60 fe ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 87 ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	75 08                	jne    8002ac <printnum+0x2c>
  8002a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002aa:	77 57                	ja     800303 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b0:	4b                   	dec    %ebx
  8002b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cb:	00 
  8002cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	e8 56 08 00 00       	call   800b34 <__udivdi3>
  8002de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	89 fa                	mov    %edi,%edx
  8002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f2:	e8 89 ff ff ff       	call   800280 <printnum>
  8002f7:	eb 0f                	jmp    800308 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fd:	89 34 24             	mov    %esi,(%esp)
  800300:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800303:	4b                   	dec    %ebx
  800304:	85 db                	test   %ebx,%ebx
  800306:	7f f1                	jg     8002f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800310:	8b 45 10             	mov    0x10(%ebp),%eax
  800313:	89 44 24 08          	mov    %eax,0x8(%esp)
  800317:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031e:	00 
  80031f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	e8 23 09 00 00       	call   800c54 <__umoddi3>
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	0f be 80 e2 0d 80 00 	movsbl 0x800de2(%eax),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800342:	83 c4 3c             	add    $0x3c,%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 08             	lea    0x8(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x38>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	3b 50 04             	cmp    0x4(%eax),%edx
  800392:	73 08                	jae    80039c <sprintputch+0x18>
		*b->buf++ = ch;
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 0a                	mov    %cl,(%edx)
  800399:	42                   	inc    %edx
  80039a:	89 10                	mov    %edx,(%eax)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 02 00 00 00       	call   8003c6 <vprintfmt>
	va_end(ap);
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 4c             	sub    $0x4c,%esp
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 6b 03 00 00    	je     80074a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	46                   	inc    %esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e5                	jne    8003d7 <vprintfmt+0x11>
  8003f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	eb 26                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800413:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800417:	eb 1d                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800420:	eb 14                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800425:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042c:	eb 08                	jmp    800436 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800431:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	0f b6 06             	movzbl (%esi),%eax
  800439:	8d 56 01             	lea    0x1(%esi),%edx
  80043c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043f:	8a 16                	mov    (%esi),%dl
  800441:	83 ea 23             	sub    $0x23,%edx
  800444:	80 fa 55             	cmp    $0x55,%dl
  800447:	0f 87 e1 02 00 00    	ja     80072e <vprintfmt+0x368>
  80044d:	0f b6 d2             	movzbl %dl,%edx
  800450:	ff 24 95 70 0e 80 00 	jmp    *0x800e70(,%edx,4)
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800462:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800466:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046c:	83 fa 09             	cmp    $0x9,%edx
  80046f:	77 2a                	ja     80049b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800471:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800472:	eb eb                	jmp    80045f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800482:	eb 17                	jmp    80049b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800488:	78 98                	js     800422 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048d:	eb a7                	jmp    800436 <vprintfmt+0x70>
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800492:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800499:	eb 9b                	jmp    800436 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049f:	79 95                	jns    800436 <vprintfmt+0x70>
  8004a1:	eb 8b                	jmp    80042e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a7:	eb 8d                	jmp    800436 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b6:	8b 00                	mov    (%eax),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 23 ff ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 02                	jns    8004d7 <vprintfmt+0x111>
  8004d5:	f7 d8                	neg    %eax
  8004d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 06             	cmp    $0x6,%eax
  8004dc:	7f 0b                	jg     8004e9 <vprintfmt+0x123>
  8004de:	8b 04 85 c8 0f 80 00 	mov    0x800fc8(,%eax,4),%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 23                	jne    80050c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ed:	c7 44 24 08 fa 0d 80 	movl   $0x800dfa,0x8(%esp)
  8004f4:	00 
  8004f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	e8 9a fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800507:	e9 dd fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	c7 44 24 08 03 0e 80 	movl   $0x800e03,0x8(%esp)
  800517:	00 
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 55 08             	mov    0x8(%ebp),%edx
  80051f:	89 14 24             	mov    %edx,(%esp)
  800522:	e8 77 fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 ba fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
  80052f:	89 f9                	mov    %edi,%ecx
  800531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 30                	mov    (%eax),%esi
  800542:	85 f6                	test   %esi,%esi
  800544:	75 05                	jne    80054b <vprintfmt+0x185>
				p = "(null)";
  800546:	be f3 0d 80 00       	mov    $0x800df3,%esi
			if (width > 0 && padc != '-')
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	0f 8e 84 00 00 00    	jle    8005d9 <vprintfmt+0x213>
  800555:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800559:	74 7e                	je     8005d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 8b 02 00 00       	call   8007f2 <strnlen>
  800567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800573:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800576:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800579:	89 de                	mov    %ebx,%esi
  80057b:	89 d3                	mov    %edx,%ebx
  80057d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	89 3c 24             	mov    %edi,(%esp)
  800588:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	4b                   	dec    %ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f f1                	jg     800581 <vprintfmt+0x1bb>
  800590:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800593:	89 f3                	mov    %esi,%ebx
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059b:	85 c0                	test   %eax,%eax
  80059d:	79 05                	jns    8005a4 <vprintfmt+0x1de>
  80059f:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a7:	29 c2                	sub    %eax,%edx
  8005a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ac:	eb 2b                	jmp    8005d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b2:	74 18                	je     8005cc <vprintfmt+0x206>
  8005b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ba:	76 10                	jbe    8005cc <vprintfmt+0x206>
					putch('?', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
  8005ca:	eb 0a                	jmp    8005d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	46                   	inc    %esi
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	74 21                	je     800602 <vprintfmt+0x23c>
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	78 c9                	js     8005ae <vprintfmt+0x1e8>
  8005e5:	4f                   	dec    %edi
  8005e6:	79 c6                	jns    8005ae <vprintfmt+0x1e8>
  8005e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005eb:	89 de                	mov    %ebx,%esi
  8005ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f0:	eb 18                	jmp    80060a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	4b                   	dec    %ebx
  800600:	eb 08                	jmp    80060a <vprintfmt+0x244>
  800602:	8b 7d 08             	mov    0x8(%ebp),%edi
  800605:	89 de                	mov    %ebx,%esi
  800607:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	7f e4                	jg     8005f2 <vprintfmt+0x22c>
  80060e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800611:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800616:	e9 ce fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7e 10                	jle    800630 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 08             	lea    0x8(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	8b 78 04             	mov    0x4(%eax),%edi
  80062e:	eb 26                	jmp    800656 <vprintfmt+0x290>
	else if (lflag)
  800630:	85 c9                	test   %ecx,%ecx
  800632:	74 12                	je     800646 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 30                	mov    (%eax),%esi
  80063f:	89 f7                	mov    %esi,%edi
  800641:	c1 ff 1f             	sar    $0x1f,%edi
  800644:	eb 10                	jmp    800656 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 30                	mov    (%eax),%esi
  800651:	89 f7                	mov    %esi,%edi
  800653:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800656:	85 ff                	test   %edi,%edi
  800658:	78 0a                	js     800664 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 8c 00 00 00       	jmp    8006f0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800672:	f7 de                	neg    %esi
  800674:	83 d7 00             	adc    $0x0,%edi
  800677:	f7 df                	neg    %edi
			}
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	eb 70                	jmp    8006f0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 c0 fc ff ff       	call   80034a <getuint>
  80068a:	89 c6                	mov    %eax,%esi
  80068c:	89 d7                	mov    %edx,%edi
			base = 10;
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800693:	eb 5b                	jmp    8006f0 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 ab fc ff ff       	call   80034a <getuint>
  80069f:	89 c6                	mov    %eax,%esi
  8006a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a8:	eb 46                	jmp    8006f0 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 63 fc ff ff       	call   80034a <getuint>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800703:	89 34 24             	mov    %esi,(%esp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 6c fb ff ff       	call   800280 <printnum>
			break;
  800714:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800717:	e9 cd fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 bb fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	eb 01                	jmp    80073f <vprintfmt+0x379>
  80073e:	4e                   	dec    %esi
  80073f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800743:	75 f9                	jne    80073e <vprintfmt+0x378>
  800745:	e9 9f fc ff ff       	jmp    8003e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 4c             	add    $0x4c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 33                	jle    8007aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800793:	e8 2e fc ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 0c                	jmp    8007af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb 05                	jmp    8007af <vsnprintf+0x5d>
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 7b ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800821:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f5                	jne    80081e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	89 1c 24             	mov    %ebx,(%esp)
  800839:	e8 9e ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 54 24 04          	mov    %edx,0x4(%esp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 c0 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 0c                	jmp    800878 <strncpy+0x21>
		*dst++ = *src;
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 3a 01             	cmpb   $0x1,(%edx)
  800874:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	41                   	inc    %ecx
  800878:	39 f1                	cmp    %esi,%ecx
  80087a:	75 f0                	jne    80086c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1c>
  800892:	89 f0                	mov    %esi,%eax
  800894:	eb 1a                	jmp    8008b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	88 18                	mov    %bl,(%eax)
  800898:	40                   	inc    %eax
  800899:	41                   	inc    %ecx
  80089a:	eb 02                	jmp    80089e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089e:	4a                   	dec    %edx
  80089f:	74 0a                	je     8008ab <strlcpy+0x2b>
  8008a1:	8a 19                	mov    (%ecx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strlcpy+0x16>
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 02                	jmp    8008ad <strlcpy+0x2d>
  8008ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 02                	jmp    8008c3 <strcmp+0xd>
		p++, q++;
  8008c1:	41                   	inc    %ecx
  8008c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	8a 01                	mov    (%ecx),%al
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x17>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 f4                	je     8008c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 03                	jmp    8008e9 <strncmp+0x12>
		n--, p++, q++;
  8008e6:	4a                   	dec    %edx
  8008e7:	40                   	inc    %eax
  8008e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 14                	je     800901 <strncmp+0x2a>
  8008ed:	8a 18                	mov    (%eax),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	74 04                	je     8008f7 <strncmp+0x20>
  8008f3:	3a 19                	cmp    (%ecx),%bl
  8008f5:	74 ef                	je     8008e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb 05                	jmp    800906 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	eb 05                	jmp    800919 <strchr+0x10>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0c                	je     800924 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092f:	eb 05                	jmp    800936 <strfind+0x10>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 07                	je     80093c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800935:	40                   	inc    %eax
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f5                	jne    800931 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 30                	je     800981 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 25                	jne    80097e <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 20                	jne    80097e <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 d0                	or     %edx,%eax
  800974:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb 03                	jmp    800981 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 34                	jae    8009ce <memmove+0x46>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2d                	jae    8009ce <memmove+0x46>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x3c>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x3c>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 07                	jmp    8009cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	4f                   	dec    %edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 20                	jmp    8009ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	75 13                	jne    8009e9 <memmove+0x61>
  8009d6:	a8 03                	test   $0x3,%al
  8009d8:	75 0f                	jne    8009e9 <memmove+0x61>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 77 ff ff ff       	call   800988 <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	eb 16                	jmp    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
  800a29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a2c:	42                   	inc    %edx
  800a2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a31:	38 c8                	cmp    %cl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 c9             	movzbl %cl,%ecx
  800a3b:	29 c8                	sub    %ecx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 e6                	jne    800a29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 05                	jmp    800a62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	40                   	inc    %eax
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	72 f7                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 01                	jmp    800a77 <strtol+0xf>
		s++;
  800a76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f9                	je     800a76 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f5                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 08                	jne    800a8d <strtol+0x25>
		s++;
  800a85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x33>
		s++, neg = 1;
  800a91:	8d 52 01             	lea    0x1(%edx),%edx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi
  800a99:	eb 05                	jmp    800aa0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 05                	je     800aa9 <strtol+0x41>
  800aa4:	83 fb 10             	cmp    $0x10,%ebx
  800aa7:	75 28                	jne    800ad1 <strtol+0x69>
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 10                	jne    800abf <strtol+0x57>
  800aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab3:	75 0a                	jne    800abf <strtol+0x57>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 12                	jmp    800ad1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 0e                	jne    800ad1 <strtol+0x69>
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 05                	jne    800acc <strtol+0x64>
		s++, base = 8;
  800ac7:	42                   	inc    %edx
  800ac8:	b3 08                	mov    $0x8,%bl
  800aca:	eb 05                	jmp    800ad1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 0a                	mov    (%edx),%cl
  800ada:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x82>
			dig = *s - '0';
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 30             	sub    $0x30,%ecx
  800ae8:	eb 1e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x92>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 12                	ja     800b14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b08:	39 f1                	cmp    %esi,%ecx
  800b0a:	7d 0c                	jge    800b18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b0c:	42                   	inc    %edx
  800b0d:	0f af c6             	imul   %esi,%eax
  800b10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb c4                	jmp    800ad8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	89 c1                	mov    %eax,%ecx
  800b16:	eb 02                	jmp    800b1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 05                	je     800b25 <strtol+0xbd>
		*endptr = (char *) s;
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b25:	85 ff                	test   %edi,%edi
  800b27:	74 04                	je     800b2d <strtol+0xc5>
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b34:	55                   	push   %ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	83 ec 10             	sub    $0x10,%esp
  800b3a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b3e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b42:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b46:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800b4a:	89 cd                	mov    %ecx,%ebp
  800b4c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	75 2c                	jne    800b80 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b54:	39 f9                	cmp    %edi,%ecx
  800b56:	77 68                	ja     800bc0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b58:	85 c9                	test   %ecx,%ecx
  800b5a:	75 0b                	jne    800b67 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b61:	31 d2                	xor    %edx,%edx
  800b63:	f7 f1                	div    %ecx
  800b65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b67:	31 d2                	xor    %edx,%edx
  800b69:	89 f8                	mov    %edi,%eax
  800b6b:	f7 f1                	div    %ecx
  800b6d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b6f:	89 f0                	mov    %esi,%eax
  800b71:	f7 f1                	div    %ecx
  800b73:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b75:	89 f0                	mov    %esi,%eax
  800b77:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b79:	83 c4 10             	add    $0x10,%esp
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b80:	39 f8                	cmp    %edi,%eax
  800b82:	77 2c                	ja     800bb0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b84:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800b87:	83 f6 1f             	xor    $0x1f,%esi
  800b8a:	75 4c                	jne    800bd8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b8c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800b8e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b93:	72 0a                	jb     800b9f <__udivdi3+0x6b>
  800b95:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b99:	0f 87 ad 00 00 00    	ja     800c4c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800b9f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ba4:	89 f0                	mov    %esi,%eax
  800ba6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    
  800baf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800bb0:	31 ff                	xor    %edi,%edi
  800bb2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bb4:	89 f0                	mov    %esi,%eax
  800bb6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bb8:	83 c4 10             	add    $0x10,%esp
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    
  800bbf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc0:	89 fa                	mov    %edi,%edx
  800bc2:	89 f0                	mov    %esi,%eax
  800bc4:	f7 f1                	div    %ecx
  800bc6:	89 c6                	mov    %eax,%esi
  800bc8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bca:	89 f0                	mov    %esi,%eax
  800bcc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
  800bd5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bd8:	89 f1                	mov    %esi,%ecx
  800bda:	d3 e0                	shl    %cl,%eax
  800bdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800be0:	b8 20 00 00 00       	mov    $0x20,%eax
  800be5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800be7:	89 ea                	mov    %ebp,%edx
  800be9:	88 c1                	mov    %al,%cl
  800beb:	d3 ea                	shr    %cl,%edx
  800bed:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bf1:	09 ca                	or     %ecx,%edx
  800bf3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800bf7:	89 f1                	mov    %esi,%ecx
  800bf9:	d3 e5                	shl    %cl,%ebp
  800bfb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800bff:	89 fd                	mov    %edi,%ebp
  800c01:	88 c1                	mov    %al,%cl
  800c03:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800c05:	89 fa                	mov    %edi,%edx
  800c07:	89 f1                	mov    %esi,%ecx
  800c09:	d3 e2                	shl    %cl,%edx
  800c0b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c0f:	88 c1                	mov    %al,%cl
  800c11:	d3 ef                	shr    %cl,%edi
  800c13:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c15:	89 f8                	mov    %edi,%eax
  800c17:	89 ea                	mov    %ebp,%edx
  800c19:	f7 74 24 08          	divl   0x8(%esp)
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800c21:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c25:	39 d1                	cmp    %edx,%ecx
  800c27:	72 17                	jb     800c40 <__udivdi3+0x10c>
  800c29:	74 09                	je     800c34 <__udivdi3+0x100>
  800c2b:	89 fe                	mov    %edi,%esi
  800c2d:	31 ff                	xor    %edi,%edi
  800c2f:	e9 41 ff ff ff       	jmp    800b75 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c34:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c38:	89 f1                	mov    %esi,%ecx
  800c3a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c3c:	39 c2                	cmp    %eax,%edx
  800c3e:	73 eb                	jae    800c2b <__udivdi3+0xf7>
		{
		  q0--;
  800c40:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c43:	31 ff                	xor    %edi,%edi
  800c45:	e9 2b ff ff ff       	jmp    800b75 <__udivdi3+0x41>
  800c4a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c4c:	31 f6                	xor    %esi,%esi
  800c4e:	e9 22 ff ff ff       	jmp    800b75 <__udivdi3+0x41>
	...

00800c54 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c54:	55                   	push   %ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	83 ec 20             	sub    $0x20,%esp
  800c5a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c5e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c62:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c66:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800c6a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c6e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c72:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800c74:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c76:	85 ed                	test   %ebp,%ebp
  800c78:	75 16                	jne    800c90 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800c7a:	39 f1                	cmp    %esi,%ecx
  800c7c:	0f 86 a6 00 00 00    	jbe    800d28 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c82:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c84:	89 d0                	mov    %edx,%eax
  800c86:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c88:	83 c4 20             	add    $0x20,%esp
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
  800c8f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c90:	39 f5                	cmp    %esi,%ebp
  800c92:	0f 87 ac 00 00 00    	ja     800d44 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c98:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800c9b:	83 f0 1f             	xor    $0x1f,%eax
  800c9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca2:	0f 84 a8 00 00 00    	je     800d50 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ca8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cac:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cae:	bf 20 00 00 00       	mov    $0x20,%edi
  800cb3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cb7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cbb:	89 f9                	mov    %edi,%ecx
  800cbd:	d3 e8                	shr    %cl,%eax
  800cbf:	09 e8                	or     %ebp,%eax
  800cc1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800cc5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cc9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ccd:	d3 e0                	shl    %cl,%eax
  800ccf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd3:	89 f2                	mov    %esi,%edx
  800cd5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cd7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cdb:	d3 e0                	shl    %cl,%eax
  800cdd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce1:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ce5:	89 f9                	mov    %edi,%ecx
  800ce7:	d3 e8                	shr    %cl,%eax
  800ce9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ceb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ced:	89 f2                	mov    %esi,%edx
  800cef:	f7 74 24 18          	divl   0x18(%esp)
  800cf3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cf5:	f7 64 24 0c          	mull   0xc(%esp)
  800cf9:	89 c5                	mov    %eax,%ebp
  800cfb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cfd:	39 d6                	cmp    %edx,%esi
  800cff:	72 67                	jb     800d68 <__umoddi3+0x114>
  800d01:	74 75                	je     800d78 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d03:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d07:	29 e8                	sub    %ebp,%eax
  800d09:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d0f:	d3 e8                	shr    %cl,%eax
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	89 f9                	mov    %edi,%ecx
  800d15:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d17:	09 d0                	or     %edx,%eax
  800d19:	89 f2                	mov    %esi,%edx
  800d1b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d1f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d21:	83 c4 20             	add    $0x20,%esp
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d28:	85 c9                	test   %ecx,%ecx
  800d2a:	75 0b                	jne    800d37 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	f7 f1                	div    %ecx
  800d35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d37:	89 f0                	mov    %esi,%eax
  800d39:	31 d2                	xor    %edx,%edx
  800d3b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d3d:	89 f8                	mov    %edi,%eax
  800d3f:	e9 3e ff ff ff       	jmp    800c82 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d46:	83 c4 20             	add    $0x20,%esp
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    
  800d4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d50:	39 f5                	cmp    %esi,%ebp
  800d52:	72 04                	jb     800d58 <__umoddi3+0x104>
  800d54:	39 f9                	cmp    %edi,%ecx
  800d56:	77 06                	ja     800d5e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d58:	89 f2                	mov    %esi,%edx
  800d5a:	29 cf                	sub    %ecx,%edi
  800d5c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d5e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d60:	83 c4 20             	add    $0x20,%esp
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    
  800d67:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d68:	89 d1                	mov    %edx,%ecx
  800d6a:	89 c5                	mov    %eax,%ebp
  800d6c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d70:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d74:	eb 8d                	jmp    800d03 <__umoddi3+0xaf>
  800d76:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d78:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d7c:	72 ea                	jb     800d68 <__umoddi3+0x114>
  800d7e:	89 f1                	mov    %esi,%ecx
  800d80:	eb 81                	jmp    800d03 <__umoddi3+0xaf>
