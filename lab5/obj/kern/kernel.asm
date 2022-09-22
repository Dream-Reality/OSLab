
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 c0 12 00       	mov    $0x12c000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 c0 12 f0       	mov    $0xf012c000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 be 24 f0 00 	cmpl   $0x0,0xf024be80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 be 24 f0    	mov    %esi,0xf024be80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 70 80 00 00       	call   f01080d4 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 a0 87 10 f0 	movl   $0xf01087a0,(%esp)
f010007d:	e8 0c 57 00 00       	call   f010578e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 cd 56 00 00       	call   f010575b <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 28 a9 10 f0 	movl   $0xf010a928,(%esp)
f0100095:	e8 f4 56 00 00       	call   f010578e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 09 1c 00 00       	call   f0101caf <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 0b 88 10 f0 	movl   $0xf010880b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 ed 7f 00 00       	call   f01080d4 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 17 88 10 f0 	movl   $0xf0108817,(%esp)
f01000f2:	e8 97 56 00 00       	call   f010578e <cprintf>

	lapic_init();
f01000f7:	e8 f3 7f 00 00       	call   f01080ef <lapic_init>
	env_init_percpu();
f01000fc:	e8 d0 4d 00 00       	call   f0104ed1 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 a2 56 00 00       	call   f01057a8 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 c9 7f 00 00       	call   f01080d4 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 c0 24 f0    	add    $0xf024c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f0100124:	e8 6a 82 00 00       	call   f0108393 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 20 66 00 00       	call   f010674e <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100135:	e8 2a 08 00 00       	call   f0100964 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010013a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100141:	00 
f0100142:	c7 04 24 2d 88 10 f0 	movl   $0xf010882d,(%esp)
f0100149:	e8 40 56 00 00       	call   f010578e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010014e:	e8 e5 2a 00 00       	call   f0102c38 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100153:	e8 a3 4d 00 00       	call   f0104efb <env_init>
	trap_init();
f0100158:	e8 69 5a 00 00       	call   f0105bc6 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010015d:	e8 8a 7c 00 00       	call   f0107dec <mp_init>
	lapic_init();
f0100162:	e8 88 7f 00 00       	call   f01080ef <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100167:	e8 78 55 00 00       	call   f01056e4 <pic_init>
f010016c:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f0100173:	e8 1b 82 00 00       	call   f0108393 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100178:	83 3d 88 be 24 f0 07 	cmpl   $0x7,0xf024be88
f010017f:	77 24                	ja     f01001a5 <i386_init+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100181:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100188:	00 
f0100189:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0100190:	f0 
f0100191:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100198:	00 
f0100199:	c7 04 24 0b 88 10 f0 	movl   $0xf010880b,(%esp)
f01001a0:	e8 9b fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001a5:	b8 16 7d 10 f0       	mov    $0xf0107d16,%eax
f01001aa:	2d 9c 7c 10 f0       	sub    $0xf0107c9c,%eax
f01001af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001b3:	c7 44 24 04 9c 7c 10 	movl   $0xf0107c9c,0x4(%esp)
f01001ba:	f0 
f01001bb:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001c2:	e8 29 79 00 00       	call   f0107af0 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c7:	bb 20 c0 24 f0       	mov    $0xf024c020,%ebx
f01001cc:	eb 6f                	jmp    f010023d <i386_init+0x10f>
		if (c == cpus + cpunum())  // We've started already.
f01001ce:	e8 01 7f 00 00       	call   f01080d4 <cpunum>
f01001d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001da:	29 c2                	sub    %eax,%edx
f01001dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001df:	8d 04 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%eax
f01001e6:	39 c3                	cmp    %eax,%ebx
f01001e8:	74 50                	je     f010023a <i386_init+0x10c>

static void boot_aps(void);


void
i386_init(void)
f01001ea:	89 d8                	mov    %ebx,%eax
f01001ec:	2d 20 c0 24 f0       	sub    $0xf024c020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001f1:	c1 f8 02             	sar    $0x2,%eax
f01001f4:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01001f7:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f01001fa:	89 d1                	mov    %edx,%ecx
f01001fc:	c1 e1 05             	shl    $0x5,%ecx
f01001ff:	29 d1                	sub    %edx,%ecx
f0100201:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100204:	89 d1                	mov    %edx,%ecx
f0100206:	c1 e1 0e             	shl    $0xe,%ecx
f0100209:	29 d1                	sub    %edx,%ecx
f010020b:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f010020e:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100212:	c1 e0 0f             	shl    $0xf,%eax
f0100215:	05 00 d0 24 f0       	add    $0xf024d000,%eax
f010021a:	a3 84 be 24 f0       	mov    %eax,0xf024be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010021f:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100226:	00 
f0100227:	0f b6 03             	movzbl (%ebx),%eax
f010022a:	89 04 24             	mov    %eax,(%esp)
f010022d:	e8 16 80 00 00       	call   f0108248 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100232:	8b 43 04             	mov    0x4(%ebx),%eax
f0100235:	83 f8 01             	cmp    $0x1,%eax
f0100238:	75 f8                	jne    f0100232 <i386_init+0x104>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010023a:	83 c3 74             	add    $0x74,%ebx
f010023d:	a1 c4 c3 24 f0       	mov    0xf024c3c4,%eax
f0100242:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100249:	29 c2                	sub    %eax,%edx
f010024b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010024e:	8d 04 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%eax
f0100255:	39 c3                	cmp    %eax,%ebx
f0100257:	0f 82 71 ff ff ff    	jb     f01001ce <i386_init+0xa0>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010025d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100264:	00 
f0100265:	c7 04 24 c8 09 20 f0 	movl   $0xf02009c8,(%esp)
f010026c:	e8 bb 4e 00 00       	call   f010512c <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100271:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100278:	00 
f0100279:	c7 04 24 d3 af 23 f0 	movl   $0xf023afd3,(%esp)
f0100280:	e8 a7 4e 00 00       	call   f010512c <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100285:	e8 81 06 00 00       	call   f010090b <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f010028a:	e8 bf 64 00 00       	call   f010674e <sched_yield>

f010028f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010028f:	55                   	push   %ebp
f0100290:	89 e5                	mov    %esp,%ebp
f0100292:	53                   	push   %ebx
f0100293:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100296:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100299:	8b 45 0c             	mov    0xc(%ebp),%eax
f010029c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01002a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002a7:	c7 04 24 48 88 10 f0 	movl   $0xf0108848,(%esp)
f01002ae:	e8 db 54 00 00       	call   f010578e <cprintf>
	vcprintf(fmt, ap);
f01002b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ba:	89 04 24             	mov    %eax,(%esp)
f01002bd:	e8 99 54 00 00       	call   f010575b <vcprintf>
	cprintf("\n");
f01002c2:	c7 04 24 28 a9 10 f0 	movl   $0xf010a928,(%esp)
f01002c9:	e8 c0 54 00 00       	call   f010578e <cprintf>
	va_end(ap);
}
f01002ce:	83 c4 14             	add    $0x14,%esp
f01002d1:	5b                   	pop    %ebx
f01002d2:	5d                   	pop    %ebp
f01002d3:	c3                   	ret    

f01002d4 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d4:	55                   	push   %ebp
f01002d5:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d7:	ba 84 00 00 00       	mov    $0x84,%edx
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002e0:	5d                   	pop    %ebp
f01002e1:	c3                   	ret    

f01002e2 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002e2:	55                   	push   %ebp
f01002e3:	89 e5                	mov    %esp,%ebp
f01002e5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002ea:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002eb:	a8 01                	test   $0x1,%al
f01002ed:	74 08                	je     f01002f7 <serial_proc_data+0x15>
f01002ef:	b2 f8                	mov    $0xf8,%dl
f01002f1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002f2:	0f b6 c0             	movzbl %al,%eax
f01002f5:	eb 05                	jmp    f01002fc <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002fc:	5d                   	pop    %ebp
f01002fd:	c3                   	ret    

f01002fe <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fe:	55                   	push   %ebp
f01002ff:	89 e5                	mov    %esp,%ebp
f0100301:	53                   	push   %ebx
f0100302:	83 ec 04             	sub    $0x4,%esp
f0100305:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100307:	eb 29                	jmp    f0100332 <cons_intr+0x34>
		if (c == 0)
f0100309:	85 c0                	test   %eax,%eax
f010030b:	74 25                	je     f0100332 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010030d:	8b 15 24 b2 24 f0    	mov    0xf024b224,%edx
f0100313:	88 82 20 b0 24 f0    	mov    %al,-0xfdb4fe0(%edx)
f0100319:	8d 42 01             	lea    0x1(%edx),%eax
f010031c:	a3 24 b2 24 f0       	mov    %eax,0xf024b224
		if (cons.wpos == CONSBUFSIZE)
f0100321:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100326:	75 0a                	jne    f0100332 <cons_intr+0x34>
			cons.wpos = 0;
f0100328:	c7 05 24 b2 24 f0 00 	movl   $0x0,0xf024b224
f010032f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100332:	ff d3                	call   *%ebx
f0100334:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100337:	75 d0                	jne    f0100309 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100339:	83 c4 04             	add    $0x4,%esp
f010033c:	5b                   	pop    %ebx
f010033d:	5d                   	pop    %ebp
f010033e:	c3                   	ret    

f010033f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010033f:	55                   	push   %ebp
f0100340:	89 e5                	mov    %esp,%ebp
f0100342:	57                   	push   %edi
f0100343:	56                   	push   %esi
f0100344:	53                   	push   %ebx
f0100345:	83 ec 2c             	sub    $0x2c,%esp
f0100348:	89 c6                	mov    %eax,%esi
f010034a:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010034f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100354:	eb 05                	jmp    f010035b <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100356:	e8 79 ff ff ff       	call   f01002d4 <delay>
f010035b:	89 fa                	mov    %edi,%edx
f010035d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010035e:	a8 20                	test   $0x20,%al
f0100360:	75 03                	jne    f0100365 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100362:	4b                   	dec    %ebx
f0100363:	75 f1                	jne    f0100356 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100365:	89 f2                	mov    %esi,%edx
f0100367:	89 f0                	mov    %esi,%eax
f0100369:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100371:	ee                   	out    %al,(%dx)
f0100372:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100377:	bf 79 03 00 00       	mov    $0x379,%edi
f010037c:	eb 05                	jmp    f0100383 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f010037e:	e8 51 ff ff ff       	call   f01002d4 <delay>
f0100383:	89 fa                	mov    %edi,%edx
f0100385:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100386:	84 c0                	test   %al,%al
f0100388:	78 03                	js     f010038d <cons_putc+0x4e>
f010038a:	4b                   	dec    %ebx
f010038b:	75 f1                	jne    f010037e <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100392:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100395:	ee                   	out    %al,(%dx)
f0100396:	b2 7a                	mov    $0x7a,%dl
f0100398:	b0 0d                	mov    $0xd,%al
f010039a:	ee                   	out    %al,(%dx)
f010039b:	b0 08                	mov    $0x8,%al
f010039d:	ee                   	out    %al,(%dx)
{
	// if no attribute given, then use black on white
	static int Color = 0x0700;
	static int State = 0;
	static int Number = 0;
	if (!(c & ~0xFF))
f010039e:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003a4:	75 06                	jne    f01003ac <cons_putc+0x6d>
		c |= Color;
f01003a6:	0b 35 00 e0 12 f0    	or     0xf012e000,%esi
	switch (c & 0xff) {
f01003ac:	89 f2                	mov    %esi,%edx
f01003ae:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01003b4:	8d 42 f8             	lea    -0x8(%edx),%eax
f01003b7:	83 f8 13             	cmp    $0x13,%eax
f01003ba:	0f 87 ab 00 00 00    	ja     f010046b <cons_putc+0x12c>
f01003c0:	ff 24 85 80 88 10 f0 	jmp    *-0xfef7780(,%eax,4)
	case '\b':
		if (crt_pos > 0) {
f01003c7:	66 a1 34 b2 24 f0    	mov    0xf024b234,%ax
f01003cd:	66 85 c0             	test   %ax,%ax
f01003d0:	0f 84 de 03 00 00    	je     f01007b4 <cons_putc+0x475>
			crt_pos--;
f01003d6:	48                   	dec    %eax
f01003d7:	66 a3 34 b2 24 f0    	mov    %ax,0xf024b234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003dd:	0f b7 c0             	movzwl %ax,%eax
f01003e0:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01003e6:	83 ce 20             	or     $0x20,%esi
f01003e9:	8b 15 30 b2 24 f0    	mov    0xf024b230,%edx
f01003ef:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01003f3:	e9 71 03 00 00       	jmp    f0100769 <cons_putc+0x42a>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003f8:	66 83 05 34 b2 24 f0 	addw   $0x50,0xf024b234
f01003ff:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100400:	66 8b 0d 34 b2 24 f0 	mov    0xf024b234,%cx
f0100407:	bb 50 00 00 00       	mov    $0x50,%ebx
f010040c:	89 c8                	mov    %ecx,%eax
f010040e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100413:	66 f7 f3             	div    %bx
f0100416:	66 29 d1             	sub    %dx,%cx
f0100419:	66 89 0d 34 b2 24 f0 	mov    %cx,0xf024b234
f0100420:	e9 44 03 00 00       	jmp    f0100769 <cons_putc+0x42a>
		break;
	case '\t':
		cons_putc(' ');
f0100425:	b8 20 00 00 00       	mov    $0x20,%eax
f010042a:	e8 10 ff ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f010042f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100434:	e8 06 ff ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f0100439:	b8 20 00 00 00       	mov    $0x20,%eax
f010043e:	e8 fc fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f0100443:	b8 20 00 00 00       	mov    $0x20,%eax
f0100448:	e8 f2 fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f010044d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100452:	e8 e8 fe ff ff       	call   f010033f <cons_putc>
f0100457:	e9 0d 03 00 00       	jmp    f0100769 <cons_putc+0x42a>
		break;
	case '\033':
		State = 1;
f010045c:	c7 05 38 b2 24 f0 01 	movl   $0x1,0xf024b238
f0100463:	00 00 00 
f0100466:	e9 fe 02 00 00       	jmp    f0100769 <cons_putc+0x42a>
		break;
	default:
		if (State == 1){
f010046b:	83 3d 38 b2 24 f0 01 	cmpl   $0x1,0xf024b238
f0100472:	0f 85 d7 02 00 00    	jne    f010074f <cons_putc+0x410>
			switch (c&0xff){
f0100478:	83 fa 5b             	cmp    $0x5b,%edx
f010047b:	0f 84 e8 02 00 00    	je     f0100769 <cons_putc+0x42a>
f0100481:	83 fa 6d             	cmp    $0x6d,%edx
f0100484:	0f 84 5a 01 00 00    	je     f01005e4 <cons_putc+0x2a5>
f010048a:	83 fa 3b             	cmp    $0x3b,%edx
f010048d:	0f 85 a9 02 00 00    	jne    f010073c <cons_putc+0x3fd>
				case '[':
					break;
				case ';':
					switch (Number){
f0100493:	a1 3c b2 24 f0       	mov    0xf024b23c,%eax
f0100498:	83 e8 1e             	sub    $0x1e,%eax
f010049b:	83 f8 11             	cmp    $0x11,%eax
f010049e:	0f 87 31 01 00 00    	ja     f01005d5 <cons_putc+0x296>
f01004a4:	ff 24 85 d0 88 10 f0 	jmp    *-0xfef7730(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f01004ab:	81 25 00 e0 12 f0 ff 	andl   $0xfffff0ff,0xf012e000
f01004b2:	f0 ff ff 
f01004b5:	e9 1b 01 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f01004ba:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004bf:	80 e4 f0             	and    $0xf0,%ah
f01004c2:	80 cc 04             	or     $0x4,%ah
f01004c5:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01004ca:	e9 06 01 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f01004cf:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004d4:	80 e4 f0             	and    $0xf0,%ah
f01004d7:	80 cc 02             	or     $0x2,%ah
f01004da:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01004df:	e9 f1 00 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f01004e4:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004e9:	80 e4 f0             	and    $0xf0,%ah
f01004ec:	80 cc 06             	or     $0x6,%ah
f01004ef:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01004f4:	e9 dc 00 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f01004f9:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004fe:	80 e4 f0             	and    $0xf0,%ah
f0100501:	80 cc 01             	or     $0x1,%ah
f0100504:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100509:	e9 c7 00 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f010050e:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100513:	80 e4 f0             	and    $0xf0,%ah
f0100516:	80 cc 05             	or     $0x5,%ah
f0100519:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010051e:	e9 b2 00 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f0100523:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100528:	80 e4 f0             	and    $0xf0,%ah
f010052b:	80 cc 03             	or     $0x3,%ah
f010052e:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100533:	e9 9d 00 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f0100538:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010053d:	80 e4 f0             	and    $0xf0,%ah
f0100540:	80 cc 07             	or     $0x7,%ah
f0100543:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100548:	e9 88 00 00 00       	jmp    f01005d5 <cons_putc+0x296>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f010054d:	81 25 00 e0 12 f0 ff 	andl   $0xffff0fff,0xf012e000
f0100554:	0f ff ff 
f0100557:	eb 7c                	jmp    f01005d5 <cons_putc+0x296>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f0100559:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010055e:	80 e4 0f             	and    $0xf,%ah
f0100561:	80 cc 40             	or     $0x40,%ah
f0100564:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100569:	eb 6a                	jmp    f01005d5 <cons_putc+0x296>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f010056b:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100570:	80 e4 0f             	and    $0xf,%ah
f0100573:	80 cc 20             	or     $0x20,%ah
f0100576:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010057b:	eb 58                	jmp    f01005d5 <cons_putc+0x296>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f010057d:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100582:	80 e4 0f             	and    $0xf,%ah
f0100585:	80 cc 60             	or     $0x60,%ah
f0100588:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010058d:	eb 46                	jmp    f01005d5 <cons_putc+0x296>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f010058f:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100594:	80 e4 0f             	and    $0xf,%ah
f0100597:	80 cc 10             	or     $0x10,%ah
f010059a:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010059f:	eb 34                	jmp    f01005d5 <cons_putc+0x296>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f01005a1:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01005a6:	80 e4 0f             	and    $0xf,%ah
f01005a9:	80 cc 50             	or     $0x50,%ah
f01005ac:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01005b1:	eb 22                	jmp    f01005d5 <cons_putc+0x296>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f01005b3:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01005b8:	80 e4 0f             	and    $0xf,%ah
f01005bb:	80 cc 30             	or     $0x30,%ah
f01005be:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01005c3:	eb 10                	jmp    f01005d5 <cons_putc+0x296>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f01005c5:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01005ca:	80 e4 0f             	and    $0xf,%ah
f01005cd:	80 cc 70             	or     $0x70,%ah
f01005d0:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
						default:break;
					}
					Number = 0;
f01005d5:	c7 05 3c b2 24 f0 00 	movl   $0x0,0xf024b23c
f01005dc:	00 00 00 
f01005df:	e9 85 01 00 00       	jmp    f0100769 <cons_putc+0x42a>
					break;
				case 'm':
					switch (Number){
f01005e4:	a1 3c b2 24 f0       	mov    0xf024b23c,%eax
f01005e9:	83 e8 1e             	sub    $0x1e,%eax
f01005ec:	83 f8 11             	cmp    $0x11,%eax
f01005ef:	0f 87 31 01 00 00    	ja     f0100726 <cons_putc+0x3e7>
f01005f5:	ff 24 85 18 89 10 f0 	jmp    *-0xfef76e8(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f01005fc:	81 25 00 e0 12 f0 ff 	andl   $0xfffff0ff,0xf012e000
f0100603:	f0 ff ff 
f0100606:	e9 1b 01 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f010060b:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100610:	80 e4 f0             	and    $0xf0,%ah
f0100613:	80 cc 04             	or     $0x4,%ah
f0100616:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010061b:	e9 06 01 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f0100620:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100625:	80 e4 f0             	and    $0xf0,%ah
f0100628:	80 cc 02             	or     $0x2,%ah
f010062b:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100630:	e9 f1 00 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f0100635:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010063a:	80 e4 f0             	and    $0xf0,%ah
f010063d:	80 cc 06             	or     $0x6,%ah
f0100640:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100645:	e9 dc 00 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f010064a:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010064f:	80 e4 f0             	and    $0xf0,%ah
f0100652:	80 cc 01             	or     $0x1,%ah
f0100655:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010065a:	e9 c7 00 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f010065f:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100664:	80 e4 f0             	and    $0xf0,%ah
f0100667:	80 cc 05             	or     $0x5,%ah
f010066a:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010066f:	e9 b2 00 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f0100674:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100679:	80 e4 f0             	and    $0xf0,%ah
f010067c:	80 cc 03             	or     $0x3,%ah
f010067f:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100684:	e9 9d 00 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f0100689:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010068e:	80 e4 f0             	and    $0xf0,%ah
f0100691:	80 cc 07             	or     $0x7,%ah
f0100694:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100699:	e9 88 00 00 00       	jmp    f0100726 <cons_putc+0x3e7>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f010069e:	81 25 00 e0 12 f0 ff 	andl   $0xffff0fff,0xf012e000
f01006a5:	0f ff ff 
f01006a8:	eb 7c                	jmp    f0100726 <cons_putc+0x3e7>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f01006aa:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006af:	80 e4 0f             	and    $0xf,%ah
f01006b2:	80 cc 40             	or     $0x40,%ah
f01006b5:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006ba:	eb 6a                	jmp    f0100726 <cons_putc+0x3e7>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f01006bc:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006c1:	80 e4 0f             	and    $0xf,%ah
f01006c4:	80 cc 20             	or     $0x20,%ah
f01006c7:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006cc:	eb 58                	jmp    f0100726 <cons_putc+0x3e7>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f01006ce:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006d3:	80 e4 0f             	and    $0xf,%ah
f01006d6:	80 cc 60             	or     $0x60,%ah
f01006d9:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006de:	eb 46                	jmp    f0100726 <cons_putc+0x3e7>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f01006e0:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006e5:	80 e4 0f             	and    $0xf,%ah
f01006e8:	80 cc 10             	or     $0x10,%ah
f01006eb:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006f0:	eb 34                	jmp    f0100726 <cons_putc+0x3e7>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f01006f2:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006f7:	80 e4 0f             	and    $0xf,%ah
f01006fa:	80 cc 50             	or     $0x50,%ah
f01006fd:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100702:	eb 22                	jmp    f0100726 <cons_putc+0x3e7>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f0100704:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100709:	80 e4 0f             	and    $0xf,%ah
f010070c:	80 cc 30             	or     $0x30,%ah
f010070f:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100714:	eb 10                	jmp    f0100726 <cons_putc+0x3e7>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f0100716:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010071b:	80 e4 0f             	and    $0xf,%ah
f010071e:	80 cc 70             	or     $0x70,%ah
f0100721:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
						default:break;
					}
					Number = 0;
f0100726:	c7 05 3c b2 24 f0 00 	movl   $0x0,0xf024b23c
f010072d:	00 00 00 
					State = 0;
f0100730:	c7 05 38 b2 24 f0 00 	movl   $0x0,0xf024b238
f0100737:	00 00 00 
f010073a:	eb 2d                	jmp    f0100769 <cons_putc+0x42a>
					break;
				default:
					Number = Number * 10 + (c&0xff) - '0';
f010073c:	a1 3c b2 24 f0       	mov    0xf024b23c,%eax
f0100741:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100744:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
f0100748:	a3 3c b2 24 f0       	mov    %eax,0xf024b23c
f010074d:	eb 1a                	jmp    f0100769 <cons_putc+0x42a>
					break;
			}
		}
		else crt_buf[crt_pos++] = c;		/* write the character */
f010074f:	66 a1 34 b2 24 f0    	mov    0xf024b234,%ax
f0100755:	0f b7 c8             	movzwl %ax,%ecx
f0100758:	8b 15 30 b2 24 f0    	mov    0xf024b230,%edx
f010075e:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100762:	40                   	inc    %eax
f0100763:	66 a3 34 b2 24 f0    	mov    %ax,0xf024b234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100769:	66 81 3d 34 b2 24 f0 	cmpw   $0x7cf,0xf024b234
f0100770:	cf 07 
f0100772:	76 40                	jbe    f01007b4 <cons_putc+0x475>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100774:	a1 30 b2 24 f0       	mov    0xf024b230,%eax
f0100779:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100780:	00 
f0100781:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100787:	89 54 24 04          	mov    %edx,0x4(%esp)
f010078b:	89 04 24             	mov    %eax,(%esp)
f010078e:	e8 5d 73 00 00       	call   f0107af0 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100793:	8b 15 30 b2 24 f0    	mov    0xf024b230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100799:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010079e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01007a4:	40                   	inc    %eax
f01007a5:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01007aa:	75 f2                	jne    f010079e <cons_putc+0x45f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01007ac:	66 83 2d 34 b2 24 f0 	subw   $0x50,0xf024b234
f01007b3:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01007b4:	8b 0d 2c b2 24 f0    	mov    0xf024b22c,%ecx
f01007ba:	b0 0e                	mov    $0xe,%al
f01007bc:	89 ca                	mov    %ecx,%edx
f01007be:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01007bf:	66 8b 35 34 b2 24 f0 	mov    0xf024b234,%si
f01007c6:	8d 59 01             	lea    0x1(%ecx),%ebx
f01007c9:	89 f0                	mov    %esi,%eax
f01007cb:	66 c1 e8 08          	shr    $0x8,%ax
f01007cf:	89 da                	mov    %ebx,%edx
f01007d1:	ee                   	out    %al,(%dx)
f01007d2:	b0 0f                	mov    $0xf,%al
f01007d4:	89 ca                	mov    %ecx,%edx
f01007d6:	ee                   	out    %al,(%dx)
f01007d7:	89 f0                	mov    %esi,%eax
f01007d9:	89 da                	mov    %ebx,%edx
f01007db:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01007dc:	83 c4 2c             	add    $0x2c,%esp
f01007df:	5b                   	pop    %ebx
f01007e0:	5e                   	pop    %esi
f01007e1:	5f                   	pop    %edi
f01007e2:	5d                   	pop    %ebp
f01007e3:	c3                   	ret    

f01007e4 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01007e4:	55                   	push   %ebp
f01007e5:	89 e5                	mov    %esp,%ebp
f01007e7:	53                   	push   %ebx
f01007e8:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007eb:	ba 64 00 00 00       	mov    $0x64,%edx
f01007f0:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01007f1:	0f b6 c0             	movzbl %al,%eax
f01007f4:	a8 01                	test   $0x1,%al
f01007f6:	0f 84 e0 00 00 00    	je     f01008dc <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01007fc:	a8 20                	test   $0x20,%al
f01007fe:	0f 85 df 00 00 00    	jne    f01008e3 <kbd_proc_data+0xff>
f0100804:	b2 60                	mov    $0x60,%dl
f0100806:	ec                   	in     (%dx),%al
f0100807:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100809:	3c e0                	cmp    $0xe0,%al
f010080b:	75 11                	jne    f010081e <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f010080d:	83 0d 28 b2 24 f0 40 	orl    $0x40,0xf024b228
		return 0;
f0100814:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100819:	e9 ca 00 00 00       	jmp    f01008e8 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f010081e:	84 c0                	test   %al,%al
f0100820:	79 33                	jns    f0100855 <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100822:	8b 0d 28 b2 24 f0    	mov    0xf024b228,%ecx
f0100828:	f6 c1 40             	test   $0x40,%cl
f010082b:	75 05                	jne    f0100832 <kbd_proc_data+0x4e>
f010082d:	88 c2                	mov    %al,%dl
f010082f:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100832:	0f b6 d2             	movzbl %dl,%edx
f0100835:	8a 82 60 89 10 f0    	mov    -0xfef76a0(%edx),%al
f010083b:	83 c8 40             	or     $0x40,%eax
f010083e:	0f b6 c0             	movzbl %al,%eax
f0100841:	f7 d0                	not    %eax
f0100843:	21 c1                	and    %eax,%ecx
f0100845:	89 0d 28 b2 24 f0    	mov    %ecx,0xf024b228
		return 0;
f010084b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100850:	e9 93 00 00 00       	jmp    f01008e8 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f0100855:	8b 0d 28 b2 24 f0    	mov    0xf024b228,%ecx
f010085b:	f6 c1 40             	test   $0x40,%cl
f010085e:	74 0e                	je     f010086e <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100860:	88 c2                	mov    %al,%dl
f0100862:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100865:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100868:	89 0d 28 b2 24 f0    	mov    %ecx,0xf024b228
	}

	shift |= shiftcode[data];
f010086e:	0f b6 d2             	movzbl %dl,%edx
f0100871:	0f b6 82 60 89 10 f0 	movzbl -0xfef76a0(%edx),%eax
f0100878:	0b 05 28 b2 24 f0    	or     0xf024b228,%eax
	shift ^= togglecode[data];
f010087e:	0f b6 8a 60 8a 10 f0 	movzbl -0xfef75a0(%edx),%ecx
f0100885:	31 c8                	xor    %ecx,%eax
f0100887:	a3 28 b2 24 f0       	mov    %eax,0xf024b228

	c = charcode[shift & (CTL | SHIFT)][data];
f010088c:	89 c1                	mov    %eax,%ecx
f010088e:	83 e1 03             	and    $0x3,%ecx
f0100891:	8b 0c 8d 60 8b 10 f0 	mov    -0xfef74a0(,%ecx,4),%ecx
f0100898:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010089c:	a8 08                	test   $0x8,%al
f010089e:	74 18                	je     f01008b8 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f01008a0:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01008a3:	83 fa 19             	cmp    $0x19,%edx
f01008a6:	77 05                	ja     f01008ad <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f01008a8:	83 eb 20             	sub    $0x20,%ebx
f01008ab:	eb 0b                	jmp    f01008b8 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f01008ad:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01008b0:	83 fa 19             	cmp    $0x19,%edx
f01008b3:	77 03                	ja     f01008b8 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f01008b5:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01008b8:	f7 d0                	not    %eax
f01008ba:	a8 06                	test   $0x6,%al
f01008bc:	75 2a                	jne    f01008e8 <kbd_proc_data+0x104>
f01008be:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01008c4:	75 22                	jne    f01008e8 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01008c6:	c7 04 24 70 8b 10 f0 	movl   $0xf0108b70,(%esp)
f01008cd:	e8 bc 4e 00 00       	call   f010578e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008d2:	ba 92 00 00 00       	mov    $0x92,%edx
f01008d7:	b0 03                	mov    $0x3,%al
f01008d9:	ee                   	out    %al,(%dx)
f01008da:	eb 0c                	jmp    f01008e8 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01008dc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01008e1:	eb 05                	jmp    f01008e8 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01008e3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01008e8:	89 d8                	mov    %ebx,%eax
f01008ea:	83 c4 14             	add    $0x14,%esp
f01008ed:	5b                   	pop    %ebx
f01008ee:	5d                   	pop    %ebp
f01008ef:	c3                   	ret    

f01008f0 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01008f0:	55                   	push   %ebp
f01008f1:	89 e5                	mov    %esp,%ebp
f01008f3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01008f6:	80 3d 00 b0 24 f0 00 	cmpb   $0x0,0xf024b000
f01008fd:	74 0a                	je     f0100909 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01008ff:	b8 e2 02 10 f0       	mov    $0xf01002e2,%eax
f0100904:	e8 f5 f9 ff ff       	call   f01002fe <cons_intr>
}
f0100909:	c9                   	leave  
f010090a:	c3                   	ret    

f010090b <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010090b:	55                   	push   %ebp
f010090c:	89 e5                	mov    %esp,%ebp
f010090e:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100911:	b8 e4 07 10 f0       	mov    $0xf01007e4,%eax
f0100916:	e8 e3 f9 ff ff       	call   f01002fe <cons_intr>
}
f010091b:	c9                   	leave  
f010091c:	c3                   	ret    

f010091d <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010091d:	55                   	push   %ebp
f010091e:	89 e5                	mov    %esp,%ebp
f0100920:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100923:	e8 c8 ff ff ff       	call   f01008f0 <serial_intr>
	kbd_intr();
f0100928:	e8 de ff ff ff       	call   f010090b <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010092d:	8b 15 20 b2 24 f0    	mov    0xf024b220,%edx
f0100933:	3b 15 24 b2 24 f0    	cmp    0xf024b224,%edx
f0100939:	74 22                	je     f010095d <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010093b:	0f b6 82 20 b0 24 f0 	movzbl -0xfdb4fe0(%edx),%eax
f0100942:	42                   	inc    %edx
f0100943:	89 15 20 b2 24 f0    	mov    %edx,0xf024b220
		if (cons.rpos == CONSBUFSIZE)
f0100949:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010094f:	75 11                	jne    f0100962 <cons_getc+0x45>
			cons.rpos = 0;
f0100951:	c7 05 20 b2 24 f0 00 	movl   $0x0,0xf024b220
f0100958:	00 00 00 
f010095b:	eb 05                	jmp    f0100962 <cons_getc+0x45>
		return c;
	}
	return 0;
f010095d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100962:	c9                   	leave  
f0100963:	c3                   	ret    

f0100964 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100964:	55                   	push   %ebp
f0100965:	89 e5                	mov    %esp,%ebp
f0100967:	57                   	push   %edi
f0100968:	56                   	push   %esi
f0100969:	53                   	push   %ebx
f010096a:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010096d:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100974:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010097b:	5a a5 
	if (*cp != 0xA55A) {
f010097d:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100983:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100987:	74 11                	je     f010099a <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100989:	c7 05 2c b2 24 f0 b4 	movl   $0x3b4,0xf024b22c
f0100990:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100993:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100998:	eb 16                	jmp    f01009b0 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010099a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01009a1:	c7 05 2c b2 24 f0 d4 	movl   $0x3d4,0xf024b22c
f01009a8:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01009ab:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01009b0:	8b 0d 2c b2 24 f0    	mov    0xf024b22c,%ecx
f01009b6:	b0 0e                	mov    $0xe,%al
f01009b8:	89 ca                	mov    %ecx,%edx
f01009ba:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01009bb:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01009be:	89 da                	mov    %ebx,%edx
f01009c0:	ec                   	in     (%dx),%al
f01009c1:	0f b6 f8             	movzbl %al,%edi
f01009c4:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01009c7:	b0 0f                	mov    $0xf,%al
f01009c9:	89 ca                	mov    %ecx,%edx
f01009cb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01009cc:	89 da                	mov    %ebx,%edx
f01009ce:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01009cf:	89 35 30 b2 24 f0    	mov    %esi,0xf024b230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01009d5:	0f b6 d8             	movzbl %al,%ebx
f01009d8:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01009da:	66 89 3d 34 b2 24 f0 	mov    %di,0xf024b234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01009e1:	e8 25 ff ff ff       	call   f010090b <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01009e6:	0f b7 05 e8 f1 14 f0 	movzwl 0xf014f1e8,%eax
f01009ed:	25 fd ff 00 00       	and    $0xfffd,%eax
f01009f2:	89 04 24             	mov    %eax,(%esp)
f01009f5:	e8 76 4c 00 00       	call   f0105670 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01009fa:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01009ff:	b0 00                	mov    $0x0,%al
f0100a01:	89 da                	mov    %ebx,%edx
f0100a03:	ee                   	out    %al,(%dx)
f0100a04:	b2 fb                	mov    $0xfb,%dl
f0100a06:	b0 80                	mov    $0x80,%al
f0100a08:	ee                   	out    %al,(%dx)
f0100a09:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100a0e:	b0 0c                	mov    $0xc,%al
f0100a10:	89 ca                	mov    %ecx,%edx
f0100a12:	ee                   	out    %al,(%dx)
f0100a13:	b2 f9                	mov    $0xf9,%dl
f0100a15:	b0 00                	mov    $0x0,%al
f0100a17:	ee                   	out    %al,(%dx)
f0100a18:	b2 fb                	mov    $0xfb,%dl
f0100a1a:	b0 03                	mov    $0x3,%al
f0100a1c:	ee                   	out    %al,(%dx)
f0100a1d:	b2 fc                	mov    $0xfc,%dl
f0100a1f:	b0 00                	mov    $0x0,%al
f0100a21:	ee                   	out    %al,(%dx)
f0100a22:	b2 f9                	mov    $0xf9,%dl
f0100a24:	b0 01                	mov    $0x1,%al
f0100a26:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100a27:	b2 fd                	mov    $0xfd,%dl
f0100a29:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100a2a:	3c ff                	cmp    $0xff,%al
f0100a2c:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100a30:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100a33:	a2 00 b0 24 f0       	mov    %al,0xf024b000
f0100a38:	89 da                	mov    %ebx,%edx
f0100a3a:	ec                   	in     (%dx),%al
f0100a3b:	89 ca                	mov    %ecx,%edx
f0100a3d:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100a3e:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100a42:	74 1d                	je     f0100a61 <cons_init+0xfd>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100a44:	0f b7 05 e8 f1 14 f0 	movzwl 0xf014f1e8,%eax
f0100a4b:	25 ef ff 00 00       	and    $0xffef,%eax
f0100a50:	89 04 24             	mov    %eax,(%esp)
f0100a53:	e8 18 4c 00 00       	call   f0105670 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100a58:	80 3d 00 b0 24 f0 00 	cmpb   $0x0,0xf024b000
f0100a5f:	75 0c                	jne    f0100a6d <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100a61:	c7 04 24 7c 8b 10 f0 	movl   $0xf0108b7c,(%esp)
f0100a68:	e8 21 4d 00 00       	call   f010578e <cprintf>
}
f0100a6d:	83 c4 2c             	add    $0x2c,%esp
f0100a70:	5b                   	pop    %ebx
f0100a71:	5e                   	pop    %esi
f0100a72:	5f                   	pop    %edi
f0100a73:	5d                   	pop    %ebp
f0100a74:	c3                   	ret    

f0100a75 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100a75:	55                   	push   %ebp
f0100a76:	89 e5                	mov    %esp,%ebp
f0100a78:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100a7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a7e:	e8 bc f8 ff ff       	call   f010033f <cons_putc>
}
f0100a83:	c9                   	leave  
f0100a84:	c3                   	ret    

f0100a85 <getchar>:

int
getchar(void)
{
f0100a85:	55                   	push   %ebp
f0100a86:	89 e5                	mov    %esp,%ebp
f0100a88:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100a8b:	e8 8d fe ff ff       	call   f010091d <cons_getc>
f0100a90:	85 c0                	test   %eax,%eax
f0100a92:	74 f7                	je     f0100a8b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100a94:	c9                   	leave  
f0100a95:	c3                   	ret    

f0100a96 <iscons>:

int
iscons(int fdnum)
{
f0100a96:	55                   	push   %ebp
f0100a97:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100a99:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a9e:	5d                   	pop    %ebp
f0100a9f:	c3                   	ret    

f0100aa0 <mon_stepi>:
        	return 0;
    }
}

int
mon_stepi(int argc, char **argv, struct Trapframe *tf){
f0100aa0:	55                   	push   %ebp
f0100aa1:	89 e5                	mov    %esp,%ebp
f0100aa3:	83 ec 18             	sub    $0x18,%esp
f0100aa6:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!tf){cprintf("mon_stepi: No Trapframe!\n");return 0;}
f0100aa9:	85 c0                	test   %eax,%eax
f0100aab:	75 13                	jne    f0100ac0 <mon_stepi+0x20>
f0100aad:	c7 04 24 99 8b 10 f0 	movl   $0xf0108b99,(%esp)
f0100ab4:	e8 d5 4c 00 00       	call   f010578e <cprintf>
f0100ab9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100abe:	eb 31                	jmp    f0100af1 <mon_stepi+0x51>
    switch (tf->tf_trapno){
f0100ac0:	8b 50 28             	mov    0x28(%eax),%edx
f0100ac3:	83 fa 01             	cmp    $0x1,%edx
f0100ac6:	74 13                	je     f0100adb <mon_stepi+0x3b>
f0100ac8:	83 fa 03             	cmp    $0x3,%edx
f0100acb:	75 1f                	jne    f0100aec <mon_stepi+0x4c>
    	case T_BRKPT:tf->tf_eflags|=FL_TF;return -1;
f0100acd:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
f0100ad4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ad9:	eb 16                	jmp    f0100af1 <mon_stepi+0x51>
    	case T_DEBUG:
        	if (tf->tf_eflags&FL_TF)return -1;
f0100adb:	8b 40 38             	mov    0x38(%eax),%eax
f0100ade:	25 00 01 00 00       	and    $0x100,%eax
    	default:
        	return 0;
f0100ae3:	83 f8 01             	cmp    $0x1,%eax
f0100ae6:	19 c0                	sbb    %eax,%eax
f0100ae8:	f7 d0                	not    %eax
f0100aea:	eb 05                	jmp    f0100af1 <mon_stepi+0x51>
f0100aec:	b8 00 00 00 00       	mov    $0x0,%eax
    }    
}
f0100af1:	c9                   	leave  
f0100af2:	c3                   	ret    

f0100af3 <mon_continue>:
	else cprintf(".\n");
	return 0;
}

int
mon_continue(int argc, char **argv, struct Trapframe *tf){
f0100af3:	55                   	push   %ebp
f0100af4:	89 e5                	mov    %esp,%ebp
f0100af6:	83 ec 18             	sub    $0x18,%esp
f0100af9:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!tf){cprintf("mon_continue: No Trapframe!\n");return 0;}
f0100afc:	85 c0                	test   %eax,%eax
f0100afe:	75 13                	jne    f0100b13 <mon_continue+0x20>
f0100b00:	c7 04 24 b3 8b 10 f0 	movl   $0xf0108bb3,(%esp)
f0100b07:	e8 82 4c 00 00       	call   f010578e <cprintf>
f0100b0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b11:	eb 2e                	jmp    f0100b41 <mon_continue+0x4e>
	switch (tf->tf_trapno){
f0100b13:	8b 50 28             	mov    0x28(%eax),%edx
f0100b16:	83 fa 01             	cmp    $0x1,%edx
f0100b19:	74 13                	je     f0100b2e <mon_continue+0x3b>
f0100b1b:	83 fa 03             	cmp    $0x3,%edx
f0100b1e:	75 1c                	jne    f0100b3c <mon_continue+0x49>
    	case T_BRKPT:
            tf->tf_eflags &= ~FL_TF;return -1;
f0100b20:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
f0100b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b2c:	eb 13                	jmp    f0100b41 <mon_continue+0x4e>
    	case T_DEBUG:
            tf->tf_eflags &= ~FL_TF;return -1;
f0100b2e:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
f0100b35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b3a:	eb 05                	jmp    f0100b41 <mon_continue+0x4e>
    	default:
        	return 0;
f0100b3c:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
f0100b41:	c9                   	leave  
f0100b42:	c3                   	ret    

f0100b43 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100b43:	55                   	push   %ebp
f0100b44:	89 e5                	mov    %esp,%ebp
f0100b46:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100b49:	c7 04 24 d0 8b 10 f0 	movl   $0xf0108bd0,(%esp)
f0100b50:	e8 39 4c 00 00       	call   f010578e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100b55:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100b5c:	00 
f0100b5d:	c7 04 24 28 8e 10 f0 	movl   $0xf0108e28,(%esp)
f0100b64:	e8 25 4c 00 00       	call   f010578e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100b69:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100b70:	00 
f0100b71:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100b78:	f0 
f0100b79:	c7 04 24 50 8e 10 f0 	movl   $0xf0108e50,(%esp)
f0100b80:	e8 09 4c 00 00       	call   f010578e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100b85:	c7 44 24 08 92 87 10 	movl   $0x108792,0x8(%esp)
f0100b8c:	00 
f0100b8d:	c7 44 24 04 92 87 10 	movl   $0xf0108792,0x4(%esp)
f0100b94:	f0 
f0100b95:	c7 04 24 74 8e 10 f0 	movl   $0xf0108e74,(%esp)
f0100b9c:	e8 ed 4b 00 00       	call   f010578e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100ba1:	c7 44 24 08 00 b0 24 	movl   $0x24b000,0x8(%esp)
f0100ba8:	00 
f0100ba9:	c7 44 24 04 00 b0 24 	movl   $0xf024b000,0x4(%esp)
f0100bb0:	f0 
f0100bb1:	c7 04 24 98 8e 10 f0 	movl   $0xf0108e98,(%esp)
f0100bb8:	e8 d1 4b 00 00       	call   f010578e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100bbd:	c7 44 24 08 08 d0 28 	movl   $0x28d008,0x8(%esp)
f0100bc4:	00 
f0100bc5:	c7 44 24 04 08 d0 28 	movl   $0xf028d008,0x4(%esp)
f0100bcc:	f0 
f0100bcd:	c7 04 24 bc 8e 10 f0 	movl   $0xf0108ebc,(%esp)
f0100bd4:	e8 b5 4b 00 00       	call   f010578e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100bd9:	b8 07 d4 28 f0       	mov    $0xf028d407,%eax
f0100bde:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100be3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100be8:	89 c2                	mov    %eax,%edx
f0100bea:	85 c0                	test   %eax,%eax
f0100bec:	79 06                	jns    f0100bf4 <mon_kerninfo+0xb1>
f0100bee:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100bf4:	c1 fa 0a             	sar    $0xa,%edx
f0100bf7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100bfb:	c7 04 24 e0 8e 10 f0 	movl   $0xf0108ee0,(%esp)
f0100c02:	e8 87 4b 00 00       	call   f010578e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100c07:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c0c:	c9                   	leave  
f0100c0d:	c3                   	ret    

f0100c0e <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100c0e:	55                   	push   %ebp
f0100c0f:	89 e5                	mov    %esp,%ebp
f0100c11:	56                   	push   %esi
f0100c12:	53                   	push   %ebx
f0100c13:	83 ec 10             	sub    $0x10,%esp
f0100c16:	bb 64 9b 10 f0       	mov    $0xf0109b64,%ebx
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f0100c1b:	be f4 9b 10 f0       	mov    $0xf0109bf4,%esi
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100c20:	8b 03                	mov    (%ebx),%eax
f0100c22:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c26:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100c29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c2d:	c7 04 24 e9 8b 10 f0 	movl   $0xf0108be9,(%esp)
f0100c34:	e8 55 4b 00 00       	call   f010578e <cprintf>
f0100c39:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100c3c:	39 f3                	cmp    %esi,%ebx
f0100c3e:	75 e0                	jne    f0100c20 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100c40:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c45:	83 c4 10             	add    $0x10,%esp
f0100c48:	5b                   	pop    %ebx
f0100c49:	5e                   	pop    %esi
f0100c4a:	5d                   	pop    %ebp
f0100c4b:	c3                   	ret    

f0100c4c <mon_showvirtualmemory>:

    return 0;
}

int
mon_showvirtualmemory(int argc, char **argv, struct Trapframe *tf){
f0100c4c:	55                   	push   %ebp
f0100c4d:	89 e5                	mov    %esp,%ebp
f0100c4f:	57                   	push   %edi
f0100c50:	56                   	push   %esi
f0100c51:	53                   	push   %ebx
f0100c52:	83 ec 2c             	sub    $0x2c,%esp
f0100c55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f0100c58:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100c5c:	74 11                	je     f0100c6f <mon_showvirtualmemory+0x23>
		cprintf("mon_showvvirtualmemory: The number of parameters is two.\n");
f0100c5e:	c7 04 24 0c 8f 10 f0 	movl   $0xf0108f0c,(%esp)
f0100c65:	e8 24 4b 00 00       	call   f010578e <cprintf>
		return 0;
f0100c6a:	e9 37 01 00 00       	jmp    f0100da6 <mon_showvirtualmemory+0x15a>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0100c6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c76:	00 
f0100c77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100c81:	89 04 24             	mov    %eax,(%esp)
f0100c84:	e8 47 6f 00 00       	call   f0107bd0 <strtol>
f0100c89:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0100c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c8e:	80 38 00             	cmpb   $0x0,(%eax)
f0100c91:	74 11                	je     f0100ca4 <mon_showvirtualmemory+0x58>
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
f0100c93:	c7 04 24 48 8f 10 f0 	movl   $0xf0108f48,(%esp)
f0100c9a:	e8 ef 4a 00 00       	call   f010578e <cprintf>
		return 0;
f0100c9f:	e9 02 01 00 00       	jmp    f0100da6 <mon_showvirtualmemory+0x15a>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100ca4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100cab:	00 
f0100cac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100caf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cb3:	8b 43 08             	mov    0x8(%ebx),%eax
f0100cb6:	89 04 24             	mov    %eax,(%esp)
f0100cb9:	e8 12 6f 00 00       	call   f0107bd0 <strtol>
	if (*errChar){
f0100cbe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100cc1:	80 3a 00             	cmpb   $0x0,(%edx)
f0100cc4:	74 11                	je     f0100cd7 <mon_showvirtualmemory+0x8b>
		cprintf("mon_showvvirtualmemory: The second argument is not a number.\n");
f0100cc6:	c7 04 24 88 8f 10 f0 	movl   $0xf0108f88,(%esp)
f0100ccd:	e8 bc 4a 00 00       	call   f010578e <cprintf>
		return 0;
f0100cd2:	e9 cf 00 00 00       	jmp    f0100da6 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr&0x3){
f0100cd7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0100cdd:	74 11                	je     f0100cf0 <mon_showvirtualmemory+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f0100cdf:	c7 04 24 c8 8f 10 f0 	movl   $0xf0108fc8,(%esp)
f0100ce6:	e8 a3 4a 00 00       	call   f010578e <cprintf>
		return 0;
f0100ceb:	e9 b6 00 00 00       	jmp    f0100da6 <mon_showvirtualmemory+0x15a>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100cf0:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3){
f0100cf2:	a8 03                	test   $0x3,%al
f0100cf4:	74 11                	je     f0100d07 <mon_showvirtualmemory+0xbb>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0100cf6:	c7 04 24 04 90 10 f0 	movl   $0xf0109004,(%esp)
f0100cfd:	e8 8c 4a 00 00       	call   f010578e <cprintf>
		return 0;
f0100d02:	e9 9f 00 00 00       	jmp    f0100da6 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr > EndAddr){
f0100d07:	39 c6                	cmp    %eax,%esi
f0100d09:	0f 86 88 00 00 00    	jbe    f0100d97 <mon_showvirtualmemory+0x14b>
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
f0100d0f:	c7 04 24 40 90 10 f0 	movl   $0xf0109040,(%esp)
f0100d16:	e8 73 4a 00 00       	call   f010578e <cprintf>
		return 0;
f0100d1b:	e9 86 00 00 00       	jmp    f0100da6 <mon_showvirtualmemory+0x15a>
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
		switch (c){
f0100d20:	83 fe 01             	cmp    $0x1,%esi
f0100d23:	74 2f                	je     f0100d54 <mon_showvirtualmemory+0x108>
f0100d25:	83 fe 01             	cmp    $0x1,%esi
f0100d28:	7f 06                	jg     f0100d30 <mon_showvirtualmemory+0xe4>
f0100d2a:	85 f6                	test   %esi,%esi
f0100d2c:	74 0e                	je     f0100d3c <mon_showvirtualmemory+0xf0>
f0100d2e:	eb 5e                	jmp    f0100d8e <mon_showvirtualmemory+0x142>
f0100d30:	83 fe 02             	cmp    $0x2,%esi
f0100d33:	74 33                	je     f0100d68 <mon_showvirtualmemory+0x11c>
f0100d35:	83 fe 03             	cmp    $0x3,%esi
f0100d38:	75 54                	jne    f0100d8e <mon_showvirtualmemory+0x142>
f0100d3a:	eb 40                	jmp    f0100d7c <mon_showvirtualmemory+0x130>
			case 0:cprintf("0x%08x   :0x%08x    ",Address,*(int*)Address);break;
f0100d3c:	8b 03                	mov    (%ebx),%eax
f0100d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d46:	c7 04 24 f2 8b 10 f0 	movl   $0xf0108bf2,(%esp)
f0100d4d:	e8 3c 4a 00 00       	call   f010578e <cprintf>
f0100d52:	eb 3a                	jmp    f0100d8e <mon_showvirtualmemory+0x142>
			case 1:cprintf("0x%08x    ",*(int*)Address);break;
f0100d54:	8b 03                	mov    (%ebx),%eax
f0100d56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d5a:	c7 04 24 fc 8b 10 f0 	movl   $0xf0108bfc,(%esp)
f0100d61:	e8 28 4a 00 00       	call   f010578e <cprintf>
f0100d66:	eb 26                	jmp    f0100d8e <mon_showvirtualmemory+0x142>
			case 2:cprintf("0x%08x    ",*(int*)Address);break;
f0100d68:	8b 03                	mov    (%ebx),%eax
f0100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d6e:	c7 04 24 fc 8b 10 f0 	movl   $0xf0108bfc,(%esp)
f0100d75:	e8 14 4a 00 00       	call   f010578e <cprintf>
f0100d7a:	eb 12                	jmp    f0100d8e <mon_showvirtualmemory+0x142>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
f0100d7c:	8b 03                	mov    (%ebx),%eax
f0100d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d82:	c7 04 24 6a ab 10 f0 	movl   $0xf010ab6a,(%esp)
f0100d89:	e8 00 4a 00 00       	call   f010578e <cprintf>
		}
		c = (c+1)&3;
f0100d8e:	46                   	inc    %esi
f0100d8f:	83 e6 03             	and    $0x3,%esi
	if (StartAddr > EndAddr){
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100d92:	83 c3 04             	add    $0x4,%ebx
f0100d95:	eb 07                	jmp    f0100d9e <mon_showvirtualmemory+0x152>
	}
	if (EndAddr&0x3){
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
f0100d97:	89 f3                	mov    %esi,%ebx
f0100d99:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100d9e:	39 fb                	cmp    %edi,%ebx
f0100da0:	0f 82 7a ff ff ff    	jb     f0100d20 <mon_showvirtualmemory+0xd4>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
		}
		c = (c+1)&3;
	}
	return 0;
}
f0100da6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dab:	83 c4 2c             	add    $0x2c,%esp
f0100dae:	5b                   	pop    %ebx
f0100daf:	5e                   	pop    %esi
f0100db0:	5f                   	pop    %edi
f0100db1:	5d                   	pop    %ebp
f0100db2:	c3                   	ret    

f0100db3 <mon_va2pa>:
int
mon_va2pa(int argc, char **argv, struct Trapframe *tf){
f0100db3:	55                   	push   %ebp
f0100db4:	89 e5                	mov    %esp,%ebp
f0100db6:	83 ec 28             	sub    $0x28,%esp
	if(argc!=2){
f0100db9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100dbd:	74 11                	je     f0100dd0 <mon_va2pa+0x1d>
		cprintf("mon_va2pa: The number of parameters is one.\n");
f0100dbf:	c7 04 24 94 90 10 f0 	movl   $0xf0109094,(%esp)
f0100dc6:	e8 c3 49 00 00       	call   f010578e <cprintf>
		return 0;
f0100dcb:	e9 cc 00 00 00       	jmp    f0100e9c <mon_va2pa+0xe9>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100dd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100dd7:	00 
f0100dd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100de2:	8b 40 04             	mov    0x4(%eax),%eax
f0100de5:	89 04 24             	mov    %eax,(%esp)
f0100de8:	e8 e3 6d 00 00       	call   f0107bd0 <strtol>
	if (*errChar){
f0100ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100df0:	80 3a 00             	cmpb   $0x0,(%edx)
f0100df3:	74 11                	je     f0100e06 <mon_va2pa+0x53>
		cprintf("mon_va2pa: The argument is not a number.\n");
f0100df5:	c7 04 24 c4 90 10 f0 	movl   $0xf01090c4,(%esp)
f0100dfc:	e8 8d 49 00 00       	call   f010578e <cprintf>
		return 0;
f0100e01:	e9 96 00 00 00       	jmp    f0100e9c <mon_va2pa+0xe9>
	}
	pde_t *pde = &kern_pgdir[PDX(Address)];
f0100e06:	89 c1                	mov    %eax,%ecx
f0100e08:	c1 e9 16             	shr    $0x16,%ecx
	if (*pde & PTE_P){
f0100e0b:	8b 15 8c be 24 f0    	mov    0xf024be8c,%edx
f0100e11:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0100e14:	f6 c2 01             	test   $0x1,%dl
f0100e17:	74 77                	je     f0100e90 <mon_va2pa+0xdd>
		pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0100e19:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e1f:	89 d1                	mov    %edx,%ecx
f0100e21:	c1 e9 0c             	shr    $0xc,%ecx
f0100e24:	3b 0d 88 be 24 f0    	cmp    0xf024be88,%ecx
f0100e2a:	72 20                	jb     f0100e4c <mon_va2pa+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e30:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0100e37:	f0 
f0100e38:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0100e3f:	00 
f0100e40:	c7 04 24 07 8c 10 f0 	movl   $0xf0108c07,(%esp)
f0100e47:	e8 f4 f1 ff ff       	call   f0100040 <_panic>
f0100e4c:	89 c1                	mov    %eax,%ecx
f0100e4e:	c1 e9 0c             	shr    $0xc,%ecx
f0100e51:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		if (*pte & PTE_P){
f0100e57:	8b 94 8a 00 00 00 f0 	mov    -0x10000000(%edx,%ecx,4),%edx
f0100e5e:	f6 c2 01             	test   $0x1,%dl
f0100e61:	74 1f                	je     f0100e82 <mon_va2pa+0xcf>
			cprintf("The physical address is 0x%08x.\n",PTE_ADDR(*pte)|(Address&0x3ff));
f0100e63:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100e69:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100e6e:	09 d0                	or     %edx,%eax
f0100e70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e74:	c7 04 24 f0 90 10 f0 	movl   $0xf01090f0,(%esp)
f0100e7b:	e8 0e 49 00 00       	call   f010578e <cprintf>
f0100e80:	eb 1a                	jmp    f0100e9c <mon_va2pa+0xe9>
		}
		else 
			cprintf("This is not a valid virtual address.\n");
f0100e82:	c7 04 24 14 91 10 f0 	movl   $0xf0109114,(%esp)
f0100e89:	e8 00 49 00 00       	call   f010578e <cprintf>
f0100e8e:	eb 0c                	jmp    f0100e9c <mon_va2pa+0xe9>
	}
	else 
		cprintf("This is not a valid virtual address.\n");
f0100e90:	c7 04 24 14 91 10 f0 	movl   $0xf0109114,(%esp)
f0100e97:	e8 f2 48 00 00       	call   f010578e <cprintf>
	return 0;
}
f0100e9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea1:	c9                   	leave  
f0100ea2:	c3                   	ret    

f0100ea3 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100ea3:	55                   	push   %ebp
f0100ea4:	89 e5                	mov    %esp,%ebp
f0100ea6:	57                   	push   %edi
f0100ea7:	56                   	push   %esi
f0100ea8:	53                   	push   %ebx
f0100ea9:	83 ec 6c             	sub    $0x6c,%esp
	cprintf("\033[34;45mThe parameters are: 34 and 45\n");
	cprintf("\033[35;46mThe parameters are: 35 and 46\n");
	cprintf("\033[36;47mThe parameters are: 36 and 47\n");
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
f0100eac:	c7 04 24 16 8c 10 f0 	movl   $0xf0108c16,(%esp)
f0100eb3:	e8 d6 48 00 00       	call   f010578e <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100eb8:	89 eb                	mov    %ebp,%ebx
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
		eip = *((uint32_t *) ebp + 1);
		debuginfo_eip(eip, &info);
f0100eba:	8d 7d d0             	lea    -0x30(%ebp),%edi
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100ebd:	eb 6d                	jmp    f0100f2c <mon_backtrace+0x89>
		eip = *((uint32_t *) ebp + 1);
f0100ebf:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f0100ec2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ec6:	89 34 24             	mov    %esi,(%esp)
f0100ec9:	e8 d3 60 00 00       	call   f0106fa1 <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n         %s:%d: %.*s+%d\n",
f0100ece:	89 f0                	mov    %esi,%eax
f0100ed0:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100ed3:	89 44 24 30          	mov    %eax,0x30(%esp)
f0100ed7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100eda:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100ede:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ee1:	89 44 24 28          	mov    %eax,0x28(%esp)
f0100ee5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ee8:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100eec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100eef:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100ef3:	8b 43 18             	mov    0x18(%ebx),%eax
f0100ef6:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100efa:	8b 43 14             	mov    0x14(%ebx),%eax
f0100efd:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100f01:	8b 43 10             	mov    0x10(%ebx),%eax
f0100f04:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100f08:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100f0b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100f0f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f16:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100f1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f1e:	c7 04 24 3c 91 10 f0 	movl   $0xf010913c,(%esp)
f0100f25:	e8 64 48 00 00       	call   f010578e <cprintf>
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100f2a:	8b 1b                	mov    (%ebx),%ebx
f0100f2c:	85 db                	test   %ebx,%ebx
f0100f2e:	75 8f                	jne    f0100ebf <mon_backtrace+0x1c>
				info.eip_fn_namelen,
				info.eip_fn_name,
				eip - info.eip_fn_addr);
	}
	return 0;
}
f0100f30:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f35:	83 c4 6c             	add    $0x6c,%esp
f0100f38:	5b                   	pop    %ebx
f0100f39:	5e                   	pop    %esi
f0100f3a:	5f                   	pop    %edi
f0100f3b:	5d                   	pop    %ebp
f0100f3c:	c3                   	ret    

f0100f3d <mon_pa2va>:
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100f3d:	55                   	push   %ebp
f0100f3e:	89 e5                	mov    %esp,%ebp
f0100f40:	57                   	push   %edi
f0100f41:	56                   	push   %esi
f0100f42:	53                   	push   %ebx
f0100f43:	83 ec 3c             	sub    $0x3c,%esp
	if(argc!=2){
f0100f46:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100f4a:	74 11                	je     f0100f5d <mon_pa2va+0x20>
		cprintf("mon_pa2va: The number of parameters is one.\n");
f0100f4c:	c7 04 24 8c 91 10 f0 	movl   $0xf010918c,(%esp)
f0100f53:	e8 36 48 00 00       	call   f010578e <cprintf>
		return 0;
f0100f58:	e9 34 01 00 00       	jmp    f0101091 <mon_pa2va+0x154>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100f5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f64:	00 
f0100f65:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f6f:	8b 40 04             	mov    0x4(%eax),%eax
f0100f72:	89 04 24             	mov    %eax,(%esp)
f0100f75:	e8 56 6c 00 00       	call   f0107bd0 <strtol>
f0100f7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (*errChar){
f0100f7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f80:	80 38 00             	cmpb   $0x0,(%eax)
f0100f83:	74 11                	je     f0100f96 <mon_pa2va+0x59>
		cprintf("mon_pa2va: The argument is not a number.\n");
f0100f85:	c7 04 24 bc 91 10 f0 	movl   $0xf01091bc,(%esp)
f0100f8c:	e8 fd 47 00 00       	call   f010578e <cprintf>
		return 0;
f0100f91:	e9 fb 00 00 00       	jmp    f0101091 <mon_pa2va+0x154>
		cprintf("mon_pa2va: The number of parameters is one.\n");
		return 0;
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
	if (*errChar){
f0100f96:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0100f9d:	bf 00 00 00 00       	mov    $0x0,%edi
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100fa5:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100faa:	89 45 cc             	mov    %eax,-0x34(%ebp)
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100fad:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100fb0:	c1 e6 02             	shl    $0x2,%esi
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
f0100fb3:	03 35 8c be 24 f0    	add    0xf024be8c,%esi
		if (*pde & PTE_P){
f0100fb9:	f6 06 01             	testb  $0x1,(%esi)
f0100fbc:	0f 84 a1 00 00 00    	je     f0101063 <mon_pa2va+0x126>
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100fc2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100fc5:	c1 e0 16             	shl    $0x16,%eax
f0100fc8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
f0100fd0:	8b 06                	mov    (%esi),%eax
f0100fd2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd7:	89 c2                	mov    %eax,%edx
f0100fd9:	c1 ea 0c             	shr    $0xc,%edx
f0100fdc:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f0100fe2:	72 20                	jb     f0101004 <mon_pa2va+0xc7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fe8:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0100fef:	f0 
f0100ff0:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0100ff7:	00 
f0100ff8:	c7 04 24 07 8c 10 f0 	movl   $0xf0108c07,(%esp)
f0100fff:	e8 3c f0 ff ff       	call   f0100040 <_panic>
				if (*pte & PTE_P){
f0101004:	8b 84 98 00 00 00 f0 	mov    -0x10000000(%eax,%ebx,4),%eax
f010100b:	a8 01                	test   $0x1,%al
f010100d:	74 47                	je     f0101056 <mon_pa2va+0x119>
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
f010100f:	33 45 d4             	xor    -0x2c(%ebp),%eax
f0101012:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
f0101017:	75 3d                	jne    f0101056 <mon_pa2va+0x119>
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0101019:	85 ff                	test   %edi,%edi
f010101b:	75 1d                	jne    f010103a <mon_pa2va+0xfd>
f010101d:	89 d8                	mov    %ebx,%eax
f010101f:	c1 e0 0c             	shl    $0xc,%eax
f0101022:	0b 45 d0             	or     -0x30(%ebp),%eax
f0101025:	0b 45 cc             	or     -0x34(%ebp),%eax
f0101028:	89 44 24 04          	mov    %eax,0x4(%esp)
f010102c:	c7 04 24 e8 91 10 f0 	movl   $0xf01091e8,(%esp)
f0101033:	e8 56 47 00 00       	call   f010578e <cprintf>
f0101038:	eb 1b                	jmp    f0101055 <mon_pa2va+0x118>
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f010103a:	89 d8                	mov    %ebx,%eax
f010103c:	c1 e0 0c             	shl    $0xc,%eax
f010103f:	0b 45 d0             	or     -0x30(%ebp),%eax
f0101042:	0b 45 cc             	or     -0x34(%ebp),%eax
f0101045:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101049:	c7 04 24 27 8c 10 f0 	movl   $0xf0108c27,(%esp)
f0101050:	e8 39 47 00 00       	call   f010578e <cprintf>
						cnt++;
f0101055:	47                   	inc    %edi
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
f0101056:	43                   	inc    %ebx
f0101057:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010105d:	0f 85 6d ff ff ff    	jne    f0100fd0 <mon_pa2va+0x93>
	if (*errChar){
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
f0101063:	ff 45 c8             	incl   -0x38(%ebp)
f0101066:	81 7d c8 00 04 00 00 	cmpl   $0x400,-0x38(%ebp)
f010106d:	0f 85 3a ff ff ff    	jne    f0100fad <mon_pa2va+0x70>
					}
				}
			}
		}
	}
	if (cnt == 0)
f0101073:	85 ff                	test   %edi,%edi
f0101075:	75 0e                	jne    f0101085 <mon_pa2va+0x148>
		cprintf("There is no virtual address.\n");
f0101077:	c7 04 24 2f 8c 10 f0 	movl   $0xf0108c2f,(%esp)
f010107e:	e8 0b 47 00 00       	call   f010578e <cprintf>
f0101083:	eb 0c                	jmp    f0101091 <mon_pa2va+0x154>
	else cprintf(".\n");
f0101085:	c7 04 24 4a 8c 10 f0 	movl   $0xf0108c4a,(%esp)
f010108c:	e8 fd 46 00 00       	call   f010578e <cprintf>
	return 0;
}
f0101091:	b8 00 00 00 00       	mov    $0x0,%eax
f0101096:	83 c4 3c             	add    $0x3c,%esp
f0101099:	5b                   	pop    %ebx
f010109a:	5e                   	pop    %esi
f010109b:	5f                   	pop    %edi
f010109c:	5d                   	pop    %ebp
f010109d:	c3                   	ret    

f010109e <mon_showmappings>:
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f010109e:	55                   	push   %ebp
f010109f:	89 e5                	mov    %esp,%ebp
f01010a1:	57                   	push   %edi
f01010a2:	56                   	push   %esi
f01010a3:	53                   	push   %ebx
f01010a4:	83 ec 3c             	sub    $0x3c,%esp
f01010a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f01010aa:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01010ae:	74 11                	je     f01010c1 <mon_showmappings+0x23>
		cprintf("mon_showmappings: The number of parameters is two.\n");
f01010b0:	c7 04 24 0c 92 10 f0 	movl   $0xf010920c,(%esp)
f01010b7:	e8 d2 46 00 00       	call   f010578e <cprintf>
		return 0;
f01010bc:	e9 9d 01 00 00       	jmp    f010125e <mon_showmappings+0x1c0>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f01010c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01010c8:	00 
f01010c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01010cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010d0:	8b 43 04             	mov    0x4(%ebx),%eax
f01010d3:	89 04 24             	mov    %eax,(%esp)
f01010d6:	e8 f5 6a 00 00       	call   f0107bd0 <strtol>
f01010db:	89 c6                	mov    %eax,%esi
	if (*errChar){
f01010dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010e0:	80 38 00             	cmpb   $0x0,(%eax)
f01010e3:	74 11                	je     f01010f6 <mon_showmappings+0x58>
		cprintf("mon_showmappings: The first argument is not a number.\n");
f01010e5:	c7 04 24 40 92 10 f0 	movl   $0xf0109240,(%esp)
f01010ec:	e8 9d 46 00 00       	call   f010578e <cprintf>
		return 0;
f01010f1:	e9 68 01 00 00       	jmp    f010125e <mon_showmappings+0x1c0>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f01010f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01010fd:	00 
f01010fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101101:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101105:	8b 43 08             	mov    0x8(%ebx),%eax
f0101108:	89 04 24             	mov    %eax,(%esp)
f010110b:	e8 c0 6a 00 00       	call   f0107bd0 <strtol>
	if (*errChar){
f0101110:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101113:	80 3a 00             	cmpb   $0x0,(%edx)
f0101116:	74 11                	je     f0101129 <mon_showmappings+0x8b>
		cprintf("mon_showmappings: The second argument is not a number.\n");
f0101118:	c7 04 24 78 92 10 f0 	movl   $0xf0109278,(%esp)
f010111f:	e8 6a 46 00 00       	call   f010578e <cprintf>
		return 0;
f0101124:	e9 35 01 00 00       	jmp    f010125e <mon_showmappings+0x1c0>
	}
	if (StartAddr&0x3ff){
f0101129:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f010112f:	74 11                	je     f0101142 <mon_showmappings+0xa4>
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
f0101131:	c7 04 24 b0 92 10 f0 	movl   $0xf01092b0,(%esp)
f0101138:	e8 51 46 00 00       	call   f010578e <cprintf>
		return 0;
f010113d:	e9 1c 01 00 00       	jmp    f010125e <mon_showmappings+0x1c0>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showmappings: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101142:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	}
	if (StartAddr&0x3ff){
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0101145:	a9 ff 03 00 00       	test   $0x3ff,%eax
f010114a:	74 11                	je     f010115d <mon_showmappings+0xbf>
		cprintf("mon_showmappings: The second parameter is not aligned.\n");
f010114c:	c7 04 24 e8 92 10 f0 	movl   $0xf01092e8,(%esp)
f0101153:	e8 36 46 00 00       	call   f010578e <cprintf>
		return 0;
f0101158:	e9 01 01 00 00       	jmp    f010125e <mon_showmappings+0x1c0>
	}
	if (StartAddr > EndAddr){
f010115d:	39 c6                	cmp    %eax,%esi
f010115f:	76 11                	jbe    f0101172 <mon_showmappings+0xd4>
		cprintf("mon_shopmappings: The first parameter is larger than the second parameter.\n");
f0101161:	c7 04 24 20 93 10 f0 	movl   $0xf0109320,(%esp)
f0101168:	e8 21 46 00 00       	call   f010578e <cprintf>
		return 0;
f010116d:	e9 ec 00 00 00       	jmp    f010125e <mon_showmappings+0x1c0>
	}

    cprintf(
f0101172:	c7 04 24 6c 93 10 f0 	movl   $0xf010936c,(%esp)
f0101179:	e8 10 46 00 00       	call   f010578e <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f010117e:	89 f3                	mov    %esi,%ebx
f0101180:	e9 d0 00 00 00       	jmp    f0101255 <mon_showmappings+0x1b7>
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0101185:	89 da                	mov    %ebx,%edx
f0101187:	c1 ea 16             	shr    $0x16,%edx
		if (*pde & PTE_P){
f010118a:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f010118f:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0101192:	a8 01                	test   $0x1,%al
f0101194:	0f 84 a5 00 00 00    	je     f010123f <mon_showmappings+0x1a1>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f010119a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010119f:	89 c2                	mov    %eax,%edx
f01011a1:	c1 ea 0c             	shr    $0xc,%edx
f01011a4:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f01011aa:	72 20                	jb     f01011cc <mon_showmappings+0x12e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011b0:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f01011b7:	f0 
f01011b8:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f01011bf:	00 
f01011c0:	c7 04 24 07 8c 10 f0 	movl   $0xf0108c07,(%esp)
f01011c7:	e8 74 ee ff ff       	call   f0100040 <_panic>
f01011cc:	89 da                	mov    %ebx,%edx
f01011ce:	c1 ea 0a             	shr    $0xa,%edx
f01011d1:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f01011d7:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f01011de:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if (*pte & PTE_P){
f01011e1:	8b 10                	mov    (%eax),%edx
f01011e3:	f6 c2 01             	test   $0x1,%dl
f01011e6:	74 57                	je     f010123f <mon_showmappings+0x1a1>
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f01011e8:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01011ee:	b8 08 00 00 00       	mov    $0x8,%eax
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f01011f3:	bf 08 00 00 00       	mov    $0x8,%edi
f01011f8:	89 fe                	mov    %edi,%esi
f01011fa:	29 c6                	sub    %eax,%esi
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
					permission[i] = Bit2Sign[8-i][(perm&1)];
f01011fc:	89 d1                	mov    %edx,%ecx
f01011fe:	83 e1 01             	and    $0x1,%ecx
f0101201:	8a 8c 71 44 9b 10 f0 	mov    -0xfef64bc(%ecx,%esi,2),%cl
f0101208:	88 4c 05 da          	mov    %cl,-0x26(%ebp,%eax,1)
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f010120c:	48                   	dec    %eax
f010120d:	d1 fa                	sar    %edx
f010120f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101212:	75 e4                	jne    f01011f8 <mon_showmappings+0x15a>
					permission[i] = Bit2Sign[8-i][(perm&1)];
				}
				permission[9]='\0';
f0101214:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
				cprintf("0x%08x             0x%08x             %s\n",Address,PTE_ADDR(*pte),permission);
f0101218:	8d 45 da             	lea    -0x26(%ebp),%eax
f010121b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010121f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101222:	8b 02                	mov    (%edx),%eax
f0101224:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101229:	89 44 24 08          	mov    %eax,0x8(%esp)
f010122d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101231:	c7 04 24 a0 94 10 f0 	movl   $0xf01094a0,(%esp)
f0101238:	e8 51 45 00 00       	call   f010578e <cprintf>
				continue;
f010123d:	eb 10                	jmp    f010124f <mon_showmappings+0x1b1>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
f010123f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101243:	c7 04 24 cc 94 10 f0 	movl   $0xf01094cc,(%esp)
f010124a:	e8 3f 45 00 00       	call   f010578e <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f010124f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101255:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0101258:	0f 82 27 ff ff ff    	jb     f0101185 <mon_showmappings+0xe7>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}
f010125e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101263:	83 c4 3c             	add    $0x3c,%esp
f0101266:	5b                   	pop    %ebx
f0101267:	5e                   	pop    %esi
f0101268:	5f                   	pop    %edi
f0101269:	5d                   	pop    %ebp
f010126a:	c3                   	ret    

f010126b <disassemble>:
// #include <stdlib.h>
#include <inc/string.h>

unsigned int disassemble(unsigned char *bytes, unsigned int max, int offset, char *output);

unsigned int disassemble(unsigned char *bytes, unsigned int max, int offset, char *output) {
f010126b:	55                   	push   %ebp
f010126c:	89 e5                	mov    %esp,%ebp
f010126e:	57                   	push   %edi
f010126f:	56                   	push   %esi
f0101270:	53                   	push   %ebx
f0101271:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f0101277:	8b 45 08             	mov    0x8(%ebp),%eax
f010127a:	8a 00                	mov    (%eax),%al
f010127c:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)

	INSTRUCTION *instructions= standard_instructions;
	if (opcode == 0x0F) { // Extended opcodes
f0101282:	3c 0f                	cmp    $0xf,%al
f0101284:	74 11                	je     f0101297 <disassemble+0x2c>
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f0101286:	8b 55 08             	mov    0x8(%ebp),%edx
f0101289:	42                   	inc    %edx
f010128a:	89 95 e4 fd ff ff    	mov    %edx,-0x21c(%ebp)

	INSTRUCTION *instructions= standard_instructions;
f0101290:	b9 20 e3 12 f0       	mov    $0xf012e320,%ecx
f0101295:	eb 4c                	jmp    f01012e3 <disassemble+0x78>
	if (opcode == 0x0F) { // Extended opcodes
		if (max < 2 || *bytes == 0x0F || *bytes == 0xA6 || *bytes == 0xA7 || *bytes == 0xF7 || *bytes == 0xFF) {
f0101297:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f010129b:	0f 86 4d 08 00 00    	jbe    f0101aee <disassemble+0x883>
f01012a1:	8b 55 08             	mov    0x8(%ebp),%edx
f01012a4:	8a 42 01             	mov    0x1(%edx),%al
f01012a7:	3c 0f                	cmp    $0xf,%al
f01012a9:	0f 84 39 08 00 00    	je     f0101ae8 <disassemble+0x87d>
f01012af:	3c a6                	cmp    $0xa6,%al
f01012b1:	0f 84 37 08 00 00    	je     f0101aee <disassemble+0x883>
f01012b7:	3c a7                	cmp    $0xa7,%al
f01012b9:	0f 84 2f 08 00 00    	je     f0101aee <disassemble+0x883>
f01012bf:	3c f7                	cmp    $0xf7,%al
f01012c1:	0f 84 27 08 00 00    	je     f0101aee <disassemble+0x883>
f01012c7:	3c ff                	cmp    $0xff,%al
f01012c9:	0f 84 1f 08 00 00    	je     f0101aee <disassemble+0x883>
			goto ILLEGAL;
		}

		instructions = extended_instructions;
		opcode = *bytes++;
f01012cf:	83 c2 02             	add    $0x2,%edx
f01012d2:	89 95 e4 fd ff ff    	mov    %edx,-0x21c(%ebp)
f01012d8:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)
	if (opcode == 0x0F) { // Extended opcodes
		if (max < 2 || *bytes == 0x0F || *bytes == 0xA6 || *bytes == 0xA7 || *bytes == 0xF7 || *bytes == 0xFF) {
			goto ILLEGAL;
		}

		instructions = extended_instructions;
f01012de:	b9 20 e9 13 f0       	mov    $0xf013e920,%ecx
		opcode = *bytes++;
	}

	if (!instructions[opcode].hasModRM) {
f01012e3:	0f b6 85 e3 fd ff ff 	movzbl -0x21d(%ebp),%eax
f01012ea:	89 c2                	mov    %eax,%edx
f01012ec:	c1 e2 06             	shl    $0x6,%edx
f01012ef:	01 c2                	add    %eax,%edx
f01012f1:	8d 04 50             	lea    (%eax,%edx,2),%eax
f01012f4:	8d 3c 41             	lea    (%ecx,%eax,2),%edi
f01012f7:	80 3f 00             	cmpb   $0x0,(%edi)
f01012fa:	0f 84 02 04 00 00    	je     f0101702 <disassemble+0x497>
	}

	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f0101300:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f0101306:	8a 02                	mov    (%edx),%al
f0101308:	88 c3                	mov    %al,%bl
f010130a:	c0 eb 06             	shr    $0x6,%bl
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
f010130d:	88 c2                	mov    %al,%dl
f010130f:	c0 ea 03             	shr    $0x3,%dl
f0101312:	83 e2 07             	and    $0x7,%edx
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f0101315:	83 e0 07             	and    $0x7,%eax
f0101318:	88 85 dc fd ff ff    	mov    %al,-0x224(%ebp)
f010131e:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f0101324:	46                   	inc    %esi

	switch (instructions[opcode].size) {
f0101325:	8a 47 01             	mov    0x1(%edi),%al
f0101328:	3c 14                	cmp    $0x14,%al
f010132a:	74 25                	je     f0101351 <disassemble+0xe6>
f010132c:	3c 15                	cmp    $0x15,%al
f010132e:	75 42                	jne    f0101372 <disassemble+0x107>
		case WORD:
			strcpy(R_output, register_mnemonics16[(int)modRM_reg]);
f0101330:	0f be d2             	movsbl %dl,%edx
f0101333:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101336:	8d 84 80 20 ef 14 f0 	lea    -0xfeb10e0(%eax,%eax,4),%eax
f010133d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101341:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101347:	89 04 24             	mov    %eax,(%esp)
f010134a:	e8 28 66 00 00       	call   f0107977 <strcpy>
			break;
f010134f:	eb 40                	jmp    f0101391 <disassemble+0x126>
		case BYTE:
			strcpy(R_output, register_mnemonics8[(int)modRM_reg]);
f0101351:	0f be d2             	movsbl %dl,%edx
f0101354:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101357:	8d 84 80 a0 ef 14 f0 	lea    -0xfeb1060(%eax,%eax,4),%eax
f010135e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101362:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101368:	89 04 24             	mov    %eax,(%esp)
f010136b:	e8 07 66 00 00       	call   f0107977 <strcpy>
			break;
f0101370:	eb 1f                	jmp    f0101391 <disassemble+0x126>
		default:
			strcpy(R_output, register_mnemonics32[(int)modRM_reg]);
f0101372:	0f be d2             	movsbl %dl,%edx
f0101375:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101378:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f010137f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101383:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101389:	89 04 24             	mov    %eax,(%esp)
f010138c:	e8 e6 65 00 00       	call   f0107977 <strcpy>
	}

	if (modRM_mod == 0b11) { // Register addressing mode.
f0101391:	80 fb 03             	cmp    $0x3,%bl
f0101394:	0f 85 c7 00 00 00    	jne    f0101461 <disassemble+0x1f6>
		switch (instructions[opcode].size) {
f010139a:	8a 47 01             	mov    0x1(%edi),%al
f010139d:	3c 14                	cmp    $0x14,%al
f010139f:	74 06                	je     f01013a7 <disassemble+0x13c>
f01013a1:	3c 15                	cmp    $0x15,%al
f01013a3:	75 7e                	jne    f0101423 <disassemble+0x1b8>
f01013a5:	eb 3e                	jmp    f01013e5 <disassemble+0x17a>
			case BYTE:
				//sprintf(RM_output, "%s", register_mnemonics8[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
f01013a7:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f01013ae:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01013b1:	8d 84 80 a0 ef 14 f0 	lea    -0xfeb1060(%eax,%eax,4),%eax
f01013b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013bc:	c7 44 24 08 1b a6 10 	movl   $0xf010a61b,0x8(%esp)
f01013c3:	f0 
f01013c4:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f01013cb:	00 
f01013cc:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01013d2:	89 04 24             	mov    %eax,(%esp)
f01013d5:	e8 67 64 00 00       	call   f0107841 <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f01013da:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
	if (modRM_mod == 0b11) { // Register addressing mode.
		switch (instructions[opcode].size) {
			case BYTE:
				//sprintf(RM_output, "%s", register_mnemonics8[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
				break;
f01013e0:	e9 1d 03 00 00       	jmp    f0101702 <disassemble+0x497>
			case WORD:
				//sprintf(RM_output, "%s", register_mnemonics16[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics16[(int)modRM_rm]);
f01013e5:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f01013ec:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01013ef:	8d 84 80 20 ef 14 f0 	lea    -0xfeb10e0(%eax,%eax,4),%eax
f01013f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013fa:	c7 44 24 08 1b a6 10 	movl   $0xf010a61b,0x8(%esp)
f0101401:	f0 
f0101402:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101409:	00 
f010140a:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101410:	89 04 24             	mov    %eax,(%esp)
f0101413:	e8 29 64 00 00       	call   f0107841 <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f0101418:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
				break;
			case WORD:
				//sprintf(RM_output, "%s", register_mnemonics16[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics16[(int)modRM_rm]);
				break;
f010141e:	e9 df 02 00 00       	jmp    f0101702 <disassemble+0x497>
			default:
				//sprintf(RM_output, "%s", register_mnemonics32[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics32[(int)modRM_rm]);
f0101423:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f010142a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010142d:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f0101434:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101438:	c7 44 24 08 1b a6 10 	movl   $0xf010a61b,0x8(%esp)
f010143f:	f0 
f0101440:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101447:	00 
f0101448:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010144e:	89 04 24             	mov    %eax,(%esp)
f0101451:	e8 eb 63 00 00       	call   f0107841 <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f0101456:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f010145c:	e9 a1 02 00 00       	jmp    f0101702 <disassemble+0x497>
				break;
			default:
				//sprintf(RM_output, "%s", register_mnemonics32[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics32[(int)modRM_rm]);
		}
	} else if (modRM_mod == 0b00 && modRM_rm == 0b101) { // Displacement only addressing mode.
f0101461:	84 db                	test   %bl,%bl
f0101463:	75 40                	jne    f01014a5 <disassemble+0x23a>
f0101465:	80 bd dc fd ff ff 05 	cmpb   $0x5,-0x224(%ebp)
f010146c:	75 37                	jne    f01014a5 <disassemble+0x23a>
		//sprintf(RM_output, "[0x%x]", *(int *)bytes);
		snprintf(RM_output,0xff, "[0x%x]", *(int *)bytes);
f010146e:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f0101474:	8b 42 01             	mov    0x1(%edx),%eax
f0101477:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010147b:	c7 44 24 08 4d 8c 10 	movl   $0xf0108c4d,0x8(%esp)
f0101482:	f0 
f0101483:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010148a:	00 
f010148b:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101491:	89 04 24             	mov    %eax,(%esp)
f0101494:	e8 a8 63 00 00       	call   f0107841 <snprintf>
		bytes += 4;
f0101499:	83 85 e4 fd ff ff 05 	addl   $0x5,-0x21c(%ebp)
f01014a0:	e9 5d 02 00 00       	jmp    f0101702 <disassemble+0x497>
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
f01014a5:	80 bd dc fd ff ff 04 	cmpb   $0x4,-0x224(%ebp)
f01014ac:	0f 85 fa 00 00 00    	jne    f01015ac <disassemble+0x341>
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f01014b2:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01014b8:	8a 40 01             	mov    0x1(%eax),%al
f01014bb:	88 85 dc fd ff ff    	mov    %al,-0x224(%ebp)
			char SIB_index = ((*bytes) >> 3) & 0b111; // Bits 5-3.
f01014c1:	c0 e8 03             	shr    $0x3,%al
f01014c4:	83 e0 07             	and    $0x7,%eax
f01014c7:	88 85 e2 fd ff ff    	mov    %al,-0x21e(%ebp)
			char SIB_base = (*bytes++) & 0b111; // Bits 2-0.
f01014cd:	8a 85 dc fd ff ff    	mov    -0x224(%ebp),%al
f01014d3:	83 e0 07             	and    $0x7,%eax

			if (SIB_base == 0b101 && modRM_mod == 0b00) {
f01014d6:	3c 05                	cmp    $0x5,%al
f01014d8:	75 3a                	jne    f0101514 <disassemble+0x2a9>
f01014da:	84 db                	test   %bl,%bl
f01014dc:	75 36                	jne    f0101514 <disassemble+0x2a9>
				//sprintf(RM_output, "[0x%x", *(int *)bytes);
				snprintf(RM_output,0xff, "[0x%x", *(int *)bytes);
f01014de:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f01014e4:	8b 42 02             	mov    0x2(%edx),%eax
f01014e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014eb:	c7 44 24 08 54 8c 10 	movl   $0xf0108c54,0x8(%esp)
f01014f2:	f0 
f01014f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01014fa:	00 
f01014fb:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101501:	89 04 24             	mov    %eax,(%esp)
f0101504:	e8 38 63 00 00       	call   f0107841 <snprintf>
				bytes += 4;
f0101509:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f010150f:	83 c6 06             	add    $0x6,%esi
f0101512:	eb 28                	jmp    f010153c <disassemble+0x2d1>
		bytes += 4;
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
			char SIB_index = ((*bytes) >> 3) & 0b111; // Bits 5-3.
			char SIB_base = (*bytes++) & 0b111; // Bits 2-0.
f0101514:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f010151a:	83 c6 02             	add    $0x2,%esi
			if (SIB_base == 0b101 && modRM_mod == 0b00) {
				//sprintf(RM_output, "[0x%x", *(int *)bytes);
				snprintf(RM_output,0xff, "[0x%x", *(int *)bytes);
				bytes += 4;
			} else {
				strcpy(RM_output, sib_base_mnemonics[(int)SIB_base]);
f010151d:	0f be c0             	movsbl %al,%eax
f0101520:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101523:	8d 84 80 a0 f0 14 f0 	lea    -0xfeb0f60(%eax,%eax,4),%eax
f010152a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010152e:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101534:	89 04 24             	mov    %eax,(%esp)
f0101537:	e8 3b 64 00 00       	call   f0107977 <strcpy>
			}

			if (SIB_index != 0b100) {
f010153c:	80 bd e2 fd ff ff 04 	cmpb   $0x4,-0x21e(%ebp)
f0101543:	0f 84 96 00 00 00    	je     f01015df <disassemble+0x374>
				strcat(RM_output, "+");
f0101549:	c7 44 24 04 5a 8c 10 	movl   $0xf0108c5a,0x4(%esp)
f0101550:	f0 
f0101551:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101557:	89 04 24             	mov    %eax,(%esp)
f010155a:	e8 35 64 00 00       	call   f0107994 <strcat>
				strcat(RM_output, register_mnemonics32[(int)SIB_index]);
f010155f:	0f be 85 e2 fd ff ff 	movsbl -0x21e(%ebp),%eax
f0101566:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101569:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f0101570:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101574:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f010157a:	89 14 24             	mov    %edx,(%esp)
f010157d:	e8 12 64 00 00       	call   f0107994 <strcat>
		//sprintf(RM_output, "[0x%x]", *(int *)bytes);
		snprintf(RM_output,0xff, "[0x%x]", *(int *)bytes);
		bytes += 4;
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f0101582:	8a 85 dc fd ff ff    	mov    -0x224(%ebp),%al
f0101588:	c0 e8 06             	shr    $0x6,%al
			}

			if (SIB_index != 0b100) {
				strcat(RM_output, "+");
				strcat(RM_output, register_mnemonics32[(int)SIB_index]);
				strcat(RM_output, sib_scale_mnemonics[(int)SIB_scale]);
f010158b:	0f be c0             	movsbl %al,%eax
f010158e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101591:	8d 84 80 20 f1 14 f0 	lea    -0xfeb0ee0(%eax,%eax,4),%eax
f0101598:	89 44 24 04          	mov    %eax,0x4(%esp)
f010159c:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01015a2:	89 04 24             	mov    %eax,(%esp)
f01015a5:	e8 ea 63 00 00       	call   f0107994 <strcat>
f01015aa:	eb 33                	jmp    f01015df <disassemble+0x374>
			}
		} else {
			//sprintf(RM_output, "[%s", register_mnemonics32[(int)modRM_rm]);
			snprintf(RM_output,0xf, "[%s", register_mnemonics32[(int)modRM_rm]);
f01015ac:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f01015b3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01015b6:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f01015bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015c1:	c7 44 24 08 5c 8c 10 	movl   $0xf0108c5c,0x8(%esp)
f01015c8:	f0 
f01015c9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f01015d0:	00 
f01015d1:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01015d7:	89 04 24             	mov    %eax,(%esp)
f01015da:	e8 62 62 00 00       	call   f0107841 <snprintf>
		}

		if (modRM_mod == 0b01) { // One-byte signed displacement follows addressing mode byte(s).
f01015df:	80 fb 01             	cmp    $0x1,%bl
f01015e2:	0f 85 80 00 00 00    	jne    f0101668 <disassemble+0x3fd>
			if (*bytes > 0x7F) {
f01015e8:	8a 1e                	mov    (%esi),%bl
f01015ea:	84 db                	test   %bl,%bl
f01015ec:	79 3d                	jns    f010162b <disassemble+0x3c0>
				//sprintf(RM_output + strlen(RM_output), "-0x%x]", -*(char *)bytes++);
				snprintf(RM_output + strlen(RM_output),0xff, "-0x%x]", -*(char *)bytes++);
f01015ee:	46                   	inc    %esi
f01015ef:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f01015f5:	8d b5 e9 fe ff ff    	lea    -0x117(%ebp),%esi
f01015fb:	89 34 24             	mov    %esi,(%esp)
f01015fe:	e8 41 63 00 00       	call   f0107944 <strlen>
f0101603:	0f be db             	movsbl %bl,%ebx
f0101606:	f7 db                	neg    %ebx
f0101608:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010160c:	c7 44 24 08 60 8c 10 	movl   $0xf0108c60,0x8(%esp)
f0101613:	f0 
f0101614:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010161b:	00 
f010161c:	01 f0                	add    %esi,%eax
f010161e:	89 04 24             	mov    %eax,(%esp)
f0101621:	e8 1b 62 00 00       	call   f0107841 <snprintf>
f0101626:	e9 d7 00 00 00       	jmp    f0101702 <disassemble+0x497>
			} else {
				//sprintf(RM_output + strlen(RM_output), "+0x%x]", *(char *)bytes++);
				snprintf(RM_output + strlen(RM_output),0xff, "+0x%x]", *(char *)bytes++);
f010162b:	46                   	inc    %esi
f010162c:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f0101632:	8d b5 e9 fe ff ff    	lea    -0x117(%ebp),%esi
f0101638:	89 34 24             	mov    %esi,(%esp)
f010163b:	e8 04 63 00 00       	call   f0107944 <strlen>
f0101640:	89 c2                	mov    %eax,%edx
f0101642:	0f be c3             	movsbl %bl,%eax
f0101645:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101649:	c7 44 24 08 67 8c 10 	movl   $0xf0108c67,0x8(%esp)
f0101650:	f0 
f0101651:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101658:	00 
f0101659:	01 f2                	add    %esi,%edx
f010165b:	89 14 24             	mov    %edx,(%esp)
f010165e:	e8 de 61 00 00       	call   f0107841 <snprintf>
f0101663:	e9 9a 00 00 00       	jmp    f0101702 <disassemble+0x497>
			}
		} else if (modRM_mod == 0b10) { // Four-byte signed displacement follows addressing mode byte(s).
f0101668:	80 fb 02             	cmp    $0x2,%bl
f010166b:	75 79                	jne    f01016e6 <disassemble+0x47b>
			if (*(unsigned int *)bytes > 0x7FFFFFFF) {
f010166d:	8b 1e                	mov    (%esi),%ebx
f010166f:	85 db                	test   %ebx,%ebx
f0101671:	79 36                	jns    f01016a9 <disassemble+0x43e>
				//sprintf(RM_output + strlen(RM_output), "-0x%x]", -*(int *)bytes);
				snprintf(RM_output + strlen(RM_output),0xff, "-0x%x]", -*(int *)bytes);
f0101673:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f0101679:	89 14 24             	mov    %edx,(%esp)
f010167c:	e8 c3 62 00 00       	call   f0107944 <strlen>
f0101681:	f7 db                	neg    %ebx
f0101683:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101687:	c7 44 24 08 60 8c 10 	movl   $0xf0108c60,0x8(%esp)
f010168e:	f0 
f010168f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101696:	00 
f0101697:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f010169d:	01 d0                	add    %edx,%eax
f010169f:	89 04 24             	mov    %eax,(%esp)
f01016a2:	e8 9a 61 00 00       	call   f0107841 <snprintf>
f01016a7:	eb 32                	jmp    f01016db <disassemble+0x470>
			} else {
				//sprintf(RM_output + strlen(RM_output), "+0x%x]", *(unsigned int *)bytes);
				snprintf(RM_output + strlen(RM_output),0xff, "+0x%x]", *(unsigned int *)bytes);
f01016a9:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01016af:	89 04 24             	mov    %eax,(%esp)
f01016b2:	e8 8d 62 00 00       	call   f0107944 <strlen>
f01016b7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01016bb:	c7 44 24 08 67 8c 10 	movl   $0xf0108c67,0x8(%esp)
f01016c2:	f0 
f01016c3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01016ca:	00 
f01016cb:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f01016d1:	01 d0                	add    %edx,%eax
f01016d3:	89 04 24             	mov    %eax,(%esp)
f01016d6:	e8 66 61 00 00       	call   f0107841 <snprintf>
			}

			bytes += 4;
f01016db:	83 c6 04             	add    $0x4,%esi
f01016de:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f01016e4:	eb 1c                	jmp    f0101702 <disassemble+0x497>
		} else {
			strcat(RM_output, "]");
f01016e6:	c7 44 24 04 6c 8c 10 	movl   $0xf0108c6c,0x4(%esp)
f01016ed:	f0 
f01016ee:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01016f4:	89 04 24             	mov    %eax,(%esp)
f01016f7:	e8 98 62 00 00       	call   f0107994 <strcat>
f01016fc:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
		}
	}

OUTPUT:
	modRM_mod = 0x0;
	strcpy(output, instructions[opcode].mnemonic);
f0101702:	8d 47 02             	lea    0x2(%edi),%eax
f0101705:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101709:	8b 45 14             	mov    0x14(%ebp),%eax
f010170c:	89 04 24             	mov    %eax,(%esp)
f010170f:	e8 63 62 00 00       	call   f0107977 <strcpy>
	for (int i = 0; i < instructions[opcode].argument_count; i++) {
f0101714:	be 00 00 00 00       	mov    $0x0,%esi
f0101719:	e9 ab 03 00 00       	jmp    f0101ac9 <disassemble+0x85e>
		if (i > 0) {
f010171e:	85 f6                	test   %esi,%esi
f0101720:	7e 13                	jle    f0101735 <disassemble+0x4ca>
			strcat(output, ",");
f0101722:	c7 44 24 04 6e 8c 10 	movl   $0xf0108c6e,0x4(%esp)
f0101729:	f0 
f010172a:	8b 55 14             	mov    0x14(%ebp),%edx
f010172d:	89 14 24             	mov    %edx,(%esp)
f0101730:	e8 5f 62 00 00       	call   f0107994 <strcat>
		}

		switch (instructions[opcode].arguments[i]) {
f0101735:	80 bc 37 02 01 00 00 	cmpb   $0x13,0x102(%edi,%esi,1)
f010173c:	13 
f010173d:	0f 87 85 03 00 00    	ja     f0101ac8 <disassemble+0x85d>
f0101743:	0f b6 84 37 02 01 00 	movzbl 0x102(%edi,%esi,1),%eax
f010174a:	00 
f010174b:	ff 24 85 80 9a 10 f0 	jmp    *-0xfef6580(,%eax,4)
			case RM:
				if (modRM_mod != 0b11) {
					switch (instructions[opcode].size) {
f0101752:	8a 47 01             	mov    0x1(%edi),%al
f0101755:	83 e8 14             	sub    $0x14,%eax
f0101758:	3c 05                	cmp    $0x5,%al
f010175a:	0f 87 86 00 00 00    	ja     f01017e6 <disassemble+0x57b>
f0101760:	0f b6 c0             	movzbl %al,%eax
f0101763:	ff 24 85 d0 9a 10 f0 	jmp    *-0xfef6530(,%eax,4)
						case BYTE:
							strcat(output, "BYTE PTR ");
f010176a:	c7 44 24 04 70 8c 10 	movl   $0xf0108c70,0x4(%esp)
f0101771:	f0 
f0101772:	8b 45 14             	mov    0x14(%ebp),%eax
f0101775:	89 04 24             	mov    %eax,(%esp)
f0101778:	e8 17 62 00 00       	call   f0107994 <strcat>
							break;
f010177d:	eb 67                	jmp    f01017e6 <disassemble+0x57b>
						case WORD:
							strcat(output, "WORD PTR ");
f010177f:	c7 44 24 04 7b 8c 10 	movl   $0xf0108c7b,0x4(%esp)
f0101786:	f0 
f0101787:	8b 55 14             	mov    0x14(%ebp),%edx
f010178a:	89 14 24             	mov    %edx,(%esp)
f010178d:	e8 02 62 00 00       	call   f0107994 <strcat>
							break;
f0101792:	eb 52                	jmp    f01017e6 <disassemble+0x57b>
						case DWORD:
							strcat(output, "DWORD PTR ");
f0101794:	c7 44 24 04 7a 8c 10 	movl   $0xf0108c7a,0x4(%esp)
f010179b:	f0 
f010179c:	8b 45 14             	mov    0x14(%ebp),%eax
f010179f:	89 04 24             	mov    %eax,(%esp)
f01017a2:	e8 ed 61 00 00       	call   f0107994 <strcat>
							break;
f01017a7:	eb 3d                	jmp    f01017e6 <disassemble+0x57b>
						case QWORD:
							strcat(output, "QWORD PTR ");
f01017a9:	c7 44 24 04 85 8c 10 	movl   $0xf0108c85,0x4(%esp)
f01017b0:	f0 
f01017b1:	8b 55 14             	mov    0x14(%ebp),%edx
f01017b4:	89 14 24             	mov    %edx,(%esp)
f01017b7:	e8 d8 61 00 00       	call   f0107994 <strcat>
							break;
f01017bc:	eb 28                	jmp    f01017e6 <disassemble+0x57b>
						case FWORD:
							strcat(output, "FWORD PTR ");
f01017be:	c7 44 24 04 90 8c 10 	movl   $0xf0108c90,0x4(%esp)
f01017c5:	f0 
f01017c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01017c9:	89 04 24             	mov    %eax,(%esp)
f01017cc:	e8 c3 61 00 00       	call   f0107994 <strcat>
							break;
f01017d1:	eb 13                	jmp    f01017e6 <disassemble+0x57b>
						case XMMWORD:
							strcat(output, "XMMWORD PTR ");
f01017d3:	c7 44 24 04 9b 8c 10 	movl   $0xf0108c9b,0x4(%esp)
f01017da:	f0 
f01017db:	8b 55 14             	mov    0x14(%ebp),%edx
f01017de:	89 14 24             	mov    %edx,(%esp)
f01017e1:	e8 ae 61 00 00       	call   f0107994 <strcat>
							break;
					}
				}

				strcat(output, RM_output);
f01017e6:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017f0:	8b 55 14             	mov    0x14(%ebp),%edx
f01017f3:	89 14 24             	mov    %edx,(%esp)
f01017f6:	e8 99 61 00 00       	call   f0107994 <strcat>
				break;
f01017fb:	e9 c8 02 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case R:
				strcat(output, R_output);
f0101800:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101806:	89 44 24 04          	mov    %eax,0x4(%esp)
f010180a:	8b 55 14             	mov    0x14(%ebp),%edx
f010180d:	89 14 24             	mov    %edx,(%esp)
f0101810:	e8 7f 61 00 00       	call   f0107994 <strcat>
				break;
f0101815:	e9 ae 02 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case IMM8:
				//sprintf(output + strlen(output), "0x%x", *bytes++);
				snprintf(output + strlen(output),0xff, "0x%x", *bytes++);
f010181a:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101820:	0f b6 18             	movzbl (%eax),%ebx
f0101823:	40                   	inc    %eax
f0101824:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
f010182a:	8b 55 14             	mov    0x14(%ebp),%edx
f010182d:	89 14 24             	mov    %edx,(%esp)
f0101830:	e8 0f 61 00 00       	call   f0107944 <strlen>
f0101835:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101839:	c7 44 24 08 b3 8c 10 	movl   $0xf0108cb3,0x8(%esp)
f0101840:	f0 
f0101841:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101848:	00 
f0101849:	03 45 14             	add    0x14(%ebp),%eax
f010184c:	89 04 24             	mov    %eax,(%esp)
f010184f:	e8 ed 5f 00 00       	call   f0107841 <snprintf>
				break;
f0101854:	e9 6f 02 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case IMM16:
				//sprintf(output + strlen(output), "0x%x", *(short *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x", *(short *)bytes);
f0101859:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010185f:	0f bf 18             	movswl (%eax),%ebx
f0101862:	8b 55 14             	mov    0x14(%ebp),%edx
f0101865:	89 14 24             	mov    %edx,(%esp)
f0101868:	e8 d7 60 00 00       	call   f0107944 <strlen>
f010186d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101871:	c7 44 24 08 b3 8c 10 	movl   $0xf0108cb3,0x8(%esp)
f0101878:	f0 
f0101879:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101880:	00 
f0101881:	03 45 14             	add    0x14(%ebp),%eax
f0101884:	89 04 24             	mov    %eax,(%esp)
f0101887:	e8 b5 5f 00 00       	call   f0107841 <snprintf>
				bytes += 2;
f010188c:	83 85 e4 fd ff ff 02 	addl   $0x2,-0x21c(%ebp)
				break;
f0101893:	e9 30 02 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case IMM32:
				//sprintf(output + strlen(output), "0x%x", *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x", *(int *)bytes);
f0101898:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010189e:	8b 18                	mov    (%eax),%ebx
f01018a0:	8b 55 14             	mov    0x14(%ebp),%edx
f01018a3:	89 14 24             	mov    %edx,(%esp)
f01018a6:	e8 99 60 00 00       	call   f0107944 <strlen>
f01018ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01018af:	c7 44 24 08 b3 8c 10 	movl   $0xf0108cb3,0x8(%esp)
f01018b6:	f0 
f01018b7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01018be:	00 
f01018bf:	03 45 14             	add    0x14(%ebp),%eax
f01018c2:	89 04 24             	mov    %eax,(%esp)
f01018c5:	e8 77 5f 00 00       	call   f0107841 <snprintf>
				bytes += 4;
f01018ca:	83 85 e4 fd ff ff 04 	addl   $0x4,-0x21c(%ebp)
				break;
f01018d1:	e9 f2 01 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case REL8:
				//sprintf(output + strlen(output), "0x%lx", offset + ((bytes - base) + 1) + *(char *)bytes);
				snprintf(output + strlen(output),0xff, "0x%lx", offset + ((bytes - base) + 1) + *(char *)bytes);
f01018d6:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01018dc:	2b 45 08             	sub    0x8(%ebp),%eax
f01018df:	8b 55 10             	mov    0x10(%ebp),%edx
f01018e2:	8d 5c 02 01          	lea    0x1(%edx,%eax,1),%ebx
f01018e6:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f01018ec:	0f be 02             	movsbl (%edx),%eax
f01018ef:	01 c3                	add    %eax,%ebx
f01018f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01018f4:	89 04 24             	mov    %eax,(%esp)
f01018f7:	e8 48 60 00 00       	call   f0107944 <strlen>
f01018fc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101900:	c7 44 24 08 a8 8c 10 	movl   $0xf0108ca8,0x8(%esp)
f0101907:	f0 
f0101908:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010190f:	00 
f0101910:	03 45 14             	add    0x14(%ebp),%eax
f0101913:	89 04 24             	mov    %eax,(%esp)
f0101916:	e8 26 5f 00 00       	call   f0107841 <snprintf>
                bytes++;
f010191b:	ff 85 e4 fd ff ff    	incl   -0x21c(%ebp)
				break;
f0101921:	e9 a2 01 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case REL32:
				//sprintf(output + strlen(output), "0x%lx", offset + ((bytes - base) + 4) + *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%lx", offset + ((bytes - base) + 4) + *(int *)bytes);
f0101926:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010192c:	2b 45 08             	sub    0x8(%ebp),%eax
f010192f:	8b 55 10             	mov    0x10(%ebp),%edx
f0101932:	8d 5c 02 04          	lea    0x4(%edx,%eax,1),%ebx
f0101936:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010193c:	03 18                	add    (%eax),%ebx
f010193e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101941:	89 14 24             	mov    %edx,(%esp)
f0101944:	e8 fb 5f 00 00       	call   f0107944 <strlen>
f0101949:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010194d:	c7 44 24 08 a8 8c 10 	movl   $0xf0108ca8,0x8(%esp)
f0101954:	f0 
f0101955:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010195c:	00 
f010195d:	03 45 14             	add    0x14(%ebp),%eax
f0101960:	89 04 24             	mov    %eax,(%esp)
f0101963:	e8 d9 5e 00 00       	call   f0107841 <snprintf>
				bytes += 4;
f0101968:	83 85 e4 fd ff ff 04 	addl   $0x4,-0x21c(%ebp)
				break;
f010196f:	e9 54 01 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case PTR1632:
				//sprintf(output + strlen(output), "0x%x:0x%x", *(short *)(bytes + 4), *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x:0x%x", *(short *)(bytes + 4), *(int *)bytes);
f0101974:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010197a:	8b 00                	mov    (%eax),%eax
f010197c:	89 85 dc fd ff ff    	mov    %eax,-0x224(%ebp)
f0101982:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f0101988:	0f bf 5a 04          	movswl 0x4(%edx),%ebx
f010198c:	8b 45 14             	mov    0x14(%ebp),%eax
f010198f:	89 04 24             	mov    %eax,(%esp)
f0101992:	e8 ad 5f 00 00       	call   f0107944 <strlen>
f0101997:	8b 95 dc fd ff ff    	mov    -0x224(%ebp),%edx
f010199d:	89 54 24 10          	mov    %edx,0x10(%esp)
f01019a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019a5:	c7 44 24 08 ae 8c 10 	movl   $0xf0108cae,0x8(%esp)
f01019ac:	f0 
f01019ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01019b4:	00 
f01019b5:	03 45 14             	add    0x14(%ebp),%eax
f01019b8:	89 04 24             	mov    %eax,(%esp)
f01019bb:	e8 81 5e 00 00       	call   f0107841 <snprintf>
				bytes += 6;
f01019c0:	83 85 e4 fd ff ff 06 	addl   $0x6,-0x21c(%ebp)
				break;
f01019c7:	e9 fc 00 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case AL:
				strcat(output, "al");
f01019cc:	c7 44 24 04 b8 8c 10 	movl   $0xf0108cb8,0x4(%esp)
f01019d3:	f0 
f01019d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01019d7:	89 04 24             	mov    %eax,(%esp)
f01019da:	e8 b5 5f 00 00       	call   f0107994 <strcat>
				break;
f01019df:	e9 e4 00 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case EAX:
				strcat(output, "eax");
f01019e4:	c7 44 24 04 bb 8c 10 	movl   $0xf0108cbb,0x4(%esp)
f01019eb:	f0 
f01019ec:	8b 55 14             	mov    0x14(%ebp),%edx
f01019ef:	89 14 24             	mov    %edx,(%esp)
f01019f2:	e8 9d 5f 00 00       	call   f0107994 <strcat>
				break;
f01019f7:	e9 cc 00 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case ES:
				strcat(output, "es");
f01019fc:	c7 44 24 04 06 a6 10 	movl   $0xf010a606,0x4(%esp)
f0101a03:	f0 
f0101a04:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a07:	89 04 24             	mov    %eax,(%esp)
f0101a0a:	e8 85 5f 00 00       	call   f0107994 <strcat>
				break;
f0101a0f:	e9 b4 00 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case CS:
				strcat(output, "cs");
f0101a14:	c7 44 24 04 bf 8c 10 	movl   $0xf0108cbf,0x4(%esp)
f0101a1b:	f0 
f0101a1c:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a1f:	89 14 24             	mov    %edx,(%esp)
f0101a22:	e8 6d 5f 00 00       	call   f0107994 <strcat>
				break;
f0101a27:	e9 9c 00 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case SS:
				strcat(output, "ss");
f0101a2c:	c7 44 24 04 c2 8c 10 	movl   $0xf0108cc2,0x4(%esp)
f0101a33:	f0 
f0101a34:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a37:	89 04 24             	mov    %eax,(%esp)
f0101a3a:	e8 55 5f 00 00       	call   f0107994 <strcat>
				break;
f0101a3f:	e9 84 00 00 00       	jmp    f0101ac8 <disassemble+0x85d>
			case DS:
				strcat(output, "ds");
f0101a44:	c7 44 24 04 71 8d 10 	movl   $0xf0108d71,0x4(%esp)
f0101a4b:	f0 
f0101a4c:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a4f:	89 14 24             	mov    %edx,(%esp)
f0101a52:	e8 3d 5f 00 00       	call   f0107994 <strcat>
				break;
f0101a57:	eb 6f                	jmp    f0101ac8 <disassemble+0x85d>
			case ONE:
				strcat(output, "1");
f0101a59:	c7 44 24 04 53 a8 10 	movl   $0xf010a853,0x4(%esp)
f0101a60:	f0 
f0101a61:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a64:	89 04 24             	mov    %eax,(%esp)
f0101a67:	e8 28 5f 00 00       	call   f0107994 <strcat>
				break;
f0101a6c:	eb 5a                	jmp    f0101ac8 <disassemble+0x85d>
			case CL:
				strcat(output, "cl");
f0101a6e:	c7 44 24 04 c5 8c 10 	movl   $0xf0108cc5,0x4(%esp)
f0101a75:	f0 
f0101a76:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a79:	89 14 24             	mov    %edx,(%esp)
f0101a7c:	e8 13 5f 00 00       	call   f0107994 <strcat>
				break;
f0101a81:	eb 45                	jmp    f0101ac8 <disassemble+0x85d>
			case XMM0:
				strcat(output, "xmm0");
f0101a83:	c7 44 24 04 c8 8c 10 	movl   $0xf0108cc8,0x4(%esp)
f0101a8a:	f0 
f0101a8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a8e:	89 04 24             	mov    %eax,(%esp)
f0101a91:	e8 fe 5e 00 00       	call   f0107994 <strcat>
				break;
f0101a96:	eb 30                	jmp    f0101ac8 <disassemble+0x85d>
			case BND0:
				strcat(output, "bnd0");
f0101a98:	c7 44 24 04 cd 8c 10 	movl   $0xf0108ccd,0x4(%esp)
f0101a9f:	f0 
f0101aa0:	8b 55 14             	mov    0x14(%ebp),%edx
f0101aa3:	89 14 24             	mov    %edx,(%esp)
f0101aa6:	e8 e9 5e 00 00       	call   f0107994 <strcat>
				break;
f0101aab:	eb 1b                	jmp    f0101ac8 <disassemble+0x85d>
			case BAD:
				bytes++;
f0101aad:	ff 85 e4 fd ff ff    	incl   -0x21c(%ebp)
				break;
f0101ab3:	eb 13                	jmp    f0101ac8 <disassemble+0x85d>
			case MM0:
				strcat(output, "mm0");
f0101ab5:	c7 44 24 04 c9 8c 10 	movl   $0xf0108cc9,0x4(%esp)
f0101abc:	f0 
f0101abd:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ac0:	89 04 24             	mov    %eax,(%esp)
f0101ac3:	e8 cc 5e 00 00       	call   f0107994 <strcat>
	}

OUTPUT:
	modRM_mod = 0x0;
	strcpy(output, instructions[opcode].mnemonic);
	for (int i = 0; i < instructions[opcode].argument_count; i++) {
f0101ac8:	46                   	inc    %esi
f0101ac9:	0f be 87 01 01 00 00 	movsbl 0x101(%edi),%eax
f0101ad0:	39 c6                	cmp    %eax,%esi
f0101ad2:	0f 8c 46 fc ff ff    	jl     f010171e <disassemble+0x4b3>
				strcat(output, "mm0");
				break;
		}
	}

	if (((unsigned int)(bytes - base)) <= max) {
f0101ad8:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101ade:	2b 45 08             	sub    0x8(%ebp),%eax
f0101ae1:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0101ae4:	72 08                	jb     f0101aee <disassemble+0x883>
f0101ae6:	eb 31                	jmp    f0101b19 <disassemble+0x8ae>
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f0101ae8:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)
	if (((unsigned int)(bytes - base)) <= max) {
		return bytes - base;
	}

ILLEGAL:
	snprintf(output,0xff, ".byte 0x%02x\n", opcode);
f0101aee:	0f b6 85 e3 fd ff ff 	movzbl -0x21d(%ebp),%eax
f0101af5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101af9:	c7 44 24 08 d2 8c 10 	movl   $0xf0108cd2,0x8(%esp)
f0101b00:	f0 
f0101b01:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101b08:	00 
f0101b09:	8b 55 14             	mov    0x14(%ebp),%edx
f0101b0c:	89 14 24             	mov    %edx,(%esp)
f0101b0f:	e8 2d 5d 00 00       	call   f0107841 <snprintf>
	return 1;
f0101b14:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0101b19:	81 c4 3c 02 00 00    	add    $0x23c,%esp
f0101b1f:	5b                   	pop    %ebx
f0101b20:	5e                   	pop    %esi
f0101b21:	5f                   	pop    %edi
f0101b22:	5d                   	pop    %ebp
f0101b23:	c3                   	ret    

f0101b24 <mon_disassembler>:
        	return 0;
    }    
}

int
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
f0101b24:	55                   	push   %ebp
f0101b25:	89 e5                	mov    %esp,%ebp
f0101b27:	57                   	push   %edi
f0101b28:	56                   	push   %esi
f0101b29:	53                   	push   %ebx
f0101b2a:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
f0101b30:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(argc>2){
f0101b36:	83 f8 02             	cmp    $0x2,%eax
f0101b39:	7e 11                	jle    f0101b4c <mon_disassembler+0x28>
		cprintf("mon_disassembler: The number of parameters is two.\n");
f0101b3b:	c7 04 24 00 95 10 f0 	movl   $0xf0109500,(%esp)
f0101b42:	e8 47 3c 00 00       	call   f010578e <cprintf>
		return 0;
f0101b47:	e9 53 01 00 00       	jmp    f0101c9f <mon_disassembler+0x17b>
	}
	int InstructionNumber = 1;
	if (argc == 2){
f0101b4c:	83 f8 02             	cmp    $0x2,%eax
f0101b4f:	75 3c                	jne    f0101b8d <mon_disassembler+0x69>
		char *errChar;
		InstructionNumber = strtol(argv[1], &errChar, 0);
f0101b51:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b58:	00 
f0101b59:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b60:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b63:	8b 40 04             	mov    0x4(%eax),%eax
f0101b66:	89 04 24             	mov    %eax,(%esp)
f0101b69:	e8 62 60 00 00       	call   f0107bd0 <strtol>
f0101b6e:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
		if (*errChar){
f0101b74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b77:	80 38 00             	cmpb   $0x0,(%eax)
f0101b7a:	74 1b                	je     f0101b97 <mon_disassembler+0x73>
			cprintf("mon_disassembler: The first argument is not a number.\n");
f0101b7c:	c7 04 24 34 95 10 f0 	movl   $0xf0109534,(%esp)
f0101b83:	e8 06 3c 00 00       	call   f010578e <cprintf>
			return 0;
f0101b88:	e9 12 01 00 00       	jmp    f0101c9f <mon_disassembler+0x17b>
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
	if(argc>2){
		cprintf("mon_disassembler: The number of parameters is two.\n");
		return 0;
	}
	int InstructionNumber = 1;
f0101b8d:	c7 85 c4 fd ff ff 01 	movl   $0x1,-0x23c(%ebp)
f0101b94:	00 00 00 
			cprintf("mon_disassembler: The first argument is not a number.\n");
			return 0;
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
f0101b97:	85 db                	test   %ebx,%ebx
f0101b99:	75 11                	jne    f0101bac <mon_disassembler+0x88>
f0101b9b:	c7 04 24 6c 95 10 f0 	movl   $0xf010956c,(%esp)
f0101ba2:	e8 e7 3b 00 00       	call   f010578e <cprintf>
f0101ba7:	e9 f3 00 00 00       	jmp    f0101c9f <mon_disassembler+0x17b>
	unsigned char* address = (unsigned char*)tf->tf_eip;
f0101bac:	8b 5b 30             	mov    0x30(%ebx),%ebx
f0101baf:	89 9d d4 fd ff ff    	mov    %ebx,-0x22c(%ebp)
	for (int i = 0;i<InstructionNumber;i++){
f0101bb5:	c7 85 cc fd ff ff 00 	movl   $0x0,-0x234(%ebp)
f0101bbc:	00 00 00 
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
f0101bbf:	8d bd e5 fe ff ff    	lea    -0x11b(%ebp),%edi
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
	unsigned char* address = (unsigned char*)tf->tf_eip;
	for (int i = 0;i<InstructionNumber;i++){
f0101bc5:	e9 c3 00 00 00       	jmp    f0101c8d <mon_disassembler+0x169>
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
f0101bca:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
f0101bd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101bd4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bdb:	00 
f0101bdc:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101be3:	00 
f0101be4:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101bea:	89 04 24             	mov    %eax,(%esp)
f0101bed:	e8 79 f6 ff ff       	call   f010126b <disassemble>
f0101bf2:	89 85 c8 fd ff ff    	mov    %eax,-0x238(%ebp)
		cprintf("%08x: ", address);
f0101bf8:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c02:	c7 04 24 e0 8c 10 f0 	movl   $0xf0108ce0,(%esp)
f0101c09:	e8 80 3b 00 00       	call   f010578e <cprintf>
		instruction[0] = 0;
f0101c0e:	c6 85 e5 fe ff ff 00 	movb   $0x0,-0x11b(%ebp)
        	return 0;
    }    
}

int
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
f0101c15:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
f0101c1b:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
f0101c21:	be 00 00 00 00       	mov    $0x0,%esi
f0101c26:	eb 31                	jmp    f0101c59 <mon_disassembler+0x135>
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
f0101c28:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101c2e:	0f b6 1c 30          	movzbl (%eax,%esi,1),%ebx
f0101c32:	89 3c 24             	mov    %edi,(%esp)
f0101c35:	e8 0a 5d 00 00       	call   f0107944 <strlen>
f0101c3a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101c3e:	c7 44 24 08 e7 8c 10 	movl   $0xf0108ce7,0x8(%esp)
f0101c45:	f0 
f0101c46:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101c4d:	00 
f0101c4e:	01 f8                	add    %edi,%eax
f0101c50:	89 04 24             	mov    %eax,(%esp)
f0101c53:	e8 e9 5b 00 00       	call   f0107841 <snprintf>
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
f0101c58:	46                   	inc    %esi
f0101c59:	3b b5 d0 fd ff ff    	cmp    -0x230(%ebp),%esi
f0101c5f:	75 c7                	jne    f0101c28 <mon_disassembler+0x104>
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
		}
		cprintf("%-30s %s\n", instruction, disassembled);
f0101c61:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
f0101c67:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c6b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c6f:	c7 04 24 ed 8c 10 f0 	movl   $0xf0108ced,(%esp)
f0101c76:	e8 13 3b 00 00       	call   f010578e <cprintf>
		address = (unsigned char*)((uint32_t)address + count);
f0101c7b:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
f0101c81:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
	unsigned char* address = (unsigned char*)tf->tf_eip;
	for (int i = 0;i<InstructionNumber;i++){
f0101c87:	ff 85 cc fd ff ff    	incl   -0x234(%ebp)
f0101c8d:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
f0101c93:	39 85 c4 fd ff ff    	cmp    %eax,-0x23c(%ebp)
f0101c99:	0f 8f 2b ff ff ff    	jg     f0101bca <mon_disassembler+0xa6>
		}
		cprintf("%-30s %s\n", instruction, disassembled);
		address = (unsigned char*)((uint32_t)address + count);
	}
	return 0;
f0101c9f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ca4:	81 c4 4c 02 00 00    	add    $0x24c,%esp
f0101caa:	5b                   	pop    %ebx
f0101cab:	5e                   	pop    %esi
f0101cac:	5f                   	pop    %edi
f0101cad:	5d                   	pop    %ebp
f0101cae:	c3                   	ret    

f0101caf <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0101caf:	55                   	push   %ebp
f0101cb0:	89 e5                	mov    %esp,%ebp
f0101cb2:	57                   	push   %edi
f0101cb3:	56                   	push   %esi
f0101cb4:	53                   	push   %ebx
f0101cb5:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101cb8:	c7 04 24 90 95 10 f0 	movl   $0xf0109590,(%esp)
f0101cbf:	e8 ca 3a 00 00       	call   f010578e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101cc4:	c7 04 24 b4 95 10 f0 	movl   $0xf01095b4,(%esp)
f0101ccb:	e8 be 3a 00 00       	call   f010578e <cprintf>

	if (tf != NULL)
f0101cd0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101cd4:	74 0b                	je     f0101ce1 <monitor+0x32>
		print_trapframe(tf);
f0101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cd9:	89 04 24             	mov    %eax,(%esp)
f0101cdc:	e8 ca 42 00 00       	call   f0105fab <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0101ce1:	c7 04 24 f7 8c 10 f0 	movl   $0xf0108cf7,(%esp)
f0101ce8:	e8 7f 5b 00 00       	call   f010786c <readline>
f0101ced:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101cef:	85 c0                	test   %eax,%eax
f0101cf1:	74 ee                	je     f0101ce1 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0101cf3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0101cfa:	be 00 00 00 00       	mov    $0x0,%esi
f0101cff:	eb 04                	jmp    f0101d05 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101d01:	c6 03 00             	movb   $0x0,(%ebx)
f0101d04:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0101d05:	8a 03                	mov    (%ebx),%al
f0101d07:	84 c0                	test   %al,%al
f0101d09:	74 5e                	je     f0101d69 <monitor+0xba>
f0101d0b:	0f be c0             	movsbl %al,%eax
f0101d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d12:	c7 04 24 fb 8c 10 f0 	movl   $0xf0108cfb,(%esp)
f0101d19:	e8 53 5d 00 00       	call   f0107a71 <strchr>
f0101d1e:	85 c0                	test   %eax,%eax
f0101d20:	75 df                	jne    f0101d01 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0101d22:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101d25:	74 42                	je     f0101d69 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0101d27:	83 fe 0f             	cmp    $0xf,%esi
f0101d2a:	75 16                	jne    f0101d42 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101d2c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101d33:	00 
f0101d34:	c7 04 24 00 8d 10 f0 	movl   $0xf0108d00,(%esp)
f0101d3b:	e8 4e 3a 00 00       	call   f010578e <cprintf>
f0101d40:	eb 9f                	jmp    f0101ce1 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0101d42:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0101d46:	46                   	inc    %esi
f0101d47:	eb 01                	jmp    f0101d4a <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0101d49:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101d4a:	8a 03                	mov    (%ebx),%al
f0101d4c:	84 c0                	test   %al,%al
f0101d4e:	74 b5                	je     f0101d05 <monitor+0x56>
f0101d50:	0f be c0             	movsbl %al,%eax
f0101d53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d57:	c7 04 24 fb 8c 10 f0 	movl   $0xf0108cfb,(%esp)
f0101d5e:	e8 0e 5d 00 00       	call   f0107a71 <strchr>
f0101d63:	85 c0                	test   %eax,%eax
f0101d65:	74 e2                	je     f0101d49 <monitor+0x9a>
f0101d67:	eb 9c                	jmp    f0101d05 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0101d69:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101d70:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101d71:	85 f6                	test   %esi,%esi
f0101d73:	0f 84 68 ff ff ff    	je     f0101ce1 <monitor+0x32>
f0101d79:	bb 60 9b 10 f0       	mov    $0xf0109b60,%ebx
f0101d7e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101d83:	8b 03                	mov    (%ebx),%eax
f0101d85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d89:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101d8c:	89 04 24             	mov    %eax,(%esp)
f0101d8f:	e8 8a 5c 00 00       	call   f0107a1e <strcmp>
f0101d94:	85 c0                	test   %eax,%eax
f0101d96:	75 24                	jne    f0101dbc <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0101d98:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0101d9b:	8b 55 08             	mov    0x8(%ebp),%edx
f0101d9e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101da2:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101da5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101da9:	89 34 24             	mov    %esi,(%esp)
f0101dac:	ff 14 85 68 9b 10 f0 	call   *-0xfef6498(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101db3:	85 c0                	test   %eax,%eax
f0101db5:	78 26                	js     f0101ddd <monitor+0x12e>
f0101db7:	e9 25 ff ff ff       	jmp    f0101ce1 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0101dbc:	47                   	inc    %edi
f0101dbd:	83 c3 0c             	add    $0xc,%ebx
f0101dc0:	83 ff 0c             	cmp    $0xc,%edi
f0101dc3:	75 be                	jne    f0101d83 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101dc5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101dcc:	c7 04 24 1d 8d 10 f0 	movl   $0xf0108d1d,(%esp)
f0101dd3:	e8 b6 39 00 00       	call   f010578e <cprintf>
f0101dd8:	e9 04 ff ff ff       	jmp    f0101ce1 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101ddd:	83 c4 5c             	add    $0x5c,%esp
f0101de0:	5b                   	pop    %ebx
f0101de1:	5e                   	pop    %esi
f0101de2:	5f                   	pop    %edi
f0101de3:	5d                   	pop    %ebp
f0101de4:	c3                   	ret    

f0101de5 <Sign2Perm>:
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}

int Sign2Perm(char *s){
f0101de5:	55                   	push   %ebp
f0101de6:	89 e5                	mov    %esp,%ebp
f0101de8:	56                   	push   %esi
f0101de9:	53                   	push   %ebx
f0101dea:	83 ec 10             	sub    $0x10,%esp
f0101ded:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int l = strlen(s);
f0101df0:	89 1c 24             	mov    %ebx,(%esp)
f0101df3:	e8 4c 5b 00 00       	call   f0107944 <strlen>
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101df8:	ba 00 00 00 00       	mov    $0x0,%edx
    return 0;
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
f0101dfd:	be 00 00 00 00       	mov    $0x0,%esi
	for (int i=0;i<l;i++){
f0101e02:	eb 47                	jmp    f0101e4b <Sign2Perm+0x66>
		switch(s[i]){
f0101e04:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0101e07:	83 e9 41             	sub    $0x41,%ecx
f0101e0a:	80 f9 16             	cmp    $0x16,%cl
f0101e0d:	77 42                	ja     f0101e51 <Sign2Perm+0x6c>
f0101e0f:	0f b6 c9             	movzbl %cl,%ecx
f0101e12:	ff 24 8d e8 9a 10 f0 	jmp    *-0xfef6518(,%ecx,4)
			case 'P':Perm|=PTE_P;break;
f0101e19:	83 ce 01             	or     $0x1,%esi
f0101e1c:	eb 2c                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'W':Perm|=PTE_W;break;
f0101e1e:	83 ce 02             	or     $0x2,%esi
f0101e21:	eb 27                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'U':Perm|=PTE_U;break;
f0101e23:	83 ce 04             	or     $0x4,%esi
f0101e26:	eb 22                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'T':Perm|=PTE_PWT;break;
f0101e28:	83 ce 08             	or     $0x8,%esi
f0101e2b:	eb 1d                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'C':Perm|=PTE_PCD;break;
f0101e2d:	83 ce 10             	or     $0x10,%esi
f0101e30:	eb 18                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'A':Perm|=PTE_A;break;
f0101e32:	83 ce 20             	or     $0x20,%esi
f0101e35:	eb 13                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'D':Perm|=PTE_D;break;
f0101e37:	83 ce 40             	or     $0x40,%esi
f0101e3a:	eb 0e                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'I':Perm|=PTE_PS;break;
f0101e3c:	81 ce 80 00 00 00    	or     $0x80,%esi
f0101e42:	eb 06                	jmp    f0101e4a <Sign2Perm+0x65>
			case 'G':Perm|=PTE_G;break;
f0101e44:	81 ce 00 01 00 00    	or     $0x100,%esi
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101e4a:	42                   	inc    %edx
f0101e4b:	39 c2                	cmp    %eax,%edx
f0101e4d:	7c b5                	jl     f0101e04 <Sign2Perm+0x1f>
f0101e4f:	eb 05                	jmp    f0101e56 <Sign2Perm+0x71>
			case 'C':Perm|=PTE_PCD;break;
			case 'A':Perm|=PTE_A;break;
			case 'D':Perm|=PTE_D;break;
			case 'I':Perm|=PTE_PS;break;
			case 'G':Perm|=PTE_G;break;
			default:return -1;
f0101e51:	be ff ff ff ff       	mov    $0xffffffff,%esi
		}
	}
	return Perm;
}
f0101e56:	89 f0                	mov    %esi,%eax
f0101e58:	83 c4 10             	add    $0x10,%esp
f0101e5b:	5b                   	pop    %ebx
f0101e5c:	5e                   	pop    %esi
f0101e5d:	5d                   	pop    %ebp
f0101e5e:	c3                   	ret    

f0101e5f <mon_clearpermissions>:
    cprintf("Permission has been updated:\n");
    mon_showmappings(argc-1,argv,tf);
    return 0;
}

int mon_clearpermissions(int argc, char **argv, struct Trapframe *tf){
f0101e5f:	55                   	push   %ebp
f0101e60:	89 e5                	mov    %esp,%ebp
f0101e62:	57                   	push   %edi
f0101e63:	56                   	push   %esi
f0101e64:	53                   	push   %ebx
f0101e65:	83 ec 2c             	sub    $0x2c,%esp
f0101e68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc!=4){
f0101e6b:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0101e6f:	74 11                	je     f0101e82 <mon_clearpermissions+0x23>
		cprintf("mon_clearpermissions: The number of parameters is three.\n");
f0101e71:	c7 04 24 dc 95 10 f0 	movl   $0xf01095dc,(%esp)
f0101e78:	e8 11 39 00 00       	call   f010578e <cprintf>
		return 0;
f0101e7d:	e9 65 01 00 00       	jmp    f0101fe7 <mon_clearpermissions+0x188>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0101e82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e89:	00 
f0101e8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e91:	8b 43 04             	mov    0x4(%ebx),%eax
f0101e94:	89 04 24             	mov    %eax,(%esp)
f0101e97:	e8 34 5d 00 00       	call   f0107bd0 <strtol>
f0101e9c:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0101e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101ea1:	80 38 00             	cmpb   $0x0,(%eax)
f0101ea4:	74 11                	je     f0101eb7 <mon_clearpermissions+0x58>
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
f0101ea6:	c7 04 24 18 96 10 f0 	movl   $0xf0109618,(%esp)
f0101ead:	e8 dc 38 00 00       	call   f010578e <cprintf>
		return 0;
f0101eb2:	e9 30 01 00 00       	jmp    f0101fe7 <mon_clearpermissions+0x188>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101eb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ebe:	00 
f0101ebf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ec6:	8b 43 08             	mov    0x8(%ebx),%eax
f0101ec9:	89 04 24             	mov    %eax,(%esp)
f0101ecc:	e8 ff 5c 00 00       	call   f0107bd0 <strtol>
	if (*errChar){
f0101ed1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ed4:	80 3a 00             	cmpb   $0x0,(%edx)
f0101ed7:	74 11                	je     f0101eea <mon_clearpermissions+0x8b>
		cprintf("mon_clearpermissions: The second argument is not a number.\n");
f0101ed9:	c7 04 24 54 96 10 f0 	movl   $0xf0109654,(%esp)
f0101ee0:	e8 a9 38 00 00       	call   f010578e <cprintf>
		return 0;
f0101ee5:	e9 fd 00 00 00       	jmp    f0101fe7 <mon_clearpermissions+0x188>
	}
	if (StartAddr&0x3ff){
f0101eea:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0101ef0:	74 11                	je     f0101f03 <mon_clearpermissions+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f0101ef2:	c7 04 24 c8 8f 10 f0 	movl   $0xf0108fc8,(%esp)
f0101ef9:	e8 90 38 00 00       	call   f010578e <cprintf>
		return 0;
f0101efe:	e9 e4 00 00 00       	jmp    f0101fe7 <mon_clearpermissions+0x188>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101f03:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0101f05:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0101f0a:	74 11                	je     f0101f1d <mon_clearpermissions+0xbe>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0101f0c:	c7 04 24 04 90 10 f0 	movl   $0xf0109004,(%esp)
f0101f13:	e8 76 38 00 00       	call   f010578e <cprintf>
		return 0;
f0101f18:	e9 ca 00 00 00       	jmp    f0101fe7 <mon_clearpermissions+0x188>
	}
	if (StartAddr > EndAddr){
f0101f1d:	39 c6                	cmp    %eax,%esi
f0101f1f:	76 11                	jbe    f0101f32 <mon_clearpermissions+0xd3>
		cprintf("mon_clearpermissions: The first parameter is larger than the second parameter.\n");
f0101f21:	c7 04 24 90 96 10 f0 	movl   $0xf0109690,(%esp)
f0101f28:	e8 61 38 00 00       	call   f010578e <cprintf>
		return 0;
f0101f2d:	e9 b5 00 00 00       	jmp    f0101fe7 <mon_clearpermissions+0x188>
	}
	int Perm = Sign2Perm(argv[3]);
f0101f32:	8b 43 0c             	mov    0xc(%ebx),%eax
f0101f35:	89 04 24             	mov    %eax,(%esp)
f0101f38:	e8 a8 fe ff ff       	call   f0101de5 <Sign2Perm>
	if (Perm == -1){
f0101f3d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f40:	75 7c                	jne    f0101fbe <mon_clearpermissions+0x15f>
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
f0101f42:	c7 04 24 e0 96 10 f0 	movl   $0xf01096e0,(%esp)
f0101f49:	e8 40 38 00 00       	call   f010578e <cprintf>
		return 0;
f0101f4e:	e9 94 00 00 00       	jmp    f0101fe7 <mon_clearpermissions+0x188>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0101f53:	89 f1                	mov    %esi,%ecx
f0101f55:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f0101f58:	8b 15 8c be 24 f0    	mov    0xf024be8c,%edx
f0101f5e:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0101f61:	f6 c2 01             	test   $0x1,%dl
f0101f64:	74 50                	je     f0101fb6 <mon_clearpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0101f66:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f6c:	89 d1                	mov    %edx,%ecx
f0101f6e:	c1 e9 0c             	shr    $0xc,%ecx
f0101f71:	3b 0d 88 be 24 f0    	cmp    0xf024be88,%ecx
f0101f77:	72 20                	jb     f0101f99 <mon_clearpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f79:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101f7d:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f0101f8c:	00 
f0101f8d:	c7 04 24 07 8c 10 f0 	movl   $0xf0108c07,(%esp)
f0101f94:	e8 a7 e0 ff ff       	call   f0100040 <_panic>
f0101f99:	89 f1                	mov    %esi,%ecx
f0101f9b:	c1 e9 0a             	shr    $0xa,%ecx
f0101f9e:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f0101fa4:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f0101fab:	8b 0a                	mov    (%edx),%ecx
f0101fad:	f6 c1 01             	test   $0x1,%cl
f0101fb0:	74 04                	je     f0101fb6 <mon_clearpermissions+0x157>
				*pte = *pte & ~Perm;
f0101fb2:	21 c1                	and    %eax,%ecx
f0101fb4:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101fb6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101fbc:	eb 02                	jmp    f0101fc0 <mon_clearpermissions+0x161>
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				*pte = *pte & ~Perm;
f0101fbe:	f7 d0                	not    %eax
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101fc0:	39 fe                	cmp    %edi,%esi
f0101fc2:	72 8f                	jb     f0101f53 <mon_clearpermissions+0xf4>
				*pte = *pte & ~Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f0101fc4:	c7 04 24 33 8d 10 f0 	movl   $0xf0108d33,(%esp)
f0101fcb:	e8 be 37 00 00       	call   f010578e <cprintf>
    mon_showmappings(argc-1,argv,tf);
f0101fd0:	8b 45 10             	mov    0x10(%ebp),%eax
f0101fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fdb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f0101fe2:	e8 b7 f0 ff ff       	call   f010109e <mon_showmappings>

    return 0;
}
f0101fe7:	b8 00 00 00 00       	mov    $0x0,%eax
f0101fec:	83 c4 2c             	add    $0x2c,%esp
f0101fef:	5b                   	pop    %ebx
f0101ff0:	5e                   	pop    %esi
f0101ff1:	5f                   	pop    %edi
f0101ff2:	5d                   	pop    %ebp
f0101ff3:	c3                   	ret    

f0101ff4 <mon_setpermissions>:
			default:return -1;
		}
	}
	return Perm;
}
int mon_setpermissions(int argc, char **argv, struct Trapframe *tf){
f0101ff4:	55                   	push   %ebp
f0101ff5:	89 e5                	mov    %esp,%ebp
f0101ff7:	57                   	push   %edi
f0101ff8:	56                   	push   %esi
f0101ff9:	53                   	push   %ebx
f0101ffa:	83 ec 2c             	sub    $0x2c,%esp
f0101ffd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=4){
f0102000:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0102004:	74 11                	je     f0102017 <mon_setpermissions+0x23>
		cprintf("mon_setpermissions: The number of parameters is three.\n");
f0102006:	c7 04 24 20 97 10 f0 	movl   $0xf0109720,(%esp)
f010200d:	e8 7c 37 00 00       	call   f010578e <cprintf>
		return 0;
f0102012:	e9 61 01 00 00       	jmp    f0102178 <mon_setpermissions+0x184>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0102017:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010201e:	00 
f010201f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102022:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102026:	8b 43 04             	mov    0x4(%ebx),%eax
f0102029:	89 04 24             	mov    %eax,(%esp)
f010202c:	e8 9f 5b 00 00       	call   f0107bd0 <strtol>
f0102031:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0102033:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102036:	80 38 00             	cmpb   $0x0,(%eax)
f0102039:	74 11                	je     f010204c <mon_setpermissions+0x58>
		cprintf("mon_setpermissions: The first argument is not a number.\n");
f010203b:	c7 04 24 58 97 10 f0 	movl   $0xf0109758,(%esp)
f0102042:	e8 47 37 00 00       	call   f010578e <cprintf>
		return 0;
f0102047:	e9 2c 01 00 00       	jmp    f0102178 <mon_setpermissions+0x184>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f010204c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102053:	00 
f0102054:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102057:	89 44 24 04          	mov    %eax,0x4(%esp)
f010205b:	8b 43 08             	mov    0x8(%ebx),%eax
f010205e:	89 04 24             	mov    %eax,(%esp)
f0102061:	e8 6a 5b 00 00       	call   f0107bd0 <strtol>
	if (*errChar){
f0102066:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102069:	80 3a 00             	cmpb   $0x0,(%edx)
f010206c:	74 11                	je     f010207f <mon_setpermissions+0x8b>
		cprintf("mon_setpermissions: The second argument is not a number\n");
f010206e:	c7 04 24 94 97 10 f0 	movl   $0xf0109794,(%esp)
f0102075:	e8 14 37 00 00       	call   f010578e <cprintf>
		return 0;
f010207a:	e9 f9 00 00 00       	jmp    f0102178 <mon_setpermissions+0x184>
	}
	if (StartAddr&0x3ff){
f010207f:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0102085:	74 11                	je     f0102098 <mon_setpermissions+0xa4>
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
f0102087:	c7 04 24 d0 97 10 f0 	movl   $0xf01097d0,(%esp)
f010208e:	e8 fb 36 00 00       	call   f010578e <cprintf>
		return 0;
f0102093:	e9 e0 00 00 00       	jmp    f0102178 <mon_setpermissions+0x184>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_setpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0102098:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f010209a:	a9 ff 03 00 00       	test   $0x3ff,%eax
f010209f:	74 11                	je     f01020b2 <mon_setpermissions+0xbe>
		cprintf("mon_setpermissions: The second parameter is not aligned.\n");
f01020a1:	c7 04 24 0c 98 10 f0 	movl   $0xf010980c,(%esp)
f01020a8:	e8 e1 36 00 00       	call   f010578e <cprintf>
		return 0;
f01020ad:	e9 c6 00 00 00       	jmp    f0102178 <mon_setpermissions+0x184>
	}
	if (StartAddr > EndAddr){
f01020b2:	39 c6                	cmp    %eax,%esi
f01020b4:	76 11                	jbe    f01020c7 <mon_setpermissions+0xd3>
		cprintf("mon_setpermissions: The first parameter is larger than the second parameter.\n");
f01020b6:	c7 04 24 48 98 10 f0 	movl   $0xf0109848,(%esp)
f01020bd:	e8 cc 36 00 00       	call   f010578e <cprintf>
		return 0;
f01020c2:	e9 b1 00 00 00       	jmp    f0102178 <mon_setpermissions+0x184>
	}
	int Perm = Sign2Perm(argv[3]);
f01020c7:	8b 43 0c             	mov    0xc(%ebx),%eax
f01020ca:	89 04 24             	mov    %eax,(%esp)
f01020cd:	e8 13 fd ff ff       	call   f0101de5 <Sign2Perm>
	if (Perm == -1){
f01020d2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020d5:	75 7a                	jne    f0102151 <mon_setpermissions+0x15d>
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
f01020d7:	c7 04 24 98 98 10 f0 	movl   $0xf0109898,(%esp)
f01020de:	e8 ab 36 00 00       	call   f010578e <cprintf>
		return 0;
f01020e3:	e9 90 00 00 00       	jmp    f0102178 <mon_setpermissions+0x184>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f01020e8:	89 f1                	mov    %esi,%ecx
f01020ea:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f01020ed:	8b 15 8c be 24 f0    	mov    0xf024be8c,%edx
f01020f3:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f01020f6:	f6 c2 01             	test   $0x1,%dl
f01020f9:	74 50                	je     f010214b <mon_setpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f01020fb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102101:	89 d1                	mov    %edx,%ecx
f0102103:	c1 e9 0c             	shr    $0xc,%ecx
f0102106:	3b 0d 88 be 24 f0    	cmp    0xf024be88,%ecx
f010210c:	72 20                	jb     f010212e <mon_setpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010210e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102112:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0102119:	f0 
f010211a:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0102121:	00 
f0102122:	c7 04 24 07 8c 10 f0 	movl   $0xf0108c07,(%esp)
f0102129:	e8 12 df ff ff       	call   f0100040 <_panic>
f010212e:	89 f1                	mov    %esi,%ecx
f0102130:	c1 e9 0a             	shr    $0xa,%ecx
f0102133:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f0102139:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f0102140:	8b 0a                	mov    (%edx),%ecx
f0102142:	f6 c1 01             	test   $0x1,%cl
f0102145:	74 04                	je     f010214b <mon_setpermissions+0x157>
				*pte = *pte | Perm;
f0102147:	09 c1                	or     %eax,%ecx
f0102149:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f010214b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102151:	39 fe                	cmp    %edi,%esi
f0102153:	72 93                	jb     f01020e8 <mon_setpermissions+0xf4>
				*pte = *pte | Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f0102155:	c7 04 24 33 8d 10 f0 	movl   $0xf0108d33,(%esp)
f010215c:	e8 2d 36 00 00       	call   f010578e <cprintf>
    mon_showmappings(argc-1,argv,tf);
f0102161:	8b 45 10             	mov    0x10(%ebp),%eax
f0102164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102168:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010216c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f0102173:	e8 26 ef ff ff       	call   f010109e <mon_showmappings>
    return 0;
}
f0102178:	b8 00 00 00 00       	mov    $0x0,%eax
f010217d:	83 c4 2c             	add    $0x2c,%esp
f0102180:	5b                   	pop    %ebx
f0102181:	5e                   	pop    %esi
f0102182:	5f                   	pop    %edi
f0102183:	5d                   	pop    %ebp
f0102184:	c3                   	ret    
f0102185:	00 00                	add    %al,(%eax)
	...

f0102188 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0102188:	55                   	push   %ebp
f0102189:	89 e5                	mov    %esp,%ebp
f010218b:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f010218e:	89 d1                	mov    %edx,%ecx
f0102190:	c1 e9 16             	shr    $0x16,%ecx
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
f0102193:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0102196:	a8 01                	test   $0x1,%al
f0102198:	74 4d                	je     f01021e7 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010219a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010219f:	89 c1                	mov    %eax,%ecx
f01021a1:	c1 e9 0c             	shr    $0xc,%ecx
f01021a4:	3b 0d 88 be 24 f0    	cmp    0xf024be88,%ecx
f01021aa:	72 20                	jb     f01021cc <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01021b0:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f01021b7:	f0 
f01021b8:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f01021bf:	00 
f01021c0:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01021c7:	e8 74 de ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01021cc:	c1 ea 0c             	shr    $0xc,%edx
f01021cf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01021d5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01021dc:	a8 01                	test   $0x1,%al
f01021de:	74 0e                	je     f01021ee <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01021e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021e5:	eb 0c                	jmp    f01021f3 <check_va2pa+0x6b>
	pgdir = &pgdir[PDX(va)];
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
		return ~0;
f01021e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01021ec:	eb 05                	jmp    f01021f3 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f01021ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f01021f3:	c9                   	leave  
f01021f4:	c3                   	ret    

f01021f5 <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f01021f5:	55                   	push   %ebp
f01021f6:	89 e5                	mov    %esp,%ebp
f01021f8:	83 ec 18             	sub    $0x18,%esp
f01021fb:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01021fd:	83 3d 44 b2 24 f0 00 	cmpl   $0x0,0xf024b244
f0102204:	75 0f                	jne    f0102215 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0102206:	b8 07 e0 28 f0       	mov    $0xf028e007,%eax
f010220b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102210:	a3 44 b2 24 f0       	mov    %eax,0xf024b244
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n>0){
f0102215:	85 d2                	test   %edx,%edx
f0102217:	74 6d                	je     f0102286 <boot_alloc+0x91>
		result = nextfree;
f0102219:	a1 44 b2 24 f0       	mov    0xf024b244,%eax
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010221e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0102225:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010222b:	89 15 44 b2 24 f0    	mov    %edx,0xf024b244
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102231:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102237:	77 20                	ja     f0102259 <boot_alloc+0x64>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102239:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010223d:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f0102244:	f0 
f0102245:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f010224c:	00 
f010224d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102254:	e8 e7 dd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102259:	81 c2 00 00 00 10    	add    $0x10000000,%edx
		if (PGNUM(PADDR(nextfree))>=npages)
f010225f:	c1 ea 0c             	shr    $0xc,%edx
f0102262:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f0102268:	72 21                	jb     f010228b <boot_alloc+0x96>
			panic("boot_alloc: out of memory");
f010226a:	c7 44 24 08 d5 a5 10 	movl   $0xf010a5d5,0x8(%esp)
f0102271:	f0 
f0102272:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
f0102279:	00 
f010227a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102281:	e8 ba dd ff ff       	call   f0100040 <_panic>
	}
	else{
		result = nextfree;
f0102286:	a1 44 b2 24 f0       	mov    0xf024b244,%eax
	}
	// cprintf("boot_alloc %x %d\n",result,n);
	return result;
	// return NULL;
}
f010228b:	c9                   	leave  
f010228c:	c3                   	ret    

f010228d <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010228d:	55                   	push   %ebp
f010228e:	89 e5                	mov    %esp,%ebp
f0102290:	56                   	push   %esi
f0102291:	53                   	push   %ebx
f0102292:	83 ec 10             	sub    $0x10,%esp
f0102295:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0102297:	89 04 24             	mov    %eax,(%esp)
f010229a:	e8 a9 33 00 00       	call   f0105648 <mc146818_read>
f010229f:	89 c6                	mov    %eax,%esi
f01022a1:	43                   	inc    %ebx
f01022a2:	89 1c 24             	mov    %ebx,(%esp)
f01022a5:	e8 9e 33 00 00       	call   f0105648 <mc146818_read>
f01022aa:	c1 e0 08             	shl    $0x8,%eax
f01022ad:	09 f0                	or     %esi,%eax
}
f01022af:	83 c4 10             	add    $0x10,%esp
f01022b2:	5b                   	pop    %ebx
f01022b3:	5e                   	pop    %esi
f01022b4:	5d                   	pop    %ebp
f01022b5:	c3                   	ret    

f01022b6 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01022b6:	55                   	push   %ebp
f01022b7:	89 e5                	mov    %esp,%ebp
f01022b9:	57                   	push   %edi
f01022ba:	56                   	push   %esi
f01022bb:	53                   	push   %ebx
f01022bc:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01022bf:	3c 01                	cmp    $0x1,%al
f01022c1:	19 f6                	sbb    %esi,%esi
f01022c3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01022c9:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01022ca:	8b 15 48 b2 24 f0    	mov    0xf024b248,%edx
f01022d0:	85 d2                	test   %edx,%edx
f01022d2:	75 1c                	jne    f01022f0 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f01022d4:	c7 44 24 08 f0 9b 10 	movl   $0xf0109bf0,0x8(%esp)
f01022db:	f0 
f01022dc:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f01022e3:	00 
f01022e4:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01022eb:	e8 50 dd ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f01022f0:	84 c0                	test   %al,%al
f01022f2:	74 4b                	je     f010233f <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01022f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01022f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01022fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01022fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102300:	89 d0                	mov    %edx,%eax
f0102302:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f0102308:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010230b:	c1 e8 16             	shr    $0x16,%eax
f010230e:	39 c6                	cmp    %eax,%esi
f0102310:	0f 96 c0             	setbe  %al
f0102313:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0102316:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f010231a:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010231c:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102320:	8b 12                	mov    (%edx),%edx
f0102322:	85 d2                	test   %edx,%edx
f0102324:	75 da                	jne    f0102300 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0102326:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102329:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010232f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102332:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102335:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0102337:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010233a:	a3 48 b2 24 f0       	mov    %eax,0xf024b248
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f010233f:	8b 1d 48 b2 24 f0    	mov    0xf024b248,%ebx
f0102345:	eb 63                	jmp    f01023aa <check_page_free_list+0xf4>
f0102347:	89 d8                	mov    %ebx,%eax
f0102349:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f010234f:	c1 f8 03             	sar    $0x3,%eax
f0102352:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0102355:	89 c2                	mov    %eax,%edx
f0102357:	c1 ea 16             	shr    $0x16,%edx
f010235a:	39 d6                	cmp    %edx,%esi
f010235c:	76 4a                	jbe    f01023a8 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010235e:	89 c2                	mov    %eax,%edx
f0102360:	c1 ea 0c             	shr    $0xc,%edx
f0102363:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f0102369:	72 20                	jb     f010238b <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010236b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010236f:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0102376:	f0 
f0102377:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010237e:	00 
f010237f:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0102386:	e8 b5 dc ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f010238b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0102392:	00 
f0102393:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f010239a:	00 
	return (void *)(pa + KERNBASE);
f010239b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023a0:	89 04 24             	mov    %eax,(%esp)
f01023a3:	e8 fe 56 00 00       	call   f0107aa6 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01023a8:	8b 1b                	mov    (%ebx),%ebx
f01023aa:	85 db                	test   %ebx,%ebx
f01023ac:	75 99                	jne    f0102347 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f01023ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01023b3:	e8 3d fe ff ff       	call   f01021f5 <boot_alloc>
f01023b8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01023bb:	8b 15 48 b2 24 f0    	mov    0xf024b248,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01023c1:	8b 0d 90 be 24 f0    	mov    0xf024be90,%ecx
		assert(pp < pages + npages);
f01023c7:	a1 88 be 24 f0       	mov    0xf024be88,%eax
f01023cc:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01023cf:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01023d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01023d5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01023d8:	be 00 00 00 00       	mov    $0x0,%esi
f01023dd:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01023e0:	e9 c4 01 00 00       	jmp    f01025a9 <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01023e5:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f01023e8:	73 24                	jae    f010240e <check_page_free_list+0x158>
f01023ea:	c7 44 24 0c fd a5 10 	movl   $0xf010a5fd,0xc(%esp)
f01023f1:	f0 
f01023f2:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01023f9:	f0 
f01023fa:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0102401:	00 
f0102402:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102409:	e8 32 dc ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010240e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0102411:	72 24                	jb     f0102437 <check_page_free_list+0x181>
f0102413:	c7 44 24 0c 1e a6 10 	movl   $0xf010a61e,0xc(%esp)
f010241a:	f0 
f010241b:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102422:	f0 
f0102423:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010242a:	00 
f010242b:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102432:	e8 09 dc ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0102437:	89 d0                	mov    %edx,%eax
f0102439:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010243c:	a8 07                	test   $0x7,%al
f010243e:	74 24                	je     f0102464 <check_page_free_list+0x1ae>
f0102440:	c7 44 24 0c 14 9c 10 	movl   $0xf0109c14,0xc(%esp)
f0102447:	f0 
f0102448:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010244f:	f0 
f0102450:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0102457:	00 
f0102458:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010245f:	e8 dc db ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102464:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0102467:	c1 e0 0c             	shl    $0xc,%eax
f010246a:	75 24                	jne    f0102490 <check_page_free_list+0x1da>
f010246c:	c7 44 24 0c 32 a6 10 	movl   $0xf010a632,0xc(%esp)
f0102473:	f0 
f0102474:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010247b:	f0 
f010247c:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0102483:	00 
f0102484:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010248b:	e8 b0 db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0102490:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0102495:	75 24                	jne    f01024bb <check_page_free_list+0x205>
f0102497:	c7 44 24 0c 43 a6 10 	movl   $0xf010a643,0xc(%esp)
f010249e:	f0 
f010249f:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01024a6:	f0 
f01024a7:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01024ae:	00 
f01024af:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01024b6:	e8 85 db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01024bb:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01024c0:	75 24                	jne    f01024e6 <check_page_free_list+0x230>
f01024c2:	c7 44 24 0c 48 9c 10 	movl   $0xf0109c48,0xc(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01024d1:	f0 
f01024d2:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01024d9:	00 
f01024da:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01024e1:	e8 5a db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01024e6:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01024eb:	75 24                	jne    f0102511 <check_page_free_list+0x25b>
f01024ed:	c7 44 24 0c 5c a6 10 	movl   $0xf010a65c,0xc(%esp)
f01024f4:	f0 
f01024f5:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01024fc:	f0 
f01024fd:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0102504:	00 
f0102505:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010250c:	e8 2f db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0102511:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0102516:	76 59                	jbe    f0102571 <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102518:	89 c1                	mov    %eax,%ecx
f010251a:	c1 e9 0c             	shr    $0xc,%ecx
f010251d:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102520:	77 20                	ja     f0102542 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102522:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102526:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f010252d:	f0 
f010252e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102535:	00 
f0102536:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f010253d:	e8 fe da ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102542:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0102548:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f010254b:	76 24                	jbe    f0102571 <check_page_free_list+0x2bb>
f010254d:	c7 44 24 0c 6c 9c 10 	movl   $0xf0109c6c,0xc(%esp)
f0102554:	f0 
f0102555:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010255c:	f0 
f010255d:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0102564:	00 
f0102565:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010256c:	e8 cf da ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0102571:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102576:	75 24                	jne    f010259c <check_page_free_list+0x2e6>
f0102578:	c7 44 24 0c 76 a6 10 	movl   $0xf010a676,0xc(%esp)
f010257f:	f0 
f0102580:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102587:	f0 
f0102588:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010258f:	00 
f0102590:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102597:	e8 a4 da ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010259c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01025a1:	77 03                	ja     f01025a6 <check_page_free_list+0x2f0>
			++nfree_basemem;
f01025a3:	46                   	inc    %esi
f01025a4:	eb 01                	jmp    f01025a7 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f01025a6:	43                   	inc    %ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01025a7:	8b 12                	mov    (%edx),%edx
f01025a9:	85 d2                	test   %edx,%edx
f01025ab:	0f 85 34 fe ff ff    	jne    f01023e5 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01025b1:	85 f6                	test   %esi,%esi
f01025b3:	7f 24                	jg     f01025d9 <check_page_free_list+0x323>
f01025b5:	c7 44 24 0c 93 a6 10 	movl   $0xf010a693,0xc(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01025c4:	f0 
f01025c5:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f01025cc:	00 
f01025cd:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01025d9:	85 db                	test   %ebx,%ebx
f01025db:	7f 24                	jg     f0102601 <check_page_free_list+0x34b>
f01025dd:	c7 44 24 0c a5 a6 10 	movl   $0xf010a6a5,0xc(%esp)
f01025e4:	f0 
f01025e5:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01025ec:	f0 
f01025ed:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01025f4:	00 
f01025f5:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01025fc:	e8 3f da ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0102601:	c7 04 24 b4 9c 10 f0 	movl   $0xf0109cb4,(%esp)
f0102608:	e8 81 31 00 00       	call   f010578e <cprintf>
}
f010260d:	83 c4 4c             	add    $0x4c,%esp
f0102610:	5b                   	pop    %ebx
f0102611:	5e                   	pop    %esi
f0102612:	5f                   	pop    %edi
f0102613:	5d                   	pop    %ebp
f0102614:	c3                   	ret    

f0102615 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0102615:	55                   	push   %ebp
f0102616:	89 e5                	mov    %esp,%ebp
f0102618:	56                   	push   %esi
f0102619:	53                   	push   %ebx
f010261a:	83 ec 10             	sub    $0x10,%esp
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	size_t i;
	pages[0].pp_ref = 1;
f010261d:	a1 90 be 24 f0       	mov    0xf024be90,%eax
f0102622:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0102628:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	size_t IOPAGE =  PGNUM(IOPHYSMEM);
	size_t EXTPAGE = PGNUM(EXTPHYSMEM);
	size_t FREEPAGE = PGNUM(PADDR(boot_alloc(0)));
f010262e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102633:	e8 bd fb ff ff       	call   f01021f5 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102638:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010263d:	77 20                	ja     f010265f <page_init+0x4a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010263f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102643:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f010264a:	f0 
f010264b:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0102652:	00 
f0102653:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010265a:	e8 e1 d9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010265f:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0102665:	c1 eb 0c             	shr    $0xc,%ebx
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
f0102668:	83 3d 48 b2 24 f0 00 	cmpl   $0x0,0xf024b248
f010266f:	74 24                	je     f0102695 <page_init+0x80>
f0102671:	c7 44 24 0c b6 a6 10 	movl   $0xf010a6b6,0xc(%esp)
f0102678:	f0 
f0102679:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102680:	f0 
f0102681:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f0102688:	00 
f0102689:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102690:	e8 ab d9 ff ff       	call   f0100040 <_panic>
 	assert(npages_basemem == IOPAGE);
f0102695:	81 3d 40 b2 24 f0 a0 	cmpl   $0xa0,0xf024b240
f010269c:	00 00 00 
f010269f:	74 24                	je     f01026c5 <page_init+0xb0>
f01026a1:	c7 44 24 0c cd a6 10 	movl   $0xf010a6cd,0xc(%esp)
f01026a8:	f0 
f01026a9:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01026b0:	f0 
f01026b1:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f01026b8:	00 
f01026b9:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01026c0:	e8 7b d9 ff ff       	call   f0100040 <_panic>
f01026c5:	be 00 00 00 00       	mov    $0x0,%esi
f01026ca:	b8 01 00 00 00       	mov    $0x1,%eax
    for (i = 1; i < IOPAGE; i++) {
		// cprintf("%x %x\n",i,PGNUM(MPENTRY_PADDR));
		if (i == PGNUM(MPENTRY_PADDR)){
f01026cf:	83 f8 07             	cmp    $0x7,%eax
f01026d2:	75 16                	jne    f01026ea <page_init+0xd5>
			pages[i].pp_ref = 1;
f01026d4:	8b 15 90 be 24 f0    	mov    0xf024be90,%edx
f01026da:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link = NULL;
f01026e0:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
 	assert(npages_basemem == IOPAGE);
    for (i = 1; i < IOPAGE; i++) {
f01026e7:	40                   	inc    %eax
f01026e8:	eb e5                	jmp    f01026cf <page_init+0xba>
		if (i == PGNUM(MPENTRY_PADDR)){
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
		else {
        	pages[i].pp_ref = 0;
f01026ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01026f1:	89 d1                	mov    %edx,%ecx
f01026f3:	03 0d 90 be 24 f0    	add    0xf024be90,%ecx
f01026f9:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        	pages[i].pp_link = page_free_list;
f01026ff:	89 31                	mov    %esi,(%ecx)
        	page_free_list = &pages[i];
f0102701:	89 d6                	mov    %edx,%esi
f0102703:	03 35 90 be 24 f0    	add    0xf024be90,%esi
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
 	assert(npages_basemem == IOPAGE);
    for (i = 1; i < IOPAGE; i++) {
f0102709:	40                   	inc    %eax
f010270a:	3d a0 00 00 00       	cmp    $0xa0,%eax
f010270f:	75 be                	jne    f01026cf <page_init+0xba>
f0102711:	89 35 48 b2 24 f0    	mov    %esi,0xf024b248
f0102717:	66 b8 00 05          	mov    $0x500,%ax
        	pages[i].pp_link = page_free_list;
        	page_free_list = &pages[i];
		}
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
f010271b:	89 c2                	mov    %eax,%edx
f010271d:	03 15 90 be 24 f0    	add    0xf024be90,%edx
f0102723:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f0102729:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f010272f:	83 c0 08             	add    $0x8,%eax
        	pages[i].pp_ref = 0;
        	pages[i].pp_link = page_free_list;
        	page_free_list = &pages[i];
		}
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
f0102732:	3d 00 08 00 00       	cmp    $0x800,%eax
f0102737:	75 e2                	jne    f010271b <page_init+0x106>
f0102739:	66 b8 00 01          	mov    $0x100,%ax
f010273d:	eb 1a                	jmp    f0102759 <page_init+0x144>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
f010273f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102746:	03 15 90 be 24 f0    	add    0xf024be90,%edx
f010274c:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f0102752:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
f0102758:	40                   	inc    %eax
f0102759:	39 d8                	cmp    %ebx,%eax
f010275b:	72 e2                	jb     f010273f <page_init+0x12a>
f010275d:	8b 0d 48 b2 24 f0    	mov    0xf024b248,%ecx
f0102763:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f010276a:	eb 1c                	jmp    f0102788 <page_init+0x173>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
        pages[i].pp_ref = 0;
f010276c:	89 c2                	mov    %eax,%edx
f010276e:	03 15 90 be 24 f0    	add    0xf024be90,%edx
f0102774:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f010277a:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f010277c:	89 c1                	mov    %eax,%ecx
f010277e:	03 0d 90 be 24 f0    	add    0xf024be90,%ecx
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
f0102784:	43                   	inc    %ebx
f0102785:	83 c0 08             	add    $0x8,%eax
f0102788:	3b 1d 88 be 24 f0    	cmp    0xf024be88,%ebx
f010278e:	72 dc                	jb     f010276c <page_init+0x157>
f0102790:	89 0d 48 b2 24 f0    	mov    %ecx,0xf024b248
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	return;
}
f0102796:	83 c4 10             	add    $0x10,%esp
f0102799:	5b                   	pop    %ebx
f010279a:	5e                   	pop    %esi
f010279b:	5d                   	pop    %ebp
f010279c:	c3                   	ret    

f010279d <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010279d:	55                   	push   %ebp
f010279e:	89 e5                	mov    %esp,%ebp
f01027a0:	53                   	push   %ebx
f01027a1:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	// assert(page_free_list != NULL);
	// cprintf("page_alloc %x\n",page_free_list);
	// cprintf("page_alloc %x\n",page_free_list);
	if (page_free_list == NULL)return NULL;
f01027a4:	8b 1d 48 b2 24 f0    	mov    0xf024b248,%ebx
f01027aa:	85 db                	test   %ebx,%ebx
f01027ac:	74 6b                	je     f0102819 <page_alloc+0x7c>
	struct PageInfo *alloc_page = page_free_list;
	page_free_list = alloc_page->pp_link;
f01027ae:	8b 03                	mov    (%ebx),%eax
f01027b0:	a3 48 b2 24 f0       	mov    %eax,0xf024b248
	alloc_page->pp_link = NULL;
f01027b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO){
f01027bb:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01027bf:	74 58                	je     f0102819 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027c1:	89 d8                	mov    %ebx,%eax
f01027c3:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f01027c9:	c1 f8 03             	sar    $0x3,%eax
f01027cc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027cf:	89 c2                	mov    %eax,%edx
f01027d1:	c1 ea 0c             	shr    $0xc,%edx
f01027d4:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f01027da:	72 20                	jb     f01027fc <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027e0:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f01027e7:	f0 
f01027e8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027ef:	00 
f01027f0:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f01027f7:	e8 44 d8 ff ff       	call   f0100040 <_panic>
		memset(page2kva(alloc_page),'\0',PGSIZE);
f01027fc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102803:	00 
f0102804:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010280b:	00 
	return (void *)(pa + KERNBASE);
f010280c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102811:	89 04 24             	mov    %eax,(%esp)
f0102814:	e8 8d 52 00 00       	call   f0107aa6 <memset>
	}
	return alloc_page;
}
f0102819:	89 d8                	mov    %ebx,%eax
f010281b:	83 c4 14             	add    $0x14,%esp
f010281e:	5b                   	pop    %ebx
f010281f:	5d                   	pop    %ebp
f0102820:	c3                   	ret    

f0102821 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0102821:	55                   	push   %ebp
f0102822:	89 e5                	mov    %esp,%ebp
f0102824:	83 ec 18             	sub    $0x18,%esp
f0102827:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link !=NULL)
f010282a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010282f:	75 05                	jne    f0102836 <page_free+0x15>
f0102831:	83 38 00             	cmpl   $0x0,(%eax)
f0102834:	74 1c                	je     f0102852 <page_free+0x31>
		panic("Something went wrong at page_free");
f0102836:	c7 44 24 08 d8 9c 10 	movl   $0xf0109cd8,0x8(%esp)
f010283d:	f0 
f010283e:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f0102845:	00 
f0102846:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010284d:	e8 ee d7 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0102852:	8b 15 48 b2 24 f0    	mov    0xf024b248,%edx
f0102858:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010285a:	a3 48 b2 24 f0       	mov    %eax,0xf024b248
	return;
}
f010285f:	c9                   	leave  
f0102860:	c3                   	ret    

f0102861 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0102861:	55                   	push   %ebp
f0102862:	89 e5                	mov    %esp,%ebp
f0102864:	83 ec 18             	sub    $0x18,%esp
f0102867:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010286a:	8b 50 04             	mov    0x4(%eax),%edx
f010286d:	4a                   	dec    %edx
f010286e:	66 89 50 04          	mov    %dx,0x4(%eax)
f0102872:	66 85 d2             	test   %dx,%dx
f0102875:	75 08                	jne    f010287f <page_decref+0x1e>
		page_free(pp);
f0102877:	89 04 24             	mov    %eax,(%esp)
f010287a:	e8 a2 ff ff ff       	call   f0102821 <page_free>
}
f010287f:	c9                   	leave  
f0102880:	c3                   	ret    

f0102881 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0102881:	55                   	push   %ebp
f0102882:	89 e5                	mov    %esp,%ebp
f0102884:	56                   	push   %esi
f0102885:	53                   	push   %ebx
f0102886:	83 ec 10             	sub    $0x10,%esp
f0102889:	8b 75 0c             	mov    0xc(%ebp),%esi
f010288c:	8b 45 10             	mov    0x10(%ebp),%eax
	// Fill this function in
	if (!((create == 0) || (create == 1)))
f010288f:	83 f8 01             	cmp    $0x1,%eax
f0102892:	76 1c                	jbe    f01028b0 <pgdir_walk+0x2f>
		panic("pgdir_walk: create is wrong!!!");
f0102894:	c7 44 24 08 fc 9c 10 	movl   $0xf0109cfc,0x8(%esp)
f010289b:	f0 
f010289c:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f01028a3:	00 
f01028a4:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01028ab:	e8 90 d7 ff ff       	call   f0100040 <_panic>
	
	pde_t *pde = &pgdir[PDX(va)];
f01028b0:	89 f1                	mov    %esi,%ecx
f01028b2:	c1 e9 16             	shr    $0x16,%ecx
f01028b5:	8b 55 08             	mov    0x8(%ebp),%edx
f01028b8:	8d 1c 8a             	lea    (%edx,%ecx,4),%ebx
	if ((*pde & PTE_P) == 0){
f01028bb:	f6 03 01             	testb  $0x1,(%ebx)
f01028be:	75 29                	jne    f01028e9 <pgdir_walk+0x68>
		if (create == false){
f01028c0:	85 c0                	test   %eax,%eax
f01028c2:	74 6b                	je     f010292f <pgdir_walk+0xae>
			return NULL;
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
f01028c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01028cb:	e8 cd fe ff ff       	call   f010279d <page_alloc>
			if (page==NULL) return NULL;
f01028d0:	85 c0                	test   %eax,%eax
f01028d2:	74 62                	je     f0102936 <pgdir_walk+0xb5>
			page->pp_ref++;
f01028d4:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028d8:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f01028de:	c1 f8 03             	sar    $0x3,%eax
f01028e1:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f01028e4:	83 c8 07             	or     $0x7,%eax
f01028e7:	89 03                	mov    %eax,(%ebx)
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
f01028e9:	8b 03                	mov    (%ebx),%eax
f01028eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028f0:	89 c2                	mov    %eax,%edx
f01028f2:	c1 ea 0c             	shr    $0xc,%edx
f01028f5:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f01028fb:	72 20                	jb     f010291d <pgdir_walk+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102901:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0102908:	f0 
f0102909:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
f0102910:	00 
f0102911:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102918:	e8 23 d7 ff ff       	call   f0100040 <_panic>
	return &pgtable[PTX(va)];
f010291d:	c1 ee 0a             	shr    $0xa,%esi
f0102920:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0102926:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010292d:	eb 0c                	jmp    f010293b <pgdir_walk+0xba>
		panic("pgdir_walk: create is wrong!!!");
	
	pde_t *pde = &pgdir[PDX(va)];
	if ((*pde & PTE_P) == 0){
		if (create == false){
			return NULL;
f010292f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102934:	eb 05                	jmp    f010293b <pgdir_walk+0xba>
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
			if (page==NULL) return NULL;
f0102936:	b8 00 00 00 00       	mov    $0x0,%eax
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	return &pgtable[PTX(va)];
}
f010293b:	83 c4 10             	add    $0x10,%esp
f010293e:	5b                   	pop    %ebx
f010293f:	5e                   	pop    %esi
f0102940:	5d                   	pop    %ebp
f0102941:	c3                   	ret    

f0102942 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0102942:	55                   	push   %ebp
f0102943:	89 e5                	mov    %esp,%ebp
f0102945:	57                   	push   %edi
f0102946:	56                   	push   %esi
f0102947:	53                   	push   %ebx
f0102948:	83 ec 2c             	sub    $0x2c,%esp
f010294b:	89 c6                	mov    %eax,%esi
f010294d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102950:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// assert(size % PGSIZE == 0);
	if (size % PGSIZE != 0){
f0102953:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f0102959:	74 1c                	je     f0102977 <boot_map_region+0x35>
		panic("boot_map_region: size % PGSIZE != 0");
f010295b:	c7 44 24 08 1c 9d 10 	movl   $0xf0109d1c,0x8(%esp)
f0102962:	f0 
f0102963:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
f010296a:	00 
f010296b:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102972:	e8 c9 d6 ff ff       	call   f0100040 <_panic>
	}
	if (PTE_ADDR(va) != va)
f0102977:	89 d1                	mov    %edx,%ecx
f0102979:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010297f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102982:	39 d1                	cmp    %edx,%ecx
f0102984:	74 1c                	je     f01029a2 <boot_map_region+0x60>
		panic("boot_map_region: va is not page_aligned");
f0102986:	c7 44 24 08 40 9d 10 	movl   $0xf0109d40,0x8(%esp)
f010298d:	f0 
f010298e:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
f0102995:	00 
f0102996:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010299d:	e8 9e d6 ff ff       	call   f0100040 <_panic>
	if (PTE_ADDR(pa) != pa)
f01029a2:	89 c7                	mov    %eax,%edi
f01029a4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01029aa:	39 c7                	cmp    %eax,%edi
f01029ac:	74 4b                	je     f01029f9 <boot_map_region+0xb7>
		panic("boot_map_region: pa is not page_aligned");
f01029ae:	c7 44 24 08 68 9d 10 	movl   $0xf0109d68,0x8(%esp)
f01029b5:	f0 
f01029b6:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
f01029bd:	00 
f01029be:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01029c5:	e8 76 d6 ff ff       	call   f0100040 <_panic>
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f01029ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01029d1:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01029d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029d5:	01 d8                	add    %ebx,%eax
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f01029d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01029db:	89 34 24             	mov    %esi,(%esp)
f01029de:	e8 9e fe ff ff       	call   f0102881 <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01029e3:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f01029e6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01029ec:	0b 55 dc             	or     -0x24(%ebp),%edx
f01029ef:	89 10                	mov    %edx,(%eax)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f01029f1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029f7:	eb 0e                	jmp    f0102a07 <boot_map_region+0xc5>
	if (size % PGSIZE != 0){
		panic("boot_map_region: size % PGSIZE != 0");
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
f01029f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f01029fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a01:	83 c8 01             	or     $0x1,%eax
f0102a04:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f0102a07:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102a0a:	72 be                	jb     f01029ca <boot_map_region+0x88>
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
	}
}
f0102a0c:	83 c4 2c             	add    $0x2c,%esp
f0102a0f:	5b                   	pop    %ebx
f0102a10:	5e                   	pop    %esi
f0102a11:	5f                   	pop    %edi
f0102a12:	5d                   	pop    %ebp
f0102a13:	c3                   	ret    

f0102a14 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0102a14:	55                   	push   %ebp
f0102a15:	89 e5                	mov    %esp,%ebp
f0102a17:	53                   	push   %ebx
f0102a18:	83 ec 14             	sub    $0x14,%esp
f0102a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
f0102a1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a25:	00 
f0102a26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a30:	89 04 24             	mov    %eax,(%esp)
f0102a33:	e8 49 fe ff ff       	call   f0102881 <pgdir_walk>
	if (pte == NULL) return NULL;
f0102a38:	85 c0                	test   %eax,%eax
f0102a3a:	74 3a                	je     f0102a76 <page_lookup+0x62>
	if (pte_store != NULL)
f0102a3c:	85 db                	test   %ebx,%ebx
f0102a3e:	74 02                	je     f0102a42 <page_lookup+0x2e>
		*pte_store = pte;
f0102a40:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));
f0102a42:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a44:	c1 e8 0c             	shr    $0xc,%eax
f0102a47:	3b 05 88 be 24 f0    	cmp    0xf024be88,%eax
f0102a4d:	72 1c                	jb     f0102a6b <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0102a4f:	c7 44 24 08 90 9d 10 	movl   $0xf0109d90,0x8(%esp)
f0102a56:	f0 
f0102a57:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0102a5e:	00 
f0102a5f:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0102a66:	e8 d5 d5 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0102a6b:	c1 e0 03             	shl    $0x3,%eax
f0102a6e:	03 05 90 be 24 f0    	add    0xf024be90,%eax
f0102a74:	eb 05                	jmp    f0102a7b <page_lookup+0x67>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
	if (pte == NULL) return NULL;
f0102a76:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store != NULL)
		*pte_store = pte;
	return pa2page(PTE_ADDR(*pte));
}
f0102a7b:	83 c4 14             	add    $0x14,%esp
f0102a7e:	5b                   	pop    %ebx
f0102a7f:	5d                   	pop    %ebp
f0102a80:	c3                   	ret    

f0102a81 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102a81:	55                   	push   %ebp
f0102a82:	89 e5                	mov    %esp,%ebp
f0102a84:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0102a87:	e8 48 56 00 00       	call   f01080d4 <cpunum>
f0102a8c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102a93:	29 c2                	sub    %eax,%edx
f0102a95:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0102a98:	83 3c 85 28 c0 24 f0 	cmpl   $0x0,-0xfdb3fd8(,%eax,4)
f0102a9f:	00 
f0102aa0:	74 20                	je     f0102ac2 <tlb_invalidate+0x41>
f0102aa2:	e8 2d 56 00 00       	call   f01080d4 <cpunum>
f0102aa7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102aae:	29 c2                	sub    %eax,%edx
f0102ab0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0102ab3:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0102aba:	8b 55 08             	mov    0x8(%ebp),%edx
f0102abd:	39 50 60             	cmp    %edx,0x60(%eax)
f0102ac0:	75 06                	jne    f0102ac8 <tlb_invalidate+0x47>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ac5:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0102ac8:	c9                   	leave  
f0102ac9:	c3                   	ret    

f0102aca <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0102aca:	55                   	push   %ebp
f0102acb:	89 e5                	mov    %esp,%ebp
f0102acd:	56                   	push   %esi
f0102ace:	53                   	push   %ebx
f0102acf:	83 ec 20             	sub    $0x20,%esp
f0102ad2:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ad5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0102ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102adb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102adf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ae3:	89 34 24             	mov    %esi,(%esp)
f0102ae6:	e8 29 ff ff ff       	call   f0102a14 <page_lookup>
	if(page != NULL){
f0102aeb:	85 c0                	test   %eax,%eax
f0102aed:	74 1d                	je     f0102b0c <page_remove+0x42>
		*pte = 0;
f0102aef:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102af2:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(page);
f0102af8:	89 04 24             	mov    %eax,(%esp)
f0102afb:	e8 61 fd ff ff       	call   f0102861 <page_decref>
		tlb_invalidate(pgdir, va);
f0102b00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b04:	89 34 24             	mov    %esi,(%esp)
f0102b07:	e8 75 ff ff ff       	call   f0102a81 <tlb_invalidate>
	}
	return;
}
f0102b0c:	83 c4 20             	add    $0x20,%esp
f0102b0f:	5b                   	pop    %ebx
f0102b10:	5e                   	pop    %esi
f0102b11:	5d                   	pop    %ebp
f0102b12:	c3                   	ret    

f0102b13 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0102b13:	55                   	push   %ebp
f0102b14:	89 e5                	mov    %esp,%ebp
f0102b16:	57                   	push   %edi
f0102b17:	56                   	push   %esi
f0102b18:	53                   	push   %ebx
f0102b19:	83 ec 1c             	sub    $0x1c,%esp
f0102b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102b1f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
f0102b22:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b29:	00 
f0102b2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b31:	89 04 24             	mov    %eax,(%esp)
f0102b34:	e8 48 fd ff ff       	call   f0102881 <pgdir_walk>
f0102b39:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0102b3b:	85 c0                	test   %eax,%eax
f0102b3d:	74 48                	je     f0102b87 <page_insert+0x74>
    pp->pp_ref++;
f0102b3f:	66 ff 46 04          	incw   0x4(%esi)
    if ((*pte & PTE_P) != 0) {
f0102b43:	f6 00 01             	testb  $0x1,(%eax)
f0102b46:	74 1e                	je     f0102b66 <page_insert+0x53>
        page_remove(pgdir,va);
f0102b48:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b4f:	89 04 24             	mov    %eax,(%esp)
f0102b52:	e8 73 ff ff ff       	call   f0102aca <page_remove>
        tlb_invalidate(pgdir,va);
f0102b57:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b5e:	89 04 24             	mov    %eax,(%esp)
f0102b61:	e8 1b ff ff ff       	call   f0102a81 <tlb_invalidate>
    }
    *pte = page2pa(pp) | perm | PTE_P;
f0102b66:	8b 55 14             	mov    0x14(%ebp),%edx
f0102b69:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b6c:	2b 35 90 be 24 f0    	sub    0xf024be90,%esi
f0102b72:	c1 fe 03             	sar    $0x3,%esi
f0102b75:	89 f0                	mov    %esi,%eax
f0102b77:	c1 e0 0c             	shl    $0xc,%eax
f0102b7a:	89 d6                	mov    %edx,%esi
f0102b7c:	09 c6                	or     %eax,%esi
f0102b7e:	89 33                	mov    %esi,(%ebx)
	return 0;
f0102b80:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b85:	eb 05                	jmp    f0102b8c <page_insert+0x79>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
    if (pte == NULL) return -E_NO_MEM;
f0102b87:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir,va);
        tlb_invalidate(pgdir,va);
    }
    *pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0102b8c:	83 c4 1c             	add    $0x1c,%esp
f0102b8f:	5b                   	pop    %ebx
f0102b90:	5e                   	pop    %esi
f0102b91:	5f                   	pop    %edi
f0102b92:	5d                   	pop    %ebp
f0102b93:	c3                   	ret    

f0102b94 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0102b94:	55                   	push   %ebp
f0102b95:	89 e5                	mov    %esp,%ebp
f0102b97:	53                   	push   %ebx
f0102b98:	83 ec 14             	sub    $0x14,%esp
f0102b9b:	8b 45 08             	mov    0x8(%ebp),%eax
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// pa = ROUNDDOWN(pa,PGSIZE);
	if (PGOFF(base))
f0102b9e:	8b 15 5c f1 14 f0    	mov    0xf014f15c,%edx
f0102ba4:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102baa:	74 1c                	je     f0102bc8 <mmio_map_region+0x34>
		panic("mmio_map_region: base error!");
f0102bac:	c7 44 24 08 e6 a6 10 	movl   $0xf010a6e6,0x8(%esp)
f0102bb3:	f0 
f0102bb4:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0102bbb:	00 
f0102bbc:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102bc3:	e8 78 d4 ff ff       	call   f0100040 <_panic>
	size = ROUNDUP(pa + size,PGSIZE);
f0102bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102bcb:	8d 9c 08 ff 0f 00 00 	lea    0xfff(%eax,%ecx,1),%ebx
f0102bd2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa,PGSIZE);
f0102bd8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size -= pa;	
f0102bdd:	29 c3                	sub    %eax,%ebx
	if (size > PTSIZE || base + size >= MMIOLIM)
f0102bdf:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f0102be5:	77 0b                	ja     f0102bf2 <mmio_map_region+0x5e>
f0102be7:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0102bea:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0102bf0:	76 1c                	jbe    f0102c0e <mmio_map_region+0x7a>
		panic("mmio_map_region: error!");
f0102bf2:	c7 44 24 08 03 a7 10 	movl   $0xf010a703,0x8(%esp)
f0102bf9:	f0 
f0102bfa:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0102c01:	00 
f0102c02:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102c09:	e8 32 d4 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir,base,size,pa,PTE_PCD|PTE_PWT|PTE_W);
f0102c0e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0102c15:	00 
f0102c16:	89 04 24             	mov    %eax,(%esp)
f0102c19:	89 d9                	mov    %ebx,%ecx
f0102c1b:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0102c20:	e8 1d fd ff ff       	call   f0102942 <boot_map_region>
	base += size;
f0102c25:	a1 5c f1 14 f0       	mov    0xf014f15c,%eax
f0102c2a:	01 c3                	add    %eax,%ebx
f0102c2c:	89 1d 5c f1 14 f0    	mov    %ebx,0xf014f15c
	return (void*)(base-size);
	panic("mmio_map_region not implemented");
}
f0102c32:	83 c4 14             	add    $0x14,%esp
f0102c35:	5b                   	pop    %ebx
f0102c36:	5d                   	pop    %ebp
f0102c37:	c3                   	ret    

f0102c38 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0102c38:	55                   	push   %ebp
f0102c39:	89 e5                	mov    %esp,%ebp
f0102c3b:	57                   	push   %edi
f0102c3c:	56                   	push   %esi
f0102c3d:	53                   	push   %ebx
f0102c3e:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0102c41:	b8 15 00 00 00       	mov    $0x15,%eax
f0102c46:	e8 42 f6 ff ff       	call   f010228d <nvram_read>
f0102c4b:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0102c4d:	b8 17 00 00 00       	mov    $0x17,%eax
f0102c52:	e8 36 f6 ff ff       	call   f010228d <nvram_read>
f0102c57:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0102c59:	b8 34 00 00 00       	mov    $0x34,%eax
f0102c5e:	e8 2a f6 ff ff       	call   f010228d <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0102c63:	c1 e0 06             	shl    $0x6,%eax
f0102c66:	74 08                	je     f0102c70 <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f0102c68:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f0102c6e:	eb 0e                	jmp    f0102c7e <mem_init+0x46>
	else if (extmem)
f0102c70:	85 f6                	test   %esi,%esi
f0102c72:	74 08                	je     f0102c7c <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0102c74:	81 c6 00 04 00 00    	add    $0x400,%esi
f0102c7a:	eb 02                	jmp    f0102c7e <mem_init+0x46>
	else
		totalmem = basemem;
f0102c7c:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f0102c7e:	89 f0                	mov    %esi,%eax
f0102c80:	c1 e8 02             	shr    $0x2,%eax
f0102c83:	a3 88 be 24 f0       	mov    %eax,0xf024be88
	npages_basemem = basemem / (PGSIZE / 1024);
f0102c88:	89 d8                	mov    %ebx,%eax
f0102c8a:	c1 e8 02             	shr    $0x2,%eax
f0102c8d:	a3 40 b2 24 f0       	mov    %eax,0xf024b240
	// cprintf("%u\n",ext16mem);
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0102c92:	89 f0                	mov    %esi,%eax
f0102c94:	29 d8                	sub    %ebx,%eax
f0102c96:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c9a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102c9e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ca2:	c7 04 24 b0 9d 10 f0 	movl   $0xf0109db0,(%esp)
f0102ca9:	e8 e0 2a 00 00       	call   f010578e <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102cae:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102cb3:	e8 3d f5 ff ff       	call   f01021f5 <boot_alloc>
f0102cb8:	a3 8c be 24 f0       	mov    %eax,0xf024be8c
	memset(kern_pgdir, 0, PGSIZE);
f0102cbd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cc4:	00 
f0102cc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102ccc:	00 
f0102ccd:	89 04 24             	mov    %eax,(%esp)
f0102cd0:	e8 d1 4d 00 00       	call   f0107aa6 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0102cd5:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cda:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cdf:	77 20                	ja     f0102d01 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ce1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ce5:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f0102cec:	f0 
f0102ced:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
f0102cf4:	00 
f0102cf5:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102cfc:	e8 3f d3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102d01:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102d07:	83 ca 05             	or     $0x5,%edx
f0102d0a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);
f0102d10:	a1 88 be 24 f0       	mov    0xf024be88,%eax
f0102d15:	c1 e0 03             	shl    $0x3,%eax
f0102d18:	e8 d8 f4 ff ff       	call   f01021f5 <boot_alloc>
f0102d1d:	a3 90 be 24 f0       	mov    %eax,0xf024be90
	// cprintf("npages: %x\n",npages);
	// cprintf("pages: %x\n",pages);
	memset(pages,0,sizeof(struct PageInfo) * npages);
f0102d22:	8b 15 88 be 24 f0    	mov    0xf024be88,%edx
f0102d28:	c1 e2 03             	shl    $0x3,%edx
f0102d2b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102d2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d36:	00 
f0102d37:	89 04 24             	mov    %eax,(%esp)
f0102d3a:	e8 67 4d 00 00       	call   f0107aa6 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f0102d3f:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0102d44:	e8 ac f4 ff ff       	call   f01021f5 <boot_alloc>
f0102d49:	a3 50 b2 24 f0       	mov    %eax,0xf024b250
	memset(envs, 0 ,sizeof(struct Env) * NENV);
f0102d4e:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0102d55:	00 
f0102d56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d5d:	00 
f0102d5e:	89 04 24             	mov    %eax,(%esp)
f0102d61:	e8 40 4d 00 00       	call   f0107aa6 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0102d66:	e8 aa f8 ff ff       	call   f0102615 <page_init>

	check_page_free_list(1);
f0102d6b:	b8 01 00 00 00       	mov    $0x1,%eax
f0102d70:	e8 41 f5 ff ff       	call   f01022b6 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0102d75:	83 3d 90 be 24 f0 00 	cmpl   $0x0,0xf024be90
f0102d7c:	75 1c                	jne    f0102d9a <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0102d7e:	c7 44 24 08 1b a7 10 	movl   $0xf010a71b,0x8(%esp)
f0102d85:	f0 
f0102d86:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f0102d8d:	00 
f0102d8e:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102d95:	e8 a6 d2 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102d9a:	a1 48 b2 24 f0       	mov    0xf024b248,%eax
f0102d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102da4:	eb 03                	jmp    f0102da9 <mem_init+0x171>
		++nfree;
f0102da6:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102da7:	8b 00                	mov    (%eax),%eax
f0102da9:	85 c0                	test   %eax,%eax
f0102dab:	75 f9                	jne    f0102da6 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102db4:	e8 e4 f9 ff ff       	call   f010279d <page_alloc>
f0102db9:	89 c6                	mov    %eax,%esi
f0102dbb:	85 c0                	test   %eax,%eax
f0102dbd:	75 24                	jne    f0102de3 <mem_init+0x1ab>
f0102dbf:	c7 44 24 0c 36 a7 10 	movl   $0xf010a736,0xc(%esp)
f0102dc6:	f0 
f0102dc7:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102dce:	f0 
f0102dcf:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0102dd6:	00 
f0102dd7:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102dde:	e8 5d d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dea:	e8 ae f9 ff ff       	call   f010279d <page_alloc>
f0102def:	89 c7                	mov    %eax,%edi
f0102df1:	85 c0                	test   %eax,%eax
f0102df3:	75 24                	jne    f0102e19 <mem_init+0x1e1>
f0102df5:	c7 44 24 0c 4c a7 10 	movl   $0xf010a74c,0xc(%esp)
f0102dfc:	f0 
f0102dfd:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102e04:	f0 
f0102e05:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0102e0c:	00 
f0102e0d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102e14:	e8 27 d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e20:	e8 78 f9 ff ff       	call   f010279d <page_alloc>
f0102e25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e28:	85 c0                	test   %eax,%eax
f0102e2a:	75 24                	jne    f0102e50 <mem_init+0x218>
f0102e2c:	c7 44 24 0c 62 a7 10 	movl   $0xf010a762,0xc(%esp)
f0102e33:	f0 
f0102e34:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102e3b:	f0 
f0102e3c:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0102e43:	00 
f0102e44:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102e4b:	e8 f0 d1 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102e50:	39 fe                	cmp    %edi,%esi
f0102e52:	75 24                	jne    f0102e78 <mem_init+0x240>
f0102e54:	c7 44 24 0c 78 a7 10 	movl   $0xf010a778,0xc(%esp)
f0102e5b:	f0 
f0102e5c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102e63:	f0 
f0102e64:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0102e6b:	00 
f0102e6c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102e73:	e8 c8 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102e78:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102e7b:	74 05                	je     f0102e82 <mem_init+0x24a>
f0102e7d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102e80:	75 24                	jne    f0102ea6 <mem_init+0x26e>
f0102e82:	c7 44 24 0c ec 9d 10 	movl   $0xf0109dec,0xc(%esp)
f0102e89:	f0 
f0102e8a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102e91:	f0 
f0102e92:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0102e99:	00 
f0102e9a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102ea1:	e8 9a d1 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ea6:	8b 15 90 be 24 f0    	mov    0xf024be90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102eac:	a1 88 be 24 f0       	mov    0xf024be88,%eax
f0102eb1:	c1 e0 0c             	shl    $0xc,%eax
f0102eb4:	89 f1                	mov    %esi,%ecx
f0102eb6:	29 d1                	sub    %edx,%ecx
f0102eb8:	c1 f9 03             	sar    $0x3,%ecx
f0102ebb:	c1 e1 0c             	shl    $0xc,%ecx
f0102ebe:	39 c1                	cmp    %eax,%ecx
f0102ec0:	72 24                	jb     f0102ee6 <mem_init+0x2ae>
f0102ec2:	c7 44 24 0c 8a a7 10 	movl   $0xf010a78a,0xc(%esp)
f0102ec9:	f0 
f0102eca:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102ed1:	f0 
f0102ed2:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0102ed9:	00 
f0102eda:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102ee1:	e8 5a d1 ff ff       	call   f0100040 <_panic>
f0102ee6:	89 f9                	mov    %edi,%ecx
f0102ee8:	29 d1                	sub    %edx,%ecx
f0102eea:	c1 f9 03             	sar    $0x3,%ecx
f0102eed:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0102ef0:	39 c8                	cmp    %ecx,%eax
f0102ef2:	77 24                	ja     f0102f18 <mem_init+0x2e0>
f0102ef4:	c7 44 24 0c a7 a7 10 	movl   $0xf010a7a7,0xc(%esp)
f0102efb:	f0 
f0102efc:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102f03:	f0 
f0102f04:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f0102f0b:	00 
f0102f0c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102f13:	e8 28 d1 ff ff       	call   f0100040 <_panic>
f0102f18:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102f1b:	29 d1                	sub    %edx,%ecx
f0102f1d:	89 ca                	mov    %ecx,%edx
f0102f1f:	c1 fa 03             	sar    $0x3,%edx
f0102f22:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0102f25:	39 d0                	cmp    %edx,%eax
f0102f27:	77 24                	ja     f0102f4d <mem_init+0x315>
f0102f29:	c7 44 24 0c c4 a7 10 	movl   $0xf010a7c4,0xc(%esp)
f0102f30:	f0 
f0102f31:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102f38:	f0 
f0102f39:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0102f40:	00 
f0102f41:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102f48:	e8 f3 d0 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102f4d:	a1 48 b2 24 f0       	mov    0xf024b248,%eax
f0102f52:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0102f55:	c7 05 48 b2 24 f0 00 	movl   $0x0,0xf024b248
f0102f5c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102f5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f66:	e8 32 f8 ff ff       	call   f010279d <page_alloc>
f0102f6b:	85 c0                	test   %eax,%eax
f0102f6d:	74 24                	je     f0102f93 <mem_init+0x35b>
f0102f6f:	c7 44 24 0c e1 a7 10 	movl   $0xf010a7e1,0xc(%esp)
f0102f76:	f0 
f0102f77:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102f7e:	f0 
f0102f7f:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0102f86:	00 
f0102f87:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102f8e:	e8 ad d0 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102f93:	89 34 24             	mov    %esi,(%esp)
f0102f96:	e8 86 f8 ff ff       	call   f0102821 <page_free>
	page_free(pp1);
f0102f9b:	89 3c 24             	mov    %edi,(%esp)
f0102f9e:	e8 7e f8 ff ff       	call   f0102821 <page_free>
	page_free(pp2);
f0102fa3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fa6:	89 04 24             	mov    %eax,(%esp)
f0102fa9:	e8 73 f8 ff ff       	call   f0102821 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102fae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fb5:	e8 e3 f7 ff ff       	call   f010279d <page_alloc>
f0102fba:	89 c6                	mov    %eax,%esi
f0102fbc:	85 c0                	test   %eax,%eax
f0102fbe:	75 24                	jne    f0102fe4 <mem_init+0x3ac>
f0102fc0:	c7 44 24 0c 36 a7 10 	movl   $0xf010a736,0xc(%esp)
f0102fc7:	f0 
f0102fc8:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0102fcf:	f0 
f0102fd0:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0102fd7:	00 
f0102fd8:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0102fdf:	e8 5c d0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fe4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102feb:	e8 ad f7 ff ff       	call   f010279d <page_alloc>
f0102ff0:	89 c7                	mov    %eax,%edi
f0102ff2:	85 c0                	test   %eax,%eax
f0102ff4:	75 24                	jne    f010301a <mem_init+0x3e2>
f0102ff6:	c7 44 24 0c 4c a7 10 	movl   $0xf010a74c,0xc(%esp)
f0102ffd:	f0 
f0102ffe:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103005:	f0 
f0103006:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f010300d:	00 
f010300e:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103015:	e8 26 d0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010301a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103021:	e8 77 f7 ff ff       	call   f010279d <page_alloc>
f0103026:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103029:	85 c0                	test   %eax,%eax
f010302b:	75 24                	jne    f0103051 <mem_init+0x419>
f010302d:	c7 44 24 0c 62 a7 10 	movl   $0xf010a762,0xc(%esp)
f0103034:	f0 
f0103035:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010303c:	f0 
f010303d:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0103044:	00 
f0103045:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010304c:	e8 ef cf ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0103051:	39 fe                	cmp    %edi,%esi
f0103053:	75 24                	jne    f0103079 <mem_init+0x441>
f0103055:	c7 44 24 0c 78 a7 10 	movl   $0xf010a778,0xc(%esp)
f010305c:	f0 
f010305d:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103064:	f0 
f0103065:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f010306c:	00 
f010306d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103074:	e8 c7 cf ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0103079:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010307c:	74 05                	je     f0103083 <mem_init+0x44b>
f010307e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0103081:	75 24                	jne    f01030a7 <mem_init+0x46f>
f0103083:	c7 44 24 0c ec 9d 10 	movl   $0xf0109dec,0xc(%esp)
f010308a:	f0 
f010308b:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103092:	f0 
f0103093:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f010309a:	00 
f010309b:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01030a2:	e8 99 cf ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01030a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030ae:	e8 ea f6 ff ff       	call   f010279d <page_alloc>
f01030b3:	85 c0                	test   %eax,%eax
f01030b5:	74 24                	je     f01030db <mem_init+0x4a3>
f01030b7:	c7 44 24 0c e1 a7 10 	movl   $0xf010a7e1,0xc(%esp)
f01030be:	f0 
f01030bf:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01030c6:	f0 
f01030c7:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01030ce:	00 
f01030cf:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01030d6:	e8 65 cf ff ff       	call   f0100040 <_panic>
f01030db:	89 f0                	mov    %esi,%eax
f01030dd:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f01030e3:	c1 f8 03             	sar    $0x3,%eax
f01030e6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030e9:	89 c2                	mov    %eax,%edx
f01030eb:	c1 ea 0c             	shr    $0xc,%edx
f01030ee:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f01030f4:	72 20                	jb     f0103116 <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030fa:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0103101:	f0 
f0103102:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103109:	00 
f010310a:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0103111:	e8 2a cf ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0103116:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010311d:	00 
f010311e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103125:	00 
	return (void *)(pa + KERNBASE);
f0103126:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010312b:	89 04 24             	mov    %eax,(%esp)
f010312e:	e8 73 49 00 00       	call   f0107aa6 <memset>
	page_free(pp0);
f0103133:	89 34 24             	mov    %esi,(%esp)
f0103136:	e8 e6 f6 ff ff       	call   f0102821 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010313b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103142:	e8 56 f6 ff ff       	call   f010279d <page_alloc>
f0103147:	85 c0                	test   %eax,%eax
f0103149:	75 24                	jne    f010316f <mem_init+0x537>
f010314b:	c7 44 24 0c f0 a7 10 	movl   $0xf010a7f0,0xc(%esp)
f0103152:	f0 
f0103153:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010315a:	f0 
f010315b:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0103162:	00 
f0103163:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010316a:	e8 d1 ce ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010316f:	39 c6                	cmp    %eax,%esi
f0103171:	74 24                	je     f0103197 <mem_init+0x55f>
f0103173:	c7 44 24 0c 0e a8 10 	movl   $0xf010a80e,0xc(%esp)
f010317a:	f0 
f010317b:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103182:	f0 
f0103183:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f010318a:	00 
f010318b:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103192:	e8 a9 ce ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103197:	89 f2                	mov    %esi,%edx
f0103199:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f010319f:	c1 fa 03             	sar    $0x3,%edx
f01031a2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031a5:	89 d0                	mov    %edx,%eax
f01031a7:	c1 e8 0c             	shr    $0xc,%eax
f01031aa:	3b 05 88 be 24 f0    	cmp    0xf024be88,%eax
f01031b0:	72 20                	jb     f01031d2 <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01031b6:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f01031bd:	f0 
f01031be:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031c5:	00 
f01031c6:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f01031cd:	e8 6e ce ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01031d2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01031d8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01031de:	80 38 00             	cmpb   $0x0,(%eax)
f01031e1:	74 24                	je     f0103207 <mem_init+0x5cf>
f01031e3:	c7 44 24 0c 1e a8 10 	movl   $0xf010a81e,0xc(%esp)
f01031ea:	f0 
f01031eb:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01031f2:	f0 
f01031f3:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f01031fa:	00 
f01031fb:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103202:	e8 39 ce ff ff       	call   f0100040 <_panic>
f0103207:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0103208:	39 d0                	cmp    %edx,%eax
f010320a:	75 d2                	jne    f01031de <mem_init+0x5a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010320c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010320f:	89 15 48 b2 24 f0    	mov    %edx,0xf024b248

	// free the pages we took
	page_free(pp0);
f0103215:	89 34 24             	mov    %esi,(%esp)
f0103218:	e8 04 f6 ff ff       	call   f0102821 <page_free>
	page_free(pp1);
f010321d:	89 3c 24             	mov    %edi,(%esp)
f0103220:	e8 fc f5 ff ff       	call   f0102821 <page_free>
	page_free(pp2);
f0103225:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103228:	89 04 24             	mov    %eax,(%esp)
f010322b:	e8 f1 f5 ff ff       	call   f0102821 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0103230:	a1 48 b2 24 f0       	mov    0xf024b248,%eax
f0103235:	eb 03                	jmp    f010323a <mem_init+0x602>
		--nfree;
f0103237:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0103238:	8b 00                	mov    (%eax),%eax
f010323a:	85 c0                	test   %eax,%eax
f010323c:	75 f9                	jne    f0103237 <mem_init+0x5ff>
		--nfree;
	assert(nfree == 0);
f010323e:	85 db                	test   %ebx,%ebx
f0103240:	74 24                	je     f0103266 <mem_init+0x62e>
f0103242:	c7 44 24 0c 28 a8 10 	movl   $0xf010a828,0xc(%esp)
f0103249:	f0 
f010324a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103251:	f0 
f0103252:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0103259:	00 
f010325a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103261:	e8 da cd ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0103266:	c7 04 24 0c 9e 10 f0 	movl   $0xf0109e0c,(%esp)
f010326d:	e8 1c 25 00 00       	call   f010578e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103272:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103279:	e8 1f f5 ff ff       	call   f010279d <page_alloc>
f010327e:	89 c7                	mov    %eax,%edi
f0103280:	85 c0                	test   %eax,%eax
f0103282:	75 24                	jne    f01032a8 <mem_init+0x670>
f0103284:	c7 44 24 0c 36 a7 10 	movl   $0xf010a736,0xc(%esp)
f010328b:	f0 
f010328c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103293:	f0 
f0103294:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010329b:	00 
f010329c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01032a3:	e8 98 cd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01032a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032af:	e8 e9 f4 ff ff       	call   f010279d <page_alloc>
f01032b4:	89 c6                	mov    %eax,%esi
f01032b6:	85 c0                	test   %eax,%eax
f01032b8:	75 24                	jne    f01032de <mem_init+0x6a6>
f01032ba:	c7 44 24 0c 4c a7 10 	movl   $0xf010a74c,0xc(%esp)
f01032c1:	f0 
f01032c2:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01032c9:	f0 
f01032ca:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f01032d1:	00 
f01032d2:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01032d9:	e8 62 cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01032de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032e5:	e8 b3 f4 ff ff       	call   f010279d <page_alloc>
f01032ea:	89 c3                	mov    %eax,%ebx
f01032ec:	85 c0                	test   %eax,%eax
f01032ee:	75 24                	jne    f0103314 <mem_init+0x6dc>
f01032f0:	c7 44 24 0c 62 a7 10 	movl   $0xf010a762,0xc(%esp)
f01032f7:	f0 
f01032f8:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01032ff:	f0 
f0103300:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0103307:	00 
f0103308:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010330f:	e8 2c cd ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0103314:	39 f7                	cmp    %esi,%edi
f0103316:	75 24                	jne    f010333c <mem_init+0x704>
f0103318:	c7 44 24 0c 78 a7 10 	movl   $0xf010a778,0xc(%esp)
f010331f:	f0 
f0103320:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103327:	f0 
f0103328:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f010332f:	00 
f0103330:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103337:	e8 04 cd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010333c:	39 c6                	cmp    %eax,%esi
f010333e:	74 04                	je     f0103344 <mem_init+0x70c>
f0103340:	39 c7                	cmp    %eax,%edi
f0103342:	75 24                	jne    f0103368 <mem_init+0x730>
f0103344:	c7 44 24 0c ec 9d 10 	movl   $0xf0109dec,0xc(%esp)
f010334b:	f0 
f010334c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103353:	f0 
f0103354:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f010335b:	00 
f010335c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103363:	e8 d8 cc ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0103368:	8b 15 48 b2 24 f0    	mov    0xf024b248,%edx
f010336e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0103371:	c7 05 48 b2 24 f0 00 	movl   $0x0,0xf024b248
f0103378:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010337b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103382:	e8 16 f4 ff ff       	call   f010279d <page_alloc>
f0103387:	85 c0                	test   %eax,%eax
f0103389:	74 24                	je     f01033af <mem_init+0x777>
f010338b:	c7 44 24 0c e1 a7 10 	movl   $0xf010a7e1,0xc(%esp)
f0103392:	f0 
f0103393:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010339a:	f0 
f010339b:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01033a2:	00 
f01033a3:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01033aa:	e8 91 cc ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01033af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01033b2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01033bd:	00 
f01033be:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01033c3:	89 04 24             	mov    %eax,(%esp)
f01033c6:	e8 49 f6 ff ff       	call   f0102a14 <page_lookup>
f01033cb:	85 c0                	test   %eax,%eax
f01033cd:	74 24                	je     f01033f3 <mem_init+0x7bb>
f01033cf:	c7 44 24 0c 2c 9e 10 	movl   $0xf0109e2c,0xc(%esp)
f01033d6:	f0 
f01033d7:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01033de:	f0 
f01033df:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01033e6:	00 
f01033e7:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01033ee:	e8 4d cc ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01033f3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01033fa:	00 
f01033fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103402:	00 
f0103403:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103407:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f010340c:	89 04 24             	mov    %eax,(%esp)
f010340f:	e8 ff f6 ff ff       	call   f0102b13 <page_insert>
f0103414:	85 c0                	test   %eax,%eax
f0103416:	78 24                	js     f010343c <mem_init+0x804>
f0103418:	c7 44 24 0c 64 9e 10 	movl   $0xf0109e64,0xc(%esp)
f010341f:	f0 
f0103420:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103427:	f0 
f0103428:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f010342f:	00 
f0103430:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103437:	e8 04 cc ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010343c:	89 3c 24             	mov    %edi,(%esp)
f010343f:	e8 dd f3 ff ff       	call   f0102821 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0103444:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010344b:	00 
f010344c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103453:	00 
f0103454:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103458:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f010345d:	89 04 24             	mov    %eax,(%esp)
f0103460:	e8 ae f6 ff ff       	call   f0102b13 <page_insert>
f0103465:	85 c0                	test   %eax,%eax
f0103467:	74 24                	je     f010348d <mem_init+0x855>
f0103469:	c7 44 24 0c 94 9e 10 	movl   $0xf0109e94,0xc(%esp)
f0103470:	f0 
f0103471:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103478:	f0 
f0103479:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0103480:	00 
f0103481:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103488:	e8 b3 cb ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010348d:	8b 0d 8c be 24 f0    	mov    0xf024be8c,%ecx
f0103493:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103496:	a1 90 be 24 f0       	mov    0xf024be90,%eax
f010349b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010349e:	8b 11                	mov    (%ecx),%edx
f01034a0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01034a6:	89 f8                	mov    %edi,%eax
f01034a8:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01034ab:	c1 f8 03             	sar    $0x3,%eax
f01034ae:	c1 e0 0c             	shl    $0xc,%eax
f01034b1:	39 c2                	cmp    %eax,%edx
f01034b3:	74 24                	je     f01034d9 <mem_init+0x8a1>
f01034b5:	c7 44 24 0c c4 9e 10 	movl   $0xf0109ec4,0xc(%esp)
f01034bc:	f0 
f01034bd:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01034c4:	f0 
f01034c5:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f01034cc:	00 
f01034cd:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01034d4:	e8 67 cb ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01034d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01034de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034e1:	e8 a2 ec ff ff       	call   f0102188 <check_va2pa>
f01034e6:	89 f2                	mov    %esi,%edx
f01034e8:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01034eb:	c1 fa 03             	sar    $0x3,%edx
f01034ee:	c1 e2 0c             	shl    $0xc,%edx
f01034f1:	39 d0                	cmp    %edx,%eax
f01034f3:	74 24                	je     f0103519 <mem_init+0x8e1>
f01034f5:	c7 44 24 0c ec 9e 10 	movl   $0xf0109eec,0xc(%esp)
f01034fc:	f0 
f01034fd:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103504:	f0 
f0103505:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f010350c:	00 
f010350d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103514:	e8 27 cb ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0103519:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010351e:	74 24                	je     f0103544 <mem_init+0x90c>
f0103520:	c7 44 24 0c 33 a8 10 	movl   $0xf010a833,0xc(%esp)
f0103527:	f0 
f0103528:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010352f:	f0 
f0103530:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0103537:	00 
f0103538:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010353f:	e8 fc ca ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0103544:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103549:	74 24                	je     f010356f <mem_init+0x937>
f010354b:	c7 44 24 0c 44 a8 10 	movl   $0xf010a844,0xc(%esp)
f0103552:	f0 
f0103553:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010355a:	f0 
f010355b:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0103562:	00 
f0103563:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010356a:	e8 d1 ca ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010356f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103576:	00 
f0103577:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010357e:	00 
f010357f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103583:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103586:	89 14 24             	mov    %edx,(%esp)
f0103589:	e8 85 f5 ff ff       	call   f0102b13 <page_insert>
f010358e:	85 c0                	test   %eax,%eax
f0103590:	74 24                	je     f01035b6 <mem_init+0x97e>
f0103592:	c7 44 24 0c 1c 9f 10 	movl   $0xf0109f1c,0xc(%esp)
f0103599:	f0 
f010359a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01035a1:	f0 
f01035a2:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01035a9:	00 
f01035aa:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01035b1:	e8 8a ca ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01035b6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01035bb:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01035c0:	e8 c3 eb ff ff       	call   f0102188 <check_va2pa>
f01035c5:	89 da                	mov    %ebx,%edx
f01035c7:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f01035cd:	c1 fa 03             	sar    $0x3,%edx
f01035d0:	c1 e2 0c             	shl    $0xc,%edx
f01035d3:	39 d0                	cmp    %edx,%eax
f01035d5:	74 24                	je     f01035fb <mem_init+0x9c3>
f01035d7:	c7 44 24 0c 58 9f 10 	movl   $0xf0109f58,0xc(%esp)
f01035de:	f0 
f01035df:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01035e6:	f0 
f01035e7:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f01035ee:	00 
f01035ef:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01035f6:	e8 45 ca ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01035fb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103600:	74 24                	je     f0103626 <mem_init+0x9ee>
f0103602:	c7 44 24 0c 55 a8 10 	movl   $0xf010a855,0xc(%esp)
f0103609:	f0 
f010360a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103611:	f0 
f0103612:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0103619:	00 
f010361a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103621:	e8 1a ca ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103626:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010362d:	e8 6b f1 ff ff       	call   f010279d <page_alloc>
f0103632:	85 c0                	test   %eax,%eax
f0103634:	74 24                	je     f010365a <mem_init+0xa22>
f0103636:	c7 44 24 0c e1 a7 10 	movl   $0xf010a7e1,0xc(%esp)
f010363d:	f0 
f010363e:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103645:	f0 
f0103646:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f010364d:	00 
f010364e:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103655:	e8 e6 c9 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010365a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103661:	00 
f0103662:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103669:	00 
f010366a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010366e:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103673:	89 04 24             	mov    %eax,(%esp)
f0103676:	e8 98 f4 ff ff       	call   f0102b13 <page_insert>
f010367b:	85 c0                	test   %eax,%eax
f010367d:	74 24                	je     f01036a3 <mem_init+0xa6b>
f010367f:	c7 44 24 0c 1c 9f 10 	movl   $0xf0109f1c,0xc(%esp)
f0103686:	f0 
f0103687:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010368e:	f0 
f010368f:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0103696:	00 
f0103697:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010369e:	e8 9d c9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01036a3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01036a8:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01036ad:	e8 d6 ea ff ff       	call   f0102188 <check_va2pa>
f01036b2:	89 da                	mov    %ebx,%edx
f01036b4:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f01036ba:	c1 fa 03             	sar    $0x3,%edx
f01036bd:	c1 e2 0c             	shl    $0xc,%edx
f01036c0:	39 d0                	cmp    %edx,%eax
f01036c2:	74 24                	je     f01036e8 <mem_init+0xab0>
f01036c4:	c7 44 24 0c 58 9f 10 	movl   $0xf0109f58,0xc(%esp)
f01036cb:	f0 
f01036cc:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01036d3:	f0 
f01036d4:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f01036db:	00 
f01036dc:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01036e3:	e8 58 c9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01036e8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01036ed:	74 24                	je     f0103713 <mem_init+0xadb>
f01036ef:	c7 44 24 0c 55 a8 10 	movl   $0xf010a855,0xc(%esp)
f01036f6:	f0 
f01036f7:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01036fe:	f0 
f01036ff:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0103706:	00 
f0103707:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010370e:	e8 2d c9 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0103713:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010371a:	e8 7e f0 ff ff       	call   f010279d <page_alloc>
f010371f:	85 c0                	test   %eax,%eax
f0103721:	74 24                	je     f0103747 <mem_init+0xb0f>
f0103723:	c7 44 24 0c e1 a7 10 	movl   $0xf010a7e1,0xc(%esp)
f010372a:	f0 
f010372b:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103732:	f0 
f0103733:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f010373a:	00 
f010373b:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103742:	e8 f9 c8 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0103747:	8b 15 8c be 24 f0    	mov    0xf024be8c,%edx
f010374d:	8b 02                	mov    (%edx),%eax
f010374f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103754:	89 c1                	mov    %eax,%ecx
f0103756:	c1 e9 0c             	shr    $0xc,%ecx
f0103759:	3b 0d 88 be 24 f0    	cmp    0xf024be88,%ecx
f010375f:	72 20                	jb     f0103781 <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103761:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103765:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f010376c:	f0 
f010376d:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0103774:	00 
f0103775:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010377c:	e8 bf c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103781:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103786:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0103789:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103790:	00 
f0103791:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103798:	00 
f0103799:	89 14 24             	mov    %edx,(%esp)
f010379c:	e8 e0 f0 ff ff       	call   f0102881 <pgdir_walk>
f01037a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01037a4:	83 c2 04             	add    $0x4,%edx
f01037a7:	39 d0                	cmp    %edx,%eax
f01037a9:	74 24                	je     f01037cf <mem_init+0xb97>
f01037ab:	c7 44 24 0c 88 9f 10 	movl   $0xf0109f88,0xc(%esp)
f01037b2:	f0 
f01037b3:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01037ba:	f0 
f01037bb:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f01037c2:	00 
f01037c3:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01037ca:	e8 71 c8 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01037cf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01037d6:	00 
f01037d7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037de:	00 
f01037df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01037e3:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01037e8:	89 04 24             	mov    %eax,(%esp)
f01037eb:	e8 23 f3 ff ff       	call   f0102b13 <page_insert>
f01037f0:	85 c0                	test   %eax,%eax
f01037f2:	74 24                	je     f0103818 <mem_init+0xbe0>
f01037f4:	c7 44 24 0c c8 9f 10 	movl   $0xf0109fc8,0xc(%esp)
f01037fb:	f0 
f01037fc:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103803:	f0 
f0103804:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f010380b:	00 
f010380c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103813:	e8 28 c8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103818:	8b 0d 8c be 24 f0    	mov    0xf024be8c,%ecx
f010381e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103821:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103826:	89 c8                	mov    %ecx,%eax
f0103828:	e8 5b e9 ff ff       	call   f0102188 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010382d:	89 da                	mov    %ebx,%edx
f010382f:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f0103835:	c1 fa 03             	sar    $0x3,%edx
f0103838:	c1 e2 0c             	shl    $0xc,%edx
f010383b:	39 d0                	cmp    %edx,%eax
f010383d:	74 24                	je     f0103863 <mem_init+0xc2b>
f010383f:	c7 44 24 0c 58 9f 10 	movl   $0xf0109f58,0xc(%esp)
f0103846:	f0 
f0103847:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010384e:	f0 
f010384f:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0103856:	00 
f0103857:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010385e:	e8 dd c7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103863:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103868:	74 24                	je     f010388e <mem_init+0xc56>
f010386a:	c7 44 24 0c 55 a8 10 	movl   $0xf010a855,0xc(%esp)
f0103871:	f0 
f0103872:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103879:	f0 
f010387a:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0103881:	00 
f0103882:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103889:	e8 b2 c7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010388e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103895:	00 
f0103896:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010389d:	00 
f010389e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01038a1:	89 04 24             	mov    %eax,(%esp)
f01038a4:	e8 d8 ef ff ff       	call   f0102881 <pgdir_walk>
f01038a9:	f6 00 04             	testb  $0x4,(%eax)
f01038ac:	75 24                	jne    f01038d2 <mem_init+0xc9a>
f01038ae:	c7 44 24 0c 08 a0 10 	movl   $0xf010a008,0xc(%esp)
f01038b5:	f0 
f01038b6:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01038bd:	f0 
f01038be:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01038c5:	00 
f01038c6:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01038cd:	e8 6e c7 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01038d2:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01038d7:	f6 00 04             	testb  $0x4,(%eax)
f01038da:	75 24                	jne    f0103900 <mem_init+0xcc8>
f01038dc:	c7 44 24 0c 66 a8 10 	movl   $0xf010a866,0xc(%esp)
f01038e3:	f0 
f01038e4:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01038eb:	f0 
f01038ec:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01038f3:	00 
f01038f4:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01038fb:	e8 40 c7 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103900:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103907:	00 
f0103908:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010390f:	00 
f0103910:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103914:	89 04 24             	mov    %eax,(%esp)
f0103917:	e8 f7 f1 ff ff       	call   f0102b13 <page_insert>
f010391c:	85 c0                	test   %eax,%eax
f010391e:	74 24                	je     f0103944 <mem_init+0xd0c>
f0103920:	c7 44 24 0c 1c 9f 10 	movl   $0xf0109f1c,0xc(%esp)
f0103927:	f0 
f0103928:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010392f:	f0 
f0103930:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0103937:	00 
f0103938:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010393f:	e8 fc c6 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0103944:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010394b:	00 
f010394c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103953:	00 
f0103954:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103959:	89 04 24             	mov    %eax,(%esp)
f010395c:	e8 20 ef ff ff       	call   f0102881 <pgdir_walk>
f0103961:	f6 00 02             	testb  $0x2,(%eax)
f0103964:	75 24                	jne    f010398a <mem_init+0xd52>
f0103966:	c7 44 24 0c 3c a0 10 	movl   $0xf010a03c,0xc(%esp)
f010396d:	f0 
f010396e:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103975:	f0 
f0103976:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f010397d:	00 
f010397e:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103985:	e8 b6 c6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010398a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103991:	00 
f0103992:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103999:	00 
f010399a:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f010399f:	89 04 24             	mov    %eax,(%esp)
f01039a2:	e8 da ee ff ff       	call   f0102881 <pgdir_walk>
f01039a7:	f6 00 04             	testb  $0x4,(%eax)
f01039aa:	74 24                	je     f01039d0 <mem_init+0xd98>
f01039ac:	c7 44 24 0c 70 a0 10 	movl   $0xf010a070,0xc(%esp)
f01039b3:	f0 
f01039b4:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01039bb:	f0 
f01039bc:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01039c3:	00 
f01039c4:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01039cb:	e8 70 c6 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01039d0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01039d7:	00 
f01039d8:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01039df:	00 
f01039e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01039e4:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01039e9:	89 04 24             	mov    %eax,(%esp)
f01039ec:	e8 22 f1 ff ff       	call   f0102b13 <page_insert>
f01039f1:	85 c0                	test   %eax,%eax
f01039f3:	78 24                	js     f0103a19 <mem_init+0xde1>
f01039f5:	c7 44 24 0c a8 a0 10 	movl   $0xf010a0a8,0xc(%esp)
f01039fc:	f0 
f01039fd:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103a04:	f0 
f0103a05:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0103a0c:	00 
f0103a0d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103a14:	e8 27 c6 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0103a19:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103a20:	00 
f0103a21:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103a28:	00 
f0103a29:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a2d:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103a32:	89 04 24             	mov    %eax,(%esp)
f0103a35:	e8 d9 f0 ff ff       	call   f0102b13 <page_insert>
f0103a3a:	85 c0                	test   %eax,%eax
f0103a3c:	74 24                	je     f0103a62 <mem_init+0xe2a>
f0103a3e:	c7 44 24 0c e0 a0 10 	movl   $0xf010a0e0,0xc(%esp)
f0103a45:	f0 
f0103a46:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103a4d:	f0 
f0103a4e:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f0103a55:	00 
f0103a56:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103a5d:	e8 de c5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103a62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103a69:	00 
f0103a6a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103a71:	00 
f0103a72:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103a77:	89 04 24             	mov    %eax,(%esp)
f0103a7a:	e8 02 ee ff ff       	call   f0102881 <pgdir_walk>
f0103a7f:	f6 00 04             	testb  $0x4,(%eax)
f0103a82:	74 24                	je     f0103aa8 <mem_init+0xe70>
f0103a84:	c7 44 24 0c 70 a0 10 	movl   $0xf010a070,0xc(%esp)
f0103a8b:	f0 
f0103a8c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103a93:	f0 
f0103a94:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0103a9b:	00 
f0103a9c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103aa3:	e8 98 c5 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0103aa8:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103aad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103ab0:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ab5:	e8 ce e6 ff ff       	call   f0102188 <check_va2pa>
f0103aba:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103abd:	89 f0                	mov    %esi,%eax
f0103abf:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f0103ac5:	c1 f8 03             	sar    $0x3,%eax
f0103ac8:	c1 e0 0c             	shl    $0xc,%eax
f0103acb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0103ace:	74 24                	je     f0103af4 <mem_init+0xebc>
f0103ad0:	c7 44 24 0c 1c a1 10 	movl   $0xf010a11c,0xc(%esp)
f0103ad7:	f0 
f0103ad8:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103adf:	f0 
f0103ae0:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0103ae7:	00 
f0103ae8:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103aef:	e8 4c c5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103af4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103af9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103afc:	e8 87 e6 ff ff       	call   f0102188 <check_va2pa>
f0103b01:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0103b04:	74 24                	je     f0103b2a <mem_init+0xef2>
f0103b06:	c7 44 24 0c 48 a1 10 	movl   $0xf010a148,0xc(%esp)
f0103b0d:	f0 
f0103b0e:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103b15:	f0 
f0103b16:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0103b1d:	00 
f0103b1e:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103b25:	e8 16 c5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0103b2a:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0103b2f:	74 24                	je     f0103b55 <mem_init+0xf1d>
f0103b31:	c7 44 24 0c 7c a8 10 	movl   $0xf010a87c,0xc(%esp)
f0103b38:	f0 
f0103b39:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103b40:	f0 
f0103b41:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0103b48:	00 
f0103b49:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103b50:	e8 eb c4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103b55:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103b5a:	74 24                	je     f0103b80 <mem_init+0xf48>
f0103b5c:	c7 44 24 0c 8d a8 10 	movl   $0xf010a88d,0xc(%esp)
f0103b63:	f0 
f0103b64:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103b6b:	f0 
f0103b6c:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0103b73:	00 
f0103b74:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103b7b:	e8 c0 c4 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0103b80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b87:	e8 11 ec ff ff       	call   f010279d <page_alloc>
f0103b8c:	85 c0                	test   %eax,%eax
f0103b8e:	74 04                	je     f0103b94 <mem_init+0xf5c>
f0103b90:	39 c3                	cmp    %eax,%ebx
f0103b92:	74 24                	je     f0103bb8 <mem_init+0xf80>
f0103b94:	c7 44 24 0c 78 a1 10 	movl   $0xf010a178,0xc(%esp)
f0103b9b:	f0 
f0103b9c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103ba3:	f0 
f0103ba4:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0103bab:	00 
f0103bac:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103bb3:	e8 88 c4 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0103bb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103bbf:	00 
f0103bc0:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103bc5:	89 04 24             	mov    %eax,(%esp)
f0103bc8:	e8 fd ee ff ff       	call   f0102aca <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103bcd:	8b 15 8c be 24 f0    	mov    0xf024be8c,%edx
f0103bd3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103bd6:	ba 00 00 00 00       	mov    $0x0,%edx
f0103bdb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bde:	e8 a5 e5 ff ff       	call   f0102188 <check_va2pa>
f0103be3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103be6:	74 24                	je     f0103c0c <mem_init+0xfd4>
f0103be8:	c7 44 24 0c 9c a1 10 	movl   $0xf010a19c,0xc(%esp)
f0103bef:	f0 
f0103bf0:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103bf7:	f0 
f0103bf8:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0103bff:	00 
f0103c00:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103c07:	e8 34 c4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103c0c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103c11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c14:	e8 6f e5 ff ff       	call   f0102188 <check_va2pa>
f0103c19:	89 f2                	mov    %esi,%edx
f0103c1b:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f0103c21:	c1 fa 03             	sar    $0x3,%edx
f0103c24:	c1 e2 0c             	shl    $0xc,%edx
f0103c27:	39 d0                	cmp    %edx,%eax
f0103c29:	74 24                	je     f0103c4f <mem_init+0x1017>
f0103c2b:	c7 44 24 0c 48 a1 10 	movl   $0xf010a148,0xc(%esp)
f0103c32:	f0 
f0103c33:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103c3a:	f0 
f0103c3b:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0103c42:	00 
f0103c43:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103c4a:	e8 f1 c3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0103c4f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103c54:	74 24                	je     f0103c7a <mem_init+0x1042>
f0103c56:	c7 44 24 0c 33 a8 10 	movl   $0xf010a833,0xc(%esp)
f0103c5d:	f0 
f0103c5e:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103c65:	f0 
f0103c66:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0103c6d:	00 
f0103c6e:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103c75:	e8 c6 c3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103c7a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103c7f:	74 24                	je     f0103ca5 <mem_init+0x106d>
f0103c81:	c7 44 24 0c 8d a8 10 	movl   $0xf010a88d,0xc(%esp)
f0103c88:	f0 
f0103c89:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103c90:	f0 
f0103c91:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f0103c98:	00 
f0103c99:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103ca0:	e8 9b c3 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0103ca5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103cac:	00 
f0103cad:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103cb4:	00 
f0103cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103cb9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103cbc:	89 0c 24             	mov    %ecx,(%esp)
f0103cbf:	e8 4f ee ff ff       	call   f0102b13 <page_insert>
f0103cc4:	85 c0                	test   %eax,%eax
f0103cc6:	74 24                	je     f0103cec <mem_init+0x10b4>
f0103cc8:	c7 44 24 0c c0 a1 10 	movl   $0xf010a1c0,0xc(%esp)
f0103ccf:	f0 
f0103cd0:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103cd7:	f0 
f0103cd8:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0103cdf:	00 
f0103ce0:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103ce7:	e8 54 c3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0103cec:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103cf1:	75 24                	jne    f0103d17 <mem_init+0x10df>
f0103cf3:	c7 44 24 0c 9e a8 10 	movl   $0xf010a89e,0xc(%esp)
f0103cfa:	f0 
f0103cfb:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103d02:	f0 
f0103d03:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0103d0a:	00 
f0103d0b:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103d12:	e8 29 c3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0103d17:	83 3e 00             	cmpl   $0x0,(%esi)
f0103d1a:	74 24                	je     f0103d40 <mem_init+0x1108>
f0103d1c:	c7 44 24 0c aa a8 10 	movl   $0xf010a8aa,0xc(%esp)
f0103d23:	f0 
f0103d24:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103d2b:	f0 
f0103d2c:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0103d33:	00 
f0103d34:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103d3b:	e8 00 c3 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103d40:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103d47:	00 
f0103d48:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103d4d:	89 04 24             	mov    %eax,(%esp)
f0103d50:	e8 75 ed ff ff       	call   f0102aca <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103d55:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103d5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103d5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d62:	e8 21 e4 ff ff       	call   f0102188 <check_va2pa>
f0103d67:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103d6a:	74 24                	je     f0103d90 <mem_init+0x1158>
f0103d6c:	c7 44 24 0c 9c a1 10 	movl   $0xf010a19c,0xc(%esp)
f0103d73:	f0 
f0103d74:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103d7b:	f0 
f0103d7c:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0103d83:	00 
f0103d84:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103d8b:	e8 b0 c2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0103d90:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103d95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d98:	e8 eb e3 ff ff       	call   f0102188 <check_va2pa>
f0103d9d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103da0:	74 24                	je     f0103dc6 <mem_init+0x118e>
f0103da2:	c7 44 24 0c f8 a1 10 	movl   $0xf010a1f8,0xc(%esp)
f0103da9:	f0 
f0103daa:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103db1:	f0 
f0103db2:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0103db9:	00 
f0103dba:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103dc1:	e8 7a c2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103dc6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103dcb:	74 24                	je     f0103df1 <mem_init+0x11b9>
f0103dcd:	c7 44 24 0c bf a8 10 	movl   $0xf010a8bf,0xc(%esp)
f0103dd4:	f0 
f0103dd5:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103ddc:	f0 
f0103ddd:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0103de4:	00 
f0103de5:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103dec:	e8 4f c2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103df1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103df6:	74 24                	je     f0103e1c <mem_init+0x11e4>
f0103df8:	c7 44 24 0c 8d a8 10 	movl   $0xf010a88d,0xc(%esp)
f0103dff:	f0 
f0103e00:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103e07:	f0 
f0103e08:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0103e0f:	00 
f0103e10:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103e17:	e8 24 c2 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0103e1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103e23:	e8 75 e9 ff ff       	call   f010279d <page_alloc>
f0103e28:	85 c0                	test   %eax,%eax
f0103e2a:	74 04                	je     f0103e30 <mem_init+0x11f8>
f0103e2c:	39 c6                	cmp    %eax,%esi
f0103e2e:	74 24                	je     f0103e54 <mem_init+0x121c>
f0103e30:	c7 44 24 0c 20 a2 10 	movl   $0xf010a220,0xc(%esp)
f0103e37:	f0 
f0103e38:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103e3f:	f0 
f0103e40:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0103e47:	00 
f0103e48:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103e4f:	e8 ec c1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103e54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103e5b:	e8 3d e9 ff ff       	call   f010279d <page_alloc>
f0103e60:	85 c0                	test   %eax,%eax
f0103e62:	74 24                	je     f0103e88 <mem_init+0x1250>
f0103e64:	c7 44 24 0c e1 a7 10 	movl   $0xf010a7e1,0xc(%esp)
f0103e6b:	f0 
f0103e6c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103e73:	f0 
f0103e74:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0103e7b:	00 
f0103e7c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103e83:	e8 b8 c1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103e88:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103e8d:	8b 08                	mov    (%eax),%ecx
f0103e8f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103e95:	89 fa                	mov    %edi,%edx
f0103e97:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f0103e9d:	c1 fa 03             	sar    $0x3,%edx
f0103ea0:	c1 e2 0c             	shl    $0xc,%edx
f0103ea3:	39 d1                	cmp    %edx,%ecx
f0103ea5:	74 24                	je     f0103ecb <mem_init+0x1293>
f0103ea7:	c7 44 24 0c c4 9e 10 	movl   $0xf0109ec4,0xc(%esp)
f0103eae:	f0 
f0103eaf:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103eb6:	f0 
f0103eb7:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0103ebe:	00 
f0103ebf:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103ec6:	e8 75 c1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103ecb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103ed1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103ed6:	74 24                	je     f0103efc <mem_init+0x12c4>
f0103ed8:	c7 44 24 0c 44 a8 10 	movl   $0xf010a844,0xc(%esp)
f0103edf:	f0 
f0103ee0:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103ee7:	f0 
f0103ee8:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0103eef:	00 
f0103ef0:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103ef7:	e8 44 c1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103efc:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0103f02:	89 3c 24             	mov    %edi,(%esp)
f0103f05:	e8 17 e9 ff ff       	call   f0102821 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0103f0a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103f11:	00 
f0103f12:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0103f19:	00 
f0103f1a:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0103f1f:	89 04 24             	mov    %eax,(%esp)
f0103f22:	e8 5a e9 ff ff       	call   f0102881 <pgdir_walk>
f0103f27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103f2a:	8b 0d 8c be 24 f0    	mov    0xf024be8c,%ecx
f0103f30:	8b 51 04             	mov    0x4(%ecx),%edx
f0103f33:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103f39:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f3c:	8b 15 88 be 24 f0    	mov    0xf024be88,%edx
f0103f42:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0103f45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103f48:	c1 ea 0c             	shr    $0xc,%edx
f0103f4b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103f4e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103f51:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0103f54:	72 23                	jb     f0103f79 <mem_init+0x1341>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f56:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103f59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103f5d:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0103f64:	f0 
f0103f65:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0103f6c:	00 
f0103f6d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103f74:	e8 c7 c0 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0103f79:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103f7c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0103f82:	39 d0                	cmp    %edx,%eax
f0103f84:	74 24                	je     f0103faa <mem_init+0x1372>
f0103f86:	c7 44 24 0c d0 a8 10 	movl   $0xf010a8d0,0xc(%esp)
f0103f8d:	f0 
f0103f8e:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0103f95:	f0 
f0103f96:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0103f9d:	00 
f0103f9e:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0103fa5:	e8 96 c0 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103faa:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0103fb1:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103fb7:	89 f8                	mov    %edi,%eax
f0103fb9:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f0103fbf:	c1 f8 03             	sar    $0x3,%eax
f0103fc2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103fc5:	89 c1                	mov    %eax,%ecx
f0103fc7:	c1 e9 0c             	shr    $0xc,%ecx
f0103fca:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0103fcd:	77 20                	ja     f0103fef <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103fcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fd3:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0103fda:	f0 
f0103fdb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103fe2:	00 
f0103fe3:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0103fea:	e8 51 c0 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103fef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103ff6:	00 
f0103ff7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103ffe:	00 
	return (void *)(pa + KERNBASE);
f0103fff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0104004:	89 04 24             	mov    %eax,(%esp)
f0104007:	e8 9a 3a 00 00       	call   f0107aa6 <memset>
	page_free(pp0);
f010400c:	89 3c 24             	mov    %edi,(%esp)
f010400f:	e8 0d e8 ff ff       	call   f0102821 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0104014:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010401b:	00 
f010401c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104023:	00 
f0104024:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104029:	89 04 24             	mov    %eax,(%esp)
f010402c:	e8 50 e8 ff ff       	call   f0102881 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104031:	89 fa                	mov    %edi,%edx
f0104033:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f0104039:	c1 fa 03             	sar    $0x3,%edx
f010403c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010403f:	89 d0                	mov    %edx,%eax
f0104041:	c1 e8 0c             	shr    $0xc,%eax
f0104044:	3b 05 88 be 24 f0    	cmp    0xf024be88,%eax
f010404a:	72 20                	jb     f010406c <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010404c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104050:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0104057:	f0 
f0104058:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010405f:	00 
f0104060:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0104067:	e8 d4 bf ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010406c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0104072:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104075:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010407b:	f6 00 01             	testb  $0x1,(%eax)
f010407e:	74 24                	je     f01040a4 <mem_init+0x146c>
f0104080:	c7 44 24 0c e8 a8 10 	movl   $0xf010a8e8,0xc(%esp)
f0104087:	f0 
f0104088:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010408f:	f0 
f0104090:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0104097:	00 
f0104098:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010409f:	e8 9c bf ff ff       	call   f0100040 <_panic>
f01040a4:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01040a7:	39 d0                	cmp    %edx,%eax
f01040a9:	75 d0                	jne    f010407b <mem_init+0x1443>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01040ab:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01040b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01040b6:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01040bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01040bf:	89 0d 48 b2 24 f0    	mov    %ecx,0xf024b248

	// free the pages we took
	page_free(pp0);
f01040c5:	89 3c 24             	mov    %edi,(%esp)
f01040c8:	e8 54 e7 ff ff       	call   f0102821 <page_free>
	page_free(pp1);
f01040cd:	89 34 24             	mov    %esi,(%esp)
f01040d0:	e8 4c e7 ff ff       	call   f0102821 <page_free>
	page_free(pp2);
f01040d5:	89 1c 24             	mov    %ebx,(%esp)
f01040d8:	e8 44 e7 ff ff       	call   f0102821 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01040dd:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01040e4:	00 
f01040e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01040ec:	e8 a3 ea ff ff       	call   f0102b94 <mmio_map_region>
f01040f1:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01040f3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01040fa:	00 
f01040fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104102:	e8 8d ea ff ff       	call   f0102b94 <mmio_map_region>
f0104107:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0104109:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010410f:	76 0d                	jbe    f010411e <mem_init+0x14e6>
f0104111:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0104117:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010411c:	76 24                	jbe    f0104142 <mem_init+0x150a>
f010411e:	c7 44 24 0c 44 a2 10 	movl   $0xf010a244,0xc(%esp)
f0104125:	f0 
f0104126:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010412d:	f0 
f010412e:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0104135:	00 
f0104136:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010413d:	e8 fe be ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0104142:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104148:	76 0e                	jbe    f0104158 <mem_init+0x1520>
f010414a:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0104150:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0104156:	76 24                	jbe    f010417c <mem_init+0x1544>
f0104158:	c7 44 24 0c 6c a2 10 	movl   $0xf010a26c,0xc(%esp)
f010415f:	f0 
f0104160:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104167:	f0 
f0104168:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f010416f:	00 
f0104170:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104177:	e8 c4 be ff ff       	call   f0100040 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010417c:	89 da                	mov    %ebx,%edx
f010417e:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0104180:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0104186:	74 24                	je     f01041ac <mem_init+0x1574>
f0104188:	c7 44 24 0c 94 a2 10 	movl   $0xf010a294,0xc(%esp)
f010418f:	f0 
f0104190:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104197:	f0 
f0104198:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f010419f:	00 
f01041a0:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01041a7:	e8 94 be ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f01041ac:	39 c6                	cmp    %eax,%esi
f01041ae:	73 24                	jae    f01041d4 <mem_init+0x159c>
f01041b0:	c7 44 24 0c ff a8 10 	movl   $0xf010a8ff,0xc(%esp)
f01041b7:	f0 
f01041b8:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01041bf:	f0 
f01041c0:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f01041c7:	00 
f01041c8:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01041cf:	e8 6c be ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01041d4:	8b 3d 8c be 24 f0    	mov    0xf024be8c,%edi
f01041da:	89 da                	mov    %ebx,%edx
f01041dc:	89 f8                	mov    %edi,%eax
f01041de:	e8 a5 df ff ff       	call   f0102188 <check_va2pa>
f01041e3:	85 c0                	test   %eax,%eax
f01041e5:	74 24                	je     f010420b <mem_init+0x15d3>
f01041e7:	c7 44 24 0c bc a2 10 	movl   $0xf010a2bc,0xc(%esp)
f01041ee:	f0 
f01041ef:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01041f6:	f0 
f01041f7:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f01041fe:	00 
f01041ff:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104206:	e8 35 be ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010420b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0104211:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104214:	89 c2                	mov    %eax,%edx
f0104216:	89 f8                	mov    %edi,%eax
f0104218:	e8 6b df ff ff       	call   f0102188 <check_va2pa>
f010421d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0104222:	74 24                	je     f0104248 <mem_init+0x1610>
f0104224:	c7 44 24 0c e0 a2 10 	movl   $0xf010a2e0,0xc(%esp)
f010422b:	f0 
f010422c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104233:	f0 
f0104234:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f010423b:	00 
f010423c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104243:	e8 f8 bd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0104248:	89 f2                	mov    %esi,%edx
f010424a:	89 f8                	mov    %edi,%eax
f010424c:	e8 37 df ff ff       	call   f0102188 <check_va2pa>
f0104251:	85 c0                	test   %eax,%eax
f0104253:	74 24                	je     f0104279 <mem_init+0x1641>
f0104255:	c7 44 24 0c 10 a3 10 	movl   $0xf010a310,0xc(%esp)
f010425c:	f0 
f010425d:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104264:	f0 
f0104265:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f010426c:	00 
f010426d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104274:	e8 c7 bd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0104279:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010427f:	89 f8                	mov    %edi,%eax
f0104281:	e8 02 df ff ff       	call   f0102188 <check_va2pa>
f0104286:	83 f8 ff             	cmp    $0xffffffff,%eax
f0104289:	74 24                	je     f01042af <mem_init+0x1677>
f010428b:	c7 44 24 0c 34 a3 10 	movl   $0xf010a334,0xc(%esp)
f0104292:	f0 
f0104293:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010429a:	f0 
f010429b:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f01042a2:	00 
f01042a3:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01042aa:	e8 91 bd ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01042af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01042b6:	00 
f01042b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042bb:	89 3c 24             	mov    %edi,(%esp)
f01042be:	e8 be e5 ff ff       	call   f0102881 <pgdir_walk>
f01042c3:	f6 00 1a             	testb  $0x1a,(%eax)
f01042c6:	75 24                	jne    f01042ec <mem_init+0x16b4>
f01042c8:	c7 44 24 0c 60 a3 10 	movl   $0xf010a360,0xc(%esp)
f01042cf:	f0 
f01042d0:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01042d7:	f0 
f01042d8:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f01042df:	00 
f01042e0:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01042e7:	e8 54 bd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01042ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01042f3:	00 
f01042f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042f8:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01042fd:	89 04 24             	mov    %eax,(%esp)
f0104300:	e8 7c e5 ff ff       	call   f0102881 <pgdir_walk>
f0104305:	f6 00 04             	testb  $0x4,(%eax)
f0104308:	74 24                	je     f010432e <mem_init+0x16f6>
f010430a:	c7 44 24 0c a4 a3 10 	movl   $0xf010a3a4,0xc(%esp)
f0104311:	f0 
f0104312:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104319:	f0 
f010431a:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0104321:	00 
f0104322:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104329:	e8 12 bd ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010432e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104335:	00 
f0104336:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010433a:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f010433f:	89 04 24             	mov    %eax,(%esp)
f0104342:	e8 3a e5 ff ff       	call   f0102881 <pgdir_walk>
f0104347:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010434d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104354:	00 
f0104355:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104358:	89 54 24 04          	mov    %edx,0x4(%esp)
f010435c:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104361:	89 04 24             	mov    %eax,(%esp)
f0104364:	e8 18 e5 ff ff       	call   f0102881 <pgdir_walk>
f0104369:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010436f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104376:	00 
f0104377:	89 74 24 04          	mov    %esi,0x4(%esp)
f010437b:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104380:	89 04 24             	mov    %eax,(%esp)
f0104383:	e8 f9 e4 ff ff       	call   f0102881 <pgdir_walk>
f0104388:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010438e:	c7 04 24 11 a9 10 f0 	movl   $0xf010a911,(%esp)
f0104395:	e8 f4 13 00 00       	call   f010578e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f010439a:	a1 90 be 24 f0       	mov    0xf024be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010439f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043a4:	77 20                	ja     f01043c6 <mem_init+0x178e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043aa:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01043b1:	f0 
f01043b2:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f01043b9:	00 
f01043ba:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01043c1:	e8 7a bc ff ff       	call   f0100040 <_panic>
f01043c6:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01043cd:	00 
	return (physaddr_t)kva - KERNBASE;
f01043ce:	05 00 00 00 10       	add    $0x10000000,%eax
f01043d3:	89 04 24             	mov    %eax,(%esp)
f01043d6:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01043db:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01043e0:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01043e5:	e8 58 e5 ff ff       	call   f0102942 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U);
f01043ea:	a1 50 b2 24 f0       	mov    0xf024b250,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043f4:	77 20                	ja     f0104416 <mem_init+0x17de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043fa:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f0104401:	f0 
f0104402:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f0104409:	00 
f010440a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104411:	e8 2a bc ff ff       	call   f0100040 <_panic>
f0104416:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f010441d:	00 
	return (physaddr_t)kva - KERNBASE;
f010441e:	05 00 00 00 10       	add    $0x10000000,%eax
f0104423:	89 04 24             	mov    %eax,(%esp)
f0104426:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010442b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0104430:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104435:	e8 08 e5 ff ff       	call   f0102942 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010443a:	b8 00 40 12 f0       	mov    $0xf0124000,%eax
f010443f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104444:	77 20                	ja     f0104466 <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104446:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010444a:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f0104451:	f0 
f0104452:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
f0104459:	00 
f010445a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104461:	e8 da bb ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
   boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f0104466:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010446d:	00 
f010446e:	c7 04 24 00 40 12 00 	movl   $0x124000,(%esp)
f0104475:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010447a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010447f:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104484:	e8 b9 e4 ff ff       	call   f0102942 <boot_map_region>
f0104489:	c7 45 cc 00 d0 24 f0 	movl   $0xf024d000,-0x34(%ebp)
f0104490:	bb 00 d0 24 f0       	mov    $0xf024d000,%ebx
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t address = KSTACKTOP - KSTKSIZE;
f0104495:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010449a:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01044a0:	77 20                	ja     f01044c2 <mem_init+0x188a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01044a6:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01044ad:	f0 
f01044ae:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f01044b5:	00 
f01044b6:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01044bd:	e8 7e bb ff ff       	call   f0100040 <_panic>
	for (int i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir,address,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f01044c2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01044c9:	00 
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01044ca:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t address = KSTACKTOP - KSTKSIZE;
	for (int i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir,address,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f01044d0:	89 04 24             	mov    %eax,(%esp)
f01044d3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01044d8:	89 f2                	mov    %esi,%edx
f01044da:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f01044df:	e8 5e e4 ff ff       	call   f0102942 <boot_map_region>
		address -= (KSTKSIZE + KSTKGAP);
f01044e4:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01044ea:	81 c3 00 80 00 00    	add    $0x8000,%ebx
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t address = KSTACKTOP - KSTKSIZE;
	for (int i = 0; i < NCPU; i++){
f01044f0:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f01044f6:	75 a2                	jne    f010449a <mem_init+0x1862>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	assert(KERNBASE == 0xf0000000); // 0x100000000 - KERNBASE
	boot_map_region(kern_pgdir,KERNBASE,0x10000000,0x0,PTE_W);
f01044f8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01044ff:	00 
f0104500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104507:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010450c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0104511:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104516:	e8 27 e4 ff ff       	call   f0102942 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010451b:	8b 1d 8c be 24 f0    	mov    0xf024be8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0104521:	8b 0d 88 be 24 f0    	mov    0xf024be88,%ecx
f0104527:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010452a:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0104531:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0104537:	be 00 00 00 00       	mov    $0x0,%esi
f010453c:	eb 70                	jmp    f01045ae <mem_init+0x1976>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010453e:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0104544:	89 d8                	mov    %ebx,%eax
f0104546:	e8 3d dc ff ff       	call   f0102188 <check_va2pa>
f010454b:	8b 15 90 be 24 f0    	mov    0xf024be90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104551:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0104557:	77 20                	ja     f0104579 <mem_init+0x1941>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104559:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010455d:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f0104564:	f0 
f0104565:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f010456c:	00 
f010456d:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104574:	e8 c7 ba ff ff       	call   f0100040 <_panic>
f0104579:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0104580:	39 d0                	cmp    %edx,%eax
f0104582:	74 24                	je     f01045a8 <mem_init+0x1970>
f0104584:	c7 44 24 0c d8 a3 10 	movl   $0xf010a3d8,0xc(%esp)
f010458b:	f0 
f010458c:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104593:	f0 
f0104594:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f010459b:	00 
f010459c:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01045a3:	e8 98 ba ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01045a8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01045ae:	39 f7                	cmp    %esi,%edi
f01045b0:	77 8c                	ja     f010453e <mem_init+0x1906>
f01045b2:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01045b7:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01045bd:	89 d8                	mov    %ebx,%eax
f01045bf:	e8 c4 db ff ff       	call   f0102188 <check_va2pa>
f01045c4:	8b 15 50 b2 24 f0    	mov    0xf024b250,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01045ca:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01045d0:	77 20                	ja     f01045f2 <mem_init+0x19ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01045d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01045d6:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01045dd:	f0 
f01045de:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f01045e5:	00 
f01045e6:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01045ed:	e8 4e ba ff ff       	call   f0100040 <_panic>
f01045f2:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01045f9:	39 d0                	cmp    %edx,%eax
f01045fb:	74 24                	je     f0104621 <mem_init+0x19e9>
f01045fd:	c7 44 24 0c 0c a4 10 	movl   $0xf010a40c,0xc(%esp)
f0104604:	f0 
f0104605:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010460c:	f0 
f010460d:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0104614:	00 
f0104615:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010461c:	e8 1f ba ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0104621:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0104627:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f010462d:	75 88                	jne    f01045b7 <mem_init+0x197f>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f010462f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104632:	c1 e7 0c             	shl    $0xc,%edi
f0104635:	be 00 00 00 00       	mov    $0x0,%esi
f010463a:	eb 3b                	jmp    f0104677 <mem_init+0x1a3f>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010463c:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
		//#ifdef DEBUG
		// cprintf("%x %x\n",i,check_va2pa(pgdir, KERNBASE + i));
		//#endif
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0104642:	89 d8                	mov    %ebx,%eax
f0104644:	e8 3f db ff ff       	call   f0102188 <check_va2pa>
f0104649:	39 c6                	cmp    %eax,%esi
f010464b:	74 24                	je     f0104671 <mem_init+0x1a39>
f010464d:	c7 44 24 0c 40 a4 10 	movl   $0xf010a440,0xc(%esp)
f0104654:	f0 
f0104655:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010465c:	f0 
f010465d:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0104664:	00 
f0104665:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010466c:	e8 cf b9 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0104671:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0104677:	39 fe                	cmp    %edi,%esi
f0104679:	72 c1                	jb     f010463c <mem_init+0x1a04>
f010467b:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0104680:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0104683:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104686:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104689:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010468f:	89 c6                	mov    %eax,%esi
f0104691:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0104697:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f010469d:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01046a0:	89 da                	mov    %ebx,%edx
f01046a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01046a5:	e8 de da ff ff       	call   f0102188 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01046aa:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01046b1:	77 23                	ja     f01046d6 <mem_init+0x1a9e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01046b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01046b6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046ba:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01046c1:	f0 
f01046c2:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01046c9:	00 
f01046ca:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01046d1:	e8 6a b9 ff ff       	call   f0100040 <_panic>
f01046d6:	39 f0                	cmp    %esi,%eax
f01046d8:	74 24                	je     f01046fe <mem_init+0x1ac6>
f01046da:	c7 44 24 0c 68 a4 10 	movl   $0xf010a468,0xc(%esp)
f01046e1:	f0 
f01046e2:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01046e9:	f0 
f01046ea:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01046f1:	00 
f01046f2:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01046f9:	e8 42 b9 ff ff       	call   f0100040 <_panic>
f01046fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104704:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010470a:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f010470d:	0f 85 55 05 00 00    	jne    f0104c68 <mem_init+0x2030>
f0104713:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104718:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010471b:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f010471e:	89 f0                	mov    %esi,%eax
f0104720:	e8 63 da ff ff       	call   f0102188 <check_va2pa>
f0104725:	83 f8 ff             	cmp    $0xffffffff,%eax
f0104728:	74 24                	je     f010474e <mem_init+0x1b16>
f010472a:	c7 44 24 0c b0 a4 10 	movl   $0xf010a4b0,0xc(%esp)
f0104731:	f0 
f0104732:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104739:	f0 
f010473a:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0104741:	00 
f0104742:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104749:	e8 f2 b8 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010474e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104754:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010475a:	75 bf                	jne    f010471b <mem_init+0x1ae3>
f010475c:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0104762:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0104769:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f010476f:	0f 85 0e ff ff ff    	jne    f0104683 <mem_init+0x1a4b>
f0104775:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104778:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010477d:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0104783:	83 fa 04             	cmp    $0x4,%edx
f0104786:	77 2e                	ja     f01047b6 <mem_init+0x1b7e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0104788:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010478c:	0f 85 aa 00 00 00    	jne    f010483c <mem_init+0x1c04>
f0104792:	c7 44 24 0c 2a a9 10 	movl   $0xf010a92a,0xc(%esp)
f0104799:	f0 
f010479a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01047a1:	f0 
f01047a2:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f01047a9:	00 
f01047aa:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01047b1:	e8 8a b8 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01047b6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01047bb:	76 55                	jbe    f0104812 <mem_init+0x1bda>
				assert(pgdir[i] & PTE_P);
f01047bd:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01047c0:	f6 c2 01             	test   $0x1,%dl
f01047c3:	75 24                	jne    f01047e9 <mem_init+0x1bb1>
f01047c5:	c7 44 24 0c 2a a9 10 	movl   $0xf010a92a,0xc(%esp)
f01047cc:	f0 
f01047cd:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01047d4:	f0 
f01047d5:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01047dc:	00 
f01047dd:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01047e4:	e8 57 b8 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01047e9:	f6 c2 02             	test   $0x2,%dl
f01047ec:	75 4e                	jne    f010483c <mem_init+0x1c04>
f01047ee:	c7 44 24 0c 3b a9 10 	movl   $0xf010a93b,0xc(%esp)
f01047f5:	f0 
f01047f6:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01047fd:	f0 
f01047fe:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0104805:	00 
f0104806:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010480d:	e8 2e b8 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0104812:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0104816:	74 24                	je     f010483c <mem_init+0x1c04>
f0104818:	c7 44 24 0c 4c a9 10 	movl   $0xf010a94c,0xc(%esp)
f010481f:	f0 
f0104820:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104827:	f0 
f0104828:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f010482f:	00 
f0104830:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104837:	e8 04 b8 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010483c:	40                   	inc    %eax
f010483d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104842:	0f 85 35 ff ff ff    	jne    f010477d <mem_init+0x1b45>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0104848:	c7 04 24 d4 a4 10 f0 	movl   $0xf010a4d4,(%esp)
f010484f:	e8 3a 0f 00 00       	call   f010578e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0104854:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104859:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010485e:	77 20                	ja     f0104880 <mem_init+0x1c48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104860:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104864:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f010486b:	f0 
f010486c:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f0104873:	00 
f0104874:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010487b:	e8 c0 b7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104880:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104885:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0104888:	b8 00 00 00 00       	mov    $0x0,%eax
f010488d:	e8 24 da ff ff       	call   f01022b6 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0104892:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0104895:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010489a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010489d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01048a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048a7:	e8 f1 de ff ff       	call   f010279d <page_alloc>
f01048ac:	89 c6                	mov    %eax,%esi
f01048ae:	85 c0                	test   %eax,%eax
f01048b0:	75 24                	jne    f01048d6 <mem_init+0x1c9e>
f01048b2:	c7 44 24 0c 36 a7 10 	movl   $0xf010a736,0xc(%esp)
f01048b9:	f0 
f01048ba:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01048c1:	f0 
f01048c2:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f01048c9:	00 
f01048ca:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f01048d1:	e8 6a b7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01048d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048dd:	e8 bb de ff ff       	call   f010279d <page_alloc>
f01048e2:	89 c7                	mov    %eax,%edi
f01048e4:	85 c0                	test   %eax,%eax
f01048e6:	75 24                	jne    f010490c <mem_init+0x1cd4>
f01048e8:	c7 44 24 0c 4c a7 10 	movl   $0xf010a74c,0xc(%esp)
f01048ef:	f0 
f01048f0:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f01048f7:	f0 
f01048f8:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f01048ff:	00 
f0104900:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104907:	e8 34 b7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010490c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104913:	e8 85 de ff ff       	call   f010279d <page_alloc>
f0104918:	89 c3                	mov    %eax,%ebx
f010491a:	85 c0                	test   %eax,%eax
f010491c:	75 24                	jne    f0104942 <mem_init+0x1d0a>
f010491e:	c7 44 24 0c 62 a7 10 	movl   $0xf010a762,0xc(%esp)
f0104925:	f0 
f0104926:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010492d:	f0 
f010492e:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f0104935:	00 
f0104936:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f010493d:	e8 fe b6 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0104942:	89 34 24             	mov    %esi,(%esp)
f0104945:	e8 d7 de ff ff       	call   f0102821 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010494a:	89 f8                	mov    %edi,%eax
f010494c:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f0104952:	c1 f8 03             	sar    $0x3,%eax
f0104955:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104958:	89 c2                	mov    %eax,%edx
f010495a:	c1 ea 0c             	shr    $0xc,%edx
f010495d:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f0104963:	72 20                	jb     f0104985 <mem_init+0x1d4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104965:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104969:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0104970:	f0 
f0104971:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0104978:	00 
f0104979:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0104980:	e8 bb b6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0104985:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010498c:	00 
f010498d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0104994:	00 
	return (void *)(pa + KERNBASE);
f0104995:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010499a:	89 04 24             	mov    %eax,(%esp)
f010499d:	e8 04 31 00 00       	call   f0107aa6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01049a2:	89 d8                	mov    %ebx,%eax
f01049a4:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f01049aa:	c1 f8 03             	sar    $0x3,%eax
f01049ad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01049b0:	89 c2                	mov    %eax,%edx
f01049b2:	c1 ea 0c             	shr    $0xc,%edx
f01049b5:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f01049bb:	72 20                	jb     f01049dd <mem_init+0x1da5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01049bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01049c1:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f01049c8:	f0 
f01049c9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01049d0:	00 
f01049d1:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f01049d8:	e8 63 b6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01049dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01049e4:	00 
f01049e5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01049ec:	00 
	return (void *)(pa + KERNBASE);
f01049ed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01049f2:	89 04 24             	mov    %eax,(%esp)
f01049f5:	e8 ac 30 00 00       	call   f0107aa6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01049fa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104a01:	00 
f0104a02:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104a09:	00 
f0104a0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a0e:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104a13:	89 04 24             	mov    %eax,(%esp)
f0104a16:	e8 f8 e0 ff ff       	call   f0102b13 <page_insert>
	assert(pp1->pp_ref == 1);
f0104a1b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0104a20:	74 24                	je     f0104a46 <mem_init+0x1e0e>
f0104a22:	c7 44 24 0c 33 a8 10 	movl   $0xf010a833,0xc(%esp)
f0104a29:	f0 
f0104a2a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104a31:	f0 
f0104a32:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f0104a39:	00 
f0104a3a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104a41:	e8 fa b5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0104a46:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0104a4d:	01 01 01 
f0104a50:	74 24                	je     f0104a76 <mem_init+0x1e3e>
f0104a52:	c7 44 24 0c f4 a4 10 	movl   $0xf010a4f4,0xc(%esp)
f0104a59:	f0 
f0104a5a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104a61:	f0 
f0104a62:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0104a69:	00 
f0104a6a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104a71:	e8 ca b5 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0104a76:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104a7d:	00 
f0104a7e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104a85:	00 
f0104a86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a8a:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104a8f:	89 04 24             	mov    %eax,(%esp)
f0104a92:	e8 7c e0 ff ff       	call   f0102b13 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0104a97:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0104a9e:	02 02 02 
f0104aa1:	74 24                	je     f0104ac7 <mem_init+0x1e8f>
f0104aa3:	c7 44 24 0c 18 a5 10 	movl   $0xf010a518,0xc(%esp)
f0104aaa:	f0 
f0104aab:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104ab2:	f0 
f0104ab3:	c7 44 24 04 88 04 00 	movl   $0x488,0x4(%esp)
f0104aba:	00 
f0104abb:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104ac2:	e8 79 b5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0104ac7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0104acc:	74 24                	je     f0104af2 <mem_init+0x1eba>
f0104ace:	c7 44 24 0c 55 a8 10 	movl   $0xf010a855,0xc(%esp)
f0104ad5:	f0 
f0104ad6:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104add:	f0 
f0104ade:	c7 44 24 04 89 04 00 	movl   $0x489,0x4(%esp)
f0104ae5:	00 
f0104ae6:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104aed:	e8 4e b5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0104af2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0104af7:	74 24                	je     f0104b1d <mem_init+0x1ee5>
f0104af9:	c7 44 24 0c bf a8 10 	movl   $0xf010a8bf,0xc(%esp)
f0104b00:	f0 
f0104b01:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104b08:	f0 
f0104b09:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f0104b10:	00 
f0104b11:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104b18:	e8 23 b5 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0104b1d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0104b24:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104b27:	89 d8                	mov    %ebx,%eax
f0104b29:	2b 05 90 be 24 f0    	sub    0xf024be90,%eax
f0104b2f:	c1 f8 03             	sar    $0x3,%eax
f0104b32:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104b35:	89 c2                	mov    %eax,%edx
f0104b37:	c1 ea 0c             	shr    $0xc,%edx
f0104b3a:	3b 15 88 be 24 f0    	cmp    0xf024be88,%edx
f0104b40:	72 20                	jb     f0104b62 <mem_init+0x1f2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104b42:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b46:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0104b4d:	f0 
f0104b4e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0104b55:	00 
f0104b56:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0104b5d:	e8 de b4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0104b62:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0104b69:	03 03 03 
f0104b6c:	74 24                	je     f0104b92 <mem_init+0x1f5a>
f0104b6e:	c7 44 24 0c 3c a5 10 	movl   $0xf010a53c,0xc(%esp)
f0104b75:	f0 
f0104b76:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104b7d:	f0 
f0104b7e:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0104b85:	00 
f0104b86:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104b8d:	e8 ae b4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0104b92:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0104b99:	00 
f0104b9a:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104b9f:	89 04 24             	mov    %eax,(%esp)
f0104ba2:	e8 23 df ff ff       	call   f0102aca <page_remove>
	assert(pp2->pp_ref == 0);
f0104ba7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0104bac:	74 24                	je     f0104bd2 <mem_init+0x1f9a>
f0104bae:	c7 44 24 0c 8d a8 10 	movl   $0xf010a88d,0xc(%esp)
f0104bb5:	f0 
f0104bb6:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104bbd:	f0 
f0104bbe:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f0104bc5:	00 
f0104bc6:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104bcd:	e8 6e b4 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0104bd2:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
f0104bd7:	8b 08                	mov    (%eax),%ecx
f0104bd9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104bdf:	89 f2                	mov    %esi,%edx
f0104be1:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f0104be7:	c1 fa 03             	sar    $0x3,%edx
f0104bea:	c1 e2 0c             	shl    $0xc,%edx
f0104bed:	39 d1                	cmp    %edx,%ecx
f0104bef:	74 24                	je     f0104c15 <mem_init+0x1fdd>
f0104bf1:	c7 44 24 0c c4 9e 10 	movl   $0xf0109ec4,0xc(%esp)
f0104bf8:	f0 
f0104bf9:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104c00:	f0 
f0104c01:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0104c08:	00 
f0104c09:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104c10:	e8 2b b4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0104c15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0104c1b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0104c20:	74 24                	je     f0104c46 <mem_init+0x200e>
f0104c22:	c7 44 24 0c 44 a8 10 	movl   $0xf010a844,0xc(%esp)
f0104c29:	f0 
f0104c2a:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104c31:	f0 
f0104c32:	c7 44 24 04 93 04 00 	movl   $0x493,0x4(%esp)
f0104c39:	00 
f0104c3a:	c7 04 24 c9 a5 10 f0 	movl   $0xf010a5c9,(%esp)
f0104c41:	e8 fa b3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0104c46:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0104c4c:	89 34 24             	mov    %esi,(%esp)
f0104c4f:	e8 cd db ff ff       	call   f0102821 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0104c54:	c7 04 24 68 a5 10 f0 	movl   $0xf010a568,(%esp)
f0104c5b:	e8 2e 0b 00 00       	call   f010578e <cprintf>
	// 	cprintf("%x %x %x\n",i,&kern_pgdir[i],KADDR(PTE_ADDR(kern_pgdir[i])));

	// pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	// cprintf("%x\n",*(int*)0x00400000);
	// cprintf("pages: %x\n",pages);
}
f0104c60:	83 c4 3c             	add    $0x3c,%esp
f0104c63:	5b                   	pop    %ebx
f0104c64:	5e                   	pop    %esi
f0104c65:	5f                   	pop    %edi
f0104c66:	5d                   	pop    %ebp
f0104c67:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0104c68:	89 da                	mov    %ebx,%edx
f0104c6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104c6d:	e8 16 d5 ff ff       	call   f0102188 <check_va2pa>
f0104c72:	e9 5f fa ff ff       	jmp    f01046d6 <mem_init+0x1a9e>

f0104c77 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0104c77:	55                   	push   %ebp
f0104c78:	89 e5                	mov    %esp,%ebp
f0104c7a:	57                   	push   %edi
f0104c7b:	56                   	push   %esi
f0104c7c:	53                   	push   %ebx
f0104c7d:	83 ec 2c             	sub    $0x2c,%esp
f0104c80:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t start = (uintptr_t)ROUNDDOWN(va,PGSIZE);
f0104c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c86:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t end = (uintptr_t)ROUNDUP(va+len,PGSIZE);
f0104c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c8f:	03 45 10             	add    0x10(%ebp),%eax
f0104c92:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104c97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104c9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// cprintf("%x %x\n",start,end);
	perm |= PTE_P;
f0104c9f:	8b 7d 14             	mov    0x14(%ebp),%edi
f0104ca2:	83 cf 01             	or     $0x1,%edi

	for (uintptr_t address = start; address < end; address+= PGSIZE){
f0104ca5:	eb 5d                	jmp    f0104d04 <user_mem_check+0x8d>
		if (address >= ULIM){
f0104ca7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0104cad:	76 16                	jbe    f0104cc5 <user_mem_check+0x4e>
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
f0104caf:	89 d8                	mov    %ebx,%eax
f0104cb1:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0104cb4:	73 03                	jae    f0104cb9 <user_mem_check+0x42>
f0104cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cb9:	a3 4c b2 24 f0       	mov    %eax,0xf024b24c
			return -E_FAULT;
f0104cbe:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0104cc3:	eb 49                	jmp    f0104d0e <user_mem_check+0x97>
		}
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)address, 0);
f0104cc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104ccc:	00 
f0104ccd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104cd1:	8b 46 60             	mov    0x60(%esi),%eax
f0104cd4:	89 04 24             	mov    %eax,(%esp)
f0104cd7:	e8 a5 db ff ff       	call   f0102881 <pgdir_walk>
		if (pte == NULL || (*pte & perm) != perm){
f0104cdc:	85 c0                	test   %eax,%eax
f0104cde:	74 08                	je     f0104ce8 <user_mem_check+0x71>
f0104ce0:	8b 00                	mov    (%eax),%eax
f0104ce2:	21 f8                	and    %edi,%eax
f0104ce4:	39 c7                	cmp    %eax,%edi
f0104ce6:	74 16                	je     f0104cfe <user_mem_check+0x87>
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
f0104ce8:	89 d8                	mov    %ebx,%eax
f0104cea:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0104ced:	73 03                	jae    f0104cf2 <user_mem_check+0x7b>
f0104cef:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cf2:	a3 4c b2 24 f0       	mov    %eax,0xf024b24c
			return -E_FAULT;
f0104cf7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0104cfc:	eb 10                	jmp    f0104d0e <user_mem_check+0x97>
	uintptr_t start = (uintptr_t)ROUNDDOWN(va,PGSIZE);
	uintptr_t end = (uintptr_t)ROUNDUP(va+len,PGSIZE);
	// cprintf("%x %x\n",start,end);
	perm |= PTE_P;

	for (uintptr_t address = start; address < end; address+= PGSIZE){
f0104cfe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104d04:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0104d07:	72 9e                	jb     f0104ca7 <user_mem_check+0x30>
		if (pte == NULL || (*pte & perm) != perm){
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
			return -E_FAULT;
		}
	}
	return 0;
f0104d09:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d0e:	83 c4 2c             	add    $0x2c,%esp
f0104d11:	5b                   	pop    %ebx
f0104d12:	5e                   	pop    %esi
f0104d13:	5f                   	pop    %edi
f0104d14:	5d                   	pop    %ebp
f0104d15:	c3                   	ret    

f0104d16 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0104d16:	55                   	push   %ebp
f0104d17:	89 e5                	mov    %esp,%ebp
f0104d19:	53                   	push   %ebx
f0104d1a:	83 ec 14             	sub    $0x14,%esp
f0104d1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0104d20:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d23:	83 c8 04             	or     $0x4,%eax
f0104d26:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d2a:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d2d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d31:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d38:	89 1c 24             	mov    %ebx,(%esp)
f0104d3b:	e8 37 ff ff ff       	call   f0104c77 <user_mem_check>
f0104d40:	85 c0                	test   %eax,%eax
f0104d42:	79 24                	jns    f0104d68 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0104d44:	a1 4c b2 24 f0       	mov    0xf024b24c,%eax
f0104d49:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d4d:	8b 43 48             	mov    0x48(%ebx),%eax
f0104d50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d54:	c7 04 24 94 a5 10 f0 	movl   $0xf010a594,(%esp)
f0104d5b:	e8 2e 0a 00 00       	call   f010578e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0104d60:	89 1c 24             	mov    %ebx,(%esp)
f0104d63:	e8 00 07 00 00       	call   f0105468 <env_destroy>
	}
}
f0104d68:	83 c4 14             	add    $0x14,%esp
f0104d6b:	5b                   	pop    %ebx
f0104d6c:	5d                   	pop    %ebp
f0104d6d:	c3                   	ret    
	...

f0104d70 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0104d70:	55                   	push   %ebp
f0104d71:	89 e5                	mov    %esp,%ebp
f0104d73:	57                   	push   %edi
f0104d74:	56                   	push   %esi
f0104d75:	53                   	push   %ebx
f0104d76:	83 ec 1c             	sub    $0x1c,%esp
f0104d79:	89 c6                	mov    %eax,%esi
	// LAB 3: Your code here.
	void *start = ROUNDDOWN(va,PGSIZE);
	void *end =ROUNDUP(va+len,PGSIZE);
f0104d7b:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0104d82:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (void *address = start; address < end; address += PGSIZE){
f0104d88:	89 d3                	mov    %edx,%ebx
f0104d8a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0104d90:	eb 6d                	jmp    f0104dff <region_alloc+0x8f>
		struct PageInfo *page = page_alloc(0);
f0104d92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104d99:	e8 ff d9 ff ff       	call   f010279d <page_alloc>
		if (page == NULL)panic("region_alloc: page_alloc failed!");
f0104d9e:	85 c0                	test   %eax,%eax
f0104da0:	75 1c                	jne    f0104dbe <region_alloc+0x4e>
f0104da2:	c7 44 24 08 5c a9 10 	movl   $0xf010a95c,0x8(%esp)
f0104da9:	f0 
f0104daa:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0104db1:	00 
f0104db2:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0104db9:	e8 82 b2 ff ff       	call   f0100040 <_panic>
		if (page_insert(e->env_pgdir,page,address,PTE_W|PTE_U))
f0104dbe:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104dc5:	00 
f0104dc6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104dca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dce:	8b 46 60             	mov    0x60(%esi),%eax
f0104dd1:	89 04 24             	mov    %eax,(%esp)
f0104dd4:	e8 3a dd ff ff       	call   f0102b13 <page_insert>
f0104dd9:	85 c0                	test   %eax,%eax
f0104ddb:	74 1c                	je     f0104df9 <region_alloc+0x89>
			panic("region_alloc: page_insert failed!");
f0104ddd:	c7 44 24 08 80 a9 10 	movl   $0xf010a980,0x8(%esp)
f0104de4:	f0 
f0104de5:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f0104dec:	00 
f0104ded:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0104df4:	e8 47 b2 ff ff       	call   f0100040 <_panic>
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *start = ROUNDDOWN(va,PGSIZE);
	void *end =ROUNDUP(va+len,PGSIZE);
	for (void *address = start; address < end; address += PGSIZE){
f0104df9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104dff:	39 fb                	cmp    %edi,%ebx
f0104e01:	72 8f                	jb     f0104d92 <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0104e03:	83 c4 1c             	add    $0x1c,%esp
f0104e06:	5b                   	pop    %ebx
f0104e07:	5e                   	pop    %esi
f0104e08:	5f                   	pop    %edi
f0104e09:	5d                   	pop    %ebp
f0104e0a:	c3                   	ret    

f0104e0b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0104e0b:	55                   	push   %ebp
f0104e0c:	89 e5                	mov    %esp,%ebp
f0104e0e:	57                   	push   %edi
f0104e0f:	56                   	push   %esi
f0104e10:	53                   	push   %ebx
f0104e11:	83 ec 0c             	sub    $0xc,%esp
f0104e14:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e17:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e1a:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0104e1d:	85 c0                	test   %eax,%eax
f0104e1f:	75 24                	jne    f0104e45 <envid2env+0x3a>
		*env_store = curenv;
f0104e21:	e8 ae 32 00 00       	call   f01080d4 <cpunum>
f0104e26:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e2d:	29 c2                	sub    %eax,%edx
f0104e2f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e32:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0104e39:	89 06                	mov    %eax,(%esi)
		return 0;
f0104e3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e40:	e9 84 00 00 00       	jmp    f0104ec9 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0104e45:	89 c3                	mov    %eax,%ebx
f0104e47:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0104e4d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0104e54:	c1 e3 07             	shl    $0x7,%ebx
f0104e57:	29 cb                	sub    %ecx,%ebx
f0104e59:	03 1d 50 b2 24 f0    	add    0xf024b250,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0104e5f:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0104e63:	74 05                	je     f0104e6a <envid2env+0x5f>
f0104e65:	39 43 48             	cmp    %eax,0x48(%ebx)
f0104e68:	74 0d                	je     f0104e77 <envid2env+0x6c>
		*env_store = 0;
f0104e6a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0104e70:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e75:	eb 52                	jmp    f0104ec9 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0104e77:	84 d2                	test   %dl,%dl
f0104e79:	74 47                	je     f0104ec2 <envid2env+0xb7>
f0104e7b:	e8 54 32 00 00       	call   f01080d4 <cpunum>
f0104e80:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e87:	29 c2                	sub    %eax,%edx
f0104e89:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e8c:	39 1c 85 28 c0 24 f0 	cmp    %ebx,-0xfdb3fd8(,%eax,4)
f0104e93:	74 2d                	je     f0104ec2 <envid2env+0xb7>
f0104e95:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0104e98:	e8 37 32 00 00       	call   f01080d4 <cpunum>
f0104e9d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ea4:	29 c2                	sub    %eax,%edx
f0104ea6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ea9:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0104eb0:	3b 78 48             	cmp    0x48(%eax),%edi
f0104eb3:	74 0d                	je     f0104ec2 <envid2env+0xb7>
		*env_store = 0;
f0104eb5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0104ebb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ec0:	eb 07                	jmp    f0104ec9 <envid2env+0xbe>
	}

	*env_store = e;
f0104ec2:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0104ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ec9:	83 c4 0c             	add    $0xc,%esp
f0104ecc:	5b                   	pop    %ebx
f0104ecd:	5e                   	pop    %esi
f0104ece:	5f                   	pop    %edi
f0104ecf:	5d                   	pop    %ebp
f0104ed0:	c3                   	ret    

f0104ed1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0104ed1:	55                   	push   %ebp
f0104ed2:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0104ed4:	b8 60 f1 14 f0       	mov    $0xf014f160,%eax
f0104ed9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0104edc:	b8 23 00 00 00       	mov    $0x23,%eax
f0104ee1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0104ee3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0104ee5:	b0 10                	mov    $0x10,%al
f0104ee7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0104ee9:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0104eeb:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0104eed:	ea f4 4e 10 f0 08 00 	ljmp   $0x8,$0xf0104ef4
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0104ef4:	b0 00                	mov    $0x0,%al
f0104ef6:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0104ef9:	5d                   	pop    %ebp
f0104efa:	c3                   	ret    

f0104efb <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0104efb:	55                   	push   %ebp
f0104efc:	89 e5                	mov    %esp,%ebp
f0104efe:	56                   	push   %esi
f0104eff:	53                   	push   %ebx
f0104f00:	83 ec 10             	sub    $0x10,%esp
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
f0104f03:	83 3d 54 b2 24 f0 00 	cmpl   $0x0,0xf024b254
f0104f0a:	74 24                	je     f0104f30 <env_init+0x35>
f0104f0c:	c7 44 24 0c d9 a9 10 	movl   $0xf010a9d9,0xc(%esp)
f0104f13:	f0 
f0104f14:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0104f1b:	f0 
f0104f1c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
f0104f23:	00 
f0104f24:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0104f2b:	e8 10 b1 ff ff       	call   f0100040 <_panic>
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
f0104f30:	8b 35 50 b2 24 f0    	mov    0xf024b250,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0104f36:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0104f3c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f41:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0104f46:	eb 02                	jmp    f0104f4a <env_init+0x4f>
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0104f48:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
f0104f4a:	89 c3                	mov    %eax,%ebx
f0104f4c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0104f53:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0104f5a:	89 48 44             	mov    %ecx,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
f0104f5d:	4a                   	dec    %edx
f0104f5e:	83 e8 7c             	sub    $0x7c,%eax
f0104f61:	83 fa ff             	cmp    $0xffffffff,%edx
f0104f64:	75 e2                	jne    f0104f48 <env_init+0x4d>
f0104f66:	89 35 54 b2 24 f0    	mov    %esi,0xf024b254
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0104f6c:	e8 60 ff ff ff       	call   f0104ed1 <env_init_percpu>
}
f0104f71:	83 c4 10             	add    $0x10,%esp
f0104f74:	5b                   	pop    %ebx
f0104f75:	5e                   	pop    %esi
f0104f76:	5d                   	pop    %ebp
f0104f77:	c3                   	ret    

f0104f78 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0104f78:	55                   	push   %ebp
f0104f79:	89 e5                	mov    %esp,%ebp
f0104f7b:	56                   	push   %esi
f0104f7c:	53                   	push   %ebx
f0104f7d:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0104f80:	8b 1d 54 b2 24 f0    	mov    0xf024b254,%ebx
f0104f86:	85 db                	test   %ebx,%ebx
f0104f88:	0f 84 8b 01 00 00    	je     f0105119 <env_alloc+0x1a1>
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0104f8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104f95:	e8 03 d8 ff ff       	call   f010279d <page_alloc>
f0104f9a:	85 c0                	test   %eax,%eax
f0104f9c:	0f 84 7e 01 00 00    	je     f0105120 <env_alloc+0x1a8>
f0104fa2:	89 c2                	mov    %eax,%edx
f0104fa4:	2b 15 90 be 24 f0    	sub    0xf024be90,%edx
f0104faa:	c1 fa 03             	sar    $0x3,%edx
f0104fad:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104fb0:	89 d1                	mov    %edx,%ecx
f0104fb2:	c1 e9 0c             	shr    $0xc,%ecx
f0104fb5:	3b 0d 88 be 24 f0    	cmp    0xf024be88,%ecx
f0104fbb:	72 20                	jb     f0104fdd <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104fbd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104fc1:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0104fc8:	f0 
f0104fc9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0104fd0:	00 
f0104fd1:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0104fd8:	e8 63 b0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104fdd:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0104fe3:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t*)page2kva(p);
	p->pp_ref++;
f0104fe6:	66 ff 40 04          	incw   0x4(%eax)

	for (int i = 0; i < PDX(UTOP); i++){
f0104fea:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fef:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f0104ff4:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0104ff7:	c7 04 91 00 00 00 00 	movl   $0x0,(%ecx,%edx,4)

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t*)page2kva(p);
	p->pp_ref++;

	for (int i = 0; i < PDX(UTOP); i++){
f0104ffe:	40                   	inc    %eax
f0104fff:	89 c2                	mov    %eax,%edx
f0105001:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0105006:	75 ec                	jne    f0104ff4 <env_alloc+0x7c>
f0105008:	66 b8 ec 0e          	mov    $0xeec,%ax
		e->env_pgdir[i] = 0;
	}

	for (int i = PDX(UTOP); i < NPDENTRIES; i++){
		e->env_pgdir[i] = kern_pgdir[i];
f010500c:	8b 15 8c be 24 f0    	mov    0xf024be8c,%edx
f0105012:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0105015:	8b 53 60             	mov    0x60(%ebx),%edx
f0105018:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010501b:	83 c0 04             	add    $0x4,%eax

	for (int i = 0; i < PDX(UTOP); i++){
		e->env_pgdir[i] = 0;
	}

	for (int i = PDX(UTOP); i < NPDENTRIES; i++){
f010501e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0105023:	75 e7                	jne    f010500c <env_alloc+0x94>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0105025:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0105028:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010502d:	77 20                	ja     f010504f <env_alloc+0xd7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010502f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105033:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f010503a:	f0 
f010503b:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f0105042:	00 
f0105043:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f010504a:	e8 f1 af ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010504f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0105055:	83 ca 05             	or     $0x5,%edx
f0105058:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010505e:	8b 43 48             	mov    0x48(%ebx),%eax
f0105061:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0105066:	89 c1                	mov    %eax,%ecx
f0105068:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f010506e:	7f 05                	jg     f0105075 <env_alloc+0xfd>
		generation = 1 << ENVGENSHIFT;
f0105070:	b9 00 10 00 00       	mov    $0x1000,%ecx
	
	e->env_id = generation | (e - envs);
f0105075:	89 d8                	mov    %ebx,%eax
f0105077:	2b 05 50 b2 24 f0    	sub    0xf024b250,%eax
f010507d:	c1 f8 02             	sar    $0x2,%eax
f0105080:	89 c6                	mov    %eax,%esi
f0105082:	c1 e6 05             	shl    $0x5,%esi
f0105085:	89 c2                	mov    %eax,%edx
f0105087:	c1 e2 0a             	shl    $0xa,%edx
f010508a:	01 f2                	add    %esi,%edx
f010508c:	01 c2                	add    %eax,%edx
f010508e:	89 d6                	mov    %edx,%esi
f0105090:	c1 e6 0f             	shl    $0xf,%esi
f0105093:	01 f2                	add    %esi,%edx
f0105095:	c1 e2 05             	shl    $0x5,%edx
f0105098:	01 d0                	add    %edx,%eax
f010509a:	f7 d8                	neg    %eax
f010509c:	09 c1                	or     %eax,%ecx
f010509e:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01050a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050a4:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01050a7:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01050ae:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01050b5:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01050bc:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01050c3:	00 
f01050c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01050cb:	00 
f01050cc:	89 1c 24             	mov    %ebx,(%esp)
f01050cf:	e8 d2 29 00 00       	call   f0107aa6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01050d4:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01050da:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01050e0:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01050e6:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01050ed:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f01050f3:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01050fa:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0105101:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0105105:	8b 43 44             	mov    0x44(%ebx),%eax
f0105108:	a3 54 b2 24 f0       	mov    %eax,0xf024b254
	*newenv_store = e;
f010510d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105110:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0105112:	b8 00 00 00 00       	mov    $0x0,%eax
f0105117:	eb 0c                	jmp    f0105125 <env_alloc+0x1ad>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0105119:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010511e:	eb 05                	jmp    f0105125 <env_alloc+0x1ad>
{
	int i;
	struct PageInfo *p = NULL;
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0105120:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0105125:	83 c4 10             	add    $0x10,%esp
f0105128:	5b                   	pop    %ebx
f0105129:	5e                   	pop    %esi
f010512a:	5d                   	pop    %ebp
f010512b:	c3                   	ret    

f010512c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010512c:	55                   	push   %ebp
f010512d:	89 e5                	mov    %esp,%ebp
f010512f:	57                   	push   %edi
f0105130:	56                   	push   %esi
f0105131:	53                   	push   %ebx
f0105132:	83 ec 3c             	sub    $0x3c,%esp
f0105135:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	assert(env_alloc(&e,0) == 0);
f0105138:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010513f:	00 
f0105140:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105143:	89 04 24             	mov    %eax,(%esp)
f0105146:	e8 2d fe ff ff       	call   f0104f78 <env_alloc>
f010514b:	85 c0                	test   %eax,%eax
f010514d:	74 24                	je     f0105173 <env_create+0x47>
f010514f:	c7 44 24 0c ef a9 10 	movl   $0xf010a9ef,0xc(%esp)
f0105156:	f0 
f0105157:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f010515e:	f0 
f010515f:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f0105166:	00 
f0105167:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f010516e:	e8 cd ae ff ff       	call   f0100040 <_panic>
	load_icode(e,binary);
f0105173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105176:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.

	struct Elf *ELFHDR = (struct Elf *)binary;
	if (ELFHDR->e_magic != ELF_MAGIC)
f0105179:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010517f:	74 1c                	je     f010519d <env_create+0x71>
		panic("load_icode: ELFHDR->e_magic != ELF_MAGIC\n");
f0105181:	c7 44 24 08 a4 a9 10 	movl   $0xf010a9a4,0x8(%esp)
f0105188:	f0 
f0105189:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f0105190:	00 
f0105191:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0105198:	e8 a3 ae ff ff       	call   f0100040 <_panic>
	
	e->env_tf.tf_eip = ELFHDR->e_entry;
f010519d:	8b 47 18             	mov    0x18(%edi),%eax
f01051a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01051a3:	89 42 30             	mov    %eax,0x30(%edx)
	lcr3(PADDR(e->env_pgdir));
f01051a6:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01051a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01051ae:	77 20                	ja     f01051d0 <env_create+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01051b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01051b4:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01051bb:	f0 
f01051bc:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f01051c3:	00 
f01051c4:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f01051cb:	e8 70 ae ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01051d0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01051d5:	0f 22 d8             	mov    %eax,%cr3

	struct Proghdr *ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
f01051d8:	89 fb                	mov    %edi,%ebx
f01051da:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr *eph = ph + ELFHDR->e_phnum;
f01051dd:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01051e1:	c1 e6 05             	shl    $0x5,%esi
f01051e4:	01 de                	add    %ebx,%esi
f01051e6:	eb 74                	jmp    f010525c <env_create+0x130>
    for (; ph < eph; ph++){
		#ifdef DEBUG
			cprintf("memory size: %x\nfile size: %x\nvirtual address: %x\noffset: %x\n\n",ph->p_memsz,ph->p_filesz,ph->p_va,ph->p_offset);
		#endif
		if (ph->p_type == ELF_PROG_LOAD){
f01051e8:	83 3b 01             	cmpl   $0x1,(%ebx)
f01051eb:	75 6c                	jne    f0105259 <env_create+0x12d>
			assert(ph->p_memsz >= ph->p_filesz);
f01051ed:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01051f0:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f01051f3:	73 24                	jae    f0105219 <env_create+0xed>
f01051f5:	c7 44 24 0c 04 aa 10 	movl   $0xf010aa04,0xc(%esp)
f01051fc:	f0 
f01051fd:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0105204:	f0 
f0105205:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f010520c:	00 
f010520d:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0105214:	e8 27 ae ff ff       	call   f0100040 <_panic>
			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f0105219:	8b 53 08             	mov    0x8(%ebx),%edx
f010521c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010521f:	e8 4c fb ff ff       	call   f0104d70 <region_alloc>
            memset((void *)ph->p_va, 0, ph->p_memsz);
f0105224:	8b 43 14             	mov    0x14(%ebx),%eax
f0105227:	89 44 24 08          	mov    %eax,0x8(%esp)
f010522b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0105232:	00 
f0105233:	8b 43 08             	mov    0x8(%ebx),%eax
f0105236:	89 04 24             	mov    %eax,(%esp)
f0105239:	e8 68 28 00 00       	call   f0107aa6 <memset>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010523e:	8b 43 10             	mov    0x10(%ebx),%eax
f0105241:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105245:	89 f8                	mov    %edi,%eax
f0105247:	03 43 04             	add    0x4(%ebx),%eax
f010524a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010524e:	8b 43 08             	mov    0x8(%ebx),%eax
f0105251:	89 04 24             	mov    %eax,(%esp)
f0105254:	e8 01 29 00 00       	call   f0107b5a <memcpy>
	e->env_tf.tf_eip = ELFHDR->e_entry;
	lcr3(PADDR(e->env_pgdir));

	struct Proghdr *ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
	struct Proghdr *eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph++){
f0105259:	83 c3 20             	add    $0x20,%ebx
f010525c:	39 de                	cmp    %ebx,%esi
f010525e:	77 88                	ja     f01051e8 <env_create+0xbc>

    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f0105260:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0105265:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010526a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010526d:	e8 fe fa ff ff       	call   f0104d70 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *e;
	assert(env_alloc(&e,0) == 0);
	load_icode(e,binary);
	e->env_type = type;
f0105272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105275:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105278:	89 50 50             	mov    %edx,0x50(%eax)
	
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS){
f010527b:	83 fa 01             	cmp    $0x1,%edx
f010527e:	75 07                	jne    f0105287 <env_create+0x15b>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f0105280:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f0105287:	83 c4 3c             	add    $0x3c,%esp
f010528a:	5b                   	pop    %ebx
f010528b:	5e                   	pop    %esi
f010528c:	5f                   	pop    %edi
f010528d:	5d                   	pop    %ebp
f010528e:	c3                   	ret    

f010528f <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010528f:	55                   	push   %ebp
f0105290:	89 e5                	mov    %esp,%ebp
f0105292:	57                   	push   %edi
f0105293:	56                   	push   %esi
f0105294:	53                   	push   %ebx
f0105295:	83 ec 2c             	sub    $0x2c,%esp
f0105298:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010529b:	e8 34 2e 00 00       	call   f01080d4 <cpunum>
f01052a0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052a7:	29 c2                	sub    %eax,%edx
f01052a9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052ac:	39 3c 85 28 c0 24 f0 	cmp    %edi,-0xfdb3fd8(,%eax,4)
f01052b3:	75 3d                	jne    f01052f2 <env_free+0x63>
		lcr3(PADDR(kern_pgdir));
f01052b5:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01052ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01052bf:	77 20                	ja     f01052e1 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01052c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01052c5:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01052cc:	f0 
f01052cd:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
f01052d4:	00 
f01052d5:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f01052dc:	e8 5f ad ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01052e1:	05 00 00 00 10       	add    $0x10000000,%eax
f01052e6:	0f 22 d8             	mov    %eax,%cr3
f01052e9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01052f0:	eb 07                	jmp    f01052f9 <env_free+0x6a>
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01052f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01052f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052fc:	c1 e0 02             	shl    $0x2,%eax
f01052ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105302:	8b 47 60             	mov    0x60(%edi),%eax
f0105305:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105308:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010530b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0105311:	0f 84 b6 00 00 00    	je     f01053cd <env_free+0x13e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0105317:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010531d:	89 f0                	mov    %esi,%eax
f010531f:	c1 e8 0c             	shr    $0xc,%eax
f0105322:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105325:	3b 05 88 be 24 f0    	cmp    0xf024be88,%eax
f010532b:	72 20                	jb     f010534d <env_free+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010532d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105331:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0105338:	f0 
f0105339:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f0105340:	00 
f0105341:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0105348:	e8 f3 ac ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010534d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105350:	c1 e2 16             	shl    $0x16,%edx
f0105353:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0105356:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010535b:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0105362:	01 
f0105363:	74 17                	je     f010537c <env_free+0xed>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0105365:	89 d8                	mov    %ebx,%eax
f0105367:	c1 e0 0c             	shl    $0xc,%eax
f010536a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010536d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105371:	8b 47 60             	mov    0x60(%edi),%eax
f0105374:	89 04 24             	mov    %eax,(%esp)
f0105377:	e8 4e d7 ff ff       	call   f0102aca <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010537c:	43                   	inc    %ebx
f010537d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0105383:	75 d6                	jne    f010535b <env_free+0xcc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0105385:	8b 47 60             	mov    0x60(%edi),%eax
f0105388:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010538b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105392:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105395:	3b 05 88 be 24 f0    	cmp    0xf024be88,%eax
f010539b:	72 1c                	jb     f01053b9 <env_free+0x12a>
		panic("pa2page called with invalid pa");
f010539d:	c7 44 24 08 90 9d 10 	movl   $0xf0109d90,0x8(%esp)
f01053a4:	f0 
f01053a5:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01053ac:	00 
f01053ad:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f01053b4:	e8 87 ac ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01053b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053bc:	c1 e0 03             	shl    $0x3,%eax
f01053bf:	03 05 90 be 24 f0    	add    0xf024be90,%eax
		page_decref(pa2page(pa));
f01053c5:	89 04 24             	mov    %eax,(%esp)
f01053c8:	e8 94 d4 ff ff       	call   f0102861 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01053cd:	ff 45 e0             	incl   -0x20(%ebp)
f01053d0:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01053d7:	0f 85 1c ff ff ff    	jne    f01052f9 <env_free+0x6a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01053dd:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01053e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01053e5:	77 20                	ja     f0105407 <env_free+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01053e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01053eb:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01053f2:	f0 
f01053f3:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f01053fa:	00 
f01053fb:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0105402:	e8 39 ac ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0105407:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010540e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105413:	c1 e8 0c             	shr    $0xc,%eax
f0105416:	3b 05 88 be 24 f0    	cmp    0xf024be88,%eax
f010541c:	72 1c                	jb     f010543a <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f010541e:	c7 44 24 08 90 9d 10 	movl   $0xf0109d90,0x8(%esp)
f0105425:	f0 
f0105426:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010542d:	00 
f010542e:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0105435:	e8 06 ac ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010543a:	c1 e0 03             	shl    $0x3,%eax
f010543d:	03 05 90 be 24 f0    	add    0xf024be90,%eax
	page_decref(pa2page(pa));
f0105443:	89 04 24             	mov    %eax,(%esp)
f0105446:	e8 16 d4 ff ff       	call   f0102861 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010544b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0105452:	a1 54 b2 24 f0       	mov    0xf024b254,%eax
f0105457:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010545a:	89 3d 54 b2 24 f0    	mov    %edi,0xf024b254
}
f0105460:	83 c4 2c             	add    $0x2c,%esp
f0105463:	5b                   	pop    %ebx
f0105464:	5e                   	pop    %esi
f0105465:	5f                   	pop    %edi
f0105466:	5d                   	pop    %ebp
f0105467:	c3                   	ret    

f0105468 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0105468:	55                   	push   %ebp
f0105469:	89 e5                	mov    %esp,%ebp
f010546b:	53                   	push   %ebx
f010546c:	83 ec 14             	sub    $0x14,%esp
f010546f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0105472:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0105476:	75 23                	jne    f010549b <env_destroy+0x33>
f0105478:	e8 57 2c 00 00       	call   f01080d4 <cpunum>
f010547d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105484:	29 c2                	sub    %eax,%edx
f0105486:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105489:	39 1c 85 28 c0 24 f0 	cmp    %ebx,-0xfdb3fd8(,%eax,4)
f0105490:	74 09                	je     f010549b <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0105492:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0105499:	eb 39                	jmp    f01054d4 <env_destroy+0x6c>
	}

	env_free(e);
f010549b:	89 1c 24             	mov    %ebx,(%esp)
f010549e:	e8 ec fd ff ff       	call   f010528f <env_free>

	if (curenv == e) {
f01054a3:	e8 2c 2c 00 00       	call   f01080d4 <cpunum>
f01054a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01054af:	29 c2                	sub    %eax,%edx
f01054b1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01054b4:	39 1c 85 28 c0 24 f0 	cmp    %ebx,-0xfdb3fd8(,%eax,4)
f01054bb:	75 17                	jne    f01054d4 <env_destroy+0x6c>
		curenv = NULL;
f01054bd:	e8 12 2c 00 00       	call   f01080d4 <cpunum>
f01054c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01054c5:	c7 80 28 c0 24 f0 00 	movl   $0x0,-0xfdb3fd8(%eax)
f01054cc:	00 00 00 
		sched_yield();
f01054cf:	e8 7a 12 00 00       	call   f010674e <sched_yield>
	}
}
f01054d4:	83 c4 14             	add    $0x14,%esp
f01054d7:	5b                   	pop    %ebx
f01054d8:	5d                   	pop    %ebp
f01054d9:	c3                   	ret    

f01054da <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01054da:	55                   	push   %ebp
f01054db:	89 e5                	mov    %esp,%ebp
f01054dd:	53                   	push   %ebx
f01054de:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01054e1:	e8 ee 2b 00 00       	call   f01080d4 <cpunum>
f01054e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01054ed:	29 c2                	sub    %eax,%edx
f01054ef:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01054f2:	8b 1c 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%ebx
f01054f9:	e8 d6 2b 00 00       	call   f01080d4 <cpunum>
f01054fe:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0105501:	8b 65 08             	mov    0x8(%ebp),%esp
f0105504:	61                   	popa   
f0105505:	07                   	pop    %es
f0105506:	1f                   	pop    %ds
f0105507:	83 c4 08             	add    $0x8,%esp
f010550a:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010550b:	c7 44 24 08 20 aa 10 	movl   $0xf010aa20,0x8(%esp)
f0105512:	f0 
f0105513:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
f010551a:	00 
f010551b:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f0105522:	e8 19 ab ff ff       	call   f0100040 <_panic>

f0105527 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0105527:	55                   	push   %ebp
f0105528:	89 e5                	mov    %esp,%ebp
f010552a:	83 ec 18             	sub    $0x18,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f010552d:	e8 a2 2b 00 00       	call   f01080d4 <cpunum>
f0105532:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105539:	29 c2                	sub    %eax,%edx
f010553b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010553e:	83 3c 85 28 c0 24 f0 	cmpl   $0x0,-0xfdb3fd8(,%eax,4)
f0105545:	00 
f0105546:	74 33                	je     f010557b <env_run+0x54>
f0105548:	e8 87 2b 00 00       	call   f01080d4 <cpunum>
f010554d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105554:	29 c2                	sub    %eax,%edx
f0105556:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105559:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0105560:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105564:	75 15                	jne    f010557b <env_run+0x54>
        curenv->env_status = ENV_RUNNABLE;
f0105566:	e8 69 2b 00 00       	call   f01080d4 <cpunum>
f010556b:	6b c0 74             	imul   $0x74,%eax,%eax
f010556e:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0105574:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	// cprintf("env_run: %x %x\n",curenv,curenv->env_tf.tf_eip);
    curenv = e;
f010557b:	e8 54 2b 00 00       	call   f01080d4 <cpunum>
f0105580:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105587:	29 c2                	sub    %eax,%edx
f0105589:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010558c:	8b 55 08             	mov    0x8(%ebp),%edx
f010558f:	89 14 85 28 c0 24 f0 	mov    %edx,-0xfdb3fd8(,%eax,4)
	// cprintf("env %x\n",e);
    curenv->env_status = ENV_RUNNING;
f0105596:	e8 39 2b 00 00       	call   f01080d4 <cpunum>
f010559b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01055a2:	29 c2                	sub    %eax,%edx
f01055a4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01055a7:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f01055ae:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f01055b5:	e8 1a 2b 00 00       	call   f01080d4 <cpunum>
f01055ba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01055c1:	29 c2                	sub    %eax,%edx
f01055c3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01055c6:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f01055cd:	ff 40 58             	incl   0x58(%eax)
    lcr3(PADDR(curenv->env_pgdir));
f01055d0:	e8 ff 2a 00 00       	call   f01080d4 <cpunum>
f01055d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01055dc:	29 c2                	sub    %eax,%edx
f01055de:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01055e1:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f01055e8:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01055eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01055f0:	77 20                	ja     f0105612 <env_run+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01055f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01055f6:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01055fd:	f0 
f01055fe:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
f0105605:	00 
f0105606:	c7 04 24 ce a9 10 f0 	movl   $0xf010a9ce,(%esp)
f010560d:	e8 2e aa ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0105612:	05 00 00 00 10       	add    $0x10000000,%eax
f0105617:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010561a:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f0105621:	e8 10 2e 00 00       	call   f0108436 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105626:	f3 90                	pause  
	unlock_kernel();
	// cprintf("env_run: %x %x\n",curenv,curenv->env_tf.tf_eip);
    env_pop_tf(&curenv->env_tf);
f0105628:	e8 a7 2a 00 00       	call   f01080d4 <cpunum>
f010562d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105634:	29 c2                	sub    %eax,%edx
f0105636:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105639:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0105640:	89 04 24             	mov    %eax,(%esp)
f0105643:	e8 92 fe ff ff       	call   f01054da <env_pop_tf>

f0105648 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0105648:	55                   	push   %ebp
f0105649:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010564b:	ba 70 00 00 00       	mov    $0x70,%edx
f0105650:	8b 45 08             	mov    0x8(%ebp),%eax
f0105653:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105654:	b2 71                	mov    $0x71,%dl
f0105656:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0105657:	0f b6 c0             	movzbl %al,%eax
}
f010565a:	5d                   	pop    %ebp
f010565b:	c3                   	ret    

f010565c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010565c:	55                   	push   %ebp
f010565d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010565f:	ba 70 00 00 00       	mov    $0x70,%edx
f0105664:	8b 45 08             	mov    0x8(%ebp),%eax
f0105667:	ee                   	out    %al,(%dx)
f0105668:	b2 71                	mov    $0x71,%dl
f010566a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010566d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010566e:	5d                   	pop    %ebp
f010566f:	c3                   	ret    

f0105670 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0105670:	55                   	push   %ebp
f0105671:	89 e5                	mov    %esp,%ebp
f0105673:	56                   	push   %esi
f0105674:	53                   	push   %ebx
f0105675:	83 ec 10             	sub    $0x10,%esp
f0105678:	8b 45 08             	mov    0x8(%ebp),%eax
f010567b:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f010567d:	66 a3 e8 f1 14 f0    	mov    %ax,0xf014f1e8
	if (!didinit)
f0105683:	80 3d 58 b2 24 f0 00 	cmpb   $0x0,0xf024b258
f010568a:	74 51                	je     f01056dd <irq_setmask_8259A+0x6d>
f010568c:	ba 21 00 00 00       	mov    $0x21,%edx
f0105691:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0105692:	89 f0                	mov    %esi,%eax
f0105694:	66 c1 e8 08          	shr    $0x8,%ax
f0105698:	b2 a1                	mov    $0xa1,%dl
f010569a:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f010569b:	c7 04 24 2c aa 10 f0 	movl   $0xf010aa2c,(%esp)
f01056a2:	e8 e7 00 00 00       	call   f010578e <cprintf>
	for (i = 0; i < 16; i++)
f01056a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01056ac:	0f b7 f6             	movzwl %si,%esi
f01056af:	f7 d6                	not    %esi
f01056b1:	89 f0                	mov    %esi,%eax
f01056b3:	88 d9                	mov    %bl,%cl
f01056b5:	d3 f8                	sar    %cl,%eax
f01056b7:	a8 01                	test   $0x1,%al
f01056b9:	74 10                	je     f01056cb <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f01056bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01056bf:	c7 04 24 cb ae 10 f0 	movl   $0xf010aecb,(%esp)
f01056c6:	e8 c3 00 00 00       	call   f010578e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01056cb:	43                   	inc    %ebx
f01056cc:	83 fb 10             	cmp    $0x10,%ebx
f01056cf:	75 e0                	jne    f01056b1 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01056d1:	c7 04 24 28 a9 10 f0 	movl   $0xf010a928,(%esp)
f01056d8:	e8 b1 00 00 00       	call   f010578e <cprintf>
}
f01056dd:	83 c4 10             	add    $0x10,%esp
f01056e0:	5b                   	pop    %ebx
f01056e1:	5e                   	pop    %esi
f01056e2:	5d                   	pop    %ebp
f01056e3:	c3                   	ret    

f01056e4 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01056e4:	55                   	push   %ebp
f01056e5:	89 e5                	mov    %esp,%ebp
f01056e7:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f01056ea:	c6 05 58 b2 24 f0 01 	movb   $0x1,0xf024b258
f01056f1:	ba 21 00 00 00       	mov    $0x21,%edx
f01056f6:	b0 ff                	mov    $0xff,%al
f01056f8:	ee                   	out    %al,(%dx)
f01056f9:	b2 a1                	mov    $0xa1,%dl
f01056fb:	ee                   	out    %al,(%dx)
f01056fc:	b2 20                	mov    $0x20,%dl
f01056fe:	b0 11                	mov    $0x11,%al
f0105700:	ee                   	out    %al,(%dx)
f0105701:	b2 21                	mov    $0x21,%dl
f0105703:	b0 20                	mov    $0x20,%al
f0105705:	ee                   	out    %al,(%dx)
f0105706:	b0 04                	mov    $0x4,%al
f0105708:	ee                   	out    %al,(%dx)
f0105709:	b0 03                	mov    $0x3,%al
f010570b:	ee                   	out    %al,(%dx)
f010570c:	b2 a0                	mov    $0xa0,%dl
f010570e:	b0 11                	mov    $0x11,%al
f0105710:	ee                   	out    %al,(%dx)
f0105711:	b2 a1                	mov    $0xa1,%dl
f0105713:	b0 28                	mov    $0x28,%al
f0105715:	ee                   	out    %al,(%dx)
f0105716:	b0 02                	mov    $0x2,%al
f0105718:	ee                   	out    %al,(%dx)
f0105719:	b0 01                	mov    $0x1,%al
f010571b:	ee                   	out    %al,(%dx)
f010571c:	b2 20                	mov    $0x20,%dl
f010571e:	b0 68                	mov    $0x68,%al
f0105720:	ee                   	out    %al,(%dx)
f0105721:	b0 0a                	mov    $0xa,%al
f0105723:	ee                   	out    %al,(%dx)
f0105724:	b2 a0                	mov    $0xa0,%dl
f0105726:	b0 68                	mov    $0x68,%al
f0105728:	ee                   	out    %al,(%dx)
f0105729:	b0 0a                	mov    $0xa,%al
f010572b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010572c:	66 a1 e8 f1 14 f0    	mov    0xf014f1e8,%ax
f0105732:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0105736:	74 0b                	je     f0105743 <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0105738:	0f b7 c0             	movzwl %ax,%eax
f010573b:	89 04 24             	mov    %eax,(%esp)
f010573e:	e8 2d ff ff ff       	call   f0105670 <irq_setmask_8259A>
}
f0105743:	c9                   	leave  
f0105744:	c3                   	ret    
f0105745:	00 00                	add    %al,(%eax)
	...

f0105748 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0105748:	55                   	push   %ebp
f0105749:	89 e5                	mov    %esp,%ebp
f010574b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010574e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105751:	89 04 24             	mov    %eax,(%esp)
f0105754:	e8 1c b3 ff ff       	call   f0100a75 <cputchar>
	*cnt++;
}
f0105759:	c9                   	leave  
f010575a:	c3                   	ret    

f010575b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010575b:	55                   	push   %ebp
f010575c:	89 e5                	mov    %esp,%ebp
f010575e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0105761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0105768:	8b 45 0c             	mov    0xc(%ebp),%eax
f010576b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010576f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105772:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105776:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105779:	89 44 24 04          	mov    %eax,0x4(%esp)
f010577d:	c7 04 24 48 57 10 f0 	movl   $0xf0105748,(%esp)
f0105784:	e8 cd 1c 00 00       	call   f0107456 <vprintfmt>
	return cnt;
}
f0105789:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010578c:	c9                   	leave  
f010578d:	c3                   	ret    

f010578e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010578e:	55                   	push   %ebp
f010578f:	89 e5                	mov    %esp,%ebp
f0105791:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0105794:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0105797:	89 44 24 04          	mov    %eax,0x4(%esp)
f010579b:	8b 45 08             	mov    0x8(%ebp),%eax
f010579e:	89 04 24             	mov    %eax,(%esp)
f01057a1:	e8 b5 ff ff ff       	call   f010575b <vcprintf>
	va_end(ap);

	return cnt;
}
f01057a6:	c9                   	leave  
f01057a7:	c3                   	ret    

f01057a8 <trap_init_percpu>:
void Handler_IRQ13();
void Handler_IRQ14();
void Handler_IRQ15();
void
trap_init_percpu(void)
{
f01057a8:	55                   	push   %ebp
f01057a9:	89 e5                	mov    %esp,%ebp
f01057ab:	57                   	push   %edi
f01057ac:	56                   	push   %esi
f01057ad:	53                   	push   %ebx
f01057ae:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	SETGATE(idt[IRQ_OFFSET],0,GD_KT,Handler_IRQ0,0);
f01057b1:	b8 e0 65 10 f0       	mov    $0xf01065e0,%eax
f01057b6:	66 a3 60 b3 24 f0    	mov    %ax,0xf024b360
f01057bc:	66 c7 05 62 b3 24 f0 	movw   $0x8,0xf024b362
f01057c3:	08 00 
f01057c5:	c6 05 64 b3 24 f0 00 	movb   $0x0,0xf024b364
f01057cc:	c6 05 65 b3 24 f0 8e 	movb   $0x8e,0xf024b365
f01057d3:	c1 e8 10             	shr    $0x10,%eax
f01057d6:	66 a3 66 b3 24 f0    	mov    %ax,0xf024b366
	SETGATE(idt[IRQ_OFFSET+1],0,GD_KT,Handler_IRQ1,0);
f01057dc:	b8 e6 65 10 f0       	mov    $0xf01065e6,%eax
f01057e1:	66 a3 68 b3 24 f0    	mov    %ax,0xf024b368
f01057e7:	66 c7 05 6a b3 24 f0 	movw   $0x8,0xf024b36a
f01057ee:	08 00 
f01057f0:	c6 05 6c b3 24 f0 00 	movb   $0x0,0xf024b36c
f01057f7:	c6 05 6d b3 24 f0 8e 	movb   $0x8e,0xf024b36d
f01057fe:	c1 e8 10             	shr    $0x10,%eax
f0105801:	66 a3 6e b3 24 f0    	mov    %ax,0xf024b36e
	SETGATE(idt[IRQ_OFFSET+2],0,GD_KT,Handler_IRQ2,0);
f0105807:	b8 ec 65 10 f0       	mov    $0xf01065ec,%eax
f010580c:	66 a3 70 b3 24 f0    	mov    %ax,0xf024b370
f0105812:	66 c7 05 72 b3 24 f0 	movw   $0x8,0xf024b372
f0105819:	08 00 
f010581b:	c6 05 74 b3 24 f0 00 	movb   $0x0,0xf024b374
f0105822:	c6 05 75 b3 24 f0 8e 	movb   $0x8e,0xf024b375
f0105829:	c1 e8 10             	shr    $0x10,%eax
f010582c:	66 a3 76 b3 24 f0    	mov    %ax,0xf024b376
	SETGATE(idt[IRQ_OFFSET+3],0,GD_KT,Handler_IRQ3,0);
f0105832:	b8 f2 65 10 f0       	mov    $0xf01065f2,%eax
f0105837:	66 a3 78 b3 24 f0    	mov    %ax,0xf024b378
f010583d:	66 c7 05 7a b3 24 f0 	movw   $0x8,0xf024b37a
f0105844:	08 00 
f0105846:	c6 05 7c b3 24 f0 00 	movb   $0x0,0xf024b37c
f010584d:	c6 05 7d b3 24 f0 8e 	movb   $0x8e,0xf024b37d
f0105854:	c1 e8 10             	shr    $0x10,%eax
f0105857:	66 a3 7e b3 24 f0    	mov    %ax,0xf024b37e
	SETGATE(idt[IRQ_OFFSET+4],0,GD_KT,Handler_IRQ4,0);
f010585d:	b8 f8 65 10 f0       	mov    $0xf01065f8,%eax
f0105862:	66 a3 80 b3 24 f0    	mov    %ax,0xf024b380
f0105868:	66 c7 05 82 b3 24 f0 	movw   $0x8,0xf024b382
f010586f:	08 00 
f0105871:	c6 05 84 b3 24 f0 00 	movb   $0x0,0xf024b384
f0105878:	c6 05 85 b3 24 f0 8e 	movb   $0x8e,0xf024b385
f010587f:	c1 e8 10             	shr    $0x10,%eax
f0105882:	66 a3 86 b3 24 f0    	mov    %ax,0xf024b386
	SETGATE(idt[IRQ_OFFSET+5],0,GD_KT,Handler_IRQ5,0);
f0105888:	b8 fe 65 10 f0       	mov    $0xf01065fe,%eax
f010588d:	66 a3 88 b3 24 f0    	mov    %ax,0xf024b388
f0105893:	66 c7 05 8a b3 24 f0 	movw   $0x8,0xf024b38a
f010589a:	08 00 
f010589c:	c6 05 8c b3 24 f0 00 	movb   $0x0,0xf024b38c
f01058a3:	c6 05 8d b3 24 f0 8e 	movb   $0x8e,0xf024b38d
f01058aa:	c1 e8 10             	shr    $0x10,%eax
f01058ad:	66 a3 8e b3 24 f0    	mov    %ax,0xf024b38e
	SETGATE(idt[IRQ_OFFSET+6],0,GD_KT,Handler_IRQ6,0);
f01058b3:	b8 04 66 10 f0       	mov    $0xf0106604,%eax
f01058b8:	66 a3 90 b3 24 f0    	mov    %ax,0xf024b390
f01058be:	66 c7 05 92 b3 24 f0 	movw   $0x8,0xf024b392
f01058c5:	08 00 
f01058c7:	c6 05 94 b3 24 f0 00 	movb   $0x0,0xf024b394
f01058ce:	c6 05 95 b3 24 f0 8e 	movb   $0x8e,0xf024b395
f01058d5:	c1 e8 10             	shr    $0x10,%eax
f01058d8:	66 a3 96 b3 24 f0    	mov    %ax,0xf024b396
	SETGATE(idt[IRQ_OFFSET+7],0,GD_KT,Handler_IRQ7,0);
f01058de:	b8 0a 66 10 f0       	mov    $0xf010660a,%eax
f01058e3:	66 a3 98 b3 24 f0    	mov    %ax,0xf024b398
f01058e9:	66 c7 05 9a b3 24 f0 	movw   $0x8,0xf024b39a
f01058f0:	08 00 
f01058f2:	c6 05 9c b3 24 f0 00 	movb   $0x0,0xf024b39c
f01058f9:	c6 05 9d b3 24 f0 8e 	movb   $0x8e,0xf024b39d
f0105900:	c1 e8 10             	shr    $0x10,%eax
f0105903:	66 a3 9e b3 24 f0    	mov    %ax,0xf024b39e
	SETGATE(idt[IRQ_OFFSET+8],0,GD_KT,Handler_IRQ8,0);
f0105909:	b8 10 66 10 f0       	mov    $0xf0106610,%eax
f010590e:	66 a3 a0 b3 24 f0    	mov    %ax,0xf024b3a0
f0105914:	66 c7 05 a2 b3 24 f0 	movw   $0x8,0xf024b3a2
f010591b:	08 00 
f010591d:	c6 05 a4 b3 24 f0 00 	movb   $0x0,0xf024b3a4
f0105924:	c6 05 a5 b3 24 f0 8e 	movb   $0x8e,0xf024b3a5
f010592b:	c1 e8 10             	shr    $0x10,%eax
f010592e:	66 a3 a6 b3 24 f0    	mov    %ax,0xf024b3a6
	SETGATE(idt[IRQ_OFFSET+9],0,GD_KT,Handler_IRQ9,0);
f0105934:	b8 16 66 10 f0       	mov    $0xf0106616,%eax
f0105939:	66 a3 a8 b3 24 f0    	mov    %ax,0xf024b3a8
f010593f:	66 c7 05 aa b3 24 f0 	movw   $0x8,0xf024b3aa
f0105946:	08 00 
f0105948:	c6 05 ac b3 24 f0 00 	movb   $0x0,0xf024b3ac
f010594f:	c6 05 ad b3 24 f0 8e 	movb   $0x8e,0xf024b3ad
f0105956:	c1 e8 10             	shr    $0x10,%eax
f0105959:	66 a3 ae b3 24 f0    	mov    %ax,0xf024b3ae
	SETGATE(idt[IRQ_OFFSET+10],0,GD_KT,Handler_IRQ10,0);
f010595f:	b8 1c 66 10 f0       	mov    $0xf010661c,%eax
f0105964:	66 a3 b0 b3 24 f0    	mov    %ax,0xf024b3b0
f010596a:	66 c7 05 b2 b3 24 f0 	movw   $0x8,0xf024b3b2
f0105971:	08 00 
f0105973:	c6 05 b4 b3 24 f0 00 	movb   $0x0,0xf024b3b4
f010597a:	c6 05 b5 b3 24 f0 8e 	movb   $0x8e,0xf024b3b5
f0105981:	c1 e8 10             	shr    $0x10,%eax
f0105984:	66 a3 b6 b3 24 f0    	mov    %ax,0xf024b3b6
	SETGATE(idt[IRQ_OFFSET+11],0,GD_KT,Handler_IRQ11,0);
f010598a:	b8 22 66 10 f0       	mov    $0xf0106622,%eax
f010598f:	66 a3 b8 b3 24 f0    	mov    %ax,0xf024b3b8
f0105995:	66 c7 05 ba b3 24 f0 	movw   $0x8,0xf024b3ba
f010599c:	08 00 
f010599e:	c6 05 bc b3 24 f0 00 	movb   $0x0,0xf024b3bc
f01059a5:	c6 05 bd b3 24 f0 8e 	movb   $0x8e,0xf024b3bd
f01059ac:	c1 e8 10             	shr    $0x10,%eax
f01059af:	66 a3 be b3 24 f0    	mov    %ax,0xf024b3be
	SETGATE(idt[IRQ_OFFSET+12],0,GD_KT,Handler_IRQ12,0);
f01059b5:	b8 28 66 10 f0       	mov    $0xf0106628,%eax
f01059ba:	66 a3 c0 b3 24 f0    	mov    %ax,0xf024b3c0
f01059c0:	66 c7 05 c2 b3 24 f0 	movw   $0x8,0xf024b3c2
f01059c7:	08 00 
f01059c9:	c6 05 c4 b3 24 f0 00 	movb   $0x0,0xf024b3c4
f01059d0:	c6 05 c5 b3 24 f0 8e 	movb   $0x8e,0xf024b3c5
f01059d7:	c1 e8 10             	shr    $0x10,%eax
f01059da:	66 a3 c6 b3 24 f0    	mov    %ax,0xf024b3c6
	SETGATE(idt[IRQ_OFFSET+13],0,GD_KT,Handler_IRQ13,0);
f01059e0:	b8 2e 66 10 f0       	mov    $0xf010662e,%eax
f01059e5:	66 a3 c8 b3 24 f0    	mov    %ax,0xf024b3c8
f01059eb:	66 c7 05 ca b3 24 f0 	movw   $0x8,0xf024b3ca
f01059f2:	08 00 
f01059f4:	c6 05 cc b3 24 f0 00 	movb   $0x0,0xf024b3cc
f01059fb:	c6 05 cd b3 24 f0 8e 	movb   $0x8e,0xf024b3cd
f0105a02:	c1 e8 10             	shr    $0x10,%eax
f0105a05:	66 a3 ce b3 24 f0    	mov    %ax,0xf024b3ce
	SETGATE(idt[IRQ_OFFSET+14],0,GD_KT,Handler_IRQ14,0);
f0105a0b:	b8 34 66 10 f0       	mov    $0xf0106634,%eax
f0105a10:	66 a3 d0 b3 24 f0    	mov    %ax,0xf024b3d0
f0105a16:	66 c7 05 d2 b3 24 f0 	movw   $0x8,0xf024b3d2
f0105a1d:	08 00 
f0105a1f:	c6 05 d4 b3 24 f0 00 	movb   $0x0,0xf024b3d4
f0105a26:	c6 05 d5 b3 24 f0 8e 	movb   $0x8e,0xf024b3d5
f0105a2d:	c1 e8 10             	shr    $0x10,%eax
f0105a30:	66 a3 d6 b3 24 f0    	mov    %ax,0xf024b3d6
	SETGATE(idt[IRQ_OFFSET+15],0,GD_KT,Handler_IRQ15,0);
f0105a36:	b8 3a 66 10 f0       	mov    $0xf010663a,%eax
f0105a3b:	66 a3 d8 b3 24 f0    	mov    %ax,0xf024b3d8
f0105a41:	66 c7 05 da b3 24 f0 	movw   $0x8,0xf024b3da
f0105a48:	08 00 
f0105a4a:	c6 05 dc b3 24 f0 00 	movb   $0x0,0xf024b3dc
f0105a51:	c6 05 dd b3 24 f0 8e 	movb   $0x8e,0xf024b3dd
f0105a58:	c1 e8 10             	shr    $0x10,%eax
f0105a5b:	66 a3 de b3 24 f0    	mov    %ax,0xf024b3de
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	// cprintf("%x\n",thiscpu->cpu_ts);
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP);
f0105a61:	e8 6e 26 00 00       	call   f01080d4 <cpunum>
f0105a66:	89 c3                	mov    %eax,%ebx
f0105a68:	e8 67 26 00 00       	call   f01080d4 <cpunum>
f0105a6d:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0105a74:	29 da                	sub    %ebx,%edx
f0105a76:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0105a79:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0105a80:	29 c1                	sub    %eax,%ecx
f0105a82:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0105a85:	0f b6 04 85 20 c0 24 	movzbl -0xfdb3fe0(,%eax,4),%eax
f0105a8c:	f0 
f0105a8d:	f7 d8                	neg    %eax
f0105a8f:	c1 e0 10             	shl    $0x10,%eax
f0105a92:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105a97:	89 04 95 30 c0 24 f0 	mov    %eax,-0xfdb3fd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0105a9e:	e8 31 26 00 00       	call   f01080d4 <cpunum>
f0105aa3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105aaa:	29 c2                	sub    %eax,%edx
f0105aac:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105aaf:	66 c7 04 85 34 c0 24 	movw   $0x10,-0xfdb3fcc(,%eax,4)
f0105ab6:	f0 10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0105ab9:	e8 16 26 00 00       	call   f01080d4 <cpunum>
f0105abe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105ac5:	29 c2                	sub    %eax,%edx
f0105ac7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105aca:	66 c7 04 85 92 c0 24 	movw   $0x68,-0xfdb3f6e(,%eax,4)
f0105ad1:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id ] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0105ad4:	e8 fb 25 00 00       	call   f01080d4 <cpunum>
f0105ad9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105ae0:	29 c2                	sub    %eax,%edx
f0105ae2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105ae5:	0f b6 1c 85 20 c0 24 	movzbl -0xfdb3fe0(,%eax,4),%ebx
f0105aec:	f0 
f0105aed:	83 c3 05             	add    $0x5,%ebx
f0105af0:	e8 df 25 00 00       	call   f01080d4 <cpunum>
f0105af5:	89 c6                	mov    %eax,%esi
f0105af7:	e8 d8 25 00 00       	call   f01080d4 <cpunum>
f0105afc:	89 c7                	mov    %eax,%edi
f0105afe:	e8 d1 25 00 00       	call   f01080d4 <cpunum>
f0105b03:	66 c7 04 dd 80 f1 14 	movw   $0x67,-0xfeb0e80(,%ebx,8)
f0105b0a:	f0 67 00 
f0105b0d:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0105b14:	29 f2                	sub    %esi,%edx
f0105b16:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105b19:	8d 14 95 2c c0 24 f0 	lea    -0xfdb3fd4(,%edx,4),%edx
f0105b20:	66 89 14 dd 82 f1 14 	mov    %dx,-0xfeb0e7e(,%ebx,8)
f0105b27:	f0 
f0105b28:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0105b2f:	29 fa                	sub    %edi,%edx
f0105b31:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105b34:	8d 14 95 2c c0 24 f0 	lea    -0xfdb3fd4(,%edx,4),%edx
f0105b3b:	c1 ea 10             	shr    $0x10,%edx
f0105b3e:	88 14 dd 84 f1 14 f0 	mov    %dl,-0xfeb0e7c(,%ebx,8)
f0105b45:	c6 04 dd 85 f1 14 f0 	movb   $0x99,-0xfeb0e7b(,%ebx,8)
f0105b4c:	99 
f0105b4d:	c6 04 dd 86 f1 14 f0 	movb   $0x40,-0xfeb0e7a(,%ebx,8)
f0105b54:	40 
f0105b55:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105b5c:	29 c2                	sub    %eax,%edx
f0105b5e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105b61:	8d 04 85 2c c0 24 f0 	lea    -0xfdb3fd4(,%eax,4),%eax
f0105b68:	c1 e8 18             	shr    $0x18,%eax
f0105b6b:	88 04 dd 87 f1 14 f0 	mov    %al,-0xfeb0e79(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id ].sd_s = 0;
f0105b72:	e8 5d 25 00 00       	call   f01080d4 <cpunum>
f0105b77:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105b7e:	29 c2                	sub    %eax,%edx
f0105b80:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105b83:	0f b6 04 85 20 c0 24 	movzbl -0xfdb3fe0(,%eax,4),%eax
f0105b8a:	f0 
f0105b8b:	80 24 c5 ad f1 14 f0 	andb   $0xef,-0xfeb0e53(,%eax,8)
f0105b92:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + thiscpu->cpu_id * 8);
f0105b93:	e8 3c 25 00 00       	call   f01080d4 <cpunum>
f0105b98:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105b9f:	29 c2                	sub    %eax,%edx
f0105ba1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105ba4:	0f b6 04 85 20 c0 24 	movzbl -0xfdb3fe0(,%eax,4),%eax
f0105bab:	f0 
f0105bac:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0105bb3:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0105bb6:	b8 ec f1 14 f0       	mov    $0xf014f1ec,%eax
f0105bbb:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0105bbe:	83 c4 0c             	add    $0xc,%esp
f0105bc1:	5b                   	pop    %ebx
f0105bc2:	5e                   	pop    %esi
f0105bc3:	5f                   	pop    %edi
f0105bc4:	5d                   	pop    %ebp
f0105bc5:	c3                   	ret    

f0105bc6 <trap_init>:
void Handler_SIMDERR();
void Handler_SYSCALL();

void 
trap_init(void)
{
f0105bc6:	55                   	push   %ebp
f0105bc7:	89 e5                	mov    %esp,%ebp
f0105bc9:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
    SETGATE(idt[T_DIVIDE],0,GD_KT,Handler_DIVIDE,0);
f0105bcc:	b8 48 65 10 f0       	mov    $0xf0106548,%eax
f0105bd1:	66 a3 60 b2 24 f0    	mov    %ax,0xf024b260
f0105bd7:	66 c7 05 62 b2 24 f0 	movw   $0x8,0xf024b262
f0105bde:	08 00 
f0105be0:	c6 05 64 b2 24 f0 00 	movb   $0x0,0xf024b264
f0105be7:	c6 05 65 b2 24 f0 8e 	movb   $0x8e,0xf024b265
f0105bee:	c1 e8 10             	shr    $0x10,%eax
f0105bf1:	66 a3 66 b2 24 f0    	mov    %ax,0xf024b266
    SETGATE(idt[T_DEBUG],0,GD_KT,Handler_DEBUG,3);
f0105bf7:	b8 52 65 10 f0       	mov    $0xf0106552,%eax
f0105bfc:	66 a3 68 b2 24 f0    	mov    %ax,0xf024b268
f0105c02:	66 c7 05 6a b2 24 f0 	movw   $0x8,0xf024b26a
f0105c09:	08 00 
f0105c0b:	c6 05 6c b2 24 f0 00 	movb   $0x0,0xf024b26c
f0105c12:	c6 05 6d b2 24 f0 ee 	movb   $0xee,0xf024b26d
f0105c19:	c1 e8 10             	shr    $0x10,%eax
f0105c1c:	66 a3 6e b2 24 f0    	mov    %ax,0xf024b26e
    SETGATE(idt[T_NMI],0,GD_KT,Handler_NMI,0);
f0105c22:	b8 5c 65 10 f0       	mov    $0xf010655c,%eax
f0105c27:	66 a3 70 b2 24 f0    	mov    %ax,0xf024b270
f0105c2d:	66 c7 05 72 b2 24 f0 	movw   $0x8,0xf024b272
f0105c34:	08 00 
f0105c36:	c6 05 74 b2 24 f0 00 	movb   $0x0,0xf024b274
f0105c3d:	c6 05 75 b2 24 f0 8e 	movb   $0x8e,0xf024b275
f0105c44:	c1 e8 10             	shr    $0x10,%eax
f0105c47:	66 a3 76 b2 24 f0    	mov    %ax,0xf024b276
    SETGATE(idt[T_BRKPT],1,GD_KT,Handler_BRKPT,3);
f0105c4d:	b8 66 65 10 f0       	mov    $0xf0106566,%eax
f0105c52:	66 a3 78 b2 24 f0    	mov    %ax,0xf024b278
f0105c58:	66 c7 05 7a b2 24 f0 	movw   $0x8,0xf024b27a
f0105c5f:	08 00 
f0105c61:	c6 05 7c b2 24 f0 00 	movb   $0x0,0xf024b27c
f0105c68:	c6 05 7d b2 24 f0 ef 	movb   $0xef,0xf024b27d
f0105c6f:	c1 e8 10             	shr    $0x10,%eax
f0105c72:	66 a3 7e b2 24 f0    	mov    %ax,0xf024b27e
    SETGATE(idt[T_OFLOW],1,GD_KT,Handler_OFLOW,0);
f0105c78:	b8 70 65 10 f0       	mov    $0xf0106570,%eax
f0105c7d:	66 a3 80 b2 24 f0    	mov    %ax,0xf024b280
f0105c83:	66 c7 05 82 b2 24 f0 	movw   $0x8,0xf024b282
f0105c8a:	08 00 
f0105c8c:	c6 05 84 b2 24 f0 00 	movb   $0x0,0xf024b284
f0105c93:	c6 05 85 b2 24 f0 8f 	movb   $0x8f,0xf024b285
f0105c9a:	c1 e8 10             	shr    $0x10,%eax
f0105c9d:	66 a3 86 b2 24 f0    	mov    %ax,0xf024b286
    SETGATE(idt[T_BOUND],0,GD_KT,Handler_BOUND,0);
f0105ca3:	b8 7a 65 10 f0       	mov    $0xf010657a,%eax
f0105ca8:	66 a3 88 b2 24 f0    	mov    %ax,0xf024b288
f0105cae:	66 c7 05 8a b2 24 f0 	movw   $0x8,0xf024b28a
f0105cb5:	08 00 
f0105cb7:	c6 05 8c b2 24 f0 00 	movb   $0x0,0xf024b28c
f0105cbe:	c6 05 8d b2 24 f0 8e 	movb   $0x8e,0xf024b28d
f0105cc5:	c1 e8 10             	shr    $0x10,%eax
f0105cc8:	66 a3 8e b2 24 f0    	mov    %ax,0xf024b28e
    SETGATE(idt[T_ILLOP],0,GD_KT,Handler_ILLOP,0);
f0105cce:	b8 84 65 10 f0       	mov    $0xf0106584,%eax
f0105cd3:	66 a3 90 b2 24 f0    	mov    %ax,0xf024b290
f0105cd9:	66 c7 05 92 b2 24 f0 	movw   $0x8,0xf024b292
f0105ce0:	08 00 
f0105ce2:	c6 05 94 b2 24 f0 00 	movb   $0x0,0xf024b294
f0105ce9:	c6 05 95 b2 24 f0 8e 	movb   $0x8e,0xf024b295
f0105cf0:	c1 e8 10             	shr    $0x10,%eax
f0105cf3:	66 a3 96 b2 24 f0    	mov    %ax,0xf024b296
    SETGATE(idt[T_DEVICE],0,GD_KT,Handler_DEVICE,0);
f0105cf9:	b8 8e 65 10 f0       	mov    $0xf010658e,%eax
f0105cfe:	66 a3 98 b2 24 f0    	mov    %ax,0xf024b298
f0105d04:	66 c7 05 9a b2 24 f0 	movw   $0x8,0xf024b29a
f0105d0b:	08 00 
f0105d0d:	c6 05 9c b2 24 f0 00 	movb   $0x0,0xf024b29c
f0105d14:	c6 05 9d b2 24 f0 8e 	movb   $0x8e,0xf024b29d
f0105d1b:	c1 e8 10             	shr    $0x10,%eax
f0105d1e:	66 a3 9e b2 24 f0    	mov    %ax,0xf024b29e
    SETGATE(idt[T_DBLFLT],0,GD_KT,Handler_DBLFLT,0);
f0105d24:	b8 98 65 10 f0       	mov    $0xf0106598,%eax
f0105d29:	66 a3 a0 b2 24 f0    	mov    %ax,0xf024b2a0
f0105d2f:	66 c7 05 a2 b2 24 f0 	movw   $0x8,0xf024b2a2
f0105d36:	08 00 
f0105d38:	c6 05 a4 b2 24 f0 00 	movb   $0x0,0xf024b2a4
f0105d3f:	c6 05 a5 b2 24 f0 8e 	movb   $0x8e,0xf024b2a5
f0105d46:	c1 e8 10             	shr    $0x10,%eax
f0105d49:	66 a3 a6 b2 24 f0    	mov    %ax,0xf024b2a6
    SETGATE(idt[T_TSS],0,GD_KT,Handler_TSS,0);
f0105d4f:	b8 a0 65 10 f0       	mov    $0xf01065a0,%eax
f0105d54:	66 a3 b0 b2 24 f0    	mov    %ax,0xf024b2b0
f0105d5a:	66 c7 05 b2 b2 24 f0 	movw   $0x8,0xf024b2b2
f0105d61:	08 00 
f0105d63:	c6 05 b4 b2 24 f0 00 	movb   $0x0,0xf024b2b4
f0105d6a:	c6 05 b5 b2 24 f0 8e 	movb   $0x8e,0xf024b2b5
f0105d71:	c1 e8 10             	shr    $0x10,%eax
f0105d74:	66 a3 b6 b2 24 f0    	mov    %ax,0xf024b2b6
    SETGATE(idt[T_SEGNP],0,GD_KT,Handler_SEGNP,0);
f0105d7a:	b8 a8 65 10 f0       	mov    $0xf01065a8,%eax
f0105d7f:	66 a3 b8 b2 24 f0    	mov    %ax,0xf024b2b8
f0105d85:	66 c7 05 ba b2 24 f0 	movw   $0x8,0xf024b2ba
f0105d8c:	08 00 
f0105d8e:	c6 05 bc b2 24 f0 00 	movb   $0x0,0xf024b2bc
f0105d95:	c6 05 bd b2 24 f0 8e 	movb   $0x8e,0xf024b2bd
f0105d9c:	c1 e8 10             	shr    $0x10,%eax
f0105d9f:	66 a3 be b2 24 f0    	mov    %ax,0xf024b2be
    SETGATE(idt[T_STACK],0,GD_KT,Handler_STACK,0);
f0105da5:	b8 b0 65 10 f0       	mov    $0xf01065b0,%eax
f0105daa:	66 a3 c0 b2 24 f0    	mov    %ax,0xf024b2c0
f0105db0:	66 c7 05 c2 b2 24 f0 	movw   $0x8,0xf024b2c2
f0105db7:	08 00 
f0105db9:	c6 05 c4 b2 24 f0 00 	movb   $0x0,0xf024b2c4
f0105dc0:	c6 05 c5 b2 24 f0 8e 	movb   $0x8e,0xf024b2c5
f0105dc7:	c1 e8 10             	shr    $0x10,%eax
f0105dca:	66 a3 c6 b2 24 f0    	mov    %ax,0xf024b2c6
    SETGATE(idt[T_GPFLT],0,GD_KT,Handler_GPFLT,0);
f0105dd0:	b8 b8 65 10 f0       	mov    $0xf01065b8,%eax
f0105dd5:	66 a3 c8 b2 24 f0    	mov    %ax,0xf024b2c8
f0105ddb:	66 c7 05 ca b2 24 f0 	movw   $0x8,0xf024b2ca
f0105de2:	08 00 
f0105de4:	c6 05 cc b2 24 f0 00 	movb   $0x0,0xf024b2cc
f0105deb:	c6 05 cd b2 24 f0 8e 	movb   $0x8e,0xf024b2cd
f0105df2:	c1 e8 10             	shr    $0x10,%eax
f0105df5:	66 a3 ce b2 24 f0    	mov    %ax,0xf024b2ce
    SETGATE(idt[T_PGFLT],0,GD_KT,Handler_PGFLT,0);
f0105dfb:	b8 c0 65 10 f0       	mov    $0xf01065c0,%eax
f0105e00:	66 a3 d0 b2 24 f0    	mov    %ax,0xf024b2d0
f0105e06:	66 c7 05 d2 b2 24 f0 	movw   $0x8,0xf024b2d2
f0105e0d:	08 00 
f0105e0f:	c6 05 d4 b2 24 f0 00 	movb   $0x0,0xf024b2d4
f0105e16:	c6 05 d5 b2 24 f0 8e 	movb   $0x8e,0xf024b2d5
f0105e1d:	c1 e8 10             	shr    $0x10,%eax
f0105e20:	66 a3 d6 b2 24 f0    	mov    %ax,0xf024b2d6
    SETGATE(idt[T_FPERR],0,GD_KT,Handler_FPERR,0);
f0105e26:	b8 c4 65 10 f0       	mov    $0xf01065c4,%eax
f0105e2b:	66 a3 e0 b2 24 f0    	mov    %ax,0xf024b2e0
f0105e31:	66 c7 05 e2 b2 24 f0 	movw   $0x8,0xf024b2e2
f0105e38:	08 00 
f0105e3a:	c6 05 e4 b2 24 f0 00 	movb   $0x0,0xf024b2e4
f0105e41:	c6 05 e5 b2 24 f0 8e 	movb   $0x8e,0xf024b2e5
f0105e48:	c1 e8 10             	shr    $0x10,%eax
f0105e4b:	66 a3 e6 b2 24 f0    	mov    %ax,0xf024b2e6
    SETGATE(idt[T_ALIGN],0,GD_KT,Handler_ALIGN,0);
f0105e51:	b8 ca 65 10 f0       	mov    $0xf01065ca,%eax
f0105e56:	66 a3 e8 b2 24 f0    	mov    %ax,0xf024b2e8
f0105e5c:	66 c7 05 ea b2 24 f0 	movw   $0x8,0xf024b2ea
f0105e63:	08 00 
f0105e65:	c6 05 ec b2 24 f0 00 	movb   $0x0,0xf024b2ec
f0105e6c:	c6 05 ed b2 24 f0 8e 	movb   $0x8e,0xf024b2ed
f0105e73:	c1 e8 10             	shr    $0x10,%eax
f0105e76:	66 a3 ee b2 24 f0    	mov    %ax,0xf024b2ee
    SETGATE(idt[T_MCHK],0,GD_KT,Handler_MCHK,0);
f0105e7c:	b8 ce 65 10 f0       	mov    $0xf01065ce,%eax
f0105e81:	66 a3 f0 b2 24 f0    	mov    %ax,0xf024b2f0
f0105e87:	66 c7 05 f2 b2 24 f0 	movw   $0x8,0xf024b2f2
f0105e8e:	08 00 
f0105e90:	c6 05 f4 b2 24 f0 00 	movb   $0x0,0xf024b2f4
f0105e97:	c6 05 f5 b2 24 f0 8e 	movb   $0x8e,0xf024b2f5
f0105e9e:	c1 e8 10             	shr    $0x10,%eax
f0105ea1:	66 a3 f6 b2 24 f0    	mov    %ax,0xf024b2f6
    SETGATE(idt[T_SIMDERR],0,GD_KT,Handler_SIMDERR,0);
f0105ea7:	b8 d4 65 10 f0       	mov    $0xf01065d4,%eax
f0105eac:	66 a3 f8 b2 24 f0    	mov    %ax,0xf024b2f8
f0105eb2:	66 c7 05 fa b2 24 f0 	movw   $0x8,0xf024b2fa
f0105eb9:	08 00 
f0105ebb:	c6 05 fc b2 24 f0 00 	movb   $0x0,0xf024b2fc
f0105ec2:	c6 05 fd b2 24 f0 8e 	movb   $0x8e,0xf024b2fd
f0105ec9:	c1 e8 10             	shr    $0x10,%eax
f0105ecc:	66 a3 fe b2 24 f0    	mov    %ax,0xf024b2fe
    SETGATE(idt[T_SYSCALL],0,GD_KT,Handler_SYSCALL,3);
f0105ed2:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f0105ed7:	66 a3 e0 b3 24 f0    	mov    %ax,0xf024b3e0
f0105edd:	66 c7 05 e2 b3 24 f0 	movw   $0x8,0xf024b3e2
f0105ee4:	08 00 
f0105ee6:	c6 05 e4 b3 24 f0 00 	movb   $0x0,0xf024b3e4
f0105eed:	c6 05 e5 b3 24 f0 ee 	movb   $0xee,0xf024b3e5
f0105ef4:	c1 e8 10             	shr    $0x10,%eax
f0105ef7:	66 a3 e6 b3 24 f0    	mov    %ax,0xf024b3e6
	// Per-CPU setup 
	trap_init_percpu();
f0105efd:	e8 a6 f8 ff ff       	call   f01057a8 <trap_init_percpu>
}
f0105f02:	c9                   	leave  
f0105f03:	c3                   	ret    

f0105f04 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0105f04:	55                   	push   %ebp
f0105f05:	89 e5                	mov    %esp,%ebp
f0105f07:	53                   	push   %ebx
f0105f08:	83 ec 14             	sub    $0x14,%esp
f0105f0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0105f0e:	8b 03                	mov    (%ebx),%eax
f0105f10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f14:	c7 04 24 40 aa 10 f0 	movl   $0xf010aa40,(%esp)
f0105f1b:	e8 6e f8 ff ff       	call   f010578e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0105f20:	8b 43 04             	mov    0x4(%ebx),%eax
f0105f23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f27:	c7 04 24 4f aa 10 f0 	movl   $0xf010aa4f,(%esp)
f0105f2e:	e8 5b f8 ff ff       	call   f010578e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0105f33:	8b 43 08             	mov    0x8(%ebx),%eax
f0105f36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f3a:	c7 04 24 5e aa 10 f0 	movl   $0xf010aa5e,(%esp)
f0105f41:	e8 48 f8 ff ff       	call   f010578e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0105f46:	8b 43 0c             	mov    0xc(%ebx),%eax
f0105f49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f4d:	c7 04 24 6d aa 10 f0 	movl   $0xf010aa6d,(%esp)
f0105f54:	e8 35 f8 ff ff       	call   f010578e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0105f59:	8b 43 10             	mov    0x10(%ebx),%eax
f0105f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f60:	c7 04 24 7c aa 10 f0 	movl   $0xf010aa7c,(%esp)
f0105f67:	e8 22 f8 ff ff       	call   f010578e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0105f6c:	8b 43 14             	mov    0x14(%ebx),%eax
f0105f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f73:	c7 04 24 8b aa 10 f0 	movl   $0xf010aa8b,(%esp)
f0105f7a:	e8 0f f8 ff ff       	call   f010578e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0105f7f:	8b 43 18             	mov    0x18(%ebx),%eax
f0105f82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f86:	c7 04 24 9a aa 10 f0 	movl   $0xf010aa9a,(%esp)
f0105f8d:	e8 fc f7 ff ff       	call   f010578e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0105f92:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105f95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f99:	c7 04 24 a9 aa 10 f0 	movl   $0xf010aaa9,(%esp)
f0105fa0:	e8 e9 f7 ff ff       	call   f010578e <cprintf>
}
f0105fa5:	83 c4 14             	add    $0x14,%esp
f0105fa8:	5b                   	pop    %ebx
f0105fa9:	5d                   	pop    %ebp
f0105faa:	c3                   	ret    

f0105fab <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0105fab:	55                   	push   %ebp
f0105fac:	89 e5                	mov    %esp,%ebp
f0105fae:	53                   	push   %ebx
f0105faf:	83 ec 14             	sub    $0x14,%esp
f0105fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105fb5:	e8 1a 21 00 00       	call   f01080d4 <cpunum>
f0105fba:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105fbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105fc2:	c7 04 24 0d ab 10 f0 	movl   $0xf010ab0d,(%esp)
f0105fc9:	e8 c0 f7 ff ff       	call   f010578e <cprintf>
	print_regs(&tf->tf_regs);
f0105fce:	89 1c 24             	mov    %ebx,(%esp)
f0105fd1:	e8 2e ff ff ff       	call   f0105f04 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0105fd6:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0105fda:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fde:	c7 04 24 2b ab 10 f0 	movl   $0xf010ab2b,(%esp)
f0105fe5:	e8 a4 f7 ff ff       	call   f010578e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0105fea:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0105fee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ff2:	c7 04 24 3e ab 10 f0 	movl   $0xf010ab3e,(%esp)
f0105ff9:	e8 90 f7 ff ff       	call   f010578e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0105ffe:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0106001:	83 f8 13             	cmp    $0x13,%eax
f0106004:	77 09                	ja     f010600f <print_trapframe+0x64>
		return excnames[trapno];
f0106006:	8b 14 85 e0 ad 10 f0 	mov    -0xfef5220(,%eax,4),%edx
f010600d:	eb 20                	jmp    f010602f <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f010600f:	83 f8 30             	cmp    $0x30,%eax
f0106012:	74 0f                	je     f0106023 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0106014:	8d 50 e0             	lea    -0x20(%eax),%edx
f0106017:	83 fa 0f             	cmp    $0xf,%edx
f010601a:	77 0e                	ja     f010602a <print_trapframe+0x7f>
		return "Hardware Interrupt";
f010601c:	ba c4 aa 10 f0       	mov    $0xf010aac4,%edx
f0106021:	eb 0c                	jmp    f010602f <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0106023:	ba b8 aa 10 f0       	mov    $0xf010aab8,%edx
f0106028:	eb 05                	jmp    f010602f <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f010602a:	ba d7 aa 10 f0       	mov    $0xf010aad7,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010602f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106033:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106037:	c7 04 24 51 ab 10 f0 	movl   $0xf010ab51,(%esp)
f010603e:	e8 4b f7 ff ff       	call   f010578e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0106043:	3b 1d 60 ba 24 f0    	cmp    0xf024ba60,%ebx
f0106049:	75 19                	jne    f0106064 <print_trapframe+0xb9>
f010604b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010604f:	75 13                	jne    f0106064 <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0106051:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0106054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106058:	c7 04 24 63 ab 10 f0 	movl   $0xf010ab63,(%esp)
f010605f:	e8 2a f7 ff ff       	call   f010578e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0106064:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0106067:	89 44 24 04          	mov    %eax,0x4(%esp)
f010606b:	c7 04 24 72 ab 10 f0 	movl   $0xf010ab72,(%esp)
f0106072:	e8 17 f7 ff ff       	call   f010578e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0106077:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010607b:	75 4d                	jne    f01060ca <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010607d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0106080:	a8 01                	test   $0x1,%al
f0106082:	74 07                	je     f010608b <print_trapframe+0xe0>
f0106084:	b9 e6 aa 10 f0       	mov    $0xf010aae6,%ecx
f0106089:	eb 05                	jmp    f0106090 <print_trapframe+0xe5>
f010608b:	b9 f1 aa 10 f0       	mov    $0xf010aaf1,%ecx
f0106090:	a8 02                	test   $0x2,%al
f0106092:	74 07                	je     f010609b <print_trapframe+0xf0>
f0106094:	ba fd aa 10 f0       	mov    $0xf010aafd,%edx
f0106099:	eb 05                	jmp    f01060a0 <print_trapframe+0xf5>
f010609b:	ba 03 ab 10 f0       	mov    $0xf010ab03,%edx
f01060a0:	a8 04                	test   $0x4,%al
f01060a2:	74 07                	je     f01060ab <print_trapframe+0x100>
f01060a4:	b8 08 ab 10 f0       	mov    $0xf010ab08,%eax
f01060a9:	eb 05                	jmp    f01060b0 <print_trapframe+0x105>
f01060ab:	b8 3d ac 10 f0       	mov    $0xf010ac3d,%eax
f01060b0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01060b4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01060b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060bc:	c7 04 24 80 ab 10 f0 	movl   $0xf010ab80,(%esp)
f01060c3:	e8 c6 f6 ff ff       	call   f010578e <cprintf>
f01060c8:	eb 0c                	jmp    f01060d6 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01060ca:	c7 04 24 28 a9 10 f0 	movl   $0xf010a928,(%esp)
f01060d1:	e8 b8 f6 ff ff       	call   f010578e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01060d6:	8b 43 30             	mov    0x30(%ebx),%eax
f01060d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060dd:	c7 04 24 8f ab 10 f0 	movl   $0xf010ab8f,(%esp)
f01060e4:	e8 a5 f6 ff ff       	call   f010578e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01060e9:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01060ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060f1:	c7 04 24 9e ab 10 f0 	movl   $0xf010ab9e,(%esp)
f01060f8:	e8 91 f6 ff ff       	call   f010578e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01060fd:	8b 43 38             	mov    0x38(%ebx),%eax
f0106100:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106104:	c7 04 24 b1 ab 10 f0 	movl   $0xf010abb1,(%esp)
f010610b:	e8 7e f6 ff ff       	call   f010578e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0106110:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0106114:	74 27                	je     f010613d <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0106116:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0106119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010611d:	c7 04 24 c0 ab 10 f0 	movl   $0xf010abc0,(%esp)
f0106124:	e8 65 f6 ff ff       	call   f010578e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0106129:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010612d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106131:	c7 04 24 cf ab 10 f0 	movl   $0xf010abcf,(%esp)
f0106138:	e8 51 f6 ff ff       	call   f010578e <cprintf>
	}
}
f010613d:	83 c4 14             	add    $0x14,%esp
f0106140:	5b                   	pop    %ebx
f0106141:	5d                   	pop    %ebp
f0106142:	c3                   	ret    

f0106143 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0106143:	55                   	push   %ebp
f0106144:	89 e5                	mov    %esp,%ebp
f0106146:	57                   	push   %edi
f0106147:	56                   	push   %esi
f0106148:	53                   	push   %ebx
f0106149:	83 ec 2c             	sub    $0x2c,%esp
f010614c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010614f:	0f 20 d0             	mov    %cr2,%eax
f0106152:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// cprintf("tf_cs:  %x\n",tf->tf_cs);
	if ( (tf->tf_cs&1)!=1 )
f0106155:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f0106159:	75 1c                	jne    f0106177 <page_fault_handler+0x34>
		panic("page_fault_handler: kernel page fault!\n");
f010615b:	c7 44 24 08 88 ad 10 	movl   $0xf010ad88,0x8(%esp)
f0106162:	f0 
f0106163:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f010616a:	00 
f010616b:	c7 04 24 e2 ab 10 f0 	movl   $0xf010abe2,(%esp)
f0106172:	e8 c9 9e ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall!=NULL){
f0106177:	e8 58 1f 00 00       	call   f01080d4 <cpunum>
f010617c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106183:	29 c2                	sub    %eax,%edx
f0106185:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106188:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f010618f:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0106193:	0f 84 d4 00 00 00    	je     f010626d <page_fault_handler+0x12a>
		// cprintf("%x\n",tf->tf_esp);
		struct UTrapframe *utf = (tf->tf_esp >= UXSTACKTOP || tf->tf_esp < UXSTACKTOP - PGSIZE) ? 
f0106199:	8b 43 3c             	mov    0x3c(%ebx),%eax
		(struct UTrapframe *)(UXSTACKTOP -  sizeof(struct UTrapframe)): (struct UTrapframe *)(tf->tf_esp - 4 - sizeof(struct UTrapframe));
f010619c:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f01061a2:	c7 45 e0 cc ff bf ee 	movl   $0xeebfffcc,-0x20(%ebp)
f01061a9:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01061af:	77 06                	ja     f01061b7 <page_fault_handler+0x74>
f01061b1:	83 e8 38             	sub    $0x38,%eax
f01061b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		// cprintf("find %x\n",utf);
		user_mem_assert(curenv,(const void*)utf,sizeof(struct UTrapframe),PTE_U|PTE_W|PTE_P);
f01061b7:	e8 18 1f 00 00       	call   f01080d4 <cpunum>
f01061bc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01061c3:	00 
f01061c4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01061cb:	00 
f01061cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01061cf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01061d6:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f01061dc:	89 04 24             	mov    %eax,(%esp)
f01061df:	e8 32 eb ff ff       	call   f0104d16 <user_mem_assert>
		// cprintf("find2\n");
		utf->utf_esp = tf->tf_esp;
f01061e4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01061e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01061ea:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01061ed:	8b 43 38             	mov    0x38(%ebx),%eax
f01061f0:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_eip = tf->tf_eip;
f01061f3:	8b 43 30             	mov    0x30(%ebx),%eax
f01061f6:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_regs = tf->tf_regs;
f01061f9:	89 d7                	mov    %edx,%edi
f01061fb:	83 c7 08             	add    $0x8,%edi
f01061fe:	89 de                	mov    %ebx,%esi
f0106200:	b8 20 00 00 00       	mov    $0x20,%eax
f0106205:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010620b:	74 03                	je     f0106210 <page_fault_handler+0xcd>
f010620d:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f010620e:	b0 1f                	mov    $0x1f,%al
f0106210:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0106216:	74 05                	je     f010621d <page_fault_handler+0xda>
f0106218:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010621a:	83 e8 02             	sub    $0x2,%eax
f010621d:	89 c1                	mov    %eax,%ecx
f010621f:	c1 e9 02             	shr    $0x2,%ecx
f0106222:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106224:	a8 02                	test   $0x2,%al
f0106226:	74 02                	je     f010622a <page_fault_handler+0xe7>
f0106228:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010622a:	a8 01                	test   $0x1,%al
f010622c:	74 01                	je     f010622f <page_fault_handler+0xec>
f010622e:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_err = tf->tf_trapno;
f010622f:	8b 43 28             	mov    0x28(%ebx),%eax
f0106232:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106235:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_fault_va = fault_va;
f0106238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010623b:	89 02                	mov    %eax,(%edx)
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010623d:	e8 92 1e 00 00       	call   f01080d4 <cpunum>
f0106242:	6b c0 74             	imul   $0x74,%eax,%eax
f0106245:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f010624b:	8b 40 64             	mov    0x64(%eax),%eax
f010624e:	89 43 30             	mov    %eax,0x30(%ebx)
		// cprintf("eip %x\n",tf->tf_eip);
		tf->tf_esp = (uintptr_t) utf;
f0106251:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106254:	89 53 3c             	mov    %edx,0x3c(%ebx)
		env_run(curenv);
f0106257:	e8 78 1e 00 00       	call   f01080d4 <cpunum>
f010625c:	6b c0 74             	imul   $0x74,%eax,%eax
f010625f:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0106265:	89 04 24             	mov    %eax,(%esp)
f0106268:	e8 ba f2 ff ff       	call   f0105527 <env_run>
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010626d:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0106270:	e8 5f 1e 00 00       	call   f01080d4 <cpunum>
		// cprintf("eip %x\n",tf->tf_eip);
		tf->tf_esp = (uintptr_t) utf;
		env_run(curenv);
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0106275:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106279:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010627c:	89 54 24 08          	mov    %edx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0106280:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106287:	29 c2                	sub    %eax,%edx
f0106289:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010628c:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
		// cprintf("eip %x\n",tf->tf_eip);
		tf->tf_esp = (uintptr_t) utf;
		env_run(curenv);
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0106293:	8b 40 48             	mov    0x48(%eax),%eax
f0106296:	89 44 24 04          	mov    %eax,0x4(%esp)
f010629a:	c7 04 24 b0 ad 10 f0 	movl   $0xf010adb0,(%esp)
f01062a1:	e8 e8 f4 ff ff       	call   f010578e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01062a6:	89 1c 24             	mov    %ebx,(%esp)
f01062a9:	e8 fd fc ff ff       	call   f0105fab <print_trapframe>
	env_destroy(curenv);
f01062ae:	e8 21 1e 00 00       	call   f01080d4 <cpunum>
f01062b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01062ba:	29 c2                	sub    %eax,%edx
f01062bc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01062bf:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f01062c6:	89 04 24             	mov    %eax,(%esp)
f01062c9:	e8 9a f1 ff ff       	call   f0105468 <env_destroy>
}
f01062ce:	83 c4 2c             	add    $0x2c,%esp
f01062d1:	5b                   	pop    %ebx
f01062d2:	5e                   	pop    %esi
f01062d3:	5f                   	pop    %edi
f01062d4:	5d                   	pop    %ebp
f01062d5:	c3                   	ret    

f01062d6 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01062d6:	55                   	push   %ebp
f01062d7:	89 e5                	mov    %esp,%ebp
f01062d9:	57                   	push   %edi
f01062da:	56                   	push   %esi
f01062db:	83 ec 20             	sub    $0x20,%esp
f01062de:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01062e1:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01062e2:	83 3d 80 be 24 f0 00 	cmpl   $0x0,0xf024be80
f01062e9:	74 01                	je     f01062ec <trap+0x16>
		asm volatile("hlt");
f01062eb:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01062ec:	e8 e3 1d 00 00       	call   f01080d4 <cpunum>
f01062f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01062f8:	29 c2                	sub    %eax,%edx
f01062fa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01062fd:	8d 14 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106304:	b8 01 00 00 00       	mov    $0x1,%eax
f0106309:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010630d:	83 f8 02             	cmp    $0x2,%eax
f0106310:	75 0c                	jne    f010631e <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0106312:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f0106319:	e8 75 20 00 00       	call   f0108393 <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010631e:	9c                   	pushf  
f010631f:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0106320:	f6 c4 02             	test   $0x2,%ah
f0106323:	74 24                	je     f0106349 <trap+0x73>
f0106325:	c7 44 24 0c ee ab 10 	movl   $0xf010abee,0xc(%esp)
f010632c:	f0 
f010632d:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0106334:	f0 
f0106335:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f010633c:	00 
f010633d:	c7 04 24 e2 ab 10 f0 	movl   $0xf010abe2,(%esp)
f0106344:	e8 f7 9c ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0106349:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010634d:	83 e0 03             	and    $0x3,%eax
f0106350:	83 f8 03             	cmp    $0x3,%eax
f0106353:	0f 85 a7 00 00 00    	jne    f0106400 <trap+0x12a>
f0106359:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f0106360:	e8 2e 20 00 00       	call   f0108393 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0106365:	e8 6a 1d 00 00       	call   f01080d4 <cpunum>
f010636a:	6b c0 74             	imul   $0x74,%eax,%eax
f010636d:	83 b8 28 c0 24 f0 00 	cmpl   $0x0,-0xfdb3fd8(%eax)
f0106374:	75 24                	jne    f010639a <trap+0xc4>
f0106376:	c7 44 24 0c 07 ac 10 	movl   $0xf010ac07,0xc(%esp)
f010637d:	f0 
f010637e:	c7 44 24 08 09 a6 10 	movl   $0xf010a609,0x8(%esp)
f0106385:	f0 
f0106386:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
f010638d:	00 
f010638e:	c7 04 24 e2 ab 10 f0 	movl   $0xf010abe2,(%esp)
f0106395:	e8 a6 9c ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010639a:	e8 35 1d 00 00       	call   f01080d4 <cpunum>
f010639f:	6b c0 74             	imul   $0x74,%eax,%eax
f01063a2:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f01063a8:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01063ac:	75 2d                	jne    f01063db <trap+0x105>
			env_free(curenv);
f01063ae:	e8 21 1d 00 00       	call   f01080d4 <cpunum>
f01063b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01063b6:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f01063bc:	89 04 24             	mov    %eax,(%esp)
f01063bf:	e8 cb ee ff ff       	call   f010528f <env_free>
			curenv = NULL;
f01063c4:	e8 0b 1d 00 00       	call   f01080d4 <cpunum>
f01063c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01063cc:	c7 80 28 c0 24 f0 00 	movl   $0x0,-0xfdb3fd8(%eax)
f01063d3:	00 00 00 
			sched_yield();
f01063d6:	e8 73 03 00 00       	call   f010674e <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01063db:	e8 f4 1c 00 00       	call   f01080d4 <cpunum>
f01063e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01063e3:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f01063e9:	b9 11 00 00 00       	mov    $0x11,%ecx
f01063ee:	89 c7                	mov    %eax,%edi
f01063f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01063f2:	e8 dd 1c 00 00       	call   f01080d4 <cpunum>
f01063f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01063fa:	8b b0 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0106400:	89 35 60 ba 24 f0    	mov    %esi,0xf024ba60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// cprintf("trap_dispatch %x\n",tf->tf_trapno);
	switch (tf->tf_trapno){
f0106406:	8b 46 28             	mov    0x28(%esi),%eax
f0106409:	83 f8 03             	cmp    $0x3,%eax
f010640c:	74 22                	je     f0106430 <trap+0x15a>
f010640e:	83 f8 03             	cmp    $0x3,%eax
f0106411:	77 07                	ja     f010641a <trap+0x144>
f0106413:	83 f8 01             	cmp    $0x1,%eax
f0106416:	75 67                	jne    f010647f <trap+0x1a9>
f0106418:	eb 23                	jmp    f010643d <trap+0x167>
f010641a:	83 f8 0e             	cmp    $0xe,%eax
f010641d:	74 07                	je     f0106426 <trap+0x150>
f010641f:	83 f8 30             	cmp    $0x30,%eax
f0106422:	75 5b                	jne    f010647f <trap+0x1a9>
f0106424:	eb 24                	jmp    f010644a <trap+0x174>
		case T_PGFLT: page_fault_handler(tf);break;
f0106426:	89 34 24             	mov    %esi,(%esp)
f0106429:	e8 15 fd ff ff       	call   f0106143 <page_fault_handler>
f010642e:	eb 4f                	jmp    f010647f <trap+0x1a9>
		case T_BRKPT: monitor(tf);return;
f0106430:	89 34 24             	mov    %esi,(%esp)
f0106433:	e8 77 b8 ff ff       	call   f0101caf <monitor>
f0106438:	e9 c8 00 00 00       	jmp    f0106505 <trap+0x22f>
		case T_DEBUG: monitor(tf);return;
f010643d:	89 34 24             	mov    %esi,(%esp)
f0106440:	e8 6a b8 ff ff       	call   f0101caf <monitor>
f0106445:	e9 bb 00 00 00       	jmp    f0106505 <trap+0x22f>
		case T_SYSCALL: {
			int32_t ret = syscall(tf->tf_regs.reg_eax,
f010644a:	8b 46 04             	mov    0x4(%esi),%eax
f010644d:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106451:	8b 06                	mov    (%esi),%eax
f0106453:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106457:	8b 46 10             	mov    0x10(%esi),%eax
f010645a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010645e:	8b 46 18             	mov    0x18(%esi),%eax
f0106461:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106465:	8b 46 14             	mov    0x14(%esi),%eax
f0106468:	89 44 24 04          	mov    %eax,0x4(%esp)
f010646c:	8b 46 1c             	mov    0x1c(%esi),%eax
f010646f:	89 04 24             	mov    %eax,(%esp)
f0106472:	e8 b3 03 00 00       	call   f010682a <syscall>
								  tf->tf_regs.reg_ebx,
								  tf->tf_regs.reg_edi,
								  tf->tf_regs.reg_esi);
			//if (ret < 0 && ret != -7)
			//	panic("trap_dispatch: system call %d\n",ret);
			tf->tf_regs.reg_eax = ret;
f0106477:	89 46 1c             	mov    %eax,0x1c(%esi)
f010647a:	e9 86 00 00 00       	jmp    f0106505 <trap+0x22f>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010647f:	8b 46 28             	mov    0x28(%esi),%eax
f0106482:	83 f8 27             	cmp    $0x27,%eax
f0106485:	75 16                	jne    f010649d <trap+0x1c7>
		cprintf("Spurious interrupt on irq 7\n");
f0106487:	c7 04 24 0e ac 10 f0 	movl   $0xf010ac0e,(%esp)
f010648e:	e8 fb f2 ff ff       	call   f010578e <cprintf>
		print_trapframe(tf);
f0106493:	89 34 24             	mov    %esi,(%esp)
f0106496:	e8 10 fb ff ff       	call   f0105fab <print_trapframe>
f010649b:	eb 68                	jmp    f0106505 <trap+0x22f>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	switch (tf->tf_trapno){
f010649d:	83 f8 21             	cmp    $0x21,%eax
f01064a0:	74 14                	je     f01064b6 <trap+0x1e0>
f01064a2:	83 f8 24             	cmp    $0x24,%eax
f01064a5:	74 16                	je     f01064bd <trap+0x1e7>
f01064a7:	83 f8 20             	cmp    $0x20,%eax
f01064aa:	75 18                	jne    f01064c4 <trap+0x1ee>
		case IRQ_OFFSET + IRQ_TIMER: {
			lapic_eoi();
f01064ac:	e8 7a 1d 00 00       	call   f010822b <lapic_eoi>
        	sched_yield();
f01064b1:	e8 98 02 00 00       	call   f010674e <sched_yield>
        	return;
		}
		case IRQ_OFFSET + IRQ_KBD:{
			kbd_intr();
f01064b6:	e8 50 a4 ff ff       	call   f010090b <kbd_intr>
f01064bb:	eb 48                	jmp    f0106505 <trap+0x22f>
			return;
		}
		case IRQ_OFFSET + IRQ_SERIAL: {
			serial_intr();
f01064bd:	e8 2e a4 ff ff       	call   f01008f0 <serial_intr>
f01064c2:	eb 41                	jmp    f0106505 <trap+0x22f>
	}
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01064c4:	89 34 24             	mov    %esi,(%esp)
f01064c7:	e8 df fa ff ff       	call   f0105fab <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01064cc:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01064d1:	75 1c                	jne    f01064ef <trap+0x219>
		panic("unhandled trap in kernel");
f01064d3:	c7 44 24 08 2b ac 10 	movl   $0xf010ac2b,0x8(%esp)
f01064da:	f0 
f01064db:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01064e2:	00 
f01064e3:	c7 04 24 e2 ab 10 f0 	movl   $0xf010abe2,(%esp)
f01064ea:	e8 51 9b ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01064ef:	e8 e0 1b 00 00       	call   f01080d4 <cpunum>
f01064f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01064f7:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f01064fd:	89 04 24             	mov    %eax,(%esp)
f0106500:	e8 63 ef ff ff       	call   f0105468 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0106505:	e8 ca 1b 00 00       	call   f01080d4 <cpunum>
f010650a:	6b c0 74             	imul   $0x74,%eax,%eax
f010650d:	83 b8 28 c0 24 f0 00 	cmpl   $0x0,-0xfdb3fd8(%eax)
f0106514:	74 2a                	je     f0106540 <trap+0x26a>
f0106516:	e8 b9 1b 00 00       	call   f01080d4 <cpunum>
f010651b:	6b c0 74             	imul   $0x74,%eax,%eax
f010651e:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0106524:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0106528:	75 16                	jne    f0106540 <trap+0x26a>
		env_run(curenv);
f010652a:	e8 a5 1b 00 00       	call   f01080d4 <cpunum>
f010652f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106532:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0106538:	89 04 24             	mov    %eax,(%esp)
f010653b:	e8 e7 ef ff ff       	call   f0105527 <env_run>
	else
		sched_yield();
f0106540:	e8 09 02 00 00       	call   f010674e <sched_yield>
f0106545:	00 00                	add    %al,(%eax)
	...

f0106548 <Handler_DIVIDE>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(Handler_DIVIDE, T_DIVIDE)
f0106548:	6a 00                	push   $0x0
f010654a:	6a 00                	push   $0x0
f010654c:	e9 ef 00 00 00       	jmp    f0106640 <_alltraps>
f0106551:	90                   	nop

f0106552 <Handler_DEBUG>:
TRAPHANDLER_NOEC(Handler_DEBUG, T_DEBUG)
f0106552:	6a 00                	push   $0x0
f0106554:	6a 01                	push   $0x1
f0106556:	e9 e5 00 00 00       	jmp    f0106640 <_alltraps>
f010655b:	90                   	nop

f010655c <Handler_NMI>:
TRAPHANDLER_NOEC(Handler_NMI, T_NMI)
f010655c:	6a 00                	push   $0x0
f010655e:	6a 02                	push   $0x2
f0106560:	e9 db 00 00 00       	jmp    f0106640 <_alltraps>
f0106565:	90                   	nop

f0106566 <Handler_BRKPT>:
TRAPHANDLER_NOEC(Handler_BRKPT, T_BRKPT)
f0106566:	6a 00                	push   $0x0
f0106568:	6a 03                	push   $0x3
f010656a:	e9 d1 00 00 00       	jmp    f0106640 <_alltraps>
f010656f:	90                   	nop

f0106570 <Handler_OFLOW>:
TRAPHANDLER_NOEC(Handler_OFLOW, T_OFLOW)
f0106570:	6a 00                	push   $0x0
f0106572:	6a 04                	push   $0x4
f0106574:	e9 c7 00 00 00       	jmp    f0106640 <_alltraps>
f0106579:	90                   	nop

f010657a <Handler_BOUND>:
TRAPHANDLER_NOEC(Handler_BOUND, T_BOUND)
f010657a:	6a 00                	push   $0x0
f010657c:	6a 05                	push   $0x5
f010657e:	e9 bd 00 00 00       	jmp    f0106640 <_alltraps>
f0106583:	90                   	nop

f0106584 <Handler_ILLOP>:
TRAPHANDLER_NOEC(Handler_ILLOP, T_ILLOP)
f0106584:	6a 00                	push   $0x0
f0106586:	6a 06                	push   $0x6
f0106588:	e9 b3 00 00 00       	jmp    f0106640 <_alltraps>
f010658d:	90                   	nop

f010658e <Handler_DEVICE>:
TRAPHANDLER_NOEC(Handler_DEVICE, T_DEVICE)
f010658e:	6a 00                	push   $0x0
f0106590:	6a 07                	push   $0x7
f0106592:	e9 a9 00 00 00       	jmp    f0106640 <_alltraps>
f0106597:	90                   	nop

f0106598 <Handler_DBLFLT>:
TRAPHANDLER(Handler_DBLFLT, T_DBLFLT)
f0106598:	6a 08                	push   $0x8
f010659a:	e9 a1 00 00 00       	jmp    f0106640 <_alltraps>
f010659f:	90                   	nop

f01065a0 <Handler_TSS>:
TRAPHANDLER(Handler_TSS, T_TSS)
f01065a0:	6a 0a                	push   $0xa
f01065a2:	e9 99 00 00 00       	jmp    f0106640 <_alltraps>
f01065a7:	90                   	nop

f01065a8 <Handler_SEGNP>:
TRAPHANDLER(Handler_SEGNP, T_SEGNP)
f01065a8:	6a 0b                	push   $0xb
f01065aa:	e9 91 00 00 00       	jmp    f0106640 <_alltraps>
f01065af:	90                   	nop

f01065b0 <Handler_STACK>:
TRAPHANDLER(Handler_STACK, T_STACK)
f01065b0:	6a 0c                	push   $0xc
f01065b2:	e9 89 00 00 00       	jmp    f0106640 <_alltraps>
f01065b7:	90                   	nop

f01065b8 <Handler_GPFLT>:
TRAPHANDLER(Handler_GPFLT, T_GPFLT)
f01065b8:	6a 0d                	push   $0xd
f01065ba:	e9 81 00 00 00       	jmp    f0106640 <_alltraps>
f01065bf:	90                   	nop

f01065c0 <Handler_PGFLT>:
TRAPHANDLER(Handler_PGFLT, T_PGFLT)
f01065c0:	6a 0e                	push   $0xe
f01065c2:	eb 7c                	jmp    f0106640 <_alltraps>

f01065c4 <Handler_FPERR>:
TRAPHANDLER_NOEC(Handler_FPERR, T_FPERR)
f01065c4:	6a 00                	push   $0x0
f01065c6:	6a 10                	push   $0x10
f01065c8:	eb 76                	jmp    f0106640 <_alltraps>

f01065ca <Handler_ALIGN>:
TRAPHANDLER(Handler_ALIGN, T_ALIGN)
f01065ca:	6a 11                	push   $0x11
f01065cc:	eb 72                	jmp    f0106640 <_alltraps>

f01065ce <Handler_MCHK>:
TRAPHANDLER_NOEC(Handler_MCHK, T_MCHK)
f01065ce:	6a 00                	push   $0x0
f01065d0:	6a 12                	push   $0x12
f01065d2:	eb 6c                	jmp    f0106640 <_alltraps>

f01065d4 <Handler_SIMDERR>:
TRAPHANDLER_NOEC(Handler_SIMDERR, T_SIMDERR)
f01065d4:	6a 00                	push   $0x0
f01065d6:	6a 13                	push   $0x13
f01065d8:	eb 66                	jmp    f0106640 <_alltraps>

f01065da <Handler_SYSCALL>:
TRAPHANDLER_NOEC(Handler_SYSCALL, T_SYSCALL)
f01065da:	6a 00                	push   $0x0
f01065dc:	6a 30                	push   $0x30
f01065de:	eb 60                	jmp    f0106640 <_alltraps>

f01065e0 <Handler_IRQ0>:



TRAPHANDLER_NOEC(Handler_IRQ0, IRQ_OFFSET)
f01065e0:	6a 00                	push   $0x0
f01065e2:	6a 20                	push   $0x20
f01065e4:	eb 5a                	jmp    f0106640 <_alltraps>

f01065e6 <Handler_IRQ1>:
TRAPHANDLER_NOEC(Handler_IRQ1, IRQ_OFFSET+1)
f01065e6:	6a 00                	push   $0x0
f01065e8:	6a 21                	push   $0x21
f01065ea:	eb 54                	jmp    f0106640 <_alltraps>

f01065ec <Handler_IRQ2>:
TRAPHANDLER_NOEC(Handler_IRQ2, IRQ_OFFSET+2)
f01065ec:	6a 00                	push   $0x0
f01065ee:	6a 22                	push   $0x22
f01065f0:	eb 4e                	jmp    f0106640 <_alltraps>

f01065f2 <Handler_IRQ3>:
TRAPHANDLER_NOEC(Handler_IRQ3, IRQ_OFFSET+3)
f01065f2:	6a 00                	push   $0x0
f01065f4:	6a 23                	push   $0x23
f01065f6:	eb 48                	jmp    f0106640 <_alltraps>

f01065f8 <Handler_IRQ4>:
TRAPHANDLER_NOEC(Handler_IRQ4, IRQ_OFFSET+4)
f01065f8:	6a 00                	push   $0x0
f01065fa:	6a 24                	push   $0x24
f01065fc:	eb 42                	jmp    f0106640 <_alltraps>

f01065fe <Handler_IRQ5>:
TRAPHANDLER_NOEC(Handler_IRQ5, IRQ_OFFSET+5)
f01065fe:	6a 00                	push   $0x0
f0106600:	6a 25                	push   $0x25
f0106602:	eb 3c                	jmp    f0106640 <_alltraps>

f0106604 <Handler_IRQ6>:
TRAPHANDLER_NOEC(Handler_IRQ6, IRQ_OFFSET+6)
f0106604:	6a 00                	push   $0x0
f0106606:	6a 26                	push   $0x26
f0106608:	eb 36                	jmp    f0106640 <_alltraps>

f010660a <Handler_IRQ7>:
TRAPHANDLER_NOEC(Handler_IRQ7, IRQ_OFFSET+7)
f010660a:	6a 00                	push   $0x0
f010660c:	6a 27                	push   $0x27
f010660e:	eb 30                	jmp    f0106640 <_alltraps>

f0106610 <Handler_IRQ8>:
TRAPHANDLER_NOEC(Handler_IRQ8, IRQ_OFFSET+8)
f0106610:	6a 00                	push   $0x0
f0106612:	6a 28                	push   $0x28
f0106614:	eb 2a                	jmp    f0106640 <_alltraps>

f0106616 <Handler_IRQ9>:
TRAPHANDLER_NOEC(Handler_IRQ9, IRQ_OFFSET+9)
f0106616:	6a 00                	push   $0x0
f0106618:	6a 29                	push   $0x29
f010661a:	eb 24                	jmp    f0106640 <_alltraps>

f010661c <Handler_IRQ10>:
TRAPHANDLER_NOEC(Handler_IRQ10, IRQ_OFFSET+10)
f010661c:	6a 00                	push   $0x0
f010661e:	6a 2a                	push   $0x2a
f0106620:	eb 1e                	jmp    f0106640 <_alltraps>

f0106622 <Handler_IRQ11>:
TRAPHANDLER_NOEC(Handler_IRQ11, IRQ_OFFSET+11)
f0106622:	6a 00                	push   $0x0
f0106624:	6a 2b                	push   $0x2b
f0106626:	eb 18                	jmp    f0106640 <_alltraps>

f0106628 <Handler_IRQ12>:
TRAPHANDLER_NOEC(Handler_IRQ12, IRQ_OFFSET+12)
f0106628:	6a 00                	push   $0x0
f010662a:	6a 2c                	push   $0x2c
f010662c:	eb 12                	jmp    f0106640 <_alltraps>

f010662e <Handler_IRQ13>:
TRAPHANDLER_NOEC(Handler_IRQ13, IRQ_OFFSET+13)
f010662e:	6a 00                	push   $0x0
f0106630:	6a 2d                	push   $0x2d
f0106632:	eb 0c                	jmp    f0106640 <_alltraps>

f0106634 <Handler_IRQ14>:
TRAPHANDLER_NOEC(Handler_IRQ14, IRQ_OFFSET+14)
f0106634:	6a 00                	push   $0x0
f0106636:	6a 2e                	push   $0x2e
f0106638:	eb 06                	jmp    f0106640 <_alltraps>

f010663a <Handler_IRQ15>:
TRAPHANDLER_NOEC(Handler_IRQ15, IRQ_OFFSET+15)
f010663a:	6a 00                	push   $0x0
f010663c:	6a 2f                	push   $0x2f
f010663e:	eb 00                	jmp    f0106640 <_alltraps>

f0106640 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushw $0x0
f0106640:	66 6a 00             	pushw  $0x0
    pushw %ds
f0106643:	66 1e                	pushw  %ds
	pushw $0x0
f0106645:	66 6a 00             	pushw  $0x0
    pushw %es
f0106648:	66 06                	pushw  %es
    pushal
f010664a:	60                   	pusha  
    movl $GD_KD, %eax
f010664b:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
f0106650:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f0106652:	8e c0                	mov    %eax,%es
    push %esp
f0106654:	54                   	push   %esp
f0106655:	e8 7c fc ff ff       	call   f01062d6 <trap>
	...

f010665c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010665c:	55                   	push   %ebp
f010665d:	89 e5                	mov    %esp,%ebp
f010665f:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0106662:	8b 15 50 b2 24 f0    	mov    0xf024b250,%edx
f0106668:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010666b:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0106670:	8b 0a                	mov    (%edx),%ecx
f0106672:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0106673:	83 f9 02             	cmp    $0x2,%ecx
f0106676:	76 0d                	jbe    f0106685 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0106678:	40                   	inc    %eax
f0106679:	83 c2 7c             	add    $0x7c,%edx
f010667c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0106681:	75 ed                	jne    f0106670 <sched_halt+0x14>
f0106683:	eb 07                	jmp    f010668c <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0106685:	3d 00 04 00 00       	cmp    $0x400,%eax
f010668a:	75 1a                	jne    f01066a6 <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f010668c:	c7 04 24 30 ae 10 f0 	movl   $0xf010ae30,(%esp)
f0106693:	e8 f6 f0 ff ff       	call   f010578e <cprintf>
		while (1)
			monitor(NULL);
f0106698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010669f:	e8 0b b6 ff ff       	call   f0101caf <monitor>
f01066a4:	eb f2                	jmp    f0106698 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01066a6:	e8 29 1a 00 00       	call   f01080d4 <cpunum>
f01066ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01066b2:	29 c2                	sub    %eax,%edx
f01066b4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01066b7:	c7 04 85 28 c0 24 f0 	movl   $0x0,-0xfdb3fd8(,%eax,4)
f01066be:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f01066c2:	a1 8c be 24 f0       	mov    0xf024be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01066c7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01066cc:	77 20                	ja     f01066ee <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01066ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01066d2:	c7 44 24 08 c4 87 10 	movl   $0xf01087c4,0x8(%esp)
f01066d9:	f0 
f01066da:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
f01066e1:	00 
f01066e2:	c7 04 24 59 ae 10 f0 	movl   $0xf010ae59,(%esp)
f01066e9:	e8 52 99 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01066ee:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01066f3:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01066f6:	e8 d9 19 00 00       	call   f01080d4 <cpunum>
f01066fb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106702:	29 c2                	sub    %eax,%edx
f0106704:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106707:	8d 14 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010670e:	b8 02 00 00 00       	mov    $0x2,%eax
f0106713:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0106717:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f010671e:	e8 13 1d 00 00       	call   f0108436 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0106723:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0106725:	e8 aa 19 00 00       	call   f01080d4 <cpunum>
f010672a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106731:	29 c2                	sub    %eax,%edx
f0106733:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0106736:	8b 04 85 30 c0 24 f0 	mov    -0xfdb3fd0(,%eax,4),%eax
f010673d:	bd 00 00 00 00       	mov    $0x0,%ebp
f0106742:	89 c4                	mov    %eax,%esp
f0106744:	6a 00                	push   $0x0
f0106746:	6a 00                	push   $0x0
f0106748:	fb                   	sti    
f0106749:	f4                   	hlt    
f010674a:	eb fd                	jmp    f0106749 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010674c:	c9                   	leave  
f010674d:	c3                   	ret    

f010674e <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010674e:	55                   	push   %ebp
f010674f:	89 e5                	mov    %esp,%ebp
f0106751:	57                   	push   %edi
f0106752:	56                   	push   %esi
f0106753:	53                   	push   %ebx
f0106754:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("cpu_env: %x\n",thiscpu->cpu_env);
	struct Env*current_env = thiscpu->cpu_env;
f0106757:	e8 78 19 00 00       	call   f01080d4 <cpunum>
f010675c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106763:	29 c2                	sub    %eax,%edx
f0106765:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106768:	8b 3c 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%edi
	size_t id = 0;
	if (current_env != NULL)id = (ENVX(current_env->env_id) + 1) % NENV;
f010676f:	85 ff                	test   %edi,%edi
f0106771:	74 74                	je     f01067e7 <sched_yield+0x99>
f0106773:	8b 47 48             	mov    0x48(%edi),%eax
f0106776:	8d 40 01             	lea    0x1(%eax),%eax
f0106779:	25 ff 03 00 00       	and    $0x3ff,%eax
f010677e:	79 6c                	jns    f01067ec <sched_yield+0x9e>
f0106780:	48                   	dec    %eax
f0106781:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0106786:	40                   	inc    %eax
f0106787:	eb 63                	jmp    f01067ec <sched_yield+0x9e>
	for (int i = 0; i < NENV; i++,id = (id + 1) % NENV){
		if (envs[id].env_status == ENV_RUNNABLE){
f0106789:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f0106790:	89 c3                	mov    %eax,%ebx
f0106792:	c1 e3 07             	shl    $0x7,%ebx
f0106795:	29 f3                	sub    %esi,%ebx
f0106797:	89 de                	mov    %ebx,%esi
f0106799:	01 cb                	add    %ecx,%ebx
f010679b:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f010679f:	75 16                	jne    f01067b7 <sched_yield+0x69>
			envs[id].env_cpunum = cpunum();
f01067a1:	e8 2e 19 00 00       	call   f01080d4 <cpunum>
f01067a6:	89 43 5c             	mov    %eax,0x5c(%ebx)
			env_run(&envs[id]);
f01067a9:	03 35 50 b2 24 f0    	add    0xf024b250,%esi
f01067af:	89 34 24             	mov    %esi,(%esp)
f01067b2:	e8 70 ed ff ff       	call   f0105527 <env_run>
	// LAB 4: Your code here.
	// cprintf("cpu_env: %x\n",thiscpu->cpu_env);
	struct Env*current_env = thiscpu->cpu_env;
	size_t id = 0;
	if (current_env != NULL)id = (ENVX(current_env->env_id) + 1) % NENV;
	for (int i = 0; i < NENV; i++,id = (id + 1) % NENV){
f01067b7:	40                   	inc    %eax
f01067b8:	25 ff 03 00 00       	and    $0x3ff,%eax
f01067bd:	4a                   	dec    %edx
f01067be:	75 c9                	jne    f0106789 <sched_yield+0x3b>
			envs[id].env_cpunum = cpunum();
			env_run(&envs[id]);
			return;
		}
	}
	if (current_env != NULL && current_env->env_status == ENV_RUNNING){
f01067c0:	85 ff                	test   %edi,%edi
f01067c2:	74 16                	je     f01067da <sched_yield+0x8c>
f01067c4:	83 7f 54 03          	cmpl   $0x3,0x54(%edi)
f01067c8:	75 10                	jne    f01067da <sched_yield+0x8c>
		current_env->env_cpunum = cpunum();
f01067ca:	e8 05 19 00 00       	call   f01080d4 <cpunum>
f01067cf:	89 47 5c             	mov    %eax,0x5c(%edi)
		env_run(current_env);
f01067d2:	89 3c 24             	mov    %edi,(%esp)
f01067d5:	e8 4d ed ff ff       	call   f0105527 <env_run>
		return;
	}
	// sched_halt never returns
	sched_halt();
f01067da:	e8 7d fe ff ff       	call   f010665c <sched_halt>
}
f01067df:	83 c4 1c             	add    $0x1c,%esp
f01067e2:	5b                   	pop    %ebx
f01067e3:	5e                   	pop    %esi
f01067e4:	5f                   	pop    %edi
f01067e5:	5d                   	pop    %ebp
f01067e6:	c3                   	ret    
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("cpu_env: %x\n",thiscpu->cpu_env);
	struct Env*current_env = thiscpu->cpu_env;
	size_t id = 0;
f01067e7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (current_env != NULL)id = (ENVX(current_env->env_id) + 1) % NENV;
	for (int i = 0; i < NENV; i++,id = (id + 1) % NENV){
		if (envs[id].env_status == ENV_RUNNABLE){
f01067ec:	8b 0d 50 b2 24 f0    	mov    0xf024b250,%ecx
f01067f2:	ba 00 04 00 00       	mov    $0x400,%edx
f01067f7:	eb 90                	jmp    f0106789 <sched_yield+0x3b>
f01067f9:	00 00                	add    %al,(%eax)
	...

f01067fc <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f01067fc:	55                   	push   %ebp
f01067fd:	89 e5                	mov    %esp,%ebp
f01067ff:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0106802:	e8 cd 18 00 00       	call   f01080d4 <cpunum>
f0106807:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010680e:	29 c2                	sub    %eax,%edx
f0106810:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106813:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f010681a:	8b 40 48             	mov    0x48(%eax),%eax
}
f010681d:	c9                   	leave  
f010681e:	c3                   	ret    

f010681f <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f010681f:	55                   	push   %ebp
f0106820:	89 e5                	mov    %esp,%ebp
f0106822:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0106825:	e8 24 ff ff ff       	call   f010674e <sched_yield>

f010682a <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010682a:	55                   	push   %ebp
f010682b:	89 e5                	mov    %esp,%ebp
f010682d:	57                   	push   %edi
f010682e:	56                   	push   %esi
f010682f:	53                   	push   %ebx
f0106830:	83 ec 3c             	sub    $0x3c,%esp
f0106833:	8b 45 08             	mov    0x8(%ebp),%eax
f0106836:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106839:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010683c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	// cprintf("syscall %x %x %x\n",syscallno,a1,a2);
	int32_t res = 0;
	switch (syscallno){
f010683f:	83 f8 0d             	cmp    $0xd,%eax
f0106842:	0f 87 fb 05 00 00    	ja     f0106e43 <syscall+0x619>
f0106848:	ff 24 85 6c ae 10 f0 	jmp    *-0xfef5194(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(const void *)s,len,PTE_U);
f010684f:	e8 80 18 00 00       	call   f01080d4 <cpunum>
f0106854:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010685b:	00 
f010685c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106860:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106864:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010686b:	29 c2                	sub    %eax,%edx
f010686d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106870:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0106877:	89 04 24             	mov    %eax,(%esp)
f010687a:	e8 97 e4 ff ff       	call   f0104d16 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010687f:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106883:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106887:	c7 04 24 66 ae 10 f0 	movl   $0xf010ae66,(%esp)
f010688e:	e8 fb ee ff ff       	call   f010578e <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	// cprintf("syscall %x %x %x\n",syscallno,a1,a2);
	int32_t res = 0;
f0106893:	b8 00 00 00 00       	mov    $0x0,%eax
f0106898:	e9 b2 05 00 00       	jmp    f0106e4f <syscall+0x625>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010689d:	e8 7b a0 ff ff       	call   f010091d <cons_getc>
	int32_t res = 0;
	switch (syscallno){
		case SYS_cputs:
			sys_cputs((const char *)a1,a2);
			break;
		case SYS_cgetc:res = sys_cgetc();break;
f01068a2:	e9 a8 05 00 00       	jmp    f0106e4f <syscall+0x625>
		case SYS_getenvid:res = sys_getenvid();break;
f01068a7:	e8 50 ff ff ff       	call   f01067fc <sys_getenvid>
f01068ac:	e9 9e 05 00 00       	jmp    f0106e4f <syscall+0x625>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01068b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01068b8:	00 
f01068b9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01068bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068c0:	89 34 24             	mov    %esi,(%esp)
f01068c3:	e8 43 e5 ff ff       	call   f0104e0b <envid2env>
f01068c8:	85 c0                	test   %eax,%eax
f01068ca:	0f 88 7f 05 00 00    	js     f0106e4f <syscall+0x625>
		return r;
	env_destroy(e);
f01068d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01068d3:	89 04 24             	mov    %eax,(%esp)
f01068d6:	e8 8d eb ff ff       	call   f0105468 <env_destroy>
	return 0;
f01068db:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cputs:
			sys_cputs((const char *)a1,a2);
			break;
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
f01068e0:	e9 6a 05 00 00       	jmp    f0106e4f <syscall+0x625>
		case SYS_yield:sys_yield();break;
f01068e5:	e8 35 ff ff ff       	call   f010681f <sys_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *e;
	int err = env_alloc(&e,curenv->env_id);
f01068ea:	e8 e5 17 00 00       	call   f01080d4 <cpunum>
f01068ef:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01068f6:	29 c2                	sub    %eax,%edx
f01068f8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01068fb:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0106902:	8b 40 48             	mov    0x48(%eax),%eax
f0106905:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106909:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010690c:	89 04 24             	mov    %eax,(%esp)
f010690f:	e8 64 e6 ff ff       	call   f0104f78 <env_alloc>
	if (err < 0)return err;
f0106914:	85 c0                	test   %eax,%eax
f0106916:	0f 88 33 05 00 00    	js     f0106e4f <syscall+0x625>
	e->env_status = ENV_NOT_RUNNABLE;
f010691c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010691f:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0106926:	e8 a9 17 00 00       	call   f01080d4 <cpunum>
f010692b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106932:	29 c2                	sub    %eax,%edx
f0106934:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106937:	8b 34 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%esi
f010693e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0106943:	89 df                	mov    %ebx,%edi
f0106945:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0106947:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010694a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0106951:	8b 40 48             	mov    0x48(%eax),%eax
			break;
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
f0106954:	e9 f6 04 00 00       	jmp    f0106e4f <syscall+0x625>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_RUNNABLE && status != ENV_RUNNABLE)
f0106959:	83 fb 02             	cmp    $0x2,%ebx
f010695c:	75 33                	jne    f0106991 <syscall+0x167>
		return -E_INVAL;
	struct Env *e;
	int err = envid2env(envid,&e,1);
f010695e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106965:	00 
f0106966:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106969:	89 44 24 04          	mov    %eax,0x4(%esp)
f010696d:	89 34 24             	mov    %esi,(%esp)
f0106970:	e8 96 e4 ff ff       	call   f0104e0b <envid2env>
	if (err < 0)return err;
f0106975:	85 c0                	test   %eax,%eax
f0106977:	0f 88 d2 04 00 00    	js     f0106e4f <syscall+0x625>
	e->env_status = status;
f010697d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106980:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0106987:	b8 00 00 00 00       	mov    $0x0,%eax
f010698c:	e9 be 04 00 00       	jmp    f0106e4f <syscall+0x625>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_RUNNABLE && status != ENV_RUNNABLE)
		return -E_INVAL;
f0106991:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
f0106996:	e9 b4 04 00 00       	jmp    f0106e4f <syscall+0x625>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
f010699b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01069a2:	00 
f01069a3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01069a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069aa:	89 34 24             	mov    %esi,(%esp)
f01069ad:	e8 59 e4 ff ff       	call   f0104e0b <envid2env>
	if (err < 0)return err;
f01069b2:	85 c0                	test   %eax,%eax
f01069b4:	0f 88 95 04 00 00    	js     f0106e4f <syscall+0x625>
	// cprintf("sys_env_pgfault_upcall: %x\n",func);
	e->env_pgfault_upcall = func;
f01069ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01069bd:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f01069c0:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
f01069c5:	e9 85 04 00 00       	jmp    f0106e4f <syscall+0x625>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
f01069ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01069d1:	00 
f01069d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01069d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069d9:	89 34 24             	mov    %esi,(%esp)
f01069dc:	e8 2a e4 ff ff       	call   f0104e0b <envid2env>
	if (err < 0)return err;
f01069e1:	85 c0                	test   %eax,%eax
f01069e3:	0f 88 66 04 00 00    	js     f0106e4f <syscall+0x625>
	if ((uint32_t)va >= UTOP || PGOFF(va))return -E_INVAL;
f01069e9:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01069ef:	77 56                	ja     f0106a47 <syscall+0x21d>
f01069f1:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01069f7:	75 58                	jne    f0106a51 <syscall+0x227>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
f01069f9:	89 f8                	mov    %edi,%eax
f01069fb:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0106a00:	83 f8 05             	cmp    $0x5,%eax
f0106a03:	75 56                	jne    f0106a5b <syscall+0x231>
		return -E_INVAL;
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0106a05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106a0c:	e8 8c bd ff ff       	call   f010279d <page_alloc>
f0106a11:	89 c6                	mov    %eax,%esi
	if (page == NULL) return -E_NO_MEM;
f0106a13:	85 c0                	test   %eax,%eax
f0106a15:	74 4e                	je     f0106a65 <syscall+0x23b>
	err = page_insert(e->env_pgdir,page,va,perm);
f0106a17:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a23:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106a26:	8b 40 60             	mov    0x60(%eax),%eax
f0106a29:	89 04 24             	mov    %eax,(%esp)
f0106a2c:	e8 e2 c0 ff ff       	call   f0102b13 <page_insert>
	if (err<0){
f0106a31:	85 c0                	test   %eax,%eax
f0106a33:	79 3a                	jns    f0106a6f <syscall+0x245>
		page_free(page);
f0106a35:	89 34 24             	mov    %esi,(%esp)
f0106a38:	e8 e4 bd ff ff       	call   f0102821 <page_free>
		return -E_NO_MEM;
f0106a3d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106a42:	e9 08 04 00 00       	jmp    f0106e4f <syscall+0x625>

	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
	if (err < 0)return err;
	if ((uint32_t)va >= UTOP || PGOFF(va))return -E_INVAL;
f0106a47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106a4c:	e9 fe 03 00 00       	jmp    f0106e4f <syscall+0x625>
f0106a51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106a56:	e9 f4 03 00 00       	jmp    f0106e4f <syscall+0x625>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
		return -E_INVAL;
f0106a5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106a60:	e9 ea 03 00 00       	jmp    f0106e4f <syscall+0x625>
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
	if (page == NULL) return -E_NO_MEM;
f0106a65:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106a6a:	e9 e0 03 00 00       	jmp    f0106e4f <syscall+0x625>
	err = page_insert(e->env_pgdir,page,va,perm);
	if (err<0){
		page_free(page);
		return -E_NO_MEM;
	}
	return 0;
f0106a6f:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
f0106a74:	e9 d6 03 00 00       	jmp    f0106e4f <syscall+0x625>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env*esrc,*edst;
	int errsrc = envid2env(srcenvid,&esrc,1),errdst = envid2env(dstenvid,&edst,1);
f0106a79:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106a80:	00 
f0106a81:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106a84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a88:	89 34 24             	mov    %esi,(%esp)
f0106a8b:	e8 7b e3 ff ff       	call   f0104e0b <envid2env>
f0106a90:	89 c6                	mov    %eax,%esi
f0106a92:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106a99:	00 
f0106a9a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106aa1:	89 3c 24             	mov    %edi,(%esp)
f0106aa4:	e8 62 e3 ff ff       	call   f0104e0b <envid2env>
	if (errsrc < 0 || errdst < 0)return -E_BAD_ENV;
f0106aa9:	85 f6                	test   %esi,%esi
f0106aab:	0f 88 c4 00 00 00    	js     f0106b75 <syscall+0x34b>
f0106ab1:	85 c0                	test   %eax,%eax
f0106ab3:	0f 88 c6 00 00 00    	js     f0106b7f <syscall+0x355>
	if ((uint32_t)srcva >= UTOP || PGOFF(srcva) || (uint32_t)dstva >= UTOP || PGOFF(dstva))return -E_INVAL;
f0106ab9:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0106abf:	0f 87 c4 00 00 00    	ja     f0106b89 <syscall+0x35f>
f0106ac5:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0106acb:	0f 85 c2 00 00 00    	jne    f0106b93 <syscall+0x369>
f0106ad1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0106ad8:	0f 87 bf 00 00 00    	ja     f0106b9d <syscall+0x373>
f0106ade:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0106ae5:	0f 85 bc 00 00 00    	jne    f0106ba7 <syscall+0x37d>
	pte_t* pte;
	struct PageInfo* page = page_lookup(esrc->env_pgdir, srcva, &pte);
f0106aeb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106aee:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106af2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106af6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106af9:	8b 40 60             	mov    0x60(%eax),%eax
f0106afc:	89 04 24             	mov    %eax,(%esp)
f0106aff:	e8 10 bf ff ff       	call   f0102a14 <page_lookup>
f0106b04:	89 c3                	mov    %eax,%ebx
	if (page == NULL) return -E_INVAL;
f0106b06:	85 c0                	test   %eax,%eax
f0106b08:	0f 84 a3 00 00 00    	je     f0106bb1 <syscall+0x387>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
f0106b0e:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0106b11:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0106b16:	83 f8 05             	cmp    $0x5,%eax
f0106b19:	0f 85 9c 00 00 00    	jne    f0106bbb <syscall+0x391>
		return -E_INVAL;
	if ((perm & PTE_W)&&!(*pte & PTE_W))return -E_INVAL;
f0106b1f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0106b23:	74 0c                	je     f0106b31 <syscall+0x307>
f0106b25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106b28:	f6 00 02             	testb  $0x2,(%eax)
f0106b2b:	0f 84 94 00 00 00    	je     f0106bc5 <syscall+0x39b>
	struct PageInfo* pagedst = page_alloc(ALLOC_ZERO);
f0106b31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106b38:	e8 60 bc ff ff       	call   f010279d <page_alloc>
f0106b3d:	89 c6                	mov    %eax,%esi
	if (page == NULL) return -E_NO_MEM;
	int err = page_insert(edst->env_pgdir,page,dstva,perm);
f0106b3f:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0106b42:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106b46:	8b 55 18             	mov    0x18(%ebp),%edx
f0106b49:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106b51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106b54:	8b 40 60             	mov    0x60(%eax),%eax
f0106b57:	89 04 24             	mov    %eax,(%esp)
f0106b5a:	e8 b4 bf ff ff       	call   f0102b13 <page_insert>
	if (err < 0){
f0106b5f:	85 c0                	test   %eax,%eax
f0106b61:	79 6c                	jns    f0106bcf <syscall+0x3a5>
		page_free(pagedst);
f0106b63:	89 34 24             	mov    %esi,(%esp)
f0106b66:	e8 b6 bc ff ff       	call   f0102821 <page_free>
		return -E_NO_MEM;
f0106b6b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106b70:	e9 da 02 00 00       	jmp    f0106e4f <syscall+0x625>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env*esrc,*edst;
	int errsrc = envid2env(srcenvid,&esrc,1),errdst = envid2env(dstenvid,&edst,1);
	if (errsrc < 0 || errdst < 0)return -E_BAD_ENV;
f0106b75:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106b7a:	e9 d0 02 00 00       	jmp    f0106e4f <syscall+0x625>
f0106b7f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106b84:	e9 c6 02 00 00       	jmp    f0106e4f <syscall+0x625>
	if ((uint32_t)srcva >= UTOP || PGOFF(srcva) || (uint32_t)dstva >= UTOP || PGOFF(dstva))return -E_INVAL;
f0106b89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b8e:	e9 bc 02 00 00       	jmp    f0106e4f <syscall+0x625>
f0106b93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b98:	e9 b2 02 00 00       	jmp    f0106e4f <syscall+0x625>
f0106b9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ba2:	e9 a8 02 00 00       	jmp    f0106e4f <syscall+0x625>
f0106ba7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106bac:	e9 9e 02 00 00       	jmp    f0106e4f <syscall+0x625>
	pte_t* pte;
	struct PageInfo* page = page_lookup(esrc->env_pgdir, srcva, &pte);
	if (page == NULL) return -E_INVAL;
f0106bb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106bb6:	e9 94 02 00 00       	jmp    f0106e4f <syscall+0x625>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
		return -E_INVAL;
f0106bbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106bc0:	e9 8a 02 00 00       	jmp    f0106e4f <syscall+0x625>
	if ((perm & PTE_W)&&!(*pte & PTE_W))return -E_INVAL;
f0106bc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106bca:	e9 80 02 00 00       	jmp    f0106e4f <syscall+0x625>
	int err = page_insert(edst->env_pgdir,page,dstva,perm);
	if (err < 0){
		page_free(pagedst);
		return -E_NO_MEM;
	}
	return 0;
f0106bcf:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
f0106bd4:	e9 76 02 00 00       	jmp    f0106e4f <syscall+0x625>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
f0106bd9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106be0:	00 
f0106be1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106be4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106be8:	89 34 24             	mov    %esi,(%esp)
f0106beb:	e8 1b e2 ff ff       	call   f0104e0b <envid2env>
	if (err < 0)return err;
f0106bf0:	85 c0                	test   %eax,%eax
f0106bf2:	0f 88 57 02 00 00    	js     f0106e4f <syscall+0x625>
	pte_t*pte;
	struct PageInfo* page = page_lookup(e->env_pgdir,va,&pte);
f0106bf8:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106bff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106c03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106c06:	8b 40 60             	mov    0x60(%eax),%eax
f0106c09:	89 04 24             	mov    %eax,(%esp)
f0106c0c:	e8 03 be ff ff       	call   f0102a14 <page_lookup>
	if (pte == NULL || !(*pte & PTE_W))return -E_BAD_ENV;
f0106c11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106c14:	85 c0                	test   %eax,%eax
f0106c16:	74 31                	je     f0106c49 <syscall+0x41f>
f0106c18:	f6 00 02             	testb  $0x2,(%eax)
f0106c1b:	74 36                	je     f0106c53 <syscall+0x429>
	if ((uint32_t)va >= UTOP || PGOFF(va)) return -E_INVAL;
f0106c1d:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0106c23:	77 38                	ja     f0106c5d <syscall+0x433>
f0106c25:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0106c2b:	75 3a                	jne    f0106c67 <syscall+0x43d>
	page_remove(e->env_pgdir,va);
f0106c2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106c34:	8b 40 60             	mov    0x60(%eax),%eax
f0106c37:	89 04 24             	mov    %eax,(%esp)
f0106c3a:	e8 8b be ff ff       	call   f0102aca <page_remove>
	return 0;
f0106c3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106c44:	e9 06 02 00 00       	jmp    f0106e4f <syscall+0x625>
	struct Env *e;
	int err = envid2env(envid,&e,1);
	if (err < 0)return err;
	pte_t*pte;
	struct PageInfo* page = page_lookup(e->env_pgdir,va,&pte);
	if (pte == NULL || !(*pte & PTE_W))return -E_BAD_ENV;
f0106c49:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106c4e:	e9 fc 01 00 00       	jmp    f0106e4f <syscall+0x625>
f0106c53:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106c58:	e9 f2 01 00 00       	jmp    f0106e4f <syscall+0x625>
	if ((uint32_t)va >= UTOP || PGOFF(va)) return -E_INVAL;
f0106c5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106c62:	e9 e8 01 00 00       	jmp    f0106e4f <syscall+0x625>
f0106c67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
f0106c6c:	e9 de 01 00 00       	jmp    f0106e4f <syscall+0x625>
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	envid_t src_envid = sys_getenvid(); 
f0106c71:	e8 86 fb ff ff       	call   f01067fc <sys_getenvid>
f0106c76:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    struct Env *e;
	int err;
    err = envid2env(envid,&e,0);
f0106c79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106c80:	00 
f0106c81:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106c84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c88:	89 34 24             	mov    %esi,(%esp)
f0106c8b:	e8 7b e1 ff ff       	call   f0104e0b <envid2env>
	// cprintf("send: err %x\n",err);
	if (err<0)return err;
f0106c90:	85 c0                	test   %eax,%eax
f0106c92:	0f 88 b7 01 00 00    	js     f0106e4f <syscall+0x625>
    if (!e->env_ipc_recving)return -E_IPC_NOT_RECV;
f0106c98:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106c9b:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0106c9f:	0f 84 bb 00 00 00    	je     f0106d60 <syscall+0x536>
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
f0106ca5:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0106cab:	77 22                	ja     f0106ccf <syscall+0x4a5>
f0106cad:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0106cb3:	0f 85 b1 00 00 00    	jne    f0106d6a <syscall+0x540>
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
f0106cb9:	8b 45 18             	mov    0x18(%ebp),%eax
f0106cbc:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0106cc1:	83 f8 05             	cmp    $0x5,%eax
f0106cc4:	0f 84 8d 01 00 00    	je     f0106e57 <syscall+0x62d>
f0106cca:	e9 a5 00 00 00       	jmp    f0106d74 <syscall+0x54a>
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
f0106ccf:	e8 00 14 00 00       	call   f01080d4 <cpunum>
f0106cd4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0106cd7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106cdb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106cdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ce2:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0106ce8:	8b 40 60             	mov    0x60(%eax),%eax
f0106ceb:	89 04 24             	mov    %eax,(%esp)
f0106cee:	e8 21 bd ff ff       	call   f0102a14 <page_lookup>
	if ((uint32_t)srcva < UTOP){
		err = page_insert(e->env_pgdir,page,e->env_ipc_dstva,perm);
		if (err<0)return err;
	}
// cprintf("sys_ipc_try_send value %x\n",value);
    e->env_ipc_recving = false;
f0106cf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106cf6:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = src_envid;
f0106cfa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0106cfd:	89 48 74             	mov    %ecx,0x74(%eax)
	e->env_ipc_value = value;
f0106d00:	89 58 70             	mov    %ebx,0x70(%eax)
	e->env_ipc_perm = ((uint32_t)srcva < UTOP)?perm:0;
f0106d03:	be 00 00 00 00       	mov    $0x0,%esi
f0106d08:	eb 3b                	jmp    f0106d45 <syscall+0x51b>
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & PTE_W) && (~*pte & PTE_W))return -E_INVAL;
f0106d0a:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0106d0e:	74 08                	je     f0106d18 <syscall+0x4ee>
f0106d10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106d13:	f6 02 02             	testb  $0x2,(%edx)
f0106d16:	74 66                	je     f0106d7e <syscall+0x554>
	if ((uint32_t)srcva < UTOP){
		err = page_insert(e->env_pgdir,page,e->env_ipc_dstva,perm);
f0106d18:	8b 75 18             	mov    0x18(%ebp),%esi
f0106d1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106d1e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106d22:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0106d25:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106d29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d2d:	8b 42 60             	mov    0x60(%edx),%eax
f0106d30:	89 04 24             	mov    %eax,(%esp)
f0106d33:	e8 db bd ff ff       	call   f0102b13 <page_insert>
		if (err<0)return err;
f0106d38:	85 c0                	test   %eax,%eax
f0106d3a:	0f 89 52 01 00 00    	jns    f0106e92 <syscall+0x668>
f0106d40:	e9 0a 01 00 00       	jmp    f0106e4f <syscall+0x625>
	}
// cprintf("sys_ipc_try_send value %x\n",value);
    e->env_ipc_recving = false;
	e->env_ipc_from = src_envid;
	e->env_ipc_value = value;
	e->env_ipc_perm = ((uint32_t)srcva < UTOP)?perm:0;
f0106d45:	89 70 78             	mov    %esi,0x78(%eax)
 	e->env_status = ENV_RUNNABLE;
f0106d48:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	 
	e->env_tf.tf_regs.reg_eax = 0;
f0106d4f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0106d56:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d5b:	e9 ef 00 00 00       	jmp    f0106e4f <syscall+0x625>
    struct Env *e;
	int err;
    err = envid2env(envid,&e,0);
	// cprintf("send: err %x\n",err);
	if (err<0)return err;
    if (!e->env_ipc_recving)return -E_IPC_NOT_RECV;
f0106d60:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0106d65:	e9 e5 00 00 00       	jmp    f0106e4f <syscall+0x625>
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
f0106d6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d6f:	e9 db 00 00 00       	jmp    f0106e4f <syscall+0x625>
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
f0106d74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d79:	e9 d1 00 00 00       	jmp    f0106e4f <syscall+0x625>
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & PTE_W) && (~*pte & PTE_W))return -E_INVAL;
f0106d7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d83:	e9 c7 00 00 00       	jmp    f0106e4f <syscall+0x625>
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
f0106d88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
		case SYS_ipc_try_send:res = (int32_t)sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void *)a3,(unsigned)a4);break;                               
f0106d8d:	e9 bd 00 00 00       	jmp    f0106e4f <syscall+0x625>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva<UTOP&&PGOFF(dstva))return -E_INVAL;
f0106d92:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0106d98:	77 0c                	ja     f0106da6 <syscall+0x57c>
f0106d9a:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0106da0:	0f 85 a4 00 00 00    	jne    f0106e4a <syscall+0x620>
	curenv->env_ipc_recving = true;
f0106da6:	e8 29 13 00 00       	call   f01080d4 <cpunum>
f0106dab:	6b c0 74             	imul   $0x74,%eax,%eax
f0106dae:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0106db4:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0106db8:	e8 17 13 00 00       	call   f01080d4 <cpunum>
f0106dbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0106dc0:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0106dc6:	89 70 6c             	mov    %esi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0106dc9:	e8 06 13 00 00       	call   f01080d4 <cpunum>
f0106dce:	6b c0 74             	imul   $0x74,%eax,%eax
f0106dd1:	8b 80 28 c0 24 f0    	mov    -0xfdb3fd8(%eax),%eax
f0106dd7:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sys_yield();
f0106dde:	e8 3c fa ff ff       	call   f010681f <sys_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	int r;
	struct Env *e;
	if ((r = envid2env(envid,&e,true)) < 0)
f0106de3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106dea:	00 
f0106deb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106dee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106df2:	89 34 24             	mov    %esi,(%esp)
f0106df5:	e8 11 e0 ff ff       	call   f0104e0b <envid2env>
f0106dfa:	85 c0                	test   %eax,%eax
f0106dfc:	78 51                	js     f0106e4f <syscall+0x625>
		return r;

	user_mem_assert(e,(const void*)tf,sizeof(struct Trapframe),PTE_U);
f0106dfe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0106e05:	00 
f0106e06:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0106e0d:	00 
f0106e0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106e15:	89 04 24             	mov    %eax,(%esp)
f0106e18:	e8 f9 de ff ff       	call   f0104d16 <user_mem_assert>
	tf->tf_eflags = (tf->tf_eflags | FL_IF) & ~FL_IOPL_MASK;
f0106e1d:	8b 43 38             	mov    0x38(%ebx),%eax
f0106e20:	80 e4 cd             	and    $0xcd,%ah
f0106e23:	80 cc 02             	or     $0x2,%ah
f0106e26:	89 43 38             	mov    %eax,0x38(%ebx)
	tf->tf_cs |= 3;
f0106e29:	66 83 4b 34 03       	orw    $0x3,0x34(%ebx)
	e->env_tf = *tf;
f0106e2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106e31:	b9 11 00 00 00       	mov    $0x11,%ecx
f0106e36:	89 c7                	mov    %eax,%edi
f0106e38:	89 de                	mov    %ebx,%esi
f0106e3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return 0; 
f0106e3c:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
		case SYS_ipc_try_send:res = (int32_t)sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void *)a3,(unsigned)a4);break;                               
		case SYS_ipc_recv:res = (int32_t)sys_ipc_recv((void *)a1);break;
		case SYS_env_set_trapframe:res = (int32_t)sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);break;
f0106e41:	eb 0c                	jmp    f0106e4f <syscall+0x625>
		default:res = -E_INVAL;
f0106e43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e48:	eb 05                	jmp    f0106e4f <syscall+0x625>
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
		case SYS_ipc_try_send:res = (int32_t)sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void *)a3,(unsigned)a4);break;                               
		case SYS_ipc_recv:res = (int32_t)sys_ipc_recv((void *)a1);break;
f0106e4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	switch (syscallno) {
	default:
		return -E_INVAL;
	}
}
f0106e4f:	83 c4 3c             	add    $0x3c,%esp
f0106e52:	5b                   	pop    %ebx
f0106e53:	5e                   	pop    %esi
f0106e54:	5f                   	pop    %edi
f0106e55:	5d                   	pop    %ebp
f0106e56:	c3                   	ret    
    if (!e->env_ipc_recving)return -E_IPC_NOT_RECV;
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
f0106e57:	e8 78 12 00 00       	call   f01080d4 <cpunum>
f0106e5c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0106e5f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106e63:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106e67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106e6e:	29 c2                	sub    %eax,%edx
f0106e70:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106e73:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0106e7a:	8b 40 60             	mov    0x60(%eax),%eax
f0106e7d:	89 04 24             	mov    %eax,(%esp)
f0106e80:	e8 8f bb ff ff       	call   f0102a14 <page_lookup>
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
f0106e85:	85 c0                	test   %eax,%eax
f0106e87:	0f 85 7d fe ff ff    	jne    f0106d0a <syscall+0x4e0>
f0106e8d:	e9 f6 fe ff ff       	jmp    f0106d88 <syscall+0x55e>
	if ((uint32_t)srcva < UTOP){
		err = page_insert(e->env_pgdir,page,e->env_ipc_dstva,perm);
		if (err<0)return err;
	}
// cprintf("sys_ipc_try_send value %x\n",value);
    e->env_ipc_recving = false;
f0106e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106e95:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = src_envid;
f0106e99:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106e9c:	89 50 74             	mov    %edx,0x74(%eax)
	e->env_ipc_value = value;
f0106e9f:	89 58 70             	mov    %ebx,0x70(%eax)
f0106ea2:	e9 9e fe ff ff       	jmp    f0106d45 <syscall+0x51b>
	...

f0106ea8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0106ea8:	55                   	push   %ebp
f0106ea9:	89 e5                	mov    %esp,%ebp
f0106eab:	57                   	push   %edi
f0106eac:	56                   	push   %esi
f0106ead:	53                   	push   %ebx
f0106eae:	83 ec 14             	sub    $0x14,%esp
f0106eb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106eb4:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0106eb7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0106eba:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0106ebd:	8b 1a                	mov    (%edx),%ebx
f0106ebf:	8b 01                	mov    (%ecx),%eax
f0106ec1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106ec4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0106ecb:	e9 83 00 00 00       	jmp    f0106f53 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0106ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106ed3:	01 d8                	add    %ebx,%eax
f0106ed5:	89 c7                	mov    %eax,%edi
f0106ed7:	c1 ef 1f             	shr    $0x1f,%edi
f0106eda:	01 c7                	add    %eax,%edi
f0106edc:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106ede:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0106ee1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0106ee4:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0106ee8:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106eea:	eb 01                	jmp    f0106eed <stab_binsearch+0x45>
			m--;
f0106eec:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106eed:	39 c3                	cmp    %eax,%ebx
f0106eef:	7f 1e                	jg     f0106f0f <stab_binsearch+0x67>
f0106ef1:	0f b6 0a             	movzbl (%edx),%ecx
f0106ef4:	83 ea 0c             	sub    $0xc,%edx
f0106ef7:	39 f1                	cmp    %esi,%ecx
f0106ef9:	75 f1                	jne    f0106eec <stab_binsearch+0x44>
f0106efb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0106efe:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0106f01:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0106f04:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0106f08:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0106f0b:	76 18                	jbe    f0106f25 <stab_binsearch+0x7d>
f0106f0d:	eb 05                	jmp    f0106f14 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0106f0f:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0106f12:	eb 3f                	jmp    f0106f53 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0106f14:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106f17:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0106f19:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0106f1c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0106f23:	eb 2e                	jmp    f0106f53 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0106f25:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0106f28:	73 15                	jae    f0106f3f <stab_binsearch+0x97>
			*region_right = m - 1;
f0106f2a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106f2d:	49                   	dec    %ecx
f0106f2e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106f34:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0106f36:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0106f3d:	eb 14                	jmp    f0106f53 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0106f3f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106f42:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106f45:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f0106f47:	ff 45 0c             	incl   0xc(%ebp)
f0106f4a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0106f4c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0106f53:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0106f56:	0f 8e 74 ff ff ff    	jle    f0106ed0 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0106f5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106f60:	75 0d                	jne    f0106f6f <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0106f62:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106f65:	8b 02                	mov    (%edx),%eax
f0106f67:	48                   	dec    %eax
f0106f68:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106f6b:	89 01                	mov    %eax,(%ecx)
f0106f6d:	eb 2a                	jmp    f0106f99 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106f6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106f72:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0106f74:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106f77:	8b 0a                	mov    (%edx),%ecx
f0106f79:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0106f7c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0106f7f:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106f83:	eb 01                	jmp    f0106f86 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0106f85:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0106f86:	39 c8                	cmp    %ecx,%eax
f0106f88:	7e 0a                	jle    f0106f94 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0106f8a:	0f b6 1a             	movzbl (%edx),%ebx
f0106f8d:	83 ea 0c             	sub    $0xc,%edx
f0106f90:	39 f3                	cmp    %esi,%ebx
f0106f92:	75 f1                	jne    f0106f85 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0106f94:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106f97:	89 02                	mov    %eax,(%edx)
	}
}
f0106f99:	83 c4 14             	add    $0x14,%esp
f0106f9c:	5b                   	pop    %ebx
f0106f9d:	5e                   	pop    %esi
f0106f9e:	5f                   	pop    %edi
f0106f9f:	5d                   	pop    %ebp
f0106fa0:	c3                   	ret    

f0106fa1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0106fa1:	55                   	push   %ebp
f0106fa2:	89 e5                	mov    %esp,%ebp
f0106fa4:	57                   	push   %edi
f0106fa5:	56                   	push   %esi
f0106fa6:	53                   	push   %ebx
f0106fa7:	83 ec 5c             	sub    $0x5c,%esp
f0106faa:	8b 75 08             	mov    0x8(%ebp),%esi
f0106fad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0106fb0:	c7 03 a4 ae 10 f0    	movl   $0xf010aea4,(%ebx)
	info->eip_line = 0;
f0106fb6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0106fbd:	c7 43 08 a4 ae 10 f0 	movl   $0xf010aea4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0106fc4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0106fcb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0106fce:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0106fd5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0106fdb:	0f 87 0f 01 00 00    	ja     f01070f0 <debuginfo_eip+0x14f>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd,sizeof(struct UserStabData),PTE_U)<0)return -1;
f0106fe1:	e8 ee 10 00 00       	call   f01080d4 <cpunum>
f0106fe6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0106fed:	00 
f0106fee:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0106ff5:	00 
f0106ff6:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0106ffd:	00 
f0106ffe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0107005:	29 c2                	sub    %eax,%edx
f0107007:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010700a:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f0107011:	89 04 24             	mov    %eax,(%esp)
f0107014:	e8 5e dc ff ff       	call   f0104c77 <user_mem_check>
f0107019:	85 c0                	test   %eax,%eax
f010701b:	0f 88 85 02 00 00    	js     f01072a6 <debuginfo_eip+0x305>
		stabs = usd->stabs;
f0107021:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0107027:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010702a:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0107030:	a1 08 00 20 00       	mov    0x200008,%eax
f0107035:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0107038:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010703e:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
f0107041:	e8 8e 10 00 00       	call   f01080d4 <cpunum>
f0107046:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010704d:	00 
f010704e:	89 fa                	mov    %edi,%edx
f0107050:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0107053:	c1 fa 02             	sar    $0x2,%edx
f0107056:	8d 0c 92             	lea    (%edx,%edx,4),%ecx
f0107059:	8d 0c 8a             	lea    (%edx,%ecx,4),%ecx
f010705c:	8d 0c 8a             	lea    (%edx,%ecx,4),%ecx
f010705f:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0107062:	c1 e1 08             	shl    $0x8,%ecx
f0107065:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0107068:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f010706b:	03 4d b8             	add    -0x48(%ebp),%ecx
f010706e:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0107071:	c1 e1 10             	shl    $0x10,%ecx
f0107074:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0107077:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f010707a:	03 4d b8             	add    -0x48(%ebp),%ecx
f010707d:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
f0107080:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107084:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0107087:	89 54 24 04          	mov    %edx,0x4(%esp)
f010708b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0107092:	29 c2                	sub    %eax,%edx
f0107094:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0107097:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f010709e:	89 04 24             	mov    %eax,(%esp)
f01070a1:	e8 d1 db ff ff       	call   f0104c77 <user_mem_check>
f01070a6:	85 c0                	test   %eax,%eax
f01070a8:	0f 88 ff 01 00 00    	js     f01072ad <debuginfo_eip+0x30c>
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
f01070ae:	e8 21 10 00 00       	call   f01080d4 <cpunum>
f01070b3:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01070ba:	00 
f01070bb:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01070be:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01070c1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01070c5:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01070c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01070cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01070d3:	29 c2                	sub    %eax,%edx
f01070d5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01070d8:	8b 04 85 28 c0 24 f0 	mov    -0xfdb3fd8(,%eax,4),%eax
f01070df:	89 04 24             	mov    %eax,(%esp)
f01070e2:	e8 90 db ff ff       	call   f0104c77 <user_mem_check>
f01070e7:	85 c0                	test   %eax,%eax
f01070e9:	79 1f                	jns    f010710a <debuginfo_eip+0x169>
f01070eb:	e9 c4 01 00 00       	jmp    f01072b4 <debuginfo_eip+0x313>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01070f0:	c7 45 c0 00 3a 12 f0 	movl   $0xf0123a00,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01070f7:	c7 45 bc 31 89 11 f0 	movl   $0xf0118931,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01070fe:	bf 30 89 11 f0       	mov    $0xf0118930,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0107103:	c7 45 c4 30 b4 10 f0 	movl   $0xf010b430,-0x3c(%ebp)
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010710a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010710d:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0107110:	0f 83 a5 01 00 00    	jae    f01072bb <debuginfo_eip+0x31a>
f0107116:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010711a:	0f 85 a2 01 00 00    	jne    f01072c2 <debuginfo_eip+0x321>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0107120:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0107127:	89 f8                	mov    %edi,%eax
f0107129:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f010712c:	c1 f8 02             	sar    $0x2,%eax
f010712f:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0107132:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0107135:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0107138:	89 d1                	mov    %edx,%ecx
f010713a:	c1 e1 08             	shl    $0x8,%ecx
f010713d:	01 ca                	add    %ecx,%edx
f010713f:	89 d1                	mov    %edx,%ecx
f0107141:	c1 e1 10             	shl    $0x10,%ecx
f0107144:	01 ca                	add    %ecx,%edx
f0107146:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f010714a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010714d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107151:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0107158:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010715b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010715e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0107161:	e8 42 fd ff ff       	call   f0106ea8 <stab_binsearch>
	if (lfile == 0)
f0107166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107169:	85 c0                	test   %eax,%eax
f010716b:	0f 84 58 01 00 00    	je     f01072c9 <debuginfo_eip+0x328>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0107171:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0107174:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107177:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010717a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010717e:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0107185:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0107188:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010718b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010718e:	e8 15 fd ff ff       	call   f0106ea8 <stab_binsearch>

	if (lfun <= rfun) {
f0107193:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107196:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107199:	39 d0                	cmp    %edx,%eax
f010719b:	7f 32                	jg     f01071cf <debuginfo_eip+0x22e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010719d:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01071a0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01071a3:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01071a6:	8b 39                	mov    (%ecx),%edi
f01071a8:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01071ab:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01071ae:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01071b1:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01071b4:	73 09                	jae    f01071bf <debuginfo_eip+0x21e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01071b6:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01071b9:	03 7d bc             	add    -0x44(%ebp),%edi
f01071bc:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01071bf:	8b 49 08             	mov    0x8(%ecx),%ecx
f01071c2:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01071c5:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01071c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01071ca:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01071cd:	eb 0f                	jmp    f01071de <debuginfo_eip+0x23d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01071cf:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01071d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01071d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01071d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01071db:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01071de:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01071e5:	00 
f01071e6:	8b 43 08             	mov    0x8(%ebx),%eax
f01071e9:	89 04 24             	mov    %eax,(%esp)
f01071ec:	e8 9d 08 00 00       	call   f0107a8e <strfind>
f01071f1:	2b 43 08             	sub    0x8(%ebx),%eax
f01071f4:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01071f7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01071fb:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0107202:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0107205:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0107208:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010720b:	e8 98 fc ff ff       	call   f0106ea8 <stab_binsearch>
	if (lline <= rline){
f0107210:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0107213:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0107216:	0f 8f b4 00 00 00    	jg     f01072d0 <debuginfo_eip+0x32f>
		info->eip_line = stabs[lline].n_desc;
f010721c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010721f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0107222:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0107227:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010722a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010722d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0107230:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0107233:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f0107237:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010723a:	eb 04                	jmp    f0107240 <debuginfo_eip+0x29f>
f010723c:	48                   	dec    %eax
f010723d:	83 ea 0c             	sub    $0xc,%edx
f0107240:	89 c7                	mov    %eax,%edi
f0107242:	39 c6                	cmp    %eax,%esi
f0107244:	7f 28                	jg     f010726e <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f0107246:	8a 4a fc             	mov    -0x4(%edx),%cl
f0107249:	80 f9 84             	cmp    $0x84,%cl
f010724c:	0f 84 99 00 00 00    	je     f01072eb <debuginfo_eip+0x34a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0107252:	80 f9 64             	cmp    $0x64,%cl
f0107255:	75 e5                	jne    f010723c <debuginfo_eip+0x29b>
f0107257:	83 3a 00             	cmpl   $0x0,(%edx)
f010725a:	74 e0                	je     f010723c <debuginfo_eip+0x29b>
f010725c:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010725f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0107262:	e9 8a 00 00 00       	jmp    f01072f1 <debuginfo_eip+0x350>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0107267:	03 45 bc             	add    -0x44(%ebp),%eax
f010726a:	89 03                	mov    %eax,(%ebx)
f010726c:	eb 03                	jmp    f0107271 <debuginfo_eip+0x2d0>
f010726e:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0107271:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107274:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0107277:	39 f2                	cmp    %esi,%edx
f0107279:	7d 5c                	jge    f01072d7 <debuginfo_eip+0x336>
		for (lline = lfun + 1;
f010727b:	42                   	inc    %edx
f010727c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010727f:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0107281:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0107284:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0107287:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010728b:	eb 03                	jmp    f0107290 <debuginfo_eip+0x2ef>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010728d:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0107290:	39 f0                	cmp    %esi,%eax
f0107292:	7d 4a                	jge    f01072de <debuginfo_eip+0x33d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0107294:	8a 0a                	mov    (%edx),%cl
f0107296:	40                   	inc    %eax
f0107297:	83 c2 0c             	add    $0xc,%edx
f010729a:	80 f9 a0             	cmp    $0xa0,%cl
f010729d:	74 ee                	je     f010728d <debuginfo_eip+0x2ec>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010729f:	b8 00 00 00 00       	mov    $0x0,%eax
f01072a4:	eb 3d                	jmp    f01072e3 <debuginfo_eip+0x342>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd,sizeof(struct UserStabData),PTE_U)<0)return -1;
f01072a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01072ab:	eb 36                	jmp    f01072e3 <debuginfo_eip+0x342>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
f01072ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01072b2:	eb 2f                	jmp    f01072e3 <debuginfo_eip+0x342>
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
f01072b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01072b9:	eb 28                	jmp    f01072e3 <debuginfo_eip+0x342>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01072bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01072c0:	eb 21                	jmp    f01072e3 <debuginfo_eip+0x342>
f01072c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01072c7:	eb 1a                	jmp    f01072e3 <debuginfo_eip+0x342>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01072c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01072ce:	eb 13                	jmp    f01072e3 <debuginfo_eip+0x342>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline){
		info->eip_line = stabs[lline].n_desc;
	}
	else return -1;
f01072d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01072d5:	eb 0c                	jmp    f01072e3 <debuginfo_eip+0x342>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01072d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01072dc:	eb 05                	jmp    f01072e3 <debuginfo_eip+0x342>
f01072de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01072e3:	83 c4 5c             	add    $0x5c,%esp
f01072e6:	5b                   	pop    %ebx
f01072e7:	5e                   	pop    %esi
f01072e8:	5f                   	pop    %edi
f01072e9:	5d                   	pop    %ebp
f01072ea:	c3                   	ret    
f01072eb:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01072ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01072f1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01072f4:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01072f7:	8b 04 87             	mov    (%edi,%eax,4),%eax
f01072fa:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01072fd:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0107300:	39 d0                	cmp    %edx,%eax
f0107302:	0f 82 5f ff ff ff    	jb     f0107267 <debuginfo_eip+0x2c6>
f0107308:	e9 64 ff ff ff       	jmp    f0107271 <debuginfo_eip+0x2d0>
f010730d:	00 00                	add    %al,(%eax)
	...

f0107310 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0107310:	55                   	push   %ebp
f0107311:	89 e5                	mov    %esp,%ebp
f0107313:	57                   	push   %edi
f0107314:	56                   	push   %esi
f0107315:	53                   	push   %ebx
f0107316:	83 ec 3c             	sub    $0x3c,%esp
f0107319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010731c:	89 d7                	mov    %edx,%edi
f010731e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107321:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0107324:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107327:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010732a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010732d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0107330:	85 c0                	test   %eax,%eax
f0107332:	75 08                	jne    f010733c <printnum+0x2c>
f0107334:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107337:	39 45 10             	cmp    %eax,0x10(%ebp)
f010733a:	77 57                	ja     f0107393 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010733c:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107340:	4b                   	dec    %ebx
f0107341:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107345:	8b 45 10             	mov    0x10(%ebp),%eax
f0107348:	89 44 24 08          	mov    %eax,0x8(%esp)
f010734c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0107350:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0107354:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010735b:	00 
f010735c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010735f:	89 04 24             	mov    %eax,(%esp)
f0107362:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107365:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107369:	e8 d6 11 00 00       	call   f0108544 <__udivdi3>
f010736e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107372:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107376:	89 04 24             	mov    %eax,(%esp)
f0107379:	89 54 24 04          	mov    %edx,0x4(%esp)
f010737d:	89 fa                	mov    %edi,%edx
f010737f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107382:	e8 89 ff ff ff       	call   f0107310 <printnum>
f0107387:	eb 0f                	jmp    f0107398 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0107389:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010738d:	89 34 24             	mov    %esi,(%esp)
f0107390:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0107393:	4b                   	dec    %ebx
f0107394:	85 db                	test   %ebx,%ebx
f0107396:	7f f1                	jg     f0107389 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0107398:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010739c:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01073a0:	8b 45 10             	mov    0x10(%ebp),%eax
f01073a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01073a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01073ae:	00 
f01073af:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01073b2:	89 04 24             	mov    %eax,(%esp)
f01073b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01073b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01073bc:	e8 a3 12 00 00       	call   f0108664 <__umoddi3>
f01073c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01073c5:	0f be 80 ae ae 10 f0 	movsbl -0xfef5152(%eax),%eax
f01073cc:	89 04 24             	mov    %eax,(%esp)
f01073cf:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01073d2:	83 c4 3c             	add    $0x3c,%esp
f01073d5:	5b                   	pop    %ebx
f01073d6:	5e                   	pop    %esi
f01073d7:	5f                   	pop    %edi
f01073d8:	5d                   	pop    %ebp
f01073d9:	c3                   	ret    

f01073da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01073da:	55                   	push   %ebp
f01073db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01073dd:	83 fa 01             	cmp    $0x1,%edx
f01073e0:	7e 0e                	jle    f01073f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01073e2:	8b 10                	mov    (%eax),%edx
f01073e4:	8d 4a 08             	lea    0x8(%edx),%ecx
f01073e7:	89 08                	mov    %ecx,(%eax)
f01073e9:	8b 02                	mov    (%edx),%eax
f01073eb:	8b 52 04             	mov    0x4(%edx),%edx
f01073ee:	eb 22                	jmp    f0107412 <getuint+0x38>
	else if (lflag)
f01073f0:	85 d2                	test   %edx,%edx
f01073f2:	74 10                	je     f0107404 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01073f4:	8b 10                	mov    (%eax),%edx
f01073f6:	8d 4a 04             	lea    0x4(%edx),%ecx
f01073f9:	89 08                	mov    %ecx,(%eax)
f01073fb:	8b 02                	mov    (%edx),%eax
f01073fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0107402:	eb 0e                	jmp    f0107412 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0107404:	8b 10                	mov    (%eax),%edx
f0107406:	8d 4a 04             	lea    0x4(%edx),%ecx
f0107409:	89 08                	mov    %ecx,(%eax)
f010740b:	8b 02                	mov    (%edx),%eax
f010740d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0107412:	5d                   	pop    %ebp
f0107413:	c3                   	ret    

f0107414 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0107414:	55                   	push   %ebp
f0107415:	89 e5                	mov    %esp,%ebp
f0107417:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010741a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010741d:	8b 10                	mov    (%eax),%edx
f010741f:	3b 50 04             	cmp    0x4(%eax),%edx
f0107422:	73 08                	jae    f010742c <sprintputch+0x18>
		*b->buf++ = ch;
f0107424:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107427:	88 0a                	mov    %cl,(%edx)
f0107429:	42                   	inc    %edx
f010742a:	89 10                	mov    %edx,(%eax)
}
f010742c:	5d                   	pop    %ebp
f010742d:	c3                   	ret    

f010742e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010742e:	55                   	push   %ebp
f010742f:	89 e5                	mov    %esp,%ebp
f0107431:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0107434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0107437:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010743b:	8b 45 10             	mov    0x10(%ebp),%eax
f010743e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107442:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107445:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107449:	8b 45 08             	mov    0x8(%ebp),%eax
f010744c:	89 04 24             	mov    %eax,(%esp)
f010744f:	e8 02 00 00 00       	call   f0107456 <vprintfmt>
	va_end(ap);
}
f0107454:	c9                   	leave  
f0107455:	c3                   	ret    

f0107456 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0107456:	55                   	push   %ebp
f0107457:	89 e5                	mov    %esp,%ebp
f0107459:	57                   	push   %edi
f010745a:	56                   	push   %esi
f010745b:	53                   	push   %ebx
f010745c:	83 ec 4c             	sub    $0x4c,%esp
f010745f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107462:	8b 75 10             	mov    0x10(%ebp),%esi
f0107465:	eb 12                	jmp    f0107479 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0107467:	85 c0                	test   %eax,%eax
f0107469:	0f 84 6b 03 00 00    	je     f01077da <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f010746f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107473:	89 04 24             	mov    %eax,(%esp)
f0107476:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0107479:	0f b6 06             	movzbl (%esi),%eax
f010747c:	46                   	inc    %esi
f010747d:	83 f8 25             	cmp    $0x25,%eax
f0107480:	75 e5                	jne    f0107467 <vprintfmt+0x11>
f0107482:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0107486:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010748d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0107492:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0107499:	b9 00 00 00 00       	mov    $0x0,%ecx
f010749e:	eb 26                	jmp    f01074c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01074a0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01074a3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01074a7:	eb 1d                	jmp    f01074c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01074a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01074ac:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01074b0:	eb 14                	jmp    f01074c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01074b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01074b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01074bc:	eb 08                	jmp    f01074c6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01074be:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01074c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01074c6:	0f b6 06             	movzbl (%esi),%eax
f01074c9:	8d 56 01             	lea    0x1(%esi),%edx
f01074cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01074cf:	8a 16                	mov    (%esi),%dl
f01074d1:	83 ea 23             	sub    $0x23,%edx
f01074d4:	80 fa 55             	cmp    $0x55,%dl
f01074d7:	0f 87 e1 02 00 00    	ja     f01077be <vprintfmt+0x368>
f01074dd:	0f b6 d2             	movzbl %dl,%edx
f01074e0:	ff 24 95 e0 af 10 f0 	jmp    *-0xfef5020(,%edx,4)
f01074e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01074ea:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01074ef:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f01074f2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01074f6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01074f9:	8d 50 d0             	lea    -0x30(%eax),%edx
f01074fc:	83 fa 09             	cmp    $0x9,%edx
f01074ff:	77 2a                	ja     f010752b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0107501:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0107502:	eb eb                	jmp    f01074ef <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0107504:	8b 45 14             	mov    0x14(%ebp),%eax
f0107507:	8d 50 04             	lea    0x4(%eax),%edx
f010750a:	89 55 14             	mov    %edx,0x14(%ebp)
f010750d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010750f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0107512:	eb 17                	jmp    f010752b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0107514:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107518:	78 98                	js     f01074b2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010751a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010751d:	eb a7                	jmp    f01074c6 <vprintfmt+0x70>
f010751f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0107522:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0107529:	eb 9b                	jmp    f01074c6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f010752b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010752f:	79 95                	jns    f01074c6 <vprintfmt+0x70>
f0107531:	eb 8b                	jmp    f01074be <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0107533:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107534:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0107537:	eb 8d                	jmp    f01074c6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0107539:	8b 45 14             	mov    0x14(%ebp),%eax
f010753c:	8d 50 04             	lea    0x4(%eax),%edx
f010753f:	89 55 14             	mov    %edx,0x14(%ebp)
f0107542:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107546:	8b 00                	mov    (%eax),%eax
f0107548:	89 04 24             	mov    %eax,(%esp)
f010754b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010754e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0107551:	e9 23 ff ff ff       	jmp    f0107479 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0107556:	8b 45 14             	mov    0x14(%ebp),%eax
f0107559:	8d 50 04             	lea    0x4(%eax),%edx
f010755c:	89 55 14             	mov    %edx,0x14(%ebp)
f010755f:	8b 00                	mov    (%eax),%eax
f0107561:	85 c0                	test   %eax,%eax
f0107563:	79 02                	jns    f0107567 <vprintfmt+0x111>
f0107565:	f7 d8                	neg    %eax
f0107567:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0107569:	83 f8 0f             	cmp    $0xf,%eax
f010756c:	7f 0b                	jg     f0107579 <vprintfmt+0x123>
f010756e:	8b 04 85 40 b1 10 f0 	mov    -0xfef4ec0(,%eax,4),%eax
f0107575:	85 c0                	test   %eax,%eax
f0107577:	75 23                	jne    f010759c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0107579:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010757d:	c7 44 24 08 c6 ae 10 	movl   $0xf010aec6,0x8(%esp)
f0107584:	f0 
f0107585:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107589:	8b 45 08             	mov    0x8(%ebp),%eax
f010758c:	89 04 24             	mov    %eax,(%esp)
f010758f:	e8 9a fe ff ff       	call   f010742e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107594:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0107597:	e9 dd fe ff ff       	jmp    f0107479 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010759c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01075a0:	c7 44 24 08 1b a6 10 	movl   $0xf010a61b,0x8(%esp)
f01075a7:	f0 
f01075a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01075ac:	8b 55 08             	mov    0x8(%ebp),%edx
f01075af:	89 14 24             	mov    %edx,(%esp)
f01075b2:	e8 77 fe ff ff       	call   f010742e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01075b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01075ba:	e9 ba fe ff ff       	jmp    f0107479 <vprintfmt+0x23>
f01075bf:	89 f9                	mov    %edi,%ecx
f01075c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01075c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01075c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01075ca:	8d 50 04             	lea    0x4(%eax),%edx
f01075cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01075d0:	8b 30                	mov    (%eax),%esi
f01075d2:	85 f6                	test   %esi,%esi
f01075d4:	75 05                	jne    f01075db <vprintfmt+0x185>
				p = "(null)";
f01075d6:	be bf ae 10 f0       	mov    $0xf010aebf,%esi
			if (width > 0 && padc != '-')
f01075db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01075df:	0f 8e 84 00 00 00    	jle    f0107669 <vprintfmt+0x213>
f01075e5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01075e9:	74 7e                	je     f0107669 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f01075eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01075ef:	89 34 24             	mov    %esi,(%esp)
f01075f2:	e8 63 03 00 00       	call   f010795a <strnlen>
f01075f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01075fa:	29 c2                	sub    %eax,%edx
f01075fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f01075ff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0107603:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0107606:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0107609:	89 de                	mov    %ebx,%esi
f010760b:	89 d3                	mov    %edx,%ebx
f010760d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010760f:	eb 0b                	jmp    f010761c <vprintfmt+0x1c6>
					putch(padc, putdat);
f0107611:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107615:	89 3c 24             	mov    %edi,(%esp)
f0107618:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010761b:	4b                   	dec    %ebx
f010761c:	85 db                	test   %ebx,%ebx
f010761e:	7f f1                	jg     f0107611 <vprintfmt+0x1bb>
f0107620:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0107623:	89 f3                	mov    %esi,%ebx
f0107625:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0107628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010762b:	85 c0                	test   %eax,%eax
f010762d:	79 05                	jns    f0107634 <vprintfmt+0x1de>
f010762f:	b8 00 00 00 00       	mov    $0x0,%eax
f0107634:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107637:	29 c2                	sub    %eax,%edx
f0107639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010763c:	eb 2b                	jmp    f0107669 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010763e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0107642:	74 18                	je     f010765c <vprintfmt+0x206>
f0107644:	8d 50 e0             	lea    -0x20(%eax),%edx
f0107647:	83 fa 5e             	cmp    $0x5e,%edx
f010764a:	76 10                	jbe    f010765c <vprintfmt+0x206>
					putch('?', putdat);
f010764c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107650:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0107657:	ff 55 08             	call   *0x8(%ebp)
f010765a:	eb 0a                	jmp    f0107666 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f010765c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107660:	89 04 24             	mov    %eax,(%esp)
f0107663:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0107666:	ff 4d e4             	decl   -0x1c(%ebp)
f0107669:	0f be 06             	movsbl (%esi),%eax
f010766c:	46                   	inc    %esi
f010766d:	85 c0                	test   %eax,%eax
f010766f:	74 21                	je     f0107692 <vprintfmt+0x23c>
f0107671:	85 ff                	test   %edi,%edi
f0107673:	78 c9                	js     f010763e <vprintfmt+0x1e8>
f0107675:	4f                   	dec    %edi
f0107676:	79 c6                	jns    f010763e <vprintfmt+0x1e8>
f0107678:	8b 7d 08             	mov    0x8(%ebp),%edi
f010767b:	89 de                	mov    %ebx,%esi
f010767d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0107680:	eb 18                	jmp    f010769a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0107682:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107686:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010768d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010768f:	4b                   	dec    %ebx
f0107690:	eb 08                	jmp    f010769a <vprintfmt+0x244>
f0107692:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107695:	89 de                	mov    %ebx,%esi
f0107697:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010769a:	85 db                	test   %ebx,%ebx
f010769c:	7f e4                	jg     f0107682 <vprintfmt+0x22c>
f010769e:	89 7d 08             	mov    %edi,0x8(%ebp)
f01076a1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01076a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01076a6:	e9 ce fd ff ff       	jmp    f0107479 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01076ab:	83 f9 01             	cmp    $0x1,%ecx
f01076ae:	7e 10                	jle    f01076c0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f01076b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01076b3:	8d 50 08             	lea    0x8(%eax),%edx
f01076b6:	89 55 14             	mov    %edx,0x14(%ebp)
f01076b9:	8b 30                	mov    (%eax),%esi
f01076bb:	8b 78 04             	mov    0x4(%eax),%edi
f01076be:	eb 26                	jmp    f01076e6 <vprintfmt+0x290>
	else if (lflag)
f01076c0:	85 c9                	test   %ecx,%ecx
f01076c2:	74 12                	je     f01076d6 <vprintfmt+0x280>
		return va_arg(*ap, long);
f01076c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01076c7:	8d 50 04             	lea    0x4(%eax),%edx
f01076ca:	89 55 14             	mov    %edx,0x14(%ebp)
f01076cd:	8b 30                	mov    (%eax),%esi
f01076cf:	89 f7                	mov    %esi,%edi
f01076d1:	c1 ff 1f             	sar    $0x1f,%edi
f01076d4:	eb 10                	jmp    f01076e6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f01076d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01076d9:	8d 50 04             	lea    0x4(%eax),%edx
f01076dc:	89 55 14             	mov    %edx,0x14(%ebp)
f01076df:	8b 30                	mov    (%eax),%esi
f01076e1:	89 f7                	mov    %esi,%edi
f01076e3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01076e6:	85 ff                	test   %edi,%edi
f01076e8:	78 0a                	js     f01076f4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01076ea:	b8 0a 00 00 00       	mov    $0xa,%eax
f01076ef:	e9 8c 00 00 00       	jmp    f0107780 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01076f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01076f8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01076ff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0107702:	f7 de                	neg    %esi
f0107704:	83 d7 00             	adc    $0x0,%edi
f0107707:	f7 df                	neg    %edi
			}
			base = 10;
f0107709:	b8 0a 00 00 00       	mov    $0xa,%eax
f010770e:	eb 70                	jmp    f0107780 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0107710:	89 ca                	mov    %ecx,%edx
f0107712:	8d 45 14             	lea    0x14(%ebp),%eax
f0107715:	e8 c0 fc ff ff       	call   f01073da <getuint>
f010771a:	89 c6                	mov    %eax,%esi
f010771c:	89 d7                	mov    %edx,%edi
			base = 10;
f010771e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0107723:	eb 5b                	jmp    f0107780 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0107725:	89 ca                	mov    %ecx,%edx
f0107727:	8d 45 14             	lea    0x14(%ebp),%eax
f010772a:	e8 ab fc ff ff       	call   f01073da <getuint>
f010772f:	89 c6                	mov    %eax,%esi
f0107731:	89 d7                	mov    %edx,%edi
			base = 8;
f0107733:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0107738:	eb 46                	jmp    f0107780 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010773a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010773e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0107745:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0107748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010774c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0107753:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0107756:	8b 45 14             	mov    0x14(%ebp),%eax
f0107759:	8d 50 04             	lea    0x4(%eax),%edx
f010775c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010775f:	8b 30                	mov    (%eax),%esi
f0107761:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0107766:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010776b:	eb 13                	jmp    f0107780 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010776d:	89 ca                	mov    %ecx,%edx
f010776f:	8d 45 14             	lea    0x14(%ebp),%eax
f0107772:	e8 63 fc ff ff       	call   f01073da <getuint>
f0107777:	89 c6                	mov    %eax,%esi
f0107779:	89 d7                	mov    %edx,%edi
			base = 16;
f010777b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0107780:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0107784:	89 54 24 10          	mov    %edx,0x10(%esp)
f0107788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010778b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010778f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107793:	89 34 24             	mov    %esi,(%esp)
f0107796:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010779a:	89 da                	mov    %ebx,%edx
f010779c:	8b 45 08             	mov    0x8(%ebp),%eax
f010779f:	e8 6c fb ff ff       	call   f0107310 <printnum>
			break;
f01077a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01077a7:	e9 cd fc ff ff       	jmp    f0107479 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01077ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01077b0:	89 04 24             	mov    %eax,(%esp)
f01077b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01077b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01077b9:	e9 bb fc ff ff       	jmp    f0107479 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01077be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01077c2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01077c9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01077cc:	eb 01                	jmp    f01077cf <vprintfmt+0x379>
f01077ce:	4e                   	dec    %esi
f01077cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01077d3:	75 f9                	jne    f01077ce <vprintfmt+0x378>
f01077d5:	e9 9f fc ff ff       	jmp    f0107479 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01077da:	83 c4 4c             	add    $0x4c,%esp
f01077dd:	5b                   	pop    %ebx
f01077de:	5e                   	pop    %esi
f01077df:	5f                   	pop    %edi
f01077e0:	5d                   	pop    %ebp
f01077e1:	c3                   	ret    

f01077e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01077e2:	55                   	push   %ebp
f01077e3:	89 e5                	mov    %esp,%ebp
f01077e5:	83 ec 28             	sub    $0x28,%esp
f01077e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01077eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01077ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01077f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01077f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01077f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01077ff:	85 c0                	test   %eax,%eax
f0107801:	74 30                	je     f0107833 <vsnprintf+0x51>
f0107803:	85 d2                	test   %edx,%edx
f0107805:	7e 33                	jle    f010783a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0107807:	8b 45 14             	mov    0x14(%ebp),%eax
f010780a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010780e:	8b 45 10             	mov    0x10(%ebp),%eax
f0107811:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107815:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0107818:	89 44 24 04          	mov    %eax,0x4(%esp)
f010781c:	c7 04 24 14 74 10 f0 	movl   $0xf0107414,(%esp)
f0107823:	e8 2e fc ff ff       	call   f0107456 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0107828:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010782b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010782e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107831:	eb 0c                	jmp    f010783f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0107833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107838:	eb 05                	jmp    f010783f <vsnprintf+0x5d>
f010783a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010783f:	c9                   	leave  
f0107840:	c3                   	ret    

f0107841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0107841:	55                   	push   %ebp
f0107842:	89 e5                	mov    %esp,%ebp
f0107844:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0107847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010784a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010784e:	8b 45 10             	mov    0x10(%ebp),%eax
f0107851:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107855:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107858:	89 44 24 04          	mov    %eax,0x4(%esp)
f010785c:	8b 45 08             	mov    0x8(%ebp),%eax
f010785f:	89 04 24             	mov    %eax,(%esp)
f0107862:	e8 7b ff ff ff       	call   f01077e2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0107867:	c9                   	leave  
f0107868:	c3                   	ret    
f0107869:	00 00                	add    %al,(%eax)
	...

f010786c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010786c:	55                   	push   %ebp
f010786d:	89 e5                	mov    %esp,%ebp
f010786f:	57                   	push   %edi
f0107870:	56                   	push   %esi
f0107871:	53                   	push   %ebx
f0107872:	83 ec 1c             	sub    $0x1c,%esp
f0107875:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0107878:	85 c0                	test   %eax,%eax
f010787a:	74 10                	je     f010788c <readline+0x20>
		cprintf("%s", prompt);
f010787c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107880:	c7 04 24 1b a6 10 f0 	movl   $0xf010a61b,(%esp)
f0107887:	e8 02 df ff ff       	call   f010578e <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010788c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0107893:	e8 fe 91 ff ff       	call   f0100a96 <iscons>
f0107898:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010789a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010789f:	e8 e1 91 ff ff       	call   f0100a85 <getchar>
f01078a4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01078a6:	85 c0                	test   %eax,%eax
f01078a8:	79 20                	jns    f01078ca <readline+0x5e>
			if (c != -E_EOF)
f01078aa:	83 f8 f8             	cmp    $0xfffffff8,%eax
f01078ad:	0f 84 82 00 00 00    	je     f0107935 <readline+0xc9>
				cprintf("read error: %e\n", c);
f01078b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01078b7:	c7 04 24 9f b1 10 f0 	movl   $0xf010b19f,(%esp)
f01078be:	e8 cb de ff ff       	call   f010578e <cprintf>
			return NULL;
f01078c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01078c8:	eb 70                	jmp    f010793a <readline+0xce>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01078ca:	83 f8 08             	cmp    $0x8,%eax
f01078cd:	74 05                	je     f01078d4 <readline+0x68>
f01078cf:	83 f8 7f             	cmp    $0x7f,%eax
f01078d2:	75 17                	jne    f01078eb <readline+0x7f>
f01078d4:	85 f6                	test   %esi,%esi
f01078d6:	7e 13                	jle    f01078eb <readline+0x7f>
			if (echoing)
f01078d8:	85 ff                	test   %edi,%edi
f01078da:	74 0c                	je     f01078e8 <readline+0x7c>
				cputchar('\b');
f01078dc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01078e3:	e8 8d 91 ff ff       	call   f0100a75 <cputchar>
			i--;
f01078e8:	4e                   	dec    %esi
f01078e9:	eb b4                	jmp    f010789f <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01078eb:	83 fb 1f             	cmp    $0x1f,%ebx
f01078ee:	7e 1d                	jle    f010790d <readline+0xa1>
f01078f0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01078f6:	7f 15                	jg     f010790d <readline+0xa1>
			if (echoing)
f01078f8:	85 ff                	test   %edi,%edi
f01078fa:	74 08                	je     f0107904 <readline+0x98>
				cputchar(c);
f01078fc:	89 1c 24             	mov    %ebx,(%esp)
f01078ff:	e8 71 91 ff ff       	call   f0100a75 <cputchar>
			buf[i++] = c;
f0107904:	88 9e 80 ba 24 f0    	mov    %bl,-0xfdb4580(%esi)
f010790a:	46                   	inc    %esi
f010790b:	eb 92                	jmp    f010789f <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010790d:	83 fb 0a             	cmp    $0xa,%ebx
f0107910:	74 05                	je     f0107917 <readline+0xab>
f0107912:	83 fb 0d             	cmp    $0xd,%ebx
f0107915:	75 88                	jne    f010789f <readline+0x33>
			if (echoing)
f0107917:	85 ff                	test   %edi,%edi
f0107919:	74 0c                	je     f0107927 <readline+0xbb>
				cputchar('\n');
f010791b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0107922:	e8 4e 91 ff ff       	call   f0100a75 <cputchar>
			buf[i] = 0;
f0107927:	c6 86 80 ba 24 f0 00 	movb   $0x0,-0xfdb4580(%esi)
			return buf;
f010792e:	b8 80 ba 24 f0       	mov    $0xf024ba80,%eax
f0107933:	eb 05                	jmp    f010793a <readline+0xce>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0107935:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010793a:	83 c4 1c             	add    $0x1c,%esp
f010793d:	5b                   	pop    %ebx
f010793e:	5e                   	pop    %esi
f010793f:	5f                   	pop    %edi
f0107940:	5d                   	pop    %ebp
f0107941:	c3                   	ret    
	...

f0107944 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0107944:	55                   	push   %ebp
f0107945:	89 e5                	mov    %esp,%ebp
f0107947:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010794a:	b8 00 00 00 00       	mov    $0x0,%eax
f010794f:	eb 01                	jmp    f0107952 <strlen+0xe>
		n++;
f0107951:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0107952:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0107956:	75 f9                	jne    f0107951 <strlen+0xd>
		n++;
	return n;
}
f0107958:	5d                   	pop    %ebp
f0107959:	c3                   	ret    

f010795a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010795a:	55                   	push   %ebp
f010795b:	89 e5                	mov    %esp,%ebp
f010795d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0107960:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107963:	b8 00 00 00 00       	mov    $0x0,%eax
f0107968:	eb 01                	jmp    f010796b <strnlen+0x11>
		n++;
f010796a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010796b:	39 d0                	cmp    %edx,%eax
f010796d:	74 06                	je     f0107975 <strnlen+0x1b>
f010796f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0107973:	75 f5                	jne    f010796a <strnlen+0x10>
		n++;
	return n;
}
f0107975:	5d                   	pop    %ebp
f0107976:	c3                   	ret    

f0107977 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0107977:	55                   	push   %ebp
f0107978:	89 e5                	mov    %esp,%ebp
f010797a:	53                   	push   %ebx
f010797b:	8b 45 08             	mov    0x8(%ebp),%eax
f010797e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0107981:	ba 00 00 00 00       	mov    $0x0,%edx
f0107986:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0107989:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010798c:	42                   	inc    %edx
f010798d:	84 c9                	test   %cl,%cl
f010798f:	75 f5                	jne    f0107986 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0107991:	5b                   	pop    %ebx
f0107992:	5d                   	pop    %ebp
f0107993:	c3                   	ret    

f0107994 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0107994:	55                   	push   %ebp
f0107995:	89 e5                	mov    %esp,%ebp
f0107997:	53                   	push   %ebx
f0107998:	83 ec 08             	sub    $0x8,%esp
f010799b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010799e:	89 1c 24             	mov    %ebx,(%esp)
f01079a1:	e8 9e ff ff ff       	call   f0107944 <strlen>
	strcpy(dst + len, src);
f01079a6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01079a9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01079ad:	01 d8                	add    %ebx,%eax
f01079af:	89 04 24             	mov    %eax,(%esp)
f01079b2:	e8 c0 ff ff ff       	call   f0107977 <strcpy>
	return dst;
}
f01079b7:	89 d8                	mov    %ebx,%eax
f01079b9:	83 c4 08             	add    $0x8,%esp
f01079bc:	5b                   	pop    %ebx
f01079bd:	5d                   	pop    %ebp
f01079be:	c3                   	ret    

f01079bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01079bf:	55                   	push   %ebp
f01079c0:	89 e5                	mov    %esp,%ebp
f01079c2:	56                   	push   %esi
f01079c3:	53                   	push   %ebx
f01079c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01079c7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01079ca:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01079cd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01079d2:	eb 0c                	jmp    f01079e0 <strncpy+0x21>
		*dst++ = *src;
f01079d4:	8a 1a                	mov    (%edx),%bl
f01079d6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01079d9:	80 3a 01             	cmpb   $0x1,(%edx)
f01079dc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01079df:	41                   	inc    %ecx
f01079e0:	39 f1                	cmp    %esi,%ecx
f01079e2:	75 f0                	jne    f01079d4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01079e4:	5b                   	pop    %ebx
f01079e5:	5e                   	pop    %esi
f01079e6:	5d                   	pop    %ebp
f01079e7:	c3                   	ret    

f01079e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01079e8:	55                   	push   %ebp
f01079e9:	89 e5                	mov    %esp,%ebp
f01079eb:	56                   	push   %esi
f01079ec:	53                   	push   %ebx
f01079ed:	8b 75 08             	mov    0x8(%ebp),%esi
f01079f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01079f3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01079f6:	85 d2                	test   %edx,%edx
f01079f8:	75 0a                	jne    f0107a04 <strlcpy+0x1c>
f01079fa:	89 f0                	mov    %esi,%eax
f01079fc:	eb 1a                	jmp    f0107a18 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01079fe:	88 18                	mov    %bl,(%eax)
f0107a00:	40                   	inc    %eax
f0107a01:	41                   	inc    %ecx
f0107a02:	eb 02                	jmp    f0107a06 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0107a04:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0107a06:	4a                   	dec    %edx
f0107a07:	74 0a                	je     f0107a13 <strlcpy+0x2b>
f0107a09:	8a 19                	mov    (%ecx),%bl
f0107a0b:	84 db                	test   %bl,%bl
f0107a0d:	75 ef                	jne    f01079fe <strlcpy+0x16>
f0107a0f:	89 c2                	mov    %eax,%edx
f0107a11:	eb 02                	jmp    f0107a15 <strlcpy+0x2d>
f0107a13:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0107a15:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0107a18:	29 f0                	sub    %esi,%eax
}
f0107a1a:	5b                   	pop    %ebx
f0107a1b:	5e                   	pop    %esi
f0107a1c:	5d                   	pop    %ebp
f0107a1d:	c3                   	ret    

f0107a1e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0107a1e:	55                   	push   %ebp
f0107a1f:	89 e5                	mov    %esp,%ebp
f0107a21:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107a24:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0107a27:	eb 02                	jmp    f0107a2b <strcmp+0xd>
		p++, q++;
f0107a29:	41                   	inc    %ecx
f0107a2a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0107a2b:	8a 01                	mov    (%ecx),%al
f0107a2d:	84 c0                	test   %al,%al
f0107a2f:	74 04                	je     f0107a35 <strcmp+0x17>
f0107a31:	3a 02                	cmp    (%edx),%al
f0107a33:	74 f4                	je     f0107a29 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0107a35:	0f b6 c0             	movzbl %al,%eax
f0107a38:	0f b6 12             	movzbl (%edx),%edx
f0107a3b:	29 d0                	sub    %edx,%eax
}
f0107a3d:	5d                   	pop    %ebp
f0107a3e:	c3                   	ret    

f0107a3f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0107a3f:	55                   	push   %ebp
f0107a40:	89 e5                	mov    %esp,%ebp
f0107a42:	53                   	push   %ebx
f0107a43:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0107a49:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0107a4c:	eb 03                	jmp    f0107a51 <strncmp+0x12>
		n--, p++, q++;
f0107a4e:	4a                   	dec    %edx
f0107a4f:	40                   	inc    %eax
f0107a50:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0107a51:	85 d2                	test   %edx,%edx
f0107a53:	74 14                	je     f0107a69 <strncmp+0x2a>
f0107a55:	8a 18                	mov    (%eax),%bl
f0107a57:	84 db                	test   %bl,%bl
f0107a59:	74 04                	je     f0107a5f <strncmp+0x20>
f0107a5b:	3a 19                	cmp    (%ecx),%bl
f0107a5d:	74 ef                	je     f0107a4e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0107a5f:	0f b6 00             	movzbl (%eax),%eax
f0107a62:	0f b6 11             	movzbl (%ecx),%edx
f0107a65:	29 d0                	sub    %edx,%eax
f0107a67:	eb 05                	jmp    f0107a6e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0107a69:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0107a6e:	5b                   	pop    %ebx
f0107a6f:	5d                   	pop    %ebp
f0107a70:	c3                   	ret    

f0107a71 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0107a71:	55                   	push   %ebp
f0107a72:	89 e5                	mov    %esp,%ebp
f0107a74:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a77:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0107a7a:	eb 05                	jmp    f0107a81 <strchr+0x10>
		if (*s == c)
f0107a7c:	38 ca                	cmp    %cl,%dl
f0107a7e:	74 0c                	je     f0107a8c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0107a80:	40                   	inc    %eax
f0107a81:	8a 10                	mov    (%eax),%dl
f0107a83:	84 d2                	test   %dl,%dl
f0107a85:	75 f5                	jne    f0107a7c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0107a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107a8c:	5d                   	pop    %ebp
f0107a8d:	c3                   	ret    

f0107a8e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0107a8e:	55                   	push   %ebp
f0107a8f:	89 e5                	mov    %esp,%ebp
f0107a91:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a94:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0107a97:	eb 05                	jmp    f0107a9e <strfind+0x10>
		if (*s == c)
f0107a99:	38 ca                	cmp    %cl,%dl
f0107a9b:	74 07                	je     f0107aa4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0107a9d:	40                   	inc    %eax
f0107a9e:	8a 10                	mov    (%eax),%dl
f0107aa0:	84 d2                	test   %dl,%dl
f0107aa2:	75 f5                	jne    f0107a99 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0107aa4:	5d                   	pop    %ebp
f0107aa5:	c3                   	ret    

f0107aa6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0107aa6:	55                   	push   %ebp
f0107aa7:	89 e5                	mov    %esp,%ebp
f0107aa9:	57                   	push   %edi
f0107aaa:	56                   	push   %esi
f0107aab:	53                   	push   %ebx
f0107aac:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ab2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0107ab5:	85 c9                	test   %ecx,%ecx
f0107ab7:	74 30                	je     f0107ae9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0107ab9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0107abf:	75 25                	jne    f0107ae6 <memset+0x40>
f0107ac1:	f6 c1 03             	test   $0x3,%cl
f0107ac4:	75 20                	jne    f0107ae6 <memset+0x40>
		c &= 0xFF;
f0107ac6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0107ac9:	89 d3                	mov    %edx,%ebx
f0107acb:	c1 e3 08             	shl    $0x8,%ebx
f0107ace:	89 d6                	mov    %edx,%esi
f0107ad0:	c1 e6 18             	shl    $0x18,%esi
f0107ad3:	89 d0                	mov    %edx,%eax
f0107ad5:	c1 e0 10             	shl    $0x10,%eax
f0107ad8:	09 f0                	or     %esi,%eax
f0107ada:	09 d0                	or     %edx,%eax
f0107adc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0107ade:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0107ae1:	fc                   	cld    
f0107ae2:	f3 ab                	rep stos %eax,%es:(%edi)
f0107ae4:	eb 03                	jmp    f0107ae9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0107ae6:	fc                   	cld    
f0107ae7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0107ae9:	89 f8                	mov    %edi,%eax
f0107aeb:	5b                   	pop    %ebx
f0107aec:	5e                   	pop    %esi
f0107aed:	5f                   	pop    %edi
f0107aee:	5d                   	pop    %ebp
f0107aef:	c3                   	ret    

f0107af0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0107af0:	55                   	push   %ebp
f0107af1:	89 e5                	mov    %esp,%ebp
f0107af3:	57                   	push   %edi
f0107af4:	56                   	push   %esi
f0107af5:	8b 45 08             	mov    0x8(%ebp),%eax
f0107af8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107afb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0107afe:	39 c6                	cmp    %eax,%esi
f0107b00:	73 34                	jae    f0107b36 <memmove+0x46>
f0107b02:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0107b05:	39 d0                	cmp    %edx,%eax
f0107b07:	73 2d                	jae    f0107b36 <memmove+0x46>
		s += n;
		d += n;
f0107b09:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107b0c:	f6 c2 03             	test   $0x3,%dl
f0107b0f:	75 1b                	jne    f0107b2c <memmove+0x3c>
f0107b11:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0107b17:	75 13                	jne    f0107b2c <memmove+0x3c>
f0107b19:	f6 c1 03             	test   $0x3,%cl
f0107b1c:	75 0e                	jne    f0107b2c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0107b1e:	83 ef 04             	sub    $0x4,%edi
f0107b21:	8d 72 fc             	lea    -0x4(%edx),%esi
f0107b24:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0107b27:	fd                   	std    
f0107b28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107b2a:	eb 07                	jmp    f0107b33 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0107b2c:	4f                   	dec    %edi
f0107b2d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0107b30:	fd                   	std    
f0107b31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0107b33:	fc                   	cld    
f0107b34:	eb 20                	jmp    f0107b56 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107b36:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0107b3c:	75 13                	jne    f0107b51 <memmove+0x61>
f0107b3e:	a8 03                	test   $0x3,%al
f0107b40:	75 0f                	jne    f0107b51 <memmove+0x61>
f0107b42:	f6 c1 03             	test   $0x3,%cl
f0107b45:	75 0a                	jne    f0107b51 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0107b47:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0107b4a:	89 c7                	mov    %eax,%edi
f0107b4c:	fc                   	cld    
f0107b4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107b4f:	eb 05                	jmp    f0107b56 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0107b51:	89 c7                	mov    %eax,%edi
f0107b53:	fc                   	cld    
f0107b54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0107b56:	5e                   	pop    %esi
f0107b57:	5f                   	pop    %edi
f0107b58:	5d                   	pop    %ebp
f0107b59:	c3                   	ret    

f0107b5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0107b5a:	55                   	push   %ebp
f0107b5b:	89 e5                	mov    %esp,%ebp
f0107b5d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0107b60:	8b 45 10             	mov    0x10(%ebp),%eax
f0107b63:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107b67:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b71:	89 04 24             	mov    %eax,(%esp)
f0107b74:	e8 77 ff ff ff       	call   f0107af0 <memmove>
}
f0107b79:	c9                   	leave  
f0107b7a:	c3                   	ret    

f0107b7b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0107b7b:	55                   	push   %ebp
f0107b7c:	89 e5                	mov    %esp,%ebp
f0107b7e:	57                   	push   %edi
f0107b7f:	56                   	push   %esi
f0107b80:	53                   	push   %ebx
f0107b81:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107b84:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107b8a:	ba 00 00 00 00       	mov    $0x0,%edx
f0107b8f:	eb 16                	jmp    f0107ba7 <memcmp+0x2c>
		if (*s1 != *s2)
f0107b91:	8a 04 17             	mov    (%edi,%edx,1),%al
f0107b94:	42                   	inc    %edx
f0107b95:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0107b99:	38 c8                	cmp    %cl,%al
f0107b9b:	74 0a                	je     f0107ba7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0107b9d:	0f b6 c0             	movzbl %al,%eax
f0107ba0:	0f b6 c9             	movzbl %cl,%ecx
f0107ba3:	29 c8                	sub    %ecx,%eax
f0107ba5:	eb 09                	jmp    f0107bb0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107ba7:	39 da                	cmp    %ebx,%edx
f0107ba9:	75 e6                	jne    f0107b91 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0107bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107bb0:	5b                   	pop    %ebx
f0107bb1:	5e                   	pop    %esi
f0107bb2:	5f                   	pop    %edi
f0107bb3:	5d                   	pop    %ebp
f0107bb4:	c3                   	ret    

f0107bb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0107bb5:	55                   	push   %ebp
f0107bb6:	89 e5                	mov    %esp,%ebp
f0107bb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0107bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0107bbe:	89 c2                	mov    %eax,%edx
f0107bc0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0107bc3:	eb 05                	jmp    f0107bca <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0107bc5:	38 08                	cmp    %cl,(%eax)
f0107bc7:	74 05                	je     f0107bce <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0107bc9:	40                   	inc    %eax
f0107bca:	39 d0                	cmp    %edx,%eax
f0107bcc:	72 f7                	jb     f0107bc5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0107bce:	5d                   	pop    %ebp
f0107bcf:	c3                   	ret    

f0107bd0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0107bd0:	55                   	push   %ebp
f0107bd1:	89 e5                	mov    %esp,%ebp
f0107bd3:	57                   	push   %edi
f0107bd4:	56                   	push   %esi
f0107bd5:	53                   	push   %ebx
f0107bd6:	8b 55 08             	mov    0x8(%ebp),%edx
f0107bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107bdc:	eb 01                	jmp    f0107bdf <strtol+0xf>
		s++;
f0107bde:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107bdf:	8a 02                	mov    (%edx),%al
f0107be1:	3c 20                	cmp    $0x20,%al
f0107be3:	74 f9                	je     f0107bde <strtol+0xe>
f0107be5:	3c 09                	cmp    $0x9,%al
f0107be7:	74 f5                	je     f0107bde <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0107be9:	3c 2b                	cmp    $0x2b,%al
f0107beb:	75 08                	jne    f0107bf5 <strtol+0x25>
		s++;
f0107bed:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0107bee:	bf 00 00 00 00       	mov    $0x0,%edi
f0107bf3:	eb 13                	jmp    f0107c08 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0107bf5:	3c 2d                	cmp    $0x2d,%al
f0107bf7:	75 0a                	jne    f0107c03 <strtol+0x33>
		s++, neg = 1;
f0107bf9:	8d 52 01             	lea    0x1(%edx),%edx
f0107bfc:	bf 01 00 00 00       	mov    $0x1,%edi
f0107c01:	eb 05                	jmp    f0107c08 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0107c03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0107c08:	85 db                	test   %ebx,%ebx
f0107c0a:	74 05                	je     f0107c11 <strtol+0x41>
f0107c0c:	83 fb 10             	cmp    $0x10,%ebx
f0107c0f:	75 28                	jne    f0107c39 <strtol+0x69>
f0107c11:	8a 02                	mov    (%edx),%al
f0107c13:	3c 30                	cmp    $0x30,%al
f0107c15:	75 10                	jne    f0107c27 <strtol+0x57>
f0107c17:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0107c1b:	75 0a                	jne    f0107c27 <strtol+0x57>
		s += 2, base = 16;
f0107c1d:	83 c2 02             	add    $0x2,%edx
f0107c20:	bb 10 00 00 00       	mov    $0x10,%ebx
f0107c25:	eb 12                	jmp    f0107c39 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0107c27:	85 db                	test   %ebx,%ebx
f0107c29:	75 0e                	jne    f0107c39 <strtol+0x69>
f0107c2b:	3c 30                	cmp    $0x30,%al
f0107c2d:	75 05                	jne    f0107c34 <strtol+0x64>
		s++, base = 8;
f0107c2f:	42                   	inc    %edx
f0107c30:	b3 08                	mov    $0x8,%bl
f0107c32:	eb 05                	jmp    f0107c39 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0107c34:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0107c39:	b8 00 00 00 00       	mov    $0x0,%eax
f0107c3e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0107c40:	8a 0a                	mov    (%edx),%cl
f0107c42:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0107c45:	80 fb 09             	cmp    $0x9,%bl
f0107c48:	77 08                	ja     f0107c52 <strtol+0x82>
			dig = *s - '0';
f0107c4a:	0f be c9             	movsbl %cl,%ecx
f0107c4d:	83 e9 30             	sub    $0x30,%ecx
f0107c50:	eb 1e                	jmp    f0107c70 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0107c52:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0107c55:	80 fb 19             	cmp    $0x19,%bl
f0107c58:	77 08                	ja     f0107c62 <strtol+0x92>
			dig = *s - 'a' + 10;
f0107c5a:	0f be c9             	movsbl %cl,%ecx
f0107c5d:	83 e9 57             	sub    $0x57,%ecx
f0107c60:	eb 0e                	jmp    f0107c70 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0107c62:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0107c65:	80 fb 19             	cmp    $0x19,%bl
f0107c68:	77 12                	ja     f0107c7c <strtol+0xac>
			dig = *s - 'A' + 10;
f0107c6a:	0f be c9             	movsbl %cl,%ecx
f0107c6d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0107c70:	39 f1                	cmp    %esi,%ecx
f0107c72:	7d 0c                	jge    f0107c80 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0107c74:	42                   	inc    %edx
f0107c75:	0f af c6             	imul   %esi,%eax
f0107c78:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0107c7a:	eb c4                	jmp    f0107c40 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0107c7c:	89 c1                	mov    %eax,%ecx
f0107c7e:	eb 02                	jmp    f0107c82 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0107c80:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0107c82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107c86:	74 05                	je     f0107c8d <strtol+0xbd>
		*endptr = (char *) s;
f0107c88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107c8b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0107c8d:	85 ff                	test   %edi,%edi
f0107c8f:	74 04                	je     f0107c95 <strtol+0xc5>
f0107c91:	89 c8                	mov    %ecx,%eax
f0107c93:	f7 d8                	neg    %eax
}
f0107c95:	5b                   	pop    %ebx
f0107c96:	5e                   	pop    %esi
f0107c97:	5f                   	pop    %edi
f0107c98:	5d                   	pop    %ebp
f0107c99:	c3                   	ret    
	...

f0107c9c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0107c9c:	fa                   	cli    

	xorw    %ax, %ax
f0107c9d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0107c9f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107ca1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107ca3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0107ca5:	0f 01 16             	lgdtl  (%esi)
f0107ca8:	74 70                	je     f0107d1a <sum+0x2>
	movl    %cr0, %eax
f0107caa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0107cad:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0107cb1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0107cb4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0107cba:	08 00                	or     %al,(%eax)

f0107cbc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0107cbc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0107cc0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107cc2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107cc4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0107cc6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0107cca:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0107ccc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0107cce:	b8 00 c0 12 00       	mov    $0x12c000,%eax
	movl    %eax, %cr3
f0107cd3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0107cd6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0107cd9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0107cde:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0107ce1:	8b 25 84 be 24 f0    	mov    0xf024be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0107ce7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0107cec:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0107cf1:	ff d0                	call   *%eax

f0107cf3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0107cf3:	eb fe                	jmp    f0107cf3 <spin>
f0107cf5:	8d 76 00             	lea    0x0(%esi),%esi

f0107cf8 <gdt>:
	...
f0107d00:	ff                   	(bad)  
f0107d01:	ff 00                	incl   (%eax)
f0107d03:	00 00                	add    %al,(%eax)
f0107d05:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0107d0c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0107d10 <gdtdesc>:
f0107d10:	17                   	pop    %ss
f0107d11:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0107d16 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0107d16:	90                   	nop
	...

f0107d18 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0107d18:	55                   	push   %ebp
f0107d19:	89 e5                	mov    %esp,%ebp
f0107d1b:	56                   	push   %esi
f0107d1c:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0107d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0107d22:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107d27:	eb 07                	jmp    f0107d30 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f0107d29:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0107d2d:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0107d2f:	41                   	inc    %ecx
f0107d30:	39 d1                	cmp    %edx,%ecx
f0107d32:	7c f5                	jl     f0107d29 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0107d34:	88 d8                	mov    %bl,%al
f0107d36:	5b                   	pop    %ebx
f0107d37:	5e                   	pop    %esi
f0107d38:	5d                   	pop    %ebp
f0107d39:	c3                   	ret    

f0107d3a <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0107d3a:	55                   	push   %ebp
f0107d3b:	89 e5                	mov    %esp,%ebp
f0107d3d:	56                   	push   %esi
f0107d3e:	53                   	push   %ebx
f0107d3f:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107d42:	8b 0d 88 be 24 f0    	mov    0xf024be88,%ecx
f0107d48:	89 c3                	mov    %eax,%ebx
f0107d4a:	c1 eb 0c             	shr    $0xc,%ebx
f0107d4d:	39 cb                	cmp    %ecx,%ebx
f0107d4f:	72 20                	jb     f0107d71 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107d51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107d55:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0107d5c:	f0 
f0107d5d:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107d64:	00 
f0107d65:	c7 04 24 3d b3 10 f0 	movl   $0xf010b33d,(%esp)
f0107d6c:	e8 cf 82 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0107d71:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107d74:	89 f2                	mov    %esi,%edx
f0107d76:	c1 ea 0c             	shr    $0xc,%edx
f0107d79:	39 d1                	cmp    %edx,%ecx
f0107d7b:	77 20                	ja     f0107d9d <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107d7d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107d81:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0107d88:	f0 
f0107d89:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107d90:	00 
f0107d91:	c7 04 24 3d b3 10 f0 	movl   $0xf010b33d,(%esp)
f0107d98:	e8 a3 82 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0107d9d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0107da3:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0107da9:	eb 2f                	jmp    f0107dda <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107dab:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107db2:	00 
f0107db3:	c7 44 24 04 4d b3 10 	movl   $0xf010b34d,0x4(%esp)
f0107dba:	f0 
f0107dbb:	89 1c 24             	mov    %ebx,(%esp)
f0107dbe:	e8 b8 fd ff ff       	call   f0107b7b <memcmp>
f0107dc3:	85 c0                	test   %eax,%eax
f0107dc5:	75 10                	jne    f0107dd7 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0107dc7:	ba 10 00 00 00       	mov    $0x10,%edx
f0107dcc:	89 d8                	mov    %ebx,%eax
f0107dce:	e8 45 ff ff ff       	call   f0107d18 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107dd3:	84 c0                	test   %al,%al
f0107dd5:	74 0c                	je     f0107de3 <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0107dd7:	83 c3 10             	add    $0x10,%ebx
f0107dda:	39 f3                	cmp    %esi,%ebx
f0107ddc:	72 cd                	jb     f0107dab <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0107dde:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0107de3:	89 d8                	mov    %ebx,%eax
f0107de5:	83 c4 10             	add    $0x10,%esp
f0107de8:	5b                   	pop    %ebx
f0107de9:	5e                   	pop    %esi
f0107dea:	5d                   	pop    %ebp
f0107deb:	c3                   	ret    

f0107dec <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0107dec:	55                   	push   %ebp
f0107ded:	89 e5                	mov    %esp,%ebp
f0107def:	57                   	push   %edi
f0107df0:	56                   	push   %esi
f0107df1:	53                   	push   %ebx
f0107df2:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0107df5:	c7 05 c0 c3 24 f0 20 	movl   $0xf024c020,0xf024c3c0
f0107dfc:	c0 24 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107dff:	83 3d 88 be 24 f0 00 	cmpl   $0x0,0xf024be88
f0107e06:	75 24                	jne    f0107e2c <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107e08:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0107e0f:	00 
f0107e10:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0107e17:	f0 
f0107e18:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0107e1f:	00 
f0107e20:	c7 04 24 3d b3 10 f0 	movl   $0xf010b33d,(%esp)
f0107e27:	e8 14 82 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0107e2c:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0107e33:	85 c0                	test   %eax,%eax
f0107e35:	74 16                	je     f0107e4d <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0107e37:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0107e3a:	ba 00 04 00 00       	mov    $0x400,%edx
f0107e3f:	e8 f6 fe ff ff       	call   f0107d3a <mpsearch1>
f0107e44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107e47:	85 c0                	test   %eax,%eax
f0107e49:	75 3c                	jne    f0107e87 <mp_init+0x9b>
f0107e4b:	eb 20                	jmp    f0107e6d <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0107e4d:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0107e54:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0107e57:	2d 00 04 00 00       	sub    $0x400,%eax
f0107e5c:	ba 00 04 00 00       	mov    $0x400,%edx
f0107e61:	e8 d4 fe ff ff       	call   f0107d3a <mpsearch1>
f0107e66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107e69:	85 c0                	test   %eax,%eax
f0107e6b:	75 1a                	jne    f0107e87 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0107e6d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107e72:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0107e77:	e8 be fe ff ff       	call   f0107d3a <mpsearch1>
f0107e7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0107e7f:	85 c0                	test   %eax,%eax
f0107e81:	0f 84 2c 02 00 00    	je     f01080b3 <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0107e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107e8a:	8b 58 04             	mov    0x4(%eax),%ebx
f0107e8d:	85 db                	test   %ebx,%ebx
f0107e8f:	74 06                	je     f0107e97 <mp_init+0xab>
f0107e91:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0107e95:	74 11                	je     f0107ea8 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0107e97:	c7 04 24 b0 b1 10 f0 	movl   $0xf010b1b0,(%esp)
f0107e9e:	e8 eb d8 ff ff       	call   f010578e <cprintf>
f0107ea3:	e9 0b 02 00 00       	jmp    f01080b3 <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107ea8:	89 d8                	mov    %ebx,%eax
f0107eaa:	c1 e8 0c             	shr    $0xc,%eax
f0107ead:	3b 05 88 be 24 f0    	cmp    0xf024be88,%eax
f0107eb3:	72 20                	jb     f0107ed5 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107eb5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107eb9:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f0107ec0:	f0 
f0107ec1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0107ec8:	00 
f0107ec9:	c7 04 24 3d b3 10 f0 	movl   $0xf010b33d,(%esp)
f0107ed0:	e8 6b 81 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0107ed5:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0107edb:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107ee2:	00 
f0107ee3:	c7 44 24 04 52 b3 10 	movl   $0xf010b352,0x4(%esp)
f0107eea:	f0 
f0107eeb:	89 1c 24             	mov    %ebx,(%esp)
f0107eee:	e8 88 fc ff ff       	call   f0107b7b <memcmp>
f0107ef3:	85 c0                	test   %eax,%eax
f0107ef5:	74 11                	je     f0107f08 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0107ef7:	c7 04 24 e0 b1 10 f0 	movl   $0xf010b1e0,(%esp)
f0107efe:	e8 8b d8 ff ff       	call   f010578e <cprintf>
f0107f03:	e9 ab 01 00 00       	jmp    f01080b3 <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0107f08:	66 8b 73 04          	mov    0x4(%ebx),%si
f0107f0c:	0f b7 d6             	movzwl %si,%edx
f0107f0f:	89 d8                	mov    %ebx,%eax
f0107f11:	e8 02 fe ff ff       	call   f0107d18 <sum>
f0107f16:	84 c0                	test   %al,%al
f0107f18:	74 11                	je     f0107f2b <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0107f1a:	c7 04 24 14 b2 10 f0 	movl   $0xf010b214,(%esp)
f0107f21:	e8 68 d8 ff ff       	call   f010578e <cprintf>
f0107f26:	e9 88 01 00 00       	jmp    f01080b3 <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0107f2b:	8a 43 06             	mov    0x6(%ebx),%al
f0107f2e:	3c 01                	cmp    $0x1,%al
f0107f30:	74 1c                	je     f0107f4e <mp_init+0x162>
f0107f32:	3c 04                	cmp    $0x4,%al
f0107f34:	74 18                	je     f0107f4e <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0107f36:	0f b6 c0             	movzbl %al,%eax
f0107f39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107f3d:	c7 04 24 38 b2 10 f0 	movl   $0xf010b238,(%esp)
f0107f44:	e8 45 d8 ff ff       	call   f010578e <cprintf>
f0107f49:	e9 65 01 00 00       	jmp    f01080b3 <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0107f4e:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0107f52:	0f b7 c6             	movzwl %si,%eax
f0107f55:	01 d8                	add    %ebx,%eax
f0107f57:	e8 bc fd ff ff       	call   f0107d18 <sum>
f0107f5c:	02 43 2a             	add    0x2a(%ebx),%al
f0107f5f:	84 c0                	test   %al,%al
f0107f61:	74 11                	je     f0107f74 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0107f63:	c7 04 24 58 b2 10 f0 	movl   $0xf010b258,(%esp)
f0107f6a:	e8 1f d8 ff ff       	call   f010578e <cprintf>
f0107f6f:	e9 3f 01 00 00       	jmp    f01080b3 <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0107f74:	85 db                	test   %ebx,%ebx
f0107f76:	0f 84 37 01 00 00    	je     f01080b3 <mp_init+0x2c7>
		return;
	ismp = 1;
f0107f7c:	c7 05 00 c0 24 f0 01 	movl   $0x1,0xf024c000
f0107f83:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0107f86:	8b 43 24             	mov    0x24(%ebx),%eax
f0107f89:	a3 00 d0 28 f0       	mov    %eax,0xf028d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0107f8e:	8d 73 2c             	lea    0x2c(%ebx),%esi
f0107f91:	bf 00 00 00 00       	mov    $0x0,%edi
f0107f96:	e9 94 00 00 00       	jmp    f010802f <mp_init+0x243>
		switch (*p) {
f0107f9b:	8a 06                	mov    (%esi),%al
f0107f9d:	84 c0                	test   %al,%al
f0107f9f:	74 06                	je     f0107fa7 <mp_init+0x1bb>
f0107fa1:	3c 04                	cmp    $0x4,%al
f0107fa3:	77 68                	ja     f010800d <mp_init+0x221>
f0107fa5:	eb 61                	jmp    f0108008 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0107fa7:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0107fab:	74 1d                	je     f0107fca <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f0107fad:	a1 c4 c3 24 f0       	mov    0xf024c3c4,%eax
f0107fb2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0107fb9:	29 c2                	sub    %eax,%edx
f0107fbb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0107fbe:	8d 04 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%eax
f0107fc5:	a3 c0 c3 24 f0       	mov    %eax,0xf024c3c0
			if (ncpu < NCPU) {
f0107fca:	a1 c4 c3 24 f0       	mov    0xf024c3c4,%eax
f0107fcf:	83 f8 07             	cmp    $0x7,%eax
f0107fd2:	7f 1b                	jg     f0107fef <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0107fd4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0107fdb:	29 c2                	sub    %eax,%edx
f0107fdd:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0107fe0:	88 04 95 20 c0 24 f0 	mov    %al,-0xfdb3fe0(,%edx,4)
				ncpu++;
f0107fe7:	40                   	inc    %eax
f0107fe8:	a3 c4 c3 24 f0       	mov    %eax,0xf024c3c4
f0107fed:	eb 14                	jmp    f0108003 <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0107fef:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0107ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ff7:	c7 04 24 88 b2 10 f0 	movl   $0xf010b288,(%esp)
f0107ffe:	e8 8b d7 ff ff       	call   f010578e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0108003:	83 c6 14             	add    $0x14,%esi
			continue;
f0108006:	eb 26                	jmp    f010802e <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0108008:	83 c6 08             	add    $0x8,%esi
			continue;
f010800b:	eb 21                	jmp    f010802e <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010800d:	0f b6 c0             	movzbl %al,%eax
f0108010:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108014:	c7 04 24 b0 b2 10 f0 	movl   $0xf010b2b0,(%esp)
f010801b:	e8 6e d7 ff ff       	call   f010578e <cprintf>
			ismp = 0;
f0108020:	c7 05 00 c0 24 f0 00 	movl   $0x0,0xf024c000
f0108027:	00 00 00 
			i = conf->entry;
f010802a:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010802e:	47                   	inc    %edi
f010802f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0108033:	39 c7                	cmp    %eax,%edi
f0108035:	0f 82 60 ff ff ff    	jb     f0107f9b <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010803b:	a1 c0 c3 24 f0       	mov    0xf024c3c0,%eax
f0108040:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0108047:	83 3d 00 c0 24 f0 00 	cmpl   $0x0,0xf024c000
f010804e:	75 22                	jne    f0108072 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0108050:	c7 05 c4 c3 24 f0 01 	movl   $0x1,0xf024c3c4
f0108057:	00 00 00 
		lapicaddr = 0;
f010805a:	c7 05 00 d0 28 f0 00 	movl   $0x0,0xf028d000
f0108061:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0108064:	c7 04 24 d0 b2 10 f0 	movl   $0xf010b2d0,(%esp)
f010806b:	e8 1e d7 ff ff       	call   f010578e <cprintf>
		return;
f0108070:	eb 41                	jmp    f01080b3 <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0108072:	8b 15 c4 c3 24 f0    	mov    0xf024c3c4,%edx
f0108078:	89 54 24 08          	mov    %edx,0x8(%esp)
f010807c:	0f b6 00             	movzbl (%eax),%eax
f010807f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108083:	c7 04 24 57 b3 10 f0 	movl   $0xf010b357,(%esp)
f010808a:	e8 ff d6 ff ff       	call   f010578e <cprintf>

	if (mp->imcrp) {
f010808f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108092:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0108096:	74 1b                	je     f01080b3 <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0108098:	c7 04 24 fc b2 10 f0 	movl   $0xf010b2fc,(%esp)
f010809f:	e8 ea d6 ff ff       	call   f010578e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01080a4:	ba 22 00 00 00       	mov    $0x22,%edx
f01080a9:	b0 70                	mov    $0x70,%al
f01080ab:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01080ac:	b2 23                	mov    $0x23,%dl
f01080ae:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01080af:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01080b2:	ee                   	out    %al,(%dx)
	}
}
f01080b3:	83 c4 2c             	add    $0x2c,%esp
f01080b6:	5b                   	pop    %ebx
f01080b7:	5e                   	pop    %esi
f01080b8:	5f                   	pop    %edi
f01080b9:	5d                   	pop    %ebp
f01080ba:	c3                   	ret    
	...

f01080bc <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01080bc:	55                   	push   %ebp
f01080bd:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01080bf:	c1 e0 02             	shl    $0x2,%eax
f01080c2:	03 05 04 d0 28 f0    	add    0xf028d004,%eax
f01080c8:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01080ca:	a1 04 d0 28 f0       	mov    0xf028d004,%eax
f01080cf:	8b 40 20             	mov    0x20(%eax),%eax
}
f01080d2:	5d                   	pop    %ebp
f01080d3:	c3                   	ret    

f01080d4 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01080d4:	55                   	push   %ebp
f01080d5:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01080d7:	a1 04 d0 28 f0       	mov    0xf028d004,%eax
f01080dc:	85 c0                	test   %eax,%eax
f01080de:	74 08                	je     f01080e8 <cpunum+0x14>
		return lapic[ID] >> 24;
f01080e0:	8b 40 20             	mov    0x20(%eax),%eax
f01080e3:	c1 e8 18             	shr    $0x18,%eax
f01080e6:	eb 05                	jmp    f01080ed <cpunum+0x19>
	return 0;
f01080e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01080ed:	5d                   	pop    %ebp
f01080ee:	c3                   	ret    

f01080ef <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01080ef:	55                   	push   %ebp
f01080f0:	89 e5                	mov    %esp,%ebp
f01080f2:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01080f5:	a1 00 d0 28 f0       	mov    0xf028d000,%eax
f01080fa:	85 c0                	test   %eax,%eax
f01080fc:	0f 84 27 01 00 00    	je     f0108229 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0108102:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0108109:	00 
f010810a:	89 04 24             	mov    %eax,(%esp)
f010810d:	e8 82 aa ff ff       	call   f0102b94 <mmio_map_region>
f0108112:	a3 04 d0 28 f0       	mov    %eax,0xf028d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0108117:	ba 27 01 00 00       	mov    $0x127,%edx
f010811c:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0108121:	e8 96 ff ff ff       	call   f01080bc <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0108126:	ba 0b 00 00 00       	mov    $0xb,%edx
f010812b:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0108130:	e8 87 ff ff ff       	call   f01080bc <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0108135:	ba 20 00 02 00       	mov    $0x20020,%edx
f010813a:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010813f:	e8 78 ff ff ff       	call   f01080bc <lapicw>
	lapicw(TICR, 10000000); 
f0108144:	ba 80 96 98 00       	mov    $0x989680,%edx
f0108149:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010814e:	e8 69 ff ff ff       	call   f01080bc <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0108153:	e8 7c ff ff ff       	call   f01080d4 <cpunum>
f0108158:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010815f:	29 c2                	sub    %eax,%edx
f0108161:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0108164:	8d 04 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%eax
f010816b:	39 05 c0 c3 24 f0    	cmp    %eax,0xf024c3c0
f0108171:	74 0f                	je     f0108182 <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f0108173:	ba 00 00 01 00       	mov    $0x10000,%edx
f0108178:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010817d:	e8 3a ff ff ff       	call   f01080bc <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0108182:	ba 00 00 01 00       	mov    $0x10000,%edx
f0108187:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010818c:	e8 2b ff ff ff       	call   f01080bc <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0108191:	a1 04 d0 28 f0       	mov    0xf028d004,%eax
f0108196:	8b 40 30             	mov    0x30(%eax),%eax
f0108199:	c1 e8 10             	shr    $0x10,%eax
f010819c:	3c 03                	cmp    $0x3,%al
f010819e:	76 0f                	jbe    f01081af <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f01081a0:	ba 00 00 01 00       	mov    $0x10000,%edx
f01081a5:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01081aa:	e8 0d ff ff ff       	call   f01080bc <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01081af:	ba 33 00 00 00       	mov    $0x33,%edx
f01081b4:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01081b9:	e8 fe fe ff ff       	call   f01080bc <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01081be:	ba 00 00 00 00       	mov    $0x0,%edx
f01081c3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01081c8:	e8 ef fe ff ff       	call   f01080bc <lapicw>
	lapicw(ESR, 0);
f01081cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01081d2:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01081d7:	e8 e0 fe ff ff       	call   f01080bc <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01081dc:	ba 00 00 00 00       	mov    $0x0,%edx
f01081e1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01081e6:	e8 d1 fe ff ff       	call   f01080bc <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01081eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01081f0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01081f5:	e8 c2 fe ff ff       	call   f01080bc <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01081fa:	ba 00 85 08 00       	mov    $0x88500,%edx
f01081ff:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108204:	e8 b3 fe ff ff       	call   f01080bc <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0108209:	8b 15 04 d0 28 f0    	mov    0xf028d004,%edx
f010820f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0108215:	f6 c4 10             	test   $0x10,%ah
f0108218:	75 f5                	jne    f010820f <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010821a:	ba 00 00 00 00       	mov    $0x0,%edx
f010821f:	b8 20 00 00 00       	mov    $0x20,%eax
f0108224:	e8 93 fe ff ff       	call   f01080bc <lapicw>
}
f0108229:	c9                   	leave  
f010822a:	c3                   	ret    

f010822b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010822b:	55                   	push   %ebp
f010822c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010822e:	83 3d 04 d0 28 f0 00 	cmpl   $0x0,0xf028d004
f0108235:	74 0f                	je     f0108246 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0108237:	ba 00 00 00 00       	mov    $0x0,%edx
f010823c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0108241:	e8 76 fe ff ff       	call   f01080bc <lapicw>
}
f0108246:	5d                   	pop    %ebp
f0108247:	c3                   	ret    

f0108248 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0108248:	55                   	push   %ebp
f0108249:	89 e5                	mov    %esp,%ebp
f010824b:	56                   	push   %esi
f010824c:	53                   	push   %ebx
f010824d:	83 ec 10             	sub    $0x10,%esp
f0108250:	8b 75 0c             	mov    0xc(%ebp),%esi
f0108253:	8a 5d 08             	mov    0x8(%ebp),%bl
f0108256:	ba 70 00 00 00       	mov    $0x70,%edx
f010825b:	b0 0f                	mov    $0xf,%al
f010825d:	ee                   	out    %al,(%dx)
f010825e:	b2 71                	mov    $0x71,%dl
f0108260:	b0 0a                	mov    $0xa,%al
f0108262:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0108263:	83 3d 88 be 24 f0 00 	cmpl   $0x0,0xf024be88
f010826a:	75 24                	jne    f0108290 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010826c:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0108273:	00 
f0108274:	c7 44 24 08 e8 87 10 	movl   $0xf01087e8,0x8(%esp)
f010827b:	f0 
f010827c:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0108283:	00 
f0108284:	c7 04 24 74 b3 10 f0 	movl   $0xf010b374,(%esp)
f010828b:	e8 b0 7d ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0108290:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0108297:	00 00 
	wrv[1] = addr >> 4;
f0108299:	89 f0                	mov    %esi,%eax
f010829b:	c1 e8 04             	shr    $0x4,%eax
f010829e:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01082a4:	c1 e3 18             	shl    $0x18,%ebx
f01082a7:	89 da                	mov    %ebx,%edx
f01082a9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01082ae:	e8 09 fe ff ff       	call   f01080bc <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01082b3:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01082b8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01082bd:	e8 fa fd ff ff       	call   f01080bc <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01082c2:	ba 00 85 00 00       	mov    $0x8500,%edx
f01082c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01082cc:	e8 eb fd ff ff       	call   f01080bc <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01082d1:	c1 ee 0c             	shr    $0xc,%esi
f01082d4:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01082da:	89 da                	mov    %ebx,%edx
f01082dc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01082e1:	e8 d6 fd ff ff       	call   f01080bc <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01082e6:	89 f2                	mov    %esi,%edx
f01082e8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01082ed:	e8 ca fd ff ff       	call   f01080bc <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01082f2:	89 da                	mov    %ebx,%edx
f01082f4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01082f9:	e8 be fd ff ff       	call   f01080bc <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01082fe:	89 f2                	mov    %esi,%edx
f0108300:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108305:	e8 b2 fd ff ff       	call   f01080bc <lapicw>
		microdelay(200);
	}
}
f010830a:	83 c4 10             	add    $0x10,%esp
f010830d:	5b                   	pop    %ebx
f010830e:	5e                   	pop    %esi
f010830f:	5d                   	pop    %ebp
f0108310:	c3                   	ret    

f0108311 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0108311:	55                   	push   %ebp
f0108312:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0108314:	8b 55 08             	mov    0x8(%ebp),%edx
f0108317:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010831d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108322:	e8 95 fd ff ff       	call   f01080bc <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0108327:	8b 15 04 d0 28 f0    	mov    0xf028d004,%edx
f010832d:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0108333:	f6 c4 10             	test   $0x10,%ah
f0108336:	75 f5                	jne    f010832d <lapic_ipi+0x1c>
		;
}
f0108338:	5d                   	pop    %ebp
f0108339:	c3                   	ret    
	...

f010833c <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010833c:	55                   	push   %ebp
f010833d:	89 e5                	mov    %esp,%ebp
f010833f:	53                   	push   %ebx
f0108340:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0108343:	83 38 00             	cmpl   $0x0,(%eax)
f0108346:	74 25                	je     f010836d <holding+0x31>
f0108348:	8b 58 08             	mov    0x8(%eax),%ebx
f010834b:	e8 84 fd ff ff       	call   f01080d4 <cpunum>
f0108350:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0108357:	29 c2                	sub    %eax,%edx
f0108359:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010835c:	8d 04 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0108363:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0108365:	0f 94 c0             	sete   %al
f0108368:	0f b6 c0             	movzbl %al,%eax
f010836b:	eb 05                	jmp    f0108372 <holding+0x36>
f010836d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108372:	83 c4 04             	add    $0x4,%esp
f0108375:	5b                   	pop    %ebx
f0108376:	5d                   	pop    %ebp
f0108377:	c3                   	ret    

f0108378 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0108378:	55                   	push   %ebp
f0108379:	89 e5                	mov    %esp,%ebp
f010837b:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010837e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0108384:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108387:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010838a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0108391:	5d                   	pop    %ebp
f0108392:	c3                   	ret    

f0108393 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0108393:	55                   	push   %ebp
f0108394:	89 e5                	mov    %esp,%ebp
f0108396:	53                   	push   %ebx
f0108397:	83 ec 24             	sub    $0x24,%esp
f010839a:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010839d:	89 d8                	mov    %ebx,%eax
f010839f:	e8 98 ff ff ff       	call   f010833c <holding>
f01083a4:	85 c0                	test   %eax,%eax
f01083a6:	74 30                	je     f01083d8 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01083a8:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01083ab:	e8 24 fd ff ff       	call   f01080d4 <cpunum>
f01083b0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01083b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01083b8:	c7 44 24 08 84 b3 10 	movl   $0xf010b384,0x8(%esp)
f01083bf:	f0 
f01083c0:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01083c7:	00 
f01083c8:	c7 04 24 e8 b3 10 f0 	movl   $0xf010b3e8,(%esp)
f01083cf:	e8 6c 7c ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01083d4:	f3 90                	pause  
f01083d6:	eb 05                	jmp    f01083dd <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01083d8:	ba 01 00 00 00       	mov    $0x1,%edx
f01083dd:	89 d0                	mov    %edx,%eax
f01083df:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01083e2:	85 c0                	test   %eax,%eax
f01083e4:	75 ee                	jne    f01083d4 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01083e6:	e8 e9 fc ff ff       	call   f01080d4 <cpunum>
f01083eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01083f2:	29 c2                	sub    %eax,%edx
f01083f4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01083f7:	8d 04 85 20 c0 24 f0 	lea    -0xfdb3fe0(,%eax,4),%eax
f01083fe:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0108401:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0108404:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0108406:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010840b:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0108411:	76 10                	jbe    f0108423 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0108413:	8b 4a 04             	mov    0x4(%edx),%ecx
f0108416:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0108419:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010841b:	40                   	inc    %eax
f010841c:	83 f8 0a             	cmp    $0xa,%eax
f010841f:	75 ea                	jne    f010840b <spin_lock+0x78>
f0108421:	eb 0d                	jmp    f0108430 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0108423:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010842a:	40                   	inc    %eax
f010842b:	83 f8 09             	cmp    $0x9,%eax
f010842e:	7e f3                	jle    f0108423 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0108430:	83 c4 24             	add    $0x24,%esp
f0108433:	5b                   	pop    %ebx
f0108434:	5d                   	pop    %ebp
f0108435:	c3                   	ret    

f0108436 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0108436:	55                   	push   %ebp
f0108437:	89 e5                	mov    %esp,%ebp
f0108439:	57                   	push   %edi
f010843a:	56                   	push   %esi
f010843b:	53                   	push   %ebx
f010843c:	83 ec 7c             	sub    $0x7c,%esp
f010843f:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0108442:	89 d8                	mov    %ebx,%eax
f0108444:	e8 f3 fe ff ff       	call   f010833c <holding>
f0108449:	85 c0                	test   %eax,%eax
f010844b:	0f 85 d3 00 00 00    	jne    f0108524 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0108451:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0108458:	00 
f0108459:	8d 43 0c             	lea    0xc(%ebx),%eax
f010845c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108460:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0108463:	89 34 24             	mov    %esi,(%esp)
f0108466:	e8 85 f6 ff ff       	call   f0107af0 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010846b:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010846e:	0f b6 38             	movzbl (%eax),%edi
f0108471:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0108474:	e8 5b fc ff ff       	call   f01080d4 <cpunum>
f0108479:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010847d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0108481:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108485:	c7 04 24 b0 b3 10 f0 	movl   $0xf010b3b0,(%esp)
f010848c:	e8 fd d2 ff ff       	call   f010578e <cprintf>
f0108491:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0108493:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0108496:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0108499:	89 c7                	mov    %eax,%edi
f010849b:	eb 63                	jmp    f0108500 <spin_unlock+0xca>
f010849d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01084a1:	89 04 24             	mov    %eax,(%esp)
f01084a4:	e8 f8 ea ff ff       	call   f0106fa1 <debuginfo_eip>
f01084a9:	85 c0                	test   %eax,%eax
f01084ab:	78 39                	js     f01084e6 <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01084ad:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01084af:	89 c2                	mov    %eax,%edx
f01084b1:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01084b4:	89 54 24 18          	mov    %edx,0x18(%esp)
f01084b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01084bb:	89 54 24 14          	mov    %edx,0x14(%esp)
f01084bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01084c2:	89 54 24 10          	mov    %edx,0x10(%esp)
f01084c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01084c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01084cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01084d0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01084d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01084d8:	c7 04 24 f8 b3 10 f0 	movl   $0xf010b3f8,(%esp)
f01084df:	e8 aa d2 ff ff       	call   f010578e <cprintf>
f01084e4:	eb 12                	jmp    f01084f8 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01084e6:	8b 06                	mov    (%esi),%eax
f01084e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01084ec:	c7 04 24 0f b4 10 f0 	movl   $0xf010b40f,(%esp)
f01084f3:	e8 96 d2 ff ff       	call   f010578e <cprintf>
f01084f8:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01084fb:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f01084fe:	74 08                	je     f0108508 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0108500:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0108502:	8b 03                	mov    (%ebx),%eax
f0108504:	85 c0                	test   %eax,%eax
f0108506:	75 95                	jne    f010849d <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0108508:	c7 44 24 08 17 b4 10 	movl   $0xf010b417,0x8(%esp)
f010850f:	f0 
f0108510:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0108517:	00 
f0108518:	c7 04 24 e8 b3 10 f0 	movl   $0xf010b3e8,(%esp)
f010851f:	e8 1c 7b ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0108524:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010852b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0108532:	b8 00 00 00 00       	mov    $0x0,%eax
f0108537:	f0 87 03             	lock xchg %eax,(%ebx)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010853a:	83 c4 7c             	add    $0x7c,%esp
f010853d:	5b                   	pop    %ebx
f010853e:	5e                   	pop    %esi
f010853f:	5f                   	pop    %edi
f0108540:	5d                   	pop    %ebp
f0108541:	c3                   	ret    
	...

f0108544 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0108544:	55                   	push   %ebp
f0108545:	57                   	push   %edi
f0108546:	56                   	push   %esi
f0108547:	83 ec 10             	sub    $0x10,%esp
f010854a:	8b 74 24 20          	mov    0x20(%esp),%esi
f010854e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0108552:	89 74 24 04          	mov    %esi,0x4(%esp)
f0108556:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f010855a:	89 cd                	mov    %ecx,%ebp
f010855c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0108560:	85 c0                	test   %eax,%eax
f0108562:	75 2c                	jne    f0108590 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0108564:	39 f9                	cmp    %edi,%ecx
f0108566:	77 68                	ja     f01085d0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0108568:	85 c9                	test   %ecx,%ecx
f010856a:	75 0b                	jne    f0108577 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010856c:	b8 01 00 00 00       	mov    $0x1,%eax
f0108571:	31 d2                	xor    %edx,%edx
f0108573:	f7 f1                	div    %ecx
f0108575:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0108577:	31 d2                	xor    %edx,%edx
f0108579:	89 f8                	mov    %edi,%eax
f010857b:	f7 f1                	div    %ecx
f010857d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010857f:	89 f0                	mov    %esi,%eax
f0108581:	f7 f1                	div    %ecx
f0108583:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0108585:	89 f0                	mov    %esi,%eax
f0108587:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0108589:	83 c4 10             	add    $0x10,%esp
f010858c:	5e                   	pop    %esi
f010858d:	5f                   	pop    %edi
f010858e:	5d                   	pop    %ebp
f010858f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0108590:	39 f8                	cmp    %edi,%eax
f0108592:	77 2c                	ja     f01085c0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0108594:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0108597:	83 f6 1f             	xor    $0x1f,%esi
f010859a:	75 4c                	jne    f01085e8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010859c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010859e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01085a3:	72 0a                	jb     f01085af <__udivdi3+0x6b>
f01085a5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01085a9:	0f 87 ad 00 00 00    	ja     f010865c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01085af:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01085b4:	89 f0                	mov    %esi,%eax
f01085b6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01085b8:	83 c4 10             	add    $0x10,%esp
f01085bb:	5e                   	pop    %esi
f01085bc:	5f                   	pop    %edi
f01085bd:	5d                   	pop    %ebp
f01085be:	c3                   	ret    
f01085bf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01085c0:	31 ff                	xor    %edi,%edi
f01085c2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01085c4:	89 f0                	mov    %esi,%eax
f01085c6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01085c8:	83 c4 10             	add    $0x10,%esp
f01085cb:	5e                   	pop    %esi
f01085cc:	5f                   	pop    %edi
f01085cd:	5d                   	pop    %ebp
f01085ce:	c3                   	ret    
f01085cf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01085d0:	89 fa                	mov    %edi,%edx
f01085d2:	89 f0                	mov    %esi,%eax
f01085d4:	f7 f1                	div    %ecx
f01085d6:	89 c6                	mov    %eax,%esi
f01085d8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01085da:	89 f0                	mov    %esi,%eax
f01085dc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01085de:	83 c4 10             	add    $0x10,%esp
f01085e1:	5e                   	pop    %esi
f01085e2:	5f                   	pop    %edi
f01085e3:	5d                   	pop    %ebp
f01085e4:	c3                   	ret    
f01085e5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01085e8:	89 f1                	mov    %esi,%ecx
f01085ea:	d3 e0                	shl    %cl,%eax
f01085ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01085f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01085f5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01085f7:	89 ea                	mov    %ebp,%edx
f01085f9:	88 c1                	mov    %al,%cl
f01085fb:	d3 ea                	shr    %cl,%edx
f01085fd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0108601:	09 ca                	or     %ecx,%edx
f0108603:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0108607:	89 f1                	mov    %esi,%ecx
f0108609:	d3 e5                	shl    %cl,%ebp
f010860b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f010860f:	89 fd                	mov    %edi,%ebp
f0108611:	88 c1                	mov    %al,%cl
f0108613:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0108615:	89 fa                	mov    %edi,%edx
f0108617:	89 f1                	mov    %esi,%ecx
f0108619:	d3 e2                	shl    %cl,%edx
f010861b:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010861f:	88 c1                	mov    %al,%cl
f0108621:	d3 ef                	shr    %cl,%edi
f0108623:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0108625:	89 f8                	mov    %edi,%eax
f0108627:	89 ea                	mov    %ebp,%edx
f0108629:	f7 74 24 08          	divl   0x8(%esp)
f010862d:	89 d1                	mov    %edx,%ecx
f010862f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f0108631:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0108635:	39 d1                	cmp    %edx,%ecx
f0108637:	72 17                	jb     f0108650 <__udivdi3+0x10c>
f0108639:	74 09                	je     f0108644 <__udivdi3+0x100>
f010863b:	89 fe                	mov    %edi,%esi
f010863d:	31 ff                	xor    %edi,%edi
f010863f:	e9 41 ff ff ff       	jmp    f0108585 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0108644:	8b 54 24 04          	mov    0x4(%esp),%edx
f0108648:	89 f1                	mov    %esi,%ecx
f010864a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010864c:	39 c2                	cmp    %eax,%edx
f010864e:	73 eb                	jae    f010863b <__udivdi3+0xf7>
		{
		  q0--;
f0108650:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0108653:	31 ff                	xor    %edi,%edi
f0108655:	e9 2b ff ff ff       	jmp    f0108585 <__udivdi3+0x41>
f010865a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010865c:	31 f6                	xor    %esi,%esi
f010865e:	e9 22 ff ff ff       	jmp    f0108585 <__udivdi3+0x41>
	...

f0108664 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0108664:	55                   	push   %ebp
f0108665:	57                   	push   %edi
f0108666:	56                   	push   %esi
f0108667:	83 ec 20             	sub    $0x20,%esp
f010866a:	8b 44 24 30          	mov    0x30(%esp),%eax
f010866e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0108672:	89 44 24 14          	mov    %eax,0x14(%esp)
f0108676:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f010867a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010867e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0108682:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0108684:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0108686:	85 ed                	test   %ebp,%ebp
f0108688:	75 16                	jne    f01086a0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f010868a:	39 f1                	cmp    %esi,%ecx
f010868c:	0f 86 a6 00 00 00    	jbe    f0108738 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0108692:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0108694:	89 d0                	mov    %edx,%eax
f0108696:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0108698:	83 c4 20             	add    $0x20,%esp
f010869b:	5e                   	pop    %esi
f010869c:	5f                   	pop    %edi
f010869d:	5d                   	pop    %ebp
f010869e:	c3                   	ret    
f010869f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01086a0:	39 f5                	cmp    %esi,%ebp
f01086a2:	0f 87 ac 00 00 00    	ja     f0108754 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01086a8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f01086ab:	83 f0 1f             	xor    $0x1f,%eax
f01086ae:	89 44 24 10          	mov    %eax,0x10(%esp)
f01086b2:	0f 84 a8 00 00 00    	je     f0108760 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01086b8:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01086bc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01086be:	bf 20 00 00 00       	mov    $0x20,%edi
f01086c3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f01086c7:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01086cb:	89 f9                	mov    %edi,%ecx
f01086cd:	d3 e8                	shr    %cl,%eax
f01086cf:	09 e8                	or     %ebp,%eax
f01086d1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f01086d5:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01086d9:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01086dd:	d3 e0                	shl    %cl,%eax
f01086df:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01086e3:	89 f2                	mov    %esi,%edx
f01086e5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f01086e7:	8b 44 24 14          	mov    0x14(%esp),%eax
f01086eb:	d3 e0                	shl    %cl,%eax
f01086ed:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01086f1:	8b 44 24 14          	mov    0x14(%esp),%eax
f01086f5:	89 f9                	mov    %edi,%ecx
f01086f7:	d3 e8                	shr    %cl,%eax
f01086f9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f01086fb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01086fd:	89 f2                	mov    %esi,%edx
f01086ff:	f7 74 24 18          	divl   0x18(%esp)
f0108703:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0108705:	f7 64 24 0c          	mull   0xc(%esp)
f0108709:	89 c5                	mov    %eax,%ebp
f010870b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010870d:	39 d6                	cmp    %edx,%esi
f010870f:	72 67                	jb     f0108778 <__umoddi3+0x114>
f0108711:	74 75                	je     f0108788 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0108713:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0108717:	29 e8                	sub    %ebp,%eax
f0108719:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f010871b:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010871f:	d3 e8                	shr    %cl,%eax
f0108721:	89 f2                	mov    %esi,%edx
f0108723:	89 f9                	mov    %edi,%ecx
f0108725:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0108727:	09 d0                	or     %edx,%eax
f0108729:	89 f2                	mov    %esi,%edx
f010872b:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010872f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0108731:	83 c4 20             	add    $0x20,%esp
f0108734:	5e                   	pop    %esi
f0108735:	5f                   	pop    %edi
f0108736:	5d                   	pop    %ebp
f0108737:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0108738:	85 c9                	test   %ecx,%ecx
f010873a:	75 0b                	jne    f0108747 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010873c:	b8 01 00 00 00       	mov    $0x1,%eax
f0108741:	31 d2                	xor    %edx,%edx
f0108743:	f7 f1                	div    %ecx
f0108745:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0108747:	89 f0                	mov    %esi,%eax
f0108749:	31 d2                	xor    %edx,%edx
f010874b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010874d:	89 f8                	mov    %edi,%eax
f010874f:	e9 3e ff ff ff       	jmp    f0108692 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0108754:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0108756:	83 c4 20             	add    $0x20,%esp
f0108759:	5e                   	pop    %esi
f010875a:	5f                   	pop    %edi
f010875b:	5d                   	pop    %ebp
f010875c:	c3                   	ret    
f010875d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0108760:	39 f5                	cmp    %esi,%ebp
f0108762:	72 04                	jb     f0108768 <__umoddi3+0x104>
f0108764:	39 f9                	cmp    %edi,%ecx
f0108766:	77 06                	ja     f010876e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0108768:	89 f2                	mov    %esi,%edx
f010876a:	29 cf                	sub    %ecx,%edi
f010876c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f010876e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0108770:	83 c4 20             	add    $0x20,%esp
f0108773:	5e                   	pop    %esi
f0108774:	5f                   	pop    %edi
f0108775:	5d                   	pop    %ebp
f0108776:	c3                   	ret    
f0108777:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0108778:	89 d1                	mov    %edx,%ecx
f010877a:	89 c5                	mov    %eax,%ebp
f010877c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0108780:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0108784:	eb 8d                	jmp    f0108713 <__umoddi3+0xaf>
f0108786:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0108788:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f010878c:	72 ea                	jb     f0108778 <__umoddi3+0x114>
f010878e:	89 f1                	mov    %esi,%ecx
f0108790:	eb 81                	jmp    f0108713 <__umoddi3+0xaf>
