
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 f7 02 00 00       	call   800328 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8a 45 0c             	mov    0xc(%ebp),%al
  800041:	88 45 f7             	mov    %al,-0x9(%ebp)
	const char *sep;

	if(flag['l'])
  800044:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  80004b:	74 21                	je     80006e <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  80004d:	3c 01                	cmp    $0x1,%al
  80004f:	19 c0                	sbb    %eax,%eax
  800051:	83 e0 c9             	and    $0xffffffc9,%eax
  800054:	83 c0 64             	add    $0x64,%eax
  800057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80005b:	8b 45 10             	mov    0x10(%ebp),%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  800069:	e8 8f 1b 00 00       	call   801bfd <printf>
	if(prefix) {
  80006e:	85 db                	test   %ebx,%ebx
  800070:	74 3b                	je     8000ad <ls1+0x79>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800072:	80 3b 00             	cmpb   $0x0,(%ebx)
  800075:	74 16                	je     80008d <ls1+0x59>
  800077:	89 1c 24             	mov    %ebx,(%esp)
  80007a:	e8 8d 09 00 00       	call   800a0c <strlen>
  80007f:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800084:	74 0e                	je     800094 <ls1+0x60>
			sep = "/";
  800086:	b8 00 25 80 00       	mov    $0x802500,%eax
  80008b:	eb 0c                	jmp    800099 <ls1+0x65>
		else
			sep = "";
  80008d:	b8 eb 29 80 00       	mov    $0x8029eb,%eax
  800092:	eb 05                	jmp    800099 <ls1+0x65>
  800094:	b8 eb 29 80 00       	mov    $0x8029eb,%eax
		printf("%s%s", prefix, sep);
  800099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	c7 04 24 0b 25 80 00 	movl   $0x80250b,(%esp)
  8000a8:	e8 50 1b 00 00       	call   801bfd <printf>
	}
	printf("%s", name);
  8000ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b4:	c7 04 24 95 29 80 00 	movl   $0x802995,(%esp)
  8000bb:	e8 3d 1b 00 00       	call   801bfd <printf>
	if(flag['F'] && isdir)
  8000c0:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c7:	74 12                	je     8000db <ls1+0xa7>
  8000c9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cd:	74 0c                	je     8000db <ls1+0xa7>
		printf("/");
  8000cf:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  8000d6:	e8 22 1b 00 00       	call   801bfd <printf>
	printf("\n");
  8000db:	c7 04 24 ea 29 80 00 	movl   $0x8029ea,(%esp)
  8000e2:	e8 16 1b 00 00       	call   801bfd <printf>
}
  8000e7:	83 c4 24             	add    $0x24,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  8000f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800103:	00 
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	89 04 24             	mov    %eax,(%esp)
  80010a:	e8 38 19 00 00       	call   801a47 <open>
  80010f:	89 c6                	mov    %eax,%esi
  800111:	85 c0                	test   %eax,%eax
  800113:	79 59                	jns    80016e <lsdir+0x81>
		panic("open %s: %e", path, fd);
  800115:	89 44 24 10          	mov    %eax,0x10(%esp)
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	c7 44 24 08 10 25 80 	movl   $0x802510,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  800137:	e8 60 02 00 00       	call   80039c <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  80013c:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800143:	74 2f                	je     800174 <lsdir+0x87>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800145:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800149:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80015a:	0f 94 c0             	sete   %al
  80015d:	0f b6 c0             	movzbl %al,%eax
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	89 3c 24             	mov    %edi,(%esp)
  800167:	e8 c8 fe ff ff       	call   800034 <ls1>
  80016c:	eb 06                	jmp    800174 <lsdir+0x87>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80016e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  800174:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  80017b:	00 
  80017c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800180:	89 34 24             	mov    %esi,(%esp)
  800183:	e8 1a 14 00 00       	call   8015a2 <readn>
  800188:	3d 00 01 00 00       	cmp    $0x100,%eax
  80018d:	74 ad                	je     80013c <lsdir+0x4f>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	7e 23                	jle    8001b6 <lsdir+0xc9>
		panic("short read in directory %s", path);
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	c7 44 24 08 26 25 80 	movl   $0x802526,0x8(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001a9:	00 
  8001aa:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  8001b1:	e8 e6 01 00 00       	call   80039c <_panic>
	if (n < 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	79 27                	jns    8001e1 <lsdir+0xf4>
		panic("error reading directory %s: %e", path, n);
  8001ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c5:	c7 44 24 08 6c 25 80 	movl   $0x80256c,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  8001dc:	e8 bb 01 00 00       	call   80039c <_panic>
}
  8001e1:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001f9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	89 1c 24             	mov    %ebx,(%esp)
  800206:	e8 99 15 00 00       	call   8017a4 <stat>
  80020b:	85 c0                	test   %eax,%eax
  80020d:	79 24                	jns    800233 <ls+0x47>
		panic("stat %s: %e", path, r);
  80020f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800213:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800217:	c7 44 24 08 41 25 80 	movl   $0x802541,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  80022e:	e8 69 01 00 00       	call   80039c <_panic>
	if (st.st_isdir && !flag['d'])
  800233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800236:	85 c0                	test   %eax,%eax
  800238:	74 1a                	je     800254 <ls+0x68>
  80023a:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800241:	75 11                	jne    800254 <ls+0x68>
		lsdir(path, prefix);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	89 1c 24             	mov    %ebx,(%esp)
  80024d:	e8 9b fe ff ff       	call   8000ed <lsdir>
  800252:	eb 23                	jmp    800277 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800258:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80025f:	85 c0                	test   %eax,%eax
  800261:	0f 95 c0             	setne  %al
  800264:	0f b6 c0             	movzbl %al,%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800272:	e8 bd fd ff ff       	call   800034 <ls1>
}
  800277:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <usage>:
	printf("\n");
}

void
usage(void)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800286:	c7 04 24 4d 25 80 00 	movl   $0x80254d,(%esp)
  80028d:	e8 6b 19 00 00       	call   801bfd <printf>
	exit();
  800292:	e8 e9 00 00 00       	call   800380 <exit>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <umain>:

void
umain(int argc, char **argv)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 20             	sub    $0x20,%esp
  8002a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a4:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002af:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 e2 0d 00 00       	call   80109c <argstart>
	while ((i = argnext(&args)) >= 0)
  8002ba:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002bd:	eb 1d                	jmp    8002dc <umain+0x43>
		switch (i) {
  8002bf:	83 f8 64             	cmp    $0x64,%eax
  8002c2:	74 0a                	je     8002ce <umain+0x35>
  8002c4:	83 f8 6c             	cmp    $0x6c,%eax
  8002c7:	74 05                	je     8002ce <umain+0x35>
  8002c9:	83 f8 46             	cmp    $0x46,%eax
  8002cc:	75 09                	jne    8002d7 <umain+0x3e>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002ce:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
			break;
  8002d5:	eb 05                	jmp    8002dc <umain+0x43>
		default:
			usage();
  8002d7:	e8 a4 ff ff ff       	call   800280 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002dc:	89 1c 24             	mov    %ebx,(%esp)
  8002df:	e8 f1 0d 00 00       	call   8010d5 <argnext>
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 d7                	jns    8002bf <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002e8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ec:	75 28                	jne    800316 <umain+0x7d>
		ls("/", "");
  8002ee:	c7 44 24 04 eb 29 80 	movl   $0x8029eb,0x4(%esp)
  8002f5:	00 
  8002f6:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  8002fd:	e8 ea fe ff ff       	call   8001ec <ls>
  800302:	eb 1c                	jmp    800320 <umain+0x87>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  800304:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 d9 fe ff ff       	call   8001ec <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800313:	43                   	inc    %ebx
  800314:	eb 05                	jmp    80031b <umain+0x82>
			break;
		default:
			usage();
		}

	if (argc == 1)
  800316:	bb 01 00 00 00       	mov    $0x1,%ebx
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80031b:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80031e:	7c e4                	jl     800304 <umain+0x6b>
			ls(argv[i], argv[i]);
	}
}
  800320:	83 c4 20             	add    $0x20,%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    
	...

00800328 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 20             	sub    $0x20,%esp
  800330:	8b 75 08             	mov    0x8(%ebp),%esi
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800336:	e8 b8 0a 00 00       	call   800df3 <sys_getenvid>
  80033b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800340:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800347:	c1 e0 07             	shl    $0x7,%eax
  80034a:	29 d0                	sub    %edx,%eax
  80034c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800351:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800357:	a3 20 44 80 00       	mov    %eax,0x804420
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80035c:	85 f6                	test   %esi,%esi
  80035e:	7e 07                	jle    800367 <libmain+0x3f>
		binaryname = argv[0];
  800360:	8b 03                	mov    (%ebx),%eax
  800362:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800367:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80036b:	89 34 24             	mov    %esi,(%esp)
  80036e:	e8 26 ff ff ff       	call   800299 <umain>

	// exit gracefully
	exit();
  800373:	e8 08 00 00 00       	call   800380 <exit>
}
  800378:	83 c4 20             	add    $0x20,%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    
	...

00800380 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800386:	e8 52 10 00 00       	call   8013dd <close_all>
	sys_env_destroy(0);
  80038b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800392:	e8 0a 0a 00 00       	call   800da1 <sys_env_destroy>
}
  800397:	c9                   	leave  
  800398:	c3                   	ret    
  800399:	00 00                	add    %al,(%eax)
	...

0080039c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
  8003a1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8003ad:	e8 41 0a 00 00       	call   800df3 <sys_getenvid>
  8003b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c8:	c7 04 24 98 25 80 00 	movl   $0x802598,(%esp)
  8003cf:	e8 c0 00 00 00       	call   800494 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	e8 50 00 00 00       	call   800433 <vcprintf>
	cprintf("\n");
  8003e3:	c7 04 24 ea 29 80 00 	movl   $0x8029ea,(%esp)
  8003ea:	e8 a5 00 00 00       	call   800494 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ef:	cc                   	int3   
  8003f0:	eb fd                	jmp    8003ef <_panic+0x53>
	...

008003f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 14             	sub    $0x14,%esp
  8003fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003fe:	8b 03                	mov    (%ebx),%eax
  800400:	8b 55 08             	mov    0x8(%ebp),%edx
  800403:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800407:	40                   	inc    %eax
  800408:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80040a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040f:	75 19                	jne    80042a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800411:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800418:	00 
  800419:	8d 43 08             	lea    0x8(%ebx),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	e8 40 09 00 00       	call   800d64 <sys_cputs>
		b->idx = 0;
  800424:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80042a:	ff 43 04             	incl   0x4(%ebx)
}
  80042d:	83 c4 14             	add    $0x14,%esp
  800430:	5b                   	pop    %ebx
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80043c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800443:	00 00 00 
	b.cnt = 0;
  800446:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80044d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800450:	8b 45 0c             	mov    0xc(%ebp),%eax
  800453:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800457:	8b 45 08             	mov    0x8(%ebp),%eax
  80045a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	c7 04 24 f4 03 80 00 	movl   $0x8003f4,(%esp)
  80046f:	e8 82 01 00 00       	call   8005f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800474:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80047a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	e8 d8 08 00 00       	call   800d64 <sys_cputs>

	return b.cnt;
}
  80048c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80049a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80049d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 87 ff ff ff       	call   800433 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    
	...

008004b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 3c             	sub    $0x3c,%esp
  8004b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bc:	89 d7                	mov    %edx,%edi
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	75 08                	jne    8004dc <printnum+0x2c>
  8004d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004da:	77 57                	ja     800533 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004dc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004e0:	4b                   	dec    %ebx
  8004e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ec:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004f0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004fb:	00 
  8004fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	e8 8a 1d 00 00       	call   802298 <__udivdi3>
  80050e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800512:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800516:	89 04 24             	mov    %eax,(%esp)
  800519:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051d:	89 fa                	mov    %edi,%edx
  80051f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800522:	e8 89 ff ff ff       	call   8004b0 <printnum>
  800527:	eb 0f                	jmp    800538 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800529:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052d:	89 34 24             	mov    %esi,(%esp)
  800530:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800533:	4b                   	dec    %ebx
  800534:	85 db                	test   %ebx,%ebx
  800536:	7f f1                	jg     800529 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800538:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800540:	8b 45 10             	mov    0x10(%ebp),%eax
  800543:	89 44 24 08          	mov    %eax,0x8(%esp)
  800547:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054e:	00 
  80054f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	e8 57 1e 00 00       	call   8023b8 <__umoddi3>
  800561:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800565:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800572:	83 c4 3c             	add    $0x3c,%esp
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80057d:	83 fa 01             	cmp    $0x1,%edx
  800580:	7e 0e                	jle    800590 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800582:	8b 10                	mov    (%eax),%edx
  800584:	8d 4a 08             	lea    0x8(%edx),%ecx
  800587:	89 08                	mov    %ecx,(%eax)
  800589:	8b 02                	mov    (%edx),%eax
  80058b:	8b 52 04             	mov    0x4(%edx),%edx
  80058e:	eb 22                	jmp    8005b2 <getuint+0x38>
	else if (lflag)
  800590:	85 d2                	test   %edx,%edx
  800592:	74 10                	je     8005a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800594:	8b 10                	mov    (%eax),%edx
  800596:	8d 4a 04             	lea    0x4(%edx),%ecx
  800599:	89 08                	mov    %ecx,(%eax)
  80059b:	8b 02                	mov    (%edx),%eax
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a2:	eb 0e                	jmp    8005b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a9:	89 08                	mov    %ecx,(%eax)
  8005ab:	8b 02                	mov    (%edx),%eax
  8005ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005b2:	5d                   	pop    %ebp
  8005b3:	c3                   	ret    

008005b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ba:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005bd:	8b 10                	mov    (%eax),%edx
  8005bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c2:	73 08                	jae    8005cc <sprintputch+0x18>
		*b->buf++ = ch;
  8005c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c7:	88 0a                	mov    %cl,(%edx)
  8005c9:	42                   	inc    %edx
  8005ca:	89 10                	mov    %edx,(%eax)
}
  8005cc:	5d                   	pop    %ebp
  8005cd:	c3                   	ret    

008005ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
  8005d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005db:	8b 45 10             	mov    0x10(%ebp),%eax
  8005de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 02 00 00 00       	call   8005f6 <vprintfmt>
	va_end(ap);
}
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	57                   	push   %edi
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
  8005fc:	83 ec 4c             	sub    $0x4c,%esp
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	8b 75 10             	mov    0x10(%ebp),%esi
  800605:	eb 12                	jmp    800619 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800607:	85 c0                	test   %eax,%eax
  800609:	0f 84 6b 03 00 00    	je     80097a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800619:	0f b6 06             	movzbl (%esi),%eax
  80061c:	46                   	inc    %esi
  80061d:	83 f8 25             	cmp    $0x25,%eax
  800620:	75 e5                	jne    800607 <vprintfmt+0x11>
  800622:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800626:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80062d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800632:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063e:	eb 26                	jmp    800666 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800643:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800647:	eb 1d                	jmp    800666 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80064c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800650:	eb 14                	jmp    800666 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800655:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80065c:	eb 08                	jmp    800666 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80065e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800661:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	0f b6 06             	movzbl (%esi),%eax
  800669:	8d 56 01             	lea    0x1(%esi),%edx
  80066c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80066f:	8a 16                	mov    (%esi),%dl
  800671:	83 ea 23             	sub    $0x23,%edx
  800674:	80 fa 55             	cmp    $0x55,%dl
  800677:	0f 87 e1 02 00 00    	ja     80095e <vprintfmt+0x368>
  80067d:	0f b6 d2             	movzbl %dl,%edx
  800680:	ff 24 95 00 27 80 00 	jmp    *0x802700(,%edx,4)
  800687:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80068f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800692:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800696:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800699:	8d 50 d0             	lea    -0x30(%eax),%edx
  80069c:	83 fa 09             	cmp    $0x9,%edx
  80069f:	77 2a                	ja     8006cb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006a2:	eb eb                	jmp    80068f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006b2:	eb 17                	jmp    8006cb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b8:	78 98                	js     800652 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006bd:	eb a7                	jmp    800666 <vprintfmt+0x70>
  8006bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006c2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006c9:	eb 9b                	jmp    800666 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cf:	79 95                	jns    800666 <vprintfmt+0x70>
  8006d1:	eb 8b                	jmp    80065e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006d7:	eb 8d                	jmp    800666 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 50 04             	lea    0x4(%eax),%edx
  8006df:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e6:	8b 00                	mov    (%eax),%eax
  8006e8:	89 04 24             	mov    %eax,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f1:	e9 23 ff ff ff       	jmp    800619 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	85 c0                	test   %eax,%eax
  800703:	79 02                	jns    800707 <vprintfmt+0x111>
  800705:	f7 d8                	neg    %eax
  800707:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800709:	83 f8 0f             	cmp    $0xf,%eax
  80070c:	7f 0b                	jg     800719 <vprintfmt+0x123>
  80070e:	8b 04 85 60 28 80 00 	mov    0x802860(,%eax,4),%eax
  800715:	85 c0                	test   %eax,%eax
  800717:	75 23                	jne    80073c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800719:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80071d:	c7 44 24 08 d3 25 80 	movl   $0x8025d3,0x8(%esp)
  800724:	00 
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	e8 9a fe ff ff       	call   8005ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800734:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800737:	e9 dd fe ff ff       	jmp    800619 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80073c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800740:	c7 44 24 08 95 29 80 	movl   $0x802995,0x8(%esp)
  800747:	00 
  800748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074c:	8b 55 08             	mov    0x8(%ebp),%edx
  80074f:	89 14 24             	mov    %edx,(%esp)
  800752:	e8 77 fe ff ff       	call   8005ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80075a:	e9 ba fe ff ff       	jmp    800619 <vprintfmt+0x23>
  80075f:	89 f9                	mov    %edi,%ecx
  800761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800764:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 50 04             	lea    0x4(%eax),%edx
  80076d:	89 55 14             	mov    %edx,0x14(%ebp)
  800770:	8b 30                	mov    (%eax),%esi
  800772:	85 f6                	test   %esi,%esi
  800774:	75 05                	jne    80077b <vprintfmt+0x185>
				p = "(null)";
  800776:	be cc 25 80 00       	mov    $0x8025cc,%esi
			if (width > 0 && padc != '-')
  80077b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077f:	0f 8e 84 00 00 00    	jle    800809 <vprintfmt+0x213>
  800785:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800789:	74 7e                	je     800809 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80078b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078f:	89 34 24             	mov    %esi,(%esp)
  800792:	e8 8b 02 00 00       	call   800a22 <strnlen>
  800797:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80079a:	29 c2                	sub    %eax,%edx
  80079c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80079f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007a9:	89 de                	mov    %ebx,%esi
  8007ab:	89 d3                	mov    %edx,%ebx
  8007ad:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	eb 0b                	jmp    8007bc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b5:	89 3c 24             	mov    %edi,(%esp)
  8007b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bb:	4b                   	dec    %ebx
  8007bc:	85 db                	test   %ebx,%ebx
  8007be:	7f f1                	jg     8007b1 <vprintfmt+0x1bb>
  8007c0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007c3:	89 f3                	mov    %esi,%ebx
  8007c5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	79 05                	jns    8007d4 <vprintfmt+0x1de>
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d7:	29 c2                	sub    %eax,%edx
  8007d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007dc:	eb 2b                	jmp    800809 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007de:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e2:	74 18                	je     8007fc <vprintfmt+0x206>
  8007e4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007e7:	83 fa 5e             	cmp    $0x5e,%edx
  8007ea:	76 10                	jbe    8007fc <vprintfmt+0x206>
					putch('?', putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
  8007fa:	eb 0a                	jmp    800806 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800806:	ff 4d e4             	decl   -0x1c(%ebp)
  800809:	0f be 06             	movsbl (%esi),%eax
  80080c:	46                   	inc    %esi
  80080d:	85 c0                	test   %eax,%eax
  80080f:	74 21                	je     800832 <vprintfmt+0x23c>
  800811:	85 ff                	test   %edi,%edi
  800813:	78 c9                	js     8007de <vprintfmt+0x1e8>
  800815:	4f                   	dec    %edi
  800816:	79 c6                	jns    8007de <vprintfmt+0x1e8>
  800818:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081b:	89 de                	mov    %ebx,%esi
  80081d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800820:	eb 18                	jmp    80083a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800822:	89 74 24 04          	mov    %esi,0x4(%esp)
  800826:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80082d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082f:	4b                   	dec    %ebx
  800830:	eb 08                	jmp    80083a <vprintfmt+0x244>
  800832:	8b 7d 08             	mov    0x8(%ebp),%edi
  800835:	89 de                	mov    %ebx,%esi
  800837:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80083a:	85 db                	test   %ebx,%ebx
  80083c:	7f e4                	jg     800822 <vprintfmt+0x22c>
  80083e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800841:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800843:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800846:	e9 ce fd ff ff       	jmp    800619 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80084b:	83 f9 01             	cmp    $0x1,%ecx
  80084e:	7e 10                	jle    800860 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 08             	lea    0x8(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 30                	mov    (%eax),%esi
  80085b:	8b 78 04             	mov    0x4(%eax),%edi
  80085e:	eb 26                	jmp    800886 <vprintfmt+0x290>
	else if (lflag)
  800860:	85 c9                	test   %ecx,%ecx
  800862:	74 12                	je     800876 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8d 50 04             	lea    0x4(%eax),%edx
  80086a:	89 55 14             	mov    %edx,0x14(%ebp)
  80086d:	8b 30                	mov    (%eax),%esi
  80086f:	89 f7                	mov    %esi,%edi
  800871:	c1 ff 1f             	sar    $0x1f,%edi
  800874:	eb 10                	jmp    800886 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)
  80087f:	8b 30                	mov    (%eax),%esi
  800881:	89 f7                	mov    %esi,%edi
  800883:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800886:	85 ff                	test   %edi,%edi
  800888:	78 0a                	js     800894 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80088a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088f:	e9 8c 00 00 00       	jmp    800920 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800894:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800898:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80089f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008a2:	f7 de                	neg    %esi
  8008a4:	83 d7 00             	adc    $0x0,%edi
  8008a7:	f7 df                	neg    %edi
			}
			base = 10;
  8008a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ae:	eb 70                	jmp    800920 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008b0:	89 ca                	mov    %ecx,%edx
  8008b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b5:	e8 c0 fc ff ff       	call   80057a <getuint>
  8008ba:	89 c6                	mov    %eax,%esi
  8008bc:	89 d7                	mov    %edx,%edi
			base = 10;
  8008be:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008c3:	eb 5b                	jmp    800920 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8008c5:	89 ca                	mov    %ecx,%edx
  8008c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ca:	e8 ab fc ff ff       	call   80057a <getuint>
  8008cf:	89 c6                	mov    %eax,%esi
  8008d1:	89 d7                	mov    %edx,%edi
			base = 8;
  8008d3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008d8:	eb 46                	jmp    800920 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008e5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8d 50 04             	lea    0x4(%eax),%edx
  8008fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ff:	8b 30                	mov    (%eax),%esi
  800901:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800906:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80090b:	eb 13                	jmp    800920 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80090d:	89 ca                	mov    %ecx,%edx
  80090f:	8d 45 14             	lea    0x14(%ebp),%eax
  800912:	e8 63 fc ff ff       	call   80057a <getuint>
  800917:	89 c6                	mov    %eax,%esi
  800919:	89 d7                	mov    %edx,%edi
			base = 16;
  80091b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800920:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800924:	89 54 24 10          	mov    %edx,0x10(%esp)
  800928:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80092f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800933:	89 34 24             	mov    %esi,(%esp)
  800936:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80093a:	89 da                	mov    %ebx,%edx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	e8 6c fb ff ff       	call   8004b0 <printnum>
			break;
  800944:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800947:	e9 cd fc ff ff       	jmp    800619 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800959:	e9 bb fc ff ff       	jmp    800619 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800962:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800969:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096c:	eb 01                	jmp    80096f <vprintfmt+0x379>
  80096e:	4e                   	dec    %esi
  80096f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800973:	75 f9                	jne    80096e <vprintfmt+0x378>
  800975:	e9 9f fc ff ff       	jmp    800619 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80097a:	83 c4 4c             	add    $0x4c,%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 28             	sub    $0x28,%esp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800991:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800995:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800998:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	74 30                	je     8009d3 <vsnprintf+0x51>
  8009a3:	85 d2                	test   %edx,%edx
  8009a5:	7e 33                	jle    8009da <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bc:	c7 04 24 b4 05 80 00 	movl   $0x8005b4,(%esp)
  8009c3:	e8 2e fc ff ff       	call   8005f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d1:	eb 0c                	jmp    8009df <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d8:	eb 05                	jmp    8009df <vsnprintf+0x5d>
  8009da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	89 04 24             	mov    %eax,(%esp)
  800a02:	e8 7b ff ff ff       	call   800982 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    
  800a09:	00 00                	add    %al,(%eax)
	...

00800a0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	eb 01                	jmp    800a1a <strlen+0xe>
		n++;
  800a19:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1e:	75 f9                	jne    800a19 <strlen+0xd>
		n++;
	return n;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	eb 01                	jmp    800a33 <strnlen+0x11>
		n++;
  800a32:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	74 06                	je     800a3d <strnlen+0x1b>
  800a37:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a3b:	75 f5                	jne    800a32 <strnlen+0x10>
		n++;
	return n;
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a51:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a54:	42                   	inc    %edx
  800a55:	84 c9                	test   %cl,%cl
  800a57:	75 f5                	jne    800a4e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a66:	89 1c 24             	mov    %ebx,(%esp)
  800a69:	e8 9e ff ff ff       	call   800a0c <strlen>
	strcpy(dst + len, src);
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a75:	01 d8                	add    %ebx,%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 c0 ff ff ff       	call   800a3f <strcpy>
	return dst;
}
  800a7f:	89 d8                	mov    %ebx,%eax
  800a81:	83 c4 08             	add    $0x8,%esp
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a92:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9a:	eb 0c                	jmp    800aa8 <strncpy+0x21>
		*dst++ = *src;
  800a9c:	8a 1a                	mov    (%edx),%bl
  800a9e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa1:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa7:	41                   	inc    %ecx
  800aa8:	39 f1                	cmp    %esi,%ecx
  800aaa:	75 f0                	jne    800a9c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abe:	85 d2                	test   %edx,%edx
  800ac0:	75 0a                	jne    800acc <strlcpy+0x1c>
  800ac2:	89 f0                	mov    %esi,%eax
  800ac4:	eb 1a                	jmp    800ae0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac6:	88 18                	mov    %bl,(%eax)
  800ac8:	40                   	inc    %eax
  800ac9:	41                   	inc    %ecx
  800aca:	eb 02                	jmp    800ace <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800acc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ace:	4a                   	dec    %edx
  800acf:	74 0a                	je     800adb <strlcpy+0x2b>
  800ad1:	8a 19                	mov    (%ecx),%bl
  800ad3:	84 db                	test   %bl,%bl
  800ad5:	75 ef                	jne    800ac6 <strlcpy+0x16>
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	eb 02                	jmp    800add <strlcpy+0x2d>
  800adb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800add:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ae0:	29 f0                	sub    %esi,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aef:	eb 02                	jmp    800af3 <strcmp+0xd>
		p++, q++;
  800af1:	41                   	inc    %ecx
  800af2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af3:	8a 01                	mov    (%ecx),%al
  800af5:	84 c0                	test   %al,%al
  800af7:	74 04                	je     800afd <strcmp+0x17>
  800af9:	3a 02                	cmp    (%edx),%al
  800afb:	74 f4                	je     800af1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800afd:	0f b6 c0             	movzbl %al,%eax
  800b00:	0f b6 12             	movzbl (%edx),%edx
  800b03:	29 d0                	sub    %edx,%eax
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b14:	eb 03                	jmp    800b19 <strncmp+0x12>
		n--, p++, q++;
  800b16:	4a                   	dec    %edx
  800b17:	40                   	inc    %eax
  800b18:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b19:	85 d2                	test   %edx,%edx
  800b1b:	74 14                	je     800b31 <strncmp+0x2a>
  800b1d:	8a 18                	mov    (%eax),%bl
  800b1f:	84 db                	test   %bl,%bl
  800b21:	74 04                	je     800b27 <strncmp+0x20>
  800b23:	3a 19                	cmp    (%ecx),%bl
  800b25:	74 ef                	je     800b16 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b27:	0f b6 00             	movzbl (%eax),%eax
  800b2a:	0f b6 11             	movzbl (%ecx),%edx
  800b2d:	29 d0                	sub    %edx,%eax
  800b2f:	eb 05                	jmp    800b36 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b42:	eb 05                	jmp    800b49 <strchr+0x10>
		if (*s == c)
  800b44:	38 ca                	cmp    %cl,%dl
  800b46:	74 0c                	je     800b54 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b48:	40                   	inc    %eax
  800b49:	8a 10                	mov    (%eax),%dl
  800b4b:	84 d2                	test   %dl,%dl
  800b4d:	75 f5                	jne    800b44 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5f:	eb 05                	jmp    800b66 <strfind+0x10>
		if (*s == c)
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 07                	je     800b6c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b65:	40                   	inc    %eax
  800b66:	8a 10                	mov    (%eax),%dl
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 f5                	jne    800b61 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7d:	85 c9                	test   %ecx,%ecx
  800b7f:	74 30                	je     800bb1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b87:	75 25                	jne    800bae <memset+0x40>
  800b89:	f6 c1 03             	test   $0x3,%cl
  800b8c:	75 20                	jne    800bae <memset+0x40>
		c &= 0xFF;
  800b8e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	c1 e3 08             	shl    $0x8,%ebx
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	c1 e6 18             	shl    $0x18,%esi
  800b9b:	89 d0                	mov    %edx,%eax
  800b9d:	c1 e0 10             	shl    $0x10,%eax
  800ba0:	09 f0                	or     %esi,%eax
  800ba2:	09 d0                	or     %edx,%eax
  800ba4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba9:	fc                   	cld    
  800baa:	f3 ab                	rep stos %eax,%es:(%edi)
  800bac:	eb 03                	jmp    800bb1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bae:	fc                   	cld    
  800baf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb1:	89 f8                	mov    %edi,%eax
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc6:	39 c6                	cmp    %eax,%esi
  800bc8:	73 34                	jae    800bfe <memmove+0x46>
  800bca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bcd:	39 d0                	cmp    %edx,%eax
  800bcf:	73 2d                	jae    800bfe <memmove+0x46>
		s += n;
		d += n;
  800bd1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd4:	f6 c2 03             	test   $0x3,%dl
  800bd7:	75 1b                	jne    800bf4 <memmove+0x3c>
  800bd9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdf:	75 13                	jne    800bf4 <memmove+0x3c>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 0e                	jne    800bf4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be6:	83 ef 04             	sub    $0x4,%edi
  800be9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bef:	fd                   	std    
  800bf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf2:	eb 07                	jmp    800bfb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf4:	4f                   	dec    %edi
  800bf5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf8:	fd                   	std    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bfb:	fc                   	cld    
  800bfc:	eb 20                	jmp    800c1e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c04:	75 13                	jne    800c19 <memmove+0x61>
  800c06:	a8 03                	test   $0x3,%al
  800c08:	75 0f                	jne    800c19 <memmove+0x61>
  800c0a:	f6 c1 03             	test   $0x3,%cl
  800c0d:	75 0a                	jne    800c19 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	fc                   	cld    
  800c15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c17:	eb 05                	jmp    800c1e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	fc                   	cld    
  800c1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c28:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	89 04 24             	mov    %eax,(%esp)
  800c3c:	e8 77 ff ff ff       	call   800bb8 <memmove>
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c52:	ba 00 00 00 00       	mov    $0x0,%edx
  800c57:	eb 16                	jmp    800c6f <memcmp+0x2c>
		if (*s1 != *s2)
  800c59:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c5c:	42                   	inc    %edx
  800c5d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c61:	38 c8                	cmp    %cl,%al
  800c63:	74 0a                	je     800c6f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c65:	0f b6 c0             	movzbl %al,%eax
  800c68:	0f b6 c9             	movzbl %cl,%ecx
  800c6b:	29 c8                	sub    %ecx,%eax
  800c6d:	eb 09                	jmp    800c78 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6f:	39 da                	cmp    %ebx,%edx
  800c71:	75 e6                	jne    800c59 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c86:	89 c2                	mov    %eax,%edx
  800c88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c8b:	eb 05                	jmp    800c92 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8d:	38 08                	cmp    %cl,(%eax)
  800c8f:	74 05                	je     800c96 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c91:	40                   	inc    %eax
  800c92:	39 d0                	cmp    %edx,%eax
  800c94:	72 f7                	jb     800c8d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca4:	eb 01                	jmp    800ca7 <strtol+0xf>
		s++;
  800ca6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca7:	8a 02                	mov    (%edx),%al
  800ca9:	3c 20                	cmp    $0x20,%al
  800cab:	74 f9                	je     800ca6 <strtol+0xe>
  800cad:	3c 09                	cmp    $0x9,%al
  800caf:	74 f5                	je     800ca6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb1:	3c 2b                	cmp    $0x2b,%al
  800cb3:	75 08                	jne    800cbd <strtol+0x25>
		s++;
  800cb5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbb:	eb 13                	jmp    800cd0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cbd:	3c 2d                	cmp    $0x2d,%al
  800cbf:	75 0a                	jne    800ccb <strtol+0x33>
		s++, neg = 1;
  800cc1:	8d 52 01             	lea    0x1(%edx),%edx
  800cc4:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc9:	eb 05                	jmp    800cd0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ccb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd0:	85 db                	test   %ebx,%ebx
  800cd2:	74 05                	je     800cd9 <strtol+0x41>
  800cd4:	83 fb 10             	cmp    $0x10,%ebx
  800cd7:	75 28                	jne    800d01 <strtol+0x69>
  800cd9:	8a 02                	mov    (%edx),%al
  800cdb:	3c 30                	cmp    $0x30,%al
  800cdd:	75 10                	jne    800cef <strtol+0x57>
  800cdf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ce3:	75 0a                	jne    800cef <strtol+0x57>
		s += 2, base = 16;
  800ce5:	83 c2 02             	add    $0x2,%edx
  800ce8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ced:	eb 12                	jmp    800d01 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cef:	85 db                	test   %ebx,%ebx
  800cf1:	75 0e                	jne    800d01 <strtol+0x69>
  800cf3:	3c 30                	cmp    $0x30,%al
  800cf5:	75 05                	jne    800cfc <strtol+0x64>
		s++, base = 8;
  800cf7:	42                   	inc    %edx
  800cf8:	b3 08                	mov    $0x8,%bl
  800cfa:	eb 05                	jmp    800d01 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cfc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d08:	8a 0a                	mov    (%edx),%cl
  800d0a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d0d:	80 fb 09             	cmp    $0x9,%bl
  800d10:	77 08                	ja     800d1a <strtol+0x82>
			dig = *s - '0';
  800d12:	0f be c9             	movsbl %cl,%ecx
  800d15:	83 e9 30             	sub    $0x30,%ecx
  800d18:	eb 1e                	jmp    800d38 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d1a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d1d:	80 fb 19             	cmp    $0x19,%bl
  800d20:	77 08                	ja     800d2a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d22:	0f be c9             	movsbl %cl,%ecx
  800d25:	83 e9 57             	sub    $0x57,%ecx
  800d28:	eb 0e                	jmp    800d38 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d2a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d2d:	80 fb 19             	cmp    $0x19,%bl
  800d30:	77 12                	ja     800d44 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d32:	0f be c9             	movsbl %cl,%ecx
  800d35:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d38:	39 f1                	cmp    %esi,%ecx
  800d3a:	7d 0c                	jge    800d48 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d3c:	42                   	inc    %edx
  800d3d:	0f af c6             	imul   %esi,%eax
  800d40:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d42:	eb c4                	jmp    800d08 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d44:	89 c1                	mov    %eax,%ecx
  800d46:	eb 02                	jmp    800d4a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d48:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4e:	74 05                	je     800d55 <strtol+0xbd>
		*endptr = (char *) s;
  800d50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d53:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d55:	85 ff                	test   %edi,%edi
  800d57:	74 04                	je     800d5d <strtol+0xc5>
  800d59:	89 c8                	mov    %ecx,%eax
  800d5b:	f7 d8                	neg    %eax
}
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
	...

00800d64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 c3                	mov    %eax,%ebx
  800d77:	89 c7                	mov    %eax,%edi
  800d79:	89 c6                	mov    %eax,%esi
  800d7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d92:	89 d1                	mov    %edx,%ecx
  800d94:	89 d3                	mov    %edx,%ebx
  800d96:	89 d7                	mov    %edx,%edi
  800d98:	89 d6                	mov    %edx,%esi
  800d9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daf:	b8 03 00 00 00       	mov    $0x3,%eax
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 cb                	mov    %ecx,%ebx
  800db9:	89 cf                	mov    %ecx,%edi
  800dbb:	89 ce                	mov    %ecx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 28                	jle    800deb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dde:	00 
  800ddf:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800de6:	e8 b1 f5 ff ff       	call   80039c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800deb:	83 c4 2c             	add    $0x2c,%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfe:	b8 02 00 00 00       	mov    $0x2,%eax
  800e03:	89 d1                	mov    %edx,%ecx
  800e05:	89 d3                	mov    %edx,%ebx
  800e07:	89 d7                	mov    %edx,%edi
  800e09:	89 d6                	mov    %edx,%esi
  800e0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_yield>:

void
sys_yield(void)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e22:	89 d1                	mov    %edx,%ecx
  800e24:	89 d3                	mov    %edx,%ebx
  800e26:	89 d7                	mov    %edx,%edi
  800e28:	89 d6                	mov    %edx,%esi
  800e2a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800e3a:	be 00 00 00 00       	mov    $0x0,%esi
  800e3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4d:	89 f7                	mov    %esi,%edi
  800e4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 28                	jle    800e7d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e59:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e60:	00 
  800e61:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800e78:	e8 1f f5 ff ff       	call   80039c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e7d:	83 c4 2c             	add    $0x2c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e93:	8b 75 18             	mov    0x18(%ebp),%esi
  800e96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 28                	jle    800ed0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eac:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec3:	00 
  800ec4:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800ecb:	e8 cc f4 ff ff       	call   80039c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ed0:	83 c4 2c             	add    $0x2c,%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee6:	b8 06 00 00 00       	mov    $0x6,%eax
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 df                	mov    %ebx,%edi
  800ef3:	89 de                	mov    %ebx,%esi
  800ef5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	7e 28                	jle    800f23 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eff:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f06:	00 
  800f07:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f16:	00 
  800f17:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800f1e:	e8 79 f4 ff ff       	call   80039c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f23:	83 c4 2c             	add    $0x2c,%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f39:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	89 df                	mov    %ebx,%edi
  800f46:	89 de                	mov    %ebx,%esi
  800f48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	7e 28                	jle    800f76 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f52:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800f71:	e8 26 f4 ff ff       	call   80039c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f76:	83 c4 2c             	add    $0x2c,%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8c:	b8 09 00 00 00       	mov    $0x9,%eax
  800f91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f94:	8b 55 08             	mov    0x8(%ebp),%edx
  800f97:	89 df                	mov    %ebx,%edi
  800f99:	89 de                	mov    %ebx,%esi
  800f9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	7e 28                	jle    800fc9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fac:	00 
  800fad:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  800fc4:	e8 d3 f3 ff ff       	call   80039c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc9:	83 c4 2c             	add    $0x2c,%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fe4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	89 df                	mov    %ebx,%edi
  800fec:	89 de                	mov    %ebx,%esi
  800fee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	7e 28                	jle    80101c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fff:	00 
  801000:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  801007:	00 
  801008:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100f:	00 
  801010:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  801017:	e8 80 f3 ff ff       	call   80039c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80101c:	83 c4 2c             	add    $0x2c,%esp
  80101f:	5b                   	pop    %ebx
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102a:	be 00 00 00 00       	mov    $0x0,%esi
  80102f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801034:	8b 7d 14             	mov    0x14(%ebp),%edi
  801037:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80103a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103d:	8b 55 08             	mov    0x8(%ebp),%edx
  801040:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	57                   	push   %edi
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
  80104d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801050:	b9 00 00 00 00       	mov    $0x0,%ecx
  801055:	b8 0d 00 00 00       	mov    $0xd,%eax
  80105a:	8b 55 08             	mov    0x8(%ebp),%edx
  80105d:	89 cb                	mov    %ecx,%ebx
  80105f:	89 cf                	mov    %ecx,%edi
  801061:	89 ce                	mov    %ecx,%esi
  801063:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801065:	85 c0                	test   %eax,%eax
  801067:	7e 28                	jle    801091 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801069:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801074:	00 
  801075:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  80107c:	00 
  80107d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801084:	00 
  801085:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  80108c:	e8 0b f3 ff ff       	call   80039c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801091:	83 c4 2c             	add    $0x2c,%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	00 00                	add    %al,(%eax)
	...

0080109c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8010a8:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8010aa:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8010ad:	83 3a 01             	cmpl   $0x1,(%edx)
  8010b0:	7e 0b                	jle    8010bd <argstart+0x21>
  8010b2:	85 c9                	test   %ecx,%ecx
  8010b4:	75 0e                	jne    8010c4 <argstart+0x28>
  8010b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bb:	eb 0c                	jmp    8010c9 <argstart+0x2d>
  8010bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c2:	eb 05                	jmp    8010c9 <argstart+0x2d>
  8010c4:	ba eb 29 80 00       	mov    $0x8029eb,%edx
  8010c9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8010cc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <argnext>:

int
argnext(struct Argstate *args)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 14             	sub    $0x14,%esp
  8010dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8010df:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8010e6:	8b 43 08             	mov    0x8(%ebx),%eax
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	74 6c                	je     801159 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  8010ed:	80 38 00             	cmpb   $0x0,(%eax)
  8010f0:	75 4d                	jne    80113f <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8010f2:	8b 0b                	mov    (%ebx),%ecx
  8010f4:	83 39 01             	cmpl   $0x1,(%ecx)
  8010f7:	74 52                	je     80114b <argnext+0x76>
		    || args->argv[1][0] != '-'
  8010f9:	8b 53 04             	mov    0x4(%ebx),%edx
  8010fc:	8b 42 04             	mov    0x4(%edx),%eax
  8010ff:	80 38 2d             	cmpb   $0x2d,(%eax)
  801102:	75 47                	jne    80114b <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801104:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801108:	74 41                	je     80114b <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80110a:	40                   	inc    %eax
  80110b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80110e:	8b 01                	mov    (%ecx),%eax
  801110:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801117:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111b:	8d 42 08             	lea    0x8(%edx),%eax
  80111e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801122:	83 c2 04             	add    $0x4,%edx
  801125:	89 14 24             	mov    %edx,(%esp)
  801128:	e8 8b fa ff ff       	call   800bb8 <memmove>
		(*args->argc)--;
  80112d:	8b 03                	mov    (%ebx),%eax
  80112f:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801131:	8b 43 08             	mov    0x8(%ebx),%eax
  801134:	80 38 2d             	cmpb   $0x2d,(%eax)
  801137:	75 06                	jne    80113f <argnext+0x6a>
  801139:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80113d:	74 0c                	je     80114b <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80113f:	8b 53 08             	mov    0x8(%ebx),%edx
  801142:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801145:	42                   	inc    %edx
  801146:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801149:	eb 13                	jmp    80115e <argnext+0x89>

    endofargs:
	args->curarg = 0;
  80114b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801152:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801157:	eb 05                	jmp    80115e <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80115e:	83 c4 14             	add    $0x14,%esp
  801161:	5b                   	pop    %ebx
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	53                   	push   %ebx
  801168:	83 ec 14             	sub    $0x14,%esp
  80116b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80116e:	8b 43 08             	mov    0x8(%ebx),%eax
  801171:	85 c0                	test   %eax,%eax
  801173:	74 59                	je     8011ce <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801175:	80 38 00             	cmpb   $0x0,(%eax)
  801178:	74 0c                	je     801186 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80117a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80117d:	c7 43 08 eb 29 80 00 	movl   $0x8029eb,0x8(%ebx)
  801184:	eb 43                	jmp    8011c9 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801186:	8b 03                	mov    (%ebx),%eax
  801188:	83 38 01             	cmpl   $0x1,(%eax)
  80118b:	7e 2e                	jle    8011bb <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  80118d:	8b 53 04             	mov    0x4(%ebx),%edx
  801190:	8b 4a 04             	mov    0x4(%edx),%ecx
  801193:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801196:	8b 00                	mov    (%eax),%eax
  801198:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80119f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a3:	8d 42 08             	lea    0x8(%edx),%eax
  8011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011aa:	83 c2 04             	add    $0x4,%edx
  8011ad:	89 14 24             	mov    %edx,(%esp)
  8011b0:	e8 03 fa ff ff       	call   800bb8 <memmove>
		(*args->argc)--;
  8011b5:	8b 03                	mov    (%ebx),%eax
  8011b7:	ff 08                	decl   (%eax)
  8011b9:	eb 0e                	jmp    8011c9 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  8011bb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8011c2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8011c9:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011cc:	eb 05                	jmp    8011d3 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8011ce:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8011d3:	83 c4 14             	add    $0x14,%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 18             	sub    $0x18,%esp
  8011df:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8011e2:	8b 42 0c             	mov    0xc(%edx),%eax
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	75 08                	jne    8011f1 <argvalue+0x18>
  8011e9:	89 14 24             	mov    %edx,(%esp)
  8011ec:	e8 73 ff ff ff       	call   801164 <argnextvalue>
}
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    
	...

008011f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80120a:	8b 45 08             	mov    0x8(%ebp),%eax
  80120d:	89 04 24             	mov    %eax,(%esp)
  801210:	e8 df ff ff ff       	call   8011f4 <fd2num>
  801215:	05 20 00 0d 00       	add    $0xd0020,%eax
  80121a:	c1 e0 0c             	shl    $0xc,%eax
}
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	53                   	push   %ebx
  801223:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801226:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80122b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 16             	shr    $0x16,%edx
  801232:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	74 11                	je     80124f <fd_alloc+0x30>
  80123e:	89 c2                	mov    %eax,%edx
  801240:	c1 ea 0c             	shr    $0xc,%edx
  801243:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124a:	f6 c2 01             	test   $0x1,%dl
  80124d:	75 09                	jne    801258 <fd_alloc+0x39>
			*fd_store = fd;
  80124f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
  801256:	eb 17                	jmp    80126f <fd_alloc+0x50>
  801258:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80125d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801262:	75 c7                	jne    80122b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801264:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80126a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80126f:	5b                   	pop    %ebx
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801278:	83 f8 1f             	cmp    $0x1f,%eax
  80127b:	77 36                	ja     8012b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801282:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801285:	89 c2                	mov    %eax,%edx
  801287:	c1 ea 16             	shr    $0x16,%edx
  80128a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801291:	f6 c2 01             	test   $0x1,%dl
  801294:	74 24                	je     8012ba <fd_lookup+0x48>
  801296:	89 c2                	mov    %eax,%edx
  801298:	c1 ea 0c             	shr    $0xc,%edx
  80129b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a2:	f6 c2 01             	test   $0x1,%dl
  8012a5:	74 1a                	je     8012c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b1:	eb 13                	jmp    8012c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b8:	eb 0c                	jmp    8012c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bf:	eb 05                	jmp    8012c6 <fd_lookup+0x54>
  8012c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 14             	sub    $0x14,%esp
  8012cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012da:	eb 0e                	jmp    8012ea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8012dc:	39 08                	cmp    %ecx,(%eax)
  8012de:	75 09                	jne    8012e9 <dev_lookup+0x21>
			*dev = devtab[i];
  8012e0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e7:	eb 35                	jmp    80131e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e9:	42                   	inc    %edx
  8012ea:	8b 04 95 6c 29 80 00 	mov    0x80296c(,%edx,4),%eax
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	75 e7                	jne    8012dc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f5:	a1 20 44 80 00       	mov    0x804420,%eax
  8012fa:	8b 00                	mov    (%eax),%eax
  8012fc:	8b 40 48             	mov    0x48(%eax),%eax
  8012ff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	c7 04 24 ec 28 80 00 	movl   $0x8028ec,(%esp)
  80130e:	e8 81 f1 ff ff       	call   800494 <cprintf>
	*dev = 0;
  801313:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801319:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131e:	83 c4 14             	add    $0x14,%esp
  801321:	5b                   	pop    %ebx
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 30             	sub    $0x30,%esp
  80132c:	8b 75 08             	mov    0x8(%ebp),%esi
  80132f:	8a 45 0c             	mov    0xc(%ebp),%al
  801332:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801335:	89 34 24             	mov    %esi,(%esp)
  801338:	e8 b7 fe ff ff       	call   8011f4 <fd2num>
  80133d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801340:	89 54 24 04          	mov    %edx,0x4(%esp)
  801344:	89 04 24             	mov    %eax,(%esp)
  801347:	e8 26 ff ff ff       	call   801272 <fd_lookup>
  80134c:	89 c3                	mov    %eax,%ebx
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 05                	js     801357 <fd_close+0x33>
	    || fd != fd2)
  801352:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801355:	74 0d                	je     801364 <fd_close+0x40>
		return (must_exist ? r : 0);
  801357:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80135b:	75 46                	jne    8013a3 <fd_close+0x7f>
  80135d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801362:	eb 3f                	jmp    8013a3 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801364:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	8b 06                	mov    (%esi),%eax
  80136d:	89 04 24             	mov    %eax,(%esp)
  801370:	e8 53 ff ff ff       	call   8012c8 <dev_lookup>
  801375:	89 c3                	mov    %eax,%ebx
  801377:	85 c0                	test   %eax,%eax
  801379:	78 18                	js     801393 <fd_close+0x6f>
		if (dev->dev_close)
  80137b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137e:	8b 40 10             	mov    0x10(%eax),%eax
  801381:	85 c0                	test   %eax,%eax
  801383:	74 09                	je     80138e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801385:	89 34 24             	mov    %esi,(%esp)
  801388:	ff d0                	call   *%eax
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	eb 05                	jmp    801393 <fd_close+0x6f>
		else
			r = 0;
  80138e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801393:	89 74 24 04          	mov    %esi,0x4(%esp)
  801397:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80139e:	e8 35 fb ff ff       	call   800ed8 <sys_page_unmap>
	return r;
}
  8013a3:	89 d8                	mov    %ebx,%eax
  8013a5:	83 c4 30             	add    $0x30,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 ae fe ff ff       	call   801272 <fd_lookup>
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 13                	js     8013db <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013cf:	00 
  8013d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d3:	89 04 24             	mov    %eax,(%esp)
  8013d6:	e8 49 ff ff ff       	call   801324 <fd_close>
}
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <close_all>:

void
close_all(void)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e9:	89 1c 24             	mov    %ebx,(%esp)
  8013ec:	e8 bb ff ff ff       	call   8013ac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f1:	43                   	inc    %ebx
  8013f2:	83 fb 20             	cmp    $0x20,%ebx
  8013f5:	75 f2                	jne    8013e9 <close_all+0xc>
		close(i);
}
  8013f7:	83 c4 14             	add    $0x14,%esp
  8013fa:	5b                   	pop    %ebx
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	57                   	push   %edi
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 4c             	sub    $0x4c,%esp
  801406:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801409:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80140c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 57 fe ff ff       	call   801272 <fd_lookup>
  80141b:	89 c3                	mov    %eax,%ebx
  80141d:	85 c0                	test   %eax,%eax
  80141f:	0f 88 e1 00 00 00    	js     801506 <dup+0x109>
		return r;
	close(newfdnum);
  801425:	89 3c 24             	mov    %edi,(%esp)
  801428:	e8 7f ff ff ff       	call   8013ac <close>

	newfd = INDEX2FD(newfdnum);
  80142d:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801433:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801436:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801439:	89 04 24             	mov    %eax,(%esp)
  80143c:	e8 c3 fd ff ff       	call   801204 <fd2data>
  801441:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801443:	89 34 24             	mov    %esi,(%esp)
  801446:	e8 b9 fd ff ff       	call   801204 <fd2data>
  80144b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80144e:	89 d8                	mov    %ebx,%eax
  801450:	c1 e8 16             	shr    $0x16,%eax
  801453:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80145a:	a8 01                	test   $0x1,%al
  80145c:	74 46                	je     8014a4 <dup+0xa7>
  80145e:	89 d8                	mov    %ebx,%eax
  801460:	c1 e8 0c             	shr    $0xc,%eax
  801463:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80146a:	f6 c2 01             	test   $0x1,%dl
  80146d:	74 35                	je     8014a4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80146f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801476:	25 07 0e 00 00       	and    $0xe07,%eax
  80147b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801482:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801486:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80148d:	00 
  80148e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801492:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801499:	e8 e7 f9 ff ff       	call   800e85 <sys_page_map>
  80149e:	89 c3                	mov    %eax,%ebx
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 3b                	js     8014df <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	c1 ea 0c             	shr    $0xc,%edx
  8014ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014bd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c8:	00 
  8014c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d4:	e8 ac f9 ff ff       	call   800e85 <sys_page_map>
  8014d9:	89 c3                	mov    %eax,%ebx
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	79 25                	jns    801504 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ea:	e8 e9 f9 ff ff       	call   800ed8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fd:	e8 d6 f9 ff ff       	call   800ed8 <sys_page_unmap>
	return r;
  801502:	eb 02                	jmp    801506 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801504:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801506:	89 d8                	mov    %ebx,%eax
  801508:	83 c4 4c             	add    $0x4c,%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5f                   	pop    %edi
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    

00801510 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	53                   	push   %ebx
  801514:	83 ec 24             	sub    $0x24,%esp
  801517:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801521:	89 1c 24             	mov    %ebx,(%esp)
  801524:	e8 49 fd ff ff       	call   801272 <fd_lookup>
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 6f                	js     80159c <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801530:	89 44 24 04          	mov    %eax,0x4(%esp)
  801534:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801537:	8b 00                	mov    (%eax),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 87 fd ff ff       	call   8012c8 <dev_lookup>
  801541:	85 c0                	test   %eax,%eax
  801543:	78 57                	js     80159c <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801545:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801548:	8b 50 08             	mov    0x8(%eax),%edx
  80154b:	83 e2 03             	and    $0x3,%edx
  80154e:	83 fa 01             	cmp    $0x1,%edx
  801551:	75 25                	jne    801578 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801553:	a1 20 44 80 00       	mov    0x804420,%eax
  801558:	8b 00                	mov    (%eax),%eax
  80155a:	8b 40 48             	mov    0x48(%eax),%eax
  80155d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801561:	89 44 24 04          	mov    %eax,0x4(%esp)
  801565:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  80156c:	e8 23 ef ff ff       	call   800494 <cprintf>
		return -E_INVAL;
  801571:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801576:	eb 24                	jmp    80159c <read+0x8c>
	}
	if (!dev->dev_read)
  801578:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157b:	8b 52 08             	mov    0x8(%edx),%edx
  80157e:	85 d2                	test   %edx,%edx
  801580:	74 15                	je     801597 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801582:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801585:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801589:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801590:	89 04 24             	mov    %eax,(%esp)
  801593:	ff d2                	call   *%edx
  801595:	eb 05                	jmp    80159c <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801597:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80159c:	83 c4 24             	add    $0x24,%esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	57                   	push   %edi
  8015a6:	56                   	push   %esi
  8015a7:	53                   	push   %ebx
  8015a8:	83 ec 1c             	sub    $0x1c,%esp
  8015ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b6:	eb 23                	jmp    8015db <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b8:	89 f0                	mov    %esi,%eax
  8015ba:	29 d8                	sub    %ebx,%eax
  8015bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c3:	01 d8                	add    %ebx,%eax
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	89 3c 24             	mov    %edi,(%esp)
  8015cc:	e8 3f ff ff ff       	call   801510 <read>
		if (m < 0)
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 10                	js     8015e5 <readn+0x43>
			return m;
		if (m == 0)
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	74 0a                	je     8015e3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d9:	01 c3                	add    %eax,%ebx
  8015db:	39 f3                	cmp    %esi,%ebx
  8015dd:	72 d9                	jb     8015b8 <readn+0x16>
  8015df:	89 d8                	mov    %ebx,%eax
  8015e1:	eb 02                	jmp    8015e5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015e3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015e5:	83 c4 1c             	add    $0x1c,%esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 24             	sub    $0x24,%esp
  8015f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fe:	89 1c 24             	mov    %ebx,(%esp)
  801601:	e8 6c fc ff ff       	call   801272 <fd_lookup>
  801606:	85 c0                	test   %eax,%eax
  801608:	78 6a                	js     801674 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801614:	8b 00                	mov    (%eax),%eax
  801616:	89 04 24             	mov    %eax,(%esp)
  801619:	e8 aa fc ff ff       	call   8012c8 <dev_lookup>
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 52                	js     801674 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801622:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801625:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801629:	75 25                	jne    801650 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162b:	a1 20 44 80 00       	mov    0x804420,%eax
  801630:	8b 00                	mov    (%eax),%eax
  801632:	8b 40 48             	mov    0x48(%eax),%eax
  801635:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  801644:	e8 4b ee ff ff       	call   800494 <cprintf>
		return -E_INVAL;
  801649:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164e:	eb 24                	jmp    801674 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801650:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801653:	8b 52 0c             	mov    0xc(%edx),%edx
  801656:	85 d2                	test   %edx,%edx
  801658:	74 15                	je     80166f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80165d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801664:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801668:	89 04 24             	mov    %eax,(%esp)
  80166b:	ff d2                	call   *%edx
  80166d:	eb 05                	jmp    801674 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80166f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801674:	83 c4 24             	add    $0x24,%esp
  801677:	5b                   	pop    %ebx
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <seek>:

int
seek(int fdnum, off_t offset)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801680:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801683:	89 44 24 04          	mov    %eax,0x4(%esp)
  801687:	8b 45 08             	mov    0x8(%ebp),%eax
  80168a:	89 04 24             	mov    %eax,(%esp)
  80168d:	e8 e0 fb ff ff       	call   801272 <fd_lookup>
  801692:	85 c0                	test   %eax,%eax
  801694:	78 0e                	js     8016a4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801696:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801699:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 24             	sub    $0x24,%esp
  8016ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	89 1c 24             	mov    %ebx,(%esp)
  8016ba:	e8 b3 fb ff ff       	call   801272 <fd_lookup>
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 63                	js     801726 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	8b 00                	mov    (%eax),%eax
  8016cf:	89 04 24             	mov    %eax,(%esp)
  8016d2:	e8 f1 fb ff ff       	call   8012c8 <dev_lookup>
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 4b                	js     801726 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e2:	75 25                	jne    801709 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e4:	a1 20 44 80 00       	mov    0x804420,%eax
  8016e9:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016eb:	8b 40 48             	mov    0x48(%eax),%eax
  8016ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f6:	c7 04 24 0c 29 80 00 	movl   $0x80290c,(%esp)
  8016fd:	e8 92 ed ff ff       	call   800494 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801707:	eb 1d                	jmp    801726 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801709:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170c:	8b 52 18             	mov    0x18(%edx),%edx
  80170f:	85 d2                	test   %edx,%edx
  801711:	74 0e                	je     801721 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801716:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	ff d2                	call   *%edx
  80171f:	eb 05                	jmp    801726 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801721:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801726:	83 c4 24             	add    $0x24,%esp
  801729:	5b                   	pop    %ebx
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	53                   	push   %ebx
  801730:	83 ec 24             	sub    $0x24,%esp
  801733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801736:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	89 04 24             	mov    %eax,(%esp)
  801743:	e8 2a fb ff ff       	call   801272 <fd_lookup>
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 52                	js     80179e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801756:	8b 00                	mov    (%eax),%eax
  801758:	89 04 24             	mov    %eax,(%esp)
  80175b:	e8 68 fb ff ff       	call   8012c8 <dev_lookup>
  801760:	85 c0                	test   %eax,%eax
  801762:	78 3a                	js     80179e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801767:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176b:	74 2c                	je     801799 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801770:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801777:	00 00 00 
	stat->st_isdir = 0;
  80177a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801781:	00 00 00 
	stat->st_dev = dev;
  801784:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80178e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801791:	89 14 24             	mov    %edx,(%esp)
  801794:	ff 50 14             	call   *0x14(%eax)
  801797:	eb 05                	jmp    80179e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801799:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80179e:	83 c4 24             	add    $0x24,%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017b3:	00 
  8017b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b7:	89 04 24             	mov    %eax,(%esp)
  8017ba:	e8 88 02 00 00       	call   801a47 <open>
  8017bf:	89 c3                	mov    %eax,%ebx
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 1b                	js     8017e0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cc:	89 1c 24             	mov    %ebx,(%esp)
  8017cf:	e8 58 ff ff ff       	call   80172c <fstat>
  8017d4:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d6:	89 1c 24             	mov    %ebx,(%esp)
  8017d9:	e8 ce fb ff ff       	call   8013ac <close>
	return r;
  8017de:	89 f3                	mov    %esi,%ebx
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    
  8017e9:	00 00                	add    %al,(%eax)
	...

008017ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 10             	sub    $0x10,%esp
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017f8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ff:	75 11                	jne    801812 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801801:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801808:	e8 02 0a 00 00       	call   80220f <ipc_find_env>
  80180d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801812:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801819:	00 
  80181a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801821:	00 
  801822:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801826:	a1 00 40 80 00       	mov    0x804000,%eax
  80182b:	89 04 24             	mov    %eax,(%esp)
  80182e:	e8 76 09 00 00       	call   8021a9 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801833:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80183a:	00 
  80183b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80183f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801846:	e8 f1 08 00 00       	call   80213c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 40 0c             	mov    0xc(%eax),%eax
  80185e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801863:	8b 45 0c             	mov    0xc(%ebp),%eax
  801866:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	b8 02 00 00 00       	mov    $0x2,%eax
  801875:	e8 72 ff ff ff       	call   8017ec <fsipc>
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 40 0c             	mov    0xc(%eax),%eax
  801888:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	b8 06 00 00 00       	mov    $0x6,%eax
  801897:	e8 50 ff ff ff       	call   8017ec <fsipc>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 14             	sub    $0x14,%esp
  8018a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bd:	e8 2a ff ff ff       	call   8017ec <fsipc>
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 2b                	js     8018f1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018cd:	00 
  8018ce:	89 1c 24             	mov    %ebx,(%esp)
  8018d1:	e8 69 f1 ff ff       	call   800a3f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d6:	a1 80 50 80 00       	mov    0x805080,%eax
  8018db:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e1:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f1:	83 c4 14             	add    $0x14,%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 14             	sub    $0x14,%esp
  8018fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 40 0c             	mov    0xc(%eax),%eax
  801907:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  80190c:	89 d8                	mov    %ebx,%eax
  80190e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801914:	76 05                	jbe    80191b <devfile_write+0x24>
  801916:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80191b:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801920:	89 44 24 08          	mov    %eax,0x8(%esp)
  801924:	8b 45 0c             	mov    0xc(%ebp),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801932:	e8 eb f2 ff ff       	call   800c22 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801937:	ba 00 00 00 00       	mov    $0x0,%edx
  80193c:	b8 04 00 00 00       	mov    $0x4,%eax
  801941:	e8 a6 fe ff ff       	call   8017ec <fsipc>
  801946:	85 c0                	test   %eax,%eax
  801948:	78 53                	js     80199d <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  80194a:	39 c3                	cmp    %eax,%ebx
  80194c:	73 24                	jae    801972 <devfile_write+0x7b>
  80194e:	c7 44 24 0c 7c 29 80 	movl   $0x80297c,0xc(%esp)
  801955:	00 
  801956:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  80195d:	00 
  80195e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801965:	00 
  801966:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  80196d:	e8 2a ea ff ff       	call   80039c <_panic>
	assert(r <= PGSIZE);
  801972:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801977:	7e 24                	jle    80199d <devfile_write+0xa6>
  801979:	c7 44 24 0c a3 29 80 	movl   $0x8029a3,0xc(%esp)
  801980:	00 
  801981:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  801988:	00 
  801989:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801990:	00 
  801991:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  801998:	e8 ff e9 ff ff       	call   80039c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  80199d:	83 c4 14             	add    $0x14,%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 10             	sub    $0x10,%esp
  8019ab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019b9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c9:	e8 1e fe ff ff       	call   8017ec <fsipc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 6a                	js     801a3e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019d4:	39 c6                	cmp    %eax,%esi
  8019d6:	73 24                	jae    8019fc <devfile_read+0x59>
  8019d8:	c7 44 24 0c 7c 29 80 	movl   $0x80297c,0xc(%esp)
  8019df:	00 
  8019e0:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  8019e7:	00 
  8019e8:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8019ef:	00 
  8019f0:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  8019f7:	e8 a0 e9 ff ff       	call   80039c <_panic>
	assert(r <= PGSIZE);
  8019fc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a01:	7e 24                	jle    801a27 <devfile_read+0x84>
  801a03:	c7 44 24 0c a3 29 80 	movl   $0x8029a3,0xc(%esp)
  801a0a:	00 
  801a0b:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  801a12:	00 
  801a13:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801a1a:	00 
  801a1b:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  801a22:	e8 75 e9 ff ff       	call   80039c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a2b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a32:	00 
  801a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 7a f1 ff ff       	call   800bb8 <memmove>
	return r;
}
  801a3e:	89 d8                	mov    %ebx,%eax
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	5b                   	pop    %ebx
  801a44:	5e                   	pop    %esi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 20             	sub    $0x20,%esp
  801a4f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a52:	89 34 24             	mov    %esi,(%esp)
  801a55:	e8 b2 ef ff ff       	call   800a0c <strlen>
  801a5a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a5f:	7f 60                	jg     801ac1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a64:	89 04 24             	mov    %eax,(%esp)
  801a67:	e8 b3 f7 ff ff       	call   80121f <fd_alloc>
  801a6c:	89 c3                	mov    %eax,%ebx
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 54                	js     801ac6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a72:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a76:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a7d:	e8 bd ef ff ff       	call   800a3f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a85:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a92:	e8 55 fd ff ff       	call   8017ec <fsipc>
  801a97:	89 c3                	mov    %eax,%ebx
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	79 15                	jns    801ab2 <open+0x6b>
		fd_close(fd, 0);
  801a9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aa4:	00 
  801aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa8:	89 04 24             	mov    %eax,(%esp)
  801aab:	e8 74 f8 ff ff       	call   801324 <fd_close>
		return r;
  801ab0:	eb 14                	jmp    801ac6 <open+0x7f>
	}

	return fd2num(fd);
  801ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab5:	89 04 24             	mov    %eax,(%esp)
  801ab8:	e8 37 f7 ff ff       	call   8011f4 <fd2num>
  801abd:	89 c3                	mov    %eax,%ebx
  801abf:	eb 05                	jmp    801ac6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	83 c4 20             	add    $0x20,%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  801ada:	b8 08 00 00 00       	mov    $0x8,%eax
  801adf:	e8 08 fd ff ff       	call   8017ec <fsipc>
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    
	...

00801ae8 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	53                   	push   %ebx
  801aec:	83 ec 14             	sub    $0x14,%esp
  801aef:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801af1:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801af5:	7e 32                	jle    801b29 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801af7:	8b 40 04             	mov    0x4(%eax),%eax
  801afa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801afe:	8d 43 10             	lea    0x10(%ebx),%eax
  801b01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b05:	8b 03                	mov    (%ebx),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 de fa ff ff       	call   8015ed <write>
		if (result > 0)
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	7e 03                	jle    801b16 <writebuf+0x2e>
			b->result += result;
  801b13:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b16:	39 43 04             	cmp    %eax,0x4(%ebx)
  801b19:	74 0e                	je     801b29 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801b1b:	89 c2                	mov    %eax,%edx
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	7e 05                	jle    801b26 <writebuf+0x3e>
  801b21:	ba 00 00 00 00       	mov    $0x0,%edx
  801b26:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801b29:	83 c4 14             	add    $0x14,%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <putch>:

static void
putch(int ch, void *thunk)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	53                   	push   %ebx
  801b33:	83 ec 04             	sub    $0x4,%esp
  801b36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801b39:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  801b3f:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801b43:	40                   	inc    %eax
  801b44:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801b47:	3d 00 01 00 00       	cmp    $0x100,%eax
  801b4c:	75 0e                	jne    801b5c <putch+0x2d>
		writebuf(b);
  801b4e:	89 d8                	mov    %ebx,%eax
  801b50:	e8 93 ff ff ff       	call   801ae8 <writebuf>
		b->idx = 0;
  801b55:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801b5c:	83 c4 04             	add    $0x4,%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b74:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b7b:	00 00 00 
	b.result = 0;
  801b7e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b85:	00 00 00 
	b.error = 1;
  801b88:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b8f:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b92:	8b 45 10             	mov    0x10(%ebp),%eax
  801b95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801baa:	c7 04 24 2f 1b 80 00 	movl   $0x801b2f,(%esp)
  801bb1:	e8 40 ea ff ff       	call   8005f6 <vprintfmt>
	if (b.idx > 0)
  801bb6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801bbd:	7e 0b                	jle    801bca <vfprintf+0x68>
		writebuf(&b);
  801bbf:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801bc5:	e8 1e ff ff ff       	call   801ae8 <writebuf>

	return (b.result ? b.result : b.error);
  801bca:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	75 06                	jne    801bda <vfprintf+0x78>
  801bd4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801bda:	c9                   	leave  
  801bdb:	c3                   	ret    

00801bdc <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801be2:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	89 04 24             	mov    %eax,(%esp)
  801bf6:	e8 67 ff ff ff       	call   801b62 <vfprintf>
	va_end(ap);

	return cnt;
}
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    

00801bfd <printf>:

int
printf(const char *fmt, ...)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c03:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801c06:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c18:	e8 45 ff ff ff       	call   801b62 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    
	...

00801c20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	56                   	push   %esi
  801c24:	53                   	push   %ebx
  801c25:	83 ec 10             	sub    $0x10,%esp
  801c28:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	89 04 24             	mov    %eax,(%esp)
  801c31:	e8 ce f5 ff ff       	call   801204 <fd2data>
  801c36:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c38:	c7 44 24 04 af 29 80 	movl   $0x8029af,0x4(%esp)
  801c3f:	00 
  801c40:	89 34 24             	mov    %esi,(%esp)
  801c43:	e8 f7 ed ff ff       	call   800a3f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c48:	8b 43 04             	mov    0x4(%ebx),%eax
  801c4b:	2b 03                	sub    (%ebx),%eax
  801c4d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c53:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c5a:	00 00 00 
	stat->st_dev = &devpipe;
  801c5d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c64:	30 80 00 
	return 0;
}
  801c67:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	53                   	push   %ebx
  801c77:	83 ec 14             	sub    $0x14,%esp
  801c7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c88:	e8 4b f2 ff ff       	call   800ed8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c8d:	89 1c 24             	mov    %ebx,(%esp)
  801c90:	e8 6f f5 ff ff       	call   801204 <fd2data>
  801c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca0:	e8 33 f2 ff ff       	call   800ed8 <sys_page_unmap>
}
  801ca5:	83 c4 14             	add    $0x14,%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	57                   	push   %edi
  801caf:	56                   	push   %esi
  801cb0:	53                   	push   %ebx
  801cb1:	83 ec 2c             	sub    $0x2c,%esp
  801cb4:	89 c7                	mov    %eax,%edi
  801cb6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cb9:	a1 20 44 80 00       	mov    0x804420,%eax
  801cbe:	8b 00                	mov    (%eax),%eax
  801cc0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cc3:	89 3c 24             	mov    %edi,(%esp)
  801cc6:	e8 89 05 00 00       	call   802254 <pageref>
  801ccb:	89 c6                	mov    %eax,%esi
  801ccd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cd0:	89 04 24             	mov    %eax,(%esp)
  801cd3:	e8 7c 05 00 00       	call   802254 <pageref>
  801cd8:	39 c6                	cmp    %eax,%esi
  801cda:	0f 94 c0             	sete   %al
  801cdd:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ce0:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ce6:	8b 12                	mov    (%edx),%edx
  801ce8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ceb:	39 cb                	cmp    %ecx,%ebx
  801ced:	75 08                	jne    801cf7 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801cef:	83 c4 2c             	add    $0x2c,%esp
  801cf2:	5b                   	pop    %ebx
  801cf3:	5e                   	pop    %esi
  801cf4:	5f                   	pop    %edi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cf7:	83 f8 01             	cmp    $0x1,%eax
  801cfa:	75 bd                	jne    801cb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cfc:	8b 42 58             	mov    0x58(%edx),%eax
  801cff:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d06:	00 
  801d07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d0f:	c7 04 24 b6 29 80 00 	movl   $0x8029b6,(%esp)
  801d16:	e8 79 e7 ff ff       	call   800494 <cprintf>
  801d1b:	eb 9c                	jmp    801cb9 <_pipeisclosed+0xe>

00801d1d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	57                   	push   %edi
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	83 ec 1c             	sub    $0x1c,%esp
  801d26:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d29:	89 34 24             	mov    %esi,(%esp)
  801d2c:	e8 d3 f4 ff ff       	call   801204 <fd2data>
  801d31:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d33:	bf 00 00 00 00       	mov    $0x0,%edi
  801d38:	eb 3c                	jmp    801d76 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d3a:	89 da                	mov    %ebx,%edx
  801d3c:	89 f0                	mov    %esi,%eax
  801d3e:	e8 68 ff ff ff       	call   801cab <_pipeisclosed>
  801d43:	85 c0                	test   %eax,%eax
  801d45:	75 38                	jne    801d7f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d47:	e8 c6 f0 ff ff       	call   800e12 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d4c:	8b 43 04             	mov    0x4(%ebx),%eax
  801d4f:	8b 13                	mov    (%ebx),%edx
  801d51:	83 c2 20             	add    $0x20,%edx
  801d54:	39 d0                	cmp    %edx,%eax
  801d56:	73 e2                	jae    801d3a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d5e:	89 c2                	mov    %eax,%edx
  801d60:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d66:	79 05                	jns    801d6d <devpipe_write+0x50>
  801d68:	4a                   	dec    %edx
  801d69:	83 ca e0             	or     $0xffffffe0,%edx
  801d6c:	42                   	inc    %edx
  801d6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d71:	40                   	inc    %eax
  801d72:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d75:	47                   	inc    %edi
  801d76:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d79:	75 d1                	jne    801d4c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d7b:	89 f8                	mov    %edi,%eax
  801d7d:	eb 05                	jmp    801d84 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 1c             	sub    $0x1c,%esp
  801d95:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d98:	89 3c 24             	mov    %edi,(%esp)
  801d9b:	e8 64 f4 ff ff       	call   801204 <fd2data>
  801da0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da2:	be 00 00 00 00       	mov    $0x0,%esi
  801da7:	eb 3a                	jmp    801de3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801da9:	85 f6                	test   %esi,%esi
  801dab:	74 04                	je     801db1 <devpipe_read+0x25>
				return i;
  801dad:	89 f0                	mov    %esi,%eax
  801daf:	eb 40                	jmp    801df1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801db1:	89 da                	mov    %ebx,%edx
  801db3:	89 f8                	mov    %edi,%eax
  801db5:	e8 f1 fe ff ff       	call   801cab <_pipeisclosed>
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	75 2e                	jne    801dec <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dbe:	e8 4f f0 ff ff       	call   800e12 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dc3:	8b 03                	mov    (%ebx),%eax
  801dc5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dc8:	74 df                	je     801da9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dca:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dcf:	79 05                	jns    801dd6 <devpipe_read+0x4a>
  801dd1:	48                   	dec    %eax
  801dd2:	83 c8 e0             	or     $0xffffffe0,%eax
  801dd5:	40                   	inc    %eax
  801dd6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801dda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801de0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de2:	46                   	inc    %esi
  801de3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de6:	75 db                	jne    801dc3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801de8:	89 f0                	mov    %esi,%eax
  801dea:	eb 05                	jmp    801df1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801df1:	83 c4 1c             	add    $0x1c,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	57                   	push   %edi
  801dfd:	56                   	push   %esi
  801dfe:	53                   	push   %ebx
  801dff:	83 ec 3c             	sub    $0x3c,%esp
  801e02:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 0f f4 ff ff       	call   80121f <fd_alloc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	0f 88 45 01 00 00    	js     801f5f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e21:	00 
  801e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e30:	e8 fc ef ff ff       	call   800e31 <sys_page_alloc>
  801e35:	89 c3                	mov    %eax,%ebx
  801e37:	85 c0                	test   %eax,%eax
  801e39:	0f 88 20 01 00 00    	js     801f5f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e3f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e42:	89 04 24             	mov    %eax,(%esp)
  801e45:	e8 d5 f3 ff ff       	call   80121f <fd_alloc>
  801e4a:	89 c3                	mov    %eax,%ebx
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	0f 88 f8 00 00 00    	js     801f4c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e54:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e5b:	00 
  801e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6a:	e8 c2 ef ff ff       	call   800e31 <sys_page_alloc>
  801e6f:	89 c3                	mov    %eax,%ebx
  801e71:	85 c0                	test   %eax,%eax
  801e73:	0f 88 d3 00 00 00    	js     801f4c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 80 f3 ff ff       	call   801204 <fd2data>
  801e84:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e86:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e8d:	00 
  801e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e99:	e8 93 ef ff ff       	call   800e31 <sys_page_alloc>
  801e9e:	89 c3                	mov    %eax,%ebx
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	0f 88 91 00 00 00    	js     801f39 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eab:	89 04 24             	mov    %eax,(%esp)
  801eae:	e8 51 f3 ff ff       	call   801204 <fd2data>
  801eb3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eba:	00 
  801ebb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ec6:	00 
  801ec7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ecb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed2:	e8 ae ef ff ff       	call   800e85 <sys_page_map>
  801ed7:	89 c3                	mov    %eax,%ebx
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 4c                	js     801f29 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801edd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ee6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ee8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eeb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ef2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801efb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f00:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f0a:	89 04 24             	mov    %eax,(%esp)
  801f0d:	e8 e2 f2 ff ff       	call   8011f4 <fd2num>
  801f12:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f17:	89 04 24             	mov    %eax,(%esp)
  801f1a:	e8 d5 f2 ff ff       	call   8011f4 <fd2num>
  801f1f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f22:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f27:	eb 36                	jmp    801f5f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f29:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f34:	e8 9f ef ff ff       	call   800ed8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f39:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f47:	e8 8c ef ff ff       	call   800ed8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f5a:	e8 79 ef ff ff       	call   800ed8 <sys_page_unmap>
    err:
	return r;
}
  801f5f:	89 d8                	mov    %ebx,%eax
  801f61:	83 c4 3c             	add    $0x3c,%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5f                   	pop    %edi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    

00801f69 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f76:	8b 45 08             	mov    0x8(%ebp),%eax
  801f79:	89 04 24             	mov    %eax,(%esp)
  801f7c:	e8 f1 f2 ff ff       	call   801272 <fd_lookup>
  801f81:	85 c0                	test   %eax,%eax
  801f83:	78 15                	js     801f9a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f88:	89 04 24             	mov    %eax,(%esp)
  801f8b:	e8 74 f2 ff ff       	call   801204 <fd2data>
	return _pipeisclosed(fd, p);
  801f90:	89 c2                	mov    %eax,%edx
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	e8 11 fd ff ff       	call   801cab <_pipeisclosed>
}
  801f9a:	c9                   	leave  
  801f9b:	c3                   	ret    

00801f9c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    

00801fa6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fac:	c7 44 24 04 ce 29 80 	movl   $0x8029ce,0x4(%esp)
  801fb3:	00 
  801fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb7:	89 04 24             	mov    %eax,(%esp)
  801fba:	e8 80 ea ff ff       	call   800a3f <strcpy>
	return 0;
}
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	57                   	push   %edi
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fd7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fdd:	eb 30                	jmp    80200f <devcons_write+0x49>
		m = n - tot;
  801fdf:	8b 75 10             	mov    0x10(%ebp),%esi
  801fe2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fe4:	83 fe 7f             	cmp    $0x7f,%esi
  801fe7:	76 05                	jbe    801fee <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fe9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fee:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ff2:	03 45 0c             	add    0xc(%ebp),%eax
  801ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff9:	89 3c 24             	mov    %edi,(%esp)
  801ffc:	e8 b7 eb ff ff       	call   800bb8 <memmove>
		sys_cputs(buf, m);
  802001:	89 74 24 04          	mov    %esi,0x4(%esp)
  802005:	89 3c 24             	mov    %edi,(%esp)
  802008:	e8 57 ed ff ff       	call   800d64 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80200d:	01 f3                	add    %esi,%ebx
  80200f:	89 d8                	mov    %ebx,%eax
  802011:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802014:	72 c9                	jb     801fdf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802016:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5e                   	pop    %esi
  80201e:	5f                   	pop    %edi
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    

00802021 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802027:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80202b:	75 07                	jne    802034 <devcons_read+0x13>
  80202d:	eb 25                	jmp    802054 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80202f:	e8 de ed ff ff       	call   800e12 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802034:	e8 49 ed ff ff       	call   800d82 <sys_cgetc>
  802039:	85 c0                	test   %eax,%eax
  80203b:	74 f2                	je     80202f <devcons_read+0xe>
  80203d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80203f:	85 c0                	test   %eax,%eax
  802041:	78 1d                	js     802060 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802043:	83 f8 04             	cmp    $0x4,%eax
  802046:	74 13                	je     80205b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802048:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204b:	88 10                	mov    %dl,(%eax)
	return 1;
  80204d:	b8 01 00 00 00       	mov    $0x1,%eax
  802052:	eb 0c                	jmp    802060 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802054:	b8 00 00 00 00       	mov    $0x0,%eax
  802059:	eb 05                	jmp    802060 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80205b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802068:	8b 45 08             	mov    0x8(%ebp),%eax
  80206b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80206e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802075:	00 
  802076:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802079:	89 04 24             	mov    %eax,(%esp)
  80207c:	e8 e3 ec ff ff       	call   800d64 <sys_cputs>
}
  802081:	c9                   	leave  
  802082:	c3                   	ret    

00802083 <getchar>:

int
getchar(void)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802089:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802090:	00 
  802091:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802094:	89 44 24 04          	mov    %eax,0x4(%esp)
  802098:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209f:	e8 6c f4 ff ff       	call   801510 <read>
	if (r < 0)
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	78 0f                	js     8020b7 <getchar+0x34>
		return r;
	if (r < 1)
  8020a8:	85 c0                	test   %eax,%eax
  8020aa:	7e 06                	jle    8020b2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020ac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020b0:	eb 05                	jmp    8020b7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020b2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    

008020b9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c9:	89 04 24             	mov    %eax,(%esp)
  8020cc:	e8 a1 f1 ff ff       	call   801272 <fd_lookup>
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	78 11                	js     8020e6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020de:	39 10                	cmp    %edx,(%eax)
  8020e0:	0f 94 c0             	sete   %al
  8020e3:	0f b6 c0             	movzbl %al,%eax
}
  8020e6:	c9                   	leave  
  8020e7:	c3                   	ret    

008020e8 <opencons>:

int
opencons(void)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f1:	89 04 24             	mov    %eax,(%esp)
  8020f4:	e8 26 f1 ff ff       	call   80121f <fd_alloc>
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	78 3c                	js     802139 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020fd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802104:	00 
  802105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802108:	89 44 24 04          	mov    %eax,0x4(%esp)
  80210c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802113:	e8 19 ed ff ff       	call   800e31 <sys_page_alloc>
  802118:	85 c0                	test   %eax,%eax
  80211a:	78 1d                	js     802139 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80211c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802122:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802125:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802131:	89 04 24             	mov    %eax,(%esp)
  802134:	e8 bb f0 ff ff       	call   8011f4 <fd2num>
}
  802139:	c9                   	leave  
  80213a:	c3                   	ret    
	...

0080213c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	56                   	push   %esi
  802140:	53                   	push   %ebx
  802141:	83 ec 10             	sub    $0x10,%esp
  802144:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80214d:	85 c0                	test   %eax,%eax
  80214f:	75 05                	jne    802156 <ipc_recv+0x1a>
  802151:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802156:	89 04 24             	mov    %eax,(%esp)
  802159:	e8 e9 ee ff ff       	call   801047 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80215e:	85 c0                	test   %eax,%eax
  802160:	79 16                	jns    802178 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802162:	85 db                	test   %ebx,%ebx
  802164:	74 06                	je     80216c <ipc_recv+0x30>
  802166:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  80216c:	85 f6                	test   %esi,%esi
  80216e:	74 32                	je     8021a2 <ipc_recv+0x66>
  802170:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802176:	eb 2a                	jmp    8021a2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802178:	85 db                	test   %ebx,%ebx
  80217a:	74 0c                	je     802188 <ipc_recv+0x4c>
  80217c:	a1 20 44 80 00       	mov    0x804420,%eax
  802181:	8b 00                	mov    (%eax),%eax
  802183:	8b 40 74             	mov    0x74(%eax),%eax
  802186:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802188:	85 f6                	test   %esi,%esi
  80218a:	74 0c                	je     802198 <ipc_recv+0x5c>
  80218c:	a1 20 44 80 00       	mov    0x804420,%eax
  802191:	8b 00                	mov    (%eax),%eax
  802193:	8b 40 78             	mov    0x78(%eax),%eax
  802196:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  802198:	a1 20 44 80 00       	mov    0x804420,%eax
  80219d:	8b 00                	mov    (%eax),%eax
  80219f:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	5b                   	pop    %ebx
  8021a6:	5e                   	pop    %esi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    

008021a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	57                   	push   %edi
  8021ad:	56                   	push   %esi
  8021ae:	53                   	push   %ebx
  8021af:	83 ec 1c             	sub    $0x1c,%esp
  8021b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021b8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8021bb:	85 db                	test   %ebx,%ebx
  8021bd:	75 05                	jne    8021c4 <ipc_send+0x1b>
  8021bf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8021c4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8021c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d3:	89 04 24             	mov    %eax,(%esp)
  8021d6:	e8 49 ee ff ff       	call   801024 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8021db:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021de:	75 07                	jne    8021e7 <ipc_send+0x3e>
  8021e0:	e8 2d ec ff ff       	call   800e12 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8021e5:	eb dd                	jmp    8021c4 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	79 1c                	jns    802207 <ipc_send+0x5e>
  8021eb:	c7 44 24 08 da 29 80 	movl   $0x8029da,0x8(%esp)
  8021f2:	00 
  8021f3:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8021fa:	00 
  8021fb:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  802202:	e8 95 e1 ff ff       	call   80039c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802207:	83 c4 1c             	add    $0x1c,%esp
  80220a:	5b                   	pop    %ebx
  80220b:	5e                   	pop    %esi
  80220c:	5f                   	pop    %edi
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	53                   	push   %ebx
  802213:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802216:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80221b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802222:	89 c2                	mov    %eax,%edx
  802224:	c1 e2 07             	shl    $0x7,%edx
  802227:	29 ca                	sub    %ecx,%edx
  802229:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80222f:	8b 52 50             	mov    0x50(%edx),%edx
  802232:	39 da                	cmp    %ebx,%edx
  802234:	75 0f                	jne    802245 <ipc_find_env+0x36>
			return envs[i].env_id;
  802236:	c1 e0 07             	shl    $0x7,%eax
  802239:	29 c8                	sub    %ecx,%eax
  80223b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802240:	8b 40 40             	mov    0x40(%eax),%eax
  802243:	eb 0c                	jmp    802251 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802245:	40                   	inc    %eax
  802246:	3d 00 04 00 00       	cmp    $0x400,%eax
  80224b:	75 ce                	jne    80221b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80224d:	66 b8 00 00          	mov    $0x0,%ax
}
  802251:	5b                   	pop    %ebx
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80225a:	89 c2                	mov    %eax,%edx
  80225c:	c1 ea 16             	shr    $0x16,%edx
  80225f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802266:	f6 c2 01             	test   $0x1,%dl
  802269:	74 1e                	je     802289 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80226b:	c1 e8 0c             	shr    $0xc,%eax
  80226e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802275:	a8 01                	test   $0x1,%al
  802277:	74 17                	je     802290 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802279:	c1 e8 0c             	shr    $0xc,%eax
  80227c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802283:	ef 
  802284:	0f b7 c0             	movzwl %ax,%eax
  802287:	eb 0c                	jmp    802295 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802289:	b8 00 00 00 00       	mov    $0x0,%eax
  80228e:	eb 05                	jmp    802295 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802290:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    
	...

00802298 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802298:	55                   	push   %ebp
  802299:	57                   	push   %edi
  80229a:	56                   	push   %esi
  80229b:	83 ec 10             	sub    $0x10,%esp
  80229e:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022aa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8022ae:	89 cd                	mov    %ecx,%ebp
  8022b0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	75 2c                	jne    8022e4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8022b8:	39 f9                	cmp    %edi,%ecx
  8022ba:	77 68                	ja     802324 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022bc:	85 c9                	test   %ecx,%ecx
  8022be:	75 0b                	jne    8022cb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c5:	31 d2                	xor    %edx,%edx
  8022c7:	f7 f1                	div    %ecx
  8022c9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	89 f8                	mov    %edi,%eax
  8022cf:	f7 f1                	div    %ecx
  8022d1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	f7 f1                	div    %ecx
  8022d7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022d9:	89 f0                	mov    %esi,%eax
  8022db:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022dd:	83 c4 10             	add    $0x10,%esp
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022e4:	39 f8                	cmp    %edi,%eax
  8022e6:	77 2c                	ja     802314 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022e8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8022eb:	83 f6 1f             	xor    $0x1f,%esi
  8022ee:	75 4c                	jne    80233c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022f0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022f2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022f7:	72 0a                	jb     802303 <__udivdi3+0x6b>
  8022f9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022fd:	0f 87 ad 00 00 00    	ja     8023b0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802303:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802308:	89 f0                	mov    %esi,%eax
  80230a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	5e                   	pop    %esi
  802310:	5f                   	pop    %edi
  802311:	5d                   	pop    %ebp
  802312:	c3                   	ret    
  802313:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802314:	31 ff                	xor    %edi,%edi
  802316:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802318:	89 f0                	mov    %esi,%eax
  80231a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80231c:	83 c4 10             	add    $0x10,%esp
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    
  802323:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802324:	89 fa                	mov    %edi,%edx
  802326:	89 f0                	mov    %esi,%eax
  802328:	f7 f1                	div    %ecx
  80232a:	89 c6                	mov    %eax,%esi
  80232c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80232e:	89 f0                	mov    %esi,%eax
  802330:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80233c:	89 f1                	mov    %esi,%ecx
  80233e:	d3 e0                	shl    %cl,%eax
  802340:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802344:	b8 20 00 00 00       	mov    $0x20,%eax
  802349:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80234b:	89 ea                	mov    %ebp,%edx
  80234d:	88 c1                	mov    %al,%cl
  80234f:	d3 ea                	shr    %cl,%edx
  802351:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802355:	09 ca                	or     %ecx,%edx
  802357:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80235b:	89 f1                	mov    %esi,%ecx
  80235d:	d3 e5                	shl    %cl,%ebp
  80235f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802363:	89 fd                	mov    %edi,%ebp
  802365:	88 c1                	mov    %al,%cl
  802367:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802369:	89 fa                	mov    %edi,%edx
  80236b:	89 f1                	mov    %esi,%ecx
  80236d:	d3 e2                	shl    %cl,%edx
  80236f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802373:	88 c1                	mov    %al,%cl
  802375:	d3 ef                	shr    %cl,%edi
  802377:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802379:	89 f8                	mov    %edi,%eax
  80237b:	89 ea                	mov    %ebp,%edx
  80237d:	f7 74 24 08          	divl   0x8(%esp)
  802381:	89 d1                	mov    %edx,%ecx
  802383:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802385:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802389:	39 d1                	cmp    %edx,%ecx
  80238b:	72 17                	jb     8023a4 <__udivdi3+0x10c>
  80238d:	74 09                	je     802398 <__udivdi3+0x100>
  80238f:	89 fe                	mov    %edi,%esi
  802391:	31 ff                	xor    %edi,%edi
  802393:	e9 41 ff ff ff       	jmp    8022d9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802398:	8b 54 24 04          	mov    0x4(%esp),%edx
  80239c:	89 f1                	mov    %esi,%ecx
  80239e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023a0:	39 c2                	cmp    %eax,%edx
  8023a2:	73 eb                	jae    80238f <__udivdi3+0xf7>
		{
		  q0--;
  8023a4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023a7:	31 ff                	xor    %edi,%edi
  8023a9:	e9 2b ff ff ff       	jmp    8022d9 <__udivdi3+0x41>
  8023ae:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023b0:	31 f6                	xor    %esi,%esi
  8023b2:	e9 22 ff ff ff       	jmp    8022d9 <__udivdi3+0x41>
	...

008023b8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8023b8:	55                   	push   %ebp
  8023b9:	57                   	push   %edi
  8023ba:	56                   	push   %esi
  8023bb:	83 ec 20             	sub    $0x20,%esp
  8023be:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023c2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023c6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023ca:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8023ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023d2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8023d6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8023d8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023da:	85 ed                	test   %ebp,%ebp
  8023dc:	75 16                	jne    8023f4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8023de:	39 f1                	cmp    %esi,%ecx
  8023e0:	0f 86 a6 00 00 00    	jbe    80248c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023e6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8023e8:	89 d0                	mov    %edx,%eax
  8023ea:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023ec:	83 c4 20             	add    $0x20,%esp
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    
  8023f3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023f4:	39 f5                	cmp    %esi,%ebp
  8023f6:	0f 87 ac 00 00 00    	ja     8024a8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023fc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023ff:	83 f0 1f             	xor    $0x1f,%eax
  802402:	89 44 24 10          	mov    %eax,0x10(%esp)
  802406:	0f 84 a8 00 00 00    	je     8024b4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80240c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802410:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802412:	bf 20 00 00 00       	mov    $0x20,%edi
  802417:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80241b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80241f:	89 f9                	mov    %edi,%ecx
  802421:	d3 e8                	shr    %cl,%eax
  802423:	09 e8                	or     %ebp,%eax
  802425:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802429:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80242d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802431:	d3 e0                	shl    %cl,%eax
  802433:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802437:	89 f2                	mov    %esi,%edx
  802439:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80243b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80243f:	d3 e0                	shl    %cl,%eax
  802441:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802445:	8b 44 24 14          	mov    0x14(%esp),%eax
  802449:	89 f9                	mov    %edi,%ecx
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80244f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802451:	89 f2                	mov    %esi,%edx
  802453:	f7 74 24 18          	divl   0x18(%esp)
  802457:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802459:	f7 64 24 0c          	mull   0xc(%esp)
  80245d:	89 c5                	mov    %eax,%ebp
  80245f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802461:	39 d6                	cmp    %edx,%esi
  802463:	72 67                	jb     8024cc <__umoddi3+0x114>
  802465:	74 75                	je     8024dc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802467:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80246b:	29 e8                	sub    %ebp,%eax
  80246d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80246f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802473:	d3 e8                	shr    %cl,%eax
  802475:	89 f2                	mov    %esi,%edx
  802477:	89 f9                	mov    %edi,%ecx
  802479:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80247b:	09 d0                	or     %edx,%eax
  80247d:	89 f2                	mov    %esi,%edx
  80247f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802483:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802485:	83 c4 20             	add    $0x20,%esp
  802488:	5e                   	pop    %esi
  802489:	5f                   	pop    %edi
  80248a:	5d                   	pop    %ebp
  80248b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80248c:	85 c9                	test   %ecx,%ecx
  80248e:	75 0b                	jne    80249b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802490:	b8 01 00 00 00       	mov    $0x1,%eax
  802495:	31 d2                	xor    %edx,%edx
  802497:	f7 f1                	div    %ecx
  802499:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80249b:	89 f0                	mov    %esi,%eax
  80249d:	31 d2                	xor    %edx,%edx
  80249f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024a1:	89 f8                	mov    %edi,%eax
  8024a3:	e9 3e ff ff ff       	jmp    8023e6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024a8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024aa:	83 c4 20             	add    $0x20,%esp
  8024ad:	5e                   	pop    %esi
  8024ae:	5f                   	pop    %edi
  8024af:	5d                   	pop    %ebp
  8024b0:	c3                   	ret    
  8024b1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024b4:	39 f5                	cmp    %esi,%ebp
  8024b6:	72 04                	jb     8024bc <__umoddi3+0x104>
  8024b8:	39 f9                	cmp    %edi,%ecx
  8024ba:	77 06                	ja     8024c2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024bc:	89 f2                	mov    %esi,%edx
  8024be:	29 cf                	sub    %ecx,%edi
  8024c0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8024c2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024c4:	83 c4 20             	add    $0x20,%esp
  8024c7:	5e                   	pop    %esi
  8024c8:	5f                   	pop    %edi
  8024c9:	5d                   	pop    %ebp
  8024ca:	c3                   	ret    
  8024cb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024cc:	89 d1                	mov    %edx,%ecx
  8024ce:	89 c5                	mov    %eax,%ebp
  8024d0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024d4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024d8:	eb 8d                	jmp    802467 <__umoddi3+0xaf>
  8024da:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024dc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024e0:	72 ea                	jb     8024cc <__umoddi3+0x114>
  8024e2:	89 f1                	mov    %esi,%ecx
  8024e4:	eb 81                	jmp    802467 <__umoddi3+0xaf>
