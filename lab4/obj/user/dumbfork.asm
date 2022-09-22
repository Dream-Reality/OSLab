
obj/user/dumbfork:     file format elf32-i386


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
  800051:	e8 03 0d 00 00       	call   800d59 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 c0 11 80 	movl   $0x8011c0,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  800075:	e8 4a 02 00 00       	call   8002c4 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 0f 0d 00 00       	call   800dad <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 e3 11 80 	movl   $0x8011e3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  8000bd:	e8 02 02 00 00       	call   8002c4 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 06 0a 00 00       	call   800ae0 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 12 0d 00 00       	call   800e00 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 f4 11 80 	movl   $0x8011f4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  80010d:	e8 b2 01 00 00       	call   8002c4 <_panic>
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
  800136:	c7 44 24 08 07 12 80 	movl   $0x801207,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  80014d:	e8 72 01 00 00       	call   8002c4 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 25                	jne    80017b <dumbfork+0x62>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80015c:	e8 ba 0b 00 00       	call   800d1b <sys_getenvid>
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
  80019a:	3d 08 20 80 00       	cmp    $0x802008,%eax
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
  8001c0:	e8 8e 0c 00 00       	call   800e53 <sys_env_set_status>
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	79 20                	jns    8001e9 <dumbfork+0xd0>
		panic("sys_env_set_status: %e", r);
  8001c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cd:	c7 44 24 08 17 12 80 	movl   $0x801217,0x8(%esp)
  8001d4:	00 
  8001d5:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001dc:	00 
  8001dd:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  8001e4:	e8 db 00 00 00       	call   8002c4 <_panic>

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
  80020c:	b8 2e 12 80 00       	mov    $0x80122e,%eax
  800211:	eb 05                	jmp    800218 <umain+0x26>
  800213:	b8 35 12 80 00       	mov    $0x801235,%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800220:	c7 04 24 3b 12 80 00 	movl   $0x80123b,(%esp)
  800227:	e8 90 01 00 00       	call   8003bc <cprintf>
		sys_yield();
  80022c:	e8 09 0b 00 00       	call   800d3a <sys_yield>

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
  800256:	e8 c0 0a 00 00       	call   800d1b <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800267:	c1 e0 07             	shl    $0x7,%eax
  80026a:	29 d0                	sub    %edx,%eax
  80026c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800271:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800274:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800277:	a3 04 20 80 00       	mov    %eax,0x802004
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800280:	c7 04 24 4d 12 80 00 	movl   $0x80124d,(%esp)
  800287:	e8 30 01 00 00       	call   8003bc <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028c:	85 f6                	test   %esi,%esi
  80028e:	7e 07                	jle    800297 <libmain+0x4f>
		binaryname = argv[0];
  800290:	8b 03                	mov    (%ebx),%eax
  800292:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800297:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80029b:	89 34 24             	mov    %esi,(%esp)
  80029e:	e8 4f ff ff ff       	call   8001f2 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 08 00 00 00       	call   8002b0 <exit>
}
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    
	...

008002b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002bd:	e8 07 0a 00 00       	call   800cc9 <sys_env_destroy>
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002d5:	e8 41 0a 00 00       	call   800d1b <sys_getenvid>
  8002da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f0:	c7 04 24 5c 12 80 00 	movl   $0x80125c,(%esp)
  8002f7:	e8 c0 00 00 00       	call   8003bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	e8 50 00 00 00       	call   80035b <vcprintf>
	cprintf("\n");
  80030b:	c7 04 24 4b 12 80 00 	movl   $0x80124b,(%esp)
  800312:	e8 a5 00 00 00       	call   8003bc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800317:	cc                   	int3   
  800318:	eb fd                	jmp    800317 <_panic+0x53>
	...

0080031c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	53                   	push   %ebx
  800320:	83 ec 14             	sub    $0x14,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800326:	8b 03                	mov    (%ebx),%eax
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80032f:	40                   	inc    %eax
  800330:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800332:	3d ff 00 00 00       	cmp    $0xff,%eax
  800337:	75 19                	jne    800352 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800339:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800340:	00 
  800341:	8d 43 08             	lea    0x8(%ebx),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	e8 40 09 00 00       	call   800c8c <sys_cputs>
		b->idx = 0;
  80034c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800352:	ff 43 04             	incl   0x4(%ebx)
}
  800355:	83 c4 14             	add    $0x14,%esp
  800358:	5b                   	pop    %ebx
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800364:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036b:	00 00 00 
	b.cnt = 0;
  80036e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800375:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	89 44 24 08          	mov    %eax,0x8(%esp)
  800386:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800390:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  800397:	e8 82 01 00 00       	call   80051e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 d8 08 00 00       	call   800c8c <sys_cputs>

	return b.cnt;
}
  8003b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	e8 87 ff ff ff       	call   80035b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    
	...

008003d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	57                   	push   %edi
  8003dc:	56                   	push   %esi
  8003dd:	53                   	push   %ebx
  8003de:	83 ec 3c             	sub    $0x3c,%esp
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e4:	89 d7                	mov    %edx,%edi
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	75 08                	jne    800404 <printnum+0x2c>
  8003fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  800402:	77 57                	ja     80045b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800404:	89 74 24 10          	mov    %esi,0x10(%esp)
  800408:	4b                   	dec    %ebx
  800409:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80040d:	8b 45 10             	mov    0x10(%ebp),%eax
  800410:	89 44 24 08          	mov    %eax,0x8(%esp)
  800414:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800418:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80041c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800423:	00 
  800424:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800431:	e8 3a 0b 00 00       	call   800f70 <__udivdi3>
  800436:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80043a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	89 54 24 04          	mov    %edx,0x4(%esp)
  800445:	89 fa                	mov    %edi,%edx
  800447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044a:	e8 89 ff ff ff       	call   8003d8 <printnum>
  80044f:	eb 0f                	jmp    800460 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800451:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800455:	89 34 24             	mov    %esi,(%esp)
  800458:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80045b:	4b                   	dec    %ebx
  80045c:	85 db                	test   %ebx,%ebx
  80045e:	7f f1                	jg     800451 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800460:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800464:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800468:	8b 45 10             	mov    0x10(%ebp),%eax
  80046b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80046f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800476:	00 
  800477:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047a:	89 04 24             	mov    %eax,(%esp)
  80047d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800480:	89 44 24 04          	mov    %eax,0x4(%esp)
  800484:	e8 07 0c 00 00       	call   801090 <__umoddi3>
  800489:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048d:	0f be 80 80 12 80 00 	movsbl 0x801280(%eax),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80049a:	83 c4 3c             	add    $0x3c,%esp
  80049d:	5b                   	pop    %ebx
  80049e:	5e                   	pop    %esi
  80049f:	5f                   	pop    %edi
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a5:	83 fa 01             	cmp    $0x1,%edx
  8004a8:	7e 0e                	jle    8004b8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	8b 52 04             	mov    0x4(%edx),%edx
  8004b6:	eb 22                	jmp    8004da <getuint+0x38>
	else if (lflag)
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	74 10                	je     8004cc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004bc:	8b 10                	mov    (%eax),%edx
  8004be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c1:	89 08                	mov    %ecx,(%eax)
  8004c3:	8b 02                	mov    (%edx),%eax
  8004c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ca:	eb 0e                	jmp    8004da <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004cc:	8b 10                	mov    (%eax),%edx
  8004ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d1:	89 08                	mov    %ecx,(%eax)
  8004d3:	8b 02                	mov    (%edx),%eax
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ea:	73 08                	jae    8004f4 <sprintputch+0x18>
		*b->buf++ = ch;
  8004ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ef:	88 0a                	mov    %cl,(%edx)
  8004f1:	42                   	inc    %edx
  8004f2:	89 10                	mov    %edx,(%eax)
}
  8004f4:	5d                   	pop    %ebp
  8004f5:	c3                   	ret    

008004f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800503:	8b 45 10             	mov    0x10(%ebp),%eax
  800506:	89 44 24 08          	mov    %eax,0x8(%esp)
  80050a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	8b 45 08             	mov    0x8(%ebp),%eax
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	e8 02 00 00 00       	call   80051e <vprintfmt>
	va_end(ap);
}
  80051c:	c9                   	leave  
  80051d:	c3                   	ret    

0080051e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051e:	55                   	push   %ebp
  80051f:	89 e5                	mov    %esp,%ebp
  800521:	57                   	push   %edi
  800522:	56                   	push   %esi
  800523:	53                   	push   %ebx
  800524:	83 ec 4c             	sub    $0x4c,%esp
  800527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052a:	8b 75 10             	mov    0x10(%ebp),%esi
  80052d:	eb 12                	jmp    800541 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052f:	85 c0                	test   %eax,%eax
  800531:	0f 84 6b 03 00 00    	je     8008a2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800537:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800541:	0f b6 06             	movzbl (%esi),%eax
  800544:	46                   	inc    %esi
  800545:	83 f8 25             	cmp    $0x25,%eax
  800548:	75 e5                	jne    80052f <vprintfmt+0x11>
  80054a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80054e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800555:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80055a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800561:	b9 00 00 00 00       	mov    $0x0,%ecx
  800566:	eb 26                	jmp    80058e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80056f:	eb 1d                	jmp    80058e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800574:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800578:	eb 14                	jmp    80058e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80057d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800584:	eb 08                	jmp    80058e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800586:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800589:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	0f b6 06             	movzbl (%esi),%eax
  800591:	8d 56 01             	lea    0x1(%esi),%edx
  800594:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800597:	8a 16                	mov    (%esi),%dl
  800599:	83 ea 23             	sub    $0x23,%edx
  80059c:	80 fa 55             	cmp    $0x55,%dl
  80059f:	0f 87 e1 02 00 00    	ja     800886 <vprintfmt+0x368>
  8005a5:	0f b6 d2             	movzbl %dl,%edx
  8005a8:	ff 24 95 40 13 80 00 	jmp    *0x801340(,%edx,4)
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005ba:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005be:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005c1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005c4:	83 fa 09             	cmp    $0x9,%edx
  8005c7:	77 2a                	ja     8005f3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ca:	eb eb                	jmp    8005b7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005da:	eb 17                	jmp    8005f3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e0:	78 98                	js     80057a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e5:	eb a7                	jmp    80058e <vprintfmt+0x70>
  8005e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ea:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005f1:	eb 9b                	jmp    80058e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f7:	79 95                	jns    80058e <vprintfmt+0x70>
  8005f9:	eb 8b                	jmp    800586 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ff:	eb 8d                	jmp    80058e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800619:	e9 23 ff ff ff       	jmp    800541 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)
  800627:	8b 00                	mov    (%eax),%eax
  800629:	85 c0                	test   %eax,%eax
  80062b:	79 02                	jns    80062f <vprintfmt+0x111>
  80062d:	f7 d8                	neg    %eax
  80062f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800631:	83 f8 08             	cmp    $0x8,%eax
  800634:	7f 0b                	jg     800641 <vprintfmt+0x123>
  800636:	8b 04 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%eax
  80063d:	85 c0                	test   %eax,%eax
  80063f:	75 23                	jne    800664 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800641:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800645:	c7 44 24 08 98 12 80 	movl   $0x801298,0x8(%esp)
  80064c:	00 
  80064d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800651:	8b 45 08             	mov    0x8(%ebp),%eax
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	e8 9a fe ff ff       	call   8004f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065f:	e9 dd fe ff ff       	jmp    800541 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800664:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800668:	c7 44 24 08 a1 12 80 	movl   $0x8012a1,0x8(%esp)
  80066f:	00 
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	8b 55 08             	mov    0x8(%ebp),%edx
  800677:	89 14 24             	mov    %edx,(%esp)
  80067a:	e8 77 fe ff ff       	call   8004f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800682:	e9 ba fe ff ff       	jmp    800541 <vprintfmt+0x23>
  800687:	89 f9                	mov    %edi,%ecx
  800689:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80068c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 30                	mov    (%eax),%esi
  80069a:	85 f6                	test   %esi,%esi
  80069c:	75 05                	jne    8006a3 <vprintfmt+0x185>
				p = "(null)";
  80069e:	be 91 12 80 00       	mov    $0x801291,%esi
			if (width > 0 && padc != '-')
  8006a3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006a7:	0f 8e 84 00 00 00    	jle    800731 <vprintfmt+0x213>
  8006ad:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006b1:	74 7e                	je     800731 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006b7:	89 34 24             	mov    %esi,(%esp)
  8006ba:	e8 8b 02 00 00       	call   80094a <strnlen>
  8006bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006c2:	29 c2                	sub    %eax,%edx
  8006c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006c7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006cb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006ce:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006d1:	89 de                	mov    %ebx,%esi
  8006d3:	89 d3                	mov    %edx,%ebx
  8006d5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	eb 0b                	jmp    8006e4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006dd:	89 3c 24             	mov    %edi,(%esp)
  8006e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	4b                   	dec    %ebx
  8006e4:	85 db                	test   %ebx,%ebx
  8006e6:	7f f1                	jg     8006d9 <vprintfmt+0x1bb>
  8006e8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006eb:	89 f3                	mov    %esi,%ebx
  8006ed:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	79 05                	jns    8006fc <vprintfmt+0x1de>
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ff:	29 c2                	sub    %eax,%edx
  800701:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800704:	eb 2b                	jmp    800731 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800706:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070a:	74 18                	je     800724 <vprintfmt+0x206>
  80070c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80070f:	83 fa 5e             	cmp    $0x5e,%edx
  800712:	76 10                	jbe    800724 <vprintfmt+0x206>
					putch('?', putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
  800722:	eb 0a                	jmp    80072e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072e:	ff 4d e4             	decl   -0x1c(%ebp)
  800731:	0f be 06             	movsbl (%esi),%eax
  800734:	46                   	inc    %esi
  800735:	85 c0                	test   %eax,%eax
  800737:	74 21                	je     80075a <vprintfmt+0x23c>
  800739:	85 ff                	test   %edi,%edi
  80073b:	78 c9                	js     800706 <vprintfmt+0x1e8>
  80073d:	4f                   	dec    %edi
  80073e:	79 c6                	jns    800706 <vprintfmt+0x1e8>
  800740:	8b 7d 08             	mov    0x8(%ebp),%edi
  800743:	89 de                	mov    %ebx,%esi
  800745:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800748:	eb 18                	jmp    800762 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80074a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800755:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800757:	4b                   	dec    %ebx
  800758:	eb 08                	jmp    800762 <vprintfmt+0x244>
  80075a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075d:	89 de                	mov    %ebx,%esi
  80075f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800762:	85 db                	test   %ebx,%ebx
  800764:	7f e4                	jg     80074a <vprintfmt+0x22c>
  800766:	89 7d 08             	mov    %edi,0x8(%ebp)
  800769:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80076e:	e9 ce fd ff ff       	jmp    800541 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800773:	83 f9 01             	cmp    $0x1,%ecx
  800776:	7e 10                	jle    800788 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8d 50 08             	lea    0x8(%eax),%edx
  80077e:	89 55 14             	mov    %edx,0x14(%ebp)
  800781:	8b 30                	mov    (%eax),%esi
  800783:	8b 78 04             	mov    0x4(%eax),%edi
  800786:	eb 26                	jmp    8007ae <vprintfmt+0x290>
	else if (lflag)
  800788:	85 c9                	test   %ecx,%ecx
  80078a:	74 12                	je     80079e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 50 04             	lea    0x4(%eax),%edx
  800792:	89 55 14             	mov    %edx,0x14(%ebp)
  800795:	8b 30                	mov    (%eax),%esi
  800797:	89 f7                	mov    %esi,%edi
  800799:	c1 ff 1f             	sar    $0x1f,%edi
  80079c:	eb 10                	jmp    8007ae <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 04             	lea    0x4(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a7:	8b 30                	mov    (%eax),%esi
  8007a9:	89 f7                	mov    %esi,%edi
  8007ab:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ae:	85 ff                	test   %edi,%edi
  8007b0:	78 0a                	js     8007bc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b7:	e9 8c 00 00 00       	jmp    800848 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007c7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007ca:	f7 de                	neg    %esi
  8007cc:	83 d7 00             	adc    $0x0,%edi
  8007cf:	f7 df                	neg    %edi
			}
			base = 10;
  8007d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d6:	eb 70                	jmp    800848 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007d8:	89 ca                	mov    %ecx,%edx
  8007da:	8d 45 14             	lea    0x14(%ebp),%eax
  8007dd:	e8 c0 fc ff ff       	call   8004a2 <getuint>
  8007e2:	89 c6                	mov    %eax,%esi
  8007e4:	89 d7                	mov    %edx,%edi
			base = 10;
  8007e6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007eb:	eb 5b                	jmp    800848 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007ed:	89 ca                	mov    %ecx,%edx
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f2:	e8 ab fc ff ff       	call   8004a2 <getuint>
  8007f7:	89 c6                	mov    %eax,%esi
  8007f9:	89 d7                	mov    %edx,%edi
			base = 8;
  8007fb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800800:	eb 46                	jmp    800848 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800802:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800806:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80080d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800810:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800814:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80081b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8d 50 04             	lea    0x4(%eax),%edx
  800824:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800827:	8b 30                	mov    (%eax),%esi
  800829:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80082e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800833:	eb 13                	jmp    800848 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800835:	89 ca                	mov    %ecx,%edx
  800837:	8d 45 14             	lea    0x14(%ebp),%eax
  80083a:	e8 63 fc ff ff       	call   8004a2 <getuint>
  80083f:	89 c6                	mov    %eax,%esi
  800841:	89 d7                	mov    %edx,%edi
			base = 16;
  800843:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800848:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80084c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800850:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800853:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800857:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085b:	89 34 24             	mov    %esi,(%esp)
  80085e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800862:	89 da                	mov    %ebx,%edx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	e8 6c fb ff ff       	call   8003d8 <printnum>
			break;
  80086c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80086f:	e9 cd fc ff ff       	jmp    800541 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800874:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800881:	e9 bb fc ff ff       	jmp    800541 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800886:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800891:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800894:	eb 01                	jmp    800897 <vprintfmt+0x379>
  800896:	4e                   	dec    %esi
  800897:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80089b:	75 f9                	jne    800896 <vprintfmt+0x378>
  80089d:	e9 9f fc ff ff       	jmp    800541 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008a2:	83 c4 4c             	add    $0x4c,%esp
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5f                   	pop    %edi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 28             	sub    $0x28,%esp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008bd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	74 30                	je     8008fb <vsnprintf+0x51>
  8008cb:	85 d2                	test   %edx,%edx
  8008cd:	7e 33                	jle    800902 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e4:	c7 04 24 dc 04 80 00 	movl   $0x8004dc,(%esp)
  8008eb:	e8 2e fc ff ff       	call   80051e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f9:	eb 0c                	jmp    800907 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800900:	eb 05                	jmp    800907 <vsnprintf+0x5d>
  800902:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800912:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800916:	8b 45 10             	mov    0x10(%ebp),%eax
  800919:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	89 44 24 04          	mov    %eax,0x4(%esp)
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	e8 7b ff ff ff       	call   8008aa <vsnprintf>
	va_end(ap);

	return rc;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    
  800931:	00 00                	add    %al,(%eax)
	...

00800934 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
  80093f:	eb 01                	jmp    800942 <strlen+0xe>
		n++;
  800941:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800942:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800946:	75 f9                	jne    800941 <strlen+0xd>
		n++;
	return n;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
  800958:	eb 01                	jmp    80095b <strnlen+0x11>
		n++;
  80095a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095b:	39 d0                	cmp    %edx,%eax
  80095d:	74 06                	je     800965 <strnlen+0x1b>
  80095f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800963:	75 f5                	jne    80095a <strnlen+0x10>
		n++;
	return n;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800971:	ba 00 00 00 00       	mov    $0x0,%edx
  800976:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800979:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80097c:	42                   	inc    %edx
  80097d:	84 c9                	test   %cl,%cl
  80097f:	75 f5                	jne    800976 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800981:	5b                   	pop    %ebx
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	53                   	push   %ebx
  800988:	83 ec 08             	sub    $0x8,%esp
  80098b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80098e:	89 1c 24             	mov    %ebx,(%esp)
  800991:	e8 9e ff ff ff       	call   800934 <strlen>
	strcpy(dst + len, src);
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
  800999:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099d:	01 d8                	add    %ebx,%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	e8 c0 ff ff ff       	call   800967 <strcpy>
	return dst;
}
  8009a7:	89 d8                	mov    %ebx,%eax
  8009a9:	83 c4 08             	add    $0x8,%esp
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ba:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c2:	eb 0c                	jmp    8009d0 <strncpy+0x21>
		*dst++ = *src;
  8009c4:	8a 1a                	mov    (%edx),%bl
  8009c6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c9:	80 3a 01             	cmpb   $0x1,(%edx)
  8009cc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cf:	41                   	inc    %ecx
  8009d0:	39 f1                	cmp    %esi,%ecx
  8009d2:	75 f0                	jne    8009c4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5e                   	pop    %esi
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e6:	85 d2                	test   %edx,%edx
  8009e8:	75 0a                	jne    8009f4 <strlcpy+0x1c>
  8009ea:	89 f0                	mov    %esi,%eax
  8009ec:	eb 1a                	jmp    800a08 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ee:	88 18                	mov    %bl,(%eax)
  8009f0:	40                   	inc    %eax
  8009f1:	41                   	inc    %ecx
  8009f2:	eb 02                	jmp    8009f6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009f6:	4a                   	dec    %edx
  8009f7:	74 0a                	je     800a03 <strlcpy+0x2b>
  8009f9:	8a 19                	mov    (%ecx),%bl
  8009fb:	84 db                	test   %bl,%bl
  8009fd:	75 ef                	jne    8009ee <strlcpy+0x16>
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	eb 02                	jmp    800a05 <strlcpy+0x2d>
  800a03:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a05:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a08:	29 f0                	sub    %esi,%eax
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a17:	eb 02                	jmp    800a1b <strcmp+0xd>
		p++, q++;
  800a19:	41                   	inc    %ecx
  800a1a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1b:	8a 01                	mov    (%ecx),%al
  800a1d:	84 c0                	test   %al,%al
  800a1f:	74 04                	je     800a25 <strcmp+0x17>
  800a21:	3a 02                	cmp    (%edx),%al
  800a23:	74 f4                	je     800a19 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a25:	0f b6 c0             	movzbl %al,%eax
  800a28:	0f b6 12             	movzbl (%edx),%edx
  800a2b:	29 d0                	sub    %edx,%eax
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a39:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a3c:	eb 03                	jmp    800a41 <strncmp+0x12>
		n--, p++, q++;
  800a3e:	4a                   	dec    %edx
  800a3f:	40                   	inc    %eax
  800a40:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a41:	85 d2                	test   %edx,%edx
  800a43:	74 14                	je     800a59 <strncmp+0x2a>
  800a45:	8a 18                	mov    (%eax),%bl
  800a47:	84 db                	test   %bl,%bl
  800a49:	74 04                	je     800a4f <strncmp+0x20>
  800a4b:	3a 19                	cmp    (%ecx),%bl
  800a4d:	74 ef                	je     800a3e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4f:	0f b6 00             	movzbl (%eax),%eax
  800a52:	0f b6 11             	movzbl (%ecx),%edx
  800a55:	29 d0                	sub    %edx,%eax
  800a57:	eb 05                	jmp    800a5e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6a:	eb 05                	jmp    800a71 <strchr+0x10>
		if (*s == c)
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	74 0c                	je     800a7c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a70:	40                   	inc    %eax
  800a71:	8a 10                	mov    (%eax),%dl
  800a73:	84 d2                	test   %dl,%dl
  800a75:	75 f5                	jne    800a6c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a87:	eb 05                	jmp    800a8e <strfind+0x10>
		if (*s == c)
  800a89:	38 ca                	cmp    %cl,%dl
  800a8b:	74 07                	je     800a94 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a8d:	40                   	inc    %eax
  800a8e:	8a 10                	mov    (%eax),%dl
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f5                	jne    800a89 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa5:	85 c9                	test   %ecx,%ecx
  800aa7:	74 30                	je     800ad9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaf:	75 25                	jne    800ad6 <memset+0x40>
  800ab1:	f6 c1 03             	test   $0x3,%cl
  800ab4:	75 20                	jne    800ad6 <memset+0x40>
		c &= 0xFF;
  800ab6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab9:	89 d3                	mov    %edx,%ebx
  800abb:	c1 e3 08             	shl    $0x8,%ebx
  800abe:	89 d6                	mov    %edx,%esi
  800ac0:	c1 e6 18             	shl    $0x18,%esi
  800ac3:	89 d0                	mov    %edx,%eax
  800ac5:	c1 e0 10             	shl    $0x10,%eax
  800ac8:	09 f0                	or     %esi,%eax
  800aca:	09 d0                	or     %edx,%eax
  800acc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ace:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ad1:	fc                   	cld    
  800ad2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad4:	eb 03                	jmp    800ad9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad6:	fc                   	cld    
  800ad7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad9:	89 f8                	mov    %edi,%eax
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aeb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aee:	39 c6                	cmp    %eax,%esi
  800af0:	73 34                	jae    800b26 <memmove+0x46>
  800af2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af5:	39 d0                	cmp    %edx,%eax
  800af7:	73 2d                	jae    800b26 <memmove+0x46>
		s += n;
		d += n;
  800af9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afc:	f6 c2 03             	test   $0x3,%dl
  800aff:	75 1b                	jne    800b1c <memmove+0x3c>
  800b01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b07:	75 13                	jne    800b1c <memmove+0x3c>
  800b09:	f6 c1 03             	test   $0x3,%cl
  800b0c:	75 0e                	jne    800b1c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b0e:	83 ef 04             	sub    $0x4,%edi
  800b11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b14:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b17:	fd                   	std    
  800b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1a:	eb 07                	jmp    800b23 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1c:	4f                   	dec    %edi
  800b1d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b20:	fd                   	std    
  800b21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b23:	fc                   	cld    
  800b24:	eb 20                	jmp    800b46 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2c:	75 13                	jne    800b41 <memmove+0x61>
  800b2e:	a8 03                	test   $0x3,%al
  800b30:	75 0f                	jne    800b41 <memmove+0x61>
  800b32:	f6 c1 03             	test   $0x3,%cl
  800b35:	75 0a                	jne    800b41 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b37:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b3a:	89 c7                	mov    %eax,%edi
  800b3c:	fc                   	cld    
  800b3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3f:	eb 05                	jmp    800b46 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b41:	89 c7                	mov    %eax,%edi
  800b43:	fc                   	cld    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b50:	8b 45 10             	mov    0x10(%ebp),%eax
  800b53:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	89 04 24             	mov    %eax,(%esp)
  800b64:	e8 77 ff ff ff       	call   800ae0 <memmove>
}
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	eb 16                	jmp    800b97 <memcmp+0x2c>
		if (*s1 != *s2)
  800b81:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b84:	42                   	inc    %edx
  800b85:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b89:	38 c8                	cmp    %cl,%al
  800b8b:	74 0a                	je     800b97 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b8d:	0f b6 c0             	movzbl %al,%eax
  800b90:	0f b6 c9             	movzbl %cl,%ecx
  800b93:	29 c8                	sub    %ecx,%eax
  800b95:	eb 09                	jmp    800ba0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b97:	39 da                	cmp    %ebx,%edx
  800b99:	75 e6                	jne    800b81 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bae:	89 c2                	mov    %eax,%edx
  800bb0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb3:	eb 05                	jmp    800bba <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb5:	38 08                	cmp    %cl,(%eax)
  800bb7:	74 05                	je     800bbe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb9:	40                   	inc    %eax
  800bba:	39 d0                	cmp    %edx,%eax
  800bbc:	72 f7                	jb     800bb5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcc:	eb 01                	jmp    800bcf <strtol+0xf>
		s++;
  800bce:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcf:	8a 02                	mov    (%edx),%al
  800bd1:	3c 20                	cmp    $0x20,%al
  800bd3:	74 f9                	je     800bce <strtol+0xe>
  800bd5:	3c 09                	cmp    $0x9,%al
  800bd7:	74 f5                	je     800bce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd9:	3c 2b                	cmp    $0x2b,%al
  800bdb:	75 08                	jne    800be5 <strtol+0x25>
		s++;
  800bdd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bde:	bf 00 00 00 00       	mov    $0x0,%edi
  800be3:	eb 13                	jmp    800bf8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be5:	3c 2d                	cmp    $0x2d,%al
  800be7:	75 0a                	jne    800bf3 <strtol+0x33>
		s++, neg = 1;
  800be9:	8d 52 01             	lea    0x1(%edx),%edx
  800bec:	bf 01 00 00 00       	mov    $0x1,%edi
  800bf1:	eb 05                	jmp    800bf8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf8:	85 db                	test   %ebx,%ebx
  800bfa:	74 05                	je     800c01 <strtol+0x41>
  800bfc:	83 fb 10             	cmp    $0x10,%ebx
  800bff:	75 28                	jne    800c29 <strtol+0x69>
  800c01:	8a 02                	mov    (%edx),%al
  800c03:	3c 30                	cmp    $0x30,%al
  800c05:	75 10                	jne    800c17 <strtol+0x57>
  800c07:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c0b:	75 0a                	jne    800c17 <strtol+0x57>
		s += 2, base = 16;
  800c0d:	83 c2 02             	add    $0x2,%edx
  800c10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c15:	eb 12                	jmp    800c29 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c17:	85 db                	test   %ebx,%ebx
  800c19:	75 0e                	jne    800c29 <strtol+0x69>
  800c1b:	3c 30                	cmp    $0x30,%al
  800c1d:	75 05                	jne    800c24 <strtol+0x64>
		s++, base = 8;
  800c1f:	42                   	inc    %edx
  800c20:	b3 08                	mov    $0x8,%bl
  800c22:	eb 05                	jmp    800c29 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c24:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c30:	8a 0a                	mov    (%edx),%cl
  800c32:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c35:	80 fb 09             	cmp    $0x9,%bl
  800c38:	77 08                	ja     800c42 <strtol+0x82>
			dig = *s - '0';
  800c3a:	0f be c9             	movsbl %cl,%ecx
  800c3d:	83 e9 30             	sub    $0x30,%ecx
  800c40:	eb 1e                	jmp    800c60 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c42:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c45:	80 fb 19             	cmp    $0x19,%bl
  800c48:	77 08                	ja     800c52 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c4a:	0f be c9             	movsbl %cl,%ecx
  800c4d:	83 e9 57             	sub    $0x57,%ecx
  800c50:	eb 0e                	jmp    800c60 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c52:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c55:	80 fb 19             	cmp    $0x19,%bl
  800c58:	77 12                	ja     800c6c <strtol+0xac>
			dig = *s - 'A' + 10;
  800c5a:	0f be c9             	movsbl %cl,%ecx
  800c5d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c60:	39 f1                	cmp    %esi,%ecx
  800c62:	7d 0c                	jge    800c70 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c64:	42                   	inc    %edx
  800c65:	0f af c6             	imul   %esi,%eax
  800c68:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c6a:	eb c4                	jmp    800c30 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c6c:	89 c1                	mov    %eax,%ecx
  800c6e:	eb 02                	jmp    800c72 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c70:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c76:	74 05                	je     800c7d <strtol+0xbd>
		*endptr = (char *) s;
  800c78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	74 04                	je     800c85 <strtol+0xc5>
  800c81:	89 c8                	mov    %ecx,%eax
  800c83:	f7 d8                	neg    %eax
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    
	...

00800c8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 c3                	mov    %eax,%ebx
  800c9f:	89 c7                	mov    %eax,%edi
  800ca1:	89 c6                	mov    %eax,%esi
  800ca3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_cgetc>:

int
sys_cgetc(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 cb                	mov    %ecx,%ebx
  800ce1:	89 cf                	mov    %ecx,%edi
  800ce3:	89 ce                	mov    %ecx,%esi
  800ce5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 28                	jle    800d13 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800cfe:	00 
  800cff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d06:	00 
  800d07:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800d0e:	e8 b1 f5 ff ff       	call   8002c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d13:	83 c4 2c             	add    $0x2c,%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	ba 00 00 00 00       	mov    $0x0,%edx
  800d26:	b8 02 00 00 00       	mov    $0x2,%eax
  800d2b:	89 d1                	mov    %edx,%ecx
  800d2d:	89 d3                	mov    %edx,%ebx
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 d6                	mov    %edx,%esi
  800d33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_yield>:

void
sys_yield(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4a:	89 d1                	mov    %edx,%ecx
  800d4c:	89 d3                	mov    %edx,%ebx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	be 00 00 00 00       	mov    $0x0,%esi
  800d67:	b8 04 00 00 00       	mov    $0x4,%eax
  800d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 f7                	mov    %esi,%edi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800da0:	e8 1f f5 ff ff       	call   8002c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dbb:	8b 75 18             	mov    0x18(%ebp),%esi
  800dbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800df3:	e8 cc f4 ff ff       	call   8002c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 28                	jle    800e4b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e27:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800e46:	e8 79 f4 ff ff       	call   8002c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e4b:	83 c4 2c             	add    $0x2c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	b8 08 00 00 00       	mov    $0x8,%eax
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800e99:	e8 26 f4 ff ff       	call   8002c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9e:	83 c4 2c             	add    $0x2c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 df                	mov    %ebx,%edi
  800ec1:	89 de                	mov    %ebx,%esi
  800ec3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	7e 28                	jle    800ef1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800eec:	e8 d3 f3 ff ff       	call   8002c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef1:	83 c4 2c             	add    $0x2c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eff:	be 00 00 00 00       	mov    $0x0,%esi
  800f04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f12:	8b 55 08             	mov    0x8(%ebp),%edx
  800f15:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	89 cb                	mov    %ecx,%ebx
  800f34:	89 cf                	mov    %ecx,%edi
  800f36:	89 ce                	mov    %ecx,%esi
  800f38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	7e 28                	jle    800f66 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f42:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f49:	00 
  800f4a:	c7 44 24 08 c4 14 80 	movl   $0x8014c4,0x8(%esp)
  800f51:	00 
  800f52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f59:	00 
  800f5a:	c7 04 24 e1 14 80 00 	movl   $0x8014e1,(%esp)
  800f61:	e8 5e f3 ff ff       	call   8002c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f66:	83 c4 2c             	add    $0x2c,%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    
	...

00800f70 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	83 ec 10             	sub    $0x10,%esp
  800f76:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f7a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f82:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800f86:	89 cd                	mov    %ecx,%ebp
  800f88:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	75 2c                	jne    800fbc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800f90:	39 f9                	cmp    %edi,%ecx
  800f92:	77 68                	ja     800ffc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f94:	85 c9                	test   %ecx,%ecx
  800f96:	75 0b                	jne    800fa3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f98:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	f7 f1                	div    %ecx
  800fa1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	89 f8                	mov    %edi,%eax
  800fa7:	f7 f1                	div    %ecx
  800fa9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	f7 f1                	div    %ecx
  800faf:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fb1:	89 f0                	mov    %esi,%eax
  800fb3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fbc:	39 f8                	cmp    %edi,%eax
  800fbe:	77 2c                	ja     800fec <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fc0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800fc3:	83 f6 1f             	xor    $0x1f,%esi
  800fc6:	75 4c                	jne    801014 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fc8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fca:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fcf:	72 0a                	jb     800fdb <__udivdi3+0x6b>
  800fd1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800fd5:	0f 87 ad 00 00 00    	ja     801088 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fdb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fe0:	89 f0                	mov    %esi,%eax
  800fe2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	5e                   	pop    %esi
  800fe8:	5f                   	pop    %edi
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    
  800feb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fec:	31 ff                	xor    %edi,%edi
  800fee:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ff0:	89 f0                	mov    %esi,%eax
  800ff2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	5e                   	pop    %esi
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    
  800ffb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ffc:	89 fa                	mov    %edi,%edx
  800ffe:	89 f0                	mov    %esi,%eax
  801000:	f7 f1                	div    %ecx
  801002:	89 c6                	mov    %eax,%esi
  801004:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801006:	89 f0                	mov    %esi,%eax
  801008:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    
  801011:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801014:	89 f1                	mov    %esi,%ecx
  801016:	d3 e0                	shl    %cl,%eax
  801018:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80101c:	b8 20 00 00 00       	mov    $0x20,%eax
  801021:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801023:	89 ea                	mov    %ebp,%edx
  801025:	88 c1                	mov    %al,%cl
  801027:	d3 ea                	shr    %cl,%edx
  801029:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80102d:	09 ca                	or     %ecx,%edx
  80102f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801033:	89 f1                	mov    %esi,%ecx
  801035:	d3 e5                	shl    %cl,%ebp
  801037:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80103b:	89 fd                	mov    %edi,%ebp
  80103d:	88 c1                	mov    %al,%cl
  80103f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801041:	89 fa                	mov    %edi,%edx
  801043:	89 f1                	mov    %esi,%ecx
  801045:	d3 e2                	shl    %cl,%edx
  801047:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80104b:	88 c1                	mov    %al,%cl
  80104d:	d3 ef                	shr    %cl,%edi
  80104f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801051:	89 f8                	mov    %edi,%eax
  801053:	89 ea                	mov    %ebp,%edx
  801055:	f7 74 24 08          	divl   0x8(%esp)
  801059:	89 d1                	mov    %edx,%ecx
  80105b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80105d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801061:	39 d1                	cmp    %edx,%ecx
  801063:	72 17                	jb     80107c <__udivdi3+0x10c>
  801065:	74 09                	je     801070 <__udivdi3+0x100>
  801067:	89 fe                	mov    %edi,%esi
  801069:	31 ff                	xor    %edi,%edi
  80106b:	e9 41 ff ff ff       	jmp    800fb1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801070:	8b 54 24 04          	mov    0x4(%esp),%edx
  801074:	89 f1                	mov    %esi,%ecx
  801076:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801078:	39 c2                	cmp    %eax,%edx
  80107a:	73 eb                	jae    801067 <__udivdi3+0xf7>
		{
		  q0--;
  80107c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80107f:	31 ff                	xor    %edi,%edi
  801081:	e9 2b ff ff ff       	jmp    800fb1 <__udivdi3+0x41>
  801086:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801088:	31 f6                	xor    %esi,%esi
  80108a:	e9 22 ff ff ff       	jmp    800fb1 <__udivdi3+0x41>
	...

00801090 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801090:	55                   	push   %ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	83 ec 20             	sub    $0x20,%esp
  801096:	8b 44 24 30          	mov    0x30(%esp),%eax
  80109a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80109e:	89 44 24 14          	mov    %eax,0x14(%esp)
  8010a2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8010a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8010aa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8010ae:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8010b0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010b2:	85 ed                	test   %ebp,%ebp
  8010b4:	75 16                	jne    8010cc <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8010b6:	39 f1                	cmp    %esi,%ecx
  8010b8:	0f 86 a6 00 00 00    	jbe    801164 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010be:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8010c0:	89 d0                	mov    %edx,%eax
  8010c2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010c4:	83 c4 20             	add    $0x20,%esp
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    
  8010cb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8010cc:	39 f5                	cmp    %esi,%ebp
  8010ce:	0f 87 ac 00 00 00    	ja     801180 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8010d4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8010d7:	83 f0 1f             	xor    $0x1f,%eax
  8010da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010de:	0f 84 a8 00 00 00    	je     80118c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010e4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010e8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8010ea:	bf 20 00 00 00       	mov    $0x20,%edi
  8010ef:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8010f3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010f7:	89 f9                	mov    %edi,%ecx
  8010f9:	d3 e8                	shr    %cl,%eax
  8010fb:	09 e8                	or     %ebp,%eax
  8010fd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801101:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801105:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801109:	d3 e0                	shl    %cl,%eax
  80110b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80110f:	89 f2                	mov    %esi,%edx
  801111:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801113:	8b 44 24 14          	mov    0x14(%esp),%eax
  801117:	d3 e0                	shl    %cl,%eax
  801119:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80111d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801121:	89 f9                	mov    %edi,%ecx
  801123:	d3 e8                	shr    %cl,%eax
  801125:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801127:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801129:	89 f2                	mov    %esi,%edx
  80112b:	f7 74 24 18          	divl   0x18(%esp)
  80112f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801131:	f7 64 24 0c          	mull   0xc(%esp)
  801135:	89 c5                	mov    %eax,%ebp
  801137:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801139:	39 d6                	cmp    %edx,%esi
  80113b:	72 67                	jb     8011a4 <__umoddi3+0x114>
  80113d:	74 75                	je     8011b4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80113f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801143:	29 e8                	sub    %ebp,%eax
  801145:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801147:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80114b:	d3 e8                	shr    %cl,%eax
  80114d:	89 f2                	mov    %esi,%edx
  80114f:	89 f9                	mov    %edi,%ecx
  801151:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801153:	09 d0                	or     %edx,%eax
  801155:	89 f2                	mov    %esi,%edx
  801157:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80115b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80115d:	83 c4 20             	add    $0x20,%esp
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801164:	85 c9                	test   %ecx,%ecx
  801166:	75 0b                	jne    801173 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801168:	b8 01 00 00 00       	mov    $0x1,%eax
  80116d:	31 d2                	xor    %edx,%edx
  80116f:	f7 f1                	div    %ecx
  801171:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801173:	89 f0                	mov    %esi,%eax
  801175:	31 d2                	xor    %edx,%edx
  801177:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801179:	89 f8                	mov    %edi,%eax
  80117b:	e9 3e ff ff ff       	jmp    8010be <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801180:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801182:	83 c4 20             	add    $0x20,%esp
  801185:	5e                   	pop    %esi
  801186:	5f                   	pop    %edi
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    
  801189:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80118c:	39 f5                	cmp    %esi,%ebp
  80118e:	72 04                	jb     801194 <__umoddi3+0x104>
  801190:	39 f9                	cmp    %edi,%ecx
  801192:	77 06                	ja     80119a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801194:	89 f2                	mov    %esi,%edx
  801196:	29 cf                	sub    %ecx,%edi
  801198:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80119a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80119c:	83 c4 20             	add    $0x20,%esp
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    
  8011a3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8011a4:	89 d1                	mov    %edx,%ecx
  8011a6:	89 c5                	mov    %eax,%ebp
  8011a8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8011ac:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8011b0:	eb 8d                	jmp    80113f <__umoddi3+0xaf>
  8011b2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011b4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8011b8:	72 ea                	jb     8011a4 <__umoddi3+0x114>
  8011ba:	89 f1                	mov    %esi,%ecx
  8011bc:	eb 81                	jmp    80113f <__umoddi3+0xaf>
