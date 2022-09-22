
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 9f 09 00 00       	call   8009d0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800043:	85 db                	test   %ebx,%ebx
  800045:	75 1e                	jne    800065 <_gettoken+0x31>
		if (debug > 1)
  800047:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80004e:	0f 8e 19 01 00 00    	jle    80016d <_gettoken+0x139>
			cprintf("GETTOKEN NULL\n");
  800054:	c7 04 24 80 37 80 00 	movl   $0x803780,(%esp)
  80005b:	e8 dc 0a 00 00       	call   800b3c <cprintf>
  800060:	e9 1b 01 00 00       	jmp    800180 <_gettoken+0x14c>
		return 0;
	}

	if (debug > 1)
  800065:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80006c:	7e 10                	jle    80007e <_gettoken+0x4a>
		cprintf("GETTOKEN: %s\n", s);
  80006e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800072:	c7 04 24 8f 37 80 00 	movl   $0x80378f,(%esp)
  800079:	e8 be 0a 00 00       	call   800b3c <cprintf>

	*p1 = 0;
  80007e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800084:	8b 45 10             	mov    0x10(%ebp),%eax
  800087:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80008d:	eb 04                	jmp    800093 <_gettoken+0x5f>
		*s++ = 0;
  80008f:	c6 03 00             	movb   $0x0,(%ebx)
  800092:	43                   	inc    %ebx
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  800093:	0f be 03             	movsbl (%ebx),%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 9d 37 80 00 	movl   $0x80379d,(%esp)
  8000a1:	e8 1b 12 00 00       	call   8012c1 <strchr>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 e5                	jne    80008f <_gettoken+0x5b>
  8000aa:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000ac:	8a 03                	mov    (%ebx),%al
  8000ae:	84 c0                	test   %al,%al
  8000b0:	75 23                	jne    8000d5 <_gettoken+0xa1>
		if (debug > 1)
  8000b2:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000b9:	0f 8e b5 00 00 00    	jle    800174 <_gettoken+0x140>
			cprintf("EOL\n");
  8000bf:	c7 04 24 a2 37 80 00 	movl   $0x8037a2,(%esp)
  8000c6:	e8 71 0a 00 00       	call   800b3c <cprintf>
		return 0;
  8000cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000d0:	e9 ab 00 00 00       	jmp    800180 <_gettoken+0x14c>
	}
	if (strchr(SYMBOLS, *s)) {
  8000d5:	0f be c0             	movsbl %al,%eax
  8000d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000dc:	c7 04 24 b3 37 80 00 	movl   $0x8037b3,(%esp)
  8000e3:	e8 d9 11 00 00       	call   8012c1 <strchr>
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	74 29                	je     800115 <_gettoken+0xe1>
		t = *s;
  8000ec:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  8000ef:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  8000f1:	c6 06 00             	movb   $0x0,(%esi)
  8000f4:	46                   	inc    %esi
  8000f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8000f8:	89 32                	mov    %esi,(%edx)
		*p2 = s;
		if (debug > 1)
  8000fa:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800101:	7e 7d                	jle    800180 <_gettoken+0x14c>
			cprintf("TOK %c\n", t);
  800103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800107:	c7 04 24 a7 37 80 00 	movl   $0x8037a7,(%esp)
  80010e:	e8 29 0a 00 00       	call   800b3c <cprintf>
  800113:	eb 6b                	jmp    800180 <_gettoken+0x14c>
		return t;
	}
	*p1 = s;
  800115:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800117:	eb 01                	jmp    80011a <_gettoken+0xe6>
		s++;
  800119:	43                   	inc    %ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80011a:	8a 03                	mov    (%ebx),%al
  80011c:	84 c0                	test   %al,%al
  80011e:	74 17                	je     800137 <_gettoken+0x103>
  800120:	0f be c0             	movsbl %al,%eax
  800123:	89 44 24 04          	mov    %eax,0x4(%esp)
  800127:	c7 04 24 af 37 80 00 	movl   $0x8037af,(%esp)
  80012e:	e8 8e 11 00 00       	call   8012c1 <strchr>
  800133:	85 c0                	test   %eax,%eax
  800135:	74 e2                	je     800119 <_gettoken+0xe5>
		s++;
	*p2 = s;
  800137:	8b 45 10             	mov    0x10(%ebp),%eax
  80013a:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  80013c:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800143:	7e 36                	jle    80017b <_gettoken+0x147>
		t = **p2;
  800145:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800148:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80014b:	8b 07                	mov    (%edi),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 bb 37 80 00 	movl   $0x8037bb,(%esp)
  800158:	e8 df 09 00 00       	call   800b3c <cprintf>
		**p2 = t;
  80015d:	8b 55 10             	mov    0x10(%ebp),%edx
  800160:	8b 02                	mov    (%edx),%eax
  800162:	89 f2                	mov    %esi,%edx
  800164:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800166:	bb 77 00 00 00       	mov    $0x77,%ebx
  80016b:	eb 13                	jmp    800180 <_gettoken+0x14c>
	int t;

	if (s == 0) {
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  80016d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800172:	eb 0c                	jmp    800180 <_gettoken+0x14c>
	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  800174:	bb 00 00 00 00       	mov    $0x0,%ebx
  800179:	eb 05                	jmp    800180 <_gettoken+0x14c>
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  80017b:	bb 77 00 00 00       	mov    $0x77,%ebx
}
  800180:	89 d8                	mov    %ebx,%eax
  800182:	83 c4 1c             	add    $0x1c,%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <gettoken>:

int
gettoken(char *s, char **p1)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 18             	sub    $0x18,%esp
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  800193:	85 c0                	test   %eax,%eax
  800195:	74 24                	je     8001bb <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  800197:	c7 44 24 08 08 50 80 	movl   $0x805008,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 04 50 80 	movl   $0x805004,0x4(%esp)
  8001a6:	00 
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <_gettoken>
  8001af:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	eb 3c                	jmp    8001f7 <gettoken+0x6d>
	}
	c = nc;
  8001bb:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8001c0:	a3 10 50 80 00       	mov    %eax,0x805010
	*p1 = np1;
  8001c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c8:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8001ce:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d0:	c7 44 24 08 08 50 80 	movl   $0x805008,0x8(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 04 04 50 80 	movl   $0x805004,0x4(%esp)
  8001df:	00 
  8001e0:	a1 08 50 80 00       	mov    0x805008,%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 47 fe ff ff       	call   800034 <_gettoken>
  8001ed:	a3 0c 50 80 00       	mov    %eax,0x80500c
	return c;
  8001f2:	a1 10 50 80 00       	mov    0x805010,%eax
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	57                   	push   %edi
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800205:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020c:	00 
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 72 ff ff ff       	call   80018a <gettoken>

again:
	argc = 0;
  800218:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80021d:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80022b:	e8 5a ff ff ff       	call   80018a <gettoken>
  800230:	83 f8 77             	cmp    $0x77,%eax
  800233:	74 2e                	je     800263 <runcmd+0x6a>
  800235:	83 f8 77             	cmp    $0x77,%eax
  800238:	7f 1b                	jg     800255 <runcmd+0x5c>
  80023a:	83 f8 3c             	cmp    $0x3c,%eax
  80023d:	74 44                	je     800283 <runcmd+0x8a>
  80023f:	83 f8 3e             	cmp    $0x3e,%eax
  800242:	0f 84 b2 00 00 00    	je     8002fa <runcmd+0x101>
  800248:	85 c0                	test   %eax,%eax
  80024a:	0f 84 38 02 00 00    	je     800488 <runcmd+0x28f>
  800250:	e9 13 02 00 00       	jmp    800468 <runcmd+0x26f>
  800255:	83 f8 7c             	cmp    $0x7c,%eax
  800258:	0f 85 0a 02 00 00    	jne    800468 <runcmd+0x26f>
  80025e:	e9 18 01 00 00       	jmp    80037b <runcmd+0x182>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800263:	83 fe 10             	cmp    $0x10,%esi
  800266:	75 11                	jne    800279 <runcmd+0x80>
				cprintf("too many arguments\n");
  800268:	c7 04 24 c5 37 80 00 	movl   $0x8037c5,(%esp)
  80026f:	e8 c8 08 00 00       	call   800b3c <cprintf>
				exit();
  800274:	e8 af 07 00 00       	call   800a28 <exit>
			}
			argv[argc++] = t;
  800279:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80027c:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  800280:	46                   	inc    %esi
			break;
  800281:	eb 9d                	jmp    800220 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800283:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800287:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80028e:	e8 f7 fe ff ff       	call   80018a <gettoken>
  800293:	83 f8 77             	cmp    $0x77,%eax
  800296:	74 11                	je     8002a9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  800298:	c7 04 24 10 39 80 00 	movl   $0x803910,(%esp)
  80029f:	e8 98 08 00 00       	call   800b3c <cprintf>
				exit();
  8002a4:	e8 7f 07 00 00       	call   800a28 <exit>
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t,O_RDONLY))<0){
  8002a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002b0:	00 
  8002b1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 5b 24 00 00       	call   802717 <open>
  8002bc:	89 c7                	mov    %eax,%edi
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	79 13                	jns    8002d5 <runcmd+0xdc>
				cprintf("fd open error");
  8002c2:	c7 04 24 d9 37 80 00 	movl   $0x8037d9,(%esp)
  8002c9:	e8 6e 08 00 00       	call   800b3c <cprintf>
				exit();
  8002ce:	e8 55 07 00 00       	call   800a28 <exit>
  8002d3:	eb 08                	jmp    8002dd <runcmd+0xe4>
			}
			if (fd){
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	0f 84 43 ff ff ff    	je     800220 <runcmd+0x27>
				dup(fd,0);
  8002dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002e4:	00 
  8002e5:	89 3c 24             	mov    %edi,(%esp)
  8002e8:	e8 e0 1d 00 00       	call   8020cd <dup>
				close(fd);
  8002ed:	89 3c 24             	mov    %edi,(%esp)
  8002f0:	e8 87 1d 00 00       	call   80207c <close>
  8002f5:	e9 26 ff ff ff       	jmp    800220 <runcmd+0x27>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800305:	e8 80 fe ff ff       	call   80018a <gettoken>
  80030a:	83 f8 77             	cmp    $0x77,%eax
  80030d:	74 11                	je     800320 <runcmd+0x127>
				cprintf("syntax error: > not followed by word\n");
  80030f:	c7 04 24 38 39 80 00 	movl   $0x803938,(%esp)
  800316:	e8 21 08 00 00       	call   800b3c <cprintf>
				exit();
  80031b:	e8 08 07 00 00       	call   800a28 <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800320:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800327:	00 
  800328:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	e8 e4 23 00 00       	call   802717 <open>
  800333:	89 c7                	mov    %eax,%edi
  800335:	85 c0                	test   %eax,%eax
  800337:	79 1c                	jns    800355 <runcmd+0x15c>
				cprintf("open %s for write: %e", t, fd);
  800339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800340:	89 44 24 04          	mov    %eax,0x4(%esp)
  800344:	c7 04 24 e7 37 80 00 	movl   $0x8037e7,(%esp)
  80034b:	e8 ec 07 00 00       	call   800b3c <cprintf>
				exit();
  800350:	e8 d3 06 00 00       	call   800a28 <exit>
			}
			if (fd != 1) {
  800355:	83 ff 01             	cmp    $0x1,%edi
  800358:	0f 84 c2 fe ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 1);
  80035e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800365:	00 
  800366:	89 3c 24             	mov    %edi,(%esp)
  800369:	e8 5f 1d 00 00       	call   8020cd <dup>
				close(fd);
  80036e:	89 3c 24             	mov    %edi,(%esp)
  800371:	e8 06 1d 00 00       	call   80207c <close>
  800376:	e9 a5 fe ff ff       	jmp    800220 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80037b:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	e8 7c 2d 00 00       	call   803105 <pipe>
  800389:	85 c0                	test   %eax,%eax
  80038b:	79 15                	jns    8003a2 <runcmd+0x1a9>
				cprintf("pipe: %e", r);
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	c7 04 24 fd 37 80 00 	movl   $0x8037fd,(%esp)
  800398:	e8 9f 07 00 00       	call   800b3c <cprintf>
				exit();
  80039d:	e8 86 06 00 00       	call   800a28 <exit>
			}
			if (debug)
  8003a2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003a9:	74 20                	je     8003cb <runcmd+0x1d2>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003ab:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b5:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bf:	c7 04 24 06 38 80 00 	movl   $0x803806,(%esp)
  8003c6:	e8 71 07 00 00       	call   800b3c <cprintf>
			if ((r = fork()) < 0) {
  8003cb:	e8 8c 16 00 00       	call   801a5c <fork>
  8003d0:	89 c7                	mov    %eax,%edi
  8003d2:	85 c0                	test   %eax,%eax
  8003d4:	79 15                	jns    8003eb <runcmd+0x1f2>
				cprintf("fork: %e", r);
  8003d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003da:	c7 04 24 13 38 80 00 	movl   $0x803813,(%esp)
  8003e1:	e8 56 07 00 00       	call   800b3c <cprintf>
				exit();
  8003e6:	e8 3d 06 00 00       	call   800a28 <exit>
			}
			if (r == 0) {
  8003eb:	85 ff                	test   %edi,%edi
  8003ed:	75 40                	jne    80042f <runcmd+0x236>
				if (p[0] != 0) {
  8003ef:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	74 1e                	je     800417 <runcmd+0x21e>
					dup(p[0], 0);
  8003f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800400:	00 
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	e8 c4 1c 00 00       	call   8020cd <dup>
					close(p[0]);
  800409:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	e8 65 1c 00 00       	call   80207c <close>
				}
				close(p[1]);
  800417:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80041d:	89 04 24             	mov    %eax,(%esp)
  800420:	e8 57 1c 00 00       	call   80207c <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800425:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  80042a:	e9 f1 fd ff ff       	jmp    800220 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80042f:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800435:	83 f8 01             	cmp    $0x1,%eax
  800438:	74 1e                	je     800458 <runcmd+0x25f>
					dup(p[1], 1);
  80043a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800441:	00 
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	e8 83 1c 00 00       	call   8020cd <dup>
					close(p[1]);
  80044a:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	e8 24 1c 00 00       	call   80207c <close>
				}
				close(p[0]);
  800458:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80045e:	89 04 24             	mov    %eax,(%esp)
  800461:	e8 16 1c 00 00       	call   80207c <close>
				goto runit;
  800466:	eb 25                	jmp    80048d <runcmd+0x294>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 1c 38 80 	movl   $0x80381c,0x8(%esp)
  800473:	00 
  800474:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  80047b:	00 
  80047c:	c7 04 24 38 38 80 00 	movl   $0x803838,(%esp)
  800483:	e8 bc 05 00 00       	call   800a44 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800488:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048d:	85 f6                	test   %esi,%esi
  80048f:	75 1e                	jne    8004af <runcmd+0x2b6>
		if (debug)
  800491:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800498:	0f 84 80 01 00 00    	je     80061e <runcmd+0x425>
			cprintf("EMPTY COMMAND\n");
  80049e:	c7 04 24 42 38 80 00 	movl   $0x803842,(%esp)
  8004a5:	e8 92 06 00 00       	call   800b3c <cprintf>
  8004aa:	e9 6f 01 00 00       	jmp    80061e <runcmd+0x425>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004af:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b2:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004b5:	74 22                	je     8004d9 <runcmd+0x2e0>
		argv0buf[0] = '/';
  8004b7:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c2:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004c8:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004ce:	89 04 24             	mov    %eax,(%esp)
  8004d1:	e8 f1 0c 00 00       	call   8011c7 <strcpy>
		argv[0] = argv0buf;
  8004d6:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  8004d9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e0:	00 

	// Print the command.
	if (debug) {
  8004e1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004e8:	74 45                	je     80052f <runcmd+0x336>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004ea:	a1 24 54 80 00       	mov    0x805424,%eax
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	8b 40 48             	mov    0x48(%eax),%eax
  8004f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f8:	c7 04 24 51 38 80 00 	movl   $0x803851,(%esp)
  8004ff:	e8 38 06 00 00       	call   800b3c <cprintf>
  800504:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800507:	eb 10                	jmp    800519 <runcmd+0x320>
			cprintf(" %s", argv[i]);
  800509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050d:	c7 04 24 dc 38 80 00 	movl   $0x8038dc,(%esp)
  800514:	e8 23 06 00 00       	call   800b3c <cprintf>
  800519:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  80051c:	8b 43 fc             	mov    -0x4(%ebx),%eax
  80051f:	85 c0                	test   %eax,%eax
  800521:	75 e6                	jne    800509 <runcmd+0x310>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800523:	c7 04 24 a0 37 80 00 	movl   $0x8037a0,(%esp)
  80052a:	e8 0d 06 00 00       	call   800b3c <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80052f:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	e8 af 23 00 00       	call   8028f0 <spawn>
  800541:	89 c3                	mov    %eax,%ebx
  800543:	85 c0                	test   %eax,%eax
  800545:	79 1e                	jns    800565 <runcmd+0x36c>
		cprintf("spawn %s: %e\n", argv[0], r);
  800547:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80054e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800552:	c7 04 24 5f 38 80 00 	movl   $0x80385f,(%esp)
  800559:	e8 de 05 00 00       	call   800b3c <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80055e:	e8 4a 1b 00 00       	call   8020ad <close_all>
  800563:	eb 5e                	jmp    8005c3 <runcmd+0x3ca>
  800565:	e8 43 1b 00 00       	call   8020ad <close_all>
	if (r >= 0) {
		if (debug)
  80056a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800571:	74 25                	je     800598 <runcmd+0x39f>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800573:	a1 24 54 80 00       	mov    0x805424,%eax
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	8b 40 48             	mov    0x48(%eax),%eax
  80057d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800581:	8b 55 a8             	mov    -0x58(%ebp),%edx
  800584:	89 54 24 08          	mov    %edx,0x8(%esp)
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	c7 04 24 6d 38 80 00 	movl   $0x80386d,(%esp)
  800593:	e8 a4 05 00 00       	call   800b3c <cprintf>
		wait(r);
  800598:	89 1c 24             	mov    %ebx,(%esp)
  80059b:	e8 08 2d 00 00       	call   8032a8 <wait>
		if (debug)
  8005a0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005a7:	74 1a                	je     8005c3 <runcmd+0x3ca>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	8b 40 48             	mov    0x48(%eax),%eax
  8005b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b7:	c7 04 24 82 38 80 00 	movl   $0x803882,(%esp)
  8005be:	e8 79 05 00 00       	call   800b3c <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	74 52                	je     800619 <runcmd+0x420>
		if (debug)
  8005c7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005ce:	74 1e                	je     8005ee <runcmd+0x3f5>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005d0:	a1 24 54 80 00       	mov    0x805424,%eax
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	8b 40 48             	mov    0x48(%eax),%eax
  8005da:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e2:	c7 04 24 98 38 80 00 	movl   $0x803898,(%esp)
  8005e9:	e8 4e 05 00 00       	call   800b3c <cprintf>
		wait(pipe_child);
  8005ee:	89 3c 24             	mov    %edi,(%esp)
  8005f1:	e8 b2 2c 00 00       	call   8032a8 <wait>
		if (debug)
  8005f6:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005fd:	74 1a                	je     800619 <runcmd+0x420>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005ff:	a1 24 54 80 00       	mov    0x805424,%eax
  800604:	8b 00                	mov    (%eax),%eax
  800606:	8b 40 48             	mov    0x48(%eax),%eax
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	c7 04 24 82 38 80 00 	movl   $0x803882,(%esp)
  800614:	e8 23 05 00 00       	call   800b3c <cprintf>
	}

	// Done!
	exit();
  800619:	e8 0a 04 00 00       	call   800a28 <exit>
}
  80061e:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  800624:	5b                   	pop    %ebx
  800625:	5e                   	pop    %esi
  800626:	5f                   	pop    %edi
  800627:	5d                   	pop    %ebp
  800628:	c3                   	ret    

00800629 <usage>:
}


void
usage(void)
{
  800629:	55                   	push   %ebp
  80062a:	89 e5                	mov    %esp,%ebp
  80062c:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80062f:	c7 04 24 60 39 80 00 	movl   $0x803960,(%esp)
  800636:	e8 01 05 00 00       	call   800b3c <cprintf>
	exit();
  80063b:	e8 e8 03 00 00       	call   800a28 <exit>
}
  800640:	c9                   	leave  
  800641:	c3                   	ret    

00800642 <umain>:

void
umain(int argc, char **argv)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	57                   	push   %edi
  800646:	56                   	push   %esi
  800647:	53                   	push   %ebx
  800648:	83 ec 4c             	sub    $0x4c,%esp
  80064b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80064e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800651:	89 44 24 08          	mov    %eax,0x8(%esp)
  800655:	89 74 24 04          	mov    %esi,0x4(%esp)
  800659:	8d 45 08             	lea    0x8(%ebp),%eax
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	e8 08 17 00 00       	call   801d6c <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800664:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80066b:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800670:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800673:	eb 2e                	jmp    8006a3 <umain+0x61>
		switch (r) {
  800675:	83 f8 69             	cmp    $0x69,%eax
  800678:	74 0c                	je     800686 <umain+0x44>
  80067a:	83 f8 78             	cmp    $0x78,%eax
  80067d:	74 1d                	je     80069c <umain+0x5a>
  80067f:	83 f8 64             	cmp    $0x64,%eax
  800682:	75 11                	jne    800695 <umain+0x53>
  800684:	eb 07                	jmp    80068d <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800686:	bf 01 00 00 00       	mov    $0x1,%edi
  80068b:	eb 16                	jmp    8006a3 <umain+0x61>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80068d:	ff 05 00 50 80 00    	incl   0x805000
			break;
  800693:	eb 0e                	jmp    8006a3 <umain+0x61>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800695:	e8 8f ff ff ff       	call   800629 <usage>
  80069a:	eb 07                	jmp    8006a3 <umain+0x61>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  80069c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006a3:	89 1c 24             	mov    %ebx,(%esp)
  8006a6:	e8 fa 16 00 00       	call   801da5 <argnext>
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	79 c6                	jns    800675 <umain+0x33>
  8006af:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006b1:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006b5:	7e 05                	jle    8006bc <umain+0x7a>
		usage();
  8006b7:	e8 6d ff ff ff       	call   800629 <usage>
	if (argc == 2) {
  8006bc:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c0:	75 72                	jne    800734 <umain+0xf2>
		close(0);
  8006c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c9:	e8 ae 19 00 00       	call   80207c <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8006d5:	00 
  8006d6:	8b 46 04             	mov    0x4(%esi),%eax
  8006d9:	89 04 24             	mov    %eax,(%esp)
  8006dc:	e8 36 20 00 00       	call   802717 <open>
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	79 27                	jns    80070c <umain+0xca>
			panic("open %s: %e", argv[1], r);
  8006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006e9:	8b 46 04             	mov    0x4(%esi),%eax
  8006ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f0:	c7 44 24 08 b8 38 80 	movl   $0x8038b8,0x8(%esp)
  8006f7:	00 
  8006f8:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  8006ff:	00 
  800700:	c7 04 24 38 38 80 00 	movl   $0x803838,(%esp)
  800707:	e8 38 03 00 00       	call   800a44 <_panic>
		assert(r == 0);
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 24                	je     800734 <umain+0xf2>
  800710:	c7 44 24 0c c4 38 80 	movl   $0x8038c4,0xc(%esp)
  800717:	00 
  800718:	c7 44 24 08 cb 38 80 	movl   $0x8038cb,0x8(%esp)
  80071f:	00 
  800720:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  800727:	00 
  800728:	c7 04 24 38 38 80 00 	movl   $0x803838,(%esp)
  80072f:	e8 10 03 00 00       	call   800a44 <_panic>
	}
	if (interactive == '?')
  800734:	83 fb 3f             	cmp    $0x3f,%ebx
  800737:	75 0e                	jne    800747 <umain+0x105>
		interactive = iscons(0);
  800739:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800740:	e8 08 02 00 00       	call   80094d <iscons>
  800745:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800747:	85 ff                	test   %edi,%edi
  800749:	74 07                	je     800752 <umain+0x110>
  80074b:	b8 b5 38 80 00       	mov    $0x8038b5,%eax
  800750:	eb 05                	jmp    800757 <umain+0x115>
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	89 04 24             	mov    %eax,(%esp)
  80075a:	e8 55 09 00 00       	call   8010b4 <readline>
  80075f:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800761:	85 c0                	test   %eax,%eax
  800763:	75 1a                	jne    80077f <umain+0x13d>
			if (debug)
  800765:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80076c:	74 0c                	je     80077a <umain+0x138>
				cprintf("EXITING\n");
  80076e:	c7 04 24 e0 38 80 00 	movl   $0x8038e0,(%esp)
  800775:	e8 c2 03 00 00       	call   800b3c <cprintf>
			exit();	// end of file
  80077a:	e8 a9 02 00 00       	call   800a28 <exit>
		}
		if (debug)
  80077f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800786:	74 10                	je     800798 <umain+0x156>
			cprintf("LINE: %s\n", buf);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	c7 04 24 e9 38 80 00 	movl   $0x8038e9,(%esp)
  800793:	e8 a4 03 00 00       	call   800b3c <cprintf>
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 aa                	je     800747 <umain+0x105>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 10                	je     8007b3 <umain+0x171>
			printf("# %s\n", buf);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	c7 04 24 f3 38 80 00 	movl   $0x8038f3,(%esp)
  8007ae:	e8 1a 21 00 00       	call   8028cd <printf>
		if (debug)
  8007b3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007ba:	74 0c                	je     8007c8 <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007bc:	c7 04 24 f9 38 80 00 	movl   $0x8038f9,(%esp)
  8007c3:	e8 74 03 00 00       	call   800b3c <cprintf>
		if ((r = fork()) < 0)
  8007c8:	e8 8f 12 00 00       	call   801a5c <fork>
  8007cd:	89 c6                	mov    %eax,%esi
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	79 20                	jns    8007f3 <umain+0x1b1>
			panic("fork: %e", r);
  8007d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d7:	c7 44 24 08 13 38 80 	movl   $0x803813,0x8(%esp)
  8007de:	00 
  8007df:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  8007e6:	00 
  8007e7:	c7 04 24 38 38 80 00 	movl   $0x803838,(%esp)
  8007ee:	e8 51 02 00 00       	call   800a44 <_panic>
		if (debug)
  8007f3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007fa:	74 10                	je     80080c <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800800:	c7 04 24 06 39 80 00 	movl   $0x803906,(%esp)
  800807:	e8 30 03 00 00       	call   800b3c <cprintf>
		if (r == 0) {
  80080c:	85 f6                	test   %esi,%esi
  80080e:	75 12                	jne    800822 <umain+0x1e0>
			runcmd(buf);
  800810:	89 1c 24             	mov    %ebx,(%esp)
  800813:	e8 e1 f9 ff ff       	call   8001f9 <runcmd>
			exit();
  800818:	e8 0b 02 00 00       	call   800a28 <exit>
  80081d:	e9 25 ff ff ff       	jmp    800747 <umain+0x105>
		} else
			wait(r);
  800822:	89 34 24             	mov    %esi,(%esp)
  800825:	e8 7e 2a 00 00       	call   8032a8 <wait>
  80082a:	e9 18 ff ff ff       	jmp    800747 <umain+0x105>
	...

00800830 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800840:	c7 44 24 04 81 39 80 	movl   $0x803981,0x4(%esp)
  800847:	00 
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 74 09 00 00       	call   8011c7 <strcpy>
	return 0;
}
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	57                   	push   %edi
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800866:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80086b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800871:	eb 30                	jmp    8008a3 <devcons_write+0x49>
		m = n - tot;
  800873:	8b 75 10             	mov    0x10(%ebp),%esi
  800876:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800878:	83 fe 7f             	cmp    $0x7f,%esi
  80087b:	76 05                	jbe    800882 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80087d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800882:	89 74 24 08          	mov    %esi,0x8(%esp)
  800886:	03 45 0c             	add    0xc(%ebp),%eax
  800889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088d:	89 3c 24             	mov    %edi,(%esp)
  800890:	e8 ab 0a 00 00       	call   801340 <memmove>
		sys_cputs(buf, m);
  800895:	89 74 24 04          	mov    %esi,0x4(%esp)
  800899:	89 3c 24             	mov    %edi,(%esp)
  80089c:	e8 4b 0c 00 00       	call   8014ec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008a1:	01 f3                	add    %esi,%ebx
  8008a3:	89 d8                	mov    %ebx,%eax
  8008a5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8008a8:	72 c9                	jb     800873 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008aa:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5f                   	pop    %edi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8008bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008bf:	75 07                	jne    8008c8 <devcons_read+0x13>
  8008c1:	eb 25                	jmp    8008e8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008c3:	e8 d2 0c 00 00       	call   80159a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c8:	e8 3d 0c 00 00       	call   80150a <sys_cgetc>
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	74 f2                	je     8008c3 <devcons_read+0xe>
  8008d1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	78 1d                	js     8008f4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d7:	83 f8 04             	cmp    $0x4,%eax
  8008da:	74 13                	je     8008ef <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	88 10                	mov    %dl,(%eax)
	return 1;
  8008e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e6:	eb 0c                	jmp    8008f4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ed:	eb 05                	jmp    8008f4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800902:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800909:	00 
  80090a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	e8 d7 0b 00 00       	call   8014ec <sys_cputs>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <getchar>:

int
getchar(void)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80091d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800924:	00 
  800925:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800933:	e8 a8 18 00 00       	call   8021e0 <read>
	if (r < 0)
  800938:	85 c0                	test   %eax,%eax
  80093a:	78 0f                	js     80094b <getchar+0x34>
		return r;
	if (r < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	7e 06                	jle    800946 <getchar+0x2f>
		return -E_EOF;
	return c;
  800940:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800944:	eb 05                	jmp    80094b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800946:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 dd 15 00 00       	call   801f42 <fd_lookup>
  800965:	85 c0                	test   %eax,%eax
  800967:	78 11                	js     80097a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800972:	39 10                	cmp    %edx,(%eax)
  800974:	0f 94 c0             	sete   %al
  800977:	0f b6 c0             	movzbl %al,%eax
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <opencons>:

int
opencons(void)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 62 15 00 00       	call   801eef <fd_alloc>
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 3c                	js     8009cd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800991:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800998:	00 
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009a7:	e8 0d 0c 00 00       	call   8015b9 <sys_page_alloc>
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	78 1d                	js     8009cd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009b0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	e8 f7 14 00 00       	call   801ec4 <fd2num>
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    
	...

008009d0 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 20             	sub    $0x20,%esp
  8009d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8009de:	e8 98 0b 00 00       	call   80157b <sys_getenvid>
  8009e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009ef:	c1 e0 07             	shl    $0x7,%eax
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8009fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ff:	a3 24 54 80 00       	mov    %eax,0x805424
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a04:	85 f6                	test   %esi,%esi
  800a06:	7e 07                	jle    800a0f <libmain+0x3f>
		binaryname = argv[0];
  800a08:	8b 03                	mov    (%ebx),%eax
  800a0a:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a13:	89 34 24             	mov    %esi,(%esp)
  800a16:	e8 27 fc ff ff       	call   800642 <umain>

	// exit gracefully
	exit();
  800a1b:	e8 08 00 00 00       	call   800a28 <exit>
}
  800a20:	83 c4 20             	add    $0x20,%esp
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    
	...

00800a28 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800a2e:	e8 7a 16 00 00       	call   8020ad <close_all>
	sys_env_destroy(0);
  800a33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a3a:	e8 ea 0a 00 00       	call   801529 <sys_env_destroy>
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    
  800a41:	00 00                	add    %al,(%eax)
	...

00800a44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a4c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a4f:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  800a55:	e8 21 0b 00 00       	call   80157b <sys_getenvid>
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a61:	8b 55 08             	mov    0x8(%ebp),%edx
  800a64:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	c7 04 24 98 39 80 00 	movl   $0x803998,(%esp)
  800a77:	e8 c0 00 00 00       	call   800b3c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a80:	8b 45 10             	mov    0x10(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 50 00 00 00       	call   800adb <vcprintf>
	cprintf("\n");
  800a8b:	c7 04 24 a0 37 80 00 	movl   $0x8037a0,(%esp)
  800a92:	e8 a5 00 00 00       	call   800b3c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a97:	cc                   	int3   
  800a98:	eb fd                	jmp    800a97 <_panic+0x53>
	...

00800a9c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 14             	sub    $0x14,%esp
  800aa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800aa6:	8b 03                	mov    (%ebx),%eax
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800aaf:	40                   	inc    %eax
  800ab0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800ab2:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ab7:	75 19                	jne    800ad2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800ab9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800ac0:	00 
  800ac1:	8d 43 08             	lea    0x8(%ebx),%eax
  800ac4:	89 04 24             	mov    %eax,(%esp)
  800ac7:	e8 20 0a 00 00       	call   8014ec <sys_cputs>
		b->idx = 0;
  800acc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800ad2:	ff 43 04             	incl   0x4(%ebx)
}
  800ad5:	83 c4 14             	add    $0x14,%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800ae4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aeb:	00 00 00 
	b.cnt = 0;
  800aee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800af5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b06:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	c7 04 24 9c 0a 80 00 	movl   $0x800a9c,(%esp)
  800b17:	e8 82 01 00 00       	call   800c9e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b1c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b26:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	e8 b8 09 00 00       	call   8014ec <sys_cputs>

	return b.cnt;
}
  800b34:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b42:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	89 04 24             	mov    %eax,(%esp)
  800b4f:	e8 87 ff ff ff       	call   800adb <vcprintf>
	va_end(ap);

	return cnt;
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    
	...

00800b58 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 3c             	sub    $0x3c,%esp
  800b61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b64:	89 d7                	mov    %edx,%edi
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b72:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b75:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	75 08                	jne    800b84 <printnum+0x2c>
  800b7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b7f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b82:	77 57                	ja     800bdb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b84:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b88:	4b                   	dec    %ebx
  800b89:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b94:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b98:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ba3:	00 
  800ba4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ba7:	89 04 24             	mov    %eax,(%esp)
  800baa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb1:	e8 72 29 00 00       	call   803528 <__udivdi3>
  800bb6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bbe:	89 04 24             	mov    %eax,(%esp)
  800bc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc5:	89 fa                	mov    %edi,%edx
  800bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bca:	e8 89 ff ff ff       	call   800b58 <printnum>
  800bcf:	eb 0f                	jmp    800be0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bd1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd5:	89 34 24             	mov    %esi,(%esp)
  800bd8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bdb:	4b                   	dec    %ebx
  800bdc:	85 db                	test   %ebx,%ebx
  800bde:	7f f1                	jg     800bd1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800be0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800be8:	8b 45 10             	mov    0x10(%ebp),%eax
  800beb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800bf6:	00 
  800bf7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bfa:	89 04 24             	mov    %eax,(%esp)
  800bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c04:	e8 3f 2a 00 00       	call   803648 <__umoddi3>
  800c09:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c0d:	0f be 80 bb 39 80 00 	movsbl 0x8039bb(%eax),%eax
  800c14:	89 04 24             	mov    %eax,(%esp)
  800c17:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800c1a:	83 c4 3c             	add    $0x3c,%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c25:	83 fa 01             	cmp    $0x1,%edx
  800c28:	7e 0e                	jle    800c38 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c2a:	8b 10                	mov    (%eax),%edx
  800c2c:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c2f:	89 08                	mov    %ecx,(%eax)
  800c31:	8b 02                	mov    (%edx),%eax
  800c33:	8b 52 04             	mov    0x4(%edx),%edx
  800c36:	eb 22                	jmp    800c5a <getuint+0x38>
	else if (lflag)
  800c38:	85 d2                	test   %edx,%edx
  800c3a:	74 10                	je     800c4c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c3c:	8b 10                	mov    (%eax),%edx
  800c3e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c41:	89 08                	mov    %ecx,(%eax)
  800c43:	8b 02                	mov    (%edx),%eax
  800c45:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4a:	eb 0e                	jmp    800c5a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c4c:	8b 10                	mov    (%eax),%edx
  800c4e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c51:	89 08                	mov    %ecx,(%eax)
  800c53:	8b 02                	mov    (%edx),%eax
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c62:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c65:	8b 10                	mov    (%eax),%edx
  800c67:	3b 50 04             	cmp    0x4(%eax),%edx
  800c6a:	73 08                	jae    800c74 <sprintputch+0x18>
		*b->buf++ = ch;
  800c6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6f:	88 0a                	mov    %cl,(%edx)
  800c71:	42                   	inc    %edx
  800c72:	89 10                	mov    %edx,(%eax)
}
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c7c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c83:	8b 45 10             	mov    0x10(%ebp),%eax
  800c86:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	89 04 24             	mov    %eax,(%esp)
  800c97:	e8 02 00 00 00       	call   800c9e <vprintfmt>
	va_end(ap);
}
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 4c             	sub    $0x4c,%esp
  800ca7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800caa:	8b 75 10             	mov    0x10(%ebp),%esi
  800cad:	eb 12                	jmp    800cc1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	0f 84 6b 03 00 00    	je     801022 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800cb7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cbb:	89 04 24             	mov    %eax,(%esp)
  800cbe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800cc1:	0f b6 06             	movzbl (%esi),%eax
  800cc4:	46                   	inc    %esi
  800cc5:	83 f8 25             	cmp    $0x25,%eax
  800cc8:	75 e5                	jne    800caf <vprintfmt+0x11>
  800cca:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800cce:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800cd5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800cda:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ce1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce6:	eb 26                	jmp    800d0e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800ceb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800cef:	eb 1d                	jmp    800d0e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cf4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800cf8:	eb 14                	jmp    800d0e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cfa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cfd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800d04:	eb 08                	jmp    800d0e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800d06:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800d09:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0e:	0f b6 06             	movzbl (%esi),%eax
  800d11:	8d 56 01             	lea    0x1(%esi),%edx
  800d14:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d17:	8a 16                	mov    (%esi),%dl
  800d19:	83 ea 23             	sub    $0x23,%edx
  800d1c:	80 fa 55             	cmp    $0x55,%dl
  800d1f:	0f 87 e1 02 00 00    	ja     801006 <vprintfmt+0x368>
  800d25:	0f b6 d2             	movzbl %dl,%edx
  800d28:	ff 24 95 00 3b 80 00 	jmp    *0x803b00(,%edx,4)
  800d2f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d32:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d37:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800d3a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800d3e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d41:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d44:	83 fa 09             	cmp    $0x9,%edx
  800d47:	77 2a                	ja     800d73 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d49:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d4a:	eb eb                	jmp    800d37 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4f:	8d 50 04             	lea    0x4(%eax),%edx
  800d52:	89 55 14             	mov    %edx,0x14(%ebp)
  800d55:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d57:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d5a:	eb 17                	jmp    800d73 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800d5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d60:	78 98                	js     800cfa <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d62:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d65:	eb a7                	jmp    800d0e <vprintfmt+0x70>
  800d67:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d6a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d71:	eb 9b                	jmp    800d0e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d77:	79 95                	jns    800d0e <vprintfmt+0x70>
  800d79:	eb 8b                	jmp    800d06 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d7b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d7c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d7f:	eb 8d                	jmp    800d0e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d81:	8b 45 14             	mov    0x14(%ebp),%eax
  800d84:	8d 50 04             	lea    0x4(%eax),%edx
  800d87:	89 55 14             	mov    %edx,0x14(%ebp)
  800d8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d8e:	8b 00                	mov    (%eax),%eax
  800d90:	89 04 24             	mov    %eax,(%esp)
  800d93:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d96:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d99:	e9 23 ff ff ff       	jmp    800cc1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800da1:	8d 50 04             	lea    0x4(%eax),%edx
  800da4:	89 55 14             	mov    %edx,0x14(%ebp)
  800da7:	8b 00                	mov    (%eax),%eax
  800da9:	85 c0                	test   %eax,%eax
  800dab:	79 02                	jns    800daf <vprintfmt+0x111>
  800dad:	f7 d8                	neg    %eax
  800daf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800db1:	83 f8 0f             	cmp    $0xf,%eax
  800db4:	7f 0b                	jg     800dc1 <vprintfmt+0x123>
  800db6:	8b 04 85 60 3c 80 00 	mov    0x803c60(,%eax,4),%eax
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	75 23                	jne    800de4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc5:	c7 44 24 08 d3 39 80 	movl   $0x8039d3,0x8(%esp)
  800dcc:	00 
  800dcd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd4:	89 04 24             	mov    %eax,(%esp)
  800dd7:	e8 9a fe ff ff       	call   800c76 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ddc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ddf:	e9 dd fe ff ff       	jmp    800cc1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800de8:	c7 44 24 08 dd 38 80 	movl   $0x8038dd,0x8(%esp)
  800def:	00 
  800df0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 14 24             	mov    %edx,(%esp)
  800dfa:	e8 77 fe ff ff       	call   800c76 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800e02:	e9 ba fe ff ff       	jmp    800cc1 <vprintfmt+0x23>
  800e07:	89 f9                	mov    %edi,%ecx
  800e09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e0c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e12:	8d 50 04             	lea    0x4(%eax),%edx
  800e15:	89 55 14             	mov    %edx,0x14(%ebp)
  800e18:	8b 30                	mov    (%eax),%esi
  800e1a:	85 f6                	test   %esi,%esi
  800e1c:	75 05                	jne    800e23 <vprintfmt+0x185>
				p = "(null)";
  800e1e:	be cc 39 80 00       	mov    $0x8039cc,%esi
			if (width > 0 && padc != '-')
  800e23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e27:	0f 8e 84 00 00 00    	jle    800eb1 <vprintfmt+0x213>
  800e2d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800e31:	74 7e                	je     800eb1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e37:	89 34 24             	mov    %esi,(%esp)
  800e3a:	e8 6b 03 00 00       	call   8011aa <strnlen>
  800e3f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e42:	29 c2                	sub    %eax,%edx
  800e44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800e47:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e4b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800e4e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800e51:	89 de                	mov    %ebx,%esi
  800e53:	89 d3                	mov    %edx,%ebx
  800e55:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e57:	eb 0b                	jmp    800e64 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800e59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5d:	89 3c 24             	mov    %edi,(%esp)
  800e60:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e63:	4b                   	dec    %ebx
  800e64:	85 db                	test   %ebx,%ebx
  800e66:	7f f1                	jg     800e59 <vprintfmt+0x1bb>
  800e68:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e6b:	89 f3                	mov    %esi,%ebx
  800e6d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e73:	85 c0                	test   %eax,%eax
  800e75:	79 05                	jns    800e7c <vprintfmt+0x1de>
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e7f:	29 c2                	sub    %eax,%edx
  800e81:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e84:	eb 2b                	jmp    800eb1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e86:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e8a:	74 18                	je     800ea4 <vprintfmt+0x206>
  800e8c:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e8f:	83 fa 5e             	cmp    $0x5e,%edx
  800e92:	76 10                	jbe    800ea4 <vprintfmt+0x206>
					putch('?', putdat);
  800e94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e98:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e9f:	ff 55 08             	call   *0x8(%ebp)
  800ea2:	eb 0a                	jmp    800eae <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800ea4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800eae:	ff 4d e4             	decl   -0x1c(%ebp)
  800eb1:	0f be 06             	movsbl (%esi),%eax
  800eb4:	46                   	inc    %esi
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	74 21                	je     800eda <vprintfmt+0x23c>
  800eb9:	85 ff                	test   %edi,%edi
  800ebb:	78 c9                	js     800e86 <vprintfmt+0x1e8>
  800ebd:	4f                   	dec    %edi
  800ebe:	79 c6                	jns    800e86 <vprintfmt+0x1e8>
  800ec0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec3:	89 de                	mov    %ebx,%esi
  800ec5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ec8:	eb 18                	jmp    800ee2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800eca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ece:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ed5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ed7:	4b                   	dec    %ebx
  800ed8:	eb 08                	jmp    800ee2 <vprintfmt+0x244>
  800eda:	8b 7d 08             	mov    0x8(%ebp),%edi
  800edd:	89 de                	mov    %ebx,%esi
  800edf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ee2:	85 db                	test   %ebx,%ebx
  800ee4:	7f e4                	jg     800eca <vprintfmt+0x22c>
  800ee6:	89 7d 08             	mov    %edi,0x8(%ebp)
  800ee9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800eeb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eee:	e9 ce fd ff ff       	jmp    800cc1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ef3:	83 f9 01             	cmp    $0x1,%ecx
  800ef6:	7e 10                	jle    800f08 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800ef8:	8b 45 14             	mov    0x14(%ebp),%eax
  800efb:	8d 50 08             	lea    0x8(%eax),%edx
  800efe:	89 55 14             	mov    %edx,0x14(%ebp)
  800f01:	8b 30                	mov    (%eax),%esi
  800f03:	8b 78 04             	mov    0x4(%eax),%edi
  800f06:	eb 26                	jmp    800f2e <vprintfmt+0x290>
	else if (lflag)
  800f08:	85 c9                	test   %ecx,%ecx
  800f0a:	74 12                	je     800f1e <vprintfmt+0x280>
		return va_arg(*ap, long);
  800f0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0f:	8d 50 04             	lea    0x4(%eax),%edx
  800f12:	89 55 14             	mov    %edx,0x14(%ebp)
  800f15:	8b 30                	mov    (%eax),%esi
  800f17:	89 f7                	mov    %esi,%edi
  800f19:	c1 ff 1f             	sar    $0x1f,%edi
  800f1c:	eb 10                	jmp    800f2e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800f1e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f21:	8d 50 04             	lea    0x4(%eax),%edx
  800f24:	89 55 14             	mov    %edx,0x14(%ebp)
  800f27:	8b 30                	mov    (%eax),%esi
  800f29:	89 f7                	mov    %esi,%edi
  800f2b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f2e:	85 ff                	test   %edi,%edi
  800f30:	78 0a                	js     800f3c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f37:	e9 8c 00 00 00       	jmp    800fc8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800f3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f40:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f47:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f4a:	f7 de                	neg    %esi
  800f4c:	83 d7 00             	adc    $0x0,%edi
  800f4f:	f7 df                	neg    %edi
			}
			base = 10;
  800f51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f56:	eb 70                	jmp    800fc8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f58:	89 ca                	mov    %ecx,%edx
  800f5a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f5d:	e8 c0 fc ff ff       	call   800c22 <getuint>
  800f62:	89 c6                	mov    %eax,%esi
  800f64:	89 d7                	mov    %edx,%edi
			base = 10;
  800f66:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f6b:	eb 5b                	jmp    800fc8 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800f6d:	89 ca                	mov    %ecx,%edx
  800f6f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f72:	e8 ab fc ff ff       	call   800c22 <getuint>
  800f77:	89 c6                	mov    %eax,%esi
  800f79:	89 d7                	mov    %edx,%edi
			base = 8;
  800f7b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f80:	eb 46                	jmp    800fc8 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800f82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f86:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f8d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f94:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f9b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa1:	8d 50 04             	lea    0x4(%eax),%edx
  800fa4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800fa7:	8b 30                	mov    (%eax),%esi
  800fa9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800fae:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800fb3:	eb 13                	jmp    800fc8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800fb5:	89 ca                	mov    %ecx,%edx
  800fb7:	8d 45 14             	lea    0x14(%ebp),%eax
  800fba:	e8 63 fc ff ff       	call   800c22 <getuint>
  800fbf:	89 c6                	mov    %eax,%esi
  800fc1:	89 d7                	mov    %edx,%edi
			base = 16;
  800fc3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fc8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800fcc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fd0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fdb:	89 34 24             	mov    %esi,(%esp)
  800fde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fe2:	89 da                	mov    %ebx,%edx
  800fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe7:	e8 6c fb ff ff       	call   800b58 <printnum>
			break;
  800fec:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fef:	e9 cd fc ff ff       	jmp    800cc1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ff4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ff8:	89 04 24             	mov    %eax,(%esp)
  800ffb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ffe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801001:	e9 bb fc ff ff       	jmp    800cc1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801006:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80100a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801011:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801014:	eb 01                	jmp    801017 <vprintfmt+0x379>
  801016:	4e                   	dec    %esi
  801017:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80101b:	75 f9                	jne    801016 <vprintfmt+0x378>
  80101d:	e9 9f fc ff ff       	jmp    800cc1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801022:	83 c4 4c             	add    $0x4c,%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 28             	sub    $0x28,%esp
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801036:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801039:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80103d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801040:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801047:	85 c0                	test   %eax,%eax
  801049:	74 30                	je     80107b <vsnprintf+0x51>
  80104b:	85 d2                	test   %edx,%edx
  80104d:	7e 33                	jle    801082 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80104f:	8b 45 14             	mov    0x14(%ebp),%eax
  801052:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801056:	8b 45 10             	mov    0x10(%ebp),%eax
  801059:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801060:	89 44 24 04          	mov    %eax,0x4(%esp)
  801064:	c7 04 24 5c 0c 80 00 	movl   $0x800c5c,(%esp)
  80106b:	e8 2e fc ff ff       	call   800c9e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801070:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801073:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801076:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801079:	eb 0c                	jmp    801087 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80107b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801080:	eb 05                	jmp    801087 <vsnprintf+0x5d>
  801082:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80108f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801092:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801096:	8b 45 10             	mov    0x10(%ebp),%eax
  801099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80109d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	89 04 24             	mov    %eax,(%esp)
  8010aa:	e8 7b ff ff ff       	call   80102a <vsnprintf>
	va_end(ap);

	return rc;
}
  8010af:	c9                   	leave  
  8010b0:	c3                   	ret    
  8010b1:	00 00                	add    %al,(%eax)
	...

008010b4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 1c             	sub    $0x1c,%esp
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	74 18                	je     8010dc <readline+0x28>
		fprintf(1, "%s", prompt);
  8010c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c8:	c7 44 24 04 dd 38 80 	movl   $0x8038dd,0x4(%esp)
  8010cf:	00 
  8010d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010d7:	e8 d0 17 00 00       	call   8028ac <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8010dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e3:	e8 65 f8 ff ff       	call   80094d <iscons>
  8010e8:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010ea:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010ef:	e8 23 f8 ff ff       	call   800917 <getchar>
  8010f4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 20                	jns    80111a <readline+0x66>
			if (c != -E_EOF)
  8010fa:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010fd:	0f 84 82 00 00 00    	je     801185 <readline+0xd1>
				cprintf("read error: %e\n", c);
  801103:	89 44 24 04          	mov    %eax,0x4(%esp)
  801107:	c7 04 24 bf 3c 80 00 	movl   $0x803cbf,(%esp)
  80110e:	e8 29 fa ff ff       	call   800b3c <cprintf>
			return NULL;
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	eb 70                	jmp    80118a <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80111a:	83 f8 08             	cmp    $0x8,%eax
  80111d:	74 05                	je     801124 <readline+0x70>
  80111f:	83 f8 7f             	cmp    $0x7f,%eax
  801122:	75 17                	jne    80113b <readline+0x87>
  801124:	85 f6                	test   %esi,%esi
  801126:	7e 13                	jle    80113b <readline+0x87>
			if (echoing)
  801128:	85 ff                	test   %edi,%edi
  80112a:	74 0c                	je     801138 <readline+0x84>
				cputchar('\b');
  80112c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801133:	e8 be f7 ff ff       	call   8008f6 <cputchar>
			i--;
  801138:	4e                   	dec    %esi
  801139:	eb b4                	jmp    8010ef <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80113b:	83 fb 1f             	cmp    $0x1f,%ebx
  80113e:	7e 1d                	jle    80115d <readline+0xa9>
  801140:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801146:	7f 15                	jg     80115d <readline+0xa9>
			if (echoing)
  801148:	85 ff                	test   %edi,%edi
  80114a:	74 08                	je     801154 <readline+0xa0>
				cputchar(c);
  80114c:	89 1c 24             	mov    %ebx,(%esp)
  80114f:	e8 a2 f7 ff ff       	call   8008f6 <cputchar>
			buf[i++] = c;
  801154:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  80115a:	46                   	inc    %esi
  80115b:	eb 92                	jmp    8010ef <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  80115d:	83 fb 0a             	cmp    $0xa,%ebx
  801160:	74 05                	je     801167 <readline+0xb3>
  801162:	83 fb 0d             	cmp    $0xd,%ebx
  801165:	75 88                	jne    8010ef <readline+0x3b>
			if (echoing)
  801167:	85 ff                	test   %edi,%edi
  801169:	74 0c                	je     801177 <readline+0xc3>
				cputchar('\n');
  80116b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801172:	e8 7f f7 ff ff       	call   8008f6 <cputchar>
			buf[i] = 0;
  801177:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80117e:	b8 20 50 80 00       	mov    $0x805020,%eax
  801183:	eb 05                	jmp    80118a <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80118a:	83 c4 1c             	add    $0x1c,%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    
	...

00801194 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
  80119f:	eb 01                	jmp    8011a2 <strlen+0xe>
		n++;
  8011a1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011a6:	75 f9                	jne    8011a1 <strlen+0xd>
		n++;
	return n;
}
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8011b0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	eb 01                	jmp    8011bb <strnlen+0x11>
		n++;
  8011ba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011bb:	39 d0                	cmp    %edx,%eax
  8011bd:	74 06                	je     8011c5 <strnlen+0x1b>
  8011bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011c3:	75 f5                	jne    8011ba <strnlen+0x10>
		n++;
	return n;
}
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	53                   	push   %ebx
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011d9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011dc:	42                   	inc    %edx
  8011dd:	84 c9                	test   %cl,%cl
  8011df:	75 f5                	jne    8011d6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011e1:	5b                   	pop    %ebx
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ee:	89 1c 24             	mov    %ebx,(%esp)
  8011f1:	e8 9e ff ff ff       	call   801194 <strlen>
	strcpy(dst + len, src);
  8011f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011fd:	01 d8                	add    %ebx,%eax
  8011ff:	89 04 24             	mov    %eax,(%esp)
  801202:	e8 c0 ff ff ff       	call   8011c7 <strcpy>
	return dst;
}
  801207:	89 d8                	mov    %ebx,%eax
  801209:	83 c4 08             	add    $0x8,%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	8b 45 08             	mov    0x8(%ebp),%eax
  801217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80121d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801222:	eb 0c                	jmp    801230 <strncpy+0x21>
		*dst++ = *src;
  801224:	8a 1a                	mov    (%edx),%bl
  801226:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801229:	80 3a 01             	cmpb   $0x1,(%edx)
  80122c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80122f:	41                   	inc    %ecx
  801230:	39 f1                	cmp    %esi,%ecx
  801232:	75 f0                	jne    801224 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	8b 75 08             	mov    0x8(%ebp),%esi
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801246:	85 d2                	test   %edx,%edx
  801248:	75 0a                	jne    801254 <strlcpy+0x1c>
  80124a:	89 f0                	mov    %esi,%eax
  80124c:	eb 1a                	jmp    801268 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80124e:	88 18                	mov    %bl,(%eax)
  801250:	40                   	inc    %eax
  801251:	41                   	inc    %ecx
  801252:	eb 02                	jmp    801256 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801254:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801256:	4a                   	dec    %edx
  801257:	74 0a                	je     801263 <strlcpy+0x2b>
  801259:	8a 19                	mov    (%ecx),%bl
  80125b:	84 db                	test   %bl,%bl
  80125d:	75 ef                	jne    80124e <strlcpy+0x16>
  80125f:	89 c2                	mov    %eax,%edx
  801261:	eb 02                	jmp    801265 <strlcpy+0x2d>
  801263:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801265:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801268:	29 f0                	sub    %esi,%eax
}
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801274:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801277:	eb 02                	jmp    80127b <strcmp+0xd>
		p++, q++;
  801279:	41                   	inc    %ecx
  80127a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80127b:	8a 01                	mov    (%ecx),%al
  80127d:	84 c0                	test   %al,%al
  80127f:	74 04                	je     801285 <strcmp+0x17>
  801281:	3a 02                	cmp    (%edx),%al
  801283:	74 f4                	je     801279 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801285:	0f b6 c0             	movzbl %al,%eax
  801288:	0f b6 12             	movzbl (%edx),%edx
  80128b:	29 d0                	sub    %edx,%eax
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	53                   	push   %ebx
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
  801296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801299:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80129c:	eb 03                	jmp    8012a1 <strncmp+0x12>
		n--, p++, q++;
  80129e:	4a                   	dec    %edx
  80129f:	40                   	inc    %eax
  8012a0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012a1:	85 d2                	test   %edx,%edx
  8012a3:	74 14                	je     8012b9 <strncmp+0x2a>
  8012a5:	8a 18                	mov    (%eax),%bl
  8012a7:	84 db                	test   %bl,%bl
  8012a9:	74 04                	je     8012af <strncmp+0x20>
  8012ab:	3a 19                	cmp    (%ecx),%bl
  8012ad:	74 ef                	je     80129e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012af:	0f b6 00             	movzbl (%eax),%eax
  8012b2:	0f b6 11             	movzbl (%ecx),%edx
  8012b5:	29 d0                	sub    %edx,%eax
  8012b7:	eb 05                	jmp    8012be <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012be:	5b                   	pop    %ebx
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    

008012c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012ca:	eb 05                	jmp    8012d1 <strchr+0x10>
		if (*s == c)
  8012cc:	38 ca                	cmp    %cl,%dl
  8012ce:	74 0c                	je     8012dc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012d0:	40                   	inc    %eax
  8012d1:	8a 10                	mov    (%eax),%dl
  8012d3:	84 d2                	test   %dl,%dl
  8012d5:	75 f5                	jne    8012cc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8012d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012e7:	eb 05                	jmp    8012ee <strfind+0x10>
		if (*s == c)
  8012e9:	38 ca                	cmp    %cl,%dl
  8012eb:	74 07                	je     8012f4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012ed:	40                   	inc    %eax
  8012ee:	8a 10                	mov    (%eax),%dl
  8012f0:	84 d2                	test   %dl,%dl
  8012f2:	75 f5                	jne    8012e9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801302:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801305:	85 c9                	test   %ecx,%ecx
  801307:	74 30                	je     801339 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801309:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80130f:	75 25                	jne    801336 <memset+0x40>
  801311:	f6 c1 03             	test   $0x3,%cl
  801314:	75 20                	jne    801336 <memset+0x40>
		c &= 0xFF;
  801316:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801319:	89 d3                	mov    %edx,%ebx
  80131b:	c1 e3 08             	shl    $0x8,%ebx
  80131e:	89 d6                	mov    %edx,%esi
  801320:	c1 e6 18             	shl    $0x18,%esi
  801323:	89 d0                	mov    %edx,%eax
  801325:	c1 e0 10             	shl    $0x10,%eax
  801328:	09 f0                	or     %esi,%eax
  80132a:	09 d0                	or     %edx,%eax
  80132c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80132e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801331:	fc                   	cld    
  801332:	f3 ab                	rep stos %eax,%es:(%edi)
  801334:	eb 03                	jmp    801339 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801336:	fc                   	cld    
  801337:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801339:	89 f8                	mov    %edi,%eax
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	8b 75 0c             	mov    0xc(%ebp),%esi
  80134b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80134e:	39 c6                	cmp    %eax,%esi
  801350:	73 34                	jae    801386 <memmove+0x46>
  801352:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801355:	39 d0                	cmp    %edx,%eax
  801357:	73 2d                	jae    801386 <memmove+0x46>
		s += n;
		d += n;
  801359:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80135c:	f6 c2 03             	test   $0x3,%dl
  80135f:	75 1b                	jne    80137c <memmove+0x3c>
  801361:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801367:	75 13                	jne    80137c <memmove+0x3c>
  801369:	f6 c1 03             	test   $0x3,%cl
  80136c:	75 0e                	jne    80137c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80136e:	83 ef 04             	sub    $0x4,%edi
  801371:	8d 72 fc             	lea    -0x4(%edx),%esi
  801374:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801377:	fd                   	std    
  801378:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80137a:	eb 07                	jmp    801383 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80137c:	4f                   	dec    %edi
  80137d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801380:	fd                   	std    
  801381:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801383:	fc                   	cld    
  801384:	eb 20                	jmp    8013a6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801386:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80138c:	75 13                	jne    8013a1 <memmove+0x61>
  80138e:	a8 03                	test   $0x3,%al
  801390:	75 0f                	jne    8013a1 <memmove+0x61>
  801392:	f6 c1 03             	test   $0x3,%cl
  801395:	75 0a                	jne    8013a1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801397:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80139a:	89 c7                	mov    %eax,%edi
  80139c:	fc                   	cld    
  80139d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80139f:	eb 05                	jmp    8013a6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013a1:	89 c7                	mov    %eax,%edi
  8013a3:	fc                   	cld    
  8013a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013a6:	5e                   	pop    %esi
  8013a7:	5f                   	pop    %edi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8013b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013be:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 77 ff ff ff       	call   801340 <memmove>
}
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013da:	ba 00 00 00 00       	mov    $0x0,%edx
  8013df:	eb 16                	jmp    8013f7 <memcmp+0x2c>
		if (*s1 != *s2)
  8013e1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8013e4:	42                   	inc    %edx
  8013e5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8013e9:	38 c8                	cmp    %cl,%al
  8013eb:	74 0a                	je     8013f7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8013ed:	0f b6 c0             	movzbl %al,%eax
  8013f0:	0f b6 c9             	movzbl %cl,%ecx
  8013f3:	29 c8                	sub    %ecx,%eax
  8013f5:	eb 09                	jmp    801400 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013f7:	39 da                	cmp    %ebx,%edx
  8013f9:	75 e6                	jne    8013e1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80140e:	89 c2                	mov    %eax,%edx
  801410:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801413:	eb 05                	jmp    80141a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801415:	38 08                	cmp    %cl,(%eax)
  801417:	74 05                	je     80141e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801419:	40                   	inc    %eax
  80141a:	39 d0                	cmp    %edx,%eax
  80141c:	72 f7                	jb     801415 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	57                   	push   %edi
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
  801426:	8b 55 08             	mov    0x8(%ebp),%edx
  801429:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80142c:	eb 01                	jmp    80142f <strtol+0xf>
		s++;
  80142e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80142f:	8a 02                	mov    (%edx),%al
  801431:	3c 20                	cmp    $0x20,%al
  801433:	74 f9                	je     80142e <strtol+0xe>
  801435:	3c 09                	cmp    $0x9,%al
  801437:	74 f5                	je     80142e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801439:	3c 2b                	cmp    $0x2b,%al
  80143b:	75 08                	jne    801445 <strtol+0x25>
		s++;
  80143d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80143e:	bf 00 00 00 00       	mov    $0x0,%edi
  801443:	eb 13                	jmp    801458 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801445:	3c 2d                	cmp    $0x2d,%al
  801447:	75 0a                	jne    801453 <strtol+0x33>
		s++, neg = 1;
  801449:	8d 52 01             	lea    0x1(%edx),%edx
  80144c:	bf 01 00 00 00       	mov    $0x1,%edi
  801451:	eb 05                	jmp    801458 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801453:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801458:	85 db                	test   %ebx,%ebx
  80145a:	74 05                	je     801461 <strtol+0x41>
  80145c:	83 fb 10             	cmp    $0x10,%ebx
  80145f:	75 28                	jne    801489 <strtol+0x69>
  801461:	8a 02                	mov    (%edx),%al
  801463:	3c 30                	cmp    $0x30,%al
  801465:	75 10                	jne    801477 <strtol+0x57>
  801467:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80146b:	75 0a                	jne    801477 <strtol+0x57>
		s += 2, base = 16;
  80146d:	83 c2 02             	add    $0x2,%edx
  801470:	bb 10 00 00 00       	mov    $0x10,%ebx
  801475:	eb 12                	jmp    801489 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801477:	85 db                	test   %ebx,%ebx
  801479:	75 0e                	jne    801489 <strtol+0x69>
  80147b:	3c 30                	cmp    $0x30,%al
  80147d:	75 05                	jne    801484 <strtol+0x64>
		s++, base = 8;
  80147f:	42                   	inc    %edx
  801480:	b3 08                	mov    $0x8,%bl
  801482:	eb 05                	jmp    801489 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801484:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801489:	b8 00 00 00 00       	mov    $0x0,%eax
  80148e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801490:	8a 0a                	mov    (%edx),%cl
  801492:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801495:	80 fb 09             	cmp    $0x9,%bl
  801498:	77 08                	ja     8014a2 <strtol+0x82>
			dig = *s - '0';
  80149a:	0f be c9             	movsbl %cl,%ecx
  80149d:	83 e9 30             	sub    $0x30,%ecx
  8014a0:	eb 1e                	jmp    8014c0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8014a2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8014a5:	80 fb 19             	cmp    $0x19,%bl
  8014a8:	77 08                	ja     8014b2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8014aa:	0f be c9             	movsbl %cl,%ecx
  8014ad:	83 e9 57             	sub    $0x57,%ecx
  8014b0:	eb 0e                	jmp    8014c0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8014b2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8014b5:	80 fb 19             	cmp    $0x19,%bl
  8014b8:	77 12                	ja     8014cc <strtol+0xac>
			dig = *s - 'A' + 10;
  8014ba:	0f be c9             	movsbl %cl,%ecx
  8014bd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014c0:	39 f1                	cmp    %esi,%ecx
  8014c2:	7d 0c                	jge    8014d0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8014c4:	42                   	inc    %edx
  8014c5:	0f af c6             	imul   %esi,%eax
  8014c8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8014ca:	eb c4                	jmp    801490 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014cc:	89 c1                	mov    %eax,%ecx
  8014ce:	eb 02                	jmp    8014d2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014d0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014d6:	74 05                	je     8014dd <strtol+0xbd>
		*endptr = (char *) s;
  8014d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014db:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8014dd:	85 ff                	test   %edi,%edi
  8014df:	74 04                	je     8014e5 <strtol+0xc5>
  8014e1:	89 c8                	mov    %ecx,%eax
  8014e3:	f7 d8                	neg    %eax
}
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    
	...

008014ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	57                   	push   %edi
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fd:	89 c3                	mov    %eax,%ebx
  8014ff:	89 c7                	mov    %eax,%edi
  801501:	89 c6                	mov    %eax,%esi
  801503:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5f                   	pop    %edi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <sys_cgetc>:

int
sys_cgetc(void)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	57                   	push   %edi
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801510:	ba 00 00 00 00       	mov    $0x0,%edx
  801515:	b8 01 00 00 00       	mov    $0x1,%eax
  80151a:	89 d1                	mov    %edx,%ecx
  80151c:	89 d3                	mov    %edx,%ebx
  80151e:	89 d7                	mov    %edx,%edi
  801520:	89 d6                	mov    %edx,%esi
  801522:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801524:	5b                   	pop    %ebx
  801525:	5e                   	pop    %esi
  801526:	5f                   	pop    %edi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    

00801529 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	57                   	push   %edi
  80152d:	56                   	push   %esi
  80152e:	53                   	push   %ebx
  80152f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801532:	b9 00 00 00 00       	mov    $0x0,%ecx
  801537:	b8 03 00 00 00       	mov    $0x3,%eax
  80153c:	8b 55 08             	mov    0x8(%ebp),%edx
  80153f:	89 cb                	mov    %ecx,%ebx
  801541:	89 cf                	mov    %ecx,%edi
  801543:	89 ce                	mov    %ecx,%esi
  801545:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801547:	85 c0                	test   %eax,%eax
  801549:	7e 28                	jle    801573 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80154b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80154f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801556:	00 
  801557:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  80155e:	00 
  80155f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801566:	00 
  801567:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  80156e:	e8 d1 f4 ff ff       	call   800a44 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801573:	83 c4 2c             	add    $0x2c,%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	57                   	push   %edi
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801581:	ba 00 00 00 00       	mov    $0x0,%edx
  801586:	b8 02 00 00 00       	mov    $0x2,%eax
  80158b:	89 d1                	mov    %edx,%ecx
  80158d:	89 d3                	mov    %edx,%ebx
  80158f:	89 d7                	mov    %edx,%edi
  801591:	89 d6                	mov    %edx,%esi
  801593:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5f                   	pop    %edi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <sys_yield>:

void
sys_yield(void)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015aa:	89 d1                	mov    %edx,%ecx
  8015ac:	89 d3                	mov    %edx,%ebx
  8015ae:	89 d7                	mov    %edx,%edi
  8015b0:	89 d6                	mov    %edx,%esi
  8015b2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5f                   	pop    %edi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015c2:	be 00 00 00 00       	mov    $0x0,%esi
  8015c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8015cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d5:	89 f7                	mov    %esi,%edi
  8015d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	7e 28                	jle    801605 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8015e8:	00 
  8015e9:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  8015f0:	00 
  8015f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015f8:	00 
  8015f9:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  801600:	e8 3f f4 ff ff       	call   800a44 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801605:	83 c4 2c             	add    $0x2c,%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    

0080160d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	57                   	push   %edi
  801611:	56                   	push   %esi
  801612:	53                   	push   %ebx
  801613:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801616:	b8 05 00 00 00       	mov    $0x5,%eax
  80161b:	8b 75 18             	mov    0x18(%ebp),%esi
  80161e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801621:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801627:	8b 55 08             	mov    0x8(%ebp),%edx
  80162a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80162c:	85 c0                	test   %eax,%eax
  80162e:	7e 28                	jle    801658 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801630:	89 44 24 10          	mov    %eax,0x10(%esp)
  801634:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80163b:	00 
  80163c:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  801643:	00 
  801644:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80164b:	00 
  80164c:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  801653:	e8 ec f3 ff ff       	call   800a44 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801658:	83 c4 2c             	add    $0x2c,%esp
  80165b:	5b                   	pop    %ebx
  80165c:	5e                   	pop    %esi
  80165d:	5f                   	pop    %edi
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	57                   	push   %edi
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801669:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166e:	b8 06 00 00 00       	mov    $0x6,%eax
  801673:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801676:	8b 55 08             	mov    0x8(%ebp),%edx
  801679:	89 df                	mov    %ebx,%edi
  80167b:	89 de                	mov    %ebx,%esi
  80167d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80167f:	85 c0                	test   %eax,%eax
  801681:	7e 28                	jle    8016ab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801683:	89 44 24 10          	mov    %eax,0x10(%esp)
  801687:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80168e:	00 
  80168f:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  801696:	00 
  801697:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80169e:	00 
  80169f:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  8016a6:	e8 99 f3 ff ff       	call   800a44 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8016ab:	83 c4 2c             	add    $0x2c,%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5f                   	pop    %edi
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	57                   	push   %edi
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cc:	89 df                	mov    %ebx,%edi
  8016ce:	89 de                	mov    %ebx,%esi
  8016d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	7e 28                	jle    8016fe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016da:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8016e1:	00 
  8016e2:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  8016e9:	00 
  8016ea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016f1:	00 
  8016f2:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  8016f9:	e8 46 f3 ff ff       	call   800a44 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016fe:	83 c4 2c             	add    $0x2c,%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5f                   	pop    %edi
  801704:	5d                   	pop    %ebp
  801705:	c3                   	ret    

00801706 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	57                   	push   %edi
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80170f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801714:	b8 09 00 00 00       	mov    $0x9,%eax
  801719:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171c:	8b 55 08             	mov    0x8(%ebp),%edx
  80171f:	89 df                	mov    %ebx,%edi
  801721:	89 de                	mov    %ebx,%esi
  801723:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801725:	85 c0                	test   %eax,%eax
  801727:	7e 28                	jle    801751 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801729:	89 44 24 10          	mov    %eax,0x10(%esp)
  80172d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801734:	00 
  801735:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  80173c:	00 
  80173d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801744:	00 
  801745:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  80174c:	e8 f3 f2 ff ff       	call   800a44 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801751:	83 c4 2c             	add    $0x2c,%esp
  801754:	5b                   	pop    %ebx
  801755:	5e                   	pop    %esi
  801756:	5f                   	pop    %edi
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	57                   	push   %edi
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801762:	bb 00 00 00 00       	mov    $0x0,%ebx
  801767:	b8 0a 00 00 00       	mov    $0xa,%eax
  80176c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176f:	8b 55 08             	mov    0x8(%ebp),%edx
  801772:	89 df                	mov    %ebx,%edi
  801774:	89 de                	mov    %ebx,%esi
  801776:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801778:	85 c0                	test   %eax,%eax
  80177a:	7e 28                	jle    8017a4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80177c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801780:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801787:	00 
  801788:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  80178f:	00 
  801790:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801797:	00 
  801798:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  80179f:	e8 a0 f2 ff ff       	call   800a44 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8017a4:	83 c4 2c             	add    $0x2c,%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5f                   	pop    %edi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	57                   	push   %edi
  8017b0:	56                   	push   %esi
  8017b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017b2:	be 00 00 00 00       	mov    $0x0,%esi
  8017b7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5f                   	pop    %edi
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	57                   	push   %edi
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017dd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e5:	89 cb                	mov    %ecx,%ebx
  8017e7:	89 cf                	mov    %ecx,%edi
  8017e9:	89 ce                	mov    %ecx,%esi
  8017eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	7e 28                	jle    801819 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017f5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8017fc:	00 
  8017fd:	c7 44 24 08 cf 3c 80 	movl   $0x803ccf,0x8(%esp)
  801804:	00 
  801805:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80180c:	00 
  80180d:	c7 04 24 ec 3c 80 00 	movl   $0x803cec,(%esp)
  801814:	e8 2b f2 ff ff       	call   800a44 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801819:	83 c4 2c             	add    $0x2c,%esp
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5f                   	pop    %edi
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    
  801821:	00 00                	add    %al,(%eax)
	...

00801824 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	83 ec 3c             	sub    $0x3c,%esp
  80182d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  801830:	89 d6                	mov    %edx,%esi
  801832:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  801835:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80183c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  80183f:	e8 37 fd ff ff       	call   80157b <sys_getenvid>
  801844:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  801846:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  80184d:	74 31                	je     801880 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  80184f:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  801856:	00 
  801857:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80185b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80185e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801862:	89 74 24 04          	mov    %esi,0x4(%esp)
  801866:	89 3c 24             	mov    %edi,(%esp)
  801869:	e8 9f fd ff ff       	call   80160d <sys_page_map>
  80186e:	85 c0                	test   %eax,%eax
  801870:	0f 8e ae 00 00 00    	jle    801924 <duppage+0x100>
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
  80187b:	e9 a4 00 00 00       	jmp    801924 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  801880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801883:	25 02 08 00 00       	and    $0x802,%eax
  801888:	83 f8 01             	cmp    $0x1,%eax
  80188b:	19 db                	sbb    %ebx,%ebx
  80188d:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801893:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  801899:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80189d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018ac:	89 3c 24             	mov    %edi,(%esp)
  8018af:	e8 59 fd ff ff       	call   80160d <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	79 1c                	jns    8018d4 <duppage+0xb0>
  8018b8:	c7 44 24 08 fa 3c 80 	movl   $0x803cfa,0x8(%esp)
  8018bf:	00 
  8018c0:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8018c7:	00 
  8018c8:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  8018cf:	e8 70 f1 ff ff       	call   800a44 <_panic>
	if ((perm|~pte)&PTE_COW){
  8018d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018d7:	f7 d0                	not    %eax
  8018d9:	09 d8                	or     %ebx,%eax
  8018db:	f6 c4 08             	test   $0x8,%ah
  8018de:	74 38                	je     801918 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  8018e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8018e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018e8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f0:	89 3c 24             	mov    %edi,(%esp)
  8018f3:	e8 15 fd ff ff       	call   80160d <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	79 23                	jns    80191f <duppage+0xfb>
  8018fc:	c7 44 24 08 fa 3c 80 	movl   $0x803cfa,0x8(%esp)
  801903:	00 
  801904:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80190b:	00 
  80190c:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801913:	e8 2c f1 ff ff       	call   800a44 <_panic>
	}
	return 0;
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
  80191d:	eb 05                	jmp    801924 <duppage+0x100>
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  801924:	83 c4 3c             	add    $0x3c,%esp
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5f                   	pop    %edi
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 20             	sub    $0x20,%esp
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801937:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  801939:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80193d:	75 1c                	jne    80195b <pgfault+0x2f>
		panic("pgfault: error!\n");
  80193f:	c7 44 24 08 16 3d 80 	movl   $0x803d16,0x8(%esp)
  801946:	00 
  801947:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80194e:	00 
  80194f:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801956:	e8 e9 f0 ff ff       	call   800a44 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  80195b:	89 f0                	mov    %esi,%eax
  80195d:	c1 e8 0c             	shr    $0xc,%eax
  801960:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801967:	f6 c4 08             	test   $0x8,%ah
  80196a:	75 1c                	jne    801988 <pgfault+0x5c>
		panic("pgfault: error!\n");
  80196c:	c7 44 24 08 16 3d 80 	movl   $0x803d16,0x8(%esp)
  801973:	00 
  801974:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80197b:	00 
  80197c:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801983:	e8 bc f0 ff ff       	call   800a44 <_panic>
	envid_t envid = sys_getenvid();
  801988:	e8 ee fb ff ff       	call   80157b <sys_getenvid>
  80198d:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  80198f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801996:	00 
  801997:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80199e:	00 
  80199f:	89 04 24             	mov    %eax,(%esp)
  8019a2:	e8 12 fc ff ff       	call   8015b9 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	79 1c                	jns    8019c7 <pgfault+0x9b>
  8019ab:	c7 44 24 08 16 3d 80 	movl   $0x803d16,0x8(%esp)
  8019b2:	00 
  8019b3:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8019ba:	00 
  8019bb:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  8019c2:	e8 7d f0 ff ff       	call   800a44 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  8019c7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  8019cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8019d4:	00 
  8019d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8019e0:	e8 c5 f9 ff ff       	call   8013aa <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  8019e5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019ec:	00 
  8019ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8019fc:	00 
  8019fd:	89 1c 24             	mov    %ebx,(%esp)
  801a00:	e8 08 fc ff ff       	call   80160d <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801a05:	85 c0                	test   %eax,%eax
  801a07:	79 1c                	jns    801a25 <pgfault+0xf9>
  801a09:	c7 44 24 08 16 3d 80 	movl   $0x803d16,0x8(%esp)
  801a10:	00 
  801a11:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801a18:	00 
  801a19:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801a20:	e8 1f f0 ff ff       	call   800a44 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801a25:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801a2c:	00 
  801a2d:	89 1c 24             	mov    %ebx,(%esp)
  801a30:	e8 2b fc ff ff       	call   801660 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801a35:	85 c0                	test   %eax,%eax
  801a37:	79 1c                	jns    801a55 <pgfault+0x129>
  801a39:	c7 44 24 08 16 3d 80 	movl   $0x803d16,0x8(%esp)
  801a40:	00 
  801a41:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801a48:	00 
  801a49:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801a50:	e8 ef ef ff ff       	call   800a44 <_panic>
	return;
	panic("pgfault not implemented");
}
  801a55:	83 c4 20             	add    $0x20,%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	57                   	push   %edi
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801a65:	c7 04 24 2c 19 80 00 	movl   $0x80192c,(%esp)
  801a6c:	e8 a3 18 00 00       	call   803314 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801a71:	bf 07 00 00 00       	mov    $0x7,%edi
  801a76:	89 f8                	mov    %edi,%eax
  801a78:	cd 30                	int    $0x30
  801a7a:	89 c7                	mov    %eax,%edi
  801a7c:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	79 1c                	jns    801a9e <fork+0x42>
		panic("fork : error!\n");
  801a82:	c7 44 24 08 33 3d 80 	movl   $0x803d33,0x8(%esp)
  801a89:	00 
  801a8a:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  801a91:	00 
  801a92:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801a99:	e8 a6 ef ff ff       	call   800a44 <_panic>
	if (envid==0){
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	75 28                	jne    801aca <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801aa2:	8b 1d 24 54 80 00    	mov    0x805424,%ebx
  801aa8:	e8 ce fa ff ff       	call   80157b <sys_getenvid>
  801aad:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ab2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ab9:	c1 e0 07             	shl    $0x7,%eax
  801abc:	29 d0                	sub    %edx,%eax
  801abe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ac3:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  801ac5:	e9 f2 00 00 00       	jmp    801bbc <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801aca:	e8 ac fa ff ff       	call   80157b <sys_getenvid>
  801acf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801ad2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801ad7:	89 d8                	mov    %ebx,%eax
  801ad9:	c1 e8 16             	shr    $0x16,%eax
  801adc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ae3:	a8 01                	test   $0x1,%al
  801ae5:	74 17                	je     801afe <fork+0xa2>
  801ae7:	89 da                	mov    %ebx,%edx
  801ae9:	c1 ea 0c             	shr    $0xc,%edx
  801aec:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801af3:	a8 01                	test   $0x1,%al
  801af5:	74 07                	je     801afe <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801af7:	89 f0                	mov    %esi,%eax
  801af9:	e8 26 fd ff ff       	call   801824 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801afe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b04:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801b0a:	75 cb                	jne    801ad7 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801b0c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b13:	00 
  801b14:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801b1b:	ee 
  801b1c:	89 3c 24             	mov    %edi,(%esp)
  801b1f:	e8 95 fa ff ff       	call   8015b9 <sys_page_alloc>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	79 1c                	jns    801b44 <fork+0xe8>
  801b28:	c7 44 24 08 33 3d 80 	movl   $0x803d33,0x8(%esp)
  801b2f:	00 
  801b30:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b37:	00 
  801b38:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801b3f:	e8 00 ef ff ff       	call   800a44 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  801b44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b47:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b4c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b53:	c1 e0 07             	shl    $0x7,%eax
  801b56:	29 d0                	sub    %edx,%eax
  801b58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b5d:	8b 40 64             	mov    0x64(%eax),%eax
  801b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b64:	89 3c 24             	mov    %edi,(%esp)
  801b67:	e8 ed fb ff ff       	call   801759 <sys_env_set_pgfault_upcall>
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	79 1c                	jns    801b8c <fork+0x130>
  801b70:	c7 44 24 08 33 3d 80 	movl   $0x803d33,0x8(%esp)
  801b77:	00 
  801b78:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b7f:	00 
  801b80:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801b87:	e8 b8 ee ff ff       	call   800a44 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801b8c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801b93:	00 
  801b94:	89 3c 24             	mov    %edi,(%esp)
  801b97:	e8 17 fb ff ff       	call   8016b3 <sys_env_set_status>
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	79 1c                	jns    801bbc <fork+0x160>
  801ba0:	c7 44 24 08 33 3d 80 	movl   $0x803d33,0x8(%esp)
  801ba7:	00 
  801ba8:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801baf:	00 
  801bb0:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801bb7:	e8 88 ee ff ff       	call   800a44 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801bbc:	89 f8                	mov    %edi,%eax
  801bbe:	83 c4 2c             	add    $0x2c,%esp
  801bc1:	5b                   	pop    %ebx
  801bc2:	5e                   	pop    %esi
  801bc3:	5f                   	pop    %edi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <sfork>:

// Challenge!
int
sfork(void)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	57                   	push   %edi
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  801bcf:	c7 04 24 2c 19 80 00 	movl   $0x80192c,(%esp)
  801bd6:	e8 39 17 00 00       	call   803314 <set_pgfault_handler>
  801bdb:	ba 07 00 00 00       	mov    $0x7,%edx
  801be0:	89 d0                	mov    %edx,%eax
  801be2:	cd 30                	int    $0x30
  801be4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801be7:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bed:	c7 04 24 27 3d 80 00 	movl   $0x803d27,(%esp)
  801bf4:	e8 43 ef ff ff       	call   800b3c <cprintf>
	if (envid<0)
  801bf9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801bfd:	79 1c                	jns    801c1b <sfork+0x55>
		panic("sfork : error!\n");
  801bff:	c7 44 24 08 32 3d 80 	movl   $0x803d32,0x8(%esp)
  801c06:	00 
  801c07:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801c0e:	00 
  801c0f:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801c16:	e8 29 ee ff ff       	call   800a44 <_panic>
	if (envid==0){
  801c1b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801c1f:	75 28                	jne    801c49 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801c21:	8b 1d 24 54 80 00    	mov    0x805424,%ebx
  801c27:	e8 4f f9 ff ff       	call   80157b <sys_getenvid>
  801c2c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801c38:	c1 e0 07             	shl    $0x7,%eax
  801c3b:	29 d0                	sub    %edx,%eax
  801c3d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c42:	89 03                	mov    %eax,(%ebx)
		return envid;
  801c44:	e9 18 01 00 00       	jmp    801d61 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801c49:	e8 2d f9 ff ff       	call   80157b <sys_getenvid>
  801c4e:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801c50:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801c55:	89 d8                	mov    %ebx,%eax
  801c57:	c1 e8 16             	shr    $0x16,%eax
  801c5a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c61:	a8 01                	test   $0x1,%al
  801c63:	74 2c                	je     801c91 <sfork+0xcb>
  801c65:	89 d8                	mov    %ebx,%eax
  801c67:	c1 e8 0c             	shr    $0xc,%eax
  801c6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c71:	a8 01                	test   $0x1,%al
  801c73:	74 1c                	je     801c91 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801c75:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c7c:	00 
  801c7d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c81:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c89:	89 3c 24             	mov    %edi,(%esp)
  801c8c:	e8 7c f9 ff ff       	call   80160d <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801c91:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c97:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801c9d:	75 b6                	jne    801c55 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  801c9f:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801ca4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca7:	e8 78 fb ff ff       	call   801824 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801cac:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801cb3:	00 
  801cb4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801cbb:	ee 
  801cbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 f2 f8 ff ff       	call   8015b9 <sys_page_alloc>
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	79 1c                	jns    801ce7 <sfork+0x121>
  801ccb:	c7 44 24 08 32 3d 80 	movl   $0x803d32,0x8(%esp)
  801cd2:	00 
  801cd3:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801cda:	00 
  801cdb:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801ce2:	e8 5d ed ff ff       	call   800a44 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801ce7:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801ced:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801cf4:	c1 e7 07             	shl    $0x7,%edi
  801cf7:	29 d7                	sub    %edx,%edi
  801cf9:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  801cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d06:	89 04 24             	mov    %eax,(%esp)
  801d09:	e8 4b fa ff ff       	call   801759 <sys_env_set_pgfault_upcall>
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	79 1c                	jns    801d2e <sfork+0x168>
  801d12:	c7 44 24 08 32 3d 80 	movl   $0x803d32,0x8(%esp)
  801d19:	00 
  801d1a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  801d21:	00 
  801d22:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801d29:	e8 16 ed ff ff       	call   800a44 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801d2e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801d35:	00 
  801d36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d39:	89 04 24             	mov    %eax,(%esp)
  801d3c:	e8 72 f9 ff ff       	call   8016b3 <sys_env_set_status>
  801d41:	85 c0                	test   %eax,%eax
  801d43:	79 1c                	jns    801d61 <sfork+0x19b>
  801d45:	c7 44 24 08 32 3d 80 	movl   $0x803d32,0x8(%esp)
  801d4c:	00 
  801d4d:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801d54:	00 
  801d55:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  801d5c:	e8 e3 ec ff ff       	call   800a44 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  801d61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d64:	83 c4 3c             	add    $0x3c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    

00801d6c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  801d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d75:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801d78:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801d7a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801d7d:	83 3a 01             	cmpl   $0x1,(%edx)
  801d80:	7e 0b                	jle    801d8d <argstart+0x21>
  801d82:	85 c9                	test   %ecx,%ecx
  801d84:	75 0e                	jne    801d94 <argstart+0x28>
  801d86:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8b:	eb 0c                	jmp    801d99 <argstart+0x2d>
  801d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d92:	eb 05                	jmp    801d99 <argstart+0x2d>
  801d94:	ba a1 37 80 00       	mov    $0x8037a1,%edx
  801d99:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801d9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <argnext>:

int
argnext(struct Argstate *args)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	53                   	push   %ebx
  801da9:	83 ec 14             	sub    $0x14,%esp
  801dac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801daf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801db6:	8b 43 08             	mov    0x8(%ebx),%eax
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	74 6c                	je     801e29 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801dbd:	80 38 00             	cmpb   $0x0,(%eax)
  801dc0:	75 4d                	jne    801e0f <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801dc2:	8b 0b                	mov    (%ebx),%ecx
  801dc4:	83 39 01             	cmpl   $0x1,(%ecx)
  801dc7:	74 52                	je     801e1b <argnext+0x76>
		    || args->argv[1][0] != '-'
  801dc9:	8b 53 04             	mov    0x4(%ebx),%edx
  801dcc:	8b 42 04             	mov    0x4(%edx),%eax
  801dcf:	80 38 2d             	cmpb   $0x2d,(%eax)
  801dd2:	75 47                	jne    801e1b <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801dd4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801dd8:	74 41                	je     801e1b <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801dda:	40                   	inc    %eax
  801ddb:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801dde:	8b 01                	mov    (%ecx),%eax
  801de0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801de7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801deb:	8d 42 08             	lea    0x8(%edx),%eax
  801dee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df2:	83 c2 04             	add    $0x4,%edx
  801df5:	89 14 24             	mov    %edx,(%esp)
  801df8:	e8 43 f5 ff ff       	call   801340 <memmove>
		(*args->argc)--;
  801dfd:	8b 03                	mov    (%ebx),%eax
  801dff:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801e01:	8b 43 08             	mov    0x8(%ebx),%eax
  801e04:	80 38 2d             	cmpb   $0x2d,(%eax)
  801e07:	75 06                	jne    801e0f <argnext+0x6a>
  801e09:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801e0d:	74 0c                	je     801e1b <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801e0f:	8b 53 08             	mov    0x8(%ebx),%edx
  801e12:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801e15:	42                   	inc    %edx
  801e16:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801e19:	eb 13                	jmp    801e2e <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801e1b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801e22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801e27:	eb 05                	jmp    801e2e <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801e2e:	83 c4 14             	add    $0x14,%esp
  801e31:	5b                   	pop    %ebx
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    

00801e34 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	53                   	push   %ebx
  801e38:	83 ec 14             	sub    $0x14,%esp
  801e3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801e3e:	8b 43 08             	mov    0x8(%ebx),%eax
  801e41:	85 c0                	test   %eax,%eax
  801e43:	74 59                	je     801e9e <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801e45:	80 38 00             	cmpb   $0x0,(%eax)
  801e48:	74 0c                	je     801e56 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801e4a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801e4d:	c7 43 08 a1 37 80 00 	movl   $0x8037a1,0x8(%ebx)
  801e54:	eb 43                	jmp    801e99 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801e56:	8b 03                	mov    (%ebx),%eax
  801e58:	83 38 01             	cmpl   $0x1,(%eax)
  801e5b:	7e 2e                	jle    801e8b <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801e5d:	8b 53 04             	mov    0x4(%ebx),%edx
  801e60:	8b 4a 04             	mov    0x4(%edx),%ecx
  801e63:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801e66:	8b 00                	mov    (%eax),%eax
  801e68:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801e6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e73:	8d 42 08             	lea    0x8(%edx),%eax
  801e76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7a:	83 c2 04             	add    $0x4,%edx
  801e7d:	89 14 24             	mov    %edx,(%esp)
  801e80:	e8 bb f4 ff ff       	call   801340 <memmove>
		(*args->argc)--;
  801e85:	8b 03                	mov    (%ebx),%eax
  801e87:	ff 08                	decl   (%eax)
  801e89:	eb 0e                	jmp    801e99 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801e8b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801e92:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801e99:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e9c:	eb 05                	jmp    801ea3 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801ea3:	83 c4 14             	add    $0x14,%esp
  801ea6:	5b                   	pop    %ebx
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 18             	sub    $0x18,%esp
  801eaf:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801eb2:	8b 42 0c             	mov    0xc(%edx),%eax
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	75 08                	jne    801ec1 <argvalue+0x18>
  801eb9:	89 14 24             	mov    %edx,(%esp)
  801ebc:	e8 73 ff ff ff       	call   801e34 <argnextvalue>
}
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    
	...

00801ec4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eca:	05 00 00 00 30       	add    $0x30000000,%eax
  801ecf:	c1 e8 0c             	shr    $0xc,%eax
}
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	89 04 24             	mov    %eax,(%esp)
  801ee0:	e8 df ff ff ff       	call   801ec4 <fd2num>
  801ee5:	05 20 00 0d 00       	add    $0xd0020,%eax
  801eea:	c1 e0 0c             	shl    $0xc,%eax
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	53                   	push   %ebx
  801ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ef6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801efb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801efd:	89 c2                	mov    %eax,%edx
  801eff:	c1 ea 16             	shr    $0x16,%edx
  801f02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f09:	f6 c2 01             	test   $0x1,%dl
  801f0c:	74 11                	je     801f1f <fd_alloc+0x30>
  801f0e:	89 c2                	mov    %eax,%edx
  801f10:	c1 ea 0c             	shr    $0xc,%edx
  801f13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801f1a:	f6 c2 01             	test   $0x1,%dl
  801f1d:	75 09                	jne    801f28 <fd_alloc+0x39>
			*fd_store = fd;
  801f1f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801f21:	b8 00 00 00 00       	mov    $0x0,%eax
  801f26:	eb 17                	jmp    801f3f <fd_alloc+0x50>
  801f28:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801f2d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801f32:	75 c7                	jne    801efb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801f34:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801f3a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801f3f:	5b                   	pop    %ebx
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801f48:	83 f8 1f             	cmp    $0x1f,%eax
  801f4b:	77 36                	ja     801f83 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801f4d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801f52:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801f55:	89 c2                	mov    %eax,%edx
  801f57:	c1 ea 16             	shr    $0x16,%edx
  801f5a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f61:	f6 c2 01             	test   $0x1,%dl
  801f64:	74 24                	je     801f8a <fd_lookup+0x48>
  801f66:	89 c2                	mov    %eax,%edx
  801f68:	c1 ea 0c             	shr    $0xc,%edx
  801f6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801f72:	f6 c2 01             	test   $0x1,%dl
  801f75:	74 1a                	je     801f91 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801f77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f7a:	89 02                	mov    %eax,(%edx)
	return 0;
  801f7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f81:	eb 13                	jmp    801f96 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801f83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f88:	eb 0c                	jmp    801f96 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801f8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f8f:	eb 05                	jmp    801f96 <fd_lookup+0x54>
  801f91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    

00801f98 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	53                   	push   %ebx
  801f9c:	83 ec 14             	sub    $0x14,%esp
  801f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801fa5:	ba 00 00 00 00       	mov    $0x0,%edx
  801faa:	eb 0e                	jmp    801fba <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801fac:	39 08                	cmp    %ecx,(%eax)
  801fae:	75 09                	jne    801fb9 <dev_lookup+0x21>
			*dev = devtab[i];
  801fb0:	89 03                	mov    %eax,(%ebx)
			return 0;
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb7:	eb 35                	jmp    801fee <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801fb9:	42                   	inc    %edx
  801fba:	8b 04 95 c0 3d 80 00 	mov    0x803dc0(,%edx,4),%eax
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	75 e7                	jne    801fac <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801fc5:	a1 24 54 80 00       	mov    0x805424,%eax
  801fca:	8b 00                	mov    (%eax),%eax
  801fcc:	8b 40 48             	mov    0x48(%eax),%eax
  801fcf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd7:	c7 04 24 44 3d 80 00 	movl   $0x803d44,(%esp)
  801fde:	e8 59 eb ff ff       	call   800b3c <cprintf>
	*dev = 0;
  801fe3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801fe9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801fee:	83 c4 14             	add    $0x14,%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

00801ff4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	56                   	push   %esi
  801ff8:	53                   	push   %ebx
  801ff9:	83 ec 30             	sub    $0x30,%esp
  801ffc:	8b 75 08             	mov    0x8(%ebp),%esi
  801fff:	8a 45 0c             	mov    0xc(%ebp),%al
  802002:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802005:	89 34 24             	mov    %esi,(%esp)
  802008:	e8 b7 fe ff ff       	call   801ec4 <fd2num>
  80200d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802010:	89 54 24 04          	mov    %edx,0x4(%esp)
  802014:	89 04 24             	mov    %eax,(%esp)
  802017:	e8 26 ff ff ff       	call   801f42 <fd_lookup>
  80201c:	89 c3                	mov    %eax,%ebx
  80201e:	85 c0                	test   %eax,%eax
  802020:	78 05                	js     802027 <fd_close+0x33>
	    || fd != fd2)
  802022:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802025:	74 0d                	je     802034 <fd_close+0x40>
		return (must_exist ? r : 0);
  802027:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80202b:	75 46                	jne    802073 <fd_close+0x7f>
  80202d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802032:	eb 3f                	jmp    802073 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802034:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802037:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203b:	8b 06                	mov    (%esi),%eax
  80203d:	89 04 24             	mov    %eax,(%esp)
  802040:	e8 53 ff ff ff       	call   801f98 <dev_lookup>
  802045:	89 c3                	mov    %eax,%ebx
  802047:	85 c0                	test   %eax,%eax
  802049:	78 18                	js     802063 <fd_close+0x6f>
		if (dev->dev_close)
  80204b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80204e:	8b 40 10             	mov    0x10(%eax),%eax
  802051:	85 c0                	test   %eax,%eax
  802053:	74 09                	je     80205e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802055:	89 34 24             	mov    %esi,(%esp)
  802058:	ff d0                	call   *%eax
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	eb 05                	jmp    802063 <fd_close+0x6f>
		else
			r = 0;
  80205e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802063:	89 74 24 04          	mov    %esi,0x4(%esp)
  802067:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206e:	e8 ed f5 ff ff       	call   801660 <sys_page_unmap>
	return r;
}
  802073:	89 d8                	mov    %ebx,%eax
  802075:	83 c4 30             	add    $0x30,%esp
  802078:	5b                   	pop    %ebx
  802079:	5e                   	pop    %esi
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    

0080207c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802085:	89 44 24 04          	mov    %eax,0x4(%esp)
  802089:	8b 45 08             	mov    0x8(%ebp),%eax
  80208c:	89 04 24             	mov    %eax,(%esp)
  80208f:	e8 ae fe ff ff       	call   801f42 <fd_lookup>
  802094:	85 c0                	test   %eax,%eax
  802096:	78 13                	js     8020ab <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802098:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80209f:	00 
  8020a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a3:	89 04 24             	mov    %eax,(%esp)
  8020a6:	e8 49 ff ff ff       	call   801ff4 <fd_close>
}
  8020ab:	c9                   	leave  
  8020ac:	c3                   	ret    

008020ad <close_all>:

void
close_all(void)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	53                   	push   %ebx
  8020b1:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8020b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8020b9:	89 1c 24             	mov    %ebx,(%esp)
  8020bc:	e8 bb ff ff ff       	call   80207c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8020c1:	43                   	inc    %ebx
  8020c2:	83 fb 20             	cmp    $0x20,%ebx
  8020c5:	75 f2                	jne    8020b9 <close_all+0xc>
		close(i);
}
  8020c7:	83 c4 14             	add    $0x14,%esp
  8020ca:	5b                   	pop    %ebx
  8020cb:	5d                   	pop    %ebp
  8020cc:	c3                   	ret    

008020cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8020cd:	55                   	push   %ebp
  8020ce:	89 e5                	mov    %esp,%ebp
  8020d0:	57                   	push   %edi
  8020d1:	56                   	push   %esi
  8020d2:	53                   	push   %ebx
  8020d3:	83 ec 4c             	sub    $0x4c,%esp
  8020d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8020d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8020dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e3:	89 04 24             	mov    %eax,(%esp)
  8020e6:	e8 57 fe ff ff       	call   801f42 <fd_lookup>
  8020eb:	89 c3                	mov    %eax,%ebx
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	0f 88 e1 00 00 00    	js     8021d6 <dup+0x109>
		return r;
	close(newfdnum);
  8020f5:	89 3c 24             	mov    %edi,(%esp)
  8020f8:	e8 7f ff ff ff       	call   80207c <close>

	newfd = INDEX2FD(newfdnum);
  8020fd:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802103:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  802106:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802109:	89 04 24             	mov    %eax,(%esp)
  80210c:	e8 c3 fd ff ff       	call   801ed4 <fd2data>
  802111:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802113:	89 34 24             	mov    %esi,(%esp)
  802116:	e8 b9 fd ff ff       	call   801ed4 <fd2data>
  80211b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80211e:	89 d8                	mov    %ebx,%eax
  802120:	c1 e8 16             	shr    $0x16,%eax
  802123:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80212a:	a8 01                	test   $0x1,%al
  80212c:	74 46                	je     802174 <dup+0xa7>
  80212e:	89 d8                	mov    %ebx,%eax
  802130:	c1 e8 0c             	shr    $0xc,%eax
  802133:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80213a:	f6 c2 01             	test   $0x1,%dl
  80213d:	74 35                	je     802174 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80213f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802146:	25 07 0e 00 00       	and    $0xe07,%eax
  80214b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80214f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802152:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802156:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80215d:	00 
  80215e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802169:	e8 9f f4 ff ff       	call   80160d <sys_page_map>
  80216e:	89 c3                	mov    %eax,%ebx
  802170:	85 c0                	test   %eax,%eax
  802172:	78 3b                	js     8021af <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802177:	89 c2                	mov    %eax,%edx
  802179:	c1 ea 0c             	shr    $0xc,%edx
  80217c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802183:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802189:	89 54 24 10          	mov    %edx,0x10(%esp)
  80218d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802191:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802198:	00 
  802199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a4:	e8 64 f4 ff ff       	call   80160d <sys_page_map>
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	79 25                	jns    8021d4 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8021af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ba:	e8 a1 f4 ff ff       	call   801660 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8021bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8021c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021cd:	e8 8e f4 ff ff       	call   801660 <sys_page_unmap>
	return r;
  8021d2:	eb 02                	jmp    8021d6 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8021d4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	83 c4 4c             	add    $0x4c,%esp
  8021db:	5b                   	pop    %ebx
  8021dc:	5e                   	pop    %esi
  8021dd:	5f                   	pop    %edi
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

008021e0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 24             	sub    $0x24,%esp
  8021e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f1:	89 1c 24             	mov    %ebx,(%esp)
  8021f4:	e8 49 fd ff ff       	call   801f42 <fd_lookup>
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 6f                	js     80226c <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802200:	89 44 24 04          	mov    %eax,0x4(%esp)
  802204:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802207:	8b 00                	mov    (%eax),%eax
  802209:	89 04 24             	mov    %eax,(%esp)
  80220c:	e8 87 fd ff ff       	call   801f98 <dev_lookup>
  802211:	85 c0                	test   %eax,%eax
  802213:	78 57                	js     80226c <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802218:	8b 50 08             	mov    0x8(%eax),%edx
  80221b:	83 e2 03             	and    $0x3,%edx
  80221e:	83 fa 01             	cmp    $0x1,%edx
  802221:	75 25                	jne    802248 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802223:	a1 24 54 80 00       	mov    0x805424,%eax
  802228:	8b 00                	mov    (%eax),%eax
  80222a:	8b 40 48             	mov    0x48(%eax),%eax
  80222d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802231:	89 44 24 04          	mov    %eax,0x4(%esp)
  802235:	c7 04 24 85 3d 80 00 	movl   $0x803d85,(%esp)
  80223c:	e8 fb e8 ff ff       	call   800b3c <cprintf>
		return -E_INVAL;
  802241:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802246:	eb 24                	jmp    80226c <read+0x8c>
	}
	if (!dev->dev_read)
  802248:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80224b:	8b 52 08             	mov    0x8(%edx),%edx
  80224e:	85 d2                	test   %edx,%edx
  802250:	74 15                	je     802267 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802252:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802255:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80225c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802260:	89 04 24             	mov    %eax,(%esp)
  802263:	ff d2                	call   *%edx
  802265:	eb 05                	jmp    80226c <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802267:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80226c:	83 c4 24             	add    $0x24,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    

00802272 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	57                   	push   %edi
  802276:	56                   	push   %esi
  802277:	53                   	push   %ebx
  802278:	83 ec 1c             	sub    $0x1c,%esp
  80227b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80227e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802281:	bb 00 00 00 00       	mov    $0x0,%ebx
  802286:	eb 23                	jmp    8022ab <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802288:	89 f0                	mov    %esi,%eax
  80228a:	29 d8                	sub    %ebx,%eax
  80228c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802290:	8b 45 0c             	mov    0xc(%ebp),%eax
  802293:	01 d8                	add    %ebx,%eax
  802295:	89 44 24 04          	mov    %eax,0x4(%esp)
  802299:	89 3c 24             	mov    %edi,(%esp)
  80229c:	e8 3f ff ff ff       	call   8021e0 <read>
		if (m < 0)
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	78 10                	js     8022b5 <readn+0x43>
			return m;
		if (m == 0)
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	74 0a                	je     8022b3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8022a9:	01 c3                	add    %eax,%ebx
  8022ab:	39 f3                	cmp    %esi,%ebx
  8022ad:	72 d9                	jb     802288 <readn+0x16>
  8022af:	89 d8                	mov    %ebx,%eax
  8022b1:	eb 02                	jmp    8022b5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8022b3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8022b5:	83 c4 1c             	add    $0x1c,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    

008022bd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8022bd:	55                   	push   %ebp
  8022be:	89 e5                	mov    %esp,%ebp
  8022c0:	53                   	push   %ebx
  8022c1:	83 ec 24             	sub    $0x24,%esp
  8022c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ce:	89 1c 24             	mov    %ebx,(%esp)
  8022d1:	e8 6c fc ff ff       	call   801f42 <fd_lookup>
  8022d6:	85 c0                	test   %eax,%eax
  8022d8:	78 6a                	js     802344 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e4:	8b 00                	mov    (%eax),%eax
  8022e6:	89 04 24             	mov    %eax,(%esp)
  8022e9:	e8 aa fc ff ff       	call   801f98 <dev_lookup>
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	78 52                	js     802344 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8022f9:	75 25                	jne    802320 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8022fb:	a1 24 54 80 00       	mov    0x805424,%eax
  802300:	8b 00                	mov    (%eax),%eax
  802302:	8b 40 48             	mov    0x48(%eax),%eax
  802305:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80230d:	c7 04 24 a1 3d 80 00 	movl   $0x803da1,(%esp)
  802314:	e8 23 e8 ff ff       	call   800b3c <cprintf>
		return -E_INVAL;
  802319:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80231e:	eb 24                	jmp    802344 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802320:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802323:	8b 52 0c             	mov    0xc(%edx),%edx
  802326:	85 d2                	test   %edx,%edx
  802328:	74 15                	je     80233f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80232a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802334:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802338:	89 04 24             	mov    %eax,(%esp)
  80233b:	ff d2                	call   *%edx
  80233d:	eb 05                	jmp    802344 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80233f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802344:	83 c4 24             	add    $0x24,%esp
  802347:	5b                   	pop    %ebx
  802348:	5d                   	pop    %ebp
  802349:	c3                   	ret    

0080234a <seek>:

int
seek(int fdnum, off_t offset)
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802350:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802353:	89 44 24 04          	mov    %eax,0x4(%esp)
  802357:	8b 45 08             	mov    0x8(%ebp),%eax
  80235a:	89 04 24             	mov    %eax,(%esp)
  80235d:	e8 e0 fb ff ff       	call   801f42 <fd_lookup>
  802362:	85 c0                	test   %eax,%eax
  802364:	78 0e                	js     802374 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802366:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80236c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80236f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802374:	c9                   	leave  
  802375:	c3                   	ret    

00802376 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802376:	55                   	push   %ebp
  802377:	89 e5                	mov    %esp,%ebp
  802379:	53                   	push   %ebx
  80237a:	83 ec 24             	sub    $0x24,%esp
  80237d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802380:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802383:	89 44 24 04          	mov    %eax,0x4(%esp)
  802387:	89 1c 24             	mov    %ebx,(%esp)
  80238a:	e8 b3 fb ff ff       	call   801f42 <fd_lookup>
  80238f:	85 c0                	test   %eax,%eax
  802391:	78 63                	js     8023f6 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80239d:	8b 00                	mov    (%eax),%eax
  80239f:	89 04 24             	mov    %eax,(%esp)
  8023a2:	e8 f1 fb ff ff       	call   801f98 <dev_lookup>
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	78 4b                	js     8023f6 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8023ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8023b2:	75 25                	jne    8023d9 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8023b4:	a1 24 54 80 00       	mov    0x805424,%eax
  8023b9:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8023bb:	8b 40 48             	mov    0x48(%eax),%eax
  8023be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c6:	c7 04 24 64 3d 80 00 	movl   $0x803d64,(%esp)
  8023cd:	e8 6a e7 ff ff       	call   800b3c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8023d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8023d7:	eb 1d                	jmp    8023f6 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8023d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023dc:	8b 52 18             	mov    0x18(%edx),%edx
  8023df:	85 d2                	test   %edx,%edx
  8023e1:	74 0e                	je     8023f1 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8023e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023ea:	89 04 24             	mov    %eax,(%esp)
  8023ed:	ff d2                	call   *%edx
  8023ef:	eb 05                	jmp    8023f6 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8023f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8023f6:	83 c4 24             	add    $0x24,%esp
  8023f9:	5b                   	pop    %ebx
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    

008023fc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8023fc:	55                   	push   %ebp
  8023fd:	89 e5                	mov    %esp,%ebp
  8023ff:	53                   	push   %ebx
  802400:	83 ec 24             	sub    $0x24,%esp
  802403:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802406:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240d:	8b 45 08             	mov    0x8(%ebp),%eax
  802410:	89 04 24             	mov    %eax,(%esp)
  802413:	e8 2a fb ff ff       	call   801f42 <fd_lookup>
  802418:	85 c0                	test   %eax,%eax
  80241a:	78 52                	js     80246e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80241c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802423:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802426:	8b 00                	mov    (%eax),%eax
  802428:	89 04 24             	mov    %eax,(%esp)
  80242b:	e8 68 fb ff ff       	call   801f98 <dev_lookup>
  802430:	85 c0                	test   %eax,%eax
  802432:	78 3a                	js     80246e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  802434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802437:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80243b:	74 2c                	je     802469 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80243d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802440:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802447:	00 00 00 
	stat->st_isdir = 0;
  80244a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802451:	00 00 00 
	stat->st_dev = dev;
  802454:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80245a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80245e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802461:	89 14 24             	mov    %edx,(%esp)
  802464:	ff 50 14             	call   *0x14(%eax)
  802467:	eb 05                	jmp    80246e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802469:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80246e:	83 c4 24             	add    $0x24,%esp
  802471:	5b                   	pop    %ebx
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    

00802474 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802474:	55                   	push   %ebp
  802475:	89 e5                	mov    %esp,%ebp
  802477:	56                   	push   %esi
  802478:	53                   	push   %ebx
  802479:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80247c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802483:	00 
  802484:	8b 45 08             	mov    0x8(%ebp),%eax
  802487:	89 04 24             	mov    %eax,(%esp)
  80248a:	e8 88 02 00 00       	call   802717 <open>
  80248f:	89 c3                	mov    %eax,%ebx
  802491:	85 c0                	test   %eax,%eax
  802493:	78 1b                	js     8024b0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  802495:	8b 45 0c             	mov    0xc(%ebp),%eax
  802498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249c:	89 1c 24             	mov    %ebx,(%esp)
  80249f:	e8 58 ff ff ff       	call   8023fc <fstat>
  8024a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8024a6:	89 1c 24             	mov    %ebx,(%esp)
  8024a9:	e8 ce fb ff ff       	call   80207c <close>
	return r;
  8024ae:	89 f3                	mov    %esi,%ebx
}
  8024b0:	89 d8                	mov    %ebx,%eax
  8024b2:	83 c4 10             	add    $0x10,%esp
  8024b5:	5b                   	pop    %ebx
  8024b6:	5e                   	pop    %esi
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    
  8024b9:	00 00                	add    %al,(%eax)
	...

008024bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8024bc:	55                   	push   %ebp
  8024bd:	89 e5                	mov    %esp,%ebp
  8024bf:	56                   	push   %esi
  8024c0:	53                   	push   %ebx
  8024c1:	83 ec 10             	sub    $0x10,%esp
  8024c4:	89 c3                	mov    %eax,%ebx
  8024c6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8024c8:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8024cf:	75 11                	jne    8024e2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8024d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8024d8:	e8 c2 0f 00 00       	call   80349f <ipc_find_env>
  8024dd:	a3 20 54 80 00       	mov    %eax,0x805420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8024e2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8024e9:	00 
  8024ea:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8024f1:	00 
  8024f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024f6:	a1 20 54 80 00       	mov    0x805420,%eax
  8024fb:	89 04 24             	mov    %eax,(%esp)
  8024fe:	e8 36 0f 00 00       	call   803439 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  802503:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80250a:	00 
  80250b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80250f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802516:	e8 b1 0e 00 00       	call   8033cc <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  80251b:	83 c4 10             	add    $0x10,%esp
  80251e:	5b                   	pop    %ebx
  80251f:	5e                   	pop    %esi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    

00802522 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802522:	55                   	push   %ebp
  802523:	89 e5                	mov    %esp,%ebp
  802525:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802528:	8b 45 08             	mov    0x8(%ebp),%eax
  80252b:	8b 40 0c             	mov    0xc(%eax),%eax
  80252e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802533:	8b 45 0c             	mov    0xc(%ebp),%eax
  802536:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80253b:	ba 00 00 00 00       	mov    $0x0,%edx
  802540:	b8 02 00 00 00       	mov    $0x2,%eax
  802545:	e8 72 ff ff ff       	call   8024bc <fsipc>
}
  80254a:	c9                   	leave  
  80254b:	c3                   	ret    

0080254c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802552:	8b 45 08             	mov    0x8(%ebp),%eax
  802555:	8b 40 0c             	mov    0xc(%eax),%eax
  802558:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80255d:	ba 00 00 00 00       	mov    $0x0,%edx
  802562:	b8 06 00 00 00       	mov    $0x6,%eax
  802567:	e8 50 ff ff ff       	call   8024bc <fsipc>
}
  80256c:	c9                   	leave  
  80256d:	c3                   	ret    

0080256e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	53                   	push   %ebx
  802572:	83 ec 14             	sub    $0x14,%esp
  802575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802578:	8b 45 08             	mov    0x8(%ebp),%eax
  80257b:	8b 40 0c             	mov    0xc(%eax),%eax
  80257e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802583:	ba 00 00 00 00       	mov    $0x0,%edx
  802588:	b8 05 00 00 00       	mov    $0x5,%eax
  80258d:	e8 2a ff ff ff       	call   8024bc <fsipc>
  802592:	85 c0                	test   %eax,%eax
  802594:	78 2b                	js     8025c1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802596:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80259d:	00 
  80259e:	89 1c 24             	mov    %ebx,(%esp)
  8025a1:	e8 21 ec ff ff       	call   8011c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8025a6:	a1 80 60 80 00       	mov    0x806080,%eax
  8025ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8025b1:	a1 84 60 80 00       	mov    0x806084,%eax
  8025b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8025bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025c1:	83 c4 14             	add    $0x14,%esp
  8025c4:	5b                   	pop    %ebx
  8025c5:	5d                   	pop    %ebp
  8025c6:	c3                   	ret    

008025c7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8025c7:	55                   	push   %ebp
  8025c8:	89 e5                	mov    %esp,%ebp
  8025ca:	53                   	push   %ebx
  8025cb:	83 ec 14             	sub    $0x14,%esp
  8025ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8025d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8025d7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8025e4:	76 05                	jbe    8025eb <devfile_write+0x24>
  8025e6:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8025eb:	a3 04 60 80 00       	mov    %eax,0x806004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  8025f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025fb:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  802602:	e8 a3 ed ff ff       	call   8013aa <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  802607:	ba 00 00 00 00       	mov    $0x0,%edx
  80260c:	b8 04 00 00 00       	mov    $0x4,%eax
  802611:	e8 a6 fe ff ff       	call   8024bc <fsipc>
  802616:	85 c0                	test   %eax,%eax
  802618:	78 53                	js     80266d <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  80261a:	39 c3                	cmp    %eax,%ebx
  80261c:	73 24                	jae    802642 <devfile_write+0x7b>
  80261e:	c7 44 24 0c d0 3d 80 	movl   $0x803dd0,0xc(%esp)
  802625:	00 
  802626:	c7 44 24 08 cb 38 80 	movl   $0x8038cb,0x8(%esp)
  80262d:	00 
  80262e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  802635:	00 
  802636:	c7 04 24 d7 3d 80 00 	movl   $0x803dd7,(%esp)
  80263d:	e8 02 e4 ff ff       	call   800a44 <_panic>
	assert(r <= PGSIZE);
  802642:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802647:	7e 24                	jle    80266d <devfile_write+0xa6>
  802649:	c7 44 24 0c e2 3d 80 	movl   $0x803de2,0xc(%esp)
  802650:	00 
  802651:	c7 44 24 08 cb 38 80 	movl   $0x8038cb,0x8(%esp)
  802658:	00 
  802659:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  802660:	00 
  802661:	c7 04 24 d7 3d 80 00 	movl   $0x803dd7,(%esp)
  802668:	e8 d7 e3 ff ff       	call   800a44 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  80266d:	83 c4 14             	add    $0x14,%esp
  802670:	5b                   	pop    %ebx
  802671:	5d                   	pop    %ebp
  802672:	c3                   	ret    

00802673 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802673:	55                   	push   %ebp
  802674:	89 e5                	mov    %esp,%ebp
  802676:	56                   	push   %esi
  802677:	53                   	push   %ebx
  802678:	83 ec 10             	sub    $0x10,%esp
  80267b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80267e:	8b 45 08             	mov    0x8(%ebp),%eax
  802681:	8b 40 0c             	mov    0xc(%eax),%eax
  802684:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802689:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80268f:	ba 00 00 00 00       	mov    $0x0,%edx
  802694:	b8 03 00 00 00       	mov    $0x3,%eax
  802699:	e8 1e fe ff ff       	call   8024bc <fsipc>
  80269e:	89 c3                	mov    %eax,%ebx
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	78 6a                	js     80270e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8026a4:	39 c6                	cmp    %eax,%esi
  8026a6:	73 24                	jae    8026cc <devfile_read+0x59>
  8026a8:	c7 44 24 0c d0 3d 80 	movl   $0x803dd0,0xc(%esp)
  8026af:	00 
  8026b0:	c7 44 24 08 cb 38 80 	movl   $0x8038cb,0x8(%esp)
  8026b7:	00 
  8026b8:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8026bf:	00 
  8026c0:	c7 04 24 d7 3d 80 00 	movl   $0x803dd7,(%esp)
  8026c7:	e8 78 e3 ff ff       	call   800a44 <_panic>
	assert(r <= PGSIZE);
  8026cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8026d1:	7e 24                	jle    8026f7 <devfile_read+0x84>
  8026d3:	c7 44 24 0c e2 3d 80 	movl   $0x803de2,0xc(%esp)
  8026da:	00 
  8026db:	c7 44 24 08 cb 38 80 	movl   $0x8038cb,0x8(%esp)
  8026e2:	00 
  8026e3:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8026ea:	00 
  8026eb:	c7 04 24 d7 3d 80 00 	movl   $0x803dd7,(%esp)
  8026f2:	e8 4d e3 ff ff       	call   800a44 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8026f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026fb:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802702:	00 
  802703:	8b 45 0c             	mov    0xc(%ebp),%eax
  802706:	89 04 24             	mov    %eax,(%esp)
  802709:	e8 32 ec ff ff       	call   801340 <memmove>
	return r;
}
  80270e:	89 d8                	mov    %ebx,%eax
  802710:	83 c4 10             	add    $0x10,%esp
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5d                   	pop    %ebp
  802716:	c3                   	ret    

00802717 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802717:	55                   	push   %ebp
  802718:	89 e5                	mov    %esp,%ebp
  80271a:	56                   	push   %esi
  80271b:	53                   	push   %ebx
  80271c:	83 ec 20             	sub    $0x20,%esp
  80271f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802722:	89 34 24             	mov    %esi,(%esp)
  802725:	e8 6a ea ff ff       	call   801194 <strlen>
  80272a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80272f:	7f 60                	jg     802791 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802734:	89 04 24             	mov    %eax,(%esp)
  802737:	e8 b3 f7 ff ff       	call   801eef <fd_alloc>
  80273c:	89 c3                	mov    %eax,%ebx
  80273e:	85 c0                	test   %eax,%eax
  802740:	78 54                	js     802796 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802742:	89 74 24 04          	mov    %esi,0x4(%esp)
  802746:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80274d:	e8 75 ea ff ff       	call   8011c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802752:	8b 45 0c             	mov    0xc(%ebp),%eax
  802755:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80275a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80275d:	b8 01 00 00 00       	mov    $0x1,%eax
  802762:	e8 55 fd ff ff       	call   8024bc <fsipc>
  802767:	89 c3                	mov    %eax,%ebx
  802769:	85 c0                	test   %eax,%eax
  80276b:	79 15                	jns    802782 <open+0x6b>
		fd_close(fd, 0);
  80276d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802774:	00 
  802775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802778:	89 04 24             	mov    %eax,(%esp)
  80277b:	e8 74 f8 ff ff       	call   801ff4 <fd_close>
		return r;
  802780:	eb 14                	jmp    802796 <open+0x7f>
	}

	return fd2num(fd);
  802782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802785:	89 04 24             	mov    %eax,(%esp)
  802788:	e8 37 f7 ff ff       	call   801ec4 <fd2num>
  80278d:	89 c3                	mov    %eax,%ebx
  80278f:	eb 05                	jmp    802796 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802791:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802796:	89 d8                	mov    %ebx,%eax
  802798:	83 c4 20             	add    $0x20,%esp
  80279b:	5b                   	pop    %ebx
  80279c:	5e                   	pop    %esi
  80279d:	5d                   	pop    %ebp
  80279e:	c3                   	ret    

0080279f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80279f:	55                   	push   %ebp
  8027a0:	89 e5                	mov    %esp,%ebp
  8027a2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8027a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8027aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8027af:	e8 08 fd ff ff       	call   8024bc <fsipc>
}
  8027b4:	c9                   	leave  
  8027b5:	c3                   	ret    
	...

008027b8 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
  8027bb:	53                   	push   %ebx
  8027bc:	83 ec 14             	sub    $0x14,%esp
  8027bf:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8027c1:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8027c5:	7e 32                	jle    8027f9 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8027c7:	8b 40 04             	mov    0x4(%eax),%eax
  8027ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027ce:	8d 43 10             	lea    0x10(%ebx),%eax
  8027d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d5:	8b 03                	mov    (%ebx),%eax
  8027d7:	89 04 24             	mov    %eax,(%esp)
  8027da:	e8 de fa ff ff       	call   8022bd <write>
		if (result > 0)
  8027df:	85 c0                	test   %eax,%eax
  8027e1:	7e 03                	jle    8027e6 <writebuf+0x2e>
			b->result += result;
  8027e3:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8027e6:	39 43 04             	cmp    %eax,0x4(%ebx)
  8027e9:	74 0e                	je     8027f9 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8027eb:	89 c2                	mov    %eax,%edx
  8027ed:	85 c0                	test   %eax,%eax
  8027ef:	7e 05                	jle    8027f6 <writebuf+0x3e>
  8027f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8027f6:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8027f9:	83 c4 14             	add    $0x14,%esp
  8027fc:	5b                   	pop    %ebx
  8027fd:	5d                   	pop    %ebp
  8027fe:	c3                   	ret    

008027ff <putch>:

static void
putch(int ch, void *thunk)
{
  8027ff:	55                   	push   %ebp
  802800:	89 e5                	mov    %esp,%ebp
  802802:	53                   	push   %ebx
  802803:	83 ec 04             	sub    $0x4,%esp
  802806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802809:	8b 43 04             	mov    0x4(%ebx),%eax
  80280c:	8b 55 08             	mov    0x8(%ebp),%edx
  80280f:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  802813:	40                   	inc    %eax
  802814:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  802817:	3d 00 01 00 00       	cmp    $0x100,%eax
  80281c:	75 0e                	jne    80282c <putch+0x2d>
		writebuf(b);
  80281e:	89 d8                	mov    %ebx,%eax
  802820:	e8 93 ff ff ff       	call   8027b8 <writebuf>
		b->idx = 0;
  802825:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80282c:	83 c4 04             	add    $0x4,%esp
  80282f:	5b                   	pop    %ebx
  802830:	5d                   	pop    %ebp
  802831:	c3                   	ret    

00802832 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802832:	55                   	push   %ebp
  802833:	89 e5                	mov    %esp,%ebp
  802835:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  80283b:	8b 45 08             	mov    0x8(%ebp),%eax
  80283e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802844:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80284b:	00 00 00 
	b.result = 0;
  80284e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802855:	00 00 00 
	b.error = 1;
  802858:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80285f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802862:	8b 45 10             	mov    0x10(%ebp),%eax
  802865:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80286c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802870:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80287a:	c7 04 24 ff 27 80 00 	movl   $0x8027ff,(%esp)
  802881:	e8 18 e4 ff ff       	call   800c9e <vprintfmt>
	if (b.idx > 0)
  802886:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80288d:	7e 0b                	jle    80289a <vfprintf+0x68>
		writebuf(&b);
  80288f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802895:	e8 1e ff ff ff       	call   8027b8 <writebuf>

	return (b.result ? b.result : b.error);
  80289a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8028a0:	85 c0                	test   %eax,%eax
  8028a2:	75 06                	jne    8028aa <vfprintf+0x78>
  8028a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8028aa:	c9                   	leave  
  8028ab:	c3                   	ret    

008028ac <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8028ac:	55                   	push   %ebp
  8028ad:	89 e5                	mov    %esp,%ebp
  8028af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8028b2:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8028b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8028c3:	89 04 24             	mov    %eax,(%esp)
  8028c6:	e8 67 ff ff ff       	call   802832 <vfprintf>
	va_end(ap);

	return cnt;
}
  8028cb:	c9                   	leave  
  8028cc:	c3                   	ret    

008028cd <printf>:

int
printf(const char *fmt, ...)
{
  8028cd:	55                   	push   %ebp
  8028ce:	89 e5                	mov    %esp,%ebp
  8028d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8028d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8028d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028da:	8b 45 08             	mov    0x8(%ebp),%eax
  8028dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8028e8:	e8 45 ff ff ff       	call   802832 <vfprintf>
	va_end(ap);

	return cnt;
}
  8028ed:	c9                   	leave  
  8028ee:	c3                   	ret    
	...

008028f0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8028f0:	55                   	push   %ebp
  8028f1:	89 e5                	mov    %esp,%ebp
  8028f3:	57                   	push   %edi
  8028f4:	56                   	push   %esi
  8028f5:	53                   	push   %ebx
  8028f6:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8028fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802903:	00 
  802904:	8b 45 08             	mov    0x8(%ebp),%eax
  802907:	89 04 24             	mov    %eax,(%esp)
  80290a:	e8 08 fe ff ff       	call   802717 <open>
  80290f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802915:	85 c0                	test   %eax,%eax
  802917:	0f 88 77 05 00 00    	js     802e94 <spawn+0x5a4>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80291d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802924:	00 
  802925:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80292b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80292f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802935:	89 04 24             	mov    %eax,(%esp)
  802938:	e8 35 f9 ff ff       	call   802272 <readn>
  80293d:	3d 00 02 00 00       	cmp    $0x200,%eax
  802942:	75 0c                	jne    802950 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  802944:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80294b:	45 4c 46 
  80294e:	74 3b                	je     80298b <spawn+0x9b>
		close(fd);
  802950:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802956:	89 04 24             	mov    %eax,(%esp)
  802959:	e8 1e f7 ff ff       	call   80207c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80295e:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802965:	46 
  802966:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  80296c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802970:	c7 04 24 ee 3d 80 00 	movl   $0x803dee,(%esp)
  802977:	e8 c0 e1 ff ff       	call   800b3c <cprintf>
		return -E_NOT_EXEC;
  80297c:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  802983:	ff ff ff 
  802986:	e9 15 05 00 00       	jmp    802ea0 <spawn+0x5b0>
  80298b:	ba 07 00 00 00       	mov    $0x7,%edx
  802990:	89 d0                	mov    %edx,%eax
  802992:	cd 30                	int    $0x30
  802994:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80299a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8029a0:	85 c0                	test   %eax,%eax
  8029a2:	0f 88 f8 04 00 00    	js     802ea0 <spawn+0x5b0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8029a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8029ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8029b4:	c1 e0 07             	shl    $0x7,%eax
  8029b7:	29 d0                	sub    %edx,%eax
  8029b9:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  8029bf:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8029c5:	b9 11 00 00 00       	mov    $0x11,%ecx
  8029ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8029cc:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8029d2:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8029d8:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8029dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029e5:	eb 0d                	jmp    8029f4 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8029e7:	89 04 24             	mov    %eax,(%esp)
  8029ea:	e8 a5 e7 ff ff       	call   801194 <strlen>
  8029ef:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8029f3:	46                   	inc    %esi
  8029f4:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8029f6:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8029fd:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  802a00:	85 c0                	test   %eax,%eax
  802a02:	75 e3                	jne    8029e7 <spawn+0xf7>
  802a04:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802a0a:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802a10:	bf 00 10 40 00       	mov    $0x401000,%edi
  802a15:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802a17:	89 f8                	mov    %edi,%eax
  802a19:	83 e0 fc             	and    $0xfffffffc,%eax
  802a1c:	f7 d2                	not    %edx
  802a1e:	8d 14 90             	lea    (%eax,%edx,4),%edx
  802a21:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802a27:	89 d0                	mov    %edx,%eax
  802a29:	83 e8 08             	sub    $0x8,%eax
  802a2c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802a31:	0f 86 7a 04 00 00    	jbe    802eb1 <spawn+0x5c1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a37:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802a3e:	00 
  802a3f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a46:	00 
  802a47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a4e:	e8 66 eb ff ff       	call   8015b9 <sys_page_alloc>
  802a53:	85 c0                	test   %eax,%eax
  802a55:	0f 88 5b 04 00 00    	js     802eb6 <spawn+0x5c6>
  802a5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a60:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802a66:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a69:	eb 2e                	jmp    802a99 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802a6b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802a71:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802a77:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802a7a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a81:	89 3c 24             	mov    %edi,(%esp)
  802a84:	e8 3e e7 ff ff       	call   8011c7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802a89:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802a8c:	89 04 24             	mov    %eax,(%esp)
  802a8f:	e8 00 e7 ff ff       	call   801194 <strlen>
  802a94:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802a98:	43                   	inc    %ebx
  802a99:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802a9f:	7c ca                	jl     802a6b <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802aa1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802aa7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802aad:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802ab4:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802aba:	74 24                	je     802ae0 <spawn+0x1f0>
  802abc:	c7 44 24 0c 64 3e 80 	movl   $0x803e64,0xc(%esp)
  802ac3:	00 
  802ac4:	c7 44 24 08 cb 38 80 	movl   $0x8038cb,0x8(%esp)
  802acb:	00 
  802acc:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  802ad3:	00 
  802ad4:	c7 04 24 08 3e 80 00 	movl   $0x803e08,(%esp)
  802adb:	e8 64 df ff ff       	call   800a44 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802ae0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802ae6:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802aeb:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802af1:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802af4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802afa:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802afd:	89 d0                	mov    %edx,%eax
  802aff:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802b04:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802b0a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802b11:	00 
  802b12:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802b19:	ee 
  802b1a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b20:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b24:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b2b:	00 
  802b2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b33:	e8 d5 ea ff ff       	call   80160d <sys_page_map>
  802b38:	89 c3                	mov    %eax,%ebx
  802b3a:	85 c0                	test   %eax,%eax
  802b3c:	78 1a                	js     802b58 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802b3e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b45:	00 
  802b46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b4d:	e8 0e eb ff ff       	call   801660 <sys_page_unmap>
  802b52:	89 c3                	mov    %eax,%ebx
  802b54:	85 c0                	test   %eax,%eax
  802b56:	79 1f                	jns    802b77 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802b58:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b5f:	00 
  802b60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b67:	e8 f4 ea ff ff       	call   801660 <sys_page_unmap>
	return r;
  802b6c:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802b72:	e9 29 03 00 00       	jmp    802ea0 <spawn+0x5b0>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802b77:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  802b7d:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  802b83:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b89:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802b90:	00 00 00 
  802b93:	e9 bb 01 00 00       	jmp    802d53 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  802b98:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802b9e:	83 38 01             	cmpl   $0x1,(%eax)
  802ba1:	0f 85 9f 01 00 00    	jne    802d46 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802ba7:	89 c2                	mov    %eax,%edx
  802ba9:	8b 40 18             	mov    0x18(%eax),%eax
  802bac:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802baf:	83 f8 01             	cmp    $0x1,%eax
  802bb2:	19 c0                	sbb    %eax,%eax
  802bb4:	83 e0 fe             	and    $0xfffffffe,%eax
  802bb7:	83 c0 07             	add    $0x7,%eax
  802bba:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802bc0:	8b 52 04             	mov    0x4(%edx),%edx
  802bc3:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802bc9:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802bcf:	8b 40 10             	mov    0x10(%eax),%eax
  802bd2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802bd8:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802bde:	8b 52 14             	mov    0x14(%edx),%edx
  802be1:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802be7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802bed:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802bf0:	89 f8                	mov    %edi,%eax
  802bf2:	25 ff 0f 00 00       	and    $0xfff,%eax
  802bf7:	74 16                	je     802c0f <spawn+0x31f>
		va -= i;
  802bf9:	29 c7                	sub    %eax,%edi
		memsz += i;
  802bfb:	01 c2                	add    %eax,%edx
  802bfd:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802c03:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802c09:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c14:	e9 1f 01 00 00       	jmp    802d38 <spawn+0x448>
		if (i >= filesz) {
  802c19:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  802c1f:	72 2b                	jb     802c4c <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802c21:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802c27:	89 54 24 08          	mov    %edx,0x8(%esp)
  802c2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c2f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802c35:	89 04 24             	mov    %eax,(%esp)
  802c38:	e8 7c e9 ff ff       	call   8015b9 <sys_page_alloc>
  802c3d:	85 c0                	test   %eax,%eax
  802c3f:	0f 89 e7 00 00 00    	jns    802d2c <spawn+0x43c>
  802c45:	89 c6                	mov    %eax,%esi
  802c47:	e9 24 02 00 00       	jmp    802e70 <spawn+0x580>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802c4c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802c53:	00 
  802c54:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802c5b:	00 
  802c5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c63:	e8 51 e9 ff ff       	call   8015b9 <sys_page_alloc>
  802c68:	85 c0                	test   %eax,%eax
  802c6a:	0f 88 f6 01 00 00    	js     802e66 <spawn+0x576>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802c70:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802c76:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c7c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802c82:	89 04 24             	mov    %eax,(%esp)
  802c85:	e8 c0 f6 ff ff       	call   80234a <seek>
  802c8a:	85 c0                	test   %eax,%eax
  802c8c:	0f 88 d8 01 00 00    	js     802e6a <spawn+0x57a>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802c92:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802c98:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802c9a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802c9f:	76 05                	jbe    802ca6 <spawn+0x3b6>
  802ca1:	b8 00 10 00 00       	mov    $0x1000,%eax
  802ca6:	89 44 24 08          	mov    %eax,0x8(%esp)
  802caa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802cb1:	00 
  802cb2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802cb8:	89 04 24             	mov    %eax,(%esp)
  802cbb:	e8 b2 f5 ff ff       	call   802272 <readn>
  802cc0:	85 c0                	test   %eax,%eax
  802cc2:	0f 88 a6 01 00 00    	js     802e6e <spawn+0x57e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802cc8:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802cce:	89 54 24 10          	mov    %edx,0x10(%esp)
  802cd2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802cd6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802cdc:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ce0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802ce7:	00 
  802ce8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cef:	e8 19 e9 ff ff       	call   80160d <sys_page_map>
  802cf4:	85 c0                	test   %eax,%eax
  802cf6:	79 20                	jns    802d18 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802cf8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cfc:	c7 44 24 08 14 3e 80 	movl   $0x803e14,0x8(%esp)
  802d03:	00 
  802d04:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  802d0b:	00 
  802d0c:	c7 04 24 08 3e 80 00 	movl   $0x803e08,(%esp)
  802d13:	e8 2c dd ff ff       	call   800a44 <_panic>
			sys_page_unmap(0, UTEMP);
  802d18:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802d1f:	00 
  802d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d27:	e8 34 e9 ff ff       	call   801660 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802d2c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802d32:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802d38:	89 de                	mov    %ebx,%esi
  802d3a:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802d40:	0f 82 d3 fe ff ff    	jb     802c19 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802d46:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802d4c:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802d53:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802d5a:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802d60:	0f 8c 32 fe ff ff    	jl     802b98 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802d66:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802d6c:	89 04 24             	mov    %eax,(%esp)
  802d6f:	e8 08 f3 ff ff       	call   80207c <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  802d74:	be 00 00 00 00       	mov    $0x0,%esi
  802d79:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(va)] & PTE_P)&&(uvpt[PGNUM(va)] & PTE_P)&&(uvpt[PGNUM(va)]&PTE_U)&&(uvpt[PGNUM(va)]&PTE_SHARE)){
  802d7f:	89 f0                	mov    %esi,%eax
  802d81:	c1 e8 16             	shr    $0x16,%eax
  802d84:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802d8b:	a8 01                	test   $0x1,%al
  802d8d:	74 49                	je     802dd8 <spawn+0x4e8>
  802d8f:	89 f0                	mov    %esi,%eax
  802d91:	c1 e8 0c             	shr    $0xc,%eax
  802d94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802d9b:	f6 c2 01             	test   $0x1,%dl
  802d9e:	74 38                	je     802dd8 <spawn+0x4e8>
  802da0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802da7:	f6 c2 04             	test   $0x4,%dl
  802daa:	74 2c                	je     802dd8 <spawn+0x4e8>
  802dac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802db3:	f6 c4 04             	test   $0x4,%ah
  802db6:	74 20                	je     802dd8 <spawn+0x4e8>
			if ((r = sys_page_map(0,(void*)va,child,(void*)va,PTE_SYSCALL))<0);
  802db8:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  802dbf:	00 
  802dc0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802dc4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802dc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  802dcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dd3:	e8 35 e8 ff ff       	call   80160d <sys_page_map>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  802dd8:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802dde:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  802de4:	75 99                	jne    802d7f <spawn+0x48f>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802de6:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802ded:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802df0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802df6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dfa:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802e00:	89 04 24             	mov    %eax,(%esp)
  802e03:	e8 fe e8 ff ff       	call   801706 <sys_env_set_trapframe>
  802e08:	85 c0                	test   %eax,%eax
  802e0a:	79 20                	jns    802e2c <spawn+0x53c>
		panic("sys_env_set_trapframe: %e", r);
  802e0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e10:	c7 44 24 08 31 3e 80 	movl   $0x803e31,0x8(%esp)
  802e17:	00 
  802e18:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802e1f:	00 
  802e20:	c7 04 24 08 3e 80 00 	movl   $0x803e08,(%esp)
  802e27:	e8 18 dc ff ff       	call   800a44 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802e2c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802e33:	00 
  802e34:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802e3a:	89 04 24             	mov    %eax,(%esp)
  802e3d:	e8 71 e8 ff ff       	call   8016b3 <sys_env_set_status>
  802e42:	85 c0                	test   %eax,%eax
  802e44:	79 5a                	jns    802ea0 <spawn+0x5b0>
		panic("sys_env_set_status: %e", r);
  802e46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e4a:	c7 44 24 08 4b 3e 80 	movl   $0x803e4b,0x8(%esp)
  802e51:	00 
  802e52:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  802e59:	00 
  802e5a:	c7 04 24 08 3e 80 00 	movl   $0x803e08,(%esp)
  802e61:	e8 de db ff ff       	call   800a44 <_panic>
  802e66:	89 c6                	mov    %eax,%esi
  802e68:	eb 06                	jmp    802e70 <spawn+0x580>
  802e6a:	89 c6                	mov    %eax,%esi
  802e6c:	eb 02                	jmp    802e70 <spawn+0x580>
  802e6e:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802e70:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802e76:	89 04 24             	mov    %eax,(%esp)
  802e79:	e8 ab e6 ff ff       	call   801529 <sys_env_destroy>
	close(fd);
  802e7e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802e84:	89 04 24             	mov    %eax,(%esp)
  802e87:	e8 f0 f1 ff ff       	call   80207c <close>
	return r;
  802e8c:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802e92:	eb 0c                	jmp    802ea0 <spawn+0x5b0>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802e94:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802e9a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802ea0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802ea6:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802eac:	5b                   	pop    %ebx
  802ead:	5e                   	pop    %esi
  802eae:	5f                   	pop    %edi
  802eaf:	5d                   	pop    %ebp
  802eb0:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802eb1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802eb6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802ebc:	eb e2                	jmp    802ea0 <spawn+0x5b0>

00802ebe <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802ebe:	55                   	push   %ebp
  802ebf:	89 e5                	mov    %esp,%ebp
  802ec1:	57                   	push   %edi
  802ec2:	56                   	push   %esi
  802ec3:	53                   	push   %ebx
  802ec4:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802ec7:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802eca:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ecf:	eb 03                	jmp    802ed4 <spawnl+0x16>
		argc++;
  802ed1:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ed2:	89 d0                	mov    %edx,%eax
  802ed4:	8d 50 04             	lea    0x4(%eax),%edx
  802ed7:	83 38 00             	cmpl   $0x0,(%eax)
  802eda:	75 f5                	jne    802ed1 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802edc:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802ee3:	83 e0 f0             	and    $0xfffffff0,%eax
  802ee6:	29 c4                	sub    %eax,%esp
  802ee8:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802eec:	83 e7 f0             	and    $0xfffffff0,%edi
  802eef:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ef4:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802ef6:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802efd:	00 

	va_start(vl, arg0);
  802efe:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802f01:	b8 00 00 00 00       	mov    $0x0,%eax
  802f06:	eb 09                	jmp    802f11 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802f08:	40                   	inc    %eax
  802f09:	8b 1a                	mov    (%edx),%ebx
  802f0b:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802f0e:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802f11:	39 c8                	cmp    %ecx,%eax
  802f13:	75 f3                	jne    802f08 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802f15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802f19:	8b 45 08             	mov    0x8(%ebp),%eax
  802f1c:	89 04 24             	mov    %eax,(%esp)
  802f1f:	e8 cc f9 ff ff       	call   8028f0 <spawn>
}
  802f24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f27:	5b                   	pop    %ebx
  802f28:	5e                   	pop    %esi
  802f29:	5f                   	pop    %edi
  802f2a:	5d                   	pop    %ebp
  802f2b:	c3                   	ret    

00802f2c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802f2c:	55                   	push   %ebp
  802f2d:	89 e5                	mov    %esp,%ebp
  802f2f:	56                   	push   %esi
  802f30:	53                   	push   %ebx
  802f31:	83 ec 10             	sub    $0x10,%esp
  802f34:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802f37:	8b 45 08             	mov    0x8(%ebp),%eax
  802f3a:	89 04 24             	mov    %eax,(%esp)
  802f3d:	e8 92 ef ff ff       	call   801ed4 <fd2data>
  802f42:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802f44:	c7 44 24 04 8a 3e 80 	movl   $0x803e8a,0x4(%esp)
  802f4b:	00 
  802f4c:	89 34 24             	mov    %esi,(%esp)
  802f4f:	e8 73 e2 ff ff       	call   8011c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802f54:	8b 43 04             	mov    0x4(%ebx),%eax
  802f57:	2b 03                	sub    (%ebx),%eax
  802f59:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802f5f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802f66:	00 00 00 
	stat->st_dev = &devpipe;
  802f69:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802f70:	40 80 00 
	return 0;
}
  802f73:	b8 00 00 00 00       	mov    $0x0,%eax
  802f78:	83 c4 10             	add    $0x10,%esp
  802f7b:	5b                   	pop    %ebx
  802f7c:	5e                   	pop    %esi
  802f7d:	5d                   	pop    %ebp
  802f7e:	c3                   	ret    

00802f7f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802f7f:	55                   	push   %ebp
  802f80:	89 e5                	mov    %esp,%ebp
  802f82:	53                   	push   %ebx
  802f83:	83 ec 14             	sub    $0x14,%esp
  802f86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802f89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f94:	e8 c7 e6 ff ff       	call   801660 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802f99:	89 1c 24             	mov    %ebx,(%esp)
  802f9c:	e8 33 ef ff ff       	call   801ed4 <fd2data>
  802fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fac:	e8 af e6 ff ff       	call   801660 <sys_page_unmap>
}
  802fb1:	83 c4 14             	add    $0x14,%esp
  802fb4:	5b                   	pop    %ebx
  802fb5:	5d                   	pop    %ebp
  802fb6:	c3                   	ret    

00802fb7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802fb7:	55                   	push   %ebp
  802fb8:	89 e5                	mov    %esp,%ebp
  802fba:	57                   	push   %edi
  802fbb:	56                   	push   %esi
  802fbc:	53                   	push   %ebx
  802fbd:	83 ec 2c             	sub    $0x2c,%esp
  802fc0:	89 c7                	mov    %eax,%edi
  802fc2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802fc5:	a1 24 54 80 00       	mov    0x805424,%eax
  802fca:	8b 00                	mov    (%eax),%eax
  802fcc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802fcf:	89 3c 24             	mov    %edi,(%esp)
  802fd2:	e8 0d 05 00 00       	call   8034e4 <pageref>
  802fd7:	89 c6                	mov    %eax,%esi
  802fd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802fdc:	89 04 24             	mov    %eax,(%esp)
  802fdf:	e8 00 05 00 00       	call   8034e4 <pageref>
  802fe4:	39 c6                	cmp    %eax,%esi
  802fe6:	0f 94 c0             	sete   %al
  802fe9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802fec:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802ff2:	8b 12                	mov    (%edx),%edx
  802ff4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802ff7:	39 cb                	cmp    %ecx,%ebx
  802ff9:	75 08                	jne    803003 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802ffb:	83 c4 2c             	add    $0x2c,%esp
  802ffe:	5b                   	pop    %ebx
  802fff:	5e                   	pop    %esi
  803000:	5f                   	pop    %edi
  803001:	5d                   	pop    %ebp
  803002:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  803003:	83 f8 01             	cmp    $0x1,%eax
  803006:	75 bd                	jne    802fc5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803008:	8b 42 58             	mov    0x58(%edx),%eax
  80300b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  803012:	00 
  803013:	89 44 24 08          	mov    %eax,0x8(%esp)
  803017:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80301b:	c7 04 24 91 3e 80 00 	movl   $0x803e91,(%esp)
  803022:	e8 15 db ff ff       	call   800b3c <cprintf>
  803027:	eb 9c                	jmp    802fc5 <_pipeisclosed+0xe>

00803029 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803029:	55                   	push   %ebp
  80302a:	89 e5                	mov    %esp,%ebp
  80302c:	57                   	push   %edi
  80302d:	56                   	push   %esi
  80302e:	53                   	push   %ebx
  80302f:	83 ec 1c             	sub    $0x1c,%esp
  803032:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803035:	89 34 24             	mov    %esi,(%esp)
  803038:	e8 97 ee ff ff       	call   801ed4 <fd2data>
  80303d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80303f:	bf 00 00 00 00       	mov    $0x0,%edi
  803044:	eb 3c                	jmp    803082 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803046:	89 da                	mov    %ebx,%edx
  803048:	89 f0                	mov    %esi,%eax
  80304a:	e8 68 ff ff ff       	call   802fb7 <_pipeisclosed>
  80304f:	85 c0                	test   %eax,%eax
  803051:	75 38                	jne    80308b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803053:	e8 42 e5 ff ff       	call   80159a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803058:	8b 43 04             	mov    0x4(%ebx),%eax
  80305b:	8b 13                	mov    (%ebx),%edx
  80305d:	83 c2 20             	add    $0x20,%edx
  803060:	39 d0                	cmp    %edx,%eax
  803062:	73 e2                	jae    803046 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803064:	8b 55 0c             	mov    0xc(%ebp),%edx
  803067:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80306a:	89 c2                	mov    %eax,%edx
  80306c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  803072:	79 05                	jns    803079 <devpipe_write+0x50>
  803074:	4a                   	dec    %edx
  803075:	83 ca e0             	or     $0xffffffe0,%edx
  803078:	42                   	inc    %edx
  803079:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80307d:	40                   	inc    %eax
  80307e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803081:	47                   	inc    %edi
  803082:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803085:	75 d1                	jne    803058 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803087:	89 f8                	mov    %edi,%eax
  803089:	eb 05                	jmp    803090 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80308b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803090:	83 c4 1c             	add    $0x1c,%esp
  803093:	5b                   	pop    %ebx
  803094:	5e                   	pop    %esi
  803095:	5f                   	pop    %edi
  803096:	5d                   	pop    %ebp
  803097:	c3                   	ret    

00803098 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803098:	55                   	push   %ebp
  803099:	89 e5                	mov    %esp,%ebp
  80309b:	57                   	push   %edi
  80309c:	56                   	push   %esi
  80309d:	53                   	push   %ebx
  80309e:	83 ec 1c             	sub    $0x1c,%esp
  8030a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8030a4:	89 3c 24             	mov    %edi,(%esp)
  8030a7:	e8 28 ee ff ff       	call   801ed4 <fd2data>
  8030ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030ae:	be 00 00 00 00       	mov    $0x0,%esi
  8030b3:	eb 3a                	jmp    8030ef <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8030b5:	85 f6                	test   %esi,%esi
  8030b7:	74 04                	je     8030bd <devpipe_read+0x25>
				return i;
  8030b9:	89 f0                	mov    %esi,%eax
  8030bb:	eb 40                	jmp    8030fd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8030bd:	89 da                	mov    %ebx,%edx
  8030bf:	89 f8                	mov    %edi,%eax
  8030c1:	e8 f1 fe ff ff       	call   802fb7 <_pipeisclosed>
  8030c6:	85 c0                	test   %eax,%eax
  8030c8:	75 2e                	jne    8030f8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8030ca:	e8 cb e4 ff ff       	call   80159a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8030cf:	8b 03                	mov    (%ebx),%eax
  8030d1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8030d4:	74 df                	je     8030b5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8030d6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8030db:	79 05                	jns    8030e2 <devpipe_read+0x4a>
  8030dd:	48                   	dec    %eax
  8030de:	83 c8 e0             	or     $0xffffffe0,%eax
  8030e1:	40                   	inc    %eax
  8030e2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8030e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8030e9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8030ec:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030ee:	46                   	inc    %esi
  8030ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8030f2:	75 db                	jne    8030cf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8030f4:	89 f0                	mov    %esi,%eax
  8030f6:	eb 05                	jmp    8030fd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8030f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8030fd:	83 c4 1c             	add    $0x1c,%esp
  803100:	5b                   	pop    %ebx
  803101:	5e                   	pop    %esi
  803102:	5f                   	pop    %edi
  803103:	5d                   	pop    %ebp
  803104:	c3                   	ret    

00803105 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803105:	55                   	push   %ebp
  803106:	89 e5                	mov    %esp,%ebp
  803108:	57                   	push   %edi
  803109:	56                   	push   %esi
  80310a:	53                   	push   %ebx
  80310b:	83 ec 3c             	sub    $0x3c,%esp
  80310e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803111:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803114:	89 04 24             	mov    %eax,(%esp)
  803117:	e8 d3 ed ff ff       	call   801eef <fd_alloc>
  80311c:	89 c3                	mov    %eax,%ebx
  80311e:	85 c0                	test   %eax,%eax
  803120:	0f 88 45 01 00 00    	js     80326b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803126:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80312d:	00 
  80312e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803131:	89 44 24 04          	mov    %eax,0x4(%esp)
  803135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80313c:	e8 78 e4 ff ff       	call   8015b9 <sys_page_alloc>
  803141:	89 c3                	mov    %eax,%ebx
  803143:	85 c0                	test   %eax,%eax
  803145:	0f 88 20 01 00 00    	js     80326b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80314b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80314e:	89 04 24             	mov    %eax,(%esp)
  803151:	e8 99 ed ff ff       	call   801eef <fd_alloc>
  803156:	89 c3                	mov    %eax,%ebx
  803158:	85 c0                	test   %eax,%eax
  80315a:	0f 88 f8 00 00 00    	js     803258 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803160:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803167:	00 
  803168:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80316b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80316f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803176:	e8 3e e4 ff ff       	call   8015b9 <sys_page_alloc>
  80317b:	89 c3                	mov    %eax,%ebx
  80317d:	85 c0                	test   %eax,%eax
  80317f:	0f 88 d3 00 00 00    	js     803258 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803188:	89 04 24             	mov    %eax,(%esp)
  80318b:	e8 44 ed ff ff       	call   801ed4 <fd2data>
  803190:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803192:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803199:	00 
  80319a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80319e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031a5:	e8 0f e4 ff ff       	call   8015b9 <sys_page_alloc>
  8031aa:	89 c3                	mov    %eax,%ebx
  8031ac:	85 c0                	test   %eax,%eax
  8031ae:	0f 88 91 00 00 00    	js     803245 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8031b7:	89 04 24             	mov    %eax,(%esp)
  8031ba:	e8 15 ed ff ff       	call   801ed4 <fd2data>
  8031bf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8031c6:	00 
  8031c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8031cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8031d2:	00 
  8031d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031de:	e8 2a e4 ff ff       	call   80160d <sys_page_map>
  8031e3:	89 c3                	mov    %eax,%ebx
  8031e5:	85 c0                	test   %eax,%eax
  8031e7:	78 4c                	js     803235 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8031e9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8031ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8031f2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8031f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8031f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8031fe:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  803204:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803207:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803209:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80320c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803216:	89 04 24             	mov    %eax,(%esp)
  803219:	e8 a6 ec ff ff       	call   801ec4 <fd2num>
  80321e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803220:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803223:	89 04 24             	mov    %eax,(%esp)
  803226:	e8 99 ec ff ff       	call   801ec4 <fd2num>
  80322b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80322e:	bb 00 00 00 00       	mov    $0x0,%ebx
  803233:	eb 36                	jmp    80326b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  803235:	89 74 24 04          	mov    %esi,0x4(%esp)
  803239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803240:	e8 1b e4 ff ff       	call   801660 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803245:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80324c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803253:	e8 08 e4 ff ff       	call   801660 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80325b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80325f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803266:	e8 f5 e3 ff ff       	call   801660 <sys_page_unmap>
    err:
	return r;
}
  80326b:	89 d8                	mov    %ebx,%eax
  80326d:	83 c4 3c             	add    $0x3c,%esp
  803270:	5b                   	pop    %ebx
  803271:	5e                   	pop    %esi
  803272:	5f                   	pop    %edi
  803273:	5d                   	pop    %ebp
  803274:	c3                   	ret    

00803275 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803275:	55                   	push   %ebp
  803276:	89 e5                	mov    %esp,%ebp
  803278:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80327b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80327e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803282:	8b 45 08             	mov    0x8(%ebp),%eax
  803285:	89 04 24             	mov    %eax,(%esp)
  803288:	e8 b5 ec ff ff       	call   801f42 <fd_lookup>
  80328d:	85 c0                	test   %eax,%eax
  80328f:	78 15                	js     8032a6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803294:	89 04 24             	mov    %eax,(%esp)
  803297:	e8 38 ec ff ff       	call   801ed4 <fd2data>
	return _pipeisclosed(fd, p);
  80329c:	89 c2                	mov    %eax,%edx
  80329e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032a1:	e8 11 fd ff ff       	call   802fb7 <_pipeisclosed>
}
  8032a6:	c9                   	leave  
  8032a7:	c3                   	ret    

008032a8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8032a8:	55                   	push   %ebp
  8032a9:	89 e5                	mov    %esp,%ebp
  8032ab:	56                   	push   %esi
  8032ac:	53                   	push   %ebx
  8032ad:	83 ec 10             	sub    $0x10,%esp
  8032b0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8032b3:	85 f6                	test   %esi,%esi
  8032b5:	75 24                	jne    8032db <wait+0x33>
  8032b7:	c7 44 24 0c a9 3e 80 	movl   $0x803ea9,0xc(%esp)
  8032be:	00 
  8032bf:	c7 44 24 08 cb 38 80 	movl   $0x8038cb,0x8(%esp)
  8032c6:	00 
  8032c7:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8032ce:	00 
  8032cf:	c7 04 24 b4 3e 80 00 	movl   $0x803eb4,(%esp)
  8032d6:	e8 69 d7 ff ff       	call   800a44 <_panic>
	e = &envs[ENVX(envid)];
  8032db:	89 f3                	mov    %esi,%ebx
  8032dd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8032e3:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8032ea:	c1 e3 07             	shl    $0x7,%ebx
  8032ed:	29 c3                	sub    %eax,%ebx
  8032ef:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8032f5:	eb 05                	jmp    8032fc <wait+0x54>
		sys_yield();
  8032f7:	e8 9e e2 ff ff       	call   80159a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8032fc:	8b 43 48             	mov    0x48(%ebx),%eax
  8032ff:	39 f0                	cmp    %esi,%eax
  803301:	75 07                	jne    80330a <wait+0x62>
  803303:	8b 43 54             	mov    0x54(%ebx),%eax
  803306:	85 c0                	test   %eax,%eax
  803308:	75 ed                	jne    8032f7 <wait+0x4f>
		sys_yield();
}
  80330a:	83 c4 10             	add    $0x10,%esp
  80330d:	5b                   	pop    %ebx
  80330e:	5e                   	pop    %esi
  80330f:	5d                   	pop    %ebp
  803310:	c3                   	ret    
  803311:	00 00                	add    %al,(%eax)
	...

00803314 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803314:	55                   	push   %ebp
  803315:	89 e5                	mov    %esp,%ebp
  803317:	53                   	push   %ebx
  803318:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80331b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803322:	75 6f                	jne    803393 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  803324:	e8 52 e2 ff ff       	call   80157b <sys_getenvid>
  803329:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80332b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  803332:	00 
  803333:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80333a:	ee 
  80333b:	89 04 24             	mov    %eax,(%esp)
  80333e:	e8 76 e2 ff ff       	call   8015b9 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  803343:	85 c0                	test   %eax,%eax
  803345:	79 1c                	jns    803363 <set_pgfault_handler+0x4f>
  803347:	c7 44 24 08 c0 3e 80 	movl   $0x803ec0,0x8(%esp)
  80334e:	00 
  80334f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  803356:	00 
  803357:	c7 04 24 1c 3f 80 00 	movl   $0x803f1c,(%esp)
  80335e:	e8 e1 d6 ff ff       	call   800a44 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  803363:	c7 44 24 04 a4 33 80 	movl   $0x8033a4,0x4(%esp)
  80336a:	00 
  80336b:	89 1c 24             	mov    %ebx,(%esp)
  80336e:	e8 e6 e3 ff ff       	call   801759 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  803373:	85 c0                	test   %eax,%eax
  803375:	79 1c                	jns    803393 <set_pgfault_handler+0x7f>
  803377:	c7 44 24 08 e8 3e 80 	movl   $0x803ee8,0x8(%esp)
  80337e:	00 
  80337f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  803386:	00 
  803387:	c7 04 24 1c 3f 80 00 	movl   $0x803f1c,(%esp)
  80338e:	e8 b1 d6 ff ff       	call   800a44 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803393:	8b 45 08             	mov    0x8(%ebp),%eax
  803396:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80339b:	83 c4 14             	add    $0x14,%esp
  80339e:	5b                   	pop    %ebx
  80339f:	5d                   	pop    %ebp
  8033a0:	c3                   	ret    
  8033a1:	00 00                	add    %al,(%eax)
	...

008033a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8033a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8033a5:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8033aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8033ac:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8033af:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8033b3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8033b8:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8033bc:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8033be:	83 c4 08             	add    $0x8,%esp
	popal
  8033c1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8033c2:	83 c4 04             	add    $0x4,%esp
	popfl
  8033c5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8033c6:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8033c9:	c3                   	ret    
	...

008033cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8033cc:	55                   	push   %ebp
  8033cd:	89 e5                	mov    %esp,%ebp
  8033cf:	56                   	push   %esi
  8033d0:	53                   	push   %ebx
  8033d1:	83 ec 10             	sub    $0x10,%esp
  8033d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8033d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033da:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8033dd:	85 c0                	test   %eax,%eax
  8033df:	75 05                	jne    8033e6 <ipc_recv+0x1a>
  8033e1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  8033e6:	89 04 24             	mov    %eax,(%esp)
  8033e9:	e8 e1 e3 ff ff       	call   8017cf <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  8033ee:	85 c0                	test   %eax,%eax
  8033f0:	79 16                	jns    803408 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  8033f2:	85 db                	test   %ebx,%ebx
  8033f4:	74 06                	je     8033fc <ipc_recv+0x30>
  8033f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8033fc:	85 f6                	test   %esi,%esi
  8033fe:	74 32                	je     803432 <ipc_recv+0x66>
  803400:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  803406:	eb 2a                	jmp    803432 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  803408:	85 db                	test   %ebx,%ebx
  80340a:	74 0c                	je     803418 <ipc_recv+0x4c>
  80340c:	a1 24 54 80 00       	mov    0x805424,%eax
  803411:	8b 00                	mov    (%eax),%eax
  803413:	8b 40 74             	mov    0x74(%eax),%eax
  803416:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  803418:	85 f6                	test   %esi,%esi
  80341a:	74 0c                	je     803428 <ipc_recv+0x5c>
  80341c:	a1 24 54 80 00       	mov    0x805424,%eax
  803421:	8b 00                	mov    (%eax),%eax
  803423:	8b 40 78             	mov    0x78(%eax),%eax
  803426:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  803428:	a1 24 54 80 00       	mov    0x805424,%eax
  80342d:	8b 00                	mov    (%eax),%eax
  80342f:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  803432:	83 c4 10             	add    $0x10,%esp
  803435:	5b                   	pop    %ebx
  803436:	5e                   	pop    %esi
  803437:	5d                   	pop    %ebp
  803438:	c3                   	ret    

00803439 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803439:	55                   	push   %ebp
  80343a:	89 e5                	mov    %esp,%ebp
  80343c:	57                   	push   %edi
  80343d:	56                   	push   %esi
  80343e:	53                   	push   %ebx
  80343f:	83 ec 1c             	sub    $0x1c,%esp
  803442:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803445:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803448:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80344b:	85 db                	test   %ebx,%ebx
  80344d:	75 05                	jne    803454 <ipc_send+0x1b>
  80344f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  803454:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803458:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80345c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  803460:	8b 45 08             	mov    0x8(%ebp),%eax
  803463:	89 04 24             	mov    %eax,(%esp)
  803466:	e8 41 e3 ff ff       	call   8017ac <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80346b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80346e:	75 07                	jne    803477 <ipc_send+0x3e>
  803470:	e8 25 e1 ff ff       	call   80159a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  803475:	eb dd                	jmp    803454 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  803477:	85 c0                	test   %eax,%eax
  803479:	79 1c                	jns    803497 <ipc_send+0x5e>
  80347b:	c7 44 24 08 2a 3f 80 	movl   $0x803f2a,0x8(%esp)
  803482:	00 
  803483:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80348a:	00 
  80348b:	c7 04 24 3c 3f 80 00 	movl   $0x803f3c,(%esp)
  803492:	e8 ad d5 ff ff       	call   800a44 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  803497:	83 c4 1c             	add    $0x1c,%esp
  80349a:	5b                   	pop    %ebx
  80349b:	5e                   	pop    %esi
  80349c:	5f                   	pop    %edi
  80349d:	5d                   	pop    %ebp
  80349e:	c3                   	ret    

0080349f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80349f:	55                   	push   %ebp
  8034a0:	89 e5                	mov    %esp,%ebp
  8034a2:	53                   	push   %ebx
  8034a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8034a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8034ab:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8034b2:	89 c2                	mov    %eax,%edx
  8034b4:	c1 e2 07             	shl    $0x7,%edx
  8034b7:	29 ca                	sub    %ecx,%edx
  8034b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8034bf:	8b 52 50             	mov    0x50(%edx),%edx
  8034c2:	39 da                	cmp    %ebx,%edx
  8034c4:	75 0f                	jne    8034d5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8034c6:	c1 e0 07             	shl    $0x7,%eax
  8034c9:	29 c8                	sub    %ecx,%eax
  8034cb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8034d0:	8b 40 40             	mov    0x40(%eax),%eax
  8034d3:	eb 0c                	jmp    8034e1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8034d5:	40                   	inc    %eax
  8034d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8034db:	75 ce                	jne    8034ab <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8034dd:	66 b8 00 00          	mov    $0x0,%ax
}
  8034e1:	5b                   	pop    %ebx
  8034e2:	5d                   	pop    %ebp
  8034e3:	c3                   	ret    

008034e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034e4:	55                   	push   %ebp
  8034e5:	89 e5                	mov    %esp,%ebp
  8034e7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  8034ea:	89 c2                	mov    %eax,%edx
  8034ec:	c1 ea 16             	shr    $0x16,%edx
  8034ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8034f6:	f6 c2 01             	test   $0x1,%dl
  8034f9:	74 1e                	je     803519 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8034fb:	c1 e8 0c             	shr    $0xc,%eax
  8034fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803505:	a8 01                	test   $0x1,%al
  803507:	74 17                	je     803520 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803509:	c1 e8 0c             	shr    $0xc,%eax
  80350c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  803513:	ef 
  803514:	0f b7 c0             	movzwl %ax,%eax
  803517:	eb 0c                	jmp    803525 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  803519:	b8 00 00 00 00       	mov    $0x0,%eax
  80351e:	eb 05                	jmp    803525 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803520:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  803525:	5d                   	pop    %ebp
  803526:	c3                   	ret    
	...

00803528 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803528:	55                   	push   %ebp
  803529:	57                   	push   %edi
  80352a:	56                   	push   %esi
  80352b:	83 ec 10             	sub    $0x10,%esp
  80352e:	8b 74 24 20          	mov    0x20(%esp),%esi
  803532:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80353a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80353e:	89 cd                	mov    %ecx,%ebp
  803540:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803544:	85 c0                	test   %eax,%eax
  803546:	75 2c                	jne    803574 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  803548:	39 f9                	cmp    %edi,%ecx
  80354a:	77 68                	ja     8035b4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80354c:	85 c9                	test   %ecx,%ecx
  80354e:	75 0b                	jne    80355b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803550:	b8 01 00 00 00       	mov    $0x1,%eax
  803555:	31 d2                	xor    %edx,%edx
  803557:	f7 f1                	div    %ecx
  803559:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80355b:	31 d2                	xor    %edx,%edx
  80355d:	89 f8                	mov    %edi,%eax
  80355f:	f7 f1                	div    %ecx
  803561:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803563:	89 f0                	mov    %esi,%eax
  803565:	f7 f1                	div    %ecx
  803567:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803569:	89 f0                	mov    %esi,%eax
  80356b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80356d:	83 c4 10             	add    $0x10,%esp
  803570:	5e                   	pop    %esi
  803571:	5f                   	pop    %edi
  803572:	5d                   	pop    %ebp
  803573:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803574:	39 f8                	cmp    %edi,%eax
  803576:	77 2c                	ja     8035a4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803578:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80357b:	83 f6 1f             	xor    $0x1f,%esi
  80357e:	75 4c                	jne    8035cc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803580:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803582:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803587:	72 0a                	jb     803593 <__udivdi3+0x6b>
  803589:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80358d:	0f 87 ad 00 00 00    	ja     803640 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803593:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803598:	89 f0                	mov    %esi,%eax
  80359a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80359c:	83 c4 10             	add    $0x10,%esp
  80359f:	5e                   	pop    %esi
  8035a0:	5f                   	pop    %edi
  8035a1:	5d                   	pop    %ebp
  8035a2:	c3                   	ret    
  8035a3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8035a4:	31 ff                	xor    %edi,%edi
  8035a6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8035a8:	89 f0                	mov    %esi,%eax
  8035aa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8035ac:	83 c4 10             	add    $0x10,%esp
  8035af:	5e                   	pop    %esi
  8035b0:	5f                   	pop    %edi
  8035b1:	5d                   	pop    %ebp
  8035b2:	c3                   	ret    
  8035b3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8035b4:	89 fa                	mov    %edi,%edx
  8035b6:	89 f0                	mov    %esi,%eax
  8035b8:	f7 f1                	div    %ecx
  8035ba:	89 c6                	mov    %eax,%esi
  8035bc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8035be:	89 f0                	mov    %esi,%eax
  8035c0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8035c2:	83 c4 10             	add    $0x10,%esp
  8035c5:	5e                   	pop    %esi
  8035c6:	5f                   	pop    %edi
  8035c7:	5d                   	pop    %ebp
  8035c8:	c3                   	ret    
  8035c9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8035cc:	89 f1                	mov    %esi,%ecx
  8035ce:	d3 e0                	shl    %cl,%eax
  8035d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8035d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8035d9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8035db:	89 ea                	mov    %ebp,%edx
  8035dd:	88 c1                	mov    %al,%cl
  8035df:	d3 ea                	shr    %cl,%edx
  8035e1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8035e5:	09 ca                	or     %ecx,%edx
  8035e7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8035eb:	89 f1                	mov    %esi,%ecx
  8035ed:	d3 e5                	shl    %cl,%ebp
  8035ef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8035f3:	89 fd                	mov    %edi,%ebp
  8035f5:	88 c1                	mov    %al,%cl
  8035f7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8035f9:	89 fa                	mov    %edi,%edx
  8035fb:	89 f1                	mov    %esi,%ecx
  8035fd:	d3 e2                	shl    %cl,%edx
  8035ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803603:	88 c1                	mov    %al,%cl
  803605:	d3 ef                	shr    %cl,%edi
  803607:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803609:	89 f8                	mov    %edi,%eax
  80360b:	89 ea                	mov    %ebp,%edx
  80360d:	f7 74 24 08          	divl   0x8(%esp)
  803611:	89 d1                	mov    %edx,%ecx
  803613:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  803615:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803619:	39 d1                	cmp    %edx,%ecx
  80361b:	72 17                	jb     803634 <__udivdi3+0x10c>
  80361d:	74 09                	je     803628 <__udivdi3+0x100>
  80361f:	89 fe                	mov    %edi,%esi
  803621:	31 ff                	xor    %edi,%edi
  803623:	e9 41 ff ff ff       	jmp    803569 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  803628:	8b 54 24 04          	mov    0x4(%esp),%edx
  80362c:	89 f1                	mov    %esi,%ecx
  80362e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803630:	39 c2                	cmp    %eax,%edx
  803632:	73 eb                	jae    80361f <__udivdi3+0xf7>
		{
		  q0--;
  803634:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803637:	31 ff                	xor    %edi,%edi
  803639:	e9 2b ff ff ff       	jmp    803569 <__udivdi3+0x41>
  80363e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803640:	31 f6                	xor    %esi,%esi
  803642:	e9 22 ff ff ff       	jmp    803569 <__udivdi3+0x41>
	...

00803648 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  803648:	55                   	push   %ebp
  803649:	57                   	push   %edi
  80364a:	56                   	push   %esi
  80364b:	83 ec 20             	sub    $0x20,%esp
  80364e:	8b 44 24 30          	mov    0x30(%esp),%eax
  803652:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803656:	89 44 24 14          	mov    %eax,0x14(%esp)
  80365a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80365e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803662:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  803666:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  803668:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80366a:	85 ed                	test   %ebp,%ebp
  80366c:	75 16                	jne    803684 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80366e:	39 f1                	cmp    %esi,%ecx
  803670:	0f 86 a6 00 00 00    	jbe    80371c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803676:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803678:	89 d0                	mov    %edx,%eax
  80367a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80367c:	83 c4 20             	add    $0x20,%esp
  80367f:	5e                   	pop    %esi
  803680:	5f                   	pop    %edi
  803681:	5d                   	pop    %ebp
  803682:	c3                   	ret    
  803683:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803684:	39 f5                	cmp    %esi,%ebp
  803686:	0f 87 ac 00 00 00    	ja     803738 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80368c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80368f:	83 f0 1f             	xor    $0x1f,%eax
  803692:	89 44 24 10          	mov    %eax,0x10(%esp)
  803696:	0f 84 a8 00 00 00    	je     803744 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80369c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8036a0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8036a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8036a7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8036ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8036af:	89 f9                	mov    %edi,%ecx
  8036b1:	d3 e8                	shr    %cl,%eax
  8036b3:	09 e8                	or     %ebp,%eax
  8036b5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8036b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8036bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8036c1:	d3 e0                	shl    %cl,%eax
  8036c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8036c7:	89 f2                	mov    %esi,%edx
  8036c9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8036cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8036cf:	d3 e0                	shl    %cl,%eax
  8036d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8036d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8036d9:	89 f9                	mov    %edi,%ecx
  8036db:	d3 e8                	shr    %cl,%eax
  8036dd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8036df:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8036e1:	89 f2                	mov    %esi,%edx
  8036e3:	f7 74 24 18          	divl   0x18(%esp)
  8036e7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8036e9:	f7 64 24 0c          	mull   0xc(%esp)
  8036ed:	89 c5                	mov    %eax,%ebp
  8036ef:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8036f1:	39 d6                	cmp    %edx,%esi
  8036f3:	72 67                	jb     80375c <__umoddi3+0x114>
  8036f5:	74 75                	je     80376c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8036f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8036fb:	29 e8                	sub    %ebp,%eax
  8036fd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8036ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803703:	d3 e8                	shr    %cl,%eax
  803705:	89 f2                	mov    %esi,%edx
  803707:	89 f9                	mov    %edi,%ecx
  803709:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80370b:	09 d0                	or     %edx,%eax
  80370d:	89 f2                	mov    %esi,%edx
  80370f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803713:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803715:	83 c4 20             	add    $0x20,%esp
  803718:	5e                   	pop    %esi
  803719:	5f                   	pop    %edi
  80371a:	5d                   	pop    %ebp
  80371b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80371c:	85 c9                	test   %ecx,%ecx
  80371e:	75 0b                	jne    80372b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803720:	b8 01 00 00 00       	mov    $0x1,%eax
  803725:	31 d2                	xor    %edx,%edx
  803727:	f7 f1                	div    %ecx
  803729:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80372b:	89 f0                	mov    %esi,%eax
  80372d:	31 d2                	xor    %edx,%edx
  80372f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803731:	89 f8                	mov    %edi,%eax
  803733:	e9 3e ff ff ff       	jmp    803676 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  803738:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80373a:	83 c4 20             	add    $0x20,%esp
  80373d:	5e                   	pop    %esi
  80373e:	5f                   	pop    %edi
  80373f:	5d                   	pop    %ebp
  803740:	c3                   	ret    
  803741:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803744:	39 f5                	cmp    %esi,%ebp
  803746:	72 04                	jb     80374c <__umoddi3+0x104>
  803748:	39 f9                	cmp    %edi,%ecx
  80374a:	77 06                	ja     803752 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80374c:	89 f2                	mov    %esi,%edx
  80374e:	29 cf                	sub    %ecx,%edi
  803750:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  803752:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803754:	83 c4 20             	add    $0x20,%esp
  803757:	5e                   	pop    %esi
  803758:	5f                   	pop    %edi
  803759:	5d                   	pop    %ebp
  80375a:	c3                   	ret    
  80375b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80375c:	89 d1                	mov    %edx,%ecx
  80375e:	89 c5                	mov    %eax,%ebp
  803760:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803764:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803768:	eb 8d                	jmp    8036f7 <__umoddi3+0xaf>
  80376a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80376c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803770:	72 ea                	jb     80375c <__umoddi3+0x114>
  803772:	89 f1                	mov    %esi,%ecx
  803774:	eb 81                	jmp    8036f7 <__umoddi3+0xaf>
