
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 17 02 00 00       	call   800248 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 fb 0c 00 00       	call   800d51 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 80 21 80 	movl   $0x802180,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 93 21 80 00 	movl   $0x802193,(%esp)
  800075:	e8 42 02 00 00       	call   8002bc <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 07 0d 00 00       	call   800da5 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 a3 21 80 	movl   $0x8021a3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 93 21 80 00 	movl   $0x802193,(%esp)
  8000bd:	e8 fa 01 00 00       	call   8002bc <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 fe 09 00 00       	call   800ad8 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 0a 0d 00 00       	call   800df8 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 93 21 80 00 	movl   $0x802193,(%esp)
  80010d:	e8 aa 01 00 00       	call   8002bc <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 c7 21 80 	movl   $0x8021c7,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 93 21 80 00 	movl   $0x802193,(%esp)
  80014d:	e8 6a 01 00 00       	call   8002bc <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 25                	jne    80017b <dumbfork+0x62>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  80015c:	e8 b2 0b 00 00       	call   800d13 <sys_getenvid>
  800161:	25 ff 03 00 00       	and    $0x3ff,%eax
  800166:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80016d:	c1 e0 07             	shl    $0x7,%eax
  800170:	29 d0                	sub    %edx,%eax
  800172:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800177:	89 03                	mov    %eax,(%ebx)
		return 0;
  800179:	eb 6e                	jmp    8001e9 <dumbfork+0xd0>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017b:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800182:	eb 13                	jmp    800197 <dumbfork+0x7e>
		duppage(envid, addr);
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	89 1c 24             	mov    %ebx,(%esp)
  80018b:	e8 a4 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800190:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800197:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80019a:	3d 00 60 80 00       	cmp    $0x806000,%eax
  80019f:	72 e3                	jb     800184 <dumbfork+0x6b>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	89 34 24             	mov    %esi,(%esp)
  8001b0:	e8 7f fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001bc:	00 
  8001bd:	89 34 24             	mov    %esi,(%esp)
  8001c0:	e8 86 0c 00 00       	call   800e4b <sys_env_set_status>
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	79 20                	jns    8001e9 <dumbfork+0xd0>
		panic("sys_env_set_status: %e", r);
  8001c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cd:	c7 44 24 08 d7 21 80 	movl   $0x8021d7,0x8(%esp)
  8001d4:	00 
  8001d5:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001dc:	00 
  8001dd:	c7 04 24 93 21 80 00 	movl   $0x802193,(%esp)
  8001e4:	e8 d3 00 00 00       	call   8002bc <_panic>

	return envid;
}
  8001e9:	89 f0                	mov    %esi,%eax
  8001eb:	83 c4 20             	add    $0x20,%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001fa:	e8 1a ff ff ff       	call   800119 <dumbfork>
  8001ff:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800201:	be 00 00 00 00       	mov    $0x0,%esi
  800206:	eb 2a                	jmp    800232 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800208:	85 db                	test   %ebx,%ebx
  80020a:	74 07                	je     800213 <umain+0x21>
  80020c:	b8 ee 21 80 00       	mov    $0x8021ee,%eax
  800211:	eb 05                	jmp    800218 <umain+0x26>
  800213:	b8 f5 21 80 00       	mov    $0x8021f5,%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800220:	c7 04 24 fb 21 80 00 	movl   $0x8021fb,(%esp)
  800227:	e8 88 01 00 00       	call   8003b4 <cprintf>
		sys_yield();
  80022c:	e8 01 0b 00 00       	call   800d32 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800231:	46                   	inc    %esi
  800232:	83 fb 01             	cmp    $0x1,%ebx
  800235:	19 c0                	sbb    %eax,%eax
  800237:	83 e0 0a             	and    $0xa,%eax
  80023a:	83 c0 0a             	add    $0xa,%eax
  80023d:	39 c6                	cmp    %eax,%esi
  80023f:	7c c7                	jl     800208 <umain+0x16>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	5b                   	pop    %ebx
  800245:	5e                   	pop    %esi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 20             	sub    $0x20,%esp
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800256:	e8 b8 0a 00 00       	call   800d13 <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800267:	c1 e0 07             	shl    $0x7,%eax
  80026a:	29 d0                	sub    %edx,%eax
  80026c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800271:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800274:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800277:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027c:	85 f6                	test   %esi,%esi
  80027e:	7e 07                	jle    800287 <libmain+0x3f>
		binaryname = argv[0];
  800280:	8b 03                	mov    (%ebx),%eax
  800282:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800287:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80028b:	89 34 24             	mov    %esi,(%esp)
  80028e:	e8 5f ff ff ff       	call   8001f2 <umain>

	// exit gracefully
	exit();
  800293:	e8 08 00 00 00       	call   8002a0 <exit>
}
  800298:	83 c4 20             	add    $0x20,%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    
	...

008002a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002a6:	e8 fa 0e 00 00       	call   8011a5 <close_all>
	sys_env_destroy(0);
  8002ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b2:	e8 0a 0a 00 00       	call   800cc1 <sys_env_destroy>
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    
  8002b9:	00 00                	add    %al,(%eax)
	...

008002bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002cd:	e8 41 0a 00 00       	call   800d13 <sys_getenvid>
  8002d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e8:	c7 04 24 18 22 80 00 	movl   $0x802218,(%esp)
  8002ef:	e8 c0 00 00 00       	call   8003b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	e8 50 00 00 00       	call   800353 <vcprintf>
	cprintf("\n");
  800303:	c7 04 24 6a 26 80 00 	movl   $0x80266a,(%esp)
  80030a:	e8 a5 00 00 00       	call   8003b4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x53>
	...

00800314 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	53                   	push   %ebx
  800318:	83 ec 14             	sub    $0x14,%esp
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031e:	8b 03                	mov    (%ebx),%eax
  800320:	8b 55 08             	mov    0x8(%ebp),%edx
  800323:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800327:	40                   	inc    %eax
  800328:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 19                	jne    80034a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800331:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800338:	00 
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	e8 40 09 00 00       	call   800c84 <sys_cputs>
		b->idx = 0;
  800344:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80034a:	ff 43 04             	incl   0x4(%ebx)
}
  80034d:	83 c4 14             	add    $0x14,%esp
  800350:	5b                   	pop    %ebx
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80035c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800363:	00 00 00 
	b.cnt = 0;
  800366:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800384:	89 44 24 04          	mov    %eax,0x4(%esp)
  800388:	c7 04 24 14 03 80 00 	movl   $0x800314,(%esp)
  80038f:	e8 82 01 00 00       	call   800516 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800394:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80039a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	e8 d8 08 00 00       	call   800c84 <sys_cputs>

	return b.cnt;
}
  8003ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 87 ff ff ff       	call   800353 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    
	...

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 3c             	sub    $0x3c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	75 08                	jne    8003fc <printnum+0x2c>
  8003f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003fa:	77 57                	ja     800453 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003fc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800400:	4b                   	dec    %ebx
  800401:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800405:	8b 45 10             	mov    0x10(%ebp),%eax
  800408:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800410:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800414:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80041b:	00 
  80041c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041f:	89 04 24             	mov    %eax,(%esp)
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	89 44 24 04          	mov    %eax,0x4(%esp)
  800429:	e8 fa 1a 00 00       	call   801f28 <__udivdi3>
  80042e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800432:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800436:	89 04 24             	mov    %eax,(%esp)
  800439:	89 54 24 04          	mov    %edx,0x4(%esp)
  80043d:	89 fa                	mov    %edi,%edx
  80043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800442:	e8 89 ff ff ff       	call   8003d0 <printnum>
  800447:	eb 0f                	jmp    800458 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800449:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044d:	89 34 24             	mov    %esi,(%esp)
  800450:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800453:	4b                   	dec    %ebx
  800454:	85 db                	test   %ebx,%ebx
  800456:	7f f1                	jg     800449 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800458:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80045c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800460:	8b 45 10             	mov    0x10(%ebp),%eax
  800463:	89 44 24 08          	mov    %eax,0x8(%esp)
  800467:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80046e:	00 
  80046f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800472:	89 04 24             	mov    %eax,(%esp)
  800475:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047c:	e8 c7 1b 00 00       	call   802048 <__umoddi3>
  800481:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800485:	0f be 80 3b 22 80 00 	movsbl 0x80223b(%eax),%eax
  80048c:	89 04 24             	mov    %eax,(%esp)
  80048f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800492:	83 c4 3c             	add    $0x3c,%esp
  800495:	5b                   	pop    %ebx
  800496:	5e                   	pop    %esi
  800497:	5f                   	pop    %edi
  800498:	5d                   	pop    %ebp
  800499:	c3                   	ret    

0080049a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049d:	83 fa 01             	cmp    $0x1,%edx
  8004a0:	7e 0e                	jle    8004b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a7:	89 08                	mov    %ecx,(%eax)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	8b 52 04             	mov    0x4(%edx),%edx
  8004ae:	eb 22                	jmp    8004d2 <getuint+0x38>
	else if (lflag)
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 10                	je     8004c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b4:	8b 10                	mov    (%eax),%edx
  8004b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b9:	89 08                	mov    %ecx,(%eax)
  8004bb:	8b 02                	mov    (%edx),%eax
  8004bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c2:	eb 0e                	jmp    8004d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c4:	8b 10                	mov    (%eax),%edx
  8004c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c9:	89 08                	mov    %ecx,(%eax)
  8004cb:	8b 02                	mov    (%edx),%eax
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d2:	5d                   	pop    %ebp
  8004d3:	c3                   	ret    

008004d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004da:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e2:	73 08                	jae    8004ec <sprintputch+0x18>
		*b->buf++ = ch;
  8004e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e7:	88 0a                	mov    %cl,(%edx)
  8004e9:	42                   	inc    %edx
  8004ea:	89 10                	mov    %edx,(%eax)
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800502:	8b 45 0c             	mov    0xc(%ebp),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	e8 02 00 00 00       	call   800516 <vprintfmt>
	va_end(ap);
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	57                   	push   %edi
  80051a:	56                   	push   %esi
  80051b:	53                   	push   %ebx
  80051c:	83 ec 4c             	sub    $0x4c,%esp
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	8b 75 10             	mov    0x10(%ebp),%esi
  800525:	eb 12                	jmp    800539 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800527:	85 c0                	test   %eax,%eax
  800529:	0f 84 6b 03 00 00    	je     80089a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80052f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800539:	0f b6 06             	movzbl (%esi),%eax
  80053c:	46                   	inc    %esi
  80053d:	83 f8 25             	cmp    $0x25,%eax
  800540:	75 e5                	jne    800527 <vprintfmt+0x11>
  800542:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800546:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80054d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800552:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800559:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055e:	eb 26                	jmp    800586 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800563:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800567:	eb 1d                	jmp    800586 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80056c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800570:	eb 14                	jmp    800586 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800575:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80057c:	eb 08                	jmp    800586 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80057e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800581:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	0f b6 06             	movzbl (%esi),%eax
  800589:	8d 56 01             	lea    0x1(%esi),%edx
  80058c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058f:	8a 16                	mov    (%esi),%dl
  800591:	83 ea 23             	sub    $0x23,%edx
  800594:	80 fa 55             	cmp    $0x55,%dl
  800597:	0f 87 e1 02 00 00    	ja     80087e <vprintfmt+0x368>
  80059d:	0f b6 d2             	movzbl %dl,%edx
  8005a0:	ff 24 95 80 23 80 00 	jmp    *0x802380(,%edx,4)
  8005a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005aa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005af:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005b2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005b6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005bc:	83 fa 09             	cmp    $0x9,%edx
  8005bf:	77 2a                	ja     8005eb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c2:	eb eb                	jmp    8005af <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d2:	eb 17                	jmp    8005eb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d8:	78 98                	js     800572 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005dd:	eb a7                	jmp    800586 <vprintfmt+0x70>
  8005df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005e9:	eb 9b                	jmp    800586 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ef:	79 95                	jns    800586 <vprintfmt+0x70>
  8005f1:	eb 8b                	jmp    80057e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f7:	eb 8d                	jmp    800586 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	89 04 24             	mov    %eax,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800611:	e9 23 ff ff ff       	jmp    800539 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	85 c0                	test   %eax,%eax
  800623:	79 02                	jns    800627 <vprintfmt+0x111>
  800625:	f7 d8                	neg    %eax
  800627:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800629:	83 f8 0f             	cmp    $0xf,%eax
  80062c:	7f 0b                	jg     800639 <vprintfmt+0x123>
  80062e:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  800635:	85 c0                	test   %eax,%eax
  800637:	75 23                	jne    80065c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800639:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80063d:	c7 44 24 08 53 22 80 	movl   $0x802253,0x8(%esp)
  800644:	00 
  800645:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800649:	8b 45 08             	mov    0x8(%ebp),%eax
  80064c:	89 04 24             	mov    %eax,(%esp)
  80064f:	e8 9a fe ff ff       	call   8004ee <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800654:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800657:	e9 dd fe ff ff       	jmp    800539 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80065c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800660:	c7 44 24 08 15 26 80 	movl   $0x802615,0x8(%esp)
  800667:	00 
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	8b 55 08             	mov    0x8(%ebp),%edx
  80066f:	89 14 24             	mov    %edx,(%esp)
  800672:	e8 77 fe ff ff       	call   8004ee <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067a:	e9 ba fe ff ff       	jmp    800539 <vprintfmt+0x23>
  80067f:	89 f9                	mov    %edi,%ecx
  800681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800684:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
  800690:	8b 30                	mov    (%eax),%esi
  800692:	85 f6                	test   %esi,%esi
  800694:	75 05                	jne    80069b <vprintfmt+0x185>
				p = "(null)";
  800696:	be 4c 22 80 00       	mov    $0x80224c,%esi
			if (width > 0 && padc != '-')
  80069b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80069f:	0f 8e 84 00 00 00    	jle    800729 <vprintfmt+0x213>
  8006a5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006a9:	74 7e                	je     800729 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006af:	89 34 24             	mov    %esi,(%esp)
  8006b2:	e8 8b 02 00 00       	call   800942 <strnlen>
  8006b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006ba:	29 c2                	sub    %eax,%edx
  8006bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006bf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006c3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006c6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006c9:	89 de                	mov    %ebx,%esi
  8006cb:	89 d3                	mov    %edx,%ebx
  8006cd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	eb 0b                	jmp    8006dc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d5:	89 3c 24             	mov    %edi,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006db:	4b                   	dec    %ebx
  8006dc:	85 db                	test   %ebx,%ebx
  8006de:	7f f1                	jg     8006d1 <vprintfmt+0x1bb>
  8006e0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006e3:	89 f3                	mov    %esi,%ebx
  8006e5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	79 05                	jns    8006f4 <vprintfmt+0x1de>
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f7:	29 c2                	sub    %eax,%edx
  8006f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006fc:	eb 2b                	jmp    800729 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800702:	74 18                	je     80071c <vprintfmt+0x206>
  800704:	8d 50 e0             	lea    -0x20(%eax),%edx
  800707:	83 fa 5e             	cmp    $0x5e,%edx
  80070a:	76 10                	jbe    80071c <vprintfmt+0x206>
					putch('?', putdat);
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800717:	ff 55 08             	call   *0x8(%ebp)
  80071a:	eb 0a                	jmp    800726 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800726:	ff 4d e4             	decl   -0x1c(%ebp)
  800729:	0f be 06             	movsbl (%esi),%eax
  80072c:	46                   	inc    %esi
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 21                	je     800752 <vprintfmt+0x23c>
  800731:	85 ff                	test   %edi,%edi
  800733:	78 c9                	js     8006fe <vprintfmt+0x1e8>
  800735:	4f                   	dec    %edi
  800736:	79 c6                	jns    8006fe <vprintfmt+0x1e8>
  800738:	8b 7d 08             	mov    0x8(%ebp),%edi
  80073b:	89 de                	mov    %ebx,%esi
  80073d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800740:	eb 18                	jmp    80075a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800742:	89 74 24 04          	mov    %esi,0x4(%esp)
  800746:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80074d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074f:	4b                   	dec    %ebx
  800750:	eb 08                	jmp    80075a <vprintfmt+0x244>
  800752:	8b 7d 08             	mov    0x8(%ebp),%edi
  800755:	89 de                	mov    %ebx,%esi
  800757:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80075a:	85 db                	test   %ebx,%ebx
  80075c:	7f e4                	jg     800742 <vprintfmt+0x22c>
  80075e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800761:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800766:	e9 ce fd ff ff       	jmp    800539 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076b:	83 f9 01             	cmp    $0x1,%ecx
  80076e:	7e 10                	jle    800780 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 50 08             	lea    0x8(%eax),%edx
  800776:	89 55 14             	mov    %edx,0x14(%ebp)
  800779:	8b 30                	mov    (%eax),%esi
  80077b:	8b 78 04             	mov    0x4(%eax),%edi
  80077e:	eb 26                	jmp    8007a6 <vprintfmt+0x290>
	else if (lflag)
  800780:	85 c9                	test   %ecx,%ecx
  800782:	74 12                	je     800796 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 50 04             	lea    0x4(%eax),%edx
  80078a:	89 55 14             	mov    %edx,0x14(%ebp)
  80078d:	8b 30                	mov    (%eax),%esi
  80078f:	89 f7                	mov    %esi,%edi
  800791:	c1 ff 1f             	sar    $0x1f,%edi
  800794:	eb 10                	jmp    8007a6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8d 50 04             	lea    0x4(%eax),%edx
  80079c:	89 55 14             	mov    %edx,0x14(%ebp)
  80079f:	8b 30                	mov    (%eax),%esi
  8007a1:	89 f7                	mov    %esi,%edi
  8007a3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007a6:	85 ff                	test   %edi,%edi
  8007a8:	78 0a                	js     8007b4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007af:	e9 8c 00 00 00       	jmp    800840 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007bf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007c2:	f7 de                	neg    %esi
  8007c4:	83 d7 00             	adc    $0x0,%edi
  8007c7:	f7 df                	neg    %edi
			}
			base = 10;
  8007c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ce:	eb 70                	jmp    800840 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007d0:	89 ca                	mov    %ecx,%edx
  8007d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d5:	e8 c0 fc ff ff       	call   80049a <getuint>
  8007da:	89 c6                	mov    %eax,%esi
  8007dc:	89 d7                	mov    %edx,%edi
			base = 10;
  8007de:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007e3:	eb 5b                	jmp    800840 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007e5:	89 ca                	mov    %ecx,%edx
  8007e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ea:	e8 ab fc ff ff       	call   80049a <getuint>
  8007ef:	89 c6                	mov    %eax,%esi
  8007f1:	89 d7                	mov    %edx,%edi
			base = 8;
  8007f3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007f8:	eb 46                	jmp    800840 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800805:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800808:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800813:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80081f:	8b 30                	mov    (%eax),%esi
  800821:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800826:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80082b:	eb 13                	jmp    800840 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80082d:	89 ca                	mov    %ecx,%edx
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 63 fc ff ff       	call   80049a <getuint>
  800837:	89 c6                	mov    %eax,%esi
  800839:	89 d7                	mov    %edx,%edi
			base = 16;
  80083b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800840:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800844:	89 54 24 10          	mov    %edx,0x10(%esp)
  800848:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80084b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80084f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800853:	89 34 24             	mov    %esi,(%esp)
  800856:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085a:	89 da                	mov    %ebx,%edx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	e8 6c fb ff ff       	call   8003d0 <printnum>
			break;
  800864:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800867:	e9 cd fc ff ff       	jmp    800539 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800876:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800879:	e9 bb fc ff ff       	jmp    800539 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800882:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800889:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088c:	eb 01                	jmp    80088f <vprintfmt+0x379>
  80088e:	4e                   	dec    %esi
  80088f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800893:	75 f9                	jne    80088e <vprintfmt+0x378>
  800895:	e9 9f fc ff ff       	jmp    800539 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80089a:	83 c4 4c             	add    $0x4c,%esp
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	5f                   	pop    %edi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 28             	sub    $0x28,%esp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	74 30                	je     8008f3 <vsnprintf+0x51>
  8008c3:	85 d2                	test   %edx,%edx
  8008c5:	7e 33                	jle    8008fa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dc:	c7 04 24 d4 04 80 00 	movl   $0x8004d4,(%esp)
  8008e3:	e8 2e fc ff ff       	call   800516 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f1:	eb 0c                	jmp    8008ff <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f8:	eb 05                	jmp    8008ff <vsnprintf+0x5d>
  8008fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800907:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80090a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090e:	8b 45 10             	mov    0x10(%ebp),%eax
  800911:	89 44 24 08          	mov    %eax,0x8(%esp)
  800915:	8b 45 0c             	mov    0xc(%ebp),%eax
  800918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	e8 7b ff ff ff       	call   8008a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800927:	c9                   	leave  
  800928:	c3                   	ret    
  800929:	00 00                	add    %al,(%eax)
	...

0080092c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
  800937:	eb 01                	jmp    80093a <strlen+0xe>
		n++;
  800939:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80093a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093e:	75 f9                	jne    800939 <strlen+0xd>
		n++;
	return n;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	eb 01                	jmp    800953 <strnlen+0x11>
		n++;
  800952:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800953:	39 d0                	cmp    %edx,%eax
  800955:	74 06                	je     80095d <strnlen+0x1b>
  800957:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80095b:	75 f5                	jne    800952 <strnlen+0x10>
		n++;
	return n;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800969:	ba 00 00 00 00       	mov    $0x0,%edx
  80096e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800971:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800974:	42                   	inc    %edx
  800975:	84 c9                	test   %cl,%cl
  800977:	75 f5                	jne    80096e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800979:	5b                   	pop    %ebx
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	83 ec 08             	sub    $0x8,%esp
  800983:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800986:	89 1c 24             	mov    %ebx,(%esp)
  800989:	e8 9e ff ff ff       	call   80092c <strlen>
	strcpy(dst + len, src);
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	89 54 24 04          	mov    %edx,0x4(%esp)
  800995:	01 d8                	add    %ebx,%eax
  800997:	89 04 24             	mov    %eax,(%esp)
  80099a:	e8 c0 ff ff ff       	call   80095f <strcpy>
	return dst;
}
  80099f:	89 d8                	mov    %ebx,%eax
  8009a1:	83 c4 08             	add    $0x8,%esp
  8009a4:	5b                   	pop    %ebx
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ba:	eb 0c                	jmp    8009c8 <strncpy+0x21>
		*dst++ = *src;
  8009bc:	8a 1a                	mov    (%edx),%bl
  8009be:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c1:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c7:	41                   	inc    %ecx
  8009c8:	39 f1                	cmp    %esi,%ecx
  8009ca:	75 f0                	jne    8009bc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009db:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	75 0a                	jne    8009ec <strlcpy+0x1c>
  8009e2:	89 f0                	mov    %esi,%eax
  8009e4:	eb 1a                	jmp    800a00 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e6:	88 18                	mov    %bl,(%eax)
  8009e8:	40                   	inc    %eax
  8009e9:	41                   	inc    %ecx
  8009ea:	eb 02                	jmp    8009ee <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ec:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009ee:	4a                   	dec    %edx
  8009ef:	74 0a                	je     8009fb <strlcpy+0x2b>
  8009f1:	8a 19                	mov    (%ecx),%bl
  8009f3:	84 db                	test   %bl,%bl
  8009f5:	75 ef                	jne    8009e6 <strlcpy+0x16>
  8009f7:	89 c2                	mov    %eax,%edx
  8009f9:	eb 02                	jmp    8009fd <strlcpy+0x2d>
  8009fb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009fd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a00:	29 f0                	sub    %esi,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0f:	eb 02                	jmp    800a13 <strcmp+0xd>
		p++, q++;
  800a11:	41                   	inc    %ecx
  800a12:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a13:	8a 01                	mov    (%ecx),%al
  800a15:	84 c0                	test   %al,%al
  800a17:	74 04                	je     800a1d <strcmp+0x17>
  800a19:	3a 02                	cmp    (%edx),%al
  800a1b:	74 f4                	je     800a11 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1d:	0f b6 c0             	movzbl %al,%eax
  800a20:	0f b6 12             	movzbl (%edx),%edx
  800a23:	29 d0                	sub    %edx,%eax
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a31:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a34:	eb 03                	jmp    800a39 <strncmp+0x12>
		n--, p++, q++;
  800a36:	4a                   	dec    %edx
  800a37:	40                   	inc    %eax
  800a38:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a39:	85 d2                	test   %edx,%edx
  800a3b:	74 14                	je     800a51 <strncmp+0x2a>
  800a3d:	8a 18                	mov    (%eax),%bl
  800a3f:	84 db                	test   %bl,%bl
  800a41:	74 04                	je     800a47 <strncmp+0x20>
  800a43:	3a 19                	cmp    (%ecx),%bl
  800a45:	74 ef                	je     800a36 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a47:	0f b6 00             	movzbl (%eax),%eax
  800a4a:	0f b6 11             	movzbl (%ecx),%edx
  800a4d:	29 d0                	sub    %edx,%eax
  800a4f:	eb 05                	jmp    800a56 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a62:	eb 05                	jmp    800a69 <strchr+0x10>
		if (*s == c)
  800a64:	38 ca                	cmp    %cl,%dl
  800a66:	74 0c                	je     800a74 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a68:	40                   	inc    %eax
  800a69:	8a 10                	mov    (%eax),%dl
  800a6b:	84 d2                	test   %dl,%dl
  800a6d:	75 f5                	jne    800a64 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a7f:	eb 05                	jmp    800a86 <strfind+0x10>
		if (*s == c)
  800a81:	38 ca                	cmp    %cl,%dl
  800a83:	74 07                	je     800a8c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a85:	40                   	inc    %eax
  800a86:	8a 10                	mov    (%eax),%dl
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	75 f5                	jne    800a81 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a9d:	85 c9                	test   %ecx,%ecx
  800a9f:	74 30                	je     800ad1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa7:	75 25                	jne    800ace <memset+0x40>
  800aa9:	f6 c1 03             	test   $0x3,%cl
  800aac:	75 20                	jne    800ace <memset+0x40>
		c &= 0xFF;
  800aae:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab1:	89 d3                	mov    %edx,%ebx
  800ab3:	c1 e3 08             	shl    $0x8,%ebx
  800ab6:	89 d6                	mov    %edx,%esi
  800ab8:	c1 e6 18             	shl    $0x18,%esi
  800abb:	89 d0                	mov    %edx,%eax
  800abd:	c1 e0 10             	shl    $0x10,%eax
  800ac0:	09 f0                	or     %esi,%eax
  800ac2:	09 d0                	or     %edx,%eax
  800ac4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac9:	fc                   	cld    
  800aca:	f3 ab                	rep stos %eax,%es:(%edi)
  800acc:	eb 03                	jmp    800ad1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ace:	fc                   	cld    
  800acf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad1:	89 f8                	mov    %edi,%eax
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae6:	39 c6                	cmp    %eax,%esi
  800ae8:	73 34                	jae    800b1e <memmove+0x46>
  800aea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	73 2d                	jae    800b1e <memmove+0x46>
		s += n;
		d += n;
  800af1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	f6 c2 03             	test   $0x3,%dl
  800af7:	75 1b                	jne    800b14 <memmove+0x3c>
  800af9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aff:	75 13                	jne    800b14 <memmove+0x3c>
  800b01:	f6 c1 03             	test   $0x3,%cl
  800b04:	75 0e                	jne    800b14 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b06:	83 ef 04             	sub    $0x4,%edi
  800b09:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0f:	fd                   	std    
  800b10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b12:	eb 07                	jmp    800b1b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b14:	4f                   	dec    %edi
  800b15:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b18:	fd                   	std    
  800b19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1b:	fc                   	cld    
  800b1c:	eb 20                	jmp    800b3e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b24:	75 13                	jne    800b39 <memmove+0x61>
  800b26:	a8 03                	test   $0x3,%al
  800b28:	75 0f                	jne    800b39 <memmove+0x61>
  800b2a:	f6 c1 03             	test   $0x3,%cl
  800b2d:	75 0a                	jne    800b39 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	fc                   	cld    
  800b35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b37:	eb 05                	jmp    800b3e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	fc                   	cld    
  800b3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b48:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	89 04 24             	mov    %eax,(%esp)
  800b5c:	e8 77 ff ff ff       	call   800ad8 <memmove>
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	eb 16                	jmp    800b8f <memcmp+0x2c>
		if (*s1 != *s2)
  800b79:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b7c:	42                   	inc    %edx
  800b7d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b81:	38 c8                	cmp    %cl,%al
  800b83:	74 0a                	je     800b8f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b85:	0f b6 c0             	movzbl %al,%eax
  800b88:	0f b6 c9             	movzbl %cl,%ecx
  800b8b:	29 c8                	sub    %ecx,%eax
  800b8d:	eb 09                	jmp    800b98 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	39 da                	cmp    %ebx,%edx
  800b91:	75 e6                	jne    800b79 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ba6:	89 c2                	mov    %eax,%edx
  800ba8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bab:	eb 05                	jmp    800bb2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bad:	38 08                	cmp    %cl,(%eax)
  800baf:	74 05                	je     800bb6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb1:	40                   	inc    %eax
  800bb2:	39 d0                	cmp    %edx,%eax
  800bb4:	72 f7                	jb     800bad <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc4:	eb 01                	jmp    800bc7 <strtol+0xf>
		s++;
  800bc6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc7:	8a 02                	mov    (%edx),%al
  800bc9:	3c 20                	cmp    $0x20,%al
  800bcb:	74 f9                	je     800bc6 <strtol+0xe>
  800bcd:	3c 09                	cmp    $0x9,%al
  800bcf:	74 f5                	je     800bc6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd1:	3c 2b                	cmp    $0x2b,%al
  800bd3:	75 08                	jne    800bdd <strtol+0x25>
		s++;
  800bd5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdb:	eb 13                	jmp    800bf0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bdd:	3c 2d                	cmp    $0x2d,%al
  800bdf:	75 0a                	jne    800beb <strtol+0x33>
		s++, neg = 1;
  800be1:	8d 52 01             	lea    0x1(%edx),%edx
  800be4:	bf 01 00 00 00       	mov    $0x1,%edi
  800be9:	eb 05                	jmp    800bf0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800beb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf0:	85 db                	test   %ebx,%ebx
  800bf2:	74 05                	je     800bf9 <strtol+0x41>
  800bf4:	83 fb 10             	cmp    $0x10,%ebx
  800bf7:	75 28                	jne    800c21 <strtol+0x69>
  800bf9:	8a 02                	mov    (%edx),%al
  800bfb:	3c 30                	cmp    $0x30,%al
  800bfd:	75 10                	jne    800c0f <strtol+0x57>
  800bff:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c03:	75 0a                	jne    800c0f <strtol+0x57>
		s += 2, base = 16;
  800c05:	83 c2 02             	add    $0x2,%edx
  800c08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0d:	eb 12                	jmp    800c21 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c0f:	85 db                	test   %ebx,%ebx
  800c11:	75 0e                	jne    800c21 <strtol+0x69>
  800c13:	3c 30                	cmp    $0x30,%al
  800c15:	75 05                	jne    800c1c <strtol+0x64>
		s++, base = 8;
  800c17:	42                   	inc    %edx
  800c18:	b3 08                	mov    $0x8,%bl
  800c1a:	eb 05                	jmp    800c21 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c28:	8a 0a                	mov    (%edx),%cl
  800c2a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c2d:	80 fb 09             	cmp    $0x9,%bl
  800c30:	77 08                	ja     800c3a <strtol+0x82>
			dig = *s - '0';
  800c32:	0f be c9             	movsbl %cl,%ecx
  800c35:	83 e9 30             	sub    $0x30,%ecx
  800c38:	eb 1e                	jmp    800c58 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c3a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 08                	ja     800c4a <strtol+0x92>
			dig = *s - 'a' + 10;
  800c42:	0f be c9             	movsbl %cl,%ecx
  800c45:	83 e9 57             	sub    $0x57,%ecx
  800c48:	eb 0e                	jmp    800c58 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c4a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c4d:	80 fb 19             	cmp    $0x19,%bl
  800c50:	77 12                	ja     800c64 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c52:	0f be c9             	movsbl %cl,%ecx
  800c55:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c58:	39 f1                	cmp    %esi,%ecx
  800c5a:	7d 0c                	jge    800c68 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c5c:	42                   	inc    %edx
  800c5d:	0f af c6             	imul   %esi,%eax
  800c60:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c62:	eb c4                	jmp    800c28 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c64:	89 c1                	mov    %eax,%ecx
  800c66:	eb 02                	jmp    800c6a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c68:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6e:	74 05                	je     800c75 <strtol+0xbd>
		*endptr = (char *) s;
  800c70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c73:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c75:	85 ff                	test   %edi,%edi
  800c77:	74 04                	je     800c7d <strtol+0xc5>
  800c79:	89 c8                	mov    %ecx,%eax
  800c7b:	f7 d8                	neg    %eax
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    
	...

00800c84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	89 c3                	mov    %eax,%ebx
  800c97:	89 c7                	mov    %eax,%edi
  800c99:	89 c6                	mov    %eax,%esi
  800c9b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	89 d7                	mov    %edx,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 cb                	mov    %ecx,%ebx
  800cd9:	89 cf                	mov    %ecx,%edi
  800cdb:	89 ce                	mov    %ecx,%esi
  800cdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 28                	jle    800d0b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cee:	00 
  800cef:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfe:	00 
  800cff:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800d06:	e8 b1 f5 ff ff       	call   8002bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0b:	83 c4 2c             	add    $0x2c,%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	89 d7                	mov    %edx,%edi
  800d29:	89 d6                	mov    %edx,%esi
  800d2b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_yield>:

void
sys_yield(void)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d38:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d42:	89 d1                	mov    %edx,%ecx
  800d44:	89 d3                	mov    %edx,%ebx
  800d46:	89 d7                	mov    %edx,%edi
  800d48:	89 d6                	mov    %edx,%esi
  800d4a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	be 00 00 00 00       	mov    $0x0,%esi
  800d5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 f7                	mov    %esi,%edi
  800d6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 28                	jle    800d9d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d79:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d80:	00 
  800d81:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800d88:	00 
  800d89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d90:	00 
  800d91:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800d98:	e8 1f f5 ff ff       	call   8002bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d9d:	83 c4 2c             	add    $0x2c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b8 05 00 00 00       	mov    $0x5,%eax
  800db3:	8b 75 18             	mov    0x18(%ebp),%esi
  800db6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 28                	jle    800df0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de3:	00 
  800de4:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800deb:	e8 cc f4 ff ff       	call   8002bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df0:	83 c4 2c             	add    $0x2c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 28                	jle    800e43 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e36:	00 
  800e37:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800e3e:	e8 79 f4 ff ff       	call   8002bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e43:	83 c4 2c             	add    $0x2c,%esp
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e59:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	89 df                	mov    %ebx,%edi
  800e66:	89 de                	mov    %ebx,%esi
  800e68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 28                	jle    800e96 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e72:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e79:	00 
  800e7a:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800e81:	00 
  800e82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e89:	00 
  800e8a:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800e91:	e8 26 f4 ff ff       	call   8002bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e96:	83 c4 2c             	add    $0x2c,%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eac:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	89 df                	mov    %ebx,%edi
  800eb9:	89 de                	mov    %ebx,%esi
  800ebb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	7e 28                	jle    800ee9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edc:	00 
  800edd:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800ee4:	e8 d3 f3 ff ff       	call   8002bc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee9:	83 c4 2c             	add    $0x2c,%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0a:	89 df                	mov    %ebx,%edi
  800f0c:	89 de                	mov    %ebx,%esi
  800f0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f10:	85 c0                	test   %eax,%eax
  800f12:	7e 28                	jle    800f3c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f18:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f1f:	00 
  800f20:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800f27:	00 
  800f28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2f:	00 
  800f30:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800f37:	e8 80 f3 ff ff       	call   8002bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f3c:	83 c4 2c             	add    $0x2c,%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	be 00 00 00 00       	mov    $0x0,%esi
  800f4f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f75:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7d:	89 cb                	mov    %ecx,%ebx
  800f7f:	89 cf                	mov    %ecx,%edi
  800f81:	89 ce                	mov    %ecx,%esi
  800f83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7e 28                	jle    800fb1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f94:	00 
  800f95:	c7 44 24 08 3f 25 80 	movl   $0x80253f,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  800fac:	e8 0b f3 ff ff       	call   8002bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb1:	83 c4 2c             	add    $0x2c,%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    
  800fb9:	00 00                	add    %al,(%eax)
	...

00800fbc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	05 00 00 00 30       	add    $0x30000000,%eax
  800fc7:	c1 e8 0c             	shr    $0xc,%eax
}
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	e8 df ff ff ff       	call   800fbc <fd2num>
  800fdd:	05 20 00 0d 00       	add    $0xd0020,%eax
  800fe2:	c1 e0 0c             	shl    $0xc,%eax
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	53                   	push   %ebx
  800feb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ff3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ff5:	89 c2                	mov    %eax,%edx
  800ff7:	c1 ea 16             	shr    $0x16,%edx
  800ffa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801001:	f6 c2 01             	test   $0x1,%dl
  801004:	74 11                	je     801017 <fd_alloc+0x30>
  801006:	89 c2                	mov    %eax,%edx
  801008:	c1 ea 0c             	shr    $0xc,%edx
  80100b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801012:	f6 c2 01             	test   $0x1,%dl
  801015:	75 09                	jne    801020 <fd_alloc+0x39>
			*fd_store = fd;
  801017:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801019:	b8 00 00 00 00       	mov    $0x0,%eax
  80101e:	eb 17                	jmp    801037 <fd_alloc+0x50>
  801020:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801025:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80102a:	75 c7                	jne    800ff3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80102c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801032:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801037:	5b                   	pop    %ebx
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801040:	83 f8 1f             	cmp    $0x1f,%eax
  801043:	77 36                	ja     80107b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801045:	05 00 00 0d 00       	add    $0xd0000,%eax
  80104a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80104d:	89 c2                	mov    %eax,%edx
  80104f:	c1 ea 16             	shr    $0x16,%edx
  801052:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801059:	f6 c2 01             	test   $0x1,%dl
  80105c:	74 24                	je     801082 <fd_lookup+0x48>
  80105e:	89 c2                	mov    %eax,%edx
  801060:	c1 ea 0c             	shr    $0xc,%edx
  801063:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80106a:	f6 c2 01             	test   $0x1,%dl
  80106d:	74 1a                	je     801089 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80106f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801072:	89 02                	mov    %eax,(%edx)
	return 0;
  801074:	b8 00 00 00 00       	mov    $0x0,%eax
  801079:	eb 13                	jmp    80108e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80107b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801080:	eb 0c                	jmp    80108e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801082:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801087:	eb 05                	jmp    80108e <fd_lookup+0x54>
  801089:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	53                   	push   %ebx
  801094:	83 ec 14             	sub    $0x14,%esp
  801097:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80109d:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a2:	eb 0e                	jmp    8010b2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8010a4:	39 08                	cmp    %ecx,(%eax)
  8010a6:	75 09                	jne    8010b1 <dev_lookup+0x21>
			*dev = devtab[i];
  8010a8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010af:	eb 35                	jmp    8010e6 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010b1:	42                   	inc    %edx
  8010b2:	8b 04 95 ec 25 80 00 	mov    0x8025ec(,%edx,4),%eax
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	75 e7                	jne    8010a4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c2:	8b 00                	mov    (%eax),%eax
  8010c4:	8b 40 48             	mov    0x48(%eax),%eax
  8010c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cf:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  8010d6:	e8 d9 f2 ff ff       	call   8003b4 <cprintf>
	*dev = 0;
  8010db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010e6:	83 c4 14             	add    $0x14,%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 30             	sub    $0x30,%esp
  8010f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f7:	8a 45 0c             	mov    0xc(%ebp),%al
  8010fa:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010fd:	89 34 24             	mov    %esi,(%esp)
  801100:	e8 b7 fe ff ff       	call   800fbc <fd2num>
  801105:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801108:	89 54 24 04          	mov    %edx,0x4(%esp)
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	e8 26 ff ff ff       	call   80103a <fd_lookup>
  801114:	89 c3                	mov    %eax,%ebx
  801116:	85 c0                	test   %eax,%eax
  801118:	78 05                	js     80111f <fd_close+0x33>
	    || fd != fd2)
  80111a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80111d:	74 0d                	je     80112c <fd_close+0x40>
		return (must_exist ? r : 0);
  80111f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801123:	75 46                	jne    80116b <fd_close+0x7f>
  801125:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112a:	eb 3f                	jmp    80116b <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80112c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801133:	8b 06                	mov    (%esi),%eax
  801135:	89 04 24             	mov    %eax,(%esp)
  801138:	e8 53 ff ff ff       	call   801090 <dev_lookup>
  80113d:	89 c3                	mov    %eax,%ebx
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 18                	js     80115b <fd_close+0x6f>
		if (dev->dev_close)
  801143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801146:	8b 40 10             	mov    0x10(%eax),%eax
  801149:	85 c0                	test   %eax,%eax
  80114b:	74 09                	je     801156 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80114d:	89 34 24             	mov    %esi,(%esp)
  801150:	ff d0                	call   *%eax
  801152:	89 c3                	mov    %eax,%ebx
  801154:	eb 05                	jmp    80115b <fd_close+0x6f>
		else
			r = 0;
  801156:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80115b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80115f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801166:	e8 8d fc ff ff       	call   800df8 <sys_page_unmap>
	return r;
}
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	83 c4 30             	add    $0x30,%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801181:	8b 45 08             	mov    0x8(%ebp),%eax
  801184:	89 04 24             	mov    %eax,(%esp)
  801187:	e8 ae fe ff ff       	call   80103a <fd_lookup>
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 13                	js     8011a3 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801190:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801197:	00 
  801198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 49 ff ff ff       	call   8010ec <fd_close>
}
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <close_all>:

void
close_all(void)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011b1:	89 1c 24             	mov    %ebx,(%esp)
  8011b4:	e8 bb ff ff ff       	call   801174 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011b9:	43                   	inc    %ebx
  8011ba:	83 fb 20             	cmp    $0x20,%ebx
  8011bd:	75 f2                	jne    8011b1 <close_all+0xc>
		close(i);
}
  8011bf:	83 c4 14             	add    $0x14,%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	57                   	push   %edi
  8011c9:	56                   	push   %esi
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 4c             	sub    $0x4c,%esp
  8011ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011db:	89 04 24             	mov    %eax,(%esp)
  8011de:	e8 57 fe ff ff       	call   80103a <fd_lookup>
  8011e3:	89 c3                	mov    %eax,%ebx
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	0f 88 e1 00 00 00    	js     8012ce <dup+0x109>
		return r;
	close(newfdnum);
  8011ed:	89 3c 24             	mov    %edi,(%esp)
  8011f0:	e8 7f ff ff ff       	call   801174 <close>

	newfd = INDEX2FD(newfdnum);
  8011f5:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8011fb:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8011fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801201:	89 04 24             	mov    %eax,(%esp)
  801204:	e8 c3 fd ff ff       	call   800fcc <fd2data>
  801209:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80120b:	89 34 24             	mov    %esi,(%esp)
  80120e:	e8 b9 fd ff ff       	call   800fcc <fd2data>
  801213:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801216:	89 d8                	mov    %ebx,%eax
  801218:	c1 e8 16             	shr    $0x16,%eax
  80121b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801222:	a8 01                	test   $0x1,%al
  801224:	74 46                	je     80126c <dup+0xa7>
  801226:	89 d8                	mov    %ebx,%eax
  801228:	c1 e8 0c             	shr    $0xc,%eax
  80122b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801232:	f6 c2 01             	test   $0x1,%dl
  801235:	74 35                	je     80126c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801237:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80123e:	25 07 0e 00 00       	and    $0xe07,%eax
  801243:	89 44 24 10          	mov    %eax,0x10(%esp)
  801247:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80124a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801255:	00 
  801256:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80125a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801261:	e8 3f fb ff ff       	call   800da5 <sys_page_map>
  801266:	89 c3                	mov    %eax,%ebx
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 3b                	js     8012a7 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80126c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80126f:	89 c2                	mov    %eax,%edx
  801271:	c1 ea 0c             	shr    $0xc,%edx
  801274:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801281:	89 54 24 10          	mov    %edx,0x10(%esp)
  801285:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801289:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801290:	00 
  801291:	89 44 24 04          	mov    %eax,0x4(%esp)
  801295:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129c:	e8 04 fb ff ff       	call   800da5 <sys_page_map>
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	79 25                	jns    8012cc <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b2:	e8 41 fb ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c5:	e8 2e fb ff ff       	call   800df8 <sys_page_unmap>
	return r;
  8012ca:	eb 02                	jmp    8012ce <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012cc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012ce:	89 d8                	mov    %ebx,%eax
  8012d0:	83 c4 4c             	add    $0x4c,%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 24             	sub    $0x24,%esp
  8012df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e9:	89 1c 24             	mov    %ebx,(%esp)
  8012ec:	e8 49 fd ff ff       	call   80103a <fd_lookup>
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 6f                	js     801364 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	8b 00                	mov    (%eax),%eax
  801301:	89 04 24             	mov    %eax,(%esp)
  801304:	e8 87 fd ff ff       	call   801090 <dev_lookup>
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 57                	js     801364 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	8b 50 08             	mov    0x8(%eax),%edx
  801313:	83 e2 03             	and    $0x3,%edx
  801316:	83 fa 01             	cmp    $0x1,%edx
  801319:	75 25                	jne    801340 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80131b:	a1 04 40 80 00       	mov    0x804004,%eax
  801320:	8b 00                	mov    (%eax),%eax
  801322:	8b 40 48             	mov    0x48(%eax),%eax
  801325:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132d:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  801334:	e8 7b f0 ff ff       	call   8003b4 <cprintf>
		return -E_INVAL;
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb 24                	jmp    801364 <read+0x8c>
	}
	if (!dev->dev_read)
  801340:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801343:	8b 52 08             	mov    0x8(%edx),%edx
  801346:	85 d2                	test   %edx,%edx
  801348:	74 15                	je     80135f <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80134a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80134d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801351:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801354:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801358:	89 04 24             	mov    %eax,(%esp)
  80135b:	ff d2                	call   *%edx
  80135d:	eb 05                	jmp    801364 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80135f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801364:	83 c4 24             	add    $0x24,%esp
  801367:	5b                   	pop    %ebx
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	57                   	push   %edi
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 1c             	sub    $0x1c,%esp
  801373:	8b 7d 08             	mov    0x8(%ebp),%edi
  801376:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801379:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137e:	eb 23                	jmp    8013a3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801380:	89 f0                	mov    %esi,%eax
  801382:	29 d8                	sub    %ebx,%eax
  801384:	89 44 24 08          	mov    %eax,0x8(%esp)
  801388:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138b:	01 d8                	add    %ebx,%eax
  80138d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801391:	89 3c 24             	mov    %edi,(%esp)
  801394:	e8 3f ff ff ff       	call   8012d8 <read>
		if (m < 0)
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 10                	js     8013ad <readn+0x43>
			return m;
		if (m == 0)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	74 0a                	je     8013ab <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013a1:	01 c3                	add    %eax,%ebx
  8013a3:	39 f3                	cmp    %esi,%ebx
  8013a5:	72 d9                	jb     801380 <readn+0x16>
  8013a7:	89 d8                	mov    %ebx,%eax
  8013a9:	eb 02                	jmp    8013ad <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8013ab:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013ad:	83 c4 1c             	add    $0x1c,%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 24             	sub    $0x24,%esp
  8013bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c6:	89 1c 24             	mov    %ebx,(%esp)
  8013c9:	e8 6c fc ff ff       	call   80103a <fd_lookup>
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 6a                	js     80143c <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dc:	8b 00                	mov    (%eax),%eax
  8013de:	89 04 24             	mov    %eax,(%esp)
  8013e1:	e8 aa fc ff ff       	call   801090 <dev_lookup>
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 52                	js     80143c <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013f1:	75 25                	jne    801418 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f8:	8b 00                	mov    (%eax),%eax
  8013fa:	8b 40 48             	mov    0x48(%eax),%eax
  8013fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801401:	89 44 24 04          	mov    %eax,0x4(%esp)
  801405:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  80140c:	e8 a3 ef ff ff       	call   8003b4 <cprintf>
		return -E_INVAL;
  801411:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801416:	eb 24                	jmp    80143c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801418:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141b:	8b 52 0c             	mov    0xc(%edx),%edx
  80141e:	85 d2                	test   %edx,%edx
  801420:	74 15                	je     801437 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801422:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801425:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801430:	89 04 24             	mov    %eax,(%esp)
  801433:	ff d2                	call   *%edx
  801435:	eb 05                	jmp    80143c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801437:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80143c:	83 c4 24             	add    $0x24,%esp
  80143f:	5b                   	pop    %ebx
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <seek>:

int
seek(int fdnum, off_t offset)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801448:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80144b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	89 04 24             	mov    %eax,(%esp)
  801455:	e8 e0 fb ff ff       	call   80103a <fd_lookup>
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 0e                	js     80146c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80145e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801461:	8b 55 0c             	mov    0xc(%ebp),%edx
  801464:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801467:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 24             	sub    $0x24,%esp
  801475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147f:	89 1c 24             	mov    %ebx,(%esp)
  801482:	e8 b3 fb ff ff       	call   80103a <fd_lookup>
  801487:	85 c0                	test   %eax,%eax
  801489:	78 63                	js     8014ee <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	8b 00                	mov    (%eax),%eax
  801497:	89 04 24             	mov    %eax,(%esp)
  80149a:	e8 f1 fb ff ff       	call   801090 <dev_lookup>
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 4b                	js     8014ee <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014aa:	75 25                	jne    8014d1 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b1:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014b3:	8b 40 48             	mov    0x48(%eax),%eax
  8014b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014be:	c7 04 24 8c 25 80 00 	movl   $0x80258c,(%esp)
  8014c5:	e8 ea ee ff ff       	call   8003b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cf:	eb 1d                	jmp    8014ee <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8014d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d4:	8b 52 18             	mov    0x18(%edx),%edx
  8014d7:	85 d2                	test   %edx,%edx
  8014d9:	74 0e                	je     8014e9 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	ff d2                	call   *%edx
  8014e7:	eb 05                	jmp    8014ee <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014ee:	83 c4 24             	add    $0x24,%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 24             	sub    $0x24,%esp
  8014fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801501:	89 44 24 04          	mov    %eax,0x4(%esp)
  801505:	8b 45 08             	mov    0x8(%ebp),%eax
  801508:	89 04 24             	mov    %eax,(%esp)
  80150b:	e8 2a fb ff ff       	call   80103a <fd_lookup>
  801510:	85 c0                	test   %eax,%eax
  801512:	78 52                	js     801566 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	8b 00                	mov    (%eax),%eax
  801520:	89 04 24             	mov    %eax,(%esp)
  801523:	e8 68 fb ff ff       	call   801090 <dev_lookup>
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 3a                	js     801566 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80152c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801533:	74 2c                	je     801561 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801535:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801538:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80153f:	00 00 00 
	stat->st_isdir = 0;
  801542:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801549:	00 00 00 
	stat->st_dev = dev;
  80154c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801556:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801559:	89 14 24             	mov    %edx,(%esp)
  80155c:	ff 50 14             	call   *0x14(%eax)
  80155f:	eb 05                	jmp    801566 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801561:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801566:	83 c4 24             	add    $0x24,%esp
  801569:	5b                   	pop    %ebx
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801574:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80157b:	00 
  80157c:	8b 45 08             	mov    0x8(%ebp),%eax
  80157f:	89 04 24             	mov    %eax,(%esp)
  801582:	e8 88 02 00 00       	call   80180f <open>
  801587:	89 c3                	mov    %eax,%ebx
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 1b                	js     8015a8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80158d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801590:	89 44 24 04          	mov    %eax,0x4(%esp)
  801594:	89 1c 24             	mov    %ebx,(%esp)
  801597:	e8 58 ff ff ff       	call   8014f4 <fstat>
  80159c:	89 c6                	mov    %eax,%esi
	close(fd);
  80159e:	89 1c 24             	mov    %ebx,(%esp)
  8015a1:	e8 ce fb ff ff       	call   801174 <close>
	return r;
  8015a6:	89 f3                	mov    %esi,%ebx
}
  8015a8:	89 d8                	mov    %ebx,%eax
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5e                   	pop    %esi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    
  8015b1:	00 00                	add    %al,(%eax)
	...

008015b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 10             	sub    $0x10,%esp
  8015bc:	89 c3                	mov    %eax,%ebx
  8015be:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015c0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015c7:	75 11                	jne    8015da <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015d0:	e8 ca 08 00 00       	call   801e9f <ipc_find_env>
  8015d5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015da:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015e1:	00 
  8015e2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015e9:	00 
  8015ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8015f3:	89 04 24             	mov    %eax,(%esp)
  8015f6:	e8 3e 08 00 00       	call   801e39 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8015fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801602:	00 
  801603:	89 74 24 04          	mov    %esi,0x4(%esp)
  801607:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160e:	e8 b9 07 00 00       	call   801dcc <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	8b 40 0c             	mov    0xc(%eax),%eax
  801626:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80162b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801633:	ba 00 00 00 00       	mov    $0x0,%edx
  801638:	b8 02 00 00 00       	mov    $0x2,%eax
  80163d:	e8 72 ff ff ff       	call   8015b4 <fsipc>
}
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	8b 40 0c             	mov    0xc(%eax),%eax
  801650:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801655:	ba 00 00 00 00       	mov    $0x0,%edx
  80165a:	b8 06 00 00 00       	mov    $0x6,%eax
  80165f:	e8 50 ff ff ff       	call   8015b4 <fsipc>
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 14             	sub    $0x14,%esp
  80166d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	8b 40 0c             	mov    0xc(%eax),%eax
  801676:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167b:	ba 00 00 00 00       	mov    $0x0,%edx
  801680:	b8 05 00 00 00       	mov    $0x5,%eax
  801685:	e8 2a ff ff ff       	call   8015b4 <fsipc>
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 2b                	js     8016b9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80168e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801695:	00 
  801696:	89 1c 24             	mov    %ebx,(%esp)
  801699:	e8 c1 f2 ff ff       	call   80095f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169e:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b9:	83 c4 14             	add    $0x14,%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 14             	sub    $0x14,%esp
  8016c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  8016d4:	89 d8                	mov    %ebx,%eax
  8016d6:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8016dc:	76 05                	jbe    8016e3 <devfile_write+0x24>
  8016de:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8016e3:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  8016e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8016fa:	e8 43 f4 ff ff       	call   800b42 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 04 00 00 00       	mov    $0x4,%eax
  801709:	e8 a6 fe ff ff       	call   8015b4 <fsipc>
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 53                	js     801765 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801712:	39 c3                	cmp    %eax,%ebx
  801714:	73 24                	jae    80173a <devfile_write+0x7b>
  801716:	c7 44 24 0c fc 25 80 	movl   $0x8025fc,0xc(%esp)
  80171d:	00 
  80171e:	c7 44 24 08 03 26 80 	movl   $0x802603,0x8(%esp)
  801725:	00 
  801726:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  80172d:	00 
  80172e:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  801735:	e8 82 eb ff ff       	call   8002bc <_panic>
	assert(r <= PGSIZE);
  80173a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80173f:	7e 24                	jle    801765 <devfile_write+0xa6>
  801741:	c7 44 24 0c 23 26 80 	movl   $0x802623,0xc(%esp)
  801748:	00 
  801749:	c7 44 24 08 03 26 80 	movl   $0x802603,0x8(%esp)
  801750:	00 
  801751:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801758:	00 
  801759:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  801760:	e8 57 eb ff ff       	call   8002bc <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801765:	83 c4 14             	add    $0x14,%esp
  801768:	5b                   	pop    %ebx
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	83 ec 10             	sub    $0x10,%esp
  801773:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	8b 40 0c             	mov    0xc(%eax),%eax
  80177c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801781:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801787:	ba 00 00 00 00       	mov    $0x0,%edx
  80178c:	b8 03 00 00 00       	mov    $0x3,%eax
  801791:	e8 1e fe ff ff       	call   8015b4 <fsipc>
  801796:	89 c3                	mov    %eax,%ebx
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 6a                	js     801806 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80179c:	39 c6                	cmp    %eax,%esi
  80179e:	73 24                	jae    8017c4 <devfile_read+0x59>
  8017a0:	c7 44 24 0c fc 25 80 	movl   $0x8025fc,0xc(%esp)
  8017a7:	00 
  8017a8:	c7 44 24 08 03 26 80 	movl   $0x802603,0x8(%esp)
  8017af:	00 
  8017b0:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8017b7:	00 
  8017b8:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  8017bf:	e8 f8 ea ff ff       	call   8002bc <_panic>
	assert(r <= PGSIZE);
  8017c4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c9:	7e 24                	jle    8017ef <devfile_read+0x84>
  8017cb:	c7 44 24 0c 23 26 80 	movl   $0x802623,0xc(%esp)
  8017d2:	00 
  8017d3:	c7 44 24 08 03 26 80 	movl   $0x802603,0x8(%esp)
  8017da:	00 
  8017db:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8017e2:	00 
  8017e3:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  8017ea:	e8 cd ea ff ff       	call   8002bc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017fa:	00 
  8017fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fe:	89 04 24             	mov    %eax,(%esp)
  801801:	e8 d2 f2 ff ff       	call   800ad8 <memmove>
	return r;
}
  801806:	89 d8                	mov    %ebx,%eax
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5e                   	pop    %esi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	83 ec 20             	sub    $0x20,%esp
  801817:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80181a:	89 34 24             	mov    %esi,(%esp)
  80181d:	e8 0a f1 ff ff       	call   80092c <strlen>
  801822:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801827:	7f 60                	jg     801889 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182c:	89 04 24             	mov    %eax,(%esp)
  80182f:	e8 b3 f7 ff ff       	call   800fe7 <fd_alloc>
  801834:	89 c3                	mov    %eax,%ebx
  801836:	85 c0                	test   %eax,%eax
  801838:	78 54                	js     80188e <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80183e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801845:	e8 15 f1 ff ff       	call   80095f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801852:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801855:	b8 01 00 00 00       	mov    $0x1,%eax
  80185a:	e8 55 fd ff ff       	call   8015b4 <fsipc>
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	85 c0                	test   %eax,%eax
  801863:	79 15                	jns    80187a <open+0x6b>
		fd_close(fd, 0);
  801865:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80186c:	00 
  80186d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801870:	89 04 24             	mov    %eax,(%esp)
  801873:	e8 74 f8 ff ff       	call   8010ec <fd_close>
		return r;
  801878:	eb 14                	jmp    80188e <open+0x7f>
	}

	return fd2num(fd);
  80187a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187d:	89 04 24             	mov    %eax,(%esp)
  801880:	e8 37 f7 ff ff       	call   800fbc <fd2num>
  801885:	89 c3                	mov    %eax,%ebx
  801887:	eb 05                	jmp    80188e <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801889:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80188e:	89 d8                	mov    %ebx,%eax
  801890:	83 c4 20             	add    $0x20,%esp
  801893:	5b                   	pop    %ebx
  801894:	5e                   	pop    %esi
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a7:	e8 08 fd ff ff       	call   8015b4 <fsipc>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    
	...

008018b0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	56                   	push   %esi
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 10             	sub    $0x10,%esp
  8018b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	89 04 24             	mov    %eax,(%esp)
  8018c1:	e8 06 f7 ff ff       	call   800fcc <fd2data>
  8018c6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8018c8:	c7 44 24 04 2f 26 80 	movl   $0x80262f,0x4(%esp)
  8018cf:	00 
  8018d0:	89 34 24             	mov    %esi,(%esp)
  8018d3:	e8 87 f0 ff ff       	call   80095f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8018db:	2b 03                	sub    (%ebx),%eax
  8018dd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018e3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8018ea:	00 00 00 
	stat->st_dev = &devpipe;
  8018ed:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8018f4:	30 80 00 
	return 0;
}
  8018f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 14             	sub    $0x14,%esp
  80190a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80190d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801918:	e8 db f4 ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80191d:	89 1c 24             	mov    %ebx,(%esp)
  801920:	e8 a7 f6 ff ff       	call   800fcc <fd2data>
  801925:	89 44 24 04          	mov    %eax,0x4(%esp)
  801929:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801930:	e8 c3 f4 ff ff       	call   800df8 <sys_page_unmap>
}
  801935:	83 c4 14             	add    $0x14,%esp
  801938:	5b                   	pop    %ebx
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	57                   	push   %edi
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 2c             	sub    $0x2c,%esp
  801944:	89 c7                	mov    %eax,%edi
  801946:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801949:	a1 04 40 80 00       	mov    0x804004,%eax
  80194e:	8b 00                	mov    (%eax),%eax
  801950:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801953:	89 3c 24             	mov    %edi,(%esp)
  801956:	e8 89 05 00 00       	call   801ee4 <pageref>
  80195b:	89 c6                	mov    %eax,%esi
  80195d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801960:	89 04 24             	mov    %eax,(%esp)
  801963:	e8 7c 05 00 00       	call   801ee4 <pageref>
  801968:	39 c6                	cmp    %eax,%esi
  80196a:	0f 94 c0             	sete   %al
  80196d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801970:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801976:	8b 12                	mov    (%edx),%edx
  801978:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80197b:	39 cb                	cmp    %ecx,%ebx
  80197d:	75 08                	jne    801987 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80197f:	83 c4 2c             	add    $0x2c,%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5f                   	pop    %edi
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801987:	83 f8 01             	cmp    $0x1,%eax
  80198a:	75 bd                	jne    801949 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80198c:	8b 42 58             	mov    0x58(%edx),%eax
  80198f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801996:	00 
  801997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80199b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199f:	c7 04 24 36 26 80 00 	movl   $0x802636,(%esp)
  8019a6:	e8 09 ea ff ff       	call   8003b4 <cprintf>
  8019ab:	eb 9c                	jmp    801949 <_pipeisclosed+0xe>

008019ad <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	57                   	push   %edi
  8019b1:	56                   	push   %esi
  8019b2:	53                   	push   %ebx
  8019b3:	83 ec 1c             	sub    $0x1c,%esp
  8019b6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019b9:	89 34 24             	mov    %esi,(%esp)
  8019bc:	e8 0b f6 ff ff       	call   800fcc <fd2data>
  8019c1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c8:	eb 3c                	jmp    801a06 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ca:	89 da                	mov    %ebx,%edx
  8019cc:	89 f0                	mov    %esi,%eax
  8019ce:	e8 68 ff ff ff       	call   80193b <_pipeisclosed>
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	75 38                	jne    801a0f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019d7:	e8 56 f3 ff ff       	call   800d32 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019dc:	8b 43 04             	mov    0x4(%ebx),%eax
  8019df:	8b 13                	mov    (%ebx),%edx
  8019e1:	83 c2 20             	add    $0x20,%edx
  8019e4:	39 d0                	cmp    %edx,%eax
  8019e6:	73 e2                	jae    8019ca <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019eb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019f6:	79 05                	jns    8019fd <devpipe_write+0x50>
  8019f8:	4a                   	dec    %edx
  8019f9:	83 ca e0             	or     $0xffffffe0,%edx
  8019fc:	42                   	inc    %edx
  8019fd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a01:	40                   	inc    %eax
  801a02:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a05:	47                   	inc    %edi
  801a06:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a09:	75 d1                	jne    8019dc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a0b:	89 f8                	mov    %edi,%eax
  801a0d:	eb 05                	jmp    801a14 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a14:	83 c4 1c             	add    $0x1c,%esp
  801a17:	5b                   	pop    %ebx
  801a18:	5e                   	pop    %esi
  801a19:	5f                   	pop    %edi
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	57                   	push   %edi
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	83 ec 1c             	sub    $0x1c,%esp
  801a25:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a28:	89 3c 24             	mov    %edi,(%esp)
  801a2b:	e8 9c f5 ff ff       	call   800fcc <fd2data>
  801a30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a32:	be 00 00 00 00       	mov    $0x0,%esi
  801a37:	eb 3a                	jmp    801a73 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a39:	85 f6                	test   %esi,%esi
  801a3b:	74 04                	je     801a41 <devpipe_read+0x25>
				return i;
  801a3d:	89 f0                	mov    %esi,%eax
  801a3f:	eb 40                	jmp    801a81 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a41:	89 da                	mov    %ebx,%edx
  801a43:	89 f8                	mov    %edi,%eax
  801a45:	e8 f1 fe ff ff       	call   80193b <_pipeisclosed>
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	75 2e                	jne    801a7c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a4e:	e8 df f2 ff ff       	call   800d32 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a53:	8b 03                	mov    (%ebx),%eax
  801a55:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a58:	74 df                	je     801a39 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a5a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a5f:	79 05                	jns    801a66 <devpipe_read+0x4a>
  801a61:	48                   	dec    %eax
  801a62:	83 c8 e0             	or     $0xffffffe0,%eax
  801a65:	40                   	inc    %eax
  801a66:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a70:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	46                   	inc    %esi
  801a73:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a76:	75 db                	jne    801a53 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a78:	89 f0                	mov    %esi,%eax
  801a7a:	eb 05                	jmp    801a81 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a81:	83 c4 1c             	add    $0x1c,%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5e                   	pop    %esi
  801a86:	5f                   	pop    %edi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 3c             	sub    $0x3c,%esp
  801a92:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a98:	89 04 24             	mov    %eax,(%esp)
  801a9b:	e8 47 f5 ff ff       	call   800fe7 <fd_alloc>
  801aa0:	89 c3                	mov    %eax,%ebx
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	0f 88 45 01 00 00    	js     801bef <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aaa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ab1:	00 
  801ab2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac0:	e8 8c f2 ff ff       	call   800d51 <sys_page_alloc>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	0f 88 20 01 00 00    	js     801bef <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801acf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ad2:	89 04 24             	mov    %eax,(%esp)
  801ad5:	e8 0d f5 ff ff       	call   800fe7 <fd_alloc>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	85 c0                	test   %eax,%eax
  801ade:	0f 88 f8 00 00 00    	js     801bdc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aeb:	00 
  801aec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801aef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afa:	e8 52 f2 ff ff       	call   800d51 <sys_page_alloc>
  801aff:	89 c3                	mov    %eax,%ebx
  801b01:	85 c0                	test   %eax,%eax
  801b03:	0f 88 d3 00 00 00    	js     801bdc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 b8 f4 ff ff       	call   800fcc <fd2data>
  801b14:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b16:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b1d:	00 
  801b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b29:	e8 23 f2 ff ff       	call   800d51 <sys_page_alloc>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	85 c0                	test   %eax,%eax
  801b32:	0f 88 91 00 00 00    	js     801bc9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b3b:	89 04 24             	mov    %eax,(%esp)
  801b3e:	e8 89 f4 ff ff       	call   800fcc <fd2data>
  801b43:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b4a:	00 
  801b4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b56:	00 
  801b57:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b62:	e8 3e f2 ff ff       	call   800da5 <sys_page_map>
  801b67:	89 c3                	mov    %eax,%ebx
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 4c                	js     801bb9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b6d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b76:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b82:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b8b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b90:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 1a f4 ff ff       	call   800fbc <fd2num>
  801ba2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ba4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ba7:	89 04 24             	mov    %eax,(%esp)
  801baa:	e8 0d f4 ff ff       	call   800fbc <fd2num>
  801baf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801bb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb7:	eb 36                	jmp    801bef <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801bb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc4:	e8 2f f2 ff ff       	call   800df8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801bc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd7:	e8 1c f2 ff ff       	call   800df8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bea:	e8 09 f2 ff ff       	call   800df8 <sys_page_unmap>
    err:
	return r;
}
  801bef:	89 d8                	mov    %ebx,%eax
  801bf1:	83 c4 3c             	add    $0x3c,%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	89 04 24             	mov    %eax,(%esp)
  801c0c:	e8 29 f4 ff ff       	call   80103a <fd_lookup>
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 15                	js     801c2a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c18:	89 04 24             	mov    %eax,(%esp)
  801c1b:	e8 ac f3 ff ff       	call   800fcc <fd2data>
	return _pipeisclosed(fd, p);
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c25:	e8 11 fd ff ff       	call   80193b <_pipeisclosed>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c3c:	c7 44 24 04 4e 26 80 	movl   $0x80264e,0x4(%esp)
  801c43:	00 
  801c44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c47:	89 04 24             	mov    %eax,(%esp)
  801c4a:	e8 10 ed ff ff       	call   80095f <strcpy>
	return 0;
}
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	57                   	push   %edi
  801c5a:	56                   	push   %esi
  801c5b:	53                   	push   %ebx
  801c5c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c62:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c67:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6d:	eb 30                	jmp    801c9f <devcons_write+0x49>
		m = n - tot;
  801c6f:	8b 75 10             	mov    0x10(%ebp),%esi
  801c72:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801c74:	83 fe 7f             	cmp    $0x7f,%esi
  801c77:	76 05                	jbe    801c7e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801c79:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c7e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c82:	03 45 0c             	add    0xc(%ebp),%eax
  801c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c89:	89 3c 24             	mov    %edi,(%esp)
  801c8c:	e8 47 ee ff ff       	call   800ad8 <memmove>
		sys_cputs(buf, m);
  801c91:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c95:	89 3c 24             	mov    %edi,(%esp)
  801c98:	e8 e7 ef ff ff       	call   800c84 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9d:	01 f3                	add    %esi,%ebx
  801c9f:	89 d8                	mov    %ebx,%eax
  801ca1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ca4:	72 c9                	jb     801c6f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801cb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cbb:	75 07                	jne    801cc4 <devcons_read+0x13>
  801cbd:	eb 25                	jmp    801ce4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cbf:	e8 6e f0 ff ff       	call   800d32 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc4:	e8 d9 ef ff ff       	call   800ca2 <sys_cgetc>
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	74 f2                	je     801cbf <devcons_read+0xe>
  801ccd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 1d                	js     801cf0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd3:	83 f8 04             	cmp    $0x4,%eax
  801cd6:	74 13                	je     801ceb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdb:	88 10                	mov    %dl,(%eax)
	return 1;
  801cdd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce2:	eb 0c                	jmp    801cf0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ce4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce9:	eb 05                	jmp    801cf0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cfe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d05:	00 
  801d06:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d09:	89 04 24             	mov    %eax,(%esp)
  801d0c:	e8 73 ef ff ff       	call   800c84 <sys_cputs>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <getchar>:

int
getchar(void)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d19:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d20:	00 
  801d21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2f:	e8 a4 f5 ff ff       	call   8012d8 <read>
	if (r < 0)
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 0f                	js     801d47 <getchar+0x34>
		return r;
	if (r < 1)
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	7e 06                	jle    801d42 <getchar+0x2f>
		return -E_EOF;
	return c;
  801d3c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d40:	eb 05                	jmp    801d47 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d42:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	89 04 24             	mov    %eax,(%esp)
  801d5c:	e8 d9 f2 ff ff       	call   80103a <fd_lookup>
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 11                	js     801d76 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d68:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6e:	39 10                	cmp    %edx,(%eax)
  801d70:	0f 94 c0             	sete   %al
  801d73:	0f b6 c0             	movzbl %al,%eax
}
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <opencons>:

int
opencons(void)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d81:	89 04 24             	mov    %eax,(%esp)
  801d84:	e8 5e f2 ff ff       	call   800fe7 <fd_alloc>
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 3c                	js     801dc9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d94:	00 
  801d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da3:	e8 a9 ef ff ff       	call   800d51 <sys_page_alloc>
  801da8:	85 c0                	test   %eax,%eax
  801daa:	78 1d                	js     801dc9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dc1:	89 04 24             	mov    %eax,(%esp)
  801dc4:	e8 f3 f1 ff ff       	call   800fbc <fd2num>
}
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    
	...

00801dcc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	83 ec 10             	sub    $0x10,%esp
  801dd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dda:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	75 05                	jne    801de6 <ipc_recv+0x1a>
  801de1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801de6:	89 04 24             	mov    %eax,(%esp)
  801de9:	e8 79 f1 ff ff       	call   800f67 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801dee:	85 c0                	test   %eax,%eax
  801df0:	79 16                	jns    801e08 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801df2:	85 db                	test   %ebx,%ebx
  801df4:	74 06                	je     801dfc <ipc_recv+0x30>
  801df6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801dfc:	85 f6                	test   %esi,%esi
  801dfe:	74 32                	je     801e32 <ipc_recv+0x66>
  801e00:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801e06:	eb 2a                	jmp    801e32 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e08:	85 db                	test   %ebx,%ebx
  801e0a:	74 0c                	je     801e18 <ipc_recv+0x4c>
  801e0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e11:	8b 00                	mov    (%eax),%eax
  801e13:	8b 40 74             	mov    0x74(%eax),%eax
  801e16:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e18:	85 f6                	test   %esi,%esi
  801e1a:	74 0c                	je     801e28 <ipc_recv+0x5c>
  801e1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e21:	8b 00                	mov    (%eax),%eax
  801e23:	8b 40 78             	mov    0x78(%eax),%eax
  801e26:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801e28:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2d:	8b 00                	mov    (%eax),%eax
  801e2f:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	5b                   	pop    %ebx
  801e36:	5e                   	pop    %esi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    

00801e39 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	57                   	push   %edi
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 1c             	sub    $0x1c,%esp
  801e42:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e48:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801e4b:	85 db                	test   %ebx,%ebx
  801e4d:	75 05                	jne    801e54 <ipc_send+0x1b>
  801e4f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801e54:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e5c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e60:	8b 45 08             	mov    0x8(%ebp),%eax
  801e63:	89 04 24             	mov    %eax,(%esp)
  801e66:	e8 d9 f0 ff ff       	call   800f44 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801e6b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e6e:	75 07                	jne    801e77 <ipc_send+0x3e>
  801e70:	e8 bd ee ff ff       	call   800d32 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801e75:	eb dd                	jmp    801e54 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801e77:	85 c0                	test   %eax,%eax
  801e79:	79 1c                	jns    801e97 <ipc_send+0x5e>
  801e7b:	c7 44 24 08 5a 26 80 	movl   $0x80265a,0x8(%esp)
  801e82:	00 
  801e83:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801e8a:	00 
  801e8b:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  801e92:	e8 25 e4 ff ff       	call   8002bc <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801e97:	83 c4 1c             	add    $0x1c,%esp
  801e9a:	5b                   	pop    %ebx
  801e9b:	5e                   	pop    %esi
  801e9c:	5f                   	pop    %edi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	53                   	push   %ebx
  801ea3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801ea6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eab:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801eb2:	89 c2                	mov    %eax,%edx
  801eb4:	c1 e2 07             	shl    $0x7,%edx
  801eb7:	29 ca                	sub    %ecx,%edx
  801eb9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ebf:	8b 52 50             	mov    0x50(%edx),%edx
  801ec2:	39 da                	cmp    %ebx,%edx
  801ec4:	75 0f                	jne    801ed5 <ipc_find_env+0x36>
			return envs[i].env_id;
  801ec6:	c1 e0 07             	shl    $0x7,%eax
  801ec9:	29 c8                	sub    %ecx,%eax
  801ecb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ed0:	8b 40 40             	mov    0x40(%eax),%eax
  801ed3:	eb 0c                	jmp    801ee1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed5:	40                   	inc    %eax
  801ed6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801edb:	75 ce                	jne    801eab <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801edd:	66 b8 00 00          	mov    $0x0,%ax
}
  801ee1:	5b                   	pop    %ebx
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801eea:	89 c2                	mov    %eax,%edx
  801eec:	c1 ea 16             	shr    $0x16,%edx
  801eef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ef6:	f6 c2 01             	test   $0x1,%dl
  801ef9:	74 1e                	je     801f19 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801efb:	c1 e8 0c             	shr    $0xc,%eax
  801efe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f05:	a8 01                	test   $0x1,%al
  801f07:	74 17                	je     801f20 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f09:	c1 e8 0c             	shr    $0xc,%eax
  801f0c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f13:	ef 
  801f14:	0f b7 c0             	movzwl %ax,%eax
  801f17:	eb 0c                	jmp    801f25 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f19:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1e:	eb 05                	jmp    801f25 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f20:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
	...

00801f28 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f28:	55                   	push   %ebp
  801f29:	57                   	push   %edi
  801f2a:	56                   	push   %esi
  801f2b:	83 ec 10             	sub    $0x10,%esp
  801f2e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f32:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f3a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801f3e:	89 cd                	mov    %ecx,%ebp
  801f40:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f44:	85 c0                	test   %eax,%eax
  801f46:	75 2c                	jne    801f74 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f48:	39 f9                	cmp    %edi,%ecx
  801f4a:	77 68                	ja     801fb4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f4c:	85 c9                	test   %ecx,%ecx
  801f4e:	75 0b                	jne    801f5b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f50:	b8 01 00 00 00       	mov    $0x1,%eax
  801f55:	31 d2                	xor    %edx,%edx
  801f57:	f7 f1                	div    %ecx
  801f59:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	89 f8                	mov    %edi,%eax
  801f5f:	f7 f1                	div    %ecx
  801f61:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f63:	89 f0                	mov    %esi,%eax
  801f65:	f7 f1                	div    %ecx
  801f67:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f69:	89 f0                	mov    %esi,%eax
  801f6b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f6d:	83 c4 10             	add    $0x10,%esp
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f74:	39 f8                	cmp    %edi,%eax
  801f76:	77 2c                	ja     801fa4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f78:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801f7b:	83 f6 1f             	xor    $0x1f,%esi
  801f7e:	75 4c                	jne    801fcc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f80:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f82:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f87:	72 0a                	jb     801f93 <__udivdi3+0x6b>
  801f89:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f8d:	0f 87 ad 00 00 00    	ja     802040 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f93:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f98:	89 f0                	mov    %esi,%eax
  801f9a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	5e                   	pop    %esi
  801fa0:	5f                   	pop    %edi
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
  801fa3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fa8:	89 f0                	mov    %esi,%eax
  801faa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    
  801fb3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fb4:	89 fa                	mov    %edi,%edx
  801fb6:	89 f0                	mov    %esi,%eax
  801fb8:	f7 f1                	div    %ecx
  801fba:	89 c6                	mov    %eax,%esi
  801fbc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fbe:	89 f0                	mov    %esi,%eax
  801fc0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    
  801fc9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801fcc:	89 f1                	mov    %esi,%ecx
  801fce:	d3 e0                	shl    %cl,%eax
  801fd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801fd4:	b8 20 00 00 00       	mov    $0x20,%eax
  801fd9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801fdb:	89 ea                	mov    %ebp,%edx
  801fdd:	88 c1                	mov    %al,%cl
  801fdf:	d3 ea                	shr    %cl,%edx
  801fe1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801fe5:	09 ca                	or     %ecx,%edx
  801fe7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801feb:	89 f1                	mov    %esi,%ecx
  801fed:	d3 e5                	shl    %cl,%ebp
  801fef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801ff3:	89 fd                	mov    %edi,%ebp
  801ff5:	88 c1                	mov    %al,%cl
  801ff7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801ff9:	89 fa                	mov    %edi,%edx
  801ffb:	89 f1                	mov    %esi,%ecx
  801ffd:	d3 e2                	shl    %cl,%edx
  801fff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802003:	88 c1                	mov    %al,%cl
  802005:	d3 ef                	shr    %cl,%edi
  802007:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802009:	89 f8                	mov    %edi,%eax
  80200b:	89 ea                	mov    %ebp,%edx
  80200d:	f7 74 24 08          	divl   0x8(%esp)
  802011:	89 d1                	mov    %edx,%ecx
  802013:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802015:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802019:	39 d1                	cmp    %edx,%ecx
  80201b:	72 17                	jb     802034 <__udivdi3+0x10c>
  80201d:	74 09                	je     802028 <__udivdi3+0x100>
  80201f:	89 fe                	mov    %edi,%esi
  802021:	31 ff                	xor    %edi,%edi
  802023:	e9 41 ff ff ff       	jmp    801f69 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802028:	8b 54 24 04          	mov    0x4(%esp),%edx
  80202c:	89 f1                	mov    %esi,%ecx
  80202e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802030:	39 c2                	cmp    %eax,%edx
  802032:	73 eb                	jae    80201f <__udivdi3+0xf7>
		{
		  q0--;
  802034:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802037:	31 ff                	xor    %edi,%edi
  802039:	e9 2b ff ff ff       	jmp    801f69 <__udivdi3+0x41>
  80203e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802040:	31 f6                	xor    %esi,%esi
  802042:	e9 22 ff ff ff       	jmp    801f69 <__udivdi3+0x41>
	...

00802048 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802048:	55                   	push   %ebp
  802049:	57                   	push   %edi
  80204a:	56                   	push   %esi
  80204b:	83 ec 20             	sub    $0x20,%esp
  80204e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802052:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802056:	89 44 24 14          	mov    %eax,0x14(%esp)
  80205a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80205e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802062:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802066:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802068:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80206a:	85 ed                	test   %ebp,%ebp
  80206c:	75 16                	jne    802084 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80206e:	39 f1                	cmp    %esi,%ecx
  802070:	0f 86 a6 00 00 00    	jbe    80211c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802076:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802078:	89 d0                	mov    %edx,%eax
  80207a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80207c:	83 c4 20             	add    $0x20,%esp
  80207f:	5e                   	pop    %esi
  802080:	5f                   	pop    %edi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    
  802083:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802084:	39 f5                	cmp    %esi,%ebp
  802086:	0f 87 ac 00 00 00    	ja     802138 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80208c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80208f:	83 f0 1f             	xor    $0x1f,%eax
  802092:	89 44 24 10          	mov    %eax,0x10(%esp)
  802096:	0f 84 a8 00 00 00    	je     802144 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80209c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020a0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8020a7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020af:	89 f9                	mov    %edi,%ecx
  8020b1:	d3 e8                	shr    %cl,%eax
  8020b3:	09 e8                	or     %ebp,%eax
  8020b5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8020b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020c1:	d3 e0                	shl    %cl,%eax
  8020c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020c7:	89 f2                	mov    %esi,%edx
  8020c9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8020cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020cf:	d3 e0                	shl    %cl,%eax
  8020d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8020df:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020e1:	89 f2                	mov    %esi,%edx
  8020e3:	f7 74 24 18          	divl   0x18(%esp)
  8020e7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	89 c5                	mov    %eax,%ebp
  8020ef:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020f1:	39 d6                	cmp    %edx,%esi
  8020f3:	72 67                	jb     80215c <__umoddi3+0x114>
  8020f5:	74 75                	je     80216c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8020f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8020fb:	29 e8                	sub    %ebp,%eax
  8020fd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8020ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802103:	d3 e8                	shr    %cl,%eax
  802105:	89 f2                	mov    %esi,%edx
  802107:	89 f9                	mov    %edi,%ecx
  802109:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80210b:	09 d0                	or     %edx,%eax
  80210d:	89 f2                	mov    %esi,%edx
  80210f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802113:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802115:	83 c4 20             	add    $0x20,%esp
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80211c:	85 c9                	test   %ecx,%ecx
  80211e:	75 0b                	jne    80212b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802120:	b8 01 00 00 00       	mov    $0x1,%eax
  802125:	31 d2                	xor    %edx,%edx
  802127:	f7 f1                	div    %ecx
  802129:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80212b:	89 f0                	mov    %esi,%eax
  80212d:	31 d2                	xor    %edx,%edx
  80212f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802131:	89 f8                	mov    %edi,%eax
  802133:	e9 3e ff ff ff       	jmp    802076 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802138:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80213a:	83 c4 20             	add    $0x20,%esp
  80213d:	5e                   	pop    %esi
  80213e:	5f                   	pop    %edi
  80213f:	5d                   	pop    %ebp
  802140:	c3                   	ret    
  802141:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802144:	39 f5                	cmp    %esi,%ebp
  802146:	72 04                	jb     80214c <__umoddi3+0x104>
  802148:	39 f9                	cmp    %edi,%ecx
  80214a:	77 06                	ja     802152 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	29 cf                	sub    %ecx,%edi
  802150:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802152:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802154:	83 c4 20             	add    $0x20,%esp
  802157:	5e                   	pop    %esi
  802158:	5f                   	pop    %edi
  802159:	5d                   	pop    %ebp
  80215a:	c3                   	ret    
  80215b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80215c:	89 d1                	mov    %edx,%ecx
  80215e:	89 c5                	mov    %eax,%ebp
  802160:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802164:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802168:	eb 8d                	jmp    8020f7 <__umoddi3+0xaf>
  80216a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80216c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802170:	72 ea                	jb     80215c <__umoddi3+0x114>
  802172:	89 f1                	mov    %esi,%ecx
  802174:	eb 81                	jmp    8020f7 <__umoddi3+0xaf>
