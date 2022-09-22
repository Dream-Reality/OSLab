
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 b3 03 00 00       	call   8003e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	eb 0a                	jmp    800055 <sum+0x21>
		tot ^= i * s[i];
  80004b:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004f:	0f af ca             	imul   %edx,%ecx
  800052:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800054:	42                   	inc    %edx
  800055:	39 da                	cmp    %ebx,%edx
  800057:	7c f2                	jl     80004b <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800059:	5b                   	pop    %ebx
  80005a:	5e                   	pop    %esi
  80005b:	5d                   	pop    %ebp
  80005c:	c3                   	ret    

0080005d <umain>:

void
umain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800069:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006c:	c7 04 24 20 28 80 00 	movl   $0x802820,(%esp)
  800073:	e8 d8 04 00 00       	call   800550 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800078:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <sum>
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 1a                	je     8000ad <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009a:	00 
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 e8 28 80 00 	movl   $0x8028e8,(%esp)
  8000a6:	e8 a5 04 00 00       	call   800550 <cprintf>
  8000ab:	eb 0c                	jmp    8000b9 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ad:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  8000b4:	e8 97 04 00 00       	call   800550 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b9:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c0:	00 
  8000c1:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000c8:	e8 67 ff ff ff       	call   800034 <sum>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 12                	je     8000e3 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d5:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8000dc:	e8 6f 04 00 00       	call   800550 <cprintf>
  8000e1:	eb 0c                	jmp    8000ef <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e3:	c7 04 24 46 28 80 00 	movl   $0x802846,(%esp)
  8000ea:	e8 61 04 00 00       	call   800550 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ef:	c7 44 24 04 5c 28 80 	movl   $0x80285c,0x4(%esp)
  8000f6:	00 
  8000f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000fd:	89 04 24             	mov    %eax,(%esp)
  800100:	e8 13 0a 00 00       	call   800b18 <strcat>
	for (i = 0; i < argc; i++) {
  800105:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  80010a:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800110:	eb 30                	jmp    800142 <umain+0xe5>
		strcat(args, " '");
  800112:	c7 44 24 04 68 28 80 	movl   $0x802868,0x4(%esp)
  800119:	00 
  80011a:	89 34 24             	mov    %esi,(%esp)
  80011d:	e8 f6 09 00 00       	call   800b18 <strcat>
		strcat(args, argv[i]);
  800122:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	89 34 24             	mov    %esi,(%esp)
  80012c:	e8 e7 09 00 00       	call   800b18 <strcat>
		strcat(args, "'");
  800131:	c7 44 24 04 69 28 80 	movl   $0x802869,0x4(%esp)
  800138:	00 
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 d7 09 00 00       	call   800b18 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800141:	43                   	inc    %ebx
  800142:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800145:	7c cb                	jl     800112 <umain+0xb5>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800147:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  800158:	e8 f3 03 00 00       	call   800550 <cprintf>

	cprintf("init: running sh\n");
  80015d:	c7 04 24 6f 28 80 00 	movl   $0x80286f,(%esp)
  800164:	e8 e7 03 00 00       	call   800550 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 9b 11 00 00       	call   801310 <close>
	if ((r = opencons()) < 0)
  800175:	e8 16 02 00 00       	call   800390 <opencons>
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 20                	jns    80019e <umain+0x141>
		panic("opencons: %e", r);
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	c7 44 24 08 81 28 80 	movl   $0x802881,0x8(%esp)
  800189:	00 
  80018a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800191:	00 
  800192:	c7 04 24 8e 28 80 00 	movl   $0x80288e,(%esp)
  800199:	e8 ba 02 00 00       	call   800458 <_panic>
	if (r != 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	74 20                	je     8001c2 <umain+0x165>
		panic("first opencons used fd %d", r);
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	c7 44 24 08 9a 28 80 	movl   $0x80289a,0x8(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001b5:	00 
  8001b6:	c7 04 24 8e 28 80 00 	movl   $0x80288e,(%esp)
  8001bd:	e8 96 02 00 00       	call   800458 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c9:	00 
  8001ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001d1:	e8 8b 11 00 00       	call   801361 <dup>
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	79 20                	jns    8001fa <umain+0x19d>
		panic("dup: %e", r);
  8001da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001de:	c7 44 24 08 b4 28 80 	movl   $0x8028b4,0x8(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001ed:	00 
  8001ee:	c7 04 24 8e 28 80 00 	movl   $0x80288e,(%esp)
  8001f5:	e8 5e 02 00 00       	call   800458 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001fa:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800201:	e8 4a 03 00 00       	call   800550 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 d0 28 80 	movl   $0x8028d0,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 cf 28 80 00 	movl   $0x8028cf,(%esp)
  80021d:	e8 f8 1d 00 00       	call   80201a <spawnl>
		if (r < 0) {
  800222:	85 c0                	test   %eax,%eax
  800224:	79 12                	jns    800238 <umain+0x1db>
			cprintf("init: spawn sh: %e\n", r);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	c7 04 24 d3 28 80 00 	movl   $0x8028d3,(%esp)
  800231:	e8 1a 03 00 00       	call   800550 <cprintf>
			continue;
  800236:	eb c2                	jmp    8001fa <umain+0x19d>
		}
		wait(r);
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 c4 21 00 00       	call   802404 <wait>
  800240:	eb b8                	jmp    8001fa <umain+0x19d>
	...

00800244 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800247:	b8 00 00 00 00       	mov    $0x0,%eax
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800254:	c7 44 24 04 53 29 80 	movl   $0x802953,0x4(%esp)
  80025b:	00 
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 94 08 00 00       	call   800afb <strcpy>
	return 0;
}
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80027f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800285:	eb 30                	jmp    8002b7 <devcons_write+0x49>
		m = n - tot;
  800287:	8b 75 10             	mov    0x10(%ebp),%esi
  80028a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80028c:	83 fe 7f             	cmp    $0x7f,%esi
  80028f:	76 05                	jbe    800296 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800291:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800296:	89 74 24 08          	mov    %esi,0x8(%esp)
  80029a:	03 45 0c             	add    0xc(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	89 3c 24             	mov    %edi,(%esp)
  8002a4:	e8 cb 09 00 00       	call   800c74 <memmove>
		sys_cputs(buf, m);
  8002a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ad:	89 3c 24             	mov    %edi,(%esp)
  8002b0:	e8 6b 0b 00 00       	call   800e20 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002b5:	01 f3                	add    %esi,%ebx
  8002b7:	89 d8                	mov    %ebx,%eax
  8002b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002bc:	72 c9                	jb     800287 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002be:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002d3:	75 07                	jne    8002dc <devcons_read+0x13>
  8002d5:	eb 25                	jmp    8002fc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002d7:	e8 f2 0b 00 00       	call   800ece <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002dc:	e8 5d 0b 00 00       	call   800e3e <sys_cgetc>
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	74 f2                	je     8002d7 <devcons_read+0xe>
  8002e5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	78 1d                	js     800308 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002eb:	83 f8 04             	cmp    $0x4,%eax
  8002ee:	74 13                	je     800303 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	88 10                	mov    %dl,(%eax)
	return 1;
  8002f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8002fa:	eb 0c                	jmp    800308 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	eb 05                	jmp    800308 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031d:	00 
  80031e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 f7 0a 00 00       	call   800e20 <sys_cputs>
}
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <getchar>:

int
getchar(void)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800347:	e8 28 11 00 00       	call   801474 <read>
	if (r < 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	78 0f                	js     80035f <getchar+0x34>
		return r;
	if (r < 1)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 06                	jle    80035a <getchar+0x2f>
		return -E_EOF;
	return c;
  800354:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800358:	eb 05                	jmp    80035f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80035a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	e8 5d 0e 00 00       	call   8011d6 <fd_lookup>
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 11                	js     80038e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80037d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800380:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800386:	39 10                	cmp    %edx,(%eax)
  800388:	0f 94 c0             	sete   %al
  80038b:	0f b6 c0             	movzbl %al,%eax
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <opencons>:

int
opencons(void)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 e2 0d 00 00       	call   801183 <fd_alloc>
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	78 3c                	js     8003e1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003ac:	00 
  8003ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003bb:	e8 2d 0b 00 00       	call   800eed <sys_page_alloc>
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	78 1d                	js     8003e1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003c4:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003d9:	89 04 24             	mov    %eax,(%esp)
  8003dc:	e8 77 0d 00 00       	call   801158 <fd2num>
}
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    
	...

008003e4 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 20             	sub    $0x20,%esp
  8003ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8003f2:	e8 b8 0a 00 00       	call   800eaf <sys_getenvid>
  8003f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800403:	c1 e0 07             	shl    $0x7,%eax
  800406:	29 d0                	sub    %edx,%eax
  800408:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80040d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800410:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800413:	a3 90 67 80 00       	mov    %eax,0x806790
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800418:	85 f6                	test   %esi,%esi
  80041a:	7e 07                	jle    800423 <libmain+0x3f>
		binaryname = argv[0];
  80041c:	8b 03                	mov    (%ebx),%eax
  80041e:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  800423:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800427:	89 34 24             	mov    %esi,(%esp)
  80042a:	e8 2e fc ff ff       	call   80005d <umain>

	// exit gracefully
	exit();
  80042f:	e8 08 00 00 00       	call   80043c <exit>
}
  800434:	83 c4 20             	add    $0x20,%esp
  800437:	5b                   	pop    %ebx
  800438:	5e                   	pop    %esi
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    
	...

0080043c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800442:	e8 fa 0e 00 00       	call   801341 <close_all>
	sys_env_destroy(0);
  800447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80044e:	e8 0a 0a 00 00       	call   800e5d <sys_env_destroy>
}
  800453:	c9                   	leave  
  800454:	c3                   	ret    
  800455:	00 00                	add    %al,(%eax)
	...

00800458 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
  80045b:	56                   	push   %esi
  80045c:	53                   	push   %ebx
  80045d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800460:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800463:	8b 1d 8c 47 80 00    	mov    0x80478c,%ebx
  800469:	e8 41 0a 00 00       	call   800eaf <sys_getenvid>
  80046e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800471:	89 54 24 10          	mov    %edx,0x10(%esp)
  800475:	8b 55 08             	mov    0x8(%ebp),%edx
  800478:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800480:	89 44 24 04          	mov    %eax,0x4(%esp)
  800484:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  80048b:	e8 c0 00 00 00       	call   800550 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800490:	89 74 24 04          	mov    %esi,0x4(%esp)
  800494:	8b 45 10             	mov    0x10(%ebp),%eax
  800497:	89 04 24             	mov    %eax,(%esp)
  80049a:	e8 50 00 00 00       	call   8004ef <vcprintf>
	cprintf("\n");
  80049f:	c7 04 24 6d 2e 80 00 	movl   $0x802e6d,(%esp)
  8004a6:	e8 a5 00 00 00       	call   800550 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ab:	cc                   	int3   
  8004ac:	eb fd                	jmp    8004ab <_panic+0x53>
	...

008004b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 14             	sub    $0x14,%esp
  8004b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ba:	8b 03                	mov    (%ebx),%eax
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004c3:	40                   	inc    %eax
  8004c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004cb:	75 19                	jne    8004e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d4:	00 
  8004d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 40 09 00 00       	call   800e20 <sys_cputs>
		b->idx = 0;
  8004e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e6:	ff 43 04             	incl   0x4(%ebx)
}
  8004e9:	83 c4 14             	add    $0x14,%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ff:	00 00 00 
	b.cnt = 0;
  800502:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800509:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800520:	89 44 24 04          	mov    %eax,0x4(%esp)
  800524:	c7 04 24 b0 04 80 00 	movl   $0x8004b0,(%esp)
  80052b:	e8 82 01 00 00       	call   8006b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800530:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	e8 d8 08 00 00       	call   800e20 <sys_cputs>

	return b.cnt;
}
  800548:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800556:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	e8 87 ff ff ff       	call   8004ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800568:	c9                   	leave  
  800569:	c3                   	ret    
	...

0080056c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	57                   	push   %edi
  800570:	56                   	push   %esi
  800571:	53                   	push   %ebx
  800572:	83 ec 3c             	sub    $0x3c,%esp
  800575:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800578:	89 d7                	mov    %edx,%edi
  80057a:	8b 45 08             	mov    0x8(%ebp),%eax
  80057d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800580:	8b 45 0c             	mov    0xc(%ebp),%eax
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800589:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80058c:	85 c0                	test   %eax,%eax
  80058e:	75 08                	jne    800598 <printnum+0x2c>
  800590:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800593:	39 45 10             	cmp    %eax,0x10(%ebp)
  800596:	77 57                	ja     8005ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800598:	89 74 24 10          	mov    %esi,0x10(%esp)
  80059c:	4b                   	dec    %ebx
  80059d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b7:	00 
  8005b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c5:	e8 02 20 00 00       	call   8025cc <__udivdi3>
  8005ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d9:	89 fa                	mov    %edi,%edx
  8005db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005de:	e8 89 ff ff ff       	call   80056c <printnum>
  8005e3:	eb 0f                	jmp    8005f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e9:	89 34 24             	mov    %esi,(%esp)
  8005ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ef:	4b                   	dec    %ebx
  8005f0:	85 db                	test   %ebx,%ebx
  8005f2:	7f f1                	jg     8005e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800603:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80060a:	00 
  80060b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	e8 cf 20 00 00       	call   8026ec <__umoddi3>
  80061d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800621:	0f be 80 8f 29 80 00 	movsbl 0x80298f(%eax),%eax
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80062e:	83 c4 3c             	add    $0x3c,%esp
  800631:	5b                   	pop    %ebx
  800632:	5e                   	pop    %esi
  800633:	5f                   	pop    %edi
  800634:	5d                   	pop    %ebp
  800635:	c3                   	ret    

00800636 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800639:	83 fa 01             	cmp    $0x1,%edx
  80063c:	7e 0e                	jle    80064c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	8d 4a 08             	lea    0x8(%edx),%ecx
  800643:	89 08                	mov    %ecx,(%eax)
  800645:	8b 02                	mov    (%edx),%eax
  800647:	8b 52 04             	mov    0x4(%edx),%edx
  80064a:	eb 22                	jmp    80066e <getuint+0x38>
	else if (lflag)
  80064c:	85 d2                	test   %edx,%edx
  80064e:	74 10                	je     800660 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800650:	8b 10                	mov    (%eax),%edx
  800652:	8d 4a 04             	lea    0x4(%edx),%ecx
  800655:	89 08                	mov    %ecx,(%eax)
  800657:	8b 02                	mov    (%edx),%eax
  800659:	ba 00 00 00 00       	mov    $0x0,%edx
  80065e:	eb 0e                	jmp    80066e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800660:	8b 10                	mov    (%eax),%edx
  800662:	8d 4a 04             	lea    0x4(%edx),%ecx
  800665:	89 08                	mov    %ecx,(%eax)
  800667:	8b 02                	mov    (%edx),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800676:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	3b 50 04             	cmp    0x4(%eax),%edx
  80067e:	73 08                	jae    800688 <sprintputch+0x18>
		*b->buf++ = ch;
  800680:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800683:	88 0a                	mov    %cl,(%edx)
  800685:	42                   	inc    %edx
  800686:	89 10                	mov    %edx,(%eax)
}
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800693:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800697:	8b 45 10             	mov    0x10(%ebp),%eax
  80069a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	e8 02 00 00 00       	call   8006b2 <vprintfmt>
	va_end(ap);
}
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	57                   	push   %edi
  8006b6:	56                   	push   %esi
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 4c             	sub    $0x4c,%esp
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	8b 75 10             	mov    0x10(%ebp),%esi
  8006c1:	eb 12                	jmp    8006d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	0f 84 6b 03 00 00    	je     800a36 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d5:	0f b6 06             	movzbl (%esi),%eax
  8006d8:	46                   	inc    %esi
  8006d9:	83 f8 25             	cmp    $0x25,%eax
  8006dc:	75 e5                	jne    8006c3 <vprintfmt+0x11>
  8006de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fa:	eb 26                	jmp    800722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800703:	eb 1d                	jmp    800722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800705:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800708:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80070c:	eb 14                	jmp    800722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800711:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800718:	eb 08                	jmp    800722 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80071a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80071d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	0f b6 06             	movzbl (%esi),%eax
  800725:	8d 56 01             	lea    0x1(%esi),%edx
  800728:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80072b:	8a 16                	mov    (%esi),%dl
  80072d:	83 ea 23             	sub    $0x23,%edx
  800730:	80 fa 55             	cmp    $0x55,%dl
  800733:	0f 87 e1 02 00 00    	ja     800a1a <vprintfmt+0x368>
  800739:	0f b6 d2             	movzbl %dl,%edx
  80073c:	ff 24 95 e0 2a 80 00 	jmp    *0x802ae0(,%edx,4)
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800746:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80074b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80074e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800752:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800755:	8d 50 d0             	lea    -0x30(%eax),%edx
  800758:	83 fa 09             	cmp    $0x9,%edx
  80075b:	77 2a                	ja     800787 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075e:	eb eb                	jmp    80074b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)
  800769:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80076e:	eb 17                	jmp    800787 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800770:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800774:	78 98                	js     80070e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800779:	eb a7                	jmp    800722 <vprintfmt+0x70>
  80077b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80077e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800785:	eb 9b                	jmp    800722 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800787:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80078b:	79 95                	jns    800722 <vprintfmt+0x70>
  80078d:	eb 8b                	jmp    80071a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80078f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800790:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800793:	eb 8d                	jmp    800722 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 04             	lea    0x4(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)
  80079e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007ad:	e9 23 ff ff ff       	jmp    8006d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 50 04             	lea    0x4(%eax),%edx
  8007b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	79 02                	jns    8007c3 <vprintfmt+0x111>
  8007c1:	f7 d8                	neg    %eax
  8007c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007c5:	83 f8 0f             	cmp    $0xf,%eax
  8007c8:	7f 0b                	jg     8007d5 <vprintfmt+0x123>
  8007ca:	8b 04 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%eax
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	75 23                	jne    8007f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d9:	c7 44 24 08 a7 29 80 	movl   $0x8029a7,0x8(%esp)
  8007e0:	00 
  8007e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	89 04 24             	mov    %eax,(%esp)
  8007eb:	e8 9a fe ff ff       	call   80068a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007f3:	e9 dd fe ff ff       	jmp    8006d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fc:	c7 44 24 08 71 2d 80 	movl   $0x802d71,0x8(%esp)
  800803:	00 
  800804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800808:	8b 55 08             	mov    0x8(%ebp),%edx
  80080b:	89 14 24             	mov    %edx,(%esp)
  80080e:	e8 77 fe ff ff       	call   80068a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800816:	e9 ba fe ff ff       	jmp    8006d5 <vprintfmt+0x23>
  80081b:	89 f9                	mov    %edi,%ecx
  80081d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800820:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8d 50 04             	lea    0x4(%eax),%edx
  800829:	89 55 14             	mov    %edx,0x14(%ebp)
  80082c:	8b 30                	mov    (%eax),%esi
  80082e:	85 f6                	test   %esi,%esi
  800830:	75 05                	jne    800837 <vprintfmt+0x185>
				p = "(null)";
  800832:	be a0 29 80 00       	mov    $0x8029a0,%esi
			if (width > 0 && padc != '-')
  800837:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80083b:	0f 8e 84 00 00 00    	jle    8008c5 <vprintfmt+0x213>
  800841:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800845:	74 7e                	je     8008c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800847:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80084b:	89 34 24             	mov    %esi,(%esp)
  80084e:	e8 8b 02 00 00       	call   800ade <strnlen>
  800853:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800856:	29 c2                	sub    %eax,%edx
  800858:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80085b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80085f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800862:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800865:	89 de                	mov    %ebx,%esi
  800867:	89 d3                	mov    %edx,%ebx
  800869:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086b:	eb 0b                	jmp    800878 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80086d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800871:	89 3c 24             	mov    %edi,(%esp)
  800874:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800877:	4b                   	dec    %ebx
  800878:	85 db                	test   %ebx,%ebx
  80087a:	7f f1                	jg     80086d <vprintfmt+0x1bb>
  80087c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80087f:	89 f3                	mov    %esi,%ebx
  800881:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800887:	85 c0                	test   %eax,%eax
  800889:	79 05                	jns    800890 <vprintfmt+0x1de>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
  800890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800893:	29 c2                	sub    %eax,%edx
  800895:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800898:	eb 2b                	jmp    8008c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80089a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80089e:	74 18                	je     8008b8 <vprintfmt+0x206>
  8008a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008a3:	83 fa 5e             	cmp    $0x5e,%edx
  8008a6:	76 10                	jbe    8008b8 <vprintfmt+0x206>
					putch('?', putdat);
  8008a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008b3:	ff 55 08             	call   *0x8(%ebp)
  8008b6:	eb 0a                	jmp    8008c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8008c5:	0f be 06             	movsbl (%esi),%eax
  8008c8:	46                   	inc    %esi
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	74 21                	je     8008ee <vprintfmt+0x23c>
  8008cd:	85 ff                	test   %edi,%edi
  8008cf:	78 c9                	js     80089a <vprintfmt+0x1e8>
  8008d1:	4f                   	dec    %edi
  8008d2:	79 c6                	jns    80089a <vprintfmt+0x1e8>
  8008d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d7:	89 de                	mov    %ebx,%esi
  8008d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008dc:	eb 18                	jmp    8008f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008eb:	4b                   	dec    %ebx
  8008ec:	eb 08                	jmp    8008f6 <vprintfmt+0x244>
  8008ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f1:	89 de                	mov    %ebx,%esi
  8008f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f6:	85 db                	test   %ebx,%ebx
  8008f8:	7f e4                	jg     8008de <vprintfmt+0x22c>
  8008fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800902:	e9 ce fd ff ff       	jmp    8006d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800907:	83 f9 01             	cmp    $0x1,%ecx
  80090a:	7e 10                	jle    80091c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8d 50 08             	lea    0x8(%eax),%edx
  800912:	89 55 14             	mov    %edx,0x14(%ebp)
  800915:	8b 30                	mov    (%eax),%esi
  800917:	8b 78 04             	mov    0x4(%eax),%edi
  80091a:	eb 26                	jmp    800942 <vprintfmt+0x290>
	else if (lflag)
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	74 12                	je     800932 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8d 50 04             	lea    0x4(%eax),%edx
  800926:	89 55 14             	mov    %edx,0x14(%ebp)
  800929:	8b 30                	mov    (%eax),%esi
  80092b:	89 f7                	mov    %esi,%edi
  80092d:	c1 ff 1f             	sar    $0x1f,%edi
  800930:	eb 10                	jmp    800942 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8d 50 04             	lea    0x4(%eax),%edx
  800938:	89 55 14             	mov    %edx,0x14(%ebp)
  80093b:	8b 30                	mov    (%eax),%esi
  80093d:	89 f7                	mov    %esi,%edi
  80093f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800942:	85 ff                	test   %edi,%edi
  800944:	78 0a                	js     800950 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800946:	b8 0a 00 00 00       	mov    $0xa,%eax
  80094b:	e9 8c 00 00 00       	jmp    8009dc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800954:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80095b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80095e:	f7 de                	neg    %esi
  800960:	83 d7 00             	adc    $0x0,%edi
  800963:	f7 df                	neg    %edi
			}
			base = 10;
  800965:	b8 0a 00 00 00       	mov    $0xa,%eax
  80096a:	eb 70                	jmp    8009dc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80096c:	89 ca                	mov    %ecx,%edx
  80096e:	8d 45 14             	lea    0x14(%ebp),%eax
  800971:	e8 c0 fc ff ff       	call   800636 <getuint>
  800976:	89 c6                	mov    %eax,%esi
  800978:	89 d7                	mov    %edx,%edi
			base = 10;
  80097a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80097f:	eb 5b                	jmp    8009dc <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800981:	89 ca                	mov    %ecx,%edx
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
  800986:	e8 ab fc ff ff       	call   800636 <getuint>
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	89 d7                	mov    %edx,%edi
			base = 8;
  80098f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800994:	eb 46                	jmp    8009dc <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800996:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b5:	8d 50 04             	lea    0x4(%eax),%edx
  8009b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009bb:	8b 30                	mov    (%eax),%esi
  8009bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009c7:	eb 13                	jmp    8009dc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c9:	89 ca                	mov    %ecx,%edx
  8009cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ce:	e8 63 fc ff ff       	call   800636 <getuint>
  8009d3:	89 c6                	mov    %eax,%esi
  8009d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8009d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ef:	89 34 24             	mov    %esi,(%esp)
  8009f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f6:	89 da                	mov    %ebx,%edx
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	e8 6c fb ff ff       	call   80056c <printnum>
			break;
  800a00:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a03:	e9 cd fc ff ff       	jmp    8006d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0c:	89 04 24             	mov    %eax,(%esp)
  800a0f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a12:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a15:	e9 bb fc ff ff       	jmp    8006d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a25:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a28:	eb 01                	jmp    800a2b <vprintfmt+0x379>
  800a2a:	4e                   	dec    %esi
  800a2b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a2f:	75 f9                	jne    800a2a <vprintfmt+0x378>
  800a31:	e9 9f fc ff ff       	jmp    8006d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a36:	83 c4 4c             	add    $0x4c,%esp
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 28             	sub    $0x28,%esp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a4d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a51:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a5b:	85 c0                	test   %eax,%eax
  800a5d:	74 30                	je     800a8f <vsnprintf+0x51>
  800a5f:	85 d2                	test   %edx,%edx
  800a61:	7e 33                	jle    800a96 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a63:	8b 45 14             	mov    0x14(%ebp),%eax
  800a66:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a71:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	c7 04 24 70 06 80 00 	movl   $0x800670,(%esp)
  800a7f:	e8 2e fc ff ff       	call   8006b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a87:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a8d:	eb 0c                	jmp    800a9b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a94:	eb 05                	jmp    800a9b <vsnprintf+0x5d>
  800a96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aa3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aaa:	8b 45 10             	mov    0x10(%ebp),%eax
  800aad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 7b ff ff ff       	call   800a3e <vsnprintf>
	va_end(ap);

	return rc;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    
  800ac5:	00 00                	add    %al,(%eax)
	...

00800ac8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ace:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad3:	eb 01                	jmp    800ad6 <strlen+0xe>
		n++;
  800ad5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ada:	75 f9                	jne    800ad5 <strlen+0xd>
		n++;
	return n;
}
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	eb 01                	jmp    800aef <strnlen+0x11>
		n++;
  800aee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aef:	39 d0                	cmp    %edx,%eax
  800af1:	74 06                	je     800af9 <strnlen+0x1b>
  800af3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af7:	75 f5                	jne    800aee <strnlen+0x10>
		n++;
	return n;
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b10:	42                   	inc    %edx
  800b11:	84 c9                	test   %cl,%cl
  800b13:	75 f5                	jne    800b0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b15:	5b                   	pop    %ebx
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b22:	89 1c 24             	mov    %ebx,(%esp)
  800b25:	e8 9e ff ff ff       	call   800ac8 <strlen>
	strcpy(dst + len, src);
  800b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b31:	01 d8                	add    %ebx,%eax
  800b33:	89 04 24             	mov    %eax,(%esp)
  800b36:	e8 c0 ff ff ff       	call   800afb <strcpy>
	return dst;
}
  800b3b:	89 d8                	mov    %ebx,%eax
  800b3d:	83 c4 08             	add    $0x8,%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b56:	eb 0c                	jmp    800b64 <strncpy+0x21>
		*dst++ = *src;
  800b58:	8a 1a                	mov    (%edx),%bl
  800b5a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b5d:	80 3a 01             	cmpb   $0x1,(%edx)
  800b60:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b63:	41                   	inc    %ecx
  800b64:	39 f1                	cmp    %esi,%ecx
  800b66:	75 f0                	jne    800b58 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 75 08             	mov    0x8(%ebp),%esi
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b77:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b7a:	85 d2                	test   %edx,%edx
  800b7c:	75 0a                	jne    800b88 <strlcpy+0x1c>
  800b7e:	89 f0                	mov    %esi,%eax
  800b80:	eb 1a                	jmp    800b9c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b82:	88 18                	mov    %bl,(%eax)
  800b84:	40                   	inc    %eax
  800b85:	41                   	inc    %ecx
  800b86:	eb 02                	jmp    800b8a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b88:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b8a:	4a                   	dec    %edx
  800b8b:	74 0a                	je     800b97 <strlcpy+0x2b>
  800b8d:	8a 19                	mov    (%ecx),%bl
  800b8f:	84 db                	test   %bl,%bl
  800b91:	75 ef                	jne    800b82 <strlcpy+0x16>
  800b93:	89 c2                	mov    %eax,%edx
  800b95:	eb 02                	jmp    800b99 <strlcpy+0x2d>
  800b97:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b99:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b9c:	29 f0                	sub    %esi,%eax
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bab:	eb 02                	jmp    800baf <strcmp+0xd>
		p++, q++;
  800bad:	41                   	inc    %ecx
  800bae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800baf:	8a 01                	mov    (%ecx),%al
  800bb1:	84 c0                	test   %al,%al
  800bb3:	74 04                	je     800bb9 <strcmp+0x17>
  800bb5:	3a 02                	cmp    (%edx),%al
  800bb7:	74 f4                	je     800bad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb9:	0f b6 c0             	movzbl %al,%eax
  800bbc:	0f b6 12             	movzbl (%edx),%edx
  800bbf:	29 d0                	sub    %edx,%eax
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	53                   	push   %ebx
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bd0:	eb 03                	jmp    800bd5 <strncmp+0x12>
		n--, p++, q++;
  800bd2:	4a                   	dec    %edx
  800bd3:	40                   	inc    %eax
  800bd4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd5:	85 d2                	test   %edx,%edx
  800bd7:	74 14                	je     800bed <strncmp+0x2a>
  800bd9:	8a 18                	mov    (%eax),%bl
  800bdb:	84 db                	test   %bl,%bl
  800bdd:	74 04                	je     800be3 <strncmp+0x20>
  800bdf:	3a 19                	cmp    (%ecx),%bl
  800be1:	74 ef                	je     800bd2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800be3:	0f b6 00             	movzbl (%eax),%eax
  800be6:	0f b6 11             	movzbl (%ecx),%edx
  800be9:	29 d0                	sub    %edx,%eax
  800beb:	eb 05                	jmp    800bf2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bfe:	eb 05                	jmp    800c05 <strchr+0x10>
		if (*s == c)
  800c00:	38 ca                	cmp    %cl,%dl
  800c02:	74 0c                	je     800c10 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c04:	40                   	inc    %eax
  800c05:	8a 10                	mov    (%eax),%dl
  800c07:	84 d2                	test   %dl,%dl
  800c09:	75 f5                	jne    800c00 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c1b:	eb 05                	jmp    800c22 <strfind+0x10>
		if (*s == c)
  800c1d:	38 ca                	cmp    %cl,%dl
  800c1f:	74 07                	je     800c28 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c21:	40                   	inc    %eax
  800c22:	8a 10                	mov    (%eax),%dl
  800c24:	84 d2                	test   %dl,%dl
  800c26:	75 f5                	jne    800c1d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c39:	85 c9                	test   %ecx,%ecx
  800c3b:	74 30                	je     800c6d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c43:	75 25                	jne    800c6a <memset+0x40>
  800c45:	f6 c1 03             	test   $0x3,%cl
  800c48:	75 20                	jne    800c6a <memset+0x40>
		c &= 0xFF;
  800c4a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	c1 e3 08             	shl    $0x8,%ebx
  800c52:	89 d6                	mov    %edx,%esi
  800c54:	c1 e6 18             	shl    $0x18,%esi
  800c57:	89 d0                	mov    %edx,%eax
  800c59:	c1 e0 10             	shl    $0x10,%eax
  800c5c:	09 f0                	or     %esi,%eax
  800c5e:	09 d0                	or     %edx,%eax
  800c60:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c62:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c65:	fc                   	cld    
  800c66:	f3 ab                	rep stos %eax,%es:(%edi)
  800c68:	eb 03                	jmp    800c6d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c6a:	fc                   	cld    
  800c6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c6d:	89 f8                	mov    %edi,%eax
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c82:	39 c6                	cmp    %eax,%esi
  800c84:	73 34                	jae    800cba <memmove+0x46>
  800c86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c89:	39 d0                	cmp    %edx,%eax
  800c8b:	73 2d                	jae    800cba <memmove+0x46>
		s += n;
		d += n;
  800c8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c90:	f6 c2 03             	test   $0x3,%dl
  800c93:	75 1b                	jne    800cb0 <memmove+0x3c>
  800c95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9b:	75 13                	jne    800cb0 <memmove+0x3c>
  800c9d:	f6 c1 03             	test   $0x3,%cl
  800ca0:	75 0e                	jne    800cb0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ca2:	83 ef 04             	sub    $0x4,%edi
  800ca5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cab:	fd                   	std    
  800cac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cae:	eb 07                	jmp    800cb7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cb0:	4f                   	dec    %edi
  800cb1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb4:	fd                   	std    
  800cb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb7:	fc                   	cld    
  800cb8:	eb 20                	jmp    800cda <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cc0:	75 13                	jne    800cd5 <memmove+0x61>
  800cc2:	a8 03                	test   $0x3,%al
  800cc4:	75 0f                	jne    800cd5 <memmove+0x61>
  800cc6:	f6 c1 03             	test   $0x3,%cl
  800cc9:	75 0a                	jne    800cd5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ccb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cce:	89 c7                	mov    %eax,%edi
  800cd0:	fc                   	cld    
  800cd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cd3:	eb 05                	jmp    800cda <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd5:	89 c7                	mov    %eax,%edi
  800cd7:	fc                   	cld    
  800cd8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	89 04 24             	mov    %eax,(%esp)
  800cf8:	e8 77 ff ff ff       	call   800c74 <memmove>
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d13:	eb 16                	jmp    800d2b <memcmp+0x2c>
		if (*s1 != *s2)
  800d15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d18:	42                   	inc    %edx
  800d19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d1d:	38 c8                	cmp    %cl,%al
  800d1f:	74 0a                	je     800d2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d21:	0f b6 c0             	movzbl %al,%eax
  800d24:	0f b6 c9             	movzbl %cl,%ecx
  800d27:	29 c8                	sub    %ecx,%eax
  800d29:	eb 09                	jmp    800d34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2b:	39 da                	cmp    %ebx,%edx
  800d2d:	75 e6                	jne    800d15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d42:	89 c2                	mov    %eax,%edx
  800d44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d47:	eb 05                	jmp    800d4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d49:	38 08                	cmp    %cl,(%eax)
  800d4b:	74 05                	je     800d52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d4d:	40                   	inc    %eax
  800d4e:	39 d0                	cmp    %edx,%eax
  800d50:	72 f7                	jb     800d49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d60:	eb 01                	jmp    800d63 <strtol+0xf>
		s++;
  800d62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d63:	8a 02                	mov    (%edx),%al
  800d65:	3c 20                	cmp    $0x20,%al
  800d67:	74 f9                	je     800d62 <strtol+0xe>
  800d69:	3c 09                	cmp    $0x9,%al
  800d6b:	74 f5                	je     800d62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d6d:	3c 2b                	cmp    $0x2b,%al
  800d6f:	75 08                	jne    800d79 <strtol+0x25>
		s++;
  800d71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d72:	bf 00 00 00 00       	mov    $0x0,%edi
  800d77:	eb 13                	jmp    800d8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d79:	3c 2d                	cmp    $0x2d,%al
  800d7b:	75 0a                	jne    800d87 <strtol+0x33>
		s++, neg = 1;
  800d7d:	8d 52 01             	lea    0x1(%edx),%edx
  800d80:	bf 01 00 00 00       	mov    $0x1,%edi
  800d85:	eb 05                	jmp    800d8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d8c:	85 db                	test   %ebx,%ebx
  800d8e:	74 05                	je     800d95 <strtol+0x41>
  800d90:	83 fb 10             	cmp    $0x10,%ebx
  800d93:	75 28                	jne    800dbd <strtol+0x69>
  800d95:	8a 02                	mov    (%edx),%al
  800d97:	3c 30                	cmp    $0x30,%al
  800d99:	75 10                	jne    800dab <strtol+0x57>
  800d9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d9f:	75 0a                	jne    800dab <strtol+0x57>
		s += 2, base = 16;
  800da1:	83 c2 02             	add    $0x2,%edx
  800da4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da9:	eb 12                	jmp    800dbd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800dab:	85 db                	test   %ebx,%ebx
  800dad:	75 0e                	jne    800dbd <strtol+0x69>
  800daf:	3c 30                	cmp    $0x30,%al
  800db1:	75 05                	jne    800db8 <strtol+0x64>
		s++, base = 8;
  800db3:	42                   	inc    %edx
  800db4:	b3 08                	mov    $0x8,%bl
  800db6:	eb 05                	jmp    800dbd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800db8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc4:	8a 0a                	mov    (%edx),%cl
  800dc6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dc9:	80 fb 09             	cmp    $0x9,%bl
  800dcc:	77 08                	ja     800dd6 <strtol+0x82>
			dig = *s - '0';
  800dce:	0f be c9             	movsbl %cl,%ecx
  800dd1:	83 e9 30             	sub    $0x30,%ecx
  800dd4:	eb 1e                	jmp    800df4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dd6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dd9:	80 fb 19             	cmp    $0x19,%bl
  800ddc:	77 08                	ja     800de6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dde:	0f be c9             	movsbl %cl,%ecx
  800de1:	83 e9 57             	sub    $0x57,%ecx
  800de4:	eb 0e                	jmp    800df4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800de6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800de9:	80 fb 19             	cmp    $0x19,%bl
  800dec:	77 12                	ja     800e00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800dee:	0f be c9             	movsbl %cl,%ecx
  800df1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800df4:	39 f1                	cmp    %esi,%ecx
  800df6:	7d 0c                	jge    800e04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800df8:	42                   	inc    %edx
  800df9:	0f af c6             	imul   %esi,%eax
  800dfc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dfe:	eb c4                	jmp    800dc4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e00:	89 c1                	mov    %eax,%ecx
  800e02:	eb 02                	jmp    800e06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e0a:	74 05                	je     800e11 <strtol+0xbd>
		*endptr = (char *) s;
  800e0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e11:	85 ff                	test   %edi,%edi
  800e13:	74 04                	je     800e19 <strtol+0xc5>
  800e15:	89 c8                	mov    %ecx,%eax
  800e17:	f7 d8                	neg    %eax
}
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
	...

00800e20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e31:	89 c3                	mov    %eax,%ebx
  800e33:	89 c7                	mov    %eax,%edi
  800e35:	89 c6                	mov    %eax,%esi
  800e37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e44:	ba 00 00 00 00       	mov    $0x0,%edx
  800e49:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4e:	89 d1                	mov    %edx,%ecx
  800e50:	89 d3                	mov    %edx,%ebx
  800e52:	89 d7                	mov    %edx,%edi
  800e54:	89 d6                	mov    %edx,%esi
  800e56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 cb                	mov    %ecx,%ebx
  800e75:	89 cf                	mov    %ecx,%edi
  800e77:	89 ce                	mov    %ecx,%esi
  800e79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	7e 28                	jle    800ea7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800e92:	00 
  800e93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9a:	00 
  800e9b:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800ea2:	e8 b1 f5 ff ff       	call   800458 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ea7:	83 c4 2c             	add    $0x2c,%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eba:	b8 02 00 00 00       	mov    $0x2,%eax
  800ebf:	89 d1                	mov    %edx,%ecx
  800ec1:	89 d3                	mov    %edx,%ebx
  800ec3:	89 d7                	mov    %edx,%edi
  800ec5:	89 d6                	mov    %edx,%esi
  800ec7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <sys_yield>:

void
sys_yield(void)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ede:	89 d1                	mov    %edx,%ecx
  800ee0:	89 d3                	mov    %edx,%ebx
  800ee2:	89 d7                	mov    %edx,%edi
  800ee4:	89 d6                	mov    %edx,%esi
  800ee6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	be 00 00 00 00       	mov    $0x0,%esi
  800efb:	b8 04 00 00 00       	mov    $0x4,%eax
  800f00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	89 f7                	mov    %esi,%edi
  800f0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	7e 28                	jle    800f39 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800f24:	00 
  800f25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2c:	00 
  800f2d:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800f34:	e8 1f f5 ff ff       	call   800458 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f39:	83 c4 2c             	add    $0x2c,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f60:	85 c0                	test   %eax,%eax
  800f62:	7e 28                	jle    800f8c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f6f:	00 
  800f70:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800f87:	e8 cc f4 ff ff       	call   800458 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f8c:	83 c4 2c             	add    $0x2c,%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa2:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faa:	8b 55 08             	mov    0x8(%ebp),%edx
  800fad:	89 df                	mov    %ebx,%edi
  800faf:	89 de                	mov    %ebx,%esi
  800fb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 28                	jle    800fdf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800fda:	e8 79 f4 ff ff       	call   800458 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fdf:	83 c4 2c             	add    $0x2c,%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff5:	b8 08 00 00 00       	mov    $0x8,%eax
  800ffa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffd:	8b 55 08             	mov    0x8(%ebp),%edx
  801000:	89 df                	mov    %ebx,%edi
  801002:	89 de                	mov    %ebx,%esi
  801004:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801006:	85 c0                	test   %eax,%eax
  801008:	7e 28                	jle    801032 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801015:	00 
  801016:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  80101d:	00 
  80101e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801025:	00 
  801026:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  80102d:	e8 26 f4 ff ff       	call   800458 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801032:	83 c4 2c             	add    $0x2c,%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801043:	bb 00 00 00 00       	mov    $0x0,%ebx
  801048:	b8 09 00 00 00       	mov    $0x9,%eax
  80104d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801050:	8b 55 08             	mov    0x8(%ebp),%edx
  801053:	89 df                	mov    %ebx,%edi
  801055:	89 de                	mov    %ebx,%esi
  801057:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	7e 28                	jle    801085 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  801080:	e8 d3 f3 ff ff       	call   800458 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801085:	83 c4 2c             	add    $0x2c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a6:	89 df                	mov    %ebx,%edi
  8010a8:	89 de                	mov    %ebx,%esi
  8010aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 28                	jle    8010d8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  8010d3:	e8 80 f3 ff ff       	call   800458 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d8:	83 c4 2c             	add    $0x2c,%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	be 00 00 00 00       	mov    $0x0,%esi
  8010eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010f0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	57                   	push   %edi
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801111:	b8 0d 00 00 00       	mov    $0xd,%eax
  801116:	8b 55 08             	mov    0x8(%ebp),%edx
  801119:	89 cb                	mov    %ecx,%ebx
  80111b:	89 cf                	mov    %ecx,%edi
  80111d:	89 ce                	mov    %ecx,%esi
  80111f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801121:	85 c0                	test   %eax,%eax
  801123:	7e 28                	jle    80114d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801125:	89 44 24 10          	mov    %eax,0x10(%esp)
  801129:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801130:	00 
  801131:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  801138:	00 
  801139:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801140:	00 
  801141:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  801148:	e8 0b f3 ff ff       	call   800458 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80114d:	83 c4 2c             	add    $0x2c,%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    
  801155:	00 00                	add    %al,(%eax)
	...

00801158 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	05 00 00 00 30       	add    $0x30000000,%eax
  801163:	c1 e8 0c             	shr    $0xc,%eax
}
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
  801171:	89 04 24             	mov    %eax,(%esp)
  801174:	e8 df ff ff ff       	call   801158 <fd2num>
  801179:	05 20 00 0d 00       	add    $0xd0020,%eax
  80117e:	c1 e0 0c             	shl    $0xc,%eax
}
  801181:	c9                   	leave  
  801182:	c3                   	ret    

00801183 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	53                   	push   %ebx
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80118a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80118f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801191:	89 c2                	mov    %eax,%edx
  801193:	c1 ea 16             	shr    $0x16,%edx
  801196:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119d:	f6 c2 01             	test   $0x1,%dl
  8011a0:	74 11                	je     8011b3 <fd_alloc+0x30>
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	c1 ea 0c             	shr    $0xc,%edx
  8011a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ae:	f6 c2 01             	test   $0x1,%dl
  8011b1:	75 09                	jne    8011bc <fd_alloc+0x39>
			*fd_store = fd;
  8011b3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ba:	eb 17                	jmp    8011d3 <fd_alloc+0x50>
  8011bc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c6:	75 c7                	jne    80118f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011ce:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d3:	5b                   	pop    %ebx
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011dc:	83 f8 1f             	cmp    $0x1f,%eax
  8011df:	77 36                	ja     801217 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e1:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011e6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 16             	shr    $0x16,%edx
  8011ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 24                	je     80121e <fd_lookup+0x48>
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 0c             	shr    $0xc,%edx
  8011ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 1a                	je     801225 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 02                	mov    %eax,(%edx)
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	eb 13                	jmp    80122a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121c:	eb 0c                	jmp    80122a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801223:	eb 05                	jmp    80122a <fd_lookup+0x54>
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	53                   	push   %ebx
  801230:	83 ec 14             	sub    $0x14,%esp
  801233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801239:	ba 00 00 00 00       	mov    $0x0,%edx
  80123e:	eb 0e                	jmp    80124e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801240:	39 08                	cmp    %ecx,(%eax)
  801242:	75 09                	jne    80124d <dev_lookup+0x21>
			*dev = devtab[i];
  801244:	89 03                	mov    %eax,(%ebx)
			return 0;
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	eb 35                	jmp    801282 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80124d:	42                   	inc    %edx
  80124e:	8b 04 95 48 2d 80 00 	mov    0x802d48(,%edx,4),%eax
  801255:	85 c0                	test   %eax,%eax
  801257:	75 e7                	jne    801240 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801259:	a1 90 67 80 00       	mov    0x806790,%eax
  80125e:	8b 00                	mov    (%eax),%eax
  801260:	8b 40 48             	mov    0x48(%eax),%eax
  801263:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126b:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  801272:	e8 d9 f2 ff ff       	call   800550 <cprintf>
	*dev = 0;
  801277:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80127d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801282:	83 c4 14             	add    $0x14,%esp
  801285:	5b                   	pop    %ebx
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 30             	sub    $0x30,%esp
  801290:	8b 75 08             	mov    0x8(%ebp),%esi
  801293:	8a 45 0c             	mov    0xc(%ebp),%al
  801296:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801299:	89 34 24             	mov    %esi,(%esp)
  80129c:	e8 b7 fe ff ff       	call   801158 <fd2num>
  8012a1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012a8:	89 04 24             	mov    %eax,(%esp)
  8012ab:	e8 26 ff ff ff       	call   8011d6 <fd_lookup>
  8012b0:	89 c3                	mov    %eax,%ebx
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 05                	js     8012bb <fd_close+0x33>
	    || fd != fd2)
  8012b6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b9:	74 0d                	je     8012c8 <fd_close+0x40>
		return (must_exist ? r : 0);
  8012bb:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012bf:	75 46                	jne    801307 <fd_close+0x7f>
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c6:	eb 3f                	jmp    801307 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	8b 06                	mov    (%esi),%eax
  8012d1:	89 04 24             	mov    %eax,(%esp)
  8012d4:	e8 53 ff ff ff       	call   80122c <dev_lookup>
  8012d9:	89 c3                	mov    %eax,%ebx
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 18                	js     8012f7 <fd_close+0x6f>
		if (dev->dev_close)
  8012df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e2:	8b 40 10             	mov    0x10(%eax),%eax
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	74 09                	je     8012f2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012e9:	89 34 24             	mov    %esi,(%esp)
  8012ec:	ff d0                	call   *%eax
  8012ee:	89 c3                	mov    %eax,%ebx
  8012f0:	eb 05                	jmp    8012f7 <fd_close+0x6f>
		else
			r = 0;
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801302:	e8 8d fc ff ff       	call   800f94 <sys_page_unmap>
	return r;
}
  801307:	89 d8                	mov    %ebx,%eax
  801309:	83 c4 30             	add    $0x30,%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801316:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131d:	8b 45 08             	mov    0x8(%ebp),%eax
  801320:	89 04 24             	mov    %eax,(%esp)
  801323:	e8 ae fe ff ff       	call   8011d6 <fd_lookup>
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 13                	js     80133f <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80132c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801333:	00 
  801334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 49 ff ff ff       	call   801288 <fd_close>
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <close_all>:

void
close_all(void)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	53                   	push   %ebx
  801345:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801348:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80134d:	89 1c 24             	mov    %ebx,(%esp)
  801350:	e8 bb ff ff ff       	call   801310 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801355:	43                   	inc    %ebx
  801356:	83 fb 20             	cmp    $0x20,%ebx
  801359:	75 f2                	jne    80134d <close_all+0xc>
		close(i);
}
  80135b:	83 c4 14             	add    $0x14,%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    

00801361 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	83 ec 4c             	sub    $0x4c,%esp
  80136a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80136d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801370:	89 44 24 04          	mov    %eax,0x4(%esp)
  801374:	8b 45 08             	mov    0x8(%ebp),%eax
  801377:	89 04 24             	mov    %eax,(%esp)
  80137a:	e8 57 fe ff ff       	call   8011d6 <fd_lookup>
  80137f:	89 c3                	mov    %eax,%ebx
  801381:	85 c0                	test   %eax,%eax
  801383:	0f 88 e1 00 00 00    	js     80146a <dup+0x109>
		return r;
	close(newfdnum);
  801389:	89 3c 24             	mov    %edi,(%esp)
  80138c:	e8 7f ff ff ff       	call   801310 <close>

	newfd = INDEX2FD(newfdnum);
  801391:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801397:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80139a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 c3 fd ff ff       	call   801168 <fd2data>
  8013a5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013a7:	89 34 24             	mov    %esi,(%esp)
  8013aa:	e8 b9 fd ff ff       	call   801168 <fd2data>
  8013af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b2:	89 d8                	mov    %ebx,%eax
  8013b4:	c1 e8 16             	shr    $0x16,%eax
  8013b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013be:	a8 01                	test   $0x1,%al
  8013c0:	74 46                	je     801408 <dup+0xa7>
  8013c2:	89 d8                	mov    %ebx,%eax
  8013c4:	c1 e8 0c             	shr    $0xc,%eax
  8013c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 35                	je     801408 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013da:	25 07 0e 00 00       	and    $0xe07,%eax
  8013df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013f1:	00 
  8013f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013fd:	e8 3f fb ff ff       	call   800f41 <sys_page_map>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	85 c0                	test   %eax,%eax
  801406:	78 3b                	js     801443 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801408:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80140b:	89 c2                	mov    %eax,%edx
  80140d:	c1 ea 0c             	shr    $0xc,%edx
  801410:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801417:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80141d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801421:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801425:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80142c:	00 
  80142d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801438:	e8 04 fb ff ff       	call   800f41 <sys_page_map>
  80143d:	89 c3                	mov    %eax,%ebx
  80143f:	85 c0                	test   %eax,%eax
  801441:	79 25                	jns    801468 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801443:	89 74 24 04          	mov    %esi,0x4(%esp)
  801447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144e:	e8 41 fb ff ff       	call   800f94 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801453:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801461:	e8 2e fb ff ff       	call   800f94 <sys_page_unmap>
	return r;
  801466:	eb 02                	jmp    80146a <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801468:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80146a:	89 d8                	mov    %ebx,%eax
  80146c:	83 c4 4c             	add    $0x4c,%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 24             	sub    $0x24,%esp
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801481:	89 44 24 04          	mov    %eax,0x4(%esp)
  801485:	89 1c 24             	mov    %ebx,(%esp)
  801488:	e8 49 fd ff ff       	call   8011d6 <fd_lookup>
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 6f                	js     801500 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	89 44 24 04          	mov    %eax,0x4(%esp)
  801498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149b:	8b 00                	mov    (%eax),%eax
  80149d:	89 04 24             	mov    %eax,(%esp)
  8014a0:	e8 87 fd ff ff       	call   80122c <dev_lookup>
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 57                	js     801500 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ac:	8b 50 08             	mov    0x8(%eax),%edx
  8014af:	83 e2 03             	and    $0x3,%edx
  8014b2:	83 fa 01             	cmp    $0x1,%edx
  8014b5:	75 25                	jne    8014dc <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b7:	a1 90 67 80 00       	mov    0x806790,%eax
  8014bc:	8b 00                	mov    (%eax),%eax
  8014be:	8b 40 48             	mov    0x48(%eax),%eax
  8014c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	c7 04 24 0d 2d 80 00 	movl   $0x802d0d,(%esp)
  8014d0:	e8 7b f0 ff ff       	call   800550 <cprintf>
		return -E_INVAL;
  8014d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014da:	eb 24                	jmp    801500 <read+0x8c>
	}
	if (!dev->dev_read)
  8014dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014df:	8b 52 08             	mov    0x8(%edx),%edx
  8014e2:	85 d2                	test   %edx,%edx
  8014e4:	74 15                	je     8014fb <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014f4:	89 04 24             	mov    %eax,(%esp)
  8014f7:	ff d2                	call   *%edx
  8014f9:	eb 05                	jmp    801500 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801500:	83 c4 24             	add    $0x24,%esp
  801503:	5b                   	pop    %ebx
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	57                   	push   %edi
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
  80150c:	83 ec 1c             	sub    $0x1c,%esp
  80150f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801512:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801515:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151a:	eb 23                	jmp    80153f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151c:	89 f0                	mov    %esi,%eax
  80151e:	29 d8                	sub    %ebx,%eax
  801520:	89 44 24 08          	mov    %eax,0x8(%esp)
  801524:	8b 45 0c             	mov    0xc(%ebp),%eax
  801527:	01 d8                	add    %ebx,%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	89 3c 24             	mov    %edi,(%esp)
  801530:	e8 3f ff ff ff       	call   801474 <read>
		if (m < 0)
  801535:	85 c0                	test   %eax,%eax
  801537:	78 10                	js     801549 <readn+0x43>
			return m;
		if (m == 0)
  801539:	85 c0                	test   %eax,%eax
  80153b:	74 0a                	je     801547 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153d:	01 c3                	add    %eax,%ebx
  80153f:	39 f3                	cmp    %esi,%ebx
  801541:	72 d9                	jb     80151c <readn+0x16>
  801543:	89 d8                	mov    %ebx,%eax
  801545:	eb 02                	jmp    801549 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801547:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801549:	83 c4 1c             	add    $0x1c,%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5f                   	pop    %edi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	53                   	push   %ebx
  801555:	83 ec 24             	sub    $0x24,%esp
  801558:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801562:	89 1c 24             	mov    %ebx,(%esp)
  801565:	e8 6c fc ff ff       	call   8011d6 <fd_lookup>
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 6a                	js     8015d8 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801571:	89 44 24 04          	mov    %eax,0x4(%esp)
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	8b 00                	mov    (%eax),%eax
  80157a:	89 04 24             	mov    %eax,(%esp)
  80157d:	e8 aa fc ff ff       	call   80122c <dev_lookup>
  801582:	85 c0                	test   %eax,%eax
  801584:	78 52                	js     8015d8 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801589:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158d:	75 25                	jne    8015b4 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158f:	a1 90 67 80 00       	mov    0x806790,%eax
  801594:	8b 00                	mov    (%eax),%eax
  801596:	8b 40 48             	mov    0x48(%eax),%eax
  801599:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80159d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a1:	c7 04 24 29 2d 80 00 	movl   $0x802d29,(%esp)
  8015a8:	e8 a3 ef ff ff       	call   800550 <cprintf>
		return -E_INVAL;
  8015ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b2:	eb 24                	jmp    8015d8 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ba:	85 d2                	test   %edx,%edx
  8015bc:	74 15                	je     8015d3 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015cc:	89 04 24             	mov    %eax,(%esp)
  8015cf:	ff d2                	call   *%edx
  8015d1:	eb 05                	jmp    8015d8 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015d8:	83 c4 24             	add    $0x24,%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <seek>:

int
seek(int fdnum, off_t offset)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ee:	89 04 24             	mov    %eax,(%esp)
  8015f1:	e8 e0 fb ff ff       	call   8011d6 <fd_lookup>
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 0e                	js     801608 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801600:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801603:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	83 ec 24             	sub    $0x24,%esp
  801611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161b:	89 1c 24             	mov    %ebx,(%esp)
  80161e:	e8 b3 fb ff ff       	call   8011d6 <fd_lookup>
  801623:	85 c0                	test   %eax,%eax
  801625:	78 63                	js     80168a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	8b 00                	mov    (%eax),%eax
  801633:	89 04 24             	mov    %eax,(%esp)
  801636:	e8 f1 fb ff ff       	call   80122c <dev_lookup>
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 4b                	js     80168a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801642:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801646:	75 25                	jne    80166d <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801648:	a1 90 67 80 00       	mov    0x806790,%eax
  80164d:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80164f:	8b 40 48             	mov    0x48(%eax),%eax
  801652:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165a:	c7 04 24 ec 2c 80 00 	movl   $0x802cec,(%esp)
  801661:	e8 ea ee ff ff       	call   800550 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166b:	eb 1d                	jmp    80168a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	8b 52 18             	mov    0x18(%edx),%edx
  801673:	85 d2                	test   %edx,%edx
  801675:	74 0e                	je     801685 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801677:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80167e:	89 04 24             	mov    %eax,(%esp)
  801681:	ff d2                	call   *%edx
  801683:	eb 05                	jmp    80168a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801685:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80168a:	83 c4 24             	add    $0x24,%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	53                   	push   %ebx
  801694:	83 ec 24             	sub    $0x24,%esp
  801697:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	e8 2a fb ff ff       	call   8011d6 <fd_lookup>
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 52                	js     801702 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ba:	8b 00                	mov    (%eax),%eax
  8016bc:	89 04 24             	mov    %eax,(%esp)
  8016bf:	e8 68 fb ff ff       	call   80122c <dev_lookup>
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 3a                	js     801702 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016cf:	74 2c                	je     8016fd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016db:	00 00 00 
	stat->st_isdir = 0;
  8016de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e5:	00 00 00 
	stat->st_dev = dev;
  8016e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016f5:	89 14 24             	mov    %edx,(%esp)
  8016f8:	ff 50 14             	call   *0x14(%eax)
  8016fb:	eb 05                	jmp    801702 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801702:	83 c4 24             	add    $0x24,%esp
  801705:	5b                   	pop    %ebx
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801710:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801717:	00 
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	89 04 24             	mov    %eax,(%esp)
  80171e:	e8 88 02 00 00       	call   8019ab <open>
  801723:	89 c3                	mov    %eax,%ebx
  801725:	85 c0                	test   %eax,%eax
  801727:	78 1b                	js     801744 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801730:	89 1c 24             	mov    %ebx,(%esp)
  801733:	e8 58 ff ff ff       	call   801690 <fstat>
  801738:	89 c6                	mov    %eax,%esi
	close(fd);
  80173a:	89 1c 24             	mov    %ebx,(%esp)
  80173d:	e8 ce fb ff ff       	call   801310 <close>
	return r;
  801742:	89 f3                	mov    %esi,%ebx
}
  801744:	89 d8                	mov    %ebx,%eax
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	5b                   	pop    %ebx
  80174a:	5e                   	pop    %esi
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    
  80174d:	00 00                	add    %al,(%eax)
	...

00801750 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	83 ec 10             	sub    $0x10,%esp
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80175c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801763:	75 11                	jne    801776 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801765:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80176c:	e8 d2 0d 00 00       	call   802543 <ipc_find_env>
  801771:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801776:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80177d:	00 
  80177e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801785:	00 
  801786:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80178a:	a1 00 50 80 00       	mov    0x805000,%eax
  80178f:	89 04 24             	mov    %eax,(%esp)
  801792:	e8 46 0d 00 00       	call   8024dd <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801797:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80179e:	00 
  80179f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017aa:	e8 c1 0c 00 00       	call   802470 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c2:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8017c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ca:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d9:	e8 72 ff ff ff       	call   801750 <fsipc>
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ec:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fb:	e8 50 ff ff ff       	call   801750 <fsipc>
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 14             	sub    $0x14,%esp
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	8b 40 0c             	mov    0xc(%eax),%eax
  801812:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	b8 05 00 00 00       	mov    $0x5,%eax
  801821:	e8 2a ff ff ff       	call   801750 <fsipc>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 2b                	js     801855 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182a:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801831:	00 
  801832:	89 1c 24             	mov    %ebx,(%esp)
  801835:	e8 c1 f2 ff ff       	call   800afb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183a:	a1 80 70 80 00       	mov    0x807080,%eax
  80183f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801845:	a1 84 70 80 00       	mov    0x807084,%eax
  80184a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801855:	83 c4 14             	add    $0x14,%esp
  801858:	5b                   	pop    %ebx
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	53                   	push   %ebx
  80185f:	83 ec 14             	sub    $0x14,%esp
  801862:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801865:	8b 45 08             	mov    0x8(%ebp),%eax
  801868:	8b 40 0c             	mov    0xc(%eax),%eax
  80186b:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801870:	89 d8                	mov    %ebx,%eax
  801872:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801878:	76 05                	jbe    80187f <devfile_write+0x24>
  80187a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80187f:	a3 04 70 80 00       	mov    %eax,0x807004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801884:	89 44 24 08          	mov    %eax,0x8(%esp)
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188f:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801896:	e8 43 f4 ff ff       	call   800cde <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a5:	e8 a6 fe ff ff       	call   801750 <fsipc>
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 53                	js     801901 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  8018ae:	39 c3                	cmp    %eax,%ebx
  8018b0:	73 24                	jae    8018d6 <devfile_write+0x7b>
  8018b2:	c7 44 24 0c 58 2d 80 	movl   $0x802d58,0xc(%esp)
  8018b9:	00 
  8018ba:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  8018c1:	00 
  8018c2:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8018c9:	00 
  8018ca:	c7 04 24 74 2d 80 00 	movl   $0x802d74,(%esp)
  8018d1:	e8 82 eb ff ff       	call   800458 <_panic>
	assert(r <= PGSIZE);
  8018d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018db:	7e 24                	jle    801901 <devfile_write+0xa6>
  8018dd:	c7 44 24 0c 7f 2d 80 	movl   $0x802d7f,0xc(%esp)
  8018e4:	00 
  8018e5:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  8018ec:	00 
  8018ed:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8018f4:	00 
  8018f5:	c7 04 24 74 2d 80 00 	movl   $0x802d74,(%esp)
  8018fc:	e8 57 eb ff ff       	call   800458 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801901:	83 c4 14             	add    $0x14,%esp
  801904:	5b                   	pop    %ebx
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	56                   	push   %esi
  80190b:	53                   	push   %ebx
  80190c:	83 ec 10             	sub    $0x10,%esp
  80190f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	8b 40 0c             	mov    0xc(%eax),%eax
  801918:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80191d:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801923:	ba 00 00 00 00       	mov    $0x0,%edx
  801928:	b8 03 00 00 00       	mov    $0x3,%eax
  80192d:	e8 1e fe ff ff       	call   801750 <fsipc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	85 c0                	test   %eax,%eax
  801936:	78 6a                	js     8019a2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801938:	39 c6                	cmp    %eax,%esi
  80193a:	73 24                	jae    801960 <devfile_read+0x59>
  80193c:	c7 44 24 0c 58 2d 80 	movl   $0x802d58,0xc(%esp)
  801943:	00 
  801944:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  80194b:	00 
  80194c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801953:	00 
  801954:	c7 04 24 74 2d 80 00 	movl   $0x802d74,(%esp)
  80195b:	e8 f8 ea ff ff       	call   800458 <_panic>
	assert(r <= PGSIZE);
  801960:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801965:	7e 24                	jle    80198b <devfile_read+0x84>
  801967:	c7 44 24 0c 7f 2d 80 	movl   $0x802d7f,0xc(%esp)
  80196e:	00 
  80196f:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  801976:	00 
  801977:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  80197e:	00 
  80197f:	c7 04 24 74 2d 80 00 	movl   $0x802d74,(%esp)
  801986:	e8 cd ea ff ff       	call   800458 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80198b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801996:	00 
  801997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199a:	89 04 24             	mov    %eax,(%esp)
  80199d:	e8 d2 f2 ff ff       	call   800c74 <memmove>
	return r;
}
  8019a2:	89 d8                	mov    %ebx,%eax
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	5b                   	pop    %ebx
  8019a8:	5e                   	pop    %esi
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	83 ec 20             	sub    $0x20,%esp
  8019b3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b6:	89 34 24             	mov    %esi,(%esp)
  8019b9:	e8 0a f1 ff ff       	call   800ac8 <strlen>
  8019be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c3:	7f 60                	jg     801a25 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	89 04 24             	mov    %eax,(%esp)
  8019cb:	e8 b3 f7 ff ff       	call   801183 <fd_alloc>
  8019d0:	89 c3                	mov    %eax,%ebx
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	78 54                	js     801a2a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019da:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8019e1:	e8 15 f1 ff ff       	call   800afb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f6:	e8 55 fd ff ff       	call   801750 <fsipc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	79 15                	jns    801a16 <open+0x6b>
		fd_close(fd, 0);
  801a01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a08:	00 
  801a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 74 f8 ff ff       	call   801288 <fd_close>
		return r;
  801a14:	eb 14                	jmp    801a2a <open+0x7f>
	}

	return fd2num(fd);
  801a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a19:	89 04 24             	mov    %eax,(%esp)
  801a1c:	e8 37 f7 ff ff       	call   801158 <fd2num>
  801a21:	89 c3                	mov    %eax,%ebx
  801a23:	eb 05                	jmp    801a2a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a25:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a2a:	89 d8                	mov    %ebx,%eax
  801a2c:	83 c4 20             	add    $0x20,%esp
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a43:	e8 08 fd ff ff       	call   801750 <fsipc>
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    
	...

00801a4c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	57                   	push   %edi
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a5f:	00 
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	89 04 24             	mov    %eax,(%esp)
  801a66:	e8 40 ff ff ff       	call   8019ab <open>
  801a6b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801a71:	85 c0                	test   %eax,%eax
  801a73:	0f 88 77 05 00 00    	js     801ff0 <spawn+0x5a4>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a79:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a80:	00 
  801a81:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 6d fa ff ff       	call   801506 <readn>
  801a99:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a9e:	75 0c                	jne    801aac <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801aa0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801aa7:	45 4c 46 
  801aaa:	74 3b                	je     801ae7 <spawn+0x9b>
		close(fd);
  801aac:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ab2:	89 04 24             	mov    %eax,(%esp)
  801ab5:	e8 56 f8 ff ff       	call   801310 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801aba:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ac1:	46 
  801ac2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acc:	c7 04 24 8b 2d 80 00 	movl   $0x802d8b,(%esp)
  801ad3:	e8 78 ea ff ff       	call   800550 <cprintf>
		return -E_NOT_EXEC;
  801ad8:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801adf:	ff ff ff 
  801ae2:	e9 15 05 00 00       	jmp    801ffc <spawn+0x5b0>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801ae7:	ba 07 00 00 00       	mov    $0x7,%edx
  801aec:	89 d0                	mov    %edx,%eax
  801aee:	cd 30                	int    $0x30
  801af0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801af6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801afc:	85 c0                	test   %eax,%eax
  801afe:	0f 88 f8 04 00 00    	js     801ffc <spawn+0x5b0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b04:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b10:	c1 e0 07             	shl    $0x7,%eax
  801b13:	29 d0                	sub    %edx,%eax
  801b15:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801b1b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b21:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b28:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b2e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b34:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801b39:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b3e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b41:	eb 0d                	jmp    801b50 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801b43:	89 04 24             	mov    %eax,(%esp)
  801b46:	e8 7d ef ff ff       	call   800ac8 <strlen>
  801b4b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b4f:	46                   	inc    %esi
  801b50:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b52:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b59:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	75 e3                	jne    801b43 <spawn+0xf7>
  801b60:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801b66:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b6c:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b71:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b73:	89 f8                	mov    %edi,%eax
  801b75:	83 e0 fc             	and    $0xfffffffc,%eax
  801b78:	f7 d2                	not    %edx
  801b7a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801b7d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b83:	89 d0                	mov    %edx,%eax
  801b85:	83 e8 08             	sub    $0x8,%eax
  801b88:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b8d:	0f 86 7a 04 00 00    	jbe    80200d <spawn+0x5c1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b93:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b9a:	00 
  801b9b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ba2:	00 
  801ba3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801baa:	e8 3e f3 ff ff       	call   800eed <sys_page_alloc>
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	0f 88 5b 04 00 00    	js     802012 <spawn+0x5c6>
  801bb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbc:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801bc2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc5:	eb 2e                	jmp    801bf5 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801bc7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801bcd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bd3:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801bd6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdd:	89 3c 24             	mov    %edi,(%esp)
  801be0:	e8 16 ef ff ff       	call   800afb <strcpy>
		string_store += strlen(argv[i]) + 1;
  801be5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801be8:	89 04 24             	mov    %eax,(%esp)
  801beb:	e8 d8 ee ff ff       	call   800ac8 <strlen>
  801bf0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bf4:	43                   	inc    %ebx
  801bf5:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801bfb:	7c ca                	jl     801bc7 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801bfd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c03:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c09:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c10:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c16:	74 24                	je     801c3c <spawn+0x1f0>
  801c18:	c7 44 24 0c 00 2e 80 	movl   $0x802e00,0xc(%esp)
  801c1f:	00 
  801c20:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  801c27:	00 
  801c28:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801c2f:	00 
  801c30:	c7 04 24 a5 2d 80 00 	movl   $0x802da5,(%esp)
  801c37:	e8 1c e8 ff ff       	call   800458 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c3c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c42:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c47:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c4d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801c50:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c56:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c60:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c66:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c6d:	00 
  801c6e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c75:	ee 
  801c76:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c80:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c87:	00 
  801c88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8f:	e8 ad f2 ff ff       	call   800f41 <sys_page_map>
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	85 c0                	test   %eax,%eax
  801c98:	78 1a                	js     801cb4 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c9a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ca1:	00 
  801ca2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca9:	e8 e6 f2 ff ff       	call   800f94 <sys_page_unmap>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	79 1f                	jns    801cd3 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801cb4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cbb:	00 
  801cbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc3:	e8 cc f2 ff ff       	call   800f94 <sys_page_unmap>
	return r;
  801cc8:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801cce:	e9 29 03 00 00       	jmp    801ffc <spawn+0x5b0>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cd3:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801cd9:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801cdf:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ce5:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801cec:	00 00 00 
  801cef:	e9 bb 01 00 00       	jmp    801eaf <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801cf4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cfa:	83 38 01             	cmpl   $0x1,(%eax)
  801cfd:	0f 85 9f 01 00 00    	jne    801ea2 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d03:	89 c2                	mov    %eax,%edx
  801d05:	8b 40 18             	mov    0x18(%eax),%eax
  801d08:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801d0b:	83 f8 01             	cmp    $0x1,%eax
  801d0e:	19 c0                	sbb    %eax,%eax
  801d10:	83 e0 fe             	and    $0xfffffffe,%eax
  801d13:	83 c0 07             	add    $0x7,%eax
  801d16:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d1c:	8b 52 04             	mov    0x4(%edx),%edx
  801d1f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801d25:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d2b:	8b 40 10             	mov    0x10(%eax),%eax
  801d2e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d34:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d3a:	8b 52 14             	mov    0x14(%edx),%edx
  801d3d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d43:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d49:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d4c:	89 f8                	mov    %edi,%eax
  801d4e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d53:	74 16                	je     801d6b <spawn+0x31f>
		va -= i;
  801d55:	29 c7                	sub    %eax,%edi
		memsz += i;
  801d57:	01 c2                	add    %eax,%edx
  801d59:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801d5f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801d65:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d70:	e9 1f 01 00 00       	jmp    801e94 <spawn+0x448>
		if (i >= filesz) {
  801d75:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  801d7b:	72 2b                	jb     801da8 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d7d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801d83:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d8b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d91:	89 04 24             	mov    %eax,(%esp)
  801d94:	e8 54 f1 ff ff       	call   800eed <sys_page_alloc>
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	0f 89 e7 00 00 00    	jns    801e88 <spawn+0x43c>
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	e9 24 02 00 00       	jmp    801fcc <spawn+0x580>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801daf:	00 
  801db0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801db7:	00 
  801db8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbf:	e8 29 f1 ff ff       	call   800eed <sys_page_alloc>
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	0f 88 f6 01 00 00    	js     801fc2 <spawn+0x576>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801dcc:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801dd2:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dde:	89 04 24             	mov    %eax,(%esp)
  801de1:	e8 f8 f7 ff ff       	call   8015de <seek>
  801de6:	85 c0                	test   %eax,%eax
  801de8:	0f 88 d8 01 00 00    	js     801fc6 <spawn+0x57a>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801dee:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801df4:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801df6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801dfb:	76 05                	jbe    801e02 <spawn+0x3b6>
  801dfd:	b8 00 10 00 00       	mov    $0x1000,%eax
  801e02:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e06:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e0d:	00 
  801e0e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e14:	89 04 24             	mov    %eax,(%esp)
  801e17:	e8 ea f6 ff ff       	call   801506 <readn>
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	0f 88 a6 01 00 00    	js     801fca <spawn+0x57e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e24:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801e2a:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e2e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e32:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e43:	00 
  801e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4b:	e8 f1 f0 ff ff       	call   800f41 <sys_page_map>
  801e50:	85 c0                	test   %eax,%eax
  801e52:	79 20                	jns    801e74 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801e54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e58:	c7 44 24 08 b1 2d 80 	movl   $0x802db1,0x8(%esp)
  801e5f:	00 
  801e60:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801e67:	00 
  801e68:	c7 04 24 a5 2d 80 00 	movl   $0x802da5,(%esp)
  801e6f:	e8 e4 e5 ff ff       	call   800458 <_panic>
			sys_page_unmap(0, UTEMP);
  801e74:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e7b:	00 
  801e7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e83:	e8 0c f1 ff ff       	call   800f94 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e8e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801e94:	89 de                	mov    %ebx,%esi
  801e96:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801e9c:	0f 82 d3 fe ff ff    	jb     801d75 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ea2:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801ea8:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801eaf:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801eb6:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801ebc:	0f 8c 32 fe ff ff    	jl     801cf4 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ec2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 40 f4 ff ff       	call   801310 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  801ed0:	be 00 00 00 00       	mov    $0x0,%esi
  801ed5:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(va)] & PTE_P)&&(uvpt[PGNUM(va)] & PTE_P)&&(uvpt[PGNUM(va)]&PTE_U)&&(uvpt[PGNUM(va)]&PTE_SHARE)){
  801edb:	89 f0                	mov    %esi,%eax
  801edd:	c1 e8 16             	shr    $0x16,%eax
  801ee0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ee7:	a8 01                	test   $0x1,%al
  801ee9:	74 49                	je     801f34 <spawn+0x4e8>
  801eeb:	89 f0                	mov    %esi,%eax
  801eed:	c1 e8 0c             	shr    $0xc,%eax
  801ef0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ef7:	f6 c2 01             	test   $0x1,%dl
  801efa:	74 38                	je     801f34 <spawn+0x4e8>
  801efc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801f03:	f6 c2 04             	test   $0x4,%dl
  801f06:	74 2c                	je     801f34 <spawn+0x4e8>
  801f08:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f0f:	f6 c4 04             	test   $0x4,%ah
  801f12:	74 20                	je     801f34 <spawn+0x4e8>
			if ((r = sys_page_map(0,(void*)va,child,(void*)va,PTE_SYSCALL))<0);
  801f14:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  801f1b:	00 
  801f1c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f2f:	e8 0d f0 ff ff       	call   800f41 <sys_page_map>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  801f34:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f3a:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  801f40:	75 99                	jne    801edb <spawn+0x48f>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801f42:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801f49:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f4c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f56:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f5c:	89 04 24             	mov    %eax,(%esp)
  801f5f:	e8 d6 f0 ff ff       	call   80103a <sys_env_set_trapframe>
  801f64:	85 c0                	test   %eax,%eax
  801f66:	79 20                	jns    801f88 <spawn+0x53c>
		panic("sys_env_set_trapframe: %e", r);
  801f68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6c:	c7 44 24 08 ce 2d 80 	movl   $0x802dce,0x8(%esp)
  801f73:	00 
  801f74:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801f7b:	00 
  801f7c:	c7 04 24 a5 2d 80 00 	movl   $0x802da5,(%esp)
  801f83:	e8 d0 e4 ff ff       	call   800458 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f88:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801f8f:	00 
  801f90:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f96:	89 04 24             	mov    %eax,(%esp)
  801f99:	e8 49 f0 ff ff       	call   800fe7 <sys_env_set_status>
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	79 5a                	jns    801ffc <spawn+0x5b0>
		panic("sys_env_set_status: %e", r);
  801fa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa6:	c7 44 24 08 e8 2d 80 	movl   $0x802de8,0x8(%esp)
  801fad:	00 
  801fae:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801fb5:	00 
  801fb6:	c7 04 24 a5 2d 80 00 	movl   $0x802da5,(%esp)
  801fbd:	e8 96 e4 ff ff       	call   800458 <_panic>
  801fc2:	89 c6                	mov    %eax,%esi
  801fc4:	eb 06                	jmp    801fcc <spawn+0x580>
  801fc6:	89 c6                	mov    %eax,%esi
  801fc8:	eb 02                	jmp    801fcc <spawn+0x580>
  801fca:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801fcc:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fd2:	89 04 24             	mov    %eax,(%esp)
  801fd5:	e8 83 ee ff ff       	call   800e5d <sys_env_destroy>
	close(fd);
  801fda:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801fe0:	89 04 24             	mov    %eax,(%esp)
  801fe3:	e8 28 f3 ff ff       	call   801310 <close>
	return r;
  801fe8:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801fee:	eb 0c                	jmp    801ffc <spawn+0x5b0>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ff0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ff6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ffc:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802002:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80200d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802012:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802018:	eb e2                	jmp    801ffc <spawn+0x5b0>

0080201a <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	57                   	push   %edi
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802023:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802026:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80202b:	eb 03                	jmp    802030 <spawnl+0x16>
		argc++;
  80202d:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80202e:	89 d0                	mov    %edx,%eax
  802030:	8d 50 04             	lea    0x4(%eax),%edx
  802033:	83 38 00             	cmpl   $0x0,(%eax)
  802036:	75 f5                	jne    80202d <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802038:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  80203f:	83 e0 f0             	and    $0xfffffff0,%eax
  802042:	29 c4                	sub    %eax,%esp
  802044:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802048:	83 e7 f0             	and    $0xfffffff0,%edi
  80204b:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  80204d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802050:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802052:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802059:	00 

	va_start(vl, arg0);
  80205a:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80205d:	b8 00 00 00 00       	mov    $0x0,%eax
  802062:	eb 09                	jmp    80206d <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802064:	40                   	inc    %eax
  802065:	8b 1a                	mov    (%edx),%ebx
  802067:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  80206a:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80206d:	39 c8                	cmp    %ecx,%eax
  80206f:	75 f3                	jne    802064 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802071:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802075:	8b 45 08             	mov    0x8(%ebp),%eax
  802078:	89 04 24             	mov    %eax,(%esp)
  80207b:	e8 cc f9 ff ff       	call   801a4c <spawn>
}
  802080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	56                   	push   %esi
  80208c:	53                   	push   %ebx
  80208d:	83 ec 10             	sub    $0x10,%esp
  802090:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802093:	8b 45 08             	mov    0x8(%ebp),%eax
  802096:	89 04 24             	mov    %eax,(%esp)
  802099:	e8 ca f0 ff ff       	call   801168 <fd2data>
  80209e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8020a0:	c7 44 24 04 28 2e 80 	movl   $0x802e28,0x4(%esp)
  8020a7:	00 
  8020a8:	89 34 24             	mov    %esi,(%esp)
  8020ab:	e8 4b ea ff ff       	call   800afb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020b0:	8b 43 04             	mov    0x4(%ebx),%eax
  8020b3:	2b 03                	sub    (%ebx),%eax
  8020b5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8020bb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8020c2:	00 00 00 
	stat->st_dev = &devpipe;
  8020c5:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  8020cc:	47 80 00 
	return 0;
}
  8020cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	53                   	push   %ebx
  8020df:	83 ec 14             	sub    $0x14,%esp
  8020e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f0:	e8 9f ee ff ff       	call   800f94 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020f5:	89 1c 24             	mov    %ebx,(%esp)
  8020f8:	e8 6b f0 ff ff       	call   801168 <fd2data>
  8020fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802108:	e8 87 ee ff ff       	call   800f94 <sys_page_unmap>
}
  80210d:	83 c4 14             	add    $0x14,%esp
  802110:	5b                   	pop    %ebx
  802111:	5d                   	pop    %ebp
  802112:	c3                   	ret    

00802113 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	57                   	push   %edi
  802117:	56                   	push   %esi
  802118:	53                   	push   %ebx
  802119:	83 ec 2c             	sub    $0x2c,%esp
  80211c:	89 c7                	mov    %eax,%edi
  80211e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802121:	a1 90 67 80 00       	mov    0x806790,%eax
  802126:	8b 00                	mov    (%eax),%eax
  802128:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80212b:	89 3c 24             	mov    %edi,(%esp)
  80212e:	e8 55 04 00 00       	call   802588 <pageref>
  802133:	89 c6                	mov    %eax,%esi
  802135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802138:	89 04 24             	mov    %eax,(%esp)
  80213b:	e8 48 04 00 00       	call   802588 <pageref>
  802140:	39 c6                	cmp    %eax,%esi
  802142:	0f 94 c0             	sete   %al
  802145:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802148:	8b 15 90 67 80 00    	mov    0x806790,%edx
  80214e:	8b 12                	mov    (%edx),%edx
  802150:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802153:	39 cb                	cmp    %ecx,%ebx
  802155:	75 08                	jne    80215f <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802157:	83 c4 2c             	add    $0x2c,%esp
  80215a:	5b                   	pop    %ebx
  80215b:	5e                   	pop    %esi
  80215c:	5f                   	pop    %edi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80215f:	83 f8 01             	cmp    $0x1,%eax
  802162:	75 bd                	jne    802121 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802164:	8b 42 58             	mov    0x58(%edx),%eax
  802167:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80216e:	00 
  80216f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802173:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802177:	c7 04 24 2f 2e 80 00 	movl   $0x802e2f,(%esp)
  80217e:	e8 cd e3 ff ff       	call   800550 <cprintf>
  802183:	eb 9c                	jmp    802121 <_pipeisclosed+0xe>

00802185 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	57                   	push   %edi
  802189:	56                   	push   %esi
  80218a:	53                   	push   %ebx
  80218b:	83 ec 1c             	sub    $0x1c,%esp
  80218e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802191:	89 34 24             	mov    %esi,(%esp)
  802194:	e8 cf ef ff ff       	call   801168 <fd2data>
  802199:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80219b:	bf 00 00 00 00       	mov    $0x0,%edi
  8021a0:	eb 3c                	jmp    8021de <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021a2:	89 da                	mov    %ebx,%edx
  8021a4:	89 f0                	mov    %esi,%eax
  8021a6:	e8 68 ff ff ff       	call   802113 <_pipeisclosed>
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	75 38                	jne    8021e7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021af:	e8 1a ed ff ff       	call   800ece <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021b4:	8b 43 04             	mov    0x4(%ebx),%eax
  8021b7:	8b 13                	mov    (%ebx),%edx
  8021b9:	83 c2 20             	add    $0x20,%edx
  8021bc:	39 d0                	cmp    %edx,%eax
  8021be:	73 e2                	jae    8021a2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021c3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8021c6:	89 c2                	mov    %eax,%edx
  8021c8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8021ce:	79 05                	jns    8021d5 <devpipe_write+0x50>
  8021d0:	4a                   	dec    %edx
  8021d1:	83 ca e0             	or     $0xffffffe0,%edx
  8021d4:	42                   	inc    %edx
  8021d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021d9:	40                   	inc    %eax
  8021da:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021dd:	47                   	inc    %edi
  8021de:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021e1:	75 d1                	jne    8021b4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021e3:	89 f8                	mov    %edi,%eax
  8021e5:	eb 05                	jmp    8021ec <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021e7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    

008021f4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	57                   	push   %edi
  8021f8:	56                   	push   %esi
  8021f9:	53                   	push   %ebx
  8021fa:	83 ec 1c             	sub    $0x1c,%esp
  8021fd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802200:	89 3c 24             	mov    %edi,(%esp)
  802203:	e8 60 ef ff ff       	call   801168 <fd2data>
  802208:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80220a:	be 00 00 00 00       	mov    $0x0,%esi
  80220f:	eb 3a                	jmp    80224b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802211:	85 f6                	test   %esi,%esi
  802213:	74 04                	je     802219 <devpipe_read+0x25>
				return i;
  802215:	89 f0                	mov    %esi,%eax
  802217:	eb 40                	jmp    802259 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802219:	89 da                	mov    %ebx,%edx
  80221b:	89 f8                	mov    %edi,%eax
  80221d:	e8 f1 fe ff ff       	call   802113 <_pipeisclosed>
  802222:	85 c0                	test   %eax,%eax
  802224:	75 2e                	jne    802254 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802226:	e8 a3 ec ff ff       	call   800ece <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80222b:	8b 03                	mov    (%ebx),%eax
  80222d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802230:	74 df                	je     802211 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802232:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802237:	79 05                	jns    80223e <devpipe_read+0x4a>
  802239:	48                   	dec    %eax
  80223a:	83 c8 e0             	or     $0xffffffe0,%eax
  80223d:	40                   	inc    %eax
  80223e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802242:	8b 55 0c             	mov    0xc(%ebp),%edx
  802245:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802248:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80224a:	46                   	inc    %esi
  80224b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80224e:	75 db                	jne    80222b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802250:	89 f0                	mov    %esi,%eax
  802252:	eb 05                	jmp    802259 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802254:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802259:	83 c4 1c             	add    $0x1c,%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5f                   	pop    %edi
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    

00802261 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	57                   	push   %edi
  802265:	56                   	push   %esi
  802266:	53                   	push   %ebx
  802267:	83 ec 3c             	sub    $0x3c,%esp
  80226a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80226d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802270:	89 04 24             	mov    %eax,(%esp)
  802273:	e8 0b ef ff ff       	call   801183 <fd_alloc>
  802278:	89 c3                	mov    %eax,%ebx
  80227a:	85 c0                	test   %eax,%eax
  80227c:	0f 88 45 01 00 00    	js     8023c7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802282:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802289:	00 
  80228a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80228d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802298:	e8 50 ec ff ff       	call   800eed <sys_page_alloc>
  80229d:	89 c3                	mov    %eax,%ebx
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	0f 88 20 01 00 00    	js     8023c7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8022aa:	89 04 24             	mov    %eax,(%esp)
  8022ad:	e8 d1 ee ff ff       	call   801183 <fd_alloc>
  8022b2:	89 c3                	mov    %eax,%ebx
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	0f 88 f8 00 00 00    	js     8023b4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022bc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022c3:	00 
  8022c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d2:	e8 16 ec ff ff       	call   800eed <sys_page_alloc>
  8022d7:	89 c3                	mov    %eax,%ebx
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	0f 88 d3 00 00 00    	js     8023b4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e4:	89 04 24             	mov    %eax,(%esp)
  8022e7:	e8 7c ee ff ff       	call   801168 <fd2data>
  8022ec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022f5:	00 
  8022f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802301:	e8 e7 eb ff ff       	call   800eed <sys_page_alloc>
  802306:	89 c3                	mov    %eax,%ebx
  802308:	85 c0                	test   %eax,%eax
  80230a:	0f 88 91 00 00 00    	js     8023a1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802310:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802313:	89 04 24             	mov    %eax,(%esp)
  802316:	e8 4d ee ff ff       	call   801168 <fd2data>
  80231b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802322:	00 
  802323:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802327:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80232e:	00 
  80232f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802333:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80233a:	e8 02 ec ff ff       	call   800f41 <sys_page_map>
  80233f:	89 c3                	mov    %eax,%ebx
  802341:	85 c0                	test   %eax,%eax
  802343:	78 4c                	js     802391 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802345:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80234b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80234e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802350:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802353:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80235a:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802363:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802365:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802368:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80236f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802372:	89 04 24             	mov    %eax,(%esp)
  802375:	e8 de ed ff ff       	call   801158 <fd2num>
  80237a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80237c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80237f:	89 04 24             	mov    %eax,(%esp)
  802382:	e8 d1 ed ff ff       	call   801158 <fd2num>
  802387:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80238a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80238f:	eb 36                	jmp    8023c7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802391:	89 74 24 04          	mov    %esi,0x4(%esp)
  802395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80239c:	e8 f3 eb ff ff       	call   800f94 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8023a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023af:	e8 e0 eb ff ff       	call   800f94 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8023b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c2:	e8 cd eb ff ff       	call   800f94 <sys_page_unmap>
    err:
	return r;
}
  8023c7:	89 d8                	mov    %ebx,%eax
  8023c9:	83 c4 3c             	add    $0x3c,%esp
  8023cc:	5b                   	pop    %ebx
  8023cd:	5e                   	pop    %esi
  8023ce:	5f                   	pop    %edi
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    

008023d1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023de:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e1:	89 04 24             	mov    %eax,(%esp)
  8023e4:	e8 ed ed ff ff       	call   8011d6 <fd_lookup>
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	78 15                	js     802402 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f0:	89 04 24             	mov    %eax,(%esp)
  8023f3:	e8 70 ed ff ff       	call   801168 <fd2data>
	return _pipeisclosed(fd, p);
  8023f8:	89 c2                	mov    %eax,%edx
  8023fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fd:	e8 11 fd ff ff       	call   802113 <_pipeisclosed>
}
  802402:	c9                   	leave  
  802403:	c3                   	ret    

00802404 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	56                   	push   %esi
  802408:	53                   	push   %ebx
  802409:	83 ec 10             	sub    $0x10,%esp
  80240c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80240f:	85 f6                	test   %esi,%esi
  802411:	75 24                	jne    802437 <wait+0x33>
  802413:	c7 44 24 0c 47 2e 80 	movl   $0x802e47,0xc(%esp)
  80241a:	00 
  80241b:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  802422:	00 
  802423:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80242a:	00 
  80242b:	c7 04 24 52 2e 80 00 	movl   $0x802e52,(%esp)
  802432:	e8 21 e0 ff ff       	call   800458 <_panic>
	e = &envs[ENVX(envid)];
  802437:	89 f3                	mov    %esi,%ebx
  802439:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80243f:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  802446:	c1 e3 07             	shl    $0x7,%ebx
  802449:	29 c3                	sub    %eax,%ebx
  80244b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802451:	eb 05                	jmp    802458 <wait+0x54>
		sys_yield();
  802453:	e8 76 ea ff ff       	call   800ece <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802458:	8b 43 48             	mov    0x48(%ebx),%eax
  80245b:	39 f0                	cmp    %esi,%eax
  80245d:	75 07                	jne    802466 <wait+0x62>
  80245f:	8b 43 54             	mov    0x54(%ebx),%eax
  802462:	85 c0                	test   %eax,%eax
  802464:	75 ed                	jne    802453 <wait+0x4f>
		sys_yield();
}
  802466:	83 c4 10             	add    $0x10,%esp
  802469:	5b                   	pop    %ebx
  80246a:	5e                   	pop    %esi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	00 00                	add    %al,(%eax)
	...

00802470 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	56                   	push   %esi
  802474:	53                   	push   %ebx
  802475:	83 ec 10             	sub    $0x10,%esp
  802478:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80247b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80247e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802481:	85 c0                	test   %eax,%eax
  802483:	75 05                	jne    80248a <ipc_recv+0x1a>
  802485:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  80248a:	89 04 24             	mov    %eax,(%esp)
  80248d:	e8 71 ec ff ff       	call   801103 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  802492:	85 c0                	test   %eax,%eax
  802494:	79 16                	jns    8024ac <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802496:	85 db                	test   %ebx,%ebx
  802498:	74 06                	je     8024a0 <ipc_recv+0x30>
  80249a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8024a0:	85 f6                	test   %esi,%esi
  8024a2:	74 32                	je     8024d6 <ipc_recv+0x66>
  8024a4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8024aa:	eb 2a                	jmp    8024d6 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8024ac:	85 db                	test   %ebx,%ebx
  8024ae:	74 0c                	je     8024bc <ipc_recv+0x4c>
  8024b0:	a1 90 67 80 00       	mov    0x806790,%eax
  8024b5:	8b 00                	mov    (%eax),%eax
  8024b7:	8b 40 74             	mov    0x74(%eax),%eax
  8024ba:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8024bc:	85 f6                	test   %esi,%esi
  8024be:	74 0c                	je     8024cc <ipc_recv+0x5c>
  8024c0:	a1 90 67 80 00       	mov    0x806790,%eax
  8024c5:	8b 00                	mov    (%eax),%eax
  8024c7:	8b 40 78             	mov    0x78(%eax),%eax
  8024ca:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8024cc:	a1 90 67 80 00       	mov    0x806790,%eax
  8024d1:	8b 00                	mov    (%eax),%eax
  8024d3:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8024d6:	83 c4 10             	add    $0x10,%esp
  8024d9:	5b                   	pop    %ebx
  8024da:	5e                   	pop    %esi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    

008024dd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024dd:	55                   	push   %ebp
  8024de:	89 e5                	mov    %esp,%ebp
  8024e0:	57                   	push   %edi
  8024e1:	56                   	push   %esi
  8024e2:	53                   	push   %ebx
  8024e3:	83 ec 1c             	sub    $0x1c,%esp
  8024e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024ec:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8024ef:	85 db                	test   %ebx,%ebx
  8024f1:	75 05                	jne    8024f8 <ipc_send+0x1b>
  8024f3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8024f8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8024fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802500:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802504:	8b 45 08             	mov    0x8(%ebp),%eax
  802507:	89 04 24             	mov    %eax,(%esp)
  80250a:	e8 d1 eb ff ff       	call   8010e0 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80250f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802512:	75 07                	jne    80251b <ipc_send+0x3e>
  802514:	e8 b5 e9 ff ff       	call   800ece <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  802519:	eb dd                	jmp    8024f8 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  80251b:	85 c0                	test   %eax,%eax
  80251d:	79 1c                	jns    80253b <ipc_send+0x5e>
  80251f:	c7 44 24 08 5d 2e 80 	movl   $0x802e5d,0x8(%esp)
  802526:	00 
  802527:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80252e:	00 
  80252f:	c7 04 24 6f 2e 80 00 	movl   $0x802e6f,(%esp)
  802536:	e8 1d df ff ff       	call   800458 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  80253b:	83 c4 1c             	add    $0x1c,%esp
  80253e:	5b                   	pop    %ebx
  80253f:	5e                   	pop    %esi
  802540:	5f                   	pop    %edi
  802541:	5d                   	pop    %ebp
  802542:	c3                   	ret    

00802543 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802543:	55                   	push   %ebp
  802544:	89 e5                	mov    %esp,%ebp
  802546:	53                   	push   %ebx
  802547:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80254a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80254f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802556:	89 c2                	mov    %eax,%edx
  802558:	c1 e2 07             	shl    $0x7,%edx
  80255b:	29 ca                	sub    %ecx,%edx
  80255d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802563:	8b 52 50             	mov    0x50(%edx),%edx
  802566:	39 da                	cmp    %ebx,%edx
  802568:	75 0f                	jne    802579 <ipc_find_env+0x36>
			return envs[i].env_id;
  80256a:	c1 e0 07             	shl    $0x7,%eax
  80256d:	29 c8                	sub    %ecx,%eax
  80256f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802574:	8b 40 40             	mov    0x40(%eax),%eax
  802577:	eb 0c                	jmp    802585 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802579:	40                   	inc    %eax
  80257a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80257f:	75 ce                	jne    80254f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802581:	66 b8 00 00          	mov    $0x0,%ax
}
  802585:	5b                   	pop    %ebx
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    

00802588 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80258e:	89 c2                	mov    %eax,%edx
  802590:	c1 ea 16             	shr    $0x16,%edx
  802593:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80259a:	f6 c2 01             	test   $0x1,%dl
  80259d:	74 1e                	je     8025bd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80259f:	c1 e8 0c             	shr    $0xc,%eax
  8025a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025a9:	a8 01                	test   $0x1,%al
  8025ab:	74 17                	je     8025c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025ad:	c1 e8 0c             	shr    $0xc,%eax
  8025b0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8025b7:	ef 
  8025b8:	0f b7 c0             	movzwl %ax,%eax
  8025bb:	eb 0c                	jmp    8025c9 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8025bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8025c2:	eb 05                	jmp    8025c9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8025c4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    
	...

008025cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8025cc:	55                   	push   %ebp
  8025cd:	57                   	push   %edi
  8025ce:	56                   	push   %esi
  8025cf:	83 ec 10             	sub    $0x10,%esp
  8025d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8025d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8025e2:	89 cd                	mov    %ecx,%ebp
  8025e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025e8:	85 c0                	test   %eax,%eax
  8025ea:	75 2c                	jne    802618 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8025ec:	39 f9                	cmp    %edi,%ecx
  8025ee:	77 68                	ja     802658 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025f0:	85 c9                	test   %ecx,%ecx
  8025f2:	75 0b                	jne    8025ff <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8025f9:	31 d2                	xor    %edx,%edx
  8025fb:	f7 f1                	div    %ecx
  8025fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025ff:	31 d2                	xor    %edx,%edx
  802601:	89 f8                	mov    %edi,%eax
  802603:	f7 f1                	div    %ecx
  802605:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802607:	89 f0                	mov    %esi,%eax
  802609:	f7 f1                	div    %ecx
  80260b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80260d:	89 f0                	mov    %esi,%eax
  80260f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802611:	83 c4 10             	add    $0x10,%esp
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802618:	39 f8                	cmp    %edi,%eax
  80261a:	77 2c                	ja     802648 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80261c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80261f:	83 f6 1f             	xor    $0x1f,%esi
  802622:	75 4c                	jne    802670 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802624:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802626:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80262b:	72 0a                	jb     802637 <__udivdi3+0x6b>
  80262d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802631:	0f 87 ad 00 00 00    	ja     8026e4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802637:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80263c:	89 f0                	mov    %esi,%eax
  80263e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802640:	83 c4 10             	add    $0x10,%esp
  802643:	5e                   	pop    %esi
  802644:	5f                   	pop    %edi
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    
  802647:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802648:	31 ff                	xor    %edi,%edi
  80264a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80264c:	89 f0                	mov    %esi,%eax
  80264e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802650:	83 c4 10             	add    $0x10,%esp
  802653:	5e                   	pop    %esi
  802654:	5f                   	pop    %edi
  802655:	5d                   	pop    %ebp
  802656:	c3                   	ret    
  802657:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802658:	89 fa                	mov    %edi,%edx
  80265a:	89 f0                	mov    %esi,%eax
  80265c:	f7 f1                	div    %ecx
  80265e:	89 c6                	mov    %eax,%esi
  802660:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802662:	89 f0                	mov    %esi,%eax
  802664:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802666:	83 c4 10             	add    $0x10,%esp
  802669:	5e                   	pop    %esi
  80266a:	5f                   	pop    %edi
  80266b:	5d                   	pop    %ebp
  80266c:	c3                   	ret    
  80266d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802670:	89 f1                	mov    %esi,%ecx
  802672:	d3 e0                	shl    %cl,%eax
  802674:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802678:	b8 20 00 00 00       	mov    $0x20,%eax
  80267d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80267f:	89 ea                	mov    %ebp,%edx
  802681:	88 c1                	mov    %al,%cl
  802683:	d3 ea                	shr    %cl,%edx
  802685:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802689:	09 ca                	or     %ecx,%edx
  80268b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80268f:	89 f1                	mov    %esi,%ecx
  802691:	d3 e5                	shl    %cl,%ebp
  802693:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802697:	89 fd                	mov    %edi,%ebp
  802699:	88 c1                	mov    %al,%cl
  80269b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80269d:	89 fa                	mov    %edi,%edx
  80269f:	89 f1                	mov    %esi,%ecx
  8026a1:	d3 e2                	shl    %cl,%edx
  8026a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8026a7:	88 c1                	mov    %al,%cl
  8026a9:	d3 ef                	shr    %cl,%edi
  8026ab:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8026ad:	89 f8                	mov    %edi,%eax
  8026af:	89 ea                	mov    %ebp,%edx
  8026b1:	f7 74 24 08          	divl   0x8(%esp)
  8026b5:	89 d1                	mov    %edx,%ecx
  8026b7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8026b9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026bd:	39 d1                	cmp    %edx,%ecx
  8026bf:	72 17                	jb     8026d8 <__udivdi3+0x10c>
  8026c1:	74 09                	je     8026cc <__udivdi3+0x100>
  8026c3:	89 fe                	mov    %edi,%esi
  8026c5:	31 ff                	xor    %edi,%edi
  8026c7:	e9 41 ff ff ff       	jmp    80260d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8026cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026d0:	89 f1                	mov    %esi,%ecx
  8026d2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026d4:	39 c2                	cmp    %eax,%edx
  8026d6:	73 eb                	jae    8026c3 <__udivdi3+0xf7>
		{
		  q0--;
  8026d8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026db:	31 ff                	xor    %edi,%edi
  8026dd:	e9 2b ff ff ff       	jmp    80260d <__udivdi3+0x41>
  8026e2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026e4:	31 f6                	xor    %esi,%esi
  8026e6:	e9 22 ff ff ff       	jmp    80260d <__udivdi3+0x41>
	...

008026ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8026ec:	55                   	push   %ebp
  8026ed:	57                   	push   %edi
  8026ee:	56                   	push   %esi
  8026ef:	83 ec 20             	sub    $0x20,%esp
  8026f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8026f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8026fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802702:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802706:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80270a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80270c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80270e:	85 ed                	test   %ebp,%ebp
  802710:	75 16                	jne    802728 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802712:	39 f1                	cmp    %esi,%ecx
  802714:	0f 86 a6 00 00 00    	jbe    8027c0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80271a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80271c:	89 d0                	mov    %edx,%eax
  80271e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802720:	83 c4 20             	add    $0x20,%esp
  802723:	5e                   	pop    %esi
  802724:	5f                   	pop    %edi
  802725:	5d                   	pop    %ebp
  802726:	c3                   	ret    
  802727:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802728:	39 f5                	cmp    %esi,%ebp
  80272a:	0f 87 ac 00 00 00    	ja     8027dc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802730:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802733:	83 f0 1f             	xor    $0x1f,%eax
  802736:	89 44 24 10          	mov    %eax,0x10(%esp)
  80273a:	0f 84 a8 00 00 00    	je     8027e8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802740:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802744:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802746:	bf 20 00 00 00       	mov    $0x20,%edi
  80274b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80274f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802753:	89 f9                	mov    %edi,%ecx
  802755:	d3 e8                	shr    %cl,%eax
  802757:	09 e8                	or     %ebp,%eax
  802759:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80275d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802761:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802765:	d3 e0                	shl    %cl,%eax
  802767:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80276b:	89 f2                	mov    %esi,%edx
  80276d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80276f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802773:	d3 e0                	shl    %cl,%eax
  802775:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802779:	8b 44 24 14          	mov    0x14(%esp),%eax
  80277d:	89 f9                	mov    %edi,%ecx
  80277f:	d3 e8                	shr    %cl,%eax
  802781:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802783:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802785:	89 f2                	mov    %esi,%edx
  802787:	f7 74 24 18          	divl   0x18(%esp)
  80278b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80278d:	f7 64 24 0c          	mull   0xc(%esp)
  802791:	89 c5                	mov    %eax,%ebp
  802793:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802795:	39 d6                	cmp    %edx,%esi
  802797:	72 67                	jb     802800 <__umoddi3+0x114>
  802799:	74 75                	je     802810 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80279b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80279f:	29 e8                	sub    %ebp,%eax
  8027a1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8027a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 f2                	mov    %esi,%edx
  8027ab:	89 f9                	mov    %edi,%ecx
  8027ad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8027af:	09 d0                	or     %edx,%eax
  8027b1:	89 f2                	mov    %esi,%edx
  8027b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8027b7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027b9:	83 c4 20             	add    $0x20,%esp
  8027bc:	5e                   	pop    %esi
  8027bd:	5f                   	pop    %edi
  8027be:	5d                   	pop    %ebp
  8027bf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8027c0:	85 c9                	test   %ecx,%ecx
  8027c2:	75 0b                	jne    8027cf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c9:	31 d2                	xor    %edx,%edx
  8027cb:	f7 f1                	div    %ecx
  8027cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8027cf:	89 f0                	mov    %esi,%eax
  8027d1:	31 d2                	xor    %edx,%edx
  8027d3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027d5:	89 f8                	mov    %edi,%eax
  8027d7:	e9 3e ff ff ff       	jmp    80271a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8027dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027de:	83 c4 20             	add    $0x20,%esp
  8027e1:	5e                   	pop    %esi
  8027e2:	5f                   	pop    %edi
  8027e3:	5d                   	pop    %ebp
  8027e4:	c3                   	ret    
  8027e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027e8:	39 f5                	cmp    %esi,%ebp
  8027ea:	72 04                	jb     8027f0 <__umoddi3+0x104>
  8027ec:	39 f9                	cmp    %edi,%ecx
  8027ee:	77 06                	ja     8027f6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027f0:	89 f2                	mov    %esi,%edx
  8027f2:	29 cf                	sub    %ecx,%edi
  8027f4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8027f6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027f8:	83 c4 20             	add    $0x20,%esp
  8027fb:	5e                   	pop    %esi
  8027fc:	5f                   	pop    %edi
  8027fd:	5d                   	pop    %ebp
  8027fe:	c3                   	ret    
  8027ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802800:	89 d1                	mov    %edx,%ecx
  802802:	89 c5                	mov    %eax,%ebp
  802804:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802808:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80280c:	eb 8d                	jmp    80279b <__umoddi3+0xaf>
  80280e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802810:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802814:	72 ea                	jb     802800 <__umoddi3+0x114>
  802816:	89 f1                	mov    %esi,%ecx
  802818:	eb 81                	jmp    80279b <__umoddi3+0xaf>
