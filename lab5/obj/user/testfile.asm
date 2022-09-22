
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 3b 07 00 00       	call   80076c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800048:	e8 36 0e 00 00       	call   800e83 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80005a:	e8 54 15 00 00       	call   8015b3 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 ce 14 00 00       	call   80154d <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 45 14 00 00       	call   8014e0 <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 a0 26 80 00       	mov    $0x8026a0,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 ab 26 80 	movl   $0x8026ab,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8000e0:	e8 fb 06 00 00       	call   8007e0 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 60 28 80 	movl   $0x802860,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8000fc:	e8 df 06 00 00       	call   8007e0 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 d5 26 80 00       	mov    $0x8026d5,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 de 26 80 	movl   $0x8026de,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80012f:	e8 ac 06 00 00       	call   8007e0 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 84 28 80 	movl   $0x802884,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800166:	e8 75 06 00 00       	call   8007e0 <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 f6 26 80 00 	movl   $0x8026f6,(%esp)
  800172:	e8 61 07 00 00       	call   8008d8 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 30 80 00    	call   *0x80301c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 0a 27 80 	movl   $0x80270a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8001ad:	e8 2e 06 00 00       	call   8007e0 <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 30 80 00       	mov    0x803000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 91 0c 00 00       	call   800e50 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 30 80 00       	mov    0x803000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 7f 0c 00 00       	call   800e50 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 b4 28 80 	movl   $0x8028b4,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8001f3:	e8 e8 05 00 00       	call   8007e0 <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 18 27 80 00 	movl   $0x802718,(%esp)
  8001ff:	e8 d4 06 00 00       	call   8008d8 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 90 0d 00 00       	call   800fb2 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 30 80 00    	call   *0x803010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 2b 27 80 	movl   $0x80272b,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80025a:	e8 81 05 00 00       	call   8007e0 <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 30 80 00       	mov    0x803000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 b4 0c 00 00       	call   800f2a <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 39 27 80 	movl   $0x802739,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800291:	e8 4a 05 00 00       	call   8007e0 <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 57 27 80 00 	movl   $0x802757,(%esp)
  80029d:	e8 36 06 00 00       	call   8008d8 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 30 80 00    	call   *0x803018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8002ce:	e8 0d 05 00 00       	call   8007e0 <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 79 27 80 00 	movl   $0x802779,(%esp)
  8002da:	e8 f9 05 00 00       	call   8008d8 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  8002e4:	8d 7d d8             	lea    -0x28(%ebp),%edi
  8002e7:	b9 04 00 00 00       	mov    $0x4,%ecx
  8002ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  8002ee:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  8002f5:	cc 
  8002f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002fd:	e8 1a 10 00 00       	call   80131c <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800302:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800309:	00 
  80030a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 15 10 30 80 00    	call   *0x803010
  800320:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800323:	74 20                	je     800345 <umain+0x2a4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	c7 44 24 08 dc 28 80 	movl   $0x8028dc,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800340:	e8 9b 04 00 00       	call   8007e0 <_panic>
	cprintf("stale fileid is good\n");
  800345:	c7 04 24 8d 27 80 00 	movl   $0x80278d,(%esp)
  80034c:	e8 87 05 00 00       	call   8008d8 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800351:	ba 02 01 00 00       	mov    $0x102,%edx
  800356:	b8 a3 27 80 00       	mov    $0x8027a3,%eax
  80035b:	e8 d4 fc ff ff       	call   800034 <xopen>
  800360:	85 c0                	test   %eax,%eax
  800362:	79 20                	jns    800384 <umain+0x2e3>
		panic("serve_open /new-file: %e", r);
  800364:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800368:	c7 44 24 08 ad 27 80 	movl   $0x8027ad,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80037f:	e8 5c 04 00 00       	call   8007e0 <_panic>
	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800384:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80038a:	a1 00 30 80 00       	mov    0x803000,%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	e8 b9 0a 00 00       	call   800e50 <strlen>
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	a1 00 30 80 00       	mov    0x803000,%eax
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003ab:	ff d3                	call   *%ebx
  8003ad:	89 c3                	mov    %eax,%ebx
  8003af:	a1 00 30 80 00       	mov    0x803000,%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 94 0a 00 00       	call   800e50 <strlen>
  8003bc:	39 c3                	cmp    %eax,%ebx
  8003be:	74 20                	je     8003e0 <umain+0x33f>
		panic("file_write: %e", r);
  8003c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c4:	c7 44 24 08 c6 27 80 	movl   $0x8027c6,0x8(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8003d3:	00 
  8003d4:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8003db:	e8 00 04 00 00       	call   8007e0 <_panic>
	cprintf("file_write is good\n");
  8003e0:	c7 04 24 d5 27 80 00 	movl   $0x8027d5,(%esp)
  8003e7:	e8 ec 04 00 00       	call   8008d8 <cprintf>

	FVA->fd_offset = 0;
  8003ec:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8003f3:	00 00 00 
	memset(buf, 0, sizeof buf);
  8003f6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8003fd:	00 
  8003fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800405:	00 
  800406:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80040c:	89 1c 24             	mov    %ebx,(%esp)
  80040f:	e8 9e 0b 00 00       	call   800fb2 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800414:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800427:	ff 15 10 30 80 00    	call   *0x803010
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	85 c0                	test   %eax,%eax
  800431:	79 20                	jns    800453 <umain+0x3b2>
		panic("file_read after file_write: %e", r);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 14 29 80 	movl   $0x802914,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80044e:	e8 8d 03 00 00       	call   8007e0 <_panic>
	if (r != strlen(msg))
  800453:	a1 00 30 80 00       	mov    0x803000,%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 f0 09 00 00       	call   800e50 <strlen>
  800460:	39 d8                	cmp    %ebx,%eax
  800462:	74 20                	je     800484 <umain+0x3e3>
		panic("file_read after file_write returned wrong length: %d", r);
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	c7 44 24 08 34 29 80 	movl   $0x802934,0x8(%esp)
  80046f:	00 
  800470:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800477:	00 
  800478:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80047f:	e8 5c 03 00 00       	call   8007e0 <_panic>
	if (strcmp(buf, msg) != 0)
  800484:	a1 00 30 80 00       	mov    0x803000,%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 8f 0a 00 00       	call   800f2a <strcmp>
  80049b:	85 c0                	test   %eax,%eax
  80049d:	74 1c                	je     8004bb <umain+0x41a>
		panic("file_read after file_write returned wrong data");
  80049f:	c7 44 24 08 6c 29 80 	movl   $0x80296c,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8004b6:	e8 25 03 00 00       	call   8007e0 <_panic>
	cprintf("file_read after file_write is good\n");
  8004bb:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  8004c2:	e8 11 04 00 00       	call   8008d8 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 a0 26 80 00 	movl   $0x8026a0,(%esp)
  8004d6:	e8 70 19 00 00       	call   801e4b <open>
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	79 25                	jns    800504 <umain+0x463>
  8004df:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004e2:	74 3c                	je     800520 <umain+0x47f>
		panic("open /not-found: %e", r);
  8004e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e8:	c7 44 24 08 b1 26 80 	movl   $0x8026b1,0x8(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8004f7:	00 
  8004f8:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8004ff:	e8 dc 02 00 00       	call   8007e0 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800504:	c7 44 24 08 e9 27 80 	movl   $0x8027e9,0x8(%esp)
  80050b:	00 
  80050c:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  800513:	00 
  800514:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80051b:	e8 c0 02 00 00       	call   8007e0 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800527:	00 
  800528:	c7 04 24 d5 26 80 00 	movl   $0x8026d5,(%esp)
  80052f:	e8 17 19 00 00       	call   801e4b <open>
  800534:	85 c0                	test   %eax,%eax
  800536:	79 20                	jns    800558 <umain+0x4b7>
		panic("open /newmotd: %e", r);
  800538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053c:	c7 44 24 08 e4 26 80 	movl   $0x8026e4,0x8(%esp)
  800543:	00 
  800544:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  80054b:	00 
  80054c:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800553:	e8 88 02 00 00       	call   8007e0 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800558:	05 00 00 0d 00       	add    $0xd0000,%eax
  80055d:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800560:	83 38 66             	cmpl   $0x66,(%eax)
  800563:	75 0c                	jne    800571 <umain+0x4d0>
  800565:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800569:	75 06                	jne    800571 <umain+0x4d0>
  80056b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80056f:	74 1c                	je     80058d <umain+0x4ec>
		panic("open did not fill struct Fd correctly\n");
  800571:	c7 44 24 08 c0 29 80 	movl   $0x8029c0,0x8(%esp)
  800578:	00 
  800579:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  800580:	00 
  800581:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800588:	e8 53 02 00 00       	call   8007e0 <_panic>
	cprintf("open is good\n");
  80058d:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800594:	e8 3f 03 00 00       	call   8008d8 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800599:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005a0:	00 
  8005a1:	c7 04 24 04 28 80 00 	movl   $0x802804,(%esp)
  8005a8:	e8 9e 18 00 00       	call   801e4b <open>
  8005ad:	89 c7                	mov    %eax,%edi
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	79 20                	jns    8005d3 <umain+0x532>
		panic("creat /big: %e", f);
  8005b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b7:	c7 44 24 08 09 28 80 	movl   $0x802809,0x8(%esp)
  8005be:	00 
  8005bf:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  8005c6:	00 
  8005c7:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8005ce:	e8 0d 02 00 00       	call   8007e0 <_panic>
	memset(buf, 0, sizeof(buf));
  8005d3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005da:	00 
  8005db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005e2:	00 
  8005e3:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	e8 c1 09 00 00       	call   800fb2 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f1:	be 00 00 00 00       	mov    $0x0,%esi
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8005f6:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8005fc:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800602:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800609:	00 
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	89 3c 24             	mov    %edi,(%esp)
  800611:	e8 db 13 00 00       	call   8019f1 <write>
  800616:	85 c0                	test   %eax,%eax
  800618:	79 24                	jns    80063e <umain+0x59d>
			panic("write /big@%d: %e", i, r);
  80061a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80061e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800622:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  800629:	00 
  80062a:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
  800631:	00 
  800632:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800639:	e8 a2 01 00 00       	call   8007e0 <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  80063e:	8d 86 00 02 00 00    	lea    0x200(%esi),%eax
  800644:	89 c6                	mov    %eax,%esi

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800646:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  80064b:	75 af                	jne    8005fc <umain+0x55b>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  80064d:	89 3c 24             	mov    %edi,(%esp)
  800650:	e8 5b 11 00 00       	call   8017b0 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80065c:	00 
  80065d:	c7 04 24 04 28 80 00 	movl   $0x802804,(%esp)
  800664:	e8 e2 17 00 00       	call   801e4b <open>
  800669:	89 c3                	mov    %eax,%ebx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	79 20                	jns    80068f <umain+0x5ee>
		panic("open /big: %e", f);
  80066f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800673:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  80067a:	00 
  80067b:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800682:	00 
  800683:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80068a:	e8 51 01 00 00       	call   8007e0 <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  80068f:	be 00 00 00 00       	mov    $0x0,%esi
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800694:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  80069a:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006a7:	00 
  8006a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ac:	89 1c 24             	mov    %ebx,(%esp)
  8006af:	e8 f2 12 00 00       	call   8019a6 <readn>
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	79 24                	jns    8006dc <umain+0x63b>
			panic("read /big@%d: %e", i, r);
  8006b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c0:	c7 44 24 08 38 28 80 	movl   $0x802838,0x8(%esp)
  8006c7:	00 
  8006c8:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8006cf:	00 
  8006d0:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  8006d7:	e8 04 01 00 00       	call   8007e0 <_panic>
		if (r != sizeof(buf))
  8006dc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006e1:	74 2c                	je     80070f <umain+0x66e>
			panic("read /big from %d returned %d < %d bytes",
  8006e3:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ea:	00 
  8006eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f3:	c7 44 24 08 e8 29 80 	movl   $0x8029e8,0x8(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800702:	00 
  800703:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  80070a:	e8 d1 00 00 00       	call   8007e0 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  80070f:	8b 07                	mov    (%edi),%eax
  800711:	39 f0                	cmp    %esi,%eax
  800713:	74 24                	je     800739 <umain+0x698>
			panic("read /big from %d returned bad data %d",
  800715:	89 44 24 10          	mov    %eax,0x10(%esp)
  800719:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071d:	c7 44 24 08 14 2a 80 	movl   $0x802a14,0x8(%esp)
  800724:	00 
  800725:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80072c:	00 
  80072d:	c7 04 24 c5 26 80 00 	movl   $0x8026c5,(%esp)
  800734:	e8 a7 00 00 00       	call   8007e0 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800739:	8d b0 00 02 00 00    	lea    0x200(%eax),%esi
  80073f:	81 fe ff df 01 00    	cmp    $0x1dfff,%esi
  800745:	0f 8e 4f ff ff ff    	jle    80069a <umain+0x5f9>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  80074b:	89 1c 24             	mov    %ebx,(%esp)
  80074e:	e8 5d 10 00 00       	call   8017b0 <close>
	cprintf("large file is good\n");
  800753:	c7 04 24 49 28 80 00 	movl   $0x802849,(%esp)
  80075a:	e8 79 01 00 00       	call   8008d8 <cprintf>
}
  80075f:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    
	...

0080076c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	83 ec 20             	sub    $0x20,%esp
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80077a:	e8 b8 0a 00 00       	call   801237 <sys_getenvid>
  80077f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800784:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80078b:	c1 e0 07             	shl    $0x7,%eax
  80078e:	29 d0                	sub    %edx,%eax
  800790:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800795:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800798:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079b:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007a0:	85 f6                	test   %esi,%esi
  8007a2:	7e 07                	jle    8007ab <libmain+0x3f>
		binaryname = argv[0];
  8007a4:	8b 03                	mov    (%ebx),%eax
  8007a6:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8007ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007af:	89 34 24             	mov    %esi,(%esp)
  8007b2:	e8 ea f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007b7:	e8 08 00 00 00       	call   8007c4 <exit>
}
  8007bc:	83 c4 20             	add    $0x20,%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    
	...

008007c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007ca:	e8 12 10 00 00       	call   8017e1 <close_all>
	sys_env_destroy(0);
  8007cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007d6:	e8 0a 0a 00 00       	call   8011e5 <sys_env_destroy>
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	56                   	push   %esi
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007eb:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8007f1:	e8 41 0a 00 00       	call   801237 <sys_getenvid>
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800800:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800804:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  800813:	e8 c0 00 00 00       	call   8008d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800818:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081c:	8b 45 10             	mov    0x10(%ebp),%eax
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	e8 50 00 00 00       	call   800877 <vcprintf>
	cprintf("\n");
  800827:	c7 04 24 da 2d 80 00 	movl   $0x802dda,(%esp)
  80082e:	e8 a5 00 00 00       	call   8008d8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800833:	cc                   	int3   
  800834:	eb fd                	jmp    800833 <_panic+0x53>
	...

00800838 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 14             	sub    $0x14,%esp
  80083f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800842:	8b 03                	mov    (%ebx),%eax
  800844:	8b 55 08             	mov    0x8(%ebp),%edx
  800847:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80084b:	40                   	inc    %eax
  80084c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80084e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800853:	75 19                	jne    80086e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800855:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80085c:	00 
  80085d:	8d 43 08             	lea    0x8(%ebx),%eax
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	e8 40 09 00 00       	call   8011a8 <sys_cputs>
		b->idx = 0;
  800868:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80086e:	ff 43 04             	incl   0x4(%ebx)
}
  800871:	83 c4 14             	add    $0x14,%esp
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800880:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800887:	00 00 00 
	b.cnt = 0;
  80088a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800891:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800894:	8b 45 0c             	mov    0xc(%ebp),%eax
  800897:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	c7 04 24 38 08 80 00 	movl   $0x800838,(%esp)
  8008b3:	e8 82 01 00 00       	call   800a3a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008b8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	e8 d8 08 00 00       	call   8011a8 <sys_cputs>

	return b.cnt;
}
  8008d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	e8 87 ff ff ff       	call   800877 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
	...

008008f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	57                   	push   %edi
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	83 ec 3c             	sub    $0x3c,%esp
  8008fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800900:	89 d7                	mov    %edx,%edi
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80090e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800911:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800914:	85 c0                	test   %eax,%eax
  800916:	75 08                	jne    800920 <printnum+0x2c>
  800918:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80091b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80091e:	77 57                	ja     800977 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800920:	89 74 24 10          	mov    %esi,0x10(%esp)
  800924:	4b                   	dec    %ebx
  800925:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800929:	8b 45 10             	mov    0x10(%ebp),%eax
  80092c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800930:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800934:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800938:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80093f:	00 
  800940:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800943:	89 04 24             	mov    %eax,(%esp)
  800946:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	e8 fa 1a 00 00       	call   80244c <__udivdi3>
  800952:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800956:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80095a:	89 04 24             	mov    %eax,(%esp)
  80095d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800961:	89 fa                	mov    %edi,%edx
  800963:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800966:	e8 89 ff ff ff       	call   8008f4 <printnum>
  80096b:	eb 0f                	jmp    80097c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80096d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800971:	89 34 24             	mov    %esi,(%esp)
  800974:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800977:	4b                   	dec    %ebx
  800978:	85 db                	test   %ebx,%ebx
  80097a:	7f f1                	jg     80096d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80097c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800980:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800984:	8b 45 10             	mov    0x10(%ebp),%eax
  800987:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800992:	00 
  800993:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	e8 c7 1b 00 00       	call   80256c <__umoddi3>
  8009a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a9:	0f be 80 8f 2a 80 00 	movsbl 0x802a8f(%eax),%eax
  8009b0:	89 04 24             	mov    %eax,(%esp)
  8009b3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009b6:	83 c4 3c             	add    $0x3c,%esp
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009c1:	83 fa 01             	cmp    $0x1,%edx
  8009c4:	7e 0e                	jle    8009d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009c6:	8b 10                	mov    (%eax),%edx
  8009c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009cb:	89 08                	mov    %ecx,(%eax)
  8009cd:	8b 02                	mov    (%edx),%eax
  8009cf:	8b 52 04             	mov    0x4(%edx),%edx
  8009d2:	eb 22                	jmp    8009f6 <getuint+0x38>
	else if (lflag)
  8009d4:	85 d2                	test   %edx,%edx
  8009d6:	74 10                	je     8009e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009d8:	8b 10                	mov    (%eax),%edx
  8009da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009dd:	89 08                	mov    %ecx,(%eax)
  8009df:	8b 02                	mov    (%edx),%eax
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e6:	eb 0e                	jmp    8009f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009e8:	8b 10                	mov    (%eax),%edx
  8009ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009ed:	89 08                	mov    %ecx,(%eax)
  8009ef:	8b 02                	mov    (%edx),%eax
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009fe:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800a01:	8b 10                	mov    (%eax),%edx
  800a03:	3b 50 04             	cmp    0x4(%eax),%edx
  800a06:	73 08                	jae    800a10 <sprintputch+0x18>
		*b->buf++ = ch;
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	88 0a                	mov    %cl,(%edx)
  800a0d:	42                   	inc    %edx
  800a0e:	89 10                	mov    %edx,(%eax)
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a18:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a22:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	89 04 24             	mov    %eax,(%esp)
  800a33:	e8 02 00 00 00       	call   800a3a <vprintfmt>
	va_end(ap);
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	83 ec 4c             	sub    $0x4c,%esp
  800a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a46:	8b 75 10             	mov    0x10(%ebp),%esi
  800a49:	eb 12                	jmp    800a5d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	0f 84 6b 03 00 00    	je     800dbe <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800a53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a57:	89 04 24             	mov    %eax,(%esp)
  800a5a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a5d:	0f b6 06             	movzbl (%esi),%eax
  800a60:	46                   	inc    %esi
  800a61:	83 f8 25             	cmp    $0x25,%eax
  800a64:	75 e5                	jne    800a4b <vprintfmt+0x11>
  800a66:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a6a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a71:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800a76:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a82:	eb 26                	jmp    800aaa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a84:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a87:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a8b:	eb 1d                	jmp    800aaa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a90:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a94:	eb 14                	jmp    800aaa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a96:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800a99:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800aa0:	eb 08                	jmp    800aaa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800aa2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800aa5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aaa:	0f b6 06             	movzbl (%esi),%eax
  800aad:	8d 56 01             	lea    0x1(%esi),%edx
  800ab0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ab3:	8a 16                	mov    (%esi),%dl
  800ab5:	83 ea 23             	sub    $0x23,%edx
  800ab8:	80 fa 55             	cmp    $0x55,%dl
  800abb:	0f 87 e1 02 00 00    	ja     800da2 <vprintfmt+0x368>
  800ac1:	0f b6 d2             	movzbl %dl,%edx
  800ac4:	ff 24 95 e0 2b 80 00 	jmp    *0x802be0(,%edx,4)
  800acb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ace:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ad3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800ad6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800ada:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800add:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ae0:	83 fa 09             	cmp    $0x9,%edx
  800ae3:	77 2a                	ja     800b0f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ae5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ae6:	eb eb                	jmp    800ad3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ae8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aeb:	8d 50 04             	lea    0x4(%eax),%edx
  800aee:	89 55 14             	mov    %edx,0x14(%ebp)
  800af1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800af6:	eb 17                	jmp    800b0f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800af8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800afc:	78 98                	js     800a96 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afe:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b01:	eb a7                	jmp    800aaa <vprintfmt+0x70>
  800b03:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b06:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800b0d:	eb 9b                	jmp    800aaa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800b0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b13:	79 95                	jns    800aaa <vprintfmt+0x70>
  800b15:	eb 8b                	jmp    800aa2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b17:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b18:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b1b:	eb 8d                	jmp    800aaa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b20:	8d 50 04             	lea    0x4(%eax),%edx
  800b23:	89 55 14             	mov    %edx,0x14(%ebp)
  800b26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b2a:	8b 00                	mov    (%eax),%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b32:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b35:	e9 23 ff ff ff       	jmp    800a5d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3d:	8d 50 04             	lea    0x4(%eax),%edx
  800b40:	89 55 14             	mov    %edx,0x14(%ebp)
  800b43:	8b 00                	mov    (%eax),%eax
  800b45:	85 c0                	test   %eax,%eax
  800b47:	79 02                	jns    800b4b <vprintfmt+0x111>
  800b49:	f7 d8                	neg    %eax
  800b4b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b4d:	83 f8 0f             	cmp    $0xf,%eax
  800b50:	7f 0b                	jg     800b5d <vprintfmt+0x123>
  800b52:	8b 04 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%eax
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	75 23                	jne    800b80 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800b5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b61:	c7 44 24 08 a7 2a 80 	movl   $0x802aa7,0x8(%esp)
  800b68:	00 
  800b69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	89 04 24             	mov    %eax,(%esp)
  800b73:	e8 9a fe ff ff       	call   800a12 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b78:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b7b:	e9 dd fe ff ff       	jmp    800a5d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b84:	c7 44 24 08 91 2e 80 	movl   $0x802e91,0x8(%esp)
  800b8b:	00 
  800b8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 14 24             	mov    %edx,(%esp)
  800b96:	e8 77 fe ff ff       	call   800a12 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b9e:	e9 ba fe ff ff       	jmp    800a5d <vprintfmt+0x23>
  800ba3:	89 f9                	mov    %edi,%ecx
  800ba5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ba8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800bab:	8b 45 14             	mov    0x14(%ebp),%eax
  800bae:	8d 50 04             	lea    0x4(%eax),%edx
  800bb1:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb4:	8b 30                	mov    (%eax),%esi
  800bb6:	85 f6                	test   %esi,%esi
  800bb8:	75 05                	jne    800bbf <vprintfmt+0x185>
				p = "(null)";
  800bba:	be a0 2a 80 00       	mov    $0x802aa0,%esi
			if (width > 0 && padc != '-')
  800bbf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800bc3:	0f 8e 84 00 00 00    	jle    800c4d <vprintfmt+0x213>
  800bc9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800bcd:	74 7e                	je     800c4d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bcf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bd3:	89 34 24             	mov    %esi,(%esp)
  800bd6:	e8 8b 02 00 00       	call   800e66 <strnlen>
  800bdb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bde:	29 c2                	sub    %eax,%edx
  800be0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800be3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800be7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800bea:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800bed:	89 de                	mov    %ebx,%esi
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bf3:	eb 0b                	jmp    800c00 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800bf5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf9:	89 3c 24             	mov    %edi,(%esp)
  800bfc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bff:	4b                   	dec    %ebx
  800c00:	85 db                	test   %ebx,%ebx
  800c02:	7f f1                	jg     800bf5 <vprintfmt+0x1bb>
  800c04:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800c07:	89 f3                	mov    %esi,%ebx
  800c09:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	79 05                	jns    800c18 <vprintfmt+0x1de>
  800c13:	b8 00 00 00 00       	mov    $0x0,%eax
  800c18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c1b:	29 c2                	sub    %eax,%edx
  800c1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c20:	eb 2b                	jmp    800c4d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c22:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c26:	74 18                	je     800c40 <vprintfmt+0x206>
  800c28:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c2b:	83 fa 5e             	cmp    $0x5e,%edx
  800c2e:	76 10                	jbe    800c40 <vprintfmt+0x206>
					putch('?', putdat);
  800c30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c34:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c3b:	ff 55 08             	call   *0x8(%ebp)
  800c3e:	eb 0a                	jmp    800c4a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800c40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c44:	89 04 24             	mov    %eax,(%esp)
  800c47:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c4a:	ff 4d e4             	decl   -0x1c(%ebp)
  800c4d:	0f be 06             	movsbl (%esi),%eax
  800c50:	46                   	inc    %esi
  800c51:	85 c0                	test   %eax,%eax
  800c53:	74 21                	je     800c76 <vprintfmt+0x23c>
  800c55:	85 ff                	test   %edi,%edi
  800c57:	78 c9                	js     800c22 <vprintfmt+0x1e8>
  800c59:	4f                   	dec    %edi
  800c5a:	79 c6                	jns    800c22 <vprintfmt+0x1e8>
  800c5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c64:	eb 18                	jmp    800c7e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c71:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c73:	4b                   	dec    %ebx
  800c74:	eb 08                	jmp    800c7e <vprintfmt+0x244>
  800c76:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c7e:	85 db                	test   %ebx,%ebx
  800c80:	7f e4                	jg     800c66 <vprintfmt+0x22c>
  800c82:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c85:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c87:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c8a:	e9 ce fd ff ff       	jmp    800a5d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c8f:	83 f9 01             	cmp    $0x1,%ecx
  800c92:	7e 10                	jle    800ca4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800c94:	8b 45 14             	mov    0x14(%ebp),%eax
  800c97:	8d 50 08             	lea    0x8(%eax),%edx
  800c9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800c9d:	8b 30                	mov    (%eax),%esi
  800c9f:	8b 78 04             	mov    0x4(%eax),%edi
  800ca2:	eb 26                	jmp    800cca <vprintfmt+0x290>
	else if (lflag)
  800ca4:	85 c9                	test   %ecx,%ecx
  800ca6:	74 12                	je     800cba <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ca8:	8b 45 14             	mov    0x14(%ebp),%eax
  800cab:	8d 50 04             	lea    0x4(%eax),%edx
  800cae:	89 55 14             	mov    %edx,0x14(%ebp)
  800cb1:	8b 30                	mov    (%eax),%esi
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	c1 ff 1f             	sar    $0x1f,%edi
  800cb8:	eb 10                	jmp    800cca <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800cba:	8b 45 14             	mov    0x14(%ebp),%eax
  800cbd:	8d 50 04             	lea    0x4(%eax),%edx
  800cc0:	89 55 14             	mov    %edx,0x14(%ebp)
  800cc3:	8b 30                	mov    (%eax),%esi
  800cc5:	89 f7                	mov    %esi,%edi
  800cc7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cca:	85 ff                	test   %edi,%edi
  800ccc:	78 0a                	js     800cd8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cce:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd3:	e9 8c 00 00 00       	jmp    800d64 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800cd8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cdc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ce3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ce6:	f7 de                	neg    %esi
  800ce8:	83 d7 00             	adc    $0x0,%edi
  800ceb:	f7 df                	neg    %edi
			}
			base = 10;
  800ced:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf2:	eb 70                	jmp    800d64 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cf4:	89 ca                	mov    %ecx,%edx
  800cf6:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf9:	e8 c0 fc ff ff       	call   8009be <getuint>
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	89 d7                	mov    %edx,%edi
			base = 10;
  800d02:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800d07:	eb 5b                	jmp    800d64 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800d09:	89 ca                	mov    %ecx,%edx
  800d0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d0e:	e8 ab fc ff ff       	call   8009be <getuint>
  800d13:	89 c6                	mov    %eax,%esi
  800d15:	89 d7                	mov    %edx,%edi
			base = 8;
  800d17:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800d1c:	eb 46                	jmp    800d64 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800d1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d22:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d29:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d30:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d37:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3d:	8d 50 04             	lea    0x4(%eax),%edx
  800d40:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d43:	8b 30                	mov    (%eax),%esi
  800d45:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d4a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d4f:	eb 13                	jmp    800d64 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d51:	89 ca                	mov    %ecx,%edx
  800d53:	8d 45 14             	lea    0x14(%ebp),%eax
  800d56:	e8 63 fc ff ff       	call   8009be <getuint>
  800d5b:	89 c6                	mov    %eax,%esi
  800d5d:	89 d7                	mov    %edx,%edi
			base = 16;
  800d5f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d64:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800d68:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d6c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d77:	89 34 24             	mov    %esi,(%esp)
  800d7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d7e:	89 da                	mov    %ebx,%edx
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	e8 6c fb ff ff       	call   8008f4 <printnum>
			break;
  800d88:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d8b:	e9 cd fc ff ff       	jmp    800a5d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d94:	89 04 24             	mov    %eax,(%esp)
  800d97:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d9d:	e9 bb fc ff ff       	jmp    800a5d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800da2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800dad:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800db0:	eb 01                	jmp    800db3 <vprintfmt+0x379>
  800db2:	4e                   	dec    %esi
  800db3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800db7:	75 f9                	jne    800db2 <vprintfmt+0x378>
  800db9:	e9 9f fc ff ff       	jmp    800a5d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800dbe:	83 c4 4c             	add    $0x4c,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	83 ec 28             	sub    $0x28,%esp
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800dd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dd5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800dd9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ddc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	74 30                	je     800e17 <vsnprintf+0x51>
  800de7:	85 d2                	test   %edx,%edx
  800de9:	7e 33                	jle    800e1e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800deb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800df2:	8b 45 10             	mov    0x10(%ebp),%eax
  800df5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e00:	c7 04 24 f8 09 80 00 	movl   $0x8009f8,(%esp)
  800e07:	e8 2e fc ff ff       	call   800a3a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e0f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e15:	eb 0c                	jmp    800e23 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1c:	eb 05                	jmp    800e23 <vsnprintf+0x5d>
  800e1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e2b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e32:	8b 45 10             	mov    0x10(%ebp),%eax
  800e35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	89 04 24             	mov    %eax,(%esp)
  800e46:	e8 7b ff ff ff       	call   800dc6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e4b:	c9                   	leave  
  800e4c:	c3                   	ret    
  800e4d:	00 00                	add    %al,(%eax)
	...

00800e50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5b:	eb 01                	jmp    800e5e <strlen+0xe>
		n++;
  800e5d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e5e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e62:	75 f9                	jne    800e5d <strlen+0xd>
		n++;
	return n;
}
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800e6c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	eb 01                	jmp    800e77 <strnlen+0x11>
		n++;
  800e76:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e77:	39 d0                	cmp    %edx,%eax
  800e79:	74 06                	je     800e81 <strnlen+0x1b>
  800e7b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800e7f:	75 f5                	jne    800e76 <strnlen+0x10>
		n++;
	return n;
}
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	53                   	push   %ebx
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800e95:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e98:	42                   	inc    %edx
  800e99:	84 c9                	test   %cl,%cl
  800e9b:	75 f5                	jne    800e92 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e9d:	5b                   	pop    %ebx
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800eaa:	89 1c 24             	mov    %ebx,(%esp)
  800ead:	e8 9e ff ff ff       	call   800e50 <strlen>
	strcpy(dst + len, src);
  800eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb9:	01 d8                	add    %ebx,%eax
  800ebb:	89 04 24             	mov    %eax,(%esp)
  800ebe:	e8 c0 ff ff ff       	call   800e83 <strcpy>
	return dst;
}
  800ec3:	89 d8                	mov    %ebx,%eax
  800ec5:	83 c4 08             	add    $0x8,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ed9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ede:	eb 0c                	jmp    800eec <strncpy+0x21>
		*dst++ = *src;
  800ee0:	8a 1a                	mov    (%edx),%bl
  800ee2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ee5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ee8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800eeb:	41                   	inc    %ecx
  800eec:	39 f1                	cmp    %esi,%ecx
  800eee:	75 f0                	jne    800ee0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	8b 75 08             	mov    0x8(%ebp),%esi
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f02:	85 d2                	test   %edx,%edx
  800f04:	75 0a                	jne    800f10 <strlcpy+0x1c>
  800f06:	89 f0                	mov    %esi,%eax
  800f08:	eb 1a                	jmp    800f24 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f0a:	88 18                	mov    %bl,(%eax)
  800f0c:	40                   	inc    %eax
  800f0d:	41                   	inc    %ecx
  800f0e:	eb 02                	jmp    800f12 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f10:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800f12:	4a                   	dec    %edx
  800f13:	74 0a                	je     800f1f <strlcpy+0x2b>
  800f15:	8a 19                	mov    (%ecx),%bl
  800f17:	84 db                	test   %bl,%bl
  800f19:	75 ef                	jne    800f0a <strlcpy+0x16>
  800f1b:	89 c2                	mov    %eax,%edx
  800f1d:	eb 02                	jmp    800f21 <strlcpy+0x2d>
  800f1f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f21:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f24:	29 f0                	sub    %esi,%eax
}
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f30:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f33:	eb 02                	jmp    800f37 <strcmp+0xd>
		p++, q++;
  800f35:	41                   	inc    %ecx
  800f36:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f37:	8a 01                	mov    (%ecx),%al
  800f39:	84 c0                	test   %al,%al
  800f3b:	74 04                	je     800f41 <strcmp+0x17>
  800f3d:	3a 02                	cmp    (%edx),%al
  800f3f:	74 f4                	je     800f35 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f41:	0f b6 c0             	movzbl %al,%eax
  800f44:	0f b6 12             	movzbl (%edx),%edx
  800f47:	29 d0                	sub    %edx,%eax
}
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	53                   	push   %ebx
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f55:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800f58:	eb 03                	jmp    800f5d <strncmp+0x12>
		n--, p++, q++;
  800f5a:	4a                   	dec    %edx
  800f5b:	40                   	inc    %eax
  800f5c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f5d:	85 d2                	test   %edx,%edx
  800f5f:	74 14                	je     800f75 <strncmp+0x2a>
  800f61:	8a 18                	mov    (%eax),%bl
  800f63:	84 db                	test   %bl,%bl
  800f65:	74 04                	je     800f6b <strncmp+0x20>
  800f67:	3a 19                	cmp    (%ecx),%bl
  800f69:	74 ef                	je     800f5a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f6b:	0f b6 00             	movzbl (%eax),%eax
  800f6e:	0f b6 11             	movzbl (%ecx),%edx
  800f71:	29 d0                	sub    %edx,%eax
  800f73:	eb 05                	jmp    800f7a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f7a:	5b                   	pop    %ebx
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f86:	eb 05                	jmp    800f8d <strchr+0x10>
		if (*s == c)
  800f88:	38 ca                	cmp    %cl,%dl
  800f8a:	74 0c                	je     800f98 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f8c:	40                   	inc    %eax
  800f8d:	8a 10                	mov    (%eax),%dl
  800f8f:	84 d2                	test   %dl,%dl
  800f91:	75 f5                	jne    800f88 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800fa3:	eb 05                	jmp    800faa <strfind+0x10>
		if (*s == c)
  800fa5:	38 ca                	cmp    %cl,%dl
  800fa7:	74 07                	je     800fb0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800fa9:	40                   	inc    %eax
  800faa:	8a 10                	mov    (%eax),%dl
  800fac:	84 d2                	test   %dl,%dl
  800fae:	75 f5                	jne    800fa5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fc1:	85 c9                	test   %ecx,%ecx
  800fc3:	74 30                	je     800ff5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fc5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fcb:	75 25                	jne    800ff2 <memset+0x40>
  800fcd:	f6 c1 03             	test   $0x3,%cl
  800fd0:	75 20                	jne    800ff2 <memset+0x40>
		c &= 0xFF;
  800fd2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fd5:	89 d3                	mov    %edx,%ebx
  800fd7:	c1 e3 08             	shl    $0x8,%ebx
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	c1 e6 18             	shl    $0x18,%esi
  800fdf:	89 d0                	mov    %edx,%eax
  800fe1:	c1 e0 10             	shl    $0x10,%eax
  800fe4:	09 f0                	or     %esi,%eax
  800fe6:	09 d0                	or     %edx,%eax
  800fe8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800fea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800fed:	fc                   	cld    
  800fee:	f3 ab                	rep stos %eax,%es:(%edi)
  800ff0:	eb 03                	jmp    800ff5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ff2:	fc                   	cld    
  800ff3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ff5:	89 f8                	mov    %edi,%eax
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	8b 45 08             	mov    0x8(%ebp),%eax
  801004:	8b 75 0c             	mov    0xc(%ebp),%esi
  801007:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80100a:	39 c6                	cmp    %eax,%esi
  80100c:	73 34                	jae    801042 <memmove+0x46>
  80100e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801011:	39 d0                	cmp    %edx,%eax
  801013:	73 2d                	jae    801042 <memmove+0x46>
		s += n;
		d += n;
  801015:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801018:	f6 c2 03             	test   $0x3,%dl
  80101b:	75 1b                	jne    801038 <memmove+0x3c>
  80101d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801023:	75 13                	jne    801038 <memmove+0x3c>
  801025:	f6 c1 03             	test   $0x3,%cl
  801028:	75 0e                	jne    801038 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80102a:	83 ef 04             	sub    $0x4,%edi
  80102d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801030:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801033:	fd                   	std    
  801034:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801036:	eb 07                	jmp    80103f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801038:	4f                   	dec    %edi
  801039:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80103c:	fd                   	std    
  80103d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80103f:	fc                   	cld    
  801040:	eb 20                	jmp    801062 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801042:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801048:	75 13                	jne    80105d <memmove+0x61>
  80104a:	a8 03                	test   $0x3,%al
  80104c:	75 0f                	jne    80105d <memmove+0x61>
  80104e:	f6 c1 03             	test   $0x3,%cl
  801051:	75 0a                	jne    80105d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801053:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801056:	89 c7                	mov    %eax,%edi
  801058:	fc                   	cld    
  801059:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80105b:	eb 05                	jmp    801062 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80105d:	89 c7                	mov    %eax,%edi
  80105f:	fc                   	cld    
  801060:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80106c:	8b 45 10             	mov    0x10(%ebp),%eax
  80106f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801073:	8b 45 0c             	mov    0xc(%ebp),%eax
  801076:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 77 ff ff ff       	call   800ffc <memmove>
}
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	57                   	push   %edi
  80108b:	56                   	push   %esi
  80108c:	53                   	push   %ebx
  80108d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801090:	8b 75 0c             	mov    0xc(%ebp),%esi
  801093:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801096:	ba 00 00 00 00       	mov    $0x0,%edx
  80109b:	eb 16                	jmp    8010b3 <memcmp+0x2c>
		if (*s1 != *s2)
  80109d:	8a 04 17             	mov    (%edi,%edx,1),%al
  8010a0:	42                   	inc    %edx
  8010a1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8010a5:	38 c8                	cmp    %cl,%al
  8010a7:	74 0a                	je     8010b3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8010a9:	0f b6 c0             	movzbl %al,%eax
  8010ac:	0f b6 c9             	movzbl %cl,%ecx
  8010af:	29 c8                	sub    %ecx,%eax
  8010b1:	eb 09                	jmp    8010bc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010b3:	39 da                	cmp    %ebx,%edx
  8010b5:	75 e6                	jne    80109d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010cf:	eb 05                	jmp    8010d6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010d1:	38 08                	cmp    %cl,(%eax)
  8010d3:	74 05                	je     8010da <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010d5:	40                   	inc    %eax
  8010d6:	39 d0                	cmp    %edx,%eax
  8010d8:	72 f7                	jb     8010d1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010e8:	eb 01                	jmp    8010eb <strtol+0xf>
		s++;
  8010ea:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010eb:	8a 02                	mov    (%edx),%al
  8010ed:	3c 20                	cmp    $0x20,%al
  8010ef:	74 f9                	je     8010ea <strtol+0xe>
  8010f1:	3c 09                	cmp    $0x9,%al
  8010f3:	74 f5                	je     8010ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010f5:	3c 2b                	cmp    $0x2b,%al
  8010f7:	75 08                	jne    801101 <strtol+0x25>
		s++;
  8010f9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ff:	eb 13                	jmp    801114 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801101:	3c 2d                	cmp    $0x2d,%al
  801103:	75 0a                	jne    80110f <strtol+0x33>
		s++, neg = 1;
  801105:	8d 52 01             	lea    0x1(%edx),%edx
  801108:	bf 01 00 00 00       	mov    $0x1,%edi
  80110d:	eb 05                	jmp    801114 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80110f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801114:	85 db                	test   %ebx,%ebx
  801116:	74 05                	je     80111d <strtol+0x41>
  801118:	83 fb 10             	cmp    $0x10,%ebx
  80111b:	75 28                	jne    801145 <strtol+0x69>
  80111d:	8a 02                	mov    (%edx),%al
  80111f:	3c 30                	cmp    $0x30,%al
  801121:	75 10                	jne    801133 <strtol+0x57>
  801123:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801127:	75 0a                	jne    801133 <strtol+0x57>
		s += 2, base = 16;
  801129:	83 c2 02             	add    $0x2,%edx
  80112c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801131:	eb 12                	jmp    801145 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801133:	85 db                	test   %ebx,%ebx
  801135:	75 0e                	jne    801145 <strtol+0x69>
  801137:	3c 30                	cmp    $0x30,%al
  801139:	75 05                	jne    801140 <strtol+0x64>
		s++, base = 8;
  80113b:	42                   	inc    %edx
  80113c:	b3 08                	mov    $0x8,%bl
  80113e:	eb 05                	jmp    801145 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801140:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80114c:	8a 0a                	mov    (%edx),%cl
  80114e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801151:	80 fb 09             	cmp    $0x9,%bl
  801154:	77 08                	ja     80115e <strtol+0x82>
			dig = *s - '0';
  801156:	0f be c9             	movsbl %cl,%ecx
  801159:	83 e9 30             	sub    $0x30,%ecx
  80115c:	eb 1e                	jmp    80117c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80115e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801161:	80 fb 19             	cmp    $0x19,%bl
  801164:	77 08                	ja     80116e <strtol+0x92>
			dig = *s - 'a' + 10;
  801166:	0f be c9             	movsbl %cl,%ecx
  801169:	83 e9 57             	sub    $0x57,%ecx
  80116c:	eb 0e                	jmp    80117c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80116e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801171:	80 fb 19             	cmp    $0x19,%bl
  801174:	77 12                	ja     801188 <strtol+0xac>
			dig = *s - 'A' + 10;
  801176:	0f be c9             	movsbl %cl,%ecx
  801179:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80117c:	39 f1                	cmp    %esi,%ecx
  80117e:	7d 0c                	jge    80118c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801180:	42                   	inc    %edx
  801181:	0f af c6             	imul   %esi,%eax
  801184:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801186:	eb c4                	jmp    80114c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801188:	89 c1                	mov    %eax,%ecx
  80118a:	eb 02                	jmp    80118e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80118c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80118e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801192:	74 05                	je     801199 <strtol+0xbd>
		*endptr = (char *) s;
  801194:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801197:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801199:	85 ff                	test   %edi,%edi
  80119b:	74 04                	je     8011a1 <strtol+0xc5>
  80119d:	89 c8                	mov    %ecx,%eax
  80119f:	f7 d8                	neg    %eax
}
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    
	...

008011a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b9:	89 c3                	mov    %eax,%ebx
  8011bb:	89 c7                	mov    %eax,%edi
  8011bd:	89 c6                	mov    %eax,%esi
  8011bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d6:	89 d1                	mov    %edx,%ecx
  8011d8:	89 d3                	mov    %edx,%ebx
  8011da:	89 d7                	mov    %edx,%edi
  8011dc:	89 d6                	mov    %edx,%esi
  8011de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	89 cb                	mov    %ecx,%ebx
  8011fd:	89 cf                	mov    %ecx,%edi
  8011ff:	89 ce                	mov    %ecx,%esi
  801201:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	7e 28                	jle    80122f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801207:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801212:	00 
  801213:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  80122a:	e8 b1 f5 ff ff       	call   8007e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80122f:	83 c4 2c             	add    $0x2c,%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123d:	ba 00 00 00 00       	mov    $0x0,%edx
  801242:	b8 02 00 00 00       	mov    $0x2,%eax
  801247:	89 d1                	mov    %edx,%ecx
  801249:	89 d3                	mov    %edx,%ebx
  80124b:	89 d7                	mov    %edx,%edi
  80124d:	89 d6                	mov    %edx,%esi
  80124f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5f                   	pop    %edi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <sys_yield>:

void
sys_yield(void)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125c:	ba 00 00 00 00       	mov    $0x0,%edx
  801261:	b8 0b 00 00 00       	mov    $0xb,%eax
  801266:	89 d1                	mov    %edx,%ecx
  801268:	89 d3                	mov    %edx,%ebx
  80126a:	89 d7                	mov    %edx,%edi
  80126c:	89 d6                	mov    %edx,%esi
  80126e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	57                   	push   %edi
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
  80127b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127e:	be 00 00 00 00       	mov    $0x0,%esi
  801283:	b8 04 00 00 00       	mov    $0x4,%eax
  801288:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128e:	8b 55 08             	mov    0x8(%ebp),%edx
  801291:	89 f7                	mov    %esi,%edi
  801293:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801295:	85 c0                	test   %eax,%eax
  801297:	7e 28                	jle    8012c1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801299:	89 44 24 10          	mov    %eax,0x10(%esp)
  80129d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012b4:	00 
  8012b5:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  8012bc:	e8 1f f5 ff ff       	call   8007e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012c1:	83 c4 2c             	add    $0x2c,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8012d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8012da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	7e 28                	jle    801314 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  8012ff:	00 
  801300:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801307:	00 
  801308:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  80130f:	e8 cc f4 ff ff       	call   8007e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801314:	83 c4 2c             	add    $0x2c,%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801325:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132a:	b8 06 00 00 00       	mov    $0x6,%eax
  80132f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801332:	8b 55 08             	mov    0x8(%ebp),%edx
  801335:	89 df                	mov    %ebx,%edi
  801337:	89 de                	mov    %ebx,%esi
  801339:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80133b:	85 c0                	test   %eax,%eax
  80133d:	7e 28                	jle    801367 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801343:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80134a:	00 
  80134b:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801362:	e8 79 f4 ff ff       	call   8007e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801367:	83 c4 2c             	add    $0x2c,%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	57                   	push   %edi
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801378:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137d:	b8 08 00 00 00       	mov    $0x8,%eax
  801382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801385:	8b 55 08             	mov    0x8(%ebp),%edx
  801388:	89 df                	mov    %ebx,%edi
  80138a:	89 de                	mov    %ebx,%esi
  80138c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80138e:	85 c0                	test   %eax,%eax
  801390:	7e 28                	jle    8013ba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801392:	89 44 24 10          	mov    %eax,0x10(%esp)
  801396:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80139d:	00 
  80139e:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  8013a5:	00 
  8013a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ad:	00 
  8013ae:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  8013b5:	e8 26 f4 ff ff       	call   8007e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013ba:	83 c4 2c             	add    $0x2c,%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5f                   	pop    %edi
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8013d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013db:	89 df                	mov    %ebx,%edi
  8013dd:	89 de                	mov    %ebx,%esi
  8013df:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	7e 28                	jle    80140d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013f0:	00 
  8013f1:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  8013f8:	00 
  8013f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801400:	00 
  801401:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801408:	e8 d3 f3 ff ff       	call   8007e0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80140d:	83 c4 2c             	add    $0x2c,%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	57                   	push   %edi
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801423:	b8 0a 00 00 00       	mov    $0xa,%eax
  801428:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142b:	8b 55 08             	mov    0x8(%ebp),%edx
  80142e:	89 df                	mov    %ebx,%edi
  801430:	89 de                	mov    %ebx,%esi
  801432:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801434:	85 c0                	test   %eax,%eax
  801436:	7e 28                	jle    801460 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801438:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801443:	00 
  801444:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  80144b:	00 
  80144c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801453:	00 
  801454:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  80145b:	e8 80 f3 ff ff       	call   8007e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801460:	83 c4 2c             	add    $0x2c,%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	57                   	push   %edi
  80146c:	56                   	push   %esi
  80146d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80146e:	be 00 00 00 00       	mov    $0x0,%esi
  801473:	b8 0c 00 00 00       	mov    $0xc,%eax
  801478:	8b 7d 14             	mov    0x14(%ebp),%edi
  80147b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80147e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801481:	8b 55 08             	mov    0x8(%ebp),%edx
  801484:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	57                   	push   %edi
  80148f:	56                   	push   %esi
  801490:	53                   	push   %ebx
  801491:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801494:	b9 00 00 00 00       	mov    $0x0,%ecx
  801499:	b8 0d 00 00 00       	mov    $0xd,%eax
  80149e:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a1:	89 cb                	mov    %ecx,%ebx
  8014a3:	89 cf                	mov    %ecx,%edi
  8014a5:	89 ce                	mov    %ecx,%esi
  8014a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	7e 28                	jle    8014d5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8014b8:	00 
  8014b9:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  8014d0:	e8 0b f3 ff ff       	call   8007e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014d5:	83 c4 2c             	add    $0x2c,%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5f                   	pop    %edi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    
  8014dd:	00 00                	add    %al,(%eax)
	...

008014e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 10             	sub    $0x10,%esp
  8014e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	75 05                	jne    8014fa <ipc_recv+0x1a>
  8014f5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  8014fa:	89 04 24             	mov    %eax,(%esp)
  8014fd:	e8 89 ff ff ff       	call   80148b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801502:	85 c0                	test   %eax,%eax
  801504:	79 16                	jns    80151c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801506:	85 db                	test   %ebx,%ebx
  801508:	74 06                	je     801510 <ipc_recv+0x30>
  80150a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801510:	85 f6                	test   %esi,%esi
  801512:	74 32                	je     801546 <ipc_recv+0x66>
  801514:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80151a:	eb 2a                	jmp    801546 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80151c:	85 db                	test   %ebx,%ebx
  80151e:	74 0c                	je     80152c <ipc_recv+0x4c>
  801520:	a1 04 40 80 00       	mov    0x804004,%eax
  801525:	8b 00                	mov    (%eax),%eax
  801527:	8b 40 74             	mov    0x74(%eax),%eax
  80152a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80152c:	85 f6                	test   %esi,%esi
  80152e:	74 0c                	je     80153c <ipc_recv+0x5c>
  801530:	a1 04 40 80 00       	mov    0x804004,%eax
  801535:	8b 00                	mov    (%eax),%eax
  801537:	8b 40 78             	mov    0x78(%eax),%eax
  80153a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  80153c:	a1 04 40 80 00       	mov    0x804004,%eax
  801541:	8b 00                	mov    (%eax),%eax
  801543:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 1c             	sub    $0x1c,%esp
  801556:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801559:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80155c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80155f:	85 db                	test   %ebx,%ebx
  801561:	75 05                	jne    801568 <ipc_send+0x1b>
  801563:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801568:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80156c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801570:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801574:	8b 45 08             	mov    0x8(%ebp),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 e9 fe ff ff       	call   801468 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80157f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801582:	75 07                	jne    80158b <ipc_send+0x3e>
  801584:	e8 cd fc ff ff       	call   801256 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801589:	eb dd                	jmp    801568 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  80158b:	85 c0                	test   %eax,%eax
  80158d:	79 1c                	jns    8015ab <ipc_send+0x5e>
  80158f:	c7 44 24 08 ca 2d 80 	movl   $0x802dca,0x8(%esp)
  801596:	00 
  801597:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80159e:	00 
  80159f:	c7 04 24 dc 2d 80 00 	movl   $0x802ddc,(%esp)
  8015a6:	e8 35 f2 ff ff       	call   8007e0 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8015ab:	83 c4 1c             	add    $0x1c,%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5f                   	pop    %edi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8015bf:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	c1 e2 07             	shl    $0x7,%edx
  8015cb:	29 ca                	sub    %ecx,%edx
  8015cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8015d3:	8b 52 50             	mov    0x50(%edx),%edx
  8015d6:	39 da                	cmp    %ebx,%edx
  8015d8:	75 0f                	jne    8015e9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8015da:	c1 e0 07             	shl    $0x7,%eax
  8015dd:	29 c8                	sub    %ecx,%eax
  8015df:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8015e4:	8b 40 40             	mov    0x40(%eax),%eax
  8015e7:	eb 0c                	jmp    8015f5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015e9:	40                   	inc    %eax
  8015ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015ef:	75 ce                	jne    8015bf <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8015f1:	66 b8 00 00          	mov    $0x0,%ax
}
  8015f5:	5b                   	pop    %ebx
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801603:	c1 e8 0c             	shr    $0xc,%eax
}
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80160e:	8b 45 08             	mov    0x8(%ebp),%eax
  801611:	89 04 24             	mov    %eax,(%esp)
  801614:	e8 df ff ff ff       	call   8015f8 <fd2num>
  801619:	05 20 00 0d 00       	add    $0xd0020,%eax
  80161e:	c1 e0 0c             	shl    $0xc,%eax
}
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80162a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80162f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801631:	89 c2                	mov    %eax,%edx
  801633:	c1 ea 16             	shr    $0x16,%edx
  801636:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80163d:	f6 c2 01             	test   $0x1,%dl
  801640:	74 11                	je     801653 <fd_alloc+0x30>
  801642:	89 c2                	mov    %eax,%edx
  801644:	c1 ea 0c             	shr    $0xc,%edx
  801647:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80164e:	f6 c2 01             	test   $0x1,%dl
  801651:	75 09                	jne    80165c <fd_alloc+0x39>
			*fd_store = fd;
  801653:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
  80165a:	eb 17                	jmp    801673 <fd_alloc+0x50>
  80165c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801661:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801666:	75 c7                	jne    80162f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801668:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80166e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801673:	5b                   	pop    %ebx
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80167c:	83 f8 1f             	cmp    $0x1f,%eax
  80167f:	77 36                	ja     8016b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801681:	05 00 00 0d 00       	add    $0xd0000,%eax
  801686:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801689:	89 c2                	mov    %eax,%edx
  80168b:	c1 ea 16             	shr    $0x16,%edx
  80168e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801695:	f6 c2 01             	test   $0x1,%dl
  801698:	74 24                	je     8016be <fd_lookup+0x48>
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	c1 ea 0c             	shr    $0xc,%edx
  80169f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016a6:	f6 c2 01             	test   $0x1,%dl
  8016a9:	74 1a                	je     8016c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b5:	eb 13                	jmp    8016ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bc:	eb 0c                	jmp    8016ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c3:	eb 05                	jmp    8016ca <fd_lookup+0x54>
  8016c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 14             	sub    $0x14,%esp
  8016d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	eb 0e                	jmp    8016ee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8016e0:	39 08                	cmp    %ecx,(%eax)
  8016e2:	75 09                	jne    8016ed <dev_lookup+0x21>
			*dev = devtab[i];
  8016e4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016eb:	eb 35                	jmp    801722 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016ed:	42                   	inc    %edx
  8016ee:	8b 04 95 68 2e 80 00 	mov    0x802e68(,%edx,4),%eax
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	75 e7                	jne    8016e0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8016fe:	8b 00                	mov    (%eax),%eax
  801700:	8b 40 48             	mov    0x48(%eax),%eax
  801703:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	c7 04 24 e8 2d 80 00 	movl   $0x802de8,(%esp)
  801712:	e8 c1 f1 ff ff       	call   8008d8 <cprintf>
	*dev = 0;
  801717:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80171d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801722:	83 c4 14             	add    $0x14,%esp
  801725:	5b                   	pop    %ebx
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 30             	sub    $0x30,%esp
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
  801733:	8a 45 0c             	mov    0xc(%ebp),%al
  801736:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801739:	89 34 24             	mov    %esi,(%esp)
  80173c:	e8 b7 fe ff ff       	call   8015f8 <fd2num>
  801741:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801744:	89 54 24 04          	mov    %edx,0x4(%esp)
  801748:	89 04 24             	mov    %eax,(%esp)
  80174b:	e8 26 ff ff ff       	call   801676 <fd_lookup>
  801750:	89 c3                	mov    %eax,%ebx
  801752:	85 c0                	test   %eax,%eax
  801754:	78 05                	js     80175b <fd_close+0x33>
	    || fd != fd2)
  801756:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801759:	74 0d                	je     801768 <fd_close+0x40>
		return (must_exist ? r : 0);
  80175b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80175f:	75 46                	jne    8017a7 <fd_close+0x7f>
  801761:	bb 00 00 00 00       	mov    $0x0,%ebx
  801766:	eb 3f                	jmp    8017a7 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176f:	8b 06                	mov    (%esi),%eax
  801771:	89 04 24             	mov    %eax,(%esp)
  801774:	e8 53 ff ff ff       	call   8016cc <dev_lookup>
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 18                	js     801797 <fd_close+0x6f>
		if (dev->dev_close)
  80177f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801782:	8b 40 10             	mov    0x10(%eax),%eax
  801785:	85 c0                	test   %eax,%eax
  801787:	74 09                	je     801792 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801789:	89 34 24             	mov    %esi,(%esp)
  80178c:	ff d0                	call   *%eax
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	eb 05                	jmp    801797 <fd_close+0x6f>
		else
			r = 0;
  801792:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801797:	89 74 24 04          	mov    %esi,0x4(%esp)
  80179b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a2:	e8 75 fb ff ff       	call   80131c <sys_page_unmap>
	return r;
}
  8017a7:	89 d8                	mov    %ebx,%eax
  8017a9:	83 c4 30             	add    $0x30,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	89 04 24             	mov    %eax,(%esp)
  8017c3:	e8 ae fe ff ff       	call   801676 <fd_lookup>
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	78 13                	js     8017df <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017cc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017d3:	00 
  8017d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d7:	89 04 24             	mov    %eax,(%esp)
  8017da:	e8 49 ff ff ff       	call   801728 <fd_close>
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <close_all>:

void
close_all(void)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8017ed:	89 1c 24             	mov    %ebx,(%esp)
  8017f0:	e8 bb ff ff ff       	call   8017b0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017f5:	43                   	inc    %ebx
  8017f6:	83 fb 20             	cmp    $0x20,%ebx
  8017f9:	75 f2                	jne    8017ed <close_all+0xc>
		close(i);
}
  8017fb:	83 c4 14             	add    $0x14,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	57                   	push   %edi
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	83 ec 4c             	sub    $0x4c,%esp
  80180a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80180d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801810:	89 44 24 04          	mov    %eax,0x4(%esp)
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	e8 57 fe ff ff       	call   801676 <fd_lookup>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	85 c0                	test   %eax,%eax
  801823:	0f 88 e1 00 00 00    	js     80190a <dup+0x109>
		return r;
	close(newfdnum);
  801829:	89 3c 24             	mov    %edi,(%esp)
  80182c:	e8 7f ff ff ff       	call   8017b0 <close>

	newfd = INDEX2FD(newfdnum);
  801831:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801837:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80183a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80183d:	89 04 24             	mov    %eax,(%esp)
  801840:	e8 c3 fd ff ff       	call   801608 <fd2data>
  801845:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801847:	89 34 24             	mov    %esi,(%esp)
  80184a:	e8 b9 fd ff ff       	call   801608 <fd2data>
  80184f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801852:	89 d8                	mov    %ebx,%eax
  801854:	c1 e8 16             	shr    $0x16,%eax
  801857:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80185e:	a8 01                	test   $0x1,%al
  801860:	74 46                	je     8018a8 <dup+0xa7>
  801862:	89 d8                	mov    %ebx,%eax
  801864:	c1 e8 0c             	shr    $0xc,%eax
  801867:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80186e:	f6 c2 01             	test   $0x1,%dl
  801871:	74 35                	je     8018a8 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801873:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80187a:	25 07 0e 00 00       	and    $0xe07,%eax
  80187f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801883:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801886:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80188a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801891:	00 
  801892:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801896:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80189d:	e8 27 fa ff ff       	call   8012c9 <sys_page_map>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 3b                	js     8018e3 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	c1 ea 0c             	shr    $0xc,%edx
  8018b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018b7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018cc:	00 
  8018cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d8:	e8 ec f9 ff ff       	call   8012c9 <sys_page_map>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	79 25                	jns    801908 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ee:	e8 29 fa ff ff       	call   80131c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801901:	e8 16 fa ff ff       	call   80131c <sys_page_unmap>
	return r;
  801906:	eb 02                	jmp    80190a <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801908:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80190a:	89 d8                	mov    %ebx,%eax
  80190c:	83 c4 4c             	add    $0x4c,%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	53                   	push   %ebx
  801918:	83 ec 24             	sub    $0x24,%esp
  80191b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801921:	89 44 24 04          	mov    %eax,0x4(%esp)
  801925:	89 1c 24             	mov    %ebx,(%esp)
  801928:	e8 49 fd ff ff       	call   801676 <fd_lookup>
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 6f                	js     8019a0 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801931:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801934:	89 44 24 04          	mov    %eax,0x4(%esp)
  801938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193b:	8b 00                	mov    (%eax),%eax
  80193d:	89 04 24             	mov    %eax,(%esp)
  801940:	e8 87 fd ff ff       	call   8016cc <dev_lookup>
  801945:	85 c0                	test   %eax,%eax
  801947:	78 57                	js     8019a0 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801949:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194c:	8b 50 08             	mov    0x8(%eax),%edx
  80194f:	83 e2 03             	and    $0x3,%edx
  801952:	83 fa 01             	cmp    $0x1,%edx
  801955:	75 25                	jne    80197c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801957:	a1 04 40 80 00       	mov    0x804004,%eax
  80195c:	8b 00                	mov    (%eax),%eax
  80195e:	8b 40 48             	mov    0x48(%eax),%eax
  801961:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801965:	89 44 24 04          	mov    %eax,0x4(%esp)
  801969:	c7 04 24 2c 2e 80 00 	movl   $0x802e2c,(%esp)
  801970:	e8 63 ef ff ff       	call   8008d8 <cprintf>
		return -E_INVAL;
  801975:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80197a:	eb 24                	jmp    8019a0 <read+0x8c>
	}
	if (!dev->dev_read)
  80197c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197f:	8b 52 08             	mov    0x8(%edx),%edx
  801982:	85 d2                	test   %edx,%edx
  801984:	74 15                	je     80199b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801986:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801989:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80198d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801990:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	ff d2                	call   *%edx
  801999:	eb 05                	jmp    8019a0 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80199b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019a0:	83 c4 24             	add    $0x24,%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	57                   	push   %edi
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 1c             	sub    $0x1c,%esp
  8019af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ba:	eb 23                	jmp    8019df <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019bc:	89 f0                	mov    %esi,%eax
  8019be:	29 d8                	sub    %ebx,%eax
  8019c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c7:	01 d8                	add    %ebx,%eax
  8019c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cd:	89 3c 24             	mov    %edi,(%esp)
  8019d0:	e8 3f ff ff ff       	call   801914 <read>
		if (m < 0)
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 10                	js     8019e9 <readn+0x43>
			return m;
		if (m == 0)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	74 0a                	je     8019e7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019dd:	01 c3                	add    %eax,%ebx
  8019df:	39 f3                	cmp    %esi,%ebx
  8019e1:	72 d9                	jb     8019bc <readn+0x16>
  8019e3:	89 d8                	mov    %ebx,%eax
  8019e5:	eb 02                	jmp    8019e9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8019e7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8019e9:	83 c4 1c             	add    $0x1c,%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5f                   	pop    %edi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 24             	sub    $0x24,%esp
  8019f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a02:	89 1c 24             	mov    %ebx,(%esp)
  801a05:	e8 6c fc ff ff       	call   801676 <fd_lookup>
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 6a                	js     801a78 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a18:	8b 00                	mov    (%eax),%eax
  801a1a:	89 04 24             	mov    %eax,(%esp)
  801a1d:	e8 aa fc ff ff       	call   8016cc <dev_lookup>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 52                	js     801a78 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a29:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a2d:	75 25                	jne    801a54 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a2f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a34:	8b 00                	mov    (%eax),%eax
  801a36:	8b 40 48             	mov    0x48(%eax),%eax
  801a39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a41:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  801a48:	e8 8b ee ff ff       	call   8008d8 <cprintf>
		return -E_INVAL;
  801a4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a52:	eb 24                	jmp    801a78 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a57:	8b 52 0c             	mov    0xc(%edx),%edx
  801a5a:	85 d2                	test   %edx,%edx
  801a5c:	74 15                	je     801a73 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a61:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a68:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a6c:	89 04 24             	mov    %eax,(%esp)
  801a6f:	ff d2                	call   *%edx
  801a71:	eb 05                	jmp    801a78 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a73:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a78:	83 c4 24             	add    $0x24,%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <seek>:

int
seek(int fdnum, off_t offset)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a84:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	89 04 24             	mov    %eax,(%esp)
  801a91:	e8 e0 fb ff ff       	call   801676 <fd_lookup>
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 0e                	js     801aa8 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	53                   	push   %ebx
  801aae:	83 ec 24             	sub    $0x24,%esp
  801ab1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ab4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	89 1c 24             	mov    %ebx,(%esp)
  801abe:	e8 b3 fb ff ff       	call   801676 <fd_lookup>
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 63                	js     801b2a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ac7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad1:	8b 00                	mov    (%eax),%eax
  801ad3:	89 04 24             	mov    %eax,(%esp)
  801ad6:	e8 f1 fb ff ff       	call   8016cc <dev_lookup>
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 4b                	js     801b2a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ae6:	75 25                	jne    801b0d <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ae8:	a1 04 40 80 00       	mov    0x804004,%eax
  801aed:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801aef:	8b 40 48             	mov    0x48(%eax),%eax
  801af2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afa:	c7 04 24 08 2e 80 00 	movl   $0x802e08,(%esp)
  801b01:	e8 d2 ed ff ff       	call   8008d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b0b:	eb 1d                	jmp    801b2a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b10:	8b 52 18             	mov    0x18(%edx),%edx
  801b13:	85 d2                	test   %edx,%edx
  801b15:	74 0e                	je     801b25 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	ff d2                	call   *%edx
  801b23:	eb 05                	jmp    801b2a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b25:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b2a:	83 c4 24             	add    $0x24,%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	53                   	push   %ebx
  801b34:	83 ec 24             	sub    $0x24,%esp
  801b37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b41:	8b 45 08             	mov    0x8(%ebp),%eax
  801b44:	89 04 24             	mov    %eax,(%esp)
  801b47:	e8 2a fb ff ff       	call   801676 <fd_lookup>
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	78 52                	js     801ba2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5a:	8b 00                	mov    (%eax),%eax
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	e8 68 fb ff ff       	call   8016cc <dev_lookup>
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 3a                	js     801ba2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b6f:	74 2c                	je     801b9d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b71:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b74:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b7b:	00 00 00 
	stat->st_isdir = 0;
  801b7e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b85:	00 00 00 
	stat->st_dev = dev;
  801b88:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b92:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b95:	89 14 24             	mov    %edx,(%esp)
  801b98:	ff 50 14             	call   *0x14(%eax)
  801b9b:	eb 05                	jmp    801ba2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b9d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ba2:	83 c4 24             	add    $0x24,%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bb7:	00 
  801bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbb:	89 04 24             	mov    %eax,(%esp)
  801bbe:	e8 88 02 00 00       	call   801e4b <open>
  801bc3:	89 c3                	mov    %eax,%ebx
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	78 1b                	js     801be4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd0:	89 1c 24             	mov    %ebx,(%esp)
  801bd3:	e8 58 ff ff ff       	call   801b30 <fstat>
  801bd8:	89 c6                	mov    %eax,%esi
	close(fd);
  801bda:	89 1c 24             	mov    %ebx,(%esp)
  801bdd:	e8 ce fb ff ff       	call   8017b0 <close>
	return r;
  801be2:	89 f3                	mov    %esi,%ebx
}
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    
  801bed:	00 00                	add    %al,(%eax)
	...

00801bf0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 10             	sub    $0x10,%esp
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bfc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c03:	75 11                	jne    801c16 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c0c:	e8 a2 f9 ff ff       	call   8015b3 <ipc_find_env>
  801c11:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c16:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c1d:	00 
  801c1e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c25:	00 
  801c26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2a:	a1 00 40 80 00       	mov    0x804000,%eax
  801c2f:	89 04 24             	mov    %eax,(%esp)
  801c32:	e8 16 f9 ff ff       	call   80154d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801c37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c3e:	00 
  801c3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4a:	e8 91 f8 ff ff       	call   8014e0 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c62:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c74:	b8 02 00 00 00       	mov    $0x2,%eax
  801c79:	e8 72 ff ff ff       	call   801bf0 <fsipc>
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	8b 40 0c             	mov    0xc(%eax),%eax
  801c8c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c91:	ba 00 00 00 00       	mov    $0x0,%edx
  801c96:	b8 06 00 00 00       	mov    $0x6,%eax
  801c9b:	e8 50 ff ff ff       	call   801bf0 <fsipc>
}
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 14             	sub    $0x14,%esp
  801ca9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbc:	b8 05 00 00 00       	mov    $0x5,%eax
  801cc1:	e8 2a ff ff ff       	call   801bf0 <fsipc>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 2b                	js     801cf5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cd1:	00 
  801cd2:	89 1c 24             	mov    %ebx,(%esp)
  801cd5:	e8 a9 f1 ff ff       	call   800e83 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cda:	a1 80 50 80 00       	mov    0x805080,%eax
  801cdf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ce5:	a1 84 50 80 00       	mov    0x805084,%eax
  801cea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf5:	83 c4 14             	add    $0x14,%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 14             	sub    $0x14,%esp
  801d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801d18:	76 05                	jbe    801d1f <devfile_write+0x24>
  801d1a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801d1f:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801d24:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801d36:	e8 2b f3 ff ff       	call   801066 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d40:	b8 04 00 00 00       	mov    $0x4,%eax
  801d45:	e8 a6 fe ff ff       	call   801bf0 <fsipc>
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 53                	js     801da1 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801d4e:	39 c3                	cmp    %eax,%ebx
  801d50:	73 24                	jae    801d76 <devfile_write+0x7b>
  801d52:	c7 44 24 0c 78 2e 80 	movl   $0x802e78,0xc(%esp)
  801d59:	00 
  801d5a:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  801d61:	00 
  801d62:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801d69:	00 
  801d6a:	c7 04 24 94 2e 80 00 	movl   $0x802e94,(%esp)
  801d71:	e8 6a ea ff ff       	call   8007e0 <_panic>
	assert(r <= PGSIZE);
  801d76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d7b:	7e 24                	jle    801da1 <devfile_write+0xa6>
  801d7d:	c7 44 24 0c 9f 2e 80 	movl   $0x802e9f,0xc(%esp)
  801d84:	00 
  801d85:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  801d8c:	00 
  801d8d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801d94:	00 
  801d95:	c7 04 24 94 2e 80 00 	movl   $0x802e94,(%esp)
  801d9c:	e8 3f ea ff ff       	call   8007e0 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801da1:	83 c4 14             	add    $0x14,%esp
  801da4:	5b                   	pop    %ebx
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	56                   	push   %esi
  801dab:	53                   	push   %ebx
  801dac:	83 ec 10             	sub    $0x10,%esp
  801daf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	8b 40 0c             	mov    0xc(%eax),%eax
  801db8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801dbd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801dc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc8:	b8 03 00 00 00       	mov    $0x3,%eax
  801dcd:	e8 1e fe ff ff       	call   801bf0 <fsipc>
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	78 6a                	js     801e42 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801dd8:	39 c6                	cmp    %eax,%esi
  801dda:	73 24                	jae    801e00 <devfile_read+0x59>
  801ddc:	c7 44 24 0c 78 2e 80 	movl   $0x802e78,0xc(%esp)
  801de3:	00 
  801de4:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  801deb:	00 
  801dec:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801df3:	00 
  801df4:	c7 04 24 94 2e 80 00 	movl   $0x802e94,(%esp)
  801dfb:	e8 e0 e9 ff ff       	call   8007e0 <_panic>
	assert(r <= PGSIZE);
  801e00:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e05:	7e 24                	jle    801e2b <devfile_read+0x84>
  801e07:	c7 44 24 0c 9f 2e 80 	movl   $0x802e9f,0xc(%esp)
  801e0e:	00 
  801e0f:	c7 44 24 08 7f 2e 80 	movl   $0x802e7f,0x8(%esp)
  801e16:	00 
  801e17:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801e1e:	00 
  801e1f:	c7 04 24 94 2e 80 00 	movl   $0x802e94,(%esp)
  801e26:	e8 b5 e9 ff ff       	call   8007e0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e36:	00 
  801e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3a:	89 04 24             	mov    %eax,(%esp)
  801e3d:	e8 ba f1 ff ff       	call   800ffc <memmove>
	return r;
}
  801e42:	89 d8                	mov    %ebx,%eax
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 20             	sub    $0x20,%esp
  801e53:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e56:	89 34 24             	mov    %esi,(%esp)
  801e59:	e8 f2 ef ff ff       	call   800e50 <strlen>
  801e5e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e63:	7f 60                	jg     801ec5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e68:	89 04 24             	mov    %eax,(%esp)
  801e6b:	e8 b3 f7 ff ff       	call   801623 <fd_alloc>
  801e70:	89 c3                	mov    %eax,%ebx
  801e72:	85 c0                	test   %eax,%eax
  801e74:	78 54                	js     801eca <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e81:	e8 fd ef ff ff       	call   800e83 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e89:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e91:	b8 01 00 00 00       	mov    $0x1,%eax
  801e96:	e8 55 fd ff ff       	call   801bf0 <fsipc>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	79 15                	jns    801eb6 <open+0x6b>
		fd_close(fd, 0);
  801ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ea8:	00 
  801ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eac:	89 04 24             	mov    %eax,(%esp)
  801eaf:	e8 74 f8 ff ff       	call   801728 <fd_close>
		return r;
  801eb4:	eb 14                	jmp    801eca <open+0x7f>
	}

	return fd2num(fd);
  801eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb9:	89 04 24             	mov    %eax,(%esp)
  801ebc:	e8 37 f7 ff ff       	call   8015f8 <fd2num>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	eb 05                	jmp    801eca <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ec5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801eca:	89 d8                	mov    %ebx,%eax
  801ecc:	83 c4 20             	add    $0x20,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    

00801ed3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ed9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ede:	b8 08 00 00 00       	mov    $0x8,%eax
  801ee3:	e8 08 fd ff ff       	call   801bf0 <fsipc>
}
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    
	...

00801eec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 10             	sub    $0x10,%esp
  801ef4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	89 04 24             	mov    %eax,(%esp)
  801efd:	e8 06 f7 ff ff       	call   801608 <fd2data>
  801f02:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f04:	c7 44 24 04 ab 2e 80 	movl   $0x802eab,0x4(%esp)
  801f0b:	00 
  801f0c:	89 34 24             	mov    %esi,(%esp)
  801f0f:	e8 6f ef ff ff       	call   800e83 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f14:	8b 43 04             	mov    0x4(%ebx),%eax
  801f17:	2b 03                	sub    (%ebx),%eax
  801f19:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f1f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f26:	00 00 00 
	stat->st_dev = &devpipe;
  801f29:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801f30:	30 80 00 
	return 0;
}
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	5b                   	pop    %ebx
  801f3c:	5e                   	pop    %esi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    

00801f3f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	53                   	push   %ebx
  801f43:	83 ec 14             	sub    $0x14,%esp
  801f46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f49:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f54:	e8 c3 f3 ff ff       	call   80131c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f59:	89 1c 24             	mov    %ebx,(%esp)
  801f5c:	e8 a7 f6 ff ff       	call   801608 <fd2data>
  801f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6c:	e8 ab f3 ff ff       	call   80131c <sys_page_unmap>
}
  801f71:	83 c4 14             	add    $0x14,%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	57                   	push   %edi
  801f7b:	56                   	push   %esi
  801f7c:	53                   	push   %ebx
  801f7d:	83 ec 2c             	sub    $0x2c,%esp
  801f80:	89 c7                	mov    %eax,%edi
  801f82:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f85:	a1 04 40 80 00       	mov    0x804004,%eax
  801f8a:	8b 00                	mov    (%eax),%eax
  801f8c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f8f:	89 3c 24             	mov    %edi,(%esp)
  801f92:	e8 71 04 00 00       	call   802408 <pageref>
  801f97:	89 c6                	mov    %eax,%esi
  801f99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f9c:	89 04 24             	mov    %eax,(%esp)
  801f9f:	e8 64 04 00 00       	call   802408 <pageref>
  801fa4:	39 c6                	cmp    %eax,%esi
  801fa6:	0f 94 c0             	sete   %al
  801fa9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801fac:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fb2:	8b 12                	mov    (%edx),%edx
  801fb4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fb7:	39 cb                	cmp    %ecx,%ebx
  801fb9:	75 08                	jne    801fc3 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801fbb:	83 c4 2c             	add    $0x2c,%esp
  801fbe:	5b                   	pop    %ebx
  801fbf:	5e                   	pop    %esi
  801fc0:	5f                   	pop    %edi
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801fc3:	83 f8 01             	cmp    $0x1,%eax
  801fc6:	75 bd                	jne    801f85 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fc8:	8b 42 58             	mov    0x58(%edx),%eax
  801fcb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801fd2:	00 
  801fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fdb:	c7 04 24 b2 2e 80 00 	movl   $0x802eb2,(%esp)
  801fe2:	e8 f1 e8 ff ff       	call   8008d8 <cprintf>
  801fe7:	eb 9c                	jmp    801f85 <_pipeisclosed+0xe>

00801fe9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	57                   	push   %edi
  801fed:	56                   	push   %esi
  801fee:	53                   	push   %ebx
  801fef:	83 ec 1c             	sub    $0x1c,%esp
  801ff2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ff5:	89 34 24             	mov    %esi,(%esp)
  801ff8:	e8 0b f6 ff ff       	call   801608 <fd2data>
  801ffd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fff:	bf 00 00 00 00       	mov    $0x0,%edi
  802004:	eb 3c                	jmp    802042 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802006:	89 da                	mov    %ebx,%edx
  802008:	89 f0                	mov    %esi,%eax
  80200a:	e8 68 ff ff ff       	call   801f77 <_pipeisclosed>
  80200f:	85 c0                	test   %eax,%eax
  802011:	75 38                	jne    80204b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802013:	e8 3e f2 ff ff       	call   801256 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802018:	8b 43 04             	mov    0x4(%ebx),%eax
  80201b:	8b 13                	mov    (%ebx),%edx
  80201d:	83 c2 20             	add    $0x20,%edx
  802020:	39 d0                	cmp    %edx,%eax
  802022:	73 e2                	jae    802006 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802024:	8b 55 0c             	mov    0xc(%ebp),%edx
  802027:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80202a:	89 c2                	mov    %eax,%edx
  80202c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802032:	79 05                	jns    802039 <devpipe_write+0x50>
  802034:	4a                   	dec    %edx
  802035:	83 ca e0             	or     $0xffffffe0,%edx
  802038:	42                   	inc    %edx
  802039:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80203d:	40                   	inc    %eax
  80203e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802041:	47                   	inc    %edi
  802042:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802045:	75 d1                	jne    802018 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802047:	89 f8                	mov    %edi,%eax
  802049:	eb 05                	jmp    802050 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80204b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    

00802058 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	57                   	push   %edi
  80205c:	56                   	push   %esi
  80205d:	53                   	push   %ebx
  80205e:	83 ec 1c             	sub    $0x1c,%esp
  802061:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802064:	89 3c 24             	mov    %edi,(%esp)
  802067:	e8 9c f5 ff ff       	call   801608 <fd2data>
  80206c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206e:	be 00 00 00 00       	mov    $0x0,%esi
  802073:	eb 3a                	jmp    8020af <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802075:	85 f6                	test   %esi,%esi
  802077:	74 04                	je     80207d <devpipe_read+0x25>
				return i;
  802079:	89 f0                	mov    %esi,%eax
  80207b:	eb 40                	jmp    8020bd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80207d:	89 da                	mov    %ebx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	e8 f1 fe ff ff       	call   801f77 <_pipeisclosed>
  802086:	85 c0                	test   %eax,%eax
  802088:	75 2e                	jne    8020b8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80208a:	e8 c7 f1 ff ff       	call   801256 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80208f:	8b 03                	mov    (%ebx),%eax
  802091:	3b 43 04             	cmp    0x4(%ebx),%eax
  802094:	74 df                	je     802075 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802096:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80209b:	79 05                	jns    8020a2 <devpipe_read+0x4a>
  80209d:	48                   	dec    %eax
  80209e:	83 c8 e0             	or     $0xffffffe0,%eax
  8020a1:	40                   	inc    %eax
  8020a2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8020a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8020ac:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ae:	46                   	inc    %esi
  8020af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020b2:	75 db                	jne    80208f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020b4:	89 f0                	mov    %esi,%eax
  8020b6:	eb 05                	jmp    8020bd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020b8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020bd:	83 c4 1c             	add    $0x1c,%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	57                   	push   %edi
  8020c9:	56                   	push   %esi
  8020ca:	53                   	push   %ebx
  8020cb:	83 ec 3c             	sub    $0x3c,%esp
  8020ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8020d4:	89 04 24             	mov    %eax,(%esp)
  8020d7:	e8 47 f5 ff ff       	call   801623 <fd_alloc>
  8020dc:	89 c3                	mov    %eax,%ebx
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	0f 88 45 01 00 00    	js     80222b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020ed:	00 
  8020ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020fc:	e8 74 f1 ff ff       	call   801275 <sys_page_alloc>
  802101:	89 c3                	mov    %eax,%ebx
  802103:	85 c0                	test   %eax,%eax
  802105:	0f 88 20 01 00 00    	js     80222b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80210b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80210e:	89 04 24             	mov    %eax,(%esp)
  802111:	e8 0d f5 ff ff       	call   801623 <fd_alloc>
  802116:	89 c3                	mov    %eax,%ebx
  802118:	85 c0                	test   %eax,%eax
  80211a:	0f 88 f8 00 00 00    	js     802218 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802120:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802127:	00 
  802128:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80212b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802136:	e8 3a f1 ff ff       	call   801275 <sys_page_alloc>
  80213b:	89 c3                	mov    %eax,%ebx
  80213d:	85 c0                	test   %eax,%eax
  80213f:	0f 88 d3 00 00 00    	js     802218 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802148:	89 04 24             	mov    %eax,(%esp)
  80214b:	e8 b8 f4 ff ff       	call   801608 <fd2data>
  802150:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802152:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802159:	00 
  80215a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802165:	e8 0b f1 ff ff       	call   801275 <sys_page_alloc>
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	85 c0                	test   %eax,%eax
  80216e:	0f 88 91 00 00 00    	js     802205 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802174:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802177:	89 04 24             	mov    %eax,(%esp)
  80217a:	e8 89 f4 ff ff       	call   801608 <fd2data>
  80217f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802186:	00 
  802187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802192:	00 
  802193:	89 74 24 04          	mov    %esi,0x4(%esp)
  802197:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219e:	e8 26 f1 ff ff       	call   8012c9 <sys_page_map>
  8021a3:	89 c3                	mov    %eax,%ebx
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	78 4c                	js     8021f5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021a9:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021b2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021be:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021cc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021d6:	89 04 24             	mov    %eax,(%esp)
  8021d9:	e8 1a f4 ff ff       	call   8015f8 <fd2num>
  8021de:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8021e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021e3:	89 04 24             	mov    %eax,(%esp)
  8021e6:	e8 0d f4 ff ff       	call   8015f8 <fd2num>
  8021eb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8021ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021f3:	eb 36                	jmp    80222b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8021f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802200:	e8 17 f1 ff ff       	call   80131c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802205:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802213:	e8 04 f1 ff ff       	call   80131c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80221b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80221f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802226:	e8 f1 f0 ff ff       	call   80131c <sys_page_unmap>
    err:
	return r;
}
  80222b:	89 d8                	mov    %ebx,%eax
  80222d:	83 c4 3c             	add    $0x3c,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80223b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802242:	8b 45 08             	mov    0x8(%ebp),%eax
  802245:	89 04 24             	mov    %eax,(%esp)
  802248:	e8 29 f4 ff ff       	call   801676 <fd_lookup>
  80224d:	85 c0                	test   %eax,%eax
  80224f:	78 15                	js     802266 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802251:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802254:	89 04 24             	mov    %eax,(%esp)
  802257:	e8 ac f3 ff ff       	call   801608 <fd2data>
	return _pipeisclosed(fd, p);
  80225c:	89 c2                	mov    %eax,%edx
  80225e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802261:	e8 11 fd ff ff       	call   801f77 <_pipeisclosed>
}
  802266:	c9                   	leave  
  802267:	c3                   	ret    

00802268 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80226b:	b8 00 00 00 00       	mov    $0x0,%eax
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    

00802272 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802278:	c7 44 24 04 ca 2e 80 	movl   $0x802eca,0x4(%esp)
  80227f:	00 
  802280:	8b 45 0c             	mov    0xc(%ebp),%eax
  802283:	89 04 24             	mov    %eax,(%esp)
  802286:	e8 f8 eb ff ff       	call   800e83 <strcpy>
	return 0;
}
  80228b:	b8 00 00 00 00       	mov    $0x0,%eax
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	57                   	push   %edi
  802296:	56                   	push   %esi
  802297:	53                   	push   %ebx
  802298:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80229e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022a3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a9:	eb 30                	jmp    8022db <devcons_write+0x49>
		m = n - tot;
  8022ab:	8b 75 10             	mov    0x10(%ebp),%esi
  8022ae:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8022b0:	83 fe 7f             	cmp    $0x7f,%esi
  8022b3:	76 05                	jbe    8022ba <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8022b5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022be:	03 45 0c             	add    0xc(%ebp),%eax
  8022c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c5:	89 3c 24             	mov    %edi,(%esp)
  8022c8:	e8 2f ed ff ff       	call   800ffc <memmove>
		sys_cputs(buf, m);
  8022cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d1:	89 3c 24             	mov    %edi,(%esp)
  8022d4:	e8 cf ee ff ff       	call   8011a8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022d9:	01 f3                	add    %esi,%ebx
  8022db:	89 d8                	mov    %ebx,%eax
  8022dd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022e0:	72 c9                	jb     8022ab <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022e2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    

008022ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ed:	55                   	push   %ebp
  8022ee:	89 e5                	mov    %esp,%ebp
  8022f0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8022f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022f7:	75 07                	jne    802300 <devcons_read+0x13>
  8022f9:	eb 25                	jmp    802320 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022fb:	e8 56 ef ff ff       	call   801256 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802300:	e8 c1 ee ff ff       	call   8011c6 <sys_cgetc>
  802305:	85 c0                	test   %eax,%eax
  802307:	74 f2                	je     8022fb <devcons_read+0xe>
  802309:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 1d                	js     80232c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80230f:	83 f8 04             	cmp    $0x4,%eax
  802312:	74 13                	je     802327 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802314:	8b 45 0c             	mov    0xc(%ebp),%eax
  802317:	88 10                	mov    %dl,(%eax)
	return 1;
  802319:	b8 01 00 00 00       	mov    $0x1,%eax
  80231e:	eb 0c                	jmp    80232c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802320:	b8 00 00 00 00       	mov    $0x0,%eax
  802325:	eb 05                	jmp    80232c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802327:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80232c:	c9                   	leave  
  80232d:	c3                   	ret    

0080232e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802334:	8b 45 08             	mov    0x8(%ebp),%eax
  802337:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80233a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802341:	00 
  802342:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802345:	89 04 24             	mov    %eax,(%esp)
  802348:	e8 5b ee ff ff       	call   8011a8 <sys_cputs>
}
  80234d:	c9                   	leave  
  80234e:	c3                   	ret    

0080234f <getchar>:

int
getchar(void)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802355:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80235c:	00 
  80235d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802360:	89 44 24 04          	mov    %eax,0x4(%esp)
  802364:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236b:	e8 a4 f5 ff ff       	call   801914 <read>
	if (r < 0)
  802370:	85 c0                	test   %eax,%eax
  802372:	78 0f                	js     802383 <getchar+0x34>
		return r;
	if (r < 1)
  802374:	85 c0                	test   %eax,%eax
  802376:	7e 06                	jle    80237e <getchar+0x2f>
		return -E_EOF;
	return c;
  802378:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80237c:	eb 05                	jmp    802383 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80237e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802383:	c9                   	leave  
  802384:	c3                   	ret    

00802385 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802385:	55                   	push   %ebp
  802386:	89 e5                	mov    %esp,%ebp
  802388:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80238b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802392:	8b 45 08             	mov    0x8(%ebp),%eax
  802395:	89 04 24             	mov    %eax,(%esp)
  802398:	e8 d9 f2 ff ff       	call   801676 <fd_lookup>
  80239d:	85 c0                	test   %eax,%eax
  80239f:	78 11                	js     8023b2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8023aa:	39 10                	cmp    %edx,(%eax)
  8023ac:	0f 94 c0             	sete   %al
  8023af:	0f b6 c0             	movzbl %al,%eax
}
  8023b2:	c9                   	leave  
  8023b3:	c3                   	ret    

008023b4 <opencons>:

int
opencons(void)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
  8023b7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023bd:	89 04 24             	mov    %eax,(%esp)
  8023c0:	e8 5e f2 ff ff       	call   801623 <fd_alloc>
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	78 3c                	js     802405 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023c9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023d0:	00 
  8023d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023df:	e8 91 ee ff ff       	call   801275 <sys_page_alloc>
  8023e4:	85 c0                	test   %eax,%eax
  8023e6:	78 1d                	js     802405 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023e8:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8023ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023fd:	89 04 24             	mov    %eax,(%esp)
  802400:	e8 f3 f1 ff ff       	call   8015f8 <fd2num>
}
  802405:	c9                   	leave  
  802406:	c3                   	ret    
	...

00802408 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80240e:	89 c2                	mov    %eax,%edx
  802410:	c1 ea 16             	shr    $0x16,%edx
  802413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80241a:	f6 c2 01             	test   $0x1,%dl
  80241d:	74 1e                	je     80243d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80241f:	c1 e8 0c             	shr    $0xc,%eax
  802422:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802429:	a8 01                	test   $0x1,%al
  80242b:	74 17                	je     802444 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80242d:	c1 e8 0c             	shr    $0xc,%eax
  802430:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802437:	ef 
  802438:	0f b7 c0             	movzwl %ax,%eax
  80243b:	eb 0c                	jmp    802449 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80243d:	b8 00 00 00 00       	mov    $0x0,%eax
  802442:	eb 05                	jmp    802449 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802444:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    
	...

0080244c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80244c:	55                   	push   %ebp
  80244d:	57                   	push   %edi
  80244e:	56                   	push   %esi
  80244f:	83 ec 10             	sub    $0x10,%esp
  802452:	8b 74 24 20          	mov    0x20(%esp),%esi
  802456:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80245a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802462:	89 cd                	mov    %ecx,%ebp
  802464:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802468:	85 c0                	test   %eax,%eax
  80246a:	75 2c                	jne    802498 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80246c:	39 f9                	cmp    %edi,%ecx
  80246e:	77 68                	ja     8024d8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802470:	85 c9                	test   %ecx,%ecx
  802472:	75 0b                	jne    80247f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802474:	b8 01 00 00 00       	mov    $0x1,%eax
  802479:	31 d2                	xor    %edx,%edx
  80247b:	f7 f1                	div    %ecx
  80247d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80247f:	31 d2                	xor    %edx,%edx
  802481:	89 f8                	mov    %edi,%eax
  802483:	f7 f1                	div    %ecx
  802485:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802487:	89 f0                	mov    %esi,%eax
  802489:	f7 f1                	div    %ecx
  80248b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80248d:	89 f0                	mov    %esi,%eax
  80248f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802491:	83 c4 10             	add    $0x10,%esp
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802498:	39 f8                	cmp    %edi,%eax
  80249a:	77 2c                	ja     8024c8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80249c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80249f:	83 f6 1f             	xor    $0x1f,%esi
  8024a2:	75 4c                	jne    8024f0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024a4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024a6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024ab:	72 0a                	jb     8024b7 <__udivdi3+0x6b>
  8024ad:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8024b1:	0f 87 ad 00 00 00    	ja     802564 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024b7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024bc:	89 f0                	mov    %esi,%eax
  8024be:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024c0:	83 c4 10             	add    $0x10,%esp
  8024c3:	5e                   	pop    %esi
  8024c4:	5f                   	pop    %edi
  8024c5:	5d                   	pop    %ebp
  8024c6:	c3                   	ret    
  8024c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024c8:	31 ff                	xor    %edi,%edi
  8024ca:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024cc:	89 f0                	mov    %esi,%eax
  8024ce:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024d0:	83 c4 10             	add    $0x10,%esp
  8024d3:	5e                   	pop    %esi
  8024d4:	5f                   	pop    %edi
  8024d5:	5d                   	pop    %ebp
  8024d6:	c3                   	ret    
  8024d7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	89 f0                	mov    %esi,%eax
  8024dc:	f7 f1                	div    %ecx
  8024de:	89 c6                	mov    %eax,%esi
  8024e0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024e2:	89 f0                	mov    %esi,%eax
  8024e4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024e6:	83 c4 10             	add    $0x10,%esp
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024f0:	89 f1                	mov    %esi,%ecx
  8024f2:	d3 e0                	shl    %cl,%eax
  8024f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024f8:	b8 20 00 00 00       	mov    $0x20,%eax
  8024fd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8024ff:	89 ea                	mov    %ebp,%edx
  802501:	88 c1                	mov    %al,%cl
  802503:	d3 ea                	shr    %cl,%edx
  802505:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802509:	09 ca                	or     %ecx,%edx
  80250b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80250f:	89 f1                	mov    %esi,%ecx
  802511:	d3 e5                	shl    %cl,%ebp
  802513:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802517:	89 fd                	mov    %edi,%ebp
  802519:	88 c1                	mov    %al,%cl
  80251b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80251d:	89 fa                	mov    %edi,%edx
  80251f:	89 f1                	mov    %esi,%ecx
  802521:	d3 e2                	shl    %cl,%edx
  802523:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802527:	88 c1                	mov    %al,%cl
  802529:	d3 ef                	shr    %cl,%edi
  80252b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80252d:	89 f8                	mov    %edi,%eax
  80252f:	89 ea                	mov    %ebp,%edx
  802531:	f7 74 24 08          	divl   0x8(%esp)
  802535:	89 d1                	mov    %edx,%ecx
  802537:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802539:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80253d:	39 d1                	cmp    %edx,%ecx
  80253f:	72 17                	jb     802558 <__udivdi3+0x10c>
  802541:	74 09                	je     80254c <__udivdi3+0x100>
  802543:	89 fe                	mov    %edi,%esi
  802545:	31 ff                	xor    %edi,%edi
  802547:	e9 41 ff ff ff       	jmp    80248d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80254c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802550:	89 f1                	mov    %esi,%ecx
  802552:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802554:	39 c2                	cmp    %eax,%edx
  802556:	73 eb                	jae    802543 <__udivdi3+0xf7>
		{
		  q0--;
  802558:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80255b:	31 ff                	xor    %edi,%edi
  80255d:	e9 2b ff ff ff       	jmp    80248d <__udivdi3+0x41>
  802562:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802564:	31 f6                	xor    %esi,%esi
  802566:	e9 22 ff ff ff       	jmp    80248d <__udivdi3+0x41>
	...

0080256c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80256c:	55                   	push   %ebp
  80256d:	57                   	push   %edi
  80256e:	56                   	push   %esi
  80256f:	83 ec 20             	sub    $0x20,%esp
  802572:	8b 44 24 30          	mov    0x30(%esp),%eax
  802576:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80257a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80257e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802582:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802586:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80258a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80258c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80258e:	85 ed                	test   %ebp,%ebp
  802590:	75 16                	jne    8025a8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802592:	39 f1                	cmp    %esi,%ecx
  802594:	0f 86 a6 00 00 00    	jbe    802640 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80259a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80259c:	89 d0                	mov    %edx,%eax
  80259e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025a0:	83 c4 20             	add    $0x20,%esp
  8025a3:	5e                   	pop    %esi
  8025a4:	5f                   	pop    %edi
  8025a5:	5d                   	pop    %ebp
  8025a6:	c3                   	ret    
  8025a7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025a8:	39 f5                	cmp    %esi,%ebp
  8025aa:	0f 87 ac 00 00 00    	ja     80265c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025b0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8025b3:	83 f0 1f             	xor    $0x1f,%eax
  8025b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025ba:	0f 84 a8 00 00 00    	je     802668 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025c0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025c4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025c6:	bf 20 00 00 00       	mov    $0x20,%edi
  8025cb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8025cf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	d3 e8                	shr    %cl,%eax
  8025d7:	09 e8                	or     %ebp,%eax
  8025d9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8025dd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025e1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025e5:	d3 e0                	shl    %cl,%eax
  8025e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025eb:	89 f2                	mov    %esi,%edx
  8025ed:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8025ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025f3:	d3 e0                	shl    %cl,%eax
  8025f5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025f9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025fd:	89 f9                	mov    %edi,%ecx
  8025ff:	d3 e8                	shr    %cl,%eax
  802601:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802603:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802605:	89 f2                	mov    %esi,%edx
  802607:	f7 74 24 18          	divl   0x18(%esp)
  80260b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80260d:	f7 64 24 0c          	mull   0xc(%esp)
  802611:	89 c5                	mov    %eax,%ebp
  802613:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802615:	39 d6                	cmp    %edx,%esi
  802617:	72 67                	jb     802680 <__umoddi3+0x114>
  802619:	74 75                	je     802690 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80261b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80261f:	29 e8                	sub    %ebp,%eax
  802621:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802623:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 f2                	mov    %esi,%edx
  80262b:	89 f9                	mov    %edi,%ecx
  80262d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80262f:	09 d0                	or     %edx,%eax
  802631:	89 f2                	mov    %esi,%edx
  802633:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802637:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802639:	83 c4 20             	add    $0x20,%esp
  80263c:	5e                   	pop    %esi
  80263d:	5f                   	pop    %edi
  80263e:	5d                   	pop    %ebp
  80263f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802640:	85 c9                	test   %ecx,%ecx
  802642:	75 0b                	jne    80264f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802644:	b8 01 00 00 00       	mov    $0x1,%eax
  802649:	31 d2                	xor    %edx,%edx
  80264b:	f7 f1                	div    %ecx
  80264d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80264f:	89 f0                	mov    %esi,%eax
  802651:	31 d2                	xor    %edx,%edx
  802653:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802655:	89 f8                	mov    %edi,%eax
  802657:	e9 3e ff ff ff       	jmp    80259a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80265c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80265e:	83 c4 20             	add    $0x20,%esp
  802661:	5e                   	pop    %esi
  802662:	5f                   	pop    %edi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    
  802665:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802668:	39 f5                	cmp    %esi,%ebp
  80266a:	72 04                	jb     802670 <__umoddi3+0x104>
  80266c:	39 f9                	cmp    %edi,%ecx
  80266e:	77 06                	ja     802676 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802670:	89 f2                	mov    %esi,%edx
  802672:	29 cf                	sub    %ecx,%edi
  802674:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802676:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802678:	83 c4 20             	add    $0x20,%esp
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    
  80267f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802680:	89 d1                	mov    %edx,%ecx
  802682:	89 c5                	mov    %eax,%ebp
  802684:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802688:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80268c:	eb 8d                	jmp    80261b <__umoddi3+0xaf>
  80268e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802690:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802694:	72 ea                	jb     802680 <__umoddi3+0x114>
  802696:	89 f1                	mov    %esi,%ecx
  802698:	eb 81                	jmp    80261b <__umoddi3+0xaf>
