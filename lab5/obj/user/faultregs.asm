
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 37 05 00 00       	call   800568 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 33 2b 80 	movl   $0x802b33,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  80005b:	e8 74 06 00 00       	call   8006d4 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 70 25 80 	movl   $0x802570,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  80007b:	e8 54 06 00 00       	call   8006d4 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  80008d:	e8 42 06 00 00       	call   8006d4 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  8000a0:	e8 2f 06 00 00       	call   8006d4 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 92 25 80 	movl   $0x802592,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  8000c7:	e8 08 06 00 00       	call   8006d4 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  8000db:	e8 f4 05 00 00       	call   8006d4 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  8000e9:	e8 e6 05 00 00       	call   8006d4 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 96 25 80 	movl   $0x802596,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  800110:	e8 bf 05 00 00       	call   8006d4 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800124:	e8 ab 05 00 00       	call   8006d4 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  800132:	e8 9d 05 00 00       	call   8006d4 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 9a 25 80 	movl   $0x80259a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  800159:	e8 76 05 00 00       	call   8006d4 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  80016d:	e8 62 05 00 00       	call   8006d4 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  80017b:	e8 54 05 00 00       	call   8006d4 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 9e 25 80 	movl   $0x80259e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  8001a2:	e8 2d 05 00 00       	call   8006d4 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  8001b6:	e8 19 05 00 00       	call   8006d4 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  8001c4:	e8 0b 05 00 00       	call   8006d4 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 a2 25 80 	movl   $0x8025a2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  8001eb:	e8 e4 04 00 00       	call   8006d4 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  8001ff:	e8 d0 04 00 00       	call   8006d4 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  80020d:	e8 c2 04 00 00       	call   8006d4 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 a6 25 80 	movl   $0x8025a6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  800234:	e8 9b 04 00 00       	call   8006d4 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800248:	e8 87 04 00 00       	call   8006d4 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  800256:	e8 79 04 00 00       	call   8006d4 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 aa 25 80 	movl   $0x8025aa,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  80027d:	e8 52 04 00 00       	call   8006d4 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800291:	e8 3e 04 00 00       	call   8006d4 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  80029f:	e8 30 04 00 00       	call   8006d4 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ae 25 80 	movl   $0x8025ae,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  8002c6:	e8 09 04 00 00       	call   8006d4 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  8002da:	e8 f5 03 00 00       	call   8006d4 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  8002e8:	e8 e7 03 00 00       	call   8006d4 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 b5 25 80 	movl   $0x8025b5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  80030f:	e8 c0 03 00 00       	call   8006d4 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800323:	e8 ac 03 00 00       	call   8006d4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 b9 25 80 00 	movl   $0x8025b9,(%esp)
  800336:	e8 99 03 00 00       	call   8006d4 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  800348:	e8 87 03 00 00       	call   8006d4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 b9 25 80 00 	movl   $0x8025b9,(%esp)
  80035b:	e8 74 03 00 00       	call   8006d4 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800369:	e8 66 03 00 00       	call   8006d4 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  800377:	e8 58 03 00 00       	call   8006d4 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	83 ec 20             	sub    $0x20,%esp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800397:	74 27                	je     8003c0 <pgfault+0x3c>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800399:	8b 40 28             	mov    0x28(%eax),%eax
  80039c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 c7 25 80 00 	movl   $0x8025c7,(%esp)
  8003bb:	e8 1c 02 00 00       	call   8005dc <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf 80 40 80 00       	mov    $0x804080,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags & ~FL_RF;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  8003dd:	89 15 a4 40 80 00    	mov    %edx,0x8040a4
	during.esp = utf->utf_esp;
  8003e3:	8b 40 30             	mov    0x30(%eax),%eax
  8003e6:	a3 a8 40 80 00       	mov    %eax,0x8040a8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003eb:	c7 44 24 04 df 25 80 	movl   $0x8025df,0x4(%esp)
  8003f2:	00 
  8003f3:	c7 04 24 ed 25 80 00 	movl   $0x8025ed,(%esp)
  8003fa:	b9 80 40 80 00       	mov    $0x804080,%ecx
  8003ff:	ba d8 25 80 00       	mov    $0x8025d8,%edx
  800404:	b8 00 40 80 00       	mov    $0x804000,%eax
  800409:	e8 26 fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80040e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800415:	00 
  800416:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80041d:	00 
  80041e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800425:	e8 47 0c 00 00       	call   801071 <sys_page_alloc>
  80042a:	85 c0                	test   %eax,%eax
  80042c:	79 20                	jns    80044e <pgfault+0xca>
		panic("sys_page_alloc: %e", r);
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 f4 25 80 	movl   $0x8025f4,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 c7 25 80 00 	movl   $0x8025c7,(%esp)
  800449:	e8 8e 01 00 00       	call   8005dc <_panic>
}
  80044e:	83 c4 20             	add    $0x20,%esp
  800451:	5e                   	pop    %esi
  800452:	5f                   	pop    %edi
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    

00800455 <umain>:

void
umain(int argc, char **argv)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80045b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800462:	e8 75 0e 00 00       	call   8012dc <set_pgfault_handler>

	asm volatile(
  800467:	50                   	push   %eax
  800468:	9c                   	pushf  
  800469:	58                   	pop    %eax
  80046a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80046f:	50                   	push   %eax
  800470:	9d                   	popf   
  800471:	a3 24 40 80 00       	mov    %eax,0x804024
  800476:	8d 05 b1 04 80 00    	lea    0x8004b1,%eax
  80047c:	a3 20 40 80 00       	mov    %eax,0x804020
  800481:	58                   	pop    %eax
  800482:	89 3d 00 40 80 00    	mov    %edi,0x804000
  800488:	89 35 04 40 80 00    	mov    %esi,0x804004
  80048e:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800494:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80049a:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004a0:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8004a6:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8004ab:	89 25 28 40 80 00    	mov    %esp,0x804028
  8004b1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b8:	00 00 00 
  8004bb:	89 3d 40 40 80 00    	mov    %edi,0x804040
  8004c1:	89 35 44 40 80 00    	mov    %esi,0x804044
  8004c7:	89 2d 48 40 80 00    	mov    %ebp,0x804048
  8004cd:	89 1d 50 40 80 00    	mov    %ebx,0x804050
  8004d3:	89 15 54 40 80 00    	mov    %edx,0x804054
  8004d9:	89 0d 58 40 80 00    	mov    %ecx,0x804058
  8004df:	a3 5c 40 80 00       	mov    %eax,0x80405c
  8004e4:	89 25 68 40 80 00    	mov    %esp,0x804068
  8004ea:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  8004f0:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8004f6:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  8004fc:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  800502:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800508:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  80050e:	a1 1c 40 80 00       	mov    0x80401c,%eax
  800513:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800519:	50                   	push   %eax
  80051a:	9c                   	pushf  
  80051b:	58                   	pop    %eax
  80051c:	a3 64 40 80 00       	mov    %eax,0x804064
  800521:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800522:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800529:	74 0c                	je     800537 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80052b:	c7 04 24 54 26 80 00 	movl   $0x802654,(%esp)
  800532:	e8 9d 01 00 00       	call   8006d4 <cprintf>
	after.eip = before.eip;
  800537:	a1 20 40 80 00       	mov    0x804020,%eax
  80053c:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  800541:	c7 44 24 04 07 26 80 	movl   $0x802607,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 18 26 80 00 	movl   $0x802618,(%esp)
  800550:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800555:	ba d8 25 80 00       	mov    $0x8025d8,%edx
  80055a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80055f:	e8 d0 fa ff ff       	call   800034 <check_regs>
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	56                   	push   %esi
  80056c:	53                   	push   %ebx
  80056d:	83 ec 20             	sub    $0x20,%esp
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800576:	e8 b8 0a 00 00       	call   801033 <sys_getenvid>
  80057b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800580:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800587:	c1 e0 07             	shl    $0x7,%eax
  80058a:	29 d0                	sub    %edx,%eax
  80058c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800591:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800597:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80059c:	85 f6                	test   %esi,%esi
  80059e:	7e 07                	jle    8005a7 <libmain+0x3f>
		binaryname = argv[0];
  8005a0:	8b 03                	mov    (%ebx),%eax
  8005a2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ab:	89 34 24             	mov    %esi,(%esp)
  8005ae:	e8 a2 fe ff ff       	call   800455 <umain>

	// exit gracefully
	exit();
  8005b3:	e8 08 00 00 00       	call   8005c0 <exit>
}
  8005b8:	83 c4 20             	add    $0x20,%esp
  8005bb:	5b                   	pop    %ebx
  8005bc:	5e                   	pop    %esi
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    
	...

008005c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005c6:	e8 b2 0f 00 00       	call   80157d <close_all>
	sys_env_destroy(0);
  8005cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005d2:	e8 0a 0a 00 00       	call   800fe1 <sys_env_destroy>
}
  8005d7:	c9                   	leave  
  8005d8:	c3                   	ret    
  8005d9:	00 00                	add    %al,(%eax)
	...

008005dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	56                   	push   %esi
  8005e0:	53                   	push   %ebx
  8005e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005e7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8005ed:	e8 41 0a 00 00       	call   801033 <sys_getenvid>
  8005f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8005fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800600:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800604:	89 44 24 04          	mov    %eax,0x4(%esp)
  800608:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  80060f:	e8 c0 00 00 00       	call   8006d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800614:	89 74 24 04          	mov    %esi,0x4(%esp)
  800618:	8b 45 10             	mov    0x10(%ebp),%eax
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	e8 50 00 00 00       	call   800673 <vcprintf>
	cprintf("\n");
  800623:	c7 04 24 32 2b 80 00 	movl   $0x802b32,(%esp)
  80062a:	e8 a5 00 00 00       	call   8006d4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062f:	cc                   	int3   
  800630:	eb fd                	jmp    80062f <_panic+0x53>
	...

00800634 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	53                   	push   %ebx
  800638:	83 ec 14             	sub    $0x14,%esp
  80063b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063e:	8b 03                	mov    (%ebx),%eax
  800640:	8b 55 08             	mov    0x8(%ebp),%edx
  800643:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800647:	40                   	inc    %eax
  800648:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80064a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064f:	75 19                	jne    80066a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800651:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800658:	00 
  800659:	8d 43 08             	lea    0x8(%ebx),%eax
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	e8 40 09 00 00       	call   800fa4 <sys_cputs>
		b->idx = 0;
  800664:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80066a:	ff 43 04             	incl   0x4(%ebx)
}
  80066d:	83 c4 14             	add    $0x14,%esp
  800670:	5b                   	pop    %ebx
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80067c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800683:	00 00 00 
	b.cnt = 0;
  800686:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80068d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800690:	8b 45 0c             	mov    0xc(%ebp),%eax
  800693:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a8:	c7 04 24 34 06 80 00 	movl   $0x800634,(%esp)
  8006af:	e8 82 01 00 00       	call   800836 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	e8 d8 08 00 00       	call   800fa4 <sys_cputs>

	return b.cnt;
}
  8006cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	e8 87 ff ff ff       	call   800673 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    
	...

008006f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	57                   	push   %edi
  8006f4:	56                   	push   %esi
  8006f5:	53                   	push   %ebx
  8006f6:	83 ec 3c             	sub    $0x3c,%esp
  8006f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006fc:	89 d7                	mov    %edx,%edi
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800704:	8b 45 0c             	mov    0xc(%ebp),%eax
  800707:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80070d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800710:	85 c0                	test   %eax,%eax
  800712:	75 08                	jne    80071c <printnum+0x2c>
  800714:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800717:	39 45 10             	cmp    %eax,0x10(%ebp)
  80071a:	77 57                	ja     800773 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80071c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800720:	4b                   	dec    %ebx
  800721:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800725:	8b 45 10             	mov    0x10(%ebp),%eax
  800728:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800730:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800734:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80073b:	00 
  80073c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800745:	89 44 24 04          	mov    %eax,0x4(%esp)
  800749:	e8 b2 1b 00 00       	call   802300 <__udivdi3>
  80074e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800752:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800756:	89 04 24             	mov    %eax,(%esp)
  800759:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075d:	89 fa                	mov    %edi,%edx
  80075f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800762:	e8 89 ff ff ff       	call   8006f0 <printnum>
  800767:	eb 0f                	jmp    800778 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800769:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076d:	89 34 24             	mov    %esi,(%esp)
  800770:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800773:	4b                   	dec    %ebx
  800774:	85 db                	test   %ebx,%ebx
  800776:	7f f1                	jg     800769 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800778:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800780:	8b 45 10             	mov    0x10(%ebp),%eax
  800783:	89 44 24 08          	mov    %eax,0x8(%esp)
  800787:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80078e:	00 
  80078f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800792:	89 04 24             	mov    %eax,(%esp)
  800795:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079c:	e8 7f 1c 00 00       	call   802420 <__umoddi3>
  8007a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a5:	0f be 80 a3 26 80 00 	movsbl 0x8026a3(%eax),%eax
  8007ac:	89 04 24             	mov    %eax,(%esp)
  8007af:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007b2:	83 c4 3c             	add    $0x3c,%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007bd:	83 fa 01             	cmp    $0x1,%edx
  8007c0:	7e 0e                	jle    8007d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007c2:	8b 10                	mov    (%eax),%edx
  8007c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007c7:	89 08                	mov    %ecx,(%eax)
  8007c9:	8b 02                	mov    (%edx),%eax
  8007cb:	8b 52 04             	mov    0x4(%edx),%edx
  8007ce:	eb 22                	jmp    8007f2 <getuint+0x38>
	else if (lflag)
  8007d0:	85 d2                	test   %edx,%edx
  8007d2:	74 10                	je     8007e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007d4:	8b 10                	mov    (%eax),%edx
  8007d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d9:	89 08                	mov    %ecx,(%eax)
  8007db:	8b 02                	mov    (%edx),%eax
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e2:	eb 0e                	jmp    8007f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007e4:	8b 10                	mov    (%eax),%edx
  8007e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e9:	89 08                	mov    %ecx,(%eax)
  8007eb:	8b 02                	mov    (%edx),%eax
  8007ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007fa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800802:	73 08                	jae    80080c <sprintputch+0x18>
		*b->buf++ = ch;
  800804:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800807:	88 0a                	mov    %cl,(%edx)
  800809:	42                   	inc    %edx
  80080a:	89 10                	mov    %edx,(%eax)
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800814:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800817:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081b:	8b 45 10             	mov    0x10(%ebp),%eax
  80081e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800822:	8b 45 0c             	mov    0xc(%ebp),%eax
  800825:	89 44 24 04          	mov    %eax,0x4(%esp)
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	89 04 24             	mov    %eax,(%esp)
  80082f:	e8 02 00 00 00       	call   800836 <vprintfmt>
	va_end(ap);
}
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	57                   	push   %edi
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	83 ec 4c             	sub    $0x4c,%esp
  80083f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800842:	8b 75 10             	mov    0x10(%ebp),%esi
  800845:	eb 12                	jmp    800859 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800847:	85 c0                	test   %eax,%eax
  800849:	0f 84 6b 03 00 00    	je     800bba <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80084f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800859:	0f b6 06             	movzbl (%esi),%eax
  80085c:	46                   	inc    %esi
  80085d:	83 f8 25             	cmp    $0x25,%eax
  800860:	75 e5                	jne    800847 <vprintfmt+0x11>
  800862:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800866:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80086d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800872:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800879:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087e:	eb 26                	jmp    8008a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800880:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800883:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800887:	eb 1d                	jmp    8008a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800889:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80088c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800890:	eb 14                	jmp    8008a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800892:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800895:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80089c:	eb 08                	jmp    8008a6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80089e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	0f b6 06             	movzbl (%esi),%eax
  8008a9:	8d 56 01             	lea    0x1(%esi),%edx
  8008ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008af:	8a 16                	mov    (%esi),%dl
  8008b1:	83 ea 23             	sub    $0x23,%edx
  8008b4:	80 fa 55             	cmp    $0x55,%dl
  8008b7:	0f 87 e1 02 00 00    	ja     800b9e <vprintfmt+0x368>
  8008bd:	0f b6 d2             	movzbl %dl,%edx
  8008c0:	ff 24 95 e0 27 80 00 	jmp    *0x8027e0(,%edx,4)
  8008c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008ca:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008cf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008d2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008d6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008d9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008dc:	83 fa 09             	cmp    $0x9,%edx
  8008df:	77 2a                	ja     80090b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008e1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008e2:	eb eb                	jmp    8008cf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ed:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008f2:	eb 17                	jmp    80090b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f8:	78 98                	js     800892 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fd:	eb a7                	jmp    8008a6 <vprintfmt+0x70>
  8008ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800902:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800909:	eb 9b                	jmp    8008a6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80090b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090f:	79 95                	jns    8008a6 <vprintfmt+0x70>
  800911:	eb 8b                	jmp    80089e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800913:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800914:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800917:	eb 8d                	jmp    8008a6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8d 50 04             	lea    0x4(%eax),%edx
  80091f:	89 55 14             	mov    %edx,0x14(%ebp)
  800922:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800926:	8b 00                	mov    (%eax),%eax
  800928:	89 04 24             	mov    %eax,(%esp)
  80092b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800931:	e9 23 ff ff ff       	jmp    800859 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800936:	8b 45 14             	mov    0x14(%ebp),%eax
  800939:	8d 50 04             	lea    0x4(%eax),%edx
  80093c:	89 55 14             	mov    %edx,0x14(%ebp)
  80093f:	8b 00                	mov    (%eax),%eax
  800941:	85 c0                	test   %eax,%eax
  800943:	79 02                	jns    800947 <vprintfmt+0x111>
  800945:	f7 d8                	neg    %eax
  800947:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800949:	83 f8 0f             	cmp    $0xf,%eax
  80094c:	7f 0b                	jg     800959 <vprintfmt+0x123>
  80094e:	8b 04 85 40 29 80 00 	mov    0x802940(,%eax,4),%eax
  800955:	85 c0                	test   %eax,%eax
  800957:	75 23                	jne    80097c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800959:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80095d:	c7 44 24 08 bb 26 80 	movl   $0x8026bb,0x8(%esp)
  800964:	00 
  800965:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	e8 9a fe ff ff       	call   80080e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800974:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800977:	e9 dd fe ff ff       	jmp    800859 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80097c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800980:	c7 44 24 08 dd 2a 80 	movl   $0x802add,0x8(%esp)
  800987:	00 
  800988:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098c:	8b 55 08             	mov    0x8(%ebp),%edx
  80098f:	89 14 24             	mov    %edx,(%esp)
  800992:	e8 77 fe ff ff       	call   80080e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800997:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80099a:	e9 ba fe ff ff       	jmp    800859 <vprintfmt+0x23>
  80099f:	89 f9                	mov    %edi,%ecx
  8009a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 50 04             	lea    0x4(%eax),%edx
  8009ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b0:	8b 30                	mov    (%eax),%esi
  8009b2:	85 f6                	test   %esi,%esi
  8009b4:	75 05                	jne    8009bb <vprintfmt+0x185>
				p = "(null)";
  8009b6:	be b4 26 80 00       	mov    $0x8026b4,%esi
			if (width > 0 && padc != '-')
  8009bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009bf:	0f 8e 84 00 00 00    	jle    800a49 <vprintfmt+0x213>
  8009c5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009c9:	74 7e                	je     800a49 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009cf:	89 34 24             	mov    %esi,(%esp)
  8009d2:	e8 8b 02 00 00       	call   800c62 <strnlen>
  8009d7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009da:	29 c2                	sub    %eax,%edx
  8009dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009df:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009e3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009e6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009e9:	89 de                	mov    %ebx,%esi
  8009eb:	89 d3                	mov    %edx,%ebx
  8009ed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ef:	eb 0b                	jmp    8009fc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f5:	89 3c 24             	mov    %edi,(%esp)
  8009f8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009fb:	4b                   	dec    %ebx
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	7f f1                	jg     8009f1 <vprintfmt+0x1bb>
  800a00:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800a03:	89 f3                	mov    %esi,%ebx
  800a05:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800a08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a0b:	85 c0                	test   %eax,%eax
  800a0d:	79 05                	jns    800a14 <vprintfmt+0x1de>
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a17:	29 c2                	sub    %eax,%edx
  800a19:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a1c:	eb 2b                	jmp    800a49 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a22:	74 18                	je     800a3c <vprintfmt+0x206>
  800a24:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a27:	83 fa 5e             	cmp    $0x5e,%edx
  800a2a:	76 10                	jbe    800a3c <vprintfmt+0x206>
					putch('?', putdat);
  800a2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a30:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a37:	ff 55 08             	call   *0x8(%ebp)
  800a3a:	eb 0a                	jmp    800a46 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a40:	89 04 24             	mov    %eax,(%esp)
  800a43:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a46:	ff 4d e4             	decl   -0x1c(%ebp)
  800a49:	0f be 06             	movsbl (%esi),%eax
  800a4c:	46                   	inc    %esi
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	74 21                	je     800a72 <vprintfmt+0x23c>
  800a51:	85 ff                	test   %edi,%edi
  800a53:	78 c9                	js     800a1e <vprintfmt+0x1e8>
  800a55:	4f                   	dec    %edi
  800a56:	79 c6                	jns    800a1e <vprintfmt+0x1e8>
  800a58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5b:	89 de                	mov    %ebx,%esi
  800a5d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a60:	eb 18                	jmp    800a7a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a66:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a6d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6f:	4b                   	dec    %ebx
  800a70:	eb 08                	jmp    800a7a <vprintfmt+0x244>
  800a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a75:	89 de                	mov    %ebx,%esi
  800a77:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	7f e4                	jg     800a62 <vprintfmt+0x22c>
  800a7e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a81:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a83:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a86:	e9 ce fd ff ff       	jmp    800859 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8b:	83 f9 01             	cmp    $0x1,%ecx
  800a8e:	7e 10                	jle    800aa0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a90:	8b 45 14             	mov    0x14(%ebp),%eax
  800a93:	8d 50 08             	lea    0x8(%eax),%edx
  800a96:	89 55 14             	mov    %edx,0x14(%ebp)
  800a99:	8b 30                	mov    (%eax),%esi
  800a9b:	8b 78 04             	mov    0x4(%eax),%edi
  800a9e:	eb 26                	jmp    800ac6 <vprintfmt+0x290>
	else if (lflag)
  800aa0:	85 c9                	test   %ecx,%ecx
  800aa2:	74 12                	je     800ab6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 50 04             	lea    0x4(%eax),%edx
  800aaa:	89 55 14             	mov    %edx,0x14(%ebp)
  800aad:	8b 30                	mov    (%eax),%esi
  800aaf:	89 f7                	mov    %esi,%edi
  800ab1:	c1 ff 1f             	sar    $0x1f,%edi
  800ab4:	eb 10                	jmp    800ac6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	8d 50 04             	lea    0x4(%eax),%edx
  800abc:	89 55 14             	mov    %edx,0x14(%ebp)
  800abf:	8b 30                	mov    (%eax),%esi
  800ac1:	89 f7                	mov    %esi,%edi
  800ac3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac6:	85 ff                	test   %edi,%edi
  800ac8:	78 0a                	js     800ad4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800aca:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acf:	e9 8c 00 00 00       	jmp    800b60 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ad4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800adf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ae2:	f7 de                	neg    %esi
  800ae4:	83 d7 00             	adc    $0x0,%edi
  800ae7:	f7 df                	neg    %edi
			}
			base = 10;
  800ae9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aee:	eb 70                	jmp    800b60 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800af0:	89 ca                	mov    %ecx,%edx
  800af2:	8d 45 14             	lea    0x14(%ebp),%eax
  800af5:	e8 c0 fc ff ff       	call   8007ba <getuint>
  800afa:	89 c6                	mov    %eax,%esi
  800afc:	89 d7                	mov    %edx,%edi
			base = 10;
  800afe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b03:	eb 5b                	jmp    800b60 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800b05:	89 ca                	mov    %ecx,%edx
  800b07:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0a:	e8 ab fc ff ff       	call   8007ba <getuint>
  800b0f:	89 c6                	mov    %eax,%esi
  800b11:	89 d7                	mov    %edx,%edi
			base = 8;
  800b13:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b18:	eb 46                	jmp    800b60 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b25:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b2c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b33:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8d 50 04             	lea    0x4(%eax),%edx
  800b3c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3f:	8b 30                	mov    (%eax),%esi
  800b41:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b46:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b4b:	eb 13                	jmp    800b60 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b4d:	89 ca                	mov    %ecx,%edx
  800b4f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b52:	e8 63 fc ff ff       	call   8007ba <getuint>
  800b57:	89 c6                	mov    %eax,%esi
  800b59:	89 d7                	mov    %edx,%edi
			base = 16;
  800b5b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b60:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b64:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b73:	89 34 24             	mov    %esi,(%esp)
  800b76:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b7a:	89 da                	mov    %ebx,%edx
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	e8 6c fb ff ff       	call   8006f0 <printnum>
			break;
  800b84:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b87:	e9 cd fc ff ff       	jmp    800859 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b90:	89 04 24             	mov    %eax,(%esp)
  800b93:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b96:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b99:	e9 bb fc ff ff       	jmp    800859 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ba9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bac:	eb 01                	jmp    800baf <vprintfmt+0x379>
  800bae:	4e                   	dec    %esi
  800baf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bb3:	75 f9                	jne    800bae <vprintfmt+0x378>
  800bb5:	e9 9f fc ff ff       	jmp    800859 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bba:	83 c4 4c             	add    $0x4c,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	83 ec 28             	sub    $0x28,%esp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bd1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bd5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	74 30                	je     800c13 <vsnprintf+0x51>
  800be3:	85 d2                	test   %edx,%edx
  800be5:	7e 33                	jle    800c1a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bee:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfc:	c7 04 24 f4 07 80 00 	movl   $0x8007f4,(%esp)
  800c03:	e8 2e fc ff ff       	call   800836 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c11:	eb 0c                	jmp    800c1f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c18:	eb 05                	jmp    800c1f <vsnprintf+0x5d>
  800c1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c27:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	89 04 24             	mov    %eax,(%esp)
  800c42:	e8 7b ff ff ff       	call   800bc2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    
  800c49:	00 00                	add    %al,(%eax)
	...

00800c4c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c52:	b8 00 00 00 00       	mov    $0x0,%eax
  800c57:	eb 01                	jmp    800c5a <strlen+0xe>
		n++;
  800c59:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c5a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c5e:	75 f9                	jne    800c59 <strlen+0xd>
		n++;
	return n;
}
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c68:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c70:	eb 01                	jmp    800c73 <strnlen+0x11>
		n++;
  800c72:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c73:	39 d0                	cmp    %edx,%eax
  800c75:	74 06                	je     800c7d <strnlen+0x1b>
  800c77:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c7b:	75 f5                	jne    800c72 <strnlen+0x10>
		n++;
	return n;
}
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	53                   	push   %ebx
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c91:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c94:	42                   	inc    %edx
  800c95:	84 c9                	test   %cl,%cl
  800c97:	75 f5                	jne    800c8e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 08             	sub    $0x8,%esp
  800ca3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca6:	89 1c 24             	mov    %ebx,(%esp)
  800ca9:	e8 9e ff ff ff       	call   800c4c <strlen>
	strcpy(dst + len, src);
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb5:	01 d8                	add    %ebx,%eax
  800cb7:	89 04 24             	mov    %eax,(%esp)
  800cba:	e8 c0 ff ff ff       	call   800c7f <strcpy>
	return dst;
}
  800cbf:	89 d8                	mov    %ebx,%eax
  800cc1:	83 c4 08             	add    $0x8,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	eb 0c                	jmp    800ce8 <strncpy+0x21>
		*dst++ = *src;
  800cdc:	8a 1a                	mov    (%edx),%bl
  800cde:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ce1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ce4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce7:	41                   	inc    %ecx
  800ce8:	39 f1                	cmp    %esi,%ecx
  800cea:	75 f0                	jne    800cdc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cfe:	85 d2                	test   %edx,%edx
  800d00:	75 0a                	jne    800d0c <strlcpy+0x1c>
  800d02:	89 f0                	mov    %esi,%eax
  800d04:	eb 1a                	jmp    800d20 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d06:	88 18                	mov    %bl,(%eax)
  800d08:	40                   	inc    %eax
  800d09:	41                   	inc    %ecx
  800d0a:	eb 02                	jmp    800d0e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d0c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800d0e:	4a                   	dec    %edx
  800d0f:	74 0a                	je     800d1b <strlcpy+0x2b>
  800d11:	8a 19                	mov    (%ecx),%bl
  800d13:	84 db                	test   %bl,%bl
  800d15:	75 ef                	jne    800d06 <strlcpy+0x16>
  800d17:	89 c2                	mov    %eax,%edx
  800d19:	eb 02                	jmp    800d1d <strlcpy+0x2d>
  800d1b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d1d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d20:	29 f0                	sub    %esi,%eax
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d2f:	eb 02                	jmp    800d33 <strcmp+0xd>
		p++, q++;
  800d31:	41                   	inc    %ecx
  800d32:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d33:	8a 01                	mov    (%ecx),%al
  800d35:	84 c0                	test   %al,%al
  800d37:	74 04                	je     800d3d <strcmp+0x17>
  800d39:	3a 02                	cmp    (%edx),%al
  800d3b:	74 f4                	je     800d31 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d3d:	0f b6 c0             	movzbl %al,%eax
  800d40:	0f b6 12             	movzbl (%edx),%edx
  800d43:	29 d0                	sub    %edx,%eax
}
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	53                   	push   %ebx
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d54:	eb 03                	jmp    800d59 <strncmp+0x12>
		n--, p++, q++;
  800d56:	4a                   	dec    %edx
  800d57:	40                   	inc    %eax
  800d58:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d59:	85 d2                	test   %edx,%edx
  800d5b:	74 14                	je     800d71 <strncmp+0x2a>
  800d5d:	8a 18                	mov    (%eax),%bl
  800d5f:	84 db                	test   %bl,%bl
  800d61:	74 04                	je     800d67 <strncmp+0x20>
  800d63:	3a 19                	cmp    (%ecx),%bl
  800d65:	74 ef                	je     800d56 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d67:	0f b6 00             	movzbl (%eax),%eax
  800d6a:	0f b6 11             	movzbl (%ecx),%edx
  800d6d:	29 d0                	sub    %edx,%eax
  800d6f:	eb 05                	jmp    800d76 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d76:	5b                   	pop    %ebx
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d82:	eb 05                	jmp    800d89 <strchr+0x10>
		if (*s == c)
  800d84:	38 ca                	cmp    %cl,%dl
  800d86:	74 0c                	je     800d94 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d88:	40                   	inc    %eax
  800d89:	8a 10                	mov    (%eax),%dl
  800d8b:	84 d2                	test   %dl,%dl
  800d8d:	75 f5                	jne    800d84 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d9f:	eb 05                	jmp    800da6 <strfind+0x10>
		if (*s == c)
  800da1:	38 ca                	cmp    %cl,%dl
  800da3:	74 07                	je     800dac <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800da5:	40                   	inc    %eax
  800da6:	8a 10                	mov    (%eax),%dl
  800da8:	84 d2                	test   %dl,%dl
  800daa:	75 f5                	jne    800da1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dbd:	85 c9                	test   %ecx,%ecx
  800dbf:	74 30                	je     800df1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dc1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc7:	75 25                	jne    800dee <memset+0x40>
  800dc9:	f6 c1 03             	test   $0x3,%cl
  800dcc:	75 20                	jne    800dee <memset+0x40>
		c &= 0xFF;
  800dce:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dd1:	89 d3                	mov    %edx,%ebx
  800dd3:	c1 e3 08             	shl    $0x8,%ebx
  800dd6:	89 d6                	mov    %edx,%esi
  800dd8:	c1 e6 18             	shl    $0x18,%esi
  800ddb:	89 d0                	mov    %edx,%eax
  800ddd:	c1 e0 10             	shl    $0x10,%eax
  800de0:	09 f0                	or     %esi,%eax
  800de2:	09 d0                	or     %edx,%eax
  800de4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800de6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800de9:	fc                   	cld    
  800dea:	f3 ab                	rep stos %eax,%es:(%edi)
  800dec:	eb 03                	jmp    800df1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dee:	fc                   	cld    
  800def:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800df1:	89 f8                	mov    %edi,%eax
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e06:	39 c6                	cmp    %eax,%esi
  800e08:	73 34                	jae    800e3e <memmove+0x46>
  800e0a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e0d:	39 d0                	cmp    %edx,%eax
  800e0f:	73 2d                	jae    800e3e <memmove+0x46>
		s += n;
		d += n;
  800e11:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e14:	f6 c2 03             	test   $0x3,%dl
  800e17:	75 1b                	jne    800e34 <memmove+0x3c>
  800e19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e1f:	75 13                	jne    800e34 <memmove+0x3c>
  800e21:	f6 c1 03             	test   $0x3,%cl
  800e24:	75 0e                	jne    800e34 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e26:	83 ef 04             	sub    $0x4,%edi
  800e29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e2c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e2f:	fd                   	std    
  800e30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e32:	eb 07                	jmp    800e3b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e34:	4f                   	dec    %edi
  800e35:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e38:	fd                   	std    
  800e39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e3b:	fc                   	cld    
  800e3c:	eb 20                	jmp    800e5e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e3e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e44:	75 13                	jne    800e59 <memmove+0x61>
  800e46:	a8 03                	test   $0x3,%al
  800e48:	75 0f                	jne    800e59 <memmove+0x61>
  800e4a:	f6 c1 03             	test   $0x3,%cl
  800e4d:	75 0a                	jne    800e59 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e4f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e52:	89 c7                	mov    %eax,%edi
  800e54:	fc                   	cld    
  800e55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e57:	eb 05                	jmp    800e5e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e59:	89 c7                	mov    %eax,%edi
  800e5b:	fc                   	cld    
  800e5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e68:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	89 04 24             	mov    %eax,(%esp)
  800e7c:	e8 77 ff ff ff       	call   800df8 <memmove>
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e92:	ba 00 00 00 00       	mov    $0x0,%edx
  800e97:	eb 16                	jmp    800eaf <memcmp+0x2c>
		if (*s1 != *s2)
  800e99:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e9c:	42                   	inc    %edx
  800e9d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ea1:	38 c8                	cmp    %cl,%al
  800ea3:	74 0a                	je     800eaf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ea5:	0f b6 c0             	movzbl %al,%eax
  800ea8:	0f b6 c9             	movzbl %cl,%ecx
  800eab:	29 c8                	sub    %ecx,%eax
  800ead:	eb 09                	jmp    800eb8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eaf:	39 da                	cmp    %ebx,%edx
  800eb1:	75 e6                	jne    800e99 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ecb:	eb 05                	jmp    800ed2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ecd:	38 08                	cmp    %cl,(%eax)
  800ecf:	74 05                	je     800ed6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ed1:	40                   	inc    %eax
  800ed2:	39 d0                	cmp    %edx,%eax
  800ed4:	72 f7                	jb     800ecd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee4:	eb 01                	jmp    800ee7 <strtol+0xf>
		s++;
  800ee6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee7:	8a 02                	mov    (%edx),%al
  800ee9:	3c 20                	cmp    $0x20,%al
  800eeb:	74 f9                	je     800ee6 <strtol+0xe>
  800eed:	3c 09                	cmp    $0x9,%al
  800eef:	74 f5                	je     800ee6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ef1:	3c 2b                	cmp    $0x2b,%al
  800ef3:	75 08                	jne    800efd <strtol+0x25>
		s++;
  800ef5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef6:	bf 00 00 00 00       	mov    $0x0,%edi
  800efb:	eb 13                	jmp    800f10 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800efd:	3c 2d                	cmp    $0x2d,%al
  800eff:	75 0a                	jne    800f0b <strtol+0x33>
		s++, neg = 1;
  800f01:	8d 52 01             	lea    0x1(%edx),%edx
  800f04:	bf 01 00 00 00       	mov    $0x1,%edi
  800f09:	eb 05                	jmp    800f10 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f10:	85 db                	test   %ebx,%ebx
  800f12:	74 05                	je     800f19 <strtol+0x41>
  800f14:	83 fb 10             	cmp    $0x10,%ebx
  800f17:	75 28                	jne    800f41 <strtol+0x69>
  800f19:	8a 02                	mov    (%edx),%al
  800f1b:	3c 30                	cmp    $0x30,%al
  800f1d:	75 10                	jne    800f2f <strtol+0x57>
  800f1f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f23:	75 0a                	jne    800f2f <strtol+0x57>
		s += 2, base = 16;
  800f25:	83 c2 02             	add    $0x2,%edx
  800f28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f2d:	eb 12                	jmp    800f41 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f2f:	85 db                	test   %ebx,%ebx
  800f31:	75 0e                	jne    800f41 <strtol+0x69>
  800f33:	3c 30                	cmp    $0x30,%al
  800f35:	75 05                	jne    800f3c <strtol+0x64>
		s++, base = 8;
  800f37:	42                   	inc    %edx
  800f38:	b3 08                	mov    $0x8,%bl
  800f3a:	eb 05                	jmp    800f41 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f48:	8a 0a                	mov    (%edx),%cl
  800f4a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f4d:	80 fb 09             	cmp    $0x9,%bl
  800f50:	77 08                	ja     800f5a <strtol+0x82>
			dig = *s - '0';
  800f52:	0f be c9             	movsbl %cl,%ecx
  800f55:	83 e9 30             	sub    $0x30,%ecx
  800f58:	eb 1e                	jmp    800f78 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f5a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f5d:	80 fb 19             	cmp    $0x19,%bl
  800f60:	77 08                	ja     800f6a <strtol+0x92>
			dig = *s - 'a' + 10;
  800f62:	0f be c9             	movsbl %cl,%ecx
  800f65:	83 e9 57             	sub    $0x57,%ecx
  800f68:	eb 0e                	jmp    800f78 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f6a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f6d:	80 fb 19             	cmp    $0x19,%bl
  800f70:	77 12                	ja     800f84 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f72:	0f be c9             	movsbl %cl,%ecx
  800f75:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f78:	39 f1                	cmp    %esi,%ecx
  800f7a:	7d 0c                	jge    800f88 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f7c:	42                   	inc    %edx
  800f7d:	0f af c6             	imul   %esi,%eax
  800f80:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f82:	eb c4                	jmp    800f48 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f84:	89 c1                	mov    %eax,%ecx
  800f86:	eb 02                	jmp    800f8a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f88:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f8e:	74 05                	je     800f95 <strtol+0xbd>
		*endptr = (char *) s;
  800f90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f93:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f95:	85 ff                	test   %edi,%edi
  800f97:	74 04                	je     800f9d <strtol+0xc5>
  800f99:	89 c8                	mov    %ecx,%eax
  800f9b:	f7 d8                	neg    %eax
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
	...

00800fa4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faa:	b8 00 00 00 00       	mov    $0x0,%eax
  800faf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb5:	89 c3                	mov    %eax,%ebx
  800fb7:	89 c7                	mov    %eax,%edi
  800fb9:	89 c6                	mov    %eax,%esi
  800fbb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd2:	89 d1                	mov    %edx,%ecx
  800fd4:	89 d3                	mov    %edx,%ebx
  800fd6:	89 d7                	mov    %edx,%edi
  800fd8:	89 d6                	mov    %edx,%esi
  800fda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fef:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff7:	89 cb                	mov    %ecx,%ebx
  800ff9:	89 cf                	mov    %ecx,%edi
  800ffb:	89 ce                	mov    %ecx,%esi
  800ffd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fff:	85 c0                	test   %eax,%eax
  801001:	7e 28                	jle    80102b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801003:	89 44 24 10          	mov    %eax,0x10(%esp)
  801007:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80100e:	00 
  80100f:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  801016:	00 
  801017:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101e:	00 
  80101f:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  801026:	e8 b1 f5 ff ff       	call   8005dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80102b:	83 c4 2c             	add    $0x2c,%esp
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	ba 00 00 00 00       	mov    $0x0,%edx
  80103e:	b8 02 00 00 00       	mov    $0x2,%eax
  801043:	89 d1                	mov    %edx,%ecx
  801045:	89 d3                	mov    %edx,%ebx
  801047:	89 d7                	mov    %edx,%edi
  801049:	89 d6                	mov    %edx,%esi
  80104b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_yield>:

void
sys_yield(void)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801058:	ba 00 00 00 00       	mov    $0x0,%edx
  80105d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 d3                	mov    %edx,%ebx
  801066:	89 d7                	mov    %edx,%edi
  801068:	89 d6                	mov    %edx,%esi
  80106a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107a:	be 00 00 00 00       	mov    $0x0,%esi
  80107f:	b8 04 00 00 00       	mov    $0x4,%eax
  801084:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801087:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108a:	8b 55 08             	mov    0x8(%ebp),%edx
  80108d:	89 f7                	mov    %esi,%edi
  80108f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801091:	85 c0                	test   %eax,%eax
  801093:	7e 28                	jle    8010bd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801095:	89 44 24 10          	mov    %eax,0x10(%esp)
  801099:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  8010b8:	e8 1f f5 ff ff       	call   8005dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010bd:	83 c4 2c             	add    $0x2c,%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8010d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8010d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010df:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	7e 28                	jle    801110 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ec:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801103:	00 
  801104:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  80110b:	e8 cc f4 ff ff       	call   8005dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801110:	83 c4 2c             	add    $0x2c,%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	57                   	push   %edi
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801121:	bb 00 00 00 00       	mov    $0x0,%ebx
  801126:	b8 06 00 00 00       	mov    $0x6,%eax
  80112b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112e:	8b 55 08             	mov    0x8(%ebp),%edx
  801131:	89 df                	mov    %ebx,%edi
  801133:	89 de                	mov    %ebx,%esi
  801135:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801137:	85 c0                	test   %eax,%eax
  801139:	7e 28                	jle    801163 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801146:	00 
  801147:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  80114e:	00 
  80114f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801156:	00 
  801157:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  80115e:	e8 79 f4 ff ff       	call   8005dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801163:	83 c4 2c             	add    $0x2c,%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	57                   	push   %edi
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801174:	bb 00 00 00 00       	mov    $0x0,%ebx
  801179:	b8 08 00 00 00       	mov    $0x8,%eax
  80117e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801181:	8b 55 08             	mov    0x8(%ebp),%edx
  801184:	89 df                	mov    %ebx,%edi
  801186:	89 de                	mov    %ebx,%esi
  801188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80118a:	85 c0                	test   %eax,%eax
  80118c:	7e 28                	jle    8011b6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801192:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801199:	00 
  80119a:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a9:	00 
  8011aa:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  8011b1:	e8 26 f4 ff ff       	call   8005dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011b6:	83 c4 2c             	add    $0x2c,%esp
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cc:	b8 09 00 00 00       	mov    $0x9,%eax
  8011d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d7:	89 df                	mov    %ebx,%edi
  8011d9:	89 de                	mov    %ebx,%esi
  8011db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	7e 28                	jle    801209 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011ec:	00 
  8011ed:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  8011f4:	00 
  8011f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011fc:	00 
  8011fd:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  801204:	e8 d3 f3 ff ff       	call   8005dc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801209:	83 c4 2c             	add    $0x2c,%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801224:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801227:	8b 55 08             	mov    0x8(%ebp),%edx
  80122a:	89 df                	mov    %ebx,%edi
  80122c:	89 de                	mov    %ebx,%esi
  80122e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801230:	85 c0                	test   %eax,%eax
  801232:	7e 28                	jle    80125c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801234:	89 44 24 10          	mov    %eax,0x10(%esp)
  801238:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80123f:	00 
  801240:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  801247:	00 
  801248:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80124f:	00 
  801250:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  801257:	e8 80 f3 ff ff       	call   8005dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80125c:	83 c4 2c             	add    $0x2c,%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	57                   	push   %edi
  801268:	56                   	push   %esi
  801269:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126a:	be 00 00 00 00       	mov    $0x0,%esi
  80126f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801274:	8b 7d 14             	mov    0x14(%ebp),%edi
  801277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80127a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127d:	8b 55 08             	mov    0x8(%ebp),%edx
  801280:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	57                   	push   %edi
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801290:	b9 00 00 00 00       	mov    $0x0,%ecx
  801295:	b8 0d 00 00 00       	mov    $0xd,%eax
  80129a:	8b 55 08             	mov    0x8(%ebp),%edx
  80129d:	89 cb                	mov    %ecx,%ebx
  80129f:	89 cf                	mov    %ecx,%edi
  8012a1:	89 ce                	mov    %ecx,%esi
  8012a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	7e 28                	jle    8012d1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ad:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8012b4:	00 
  8012b5:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c4:	00 
  8012c5:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  8012cc:	e8 0b f3 ff ff       	call   8005dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d1:	83 c4 2c             	add    $0x2c,%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5f                   	pop    %edi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    
  8012d9:	00 00                	add    %al,(%eax)
	...

008012dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012e3:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012ea:	75 6f                	jne    80135b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8012ec:	e8 42 fd ff ff       	call   801033 <sys_getenvid>
  8012f1:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8012f3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012fa:	00 
  8012fb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801302:	ee 
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 66 fd ff ff       	call   801071 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  80130b:	85 c0                	test   %eax,%eax
  80130d:	79 1c                	jns    80132b <set_pgfault_handler+0x4f>
  80130f:	c7 44 24 08 cc 29 80 	movl   $0x8029cc,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 25 2a 80 00 	movl   $0x802a25,(%esp)
  801326:	e8 b1 f2 ff ff       	call   8005dc <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80132b:	c7 44 24 04 6c 13 80 	movl   $0x80136c,0x4(%esp)
  801332:	00 
  801333:	89 1c 24             	mov    %ebx,(%esp)
  801336:	e8 d6 fe ff ff       	call   801211 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80133b:	85 c0                	test   %eax,%eax
  80133d:	79 1c                	jns    80135b <set_pgfault_handler+0x7f>
  80133f:	c7 44 24 08 f4 29 80 	movl   $0x8029f4,0x8(%esp)
  801346:	00 
  801347:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 25 2a 80 00 	movl   $0x802a25,(%esp)
  801356:	e8 81 f2 ff ff       	call   8005dc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801363:	83 c4 14             	add    $0x14,%esp
  801366:	5b                   	pop    %ebx
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    
  801369:	00 00                	add    %al,(%eax)
	...

0080136c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80136c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80136d:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801372:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801374:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  801377:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  80137b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  801380:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  801384:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  801386:	83 c4 08             	add    $0x8,%esp
	popal
  801389:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  80138a:	83 c4 04             	add    $0x4,%esp
	popfl
  80138d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  80138e:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801391:	c3                   	ret    
	...

00801394 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801397:	8b 45 08             	mov    0x8(%ebp),%eax
  80139a:	05 00 00 00 30       	add    $0x30000000,%eax
  80139f:	c1 e8 0c             	shr    $0xc,%eax
}
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	e8 df ff ff ff       	call   801394 <fd2num>
  8013b5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013ba:	c1 e0 0c             	shl    $0xc,%eax
}
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    

008013bf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	53                   	push   %ebx
  8013c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013c6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013cb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	c1 ea 16             	shr    $0x16,%edx
  8013d2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d9:	f6 c2 01             	test   $0x1,%dl
  8013dc:	74 11                	je     8013ef <fd_alloc+0x30>
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	c1 ea 0c             	shr    $0xc,%edx
  8013e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ea:	f6 c2 01             	test   $0x1,%dl
  8013ed:	75 09                	jne    8013f8 <fd_alloc+0x39>
			*fd_store = fd;
  8013ef:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f6:	eb 17                	jmp    80140f <fd_alloc+0x50>
  8013f8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801402:	75 c7                	jne    8013cb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801404:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80140a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80140f:	5b                   	pop    %ebx
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801418:	83 f8 1f             	cmp    $0x1f,%eax
  80141b:	77 36                	ja     801453 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80141d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801422:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801425:	89 c2                	mov    %eax,%edx
  801427:	c1 ea 16             	shr    $0x16,%edx
  80142a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801431:	f6 c2 01             	test   $0x1,%dl
  801434:	74 24                	je     80145a <fd_lookup+0x48>
  801436:	89 c2                	mov    %eax,%edx
  801438:	c1 ea 0c             	shr    $0xc,%edx
  80143b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801442:	f6 c2 01             	test   $0x1,%dl
  801445:	74 1a                	je     801461 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144a:	89 02                	mov    %eax,(%edx)
	return 0;
  80144c:	b8 00 00 00 00       	mov    $0x0,%eax
  801451:	eb 13                	jmp    801466 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801458:	eb 0c                	jmp    801466 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145f:	eb 05                	jmp    801466 <fd_lookup+0x54>
  801461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 14             	sub    $0x14,%esp
  80146f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801472:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801475:	ba 00 00 00 00       	mov    $0x0,%edx
  80147a:	eb 0e                	jmp    80148a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80147c:	39 08                	cmp    %ecx,(%eax)
  80147e:	75 09                	jne    801489 <dev_lookup+0x21>
			*dev = devtab[i];
  801480:	89 03                	mov    %eax,(%ebx)
			return 0;
  801482:	b8 00 00 00 00       	mov    $0x0,%eax
  801487:	eb 35                	jmp    8014be <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801489:	42                   	inc    %edx
  80148a:	8b 04 95 b4 2a 80 00 	mov    0x802ab4(,%edx,4),%eax
  801491:	85 c0                	test   %eax,%eax
  801493:	75 e7                	jne    80147c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801495:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80149a:	8b 00                	mov    (%eax),%eax
  80149c:	8b 40 48             	mov    0x48(%eax),%eax
  80149f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a7:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  8014ae:	e8 21 f2 ff ff       	call   8006d4 <cprintf>
	*dev = 0;
  8014b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014be:	83 c4 14             	add    $0x14,%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 30             	sub    $0x30,%esp
  8014cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014cf:	8a 45 0c             	mov    0xc(%ebp),%al
  8014d2:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d5:	89 34 24             	mov    %esi,(%esp)
  8014d8:	e8 b7 fe ff ff       	call   801394 <fd2num>
  8014dd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014e4:	89 04 24             	mov    %eax,(%esp)
  8014e7:	e8 26 ff ff ff       	call   801412 <fd_lookup>
  8014ec:	89 c3                	mov    %eax,%ebx
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 05                	js     8014f7 <fd_close+0x33>
	    || fd != fd2)
  8014f2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f5:	74 0d                	je     801504 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014f7:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014fb:	75 46                	jne    801543 <fd_close+0x7f>
  8014fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801502:	eb 3f                	jmp    801543 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801504:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	8b 06                	mov    (%esi),%eax
  80150d:	89 04 24             	mov    %eax,(%esp)
  801510:	e8 53 ff ff ff       	call   801468 <dev_lookup>
  801515:	89 c3                	mov    %eax,%ebx
  801517:	85 c0                	test   %eax,%eax
  801519:	78 18                	js     801533 <fd_close+0x6f>
		if (dev->dev_close)
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	8b 40 10             	mov    0x10(%eax),%eax
  801521:	85 c0                	test   %eax,%eax
  801523:	74 09                	je     80152e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801525:	89 34 24             	mov    %esi,(%esp)
  801528:	ff d0                	call   *%eax
  80152a:	89 c3                	mov    %eax,%ebx
  80152c:	eb 05                	jmp    801533 <fd_close+0x6f>
		else
			r = 0;
  80152e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801533:	89 74 24 04          	mov    %esi,0x4(%esp)
  801537:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153e:	e8 d5 fb ff ff       	call   801118 <sys_page_unmap>
	return r;
}
  801543:	89 d8                	mov    %ebx,%eax
  801545:	83 c4 30             	add    $0x30,%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801555:	89 44 24 04          	mov    %eax,0x4(%esp)
  801559:	8b 45 08             	mov    0x8(%ebp),%eax
  80155c:	89 04 24             	mov    %eax,(%esp)
  80155f:	e8 ae fe ff ff       	call   801412 <fd_lookup>
  801564:	85 c0                	test   %eax,%eax
  801566:	78 13                	js     80157b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801568:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80156f:	00 
  801570:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801573:	89 04 24             	mov    %eax,(%esp)
  801576:	e8 49 ff ff ff       	call   8014c4 <fd_close>
}
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <close_all>:

void
close_all(void)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801584:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801589:	89 1c 24             	mov    %ebx,(%esp)
  80158c:	e8 bb ff ff ff       	call   80154c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801591:	43                   	inc    %ebx
  801592:	83 fb 20             	cmp    $0x20,%ebx
  801595:	75 f2                	jne    801589 <close_all+0xc>
		close(i);
}
  801597:	83 c4 14             	add    $0x14,%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	57                   	push   %edi
  8015a1:	56                   	push   %esi
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 4c             	sub    $0x4c,%esp
  8015a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b3:	89 04 24             	mov    %eax,(%esp)
  8015b6:	e8 57 fe ff ff       	call   801412 <fd_lookup>
  8015bb:	89 c3                	mov    %eax,%ebx
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	0f 88 e1 00 00 00    	js     8016a6 <dup+0x109>
		return r;
	close(newfdnum);
  8015c5:	89 3c 24             	mov    %edi,(%esp)
  8015c8:	e8 7f ff ff ff       	call   80154c <close>

	newfd = INDEX2FD(newfdnum);
  8015cd:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015d3:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d9:	89 04 24             	mov    %eax,(%esp)
  8015dc:	e8 c3 fd ff ff       	call   8013a4 <fd2data>
  8015e1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015e3:	89 34 24             	mov    %esi,(%esp)
  8015e6:	e8 b9 fd ff ff       	call   8013a4 <fd2data>
  8015eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ee:	89 d8                	mov    %ebx,%eax
  8015f0:	c1 e8 16             	shr    $0x16,%eax
  8015f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015fa:	a8 01                	test   $0x1,%al
  8015fc:	74 46                	je     801644 <dup+0xa7>
  8015fe:	89 d8                	mov    %ebx,%eax
  801600:	c1 e8 0c             	shr    $0xc,%eax
  801603:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80160a:	f6 c2 01             	test   $0x1,%dl
  80160d:	74 35                	je     801644 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80160f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801616:	25 07 0e 00 00       	and    $0xe07,%eax
  80161b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80161f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801622:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801626:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80162d:	00 
  80162e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801632:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801639:	e8 87 fa ff ff       	call   8010c5 <sys_page_map>
  80163e:	89 c3                	mov    %eax,%ebx
  801640:	85 c0                	test   %eax,%eax
  801642:	78 3b                	js     80167f <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801647:	89 c2                	mov    %eax,%edx
  801649:	c1 ea 0c             	shr    $0xc,%edx
  80164c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801653:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801659:	89 54 24 10          	mov    %edx,0x10(%esp)
  80165d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801661:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801668:	00 
  801669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801674:	e8 4c fa ff ff       	call   8010c5 <sys_page_map>
  801679:	89 c3                	mov    %eax,%ebx
  80167b:	85 c0                	test   %eax,%eax
  80167d:	79 25                	jns    8016a4 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80167f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801683:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168a:	e8 89 fa ff ff       	call   801118 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80168f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801692:	89 44 24 04          	mov    %eax,0x4(%esp)
  801696:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169d:	e8 76 fa ff ff       	call   801118 <sys_page_unmap>
	return r;
  8016a2:	eb 02                	jmp    8016a6 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016a4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	83 c4 4c             	add    $0x4c,%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5f                   	pop    %edi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 24             	sub    $0x24,%esp
  8016b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c1:	89 1c 24             	mov    %ebx,(%esp)
  8016c4:	e8 49 fd ff ff       	call   801412 <fd_lookup>
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 6f                	js     80173c <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d7:	8b 00                	mov    (%eax),%eax
  8016d9:	89 04 24             	mov    %eax,(%esp)
  8016dc:	e8 87 fd ff ff       	call   801468 <dev_lookup>
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 57                	js     80173c <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e8:	8b 50 08             	mov    0x8(%eax),%edx
  8016eb:	83 e2 03             	and    $0x3,%edx
  8016ee:	83 fa 01             	cmp    $0x1,%edx
  8016f1:	75 25                	jne    801718 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f3:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016f8:	8b 00                	mov    (%eax),%eax
  8016fa:	8b 40 48             	mov    0x48(%eax),%eax
  8016fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801701:	89 44 24 04          	mov    %eax,0x4(%esp)
  801705:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  80170c:	e8 c3 ef ff ff       	call   8006d4 <cprintf>
		return -E_INVAL;
  801711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801716:	eb 24                	jmp    80173c <read+0x8c>
	}
	if (!dev->dev_read)
  801718:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171b:	8b 52 08             	mov    0x8(%edx),%edx
  80171e:	85 d2                	test   %edx,%edx
  801720:	74 15                	je     801737 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801722:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801725:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801730:	89 04 24             	mov    %eax,(%esp)
  801733:	ff d2                	call   *%edx
  801735:	eb 05                	jmp    80173c <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801737:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80173c:	83 c4 24             	add    $0x24,%esp
  80173f:	5b                   	pop    %ebx
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	57                   	push   %edi
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
  801748:	83 ec 1c             	sub    $0x1c,%esp
  80174b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80174e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801751:	bb 00 00 00 00       	mov    $0x0,%ebx
  801756:	eb 23                	jmp    80177b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801758:	89 f0                	mov    %esi,%eax
  80175a:	29 d8                	sub    %ebx,%eax
  80175c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801760:	8b 45 0c             	mov    0xc(%ebp),%eax
  801763:	01 d8                	add    %ebx,%eax
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	89 3c 24             	mov    %edi,(%esp)
  80176c:	e8 3f ff ff ff       	call   8016b0 <read>
		if (m < 0)
  801771:	85 c0                	test   %eax,%eax
  801773:	78 10                	js     801785 <readn+0x43>
			return m;
		if (m == 0)
  801775:	85 c0                	test   %eax,%eax
  801777:	74 0a                	je     801783 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801779:	01 c3                	add    %eax,%ebx
  80177b:	39 f3                	cmp    %esi,%ebx
  80177d:	72 d9                	jb     801758 <readn+0x16>
  80177f:	89 d8                	mov    %ebx,%eax
  801781:	eb 02                	jmp    801785 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801783:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801785:	83 c4 1c             	add    $0x1c,%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5f                   	pop    %edi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	53                   	push   %ebx
  801791:	83 ec 24             	sub    $0x24,%esp
  801794:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801797:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179e:	89 1c 24             	mov    %ebx,(%esp)
  8017a1:	e8 6c fc ff ff       	call   801412 <fd_lookup>
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 6a                	js     801814 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b4:	8b 00                	mov    (%eax),%eax
  8017b6:	89 04 24             	mov    %eax,(%esp)
  8017b9:	e8 aa fc ff ff       	call   801468 <dev_lookup>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 52                	js     801814 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c9:	75 25                	jne    8017f0 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017cb:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8017d0:	8b 00                	mov    (%eax),%eax
  8017d2:	8b 40 48             	mov    0x48(%eax),%eax
  8017d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dd:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  8017e4:	e8 eb ee ff ff       	call   8006d4 <cprintf>
		return -E_INVAL;
  8017e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ee:	eb 24                	jmp    801814 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f6:	85 d2                	test   %edx,%edx
  8017f8:	74 15                	je     80180f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801804:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	ff d2                	call   *%edx
  80180d:	eb 05                	jmp    801814 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80180f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801814:	83 c4 24             	add    $0x24,%esp
  801817:	5b                   	pop    %ebx
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <seek>:

int
seek(int fdnum, off_t offset)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801820:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	e8 e0 fb ff ff       	call   801412 <fd_lookup>
  801832:	85 c0                	test   %eax,%eax
  801834:	78 0e                	js     801844 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801836:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801839:	8b 55 0c             	mov    0xc(%ebp),%edx
  80183c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80183f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	53                   	push   %ebx
  80184a:	83 ec 24             	sub    $0x24,%esp
  80184d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801850:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801853:	89 44 24 04          	mov    %eax,0x4(%esp)
  801857:	89 1c 24             	mov    %ebx,(%esp)
  80185a:	e8 b3 fb ff ff       	call   801412 <fd_lookup>
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 63                	js     8018c6 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801863:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801866:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186d:	8b 00                	mov    (%eax),%eax
  80186f:	89 04 24             	mov    %eax,(%esp)
  801872:	e8 f1 fb ff ff       	call   801468 <dev_lookup>
  801877:	85 c0                	test   %eax,%eax
  801879:	78 4b                	js     8018c6 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801882:	75 25                	jne    8018a9 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801884:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801889:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80188b:	8b 40 48             	mov    0x48(%eax),%eax
  80188e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801892:	89 44 24 04          	mov    %eax,0x4(%esp)
  801896:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  80189d:	e8 32 ee ff ff       	call   8006d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a7:	eb 1d                	jmp    8018c6 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ac:	8b 52 18             	mov    0x18(%edx),%edx
  8018af:	85 d2                	test   %edx,%edx
  8018b1:	74 0e                	je     8018c1 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ba:	89 04 24             	mov    %eax,(%esp)
  8018bd:	ff d2                	call   *%edx
  8018bf:	eb 05                	jmp    8018c6 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018c6:	83 c4 24             	add    $0x24,%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	53                   	push   %ebx
  8018d0:	83 ec 24             	sub    $0x24,%esp
  8018d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e0:	89 04 24             	mov    %eax,(%esp)
  8018e3:	e8 2a fb ff ff       	call   801412 <fd_lookup>
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	78 52                	js     80193e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f6:	8b 00                	mov    (%eax),%eax
  8018f8:	89 04 24             	mov    %eax,(%esp)
  8018fb:	e8 68 fb ff ff       	call   801468 <dev_lookup>
  801900:	85 c0                	test   %eax,%eax
  801902:	78 3a                	js     80193e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801904:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801907:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80190b:	74 2c                	je     801939 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80190d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801910:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801917:	00 00 00 
	stat->st_isdir = 0;
  80191a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801921:	00 00 00 
	stat->st_dev = dev;
  801924:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80192a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80192e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801931:	89 14 24             	mov    %edx,(%esp)
  801934:	ff 50 14             	call   *0x14(%eax)
  801937:	eb 05                	jmp    80193e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801939:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80193e:	83 c4 24             	add    $0x24,%esp
  801941:	5b                   	pop    %ebx
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	56                   	push   %esi
  801948:	53                   	push   %ebx
  801949:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80194c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801953:	00 
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	89 04 24             	mov    %eax,(%esp)
  80195a:	e8 88 02 00 00       	call   801be7 <open>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	85 c0                	test   %eax,%eax
  801963:	78 1b                	js     801980 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801965:	8b 45 0c             	mov    0xc(%ebp),%eax
  801968:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196c:	89 1c 24             	mov    %ebx,(%esp)
  80196f:	e8 58 ff ff ff       	call   8018cc <fstat>
  801974:	89 c6                	mov    %eax,%esi
	close(fd);
  801976:	89 1c 24             	mov    %ebx,(%esp)
  801979:	e8 ce fb ff ff       	call   80154c <close>
	return r;
  80197e:	89 f3                	mov    %esi,%ebx
}
  801980:	89 d8                	mov    %ebx,%eax
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    
  801989:	00 00                	add    %al,(%eax)
	...

0080198c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	56                   	push   %esi
  801990:	53                   	push   %ebx
  801991:	83 ec 10             	sub    $0x10,%esp
  801994:	89 c3                	mov    %eax,%ebx
  801996:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801998:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  80199f:	75 11                	jne    8019b2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019a8:	e8 ca 08 00 00       	call   802277 <ipc_find_env>
  8019ad:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019b9:	00 
  8019ba:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019c1:	00 
  8019c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c6:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8019cb:	89 04 24             	mov    %eax,(%esp)
  8019ce:	e8 3e 08 00 00       	call   802211 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8019d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019da:	00 
  8019db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e6:	e8 b9 07 00 00       	call   8021a4 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	5d                   	pop    %ebp
  8019f1:	c3                   	ret    

008019f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a06:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a10:	b8 02 00 00 00       	mov    $0x2,%eax
  801a15:	e8 72 ff ff ff       	call   80198c <fsipc>
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a22:	8b 45 08             	mov    0x8(%ebp),%eax
  801a25:	8b 40 0c             	mov    0xc(%eax),%eax
  801a28:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a32:	b8 06 00 00 00       	mov    $0x6,%eax
  801a37:	e8 50 ff ff ff       	call   80198c <fsipc>
}
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	53                   	push   %ebx
  801a42:	83 ec 14             	sub    $0x14,%esp
  801a45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a53:	ba 00 00 00 00       	mov    $0x0,%edx
  801a58:	b8 05 00 00 00       	mov    $0x5,%eax
  801a5d:	e8 2a ff ff ff       	call   80198c <fsipc>
  801a62:	85 c0                	test   %eax,%eax
  801a64:	78 2b                	js     801a91 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a66:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a6d:	00 
  801a6e:	89 1c 24             	mov    %ebx,(%esp)
  801a71:	e8 09 f2 ff ff       	call   800c7f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a76:	a1 80 50 80 00       	mov    0x805080,%eax
  801a7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a81:	a1 84 50 80 00       	mov    0x805084,%eax
  801a86:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a91:	83 c4 14             	add    $0x14,%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 14             	sub    $0x14,%esp
  801a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa4:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801aac:	89 d8                	mov    %ebx,%eax
  801aae:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801ab4:	76 05                	jbe    801abb <devfile_write+0x24>
  801ab6:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801abb:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801ac0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acb:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ad2:	e8 8b f3 ff ff       	call   800e62 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  801adc:	b8 04 00 00 00       	mov    $0x4,%eax
  801ae1:	e8 a6 fe ff ff       	call   80198c <fsipc>
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	78 53                	js     801b3d <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801aea:	39 c3                	cmp    %eax,%ebx
  801aec:	73 24                	jae    801b12 <devfile_write+0x7b>
  801aee:	c7 44 24 0c c4 2a 80 	movl   $0x802ac4,0xc(%esp)
  801af5:	00 
  801af6:	c7 44 24 08 cb 2a 80 	movl   $0x802acb,0x8(%esp)
  801afd:	00 
  801afe:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801b05:	00 
  801b06:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801b0d:	e8 ca ea ff ff       	call   8005dc <_panic>
	assert(r <= PGSIZE);
  801b12:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b17:	7e 24                	jle    801b3d <devfile_write+0xa6>
  801b19:	c7 44 24 0c eb 2a 80 	movl   $0x802aeb,0xc(%esp)
  801b20:	00 
  801b21:	c7 44 24 08 cb 2a 80 	movl   $0x802acb,0x8(%esp)
  801b28:	00 
  801b29:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801b30:	00 
  801b31:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801b38:	e8 9f ea ff ff       	call   8005dc <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801b3d:	83 c4 14             	add    $0x14,%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 10             	sub    $0x10,%esp
  801b4b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b51:	8b 40 0c             	mov    0xc(%eax),%eax
  801b54:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b59:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b64:	b8 03 00 00 00       	mov    $0x3,%eax
  801b69:	e8 1e fe ff ff       	call   80198c <fsipc>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 6a                	js     801bde <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b74:	39 c6                	cmp    %eax,%esi
  801b76:	73 24                	jae    801b9c <devfile_read+0x59>
  801b78:	c7 44 24 0c c4 2a 80 	movl   $0x802ac4,0xc(%esp)
  801b7f:	00 
  801b80:	c7 44 24 08 cb 2a 80 	movl   $0x802acb,0x8(%esp)
  801b87:	00 
  801b88:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801b8f:	00 
  801b90:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801b97:	e8 40 ea ff ff       	call   8005dc <_panic>
	assert(r <= PGSIZE);
  801b9c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba1:	7e 24                	jle    801bc7 <devfile_read+0x84>
  801ba3:	c7 44 24 0c eb 2a 80 	movl   $0x802aeb,0xc(%esp)
  801baa:	00 
  801bab:	c7 44 24 08 cb 2a 80 	movl   $0x802acb,0x8(%esp)
  801bb2:	00 
  801bb3:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801bba:	00 
  801bbb:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801bc2:	e8 15 ea ff ff       	call   8005dc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bcb:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bd2:	00 
  801bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd6:	89 04 24             	mov    %eax,(%esp)
  801bd9:	e8 1a f2 ff ff       	call   800df8 <memmove>
	return r;
}
  801bde:	89 d8                	mov    %ebx,%eax
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	83 ec 20             	sub    $0x20,%esp
  801bef:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bf2:	89 34 24             	mov    %esi,(%esp)
  801bf5:	e8 52 f0 ff ff       	call   800c4c <strlen>
  801bfa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bff:	7f 60                	jg     801c61 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c04:	89 04 24             	mov    %eax,(%esp)
  801c07:	e8 b3 f7 ff ff       	call   8013bf <fd_alloc>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 54                	js     801c66 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c12:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c16:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c1d:	e8 5d f0 ff ff       	call   800c7f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c25:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c2d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c32:	e8 55 fd ff ff       	call   80198c <fsipc>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	79 15                	jns    801c52 <open+0x6b>
		fd_close(fd, 0);
  801c3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c44:	00 
  801c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c48:	89 04 24             	mov    %eax,(%esp)
  801c4b:	e8 74 f8 ff ff       	call   8014c4 <fd_close>
		return r;
  801c50:	eb 14                	jmp    801c66 <open+0x7f>
	}

	return fd2num(fd);
  801c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 37 f7 ff ff       	call   801394 <fd2num>
  801c5d:	89 c3                	mov    %eax,%ebx
  801c5f:	eb 05                	jmp    801c66 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c61:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	83 c4 20             	add    $0x20,%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c75:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7a:	b8 08 00 00 00       	mov    $0x8,%eax
  801c7f:	e8 08 fd ff ff       	call   80198c <fsipc>
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    
	...

00801c88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	56                   	push   %esi
  801c8c:	53                   	push   %ebx
  801c8d:	83 ec 10             	sub    $0x10,%esp
  801c90:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
  801c96:	89 04 24             	mov    %eax,(%esp)
  801c99:	e8 06 f7 ff ff       	call   8013a4 <fd2data>
  801c9e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ca0:	c7 44 24 04 f7 2a 80 	movl   $0x802af7,0x4(%esp)
  801ca7:	00 
  801ca8:	89 34 24             	mov    %esi,(%esp)
  801cab:	e8 cf ef ff ff       	call   800c7f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cb0:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb3:	2b 03                	sub    (%ebx),%eax
  801cb5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801cbb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801cc2:	00 00 00 
	stat->st_dev = &devpipe;
  801cc5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801ccc:	30 80 00 
	return 0;
}
  801ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	53                   	push   %ebx
  801cdf:	83 ec 14             	sub    $0x14,%esp
  801ce2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ce5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf0:	e8 23 f4 ff ff       	call   801118 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cf5:	89 1c 24             	mov    %ebx,(%esp)
  801cf8:	e8 a7 f6 ff ff       	call   8013a4 <fd2data>
  801cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d08:	e8 0b f4 ff ff       	call   801118 <sys_page_unmap>
}
  801d0d:	83 c4 14             	add    $0x14,%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	57                   	push   %edi
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	83 ec 2c             	sub    $0x2c,%esp
  801d1c:	89 c7                	mov    %eax,%edi
  801d1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d21:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801d26:	8b 00                	mov    (%eax),%eax
  801d28:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d2b:	89 3c 24             	mov    %edi,(%esp)
  801d2e:	e8 89 05 00 00       	call   8022bc <pageref>
  801d33:	89 c6                	mov    %eax,%esi
  801d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d38:	89 04 24             	mov    %eax,(%esp)
  801d3b:	e8 7c 05 00 00       	call   8022bc <pageref>
  801d40:	39 c6                	cmp    %eax,%esi
  801d42:	0f 94 c0             	sete   %al
  801d45:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d48:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801d4e:	8b 12                	mov    (%edx),%edx
  801d50:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d53:	39 cb                	cmp    %ecx,%ebx
  801d55:	75 08                	jne    801d5f <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d57:	83 c4 2c             	add    $0x2c,%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d5f:	83 f8 01             	cmp    $0x1,%eax
  801d62:	75 bd                	jne    801d21 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d64:	8b 42 58             	mov    0x58(%edx),%eax
  801d67:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d6e:	00 
  801d6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d77:	c7 04 24 fe 2a 80 00 	movl   $0x802afe,(%esp)
  801d7e:	e8 51 e9 ff ff       	call   8006d4 <cprintf>
  801d83:	eb 9c                	jmp    801d21 <_pipeisclosed+0xe>

00801d85 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	57                   	push   %edi
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	83 ec 1c             	sub    $0x1c,%esp
  801d8e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d91:	89 34 24             	mov    %esi,(%esp)
  801d94:	e8 0b f6 ff ff       	call   8013a4 <fd2data>
  801d99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9b:	bf 00 00 00 00       	mov    $0x0,%edi
  801da0:	eb 3c                	jmp    801dde <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801da2:	89 da                	mov    %ebx,%edx
  801da4:	89 f0                	mov    %esi,%eax
  801da6:	e8 68 ff ff ff       	call   801d13 <_pipeisclosed>
  801dab:	85 c0                	test   %eax,%eax
  801dad:	75 38                	jne    801de7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801daf:	e8 9e f2 ff ff       	call   801052 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801db4:	8b 43 04             	mov    0x4(%ebx),%eax
  801db7:	8b 13                	mov    (%ebx),%edx
  801db9:	83 c2 20             	add    $0x20,%edx
  801dbc:	39 d0                	cmp    %edx,%eax
  801dbe:	73 e2                	jae    801da2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801dc6:	89 c2                	mov    %eax,%edx
  801dc8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801dce:	79 05                	jns    801dd5 <devpipe_write+0x50>
  801dd0:	4a                   	dec    %edx
  801dd1:	83 ca e0             	or     $0xffffffe0,%edx
  801dd4:	42                   	inc    %edx
  801dd5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dd9:	40                   	inc    %eax
  801dda:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddd:	47                   	inc    %edi
  801dde:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de1:	75 d1                	jne    801db4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801de3:	89 f8                	mov    %edi,%eax
  801de5:	eb 05                	jmp    801dec <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dec:	83 c4 1c             	add    $0x1c,%esp
  801def:	5b                   	pop    %ebx
  801df0:	5e                   	pop    %esi
  801df1:	5f                   	pop    %edi
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	57                   	push   %edi
  801df8:	56                   	push   %esi
  801df9:	53                   	push   %ebx
  801dfa:	83 ec 1c             	sub    $0x1c,%esp
  801dfd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e00:	89 3c 24             	mov    %edi,(%esp)
  801e03:	e8 9c f5 ff ff       	call   8013a4 <fd2data>
  801e08:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0a:	be 00 00 00 00       	mov    $0x0,%esi
  801e0f:	eb 3a                	jmp    801e4b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e11:	85 f6                	test   %esi,%esi
  801e13:	74 04                	je     801e19 <devpipe_read+0x25>
				return i;
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	eb 40                	jmp    801e59 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e19:	89 da                	mov    %ebx,%edx
  801e1b:	89 f8                	mov    %edi,%eax
  801e1d:	e8 f1 fe ff ff       	call   801d13 <_pipeisclosed>
  801e22:	85 c0                	test   %eax,%eax
  801e24:	75 2e                	jne    801e54 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e26:	e8 27 f2 ff ff       	call   801052 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e2b:	8b 03                	mov    (%ebx),%eax
  801e2d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e30:	74 df                	je     801e11 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e32:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e37:	79 05                	jns    801e3e <devpipe_read+0x4a>
  801e39:	48                   	dec    %eax
  801e3a:	83 c8 e0             	or     $0xffffffe0,%eax
  801e3d:	40                   	inc    %eax
  801e3e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e45:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e48:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e4a:	46                   	inc    %esi
  801e4b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e4e:	75 db                	jne    801e2b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e50:	89 f0                	mov    %esi,%eax
  801e52:	eb 05                	jmp    801e59 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e59:	83 c4 1c             	add    $0x1c,%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5f                   	pop    %edi
  801e5f:	5d                   	pop    %ebp
  801e60:	c3                   	ret    

00801e61 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	57                   	push   %edi
  801e65:	56                   	push   %esi
  801e66:	53                   	push   %ebx
  801e67:	83 ec 3c             	sub    $0x3c,%esp
  801e6a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e70:	89 04 24             	mov    %eax,(%esp)
  801e73:	e8 47 f5 ff ff       	call   8013bf <fd_alloc>
  801e78:	89 c3                	mov    %eax,%ebx
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	0f 88 45 01 00 00    	js     801fc7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e89:	00 
  801e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e98:	e8 d4 f1 ff ff       	call   801071 <sys_page_alloc>
  801e9d:	89 c3                	mov    %eax,%ebx
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	0f 88 20 01 00 00    	js     801fc7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ea7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801eaa:	89 04 24             	mov    %eax,(%esp)
  801ead:	e8 0d f5 ff ff       	call   8013bf <fd_alloc>
  801eb2:	89 c3                	mov    %eax,%ebx
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	0f 88 f8 00 00 00    	js     801fb4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec3:	00 
  801ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed2:	e8 9a f1 ff ff       	call   801071 <sys_page_alloc>
  801ed7:	89 c3                	mov    %eax,%ebx
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	0f 88 d3 00 00 00    	js     801fb4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ee4:	89 04 24             	mov    %eax,(%esp)
  801ee7:	e8 b8 f4 ff ff       	call   8013a4 <fd2data>
  801eec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef5:	00 
  801ef6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f01:	e8 6b f1 ff ff       	call   801071 <sys_page_alloc>
  801f06:	89 c3                	mov    %eax,%ebx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	0f 88 91 00 00 00    	js     801fa1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f13:	89 04 24             	mov    %eax,(%esp)
  801f16:	e8 89 f4 ff ff       	call   8013a4 <fd2data>
  801f1b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f22:	00 
  801f23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f2e:	00 
  801f2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3a:	e8 86 f1 ff ff       	call   8010c5 <sys_page_map>
  801f3f:	89 c3                	mov    %eax,%ebx
  801f41:	85 c0                	test   %eax,%eax
  801f43:	78 4c                	js     801f91 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f5a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f63:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f72:	89 04 24             	mov    %eax,(%esp)
  801f75:	e8 1a f4 ff ff       	call   801394 <fd2num>
  801f7a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f7f:	89 04 24             	mov    %eax,(%esp)
  801f82:	e8 0d f4 ff ff       	call   801394 <fd2num>
  801f87:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f8f:	eb 36                	jmp    801fc7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f91:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9c:	e8 77 f1 ff ff       	call   801118 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801faf:	e8 64 f1 ff ff       	call   801118 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801fb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc2:	e8 51 f1 ff ff       	call   801118 <sys_page_unmap>
    err:
	return r;
}
  801fc7:	89 d8                	mov    %ebx,%eax
  801fc9:	83 c4 3c             	add    $0x3c,%esp
  801fcc:	5b                   	pop    %ebx
  801fcd:	5e                   	pop    %esi
  801fce:	5f                   	pop    %edi
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fde:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe1:	89 04 24             	mov    %eax,(%esp)
  801fe4:	e8 29 f4 ff ff       	call   801412 <fd_lookup>
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 15                	js     802002 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff0:	89 04 24             	mov    %eax,(%esp)
  801ff3:	e8 ac f3 ff ff       	call   8013a4 <fd2data>
	return _pipeisclosed(fd, p);
  801ff8:	89 c2                	mov    %eax,%edx
  801ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffd:	e8 11 fd ff ff       	call   801d13 <_pipeisclosed>
}
  802002:	c9                   	leave  
  802003:	c3                   	ret    

00802004 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802014:	c7 44 24 04 16 2b 80 	movl   $0x802b16,0x4(%esp)
  80201b:	00 
  80201c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201f:	89 04 24             	mov    %eax,(%esp)
  802022:	e8 58 ec ff ff       	call   800c7f <strcpy>
	return 0;
}
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
  80202c:	c9                   	leave  
  80202d:	c3                   	ret    

0080202e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80203f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802045:	eb 30                	jmp    802077 <devcons_write+0x49>
		m = n - tot;
  802047:	8b 75 10             	mov    0x10(%ebp),%esi
  80204a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80204c:	83 fe 7f             	cmp    $0x7f,%esi
  80204f:	76 05                	jbe    802056 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802051:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802056:	89 74 24 08          	mov    %esi,0x8(%esp)
  80205a:	03 45 0c             	add    0xc(%ebp),%eax
  80205d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802061:	89 3c 24             	mov    %edi,(%esp)
  802064:	e8 8f ed ff ff       	call   800df8 <memmove>
		sys_cputs(buf, m);
  802069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206d:	89 3c 24             	mov    %edi,(%esp)
  802070:	e8 2f ef ff ff       	call   800fa4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802075:	01 f3                	add    %esi,%ebx
  802077:	89 d8                	mov    %ebx,%eax
  802079:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80207c:	72 c9                	jb     802047 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80207e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80208f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802093:	75 07                	jne    80209c <devcons_read+0x13>
  802095:	eb 25                	jmp    8020bc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802097:	e8 b6 ef ff ff       	call   801052 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80209c:	e8 21 ef ff ff       	call   800fc2 <sys_cgetc>
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	74 f2                	je     802097 <devcons_read+0xe>
  8020a5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 1d                	js     8020c8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020ab:	83 f8 04             	cmp    $0x4,%eax
  8020ae:	74 13                	je     8020c3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b3:	88 10                	mov    %dl,(%eax)
	return 1;
  8020b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ba:	eb 0c                	jmp    8020c8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c1:	eb 05                	jmp    8020c8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020c8:	c9                   	leave  
  8020c9:	c3                   	ret    

008020ca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
  8020cd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020dd:	00 
  8020de:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e1:	89 04 24             	mov    %eax,(%esp)
  8020e4:	e8 bb ee ff ff       	call   800fa4 <sys_cputs>
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <getchar>:

int
getchar(void)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020f8:	00 
  8020f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802107:	e8 a4 f5 ff ff       	call   8016b0 <read>
	if (r < 0)
  80210c:	85 c0                	test   %eax,%eax
  80210e:	78 0f                	js     80211f <getchar+0x34>
		return r;
	if (r < 1)
  802110:	85 c0                	test   %eax,%eax
  802112:	7e 06                	jle    80211a <getchar+0x2f>
		return -E_EOF;
	return c;
  802114:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802118:	eb 05                	jmp    80211f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80211a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80211f:	c9                   	leave  
  802120:	c3                   	ret    

00802121 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212e:	8b 45 08             	mov    0x8(%ebp),%eax
  802131:	89 04 24             	mov    %eax,(%esp)
  802134:	e8 d9 f2 ff ff       	call   801412 <fd_lookup>
  802139:	85 c0                	test   %eax,%eax
  80213b:	78 11                	js     80214e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80213d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802140:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802146:	39 10                	cmp    %edx,(%eax)
  802148:	0f 94 c0             	sete   %al
  80214b:	0f b6 c0             	movzbl %al,%eax
}
  80214e:	c9                   	leave  
  80214f:	c3                   	ret    

00802150 <opencons>:

int
opencons(void)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 5e f2 ff ff       	call   8013bf <fd_alloc>
  802161:	85 c0                	test   %eax,%eax
  802163:	78 3c                	js     8021a1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802165:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80216c:	00 
  80216d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802170:	89 44 24 04          	mov    %eax,0x4(%esp)
  802174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217b:	e8 f1 ee ff ff       	call   801071 <sys_page_alloc>
  802180:	85 c0                	test   %eax,%eax
  802182:	78 1d                	js     8021a1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802184:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80218a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80218f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802192:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802199:	89 04 24             	mov    %eax,(%esp)
  80219c:	e8 f3 f1 ff ff       	call   801394 <fd2num>
}
  8021a1:	c9                   	leave  
  8021a2:	c3                   	ret    
	...

008021a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	56                   	push   %esi
  8021a8:	53                   	push   %ebx
  8021a9:	83 ec 10             	sub    $0x10,%esp
  8021ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8021af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8021b5:	85 c0                	test   %eax,%eax
  8021b7:	75 05                	jne    8021be <ipc_recv+0x1a>
  8021b9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  8021be:	89 04 24             	mov    %eax,(%esp)
  8021c1:	e8 c1 f0 ff ff       	call   801287 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	79 16                	jns    8021e0 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  8021ca:	85 db                	test   %ebx,%ebx
  8021cc:	74 06                	je     8021d4 <ipc_recv+0x30>
  8021ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8021d4:	85 f6                	test   %esi,%esi
  8021d6:	74 32                	je     80220a <ipc_recv+0x66>
  8021d8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8021de:	eb 2a                	jmp    80220a <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8021e0:	85 db                	test   %ebx,%ebx
  8021e2:	74 0c                	je     8021f0 <ipc_recv+0x4c>
  8021e4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8021e9:	8b 00                	mov    (%eax),%eax
  8021eb:	8b 40 74             	mov    0x74(%eax),%eax
  8021ee:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8021f0:	85 f6                	test   %esi,%esi
  8021f2:	74 0c                	je     802200 <ipc_recv+0x5c>
  8021f4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8021f9:	8b 00                	mov    (%eax),%eax
  8021fb:	8b 40 78             	mov    0x78(%eax),%eax
  8021fe:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  802200:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802205:	8b 00                	mov    (%eax),%eax
  802207:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  80220a:	83 c4 10             	add    $0x10,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    

00802211 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	57                   	push   %edi
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	83 ec 1c             	sub    $0x1c,%esp
  80221a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80221d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802220:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802223:	85 db                	test   %ebx,%ebx
  802225:	75 05                	jne    80222c <ipc_send+0x1b>
  802227:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  80222c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802230:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802234:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802238:	8b 45 08             	mov    0x8(%ebp),%eax
  80223b:	89 04 24             	mov    %eax,(%esp)
  80223e:	e8 21 f0 ff ff       	call   801264 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  802243:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802246:	75 07                	jne    80224f <ipc_send+0x3e>
  802248:	e8 05 ee ff ff       	call   801052 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  80224d:	eb dd                	jmp    80222c <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  80224f:	85 c0                	test   %eax,%eax
  802251:	79 1c                	jns    80226f <ipc_send+0x5e>
  802253:	c7 44 24 08 22 2b 80 	movl   $0x802b22,0x8(%esp)
  80225a:	00 
  80225b:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802262:	00 
  802263:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  80226a:	e8 6d e3 ff ff       	call   8005dc <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  80226f:	83 c4 1c             	add    $0x1c,%esp
  802272:	5b                   	pop    %ebx
  802273:	5e                   	pop    %esi
  802274:	5f                   	pop    %edi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	53                   	push   %ebx
  80227b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80227e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802283:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80228a:	89 c2                	mov    %eax,%edx
  80228c:	c1 e2 07             	shl    $0x7,%edx
  80228f:	29 ca                	sub    %ecx,%edx
  802291:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802297:	8b 52 50             	mov    0x50(%edx),%edx
  80229a:	39 da                	cmp    %ebx,%edx
  80229c:	75 0f                	jne    8022ad <ipc_find_env+0x36>
			return envs[i].env_id;
  80229e:	c1 e0 07             	shl    $0x7,%eax
  8022a1:	29 c8                	sub    %ecx,%eax
  8022a3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022a8:	8b 40 40             	mov    0x40(%eax),%eax
  8022ab:	eb 0c                	jmp    8022b9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ad:	40                   	inc    %eax
  8022ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b3:	75 ce                	jne    802283 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b5:	66 b8 00 00          	mov    $0x0,%ax
}
  8022b9:	5b                   	pop    %ebx
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    

008022bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  8022c2:	89 c2                	mov    %eax,%edx
  8022c4:	c1 ea 16             	shr    $0x16,%edx
  8022c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022ce:	f6 c2 01             	test   $0x1,%dl
  8022d1:	74 1e                	je     8022f1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d3:	c1 e8 0c             	shr    $0xc,%eax
  8022d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022dd:	a8 01                	test   $0x1,%al
  8022df:	74 17                	je     8022f8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e1:	c1 e8 0c             	shr    $0xc,%eax
  8022e4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022eb:	ef 
  8022ec:	0f b7 c0             	movzwl %ax,%eax
  8022ef:	eb 0c                	jmp    8022fd <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f6:	eb 05                	jmp    8022fd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022f8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    
	...

00802300 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	83 ec 10             	sub    $0x10,%esp
  802306:	8b 74 24 20          	mov    0x20(%esp),%esi
  80230a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80230e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802312:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802316:	89 cd                	mov    %ecx,%ebp
  802318:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80231c:	85 c0                	test   %eax,%eax
  80231e:	75 2c                	jne    80234c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802320:	39 f9                	cmp    %edi,%ecx
  802322:	77 68                	ja     80238c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802324:	85 c9                	test   %ecx,%ecx
  802326:	75 0b                	jne    802333 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802328:	b8 01 00 00 00       	mov    $0x1,%eax
  80232d:	31 d2                	xor    %edx,%edx
  80232f:	f7 f1                	div    %ecx
  802331:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802333:	31 d2                	xor    %edx,%edx
  802335:	89 f8                	mov    %edi,%eax
  802337:	f7 f1                	div    %ecx
  802339:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80233b:	89 f0                	mov    %esi,%eax
  80233d:	f7 f1                	div    %ecx
  80233f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802341:	89 f0                	mov    %esi,%eax
  802343:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802345:	83 c4 10             	add    $0x10,%esp
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80234c:	39 f8                	cmp    %edi,%eax
  80234e:	77 2c                	ja     80237c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802350:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802353:	83 f6 1f             	xor    $0x1f,%esi
  802356:	75 4c                	jne    8023a4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802358:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80235a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80235f:	72 0a                	jb     80236b <__udivdi3+0x6b>
  802361:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802365:	0f 87 ad 00 00 00    	ja     802418 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80236b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802370:	89 f0                	mov    %esi,%eax
  802372:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	5e                   	pop    %esi
  802378:	5f                   	pop    %edi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
  80237b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80237c:	31 ff                	xor    %edi,%edi
  80237e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802380:	89 f0                	mov    %esi,%eax
  802382:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802384:	83 c4 10             	add    $0x10,%esp
  802387:	5e                   	pop    %esi
  802388:	5f                   	pop    %edi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    
  80238b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80238c:	89 fa                	mov    %edi,%edx
  80238e:	89 f0                	mov    %esi,%eax
  802390:	f7 f1                	div    %ecx
  802392:	89 c6                	mov    %eax,%esi
  802394:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802396:	89 f0                	mov    %esi,%eax
  802398:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80239a:	83 c4 10             	add    $0x10,%esp
  80239d:	5e                   	pop    %esi
  80239e:	5f                   	pop    %edi
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    
  8023a1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023a4:	89 f1                	mov    %esi,%ecx
  8023a6:	d3 e0                	shl    %cl,%eax
  8023a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023ac:	b8 20 00 00 00       	mov    $0x20,%eax
  8023b1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8023b3:	89 ea                	mov    %ebp,%edx
  8023b5:	88 c1                	mov    %al,%cl
  8023b7:	d3 ea                	shr    %cl,%edx
  8023b9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023bd:	09 ca                	or     %ecx,%edx
  8023bf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8023c3:	89 f1                	mov    %esi,%ecx
  8023c5:	d3 e5                	shl    %cl,%ebp
  8023c7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8023cb:	89 fd                	mov    %edi,%ebp
  8023cd:	88 c1                	mov    %al,%cl
  8023cf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8023d1:	89 fa                	mov    %edi,%edx
  8023d3:	89 f1                	mov    %esi,%ecx
  8023d5:	d3 e2                	shl    %cl,%edx
  8023d7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023db:	88 c1                	mov    %al,%cl
  8023dd:	d3 ef                	shr    %cl,%edi
  8023df:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023e1:	89 f8                	mov    %edi,%eax
  8023e3:	89 ea                	mov    %ebp,%edx
  8023e5:	f7 74 24 08          	divl   0x8(%esp)
  8023e9:	89 d1                	mov    %edx,%ecx
  8023eb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023ed:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f1:	39 d1                	cmp    %edx,%ecx
  8023f3:	72 17                	jb     80240c <__udivdi3+0x10c>
  8023f5:	74 09                	je     802400 <__udivdi3+0x100>
  8023f7:	89 fe                	mov    %edi,%esi
  8023f9:	31 ff                	xor    %edi,%edi
  8023fb:	e9 41 ff ff ff       	jmp    802341 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802400:	8b 54 24 04          	mov    0x4(%esp),%edx
  802404:	89 f1                	mov    %esi,%ecx
  802406:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802408:	39 c2                	cmp    %eax,%edx
  80240a:	73 eb                	jae    8023f7 <__udivdi3+0xf7>
		{
		  q0--;
  80240c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80240f:	31 ff                	xor    %edi,%edi
  802411:	e9 2b ff ff ff       	jmp    802341 <__udivdi3+0x41>
  802416:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802418:	31 f6                	xor    %esi,%esi
  80241a:	e9 22 ff ff ff       	jmp    802341 <__udivdi3+0x41>
	...

00802420 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	83 ec 20             	sub    $0x20,%esp
  802426:	8b 44 24 30          	mov    0x30(%esp),%eax
  80242a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80242e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802432:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802436:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80243a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80243e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802440:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802442:	85 ed                	test   %ebp,%ebp
  802444:	75 16                	jne    80245c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802446:	39 f1                	cmp    %esi,%ecx
  802448:	0f 86 a6 00 00 00    	jbe    8024f4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80244e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802450:	89 d0                	mov    %edx,%eax
  802452:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802454:	83 c4 20             	add    $0x20,%esp
  802457:	5e                   	pop    %esi
  802458:	5f                   	pop    %edi
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    
  80245b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80245c:	39 f5                	cmp    %esi,%ebp
  80245e:	0f 87 ac 00 00 00    	ja     802510 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802464:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802467:	83 f0 1f             	xor    $0x1f,%eax
  80246a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80246e:	0f 84 a8 00 00 00    	je     80251c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802474:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802478:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80247a:	bf 20 00 00 00       	mov    $0x20,%edi
  80247f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802483:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802487:	89 f9                	mov    %edi,%ecx
  802489:	d3 e8                	shr    %cl,%eax
  80248b:	09 e8                	or     %ebp,%eax
  80248d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802491:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802495:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802499:	d3 e0                	shl    %cl,%eax
  80249b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80249f:	89 f2                	mov    %esi,%edx
  8024a1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8024a3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024a7:	d3 e0                	shl    %cl,%eax
  8024a9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8024ad:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	d3 e8                	shr    %cl,%eax
  8024b5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8024b7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024b9:	89 f2                	mov    %esi,%edx
  8024bb:	f7 74 24 18          	divl   0x18(%esp)
  8024bf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8024c1:	f7 64 24 0c          	mull   0xc(%esp)
  8024c5:	89 c5                	mov    %eax,%ebp
  8024c7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024c9:	39 d6                	cmp    %edx,%esi
  8024cb:	72 67                	jb     802534 <__umoddi3+0x114>
  8024cd:	74 75                	je     802544 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8024cf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024d3:	29 e8                	sub    %ebp,%eax
  8024d5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8024d7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024db:	d3 e8                	shr    %cl,%eax
  8024dd:	89 f2                	mov    %esi,%edx
  8024df:	89 f9                	mov    %edi,%ecx
  8024e1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8024e3:	09 d0                	or     %edx,%eax
  8024e5:	89 f2                	mov    %esi,%edx
  8024e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024eb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024ed:	83 c4 20             	add    $0x20,%esp
  8024f0:	5e                   	pop    %esi
  8024f1:	5f                   	pop    %edi
  8024f2:	5d                   	pop    %ebp
  8024f3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024f4:	85 c9                	test   %ecx,%ecx
  8024f6:	75 0b                	jne    802503 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fd:	31 d2                	xor    %edx,%edx
  8024ff:	f7 f1                	div    %ecx
  802501:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802503:	89 f0                	mov    %esi,%eax
  802505:	31 d2                	xor    %edx,%edx
  802507:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802509:	89 f8                	mov    %edi,%eax
  80250b:	e9 3e ff ff ff       	jmp    80244e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802510:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802512:	83 c4 20             	add    $0x20,%esp
  802515:	5e                   	pop    %esi
  802516:	5f                   	pop    %edi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    
  802519:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80251c:	39 f5                	cmp    %esi,%ebp
  80251e:	72 04                	jb     802524 <__umoddi3+0x104>
  802520:	39 f9                	cmp    %edi,%ecx
  802522:	77 06                	ja     80252a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802524:	89 f2                	mov    %esi,%edx
  802526:	29 cf                	sub    %ecx,%edi
  802528:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80252a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80252c:	83 c4 20             	add    $0x20,%esp
  80252f:	5e                   	pop    %esi
  802530:	5f                   	pop    %edi
  802531:	5d                   	pop    %ebp
  802532:	c3                   	ret    
  802533:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802534:	89 d1                	mov    %edx,%ecx
  802536:	89 c5                	mov    %eax,%ebp
  802538:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80253c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802540:	eb 8d                	jmp    8024cf <__umoddi3+0xaf>
  802542:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802544:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802548:	72 ea                	jb     802534 <__umoddi3+0x114>
  80254a:	89 f1                	mov    %esi,%ecx
  80254c:	eb 81                	jmp    8024cf <__umoddi3+0xaf>
