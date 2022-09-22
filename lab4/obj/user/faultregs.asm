
obj/user/faultregs:     file format elf32-i386


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
  80004c:	c7 44 24 04 d1 15 80 	movl   $0x8015d1,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 a0 15 80 00 	movl   $0x8015a0,(%esp)
  80005b:	e8 7c 06 00 00       	call   8006dc <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 b0 15 80 	movl   $0x8015b0,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  80007b:	e8 5c 06 00 00       	call   8006dc <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  80008d:	e8 4a 06 00 00       	call   8006dc <cprintf>

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
  800099:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  8000a0:	e8 37 06 00 00       	call   8006dc <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 d2 15 80 	movl   $0x8015d2,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  8000c7:	e8 10 06 00 00       	call   8006dc <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  8000db:	e8 fc 05 00 00       	call   8006dc <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  8000e9:	e8 ee 05 00 00       	call   8006dc <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 d6 15 80 	movl   $0x8015d6,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  800110:	e8 c7 05 00 00       	call   8006dc <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  800124:	e8 b3 05 00 00       	call   8006dc <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  800132:	e8 a5 05 00 00       	call   8006dc <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 da 15 80 	movl   $0x8015da,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  800159:	e8 7e 05 00 00       	call   8006dc <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  80016d:	e8 6a 05 00 00       	call   8006dc <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  80017b:	e8 5c 05 00 00       	call   8006dc <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 de 15 80 	movl   $0x8015de,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  8001a2:	e8 35 05 00 00       	call   8006dc <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  8001b6:	e8 21 05 00 00       	call   8006dc <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  8001c4:	e8 13 05 00 00       	call   8006dc <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 e2 15 80 	movl   $0x8015e2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  8001eb:	e8 ec 04 00 00       	call   8006dc <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  8001ff:	e8 d8 04 00 00       	call   8006dc <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  80020d:	e8 ca 04 00 00       	call   8006dc <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 e6 15 80 	movl   $0x8015e6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  800234:	e8 a3 04 00 00       	call   8006dc <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  800248:	e8 8f 04 00 00       	call   8006dc <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  800256:	e8 81 04 00 00       	call   8006dc <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 ea 15 80 	movl   $0x8015ea,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  80027d:	e8 5a 04 00 00       	call   8006dc <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  800291:	e8 46 04 00 00       	call   8006dc <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  80029f:	e8 38 04 00 00       	call   8006dc <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ee 15 80 	movl   $0x8015ee,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  8002c6:	e8 11 04 00 00       	call   8006dc <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  8002da:	e8 fd 03 00 00       	call   8006dc <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  8002e8:	e8 ef 03 00 00       	call   8006dc <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 f5 15 80 	movl   $0x8015f5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  80030f:	e8 c8 03 00 00       	call   8006dc <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  800323:	e8 b4 03 00 00       	call   8006dc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 f9 15 80 00 	movl   $0x8015f9,(%esp)
  800336:	e8 a1 03 00 00       	call   8006dc <cprintf>
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
  800341:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  800348:	e8 8f 03 00 00       	call   8006dc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 f9 15 80 00 	movl   $0x8015f9,(%esp)
  80035b:	e8 7c 03 00 00       	call   8006dc <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  800369:	e8 6e 03 00 00       	call   8006dc <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  800377:	e8 60 03 00 00       	call   8006dc <cprintf>
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
  8003a4:	c7 44 24 08 60 16 80 	movl   $0x801660,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 07 16 80 00 	movl   $0x801607,(%esp)
  8003bb:	e8 24 02 00 00       	call   8005e4 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf a0 20 80 00       	mov    $0x8020a0,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags & ~FL_RF;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  8003dd:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  8003e3:	8b 40 30             	mov    0x30(%eax),%eax
  8003e6:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003eb:	c7 44 24 04 1f 16 80 	movl   $0x80161f,0x4(%esp)
  8003f2:	00 
  8003f3:	c7 04 24 2d 16 80 00 	movl   $0x80162d,(%esp)
  8003fa:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  8003ff:	ba 18 16 80 00       	mov    $0x801618,%edx
  800404:	b8 20 20 80 00       	mov    $0x802020,%eax
  800409:	e8 26 fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80040e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800415:	00 
  800416:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80041d:	00 
  80041e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800425:	e8 4f 0c 00 00       	call   801079 <sys_page_alloc>
  80042a:	85 c0                	test   %eax,%eax
  80042c:	79 20                	jns    80044e <pgfault+0xca>
		panic("sys_page_alloc: %e", r);
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 34 16 80 	movl   $0x801634,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 07 16 80 00 	movl   $0x801607,(%esp)
  800449:	e8 96 01 00 00       	call   8005e4 <_panic>
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
  800462:	e8 29 0e 00 00       	call   801290 <set_pgfault_handler>

	asm volatile(
  800467:	50                   	push   %eax
  800468:	9c                   	pushf  
  800469:	58                   	pop    %eax
  80046a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80046f:	50                   	push   %eax
  800470:	9d                   	popf   
  800471:	a3 44 20 80 00       	mov    %eax,0x802044
  800476:	8d 05 b1 04 80 00    	lea    0x8004b1,%eax
  80047c:	a3 40 20 80 00       	mov    %eax,0x802040
  800481:	58                   	pop    %eax
  800482:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800488:	89 35 24 20 80 00    	mov    %esi,0x802024
  80048e:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800494:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  80049a:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004a0:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004a6:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004ab:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004b1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b8:	00 00 00 
  8004bb:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004c1:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004c7:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004cd:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  8004d3:	89 15 74 20 80 00    	mov    %edx,0x802074
  8004d9:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  8004df:	a3 7c 20 80 00       	mov    %eax,0x80207c
  8004e4:	89 25 88 20 80 00    	mov    %esp,0x802088
  8004ea:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8004f0:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8004f6:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8004fc:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800502:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800508:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80050e:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800513:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800519:	50                   	push   %eax
  80051a:	9c                   	pushf  
  80051b:	58                   	pop    %eax
  80051c:	a3 84 20 80 00       	mov    %eax,0x802084
  800521:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800522:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800529:	74 0c                	je     800537 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80052b:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  800532:	e8 a5 01 00 00       	call   8006dc <cprintf>
	after.eip = before.eip;
  800537:	a1 40 20 80 00       	mov    0x802040,%eax
  80053c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800541:	c7 44 24 04 47 16 80 	movl   $0x801647,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 58 16 80 00 	movl   $0x801658,(%esp)
  800550:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800555:	ba 18 16 80 00       	mov    $0x801618,%edx
  80055a:	b8 20 20 80 00       	mov    $0x802020,%eax
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
  800576:	e8 c0 0a 00 00       	call   80103b <sys_getenvid>
  80057b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800580:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800587:	c1 e0 07             	shl    $0x7,%eax
  80058a:	29 d0                	sub    %edx,%eax
  80058c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800591:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800597:	a3 cc 20 80 00       	mov    %eax,0x8020cc
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  8005a0:	c7 04 24 b3 16 80 00 	movl   $0x8016b3,(%esp)
  8005a7:	e8 30 01 00 00       	call   8006dc <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005ac:	85 f6                	test   %esi,%esi
  8005ae:	7e 07                	jle    8005b7 <libmain+0x4f>
		binaryname = argv[0];
  8005b0:	8b 03                	mov    (%ebx),%eax
  8005b2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bb:	89 34 24             	mov    %esi,(%esp)
  8005be:	e8 92 fe ff ff       	call   800455 <umain>

	// exit gracefully
	exit();
  8005c3:	e8 08 00 00 00       	call   8005d0 <exit>
}
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	5b                   	pop    %ebx
  8005cc:	5e                   	pop    %esi
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    
	...

008005d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005dd:	e8 07 0a 00 00       	call   800fe9 <sys_env_destroy>
}
  8005e2:	c9                   	leave  
  8005e3:	c3                   	ret    

008005e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	56                   	push   %esi
  8005e8:	53                   	push   %ebx
  8005e9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ec:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ef:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8005f5:	e8 41 0a 00 00       	call   80103b <sys_getenvid>
  8005fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800601:	8b 55 08             	mov    0x8(%ebp),%edx
  800604:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800608:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80060c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800610:	c7 04 24 c4 16 80 00 	movl   $0x8016c4,(%esp)
  800617:	e8 c0 00 00 00       	call   8006dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800620:	8b 45 10             	mov    0x10(%ebp),%eax
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	e8 50 00 00 00       	call   80067b <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 d0 15 80 00 	movl   $0x8015d0,(%esp)
  800632:	e8 a5 00 00 00       	call   8006dc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800637:	cc                   	int3   
  800638:	eb fd                	jmp    800637 <_panic+0x53>
	...

0080063c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	53                   	push   %ebx
  800640:	83 ec 14             	sub    $0x14,%esp
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800646:	8b 03                	mov    (%ebx),%eax
  800648:	8b 55 08             	mov    0x8(%ebp),%edx
  80064b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80064f:	40                   	inc    %eax
  800650:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800652:	3d ff 00 00 00       	cmp    $0xff,%eax
  800657:	75 19                	jne    800672 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800659:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800660:	00 
  800661:	8d 43 08             	lea    0x8(%ebx),%eax
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	e8 40 09 00 00       	call   800fac <sys_cputs>
		b->idx = 0;
  80066c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800672:	ff 43 04             	incl   0x4(%ebx)
}
  800675:	83 c4 14             	add    $0x14,%esp
  800678:	5b                   	pop    %ebx
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800684:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068b:	00 00 00 
	b.cnt = 0;
  80068e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800695:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800698:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	c7 04 24 3c 06 80 00 	movl   $0x80063c,(%esp)
  8006b7:	e8 82 01 00 00       	call   80083e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006bc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	e8 d8 08 00 00       	call   800fac <sys_cputs>

	return b.cnt;
}
  8006d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	e8 87 ff ff ff       	call   80067b <vcprintf>
	va_end(ap);

	return cnt;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    
	...

008006f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	57                   	push   %edi
  8006fc:	56                   	push   %esi
  8006fd:	53                   	push   %ebx
  8006fe:	83 ec 3c             	sub    $0x3c,%esp
  800701:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800704:	89 d7                	mov    %edx,%edi
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80070c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800712:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800715:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800718:	85 c0                	test   %eax,%eax
  80071a:	75 08                	jne    800724 <printnum+0x2c>
  80071c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80071f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800722:	77 57                	ja     80077b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800724:	89 74 24 10          	mov    %esi,0x10(%esp)
  800728:	4b                   	dec    %ebx
  800729:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80072d:	8b 45 10             	mov    0x10(%ebp),%eax
  800730:	89 44 24 08          	mov    %eax,0x8(%esp)
  800734:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800738:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80073c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800743:	00 
  800744:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80074d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800751:	e8 f2 0b 00 00       	call   801348 <__udivdi3>
  800756:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80075a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80075e:	89 04 24             	mov    %eax,(%esp)
  800761:	89 54 24 04          	mov    %edx,0x4(%esp)
  800765:	89 fa                	mov    %edi,%edx
  800767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80076a:	e8 89 ff ff ff       	call   8006f8 <printnum>
  80076f:	eb 0f                	jmp    800780 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800771:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800775:	89 34 24             	mov    %esi,(%esp)
  800778:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80077b:	4b                   	dec    %ebx
  80077c:	85 db                	test   %ebx,%ebx
  80077e:	7f f1                	jg     800771 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800780:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800784:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800788:	8b 45 10             	mov    0x10(%ebp),%eax
  80078b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800796:	00 
  800797:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	e8 bf 0c 00 00       	call   801468 <__umoddi3>
  8007a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ad:	0f be 80 e7 16 80 00 	movsbl 0x8016e7(%eax),%eax
  8007b4:	89 04 24             	mov    %eax,(%esp)
  8007b7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007ba:	83 c4 3c             	add    $0x3c,%esp
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5f                   	pop    %edi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007c5:	83 fa 01             	cmp    $0x1,%edx
  8007c8:	7e 0e                	jle    8007d8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007ca:	8b 10                	mov    (%eax),%edx
  8007cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007cf:	89 08                	mov    %ecx,(%eax)
  8007d1:	8b 02                	mov    (%edx),%eax
  8007d3:	8b 52 04             	mov    0x4(%edx),%edx
  8007d6:	eb 22                	jmp    8007fa <getuint+0x38>
	else if (lflag)
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 10                	je     8007ec <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007dc:	8b 10                	mov    (%eax),%edx
  8007de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e1:	89 08                	mov    %ecx,(%eax)
  8007e3:	8b 02                	mov    (%edx),%eax
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ea:	eb 0e                	jmp    8007fa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007ec:	8b 10                	mov    (%eax),%edx
  8007ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007f1:	89 08                	mov    %ecx,(%eax)
  8007f3:	8b 02                	mov    (%edx),%eax
  8007f5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800802:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800805:	8b 10                	mov    (%eax),%edx
  800807:	3b 50 04             	cmp    0x4(%eax),%edx
  80080a:	73 08                	jae    800814 <sprintputch+0x18>
		*b->buf++ = ch;
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	88 0a                	mov    %cl,(%edx)
  800811:	42                   	inc    %edx
  800812:	89 10                	mov    %edx,(%eax)
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80081c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80081f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800823:	8b 45 10             	mov    0x10(%ebp),%eax
  800826:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	e8 02 00 00 00       	call   80083e <vprintfmt>
	va_end(ap);
}
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	57                   	push   %edi
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	83 ec 4c             	sub    $0x4c,%esp
  800847:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084a:	8b 75 10             	mov    0x10(%ebp),%esi
  80084d:	eb 12                	jmp    800861 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80084f:	85 c0                	test   %eax,%eax
  800851:	0f 84 6b 03 00 00    	je     800bc2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800857:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085b:	89 04 24             	mov    %eax,(%esp)
  80085e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800861:	0f b6 06             	movzbl (%esi),%eax
  800864:	46                   	inc    %esi
  800865:	83 f8 25             	cmp    $0x25,%eax
  800868:	75 e5                	jne    80084f <vprintfmt+0x11>
  80086a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80086e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800875:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80087a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
  800886:	eb 26                	jmp    8008ae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800888:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80088b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80088f:	eb 1d                	jmp    8008ae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800891:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800894:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800898:	eb 14                	jmp    8008ae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80089d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008a4:	eb 08                	jmp    8008ae <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008a6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008a9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	0f b6 06             	movzbl (%esi),%eax
  8008b1:	8d 56 01             	lea    0x1(%esi),%edx
  8008b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008b7:	8a 16                	mov    (%esi),%dl
  8008b9:	83 ea 23             	sub    $0x23,%edx
  8008bc:	80 fa 55             	cmp    $0x55,%dl
  8008bf:	0f 87 e1 02 00 00    	ja     800ba6 <vprintfmt+0x368>
  8008c5:	0f b6 d2             	movzbl %dl,%edx
  8008c8:	ff 24 95 a0 17 80 00 	jmp    *0x8017a0(,%edx,4)
  8008cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008d2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008d7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008da:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008de:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008e1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008e4:	83 fa 09             	cmp    $0x9,%edx
  8008e7:	77 2a                	ja     800913 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008e9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008ea:	eb eb                	jmp    8008d7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	8d 50 04             	lea    0x4(%eax),%edx
  8008f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008fa:	eb 17                	jmp    800913 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800900:	78 98                	js     80089a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800902:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800905:	eb a7                	jmp    8008ae <vprintfmt+0x70>
  800907:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80090a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800911:	eb 9b                	jmp    8008ae <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800913:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800917:	79 95                	jns    8008ae <vprintfmt+0x70>
  800919:	eb 8b                	jmp    8008a6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80091b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80091f:	eb 8d                	jmp    8008ae <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800921:	8b 45 14             	mov    0x14(%ebp),%eax
  800924:	8d 50 04             	lea    0x4(%eax),%edx
  800927:	89 55 14             	mov    %edx,0x14(%ebp)
  80092a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092e:	8b 00                	mov    (%eax),%eax
  800930:	89 04 24             	mov    %eax,(%esp)
  800933:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800936:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800939:	e9 23 ff ff ff       	jmp    800861 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)
  800947:	8b 00                	mov    (%eax),%eax
  800949:	85 c0                	test   %eax,%eax
  80094b:	79 02                	jns    80094f <vprintfmt+0x111>
  80094d:	f7 d8                	neg    %eax
  80094f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800951:	83 f8 08             	cmp    $0x8,%eax
  800954:	7f 0b                	jg     800961 <vprintfmt+0x123>
  800956:	8b 04 85 00 19 80 00 	mov    0x801900(,%eax,4),%eax
  80095d:	85 c0                	test   %eax,%eax
  80095f:	75 23                	jne    800984 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800961:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800965:	c7 44 24 08 ff 16 80 	movl   $0x8016ff,0x8(%esp)
  80096c:	00 
  80096d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	e8 9a fe ff ff       	call   800816 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80097f:	e9 dd fe ff ff       	jmp    800861 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800984:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800988:	c7 44 24 08 08 17 80 	movl   $0x801708,0x8(%esp)
  80098f:	00 
  800990:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800994:	8b 55 08             	mov    0x8(%ebp),%edx
  800997:	89 14 24             	mov    %edx,(%esp)
  80099a:	e8 77 fe ff ff       	call   800816 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009a2:	e9 ba fe ff ff       	jmp    800861 <vprintfmt+0x23>
  8009a7:	89 f9                	mov    %edi,%ecx
  8009a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 30                	mov    (%eax),%esi
  8009ba:	85 f6                	test   %esi,%esi
  8009bc:	75 05                	jne    8009c3 <vprintfmt+0x185>
				p = "(null)";
  8009be:	be f8 16 80 00       	mov    $0x8016f8,%esi
			if (width > 0 && padc != '-')
  8009c3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009c7:	0f 8e 84 00 00 00    	jle    800a51 <vprintfmt+0x213>
  8009cd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009d1:	74 7e                	je     800a51 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009d7:	89 34 24             	mov    %esi,(%esp)
  8009da:	e8 8b 02 00 00       	call   800c6a <strnlen>
  8009df:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009e2:	29 c2                	sub    %eax,%edx
  8009e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009e7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009eb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009ee:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009f1:	89 de                	mov    %ebx,%esi
  8009f3:	89 d3                	mov    %edx,%ebx
  8009f5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f7:	eb 0b                	jmp    800a04 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fd:	89 3c 24             	mov    %edi,(%esp)
  800a00:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a03:	4b                   	dec    %ebx
  800a04:	85 db                	test   %ebx,%ebx
  800a06:	7f f1                	jg     8009f9 <vprintfmt+0x1bb>
  800a08:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800a0b:	89 f3                	mov    %esi,%ebx
  800a0d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800a10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a13:	85 c0                	test   %eax,%eax
  800a15:	79 05                	jns    800a1c <vprintfmt+0x1de>
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a1f:	29 c2                	sub    %eax,%edx
  800a21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a24:	eb 2b                	jmp    800a51 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a26:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a2a:	74 18                	je     800a44 <vprintfmt+0x206>
  800a2c:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a2f:	83 fa 5e             	cmp    $0x5e,%edx
  800a32:	76 10                	jbe    800a44 <vprintfmt+0x206>
					putch('?', putdat);
  800a34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a38:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a3f:	ff 55 08             	call   *0x8(%ebp)
  800a42:	eb 0a                	jmp    800a4e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a48:	89 04 24             	mov    %eax,(%esp)
  800a4b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4e:	ff 4d e4             	decl   -0x1c(%ebp)
  800a51:	0f be 06             	movsbl (%esi),%eax
  800a54:	46                   	inc    %esi
  800a55:	85 c0                	test   %eax,%eax
  800a57:	74 21                	je     800a7a <vprintfmt+0x23c>
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	78 c9                	js     800a26 <vprintfmt+0x1e8>
  800a5d:	4f                   	dec    %edi
  800a5e:	79 c6                	jns    800a26 <vprintfmt+0x1e8>
  800a60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a63:	89 de                	mov    %ebx,%esi
  800a65:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a68:	eb 18                	jmp    800a82 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a75:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a77:	4b                   	dec    %ebx
  800a78:	eb 08                	jmp    800a82 <vprintfmt+0x244>
  800a7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7d:	89 de                	mov    %ebx,%esi
  800a7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a82:	85 db                	test   %ebx,%ebx
  800a84:	7f e4                	jg     800a6a <vprintfmt+0x22c>
  800a86:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a89:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a8e:	e9 ce fd ff ff       	jmp    800861 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a93:	83 f9 01             	cmp    $0x1,%ecx
  800a96:	7e 10                	jle    800aa8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a98:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9b:	8d 50 08             	lea    0x8(%eax),%edx
  800a9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa1:	8b 30                	mov    (%eax),%esi
  800aa3:	8b 78 04             	mov    0x4(%eax),%edi
  800aa6:	eb 26                	jmp    800ace <vprintfmt+0x290>
	else if (lflag)
  800aa8:	85 c9                	test   %ecx,%ecx
  800aaa:	74 12                	je     800abe <vprintfmt+0x280>
		return va_arg(*ap, long);
  800aac:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaf:	8d 50 04             	lea    0x4(%eax),%edx
  800ab2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab5:	8b 30                	mov    (%eax),%esi
  800ab7:	89 f7                	mov    %esi,%edi
  800ab9:	c1 ff 1f             	sar    $0x1f,%edi
  800abc:	eb 10                	jmp    800ace <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8d 50 04             	lea    0x4(%eax),%edx
  800ac4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac7:	8b 30                	mov    (%eax),%esi
  800ac9:	89 f7                	mov    %esi,%edi
  800acb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ace:	85 ff                	test   %edi,%edi
  800ad0:	78 0a                	js     800adc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ad7:	e9 8c 00 00 00       	jmp    800b68 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800adc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ae7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aea:	f7 de                	neg    %esi
  800aec:	83 d7 00             	adc    $0x0,%edi
  800aef:	f7 df                	neg    %edi
			}
			base = 10;
  800af1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af6:	eb 70                	jmp    800b68 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800af8:	89 ca                	mov    %ecx,%edx
  800afa:	8d 45 14             	lea    0x14(%ebp),%eax
  800afd:	e8 c0 fc ff ff       	call   8007c2 <getuint>
  800b02:	89 c6                	mov    %eax,%esi
  800b04:	89 d7                	mov    %edx,%edi
			base = 10;
  800b06:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b0b:	eb 5b                	jmp    800b68 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800b0d:	89 ca                	mov    %ecx,%edx
  800b0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b12:	e8 ab fc ff ff       	call   8007c2 <getuint>
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	89 d7                	mov    %edx,%edi
			base = 8;
  800b1b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b20:	eb 46                	jmp    800b68 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b26:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b2d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b34:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b3b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b41:	8d 50 04             	lea    0x4(%eax),%edx
  800b44:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b47:	8b 30                	mov    (%eax),%esi
  800b49:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b4e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b53:	eb 13                	jmp    800b68 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b55:	89 ca                	mov    %ecx,%edx
  800b57:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5a:	e8 63 fc ff ff       	call   8007c2 <getuint>
  800b5f:	89 c6                	mov    %eax,%esi
  800b61:	89 d7                	mov    %edx,%edi
			base = 16;
  800b63:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b68:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b6c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b73:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b77:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7b:	89 34 24             	mov    %esi,(%esp)
  800b7e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b82:	89 da                	mov    %ebx,%edx
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	e8 6c fb ff ff       	call   8006f8 <printnum>
			break;
  800b8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b8f:	e9 cd fc ff ff       	jmp    800861 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b98:	89 04 24             	mov    %eax,(%esp)
  800b9b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ba1:	e9 bb fc ff ff       	jmp    800861 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ba6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800baa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bb1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bb4:	eb 01                	jmp    800bb7 <vprintfmt+0x379>
  800bb6:	4e                   	dec    %esi
  800bb7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bbb:	75 f9                	jne    800bb6 <vprintfmt+0x378>
  800bbd:	e9 9f fc ff ff       	jmp    800861 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bc2:	83 c4 4c             	add    $0x4c,%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	83 ec 28             	sub    $0x28,%esp
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bd9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bdd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800be0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	74 30                	je     800c1b <vsnprintf+0x51>
  800beb:	85 d2                	test   %edx,%edx
  800bed:	7e 33                	jle    800c22 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bef:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c04:	c7 04 24 fc 07 80 00 	movl   $0x8007fc,(%esp)
  800c0b:	e8 2e fc ff ff       	call   80083e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c13:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c19:	eb 0c                	jmp    800c27 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c20:	eb 05                	jmp    800c27 <vsnprintf+0x5d>
  800c22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c2f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c36:	8b 45 10             	mov    0x10(%ebp),%eax
  800c39:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c44:	8b 45 08             	mov    0x8(%ebp),%eax
  800c47:	89 04 24             	mov    %eax,(%esp)
  800c4a:	e8 7b ff ff ff       	call   800bca <vsnprintf>
	va_end(ap);

	return rc;
}
  800c4f:	c9                   	leave  
  800c50:	c3                   	ret    
  800c51:	00 00                	add    %al,(%eax)
	...

00800c54 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5f:	eb 01                	jmp    800c62 <strlen+0xe>
		n++;
  800c61:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c62:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c66:	75 f9                	jne    800c61 <strlen+0xd>
		n++;
	return n;
}
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c70:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
  800c78:	eb 01                	jmp    800c7b <strnlen+0x11>
		n++;
  800c7a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c7b:	39 d0                	cmp    %edx,%eax
  800c7d:	74 06                	je     800c85 <strnlen+0x1b>
  800c7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c83:	75 f5                	jne    800c7a <strnlen+0x10>
		n++;
	return n;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	53                   	push   %ebx
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c91:	ba 00 00 00 00       	mov    $0x0,%edx
  800c96:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c99:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c9c:	42                   	inc    %edx
  800c9d:	84 c9                	test   %cl,%cl
  800c9f:	75 f5                	jne    800c96 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 08             	sub    $0x8,%esp
  800cab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cae:	89 1c 24             	mov    %ebx,(%esp)
  800cb1:	e8 9e ff ff ff       	call   800c54 <strlen>
	strcpy(dst + len, src);
  800cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cbd:	01 d8                	add    %ebx,%eax
  800cbf:	89 04 24             	mov    %eax,(%esp)
  800cc2:	e8 c0 ff ff ff       	call   800c87 <strcpy>
	return dst;
}
  800cc7:	89 d8                	mov    %ebx,%eax
  800cc9:	83 c4 08             	add    $0x8,%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cda:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce2:	eb 0c                	jmp    800cf0 <strncpy+0x21>
		*dst++ = *src;
  800ce4:	8a 1a                	mov    (%edx),%bl
  800ce6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ce9:	80 3a 01             	cmpb   $0x1,(%edx)
  800cec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cef:	41                   	inc    %ecx
  800cf0:	39 f1                	cmp    %esi,%ecx
  800cf2:	75 f0                	jne    800ce4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	8b 75 08             	mov    0x8(%ebp),%esi
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d06:	85 d2                	test   %edx,%edx
  800d08:	75 0a                	jne    800d14 <strlcpy+0x1c>
  800d0a:	89 f0                	mov    %esi,%eax
  800d0c:	eb 1a                	jmp    800d28 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d0e:	88 18                	mov    %bl,(%eax)
  800d10:	40                   	inc    %eax
  800d11:	41                   	inc    %ecx
  800d12:	eb 02                	jmp    800d16 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d14:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800d16:	4a                   	dec    %edx
  800d17:	74 0a                	je     800d23 <strlcpy+0x2b>
  800d19:	8a 19                	mov    (%ecx),%bl
  800d1b:	84 db                	test   %bl,%bl
  800d1d:	75 ef                	jne    800d0e <strlcpy+0x16>
  800d1f:	89 c2                	mov    %eax,%edx
  800d21:	eb 02                	jmp    800d25 <strlcpy+0x2d>
  800d23:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d25:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d28:	29 f0                	sub    %esi,%eax
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d34:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d37:	eb 02                	jmp    800d3b <strcmp+0xd>
		p++, q++;
  800d39:	41                   	inc    %ecx
  800d3a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d3b:	8a 01                	mov    (%ecx),%al
  800d3d:	84 c0                	test   %al,%al
  800d3f:	74 04                	je     800d45 <strcmp+0x17>
  800d41:	3a 02                	cmp    (%edx),%al
  800d43:	74 f4                	je     800d39 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d45:	0f b6 c0             	movzbl %al,%eax
  800d48:	0f b6 12             	movzbl (%edx),%edx
  800d4b:	29 d0                	sub    %edx,%eax
}
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	53                   	push   %ebx
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d5c:	eb 03                	jmp    800d61 <strncmp+0x12>
		n--, p++, q++;
  800d5e:	4a                   	dec    %edx
  800d5f:	40                   	inc    %eax
  800d60:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d61:	85 d2                	test   %edx,%edx
  800d63:	74 14                	je     800d79 <strncmp+0x2a>
  800d65:	8a 18                	mov    (%eax),%bl
  800d67:	84 db                	test   %bl,%bl
  800d69:	74 04                	je     800d6f <strncmp+0x20>
  800d6b:	3a 19                	cmp    (%ecx),%bl
  800d6d:	74 ef                	je     800d5e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d6f:	0f b6 00             	movzbl (%eax),%eax
  800d72:	0f b6 11             	movzbl (%ecx),%edx
  800d75:	29 d0                	sub    %edx,%eax
  800d77:	eb 05                	jmp    800d7e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d8a:	eb 05                	jmp    800d91 <strchr+0x10>
		if (*s == c)
  800d8c:	38 ca                	cmp    %cl,%dl
  800d8e:	74 0c                	je     800d9c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d90:	40                   	inc    %eax
  800d91:	8a 10                	mov    (%eax),%dl
  800d93:	84 d2                	test   %dl,%dl
  800d95:	75 f5                	jne    800d8c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800da7:	eb 05                	jmp    800dae <strfind+0x10>
		if (*s == c)
  800da9:	38 ca                	cmp    %cl,%dl
  800dab:	74 07                	je     800db4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800dad:	40                   	inc    %eax
  800dae:	8a 10                	mov    (%eax),%dl
  800db0:	84 d2                	test   %dl,%dl
  800db2:	75 f5                	jne    800da9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dc5:	85 c9                	test   %ecx,%ecx
  800dc7:	74 30                	je     800df9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dcf:	75 25                	jne    800df6 <memset+0x40>
  800dd1:	f6 c1 03             	test   $0x3,%cl
  800dd4:	75 20                	jne    800df6 <memset+0x40>
		c &= 0xFF;
  800dd6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dd9:	89 d3                	mov    %edx,%ebx
  800ddb:	c1 e3 08             	shl    $0x8,%ebx
  800dde:	89 d6                	mov    %edx,%esi
  800de0:	c1 e6 18             	shl    $0x18,%esi
  800de3:	89 d0                	mov    %edx,%eax
  800de5:	c1 e0 10             	shl    $0x10,%eax
  800de8:	09 f0                	or     %esi,%eax
  800dea:	09 d0                	or     %edx,%eax
  800dec:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dee:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800df1:	fc                   	cld    
  800df2:	f3 ab                	rep stos %eax,%es:(%edi)
  800df4:	eb 03                	jmp    800df9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800df6:	fc                   	cld    
  800df7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800df9:	89 f8                	mov    %edi,%eax
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e0e:	39 c6                	cmp    %eax,%esi
  800e10:	73 34                	jae    800e46 <memmove+0x46>
  800e12:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e15:	39 d0                	cmp    %edx,%eax
  800e17:	73 2d                	jae    800e46 <memmove+0x46>
		s += n;
		d += n;
  800e19:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e1c:	f6 c2 03             	test   $0x3,%dl
  800e1f:	75 1b                	jne    800e3c <memmove+0x3c>
  800e21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e27:	75 13                	jne    800e3c <memmove+0x3c>
  800e29:	f6 c1 03             	test   $0x3,%cl
  800e2c:	75 0e                	jne    800e3c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e2e:	83 ef 04             	sub    $0x4,%edi
  800e31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e34:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e37:	fd                   	std    
  800e38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3a:	eb 07                	jmp    800e43 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e3c:	4f                   	dec    %edi
  800e3d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e40:	fd                   	std    
  800e41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e43:	fc                   	cld    
  800e44:	eb 20                	jmp    800e66 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e4c:	75 13                	jne    800e61 <memmove+0x61>
  800e4e:	a8 03                	test   $0x3,%al
  800e50:	75 0f                	jne    800e61 <memmove+0x61>
  800e52:	f6 c1 03             	test   $0x3,%cl
  800e55:	75 0a                	jne    800e61 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e57:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e5a:	89 c7                	mov    %eax,%edi
  800e5c:	fc                   	cld    
  800e5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e5f:	eb 05                	jmp    800e66 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e61:	89 c7                	mov    %eax,%edi
  800e63:	fc                   	cld    
  800e64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e70:	8b 45 10             	mov    0x10(%ebp),%eax
  800e73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	89 04 24             	mov    %eax,(%esp)
  800e84:	e8 77 ff ff ff       	call   800e00 <memmove>
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9f:	eb 16                	jmp    800eb7 <memcmp+0x2c>
		if (*s1 != *s2)
  800ea1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ea4:	42                   	inc    %edx
  800ea5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ea9:	38 c8                	cmp    %cl,%al
  800eab:	74 0a                	je     800eb7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ead:	0f b6 c0             	movzbl %al,%eax
  800eb0:	0f b6 c9             	movzbl %cl,%ecx
  800eb3:	29 c8                	sub    %ecx,%eax
  800eb5:	eb 09                	jmp    800ec0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eb7:	39 da                	cmp    %ebx,%edx
  800eb9:	75 e6                	jne    800ea1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ed3:	eb 05                	jmp    800eda <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed5:	38 08                	cmp    %cl,(%eax)
  800ed7:	74 05                	je     800ede <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ed9:	40                   	inc    %eax
  800eda:	39 d0                	cmp    %edx,%eax
  800edc:	72 f7                	jb     800ed5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eec:	eb 01                	jmp    800eef <strtol+0xf>
		s++;
  800eee:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eef:	8a 02                	mov    (%edx),%al
  800ef1:	3c 20                	cmp    $0x20,%al
  800ef3:	74 f9                	je     800eee <strtol+0xe>
  800ef5:	3c 09                	cmp    $0x9,%al
  800ef7:	74 f5                	je     800eee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ef9:	3c 2b                	cmp    $0x2b,%al
  800efb:	75 08                	jne    800f05 <strtol+0x25>
		s++;
  800efd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800efe:	bf 00 00 00 00       	mov    $0x0,%edi
  800f03:	eb 13                	jmp    800f18 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f05:	3c 2d                	cmp    $0x2d,%al
  800f07:	75 0a                	jne    800f13 <strtol+0x33>
		s++, neg = 1;
  800f09:	8d 52 01             	lea    0x1(%edx),%edx
  800f0c:	bf 01 00 00 00       	mov    $0x1,%edi
  800f11:	eb 05                	jmp    800f18 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f18:	85 db                	test   %ebx,%ebx
  800f1a:	74 05                	je     800f21 <strtol+0x41>
  800f1c:	83 fb 10             	cmp    $0x10,%ebx
  800f1f:	75 28                	jne    800f49 <strtol+0x69>
  800f21:	8a 02                	mov    (%edx),%al
  800f23:	3c 30                	cmp    $0x30,%al
  800f25:	75 10                	jne    800f37 <strtol+0x57>
  800f27:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f2b:	75 0a                	jne    800f37 <strtol+0x57>
		s += 2, base = 16;
  800f2d:	83 c2 02             	add    $0x2,%edx
  800f30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f35:	eb 12                	jmp    800f49 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f37:	85 db                	test   %ebx,%ebx
  800f39:	75 0e                	jne    800f49 <strtol+0x69>
  800f3b:	3c 30                	cmp    $0x30,%al
  800f3d:	75 05                	jne    800f44 <strtol+0x64>
		s++, base = 8;
  800f3f:	42                   	inc    %edx
  800f40:	b3 08                	mov    $0x8,%bl
  800f42:	eb 05                	jmp    800f49 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f44:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f50:	8a 0a                	mov    (%edx),%cl
  800f52:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f55:	80 fb 09             	cmp    $0x9,%bl
  800f58:	77 08                	ja     800f62 <strtol+0x82>
			dig = *s - '0';
  800f5a:	0f be c9             	movsbl %cl,%ecx
  800f5d:	83 e9 30             	sub    $0x30,%ecx
  800f60:	eb 1e                	jmp    800f80 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f62:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f65:	80 fb 19             	cmp    $0x19,%bl
  800f68:	77 08                	ja     800f72 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f6a:	0f be c9             	movsbl %cl,%ecx
  800f6d:	83 e9 57             	sub    $0x57,%ecx
  800f70:	eb 0e                	jmp    800f80 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f72:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f75:	80 fb 19             	cmp    $0x19,%bl
  800f78:	77 12                	ja     800f8c <strtol+0xac>
			dig = *s - 'A' + 10;
  800f7a:	0f be c9             	movsbl %cl,%ecx
  800f7d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f80:	39 f1                	cmp    %esi,%ecx
  800f82:	7d 0c                	jge    800f90 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f84:	42                   	inc    %edx
  800f85:	0f af c6             	imul   %esi,%eax
  800f88:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f8a:	eb c4                	jmp    800f50 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f8c:	89 c1                	mov    %eax,%ecx
  800f8e:	eb 02                	jmp    800f92 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f90:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f96:	74 05                	je     800f9d <strtol+0xbd>
		*endptr = (char *) s;
  800f98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f9b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f9d:	85 ff                	test   %edi,%edi
  800f9f:	74 04                	je     800fa5 <strtol+0xc5>
  800fa1:	89 c8                	mov    %ecx,%eax
  800fa3:	f7 d8                	neg    %eax
}
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
	...

00800fac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fba:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	89 c7                	mov    %eax,%edi
  800fc1:	89 c6                	mov    %eax,%esi
  800fc3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_cgetc>:

int
sys_cgetc(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fda:	89 d1                	mov    %edx,%ecx
  800fdc:	89 d3                	mov    %edx,%ebx
  800fde:	89 d7                	mov    %edx,%edi
  800fe0:	89 d6                	mov    %edx,%esi
  800fe2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ffc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fff:	89 cb                	mov    %ecx,%ebx
  801001:	89 cf                	mov    %ecx,%edi
  801003:	89 ce                	mov    %ecx,%esi
  801005:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	7e 28                	jle    801033 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801016:	00 
  801017:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  80101e:	00 
  80101f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801026:	00 
  801027:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  80102e:	e8 b1 f5 ff ff       	call   8005e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801033:	83 c4 2c             	add    $0x2c,%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801041:	ba 00 00 00 00       	mov    $0x0,%edx
  801046:	b8 02 00 00 00       	mov    $0x2,%eax
  80104b:	89 d1                	mov    %edx,%ecx
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	89 d7                	mov    %edx,%edi
  801051:	89 d6                	mov    %edx,%esi
  801053:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <sys_yield>:

void
sys_yield(void)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801060:	ba 00 00 00 00       	mov    $0x0,%edx
  801065:	b8 0a 00 00 00       	mov    $0xa,%eax
  80106a:	89 d1                	mov    %edx,%ecx
  80106c:	89 d3                	mov    %edx,%ebx
  80106e:	89 d7                	mov    %edx,%edi
  801070:	89 d6                	mov    %edx,%esi
  801072:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	be 00 00 00 00       	mov    $0x0,%esi
  801087:	b8 04 00 00 00       	mov    $0x4,%eax
  80108c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80108f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801092:	8b 55 08             	mov    0x8(%ebp),%edx
  801095:	89 f7                	mov    %esi,%edi
  801097:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801099:	85 c0                	test   %eax,%eax
  80109b:	7e 28                	jle    8010c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  8010b0:	00 
  8010b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b8:	00 
  8010b9:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  8010c0:	e8 1f f5 ff ff       	call   8005e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010c5:	83 c4 2c             	add    $0x2c,%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010db:	8b 75 18             	mov    0x18(%ebp),%esi
  8010de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	7e 28                	jle    801118 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  801103:	00 
  801104:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80110b:	00 
  80110c:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  801113:	e8 cc f4 ff ff       	call   8005e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801118:	83 c4 2c             	add    $0x2c,%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	53                   	push   %ebx
  801126:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801129:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112e:	b8 06 00 00 00       	mov    $0x6,%eax
  801133:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801136:	8b 55 08             	mov    0x8(%ebp),%edx
  801139:	89 df                	mov    %ebx,%edi
  80113b:	89 de                	mov    %ebx,%esi
  80113d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80113f:	85 c0                	test   %eax,%eax
  801141:	7e 28                	jle    80116b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801143:	89 44 24 10          	mov    %eax,0x10(%esp)
  801147:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80114e:	00 
  80114f:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80115e:	00 
  80115f:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  801166:	e8 79 f4 ff ff       	call   8005e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80116b:	83 c4 2c             	add    $0x2c,%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801181:	b8 08 00 00 00       	mov    $0x8,%eax
  801186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801189:	8b 55 08             	mov    0x8(%ebp),%edx
  80118c:	89 df                	mov    %ebx,%edi
  80118e:	89 de                	mov    %ebx,%esi
  801190:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801192:	85 c0                	test   %eax,%eax
  801194:	7e 28                	jle    8011be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801196:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b1:	00 
  8011b2:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  8011b9:	e8 26 f4 ff ff       	call   8005e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011be:	83 c4 2c             	add    $0x2c,%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8011d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011df:	89 df                	mov    %ebx,%edi
  8011e1:	89 de                	mov    %ebx,%esi
  8011e3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	7e 28                	jle    801211 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011f4:	00 
  8011f5:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  8011fc:	00 
  8011fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801204:	00 
  801205:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  80120c:	e8 d3 f3 ff ff       	call   8005e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801211:	83 c4 2c             	add    $0x2c,%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121f:	be 00 00 00 00       	mov    $0x0,%esi
  801224:	b8 0b 00 00 00       	mov    $0xb,%eax
  801229:	8b 7d 14             	mov    0x14(%ebp),%edi
  80122c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	8b 55 08             	mov    0x8(%ebp),%edx
  801235:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801245:	b9 00 00 00 00       	mov    $0x0,%ecx
  80124a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80124f:	8b 55 08             	mov    0x8(%ebp),%edx
  801252:	89 cb                	mov    %ecx,%ebx
  801254:	89 cf                	mov    %ecx,%edi
  801256:	89 ce                	mov    %ecx,%esi
  801258:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80125a:	85 c0                	test   %eax,%eax
  80125c:	7e 28                	jle    801286 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801262:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801269:	00 
  80126a:	c7 44 24 08 24 19 80 	movl   $0x801924,0x8(%esp)
  801271:	00 
  801272:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801279:	00 
  80127a:	c7 04 24 41 19 80 00 	movl   $0x801941,(%esp)
  801281:	e8 5e f3 ff ff       	call   8005e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801286:	83 c4 2c             	add    $0x2c,%esp
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5f                   	pop    %edi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    
	...

00801290 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  801297:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80129e:	75 6f                	jne    80130f <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8012a0:	e8 96 fd ff ff       	call   80103b <sys_getenvid>
  8012a5:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8012a7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012ae:	00 
  8012af:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012b6:	ee 
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 ba fd ff ff       	call   801079 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	79 1c                	jns    8012df <set_pgfault_handler+0x4f>
  8012c3:	c7 44 24 08 50 19 80 	movl   $0x801950,0x8(%esp)
  8012ca:	00 
  8012cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d2:	00 
  8012d3:	c7 04 24 ac 19 80 00 	movl   $0x8019ac,(%esp)
  8012da:	e8 05 f3 ff ff       	call   8005e4 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8012df:	c7 44 24 04 20 13 80 	movl   $0x801320,0x4(%esp)
  8012e6:	00 
  8012e7:	89 1c 24             	mov    %ebx,(%esp)
  8012ea:	e8 d7 fe ff ff       	call   8011c6 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	79 1c                	jns    80130f <set_pgfault_handler+0x7f>
  8012f3:	c7 44 24 08 78 19 80 	movl   $0x801978,0x8(%esp)
  8012fa:	00 
  8012fb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801302:	00 
  801303:	c7 04 24 ac 19 80 00 	movl   $0x8019ac,(%esp)
  80130a:	e8 d5 f2 ff ff       	call   8005e4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80130f:	8b 45 08             	mov    0x8(%ebp),%eax
  801312:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801317:	83 c4 14             	add    $0x14,%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    
  80131d:	00 00                	add    %al,(%eax)
	...

00801320 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801320:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801321:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801326:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801328:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80132b:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  80132f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  801334:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  801338:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80133a:	83 c4 08             	add    $0x8,%esp
	popal
  80133d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  80133e:	83 c4 04             	add    $0x4,%esp
	popfl
  801341:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  801342:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801345:	c3                   	ret    
	...

00801348 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801348:	55                   	push   %ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	83 ec 10             	sub    $0x10,%esp
  80134e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801352:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80135a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80135e:	89 cd                	mov    %ecx,%ebp
  801360:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801364:	85 c0                	test   %eax,%eax
  801366:	75 2c                	jne    801394 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801368:	39 f9                	cmp    %edi,%ecx
  80136a:	77 68                	ja     8013d4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80136c:	85 c9                	test   %ecx,%ecx
  80136e:	75 0b                	jne    80137b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801370:	b8 01 00 00 00       	mov    $0x1,%eax
  801375:	31 d2                	xor    %edx,%edx
  801377:	f7 f1                	div    %ecx
  801379:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	89 f8                	mov    %edi,%eax
  80137f:	f7 f1                	div    %ecx
  801381:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801383:	89 f0                	mov    %esi,%eax
  801385:	f7 f1                	div    %ecx
  801387:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801389:	89 f0                	mov    %esi,%eax
  80138b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801394:	39 f8                	cmp    %edi,%eax
  801396:	77 2c                	ja     8013c4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801398:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80139b:	83 f6 1f             	xor    $0x1f,%esi
  80139e:	75 4c                	jne    8013ec <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013a0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013a2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013a7:	72 0a                	jb     8013b3 <__udivdi3+0x6b>
  8013a9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8013ad:	0f 87 ad 00 00 00    	ja     801460 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013b3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013b8:	89 f0                	mov    %esi,%eax
  8013ba:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	5e                   	pop    %esi
  8013c0:	5f                   	pop    %edi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    
  8013c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8013c4:	31 ff                	xor    %edi,%edi
  8013c6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013c8:	89 f0                	mov    %esi,%eax
  8013ca:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	5e                   	pop    %esi
  8013d0:	5f                   	pop    %edi
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    
  8013d3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013d4:	89 fa                	mov    %edi,%edx
  8013d6:	89 f0                	mov    %esi,%eax
  8013d8:	f7 f1                	div    %ecx
  8013da:	89 c6                	mov    %eax,%esi
  8013dc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013de:	89 f0                	mov    %esi,%eax
  8013e0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	5e                   	pop    %esi
  8013e6:	5f                   	pop    %edi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    
  8013e9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e0                	shl    %cl,%eax
  8013f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8013f4:	b8 20 00 00 00       	mov    $0x20,%eax
  8013f9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8013fb:	89 ea                	mov    %ebp,%edx
  8013fd:	88 c1                	mov    %al,%cl
  8013ff:	d3 ea                	shr    %cl,%edx
  801401:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801405:	09 ca                	or     %ecx,%edx
  801407:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80140b:	89 f1                	mov    %esi,%ecx
  80140d:	d3 e5                	shl    %cl,%ebp
  80140f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801413:	89 fd                	mov    %edi,%ebp
  801415:	88 c1                	mov    %al,%cl
  801417:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801419:	89 fa                	mov    %edi,%edx
  80141b:	89 f1                	mov    %esi,%ecx
  80141d:	d3 e2                	shl    %cl,%edx
  80141f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801423:	88 c1                	mov    %al,%cl
  801425:	d3 ef                	shr    %cl,%edi
  801427:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801429:	89 f8                	mov    %edi,%eax
  80142b:	89 ea                	mov    %ebp,%edx
  80142d:	f7 74 24 08          	divl   0x8(%esp)
  801431:	89 d1                	mov    %edx,%ecx
  801433:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801435:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801439:	39 d1                	cmp    %edx,%ecx
  80143b:	72 17                	jb     801454 <__udivdi3+0x10c>
  80143d:	74 09                	je     801448 <__udivdi3+0x100>
  80143f:	89 fe                	mov    %edi,%esi
  801441:	31 ff                	xor    %edi,%edi
  801443:	e9 41 ff ff ff       	jmp    801389 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801448:	8b 54 24 04          	mov    0x4(%esp),%edx
  80144c:	89 f1                	mov    %esi,%ecx
  80144e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801450:	39 c2                	cmp    %eax,%edx
  801452:	73 eb                	jae    80143f <__udivdi3+0xf7>
		{
		  q0--;
  801454:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801457:	31 ff                	xor    %edi,%edi
  801459:	e9 2b ff ff ff       	jmp    801389 <__udivdi3+0x41>
  80145e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801460:	31 f6                	xor    %esi,%esi
  801462:	e9 22 ff ff ff       	jmp    801389 <__udivdi3+0x41>
	...

00801468 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801468:	55                   	push   %ebp
  801469:	57                   	push   %edi
  80146a:	56                   	push   %esi
  80146b:	83 ec 20             	sub    $0x20,%esp
  80146e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801472:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801476:	89 44 24 14          	mov    %eax,0x14(%esp)
  80147a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80147e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801482:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801486:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801488:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80148a:	85 ed                	test   %ebp,%ebp
  80148c:	75 16                	jne    8014a4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80148e:	39 f1                	cmp    %esi,%ecx
  801490:	0f 86 a6 00 00 00    	jbe    80153c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801496:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801498:	89 d0                	mov    %edx,%eax
  80149a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80149c:	83 c4 20             	add    $0x20,%esp
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
  8014a3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014a4:	39 f5                	cmp    %esi,%ebp
  8014a6:	0f 87 ac 00 00 00    	ja     801558 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8014ac:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8014af:	83 f0 1f             	xor    $0x1f,%eax
  8014b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b6:	0f 84 a8 00 00 00    	je     801564 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8014bc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014c0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8014c2:	bf 20 00 00 00       	mov    $0x20,%edi
  8014c7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8014cb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014cf:	89 f9                	mov    %edi,%ecx
  8014d1:	d3 e8                	shr    %cl,%eax
  8014d3:	09 e8                	or     %ebp,%eax
  8014d5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8014d9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014dd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014e1:	d3 e0                	shl    %cl,%eax
  8014e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8014e7:	89 f2                	mov    %esi,%edx
  8014e9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8014eb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014ef:	d3 e0                	shl    %cl,%eax
  8014f1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8014f5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014f9:	89 f9                	mov    %edi,%ecx
  8014fb:	d3 e8                	shr    %cl,%eax
  8014fd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8014ff:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801501:	89 f2                	mov    %esi,%edx
  801503:	f7 74 24 18          	divl   0x18(%esp)
  801507:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801509:	f7 64 24 0c          	mull   0xc(%esp)
  80150d:	89 c5                	mov    %eax,%ebp
  80150f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801511:	39 d6                	cmp    %edx,%esi
  801513:	72 67                	jb     80157c <__umoddi3+0x114>
  801515:	74 75                	je     80158c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801517:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80151b:	29 e8                	sub    %ebp,%eax
  80151d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80151f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801523:	d3 e8                	shr    %cl,%eax
  801525:	89 f2                	mov    %esi,%edx
  801527:	89 f9                	mov    %edi,%ecx
  801529:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80152b:	09 d0                	or     %edx,%eax
  80152d:	89 f2                	mov    %esi,%edx
  80152f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801533:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801535:	83 c4 20             	add    $0x20,%esp
  801538:	5e                   	pop    %esi
  801539:	5f                   	pop    %edi
  80153a:	5d                   	pop    %ebp
  80153b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80153c:	85 c9                	test   %ecx,%ecx
  80153e:	75 0b                	jne    80154b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801540:	b8 01 00 00 00       	mov    $0x1,%eax
  801545:	31 d2                	xor    %edx,%edx
  801547:	f7 f1                	div    %ecx
  801549:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80154b:	89 f0                	mov    %esi,%eax
  80154d:	31 d2                	xor    %edx,%edx
  80154f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801551:	89 f8                	mov    %edi,%eax
  801553:	e9 3e ff ff ff       	jmp    801496 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801558:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80155a:	83 c4 20             	add    $0x20,%esp
  80155d:	5e                   	pop    %esi
  80155e:	5f                   	pop    %edi
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    
  801561:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801564:	39 f5                	cmp    %esi,%ebp
  801566:	72 04                	jb     80156c <__umoddi3+0x104>
  801568:	39 f9                	cmp    %edi,%ecx
  80156a:	77 06                	ja     801572 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80156c:	89 f2                	mov    %esi,%edx
  80156e:	29 cf                	sub    %ecx,%edi
  801570:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801572:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801574:	83 c4 20             	add    $0x20,%esp
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    
  80157b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80157c:	89 d1                	mov    %edx,%ecx
  80157e:	89 c5                	mov    %eax,%ebp
  801580:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801584:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801588:	eb 8d                	jmp    801517 <__umoddi3+0xaf>
  80158a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80158c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801590:	72 ea                	jb     80157c <__umoddi3+0x114>
  801592:	89 f1                	mov    %esi,%ecx
  801594:	eb 81                	jmp    801517 <__umoddi3+0xaf>
