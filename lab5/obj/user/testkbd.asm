
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 8b 02 00 00       	call   8002bc <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800040:	e8 41 0e 00 00       	call   800e86 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	4b                   	dec    %ebx
  800046:	75 f8                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  800048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80004f:	e8 74 12 00 00       	call   8012c8 <close>
	if ((r = opencons()) < 0)
  800054:	e8 0f 02 00 00       	call   800268 <opencons>
  800059:	85 c0                	test   %eax,%eax
  80005b:	79 20                	jns    80007d <umain+0x49>
		panic("opencons: %e", r);
  80005d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800061:	c7 44 24 08 80 22 80 	movl   $0x802280,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800070:	00 
  800071:	c7 04 24 8d 22 80 00 	movl   $0x80228d,(%esp)
  800078:	e8 b3 02 00 00       	call   800330 <_panic>
	if (r != 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	74 20                	je     8000a1 <umain+0x6d>
		panic("first opencons used fd %d", r);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 9c 22 80 	movl   $0x80229c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 8d 22 80 00 	movl   $0x80228d,(%esp)
  80009c:	e8 8f 02 00 00       	call   800330 <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a8:	00 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 64 12 00 00       	call   801319 <dup>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0xa5>
		panic("dup: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 b6 22 80 	movl   $0x8022b6,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 8d 22 80 00 	movl   $0x80228d,(%esp)
  8000d4:	e8 57 02 00 00       	call   800330 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000d9:	c7 04 24 be 22 80 00 	movl   $0x8022be,(%esp)
  8000e0:	e8 bb 08 00 00       	call   8009a0 <readline>
		if (buf != NULL)
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	74 1a                	je     800103 <umain+0xcf>
			fprintf(1, "%s\n", buf);
  8000e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ed:	c7 44 24 04 cc 22 80 	movl   $0x8022cc,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fc:	e8 f7 19 00 00       	call   801af8 <fprintf>
  800101:	eb d6                	jmp    8000d9 <umain+0xa5>
		else
			fprintf(1, "(end of file received)\n");
  800103:	c7 44 24 04 d0 22 80 	movl   $0x8022d0,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800112:	e8 e1 19 00 00       	call   801af8 <fprintf>
  800117:	eb c0                	jmp    8000d9 <umain+0xa5>
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80011f:	b8 00 00 00 00       	mov    $0x0,%eax
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80012c:	c7 44 24 04 e8 22 80 	movl   $0x8022e8,0x4(%esp)
  800133:	00 
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 74 09 00 00       	call   800ab3 <strcpy>
	return 0;
}
  80013f:	b8 00 00 00 00       	mov    $0x0,%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800152:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800157:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80015d:	eb 30                	jmp    80018f <devcons_write+0x49>
		m = n - tot;
  80015f:	8b 75 10             	mov    0x10(%ebp),%esi
  800162:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800164:	83 fe 7f             	cmp    $0x7f,%esi
  800167:	76 05                	jbe    80016e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800169:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80016e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800172:	03 45 0c             	add    0xc(%ebp),%eax
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	89 3c 24             	mov    %edi,(%esp)
  80017c:	e8 ab 0a 00 00       	call   800c2c <memmove>
		sys_cputs(buf, m);
  800181:	89 74 24 04          	mov    %esi,0x4(%esp)
  800185:	89 3c 24             	mov    %edi,(%esp)
  800188:	e8 4b 0c 00 00       	call   800dd8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80018d:	01 f3                	add    %esi,%ebx
  80018f:	89 d8                	mov    %ebx,%eax
  800191:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800194:	72 c9                	jb     80015f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800196:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8001a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001ab:	75 07                	jne    8001b4 <devcons_read+0x13>
  8001ad:	eb 25                	jmp    8001d4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8001af:	e8 d2 0c 00 00       	call   800e86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001b4:	e8 3d 0c 00 00       	call   800df6 <sys_cgetc>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	74 f2                	je     8001af <devcons_read+0xe>
  8001bd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	78 1d                	js     8001e0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001c3:	83 f8 04             	cmp    $0x4,%eax
  8001c6:	74 13                	je     8001db <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	88 10                	mov    %dl,(%eax)
	return 1;
  8001cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8001d2:	eb 0c                	jmp    8001e0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d9:	eb 05                	jmp    8001e0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f5:	00 
  8001f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 d7 0b 00 00       	call   800dd8 <sys_cputs>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <getchar>:

int
getchar(void)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800209:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800210:	00 
  800211:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021f:	e8 08 12 00 00       	call   80142c <read>
	if (r < 0)
  800224:	85 c0                	test   %eax,%eax
  800226:	78 0f                	js     800237 <getchar+0x34>
		return r;
	if (r < 1)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 06                	jle    800232 <getchar+0x2f>
		return -E_EOF;
	return c;
  80022c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800230:	eb 05                	jmp    800237 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800232:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80023f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 3d 0f 00 00       	call   80118e <fd_lookup>
  800251:	85 c0                	test   %eax,%eax
  800253:	78 11                	js     800266 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800258:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80025e:	39 10                	cmp    %edx,(%eax)
  800260:	0f 94 c0             	sete   %al
  800263:	0f b6 c0             	movzbl %al,%eax
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <opencons>:

int
opencons(void)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80026e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 c2 0e 00 00       	call   80113b <fd_alloc>
  800279:	85 c0                	test   %eax,%eax
  80027b:	78 3c                	js     8002b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80027d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800284:	00 
  800285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800293:	e8 0d 0c 00 00       	call   800ea5 <sys_page_alloc>
  800298:	85 c0                	test   %eax,%eax
  80029a:	78 1d                	js     8002b9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80029c:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 57 0e 00 00       	call   801110 <fd2num>
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    
	...

008002bc <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 20             	sub    $0x20,%esp
  8002c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8002ca:	e8 98 0b 00 00       	call   800e67 <sys_getenvid>
  8002cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002db:	c1 e0 07             	shl    $0x7,%eax
  8002de:	29 d0                	sub    %edx,%eax
  8002e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8002e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8002eb:	a3 04 44 80 00       	mov    %eax,0x804404
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f0:	85 f6                	test   %esi,%esi
  8002f2:	7e 07                	jle    8002fb <libmain+0x3f>
		binaryname = argv[0];
  8002f4:	8b 03                	mov    (%ebx),%eax
  8002f6:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ff:	89 34 24             	mov    %esi,(%esp)
  800302:	e8 2d fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800307:	e8 08 00 00 00       	call   800314 <exit>
}
  80030c:	83 c4 20             	add    $0x20,%esp
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    
	...

00800314 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80031a:	e8 da 0f 00 00       	call   8012f9 <close_all>
	sys_env_destroy(0);
  80031f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800326:	e8 ea 0a 00 00       	call   800e15 <sys_env_destroy>
}
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    
  80032d:	00 00                	add    %al,(%eax)
	...

00800330 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800338:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033b:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  800341:	e8 21 0b 00 00       	call   800e67 <sys_getenvid>
  800346:	8b 55 0c             	mov    0xc(%ebp),%edx
  800349:	89 54 24 10          	mov    %edx,0x10(%esp)
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800354:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035c:	c7 04 24 00 23 80 00 	movl   $0x802300,(%esp)
  800363:	e8 c0 00 00 00       	call   800428 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800368:	89 74 24 04          	mov    %esi,0x4(%esp)
  80036c:	8b 45 10             	mov    0x10(%ebp),%eax
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	e8 50 00 00 00       	call   8003c7 <vcprintf>
	cprintf("\n");
  800377:	c7 04 24 4e 27 80 00 	movl   $0x80274e,(%esp)
  80037e:	e8 a5 00 00 00       	call   800428 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800383:	cc                   	int3   
  800384:	eb fd                	jmp    800383 <_panic+0x53>
	...

00800388 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	53                   	push   %ebx
  80038c:	83 ec 14             	sub    $0x14,%esp
  80038f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800392:	8b 03                	mov    (%ebx),%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80039b:	40                   	inc    %eax
  80039c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a3:	75 19                	jne    8003be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ac:	00 
  8003ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 20 0a 00 00       	call   800dd8 <sys_cputs>
		b->idx = 0;
  8003b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003be:	ff 43 04             	incl   0x4(%ebx)
}
  8003c1:	83 c4 14             	add    $0x14,%esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d7:	00 00 00 
	b.cnt = 0;
  8003da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fc:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800403:	e8 82 01 00 00       	call   80058a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800408:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80040e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800412:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 b8 09 00 00       	call   800dd8 <sys_cputs>

	return b.cnt;
}
  800420:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800431:	89 44 24 04          	mov    %eax,0x4(%esp)
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	e8 87 ff ff ff       	call   8003c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800440:	c9                   	leave  
  800441:	c3                   	ret    
	...

00800444 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
  80044a:	83 ec 3c             	sub    $0x3c,%esp
  80044d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800450:	89 d7                	mov    %edx,%edi
  800452:	8b 45 08             	mov    0x8(%ebp),%eax
  800455:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800458:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800461:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800464:	85 c0                	test   %eax,%eax
  800466:	75 08                	jne    800470 <printnum+0x2c>
  800468:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80046e:	77 57                	ja     8004c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800470:	89 74 24 10          	mov    %esi,0x10(%esp)
  800474:	4b                   	dec    %ebx
  800475:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800479:	8b 45 10             	mov    0x10(%ebp),%eax
  80047c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800480:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800484:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800488:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048f:	00 
  800490:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	e8 72 1b 00 00       	call   802014 <__udivdi3>
  8004a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b1:	89 fa                	mov    %edi,%edx
  8004b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b6:	e8 89 ff ff ff       	call   800444 <printnum>
  8004bb:	eb 0f                	jmp    8004cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c1:	89 34 24             	mov    %esi,(%esp)
  8004c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c7:	4b                   	dec    %ebx
  8004c8:	85 db                	test   %ebx,%ebx
  8004ca:	7f f1                	jg     8004bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e2:	00 
  8004e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f0:	e8 3f 1c 00 00       	call   802134 <__umoddi3>
  8004f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f9:	0f be 80 23 23 80 00 	movsbl 0x802323(%eax),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800506:	83 c4 3c             	add    $0x3c,%esp
  800509:	5b                   	pop    %ebx
  80050a:	5e                   	pop    %esi
  80050b:	5f                   	pop    %edi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800511:	83 fa 01             	cmp    $0x1,%edx
  800514:	7e 0e                	jle    800524 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800516:	8b 10                	mov    (%eax),%edx
  800518:	8d 4a 08             	lea    0x8(%edx),%ecx
  80051b:	89 08                	mov    %ecx,(%eax)
  80051d:	8b 02                	mov    (%edx),%eax
  80051f:	8b 52 04             	mov    0x4(%edx),%edx
  800522:	eb 22                	jmp    800546 <getuint+0x38>
	else if (lflag)
  800524:	85 d2                	test   %edx,%edx
  800526:	74 10                	je     800538 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052d:	89 08                	mov    %ecx,(%eax)
  80052f:	8b 02                	mov    (%edx),%eax
  800531:	ba 00 00 00 00       	mov    $0x0,%edx
  800536:	eb 0e                	jmp    800546 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800538:	8b 10                	mov    (%eax),%edx
  80053a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80053d:	89 08                	mov    %ecx,(%eax)
  80053f:	8b 02                	mov    (%edx),%eax
  800541:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800546:	5d                   	pop    %ebp
  800547:	c3                   	ret    

00800548 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800551:	8b 10                	mov    (%eax),%edx
  800553:	3b 50 04             	cmp    0x4(%eax),%edx
  800556:	73 08                	jae    800560 <sprintputch+0x18>
		*b->buf++ = ch;
  800558:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80055b:	88 0a                	mov    %cl,(%edx)
  80055d:	42                   	inc    %edx
  80055e:	89 10                	mov    %edx,(%eax)
}
  800560:	5d                   	pop    %ebp
  800561:	c3                   	ret    

00800562 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800568:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056f:	8b 45 10             	mov    0x10(%ebp),%eax
  800572:	89 44 24 08          	mov    %eax,0x8(%esp)
  800576:	8b 45 0c             	mov    0xc(%ebp),%eax
  800579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 02 00 00 00       	call   80058a <vprintfmt>
	va_end(ap);
}
  800588:	c9                   	leave  
  800589:	c3                   	ret    

0080058a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	57                   	push   %edi
  80058e:	56                   	push   %esi
  80058f:	53                   	push   %ebx
  800590:	83 ec 4c             	sub    $0x4c,%esp
  800593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800596:	8b 75 10             	mov    0x10(%ebp),%esi
  800599:	eb 12                	jmp    8005ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80059b:	85 c0                	test   %eax,%eax
  80059d:	0f 84 6b 03 00 00    	je     80090e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ad:	0f b6 06             	movzbl (%esi),%eax
  8005b0:	46                   	inc    %esi
  8005b1:	83 f8 25             	cmp    $0x25,%eax
  8005b4:	75 e5                	jne    80059b <vprintfmt+0x11>
  8005b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	eb 26                	jmp    8005fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005db:	eb 1d                	jmp    8005fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005e4:	eb 14                	jmp    8005fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f0:	eb 08                	jmp    8005fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	0f b6 06             	movzbl (%esi),%eax
  8005fd:	8d 56 01             	lea    0x1(%esi),%edx
  800600:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800603:	8a 16                	mov    (%esi),%dl
  800605:	83 ea 23             	sub    $0x23,%edx
  800608:	80 fa 55             	cmp    $0x55,%dl
  80060b:	0f 87 e1 02 00 00    	ja     8008f2 <vprintfmt+0x368>
  800611:	0f b6 d2             	movzbl %dl,%edx
  800614:	ff 24 95 60 24 80 00 	jmp    *0x802460(,%edx,4)
  80061b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800623:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800626:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80062a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80062d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800630:	83 fa 09             	cmp    $0x9,%edx
  800633:	77 2a                	ja     80065f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800635:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800636:	eb eb                	jmp    800623 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800646:	eb 17                	jmp    80065f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800648:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064c:	78 98                	js     8005e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800651:	eb a7                	jmp    8005fa <vprintfmt+0x70>
  800653:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800656:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80065d:	eb 9b                	jmp    8005fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80065f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800663:	79 95                	jns    8005fa <vprintfmt+0x70>
  800665:	eb 8b                	jmp    8005f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800667:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80066b:	eb 8d                	jmp    8005fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800685:	e9 23 ff ff ff       	jmp    8005ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	79 02                	jns    80069b <vprintfmt+0x111>
  800699:	f7 d8                	neg    %eax
  80069b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80069d:	83 f8 0f             	cmp    $0xf,%eax
  8006a0:	7f 0b                	jg     8006ad <vprintfmt+0x123>
  8006a2:	8b 04 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%eax
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	75 23                	jne    8006d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b1:	c7 44 24 08 3b 23 80 	movl   $0x80233b,0x8(%esp)
  8006b8:	00 
  8006b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	e8 9a fe ff ff       	call   800562 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006cb:	e9 dd fe ff ff       	jmp    8005ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d4:	c7 44 24 08 05 27 80 	movl   $0x802705,0x8(%esp)
  8006db:	00 
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e3:	89 14 24             	mov    %edx,(%esp)
  8006e6:	e8 77 fe ff ff       	call   800562 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ee:	e9 ba fe ff ff       	jmp    8005ad <vprintfmt+0x23>
  8006f3:	89 f9                	mov    %edi,%ecx
  8006f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 50 04             	lea    0x4(%eax),%edx
  800701:	89 55 14             	mov    %edx,0x14(%ebp)
  800704:	8b 30                	mov    (%eax),%esi
  800706:	85 f6                	test   %esi,%esi
  800708:	75 05                	jne    80070f <vprintfmt+0x185>
				p = "(null)";
  80070a:	be 34 23 80 00       	mov    $0x802334,%esi
			if (width > 0 && padc != '-')
  80070f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800713:	0f 8e 84 00 00 00    	jle    80079d <vprintfmt+0x213>
  800719:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80071d:	74 7e                	je     80079d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800723:	89 34 24             	mov    %esi,(%esp)
  800726:	e8 6b 03 00 00       	call   800a96 <strnlen>
  80072b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072e:	29 c2                	sub    %eax,%edx
  800730:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800733:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800737:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80073a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80073d:	89 de                	mov    %ebx,%esi
  80073f:	89 d3                	mov    %edx,%ebx
  800741:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800743:	eb 0b                	jmp    800750 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800745:	89 74 24 04          	mov    %esi,0x4(%esp)
  800749:	89 3c 24             	mov    %edi,(%esp)
  80074c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074f:	4b                   	dec    %ebx
  800750:	85 db                	test   %ebx,%ebx
  800752:	7f f1                	jg     800745 <vprintfmt+0x1bb>
  800754:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800757:	89 f3                	mov    %esi,%ebx
  800759:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80075c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075f:	85 c0                	test   %eax,%eax
  800761:	79 05                	jns    800768 <vprintfmt+0x1de>
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80076b:	29 c2                	sub    %eax,%edx
  80076d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800770:	eb 2b                	jmp    80079d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800772:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800776:	74 18                	je     800790 <vprintfmt+0x206>
  800778:	8d 50 e0             	lea    -0x20(%eax),%edx
  80077b:	83 fa 5e             	cmp    $0x5e,%edx
  80077e:	76 10                	jbe    800790 <vprintfmt+0x206>
					putch('?', putdat);
  800780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800784:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
  80078e:	eb 0a                	jmp    80079a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079a:	ff 4d e4             	decl   -0x1c(%ebp)
  80079d:	0f be 06             	movsbl (%esi),%eax
  8007a0:	46                   	inc    %esi
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	74 21                	je     8007c6 <vprintfmt+0x23c>
  8007a5:	85 ff                	test   %edi,%edi
  8007a7:	78 c9                	js     800772 <vprintfmt+0x1e8>
  8007a9:	4f                   	dec    %edi
  8007aa:	79 c6                	jns    800772 <vprintfmt+0x1e8>
  8007ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007af:	89 de                	mov    %ebx,%esi
  8007b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007b4:	eb 18                	jmp    8007ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c3:	4b                   	dec    %ebx
  8007c4:	eb 08                	jmp    8007ce <vprintfmt+0x244>
  8007c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c9:	89 de                	mov    %ebx,%esi
  8007cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007ce:	85 db                	test   %ebx,%ebx
  8007d0:	7f e4                	jg     8007b6 <vprintfmt+0x22c>
  8007d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007da:	e9 ce fd ff ff       	jmp    8005ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007df:	83 f9 01             	cmp    $0x1,%ecx
  8007e2:	7e 10                	jle    8007f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 50 08             	lea    0x8(%eax),%edx
  8007ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ed:	8b 30                	mov    (%eax),%esi
  8007ef:	8b 78 04             	mov    0x4(%eax),%edi
  8007f2:	eb 26                	jmp    80081a <vprintfmt+0x290>
	else if (lflag)
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	74 12                	je     80080a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	8b 30                	mov    (%eax),%esi
  800803:	89 f7                	mov    %esi,%edi
  800805:	c1 ff 1f             	sar    $0x1f,%edi
  800808:	eb 10                	jmp    80081a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8d 50 04             	lea    0x4(%eax),%edx
  800810:	89 55 14             	mov    %edx,0x14(%ebp)
  800813:	8b 30                	mov    (%eax),%esi
  800815:	89 f7                	mov    %esi,%edi
  800817:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081a:	85 ff                	test   %edi,%edi
  80081c:	78 0a                	js     800828 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 8c 00 00 00       	jmp    8008b4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800828:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800836:	f7 de                	neg    %esi
  800838:	83 d7 00             	adc    $0x0,%edi
  80083b:	f7 df                	neg    %edi
			}
			base = 10;
  80083d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800842:	eb 70                	jmp    8008b4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800844:	89 ca                	mov    %ecx,%edx
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 c0 fc ff ff       	call   80050e <getuint>
  80084e:	89 c6                	mov    %eax,%esi
  800850:	89 d7                	mov    %edx,%edi
			base = 10;
  800852:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800857:	eb 5b                	jmp    8008b4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800859:	89 ca                	mov    %ecx,%edx
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	e8 ab fc ff ff       	call   80050e <getuint>
  800863:	89 c6                	mov    %eax,%esi
  800865:	89 d7                	mov    %edx,%edi
			base = 8;
  800867:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80086c:	eb 46                	jmp    8008b4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80086e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800872:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800879:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80087c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800880:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800887:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8d 50 04             	lea    0x4(%eax),%edx
  800890:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800893:	8b 30                	mov    (%eax),%esi
  800895:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80089a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80089f:	eb 13                	jmp    8008b4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a1:	89 ca                	mov    %ecx,%edx
  8008a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a6:	e8 63 fc ff ff       	call   80050e <getuint>
  8008ab:	89 c6                	mov    %eax,%esi
  8008ad:	89 d7                	mov    %edx,%edi
			base = 16;
  8008af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008b8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c7:	89 34 24             	mov    %esi,(%esp)
  8008ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ce:	89 da                	mov    %ebx,%edx
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	e8 6c fb ff ff       	call   800444 <printnum>
			break;
  8008d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008db:	e9 cd fc ff ff       	jmp    8005ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	89 04 24             	mov    %eax,(%esp)
  8008e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ed:	e9 bb fc ff ff       	jmp    8005ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008fd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800900:	eb 01                	jmp    800903 <vprintfmt+0x379>
  800902:	4e                   	dec    %esi
  800903:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800907:	75 f9                	jne    800902 <vprintfmt+0x378>
  800909:	e9 9f fc ff ff       	jmp    8005ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80090e:	83 c4 4c             	add    $0x4c,%esp
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 28             	sub    $0x28,%esp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800922:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800925:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800929:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800933:	85 c0                	test   %eax,%eax
  800935:	74 30                	je     800967 <vsnprintf+0x51>
  800937:	85 d2                	test   %edx,%edx
  800939:	7e 33                	jle    80096e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800942:	8b 45 10             	mov    0x10(%ebp),%eax
  800945:	89 44 24 08          	mov    %eax,0x8(%esp)
  800949:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	c7 04 24 48 05 80 00 	movl   $0x800548,(%esp)
  800957:	e8 2e fc ff ff       	call   80058a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80095c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800965:	eb 0c                	jmp    800973 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800967:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096c:	eb 05                	jmp    800973 <vsnprintf+0x5d>
  80096e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800982:	8b 45 10             	mov    0x10(%ebp),%eax
  800985:	89 44 24 08          	mov    %eax,0x8(%esp)
  800989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 7b ff ff ff       	call   800916 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    
  80099d:	00 00                	add    %al,(%eax)
	...

008009a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	83 ec 1c             	sub    $0x1c,%esp
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	74 18                	je     8009c8 <readline+0x28>
		fprintf(1, "%s", prompt);
  8009b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b4:	c7 44 24 04 05 27 80 	movl   $0x802705,0x4(%esp)
  8009bb:	00 
  8009bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009c3:	e8 30 11 00 00       	call   801af8 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8009c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009cf:	e8 65 f8 ff ff       	call   800239 <iscons>
  8009d4:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009d6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009db:	e8 23 f8 ff ff       	call   800203 <getchar>
  8009e0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009e2:	85 c0                	test   %eax,%eax
  8009e4:	79 20                	jns    800a06 <readline+0x66>
			if (c != -E_EOF)
  8009e6:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8009e9:	0f 84 82 00 00 00    	je     800a71 <readline+0xd1>
				cprintf("read error: %e\n", c);
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	c7 04 24 1f 26 80 00 	movl   $0x80261f,(%esp)
  8009fa:	e8 29 fa ff ff       	call   800428 <cprintf>
			return NULL;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 70                	jmp    800a76 <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a06:	83 f8 08             	cmp    $0x8,%eax
  800a09:	74 05                	je     800a10 <readline+0x70>
  800a0b:	83 f8 7f             	cmp    $0x7f,%eax
  800a0e:	75 17                	jne    800a27 <readline+0x87>
  800a10:	85 f6                	test   %esi,%esi
  800a12:	7e 13                	jle    800a27 <readline+0x87>
			if (echoing)
  800a14:	85 ff                	test   %edi,%edi
  800a16:	74 0c                	je     800a24 <readline+0x84>
				cputchar('\b');
  800a18:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800a1f:	e8 be f7 ff ff       	call   8001e2 <cputchar>
			i--;
  800a24:	4e                   	dec    %esi
  800a25:	eb b4                	jmp    8009db <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a27:	83 fb 1f             	cmp    $0x1f,%ebx
  800a2a:	7e 1d                	jle    800a49 <readline+0xa9>
  800a2c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a32:	7f 15                	jg     800a49 <readline+0xa9>
			if (echoing)
  800a34:	85 ff                	test   %edi,%edi
  800a36:	74 08                	je     800a40 <readline+0xa0>
				cputchar(c);
  800a38:	89 1c 24             	mov    %ebx,(%esp)
  800a3b:	e8 a2 f7 ff ff       	call   8001e2 <cputchar>
			buf[i++] = c;
  800a40:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a46:	46                   	inc    %esi
  800a47:	eb 92                	jmp    8009db <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800a49:	83 fb 0a             	cmp    $0xa,%ebx
  800a4c:	74 05                	je     800a53 <readline+0xb3>
  800a4e:	83 fb 0d             	cmp    $0xd,%ebx
  800a51:	75 88                	jne    8009db <readline+0x3b>
			if (echoing)
  800a53:	85 ff                	test   %edi,%edi
  800a55:	74 0c                	je     800a63 <readline+0xc3>
				cputchar('\n');
  800a57:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800a5e:	e8 7f f7 ff ff       	call   8001e2 <cputchar>
			buf[i] = 0;
  800a63:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a6a:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a6f:	eb 05                	jmp    800a76 <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800a76:	83 c4 1c             	add    $0x1c,%esp
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    
	...

00800a80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	eb 01                	jmp    800a8e <strlen+0xe>
		n++;
  800a8d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a8e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a92:	75 f9                	jne    800a8d <strlen+0xd>
		n++;
	return n;
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	eb 01                	jmp    800aa7 <strnlen+0x11>
		n++;
  800aa6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa7:	39 d0                	cmp    %edx,%eax
  800aa9:	74 06                	je     800ab1 <strnlen+0x1b>
  800aab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aaf:	75 f5                	jne    800aa6 <strnlen+0x10>
		n++;
	return n;
}
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	53                   	push   %ebx
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800abd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ac5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ac8:	42                   	inc    %edx
  800ac9:	84 c9                	test   %cl,%cl
  800acb:	75 f5                	jne    800ac2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800acd:	5b                   	pop    %ebx
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	83 ec 08             	sub    $0x8,%esp
  800ad7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ada:	89 1c 24             	mov    %ebx,(%esp)
  800add:	e8 9e ff ff ff       	call   800a80 <strlen>
	strcpy(dst + len, src);
  800ae2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae9:	01 d8                	add    %ebx,%eax
  800aeb:	89 04 24             	mov    %eax,(%esp)
  800aee:	e8 c0 ff ff ff       	call   800ab3 <strcpy>
	return dst;
}
  800af3:	89 d8                	mov    %ebx,%eax
  800af5:	83 c4 08             	add    $0x8,%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0e:	eb 0c                	jmp    800b1c <strncpy+0x21>
		*dst++ = *src;
  800b10:	8a 1a                	mov    (%edx),%bl
  800b12:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b15:	80 3a 01             	cmpb   $0x1,(%edx)
  800b18:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b1b:	41                   	inc    %ecx
  800b1c:	39 f1                	cmp    %esi,%ecx
  800b1e:	75 f0                	jne    800b10 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b32:	85 d2                	test   %edx,%edx
  800b34:	75 0a                	jne    800b40 <strlcpy+0x1c>
  800b36:	89 f0                	mov    %esi,%eax
  800b38:	eb 1a                	jmp    800b54 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b3a:	88 18                	mov    %bl,(%eax)
  800b3c:	40                   	inc    %eax
  800b3d:	41                   	inc    %ecx
  800b3e:	eb 02                	jmp    800b42 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b40:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b42:	4a                   	dec    %edx
  800b43:	74 0a                	je     800b4f <strlcpy+0x2b>
  800b45:	8a 19                	mov    (%ecx),%bl
  800b47:	84 db                	test   %bl,%bl
  800b49:	75 ef                	jne    800b3a <strlcpy+0x16>
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	eb 02                	jmp    800b51 <strlcpy+0x2d>
  800b4f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b51:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b54:	29 f0                	sub    %esi,%eax
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b60:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b63:	eb 02                	jmp    800b67 <strcmp+0xd>
		p++, q++;
  800b65:	41                   	inc    %ecx
  800b66:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b67:	8a 01                	mov    (%ecx),%al
  800b69:	84 c0                	test   %al,%al
  800b6b:	74 04                	je     800b71 <strcmp+0x17>
  800b6d:	3a 02                	cmp    (%edx),%al
  800b6f:	74 f4                	je     800b65 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b71:	0f b6 c0             	movzbl %al,%eax
  800b74:	0f b6 12             	movzbl (%edx),%edx
  800b77:	29 d0                	sub    %edx,%eax
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	53                   	push   %ebx
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b85:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b88:	eb 03                	jmp    800b8d <strncmp+0x12>
		n--, p++, q++;
  800b8a:	4a                   	dec    %edx
  800b8b:	40                   	inc    %eax
  800b8c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b8d:	85 d2                	test   %edx,%edx
  800b8f:	74 14                	je     800ba5 <strncmp+0x2a>
  800b91:	8a 18                	mov    (%eax),%bl
  800b93:	84 db                	test   %bl,%bl
  800b95:	74 04                	je     800b9b <strncmp+0x20>
  800b97:	3a 19                	cmp    (%ecx),%bl
  800b99:	74 ef                	je     800b8a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b9b:	0f b6 00             	movzbl (%eax),%eax
  800b9e:	0f b6 11             	movzbl (%ecx),%edx
  800ba1:	29 d0                	sub    %edx,%eax
  800ba3:	eb 05                	jmp    800baa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb6:	eb 05                	jmp    800bbd <strchr+0x10>
		if (*s == c)
  800bb8:	38 ca                	cmp    %cl,%dl
  800bba:	74 0c                	je     800bc8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bbc:	40                   	inc    %eax
  800bbd:	8a 10                	mov    (%eax),%dl
  800bbf:	84 d2                	test   %dl,%dl
  800bc1:	75 f5                	jne    800bb8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bd3:	eb 05                	jmp    800bda <strfind+0x10>
		if (*s == c)
  800bd5:	38 ca                	cmp    %cl,%dl
  800bd7:	74 07                	je     800be0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bd9:	40                   	inc    %eax
  800bda:	8a 10                	mov    (%eax),%dl
  800bdc:	84 d2                	test   %dl,%dl
  800bde:	75 f5                	jne    800bd5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf1:	85 c9                	test   %ecx,%ecx
  800bf3:	74 30                	je     800c25 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfb:	75 25                	jne    800c22 <memset+0x40>
  800bfd:	f6 c1 03             	test   $0x3,%cl
  800c00:	75 20                	jne    800c22 <memset+0x40>
		c &= 0xFF;
  800c02:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	c1 e3 08             	shl    $0x8,%ebx
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	c1 e6 18             	shl    $0x18,%esi
  800c0f:	89 d0                	mov    %edx,%eax
  800c11:	c1 e0 10             	shl    $0x10,%eax
  800c14:	09 f0                	or     %esi,%eax
  800c16:	09 d0                	or     %edx,%eax
  800c18:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c1a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c1d:	fc                   	cld    
  800c1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c20:	eb 03                	jmp    800c25 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c22:	fc                   	cld    
  800c23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c25:	89 f8                	mov    %edi,%eax
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c3a:	39 c6                	cmp    %eax,%esi
  800c3c:	73 34                	jae    800c72 <memmove+0x46>
  800c3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c41:	39 d0                	cmp    %edx,%eax
  800c43:	73 2d                	jae    800c72 <memmove+0x46>
		s += n;
		d += n;
  800c45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c48:	f6 c2 03             	test   $0x3,%dl
  800c4b:	75 1b                	jne    800c68 <memmove+0x3c>
  800c4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c53:	75 13                	jne    800c68 <memmove+0x3c>
  800c55:	f6 c1 03             	test   $0x3,%cl
  800c58:	75 0e                	jne    800c68 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5a:	83 ef 04             	sub    $0x4,%edi
  800c5d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c60:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c63:	fd                   	std    
  800c64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c66:	eb 07                	jmp    800c6f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c68:	4f                   	dec    %edi
  800c69:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c6c:	fd                   	std    
  800c6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6f:	fc                   	cld    
  800c70:	eb 20                	jmp    800c92 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c78:	75 13                	jne    800c8d <memmove+0x61>
  800c7a:	a8 03                	test   $0x3,%al
  800c7c:	75 0f                	jne    800c8d <memmove+0x61>
  800c7e:	f6 c1 03             	test   $0x3,%cl
  800c81:	75 0a                	jne    800c8d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c83:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c86:	89 c7                	mov    %eax,%edi
  800c88:	fc                   	cld    
  800c89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8b:	eb 05                	jmp    800c92 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c8d:	89 c7                	mov    %eax,%edi
  800c8f:	fc                   	cld    
  800c90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800caa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cad:	89 04 24             	mov    %eax,(%esp)
  800cb0:	e8 77 ff ff ff       	call   800c2c <memmove>
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccb:	eb 16                	jmp    800ce3 <memcmp+0x2c>
		if (*s1 != *s2)
  800ccd:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cd0:	42                   	inc    %edx
  800cd1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cd5:	38 c8                	cmp    %cl,%al
  800cd7:	74 0a                	je     800ce3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cd9:	0f b6 c0             	movzbl %al,%eax
  800cdc:	0f b6 c9             	movzbl %cl,%ecx
  800cdf:	29 c8                	sub    %ecx,%eax
  800ce1:	eb 09                	jmp    800cec <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce3:	39 da                	cmp    %ebx,%edx
  800ce5:	75 e6                	jne    800ccd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cfa:	89 c2                	mov    %eax,%edx
  800cfc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cff:	eb 05                	jmp    800d06 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d01:	38 08                	cmp    %cl,(%eax)
  800d03:	74 05                	je     800d0a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d05:	40                   	inc    %eax
  800d06:	39 d0                	cmp    %edx,%eax
  800d08:	72 f7                	jb     800d01 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d18:	eb 01                	jmp    800d1b <strtol+0xf>
		s++;
  800d1a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1b:	8a 02                	mov    (%edx),%al
  800d1d:	3c 20                	cmp    $0x20,%al
  800d1f:	74 f9                	je     800d1a <strtol+0xe>
  800d21:	3c 09                	cmp    $0x9,%al
  800d23:	74 f5                	je     800d1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d25:	3c 2b                	cmp    $0x2b,%al
  800d27:	75 08                	jne    800d31 <strtol+0x25>
		s++;
  800d29:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2f:	eb 13                	jmp    800d44 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d31:	3c 2d                	cmp    $0x2d,%al
  800d33:	75 0a                	jne    800d3f <strtol+0x33>
		s++, neg = 1;
  800d35:	8d 52 01             	lea    0x1(%edx),%edx
  800d38:	bf 01 00 00 00       	mov    $0x1,%edi
  800d3d:	eb 05                	jmp    800d44 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d44:	85 db                	test   %ebx,%ebx
  800d46:	74 05                	je     800d4d <strtol+0x41>
  800d48:	83 fb 10             	cmp    $0x10,%ebx
  800d4b:	75 28                	jne    800d75 <strtol+0x69>
  800d4d:	8a 02                	mov    (%edx),%al
  800d4f:	3c 30                	cmp    $0x30,%al
  800d51:	75 10                	jne    800d63 <strtol+0x57>
  800d53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d57:	75 0a                	jne    800d63 <strtol+0x57>
		s += 2, base = 16;
  800d59:	83 c2 02             	add    $0x2,%edx
  800d5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d61:	eb 12                	jmp    800d75 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d63:	85 db                	test   %ebx,%ebx
  800d65:	75 0e                	jne    800d75 <strtol+0x69>
  800d67:	3c 30                	cmp    $0x30,%al
  800d69:	75 05                	jne    800d70 <strtol+0x64>
		s++, base = 8;
  800d6b:	42                   	inc    %edx
  800d6c:	b3 08                	mov    $0x8,%bl
  800d6e:	eb 05                	jmp    800d75 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d70:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d75:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d7c:	8a 0a                	mov    (%edx),%cl
  800d7e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d81:	80 fb 09             	cmp    $0x9,%bl
  800d84:	77 08                	ja     800d8e <strtol+0x82>
			dig = *s - '0';
  800d86:	0f be c9             	movsbl %cl,%ecx
  800d89:	83 e9 30             	sub    $0x30,%ecx
  800d8c:	eb 1e                	jmp    800dac <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d8e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d91:	80 fb 19             	cmp    $0x19,%bl
  800d94:	77 08                	ja     800d9e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d96:	0f be c9             	movsbl %cl,%ecx
  800d99:	83 e9 57             	sub    $0x57,%ecx
  800d9c:	eb 0e                	jmp    800dac <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d9e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800da1:	80 fb 19             	cmp    $0x19,%bl
  800da4:	77 12                	ja     800db8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800da6:	0f be c9             	movsbl %cl,%ecx
  800da9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dac:	39 f1                	cmp    %esi,%ecx
  800dae:	7d 0c                	jge    800dbc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800db0:	42                   	inc    %edx
  800db1:	0f af c6             	imul   %esi,%eax
  800db4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800db6:	eb c4                	jmp    800d7c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800db8:	89 c1                	mov    %eax,%ecx
  800dba:	eb 02                	jmp    800dbe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dbc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc2:	74 05                	je     800dc9 <strtol+0xbd>
		*endptr = (char *) s;
  800dc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc9:	85 ff                	test   %edi,%edi
  800dcb:	74 04                	je     800dd1 <strtol+0xc5>
  800dcd:	89 c8                	mov    %ecx,%eax
  800dcf:	f7 d8                	neg    %eax
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    
	...

00800dd8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800dde:	b8 00 00 00 00       	mov    $0x0,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	89 c7                	mov    %eax,%edi
  800ded:	89 c6                	mov    %eax,%esi
  800def:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	89 d3                	mov    %edx,%ebx
  800e0a:	89 d7                	mov    %edx,%edi
  800e0c:	89 d6                	mov    %edx,%esi
  800e0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
  800e1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e23:	b8 03 00 00 00       	mov    $0x3,%eax
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 cb                	mov    %ecx,%ebx
  800e2d:	89 cf                	mov    %ecx,%edi
  800e2f:	89 ce                	mov    %ecx,%esi
  800e31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 28                	jle    800e5f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e42:	00 
  800e43:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  800e5a:	e8 d1 f4 ff ff       	call   800330 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e5f:	83 c4 2c             	add    $0x2c,%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e72:	b8 02 00 00 00       	mov    $0x2,%eax
  800e77:	89 d1                	mov    %edx,%ecx
  800e79:	89 d3                	mov    %edx,%ebx
  800e7b:	89 d7                	mov    %edx,%edi
  800e7d:	89 d6                	mov    %edx,%esi
  800e7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_yield>:

void
sys_yield(void)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e96:	89 d1                	mov    %edx,%ecx
  800e98:	89 d3                	mov    %edx,%ebx
  800e9a:	89 d7                	mov    %edx,%edi
  800e9c:	89 d6                	mov    %edx,%esi
  800e9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	be 00 00 00 00       	mov    $0x0,%esi
  800eb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	89 f7                	mov    %esi,%edi
  800ec3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	7e 28                	jle    800ef1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  800edc:	00 
  800edd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee4:	00 
  800ee5:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  800eec:	e8 3f f4 ff ff       	call   800330 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ef1:	83 c4 2c             	add    $0x2c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f02:	b8 05 00 00 00       	mov    $0x5,%eax
  800f07:	8b 75 18             	mov    0x18(%ebp),%esi
  800f0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	7e 28                	jle    800f44 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f20:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f27:	00 
  800f28:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  800f2f:	00 
  800f30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f37:	00 
  800f38:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  800f3f:	e8 ec f3 ff ff       	call   800330 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f44:	83 c4 2c             	add    $0x2c,%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 df                	mov    %ebx,%edi
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	7e 28                	jle    800f97 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8a:	00 
  800f8b:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  800f92:	e8 99 f3 ff ff       	call   800330 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f97:	83 c4 2c             	add    $0x2c,%esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fad:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 df                	mov    %ebx,%edi
  800fba:	89 de                	mov    %ebx,%esi
  800fbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	7e 28                	jle    800fea <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fcd:	00 
  800fce:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdd:	00 
  800fde:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  800fe5:	e8 46 f3 ff ff       	call   800330 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fea:	83 c4 2c             	add    $0x2c,%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801000:	b8 09 00 00 00       	mov    $0x9,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	89 df                	mov    %ebx,%edi
  80100d:	89 de                	mov    %ebx,%esi
  80100f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801011:	85 c0                	test   %eax,%eax
  801013:	7e 28                	jle    80103d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801015:	89 44 24 10          	mov    %eax,0x10(%esp)
  801019:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801020:	00 
  801021:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  801028:	00 
  801029:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801030:	00 
  801031:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  801038:	e8 f3 f2 ff ff       	call   800330 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80103d:	83 c4 2c             	add    $0x2c,%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	57                   	push   %edi
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
  80104b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801053:	b8 0a 00 00 00       	mov    $0xa,%eax
  801058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105b:	8b 55 08             	mov    0x8(%ebp),%edx
  80105e:	89 df                	mov    %ebx,%edi
  801060:	89 de                	mov    %ebx,%esi
  801062:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801064:	85 c0                	test   %eax,%eax
  801066:	7e 28                	jle    801090 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801068:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801073:	00 
  801074:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  80107b:	00 
  80107c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801083:	00 
  801084:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  80108b:	e8 a0 f2 ff ff       	call   800330 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801090:	83 c4 2c             	add    $0x2c,%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109e:	be 00 00 00 00       	mov    $0x0,%esi
  8010a3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d1:	89 cb                	mov    %ecx,%ebx
  8010d3:	89 cf                	mov    %ecx,%edi
  8010d5:	89 ce                	mov    %ecx,%esi
  8010d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	7e 28                	jle    801105 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 08 2f 26 80 	movl   $0x80262f,0x8(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f8:	00 
  8010f9:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  801100:	e8 2b f2 ff ff       	call   800330 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801105:	83 c4 2c             	add    $0x2c,%esp
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    
  80110d:	00 00                	add    %al,(%eax)
	...

00801110 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	05 00 00 00 30       	add    $0x30000000,%eax
  80111b:	c1 e8 0c             	shr    $0xc,%eax
}
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	89 04 24             	mov    %eax,(%esp)
  80112c:	e8 df ff ff ff       	call   801110 <fd2num>
  801131:	05 20 00 0d 00       	add    $0xd0020,%eax
  801136:	c1 e0 0c             	shl    $0xc,%eax
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	53                   	push   %ebx
  80113f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801142:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801147:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801149:	89 c2                	mov    %eax,%edx
  80114b:	c1 ea 16             	shr    $0x16,%edx
  80114e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801155:	f6 c2 01             	test   $0x1,%dl
  801158:	74 11                	je     80116b <fd_alloc+0x30>
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	c1 ea 0c             	shr    $0xc,%edx
  80115f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801166:	f6 c2 01             	test   $0x1,%dl
  801169:	75 09                	jne    801174 <fd_alloc+0x39>
			*fd_store = fd;
  80116b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80116d:	b8 00 00 00 00       	mov    $0x0,%eax
  801172:	eb 17                	jmp    80118b <fd_alloc+0x50>
  801174:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801179:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117e:	75 c7                	jne    801147 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801180:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801186:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80118b:	5b                   	pop    %ebx
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801194:	83 f8 1f             	cmp    $0x1f,%eax
  801197:	77 36                	ja     8011cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801199:	05 00 00 0d 00       	add    $0xd0000,%eax
  80119e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a1:	89 c2                	mov    %eax,%edx
  8011a3:	c1 ea 16             	shr    $0x16,%edx
  8011a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ad:	f6 c2 01             	test   $0x1,%dl
  8011b0:	74 24                	je     8011d6 <fd_lookup+0x48>
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	c1 ea 0c             	shr    $0xc,%edx
  8011b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011be:	f6 c2 01             	test   $0x1,%dl
  8011c1:	74 1a                	je     8011dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cd:	eb 13                	jmp    8011e2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d4:	eb 0c                	jmp    8011e2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011db:	eb 05                	jmp    8011e2 <fd_lookup+0x54>
  8011dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 14             	sub    $0x14,%esp
  8011eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f6:	eb 0e                	jmp    801206 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8011f8:	39 08                	cmp    %ecx,(%eax)
  8011fa:	75 09                	jne    801205 <dev_lookup+0x21>
			*dev = devtab[i];
  8011fc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8011fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801203:	eb 35                	jmp    80123a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801205:	42                   	inc    %edx
  801206:	8b 04 95 dc 26 80 00 	mov    0x8026dc(,%edx,4),%eax
  80120d:	85 c0                	test   %eax,%eax
  80120f:	75 e7                	jne    8011f8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801211:	a1 04 44 80 00       	mov    0x804404,%eax
  801216:	8b 00                	mov    (%eax),%eax
  801218:	8b 40 48             	mov    0x48(%eax),%eax
  80121b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80121f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801223:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  80122a:	e8 f9 f1 ff ff       	call   800428 <cprintf>
	*dev = 0;
  80122f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80123a:	83 c4 14             	add    $0x14,%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
  801245:	83 ec 30             	sub    $0x30,%esp
  801248:	8b 75 08             	mov    0x8(%ebp),%esi
  80124b:	8a 45 0c             	mov    0xc(%ebp),%al
  80124e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801251:	89 34 24             	mov    %esi,(%esp)
  801254:	e8 b7 fe ff ff       	call   801110 <fd2num>
  801259:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80125c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801260:	89 04 24             	mov    %eax,(%esp)
  801263:	e8 26 ff ff ff       	call   80118e <fd_lookup>
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 05                	js     801273 <fd_close+0x33>
	    || fd != fd2)
  80126e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801271:	74 0d                	je     801280 <fd_close+0x40>
		return (must_exist ? r : 0);
  801273:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801277:	75 46                	jne    8012bf <fd_close+0x7f>
  801279:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127e:	eb 3f                	jmp    8012bf <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801280:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801283:	89 44 24 04          	mov    %eax,0x4(%esp)
  801287:	8b 06                	mov    (%esi),%eax
  801289:	89 04 24             	mov    %eax,(%esp)
  80128c:	e8 53 ff ff ff       	call   8011e4 <dev_lookup>
  801291:	89 c3                	mov    %eax,%ebx
  801293:	85 c0                	test   %eax,%eax
  801295:	78 18                	js     8012af <fd_close+0x6f>
		if (dev->dev_close)
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	8b 40 10             	mov    0x10(%eax),%eax
  80129d:	85 c0                	test   %eax,%eax
  80129f:	74 09                	je     8012aa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012a1:	89 34 24             	mov    %esi,(%esp)
  8012a4:	ff d0                	call   *%eax
  8012a6:	89 c3                	mov    %eax,%ebx
  8012a8:	eb 05                	jmp    8012af <fd_close+0x6f>
		else
			r = 0;
  8012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ba:	e8 8d fc ff ff       	call   800f4c <sys_page_unmap>
	return r;
}
  8012bf:	89 d8                	mov    %ebx,%eax
  8012c1:	83 c4 30             	add    $0x30,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d8:	89 04 24             	mov    %eax,(%esp)
  8012db:	e8 ae fe ff ff       	call   80118e <fd_lookup>
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 13                	js     8012f7 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012e4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012eb:	00 
  8012ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ef:	89 04 24             	mov    %eax,(%esp)
  8012f2:	e8 49 ff ff ff       	call   801240 <fd_close>
}
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <close_all>:

void
close_all(void)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801300:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801305:	89 1c 24             	mov    %ebx,(%esp)
  801308:	e8 bb ff ff ff       	call   8012c8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80130d:	43                   	inc    %ebx
  80130e:	83 fb 20             	cmp    $0x20,%ebx
  801311:	75 f2                	jne    801305 <close_all+0xc>
		close(i);
}
  801313:	83 c4 14             	add    $0x14,%esp
  801316:	5b                   	pop    %ebx
  801317:	5d                   	pop    %ebp
  801318:	c3                   	ret    

00801319 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	57                   	push   %edi
  80131d:	56                   	push   %esi
  80131e:	53                   	push   %ebx
  80131f:	83 ec 4c             	sub    $0x4c,%esp
  801322:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801325:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 57 fe ff ff       	call   80118e <fd_lookup>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	85 c0                	test   %eax,%eax
  80133b:	0f 88 e1 00 00 00    	js     801422 <dup+0x109>
		return r;
	close(newfdnum);
  801341:	89 3c 24             	mov    %edi,(%esp)
  801344:	e8 7f ff ff ff       	call   8012c8 <close>

	newfd = INDEX2FD(newfdnum);
  801349:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80134f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 c3 fd ff ff       	call   801120 <fd2data>
  80135d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80135f:	89 34 24             	mov    %esi,(%esp)
  801362:	e8 b9 fd ff ff       	call   801120 <fd2data>
  801367:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80136a:	89 d8                	mov    %ebx,%eax
  80136c:	c1 e8 16             	shr    $0x16,%eax
  80136f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801376:	a8 01                	test   $0x1,%al
  801378:	74 46                	je     8013c0 <dup+0xa7>
  80137a:	89 d8                	mov    %ebx,%eax
  80137c:	c1 e8 0c             	shr    $0xc,%eax
  80137f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801386:	f6 c2 01             	test   $0x1,%dl
  801389:	74 35                	je     8013c0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80138b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801392:	25 07 0e 00 00       	and    $0xe07,%eax
  801397:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80139e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013a9:	00 
  8013aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b5:	e8 3f fb ff ff       	call   800ef9 <sys_page_map>
  8013ba:	89 c3                	mov    %eax,%ebx
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 3b                	js     8013fb <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	c1 ea 0c             	shr    $0xc,%edx
  8013c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cf:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013d9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013e4:	00 
  8013e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f0:	e8 04 fb ff ff       	call   800ef9 <sys_page_map>
  8013f5:	89 c3                	mov    %eax,%ebx
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	79 25                	jns    801420 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801406:	e8 41 fb ff ff       	call   800f4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80140e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801412:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801419:	e8 2e fb ff ff       	call   800f4c <sys_page_unmap>
	return r;
  80141e:	eb 02                	jmp    801422 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801420:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801422:	89 d8                	mov    %ebx,%eax
  801424:	83 c4 4c             	add    $0x4c,%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5f                   	pop    %edi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 24             	sub    $0x24,%esp
  801433:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143d:	89 1c 24             	mov    %ebx,(%esp)
  801440:	e8 49 fd ff ff       	call   80118e <fd_lookup>
  801445:	85 c0                	test   %eax,%eax
  801447:	78 6f                	js     8014b8 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801453:	8b 00                	mov    (%eax),%eax
  801455:	89 04 24             	mov    %eax,(%esp)
  801458:	e8 87 fd ff ff       	call   8011e4 <dev_lookup>
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 57                	js     8014b8 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	8b 50 08             	mov    0x8(%eax),%edx
  801467:	83 e2 03             	and    $0x3,%edx
  80146a:	83 fa 01             	cmp    $0x1,%edx
  80146d:	75 25                	jne    801494 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146f:	a1 04 44 80 00       	mov    0x804404,%eax
  801474:	8b 00                	mov    (%eax),%eax
  801476:	8b 40 48             	mov    0x48(%eax),%eax
  801479:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	c7 04 24 a0 26 80 00 	movl   $0x8026a0,(%esp)
  801488:	e8 9b ef ff ff       	call   800428 <cprintf>
		return -E_INVAL;
  80148d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801492:	eb 24                	jmp    8014b8 <read+0x8c>
	}
	if (!dev->dev_read)
  801494:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801497:	8b 52 08             	mov    0x8(%edx),%edx
  80149a:	85 d2                	test   %edx,%edx
  80149c:	74 15                	je     8014b3 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	ff d2                	call   *%edx
  8014b1:	eb 05                	jmp    8014b8 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014b8:	83 c4 24             	add    $0x24,%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5d                   	pop    %ebp
  8014bd:	c3                   	ret    

008014be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 1c             	sub    $0x1c,%esp
  8014c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d2:	eb 23                	jmp    8014f7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d4:	89 f0                	mov    %esi,%eax
  8014d6:	29 d8                	sub    %ebx,%eax
  8014d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014df:	01 d8                	add    %ebx,%eax
  8014e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e5:	89 3c 24             	mov    %edi,(%esp)
  8014e8:	e8 3f ff ff ff       	call   80142c <read>
		if (m < 0)
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 10                	js     801501 <readn+0x43>
			return m;
		if (m == 0)
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	74 0a                	je     8014ff <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f5:	01 c3                	add    %eax,%ebx
  8014f7:	39 f3                	cmp    %esi,%ebx
  8014f9:	72 d9                	jb     8014d4 <readn+0x16>
  8014fb:	89 d8                	mov    %ebx,%eax
  8014fd:	eb 02                	jmp    801501 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014ff:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801501:	83 c4 1c             	add    $0x1c,%esp
  801504:	5b                   	pop    %ebx
  801505:	5e                   	pop    %esi
  801506:	5f                   	pop    %edi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 24             	sub    $0x24,%esp
  801510:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801513:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151a:	89 1c 24             	mov    %ebx,(%esp)
  80151d:	e8 6c fc ff ff       	call   80118e <fd_lookup>
  801522:	85 c0                	test   %eax,%eax
  801524:	78 6a                	js     801590 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801530:	8b 00                	mov    (%eax),%eax
  801532:	89 04 24             	mov    %eax,(%esp)
  801535:	e8 aa fc ff ff       	call   8011e4 <dev_lookup>
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 52                	js     801590 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801541:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801545:	75 25                	jne    80156c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801547:	a1 04 44 80 00       	mov    0x804404,%eax
  80154c:	8b 00                	mov    (%eax),%eax
  80154e:	8b 40 48             	mov    0x48(%eax),%eax
  801551:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801555:	89 44 24 04          	mov    %eax,0x4(%esp)
  801559:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  801560:	e8 c3 ee ff ff       	call   800428 <cprintf>
		return -E_INVAL;
  801565:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156a:	eb 24                	jmp    801590 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80156c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156f:	8b 52 0c             	mov    0xc(%edx),%edx
  801572:	85 d2                	test   %edx,%edx
  801574:	74 15                	je     80158b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801576:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801579:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80157d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801580:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801584:	89 04 24             	mov    %eax,(%esp)
  801587:	ff d2                	call   *%edx
  801589:	eb 05                	jmp    801590 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80158b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801590:	83 c4 24             	add    $0x24,%esp
  801593:	5b                   	pop    %ebx
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <seek>:

int
seek(int fdnum, off_t offset)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	89 04 24             	mov    %eax,(%esp)
  8015a9:	e8 e0 fb ff ff       	call   80118e <fd_lookup>
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 0e                	js     8015c0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	53                   	push   %ebx
  8015c6:	83 ec 24             	sub    $0x24,%esp
  8015c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d3:	89 1c 24             	mov    %ebx,(%esp)
  8015d6:	e8 b3 fb ff ff       	call   80118e <fd_lookup>
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 63                	js     801642 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e9:	8b 00                	mov    (%eax),%eax
  8015eb:	89 04 24             	mov    %eax,(%esp)
  8015ee:	e8 f1 fb ff ff       	call   8011e4 <dev_lookup>
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 4b                	js     801642 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fe:	75 25                	jne    801625 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801600:	a1 04 44 80 00       	mov    0x804404,%eax
  801605:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801607:	8b 40 48             	mov    0x48(%eax),%eax
  80160a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80160e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801612:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  801619:	e8 0a ee ff ff       	call   800428 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80161e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801623:	eb 1d                	jmp    801642 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801625:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801628:	8b 52 18             	mov    0x18(%edx),%edx
  80162b:	85 d2                	test   %edx,%edx
  80162d:	74 0e                	je     80163d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80162f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801632:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801636:	89 04 24             	mov    %eax,(%esp)
  801639:	ff d2                	call   *%edx
  80163b:	eb 05                	jmp    801642 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801642:	83 c4 24             	add    $0x24,%esp
  801645:	5b                   	pop    %ebx
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 24             	sub    $0x24,%esp
  80164f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	89 44 24 04          	mov    %eax,0x4(%esp)
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	89 04 24             	mov    %eax,(%esp)
  80165f:	e8 2a fb ff ff       	call   80118e <fd_lookup>
  801664:	85 c0                	test   %eax,%eax
  801666:	78 52                	js     8016ba <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	8b 00                	mov    (%eax),%eax
  801674:	89 04 24             	mov    %eax,(%esp)
  801677:	e8 68 fb ff ff       	call   8011e4 <dev_lookup>
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 3a                	js     8016ba <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801687:	74 2c                	je     8016b5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801689:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801693:	00 00 00 
	stat->st_isdir = 0;
  801696:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169d:	00 00 00 
	stat->st_dev = dev;
  8016a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ad:	89 14 24             	mov    %edx,(%esp)
  8016b0:	ff 50 14             	call   *0x14(%eax)
  8016b3:	eb 05                	jmp    8016ba <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ba:	83 c4 24             	add    $0x24,%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016cf:	00 
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	89 04 24             	mov    %eax,(%esp)
  8016d6:	e8 88 02 00 00       	call   801963 <open>
  8016db:	89 c3                	mov    %eax,%ebx
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 1b                	js     8016fc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8016e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	89 1c 24             	mov    %ebx,(%esp)
  8016eb:	e8 58 ff ff ff       	call   801648 <fstat>
  8016f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f2:	89 1c 24             	mov    %ebx,(%esp)
  8016f5:	e8 ce fb ff ff       	call   8012c8 <close>
	return r;
  8016fa:	89 f3                	mov    %esi,%ebx
}
  8016fc:	89 d8                	mov    %ebx,%eax
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    
  801705:	00 00                	add    %al,(%eax)
	...

00801708 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	83 ec 10             	sub    $0x10,%esp
  801710:	89 c3                	mov    %eax,%ebx
  801712:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801714:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80171b:	75 11                	jne    80172e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80171d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801724:	e8 62 08 00 00       	call   801f8b <ipc_find_env>
  801729:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80172e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801735:	00 
  801736:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80173d:	00 
  80173e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801742:	a1 00 44 80 00       	mov    0x804400,%eax
  801747:	89 04 24             	mov    %eax,(%esp)
  80174a:	e8 d6 07 00 00       	call   801f25 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  80174f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801756:	00 
  801757:	89 74 24 04          	mov    %esi,0x4(%esp)
  80175b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801762:	e8 51 07 00 00       	call   801eb8 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	5b                   	pop    %ebx
  80176b:	5e                   	pop    %esi
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	8b 40 0c             	mov    0xc(%eax),%eax
  80177a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801782:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801787:	ba 00 00 00 00       	mov    $0x0,%edx
  80178c:	b8 02 00 00 00       	mov    $0x2,%eax
  801791:	e8 72 ff ff ff       	call   801708 <fsipc>
}
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179e:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b3:	e8 50 ff ff ff       	call   801708 <fsipc>
}
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	83 ec 14             	sub    $0x14,%esp
  8017c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ca:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d9:	e8 2a ff ff ff       	call   801708 <fsipc>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 2b                	js     80180d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017e9:	00 
  8017ea:	89 1c 24             	mov    %ebx,(%esp)
  8017ed:	e8 c1 f2 ff ff       	call   800ab3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801802:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801808:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180d:	83 c4 14             	add    $0x14,%esp
  801810:	5b                   	pop    %ebx
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	83 ec 14             	sub    $0x14,%esp
  80181a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	8b 40 0c             	mov    0xc(%eax),%eax
  801823:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801828:	89 d8                	mov    %ebx,%eax
  80182a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801830:	76 05                	jbe    801837 <devfile_write+0x24>
  801832:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801837:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  80183c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801840:	8b 45 0c             	mov    0xc(%ebp),%eax
  801843:	89 44 24 04          	mov    %eax,0x4(%esp)
  801847:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80184e:	e8 43 f4 ff ff       	call   800c96 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
  801858:	b8 04 00 00 00       	mov    $0x4,%eax
  80185d:	e8 a6 fe ff ff       	call   801708 <fsipc>
  801862:	85 c0                	test   %eax,%eax
  801864:	78 53                	js     8018b9 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801866:	39 c3                	cmp    %eax,%ebx
  801868:	73 24                	jae    80188e <devfile_write+0x7b>
  80186a:	c7 44 24 0c ec 26 80 	movl   $0x8026ec,0xc(%esp)
  801871:	00 
  801872:	c7 44 24 08 f3 26 80 	movl   $0x8026f3,0x8(%esp)
  801879:	00 
  80187a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801881:	00 
  801882:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  801889:	e8 a2 ea ff ff       	call   800330 <_panic>
	assert(r <= PGSIZE);
  80188e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801893:	7e 24                	jle    8018b9 <devfile_write+0xa6>
  801895:	c7 44 24 0c 13 27 80 	movl   $0x802713,0xc(%esp)
  80189c:	00 
  80189d:	c7 44 24 08 f3 26 80 	movl   $0x8026f3,0x8(%esp)
  8018a4:	00 
  8018a5:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8018ac:	00 
  8018ad:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  8018b4:	e8 77 ea ff ff       	call   800330 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  8018b9:	83 c4 14             	add    $0x14,%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 10             	sub    $0x10,%esp
  8018c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e5:	e8 1e fe ff ff       	call   801708 <fsipc>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 6a                	js     80195a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018f0:	39 c6                	cmp    %eax,%esi
  8018f2:	73 24                	jae    801918 <devfile_read+0x59>
  8018f4:	c7 44 24 0c ec 26 80 	movl   $0x8026ec,0xc(%esp)
  8018fb:	00 
  8018fc:	c7 44 24 08 f3 26 80 	movl   $0x8026f3,0x8(%esp)
  801903:	00 
  801904:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80190b:	00 
  80190c:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  801913:	e8 18 ea ff ff       	call   800330 <_panic>
	assert(r <= PGSIZE);
  801918:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80191d:	7e 24                	jle    801943 <devfile_read+0x84>
  80191f:	c7 44 24 0c 13 27 80 	movl   $0x802713,0xc(%esp)
  801926:	00 
  801927:	c7 44 24 08 f3 26 80 	movl   $0x8026f3,0x8(%esp)
  80192e:	00 
  80192f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801936:	00 
  801937:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  80193e:	e8 ed e9 ff ff       	call   800330 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801943:	89 44 24 08          	mov    %eax,0x8(%esp)
  801947:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80194e:	00 
  80194f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	e8 d2 f2 ff ff       	call   800c2c <memmove>
	return r;
}
  80195a:	89 d8                	mov    %ebx,%eax
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	83 ec 20             	sub    $0x20,%esp
  80196b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80196e:	89 34 24             	mov    %esi,(%esp)
  801971:	e8 0a f1 ff ff       	call   800a80 <strlen>
  801976:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197b:	7f 60                	jg     8019dd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80197d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801980:	89 04 24             	mov    %eax,(%esp)
  801983:	e8 b3 f7 ff ff       	call   80113b <fd_alloc>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 54                	js     8019e2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80198e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801992:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801999:	e8 15 f1 ff ff       	call   800ab3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ae:	e8 55 fd ff ff       	call   801708 <fsipc>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	79 15                	jns    8019ce <open+0x6b>
		fd_close(fd, 0);
  8019b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019c0:	00 
  8019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c4:	89 04 24             	mov    %eax,(%esp)
  8019c7:	e8 74 f8 ff ff       	call   801240 <fd_close>
		return r;
  8019cc:	eb 14                	jmp    8019e2 <open+0x7f>
	}

	return fd2num(fd);
  8019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d1:	89 04 24             	mov    %eax,(%esp)
  8019d4:	e8 37 f7 ff ff       	call   801110 <fd2num>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	eb 05                	jmp    8019e2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019dd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019e2:	89 d8                	mov    %ebx,%eax
  8019e4:	83 c4 20             	add    $0x20,%esp
  8019e7:	5b                   	pop    %ebx
  8019e8:	5e                   	pop    %esi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019fb:	e8 08 fd ff ff       	call   801708 <fsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    
	...

00801a04 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	53                   	push   %ebx
  801a08:	83 ec 14             	sub    $0x14,%esp
  801a0b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a0d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a11:	7e 32                	jle    801a45 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a13:	8b 40 04             	mov    0x4(%eax),%eax
  801a16:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1a:	8d 43 10             	lea    0x10(%ebx),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	8b 03                	mov    (%ebx),%eax
  801a23:	89 04 24             	mov    %eax,(%esp)
  801a26:	e8 de fa ff ff       	call   801509 <write>
		if (result > 0)
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	7e 03                	jle    801a32 <writebuf+0x2e>
			b->result += result;
  801a2f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a32:	39 43 04             	cmp    %eax,0x4(%ebx)
  801a35:	74 0e                	je     801a45 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801a37:	89 c2                	mov    %eax,%edx
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	7e 05                	jle    801a42 <writebuf+0x3e>
  801a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a42:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801a45:	83 c4 14             	add    $0x14,%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <putch>:

static void
putch(int ch, void *thunk)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	53                   	push   %ebx
  801a4f:	83 ec 04             	sub    $0x4,%esp
  801a52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a55:	8b 43 04             	mov    0x4(%ebx),%eax
  801a58:	8b 55 08             	mov    0x8(%ebp),%edx
  801a5b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801a5f:	40                   	inc    %eax
  801a60:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801a63:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a68:	75 0e                	jne    801a78 <putch+0x2d>
		writebuf(b);
  801a6a:	89 d8                	mov    %ebx,%eax
  801a6c:	e8 93 ff ff ff       	call   801a04 <writebuf>
		b->idx = 0;
  801a71:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a78:	83 c4 04             	add    $0x4,%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801a87:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a90:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a97:	00 00 00 
	b.result = 0;
  801a9a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801aa1:	00 00 00 
	b.error = 1;
  801aa4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801aab:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801aae:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801abc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	c7 04 24 4b 1a 80 00 	movl   $0x801a4b,(%esp)
  801acd:	e8 b8 ea ff ff       	call   80058a <vprintfmt>
	if (b.idx > 0)
  801ad2:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801ad9:	7e 0b                	jle    801ae6 <vfprintf+0x68>
		writebuf(&b);
  801adb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ae1:	e8 1e ff ff ff       	call   801a04 <writebuf>

	return (b.result ? b.result : b.error);
  801ae6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801aec:	85 c0                	test   %eax,%eax
  801aee:	75 06                	jne    801af6 <vfprintf+0x78>
  801af0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801afe:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b01:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	89 04 24             	mov    %eax,(%esp)
  801b12:	e8 67 ff ff ff       	call   801a7e <vfprintf>
	va_end(ap);

	return cnt;
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <printf>:

int
printf(const char *fmt, ...)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b1f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b34:	e8 45 ff ff ff       	call   801a7e <vfprintf>
	va_end(ap);

	return cnt;
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    
	...

00801b3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	83 ec 10             	sub    $0x10,%esp
  801b44:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b47:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4a:	89 04 24             	mov    %eax,(%esp)
  801b4d:	e8 ce f5 ff ff       	call   801120 <fd2data>
  801b52:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b54:	c7 44 24 04 1f 27 80 	movl   $0x80271f,0x4(%esp)
  801b5b:	00 
  801b5c:	89 34 24             	mov    %esi,(%esp)
  801b5f:	e8 4f ef ff ff       	call   800ab3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b64:	8b 43 04             	mov    0x4(%ebx),%eax
  801b67:	2b 03                	sub    (%ebx),%eax
  801b69:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b6f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b76:	00 00 00 
	stat->st_dev = &devpipe;
  801b79:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801b80:	30 80 00 
	return 0;
}
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	5b                   	pop    %ebx
  801b8c:	5e                   	pop    %esi
  801b8d:	5d                   	pop    %ebp
  801b8e:	c3                   	ret    

00801b8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	53                   	push   %ebx
  801b93:	83 ec 14             	sub    $0x14,%esp
  801b96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba4:	e8 a3 f3 ff ff       	call   800f4c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ba9:	89 1c 24             	mov    %ebx,(%esp)
  801bac:	e8 6f f5 ff ff       	call   801120 <fd2data>
  801bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbc:	e8 8b f3 ff ff       	call   800f4c <sys_page_unmap>
}
  801bc1:	83 c4 14             	add    $0x14,%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5d                   	pop    %ebp
  801bc6:	c3                   	ret    

00801bc7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	57                   	push   %edi
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 2c             	sub    $0x2c,%esp
  801bd0:	89 c7                	mov    %eax,%edi
  801bd2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bd5:	a1 04 44 80 00       	mov    0x804404,%eax
  801bda:	8b 00                	mov    (%eax),%eax
  801bdc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bdf:	89 3c 24             	mov    %edi,(%esp)
  801be2:	e8 e9 03 00 00       	call   801fd0 <pageref>
  801be7:	89 c6                	mov    %eax,%esi
  801be9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 dc 03 00 00       	call   801fd0 <pageref>
  801bf4:	39 c6                	cmp    %eax,%esi
  801bf6:	0f 94 c0             	sete   %al
  801bf9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bfc:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801c02:	8b 12                	mov    (%edx),%edx
  801c04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c07:	39 cb                	cmp    %ecx,%ebx
  801c09:	75 08                	jne    801c13 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c0b:	83 c4 2c             	add    $0x2c,%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c13:	83 f8 01             	cmp    $0x1,%eax
  801c16:	75 bd                	jne    801bd5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c18:	8b 42 58             	mov    0x58(%edx),%eax
  801c1b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c22:	00 
  801c23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2b:	c7 04 24 26 27 80 00 	movl   $0x802726,(%esp)
  801c32:	e8 f1 e7 ff ff       	call   800428 <cprintf>
  801c37:	eb 9c                	jmp    801bd5 <_pipeisclosed+0xe>

00801c39 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	57                   	push   %edi
  801c3d:	56                   	push   %esi
  801c3e:	53                   	push   %ebx
  801c3f:	83 ec 1c             	sub    $0x1c,%esp
  801c42:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c45:	89 34 24             	mov    %esi,(%esp)
  801c48:	e8 d3 f4 ff ff       	call   801120 <fd2data>
  801c4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c54:	eb 3c                	jmp    801c92 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c56:	89 da                	mov    %ebx,%edx
  801c58:	89 f0                	mov    %esi,%eax
  801c5a:	e8 68 ff ff ff       	call   801bc7 <_pipeisclosed>
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	75 38                	jne    801c9b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c63:	e8 1e f2 ff ff       	call   800e86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c68:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6b:	8b 13                	mov    (%ebx),%edx
  801c6d:	83 c2 20             	add    $0x20,%edx
  801c70:	39 d0                	cmp    %edx,%eax
  801c72:	73 e2                	jae    801c56 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c77:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801c7a:	89 c2                	mov    %eax,%edx
  801c7c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c82:	79 05                	jns    801c89 <devpipe_write+0x50>
  801c84:	4a                   	dec    %edx
  801c85:	83 ca e0             	or     $0xffffffe0,%edx
  801c88:	42                   	inc    %edx
  801c89:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c8d:	40                   	inc    %eax
  801c8e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c91:	47                   	inc    %edi
  801c92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c95:	75 d1                	jne    801c68 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c97:	89 f8                	mov    %edi,%eax
  801c99:	eb 05                	jmp    801ca0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	57                   	push   %edi
  801cac:	56                   	push   %esi
  801cad:	53                   	push   %ebx
  801cae:	83 ec 1c             	sub    $0x1c,%esp
  801cb1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cb4:	89 3c 24             	mov    %edi,(%esp)
  801cb7:	e8 64 f4 ff ff       	call   801120 <fd2data>
  801cbc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbe:	be 00 00 00 00       	mov    $0x0,%esi
  801cc3:	eb 3a                	jmp    801cff <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cc5:	85 f6                	test   %esi,%esi
  801cc7:	74 04                	je     801ccd <devpipe_read+0x25>
				return i;
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	eb 40                	jmp    801d0d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ccd:	89 da                	mov    %ebx,%edx
  801ccf:	89 f8                	mov    %edi,%eax
  801cd1:	e8 f1 fe ff ff       	call   801bc7 <_pipeisclosed>
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	75 2e                	jne    801d08 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cda:	e8 a7 f1 ff ff       	call   800e86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cdf:	8b 03                	mov    (%ebx),%eax
  801ce1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ce4:	74 df                	je     801cc5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ce6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ceb:	79 05                	jns    801cf2 <devpipe_read+0x4a>
  801ced:	48                   	dec    %eax
  801cee:	83 c8 e0             	or     $0xffffffe0,%eax
  801cf1:	40                   	inc    %eax
  801cf2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801cf6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801cfc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfe:	46                   	inc    %esi
  801cff:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d02:	75 db                	jne    801cdf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d04:	89 f0                	mov    %esi,%eax
  801d06:	eb 05                	jmp    801d0d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d0d:	83 c4 1c             	add    $0x1c,%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	57                   	push   %edi
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	83 ec 3c             	sub    $0x3c,%esp
  801d1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d24:	89 04 24             	mov    %eax,(%esp)
  801d27:	e8 0f f4 ff ff       	call   80113b <fd_alloc>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 45 01 00 00    	js     801e7b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d3d:	00 
  801d3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4c:	e8 54 f1 ff ff       	call   800ea5 <sys_page_alloc>
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	85 c0                	test   %eax,%eax
  801d55:	0f 88 20 01 00 00    	js     801e7b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d5b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d5e:	89 04 24             	mov    %eax,(%esp)
  801d61:	e8 d5 f3 ff ff       	call   80113b <fd_alloc>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	0f 88 f8 00 00 00    	js     801e68 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d70:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d77:	00 
  801d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d86:	e8 1a f1 ff ff       	call   800ea5 <sys_page_alloc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	0f 88 d3 00 00 00    	js     801e68 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d98:	89 04 24             	mov    %eax,(%esp)
  801d9b:	e8 80 f3 ff ff       	call   801120 <fd2data>
  801da0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801da9:	00 
  801daa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db5:	e8 eb f0 ff ff       	call   800ea5 <sys_page_alloc>
  801dba:	89 c3                	mov    %eax,%ebx
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	0f 88 91 00 00 00    	js     801e55 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dc7:	89 04 24             	mov    %eax,(%esp)
  801dca:	e8 51 f3 ff ff       	call   801120 <fd2data>
  801dcf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801dd6:	00 
  801dd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ddb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801de2:	00 
  801de3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dee:	e8 06 f1 ff ff       	call   800ef9 <sys_page_map>
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 4c                	js     801e45 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801df9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e02:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e0e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e17:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e19:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e1c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e26:	89 04 24             	mov    %eax,(%esp)
  801e29:	e8 e2 f2 ff ff       	call   801110 <fd2num>
  801e2e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e33:	89 04 24             	mov    %eax,(%esp)
  801e36:	e8 d5 f2 ff ff       	call   801110 <fd2num>
  801e3b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e43:	eb 36                	jmp    801e7b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e50:	e8 f7 f0 ff ff       	call   800f4c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e63:	e8 e4 f0 ff ff       	call   800f4c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e76:	e8 d1 f0 ff ff       	call   800f4c <sys_page_unmap>
    err:
	return r;
}
  801e7b:	89 d8                	mov    %ebx,%eax
  801e7d:	83 c4 3c             	add    $0x3c,%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    

00801e85 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e92:	8b 45 08             	mov    0x8(%ebp),%eax
  801e95:	89 04 24             	mov    %eax,(%esp)
  801e98:	e8 f1 f2 ff ff       	call   80118e <fd_lookup>
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 15                	js     801eb6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea4:	89 04 24             	mov    %eax,(%esp)
  801ea7:	e8 74 f2 ff ff       	call   801120 <fd2data>
	return _pipeisclosed(fd, p);
  801eac:	89 c2                	mov    %eax,%edx
  801eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb1:	e8 11 fd ff ff       	call   801bc7 <_pipeisclosed>
}
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	56                   	push   %esi
  801ebc:	53                   	push   %ebx
  801ebd:	83 ec 10             	sub    $0x10,%esp
  801ec0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	75 05                	jne    801ed2 <ipc_recv+0x1a>
  801ecd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801ed2:	89 04 24             	mov    %eax,(%esp)
  801ed5:	e8 e1 f1 ff ff       	call   8010bb <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801eda:	85 c0                	test   %eax,%eax
  801edc:	79 16                	jns    801ef4 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801ede:	85 db                	test   %ebx,%ebx
  801ee0:	74 06                	je     801ee8 <ipc_recv+0x30>
  801ee2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801ee8:	85 f6                	test   %esi,%esi
  801eea:	74 32                	je     801f1e <ipc_recv+0x66>
  801eec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801ef2:	eb 2a                	jmp    801f1e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ef4:	85 db                	test   %ebx,%ebx
  801ef6:	74 0c                	je     801f04 <ipc_recv+0x4c>
  801ef8:	a1 04 44 80 00       	mov    0x804404,%eax
  801efd:	8b 00                	mov    (%eax),%eax
  801eff:	8b 40 74             	mov    0x74(%eax),%eax
  801f02:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801f04:	85 f6                	test   %esi,%esi
  801f06:	74 0c                	je     801f14 <ipc_recv+0x5c>
  801f08:	a1 04 44 80 00       	mov    0x804404,%eax
  801f0d:	8b 00                	mov    (%eax),%eax
  801f0f:	8b 40 78             	mov    0x78(%eax),%eax
  801f12:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801f14:	a1 04 44 80 00       	mov    0x804404,%eax
  801f19:	8b 00                	mov    (%eax),%eax
  801f1b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	5b                   	pop    %ebx
  801f22:	5e                   	pop    %esi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	57                   	push   %edi
  801f29:	56                   	push   %esi
  801f2a:	53                   	push   %ebx
  801f2b:	83 ec 1c             	sub    $0x1c,%esp
  801f2e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f34:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801f37:	85 db                	test   %ebx,%ebx
  801f39:	75 05                	jne    801f40 <ipc_send+0x1b>
  801f3b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801f40:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 41 f1 ff ff       	call   801098 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801f57:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5a:	75 07                	jne    801f63 <ipc_send+0x3e>
  801f5c:	e8 25 ef ff ff       	call   800e86 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801f61:	eb dd                	jmp    801f40 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801f63:	85 c0                	test   %eax,%eax
  801f65:	79 1c                	jns    801f83 <ipc_send+0x5e>
  801f67:	c7 44 24 08 3e 27 80 	movl   $0x80273e,0x8(%esp)
  801f6e:	00 
  801f6f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801f76:	00 
  801f77:	c7 04 24 50 27 80 00 	movl   $0x802750,(%esp)
  801f7e:	e8 ad e3 ff ff       	call   800330 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801f83:	83 c4 1c             	add    $0x1c,%esp
  801f86:	5b                   	pop    %ebx
  801f87:	5e                   	pop    %esi
  801f88:	5f                   	pop    %edi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	53                   	push   %ebx
  801f8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f97:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f9e:	89 c2                	mov    %eax,%edx
  801fa0:	c1 e2 07             	shl    $0x7,%edx
  801fa3:	29 ca                	sub    %ecx,%edx
  801fa5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fab:	8b 52 50             	mov    0x50(%edx),%edx
  801fae:	39 da                	cmp    %ebx,%edx
  801fb0:	75 0f                	jne    801fc1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801fb2:	c1 e0 07             	shl    $0x7,%eax
  801fb5:	29 c8                	sub    %ecx,%eax
  801fb7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801fbc:	8b 40 40             	mov    0x40(%eax),%eax
  801fbf:	eb 0c                	jmp    801fcd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fc1:	40                   	inc    %eax
  801fc2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fc7:	75 ce                	jne    801f97 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fc9:	66 b8 00 00          	mov    $0x0,%ax
}
  801fcd:	5b                   	pop    %ebx
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    

00801fd0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801fd6:	89 c2                	mov    %eax,%edx
  801fd8:	c1 ea 16             	shr    $0x16,%edx
  801fdb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fe2:	f6 c2 01             	test   $0x1,%dl
  801fe5:	74 1e                	je     802005 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fe7:	c1 e8 0c             	shr    $0xc,%eax
  801fea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ff1:	a8 01                	test   $0x1,%al
  801ff3:	74 17                	je     80200c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff5:	c1 e8 0c             	shr    $0xc,%eax
  801ff8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fff:	ef 
  802000:	0f b7 c0             	movzwl %ax,%eax
  802003:	eb 0c                	jmp    802011 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802005:	b8 00 00 00 00       	mov    $0x0,%eax
  80200a:	eb 05                	jmp    802011 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    
	...

00802014 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	83 ec 10             	sub    $0x10,%esp
  80201a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80201e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802022:	89 74 24 04          	mov    %esi,0x4(%esp)
  802026:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80202a:	89 cd                	mov    %ecx,%ebp
  80202c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802030:	85 c0                	test   %eax,%eax
  802032:	75 2c                	jne    802060 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802034:	39 f9                	cmp    %edi,%ecx
  802036:	77 68                	ja     8020a0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802038:	85 c9                	test   %ecx,%ecx
  80203a:	75 0b                	jne    802047 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80203c:	b8 01 00 00 00       	mov    $0x1,%eax
  802041:	31 d2                	xor    %edx,%edx
  802043:	f7 f1                	div    %ecx
  802045:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802047:	31 d2                	xor    %edx,%edx
  802049:	89 f8                	mov    %edi,%eax
  80204b:	f7 f1                	div    %ecx
  80204d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80204f:	89 f0                	mov    %esi,%eax
  802051:	f7 f1                	div    %ecx
  802053:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802055:	89 f0                	mov    %esi,%eax
  802057:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802059:	83 c4 10             	add    $0x10,%esp
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802060:	39 f8                	cmp    %edi,%eax
  802062:	77 2c                	ja     802090 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802064:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802067:	83 f6 1f             	xor    $0x1f,%esi
  80206a:	75 4c                	jne    8020b8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80206c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80206e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802073:	72 0a                	jb     80207f <__udivdi3+0x6b>
  802075:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802079:	0f 87 ad 00 00 00    	ja     80212c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80207f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802084:	89 f0                	mov    %esi,%eax
  802086:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802088:	83 c4 10             	add    $0x10,%esp
  80208b:	5e                   	pop    %esi
  80208c:	5f                   	pop    %edi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    
  80208f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802090:	31 ff                	xor    %edi,%edi
  802092:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802094:	89 f0                	mov    %esi,%eax
  802096:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	5e                   	pop    %esi
  80209c:	5f                   	pop    %edi
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    
  80209f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020a0:	89 fa                	mov    %edi,%edx
  8020a2:	89 f0                	mov    %esi,%eax
  8020a4:	f7 f1                	div    %ecx
  8020a6:	89 c6                	mov    %eax,%esi
  8020a8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020aa:	89 f0                	mov    %esi,%eax
  8020ac:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	5e                   	pop    %esi
  8020b2:	5f                   	pop    %edi
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    
  8020b5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020b8:	89 f1                	mov    %esi,%ecx
  8020ba:	d3 e0                	shl    %cl,%eax
  8020bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020c0:	b8 20 00 00 00       	mov    $0x20,%eax
  8020c5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8020c7:	89 ea                	mov    %ebp,%edx
  8020c9:	88 c1                	mov    %al,%cl
  8020cb:	d3 ea                	shr    %cl,%edx
  8020cd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8020d1:	09 ca                	or     %ecx,%edx
  8020d3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8020d7:	89 f1                	mov    %esi,%ecx
  8020d9:	d3 e5                	shl    %cl,%ebp
  8020db:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8020df:	89 fd                	mov    %edi,%ebp
  8020e1:	88 c1                	mov    %al,%cl
  8020e3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8020e5:	89 fa                	mov    %edi,%edx
  8020e7:	89 f1                	mov    %esi,%ecx
  8020e9:	d3 e2                	shl    %cl,%edx
  8020eb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020ef:	88 c1                	mov    %al,%cl
  8020f1:	d3 ef                	shr    %cl,%edi
  8020f3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020f5:	89 f8                	mov    %edi,%eax
  8020f7:	89 ea                	mov    %ebp,%edx
  8020f9:	f7 74 24 08          	divl   0x8(%esp)
  8020fd:	89 d1                	mov    %edx,%ecx
  8020ff:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802101:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802105:	39 d1                	cmp    %edx,%ecx
  802107:	72 17                	jb     802120 <__udivdi3+0x10c>
  802109:	74 09                	je     802114 <__udivdi3+0x100>
  80210b:	89 fe                	mov    %edi,%esi
  80210d:	31 ff                	xor    %edi,%edi
  80210f:	e9 41 ff ff ff       	jmp    802055 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802114:	8b 54 24 04          	mov    0x4(%esp),%edx
  802118:	89 f1                	mov    %esi,%ecx
  80211a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80211c:	39 c2                	cmp    %eax,%edx
  80211e:	73 eb                	jae    80210b <__udivdi3+0xf7>
		{
		  q0--;
  802120:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802123:	31 ff                	xor    %edi,%edi
  802125:	e9 2b ff ff ff       	jmp    802055 <__udivdi3+0x41>
  80212a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80212c:	31 f6                	xor    %esi,%esi
  80212e:	e9 22 ff ff ff       	jmp    802055 <__udivdi3+0x41>
	...

00802134 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802134:	55                   	push   %ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	83 ec 20             	sub    $0x20,%esp
  80213a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80213e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802142:	89 44 24 14          	mov    %eax,0x14(%esp)
  802146:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80214a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80214e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802152:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802154:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802156:	85 ed                	test   %ebp,%ebp
  802158:	75 16                	jne    802170 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80215a:	39 f1                	cmp    %esi,%ecx
  80215c:	0f 86 a6 00 00 00    	jbe    802208 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802162:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802164:	89 d0                	mov    %edx,%eax
  802166:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802168:	83 c4 20             	add    $0x20,%esp
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    
  80216f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802170:	39 f5                	cmp    %esi,%ebp
  802172:	0f 87 ac 00 00 00    	ja     802224 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802178:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80217b:	83 f0 1f             	xor    $0x1f,%eax
  80217e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802182:	0f 84 a8 00 00 00    	je     802230 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802188:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80218c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80218e:	bf 20 00 00 00       	mov    $0x20,%edi
  802193:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802197:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80219b:	89 f9                	mov    %edi,%ecx
  80219d:	d3 e8                	shr    %cl,%eax
  80219f:	09 e8                	or     %ebp,%eax
  8021a1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8021a5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8021a9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021ad:	d3 e0                	shl    %cl,%eax
  8021af:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8021b3:	89 f2                	mov    %esi,%edx
  8021b5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8021b7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021bb:	d3 e0                	shl    %cl,%eax
  8021bd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8021c1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8021cb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	f7 74 24 18          	divl   0x18(%esp)
  8021d3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021d5:	f7 64 24 0c          	mull   0xc(%esp)
  8021d9:	89 c5                	mov    %eax,%ebp
  8021db:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021dd:	39 d6                	cmp    %edx,%esi
  8021df:	72 67                	jb     802248 <__umoddi3+0x114>
  8021e1:	74 75                	je     802258 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021e3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021e7:	29 e8                	sub    %ebp,%eax
  8021e9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021eb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021ef:	d3 e8                	shr    %cl,%eax
  8021f1:	89 f2                	mov    %esi,%edx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021f7:	09 d0                	or     %edx,%eax
  8021f9:	89 f2                	mov    %esi,%edx
  8021fb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021ff:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802201:	83 c4 20             	add    $0x20,%esp
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802208:	85 c9                	test   %ecx,%ecx
  80220a:	75 0b                	jne    802217 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80220c:	b8 01 00 00 00       	mov    $0x1,%eax
  802211:	31 d2                	xor    %edx,%edx
  802213:	f7 f1                	div    %ecx
  802215:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802217:	89 f0                	mov    %esi,%eax
  802219:	31 d2                	xor    %edx,%edx
  80221b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80221d:	89 f8                	mov    %edi,%eax
  80221f:	e9 3e ff ff ff       	jmp    802162 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802224:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802226:	83 c4 20             	add    $0x20,%esp
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802230:	39 f5                	cmp    %esi,%ebp
  802232:	72 04                	jb     802238 <__umoddi3+0x104>
  802234:	39 f9                	cmp    %edi,%ecx
  802236:	77 06                	ja     80223e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802238:	89 f2                	mov    %esi,%edx
  80223a:	29 cf                	sub    %ecx,%edi
  80223c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80223e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802240:	83 c4 20             	add    $0x20,%esp
  802243:	5e                   	pop    %esi
  802244:	5f                   	pop    %edi
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    
  802247:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802248:	89 d1                	mov    %edx,%ecx
  80224a:	89 c5                	mov    %eax,%ebp
  80224c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802250:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802254:	eb 8d                	jmp    8021e3 <__umoddi3+0xaf>
  802256:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802258:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80225c:	72 ea                	jb     802248 <__umoddi3+0x114>
  80225e:	89 f1                	mov    %esi,%ecx
  802260:	eb 81                	jmp    8021e3 <__umoddi3+0xaf>
