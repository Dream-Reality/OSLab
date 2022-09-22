
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
f010004b:	83 3d 80 6e 35 f0 00 	cmpl   $0x0,0xf0356e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 6e 35 f0    	mov    %esi,0xf0356e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 0c 81 00 00       	call   f0108170 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 40 88 10 f0 	movl   $0xf0108840,(%esp)
f010007d:	e8 6c 57 00 00       	call   f01057ee <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 2d 57 00 00       	call   f01057bb <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 c8 a9 10 f0 	movl   $0xf010a9c8,(%esp)
f0100095:	e8 54 57 00 00       	call   f01057ee <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 d5 1b 00 00       	call   f0101c7b <monitor>
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
f01000ae:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 ab 88 10 f0 	movl   $0xf01088ab,(%esp)
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
f01000e2:	e8 89 80 00 00       	call   f0108170 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 b7 88 10 f0 	movl   $0xf01088b7,(%esp)
f01000f2:	e8 f7 56 00 00       	call   f01057ee <cprintf>

	lapic_init();
f01000f7:	e8 8f 80 00 00       	call   f010818b <lapic_init>
	env_init_percpu();
f01000fc:	e8 9c 4d 00 00       	call   f0104e9d <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 02 57 00 00       	call   f0105808 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 65 80 00 00       	call   f0108170 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 70 35 f0    	add    $0xf0357020,%edx
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
f0100124:	e8 06 83 00 00       	call   f010842f <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 c4 66 00 00       	call   f01067f2 <sched_yield>

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
f0100135:	e8 12 08 00 00       	call   f010094c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010013a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100141:	00 
f0100142:	c7 04 24 cd 88 10 f0 	movl   $0xf01088cd,(%esp)
f0100149:	e8 a0 56 00 00       	call   f01057ee <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010014e:	e8 b1 2a 00 00       	call   f0102c04 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100153:	e8 6f 4d 00 00       	call   f0104ec7 <env_init>
	trap_init();
f0100158:	e8 f8 5a 00 00       	call   f0105c55 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010015d:	e8 26 7d 00 00       	call   f0107e88 <mp_init>
	lapic_init();
f0100162:	e8 24 80 00 00       	call   f010818b <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100167:	e8 d8 55 00 00       	call   f0105744 <pic_init>
f010016c:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f0100173:	e8 b7 82 00 00       	call   f010842f <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100178:	83 3d 88 6e 35 f0 07 	cmpl   $0x7,0xf0356e88
f010017f:	77 24                	ja     f01001a5 <i386_init+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100181:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100188:	00 
f0100189:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0100190:	f0 
f0100191:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
f0100198:	00 
f0100199:	c7 04 24 ab 88 10 f0 	movl   $0xf01088ab,(%esp)
f01001a0:	e8 9b fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001a5:	b8 b2 7d 10 f0       	mov    $0xf0107db2,%eax
f01001aa:	2d 38 7d 10 f0       	sub    $0xf0107d38,%eax
f01001af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001b3:	c7 44 24 04 38 7d 10 	movl   $0xf0107d38,0x4(%esp)
f01001ba:	f0 
f01001bb:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001c2:	e8 c5 79 00 00       	call   f0107b8c <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c7:	bb 20 70 35 f0       	mov    $0xf0357020,%ebx
f01001cc:	eb 6f                	jmp    f010023d <i386_init+0x10f>
		if (c == cpus + cpunum())  // We've started already.
f01001ce:	e8 9d 7f 00 00       	call   f0108170 <cpunum>
f01001d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001da:	29 c2                	sub    %eax,%edx
f01001dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001df:	8d 04 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%eax
f01001e6:	39 c3                	cmp    %eax,%ebx
f01001e8:	74 50                	je     f010023a <i386_init+0x10c>

static void boot_aps(void);


void
i386_init(void)
f01001ea:	89 d8                	mov    %ebx,%eax
f01001ec:	2d 20 70 35 f0       	sub    $0xf0357020,%eax
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
f0100215:	05 00 80 35 f0       	add    $0xf0358000,%eax
f010021a:	a3 84 6e 35 f0       	mov    %eax,0xf0356e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010021f:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100226:	00 
f0100227:	0f b6 03             	movzbl (%ebx),%eax
f010022a:	89 04 24             	mov    %eax,(%esp)
f010022d:	e8 b2 80 00 00       	call   f01082e4 <lapic_startap>
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
f010023d:	a1 c4 73 35 f0       	mov    0xf03573c4,%eax
f0100242:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100249:	29 c2                	sub    %eax,%edx
f010024b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010024e:	8d 04 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%eax
f0100255:	39 c3                	cmp    %eax,%ebx
f0100257:	0f 82 71 ff ff ff    	jb     f01001ce <i386_init+0xa0>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010025d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100264:	00 
f0100265:	c7 04 24 7e 44 34 f0 	movl   $0xf034447e,(%esp)
f010026c:	e8 db 4e 00 00       	call   f010514c <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100271:	e8 7c 65 00 00       	call   f01067f2 <sched_yield>

f0100276 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100276:	55                   	push   %ebp
f0100277:	89 e5                	mov    %esp,%ebp
f0100279:	53                   	push   %ebx
f010027a:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010027d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100280:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100283:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100287:	8b 45 08             	mov    0x8(%ebp),%eax
f010028a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010028e:	c7 04 24 e8 88 10 f0 	movl   $0xf01088e8,(%esp)
f0100295:	e8 54 55 00 00       	call   f01057ee <cprintf>
	vcprintf(fmt, ap);
f010029a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010029e:	8b 45 10             	mov    0x10(%ebp),%eax
f01002a1:	89 04 24             	mov    %eax,(%esp)
f01002a4:	e8 12 55 00 00       	call   f01057bb <vcprintf>
	cprintf("\n");
f01002a9:	c7 04 24 c8 a9 10 f0 	movl   $0xf010a9c8,(%esp)
f01002b0:	e8 39 55 00 00       	call   f01057ee <cprintf>
	va_end(ap);
}
f01002b5:	83 c4 14             	add    $0x14,%esp
f01002b8:	5b                   	pop    %ebx
f01002b9:	5d                   	pop    %ebp
f01002ba:	c3                   	ret    
	...

f01002bc <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002bf:	ba 84 00 00 00       	mov    $0x84,%edx
f01002c4:	ec                   	in     (%dx),%al
f01002c5:	ec                   	in     (%dx),%al
f01002c6:	ec                   	in     (%dx),%al
f01002c7:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002c8:	5d                   	pop    %ebp
f01002c9:	c3                   	ret    

f01002ca <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ca:	55                   	push   %ebp
f01002cb:	89 e5                	mov    %esp,%ebp
f01002cd:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d3:	a8 01                	test   $0x1,%al
f01002d5:	74 08                	je     f01002df <serial_proc_data+0x15>
f01002d7:	b2 f8                	mov    $0xf8,%dl
f01002d9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002da:	0f b6 c0             	movzbl %al,%eax
f01002dd:	eb 05                	jmp    f01002e4 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002e4:	5d                   	pop    %ebp
f01002e5:	c3                   	ret    

f01002e6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002e6:	55                   	push   %ebp
f01002e7:	89 e5                	mov    %esp,%ebp
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 04             	sub    $0x4,%esp
f01002ed:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002ef:	eb 29                	jmp    f010031a <cons_intr+0x34>
		if (c == 0)
f01002f1:	85 c0                	test   %eax,%eax
f01002f3:	74 25                	je     f010031a <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01002f5:	8b 15 24 62 35 f0    	mov    0xf0356224,%edx
f01002fb:	88 82 20 60 35 f0    	mov    %al,-0xfca9fe0(%edx)
f0100301:	8d 42 01             	lea    0x1(%edx),%eax
f0100304:	a3 24 62 35 f0       	mov    %eax,0xf0356224
		if (cons.wpos == CONSBUFSIZE)
f0100309:	3d 00 02 00 00       	cmp    $0x200,%eax
f010030e:	75 0a                	jne    f010031a <cons_intr+0x34>
			cons.wpos = 0;
f0100310:	c7 05 24 62 35 f0 00 	movl   $0x0,0xf0356224
f0100317:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010031a:	ff d3                	call   *%ebx
f010031c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010031f:	75 d0                	jne    f01002f1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100321:	83 c4 04             	add    $0x4,%esp
f0100324:	5b                   	pop    %ebx
f0100325:	5d                   	pop    %ebp
f0100326:	c3                   	ret    

f0100327 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100327:	55                   	push   %ebp
f0100328:	89 e5                	mov    %esp,%ebp
f010032a:	57                   	push   %edi
f010032b:	56                   	push   %esi
f010032c:	53                   	push   %ebx
f010032d:	83 ec 2c             	sub    $0x2c,%esp
f0100330:	89 c6                	mov    %eax,%esi
f0100332:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100337:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010033c:	eb 05                	jmp    f0100343 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010033e:	e8 79 ff ff ff       	call   f01002bc <delay>
f0100343:	89 fa                	mov    %edi,%edx
f0100345:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100346:	a8 20                	test   $0x20,%al
f0100348:	75 03                	jne    f010034d <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010034a:	4b                   	dec    %ebx
f010034b:	75 f1                	jne    f010033e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010034d:	89 f2                	mov    %esi,%edx
f010034f:	89 f0                	mov    %esi,%eax
f0100351:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100354:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100359:	ee                   	out    %al,(%dx)
f010035a:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100364:	eb 05                	jmp    f010036b <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100366:	e8 51 ff ff ff       	call   f01002bc <delay>
f010036b:	89 fa                	mov    %edi,%edx
f010036d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010036e:	84 c0                	test   %al,%al
f0100370:	78 03                	js     f0100375 <cons_putc+0x4e>
f0100372:	4b                   	dec    %ebx
f0100373:	75 f1                	jne    f0100366 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100375:	ba 78 03 00 00       	mov    $0x378,%edx
f010037a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010037d:	ee                   	out    %al,(%dx)
f010037e:	b2 7a                	mov    $0x7a,%dl
f0100380:	b0 0d                	mov    $0xd,%al
f0100382:	ee                   	out    %al,(%dx)
f0100383:	b0 08                	mov    $0x8,%al
f0100385:	ee                   	out    %al,(%dx)
{
	// if no attribute given, then use black on white
	static int Color = 0x0700;
	static int State = 0;
	static int Number = 0;
	if (!(c & ~0xFF))
f0100386:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010038c:	75 06                	jne    f0100394 <cons_putc+0x6d>
		c |= Color;
f010038e:	0b 35 00 e0 12 f0    	or     0xf012e000,%esi
	switch (c & 0xff) {
f0100394:	89 f2                	mov    %esi,%edx
f0100396:	81 e2 ff 00 00 00    	and    $0xff,%edx
f010039c:	8d 42 f8             	lea    -0x8(%edx),%eax
f010039f:	83 f8 13             	cmp    $0x13,%eax
f01003a2:	0f 87 ab 00 00 00    	ja     f0100453 <cons_putc+0x12c>
f01003a8:	ff 24 85 20 89 10 f0 	jmp    *-0xfef76e0(,%eax,4)
	case '\b':
		if (crt_pos > 0) {
f01003af:	66 a1 34 62 35 f0    	mov    0xf0356234,%ax
f01003b5:	66 85 c0             	test   %ax,%ax
f01003b8:	0f 84 de 03 00 00    	je     f010079c <cons_putc+0x475>
			crt_pos--;
f01003be:	48                   	dec    %eax
f01003bf:	66 a3 34 62 35 f0    	mov    %ax,0xf0356234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c5:	0f b7 c0             	movzwl %ax,%eax
f01003c8:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01003ce:	83 ce 20             	or     $0x20,%esi
f01003d1:	8b 15 30 62 35 f0    	mov    0xf0356230,%edx
f01003d7:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01003db:	e9 71 03 00 00       	jmp    f0100751 <cons_putc+0x42a>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003e0:	66 83 05 34 62 35 f0 	addw   $0x50,0xf0356234
f01003e7:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e8:	66 8b 0d 34 62 35 f0 	mov    0xf0356234,%cx
f01003ef:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003f4:	89 c8                	mov    %ecx,%eax
f01003f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01003fb:	66 f7 f3             	div    %bx
f01003fe:	66 29 d1             	sub    %dx,%cx
f0100401:	66 89 0d 34 62 35 f0 	mov    %cx,0xf0356234
f0100408:	e9 44 03 00 00       	jmp    f0100751 <cons_putc+0x42a>
		break;
	case '\t':
		cons_putc(' ');
f010040d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100412:	e8 10 ff ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100417:	b8 20 00 00 00       	mov    $0x20,%eax
f010041c:	e8 06 ff ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100421:	b8 20 00 00 00       	mov    $0x20,%eax
f0100426:	e8 fc fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f010042b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100430:	e8 f2 fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100435:	b8 20 00 00 00       	mov    $0x20,%eax
f010043a:	e8 e8 fe ff ff       	call   f0100327 <cons_putc>
f010043f:	e9 0d 03 00 00       	jmp    f0100751 <cons_putc+0x42a>
		break;
	case '\033':
		State = 1;
f0100444:	c7 05 38 62 35 f0 01 	movl   $0x1,0xf0356238
f010044b:	00 00 00 
f010044e:	e9 fe 02 00 00       	jmp    f0100751 <cons_putc+0x42a>
		break;
	default:
		if (State == 1){
f0100453:	83 3d 38 62 35 f0 01 	cmpl   $0x1,0xf0356238
f010045a:	0f 85 d7 02 00 00    	jne    f0100737 <cons_putc+0x410>
			switch (c&0xff){
f0100460:	83 fa 5b             	cmp    $0x5b,%edx
f0100463:	0f 84 e8 02 00 00    	je     f0100751 <cons_putc+0x42a>
f0100469:	83 fa 6d             	cmp    $0x6d,%edx
f010046c:	0f 84 5a 01 00 00    	je     f01005cc <cons_putc+0x2a5>
f0100472:	83 fa 3b             	cmp    $0x3b,%edx
f0100475:	0f 85 a9 02 00 00    	jne    f0100724 <cons_putc+0x3fd>
				case '[':
					break;
				case ';':
					switch (Number){
f010047b:	a1 3c 62 35 f0       	mov    0xf035623c,%eax
f0100480:	83 e8 1e             	sub    $0x1e,%eax
f0100483:	83 f8 11             	cmp    $0x11,%eax
f0100486:	0f 87 31 01 00 00    	ja     f01005bd <cons_putc+0x296>
f010048c:	ff 24 85 70 89 10 f0 	jmp    *-0xfef7690(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f0100493:	81 25 00 e0 12 f0 ff 	andl   $0xfffff0ff,0xf012e000
f010049a:	f0 ff ff 
f010049d:	e9 1b 01 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f01004a2:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004a7:	80 e4 f0             	and    $0xf0,%ah
f01004aa:	80 cc 04             	or     $0x4,%ah
f01004ad:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01004b2:	e9 06 01 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f01004b7:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004bc:	80 e4 f0             	and    $0xf0,%ah
f01004bf:	80 cc 02             	or     $0x2,%ah
f01004c2:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01004c7:	e9 f1 00 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f01004cc:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004d1:	80 e4 f0             	and    $0xf0,%ah
f01004d4:	80 cc 06             	or     $0x6,%ah
f01004d7:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01004dc:	e9 dc 00 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f01004e1:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004e6:	80 e4 f0             	and    $0xf0,%ah
f01004e9:	80 cc 01             	or     $0x1,%ah
f01004ec:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01004f1:	e9 c7 00 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f01004f6:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01004fb:	80 e4 f0             	and    $0xf0,%ah
f01004fe:	80 cc 05             	or     $0x5,%ah
f0100501:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100506:	e9 b2 00 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f010050b:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100510:	80 e4 f0             	and    $0xf0,%ah
f0100513:	80 cc 03             	or     $0x3,%ah
f0100516:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010051b:	e9 9d 00 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f0100520:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100525:	80 e4 f0             	and    $0xf0,%ah
f0100528:	80 cc 07             	or     $0x7,%ah
f010052b:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100530:	e9 88 00 00 00       	jmp    f01005bd <cons_putc+0x296>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f0100535:	81 25 00 e0 12 f0 ff 	andl   $0xffff0fff,0xf012e000
f010053c:	0f ff ff 
f010053f:	eb 7c                	jmp    f01005bd <cons_putc+0x296>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f0100541:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100546:	80 e4 0f             	and    $0xf,%ah
f0100549:	80 cc 40             	or     $0x40,%ah
f010054c:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100551:	eb 6a                	jmp    f01005bd <cons_putc+0x296>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f0100553:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100558:	80 e4 0f             	and    $0xf,%ah
f010055b:	80 cc 20             	or     $0x20,%ah
f010055e:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100563:	eb 58                	jmp    f01005bd <cons_putc+0x296>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f0100565:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010056a:	80 e4 0f             	and    $0xf,%ah
f010056d:	80 cc 60             	or     $0x60,%ah
f0100570:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100575:	eb 46                	jmp    f01005bd <cons_putc+0x296>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f0100577:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010057c:	80 e4 0f             	and    $0xf,%ah
f010057f:	80 cc 10             	or     $0x10,%ah
f0100582:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100587:	eb 34                	jmp    f01005bd <cons_putc+0x296>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f0100589:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010058e:	80 e4 0f             	and    $0xf,%ah
f0100591:	80 cc 50             	or     $0x50,%ah
f0100594:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100599:	eb 22                	jmp    f01005bd <cons_putc+0x296>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f010059b:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01005a0:	80 e4 0f             	and    $0xf,%ah
f01005a3:	80 cc 30             	or     $0x30,%ah
f01005a6:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01005ab:	eb 10                	jmp    f01005bd <cons_putc+0x296>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f01005ad:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01005b2:	80 e4 0f             	and    $0xf,%ah
f01005b5:	80 cc 70             	or     $0x70,%ah
f01005b8:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
						default:break;
					}
					Number = 0;
f01005bd:	c7 05 3c 62 35 f0 00 	movl   $0x0,0xf035623c
f01005c4:	00 00 00 
f01005c7:	e9 85 01 00 00       	jmp    f0100751 <cons_putc+0x42a>
					break;
				case 'm':
					switch (Number){
f01005cc:	a1 3c 62 35 f0       	mov    0xf035623c,%eax
f01005d1:	83 e8 1e             	sub    $0x1e,%eax
f01005d4:	83 f8 11             	cmp    $0x11,%eax
f01005d7:	0f 87 31 01 00 00    	ja     f010070e <cons_putc+0x3e7>
f01005dd:	ff 24 85 b8 89 10 f0 	jmp    *-0xfef7648(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f01005e4:	81 25 00 e0 12 f0 ff 	andl   $0xfffff0ff,0xf012e000
f01005eb:	f0 ff ff 
f01005ee:	e9 1b 01 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f01005f3:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01005f8:	80 e4 f0             	and    $0xf0,%ah
f01005fb:	80 cc 04             	or     $0x4,%ah
f01005fe:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100603:	e9 06 01 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f0100608:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010060d:	80 e4 f0             	and    $0xf0,%ah
f0100610:	80 cc 02             	or     $0x2,%ah
f0100613:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100618:	e9 f1 00 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f010061d:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100622:	80 e4 f0             	and    $0xf0,%ah
f0100625:	80 cc 06             	or     $0x6,%ah
f0100628:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010062d:	e9 dc 00 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f0100632:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100637:	80 e4 f0             	and    $0xf0,%ah
f010063a:	80 cc 01             	or     $0x1,%ah
f010063d:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100642:	e9 c7 00 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f0100647:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f010064c:	80 e4 f0             	and    $0xf0,%ah
f010064f:	80 cc 05             	or     $0x5,%ah
f0100652:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100657:	e9 b2 00 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f010065c:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100661:	80 e4 f0             	and    $0xf0,%ah
f0100664:	80 cc 03             	or     $0x3,%ah
f0100667:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f010066c:	e9 9d 00 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f0100671:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100676:	80 e4 f0             	and    $0xf0,%ah
f0100679:	80 cc 07             	or     $0x7,%ah
f010067c:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f0100681:	e9 88 00 00 00       	jmp    f010070e <cons_putc+0x3e7>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f0100686:	81 25 00 e0 12 f0 ff 	andl   $0xffff0fff,0xf012e000
f010068d:	0f ff ff 
f0100690:	eb 7c                	jmp    f010070e <cons_putc+0x3e7>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f0100692:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100697:	80 e4 0f             	and    $0xf,%ah
f010069a:	80 cc 40             	or     $0x40,%ah
f010069d:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006a2:	eb 6a                	jmp    f010070e <cons_putc+0x3e7>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f01006a4:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006a9:	80 e4 0f             	and    $0xf,%ah
f01006ac:	80 cc 20             	or     $0x20,%ah
f01006af:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006b4:	eb 58                	jmp    f010070e <cons_putc+0x3e7>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f01006b6:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006bb:	80 e4 0f             	and    $0xf,%ah
f01006be:	80 cc 60             	or     $0x60,%ah
f01006c1:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006c6:	eb 46                	jmp    f010070e <cons_putc+0x3e7>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f01006c8:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006cd:	80 e4 0f             	and    $0xf,%ah
f01006d0:	80 cc 10             	or     $0x10,%ah
f01006d3:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006d8:	eb 34                	jmp    f010070e <cons_putc+0x3e7>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f01006da:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006df:	80 e4 0f             	and    $0xf,%ah
f01006e2:	80 cc 50             	or     $0x50,%ah
f01006e5:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006ea:	eb 22                	jmp    f010070e <cons_putc+0x3e7>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f01006ec:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f01006f1:	80 e4 0f             	and    $0xf,%ah
f01006f4:	80 cc 30             	or     $0x30,%ah
f01006f7:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
f01006fc:	eb 10                	jmp    f010070e <cons_putc+0x3e7>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f01006fe:	a1 00 e0 12 f0       	mov    0xf012e000,%eax
f0100703:	80 e4 0f             	and    $0xf,%ah
f0100706:	80 cc 70             	or     $0x70,%ah
f0100709:	a3 00 e0 12 f0       	mov    %eax,0xf012e000
						default:break;
					}
					Number = 0;
f010070e:	c7 05 3c 62 35 f0 00 	movl   $0x0,0xf035623c
f0100715:	00 00 00 
					State = 0;
f0100718:	c7 05 38 62 35 f0 00 	movl   $0x0,0xf0356238
f010071f:	00 00 00 
f0100722:	eb 2d                	jmp    f0100751 <cons_putc+0x42a>
					break;
				default:
					Number = Number * 10 + (c&0xff) - '0';
f0100724:	a1 3c 62 35 f0       	mov    0xf035623c,%eax
f0100729:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010072c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
f0100730:	a3 3c 62 35 f0       	mov    %eax,0xf035623c
f0100735:	eb 1a                	jmp    f0100751 <cons_putc+0x42a>
					break;
			}
		}
		else crt_buf[crt_pos++] = c;		/* write the character */
f0100737:	66 a1 34 62 35 f0    	mov    0xf0356234,%ax
f010073d:	0f b7 c8             	movzwl %ax,%ecx
f0100740:	8b 15 30 62 35 f0    	mov    0xf0356230,%edx
f0100746:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010074a:	40                   	inc    %eax
f010074b:	66 a3 34 62 35 f0    	mov    %ax,0xf0356234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100751:	66 81 3d 34 62 35 f0 	cmpw   $0x7cf,0xf0356234
f0100758:	cf 07 
f010075a:	76 40                	jbe    f010079c <cons_putc+0x475>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010075c:	a1 30 62 35 f0       	mov    0xf0356230,%eax
f0100761:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100768:	00 
f0100769:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010076f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100773:	89 04 24             	mov    %eax,(%esp)
f0100776:	e8 11 74 00 00       	call   f0107b8c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010077b:	8b 15 30 62 35 f0    	mov    0xf0356230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100781:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100786:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010078c:	40                   	inc    %eax
f010078d:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100792:	75 f2                	jne    f0100786 <cons_putc+0x45f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100794:	66 83 2d 34 62 35 f0 	subw   $0x50,0xf0356234
f010079b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010079c:	8b 0d 2c 62 35 f0    	mov    0xf035622c,%ecx
f01007a2:	b0 0e                	mov    $0xe,%al
f01007a4:	89 ca                	mov    %ecx,%edx
f01007a6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01007a7:	66 8b 35 34 62 35 f0 	mov    0xf0356234,%si
f01007ae:	8d 59 01             	lea    0x1(%ecx),%ebx
f01007b1:	89 f0                	mov    %esi,%eax
f01007b3:	66 c1 e8 08          	shr    $0x8,%ax
f01007b7:	89 da                	mov    %ebx,%edx
f01007b9:	ee                   	out    %al,(%dx)
f01007ba:	b0 0f                	mov    $0xf,%al
f01007bc:	89 ca                	mov    %ecx,%edx
f01007be:	ee                   	out    %al,(%dx)
f01007bf:	89 f0                	mov    %esi,%eax
f01007c1:	89 da                	mov    %ebx,%edx
f01007c3:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01007c4:	83 c4 2c             	add    $0x2c,%esp
f01007c7:	5b                   	pop    %ebx
f01007c8:	5e                   	pop    %esi
f01007c9:	5f                   	pop    %edi
f01007ca:	5d                   	pop    %ebp
f01007cb:	c3                   	ret    

f01007cc <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01007cc:	55                   	push   %ebp
f01007cd:	89 e5                	mov    %esp,%ebp
f01007cf:	53                   	push   %ebx
f01007d0:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007d3:	ba 64 00 00 00       	mov    $0x64,%edx
f01007d8:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01007d9:	0f b6 c0             	movzbl %al,%eax
f01007dc:	a8 01                	test   $0x1,%al
f01007de:	0f 84 e0 00 00 00    	je     f01008c4 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01007e4:	a8 20                	test   $0x20,%al
f01007e6:	0f 85 df 00 00 00    	jne    f01008cb <kbd_proc_data+0xff>
f01007ec:	b2 60                	mov    $0x60,%dl
f01007ee:	ec                   	in     (%dx),%al
f01007ef:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01007f1:	3c e0                	cmp    $0xe0,%al
f01007f3:	75 11                	jne    f0100806 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f01007f5:	83 0d 28 62 35 f0 40 	orl    $0x40,0xf0356228
		return 0;
f01007fc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100801:	e9 ca 00 00 00       	jmp    f01008d0 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100806:	84 c0                	test   %al,%al
f0100808:	79 33                	jns    f010083d <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010080a:	8b 0d 28 62 35 f0    	mov    0xf0356228,%ecx
f0100810:	f6 c1 40             	test   $0x40,%cl
f0100813:	75 05                	jne    f010081a <kbd_proc_data+0x4e>
f0100815:	88 c2                	mov    %al,%dl
f0100817:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010081a:	0f b6 d2             	movzbl %dl,%edx
f010081d:	8a 82 00 8a 10 f0    	mov    -0xfef7600(%edx),%al
f0100823:	83 c8 40             	or     $0x40,%eax
f0100826:	0f b6 c0             	movzbl %al,%eax
f0100829:	f7 d0                	not    %eax
f010082b:	21 c1                	and    %eax,%ecx
f010082d:	89 0d 28 62 35 f0    	mov    %ecx,0xf0356228
		return 0;
f0100833:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100838:	e9 93 00 00 00       	jmp    f01008d0 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f010083d:	8b 0d 28 62 35 f0    	mov    0xf0356228,%ecx
f0100843:	f6 c1 40             	test   $0x40,%cl
f0100846:	74 0e                	je     f0100856 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100848:	88 c2                	mov    %al,%dl
f010084a:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010084d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100850:	89 0d 28 62 35 f0    	mov    %ecx,0xf0356228
	}

	shift |= shiftcode[data];
f0100856:	0f b6 d2             	movzbl %dl,%edx
f0100859:	0f b6 82 00 8a 10 f0 	movzbl -0xfef7600(%edx),%eax
f0100860:	0b 05 28 62 35 f0    	or     0xf0356228,%eax
	shift ^= togglecode[data];
f0100866:	0f b6 8a 00 8b 10 f0 	movzbl -0xfef7500(%edx),%ecx
f010086d:	31 c8                	xor    %ecx,%eax
f010086f:	a3 28 62 35 f0       	mov    %eax,0xf0356228

	c = charcode[shift & (CTL | SHIFT)][data];
f0100874:	89 c1                	mov    %eax,%ecx
f0100876:	83 e1 03             	and    $0x3,%ecx
f0100879:	8b 0c 8d 00 8c 10 f0 	mov    -0xfef7400(,%ecx,4),%ecx
f0100880:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100884:	a8 08                	test   $0x8,%al
f0100886:	74 18                	je     f01008a0 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f0100888:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010088b:	83 fa 19             	cmp    $0x19,%edx
f010088e:	77 05                	ja     f0100895 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f0100890:	83 eb 20             	sub    $0x20,%ebx
f0100893:	eb 0b                	jmp    f01008a0 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f0100895:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100898:	83 fa 19             	cmp    $0x19,%edx
f010089b:	77 03                	ja     f01008a0 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f010089d:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01008a0:	f7 d0                	not    %eax
f01008a2:	a8 06                	test   $0x6,%al
f01008a4:	75 2a                	jne    f01008d0 <kbd_proc_data+0x104>
f01008a6:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01008ac:	75 22                	jne    f01008d0 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01008ae:	c7 04 24 10 8c 10 f0 	movl   $0xf0108c10,(%esp)
f01008b5:	e8 34 4f 00 00       	call   f01057ee <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008ba:	ba 92 00 00 00       	mov    $0x92,%edx
f01008bf:	b0 03                	mov    $0x3,%al
f01008c1:	ee                   	out    %al,(%dx)
f01008c2:	eb 0c                	jmp    f01008d0 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01008c4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01008c9:	eb 05                	jmp    f01008d0 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01008cb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01008d0:	89 d8                	mov    %ebx,%eax
f01008d2:	83 c4 14             	add    $0x14,%esp
f01008d5:	5b                   	pop    %ebx
f01008d6:	5d                   	pop    %ebp
f01008d7:	c3                   	ret    

f01008d8 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01008d8:	55                   	push   %ebp
f01008d9:	89 e5                	mov    %esp,%ebp
f01008db:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01008de:	80 3d 00 60 35 f0 00 	cmpb   $0x0,0xf0356000
f01008e5:	74 0a                	je     f01008f1 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01008e7:	b8 ca 02 10 f0       	mov    $0xf01002ca,%eax
f01008ec:	e8 f5 f9 ff ff       	call   f01002e6 <cons_intr>
}
f01008f1:	c9                   	leave  
f01008f2:	c3                   	ret    

f01008f3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01008f3:	55                   	push   %ebp
f01008f4:	89 e5                	mov    %esp,%ebp
f01008f6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01008f9:	b8 cc 07 10 f0       	mov    $0xf01007cc,%eax
f01008fe:	e8 e3 f9 ff ff       	call   f01002e6 <cons_intr>
}
f0100903:	c9                   	leave  
f0100904:	c3                   	ret    

f0100905 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100905:	55                   	push   %ebp
f0100906:	89 e5                	mov    %esp,%ebp
f0100908:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010090b:	e8 c8 ff ff ff       	call   f01008d8 <serial_intr>
	kbd_intr();
f0100910:	e8 de ff ff ff       	call   f01008f3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100915:	8b 15 20 62 35 f0    	mov    0xf0356220,%edx
f010091b:	3b 15 24 62 35 f0    	cmp    0xf0356224,%edx
f0100921:	74 22                	je     f0100945 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100923:	0f b6 82 20 60 35 f0 	movzbl -0xfca9fe0(%edx),%eax
f010092a:	42                   	inc    %edx
f010092b:	89 15 20 62 35 f0    	mov    %edx,0xf0356220
		if (cons.rpos == CONSBUFSIZE)
f0100931:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100937:	75 11                	jne    f010094a <cons_getc+0x45>
			cons.rpos = 0;
f0100939:	c7 05 20 62 35 f0 00 	movl   $0x0,0xf0356220
f0100940:	00 00 00 
f0100943:	eb 05                	jmp    f010094a <cons_getc+0x45>
		return c;
	}
	return 0;
f0100945:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010094a:	c9                   	leave  
f010094b:	c3                   	ret    

f010094c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010094c:	55                   	push   %ebp
f010094d:	89 e5                	mov    %esp,%ebp
f010094f:	57                   	push   %edi
f0100950:	56                   	push   %esi
f0100951:	53                   	push   %ebx
f0100952:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100955:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010095c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100963:	5a a5 
	if (*cp != 0xA55A) {
f0100965:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010096b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010096f:	74 11                	je     f0100982 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100971:	c7 05 2c 62 35 f0 b4 	movl   $0x3b4,0xf035622c
f0100978:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010097b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100980:	eb 16                	jmp    f0100998 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100982:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100989:	c7 05 2c 62 35 f0 d4 	movl   $0x3d4,0xf035622c
f0100990:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100993:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100998:	8b 0d 2c 62 35 f0    	mov    0xf035622c,%ecx
f010099e:	b0 0e                	mov    $0xe,%al
f01009a0:	89 ca                	mov    %ecx,%edx
f01009a2:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01009a3:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01009a6:	89 da                	mov    %ebx,%edx
f01009a8:	ec                   	in     (%dx),%al
f01009a9:	0f b6 f8             	movzbl %al,%edi
f01009ac:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01009af:	b0 0f                	mov    $0xf,%al
f01009b1:	89 ca                	mov    %ecx,%edx
f01009b3:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01009b4:	89 da                	mov    %ebx,%edx
f01009b6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01009b7:	89 35 30 62 35 f0    	mov    %esi,0xf0356230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01009bd:	0f b6 d8             	movzbl %al,%ebx
f01009c0:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01009c2:	66 89 3d 34 62 35 f0 	mov    %di,0xf0356234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01009c9:	e8 25 ff ff ff       	call   f01008f3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01009ce:	0f b7 05 e8 f1 14 f0 	movzwl 0xf014f1e8,%eax
f01009d5:	25 fd ff 00 00       	and    $0xfffd,%eax
f01009da:	89 04 24             	mov    %eax,(%esp)
f01009dd:	e8 ee 4c 00 00       	call   f01056d0 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01009e2:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01009e7:	b0 00                	mov    $0x0,%al
f01009e9:	89 da                	mov    %ebx,%edx
f01009eb:	ee                   	out    %al,(%dx)
f01009ec:	b2 fb                	mov    $0xfb,%dl
f01009ee:	b0 80                	mov    $0x80,%al
f01009f0:	ee                   	out    %al,(%dx)
f01009f1:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01009f6:	b0 0c                	mov    $0xc,%al
f01009f8:	89 ca                	mov    %ecx,%edx
f01009fa:	ee                   	out    %al,(%dx)
f01009fb:	b2 f9                	mov    $0xf9,%dl
f01009fd:	b0 00                	mov    $0x0,%al
f01009ff:	ee                   	out    %al,(%dx)
f0100a00:	b2 fb                	mov    $0xfb,%dl
f0100a02:	b0 03                	mov    $0x3,%al
f0100a04:	ee                   	out    %al,(%dx)
f0100a05:	b2 fc                	mov    $0xfc,%dl
f0100a07:	b0 00                	mov    $0x0,%al
f0100a09:	ee                   	out    %al,(%dx)
f0100a0a:	b2 f9                	mov    $0xf9,%dl
f0100a0c:	b0 01                	mov    $0x1,%al
f0100a0e:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100a0f:	b2 fd                	mov    $0xfd,%dl
f0100a11:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100a12:	3c ff                	cmp    $0xff,%al
f0100a14:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100a18:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100a1b:	a2 00 60 35 f0       	mov    %al,0xf0356000
f0100a20:	89 da                	mov    %ebx,%edx
f0100a22:	ec                   	in     (%dx),%al
f0100a23:	89 ca                	mov    %ecx,%edx
f0100a25:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100a26:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100a2a:	75 0c                	jne    f0100a38 <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f0100a2c:	c7 04 24 1c 8c 10 f0 	movl   $0xf0108c1c,(%esp)
f0100a33:	e8 b6 4d 00 00       	call   f01057ee <cprintf>
}
f0100a38:	83 c4 2c             	add    $0x2c,%esp
f0100a3b:	5b                   	pop    %ebx
f0100a3c:	5e                   	pop    %esi
f0100a3d:	5f                   	pop    %edi
f0100a3e:	5d                   	pop    %ebp
f0100a3f:	c3                   	ret    

f0100a40 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100a40:	55                   	push   %ebp
f0100a41:	89 e5                	mov    %esp,%ebp
f0100a43:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100a46:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a49:	e8 d9 f8 ff ff       	call   f0100327 <cons_putc>
}
f0100a4e:	c9                   	leave  
f0100a4f:	c3                   	ret    

f0100a50 <getchar>:

int
getchar(void)
{
f0100a50:	55                   	push   %ebp
f0100a51:	89 e5                	mov    %esp,%ebp
f0100a53:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100a56:	e8 aa fe ff ff       	call   f0100905 <cons_getc>
f0100a5b:	85 c0                	test   %eax,%eax
f0100a5d:	74 f7                	je     f0100a56 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100a5f:	c9                   	leave  
f0100a60:	c3                   	ret    

f0100a61 <iscons>:

int
iscons(int fdnum)
{
f0100a61:	55                   	push   %ebp
f0100a62:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100a64:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a69:	5d                   	pop    %ebp
f0100a6a:	c3                   	ret    
	...

f0100a6c <mon_stepi>:
        	return 0;
    }
}

int
mon_stepi(int argc, char **argv, struct Trapframe *tf){
f0100a6c:	55                   	push   %ebp
f0100a6d:	89 e5                	mov    %esp,%ebp
f0100a6f:	83 ec 18             	sub    $0x18,%esp
f0100a72:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!tf){cprintf("mon_stepi: No Trapframe!\n");return 0;}
f0100a75:	85 c0                	test   %eax,%eax
f0100a77:	75 13                	jne    f0100a8c <mon_stepi+0x20>
f0100a79:	c7 04 24 39 8c 10 f0 	movl   $0xf0108c39,(%esp)
f0100a80:	e8 69 4d 00 00       	call   f01057ee <cprintf>
f0100a85:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a8a:	eb 31                	jmp    f0100abd <mon_stepi+0x51>
    switch (tf->tf_trapno){
f0100a8c:	8b 50 28             	mov    0x28(%eax),%edx
f0100a8f:	83 fa 01             	cmp    $0x1,%edx
f0100a92:	74 13                	je     f0100aa7 <mon_stepi+0x3b>
f0100a94:	83 fa 03             	cmp    $0x3,%edx
f0100a97:	75 1f                	jne    f0100ab8 <mon_stepi+0x4c>
    	case T_BRKPT:tf->tf_eflags|=FL_TF;return -1;
f0100a99:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
f0100aa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100aa5:	eb 16                	jmp    f0100abd <mon_stepi+0x51>
    	case T_DEBUG:
        	if (tf->tf_eflags&FL_TF)return -1;
f0100aa7:	8b 40 38             	mov    0x38(%eax),%eax
f0100aaa:	25 00 01 00 00       	and    $0x100,%eax
    	default:
        	return 0;
f0100aaf:	83 f8 01             	cmp    $0x1,%eax
f0100ab2:	19 c0                	sbb    %eax,%eax
f0100ab4:	f7 d0                	not    %eax
f0100ab6:	eb 05                	jmp    f0100abd <mon_stepi+0x51>
f0100ab8:	b8 00 00 00 00       	mov    $0x0,%eax
    }    
}
f0100abd:	c9                   	leave  
f0100abe:	c3                   	ret    

f0100abf <mon_continue>:
	else cprintf(".\n");
	return 0;
}

int
mon_continue(int argc, char **argv, struct Trapframe *tf){
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
f0100ac2:	83 ec 18             	sub    $0x18,%esp
f0100ac5:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!tf){cprintf("mon_continue: No Trapframe!\n");return 0;}
f0100ac8:	85 c0                	test   %eax,%eax
f0100aca:	75 13                	jne    f0100adf <mon_continue+0x20>
f0100acc:	c7 04 24 53 8c 10 f0 	movl   $0xf0108c53,(%esp)
f0100ad3:	e8 16 4d 00 00       	call   f01057ee <cprintf>
f0100ad8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100add:	eb 2e                	jmp    f0100b0d <mon_continue+0x4e>
	switch (tf->tf_trapno){
f0100adf:	8b 50 28             	mov    0x28(%eax),%edx
f0100ae2:	83 fa 01             	cmp    $0x1,%edx
f0100ae5:	74 13                	je     f0100afa <mon_continue+0x3b>
f0100ae7:	83 fa 03             	cmp    $0x3,%edx
f0100aea:	75 1c                	jne    f0100b08 <mon_continue+0x49>
    	case T_BRKPT:
            tf->tf_eflags &= ~FL_TF;return -1;
f0100aec:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
f0100af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100af8:	eb 13                	jmp    f0100b0d <mon_continue+0x4e>
    	case T_DEBUG:
            tf->tf_eflags &= ~FL_TF;return -1;
f0100afa:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
f0100b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b06:	eb 05                	jmp    f0100b0d <mon_continue+0x4e>
    	default:
        	return 0;
f0100b08:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
f0100b0d:	c9                   	leave  
f0100b0e:	c3                   	ret    

f0100b0f <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100b0f:	55                   	push   %ebp
f0100b10:	89 e5                	mov    %esp,%ebp
f0100b12:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100b15:	c7 04 24 70 8c 10 f0 	movl   $0xf0108c70,(%esp)
f0100b1c:	e8 cd 4c 00 00       	call   f01057ee <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100b21:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100b28:	00 
f0100b29:	c7 04 24 c8 8e 10 f0 	movl   $0xf0108ec8,(%esp)
f0100b30:	e8 b9 4c 00 00       	call   f01057ee <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100b35:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100b3c:	00 
f0100b3d:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100b44:	f0 
f0100b45:	c7 04 24 f0 8e 10 f0 	movl   $0xf0108ef0,(%esp)
f0100b4c:	e8 9d 4c 00 00       	call   f01057ee <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100b51:	c7 44 24 08 2e 88 10 	movl   $0x10882e,0x8(%esp)
f0100b58:	00 
f0100b59:	c7 44 24 04 2e 88 10 	movl   $0xf010882e,0x4(%esp)
f0100b60:	f0 
f0100b61:	c7 04 24 14 8f 10 f0 	movl   $0xf0108f14,(%esp)
f0100b68:	e8 81 4c 00 00       	call   f01057ee <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100b6d:	c7 44 24 08 00 60 35 	movl   $0x356000,0x8(%esp)
f0100b74:	00 
f0100b75:	c7 44 24 04 00 60 35 	movl   $0xf0356000,0x4(%esp)
f0100b7c:	f0 
f0100b7d:	c7 04 24 38 8f 10 f0 	movl   $0xf0108f38,(%esp)
f0100b84:	e8 65 4c 00 00       	call   f01057ee <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100b89:	c7 44 24 08 08 80 39 	movl   $0x398008,0x8(%esp)
f0100b90:	00 
f0100b91:	c7 44 24 04 08 80 39 	movl   $0xf0398008,0x4(%esp)
f0100b98:	f0 
f0100b99:	c7 04 24 5c 8f 10 f0 	movl   $0xf0108f5c,(%esp)
f0100ba0:	e8 49 4c 00 00       	call   f01057ee <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100ba5:	b8 07 84 39 f0       	mov    $0xf0398407,%eax
f0100baa:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100baf:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100bb4:	89 c2                	mov    %eax,%edx
f0100bb6:	85 c0                	test   %eax,%eax
f0100bb8:	79 06                	jns    f0100bc0 <mon_kerninfo+0xb1>
f0100bba:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100bc0:	c1 fa 0a             	sar    $0xa,%edx
f0100bc3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100bc7:	c7 04 24 80 8f 10 f0 	movl   $0xf0108f80,(%esp)
f0100bce:	e8 1b 4c 00 00       	call   f01057ee <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100bd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bd8:	c9                   	leave  
f0100bd9:	c3                   	ret    

f0100bda <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100bda:	55                   	push   %ebp
f0100bdb:	89 e5                	mov    %esp,%ebp
f0100bdd:	56                   	push   %esi
f0100bde:	53                   	push   %ebx
f0100bdf:	83 ec 10             	sub    $0x10,%esp
f0100be2:	bb 04 9c 10 f0       	mov    $0xf0109c04,%ebx
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f0100be7:	be 94 9c 10 f0       	mov    $0xf0109c94,%esi
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100bec:	8b 03                	mov    (%ebx),%eax
f0100bee:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bf2:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bf9:	c7 04 24 89 8c 10 f0 	movl   $0xf0108c89,(%esp)
f0100c00:	e8 e9 4b 00 00       	call   f01057ee <cprintf>
f0100c05:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100c08:	39 f3                	cmp    %esi,%ebx
f0100c0a:	75 e0                	jne    f0100bec <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100c0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c11:	83 c4 10             	add    $0x10,%esp
f0100c14:	5b                   	pop    %ebx
f0100c15:	5e                   	pop    %esi
f0100c16:	5d                   	pop    %ebp
f0100c17:	c3                   	ret    

f0100c18 <mon_showvirtualmemory>:

    return 0;
}

int
mon_showvirtualmemory(int argc, char **argv, struct Trapframe *tf){
f0100c18:	55                   	push   %ebp
f0100c19:	89 e5                	mov    %esp,%ebp
f0100c1b:	57                   	push   %edi
f0100c1c:	56                   	push   %esi
f0100c1d:	53                   	push   %ebx
f0100c1e:	83 ec 2c             	sub    $0x2c,%esp
f0100c21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f0100c24:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100c28:	74 11                	je     f0100c3b <mon_showvirtualmemory+0x23>
		cprintf("mon_showvvirtualmemory: The number of parameters is two.\n");
f0100c2a:	c7 04 24 ac 8f 10 f0 	movl   $0xf0108fac,(%esp)
f0100c31:	e8 b8 4b 00 00       	call   f01057ee <cprintf>
		return 0;
f0100c36:	e9 37 01 00 00       	jmp    f0100d72 <mon_showvirtualmemory+0x15a>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0100c3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c42:	00 
f0100c43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c4a:	8b 43 04             	mov    0x4(%ebx),%eax
f0100c4d:	89 04 24             	mov    %eax,(%esp)
f0100c50:	e8 17 70 00 00       	call   f0107c6c <strtol>
f0100c55:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0100c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c5a:	80 38 00             	cmpb   $0x0,(%eax)
f0100c5d:	74 11                	je     f0100c70 <mon_showvirtualmemory+0x58>
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
f0100c5f:	c7 04 24 e8 8f 10 f0 	movl   $0xf0108fe8,(%esp)
f0100c66:	e8 83 4b 00 00       	call   f01057ee <cprintf>
		return 0;
f0100c6b:	e9 02 01 00 00       	jmp    f0100d72 <mon_showvirtualmemory+0x15a>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100c70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c77:	00 
f0100c78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c82:	89 04 24             	mov    %eax,(%esp)
f0100c85:	e8 e2 6f 00 00       	call   f0107c6c <strtol>
	if (*errChar){
f0100c8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c8d:	80 3a 00             	cmpb   $0x0,(%edx)
f0100c90:	74 11                	je     f0100ca3 <mon_showvirtualmemory+0x8b>
		cprintf("mon_showvvirtualmemory: The second argument is not a number.\n");
f0100c92:	c7 04 24 28 90 10 f0 	movl   $0xf0109028,(%esp)
f0100c99:	e8 50 4b 00 00       	call   f01057ee <cprintf>
		return 0;
f0100c9e:	e9 cf 00 00 00       	jmp    f0100d72 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr&0x3){
f0100ca3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0100ca9:	74 11                	je     f0100cbc <mon_showvirtualmemory+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f0100cab:	c7 04 24 68 90 10 f0 	movl   $0xf0109068,(%esp)
f0100cb2:	e8 37 4b 00 00       	call   f01057ee <cprintf>
		return 0;
f0100cb7:	e9 b6 00 00 00       	jmp    f0100d72 <mon_showvirtualmemory+0x15a>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100cbc:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3){
f0100cbe:	a8 03                	test   $0x3,%al
f0100cc0:	74 11                	je     f0100cd3 <mon_showvirtualmemory+0xbb>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0100cc2:	c7 04 24 a4 90 10 f0 	movl   $0xf01090a4,(%esp)
f0100cc9:	e8 20 4b 00 00       	call   f01057ee <cprintf>
		return 0;
f0100cce:	e9 9f 00 00 00       	jmp    f0100d72 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr > EndAddr){
f0100cd3:	39 c6                	cmp    %eax,%esi
f0100cd5:	0f 86 88 00 00 00    	jbe    f0100d63 <mon_showvirtualmemory+0x14b>
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
f0100cdb:	c7 04 24 e0 90 10 f0 	movl   $0xf01090e0,(%esp)
f0100ce2:	e8 07 4b 00 00       	call   f01057ee <cprintf>
		return 0;
f0100ce7:	e9 86 00 00 00       	jmp    f0100d72 <mon_showvirtualmemory+0x15a>
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
		switch (c){
f0100cec:	83 fe 01             	cmp    $0x1,%esi
f0100cef:	74 2f                	je     f0100d20 <mon_showvirtualmemory+0x108>
f0100cf1:	83 fe 01             	cmp    $0x1,%esi
f0100cf4:	7f 06                	jg     f0100cfc <mon_showvirtualmemory+0xe4>
f0100cf6:	85 f6                	test   %esi,%esi
f0100cf8:	74 0e                	je     f0100d08 <mon_showvirtualmemory+0xf0>
f0100cfa:	eb 5e                	jmp    f0100d5a <mon_showvirtualmemory+0x142>
f0100cfc:	83 fe 02             	cmp    $0x2,%esi
f0100cff:	74 33                	je     f0100d34 <mon_showvirtualmemory+0x11c>
f0100d01:	83 fe 03             	cmp    $0x3,%esi
f0100d04:	75 54                	jne    f0100d5a <mon_showvirtualmemory+0x142>
f0100d06:	eb 40                	jmp    f0100d48 <mon_showvirtualmemory+0x130>
			case 0:cprintf("0x%08x   :0x%08x    ",Address,*(int*)Address);break;
f0100d08:	8b 03                	mov    (%ebx),%eax
f0100d0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d12:	c7 04 24 92 8c 10 f0 	movl   $0xf0108c92,(%esp)
f0100d19:	e8 d0 4a 00 00       	call   f01057ee <cprintf>
f0100d1e:	eb 3a                	jmp    f0100d5a <mon_showvirtualmemory+0x142>
			case 1:cprintf("0x%08x    ",*(int*)Address);break;
f0100d20:	8b 03                	mov    (%ebx),%eax
f0100d22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d26:	c7 04 24 9c 8c 10 f0 	movl   $0xf0108c9c,(%esp)
f0100d2d:	e8 bc 4a 00 00       	call   f01057ee <cprintf>
f0100d32:	eb 26                	jmp    f0100d5a <mon_showvirtualmemory+0x142>
			case 2:cprintf("0x%08x    ",*(int*)Address);break;
f0100d34:	8b 03                	mov    (%ebx),%eax
f0100d36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d3a:	c7 04 24 9c 8c 10 f0 	movl   $0xf0108c9c,(%esp)
f0100d41:	e8 a8 4a 00 00       	call   f01057ee <cprintf>
f0100d46:	eb 12                	jmp    f0100d5a <mon_showvirtualmemory+0x142>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
f0100d48:	8b 03                	mov    (%ebx),%eax
f0100d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d4e:	c7 04 24 35 ac 10 f0 	movl   $0xf010ac35,(%esp)
f0100d55:	e8 94 4a 00 00       	call   f01057ee <cprintf>
		}
		c = (c+1)&3;
f0100d5a:	46                   	inc    %esi
f0100d5b:	83 e6 03             	and    $0x3,%esi
	if (StartAddr > EndAddr){
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100d5e:	83 c3 04             	add    $0x4,%ebx
f0100d61:	eb 07                	jmp    f0100d6a <mon_showvirtualmemory+0x152>
	}
	if (EndAddr&0x3){
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
f0100d63:	89 f3                	mov    %esi,%ebx
f0100d65:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100d6a:	39 fb                	cmp    %edi,%ebx
f0100d6c:	0f 82 7a ff ff ff    	jb     f0100cec <mon_showvirtualmemory+0xd4>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
		}
		c = (c+1)&3;
	}
	return 0;
}
f0100d72:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d77:	83 c4 2c             	add    $0x2c,%esp
f0100d7a:	5b                   	pop    %ebx
f0100d7b:	5e                   	pop    %esi
f0100d7c:	5f                   	pop    %edi
f0100d7d:	5d                   	pop    %ebp
f0100d7e:	c3                   	ret    

f0100d7f <mon_va2pa>:
int
mon_va2pa(int argc, char **argv, struct Trapframe *tf){
f0100d7f:	55                   	push   %ebp
f0100d80:	89 e5                	mov    %esp,%ebp
f0100d82:	83 ec 28             	sub    $0x28,%esp
	if(argc!=2){
f0100d85:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100d89:	74 11                	je     f0100d9c <mon_va2pa+0x1d>
		cprintf("mon_va2pa: The number of parameters is one.\n");
f0100d8b:	c7 04 24 34 91 10 f0 	movl   $0xf0109134,(%esp)
f0100d92:	e8 57 4a 00 00       	call   f01057ee <cprintf>
		return 0;
f0100d97:	e9 cc 00 00 00       	jmp    f0100e68 <mon_va2pa+0xe9>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100d9c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100da3:	00 
f0100da4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100da7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dae:	8b 40 04             	mov    0x4(%eax),%eax
f0100db1:	89 04 24             	mov    %eax,(%esp)
f0100db4:	e8 b3 6e 00 00       	call   f0107c6c <strtol>
	if (*errChar){
f0100db9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100dbc:	80 3a 00             	cmpb   $0x0,(%edx)
f0100dbf:	74 11                	je     f0100dd2 <mon_va2pa+0x53>
		cprintf("mon_va2pa: The argument is not a number.\n");
f0100dc1:	c7 04 24 64 91 10 f0 	movl   $0xf0109164,(%esp)
f0100dc8:	e8 21 4a 00 00       	call   f01057ee <cprintf>
		return 0;
f0100dcd:	e9 96 00 00 00       	jmp    f0100e68 <mon_va2pa+0xe9>
	}
	pde_t *pde = &kern_pgdir[PDX(Address)];
f0100dd2:	89 c1                	mov    %eax,%ecx
f0100dd4:	c1 e9 16             	shr    $0x16,%ecx
	if (*pde & PTE_P){
f0100dd7:	8b 15 8c 6e 35 f0    	mov    0xf0356e8c,%edx
f0100ddd:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0100de0:	f6 c2 01             	test   $0x1,%dl
f0100de3:	74 77                	je     f0100e5c <mon_va2pa+0xdd>
		pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0100de5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100deb:	89 d1                	mov    %edx,%ecx
f0100ded:	c1 e9 0c             	shr    $0xc,%ecx
f0100df0:	3b 0d 88 6e 35 f0    	cmp    0xf0356e88,%ecx
f0100df6:	72 20                	jb     f0100e18 <mon_va2pa+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100df8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100dfc:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0100e03:	f0 
f0100e04:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0100e0b:	00 
f0100e0c:	c7 04 24 a7 8c 10 f0 	movl   $0xf0108ca7,(%esp)
f0100e13:	e8 28 f2 ff ff       	call   f0100040 <_panic>
f0100e18:	89 c1                	mov    %eax,%ecx
f0100e1a:	c1 e9 0c             	shr    $0xc,%ecx
f0100e1d:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		if (*pte & PTE_P){
f0100e23:	8b 94 8a 00 00 00 f0 	mov    -0x10000000(%edx,%ecx,4),%edx
f0100e2a:	f6 c2 01             	test   $0x1,%dl
f0100e2d:	74 1f                	je     f0100e4e <mon_va2pa+0xcf>
			cprintf("The physical address is 0x%08x.\n",PTE_ADDR(*pte)|(Address&0x3ff));
f0100e2f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100e35:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100e3a:	09 d0                	or     %edx,%eax
f0100e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e40:	c7 04 24 90 91 10 f0 	movl   $0xf0109190,(%esp)
f0100e47:	e8 a2 49 00 00       	call   f01057ee <cprintf>
f0100e4c:	eb 1a                	jmp    f0100e68 <mon_va2pa+0xe9>
		}
		else 
			cprintf("This is not a valid virtual address.\n");
f0100e4e:	c7 04 24 b4 91 10 f0 	movl   $0xf01091b4,(%esp)
f0100e55:	e8 94 49 00 00       	call   f01057ee <cprintf>
f0100e5a:	eb 0c                	jmp    f0100e68 <mon_va2pa+0xe9>
	}
	else 
		cprintf("This is not a valid virtual address.\n");
f0100e5c:	c7 04 24 b4 91 10 f0 	movl   $0xf01091b4,(%esp)
f0100e63:	e8 86 49 00 00       	call   f01057ee <cprintf>
	return 0;
}
f0100e68:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e6d:	c9                   	leave  
f0100e6e:	c3                   	ret    

f0100e6f <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100e6f:	55                   	push   %ebp
f0100e70:	89 e5                	mov    %esp,%ebp
f0100e72:	57                   	push   %edi
f0100e73:	56                   	push   %esi
f0100e74:	53                   	push   %ebx
f0100e75:	83 ec 6c             	sub    $0x6c,%esp
	cprintf("\033[34;45mThe parameters are: 34 and 45\n");
	cprintf("\033[35;46mThe parameters are: 35 and 46\n");
	cprintf("\033[36;47mThe parameters are: 36 and 47\n");
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
f0100e78:	c7 04 24 b6 8c 10 f0 	movl   $0xf0108cb6,(%esp)
f0100e7f:	e8 6a 49 00 00       	call   f01057ee <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100e84:	89 eb                	mov    %ebp,%ebx
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
		eip = *((uint32_t *) ebp + 1);
		debuginfo_eip(eip, &info);
f0100e86:	8d 7d d0             	lea    -0x30(%ebp),%edi
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100e89:	eb 6d                	jmp    f0100ef8 <mon_backtrace+0x89>
		eip = *((uint32_t *) ebp + 1);
f0100e8b:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f0100e8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e92:	89 34 24             	mov    %esi,(%esp)
f0100e95:	e8 b3 61 00 00       	call   f010704d <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n         %s:%d: %.*s+%d\n",
f0100e9a:	89 f0                	mov    %esi,%eax
f0100e9c:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100e9f:	89 44 24 30          	mov    %eax,0x30(%esp)
f0100ea3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ea6:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100eaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ead:	89 44 24 28          	mov    %eax,0x28(%esp)
f0100eb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100eb4:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100eb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ebb:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100ebf:	8b 43 18             	mov    0x18(%ebx),%eax
f0100ec2:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100ec6:	8b 43 14             	mov    0x14(%ebx),%eax
f0100ec9:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100ecd:	8b 43 10             	mov    0x10(%ebx),%eax
f0100ed0:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100ed4:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100edb:	8b 43 08             	mov    0x8(%ebx),%eax
f0100ede:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee2:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100ee6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100eea:	c7 04 24 dc 91 10 f0 	movl   $0xf01091dc,(%esp)
f0100ef1:	e8 f8 48 00 00       	call   f01057ee <cprintf>
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100ef6:	8b 1b                	mov    (%ebx),%ebx
f0100ef8:	85 db                	test   %ebx,%ebx
f0100efa:	75 8f                	jne    f0100e8b <mon_backtrace+0x1c>
				info.eip_fn_namelen,
				info.eip_fn_name,
				eip - info.eip_fn_addr);
	}
	return 0;
}
f0100efc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f01:	83 c4 6c             	add    $0x6c,%esp
f0100f04:	5b                   	pop    %ebx
f0100f05:	5e                   	pop    %esi
f0100f06:	5f                   	pop    %edi
f0100f07:	5d                   	pop    %ebp
f0100f08:	c3                   	ret    

f0100f09 <mon_pa2va>:
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100f09:	55                   	push   %ebp
f0100f0a:	89 e5                	mov    %esp,%ebp
f0100f0c:	57                   	push   %edi
f0100f0d:	56                   	push   %esi
f0100f0e:	53                   	push   %ebx
f0100f0f:	83 ec 3c             	sub    $0x3c,%esp
	if(argc!=2){
f0100f12:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100f16:	74 11                	je     f0100f29 <mon_pa2va+0x20>
		cprintf("mon_pa2va: The number of parameters is one.\n");
f0100f18:	c7 04 24 2c 92 10 f0 	movl   $0xf010922c,(%esp)
f0100f1f:	e8 ca 48 00 00       	call   f01057ee <cprintf>
		return 0;
f0100f24:	e9 34 01 00 00       	jmp    f010105d <mon_pa2va+0x154>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100f29:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f30:	00 
f0100f31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f3b:	8b 40 04             	mov    0x4(%eax),%eax
f0100f3e:	89 04 24             	mov    %eax,(%esp)
f0100f41:	e8 26 6d 00 00       	call   f0107c6c <strtol>
f0100f46:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (*errChar){
f0100f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f4c:	80 38 00             	cmpb   $0x0,(%eax)
f0100f4f:	74 11                	je     f0100f62 <mon_pa2va+0x59>
		cprintf("mon_pa2va: The argument is not a number.\n");
f0100f51:	c7 04 24 5c 92 10 f0 	movl   $0xf010925c,(%esp)
f0100f58:	e8 91 48 00 00       	call   f01057ee <cprintf>
		return 0;
f0100f5d:	e9 fb 00 00 00       	jmp    f010105d <mon_pa2va+0x154>
		cprintf("mon_pa2va: The number of parameters is one.\n");
		return 0;
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
	if (*errChar){
f0100f62:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0100f69:	bf 00 00 00 00       	mov    $0x0,%edi
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100f6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f71:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100f76:	89 45 cc             	mov    %eax,-0x34(%ebp)
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100f79:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100f7c:	c1 e6 02             	shl    $0x2,%esi
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
f0100f7f:	03 35 8c 6e 35 f0    	add    0xf0356e8c,%esi
		if (*pde & PTE_P){
f0100f85:	f6 06 01             	testb  $0x1,(%esi)
f0100f88:	0f 84 a1 00 00 00    	je     f010102f <mon_pa2va+0x126>
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100f8e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100f91:	c1 e0 16             	shl    $0x16,%eax
f0100f94:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f97:	bb 00 00 00 00       	mov    $0x0,%ebx
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
f0100f9c:	8b 06                	mov    (%esi),%eax
f0100f9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fa3:	89 c2                	mov    %eax,%edx
f0100fa5:	c1 ea 0c             	shr    $0xc,%edx
f0100fa8:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f0100fae:	72 20                	jb     f0100fd0 <mon_pa2va+0xc7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb4:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0100fbb:	f0 
f0100fbc:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0100fc3:	00 
f0100fc4:	c7 04 24 a7 8c 10 f0 	movl   $0xf0108ca7,(%esp)
f0100fcb:	e8 70 f0 ff ff       	call   f0100040 <_panic>
				if (*pte & PTE_P){
f0100fd0:	8b 84 98 00 00 00 f0 	mov    -0x10000000(%eax,%ebx,4),%eax
f0100fd7:	a8 01                	test   $0x1,%al
f0100fd9:	74 47                	je     f0101022 <mon_pa2va+0x119>
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
f0100fdb:	33 45 d4             	xor    -0x2c(%ebp),%eax
f0100fde:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
f0100fe3:	75 3d                	jne    f0101022 <mon_pa2va+0x119>
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100fe5:	85 ff                	test   %edi,%edi
f0100fe7:	75 1d                	jne    f0101006 <mon_pa2va+0xfd>
f0100fe9:	89 d8                	mov    %ebx,%eax
f0100feb:	c1 e0 0c             	shl    $0xc,%eax
f0100fee:	0b 45 d0             	or     -0x30(%ebp),%eax
f0100ff1:	0b 45 cc             	or     -0x34(%ebp),%eax
f0100ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ff8:	c7 04 24 88 92 10 f0 	movl   $0xf0109288,(%esp)
f0100fff:	e8 ea 47 00 00       	call   f01057ee <cprintf>
f0101004:	eb 1b                	jmp    f0101021 <mon_pa2va+0x118>
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0101006:	89 d8                	mov    %ebx,%eax
f0101008:	c1 e0 0c             	shl    $0xc,%eax
f010100b:	0b 45 d0             	or     -0x30(%ebp),%eax
f010100e:	0b 45 cc             	or     -0x34(%ebp),%eax
f0101011:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101015:	c7 04 24 c7 8c 10 f0 	movl   $0xf0108cc7,(%esp)
f010101c:	e8 cd 47 00 00       	call   f01057ee <cprintf>
						cnt++;
f0101021:	47                   	inc    %edi
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
f0101022:	43                   	inc    %ebx
f0101023:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0101029:	0f 85 6d ff ff ff    	jne    f0100f9c <mon_pa2va+0x93>
	if (*errChar){
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
f010102f:	ff 45 c8             	incl   -0x38(%ebp)
f0101032:	81 7d c8 00 04 00 00 	cmpl   $0x400,-0x38(%ebp)
f0101039:	0f 85 3a ff ff ff    	jne    f0100f79 <mon_pa2va+0x70>
					}
				}
			}
		}
	}
	if (cnt == 0)
f010103f:	85 ff                	test   %edi,%edi
f0101041:	75 0e                	jne    f0101051 <mon_pa2va+0x148>
		cprintf("There is no virtual address.\n");
f0101043:	c7 04 24 cf 8c 10 f0 	movl   $0xf0108ccf,(%esp)
f010104a:	e8 9f 47 00 00       	call   f01057ee <cprintf>
f010104f:	eb 0c                	jmp    f010105d <mon_pa2va+0x154>
	else cprintf(".\n");
f0101051:	c7 04 24 ea 8c 10 f0 	movl   $0xf0108cea,(%esp)
f0101058:	e8 91 47 00 00       	call   f01057ee <cprintf>
	return 0;
}
f010105d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101062:	83 c4 3c             	add    $0x3c,%esp
f0101065:	5b                   	pop    %ebx
f0101066:	5e                   	pop    %esi
f0101067:	5f                   	pop    %edi
f0101068:	5d                   	pop    %ebp
f0101069:	c3                   	ret    

f010106a <mon_showmappings>:
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f010106a:	55                   	push   %ebp
f010106b:	89 e5                	mov    %esp,%ebp
f010106d:	57                   	push   %edi
f010106e:	56                   	push   %esi
f010106f:	53                   	push   %ebx
f0101070:	83 ec 3c             	sub    $0x3c,%esp
f0101073:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f0101076:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010107a:	74 11                	je     f010108d <mon_showmappings+0x23>
		cprintf("mon_showmappings: The number of parameters is two.\n");
f010107c:	c7 04 24 ac 92 10 f0 	movl   $0xf01092ac,(%esp)
f0101083:	e8 66 47 00 00       	call   f01057ee <cprintf>
		return 0;
f0101088:	e9 9d 01 00 00       	jmp    f010122a <mon_showmappings+0x1c0>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f010108d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101094:	00 
f0101095:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101098:	89 44 24 04          	mov    %eax,0x4(%esp)
f010109c:	8b 43 04             	mov    0x4(%ebx),%eax
f010109f:	89 04 24             	mov    %eax,(%esp)
f01010a2:	e8 c5 6b 00 00       	call   f0107c6c <strtol>
f01010a7:	89 c6                	mov    %eax,%esi
	if (*errChar){
f01010a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010ac:	80 38 00             	cmpb   $0x0,(%eax)
f01010af:	74 11                	je     f01010c2 <mon_showmappings+0x58>
		cprintf("mon_showmappings: The first argument is not a number.\n");
f01010b1:	c7 04 24 e0 92 10 f0 	movl   $0xf01092e0,(%esp)
f01010b8:	e8 31 47 00 00       	call   f01057ee <cprintf>
		return 0;
f01010bd:	e9 68 01 00 00       	jmp    f010122a <mon_showmappings+0x1c0>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f01010c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01010c9:	00 
f01010ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01010cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010d1:	8b 43 08             	mov    0x8(%ebx),%eax
f01010d4:	89 04 24             	mov    %eax,(%esp)
f01010d7:	e8 90 6b 00 00       	call   f0107c6c <strtol>
	if (*errChar){
f01010dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01010df:	80 3a 00             	cmpb   $0x0,(%edx)
f01010e2:	74 11                	je     f01010f5 <mon_showmappings+0x8b>
		cprintf("mon_showmappings: The second argument is not a number.\n");
f01010e4:	c7 04 24 18 93 10 f0 	movl   $0xf0109318,(%esp)
f01010eb:	e8 fe 46 00 00       	call   f01057ee <cprintf>
		return 0;
f01010f0:	e9 35 01 00 00       	jmp    f010122a <mon_showmappings+0x1c0>
	}
	if (StartAddr&0x3ff){
f01010f5:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f01010fb:	74 11                	je     f010110e <mon_showmappings+0xa4>
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
f01010fd:	c7 04 24 50 93 10 f0 	movl   $0xf0109350,(%esp)
f0101104:	e8 e5 46 00 00       	call   f01057ee <cprintf>
		return 0;
f0101109:	e9 1c 01 00 00       	jmp    f010122a <mon_showmappings+0x1c0>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showmappings: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f010110e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	}
	if (StartAddr&0x3ff){
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0101111:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0101116:	74 11                	je     f0101129 <mon_showmappings+0xbf>
		cprintf("mon_showmappings: The second parameter is not aligned.\n");
f0101118:	c7 04 24 88 93 10 f0 	movl   $0xf0109388,(%esp)
f010111f:	e8 ca 46 00 00       	call   f01057ee <cprintf>
		return 0;
f0101124:	e9 01 01 00 00       	jmp    f010122a <mon_showmappings+0x1c0>
	}
	if (StartAddr > EndAddr){
f0101129:	39 c6                	cmp    %eax,%esi
f010112b:	76 11                	jbe    f010113e <mon_showmappings+0xd4>
		cprintf("mon_shopmappings: The first parameter is larger than the second parameter.\n");
f010112d:	c7 04 24 c0 93 10 f0 	movl   $0xf01093c0,(%esp)
f0101134:	e8 b5 46 00 00       	call   f01057ee <cprintf>
		return 0;
f0101139:	e9 ec 00 00 00       	jmp    f010122a <mon_showmappings+0x1c0>
	}

    cprintf(
f010113e:	c7 04 24 0c 94 10 f0 	movl   $0xf010940c,(%esp)
f0101145:	e8 a4 46 00 00       	call   f01057ee <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f010114a:	89 f3                	mov    %esi,%ebx
f010114c:	e9 d0 00 00 00       	jmp    f0101221 <mon_showmappings+0x1b7>
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0101151:	89 da                	mov    %ebx,%edx
f0101153:	c1 ea 16             	shr    $0x16,%edx
		if (*pde & PTE_P){
f0101156:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010115b:	8b 04 90             	mov    (%eax,%edx,4),%eax
f010115e:	a8 01                	test   $0x1,%al
f0101160:	0f 84 a5 00 00 00    	je     f010120b <mon_showmappings+0x1a1>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0101166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010116b:	89 c2                	mov    %eax,%edx
f010116d:	c1 ea 0c             	shr    $0xc,%edx
f0101170:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f0101176:	72 20                	jb     f0101198 <mon_showmappings+0x12e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101178:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010117c:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0101183:	f0 
f0101184:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f010118b:	00 
f010118c:	c7 04 24 a7 8c 10 f0 	movl   $0xf0108ca7,(%esp)
f0101193:	e8 a8 ee ff ff       	call   f0100040 <_panic>
f0101198:	89 da                	mov    %ebx,%edx
f010119a:	c1 ea 0a             	shr    $0xa,%edx
f010119d:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f01011a3:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f01011aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if (*pte & PTE_P){
f01011ad:	8b 10                	mov    (%eax),%edx
f01011af:	f6 c2 01             	test   $0x1,%dl
f01011b2:	74 57                	je     f010120b <mon_showmappings+0x1a1>
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f01011b4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01011ba:	b8 08 00 00 00       	mov    $0x8,%eax
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f01011bf:	bf 08 00 00 00       	mov    $0x8,%edi
f01011c4:	89 fe                	mov    %edi,%esi
f01011c6:	29 c6                	sub    %eax,%esi
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
					permission[i] = Bit2Sign[8-i][(perm&1)];
f01011c8:	89 d1                	mov    %edx,%ecx
f01011ca:	83 e1 01             	and    $0x1,%ecx
f01011cd:	8a 8c 71 e4 9b 10 f0 	mov    -0xfef641c(%ecx,%esi,2),%cl
f01011d4:	88 4c 05 da          	mov    %cl,-0x26(%ebp,%eax,1)
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f01011d8:	48                   	dec    %eax
f01011d9:	d1 fa                	sar    %edx
f01011db:	83 f8 ff             	cmp    $0xffffffff,%eax
f01011de:	75 e4                	jne    f01011c4 <mon_showmappings+0x15a>
					permission[i] = Bit2Sign[8-i][(perm&1)];
				}
				permission[9]='\0';
f01011e0:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
				cprintf("0x%08x             0x%08x             %s\n",Address,PTE_ADDR(*pte),permission);
f01011e4:	8d 45 da             	lea    -0x26(%ebp),%eax
f01011e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01011ee:	8b 02                	mov    (%edx),%eax
f01011f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011fd:	c7 04 24 40 95 10 f0 	movl   $0xf0109540,(%esp)
f0101204:	e8 e5 45 00 00       	call   f01057ee <cprintf>
				continue;
f0101209:	eb 10                	jmp    f010121b <mon_showmappings+0x1b1>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
f010120b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010120f:	c7 04 24 6c 95 10 f0 	movl   $0xf010956c,(%esp)
f0101216:	e8 d3 45 00 00       	call   f01057ee <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f010121b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101221:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0101224:	0f 82 27 ff ff ff    	jb     f0101151 <mon_showmappings+0xe7>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}
f010122a:	b8 00 00 00 00       	mov    $0x0,%eax
f010122f:	83 c4 3c             	add    $0x3c,%esp
f0101232:	5b                   	pop    %ebx
f0101233:	5e                   	pop    %esi
f0101234:	5f                   	pop    %edi
f0101235:	5d                   	pop    %ebp
f0101236:	c3                   	ret    

f0101237 <disassemble>:
// #include <stdlib.h>
#include <inc/string.h>

unsigned int disassemble(unsigned char *bytes, unsigned int max, int offset, char *output);

unsigned int disassemble(unsigned char *bytes, unsigned int max, int offset, char *output) {
f0101237:	55                   	push   %ebp
f0101238:	89 e5                	mov    %esp,%ebp
f010123a:	57                   	push   %edi
f010123b:	56                   	push   %esi
f010123c:	53                   	push   %ebx
f010123d:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f0101243:	8b 45 08             	mov    0x8(%ebp),%eax
f0101246:	8a 00                	mov    (%eax),%al
f0101248:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)

	INSTRUCTION *instructions= standard_instructions;
	if (opcode == 0x0F) { // Extended opcodes
f010124e:	3c 0f                	cmp    $0xf,%al
f0101250:	74 11                	je     f0101263 <disassemble+0x2c>
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f0101252:	8b 55 08             	mov    0x8(%ebp),%edx
f0101255:	42                   	inc    %edx
f0101256:	89 95 e4 fd ff ff    	mov    %edx,-0x21c(%ebp)

	INSTRUCTION *instructions= standard_instructions;
f010125c:	b9 20 e3 12 f0       	mov    $0xf012e320,%ecx
f0101261:	eb 4c                	jmp    f01012af <disassemble+0x78>
	if (opcode == 0x0F) { // Extended opcodes
		if (max < 2 || *bytes == 0x0F || *bytes == 0xA6 || *bytes == 0xA7 || *bytes == 0xF7 || *bytes == 0xFF) {
f0101263:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0101267:	0f 86 4d 08 00 00    	jbe    f0101aba <disassemble+0x883>
f010126d:	8b 55 08             	mov    0x8(%ebp),%edx
f0101270:	8a 42 01             	mov    0x1(%edx),%al
f0101273:	3c 0f                	cmp    $0xf,%al
f0101275:	0f 84 39 08 00 00    	je     f0101ab4 <disassemble+0x87d>
f010127b:	3c a6                	cmp    $0xa6,%al
f010127d:	0f 84 37 08 00 00    	je     f0101aba <disassemble+0x883>
f0101283:	3c a7                	cmp    $0xa7,%al
f0101285:	0f 84 2f 08 00 00    	je     f0101aba <disassemble+0x883>
f010128b:	3c f7                	cmp    $0xf7,%al
f010128d:	0f 84 27 08 00 00    	je     f0101aba <disassemble+0x883>
f0101293:	3c ff                	cmp    $0xff,%al
f0101295:	0f 84 1f 08 00 00    	je     f0101aba <disassemble+0x883>
			goto ILLEGAL;
		}

		instructions = extended_instructions;
		opcode = *bytes++;
f010129b:	83 c2 02             	add    $0x2,%edx
f010129e:	89 95 e4 fd ff ff    	mov    %edx,-0x21c(%ebp)
f01012a4:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)
	if (opcode == 0x0F) { // Extended opcodes
		if (max < 2 || *bytes == 0x0F || *bytes == 0xA6 || *bytes == 0xA7 || *bytes == 0xF7 || *bytes == 0xFF) {
			goto ILLEGAL;
		}

		instructions = extended_instructions;
f01012aa:	b9 20 e9 13 f0       	mov    $0xf013e920,%ecx
		opcode = *bytes++;
	}

	if (!instructions[opcode].hasModRM) {
f01012af:	0f b6 85 e3 fd ff ff 	movzbl -0x21d(%ebp),%eax
f01012b6:	89 c2                	mov    %eax,%edx
f01012b8:	c1 e2 06             	shl    $0x6,%edx
f01012bb:	01 c2                	add    %eax,%edx
f01012bd:	8d 04 50             	lea    (%eax,%edx,2),%eax
f01012c0:	8d 3c 41             	lea    (%ecx,%eax,2),%edi
f01012c3:	80 3f 00             	cmpb   $0x0,(%edi)
f01012c6:	0f 84 02 04 00 00    	je     f01016ce <disassemble+0x497>
	}

	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f01012cc:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f01012d2:	8a 02                	mov    (%edx),%al
f01012d4:	88 c3                	mov    %al,%bl
f01012d6:	c0 eb 06             	shr    $0x6,%bl
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
f01012d9:	88 c2                	mov    %al,%dl
f01012db:	c0 ea 03             	shr    $0x3,%dl
f01012de:	83 e2 07             	and    $0x7,%edx
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f01012e1:	83 e0 07             	and    $0x7,%eax
f01012e4:	88 85 dc fd ff ff    	mov    %al,-0x224(%ebp)
f01012ea:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f01012f0:	46                   	inc    %esi

	switch (instructions[opcode].size) {
f01012f1:	8a 47 01             	mov    0x1(%edi),%al
f01012f4:	3c 14                	cmp    $0x14,%al
f01012f6:	74 25                	je     f010131d <disassemble+0xe6>
f01012f8:	3c 15                	cmp    $0x15,%al
f01012fa:	75 42                	jne    f010133e <disassemble+0x107>
		case WORD:
			strcpy(R_output, register_mnemonics16[(int)modRM_reg]);
f01012fc:	0f be d2             	movsbl %dl,%edx
f01012ff:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101302:	8d 84 80 20 ef 14 f0 	lea    -0xfeb10e0(%eax,%eax,4),%eax
f0101309:	89 44 24 04          	mov    %eax,0x4(%esp)
f010130d:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101313:	89 04 24             	mov    %eax,(%esp)
f0101316:	e8 f8 66 00 00       	call   f0107a13 <strcpy>
			break;
f010131b:	eb 40                	jmp    f010135d <disassemble+0x126>
		case BYTE:
			strcpy(R_output, register_mnemonics8[(int)modRM_reg]);
f010131d:	0f be d2             	movsbl %dl,%edx
f0101320:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101323:	8d 84 80 a0 ef 14 f0 	lea    -0xfeb1060(%eax,%eax,4),%eax
f010132a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010132e:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101334:	89 04 24             	mov    %eax,(%esp)
f0101337:	e8 d7 66 00 00       	call   f0107a13 <strcpy>
			break;
f010133c:	eb 1f                	jmp    f010135d <disassemble+0x126>
		default:
			strcpy(R_output, register_mnemonics32[(int)modRM_reg]);
f010133e:	0f be d2             	movsbl %dl,%edx
f0101341:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101344:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f010134b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010134f:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101355:	89 04 24             	mov    %eax,(%esp)
f0101358:	e8 b6 66 00 00       	call   f0107a13 <strcpy>
	}

	if (modRM_mod == 0b11) { // Register addressing mode.
f010135d:	80 fb 03             	cmp    $0x3,%bl
f0101360:	0f 85 c7 00 00 00    	jne    f010142d <disassemble+0x1f6>
		switch (instructions[opcode].size) {
f0101366:	8a 47 01             	mov    0x1(%edi),%al
f0101369:	3c 14                	cmp    $0x14,%al
f010136b:	74 06                	je     f0101373 <disassemble+0x13c>
f010136d:	3c 15                	cmp    $0x15,%al
f010136f:	75 7e                	jne    f01013ef <disassemble+0x1b8>
f0101371:	eb 3e                	jmp    f01013b1 <disassemble+0x17a>
			case BYTE:
				//sprintf(RM_output, "%s", register_mnemonics8[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
f0101373:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f010137a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010137d:	8d 84 80 a0 ef 14 f0 	lea    -0xfeb1060(%eax,%eax,4),%eax
f0101384:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101388:	c7 44 24 08 bb a6 10 	movl   $0xf010a6bb,0x8(%esp)
f010138f:	f0 
f0101390:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101397:	00 
f0101398:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010139e:	89 04 24             	mov    %eax,(%esp)
f01013a1:	e8 47 65 00 00       	call   f01078ed <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f01013a6:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
	if (modRM_mod == 0b11) { // Register addressing mode.
		switch (instructions[opcode].size) {
			case BYTE:
				//sprintf(RM_output, "%s", register_mnemonics8[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
				break;
f01013ac:	e9 1d 03 00 00       	jmp    f01016ce <disassemble+0x497>
			case WORD:
				//sprintf(RM_output, "%s", register_mnemonics16[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics16[(int)modRM_rm]);
f01013b1:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f01013b8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01013bb:	8d 84 80 20 ef 14 f0 	lea    -0xfeb10e0(%eax,%eax,4),%eax
f01013c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013c6:	c7 44 24 08 bb a6 10 	movl   $0xf010a6bb,0x8(%esp)
f01013cd:	f0 
f01013ce:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f01013d5:	00 
f01013d6:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01013dc:	89 04 24             	mov    %eax,(%esp)
f01013df:	e8 09 65 00 00       	call   f01078ed <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f01013e4:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
				break;
			case WORD:
				//sprintf(RM_output, "%s", register_mnemonics16[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics16[(int)modRM_rm]);
				break;
f01013ea:	e9 df 02 00 00       	jmp    f01016ce <disassemble+0x497>
			default:
				//sprintf(RM_output, "%s", register_mnemonics32[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics32[(int)modRM_rm]);
f01013ef:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f01013f6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01013f9:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f0101400:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101404:	c7 44 24 08 bb a6 10 	movl   $0xf010a6bb,0x8(%esp)
f010140b:	f0 
f010140c:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101413:	00 
f0101414:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010141a:	89 04 24             	mov    %eax,(%esp)
f010141d:	e8 cb 64 00 00       	call   f01078ed <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f0101422:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f0101428:	e9 a1 02 00 00       	jmp    f01016ce <disassemble+0x497>
				break;
			default:
				//sprintf(RM_output, "%s", register_mnemonics32[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics32[(int)modRM_rm]);
		}
	} else if (modRM_mod == 0b00 && modRM_rm == 0b101) { // Displacement only addressing mode.
f010142d:	84 db                	test   %bl,%bl
f010142f:	75 40                	jne    f0101471 <disassemble+0x23a>
f0101431:	80 bd dc fd ff ff 05 	cmpb   $0x5,-0x224(%ebp)
f0101438:	75 37                	jne    f0101471 <disassemble+0x23a>
		//sprintf(RM_output, "[0x%x]", *(int *)bytes);
		snprintf(RM_output,0xff, "[0x%x]", *(int *)bytes);
f010143a:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f0101440:	8b 42 01             	mov    0x1(%edx),%eax
f0101443:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101447:	c7 44 24 08 ed 8c 10 	movl   $0xf0108ced,0x8(%esp)
f010144e:	f0 
f010144f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101456:	00 
f0101457:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010145d:	89 04 24             	mov    %eax,(%esp)
f0101460:	e8 88 64 00 00       	call   f01078ed <snprintf>
		bytes += 4;
f0101465:	83 85 e4 fd ff ff 05 	addl   $0x5,-0x21c(%ebp)
f010146c:	e9 5d 02 00 00       	jmp    f01016ce <disassemble+0x497>
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
f0101471:	80 bd dc fd ff ff 04 	cmpb   $0x4,-0x224(%ebp)
f0101478:	0f 85 fa 00 00 00    	jne    f0101578 <disassemble+0x341>
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f010147e:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101484:	8a 40 01             	mov    0x1(%eax),%al
f0101487:	88 85 dc fd ff ff    	mov    %al,-0x224(%ebp)
			char SIB_index = ((*bytes) >> 3) & 0b111; // Bits 5-3.
f010148d:	c0 e8 03             	shr    $0x3,%al
f0101490:	83 e0 07             	and    $0x7,%eax
f0101493:	88 85 e2 fd ff ff    	mov    %al,-0x21e(%ebp)
			char SIB_base = (*bytes++) & 0b111; // Bits 2-0.
f0101499:	8a 85 dc fd ff ff    	mov    -0x224(%ebp),%al
f010149f:	83 e0 07             	and    $0x7,%eax

			if (SIB_base == 0b101 && modRM_mod == 0b00) {
f01014a2:	3c 05                	cmp    $0x5,%al
f01014a4:	75 3a                	jne    f01014e0 <disassemble+0x2a9>
f01014a6:	84 db                	test   %bl,%bl
f01014a8:	75 36                	jne    f01014e0 <disassemble+0x2a9>
				//sprintf(RM_output, "[0x%x", *(int *)bytes);
				snprintf(RM_output,0xff, "[0x%x", *(int *)bytes);
f01014aa:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f01014b0:	8b 42 02             	mov    0x2(%edx),%eax
f01014b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014b7:	c7 44 24 08 f4 8c 10 	movl   $0xf0108cf4,0x8(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01014c6:	00 
f01014c7:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01014cd:	89 04 24             	mov    %eax,(%esp)
f01014d0:	e8 18 64 00 00       	call   f01078ed <snprintf>
				bytes += 4;
f01014d5:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f01014db:	83 c6 06             	add    $0x6,%esi
f01014de:	eb 28                	jmp    f0101508 <disassemble+0x2d1>
		bytes += 4;
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
			char SIB_index = ((*bytes) >> 3) & 0b111; // Bits 5-3.
			char SIB_base = (*bytes++) & 0b111; // Bits 2-0.
f01014e0:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f01014e6:	83 c6 02             	add    $0x2,%esi
			if (SIB_base == 0b101 && modRM_mod == 0b00) {
				//sprintf(RM_output, "[0x%x", *(int *)bytes);
				snprintf(RM_output,0xff, "[0x%x", *(int *)bytes);
				bytes += 4;
			} else {
				strcpy(RM_output, sib_base_mnemonics[(int)SIB_base]);
f01014e9:	0f be c0             	movsbl %al,%eax
f01014ec:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01014ef:	8d 84 80 a0 f0 14 f0 	lea    -0xfeb0f60(%eax,%eax,4),%eax
f01014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014fa:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101500:	89 04 24             	mov    %eax,(%esp)
f0101503:	e8 0b 65 00 00       	call   f0107a13 <strcpy>
			}

			if (SIB_index != 0b100) {
f0101508:	80 bd e2 fd ff ff 04 	cmpb   $0x4,-0x21e(%ebp)
f010150f:	0f 84 96 00 00 00    	je     f01015ab <disassemble+0x374>
				strcat(RM_output, "+");
f0101515:	c7 44 24 04 fa 8c 10 	movl   $0xf0108cfa,0x4(%esp)
f010151c:	f0 
f010151d:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101523:	89 04 24             	mov    %eax,(%esp)
f0101526:	e8 05 65 00 00       	call   f0107a30 <strcat>
				strcat(RM_output, register_mnemonics32[(int)SIB_index]);
f010152b:	0f be 85 e2 fd ff ff 	movsbl -0x21e(%ebp),%eax
f0101532:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101535:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f010153c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101540:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f0101546:	89 14 24             	mov    %edx,(%esp)
f0101549:	e8 e2 64 00 00       	call   f0107a30 <strcat>
		//sprintf(RM_output, "[0x%x]", *(int *)bytes);
		snprintf(RM_output,0xff, "[0x%x]", *(int *)bytes);
		bytes += 4;
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f010154e:	8a 85 dc fd ff ff    	mov    -0x224(%ebp),%al
f0101554:	c0 e8 06             	shr    $0x6,%al
			}

			if (SIB_index != 0b100) {
				strcat(RM_output, "+");
				strcat(RM_output, register_mnemonics32[(int)SIB_index]);
				strcat(RM_output, sib_scale_mnemonics[(int)SIB_scale]);
f0101557:	0f be c0             	movsbl %al,%eax
f010155a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010155d:	8d 84 80 20 f1 14 f0 	lea    -0xfeb0ee0(%eax,%eax,4),%eax
f0101564:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101568:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010156e:	89 04 24             	mov    %eax,(%esp)
f0101571:	e8 ba 64 00 00       	call   f0107a30 <strcat>
f0101576:	eb 33                	jmp    f01015ab <disassemble+0x374>
			}
		} else {
			//sprintf(RM_output, "[%s", register_mnemonics32[(int)modRM_rm]);
			snprintf(RM_output,0xf, "[%s", register_mnemonics32[(int)modRM_rm]);
f0101578:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f010157f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101582:	8d 84 80 20 f0 14 f0 	lea    -0xfeb0fe0(%eax,%eax,4),%eax
f0101589:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010158d:	c7 44 24 08 fc 8c 10 	movl   $0xf0108cfc,0x8(%esp)
f0101594:	f0 
f0101595:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f010159c:	00 
f010159d:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01015a3:	89 04 24             	mov    %eax,(%esp)
f01015a6:	e8 42 63 00 00       	call   f01078ed <snprintf>
		}

		if (modRM_mod == 0b01) { // One-byte signed displacement follows addressing mode byte(s).
f01015ab:	80 fb 01             	cmp    $0x1,%bl
f01015ae:	0f 85 80 00 00 00    	jne    f0101634 <disassemble+0x3fd>
			if (*bytes > 0x7F) {
f01015b4:	8a 1e                	mov    (%esi),%bl
f01015b6:	84 db                	test   %bl,%bl
f01015b8:	79 3d                	jns    f01015f7 <disassemble+0x3c0>
				//sprintf(RM_output + strlen(RM_output), "-0x%x]", -*(char *)bytes++);
				snprintf(RM_output + strlen(RM_output),0xff, "-0x%x]", -*(char *)bytes++);
f01015ba:	46                   	inc    %esi
f01015bb:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f01015c1:	8d b5 e9 fe ff ff    	lea    -0x117(%ebp),%esi
f01015c7:	89 34 24             	mov    %esi,(%esp)
f01015ca:	e8 11 64 00 00       	call   f01079e0 <strlen>
f01015cf:	0f be db             	movsbl %bl,%ebx
f01015d2:	f7 db                	neg    %ebx
f01015d4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01015d8:	c7 44 24 08 00 8d 10 	movl   $0xf0108d00,0x8(%esp)
f01015df:	f0 
f01015e0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01015e7:	00 
f01015e8:	01 f0                	add    %esi,%eax
f01015ea:	89 04 24             	mov    %eax,(%esp)
f01015ed:	e8 fb 62 00 00       	call   f01078ed <snprintf>
f01015f2:	e9 d7 00 00 00       	jmp    f01016ce <disassemble+0x497>
			} else {
				//sprintf(RM_output + strlen(RM_output), "+0x%x]", *(char *)bytes++);
				snprintf(RM_output + strlen(RM_output),0xff, "+0x%x]", *(char *)bytes++);
f01015f7:	46                   	inc    %esi
f01015f8:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f01015fe:	8d b5 e9 fe ff ff    	lea    -0x117(%ebp),%esi
f0101604:	89 34 24             	mov    %esi,(%esp)
f0101607:	e8 d4 63 00 00       	call   f01079e0 <strlen>
f010160c:	89 c2                	mov    %eax,%edx
f010160e:	0f be c3             	movsbl %bl,%eax
f0101611:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101615:	c7 44 24 08 07 8d 10 	movl   $0xf0108d07,0x8(%esp)
f010161c:	f0 
f010161d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101624:	00 
f0101625:	01 f2                	add    %esi,%edx
f0101627:	89 14 24             	mov    %edx,(%esp)
f010162a:	e8 be 62 00 00       	call   f01078ed <snprintf>
f010162f:	e9 9a 00 00 00       	jmp    f01016ce <disassemble+0x497>
			}
		} else if (modRM_mod == 0b10) { // Four-byte signed displacement follows addressing mode byte(s).
f0101634:	80 fb 02             	cmp    $0x2,%bl
f0101637:	75 79                	jne    f01016b2 <disassemble+0x47b>
			if (*(unsigned int *)bytes > 0x7FFFFFFF) {
f0101639:	8b 1e                	mov    (%esi),%ebx
f010163b:	85 db                	test   %ebx,%ebx
f010163d:	79 36                	jns    f0101675 <disassemble+0x43e>
				//sprintf(RM_output + strlen(RM_output), "-0x%x]", -*(int *)bytes);
				snprintf(RM_output + strlen(RM_output),0xff, "-0x%x]", -*(int *)bytes);
f010163f:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f0101645:	89 14 24             	mov    %edx,(%esp)
f0101648:	e8 93 63 00 00       	call   f01079e0 <strlen>
f010164d:	f7 db                	neg    %ebx
f010164f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101653:	c7 44 24 08 00 8d 10 	movl   $0xf0108d00,0x8(%esp)
f010165a:	f0 
f010165b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101662:	00 
f0101663:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f0101669:	01 d0                	add    %edx,%eax
f010166b:	89 04 24             	mov    %eax,(%esp)
f010166e:	e8 7a 62 00 00       	call   f01078ed <snprintf>
f0101673:	eb 32                	jmp    f01016a7 <disassemble+0x470>
			} else {
				//sprintf(RM_output + strlen(RM_output), "+0x%x]", *(unsigned int *)bytes);
				snprintf(RM_output + strlen(RM_output),0xff, "+0x%x]", *(unsigned int *)bytes);
f0101675:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010167b:	89 04 24             	mov    %eax,(%esp)
f010167e:	e8 5d 63 00 00       	call   f01079e0 <strlen>
f0101683:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101687:	c7 44 24 08 07 8d 10 	movl   $0xf0108d07,0x8(%esp)
f010168e:	f0 
f010168f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101696:	00 
f0101697:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f010169d:	01 d0                	add    %edx,%eax
f010169f:	89 04 24             	mov    %eax,(%esp)
f01016a2:	e8 46 62 00 00       	call   f01078ed <snprintf>
			}

			bytes += 4;
f01016a7:	83 c6 04             	add    $0x4,%esi
f01016aa:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f01016b0:	eb 1c                	jmp    f01016ce <disassemble+0x497>
		} else {
			strcat(RM_output, "]");
f01016b2:	c7 44 24 04 0c 8d 10 	movl   $0xf0108d0c,0x4(%esp)
f01016b9:	f0 
f01016ba:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01016c0:	89 04 24             	mov    %eax,(%esp)
f01016c3:	e8 68 63 00 00       	call   f0107a30 <strcat>
f01016c8:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
		}
	}

OUTPUT:
	modRM_mod = 0x0;
	strcpy(output, instructions[opcode].mnemonic);
f01016ce:	8d 47 02             	lea    0x2(%edi),%eax
f01016d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01016d8:	89 04 24             	mov    %eax,(%esp)
f01016db:	e8 33 63 00 00       	call   f0107a13 <strcpy>
	for (int i = 0; i < instructions[opcode].argument_count; i++) {
f01016e0:	be 00 00 00 00       	mov    $0x0,%esi
f01016e5:	e9 ab 03 00 00       	jmp    f0101a95 <disassemble+0x85e>
		if (i > 0) {
f01016ea:	85 f6                	test   %esi,%esi
f01016ec:	7e 13                	jle    f0101701 <disassemble+0x4ca>
			strcat(output, ",");
f01016ee:	c7 44 24 04 0e 8d 10 	movl   $0xf0108d0e,0x4(%esp)
f01016f5:	f0 
f01016f6:	8b 55 14             	mov    0x14(%ebp),%edx
f01016f9:	89 14 24             	mov    %edx,(%esp)
f01016fc:	e8 2f 63 00 00       	call   f0107a30 <strcat>
		}

		switch (instructions[opcode].arguments[i]) {
f0101701:	80 bc 37 02 01 00 00 	cmpb   $0x13,0x102(%edi,%esi,1)
f0101708:	13 
f0101709:	0f 87 85 03 00 00    	ja     f0101a94 <disassemble+0x85d>
f010170f:	0f b6 84 37 02 01 00 	movzbl 0x102(%edi,%esi,1),%eax
f0101716:	00 
f0101717:	ff 24 85 20 9b 10 f0 	jmp    *-0xfef64e0(,%eax,4)
			case RM:
				if (modRM_mod != 0b11) {
					switch (instructions[opcode].size) {
f010171e:	8a 47 01             	mov    0x1(%edi),%al
f0101721:	83 e8 14             	sub    $0x14,%eax
f0101724:	3c 05                	cmp    $0x5,%al
f0101726:	0f 87 86 00 00 00    	ja     f01017b2 <disassemble+0x57b>
f010172c:	0f b6 c0             	movzbl %al,%eax
f010172f:	ff 24 85 70 9b 10 f0 	jmp    *-0xfef6490(,%eax,4)
						case BYTE:
							strcat(output, "BYTE PTR ");
f0101736:	c7 44 24 04 10 8d 10 	movl   $0xf0108d10,0x4(%esp)
f010173d:	f0 
f010173e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101741:	89 04 24             	mov    %eax,(%esp)
f0101744:	e8 e7 62 00 00       	call   f0107a30 <strcat>
							break;
f0101749:	eb 67                	jmp    f01017b2 <disassemble+0x57b>
						case WORD:
							strcat(output, "WORD PTR ");
f010174b:	c7 44 24 04 1b 8d 10 	movl   $0xf0108d1b,0x4(%esp)
f0101752:	f0 
f0101753:	8b 55 14             	mov    0x14(%ebp),%edx
f0101756:	89 14 24             	mov    %edx,(%esp)
f0101759:	e8 d2 62 00 00       	call   f0107a30 <strcat>
							break;
f010175e:	eb 52                	jmp    f01017b2 <disassemble+0x57b>
						case DWORD:
							strcat(output, "DWORD PTR ");
f0101760:	c7 44 24 04 1a 8d 10 	movl   $0xf0108d1a,0x4(%esp)
f0101767:	f0 
f0101768:	8b 45 14             	mov    0x14(%ebp),%eax
f010176b:	89 04 24             	mov    %eax,(%esp)
f010176e:	e8 bd 62 00 00       	call   f0107a30 <strcat>
							break;
f0101773:	eb 3d                	jmp    f01017b2 <disassemble+0x57b>
						case QWORD:
							strcat(output, "QWORD PTR ");
f0101775:	c7 44 24 04 25 8d 10 	movl   $0xf0108d25,0x4(%esp)
f010177c:	f0 
f010177d:	8b 55 14             	mov    0x14(%ebp),%edx
f0101780:	89 14 24             	mov    %edx,(%esp)
f0101783:	e8 a8 62 00 00       	call   f0107a30 <strcat>
							break;
f0101788:	eb 28                	jmp    f01017b2 <disassemble+0x57b>
						case FWORD:
							strcat(output, "FWORD PTR ");
f010178a:	c7 44 24 04 30 8d 10 	movl   $0xf0108d30,0x4(%esp)
f0101791:	f0 
f0101792:	8b 45 14             	mov    0x14(%ebp),%eax
f0101795:	89 04 24             	mov    %eax,(%esp)
f0101798:	e8 93 62 00 00       	call   f0107a30 <strcat>
							break;
f010179d:	eb 13                	jmp    f01017b2 <disassemble+0x57b>
						case XMMWORD:
							strcat(output, "XMMWORD PTR ");
f010179f:	c7 44 24 04 3b 8d 10 	movl   $0xf0108d3b,0x4(%esp)
f01017a6:	f0 
f01017a7:	8b 55 14             	mov    0x14(%ebp),%edx
f01017aa:	89 14 24             	mov    %edx,(%esp)
f01017ad:	e8 7e 62 00 00       	call   f0107a30 <strcat>
							break;
					}
				}

				strcat(output, RM_output);
f01017b2:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017bc:	8b 55 14             	mov    0x14(%ebp),%edx
f01017bf:	89 14 24             	mov    %edx,(%esp)
f01017c2:	e8 69 62 00 00       	call   f0107a30 <strcat>
				break;
f01017c7:	e9 c8 02 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case R:
				strcat(output, R_output);
f01017cc:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f01017d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017d6:	8b 55 14             	mov    0x14(%ebp),%edx
f01017d9:	89 14 24             	mov    %edx,(%esp)
f01017dc:	e8 4f 62 00 00       	call   f0107a30 <strcat>
				break;
f01017e1:	e9 ae 02 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case IMM8:
				//sprintf(output + strlen(output), "0x%x", *bytes++);
				snprintf(output + strlen(output),0xff, "0x%x", *bytes++);
f01017e6:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01017ec:	0f b6 18             	movzbl (%eax),%ebx
f01017ef:	40                   	inc    %eax
f01017f0:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
f01017f6:	8b 55 14             	mov    0x14(%ebp),%edx
f01017f9:	89 14 24             	mov    %edx,(%esp)
f01017fc:	e8 df 61 00 00       	call   f01079e0 <strlen>
f0101801:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101805:	c7 44 24 08 53 8d 10 	movl   $0xf0108d53,0x8(%esp)
f010180c:	f0 
f010180d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101814:	00 
f0101815:	03 45 14             	add    0x14(%ebp),%eax
f0101818:	89 04 24             	mov    %eax,(%esp)
f010181b:	e8 cd 60 00 00       	call   f01078ed <snprintf>
				break;
f0101820:	e9 6f 02 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case IMM16:
				//sprintf(output + strlen(output), "0x%x", *(short *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x", *(short *)bytes);
f0101825:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010182b:	0f bf 18             	movswl (%eax),%ebx
f010182e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101831:	89 14 24             	mov    %edx,(%esp)
f0101834:	e8 a7 61 00 00       	call   f01079e0 <strlen>
f0101839:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010183d:	c7 44 24 08 53 8d 10 	movl   $0xf0108d53,0x8(%esp)
f0101844:	f0 
f0101845:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010184c:	00 
f010184d:	03 45 14             	add    0x14(%ebp),%eax
f0101850:	89 04 24             	mov    %eax,(%esp)
f0101853:	e8 95 60 00 00       	call   f01078ed <snprintf>
				bytes += 2;
f0101858:	83 85 e4 fd ff ff 02 	addl   $0x2,-0x21c(%ebp)
				break;
f010185f:	e9 30 02 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case IMM32:
				//sprintf(output + strlen(output), "0x%x", *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x", *(int *)bytes);
f0101864:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010186a:	8b 18                	mov    (%eax),%ebx
f010186c:	8b 55 14             	mov    0x14(%ebp),%edx
f010186f:	89 14 24             	mov    %edx,(%esp)
f0101872:	e8 69 61 00 00       	call   f01079e0 <strlen>
f0101877:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010187b:	c7 44 24 08 53 8d 10 	movl   $0xf0108d53,0x8(%esp)
f0101882:	f0 
f0101883:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010188a:	00 
f010188b:	03 45 14             	add    0x14(%ebp),%eax
f010188e:	89 04 24             	mov    %eax,(%esp)
f0101891:	e8 57 60 00 00       	call   f01078ed <snprintf>
				bytes += 4;
f0101896:	83 85 e4 fd ff ff 04 	addl   $0x4,-0x21c(%ebp)
				break;
f010189d:	e9 f2 01 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case REL8:
				//sprintf(output + strlen(output), "0x%lx", offset + ((bytes - base) + 1) + *(char *)bytes);
				snprintf(output + strlen(output),0xff, "0x%lx", offset + ((bytes - base) + 1) + *(char *)bytes);
f01018a2:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01018a8:	2b 45 08             	sub    0x8(%ebp),%eax
f01018ab:	8b 55 10             	mov    0x10(%ebp),%edx
f01018ae:	8d 5c 02 01          	lea    0x1(%edx,%eax,1),%ebx
f01018b2:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f01018b8:	0f be 02             	movsbl (%edx),%eax
f01018bb:	01 c3                	add    %eax,%ebx
f01018bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01018c0:	89 04 24             	mov    %eax,(%esp)
f01018c3:	e8 18 61 00 00       	call   f01079e0 <strlen>
f01018c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01018cc:	c7 44 24 08 48 8d 10 	movl   $0xf0108d48,0x8(%esp)
f01018d3:	f0 
f01018d4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01018db:	00 
f01018dc:	03 45 14             	add    0x14(%ebp),%eax
f01018df:	89 04 24             	mov    %eax,(%esp)
f01018e2:	e8 06 60 00 00       	call   f01078ed <snprintf>
                bytes++;
f01018e7:	ff 85 e4 fd ff ff    	incl   -0x21c(%ebp)
				break;
f01018ed:	e9 a2 01 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case REL32:
				//sprintf(output + strlen(output), "0x%lx", offset + ((bytes - base) + 4) + *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%lx", offset + ((bytes - base) + 4) + *(int *)bytes);
f01018f2:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01018f8:	2b 45 08             	sub    0x8(%ebp),%eax
f01018fb:	8b 55 10             	mov    0x10(%ebp),%edx
f01018fe:	8d 5c 02 04          	lea    0x4(%edx,%eax,1),%ebx
f0101902:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101908:	03 18                	add    (%eax),%ebx
f010190a:	8b 55 14             	mov    0x14(%ebp),%edx
f010190d:	89 14 24             	mov    %edx,(%esp)
f0101910:	e8 cb 60 00 00       	call   f01079e0 <strlen>
f0101915:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101919:	c7 44 24 08 48 8d 10 	movl   $0xf0108d48,0x8(%esp)
f0101920:	f0 
f0101921:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101928:	00 
f0101929:	03 45 14             	add    0x14(%ebp),%eax
f010192c:	89 04 24             	mov    %eax,(%esp)
f010192f:	e8 b9 5f 00 00       	call   f01078ed <snprintf>
				bytes += 4;
f0101934:	83 85 e4 fd ff ff 04 	addl   $0x4,-0x21c(%ebp)
				break;
f010193b:	e9 54 01 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case PTR1632:
				//sprintf(output + strlen(output), "0x%x:0x%x", *(short *)(bytes + 4), *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x:0x%x", *(short *)(bytes + 4), *(int *)bytes);
f0101940:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101946:	8b 00                	mov    (%eax),%eax
f0101948:	89 85 dc fd ff ff    	mov    %eax,-0x224(%ebp)
f010194e:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f0101954:	0f bf 5a 04          	movswl 0x4(%edx),%ebx
f0101958:	8b 45 14             	mov    0x14(%ebp),%eax
f010195b:	89 04 24             	mov    %eax,(%esp)
f010195e:	e8 7d 60 00 00       	call   f01079e0 <strlen>
f0101963:	8b 95 dc fd ff ff    	mov    -0x224(%ebp),%edx
f0101969:	89 54 24 10          	mov    %edx,0x10(%esp)
f010196d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101971:	c7 44 24 08 4e 8d 10 	movl   $0xf0108d4e,0x8(%esp)
f0101978:	f0 
f0101979:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101980:	00 
f0101981:	03 45 14             	add    0x14(%ebp),%eax
f0101984:	89 04 24             	mov    %eax,(%esp)
f0101987:	e8 61 5f 00 00       	call   f01078ed <snprintf>
				bytes += 6;
f010198c:	83 85 e4 fd ff ff 06 	addl   $0x6,-0x21c(%ebp)
				break;
f0101993:	e9 fc 00 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case AL:
				strcat(output, "al");
f0101998:	c7 44 24 04 58 8d 10 	movl   $0xf0108d58,0x4(%esp)
f010199f:	f0 
f01019a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01019a3:	89 04 24             	mov    %eax,(%esp)
f01019a6:	e8 85 60 00 00       	call   f0107a30 <strcat>
				break;
f01019ab:	e9 e4 00 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case EAX:
				strcat(output, "eax");
f01019b0:	c7 44 24 04 5b 8d 10 	movl   $0xf0108d5b,0x4(%esp)
f01019b7:	f0 
f01019b8:	8b 55 14             	mov    0x14(%ebp),%edx
f01019bb:	89 14 24             	mov    %edx,(%esp)
f01019be:	e8 6d 60 00 00       	call   f0107a30 <strcat>
				break;
f01019c3:	e9 cc 00 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case ES:
				strcat(output, "es");
f01019c8:	c7 44 24 04 a6 a6 10 	movl   $0xf010a6a6,0x4(%esp)
f01019cf:	f0 
f01019d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01019d3:	89 04 24             	mov    %eax,(%esp)
f01019d6:	e8 55 60 00 00       	call   f0107a30 <strcat>
				break;
f01019db:	e9 b4 00 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case CS:
				strcat(output, "cs");
f01019e0:	c7 44 24 04 5f 8d 10 	movl   $0xf0108d5f,0x4(%esp)
f01019e7:	f0 
f01019e8:	8b 55 14             	mov    0x14(%ebp),%edx
f01019eb:	89 14 24             	mov    %edx,(%esp)
f01019ee:	e8 3d 60 00 00       	call   f0107a30 <strcat>
				break;
f01019f3:	e9 9c 00 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case SS:
				strcat(output, "ss");
f01019f8:	c7 44 24 04 62 8d 10 	movl   $0xf0108d62,0x4(%esp)
f01019ff:	f0 
f0101a00:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a03:	89 04 24             	mov    %eax,(%esp)
f0101a06:	e8 25 60 00 00       	call   f0107a30 <strcat>
				break;
f0101a0b:	e9 84 00 00 00       	jmp    f0101a94 <disassemble+0x85d>
			case DS:
				strcat(output, "ds");
f0101a10:	c7 44 24 04 11 8e 10 	movl   $0xf0108e11,0x4(%esp)
f0101a17:	f0 
f0101a18:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a1b:	89 14 24             	mov    %edx,(%esp)
f0101a1e:	e8 0d 60 00 00       	call   f0107a30 <strcat>
				break;
f0101a23:	eb 6f                	jmp    f0101a94 <disassemble+0x85d>
			case ONE:
				strcat(output, "1");
f0101a25:	c7 44 24 04 f3 a8 10 	movl   $0xf010a8f3,0x4(%esp)
f0101a2c:	f0 
f0101a2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a30:	89 04 24             	mov    %eax,(%esp)
f0101a33:	e8 f8 5f 00 00       	call   f0107a30 <strcat>
				break;
f0101a38:	eb 5a                	jmp    f0101a94 <disassemble+0x85d>
			case CL:
				strcat(output, "cl");
f0101a3a:	c7 44 24 04 65 8d 10 	movl   $0xf0108d65,0x4(%esp)
f0101a41:	f0 
f0101a42:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a45:	89 14 24             	mov    %edx,(%esp)
f0101a48:	e8 e3 5f 00 00       	call   f0107a30 <strcat>
				break;
f0101a4d:	eb 45                	jmp    f0101a94 <disassemble+0x85d>
			case XMM0:
				strcat(output, "xmm0");
f0101a4f:	c7 44 24 04 68 8d 10 	movl   $0xf0108d68,0x4(%esp)
f0101a56:	f0 
f0101a57:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a5a:	89 04 24             	mov    %eax,(%esp)
f0101a5d:	e8 ce 5f 00 00       	call   f0107a30 <strcat>
				break;
f0101a62:	eb 30                	jmp    f0101a94 <disassemble+0x85d>
			case BND0:
				strcat(output, "bnd0");
f0101a64:	c7 44 24 04 6d 8d 10 	movl   $0xf0108d6d,0x4(%esp)
f0101a6b:	f0 
f0101a6c:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a6f:	89 14 24             	mov    %edx,(%esp)
f0101a72:	e8 b9 5f 00 00       	call   f0107a30 <strcat>
				break;
f0101a77:	eb 1b                	jmp    f0101a94 <disassemble+0x85d>
			case BAD:
				bytes++;
f0101a79:	ff 85 e4 fd ff ff    	incl   -0x21c(%ebp)
				break;
f0101a7f:	eb 13                	jmp    f0101a94 <disassemble+0x85d>
			case MM0:
				strcat(output, "mm0");
f0101a81:	c7 44 24 04 69 8d 10 	movl   $0xf0108d69,0x4(%esp)
f0101a88:	f0 
f0101a89:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a8c:	89 04 24             	mov    %eax,(%esp)
f0101a8f:	e8 9c 5f 00 00       	call   f0107a30 <strcat>
	}

OUTPUT:
	modRM_mod = 0x0;
	strcpy(output, instructions[opcode].mnemonic);
	for (int i = 0; i < instructions[opcode].argument_count; i++) {
f0101a94:	46                   	inc    %esi
f0101a95:	0f be 87 01 01 00 00 	movsbl 0x101(%edi),%eax
f0101a9c:	39 c6                	cmp    %eax,%esi
f0101a9e:	0f 8c 46 fc ff ff    	jl     f01016ea <disassemble+0x4b3>
				strcat(output, "mm0");
				break;
		}
	}

	if (((unsigned int)(bytes - base)) <= max) {
f0101aa4:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101aaa:	2b 45 08             	sub    0x8(%ebp),%eax
f0101aad:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0101ab0:	72 08                	jb     f0101aba <disassemble+0x883>
f0101ab2:	eb 31                	jmp    f0101ae5 <disassemble+0x8ae>
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f0101ab4:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)
	if (((unsigned int)(bytes - base)) <= max) {
		return bytes - base;
	}

ILLEGAL:
	snprintf(output,0xff, ".byte 0x%02x\n", opcode);
f0101aba:	0f b6 85 e3 fd ff ff 	movzbl -0x21d(%ebp),%eax
f0101ac1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ac5:	c7 44 24 08 72 8d 10 	movl   $0xf0108d72,0x8(%esp)
f0101acc:	f0 
f0101acd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101ad4:	00 
f0101ad5:	8b 55 14             	mov    0x14(%ebp),%edx
f0101ad8:	89 14 24             	mov    %edx,(%esp)
f0101adb:	e8 0d 5e 00 00       	call   f01078ed <snprintf>
	return 1;
f0101ae0:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0101ae5:	81 c4 3c 02 00 00    	add    $0x23c,%esp
f0101aeb:	5b                   	pop    %ebx
f0101aec:	5e                   	pop    %esi
f0101aed:	5f                   	pop    %edi
f0101aee:	5d                   	pop    %ebp
f0101aef:	c3                   	ret    

f0101af0 <mon_disassembler>:
        	return 0;
    }    
}

int
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
f0101af0:	55                   	push   %ebp
f0101af1:	89 e5                	mov    %esp,%ebp
f0101af3:	57                   	push   %edi
f0101af4:	56                   	push   %esi
f0101af5:	53                   	push   %ebx
f0101af6:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
f0101afc:	8b 45 08             	mov    0x8(%ebp),%eax
f0101aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(argc>2){
f0101b02:	83 f8 02             	cmp    $0x2,%eax
f0101b05:	7e 11                	jle    f0101b18 <mon_disassembler+0x28>
		cprintf("mon_disassembler: The number of parameters is two.\n");
f0101b07:	c7 04 24 a0 95 10 f0 	movl   $0xf01095a0,(%esp)
f0101b0e:	e8 db 3c 00 00       	call   f01057ee <cprintf>
		return 0;
f0101b13:	e9 53 01 00 00       	jmp    f0101c6b <mon_disassembler+0x17b>
	}
	int InstructionNumber = 1;
	if (argc == 2){
f0101b18:	83 f8 02             	cmp    $0x2,%eax
f0101b1b:	75 3c                	jne    f0101b59 <mon_disassembler+0x69>
		char *errChar;
		InstructionNumber = strtol(argv[1], &errChar, 0);
f0101b1d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b24:	00 
f0101b25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b2f:	8b 40 04             	mov    0x4(%eax),%eax
f0101b32:	89 04 24             	mov    %eax,(%esp)
f0101b35:	e8 32 61 00 00       	call   f0107c6c <strtol>
f0101b3a:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
		if (*errChar){
f0101b40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b43:	80 38 00             	cmpb   $0x0,(%eax)
f0101b46:	74 1b                	je     f0101b63 <mon_disassembler+0x73>
			cprintf("mon_disassembler: The first argument is not a number.\n");
f0101b48:	c7 04 24 d4 95 10 f0 	movl   $0xf01095d4,(%esp)
f0101b4f:	e8 9a 3c 00 00       	call   f01057ee <cprintf>
			return 0;
f0101b54:	e9 12 01 00 00       	jmp    f0101c6b <mon_disassembler+0x17b>
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
	if(argc>2){
		cprintf("mon_disassembler: The number of parameters is two.\n");
		return 0;
	}
	int InstructionNumber = 1;
f0101b59:	c7 85 c4 fd ff ff 01 	movl   $0x1,-0x23c(%ebp)
f0101b60:	00 00 00 
			cprintf("mon_disassembler: The first argument is not a number.\n");
			return 0;
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
f0101b63:	85 db                	test   %ebx,%ebx
f0101b65:	75 11                	jne    f0101b78 <mon_disassembler+0x88>
f0101b67:	c7 04 24 0c 96 10 f0 	movl   $0xf010960c,(%esp)
f0101b6e:	e8 7b 3c 00 00       	call   f01057ee <cprintf>
f0101b73:	e9 f3 00 00 00       	jmp    f0101c6b <mon_disassembler+0x17b>
	unsigned char* address = (unsigned char*)tf->tf_eip;
f0101b78:	8b 5b 30             	mov    0x30(%ebx),%ebx
f0101b7b:	89 9d d4 fd ff ff    	mov    %ebx,-0x22c(%ebp)
	for (int i = 0;i<InstructionNumber;i++){
f0101b81:	c7 85 cc fd ff ff 00 	movl   $0x0,-0x234(%ebp)
f0101b88:	00 00 00 
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
f0101b8b:	8d bd e5 fe ff ff    	lea    -0x11b(%ebp),%edi
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
	unsigned char* address = (unsigned char*)tf->tf_eip;
	for (int i = 0;i<InstructionNumber;i++){
f0101b91:	e9 c3 00 00 00       	jmp    f0101c59 <mon_disassembler+0x169>
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
f0101b96:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
f0101b9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ba0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ba7:	00 
f0101ba8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101baf:	00 
f0101bb0:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101bb6:	89 04 24             	mov    %eax,(%esp)
f0101bb9:	e8 79 f6 ff ff       	call   f0101237 <disassemble>
f0101bbe:	89 85 c8 fd ff ff    	mov    %eax,-0x238(%ebp)
		cprintf("%08x: ", address);
f0101bc4:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101bca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bce:	c7 04 24 80 8d 10 f0 	movl   $0xf0108d80,(%esp)
f0101bd5:	e8 14 3c 00 00       	call   f01057ee <cprintf>
		instruction[0] = 0;
f0101bda:	c6 85 e5 fe ff ff 00 	movb   $0x0,-0x11b(%ebp)
        	return 0;
    }    
}

int
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
f0101be1:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
f0101be7:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
f0101bed:	be 00 00 00 00       	mov    $0x0,%esi
f0101bf2:	eb 31                	jmp    f0101c25 <mon_disassembler+0x135>
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
f0101bf4:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101bfa:	0f b6 1c 30          	movzbl (%eax,%esi,1),%ebx
f0101bfe:	89 3c 24             	mov    %edi,(%esp)
f0101c01:	e8 da 5d 00 00       	call   f01079e0 <strlen>
f0101c06:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101c0a:	c7 44 24 08 87 8d 10 	movl   $0xf0108d87,0x8(%esp)
f0101c11:	f0 
f0101c12:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101c19:	00 
f0101c1a:	01 f8                	add    %edi,%eax
f0101c1c:	89 04 24             	mov    %eax,(%esp)
f0101c1f:	e8 c9 5c 00 00       	call   f01078ed <snprintf>
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
f0101c24:	46                   	inc    %esi
f0101c25:	3b b5 d0 fd ff ff    	cmp    -0x230(%ebp),%esi
f0101c2b:	75 c7                	jne    f0101bf4 <mon_disassembler+0x104>
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
		}
		cprintf("%-30s %s\n", instruction, disassembled);
f0101c2d:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
f0101c33:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c37:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c3b:	c7 04 24 8d 8d 10 f0 	movl   $0xf0108d8d,(%esp)
f0101c42:	e8 a7 3b 00 00       	call   f01057ee <cprintf>
		address = (unsigned char*)((uint32_t)address + count);
f0101c47:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
f0101c4d:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
	unsigned char* address = (unsigned char*)tf->tf_eip;
	for (int i = 0;i<InstructionNumber;i++){
f0101c53:	ff 85 cc fd ff ff    	incl   -0x234(%ebp)
f0101c59:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
f0101c5f:	39 85 c4 fd ff ff    	cmp    %eax,-0x23c(%ebp)
f0101c65:	0f 8f 2b ff ff ff    	jg     f0101b96 <mon_disassembler+0xa6>
		}
		cprintf("%-30s %s\n", instruction, disassembled);
		address = (unsigned char*)((uint32_t)address + count);
	}
	return 0;
f0101c6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c70:	81 c4 4c 02 00 00    	add    $0x24c,%esp
f0101c76:	5b                   	pop    %ebx
f0101c77:	5e                   	pop    %esi
f0101c78:	5f                   	pop    %edi
f0101c79:	5d                   	pop    %ebp
f0101c7a:	c3                   	ret    

f0101c7b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0101c7b:	55                   	push   %ebp
f0101c7c:	89 e5                	mov    %esp,%ebp
f0101c7e:	57                   	push   %edi
f0101c7f:	56                   	push   %esi
f0101c80:	53                   	push   %ebx
f0101c81:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101c84:	c7 04 24 30 96 10 f0 	movl   $0xf0109630,(%esp)
f0101c8b:	e8 5e 3b 00 00       	call   f01057ee <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101c90:	c7 04 24 54 96 10 f0 	movl   $0xf0109654,(%esp)
f0101c97:	e8 52 3b 00 00       	call   f01057ee <cprintf>

	if (tf != NULL)
f0101c9c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101ca0:	74 0b                	je     f0101cad <monitor+0x32>
		print_trapframe(tf);
f0101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ca5:	89 04 24             	mov    %eax,(%esp)
f0101ca8:	e8 8d 43 00 00       	call   f010603a <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0101cad:	c7 04 24 97 8d 10 f0 	movl   $0xf0108d97,(%esp)
f0101cb4:	e8 5f 5c 00 00       	call   f0107918 <readline>
f0101cb9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101cbb:	85 c0                	test   %eax,%eax
f0101cbd:	74 ee                	je     f0101cad <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0101cbf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0101cc6:	be 00 00 00 00       	mov    $0x0,%esi
f0101ccb:	eb 04                	jmp    f0101cd1 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101ccd:	c6 03 00             	movb   $0x0,(%ebx)
f0101cd0:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0101cd1:	8a 03                	mov    (%ebx),%al
f0101cd3:	84 c0                	test   %al,%al
f0101cd5:	74 5e                	je     f0101d35 <monitor+0xba>
f0101cd7:	0f be c0             	movsbl %al,%eax
f0101cda:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101cde:	c7 04 24 9b 8d 10 f0 	movl   $0xf0108d9b,(%esp)
f0101ce5:	e8 23 5e 00 00       	call   f0107b0d <strchr>
f0101cea:	85 c0                	test   %eax,%eax
f0101cec:	75 df                	jne    f0101ccd <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0101cee:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101cf1:	74 42                	je     f0101d35 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0101cf3:	83 fe 0f             	cmp    $0xf,%esi
f0101cf6:	75 16                	jne    f0101d0e <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101cf8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101cff:	00 
f0101d00:	c7 04 24 a0 8d 10 f0 	movl   $0xf0108da0,(%esp)
f0101d07:	e8 e2 3a 00 00       	call   f01057ee <cprintf>
f0101d0c:	eb 9f                	jmp    f0101cad <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0101d0e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0101d12:	46                   	inc    %esi
f0101d13:	eb 01                	jmp    f0101d16 <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0101d15:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101d16:	8a 03                	mov    (%ebx),%al
f0101d18:	84 c0                	test   %al,%al
f0101d1a:	74 b5                	je     f0101cd1 <monitor+0x56>
f0101d1c:	0f be c0             	movsbl %al,%eax
f0101d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d23:	c7 04 24 9b 8d 10 f0 	movl   $0xf0108d9b,(%esp)
f0101d2a:	e8 de 5d 00 00       	call   f0107b0d <strchr>
f0101d2f:	85 c0                	test   %eax,%eax
f0101d31:	74 e2                	je     f0101d15 <monitor+0x9a>
f0101d33:	eb 9c                	jmp    f0101cd1 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0101d35:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101d3c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101d3d:	85 f6                	test   %esi,%esi
f0101d3f:	0f 84 68 ff ff ff    	je     f0101cad <monitor+0x32>
f0101d45:	bb 00 9c 10 f0       	mov    $0xf0109c00,%ebx
f0101d4a:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101d4f:	8b 03                	mov    (%ebx),%eax
f0101d51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d55:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101d58:	89 04 24             	mov    %eax,(%esp)
f0101d5b:	e8 5a 5d 00 00       	call   f0107aba <strcmp>
f0101d60:	85 c0                	test   %eax,%eax
f0101d62:	75 24                	jne    f0101d88 <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0101d64:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0101d67:	8b 55 08             	mov    0x8(%ebp),%edx
f0101d6a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101d6e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101d71:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d75:	89 34 24             	mov    %esi,(%esp)
f0101d78:	ff 14 85 08 9c 10 f0 	call   *-0xfef63f8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101d7f:	85 c0                	test   %eax,%eax
f0101d81:	78 26                	js     f0101da9 <monitor+0x12e>
f0101d83:	e9 25 ff ff ff       	jmp    f0101cad <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0101d88:	47                   	inc    %edi
f0101d89:	83 c3 0c             	add    $0xc,%ebx
f0101d8c:	83 ff 0c             	cmp    $0xc,%edi
f0101d8f:	75 be                	jne    f0101d4f <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101d91:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101d94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d98:	c7 04 24 bd 8d 10 f0 	movl   $0xf0108dbd,(%esp)
f0101d9f:	e8 4a 3a 00 00       	call   f01057ee <cprintf>
f0101da4:	e9 04 ff ff ff       	jmp    f0101cad <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101da9:	83 c4 5c             	add    $0x5c,%esp
f0101dac:	5b                   	pop    %ebx
f0101dad:	5e                   	pop    %esi
f0101dae:	5f                   	pop    %edi
f0101daf:	5d                   	pop    %ebp
f0101db0:	c3                   	ret    

f0101db1 <Sign2Perm>:
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}

int Sign2Perm(char *s){
f0101db1:	55                   	push   %ebp
f0101db2:	89 e5                	mov    %esp,%ebp
f0101db4:	56                   	push   %esi
f0101db5:	53                   	push   %ebx
f0101db6:	83 ec 10             	sub    $0x10,%esp
f0101db9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int l = strlen(s);
f0101dbc:	89 1c 24             	mov    %ebx,(%esp)
f0101dbf:	e8 1c 5c 00 00       	call   f01079e0 <strlen>
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101dc4:	ba 00 00 00 00       	mov    $0x0,%edx
    return 0;
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
f0101dc9:	be 00 00 00 00       	mov    $0x0,%esi
	for (int i=0;i<l;i++){
f0101dce:	eb 47                	jmp    f0101e17 <Sign2Perm+0x66>
		switch(s[i]){
f0101dd0:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0101dd3:	83 e9 41             	sub    $0x41,%ecx
f0101dd6:	80 f9 16             	cmp    $0x16,%cl
f0101dd9:	77 42                	ja     f0101e1d <Sign2Perm+0x6c>
f0101ddb:	0f b6 c9             	movzbl %cl,%ecx
f0101dde:	ff 24 8d 88 9b 10 f0 	jmp    *-0xfef6478(,%ecx,4)
			case 'P':Perm|=PTE_P;break;
f0101de5:	83 ce 01             	or     $0x1,%esi
f0101de8:	eb 2c                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'W':Perm|=PTE_W;break;
f0101dea:	83 ce 02             	or     $0x2,%esi
f0101ded:	eb 27                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'U':Perm|=PTE_U;break;
f0101def:	83 ce 04             	or     $0x4,%esi
f0101df2:	eb 22                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'T':Perm|=PTE_PWT;break;
f0101df4:	83 ce 08             	or     $0x8,%esi
f0101df7:	eb 1d                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'C':Perm|=PTE_PCD;break;
f0101df9:	83 ce 10             	or     $0x10,%esi
f0101dfc:	eb 18                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'A':Perm|=PTE_A;break;
f0101dfe:	83 ce 20             	or     $0x20,%esi
f0101e01:	eb 13                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'D':Perm|=PTE_D;break;
f0101e03:	83 ce 40             	or     $0x40,%esi
f0101e06:	eb 0e                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'I':Perm|=PTE_PS;break;
f0101e08:	81 ce 80 00 00 00    	or     $0x80,%esi
f0101e0e:	eb 06                	jmp    f0101e16 <Sign2Perm+0x65>
			case 'G':Perm|=PTE_G;break;
f0101e10:	81 ce 00 01 00 00    	or     $0x100,%esi
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101e16:	42                   	inc    %edx
f0101e17:	39 c2                	cmp    %eax,%edx
f0101e19:	7c b5                	jl     f0101dd0 <Sign2Perm+0x1f>
f0101e1b:	eb 05                	jmp    f0101e22 <Sign2Perm+0x71>
			case 'C':Perm|=PTE_PCD;break;
			case 'A':Perm|=PTE_A;break;
			case 'D':Perm|=PTE_D;break;
			case 'I':Perm|=PTE_PS;break;
			case 'G':Perm|=PTE_G;break;
			default:return -1;
f0101e1d:	be ff ff ff ff       	mov    $0xffffffff,%esi
		}
	}
	return Perm;
}
f0101e22:	89 f0                	mov    %esi,%eax
f0101e24:	83 c4 10             	add    $0x10,%esp
f0101e27:	5b                   	pop    %ebx
f0101e28:	5e                   	pop    %esi
f0101e29:	5d                   	pop    %ebp
f0101e2a:	c3                   	ret    

f0101e2b <mon_clearpermissions>:
    cprintf("Permission has been updated:\n");
    mon_showmappings(argc-1,argv,tf);
    return 0;
}

int mon_clearpermissions(int argc, char **argv, struct Trapframe *tf){
f0101e2b:	55                   	push   %ebp
f0101e2c:	89 e5                	mov    %esp,%ebp
f0101e2e:	57                   	push   %edi
f0101e2f:	56                   	push   %esi
f0101e30:	53                   	push   %ebx
f0101e31:	83 ec 2c             	sub    $0x2c,%esp
f0101e34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc!=4){
f0101e37:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0101e3b:	74 11                	je     f0101e4e <mon_clearpermissions+0x23>
		cprintf("mon_clearpermissions: The number of parameters is three.\n");
f0101e3d:	c7 04 24 7c 96 10 f0 	movl   $0xf010967c,(%esp)
f0101e44:	e8 a5 39 00 00       	call   f01057ee <cprintf>
		return 0;
f0101e49:	e9 65 01 00 00       	jmp    f0101fb3 <mon_clearpermissions+0x188>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0101e4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e55:	00 
f0101e56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e5d:	8b 43 04             	mov    0x4(%ebx),%eax
f0101e60:	89 04 24             	mov    %eax,(%esp)
f0101e63:	e8 04 5e 00 00       	call   f0107c6c <strtol>
f0101e68:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0101e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101e6d:	80 38 00             	cmpb   $0x0,(%eax)
f0101e70:	74 11                	je     f0101e83 <mon_clearpermissions+0x58>
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
f0101e72:	c7 04 24 b8 96 10 f0 	movl   $0xf01096b8,(%esp)
f0101e79:	e8 70 39 00 00       	call   f01057ee <cprintf>
		return 0;
f0101e7e:	e9 30 01 00 00       	jmp    f0101fb3 <mon_clearpermissions+0x188>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101e83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e8a:	00 
f0101e8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e92:	8b 43 08             	mov    0x8(%ebx),%eax
f0101e95:	89 04 24             	mov    %eax,(%esp)
f0101e98:	e8 cf 5d 00 00       	call   f0107c6c <strtol>
	if (*errChar){
f0101e9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ea0:	80 3a 00             	cmpb   $0x0,(%edx)
f0101ea3:	74 11                	je     f0101eb6 <mon_clearpermissions+0x8b>
		cprintf("mon_clearpermissions: The second argument is not a number.\n");
f0101ea5:	c7 04 24 f4 96 10 f0 	movl   $0xf01096f4,(%esp)
f0101eac:	e8 3d 39 00 00       	call   f01057ee <cprintf>
		return 0;
f0101eb1:	e9 fd 00 00 00       	jmp    f0101fb3 <mon_clearpermissions+0x188>
	}
	if (StartAddr&0x3ff){
f0101eb6:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0101ebc:	74 11                	je     f0101ecf <mon_clearpermissions+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f0101ebe:	c7 04 24 68 90 10 f0 	movl   $0xf0109068,(%esp)
f0101ec5:	e8 24 39 00 00       	call   f01057ee <cprintf>
		return 0;
f0101eca:	e9 e4 00 00 00       	jmp    f0101fb3 <mon_clearpermissions+0x188>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101ecf:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0101ed1:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0101ed6:	74 11                	je     f0101ee9 <mon_clearpermissions+0xbe>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0101ed8:	c7 04 24 a4 90 10 f0 	movl   $0xf01090a4,(%esp)
f0101edf:	e8 0a 39 00 00       	call   f01057ee <cprintf>
		return 0;
f0101ee4:	e9 ca 00 00 00       	jmp    f0101fb3 <mon_clearpermissions+0x188>
	}
	if (StartAddr > EndAddr){
f0101ee9:	39 c6                	cmp    %eax,%esi
f0101eeb:	76 11                	jbe    f0101efe <mon_clearpermissions+0xd3>
		cprintf("mon_clearpermissions: The first parameter is larger than the second parameter.\n");
f0101eed:	c7 04 24 30 97 10 f0 	movl   $0xf0109730,(%esp)
f0101ef4:	e8 f5 38 00 00       	call   f01057ee <cprintf>
		return 0;
f0101ef9:	e9 b5 00 00 00       	jmp    f0101fb3 <mon_clearpermissions+0x188>
	}
	int Perm = Sign2Perm(argv[3]);
f0101efe:	8b 43 0c             	mov    0xc(%ebx),%eax
f0101f01:	89 04 24             	mov    %eax,(%esp)
f0101f04:	e8 a8 fe ff ff       	call   f0101db1 <Sign2Perm>
	if (Perm == -1){
f0101f09:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f0c:	75 7c                	jne    f0101f8a <mon_clearpermissions+0x15f>
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
f0101f0e:	c7 04 24 80 97 10 f0 	movl   $0xf0109780,(%esp)
f0101f15:	e8 d4 38 00 00       	call   f01057ee <cprintf>
		return 0;
f0101f1a:	e9 94 00 00 00       	jmp    f0101fb3 <mon_clearpermissions+0x188>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0101f1f:	89 f1                	mov    %esi,%ecx
f0101f21:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f0101f24:	8b 15 8c 6e 35 f0    	mov    0xf0356e8c,%edx
f0101f2a:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0101f2d:	f6 c2 01             	test   $0x1,%dl
f0101f30:	74 50                	je     f0101f82 <mon_clearpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0101f32:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f38:	89 d1                	mov    %edx,%ecx
f0101f3a:	c1 e9 0c             	shr    $0xc,%ecx
f0101f3d:	3b 0d 88 6e 35 f0    	cmp    0xf0356e88,%ecx
f0101f43:	72 20                	jb     f0101f65 <mon_clearpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f45:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101f49:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0101f50:	f0 
f0101f51:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f0101f58:	00 
f0101f59:	c7 04 24 a7 8c 10 f0 	movl   $0xf0108ca7,(%esp)
f0101f60:	e8 db e0 ff ff       	call   f0100040 <_panic>
f0101f65:	89 f1                	mov    %esi,%ecx
f0101f67:	c1 e9 0a             	shr    $0xa,%ecx
f0101f6a:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f0101f70:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f0101f77:	8b 0a                	mov    (%edx),%ecx
f0101f79:	f6 c1 01             	test   $0x1,%cl
f0101f7c:	74 04                	je     f0101f82 <mon_clearpermissions+0x157>
				*pte = *pte & ~Perm;
f0101f7e:	21 c1                	and    %eax,%ecx
f0101f80:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101f82:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101f88:	eb 02                	jmp    f0101f8c <mon_clearpermissions+0x161>
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				*pte = *pte & ~Perm;
f0101f8a:	f7 d0                	not    %eax
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101f8c:	39 fe                	cmp    %edi,%esi
f0101f8e:	72 8f                	jb     f0101f1f <mon_clearpermissions+0xf4>
				*pte = *pte & ~Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f0101f90:	c7 04 24 d3 8d 10 f0 	movl   $0xf0108dd3,(%esp)
f0101f97:	e8 52 38 00 00       	call   f01057ee <cprintf>
    mon_showmappings(argc-1,argv,tf);
f0101f9c:	8b 45 10             	mov    0x10(%ebp),%eax
f0101f9f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fa3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fa7:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f0101fae:	e8 b7 f0 ff ff       	call   f010106a <mon_showmappings>

    return 0;
}
f0101fb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0101fb8:	83 c4 2c             	add    $0x2c,%esp
f0101fbb:	5b                   	pop    %ebx
f0101fbc:	5e                   	pop    %esi
f0101fbd:	5f                   	pop    %edi
f0101fbe:	5d                   	pop    %ebp
f0101fbf:	c3                   	ret    

f0101fc0 <mon_setpermissions>:
			default:return -1;
		}
	}
	return Perm;
}
int mon_setpermissions(int argc, char **argv, struct Trapframe *tf){
f0101fc0:	55                   	push   %ebp
f0101fc1:	89 e5                	mov    %esp,%ebp
f0101fc3:	57                   	push   %edi
f0101fc4:	56                   	push   %esi
f0101fc5:	53                   	push   %ebx
f0101fc6:	83 ec 2c             	sub    $0x2c,%esp
f0101fc9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=4){
f0101fcc:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0101fd0:	74 11                	je     f0101fe3 <mon_setpermissions+0x23>
		cprintf("mon_setpermissions: The number of parameters is three.\n");
f0101fd2:	c7 04 24 c0 97 10 f0 	movl   $0xf01097c0,(%esp)
f0101fd9:	e8 10 38 00 00       	call   f01057ee <cprintf>
		return 0;
f0101fde:	e9 61 01 00 00       	jmp    f0102144 <mon_setpermissions+0x184>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0101fe3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fea:	00 
f0101feb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101fee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ff2:	8b 43 04             	mov    0x4(%ebx),%eax
f0101ff5:	89 04 24             	mov    %eax,(%esp)
f0101ff8:	e8 6f 5c 00 00       	call   f0107c6c <strtol>
f0101ffd:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0101fff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102002:	80 38 00             	cmpb   $0x0,(%eax)
f0102005:	74 11                	je     f0102018 <mon_setpermissions+0x58>
		cprintf("mon_setpermissions: The first argument is not a number.\n");
f0102007:	c7 04 24 f8 97 10 f0 	movl   $0xf01097f8,(%esp)
f010200e:	e8 db 37 00 00       	call   f01057ee <cprintf>
		return 0;
f0102013:	e9 2c 01 00 00       	jmp    f0102144 <mon_setpermissions+0x184>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0102018:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010201f:	00 
f0102020:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102023:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102027:	8b 43 08             	mov    0x8(%ebx),%eax
f010202a:	89 04 24             	mov    %eax,(%esp)
f010202d:	e8 3a 5c 00 00       	call   f0107c6c <strtol>
	if (*errChar){
f0102032:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102035:	80 3a 00             	cmpb   $0x0,(%edx)
f0102038:	74 11                	je     f010204b <mon_setpermissions+0x8b>
		cprintf("mon_setpermissions: The second argument is not a number\n");
f010203a:	c7 04 24 34 98 10 f0 	movl   $0xf0109834,(%esp)
f0102041:	e8 a8 37 00 00       	call   f01057ee <cprintf>
		return 0;
f0102046:	e9 f9 00 00 00       	jmp    f0102144 <mon_setpermissions+0x184>
	}
	if (StartAddr&0x3ff){
f010204b:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0102051:	74 11                	je     f0102064 <mon_setpermissions+0xa4>
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
f0102053:	c7 04 24 70 98 10 f0 	movl   $0xf0109870,(%esp)
f010205a:	e8 8f 37 00 00       	call   f01057ee <cprintf>
		return 0;
f010205f:	e9 e0 00 00 00       	jmp    f0102144 <mon_setpermissions+0x184>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_setpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0102064:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0102066:	a9 ff 03 00 00       	test   $0x3ff,%eax
f010206b:	74 11                	je     f010207e <mon_setpermissions+0xbe>
		cprintf("mon_setpermissions: The second parameter is not aligned.\n");
f010206d:	c7 04 24 ac 98 10 f0 	movl   $0xf01098ac,(%esp)
f0102074:	e8 75 37 00 00       	call   f01057ee <cprintf>
		return 0;
f0102079:	e9 c6 00 00 00       	jmp    f0102144 <mon_setpermissions+0x184>
	}
	if (StartAddr > EndAddr){
f010207e:	39 c6                	cmp    %eax,%esi
f0102080:	76 11                	jbe    f0102093 <mon_setpermissions+0xd3>
		cprintf("mon_setpermissions: The first parameter is larger than the second parameter.\n");
f0102082:	c7 04 24 e8 98 10 f0 	movl   $0xf01098e8,(%esp)
f0102089:	e8 60 37 00 00       	call   f01057ee <cprintf>
		return 0;
f010208e:	e9 b1 00 00 00       	jmp    f0102144 <mon_setpermissions+0x184>
	}
	int Perm = Sign2Perm(argv[3]);
f0102093:	8b 43 0c             	mov    0xc(%ebx),%eax
f0102096:	89 04 24             	mov    %eax,(%esp)
f0102099:	e8 13 fd ff ff       	call   f0101db1 <Sign2Perm>
	if (Perm == -1){
f010209e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020a1:	75 7a                	jne    f010211d <mon_setpermissions+0x15d>
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
f01020a3:	c7 04 24 38 99 10 f0 	movl   $0xf0109938,(%esp)
f01020aa:	e8 3f 37 00 00       	call   f01057ee <cprintf>
		return 0;
f01020af:	e9 90 00 00 00       	jmp    f0102144 <mon_setpermissions+0x184>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f01020b4:	89 f1                	mov    %esi,%ecx
f01020b6:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f01020b9:	8b 15 8c 6e 35 f0    	mov    0xf0356e8c,%edx
f01020bf:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f01020c2:	f6 c2 01             	test   $0x1,%dl
f01020c5:	74 50                	je     f0102117 <mon_setpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f01020c7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020cd:	89 d1                	mov    %edx,%ecx
f01020cf:	c1 e9 0c             	shr    $0xc,%ecx
f01020d2:	3b 0d 88 6e 35 f0    	cmp    0xf0356e88,%ecx
f01020d8:	72 20                	jb     f01020fa <mon_setpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020da:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01020de:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f01020e5:	f0 
f01020e6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f01020ed:	00 
f01020ee:	c7 04 24 a7 8c 10 f0 	movl   $0xf0108ca7,(%esp)
f01020f5:	e8 46 df ff ff       	call   f0100040 <_panic>
f01020fa:	89 f1                	mov    %esi,%ecx
f01020fc:	c1 e9 0a             	shr    $0xa,%ecx
f01020ff:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f0102105:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f010210c:	8b 0a                	mov    (%edx),%ecx
f010210e:	f6 c1 01             	test   $0x1,%cl
f0102111:	74 04                	je     f0102117 <mon_setpermissions+0x157>
				*pte = *pte | Perm;
f0102113:	09 c1                	or     %eax,%ecx
f0102115:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0102117:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010211d:	39 fe                	cmp    %edi,%esi
f010211f:	72 93                	jb     f01020b4 <mon_setpermissions+0xf4>
				*pte = *pte | Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f0102121:	c7 04 24 d3 8d 10 f0 	movl   $0xf0108dd3,(%esp)
f0102128:	e8 c1 36 00 00       	call   f01057ee <cprintf>
    mon_showmappings(argc-1,argv,tf);
f010212d:	8b 45 10             	mov    0x10(%ebp),%eax
f0102130:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102138:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f010213f:	e8 26 ef ff ff       	call   f010106a <mon_showmappings>
    return 0;
}
f0102144:	b8 00 00 00 00       	mov    $0x0,%eax
f0102149:	83 c4 2c             	add    $0x2c,%esp
f010214c:	5b                   	pop    %ebx
f010214d:	5e                   	pop    %esi
f010214e:	5f                   	pop    %edi
f010214f:	5d                   	pop    %ebp
f0102150:	c3                   	ret    
f0102151:	00 00                	add    %al,(%eax)
	...

f0102154 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0102154:	55                   	push   %ebp
f0102155:	89 e5                	mov    %esp,%ebp
f0102157:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f010215a:	89 d1                	mov    %edx,%ecx
f010215c:	c1 e9 16             	shr    $0x16,%ecx
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
f010215f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0102162:	a8 01                	test   $0x1,%al
f0102164:	74 4d                	je     f01021b3 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0102166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010216b:	89 c1                	mov    %eax,%ecx
f010216d:	c1 e9 0c             	shr    $0xc,%ecx
f0102170:	3b 0d 88 6e 35 f0    	cmp    0xf0356e88,%ecx
f0102176:	72 20                	jb     f0102198 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102178:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010217c:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0102183:	f0 
f0102184:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f010218b:	00 
f010218c:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102193:	e8 a8 de ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0102198:	c1 ea 0c             	shr    $0xc,%edx
f010219b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01021a1:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01021a8:	a8 01                	test   $0x1,%al
f01021aa:	74 0e                	je     f01021ba <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01021ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021b1:	eb 0c                	jmp    f01021bf <check_va2pa+0x6b>
	pgdir = &pgdir[PDX(va)];
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
		return ~0;
f01021b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01021b8:	eb 05                	jmp    f01021bf <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f01021ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f01021bf:	c9                   	leave  
f01021c0:	c3                   	ret    

f01021c1 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01021c1:	55                   	push   %ebp
f01021c2:	89 e5                	mov    %esp,%ebp
f01021c4:	83 ec 18             	sub    $0x18,%esp
f01021c7:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01021c9:	83 3d 44 62 35 f0 00 	cmpl   $0x0,0xf0356244
f01021d0:	75 0f                	jne    f01021e1 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01021d2:	b8 07 90 39 f0       	mov    $0xf0399007,%eax
f01021d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021dc:	a3 44 62 35 f0       	mov    %eax,0xf0356244
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n>0){
f01021e1:	85 d2                	test   %edx,%edx
f01021e3:	74 6d                	je     f0102252 <boot_alloc+0x91>
		result = nextfree;
f01021e5:	a1 44 62 35 f0       	mov    0xf0356244,%eax
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01021ea:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01021f1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021f7:	89 15 44 62 35 f0    	mov    %edx,0xf0356244
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021fd:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102203:	77 20                	ja     f0102225 <boot_alloc+0x64>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102205:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102209:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0102210:	f0 
f0102211:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
f0102218:	00 
f0102219:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102220:	e8 1b de ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102225:	81 c2 00 00 00 10    	add    $0x10000000,%edx
		if (PGNUM(PADDR(nextfree))>=npages)
f010222b:	c1 ea 0c             	shr    $0xc,%edx
f010222e:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f0102234:	72 21                	jb     f0102257 <boot_alloc+0x96>
			panic("boot_alloc: out of memory");
f0102236:	c7 44 24 08 75 a6 10 	movl   $0xf010a675,0x8(%esp)
f010223d:	f0 
f010223e:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0102245:	00 
f0102246:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010224d:	e8 ee dd ff ff       	call   f0100040 <_panic>
	}
	else{
		result = nextfree;
f0102252:	a1 44 62 35 f0       	mov    0xf0356244,%eax
	}
	// cprintf("boot_alloc %x %d\n",result,n);
	return result;
	// return NULL;
}
f0102257:	c9                   	leave  
f0102258:	c3                   	ret    

f0102259 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0102259:	55                   	push   %ebp
f010225a:	89 e5                	mov    %esp,%ebp
f010225c:	56                   	push   %esi
f010225d:	53                   	push   %ebx
f010225e:	83 ec 10             	sub    $0x10,%esp
f0102261:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0102263:	89 04 24             	mov    %eax,(%esp)
f0102266:	e8 3d 34 00 00       	call   f01056a8 <mc146818_read>
f010226b:	89 c6                	mov    %eax,%esi
f010226d:	43                   	inc    %ebx
f010226e:	89 1c 24             	mov    %ebx,(%esp)
f0102271:	e8 32 34 00 00       	call   f01056a8 <mc146818_read>
f0102276:	c1 e0 08             	shl    $0x8,%eax
f0102279:	09 f0                	or     %esi,%eax
}
f010227b:	83 c4 10             	add    $0x10,%esp
f010227e:	5b                   	pop    %ebx
f010227f:	5e                   	pop    %esi
f0102280:	5d                   	pop    %ebp
f0102281:	c3                   	ret    

f0102282 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0102282:	55                   	push   %ebp
f0102283:	89 e5                	mov    %esp,%ebp
f0102285:	57                   	push   %edi
f0102286:	56                   	push   %esi
f0102287:	53                   	push   %ebx
f0102288:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010228b:	3c 01                	cmp    $0x1,%al
f010228d:	19 f6                	sbb    %esi,%esi
f010228f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0102295:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0102296:	8b 15 48 62 35 f0    	mov    0xf0356248,%edx
f010229c:	85 d2                	test   %edx,%edx
f010229e:	75 1c                	jne    f01022bc <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f01022a0:	c7 44 24 08 90 9c 10 	movl   $0xf0109c90,0x8(%esp)
f01022a7:	f0 
f01022a8:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f01022af:	00 
f01022b0:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01022b7:	e8 84 dd ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f01022bc:	84 c0                	test   %al,%al
f01022be:	74 4b                	je     f010230b <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01022c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01022c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01022c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01022c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022cc:	89 d0                	mov    %edx,%eax
f01022ce:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f01022d4:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01022d7:	c1 e8 16             	shr    $0x16,%eax
f01022da:	39 c6                	cmp    %eax,%esi
f01022dc:	0f 96 c0             	setbe  %al
f01022df:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01022e2:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f01022e6:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01022e8:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01022ec:	8b 12                	mov    (%edx),%edx
f01022ee:	85 d2                	test   %edx,%edx
f01022f0:	75 da                	jne    f01022cc <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01022f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01022f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01022fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01022fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102301:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0102303:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102306:	a3 48 62 35 f0       	mov    %eax,0xf0356248
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f010230b:	8b 1d 48 62 35 f0    	mov    0xf0356248,%ebx
f0102311:	eb 63                	jmp    f0102376 <check_page_free_list+0xf4>
f0102313:	89 d8                	mov    %ebx,%eax
f0102315:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f010231b:	c1 f8 03             	sar    $0x3,%eax
f010231e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0102321:	89 c2                	mov    %eax,%edx
f0102323:	c1 ea 16             	shr    $0x16,%edx
f0102326:	39 d6                	cmp    %edx,%esi
f0102328:	76 4a                	jbe    f0102374 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010232a:	89 c2                	mov    %eax,%edx
f010232c:	c1 ea 0c             	shr    $0xc,%edx
f010232f:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f0102335:	72 20                	jb     f0102357 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102337:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010233b:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0102342:	f0 
f0102343:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010234a:	00 
f010234b:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0102352:	e8 e9 dc ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0102357:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010235e:	00 
f010235f:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0102366:	00 
	return (void *)(pa + KERNBASE);
f0102367:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010236c:	89 04 24             	mov    %eax,(%esp)
f010236f:	e8 ce 57 00 00       	call   f0107b42 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0102374:	8b 1b                	mov    (%ebx),%ebx
f0102376:	85 db                	test   %ebx,%ebx
f0102378:	75 99                	jne    f0102313 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f010237a:	b8 00 00 00 00       	mov    $0x0,%eax
f010237f:	e8 3d fe ff ff       	call   f01021c1 <boot_alloc>
f0102384:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102387:	8b 15 48 62 35 f0    	mov    0xf0356248,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010238d:	8b 0d 90 6e 35 f0    	mov    0xf0356e90,%ecx
		assert(pp < pages + npages);
f0102393:	a1 88 6e 35 f0       	mov    0xf0356e88,%eax
f0102398:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010239b:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010239e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01023a1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01023a4:	be 00 00 00 00       	mov    $0x0,%esi
f01023a9:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01023ac:	e9 c4 01 00 00       	jmp    f0102575 <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01023b1:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f01023b4:	73 24                	jae    f01023da <check_page_free_list+0x158>
f01023b6:	c7 44 24 0c 9d a6 10 	movl   $0xf010a69d,0xc(%esp)
f01023bd:	f0 
f01023be:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01023c5:	f0 
f01023c6:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01023cd:	00 
f01023ce:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01023d5:	e8 66 dc ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f01023da:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01023dd:	72 24                	jb     f0102403 <check_page_free_list+0x181>
f01023df:	c7 44 24 0c be a6 10 	movl   $0xf010a6be,0xc(%esp)
f01023e6:	f0 
f01023e7:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01023ee:	f0 
f01023ef:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f01023f6:	00 
f01023f7:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01023fe:	e8 3d dc ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0102403:	89 d0                	mov    %edx,%eax
f0102405:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0102408:	a8 07                	test   $0x7,%al
f010240a:	74 24                	je     f0102430 <check_page_free_list+0x1ae>
f010240c:	c7 44 24 0c b4 9c 10 	movl   $0xf0109cb4,0xc(%esp)
f0102413:	f0 
f0102414:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010241b:	f0 
f010241c:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0102423:	00 
f0102424:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010242b:	e8 10 dc ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102430:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0102433:	c1 e0 0c             	shl    $0xc,%eax
f0102436:	75 24                	jne    f010245c <check_page_free_list+0x1da>
f0102438:	c7 44 24 0c d2 a6 10 	movl   $0xf010a6d2,0xc(%esp)
f010243f:	f0 
f0102440:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102447:	f0 
f0102448:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f010244f:	00 
f0102450:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102457:	e8 e4 db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010245c:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0102461:	75 24                	jne    f0102487 <check_page_free_list+0x205>
f0102463:	c7 44 24 0c e3 a6 10 	movl   $0xf010a6e3,0xc(%esp)
f010246a:	f0 
f010246b:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102472:	f0 
f0102473:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f010247a:	00 
f010247b:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102482:	e8 b9 db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0102487:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010248c:	75 24                	jne    f01024b2 <check_page_free_list+0x230>
f010248e:	c7 44 24 0c e8 9c 10 	movl   $0xf0109ce8,0xc(%esp)
f0102495:	f0 
f0102496:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010249d:	f0 
f010249e:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f01024a5:	00 
f01024a6:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01024ad:	e8 8e db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01024b2:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01024b7:	75 24                	jne    f01024dd <check_page_free_list+0x25b>
f01024b9:	c7 44 24 0c fc a6 10 	movl   $0xf010a6fc,0xc(%esp)
f01024c0:	f0 
f01024c1:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01024c8:	f0 
f01024c9:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01024d0:	00 
f01024d1:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01024d8:	e8 63 db ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01024dd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01024e2:	76 59                	jbe    f010253d <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024e4:	89 c1                	mov    %eax,%ecx
f01024e6:	c1 e9 0c             	shr    $0xc,%ecx
f01024e9:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01024ec:	77 20                	ja     f010250e <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024f2:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f01024f9:	f0 
f01024fa:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102501:	00 
f0102502:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0102509:	e8 32 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010250e:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0102514:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0102517:	76 24                	jbe    f010253d <check_page_free_list+0x2bb>
f0102519:	c7 44 24 0c 0c 9d 10 	movl   $0xf0109d0c,0xc(%esp)
f0102520:	f0 
f0102521:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102528:	f0 
f0102529:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0102530:	00 
f0102531:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102538:	e8 03 db ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010253d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102542:	75 24                	jne    f0102568 <check_page_free_list+0x2e6>
f0102544:	c7 44 24 0c 16 a7 10 	movl   $0xf010a716,0xc(%esp)
f010254b:	f0 
f010254c:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102553:	f0 
f0102554:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f010255b:	00 
f010255c:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102563:	e8 d8 da ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0102568:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010256d:	77 03                	ja     f0102572 <check_page_free_list+0x2f0>
			++nfree_basemem;
f010256f:	46                   	inc    %esi
f0102570:	eb 01                	jmp    f0102573 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0102572:	43                   	inc    %ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102573:	8b 12                	mov    (%edx),%edx
f0102575:	85 d2                	test   %edx,%edx
f0102577:	0f 85 34 fe ff ff    	jne    f01023b1 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010257d:	85 f6                	test   %esi,%esi
f010257f:	7f 24                	jg     f01025a5 <check_page_free_list+0x323>
f0102581:	c7 44 24 0c 33 a7 10 	movl   $0xf010a733,0xc(%esp)
f0102588:	f0 
f0102589:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102590:	f0 
f0102591:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f0102598:	00 
f0102599:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01025a0:	e8 9b da ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01025a5:	85 db                	test   %ebx,%ebx
f01025a7:	7f 24                	jg     f01025cd <check_page_free_list+0x34b>
f01025a9:	c7 44 24 0c 45 a7 10 	movl   $0xf010a745,0xc(%esp)
f01025b0:	f0 
f01025b1:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01025b8:	f0 
f01025b9:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01025c0:	00 
f01025c1:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01025c8:	e8 73 da ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01025cd:	c7 04 24 54 9d 10 f0 	movl   $0xf0109d54,(%esp)
f01025d4:	e8 15 32 00 00       	call   f01057ee <cprintf>
}
f01025d9:	83 c4 4c             	add    $0x4c,%esp
f01025dc:	5b                   	pop    %ebx
f01025dd:	5e                   	pop    %esi
f01025de:	5f                   	pop    %edi
f01025df:	5d                   	pop    %ebp
f01025e0:	c3                   	ret    

f01025e1 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01025e1:	55                   	push   %ebp
f01025e2:	89 e5                	mov    %esp,%ebp
f01025e4:	56                   	push   %esi
f01025e5:	53                   	push   %ebx
f01025e6:	83 ec 10             	sub    $0x10,%esp
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	size_t i;
	pages[0].pp_ref = 1;
f01025e9:	a1 90 6e 35 f0       	mov    0xf0356e90,%eax
f01025ee:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f01025f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	size_t IOPAGE =  PGNUM(IOPHYSMEM);
	size_t EXTPAGE = PGNUM(EXTPHYSMEM);
	size_t FREEPAGE = PGNUM(PADDR(boot_alloc(0)));
f01025fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01025ff:	e8 bd fb ff ff       	call   f01021c1 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102604:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102609:	77 20                	ja     f010262b <page_init+0x4a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010260b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010260f:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0102616:	f0 
f0102617:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
f010261e:	00 
f010261f:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102626:	e8 15 da ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010262b:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0102631:	c1 eb 0c             	shr    $0xc,%ebx
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
f0102634:	83 3d 48 62 35 f0 00 	cmpl   $0x0,0xf0356248
f010263b:	74 24                	je     f0102661 <page_init+0x80>
f010263d:	c7 44 24 0c 56 a7 10 	movl   $0xf010a756,0xc(%esp)
f0102644:	f0 
f0102645:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010264c:	f0 
f010264d:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
f0102654:	00 
f0102655:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010265c:	e8 df d9 ff ff       	call   f0100040 <_panic>
 	assert(npages_basemem == IOPAGE);
f0102661:	81 3d 40 62 35 f0 a0 	cmpl   $0xa0,0xf0356240
f0102668:	00 00 00 
f010266b:	74 24                	je     f0102691 <page_init+0xb0>
f010266d:	c7 44 24 0c 6d a7 10 	movl   $0xf010a76d,0xc(%esp)
f0102674:	f0 
f0102675:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010267c:	f0 
f010267d:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0102684:	00 
f0102685:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010268c:	e8 af d9 ff ff       	call   f0100040 <_panic>
f0102691:	be 00 00 00 00       	mov    $0x0,%esi
f0102696:	b8 01 00 00 00       	mov    $0x1,%eax
    for (i = 1; i < IOPAGE; i++) {
		// cprintf("%x %x\n",i,PGNUM(MPENTRY_PADDR));
		if (i == PGNUM(MPENTRY_PADDR)){
f010269b:	83 f8 07             	cmp    $0x7,%eax
f010269e:	75 16                	jne    f01026b6 <page_init+0xd5>
			pages[i].pp_ref = 1;
f01026a0:	8b 15 90 6e 35 f0    	mov    0xf0356e90,%edx
f01026a6:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link = NULL;
f01026ac:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
 	assert(npages_basemem == IOPAGE);
    for (i = 1; i < IOPAGE; i++) {
f01026b3:	40                   	inc    %eax
f01026b4:	eb e5                	jmp    f010269b <page_init+0xba>
		if (i == PGNUM(MPENTRY_PADDR)){
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
		else {
        	pages[i].pp_ref = 0;
f01026b6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01026bd:	89 d1                	mov    %edx,%ecx
f01026bf:	03 0d 90 6e 35 f0    	add    0xf0356e90,%ecx
f01026c5:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        	pages[i].pp_link = page_free_list;
f01026cb:	89 31                	mov    %esi,(%ecx)
        	page_free_list = &pages[i];
f01026cd:	89 d6                	mov    %edx,%esi
f01026cf:	03 35 90 6e 35 f0    	add    0xf0356e90,%esi
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
 	assert(npages_basemem == IOPAGE);
    for (i = 1; i < IOPAGE; i++) {
f01026d5:	40                   	inc    %eax
f01026d6:	3d a0 00 00 00       	cmp    $0xa0,%eax
f01026db:	75 be                	jne    f010269b <page_init+0xba>
f01026dd:	89 35 48 62 35 f0    	mov    %esi,0xf0356248
f01026e3:	66 b8 00 05          	mov    $0x500,%ax
        	pages[i].pp_link = page_free_list;
        	page_free_list = &pages[i];
		}
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
f01026e7:	89 c2                	mov    %eax,%edx
f01026e9:	03 15 90 6e 35 f0    	add    0xf0356e90,%edx
f01026ef:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f01026f5:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f01026fb:	83 c0 08             	add    $0x8,%eax
        	pages[i].pp_ref = 0;
        	pages[i].pp_link = page_free_list;
        	page_free_list = &pages[i];
		}
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
f01026fe:	3d 00 08 00 00       	cmp    $0x800,%eax
f0102703:	75 e2                	jne    f01026e7 <page_init+0x106>
f0102705:	66 b8 00 01          	mov    $0x100,%ax
f0102709:	eb 1a                	jmp    f0102725 <page_init+0x144>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
f010270b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102712:	03 15 90 6e 35 f0    	add    0xf0356e90,%edx
f0102718:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f010271e:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
f0102724:	40                   	inc    %eax
f0102725:	39 d8                	cmp    %ebx,%eax
f0102727:	72 e2                	jb     f010270b <page_init+0x12a>
f0102729:	8b 0d 48 62 35 f0    	mov    0xf0356248,%ecx
f010272f:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0102736:	eb 1c                	jmp    f0102754 <page_init+0x173>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
        pages[i].pp_ref = 0;
f0102738:	89 c2                	mov    %eax,%edx
f010273a:	03 15 90 6e 35 f0    	add    0xf0356e90,%edx
f0102740:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0102746:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f0102748:	89 c1                	mov    %eax,%ecx
f010274a:	03 0d 90 6e 35 f0    	add    0xf0356e90,%ecx
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
f0102750:	43                   	inc    %ebx
f0102751:	83 c0 08             	add    $0x8,%eax
f0102754:	3b 1d 88 6e 35 f0    	cmp    0xf0356e88,%ebx
f010275a:	72 dc                	jb     f0102738 <page_init+0x157>
f010275c:	89 0d 48 62 35 f0    	mov    %ecx,0xf0356248
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	return;
}
f0102762:	83 c4 10             	add    $0x10,%esp
f0102765:	5b                   	pop    %ebx
f0102766:	5e                   	pop    %esi
f0102767:	5d                   	pop    %ebp
f0102768:	c3                   	ret    

f0102769 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0102769:	55                   	push   %ebp
f010276a:	89 e5                	mov    %esp,%ebp
f010276c:	53                   	push   %ebx
f010276d:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	// assert(page_free_list != NULL);
	// cprintf("page_alloc %x\n",page_free_list);
	// cprintf("page_alloc %x\n",page_free_list);
	if (page_free_list == NULL)return NULL;
f0102770:	8b 1d 48 62 35 f0    	mov    0xf0356248,%ebx
f0102776:	85 db                	test   %ebx,%ebx
f0102778:	74 6b                	je     f01027e5 <page_alloc+0x7c>
	struct PageInfo *alloc_page = page_free_list;
	page_free_list = alloc_page->pp_link;
f010277a:	8b 03                	mov    (%ebx),%eax
f010277c:	a3 48 62 35 f0       	mov    %eax,0xf0356248
	alloc_page->pp_link = NULL;
f0102781:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO){
f0102787:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010278b:	74 58                	je     f01027e5 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010278d:	89 d8                	mov    %ebx,%eax
f010278f:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f0102795:	c1 f8 03             	sar    $0x3,%eax
f0102798:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010279b:	89 c2                	mov    %eax,%edx
f010279d:	c1 ea 0c             	shr    $0xc,%edx
f01027a0:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f01027a6:	72 20                	jb     f01027c8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027ac:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f01027b3:	f0 
f01027b4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027bb:	00 
f01027bc:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f01027c3:	e8 78 d8 ff ff       	call   f0100040 <_panic>
		memset(page2kva(alloc_page),'\0',PGSIZE);
f01027c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01027cf:	00 
f01027d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027d7:	00 
	return (void *)(pa + KERNBASE);
f01027d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027dd:	89 04 24             	mov    %eax,(%esp)
f01027e0:	e8 5d 53 00 00       	call   f0107b42 <memset>
	}
	return alloc_page;
}
f01027e5:	89 d8                	mov    %ebx,%eax
f01027e7:	83 c4 14             	add    $0x14,%esp
f01027ea:	5b                   	pop    %ebx
f01027eb:	5d                   	pop    %ebp
f01027ec:	c3                   	ret    

f01027ed <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01027ed:	55                   	push   %ebp
f01027ee:	89 e5                	mov    %esp,%ebp
f01027f0:	83 ec 18             	sub    $0x18,%esp
f01027f3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link !=NULL)
f01027f6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01027fb:	75 05                	jne    f0102802 <page_free+0x15>
f01027fd:	83 38 00             	cmpl   $0x0,(%eax)
f0102800:	74 1c                	je     f010281e <page_free+0x31>
		panic("Something went wrong at page_free");
f0102802:	c7 44 24 08 78 9d 10 	movl   $0xf0109d78,0x8(%esp)
f0102809:	f0 
f010280a:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
f0102811:	00 
f0102812:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102819:	e8 22 d8 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010281e:	8b 15 48 62 35 f0    	mov    0xf0356248,%edx
f0102824:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0102826:	a3 48 62 35 f0       	mov    %eax,0xf0356248
	return;
}
f010282b:	c9                   	leave  
f010282c:	c3                   	ret    

f010282d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010282d:	55                   	push   %ebp
f010282e:	89 e5                	mov    %esp,%ebp
f0102830:	83 ec 18             	sub    $0x18,%esp
f0102833:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0102836:	8b 50 04             	mov    0x4(%eax),%edx
f0102839:	4a                   	dec    %edx
f010283a:	66 89 50 04          	mov    %dx,0x4(%eax)
f010283e:	66 85 d2             	test   %dx,%dx
f0102841:	75 08                	jne    f010284b <page_decref+0x1e>
		page_free(pp);
f0102843:	89 04 24             	mov    %eax,(%esp)
f0102846:	e8 a2 ff ff ff       	call   f01027ed <page_free>
}
f010284b:	c9                   	leave  
f010284c:	c3                   	ret    

f010284d <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010284d:	55                   	push   %ebp
f010284e:	89 e5                	mov    %esp,%ebp
f0102850:	56                   	push   %esi
f0102851:	53                   	push   %ebx
f0102852:	83 ec 10             	sub    $0x10,%esp
f0102855:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102858:	8b 45 10             	mov    0x10(%ebp),%eax
	// Fill this function in
	if (!((create == 0) || (create == 1)))
f010285b:	83 f8 01             	cmp    $0x1,%eax
f010285e:	76 1c                	jbe    f010287c <pgdir_walk+0x2f>
		panic("pgdir_walk: create is wrong!!!");
f0102860:	c7 44 24 08 9c 9d 10 	movl   $0xf0109d9c,0x8(%esp)
f0102867:	f0 
f0102868:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
f010286f:	00 
f0102870:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102877:	e8 c4 d7 ff ff       	call   f0100040 <_panic>
	
	pde_t *pde = &pgdir[PDX(va)];
f010287c:	89 f1                	mov    %esi,%ecx
f010287e:	c1 e9 16             	shr    $0x16,%ecx
f0102881:	8b 55 08             	mov    0x8(%ebp),%edx
f0102884:	8d 1c 8a             	lea    (%edx,%ecx,4),%ebx
	if ((*pde & PTE_P) == 0){
f0102887:	f6 03 01             	testb  $0x1,(%ebx)
f010288a:	75 29                	jne    f01028b5 <pgdir_walk+0x68>
		if (create == false){
f010288c:	85 c0                	test   %eax,%eax
f010288e:	74 6b                	je     f01028fb <pgdir_walk+0xae>
			return NULL;
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0102890:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102897:	e8 cd fe ff ff       	call   f0102769 <page_alloc>
			if (page==NULL) return NULL;
f010289c:	85 c0                	test   %eax,%eax
f010289e:	74 62                	je     f0102902 <pgdir_walk+0xb5>
			page->pp_ref++;
f01028a0:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028a4:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f01028aa:	c1 f8 03             	sar    $0x3,%eax
f01028ad:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f01028b0:	83 c8 07             	or     $0x7,%eax
f01028b3:	89 03                	mov    %eax,(%ebx)
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
f01028b5:	8b 03                	mov    (%ebx),%eax
f01028b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028bc:	89 c2                	mov    %eax,%edx
f01028be:	c1 ea 0c             	shr    $0xc,%edx
f01028c1:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f01028c7:	72 20                	jb     f01028e9 <pgdir_walk+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028cd:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f01028d4:	f0 
f01028d5:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
f01028dc:	00 
f01028dd:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01028e4:	e8 57 d7 ff ff       	call   f0100040 <_panic>
	return &pgtable[PTX(va)];
f01028e9:	c1 ee 0a             	shr    $0xa,%esi
f01028ec:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01028f2:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01028f9:	eb 0c                	jmp    f0102907 <pgdir_walk+0xba>
		panic("pgdir_walk: create is wrong!!!");
	
	pde_t *pde = &pgdir[PDX(va)];
	if ((*pde & PTE_P) == 0){
		if (create == false){
			return NULL;
f01028fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102900:	eb 05                	jmp    f0102907 <pgdir_walk+0xba>
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
			if (page==NULL) return NULL;
f0102902:	b8 00 00 00 00       	mov    $0x0,%eax
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	return &pgtable[PTX(va)];
}
f0102907:	83 c4 10             	add    $0x10,%esp
f010290a:	5b                   	pop    %ebx
f010290b:	5e                   	pop    %esi
f010290c:	5d                   	pop    %ebp
f010290d:	c3                   	ret    

f010290e <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010290e:	55                   	push   %ebp
f010290f:	89 e5                	mov    %esp,%ebp
f0102911:	57                   	push   %edi
f0102912:	56                   	push   %esi
f0102913:	53                   	push   %ebx
f0102914:	83 ec 2c             	sub    $0x2c,%esp
f0102917:	89 c6                	mov    %eax,%esi
f0102919:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010291c:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// assert(size % PGSIZE == 0);
	if (size % PGSIZE != 0){
f010291f:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f0102925:	74 1c                	je     f0102943 <boot_map_region+0x35>
		panic("boot_map_region: size % PGSIZE != 0");
f0102927:	c7 44 24 08 bc 9d 10 	movl   $0xf0109dbc,0x8(%esp)
f010292e:	f0 
f010292f:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
f0102936:	00 
f0102937:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010293e:	e8 fd d6 ff ff       	call   f0100040 <_panic>
	}
	if (PTE_ADDR(va) != va)
f0102943:	89 d1                	mov    %edx,%ecx
f0102945:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010294b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010294e:	39 d1                	cmp    %edx,%ecx
f0102950:	74 1c                	je     f010296e <boot_map_region+0x60>
		panic("boot_map_region: va is not page_aligned");
f0102952:	c7 44 24 08 e0 9d 10 	movl   $0xf0109de0,0x8(%esp)
f0102959:	f0 
f010295a:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
f0102961:	00 
f0102962:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102969:	e8 d2 d6 ff ff       	call   f0100040 <_panic>
	if (PTE_ADDR(pa) != pa)
f010296e:	89 c7                	mov    %eax,%edi
f0102970:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102976:	39 c7                	cmp    %eax,%edi
f0102978:	74 4b                	je     f01029c5 <boot_map_region+0xb7>
		panic("boot_map_region: pa is not page_aligned");
f010297a:	c7 44 24 08 08 9e 10 	movl   $0xf0109e08,0x8(%esp)
f0102981:	f0 
f0102982:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
f0102989:	00 
f010298a:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102991:	e8 aa d6 ff ff       	call   f0100040 <_panic>
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f0102996:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010299d:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f010299e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029a1:	01 d8                	add    %ebx,%eax
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f01029a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01029a7:	89 34 24             	mov    %esi,(%esp)
f01029aa:	e8 9e fe ff ff       	call   f010284d <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01029af:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f01029b2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01029b8:	0b 55 dc             	or     -0x24(%ebp),%edx
f01029bb:	89 10                	mov    %edx,(%eax)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f01029bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029c3:	eb 0e                	jmp    f01029d3 <boot_map_region+0xc5>
	if (size % PGSIZE != 0){
		panic("boot_map_region: size % PGSIZE != 0");
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
f01029c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f01029ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029cd:	83 c8 01             	or     $0x1,%eax
f01029d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f01029d3:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01029d6:	72 be                	jb     f0102996 <boot_map_region+0x88>
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
	}
}
f01029d8:	83 c4 2c             	add    $0x2c,%esp
f01029db:	5b                   	pop    %ebx
f01029dc:	5e                   	pop    %esi
f01029dd:	5f                   	pop    %edi
f01029de:	5d                   	pop    %ebp
f01029df:	c3                   	ret    

f01029e0 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01029e0:	55                   	push   %ebp
f01029e1:	89 e5                	mov    %esp,%ebp
f01029e3:	53                   	push   %ebx
f01029e4:	83 ec 14             	sub    $0x14,%esp
f01029e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
f01029ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01029f1:	00 
f01029f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01029f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01029fc:	89 04 24             	mov    %eax,(%esp)
f01029ff:	e8 49 fe ff ff       	call   f010284d <pgdir_walk>
	if (pte == NULL) return NULL;
f0102a04:	85 c0                	test   %eax,%eax
f0102a06:	74 3a                	je     f0102a42 <page_lookup+0x62>
	if (pte_store != NULL)
f0102a08:	85 db                	test   %ebx,%ebx
f0102a0a:	74 02                	je     f0102a0e <page_lookup+0x2e>
		*pte_store = pte;
f0102a0c:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));
f0102a0e:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a10:	c1 e8 0c             	shr    $0xc,%eax
f0102a13:	3b 05 88 6e 35 f0    	cmp    0xf0356e88,%eax
f0102a19:	72 1c                	jb     f0102a37 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0102a1b:	c7 44 24 08 30 9e 10 	movl   $0xf0109e30,0x8(%esp)
f0102a22:	f0 
f0102a23:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0102a2a:	00 
f0102a2b:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0102a32:	e8 09 d6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0102a37:	c1 e0 03             	shl    $0x3,%eax
f0102a3a:	03 05 90 6e 35 f0    	add    0xf0356e90,%eax
f0102a40:	eb 05                	jmp    f0102a47 <page_lookup+0x67>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
	if (pte == NULL) return NULL;
f0102a42:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store != NULL)
		*pte_store = pte;
	return pa2page(PTE_ADDR(*pte));
}
f0102a47:	83 c4 14             	add    $0x14,%esp
f0102a4a:	5b                   	pop    %ebx
f0102a4b:	5d                   	pop    %ebp
f0102a4c:	c3                   	ret    

f0102a4d <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102a4d:	55                   	push   %ebp
f0102a4e:	89 e5                	mov    %esp,%ebp
f0102a50:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0102a53:	e8 18 57 00 00       	call   f0108170 <cpunum>
f0102a58:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102a5f:	29 c2                	sub    %eax,%edx
f0102a61:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0102a64:	83 3c 85 28 70 35 f0 	cmpl   $0x0,-0xfca8fd8(,%eax,4)
f0102a6b:	00 
f0102a6c:	74 20                	je     f0102a8e <tlb_invalidate+0x41>
f0102a6e:	e8 fd 56 00 00       	call   f0108170 <cpunum>
f0102a73:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102a7a:	29 c2                	sub    %eax,%edx
f0102a7c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0102a7f:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0102a86:	8b 55 08             	mov    0x8(%ebp),%edx
f0102a89:	39 50 60             	cmp    %edx,0x60(%eax)
f0102a8c:	75 06                	jne    f0102a94 <tlb_invalidate+0x47>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a91:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0102a94:	c9                   	leave  
f0102a95:	c3                   	ret    

f0102a96 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0102a96:	55                   	push   %ebp
f0102a97:	89 e5                	mov    %esp,%ebp
f0102a99:	56                   	push   %esi
f0102a9a:	53                   	push   %ebx
f0102a9b:	83 ec 20             	sub    $0x20,%esp
f0102a9e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0102aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102aab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102aaf:	89 34 24             	mov    %esi,(%esp)
f0102ab2:	e8 29 ff ff ff       	call   f01029e0 <page_lookup>
	if(page != NULL){
f0102ab7:	85 c0                	test   %eax,%eax
f0102ab9:	74 1d                	je     f0102ad8 <page_remove+0x42>
		*pte = 0;
f0102abb:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102abe:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(page);
f0102ac4:	89 04 24             	mov    %eax,(%esp)
f0102ac7:	e8 61 fd ff ff       	call   f010282d <page_decref>
		tlb_invalidate(pgdir, va);
f0102acc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ad0:	89 34 24             	mov    %esi,(%esp)
f0102ad3:	e8 75 ff ff ff       	call   f0102a4d <tlb_invalidate>
	}
	return;
}
f0102ad8:	83 c4 20             	add    $0x20,%esp
f0102adb:	5b                   	pop    %ebx
f0102adc:	5e                   	pop    %esi
f0102add:	5d                   	pop    %ebp
f0102ade:	c3                   	ret    

f0102adf <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0102adf:	55                   	push   %ebp
f0102ae0:	89 e5                	mov    %esp,%ebp
f0102ae2:	57                   	push   %edi
f0102ae3:	56                   	push   %esi
f0102ae4:	53                   	push   %ebx
f0102ae5:	83 ec 1c             	sub    $0x1c,%esp
f0102ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102aeb:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
f0102aee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102af5:	00 
f0102af6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102afa:	8b 45 08             	mov    0x8(%ebp),%eax
f0102afd:	89 04 24             	mov    %eax,(%esp)
f0102b00:	e8 48 fd ff ff       	call   f010284d <pgdir_walk>
f0102b05:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0102b07:	85 c0                	test   %eax,%eax
f0102b09:	74 48                	je     f0102b53 <page_insert+0x74>
    pp->pp_ref++;
f0102b0b:	66 ff 46 04          	incw   0x4(%esi)
    if ((*pte & PTE_P) != 0) {
f0102b0f:	f6 00 01             	testb  $0x1,(%eax)
f0102b12:	74 1e                	je     f0102b32 <page_insert+0x53>
        page_remove(pgdir,va);
f0102b14:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b18:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b1b:	89 04 24             	mov    %eax,(%esp)
f0102b1e:	e8 73 ff ff ff       	call   f0102a96 <page_remove>
        tlb_invalidate(pgdir,va);
f0102b23:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b27:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b2a:	89 04 24             	mov    %eax,(%esp)
f0102b2d:	e8 1b ff ff ff       	call   f0102a4d <tlb_invalidate>
    }
    *pte = page2pa(pp) | perm | PTE_P;
f0102b32:	8b 55 14             	mov    0x14(%ebp),%edx
f0102b35:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b38:	2b 35 90 6e 35 f0    	sub    0xf0356e90,%esi
f0102b3e:	c1 fe 03             	sar    $0x3,%esi
f0102b41:	89 f0                	mov    %esi,%eax
f0102b43:	c1 e0 0c             	shl    $0xc,%eax
f0102b46:	89 d6                	mov    %edx,%esi
f0102b48:	09 c6                	or     %eax,%esi
f0102b4a:	89 33                	mov    %esi,(%ebx)
	return 0;
f0102b4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b51:	eb 05                	jmp    f0102b58 <page_insert+0x79>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
    if (pte == NULL) return -E_NO_MEM;
f0102b53:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir,va);
        tlb_invalidate(pgdir,va);
    }
    *pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0102b58:	83 c4 1c             	add    $0x1c,%esp
f0102b5b:	5b                   	pop    %ebx
f0102b5c:	5e                   	pop    %esi
f0102b5d:	5f                   	pop    %edi
f0102b5e:	5d                   	pop    %ebp
f0102b5f:	c3                   	ret    

f0102b60 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0102b60:	55                   	push   %ebp
f0102b61:	89 e5                	mov    %esp,%ebp
f0102b63:	53                   	push   %ebx
f0102b64:	83 ec 14             	sub    $0x14,%esp
f0102b67:	8b 45 08             	mov    0x8(%ebp),%eax
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// pa = ROUNDDOWN(pa,PGSIZE);
	if (PGOFF(base))
f0102b6a:	8b 15 5c f1 14 f0    	mov    0xf014f15c,%edx
f0102b70:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102b76:	74 1c                	je     f0102b94 <mmio_map_region+0x34>
		panic("mmio_map_region: base error!");
f0102b78:	c7 44 24 08 86 a7 10 	movl   $0xf010a786,0x8(%esp)
f0102b7f:	f0 
f0102b80:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0102b87:	00 
f0102b88:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102b8f:	e8 ac d4 ff ff       	call   f0100040 <_panic>
	size = ROUNDUP(pa + size,PGSIZE);
f0102b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102b97:	8d 9c 08 ff 0f 00 00 	lea    0xfff(%eax,%ecx,1),%ebx
f0102b9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa,PGSIZE);
f0102ba4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size -= pa;	
f0102ba9:	29 c3                	sub    %eax,%ebx
	if (size > PTSIZE || base + size >= MMIOLIM)
f0102bab:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f0102bb1:	77 0b                	ja     f0102bbe <mmio_map_region+0x5e>
f0102bb3:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0102bb6:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0102bbc:	76 1c                	jbe    f0102bda <mmio_map_region+0x7a>
		panic("mmio_map_region: error!");
f0102bbe:	c7 44 24 08 a3 a7 10 	movl   $0xf010a7a3,0x8(%esp)
f0102bc5:	f0 
f0102bc6:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f0102bcd:	00 
f0102bce:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102bd5:	e8 66 d4 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir,base,size,pa,PTE_PCD|PTE_PWT|PTE_W);
f0102bda:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0102be1:	00 
f0102be2:	89 04 24             	mov    %eax,(%esp)
f0102be5:	89 d9                	mov    %ebx,%ecx
f0102be7:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0102bec:	e8 1d fd ff ff       	call   f010290e <boot_map_region>
	base += size;
f0102bf1:	a1 5c f1 14 f0       	mov    0xf014f15c,%eax
f0102bf6:	01 c3                	add    %eax,%ebx
f0102bf8:	89 1d 5c f1 14 f0    	mov    %ebx,0xf014f15c
	return (void*)(base-size);
	panic("mmio_map_region not implemented");
}
f0102bfe:	83 c4 14             	add    $0x14,%esp
f0102c01:	5b                   	pop    %ebx
f0102c02:	5d                   	pop    %ebp
f0102c03:	c3                   	ret    

f0102c04 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0102c04:	55                   	push   %ebp
f0102c05:	89 e5                	mov    %esp,%ebp
f0102c07:	57                   	push   %edi
f0102c08:	56                   	push   %esi
f0102c09:	53                   	push   %ebx
f0102c0a:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0102c0d:	b8 15 00 00 00       	mov    $0x15,%eax
f0102c12:	e8 42 f6 ff ff       	call   f0102259 <nvram_read>
f0102c17:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0102c19:	b8 17 00 00 00       	mov    $0x17,%eax
f0102c1e:	e8 36 f6 ff ff       	call   f0102259 <nvram_read>
f0102c23:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0102c25:	b8 34 00 00 00       	mov    $0x34,%eax
f0102c2a:	e8 2a f6 ff ff       	call   f0102259 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0102c2f:	c1 e0 06             	shl    $0x6,%eax
f0102c32:	74 08                	je     f0102c3c <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f0102c34:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f0102c3a:	eb 0e                	jmp    f0102c4a <mem_init+0x46>
	else if (extmem)
f0102c3c:	85 f6                	test   %esi,%esi
f0102c3e:	74 08                	je     f0102c48 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0102c40:	81 c6 00 04 00 00    	add    $0x400,%esi
f0102c46:	eb 02                	jmp    f0102c4a <mem_init+0x46>
	else
		totalmem = basemem;
f0102c48:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f0102c4a:	89 f0                	mov    %esi,%eax
f0102c4c:	c1 e8 02             	shr    $0x2,%eax
f0102c4f:	a3 88 6e 35 f0       	mov    %eax,0xf0356e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0102c54:	89 d8                	mov    %ebx,%eax
f0102c56:	c1 e8 02             	shr    $0x2,%eax
f0102c59:	a3 40 62 35 f0       	mov    %eax,0xf0356240
	// cprintf("%u\n",ext16mem);
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0102c5e:	89 f0                	mov    %esi,%eax
f0102c60:	29 d8                	sub    %ebx,%eax
f0102c62:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c66:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102c6a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c6e:	c7 04 24 50 9e 10 f0 	movl   $0xf0109e50,(%esp)
f0102c75:	e8 74 2b 00 00       	call   f01057ee <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102c7a:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102c7f:	e8 3d f5 ff ff       	call   f01021c1 <boot_alloc>
f0102c84:	a3 8c 6e 35 f0       	mov    %eax,0xf0356e8c
	memset(kern_pgdir, 0, PGSIZE);
f0102c89:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c90:	00 
f0102c91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c98:	00 
f0102c99:	89 04 24             	mov    %eax,(%esp)
f0102c9c:	e8 a1 4e 00 00       	call   f0107b42 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0102ca1:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ca6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cab:	77 20                	ja     f0102ccd <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cb1:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0102cb8:	f0 
f0102cb9:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f0102cc0:	00 
f0102cc1:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102cc8:	e8 73 d3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ccd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102cd3:	83 ca 05             	or     $0x5,%edx
f0102cd6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);
f0102cdc:	a1 88 6e 35 f0       	mov    0xf0356e88,%eax
f0102ce1:	c1 e0 03             	shl    $0x3,%eax
f0102ce4:	e8 d8 f4 ff ff       	call   f01021c1 <boot_alloc>
f0102ce9:	a3 90 6e 35 f0       	mov    %eax,0xf0356e90
	// cprintf("npages: %x\n",npages);
	// cprintf("pages: %x\n",pages);
	memset(pages,0,sizeof(struct PageInfo) * npages);
f0102cee:	8b 15 88 6e 35 f0    	mov    0xf0356e88,%edx
f0102cf4:	c1 e2 03             	shl    $0x3,%edx
f0102cf7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102cfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d02:	00 
f0102d03:	89 04 24             	mov    %eax,(%esp)
f0102d06:	e8 37 4e 00 00       	call   f0107b42 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f0102d0b:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0102d10:	e8 ac f4 ff ff       	call   f01021c1 <boot_alloc>
f0102d15:	a3 50 62 35 f0       	mov    %eax,0xf0356250
	memset(envs, 0 ,sizeof(struct Env) * NENV);
f0102d1a:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0102d21:	00 
f0102d22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d29:	00 
f0102d2a:	89 04 24             	mov    %eax,(%esp)
f0102d2d:	e8 10 4e 00 00       	call   f0107b42 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0102d32:	e8 aa f8 ff ff       	call   f01025e1 <page_init>

	check_page_free_list(1);
f0102d37:	b8 01 00 00 00       	mov    $0x1,%eax
f0102d3c:	e8 41 f5 ff ff       	call   f0102282 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0102d41:	83 3d 90 6e 35 f0 00 	cmpl   $0x0,0xf0356e90
f0102d48:	75 1c                	jne    f0102d66 <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0102d4a:	c7 44 24 08 bb a7 10 	movl   $0xf010a7bb,0x8(%esp)
f0102d51:	f0 
f0102d52:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0102d59:	00 
f0102d5a:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102d61:	e8 da d2 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102d66:	a1 48 62 35 f0       	mov    0xf0356248,%eax
f0102d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102d70:	eb 03                	jmp    f0102d75 <mem_init+0x171>
		++nfree;
f0102d72:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102d73:	8b 00                	mov    (%eax),%eax
f0102d75:	85 c0                	test   %eax,%eax
f0102d77:	75 f9                	jne    f0102d72 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d80:	e8 e4 f9 ff ff       	call   f0102769 <page_alloc>
f0102d85:	89 c6                	mov    %eax,%esi
f0102d87:	85 c0                	test   %eax,%eax
f0102d89:	75 24                	jne    f0102daf <mem_init+0x1ab>
f0102d8b:	c7 44 24 0c d6 a7 10 	movl   $0xf010a7d6,0xc(%esp)
f0102d92:	f0 
f0102d93:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102d9a:	f0 
f0102d9b:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0102da2:	00 
f0102da3:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102daa:	e8 91 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102daf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102db6:	e8 ae f9 ff ff       	call   f0102769 <page_alloc>
f0102dbb:	89 c7                	mov    %eax,%edi
f0102dbd:	85 c0                	test   %eax,%eax
f0102dbf:	75 24                	jne    f0102de5 <mem_init+0x1e1>
f0102dc1:	c7 44 24 0c ec a7 10 	movl   $0xf010a7ec,0xc(%esp)
f0102dc8:	f0 
f0102dc9:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102dd0:	f0 
f0102dd1:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0102dd8:	00 
f0102dd9:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102de0:	e8 5b d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102de5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dec:	e8 78 f9 ff ff       	call   f0102769 <page_alloc>
f0102df1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102df4:	85 c0                	test   %eax,%eax
f0102df6:	75 24                	jne    f0102e1c <mem_init+0x218>
f0102df8:	c7 44 24 0c 02 a8 10 	movl   $0xf010a802,0xc(%esp)
f0102dff:	f0 
f0102e00:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102e07:	f0 
f0102e08:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0102e0f:	00 
f0102e10:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102e17:	e8 24 d2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102e1c:	39 fe                	cmp    %edi,%esi
f0102e1e:	75 24                	jne    f0102e44 <mem_init+0x240>
f0102e20:	c7 44 24 0c 18 a8 10 	movl   $0xf010a818,0xc(%esp)
f0102e27:	f0 
f0102e28:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102e2f:	f0 
f0102e30:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0102e37:	00 
f0102e38:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102e3f:	e8 fc d1 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102e44:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102e47:	74 05                	je     f0102e4e <mem_init+0x24a>
f0102e49:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102e4c:	75 24                	jne    f0102e72 <mem_init+0x26e>
f0102e4e:	c7 44 24 0c 8c 9e 10 	movl   $0xf0109e8c,0xc(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102e5d:	f0 
f0102e5e:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0102e65:	00 
f0102e66:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102e6d:	e8 ce d1 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e72:	8b 15 90 6e 35 f0    	mov    0xf0356e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102e78:	a1 88 6e 35 f0       	mov    0xf0356e88,%eax
f0102e7d:	c1 e0 0c             	shl    $0xc,%eax
f0102e80:	89 f1                	mov    %esi,%ecx
f0102e82:	29 d1                	sub    %edx,%ecx
f0102e84:	c1 f9 03             	sar    $0x3,%ecx
f0102e87:	c1 e1 0c             	shl    $0xc,%ecx
f0102e8a:	39 c1                	cmp    %eax,%ecx
f0102e8c:	72 24                	jb     f0102eb2 <mem_init+0x2ae>
f0102e8e:	c7 44 24 0c 2a a8 10 	movl   $0xf010a82a,0xc(%esp)
f0102e95:	f0 
f0102e96:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102e9d:	f0 
f0102e9e:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0102ea5:	00 
f0102ea6:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102ead:	e8 8e d1 ff ff       	call   f0100040 <_panic>
f0102eb2:	89 f9                	mov    %edi,%ecx
f0102eb4:	29 d1                	sub    %edx,%ecx
f0102eb6:	c1 f9 03             	sar    $0x3,%ecx
f0102eb9:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0102ebc:	39 c8                	cmp    %ecx,%eax
f0102ebe:	77 24                	ja     f0102ee4 <mem_init+0x2e0>
f0102ec0:	c7 44 24 0c 47 a8 10 	movl   $0xf010a847,0xc(%esp)
f0102ec7:	f0 
f0102ec8:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102ecf:	f0 
f0102ed0:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0102ed7:	00 
f0102ed8:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102edf:	e8 5c d1 ff ff       	call   f0100040 <_panic>
f0102ee4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ee7:	29 d1                	sub    %edx,%ecx
f0102ee9:	89 ca                	mov    %ecx,%edx
f0102eeb:	c1 fa 03             	sar    $0x3,%edx
f0102eee:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0102ef1:	39 d0                	cmp    %edx,%eax
f0102ef3:	77 24                	ja     f0102f19 <mem_init+0x315>
f0102ef5:	c7 44 24 0c 64 a8 10 	movl   $0xf010a864,0xc(%esp)
f0102efc:	f0 
f0102efd:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102f04:	f0 
f0102f05:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0102f0c:	00 
f0102f0d:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102f14:	e8 27 d1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102f19:	a1 48 62 35 f0       	mov    0xf0356248,%eax
f0102f1e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0102f21:	c7 05 48 62 35 f0 00 	movl   $0x0,0xf0356248
f0102f28:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102f2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f32:	e8 32 f8 ff ff       	call   f0102769 <page_alloc>
f0102f37:	85 c0                	test   %eax,%eax
f0102f39:	74 24                	je     f0102f5f <mem_init+0x35b>
f0102f3b:	c7 44 24 0c 81 a8 10 	movl   $0xf010a881,0xc(%esp)
f0102f42:	f0 
f0102f43:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102f4a:	f0 
f0102f4b:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0102f52:	00 
f0102f53:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102f5a:	e8 e1 d0 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102f5f:	89 34 24             	mov    %esi,(%esp)
f0102f62:	e8 86 f8 ff ff       	call   f01027ed <page_free>
	page_free(pp1);
f0102f67:	89 3c 24             	mov    %edi,(%esp)
f0102f6a:	e8 7e f8 ff ff       	call   f01027ed <page_free>
	page_free(pp2);
f0102f6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f72:	89 04 24             	mov    %eax,(%esp)
f0102f75:	e8 73 f8 ff ff       	call   f01027ed <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f81:	e8 e3 f7 ff ff       	call   f0102769 <page_alloc>
f0102f86:	89 c6                	mov    %eax,%esi
f0102f88:	85 c0                	test   %eax,%eax
f0102f8a:	75 24                	jne    f0102fb0 <mem_init+0x3ac>
f0102f8c:	c7 44 24 0c d6 a7 10 	movl   $0xf010a7d6,0xc(%esp)
f0102f93:	f0 
f0102f94:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102f9b:	f0 
f0102f9c:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0102fa3:	00 
f0102fa4:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102fab:	e8 90 d0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fb7:	e8 ad f7 ff ff       	call   f0102769 <page_alloc>
f0102fbc:	89 c7                	mov    %eax,%edi
f0102fbe:	85 c0                	test   %eax,%eax
f0102fc0:	75 24                	jne    f0102fe6 <mem_init+0x3e2>
f0102fc2:	c7 44 24 0c ec a7 10 	movl   $0xf010a7ec,0xc(%esp)
f0102fc9:	f0 
f0102fca:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0102fd1:	f0 
f0102fd2:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0102fd9:	00 
f0102fda:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0102fe1:	e8 5a d0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fe6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fed:	e8 77 f7 ff ff       	call   f0102769 <page_alloc>
f0102ff2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ff5:	85 c0                	test   %eax,%eax
f0102ff7:	75 24                	jne    f010301d <mem_init+0x419>
f0102ff9:	c7 44 24 0c 02 a8 10 	movl   $0xf010a802,0xc(%esp)
f0103000:	f0 
f0103001:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103008:	f0 
f0103009:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0103010:	00 
f0103011:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103018:	e8 23 d0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010301d:	39 fe                	cmp    %edi,%esi
f010301f:	75 24                	jne    f0103045 <mem_init+0x441>
f0103021:	c7 44 24 0c 18 a8 10 	movl   $0xf010a818,0xc(%esp)
f0103028:	f0 
f0103029:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103030:	f0 
f0103031:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0103038:	00 
f0103039:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103040:	e8 fb cf ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0103045:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0103048:	74 05                	je     f010304f <mem_init+0x44b>
f010304a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010304d:	75 24                	jne    f0103073 <mem_init+0x46f>
f010304f:	c7 44 24 0c 8c 9e 10 	movl   $0xf0109e8c,0xc(%esp)
f0103056:	f0 
f0103057:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010305e:	f0 
f010305f:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0103066:	00 
f0103067:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010306e:	e8 cd cf ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0103073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010307a:	e8 ea f6 ff ff       	call   f0102769 <page_alloc>
f010307f:	85 c0                	test   %eax,%eax
f0103081:	74 24                	je     f01030a7 <mem_init+0x4a3>
f0103083:	c7 44 24 0c 81 a8 10 	movl   $0xf010a881,0xc(%esp)
f010308a:	f0 
f010308b:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103092:	f0 
f0103093:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f010309a:	00 
f010309b:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01030a2:	e8 99 cf ff ff       	call   f0100040 <_panic>
f01030a7:	89 f0                	mov    %esi,%eax
f01030a9:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f01030af:	c1 f8 03             	sar    $0x3,%eax
f01030b2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030b5:	89 c2                	mov    %eax,%edx
f01030b7:	c1 ea 0c             	shr    $0xc,%edx
f01030ba:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f01030c0:	72 20                	jb     f01030e2 <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030c6:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f01030cd:	f0 
f01030ce:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01030d5:	00 
f01030d6:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f01030dd:	e8 5e cf ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01030e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030e9:	00 
f01030ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01030f1:	00 
	return (void *)(pa + KERNBASE);
f01030f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01030f7:	89 04 24             	mov    %eax,(%esp)
f01030fa:	e8 43 4a 00 00       	call   f0107b42 <memset>
	page_free(pp0);
f01030ff:	89 34 24             	mov    %esi,(%esp)
f0103102:	e8 e6 f6 ff ff       	call   f01027ed <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0103107:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010310e:	e8 56 f6 ff ff       	call   f0102769 <page_alloc>
f0103113:	85 c0                	test   %eax,%eax
f0103115:	75 24                	jne    f010313b <mem_init+0x537>
f0103117:	c7 44 24 0c 90 a8 10 	movl   $0xf010a890,0xc(%esp)
f010311e:	f0 
f010311f:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103126:	f0 
f0103127:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f010312e:	00 
f010312f:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103136:	e8 05 cf ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010313b:	39 c6                	cmp    %eax,%esi
f010313d:	74 24                	je     f0103163 <mem_init+0x55f>
f010313f:	c7 44 24 0c ae a8 10 	movl   $0xf010a8ae,0xc(%esp)
f0103146:	f0 
f0103147:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010314e:	f0 
f010314f:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0103156:	00 
f0103157:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010315e:	e8 dd ce ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103163:	89 f2                	mov    %esi,%edx
f0103165:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f010316b:	c1 fa 03             	sar    $0x3,%edx
f010316e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103171:	89 d0                	mov    %edx,%eax
f0103173:	c1 e8 0c             	shr    $0xc,%eax
f0103176:	3b 05 88 6e 35 f0    	cmp    0xf0356e88,%eax
f010317c:	72 20                	jb     f010319e <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010317e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103182:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0103189:	f0 
f010318a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103191:	00 
f0103192:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0103199:	e8 a2 ce ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010319e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01031a4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01031aa:	80 38 00             	cmpb   $0x0,(%eax)
f01031ad:	74 24                	je     f01031d3 <mem_init+0x5cf>
f01031af:	c7 44 24 0c be a8 10 	movl   $0xf010a8be,0xc(%esp)
f01031b6:	f0 
f01031b7:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01031be:	f0 
f01031bf:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01031c6:	00 
f01031c7:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01031ce:	e8 6d ce ff ff       	call   f0100040 <_panic>
f01031d3:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01031d4:	39 d0                	cmp    %edx,%eax
f01031d6:	75 d2                	jne    f01031aa <mem_init+0x5a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01031d8:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01031db:	89 15 48 62 35 f0    	mov    %edx,0xf0356248

	// free the pages we took
	page_free(pp0);
f01031e1:	89 34 24             	mov    %esi,(%esp)
f01031e4:	e8 04 f6 ff ff       	call   f01027ed <page_free>
	page_free(pp1);
f01031e9:	89 3c 24             	mov    %edi,(%esp)
f01031ec:	e8 fc f5 ff ff       	call   f01027ed <page_free>
	page_free(pp2);
f01031f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031f4:	89 04 24             	mov    %eax,(%esp)
f01031f7:	e8 f1 f5 ff ff       	call   f01027ed <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01031fc:	a1 48 62 35 f0       	mov    0xf0356248,%eax
f0103201:	eb 03                	jmp    f0103206 <mem_init+0x602>
		--nfree;
f0103203:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0103204:	8b 00                	mov    (%eax),%eax
f0103206:	85 c0                	test   %eax,%eax
f0103208:	75 f9                	jne    f0103203 <mem_init+0x5ff>
		--nfree;
	assert(nfree == 0);
f010320a:	85 db                	test   %ebx,%ebx
f010320c:	74 24                	je     f0103232 <mem_init+0x62e>
f010320e:	c7 44 24 0c c8 a8 10 	movl   $0xf010a8c8,0xc(%esp)
f0103215:	f0 
f0103216:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010321d:	f0 
f010321e:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0103225:	00 
f0103226:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010322d:	e8 0e ce ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0103232:	c7 04 24 ac 9e 10 f0 	movl   $0xf0109eac,(%esp)
f0103239:	e8 b0 25 00 00       	call   f01057ee <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010323e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103245:	e8 1f f5 ff ff       	call   f0102769 <page_alloc>
f010324a:	89 c7                	mov    %eax,%edi
f010324c:	85 c0                	test   %eax,%eax
f010324e:	75 24                	jne    f0103274 <mem_init+0x670>
f0103250:	c7 44 24 0c d6 a7 10 	movl   $0xf010a7d6,0xc(%esp)
f0103257:	f0 
f0103258:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010325f:	f0 
f0103260:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0103267:	00 
f0103268:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010326f:	e8 cc cd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0103274:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010327b:	e8 e9 f4 ff ff       	call   f0102769 <page_alloc>
f0103280:	89 c6                	mov    %eax,%esi
f0103282:	85 c0                	test   %eax,%eax
f0103284:	75 24                	jne    f01032aa <mem_init+0x6a6>
f0103286:	c7 44 24 0c ec a7 10 	movl   $0xf010a7ec,0xc(%esp)
f010328d:	f0 
f010328e:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103295:	f0 
f0103296:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f010329d:	00 
f010329e:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01032a5:	e8 96 cd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01032aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032b1:	e8 b3 f4 ff ff       	call   f0102769 <page_alloc>
f01032b6:	89 c3                	mov    %eax,%ebx
f01032b8:	85 c0                	test   %eax,%eax
f01032ba:	75 24                	jne    f01032e0 <mem_init+0x6dc>
f01032bc:	c7 44 24 0c 02 a8 10 	movl   $0xf010a802,0xc(%esp)
f01032c3:	f0 
f01032c4:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01032cb:	f0 
f01032cc:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f01032d3:	00 
f01032d4:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01032db:	e8 60 cd ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01032e0:	39 f7                	cmp    %esi,%edi
f01032e2:	75 24                	jne    f0103308 <mem_init+0x704>
f01032e4:	c7 44 24 0c 18 a8 10 	movl   $0xf010a818,0xc(%esp)
f01032eb:	f0 
f01032ec:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01032f3:	f0 
f01032f4:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01032fb:	00 
f01032fc:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103303:	e8 38 cd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0103308:	39 c6                	cmp    %eax,%esi
f010330a:	74 04                	je     f0103310 <mem_init+0x70c>
f010330c:	39 c7                	cmp    %eax,%edi
f010330e:	75 24                	jne    f0103334 <mem_init+0x730>
f0103310:	c7 44 24 0c 8c 9e 10 	movl   $0xf0109e8c,0xc(%esp)
f0103317:	f0 
f0103318:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010331f:	f0 
f0103320:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0103327:	00 
f0103328:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010332f:	e8 0c cd ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0103334:	8b 15 48 62 35 f0    	mov    0xf0356248,%edx
f010333a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010333d:	c7 05 48 62 35 f0 00 	movl   $0x0,0xf0356248
f0103344:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0103347:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010334e:	e8 16 f4 ff ff       	call   f0102769 <page_alloc>
f0103353:	85 c0                	test   %eax,%eax
f0103355:	74 24                	je     f010337b <mem_init+0x777>
f0103357:	c7 44 24 0c 81 a8 10 	movl   $0xf010a881,0xc(%esp)
f010335e:	f0 
f010335f:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103366:	f0 
f0103367:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f010336e:	00 
f010336f:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103376:	e8 c5 cc ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010337b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010337e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103382:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103389:	00 
f010338a:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010338f:	89 04 24             	mov    %eax,(%esp)
f0103392:	e8 49 f6 ff ff       	call   f01029e0 <page_lookup>
f0103397:	85 c0                	test   %eax,%eax
f0103399:	74 24                	je     f01033bf <mem_init+0x7bb>
f010339b:	c7 44 24 0c cc 9e 10 	movl   $0xf0109ecc,0xc(%esp)
f01033a2:	f0 
f01033a3:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01033aa:	f0 
f01033ab:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f01033b2:	00 
f01033b3:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01033ba:	e8 81 cc ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01033bf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01033c6:	00 
f01033c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01033ce:	00 
f01033cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033d3:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01033d8:	89 04 24             	mov    %eax,(%esp)
f01033db:	e8 ff f6 ff ff       	call   f0102adf <page_insert>
f01033e0:	85 c0                	test   %eax,%eax
f01033e2:	78 24                	js     f0103408 <mem_init+0x804>
f01033e4:	c7 44 24 0c 04 9f 10 	movl   $0xf0109f04,0xc(%esp)
f01033eb:	f0 
f01033ec:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01033f3:	f0 
f01033f4:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01033fb:	00 
f01033fc:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103403:	e8 38 cc ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0103408:	89 3c 24             	mov    %edi,(%esp)
f010340b:	e8 dd f3 ff ff       	call   f01027ed <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0103410:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103417:	00 
f0103418:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010341f:	00 
f0103420:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103424:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103429:	89 04 24             	mov    %eax,(%esp)
f010342c:	e8 ae f6 ff ff       	call   f0102adf <page_insert>
f0103431:	85 c0                	test   %eax,%eax
f0103433:	74 24                	je     f0103459 <mem_init+0x855>
f0103435:	c7 44 24 0c 34 9f 10 	movl   $0xf0109f34,0xc(%esp)
f010343c:	f0 
f010343d:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103444:	f0 
f0103445:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f010344c:	00 
f010344d:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103454:	e8 e7 cb ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103459:	8b 0d 8c 6e 35 f0    	mov    0xf0356e8c,%ecx
f010345f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103462:	a1 90 6e 35 f0       	mov    0xf0356e90,%eax
f0103467:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010346a:	8b 11                	mov    (%ecx),%edx
f010346c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103472:	89 f8                	mov    %edi,%eax
f0103474:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103477:	c1 f8 03             	sar    $0x3,%eax
f010347a:	c1 e0 0c             	shl    $0xc,%eax
f010347d:	39 c2                	cmp    %eax,%edx
f010347f:	74 24                	je     f01034a5 <mem_init+0x8a1>
f0103481:	c7 44 24 0c 64 9f 10 	movl   $0xf0109f64,0xc(%esp)
f0103488:	f0 
f0103489:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103490:	f0 
f0103491:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0103498:	00 
f0103499:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01034a0:	e8 9b cb ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01034a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01034aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034ad:	e8 a2 ec ff ff       	call   f0102154 <check_va2pa>
f01034b2:	89 f2                	mov    %esi,%edx
f01034b4:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01034b7:	c1 fa 03             	sar    $0x3,%edx
f01034ba:	c1 e2 0c             	shl    $0xc,%edx
f01034bd:	39 d0                	cmp    %edx,%eax
f01034bf:	74 24                	je     f01034e5 <mem_init+0x8e1>
f01034c1:	c7 44 24 0c 8c 9f 10 	movl   $0xf0109f8c,0xc(%esp)
f01034c8:	f0 
f01034c9:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01034d0:	f0 
f01034d1:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f01034d8:	00 
f01034d9:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01034e0:	e8 5b cb ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01034e5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01034ea:	74 24                	je     f0103510 <mem_init+0x90c>
f01034ec:	c7 44 24 0c d3 a8 10 	movl   $0xf010a8d3,0xc(%esp)
f01034f3:	f0 
f01034f4:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01034fb:	f0 
f01034fc:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0103503:	00 
f0103504:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010350b:	e8 30 cb ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0103510:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103515:	74 24                	je     f010353b <mem_init+0x937>
f0103517:	c7 44 24 0c e4 a8 10 	movl   $0xf010a8e4,0xc(%esp)
f010351e:	f0 
f010351f:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103526:	f0 
f0103527:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f010352e:	00 
f010352f:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103536:	e8 05 cb ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010353b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103542:	00 
f0103543:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010354a:	00 
f010354b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010354f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103552:	89 14 24             	mov    %edx,(%esp)
f0103555:	e8 85 f5 ff ff       	call   f0102adf <page_insert>
f010355a:	85 c0                	test   %eax,%eax
f010355c:	74 24                	je     f0103582 <mem_init+0x97e>
f010355e:	c7 44 24 0c bc 9f 10 	movl   $0xf0109fbc,0xc(%esp)
f0103565:	f0 
f0103566:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010356d:	f0 
f010356e:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0103575:	00 
f0103576:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010357d:	e8 be ca ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103582:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103587:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010358c:	e8 c3 eb ff ff       	call   f0102154 <check_va2pa>
f0103591:	89 da                	mov    %ebx,%edx
f0103593:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0103599:	c1 fa 03             	sar    $0x3,%edx
f010359c:	c1 e2 0c             	shl    $0xc,%edx
f010359f:	39 d0                	cmp    %edx,%eax
f01035a1:	74 24                	je     f01035c7 <mem_init+0x9c3>
f01035a3:	c7 44 24 0c f8 9f 10 	movl   $0xf0109ff8,0xc(%esp)
f01035aa:	f0 
f01035ab:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01035b2:	f0 
f01035b3:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01035ba:	00 
f01035bb:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01035c2:	e8 79 ca ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01035c7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01035cc:	74 24                	je     f01035f2 <mem_init+0x9ee>
f01035ce:	c7 44 24 0c f5 a8 10 	movl   $0xf010a8f5,0xc(%esp)
f01035d5:	f0 
f01035d6:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01035dd:	f0 
f01035de:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01035e5:	00 
f01035e6:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01035ed:	e8 4e ca ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01035f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035f9:	e8 6b f1 ff ff       	call   f0102769 <page_alloc>
f01035fe:	85 c0                	test   %eax,%eax
f0103600:	74 24                	je     f0103626 <mem_init+0xa22>
f0103602:	c7 44 24 0c 81 a8 10 	movl   $0xf010a881,0xc(%esp)
f0103609:	f0 
f010360a:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103611:	f0 
f0103612:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0103619:	00 
f010361a:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103621:	e8 1a ca ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103626:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010362d:	00 
f010362e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103635:	00 
f0103636:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010363a:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010363f:	89 04 24             	mov    %eax,(%esp)
f0103642:	e8 98 f4 ff ff       	call   f0102adf <page_insert>
f0103647:	85 c0                	test   %eax,%eax
f0103649:	74 24                	je     f010366f <mem_init+0xa6b>
f010364b:	c7 44 24 0c bc 9f 10 	movl   $0xf0109fbc,0xc(%esp)
f0103652:	f0 
f0103653:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010365a:	f0 
f010365b:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0103662:	00 
f0103663:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010366a:	e8 d1 c9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010366f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103674:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103679:	e8 d6 ea ff ff       	call   f0102154 <check_va2pa>
f010367e:	89 da                	mov    %ebx,%edx
f0103680:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0103686:	c1 fa 03             	sar    $0x3,%edx
f0103689:	c1 e2 0c             	shl    $0xc,%edx
f010368c:	39 d0                	cmp    %edx,%eax
f010368e:	74 24                	je     f01036b4 <mem_init+0xab0>
f0103690:	c7 44 24 0c f8 9f 10 	movl   $0xf0109ff8,0xc(%esp)
f0103697:	f0 
f0103698:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010369f:	f0 
f01036a0:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01036a7:	00 
f01036a8:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01036af:	e8 8c c9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01036b4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01036b9:	74 24                	je     f01036df <mem_init+0xadb>
f01036bb:	c7 44 24 0c f5 a8 10 	movl   $0xf010a8f5,0xc(%esp)
f01036c2:	f0 
f01036c3:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01036ca:	f0 
f01036cb:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f01036d2:	00 
f01036d3:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01036da:	e8 61 c9 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01036df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01036e6:	e8 7e f0 ff ff       	call   f0102769 <page_alloc>
f01036eb:	85 c0                	test   %eax,%eax
f01036ed:	74 24                	je     f0103713 <mem_init+0xb0f>
f01036ef:	c7 44 24 0c 81 a8 10 	movl   $0xf010a881,0xc(%esp)
f01036f6:	f0 
f01036f7:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01036fe:	f0 
f01036ff:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0103706:	00 
f0103707:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010370e:	e8 2d c9 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0103713:	8b 15 8c 6e 35 f0    	mov    0xf0356e8c,%edx
f0103719:	8b 02                	mov    (%edx),%eax
f010371b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103720:	89 c1                	mov    %eax,%ecx
f0103722:	c1 e9 0c             	shr    $0xc,%ecx
f0103725:	3b 0d 88 6e 35 f0    	cmp    0xf0356e88,%ecx
f010372b:	72 20                	jb     f010374d <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010372d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103731:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0103738:	f0 
f0103739:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0103740:	00 
f0103741:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103748:	e8 f3 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010374d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103752:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0103755:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010375c:	00 
f010375d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103764:	00 
f0103765:	89 14 24             	mov    %edx,(%esp)
f0103768:	e8 e0 f0 ff ff       	call   f010284d <pgdir_walk>
f010376d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103770:	83 c2 04             	add    $0x4,%edx
f0103773:	39 d0                	cmp    %edx,%eax
f0103775:	74 24                	je     f010379b <mem_init+0xb97>
f0103777:	c7 44 24 0c 28 a0 10 	movl   $0xf010a028,0xc(%esp)
f010377e:	f0 
f010377f:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103786:	f0 
f0103787:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010378e:	00 
f010378f:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103796:	e8 a5 c8 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010379b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01037a2:	00 
f01037a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037aa:	00 
f01037ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01037af:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01037b4:	89 04 24             	mov    %eax,(%esp)
f01037b7:	e8 23 f3 ff ff       	call   f0102adf <page_insert>
f01037bc:	85 c0                	test   %eax,%eax
f01037be:	74 24                	je     f01037e4 <mem_init+0xbe0>
f01037c0:	c7 44 24 0c 68 a0 10 	movl   $0xf010a068,0xc(%esp)
f01037c7:	f0 
f01037c8:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01037cf:	f0 
f01037d0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01037d7:	00 
f01037d8:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01037df:	e8 5c c8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01037e4:	8b 0d 8c 6e 35 f0    	mov    0xf0356e8c,%ecx
f01037ea:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01037ed:	ba 00 10 00 00       	mov    $0x1000,%edx
f01037f2:	89 c8                	mov    %ecx,%eax
f01037f4:	e8 5b e9 ff ff       	call   f0102154 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01037f9:	89 da                	mov    %ebx,%edx
f01037fb:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0103801:	c1 fa 03             	sar    $0x3,%edx
f0103804:	c1 e2 0c             	shl    $0xc,%edx
f0103807:	39 d0                	cmp    %edx,%eax
f0103809:	74 24                	je     f010382f <mem_init+0xc2b>
f010380b:	c7 44 24 0c f8 9f 10 	movl   $0xf0109ff8,0xc(%esp)
f0103812:	f0 
f0103813:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010381a:	f0 
f010381b:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0103822:	00 
f0103823:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010382a:	e8 11 c8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010382f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103834:	74 24                	je     f010385a <mem_init+0xc56>
f0103836:	c7 44 24 0c f5 a8 10 	movl   $0xf010a8f5,0xc(%esp)
f010383d:	f0 
f010383e:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103845:	f0 
f0103846:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f010384d:	00 
f010384e:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103855:	e8 e6 c7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010385a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103861:	00 
f0103862:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103869:	00 
f010386a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010386d:	89 04 24             	mov    %eax,(%esp)
f0103870:	e8 d8 ef ff ff       	call   f010284d <pgdir_walk>
f0103875:	f6 00 04             	testb  $0x4,(%eax)
f0103878:	75 24                	jne    f010389e <mem_init+0xc9a>
f010387a:	c7 44 24 0c a8 a0 10 	movl   $0xf010a0a8,0xc(%esp)
f0103881:	f0 
f0103882:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103889:	f0 
f010388a:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0103891:	00 
f0103892:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103899:	e8 a2 c7 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010389e:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01038a3:	f6 00 04             	testb  $0x4,(%eax)
f01038a6:	75 24                	jne    f01038cc <mem_init+0xcc8>
f01038a8:	c7 44 24 0c 06 a9 10 	movl   $0xf010a906,0xc(%esp)
f01038af:	f0 
f01038b0:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01038b7:	f0 
f01038b8:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f01038bf:	00 
f01038c0:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01038c7:	e8 74 c7 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01038cc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01038d3:	00 
f01038d4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038db:	00 
f01038dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038e0:	89 04 24             	mov    %eax,(%esp)
f01038e3:	e8 f7 f1 ff ff       	call   f0102adf <page_insert>
f01038e8:	85 c0                	test   %eax,%eax
f01038ea:	74 24                	je     f0103910 <mem_init+0xd0c>
f01038ec:	c7 44 24 0c bc 9f 10 	movl   $0xf0109fbc,0xc(%esp)
f01038f3:	f0 
f01038f4:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01038fb:	f0 
f01038fc:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0103903:	00 
f0103904:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010390b:	e8 30 c7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0103910:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103917:	00 
f0103918:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010391f:	00 
f0103920:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103925:	89 04 24             	mov    %eax,(%esp)
f0103928:	e8 20 ef ff ff       	call   f010284d <pgdir_walk>
f010392d:	f6 00 02             	testb  $0x2,(%eax)
f0103930:	75 24                	jne    f0103956 <mem_init+0xd52>
f0103932:	c7 44 24 0c dc a0 10 	movl   $0xf010a0dc,0xc(%esp)
f0103939:	f0 
f010393a:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103941:	f0 
f0103942:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0103949:	00 
f010394a:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103951:	e8 ea c6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103956:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010395d:	00 
f010395e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103965:	00 
f0103966:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010396b:	89 04 24             	mov    %eax,(%esp)
f010396e:	e8 da ee ff ff       	call   f010284d <pgdir_walk>
f0103973:	f6 00 04             	testb  $0x4,(%eax)
f0103976:	74 24                	je     f010399c <mem_init+0xd98>
f0103978:	c7 44 24 0c 10 a1 10 	movl   $0xf010a110,0xc(%esp)
f010397f:	f0 
f0103980:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103987:	f0 
f0103988:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010398f:	00 
f0103990:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103997:	e8 a4 c6 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010399c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01039a3:	00 
f01039a4:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01039ab:	00 
f01039ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01039b0:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01039b5:	89 04 24             	mov    %eax,(%esp)
f01039b8:	e8 22 f1 ff ff       	call   f0102adf <page_insert>
f01039bd:	85 c0                	test   %eax,%eax
f01039bf:	78 24                	js     f01039e5 <mem_init+0xde1>
f01039c1:	c7 44 24 0c 48 a1 10 	movl   $0xf010a148,0xc(%esp)
f01039c8:	f0 
f01039c9:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01039d0:	f0 
f01039d1:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01039d8:	00 
f01039d9:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01039e0:	e8 5b c6 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01039e5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01039ec:	00 
f01039ed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01039f4:	00 
f01039f5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01039f9:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01039fe:	89 04 24             	mov    %eax,(%esp)
f0103a01:	e8 d9 f0 ff ff       	call   f0102adf <page_insert>
f0103a06:	85 c0                	test   %eax,%eax
f0103a08:	74 24                	je     f0103a2e <mem_init+0xe2a>
f0103a0a:	c7 44 24 0c 80 a1 10 	movl   $0xf010a180,0xc(%esp)
f0103a11:	f0 
f0103a12:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103a19:	f0 
f0103a1a:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0103a21:	00 
f0103a22:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103a29:	e8 12 c6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103a2e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103a35:	00 
f0103a36:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103a3d:	00 
f0103a3e:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103a43:	89 04 24             	mov    %eax,(%esp)
f0103a46:	e8 02 ee ff ff       	call   f010284d <pgdir_walk>
f0103a4b:	f6 00 04             	testb  $0x4,(%eax)
f0103a4e:	74 24                	je     f0103a74 <mem_init+0xe70>
f0103a50:	c7 44 24 0c 10 a1 10 	movl   $0xf010a110,0xc(%esp)
f0103a57:	f0 
f0103a58:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103a5f:	f0 
f0103a60:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0103a67:	00 
f0103a68:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103a6f:	e8 cc c5 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0103a74:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103a79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a81:	e8 ce e6 ff ff       	call   f0102154 <check_va2pa>
f0103a86:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103a89:	89 f0                	mov    %esi,%eax
f0103a8b:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f0103a91:	c1 f8 03             	sar    $0x3,%eax
f0103a94:	c1 e0 0c             	shl    $0xc,%eax
f0103a97:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0103a9a:	74 24                	je     f0103ac0 <mem_init+0xebc>
f0103a9c:	c7 44 24 0c bc a1 10 	movl   $0xf010a1bc,0xc(%esp)
f0103aa3:	f0 
f0103aa4:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103aab:	f0 
f0103aac:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0103ab3:	00 
f0103ab4:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103abb:	e8 80 c5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103ac0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103ac5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ac8:	e8 87 e6 ff ff       	call   f0102154 <check_va2pa>
f0103acd:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0103ad0:	74 24                	je     f0103af6 <mem_init+0xef2>
f0103ad2:	c7 44 24 0c e8 a1 10 	movl   $0xf010a1e8,0xc(%esp)
f0103ad9:	f0 
f0103ada:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103ae1:	f0 
f0103ae2:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0103ae9:	00 
f0103aea:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103af1:	e8 4a c5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0103af6:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0103afb:	74 24                	je     f0103b21 <mem_init+0xf1d>
f0103afd:	c7 44 24 0c 1c a9 10 	movl   $0xf010a91c,0xc(%esp)
f0103b04:	f0 
f0103b05:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103b0c:	f0 
f0103b0d:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0103b14:	00 
f0103b15:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103b1c:	e8 1f c5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103b21:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103b26:	74 24                	je     f0103b4c <mem_init+0xf48>
f0103b28:	c7 44 24 0c 2d a9 10 	movl   $0xf010a92d,0xc(%esp)
f0103b2f:	f0 
f0103b30:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103b37:	f0 
f0103b38:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f0103b3f:	00 
f0103b40:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103b47:	e8 f4 c4 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0103b4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b53:	e8 11 ec ff ff       	call   f0102769 <page_alloc>
f0103b58:	85 c0                	test   %eax,%eax
f0103b5a:	74 04                	je     f0103b60 <mem_init+0xf5c>
f0103b5c:	39 c3                	cmp    %eax,%ebx
f0103b5e:	74 24                	je     f0103b84 <mem_init+0xf80>
f0103b60:	c7 44 24 0c 18 a2 10 	movl   $0xf010a218,0xc(%esp)
f0103b67:	f0 
f0103b68:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103b6f:	f0 
f0103b70:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0103b77:	00 
f0103b78:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103b7f:	e8 bc c4 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0103b84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b8b:	00 
f0103b8c:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103b91:	89 04 24             	mov    %eax,(%esp)
f0103b94:	e8 fd ee ff ff       	call   f0102a96 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103b99:	8b 15 8c 6e 35 f0    	mov    0xf0356e8c,%edx
f0103b9f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103ba2:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ba7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103baa:	e8 a5 e5 ff ff       	call   f0102154 <check_va2pa>
f0103baf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103bb2:	74 24                	je     f0103bd8 <mem_init+0xfd4>
f0103bb4:	c7 44 24 0c 3c a2 10 	movl   $0xf010a23c,0xc(%esp)
f0103bbb:	f0 
f0103bbc:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103bc3:	f0 
f0103bc4:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f0103bcb:	00 
f0103bcc:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103bd3:	e8 68 c4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103bd8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103bdd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103be0:	e8 6f e5 ff ff       	call   f0102154 <check_va2pa>
f0103be5:	89 f2                	mov    %esi,%edx
f0103be7:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0103bed:	c1 fa 03             	sar    $0x3,%edx
f0103bf0:	c1 e2 0c             	shl    $0xc,%edx
f0103bf3:	39 d0                	cmp    %edx,%eax
f0103bf5:	74 24                	je     f0103c1b <mem_init+0x1017>
f0103bf7:	c7 44 24 0c e8 a1 10 	movl   $0xf010a1e8,0xc(%esp)
f0103bfe:	f0 
f0103bff:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103c06:	f0 
f0103c07:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0103c0e:	00 
f0103c0f:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103c16:	e8 25 c4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0103c1b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103c20:	74 24                	je     f0103c46 <mem_init+0x1042>
f0103c22:	c7 44 24 0c d3 a8 10 	movl   $0xf010a8d3,0xc(%esp)
f0103c29:	f0 
f0103c2a:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103c31:	f0 
f0103c32:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0103c39:	00 
f0103c3a:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103c41:	e8 fa c3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103c46:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103c4b:	74 24                	je     f0103c71 <mem_init+0x106d>
f0103c4d:	c7 44 24 0c 2d a9 10 	movl   $0xf010a92d,0xc(%esp)
f0103c54:	f0 
f0103c55:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103c5c:	f0 
f0103c5d:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0103c64:	00 
f0103c65:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103c6c:	e8 cf c3 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0103c71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103c78:	00 
f0103c79:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103c80:	00 
f0103c81:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103c85:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103c88:	89 0c 24             	mov    %ecx,(%esp)
f0103c8b:	e8 4f ee ff ff       	call   f0102adf <page_insert>
f0103c90:	85 c0                	test   %eax,%eax
f0103c92:	74 24                	je     f0103cb8 <mem_init+0x10b4>
f0103c94:	c7 44 24 0c 60 a2 10 	movl   $0xf010a260,0xc(%esp)
f0103c9b:	f0 
f0103c9c:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103ca3:	f0 
f0103ca4:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f0103cab:	00 
f0103cac:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103cb3:	e8 88 c3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0103cb8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103cbd:	75 24                	jne    f0103ce3 <mem_init+0x10df>
f0103cbf:	c7 44 24 0c 3e a9 10 	movl   $0xf010a93e,0xc(%esp)
f0103cc6:	f0 
f0103cc7:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103cce:	f0 
f0103ccf:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0103cd6:	00 
f0103cd7:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103cde:	e8 5d c3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0103ce3:	83 3e 00             	cmpl   $0x0,(%esi)
f0103ce6:	74 24                	je     f0103d0c <mem_init+0x1108>
f0103ce8:	c7 44 24 0c 4a a9 10 	movl   $0xf010a94a,0xc(%esp)
f0103cef:	f0 
f0103cf0:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103cf7:	f0 
f0103cf8:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0103cff:	00 
f0103d00:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103d07:	e8 34 c3 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103d0c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103d13:	00 
f0103d14:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103d19:	89 04 24             	mov    %eax,(%esp)
f0103d1c:	e8 75 ed ff ff       	call   f0102a96 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103d21:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103d26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103d29:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d2e:	e8 21 e4 ff ff       	call   f0102154 <check_va2pa>
f0103d33:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103d36:	74 24                	je     f0103d5c <mem_init+0x1158>
f0103d38:	c7 44 24 0c 3c a2 10 	movl   $0xf010a23c,0xc(%esp)
f0103d3f:	f0 
f0103d40:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103d47:	f0 
f0103d48:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0103d4f:	00 
f0103d50:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103d57:	e8 e4 c2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0103d5c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103d61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d64:	e8 eb e3 ff ff       	call   f0102154 <check_va2pa>
f0103d69:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103d6c:	74 24                	je     f0103d92 <mem_init+0x118e>
f0103d6e:	c7 44 24 0c 98 a2 10 	movl   $0xf010a298,0xc(%esp)
f0103d75:	f0 
f0103d76:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103d7d:	f0 
f0103d7e:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0103d85:	00 
f0103d86:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103d8d:	e8 ae c2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103d92:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103d97:	74 24                	je     f0103dbd <mem_init+0x11b9>
f0103d99:	c7 44 24 0c 5f a9 10 	movl   $0xf010a95f,0xc(%esp)
f0103da0:	f0 
f0103da1:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103da8:	f0 
f0103da9:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0103db0:	00 
f0103db1:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103db8:	e8 83 c2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103dbd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103dc2:	74 24                	je     f0103de8 <mem_init+0x11e4>
f0103dc4:	c7 44 24 0c 2d a9 10 	movl   $0xf010a92d,0xc(%esp)
f0103dcb:	f0 
f0103dcc:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103dd3:	f0 
f0103dd4:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0103ddb:	00 
f0103ddc:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103de3:	e8 58 c2 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0103de8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103def:	e8 75 e9 ff ff       	call   f0102769 <page_alloc>
f0103df4:	85 c0                	test   %eax,%eax
f0103df6:	74 04                	je     f0103dfc <mem_init+0x11f8>
f0103df8:	39 c6                	cmp    %eax,%esi
f0103dfa:	74 24                	je     f0103e20 <mem_init+0x121c>
f0103dfc:	c7 44 24 0c c0 a2 10 	movl   $0xf010a2c0,0xc(%esp)
f0103e03:	f0 
f0103e04:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103e0b:	f0 
f0103e0c:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f0103e13:	00 
f0103e14:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103e1b:	e8 20 c2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103e20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103e27:	e8 3d e9 ff ff       	call   f0102769 <page_alloc>
f0103e2c:	85 c0                	test   %eax,%eax
f0103e2e:	74 24                	je     f0103e54 <mem_init+0x1250>
f0103e30:	c7 44 24 0c 81 a8 10 	movl   $0xf010a881,0xc(%esp)
f0103e37:	f0 
f0103e38:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103e3f:	f0 
f0103e40:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0103e47:	00 
f0103e48:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103e4f:	e8 ec c1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103e54:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103e59:	8b 08                	mov    (%eax),%ecx
f0103e5b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103e61:	89 fa                	mov    %edi,%edx
f0103e63:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0103e69:	c1 fa 03             	sar    $0x3,%edx
f0103e6c:	c1 e2 0c             	shl    $0xc,%edx
f0103e6f:	39 d1                	cmp    %edx,%ecx
f0103e71:	74 24                	je     f0103e97 <mem_init+0x1293>
f0103e73:	c7 44 24 0c 64 9f 10 	movl   $0xf0109f64,0xc(%esp)
f0103e7a:	f0 
f0103e7b:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103e82:	f0 
f0103e83:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0103e8a:	00 
f0103e8b:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103e92:	e8 a9 c1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103e97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103e9d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103ea2:	74 24                	je     f0103ec8 <mem_init+0x12c4>
f0103ea4:	c7 44 24 0c e4 a8 10 	movl   $0xf010a8e4,0xc(%esp)
f0103eab:	f0 
f0103eac:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103eb3:	f0 
f0103eb4:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0103ebb:	00 
f0103ebc:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103ec3:	e8 78 c1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103ec8:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0103ece:	89 3c 24             	mov    %edi,(%esp)
f0103ed1:	e8 17 e9 ff ff       	call   f01027ed <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0103ed6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103edd:	00 
f0103ede:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0103ee5:	00 
f0103ee6:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103eeb:	89 04 24             	mov    %eax,(%esp)
f0103eee:	e8 5a e9 ff ff       	call   f010284d <pgdir_walk>
f0103ef3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103ef6:	8b 0d 8c 6e 35 f0    	mov    0xf0356e8c,%ecx
f0103efc:	8b 51 04             	mov    0x4(%ecx),%edx
f0103eff:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103f05:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f08:	8b 15 88 6e 35 f0    	mov    0xf0356e88,%edx
f0103f0e:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0103f11:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103f14:	c1 ea 0c             	shr    $0xc,%edx
f0103f17:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103f1a:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103f1d:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0103f20:	72 23                	jb     f0103f45 <mem_init+0x1341>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f22:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103f25:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103f29:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0103f30:	f0 
f0103f31:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0103f38:	00 
f0103f39:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103f40:	e8 fb c0 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0103f45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103f48:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0103f4e:	39 d0                	cmp    %edx,%eax
f0103f50:	74 24                	je     f0103f76 <mem_init+0x1372>
f0103f52:	c7 44 24 0c 70 a9 10 	movl   $0xf010a970,0xc(%esp)
f0103f59:	f0 
f0103f5a:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0103f61:	f0 
f0103f62:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0103f69:	00 
f0103f6a:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0103f71:	e8 ca c0 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103f76:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0103f7d:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103f83:	89 f8                	mov    %edi,%eax
f0103f85:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f0103f8b:	c1 f8 03             	sar    $0x3,%eax
f0103f8e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f91:	89 c1                	mov    %eax,%ecx
f0103f93:	c1 e9 0c             	shr    $0xc,%ecx
f0103f96:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0103f99:	77 20                	ja     f0103fbb <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f9f:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0103fa6:	f0 
f0103fa7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103fae:	00 
f0103faf:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0103fb6:	e8 85 c0 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103fbb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103fc2:	00 
f0103fc3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103fca:	00 
	return (void *)(pa + KERNBASE);
f0103fcb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103fd0:	89 04 24             	mov    %eax,(%esp)
f0103fd3:	e8 6a 3b 00 00       	call   f0107b42 <memset>
	page_free(pp0);
f0103fd8:	89 3c 24             	mov    %edi,(%esp)
f0103fdb:	e8 0d e8 ff ff       	call   f01027ed <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103fe0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103fe7:	00 
f0103fe8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fef:	00 
f0103ff0:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0103ff5:	89 04 24             	mov    %eax,(%esp)
f0103ff8:	e8 50 e8 ff ff       	call   f010284d <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103ffd:	89 fa                	mov    %edi,%edx
f0103fff:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0104005:	c1 fa 03             	sar    $0x3,%edx
f0104008:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010400b:	89 d0                	mov    %edx,%eax
f010400d:	c1 e8 0c             	shr    $0xc,%eax
f0104010:	3b 05 88 6e 35 f0    	cmp    0xf0356e88,%eax
f0104016:	72 20                	jb     f0104038 <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104018:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010401c:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0104023:	f0 
f0104024:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010402b:	00 
f010402c:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0104033:	e8 08 c0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104038:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010403e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104041:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0104047:	f6 00 01             	testb  $0x1,(%eax)
f010404a:	74 24                	je     f0104070 <mem_init+0x146c>
f010404c:	c7 44 24 0c 88 a9 10 	movl   $0xf010a988,0xc(%esp)
f0104053:	f0 
f0104054:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010405b:	f0 
f010405c:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f0104063:	00 
f0104064:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010406b:	e8 d0 bf ff ff       	call   f0100040 <_panic>
f0104070:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0104073:	39 d0                	cmp    %edx,%eax
f0104075:	75 d0                	jne    f0104047 <mem_init+0x1443>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0104077:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010407c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0104082:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0104088:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010408b:	89 0d 48 62 35 f0    	mov    %ecx,0xf0356248

	// free the pages we took
	page_free(pp0);
f0104091:	89 3c 24             	mov    %edi,(%esp)
f0104094:	e8 54 e7 ff ff       	call   f01027ed <page_free>
	page_free(pp1);
f0104099:	89 34 24             	mov    %esi,(%esp)
f010409c:	e8 4c e7 ff ff       	call   f01027ed <page_free>
	page_free(pp2);
f01040a1:	89 1c 24             	mov    %ebx,(%esp)
f01040a4:	e8 44 e7 ff ff       	call   f01027ed <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01040a9:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01040b0:	00 
f01040b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01040b8:	e8 a3 ea ff ff       	call   f0102b60 <mmio_map_region>
f01040bd:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01040bf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01040c6:	00 
f01040c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01040ce:	e8 8d ea ff ff       	call   f0102b60 <mmio_map_region>
f01040d3:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01040d5:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01040db:	76 0d                	jbe    f01040ea <mem_init+0x14e6>
f01040dd:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f01040e3:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01040e8:	76 24                	jbe    f010410e <mem_init+0x150a>
f01040ea:	c7 44 24 0c e4 a2 10 	movl   $0xf010a2e4,0xc(%esp)
f01040f1:	f0 
f01040f2:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01040f9:	f0 
f01040fa:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0104101:	00 
f0104102:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104109:	e8 32 bf ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010410e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104114:	76 0e                	jbe    f0104124 <mem_init+0x1520>
f0104116:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f010411c:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0104122:	76 24                	jbe    f0104148 <mem_init+0x1544>
f0104124:	c7 44 24 0c 0c a3 10 	movl   $0xf010a30c,0xc(%esp)
f010412b:	f0 
f010412c:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104133:	f0 
f0104134:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f010413b:	00 
f010413c:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104143:	e8 f8 be ff ff       	call   f0100040 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104148:	89 da                	mov    %ebx,%edx
f010414a:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010414c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0104152:	74 24                	je     f0104178 <mem_init+0x1574>
f0104154:	c7 44 24 0c 34 a3 10 	movl   $0xf010a334,0xc(%esp)
f010415b:	f0 
f010415c:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104163:	f0 
f0104164:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f010416b:	00 
f010416c:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104173:	e8 c8 be ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0104178:	39 c6                	cmp    %eax,%esi
f010417a:	73 24                	jae    f01041a0 <mem_init+0x159c>
f010417c:	c7 44 24 0c 9f a9 10 	movl   $0xf010a99f,0xc(%esp)
f0104183:	f0 
f0104184:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010418b:	f0 
f010418c:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0104193:	00 
f0104194:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010419b:	e8 a0 be ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01041a0:	8b 3d 8c 6e 35 f0    	mov    0xf0356e8c,%edi
f01041a6:	89 da                	mov    %ebx,%edx
f01041a8:	89 f8                	mov    %edi,%eax
f01041aa:	e8 a5 df ff ff       	call   f0102154 <check_va2pa>
f01041af:	85 c0                	test   %eax,%eax
f01041b1:	74 24                	je     f01041d7 <mem_init+0x15d3>
f01041b3:	c7 44 24 0c 5c a3 10 	movl   $0xf010a35c,0xc(%esp)
f01041ba:	f0 
f01041bb:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01041c2:	f0 
f01041c3:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f01041ca:	00 
f01041cb:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01041d2:	e8 69 be ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01041d7:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01041dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01041e0:	89 c2                	mov    %eax,%edx
f01041e2:	89 f8                	mov    %edi,%eax
f01041e4:	e8 6b df ff ff       	call   f0102154 <check_va2pa>
f01041e9:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01041ee:	74 24                	je     f0104214 <mem_init+0x1610>
f01041f0:	c7 44 24 0c 80 a3 10 	movl   $0xf010a380,0xc(%esp)
f01041f7:	f0 
f01041f8:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01041ff:	f0 
f0104200:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0104207:	00 
f0104208:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010420f:	e8 2c be ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0104214:	89 f2                	mov    %esi,%edx
f0104216:	89 f8                	mov    %edi,%eax
f0104218:	e8 37 df ff ff       	call   f0102154 <check_va2pa>
f010421d:	85 c0                	test   %eax,%eax
f010421f:	74 24                	je     f0104245 <mem_init+0x1641>
f0104221:	c7 44 24 0c b0 a3 10 	movl   $0xf010a3b0,0xc(%esp)
f0104228:	f0 
f0104229:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104230:	f0 
f0104231:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f0104238:	00 
f0104239:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104240:	e8 fb bd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0104245:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010424b:	89 f8                	mov    %edi,%eax
f010424d:	e8 02 df ff ff       	call   f0102154 <check_va2pa>
f0104252:	83 f8 ff             	cmp    $0xffffffff,%eax
f0104255:	74 24                	je     f010427b <mem_init+0x1677>
f0104257:	c7 44 24 0c d4 a3 10 	movl   $0xf010a3d4,0xc(%esp)
f010425e:	f0 
f010425f:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104266:	f0 
f0104267:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f010426e:	00 
f010426f:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104276:	e8 c5 bd ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010427b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104282:	00 
f0104283:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104287:	89 3c 24             	mov    %edi,(%esp)
f010428a:	e8 be e5 ff ff       	call   f010284d <pgdir_walk>
f010428f:	f6 00 1a             	testb  $0x1a,(%eax)
f0104292:	75 24                	jne    f01042b8 <mem_init+0x16b4>
f0104294:	c7 44 24 0c 00 a4 10 	movl   $0xf010a400,0xc(%esp)
f010429b:	f0 
f010429c:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01042a3:	f0 
f01042a4:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f01042ab:	00 
f01042ac:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01042b3:	e8 88 bd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01042b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01042bf:	00 
f01042c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042c4:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01042c9:	89 04 24             	mov    %eax,(%esp)
f01042cc:	e8 7c e5 ff ff       	call   f010284d <pgdir_walk>
f01042d1:	f6 00 04             	testb  $0x4,(%eax)
f01042d4:	74 24                	je     f01042fa <mem_init+0x16f6>
f01042d6:	c7 44 24 0c 44 a4 10 	movl   $0xf010a444,0xc(%esp)
f01042dd:	f0 
f01042de:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01042e5:	f0 
f01042e6:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f01042ed:	00 
f01042ee:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01042f5:	e8 46 bd ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01042fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104301:	00 
f0104302:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104306:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010430b:	89 04 24             	mov    %eax,(%esp)
f010430e:	e8 3a e5 ff ff       	call   f010284d <pgdir_walk>
f0104313:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0104319:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104320:	00 
f0104321:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104324:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104328:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010432d:	89 04 24             	mov    %eax,(%esp)
f0104330:	e8 18 e5 ff ff       	call   f010284d <pgdir_walk>
f0104335:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010433b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104342:	00 
f0104343:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104347:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f010434c:	89 04 24             	mov    %eax,(%esp)
f010434f:	e8 f9 e4 ff ff       	call   f010284d <pgdir_walk>
f0104354:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010435a:	c7 04 24 b1 a9 10 f0 	movl   $0xf010a9b1,(%esp)
f0104361:	e8 88 14 00 00       	call   f01057ee <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f0104366:	a1 90 6e 35 f0       	mov    0xf0356e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010436b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104370:	77 20                	ja     f0104392 <mem_init+0x178e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104372:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104376:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f010437d:	f0 
f010437e:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0104385:	00 
f0104386:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010438d:	e8 ae bc ff ff       	call   f0100040 <_panic>
f0104392:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0104399:	00 
	return (physaddr_t)kva - KERNBASE;
f010439a:	05 00 00 00 10       	add    $0x10000000,%eax
f010439f:	89 04 24             	mov    %eax,(%esp)
f01043a2:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01043a7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01043ac:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01043b1:	e8 58 e5 ff ff       	call   f010290e <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U);
f01043b6:	a1 50 62 35 f0       	mov    0xf0356250,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043c0:	77 20                	ja     f01043e2 <mem_init+0x17de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043c6:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f01043cd:	f0 
f01043ce:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f01043d5:	00 
f01043d6:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01043dd:	e8 5e bc ff ff       	call   f0100040 <_panic>
f01043e2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01043e9:	00 
	return (physaddr_t)kva - KERNBASE;
f01043ea:	05 00 00 00 10       	add    $0x10000000,%eax
f01043ef:	89 04 24             	mov    %eax,(%esp)
f01043f2:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01043f7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01043fc:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0104401:	e8 08 e5 ff ff       	call   f010290e <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104406:	b8 00 40 12 f0       	mov    $0xf0124000,%eax
f010440b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104410:	77 20                	ja     f0104432 <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104412:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104416:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f010441d:	f0 
f010441e:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f0104425:	00 
f0104426:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010442d:	e8 0e bc ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
   boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f0104432:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0104439:	00 
f010443a:	c7 04 24 00 40 12 00 	movl   $0x124000,(%esp)
f0104441:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0104446:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010444b:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0104450:	e8 b9 e4 ff ff       	call   f010290e <boot_map_region>
f0104455:	c7 45 cc 00 80 35 f0 	movl   $0xf0358000,-0x34(%ebp)
f010445c:	bb 00 80 35 f0       	mov    $0xf0358000,%ebx
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t address = KSTACKTOP - KSTKSIZE;
f0104461:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104466:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010446c:	77 20                	ja     f010448e <mem_init+0x188a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010446e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104472:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0104479:	f0 
f010447a:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f0104481:	00 
f0104482:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104489:	e8 b2 bb ff ff       	call   f0100040 <_panic>
	for (int i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir,address,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f010448e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0104495:	00 
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104496:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t address = KSTACKTOP - KSTKSIZE;
	for (int i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir,address,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f010449c:	89 04 24             	mov    %eax,(%esp)
f010449f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01044a4:	89 f2                	mov    %esi,%edx
f01044a6:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01044ab:	e8 5e e4 ff ff       	call   f010290e <boot_map_region>
		address -= (KSTKSIZE + KSTKGAP);
f01044b0:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01044b6:	81 c3 00 80 00 00    	add    $0x8000,%ebx
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t address = KSTACKTOP - KSTKSIZE;
	for (int i = 0; i < NCPU; i++){
f01044bc:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f01044c2:	75 a2                	jne    f0104466 <mem_init+0x1862>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	assert(KERNBASE == 0xf0000000); // 0x100000000 - KERNBASE
	boot_map_region(kern_pgdir,KERNBASE,0x10000000,0x0,PTE_W);
f01044c4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01044cb:	00 
f01044cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01044d3:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01044d8:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01044dd:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01044e2:	e8 27 e4 ff ff       	call   f010290e <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01044e7:	8b 1d 8c 6e 35 f0    	mov    0xf0356e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01044ed:	8b 0d 88 6e 35 f0    	mov    0xf0356e88,%ecx
f01044f3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01044f6:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f01044fd:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0104503:	be 00 00 00 00       	mov    $0x0,%esi
f0104508:	eb 70                	jmp    f010457a <mem_init+0x1976>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010450a:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0104510:	89 d8                	mov    %ebx,%eax
f0104512:	e8 3d dc ff ff       	call   f0102154 <check_va2pa>
f0104517:	8b 15 90 6e 35 f0    	mov    0xf0356e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010451d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0104523:	77 20                	ja     f0104545 <mem_init+0x1941>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104525:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104529:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0104530:	f0 
f0104531:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0104538:	00 
f0104539:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104540:	e8 fb ba ff ff       	call   f0100040 <_panic>
f0104545:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010454c:	39 d0                	cmp    %edx,%eax
f010454e:	74 24                	je     f0104574 <mem_init+0x1970>
f0104550:	c7 44 24 0c 78 a4 10 	movl   $0xf010a478,0xc(%esp)
f0104557:	f0 
f0104558:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010455f:	f0 
f0104560:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0104567:	00 
f0104568:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010456f:	e8 cc ba ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0104574:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010457a:	39 f7                	cmp    %esi,%edi
f010457c:	77 8c                	ja     f010450a <mem_init+0x1906>
f010457e:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104583:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0104589:	89 d8                	mov    %ebx,%eax
f010458b:	e8 c4 db ff ff       	call   f0102154 <check_va2pa>
f0104590:	8b 15 50 62 35 f0    	mov    0xf0356250,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104596:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010459c:	77 20                	ja     f01045be <mem_init+0x19ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010459e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01045a2:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f01045a9:	f0 
f01045aa:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f01045b1:	00 
f01045b2:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01045b9:	e8 82 ba ff ff       	call   f0100040 <_panic>
f01045be:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01045c5:	39 d0                	cmp    %edx,%eax
f01045c7:	74 24                	je     f01045ed <mem_init+0x19e9>
f01045c9:	c7 44 24 0c ac a4 10 	movl   $0xf010a4ac,0xc(%esp)
f01045d0:	f0 
f01045d1:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01045d8:	f0 
f01045d9:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f01045e0:	00 
f01045e1:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01045e8:	e8 53 ba ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01045ed:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01045f3:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f01045f9:	75 88                	jne    f0104583 <mem_init+0x197f>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f01045fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01045fe:	c1 e7 0c             	shl    $0xc,%edi
f0104601:	be 00 00 00 00       	mov    $0x0,%esi
f0104606:	eb 3b                	jmp    f0104643 <mem_init+0x1a3f>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104608:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
		//#ifdef DEBUG
		// cprintf("%x %x\n",i,check_va2pa(pgdir, KERNBASE + i));
		//#endif
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010460e:	89 d8                	mov    %ebx,%eax
f0104610:	e8 3f db ff ff       	call   f0102154 <check_va2pa>
f0104615:	39 c6                	cmp    %eax,%esi
f0104617:	74 24                	je     f010463d <mem_init+0x1a39>
f0104619:	c7 44 24 0c e0 a4 10 	movl   $0xf010a4e0,0xc(%esp)
f0104620:	f0 
f0104621:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104628:	f0 
f0104629:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0104630:	00 
f0104631:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104638:	e8 03 ba ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f010463d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0104643:	39 fe                	cmp    %edi,%esi
f0104645:	72 c1                	jb     f0104608 <mem_init+0x1a04>
f0104647:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f010464c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010464f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104652:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104655:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010465b:	89 c6                	mov    %eax,%esi
f010465d:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0104663:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0104669:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010466c:	89 da                	mov    %ebx,%edx
f010466e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104671:	e8 de da ff ff       	call   f0102154 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104676:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010467d:	77 23                	ja     f01046a2 <mem_init+0x1a9e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010467f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104682:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104686:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f010468d:	f0 
f010468e:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0104695:	00 
f0104696:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010469d:	e8 9e b9 ff ff       	call   f0100040 <_panic>
f01046a2:	39 f0                	cmp    %esi,%eax
f01046a4:	74 24                	je     f01046ca <mem_init+0x1ac6>
f01046a6:	c7 44 24 0c 08 a5 10 	movl   $0xf010a508,0xc(%esp)
f01046ad:	f0 
f01046ae:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01046b5:	f0 
f01046b6:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01046bd:	00 
f01046be:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01046c5:	e8 76 b9 ff ff       	call   f0100040 <_panic>
f01046ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01046d0:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01046d6:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f01046d9:	0f 85 55 05 00 00    	jne    f0104c34 <mem_init+0x2030>
f01046df:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046e4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01046e7:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f01046ea:	89 f0                	mov    %esi,%eax
f01046ec:	e8 63 da ff ff       	call   f0102154 <check_va2pa>
f01046f1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01046f4:	74 24                	je     f010471a <mem_init+0x1b16>
f01046f6:	c7 44 24 0c 50 a5 10 	movl   $0xf010a550,0xc(%esp)
f01046fd:	f0 
f01046fe:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104705:	f0 
f0104706:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f010470d:	00 
f010470e:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104715:	e8 26 b9 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010471a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104720:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0104726:	75 bf                	jne    f01046e7 <mem_init+0x1ae3>
f0104728:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f010472e:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0104735:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f010473b:	0f 85 0e ff ff ff    	jne    f010464f <mem_init+0x1a4b>
f0104741:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104744:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0104749:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010474f:	83 fa 04             	cmp    $0x4,%edx
f0104752:	77 2e                	ja     f0104782 <mem_init+0x1b7e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0104754:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0104758:	0f 85 aa 00 00 00    	jne    f0104808 <mem_init+0x1c04>
f010475e:	c7 44 24 0c ca a9 10 	movl   $0xf010a9ca,0xc(%esp)
f0104765:	f0 
f0104766:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010476d:	f0 
f010476e:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0104775:	00 
f0104776:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010477d:	e8 be b8 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0104782:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0104787:	76 55                	jbe    f01047de <mem_init+0x1bda>
				assert(pgdir[i] & PTE_P);
f0104789:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010478c:	f6 c2 01             	test   $0x1,%dl
f010478f:	75 24                	jne    f01047b5 <mem_init+0x1bb1>
f0104791:	c7 44 24 0c ca a9 10 	movl   $0xf010a9ca,0xc(%esp)
f0104798:	f0 
f0104799:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01047a0:	f0 
f01047a1:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01047a8:	00 
f01047a9:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01047b0:	e8 8b b8 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01047b5:	f6 c2 02             	test   $0x2,%dl
f01047b8:	75 4e                	jne    f0104808 <mem_init+0x1c04>
f01047ba:	c7 44 24 0c db a9 10 	movl   $0xf010a9db,0xc(%esp)
f01047c1:	f0 
f01047c2:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01047c9:	f0 
f01047ca:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f01047d1:	00 
f01047d2:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01047d9:	e8 62 b8 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01047de:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01047e2:	74 24                	je     f0104808 <mem_init+0x1c04>
f01047e4:	c7 44 24 0c ec a9 10 	movl   $0xf010a9ec,0xc(%esp)
f01047eb:	f0 
f01047ec:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01047f3:	f0 
f01047f4:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01047fb:	00 
f01047fc:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104803:	e8 38 b8 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0104808:	40                   	inc    %eax
f0104809:	3d 00 04 00 00       	cmp    $0x400,%eax
f010480e:	0f 85 35 ff ff ff    	jne    f0104749 <mem_init+0x1b45>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0104814:	c7 04 24 74 a5 10 f0 	movl   $0xf010a574,(%esp)
f010481b:	e8 ce 0f 00 00       	call   f01057ee <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0104820:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104825:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010482a:	77 20                	ja     f010484c <mem_init+0x1c48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010482c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104830:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0104837:	f0 
f0104838:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
f010483f:	00 
f0104840:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104847:	e8 f4 b7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010484c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104851:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0104854:	b8 00 00 00 00       	mov    $0x0,%eax
f0104859:	e8 24 da ff ff       	call   f0102282 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010485e:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0104861:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0104866:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0104869:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010486c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104873:	e8 f1 de ff ff       	call   f0102769 <page_alloc>
f0104878:	89 c6                	mov    %eax,%esi
f010487a:	85 c0                	test   %eax,%eax
f010487c:	75 24                	jne    f01048a2 <mem_init+0x1c9e>
f010487e:	c7 44 24 0c d6 a7 10 	movl   $0xf010a7d6,0xc(%esp)
f0104885:	f0 
f0104886:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010488d:	f0 
f010488e:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f0104895:	00 
f0104896:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f010489d:	e8 9e b7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01048a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048a9:	e8 bb de ff ff       	call   f0102769 <page_alloc>
f01048ae:	89 c7                	mov    %eax,%edi
f01048b0:	85 c0                	test   %eax,%eax
f01048b2:	75 24                	jne    f01048d8 <mem_init+0x1cd4>
f01048b4:	c7 44 24 0c ec a7 10 	movl   $0xf010a7ec,0xc(%esp)
f01048bb:	f0 
f01048bc:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01048c3:	f0 
f01048c4:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f01048cb:	00 
f01048cc:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f01048d3:	e8 68 b7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01048d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048df:	e8 85 de ff ff       	call   f0102769 <page_alloc>
f01048e4:	89 c3                	mov    %eax,%ebx
f01048e6:	85 c0                	test   %eax,%eax
f01048e8:	75 24                	jne    f010490e <mem_init+0x1d0a>
f01048ea:	c7 44 24 0c 02 a8 10 	movl   $0xf010a802,0xc(%esp)
f01048f1:	f0 
f01048f2:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01048f9:	f0 
f01048fa:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f0104901:	00 
f0104902:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104909:	e8 32 b7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010490e:	89 34 24             	mov    %esi,(%esp)
f0104911:	e8 d7 de ff ff       	call   f01027ed <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104916:	89 f8                	mov    %edi,%eax
f0104918:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f010491e:	c1 f8 03             	sar    $0x3,%eax
f0104921:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104924:	89 c2                	mov    %eax,%edx
f0104926:	c1 ea 0c             	shr    $0xc,%edx
f0104929:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f010492f:	72 20                	jb     f0104951 <mem_init+0x1d4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104931:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104935:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f010493c:	f0 
f010493d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0104944:	00 
f0104945:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f010494c:	e8 ef b6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0104951:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104958:	00 
f0104959:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0104960:	00 
	return (void *)(pa + KERNBASE);
f0104961:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0104966:	89 04 24             	mov    %eax,(%esp)
f0104969:	e8 d4 31 00 00       	call   f0107b42 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010496e:	89 d8                	mov    %ebx,%eax
f0104970:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f0104976:	c1 f8 03             	sar    $0x3,%eax
f0104979:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010497c:	89 c2                	mov    %eax,%edx
f010497e:	c1 ea 0c             	shr    $0xc,%edx
f0104981:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f0104987:	72 20                	jb     f01049a9 <mem_init+0x1da5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104989:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010498d:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0104994:	f0 
f0104995:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010499c:	00 
f010499d:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f01049a4:	e8 97 b6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01049a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01049b0:	00 
f01049b1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01049b8:	00 
	return (void *)(pa + KERNBASE);
f01049b9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01049be:	89 04 24             	mov    %eax,(%esp)
f01049c1:	e8 7c 31 00 00       	call   f0107b42 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01049c6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01049cd:	00 
f01049ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01049d5:	00 
f01049d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01049da:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f01049df:	89 04 24             	mov    %eax,(%esp)
f01049e2:	e8 f8 e0 ff ff       	call   f0102adf <page_insert>
	assert(pp1->pp_ref == 1);
f01049e7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01049ec:	74 24                	je     f0104a12 <mem_init+0x1e0e>
f01049ee:	c7 44 24 0c d3 a8 10 	movl   $0xf010a8d3,0xc(%esp)
f01049f5:	f0 
f01049f6:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01049fd:	f0 
f01049fe:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0104a05:	00 
f0104a06:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104a0d:	e8 2e b6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0104a12:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0104a19:	01 01 01 
f0104a1c:	74 24                	je     f0104a42 <mem_init+0x1e3e>
f0104a1e:	c7 44 24 0c 94 a5 10 	movl   $0xf010a594,0xc(%esp)
f0104a25:	f0 
f0104a26:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104a2d:	f0 
f0104a2e:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0104a35:	00 
f0104a36:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104a3d:	e8 fe b5 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0104a42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104a49:	00 
f0104a4a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104a51:	00 
f0104a52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a56:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0104a5b:	89 04 24             	mov    %eax,(%esp)
f0104a5e:	e8 7c e0 ff ff       	call   f0102adf <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0104a63:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0104a6a:	02 02 02 
f0104a6d:	74 24                	je     f0104a93 <mem_init+0x1e8f>
f0104a6f:	c7 44 24 0c b8 a5 10 	movl   $0xf010a5b8,0xc(%esp)
f0104a76:	f0 
f0104a77:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104a7e:	f0 
f0104a7f:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0104a86:	00 
f0104a87:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104a8e:	e8 ad b5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0104a93:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0104a98:	74 24                	je     f0104abe <mem_init+0x1eba>
f0104a9a:	c7 44 24 0c f5 a8 10 	movl   $0xf010a8f5,0xc(%esp)
f0104aa1:	f0 
f0104aa2:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104aa9:	f0 
f0104aaa:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f0104ab1:	00 
f0104ab2:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104ab9:	e8 82 b5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0104abe:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0104ac3:	74 24                	je     f0104ae9 <mem_init+0x1ee5>
f0104ac5:	c7 44 24 0c 5f a9 10 	movl   $0xf010a95f,0xc(%esp)
f0104acc:	f0 
f0104acd:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104ad4:	f0 
f0104ad5:	c7 44 24 04 88 04 00 	movl   $0x488,0x4(%esp)
f0104adc:	00 
f0104add:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104ae4:	e8 57 b5 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0104ae9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0104af0:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104af3:	89 d8                	mov    %ebx,%eax
f0104af5:	2b 05 90 6e 35 f0    	sub    0xf0356e90,%eax
f0104afb:	c1 f8 03             	sar    $0x3,%eax
f0104afe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104b01:	89 c2                	mov    %eax,%edx
f0104b03:	c1 ea 0c             	shr    $0xc,%edx
f0104b06:	3b 15 88 6e 35 f0    	cmp    0xf0356e88,%edx
f0104b0c:	72 20                	jb     f0104b2e <mem_init+0x1f2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b12:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0104b19:	f0 
f0104b1a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0104b21:	00 
f0104b22:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0104b29:	e8 12 b5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0104b2e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0104b35:	03 03 03 
f0104b38:	74 24                	je     f0104b5e <mem_init+0x1f5a>
f0104b3a:	c7 44 24 0c dc a5 10 	movl   $0xf010a5dc,0xc(%esp)
f0104b41:	f0 
f0104b42:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104b49:	f0 
f0104b4a:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f0104b51:	00 
f0104b52:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104b59:	e8 e2 b4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0104b5e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0104b65:	00 
f0104b66:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0104b6b:	89 04 24             	mov    %eax,(%esp)
f0104b6e:	e8 23 df ff ff       	call   f0102a96 <page_remove>
	assert(pp2->pp_ref == 0);
f0104b73:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0104b78:	74 24                	je     f0104b9e <mem_init+0x1f9a>
f0104b7a:	c7 44 24 0c 2d a9 10 	movl   $0xf010a92d,0xc(%esp)
f0104b81:	f0 
f0104b82:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104b89:	f0 
f0104b8a:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0104b91:	00 
f0104b92:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104b99:	e8 a2 b4 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0104b9e:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
f0104ba3:	8b 08                	mov    (%eax),%ecx
f0104ba5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104bab:	89 f2                	mov    %esi,%edx
f0104bad:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0104bb3:	c1 fa 03             	sar    $0x3,%edx
f0104bb6:	c1 e2 0c             	shl    $0xc,%edx
f0104bb9:	39 d1                	cmp    %edx,%ecx
f0104bbb:	74 24                	je     f0104be1 <mem_init+0x1fdd>
f0104bbd:	c7 44 24 0c 64 9f 10 	movl   $0xf0109f64,0xc(%esp)
f0104bc4:	f0 
f0104bc5:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104bcc:	f0 
f0104bcd:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f0104bd4:	00 
f0104bd5:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104bdc:	e8 5f b4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0104be1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0104be7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0104bec:	74 24                	je     f0104c12 <mem_init+0x200e>
f0104bee:	c7 44 24 0c e4 a8 10 	movl   $0xf010a8e4,0xc(%esp)
f0104bf5:	f0 
f0104bf6:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104bfd:	f0 
f0104bfe:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0104c05:	00 
f0104c06:	c7 04 24 69 a6 10 f0 	movl   $0xf010a669,(%esp)
f0104c0d:	e8 2e b4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0104c12:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0104c18:	89 34 24             	mov    %esi,(%esp)
f0104c1b:	e8 cd db ff ff       	call   f01027ed <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0104c20:	c7 04 24 08 a6 10 f0 	movl   $0xf010a608,(%esp)
f0104c27:	e8 c2 0b 00 00       	call   f01057ee <cprintf>
	// 	cprintf("%x %x %x\n",i,&kern_pgdir[i],KADDR(PTE_ADDR(kern_pgdir[i])));

	// pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	// cprintf("%x\n",*(int*)0x00400000);
	// cprintf("pages: %x\n",pages);
}
f0104c2c:	83 c4 3c             	add    $0x3c,%esp
f0104c2f:	5b                   	pop    %ebx
f0104c30:	5e                   	pop    %esi
f0104c31:	5f                   	pop    %edi
f0104c32:	5d                   	pop    %ebp
f0104c33:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0104c34:	89 da                	mov    %ebx,%edx
f0104c36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104c39:	e8 16 d5 ff ff       	call   f0102154 <check_va2pa>
f0104c3e:	e9 5f fa ff ff       	jmp    f01046a2 <mem_init+0x1a9e>

f0104c43 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0104c43:	55                   	push   %ebp
f0104c44:	89 e5                	mov    %esp,%ebp
f0104c46:	57                   	push   %edi
f0104c47:	56                   	push   %esi
f0104c48:	53                   	push   %ebx
f0104c49:	83 ec 2c             	sub    $0x2c,%esp
f0104c4c:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t start = (uintptr_t)ROUNDDOWN(va,PGSIZE);
f0104c4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c52:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t end = (uintptr_t)ROUNDUP(va+len,PGSIZE);
f0104c58:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c5b:	03 45 10             	add    0x10(%ebp),%eax
f0104c5e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104c63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104c68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// cprintf("%x %x\n",start,end);
	perm |= PTE_P;
f0104c6b:	8b 7d 14             	mov    0x14(%ebp),%edi
f0104c6e:	83 cf 01             	or     $0x1,%edi

	for (uintptr_t address = start; address < end; address+= PGSIZE){
f0104c71:	eb 5d                	jmp    f0104cd0 <user_mem_check+0x8d>
		if (address >= ULIM){
f0104c73:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0104c79:	76 16                	jbe    f0104c91 <user_mem_check+0x4e>
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
f0104c7b:	89 d8                	mov    %ebx,%eax
f0104c7d:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0104c80:	73 03                	jae    f0104c85 <user_mem_check+0x42>
f0104c82:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c85:	a3 4c 62 35 f0       	mov    %eax,0xf035624c
			return -E_FAULT;
f0104c8a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0104c8f:	eb 49                	jmp    f0104cda <user_mem_check+0x97>
		}
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)address, 0);
f0104c91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104c98:	00 
f0104c99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104c9d:	8b 46 60             	mov    0x60(%esi),%eax
f0104ca0:	89 04 24             	mov    %eax,(%esp)
f0104ca3:	e8 a5 db ff ff       	call   f010284d <pgdir_walk>
		if (pte == NULL || (*pte & perm) != perm){
f0104ca8:	85 c0                	test   %eax,%eax
f0104caa:	74 08                	je     f0104cb4 <user_mem_check+0x71>
f0104cac:	8b 00                	mov    (%eax),%eax
f0104cae:	21 f8                	and    %edi,%eax
f0104cb0:	39 c7                	cmp    %eax,%edi
f0104cb2:	74 16                	je     f0104cca <user_mem_check+0x87>
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
f0104cb4:	89 d8                	mov    %ebx,%eax
f0104cb6:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0104cb9:	73 03                	jae    f0104cbe <user_mem_check+0x7b>
f0104cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cbe:	a3 4c 62 35 f0       	mov    %eax,0xf035624c
			return -E_FAULT;
f0104cc3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0104cc8:	eb 10                	jmp    f0104cda <user_mem_check+0x97>
	uintptr_t start = (uintptr_t)ROUNDDOWN(va,PGSIZE);
	uintptr_t end = (uintptr_t)ROUNDUP(va+len,PGSIZE);
	// cprintf("%x %x\n",start,end);
	perm |= PTE_P;

	for (uintptr_t address = start; address < end; address+= PGSIZE){
f0104cca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104cd0:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0104cd3:	72 9e                	jb     f0104c73 <user_mem_check+0x30>
		if (pte == NULL || (*pte & perm) != perm){
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
			return -E_FAULT;
		}
	}
	return 0;
f0104cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104cda:	83 c4 2c             	add    $0x2c,%esp
f0104cdd:	5b                   	pop    %ebx
f0104cde:	5e                   	pop    %esi
f0104cdf:	5f                   	pop    %edi
f0104ce0:	5d                   	pop    %ebp
f0104ce1:	c3                   	ret    

f0104ce2 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0104ce2:	55                   	push   %ebp
f0104ce3:	89 e5                	mov    %esp,%ebp
f0104ce5:	53                   	push   %ebx
f0104ce6:	83 ec 14             	sub    $0x14,%esp
f0104ce9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0104cec:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cef:	83 c8 04             	or     $0x4,%eax
f0104cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104cf6:	8b 45 10             	mov    0x10(%ebp),%eax
f0104cf9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d04:	89 1c 24             	mov    %ebx,(%esp)
f0104d07:	e8 37 ff ff ff       	call   f0104c43 <user_mem_check>
f0104d0c:	85 c0                	test   %eax,%eax
f0104d0e:	79 24                	jns    f0104d34 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0104d10:	a1 4c 62 35 f0       	mov    0xf035624c,%eax
f0104d15:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d19:	8b 43 48             	mov    0x48(%ebx),%eax
f0104d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d20:	c7 04 24 34 a6 10 f0 	movl   $0xf010a634,(%esp)
f0104d27:	e8 c2 0a 00 00       	call   f01057ee <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0104d2c:	89 1c 24             	mov    %ebx,(%esp)
f0104d2f:	e8 93 07 00 00       	call   f01054c7 <env_destroy>
	}
}
f0104d34:	83 c4 14             	add    $0x14,%esp
f0104d37:	5b                   	pop    %ebx
f0104d38:	5d                   	pop    %ebp
f0104d39:	c3                   	ret    
	...

f0104d3c <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0104d3c:	55                   	push   %ebp
f0104d3d:	89 e5                	mov    %esp,%ebp
f0104d3f:	57                   	push   %edi
f0104d40:	56                   	push   %esi
f0104d41:	53                   	push   %ebx
f0104d42:	83 ec 1c             	sub    $0x1c,%esp
f0104d45:	89 c6                	mov    %eax,%esi
	// LAB 3: Your code here.
	void *start = ROUNDDOWN(va,PGSIZE);
	void *end =ROUNDUP(va+len,PGSIZE);
f0104d47:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0104d4e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (void *address = start; address < end; address += PGSIZE){
f0104d54:	89 d3                	mov    %edx,%ebx
f0104d56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0104d5c:	eb 6d                	jmp    f0104dcb <region_alloc+0x8f>
		struct PageInfo *page = page_alloc(0);
f0104d5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104d65:	e8 ff d9 ff ff       	call   f0102769 <page_alloc>
		if (page == NULL)panic("region_alloc: page_alloc failed!");
f0104d6a:	85 c0                	test   %eax,%eax
f0104d6c:	75 1c                	jne    f0104d8a <region_alloc+0x4e>
f0104d6e:	c7 44 24 08 fc a9 10 	movl   $0xf010a9fc,0x8(%esp)
f0104d75:	f0 
f0104d76:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0104d7d:	00 
f0104d7e:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f0104d85:	e8 b6 b2 ff ff       	call   f0100040 <_panic>
		if (page_insert(e->env_pgdir,page,address,PTE_W|PTE_U))
f0104d8a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104d91:	00 
f0104d92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104d96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d9a:	8b 46 60             	mov    0x60(%esi),%eax
f0104d9d:	89 04 24             	mov    %eax,(%esp)
f0104da0:	e8 3a dd ff ff       	call   f0102adf <page_insert>
f0104da5:	85 c0                	test   %eax,%eax
f0104da7:	74 1c                	je     f0104dc5 <region_alloc+0x89>
			panic("region_alloc: page_insert failed!");
f0104da9:	c7 44 24 08 20 aa 10 	movl   $0xf010aa20,0x8(%esp)
f0104db0:	f0 
f0104db1:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f0104db8:	00 
f0104db9:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f0104dc0:	e8 7b b2 ff ff       	call   f0100040 <_panic>
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *start = ROUNDDOWN(va,PGSIZE);
	void *end =ROUNDUP(va+len,PGSIZE);
	for (void *address = start; address < end; address += PGSIZE){
f0104dc5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104dcb:	39 fb                	cmp    %edi,%ebx
f0104dcd:	72 8f                	jb     f0104d5e <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0104dcf:	83 c4 1c             	add    $0x1c,%esp
f0104dd2:	5b                   	pop    %ebx
f0104dd3:	5e                   	pop    %esi
f0104dd4:	5f                   	pop    %edi
f0104dd5:	5d                   	pop    %ebp
f0104dd6:	c3                   	ret    

f0104dd7 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0104dd7:	55                   	push   %ebp
f0104dd8:	89 e5                	mov    %esp,%ebp
f0104dda:	57                   	push   %edi
f0104ddb:	56                   	push   %esi
f0104ddc:	53                   	push   %ebx
f0104ddd:	83 ec 0c             	sub    $0xc,%esp
f0104de0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104de3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104de6:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0104de9:	85 c0                	test   %eax,%eax
f0104deb:	75 24                	jne    f0104e11 <envid2env+0x3a>
		*env_store = curenv;
f0104ded:	e8 7e 33 00 00       	call   f0108170 <cpunum>
f0104df2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104df9:	29 c2                	sub    %eax,%edx
f0104dfb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dfe:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0104e05:	89 06                	mov    %eax,(%esi)
		return 0;
f0104e07:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e0c:	e9 84 00 00 00       	jmp    f0104e95 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0104e11:	89 c3                	mov    %eax,%ebx
f0104e13:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0104e19:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0104e20:	c1 e3 07             	shl    $0x7,%ebx
f0104e23:	29 cb                	sub    %ecx,%ebx
f0104e25:	03 1d 50 62 35 f0    	add    0xf0356250,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0104e2b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0104e2f:	74 05                	je     f0104e36 <envid2env+0x5f>
f0104e31:	39 43 48             	cmp    %eax,0x48(%ebx)
f0104e34:	74 0d                	je     f0104e43 <envid2env+0x6c>
		*env_store = 0;
f0104e36:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0104e3c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e41:	eb 52                	jmp    f0104e95 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0104e43:	84 d2                	test   %dl,%dl
f0104e45:	74 47                	je     f0104e8e <envid2env+0xb7>
f0104e47:	e8 24 33 00 00       	call   f0108170 <cpunum>
f0104e4c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e53:	29 c2                	sub    %eax,%edx
f0104e55:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e58:	39 1c 85 28 70 35 f0 	cmp    %ebx,-0xfca8fd8(,%eax,4)
f0104e5f:	74 2d                	je     f0104e8e <envid2env+0xb7>
f0104e61:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0104e64:	e8 07 33 00 00       	call   f0108170 <cpunum>
f0104e69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e70:	29 c2                	sub    %eax,%edx
f0104e72:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e75:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0104e7c:	3b 78 48             	cmp    0x48(%eax),%edi
f0104e7f:	74 0d                	je     f0104e8e <envid2env+0xb7>
		*env_store = 0;
f0104e81:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0104e87:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e8c:	eb 07                	jmp    f0104e95 <envid2env+0xbe>
	}

	*env_store = e;
f0104e8e:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0104e90:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e95:	83 c4 0c             	add    $0xc,%esp
f0104e98:	5b                   	pop    %ebx
f0104e99:	5e                   	pop    %esi
f0104e9a:	5f                   	pop    %edi
f0104e9b:	5d                   	pop    %ebp
f0104e9c:	c3                   	ret    

f0104e9d <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0104e9d:	55                   	push   %ebp
f0104e9e:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0104ea0:	b8 60 f1 14 f0       	mov    $0xf014f160,%eax
f0104ea5:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0104ea8:	b8 23 00 00 00       	mov    $0x23,%eax
f0104ead:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0104eaf:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0104eb1:	b0 10                	mov    $0x10,%al
f0104eb3:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0104eb5:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0104eb7:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0104eb9:	ea c0 4e 10 f0 08 00 	ljmp   $0x8,$0xf0104ec0
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0104ec0:	b0 00                	mov    $0x0,%al
f0104ec2:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0104ec5:	5d                   	pop    %ebp
f0104ec6:	c3                   	ret    

f0104ec7 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0104ec7:	55                   	push   %ebp
f0104ec8:	89 e5                	mov    %esp,%ebp
f0104eca:	56                   	push   %esi
f0104ecb:	53                   	push   %ebx
f0104ecc:	83 ec 10             	sub    $0x10,%esp
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
f0104ecf:	83 3d 54 62 35 f0 00 	cmpl   $0x0,0xf0356254
f0104ed6:	74 24                	je     f0104efc <env_init+0x35>
f0104ed8:	c7 44 24 0c 79 aa 10 	movl   $0xf010aa79,0xc(%esp)
f0104edf:	f0 
f0104ee0:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0104ee7:	f0 
f0104ee8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
f0104eef:	00 
f0104ef0:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f0104ef7:	e8 44 b1 ff ff       	call   f0100040 <_panic>
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
f0104efc:	8b 35 50 62 35 f0    	mov    0xf0356250,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0104f02:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0104f08:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f0d:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0104f12:	eb 02                	jmp    f0104f16 <env_init+0x4f>
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0104f14:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
f0104f16:	89 c3                	mov    %eax,%ebx
f0104f18:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0104f1f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0104f26:	89 48 44             	mov    %ecx,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
f0104f29:	4a                   	dec    %edx
f0104f2a:	83 e8 7c             	sub    $0x7c,%eax
f0104f2d:	83 fa ff             	cmp    $0xffffffff,%edx
f0104f30:	75 e2                	jne    f0104f14 <env_init+0x4d>
f0104f32:	89 35 54 62 35 f0    	mov    %esi,0xf0356254
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0104f38:	e8 60 ff ff ff       	call   f0104e9d <env_init_percpu>
}
f0104f3d:	83 c4 10             	add    $0x10,%esp
f0104f40:	5b                   	pop    %ebx
f0104f41:	5e                   	pop    %esi
f0104f42:	5d                   	pop    %ebp
f0104f43:	c3                   	ret    

f0104f44 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0104f44:	55                   	push   %ebp
f0104f45:	89 e5                	mov    %esp,%ebp
f0104f47:	56                   	push   %esi
f0104f48:	53                   	push   %ebx
f0104f49:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0104f4c:	8b 1d 54 62 35 f0    	mov    0xf0356254,%ebx
f0104f52:	85 db                	test   %ebx,%ebx
f0104f54:	0f 84 df 01 00 00    	je     f0105139 <env_alloc+0x1f5>
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0104f5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104f61:	e8 03 d8 ff ff       	call   f0102769 <page_alloc>
f0104f66:	85 c0                	test   %eax,%eax
f0104f68:	0f 84 d2 01 00 00    	je     f0105140 <env_alloc+0x1fc>
f0104f6e:	89 c2                	mov    %eax,%edx
f0104f70:	2b 15 90 6e 35 f0    	sub    0xf0356e90,%edx
f0104f76:	c1 fa 03             	sar    $0x3,%edx
f0104f79:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104f7c:	89 d1                	mov    %edx,%ecx
f0104f7e:	c1 e9 0c             	shr    $0xc,%ecx
f0104f81:	3b 0d 88 6e 35 f0    	cmp    0xf0356e88,%ecx
f0104f87:	72 20                	jb     f0104fa9 <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f89:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104f8d:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0104f94:	f0 
f0104f95:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0104f9c:	00 
f0104f9d:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0104fa4:	e8 97 b0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104fa9:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0104faf:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t*)page2kva(p);
	p->pp_ref++;
f0104fb2:	66 ff 40 04          	incw   0x4(%eax)

	for (int i = 0; i < PDX(UTOP); i++){
f0104fb6:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fbb:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f0104fc0:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0104fc3:	c7 04 91 00 00 00 00 	movl   $0x0,(%ecx,%edx,4)

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t*)page2kva(p);
	p->pp_ref++;

	for (int i = 0; i < PDX(UTOP); i++){
f0104fca:	40                   	inc    %eax
f0104fcb:	89 c2                	mov    %eax,%edx
f0104fcd:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0104fd2:	75 ec                	jne    f0104fc0 <env_alloc+0x7c>
f0104fd4:	66 b8 ec 0e          	mov    $0xeec,%ax
		e->env_pgdir[i] = 0;
	}

	for (int i = PDX(UTOP); i < NPDENTRIES; i++){
		e->env_pgdir[i] = kern_pgdir[i];
f0104fd8:	8b 15 8c 6e 35 f0    	mov    0xf0356e8c,%edx
f0104fde:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0104fe1:	8b 53 60             	mov    0x60(%ebx),%edx
f0104fe4:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0104fe7:	83 c0 04             	add    $0x4,%eax

	for (int i = 0; i < PDX(UTOP); i++){
		e->env_pgdir[i] = 0;
	}

	for (int i = PDX(UTOP); i < NPDENTRIES; i++){
f0104fea:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0104fef:	75 e7                	jne    f0104fd8 <env_alloc+0x94>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0104ff1:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104ff4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104ff9:	77 20                	ja     f010501b <env_alloc+0xd7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104ffb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fff:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0105006:	f0 
f0105007:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f010500e:	00 
f010500f:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f0105016:	e8 25 b0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010501b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0105021:	83 ca 05             	or     $0x5,%edx
f0105024:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010502a:	8b 43 48             	mov    0x48(%ebx),%eax
f010502d:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0105032:	89 c1                	mov    %eax,%ecx
f0105034:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f010503a:	7f 05                	jg     f0105041 <env_alloc+0xfd>
		generation = 1 << ENVGENSHIFT;
f010503c:	b9 00 10 00 00       	mov    $0x1000,%ecx
	
	e->env_id = generation | (e - envs);
f0105041:	89 d8                	mov    %ebx,%eax
f0105043:	2b 05 50 62 35 f0    	sub    0xf0356250,%eax
f0105049:	c1 f8 02             	sar    $0x2,%eax
f010504c:	89 c6                	mov    %eax,%esi
f010504e:	c1 e6 05             	shl    $0x5,%esi
f0105051:	89 c2                	mov    %eax,%edx
f0105053:	c1 e2 0a             	shl    $0xa,%edx
f0105056:	01 f2                	add    %esi,%edx
f0105058:	01 c2                	add    %eax,%edx
f010505a:	89 d6                	mov    %edx,%esi
f010505c:	c1 e6 0f             	shl    $0xf,%esi
f010505f:	01 f2                	add    %esi,%edx
f0105061:	c1 e2 05             	shl    $0x5,%edx
f0105064:	01 d0                	add    %edx,%eax
f0105066:	f7 d8                	neg    %eax
f0105068:	09 c1                	or     %eax,%ecx
f010506a:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010506d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105070:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0105073:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010507a:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0105081:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0105088:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010508f:	00 
f0105090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0105097:	00 
f0105098:	89 1c 24             	mov    %ebx,(%esp)
f010509b:	e8 a2 2a 00 00       	call   f0107b42 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01050a0:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01050a6:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01050ac:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01050b2:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01050b9:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f01050bf:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01050c6:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01050cd:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01050d1:	8b 43 44             	mov    0x44(%ebx),%eax
f01050d4:	a3 54 62 35 f0       	mov    %eax,0xf0356254
	*newenv_store = e;
f01050d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01050dc:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01050de:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01050e1:	e8 8a 30 00 00       	call   f0108170 <cpunum>
f01050e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01050ed:	29 c2                	sub    %eax,%edx
f01050ef:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01050f2:	83 3c 85 28 70 35 f0 	cmpl   $0x0,-0xfca8fd8(,%eax,4)
f01050f9:	00 
f01050fa:	74 1d                	je     f0105119 <env_alloc+0x1d5>
f01050fc:	e8 6f 30 00 00       	call   f0108170 <cpunum>
f0105101:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105108:	29 c2                	sub    %eax,%edx
f010510a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010510d:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0105114:	8b 40 48             	mov    0x48(%eax),%eax
f0105117:	eb 05                	jmp    f010511e <env_alloc+0x1da>
f0105119:	b8 00 00 00 00       	mov    $0x0,%eax
f010511e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105122:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105126:	c7 04 24 8f aa 10 f0 	movl   $0xf010aa8f,(%esp)
f010512d:	e8 bc 06 00 00       	call   f01057ee <cprintf>
	return 0;
f0105132:	b8 00 00 00 00       	mov    $0x0,%eax
f0105137:	eb 0c                	jmp    f0105145 <env_alloc+0x201>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0105139:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010513e:	eb 05                	jmp    f0105145 <env_alloc+0x201>
{
	int i;
	struct PageInfo *p = NULL;
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0105140:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0105145:	83 c4 10             	add    $0x10,%esp
f0105148:	5b                   	pop    %ebx
f0105149:	5e                   	pop    %esi
f010514a:	5d                   	pop    %ebp
f010514b:	c3                   	ret    

f010514c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010514c:	55                   	push   %ebp
f010514d:	89 e5                	mov    %esp,%ebp
f010514f:	57                   	push   %edi
f0105150:	56                   	push   %esi
f0105151:	53                   	push   %ebx
f0105152:	83 ec 3c             	sub    $0x3c,%esp
f0105155:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	assert(env_alloc(&e,0) == 0);
f0105158:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010515f:	00 
f0105160:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105163:	89 04 24             	mov    %eax,(%esp)
f0105166:	e8 d9 fd ff ff       	call   f0104f44 <env_alloc>
f010516b:	85 c0                	test   %eax,%eax
f010516d:	74 24                	je     f0105193 <env_create+0x47>
f010516f:	c7 44 24 0c a4 aa 10 	movl   $0xf010aaa4,0xc(%esp)
f0105176:	f0 
f0105177:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f010517e:	f0 
f010517f:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f0105186:	00 
f0105187:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f010518e:	e8 ad ae ff ff       	call   f0100040 <_panic>
	load_icode(e,binary);
f0105193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105196:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.

	struct Elf *ELFHDR = (struct Elf *)binary;
	if (ELFHDR->e_magic != ELF_MAGIC)
f0105199:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010519f:	74 1c                	je     f01051bd <env_create+0x71>
		panic("load_icode: ELFHDR->e_magic != ELF_MAGIC\n");
f01051a1:	c7 44 24 08 44 aa 10 	movl   $0xf010aa44,0x8(%esp)
f01051a8:	f0 
f01051a9:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f01051b0:	00 
f01051b1:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f01051b8:	e8 83 ae ff ff       	call   f0100040 <_panic>
	
	e->env_tf.tf_eip = ELFHDR->e_entry;
f01051bd:	8b 47 18             	mov    0x18(%edi),%eax
f01051c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01051c3:	89 42 30             	mov    %eax,0x30(%edx)
	lcr3(PADDR(e->env_pgdir));
f01051c6:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01051c9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01051ce:	77 20                	ja     f01051f0 <env_create+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01051d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01051d4:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f01051db:	f0 
f01051dc:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f01051e3:	00 
f01051e4:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f01051eb:	e8 50 ae ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01051f0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01051f5:	0f 22 d8             	mov    %eax,%cr3

	struct Proghdr *ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
f01051f8:	89 fb                	mov    %edi,%ebx
f01051fa:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr *eph = ph + ELFHDR->e_phnum;
f01051fd:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0105201:	c1 e6 05             	shl    $0x5,%esi
f0105204:	01 de                	add    %ebx,%esi
f0105206:	eb 74                	jmp    f010527c <env_create+0x130>
    for (; ph < eph; ph++){
		#ifdef DEBUG
			cprintf("memory size: %x\nfile size: %x\nvirtual address: %x\noffset: %x\n\n",ph->p_memsz,ph->p_filesz,ph->p_va,ph->p_offset);
		#endif
		if (ph->p_type == ELF_PROG_LOAD){
f0105208:	83 3b 01             	cmpl   $0x1,(%ebx)
f010520b:	75 6c                	jne    f0105279 <env_create+0x12d>
			assert(ph->p_memsz >= ph->p_filesz);
f010520d:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0105210:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f0105213:	73 24                	jae    f0105239 <env_create+0xed>
f0105215:	c7 44 24 0c b9 aa 10 	movl   $0xf010aab9,0xc(%esp)
f010521c:	f0 
f010521d:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0105224:	f0 
f0105225:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f010522c:	00 
f010522d:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f0105234:	e8 07 ae ff ff       	call   f0100040 <_panic>
			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f0105239:	8b 53 08             	mov    0x8(%ebx),%edx
f010523c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010523f:	e8 f8 fa ff ff       	call   f0104d3c <region_alloc>
            memset((void *)ph->p_va, 0, ph->p_memsz);
f0105244:	8b 43 14             	mov    0x14(%ebx),%eax
f0105247:	89 44 24 08          	mov    %eax,0x8(%esp)
f010524b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0105252:	00 
f0105253:	8b 43 08             	mov    0x8(%ebx),%eax
f0105256:	89 04 24             	mov    %eax,(%esp)
f0105259:	e8 e4 28 00 00       	call   f0107b42 <memset>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010525e:	8b 43 10             	mov    0x10(%ebx),%eax
f0105261:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105265:	89 f8                	mov    %edi,%eax
f0105267:	03 43 04             	add    0x4(%ebx),%eax
f010526a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010526e:	8b 43 08             	mov    0x8(%ebx),%eax
f0105271:	89 04 24             	mov    %eax,(%esp)
f0105274:	e8 7d 29 00 00       	call   f0107bf6 <memcpy>
	e->env_tf.tf_eip = ELFHDR->e_entry;
	lcr3(PADDR(e->env_pgdir));

	struct Proghdr *ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
	struct Proghdr *eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph++){
f0105279:	83 c3 20             	add    $0x20,%ebx
f010527c:	39 de                	cmp    %ebx,%esi
f010527e:	77 88                	ja     f0105208 <env_create+0xbc>

    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f0105280:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0105285:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010528a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010528d:	e8 aa fa ff ff       	call   f0104d3c <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *e;
	assert(env_alloc(&e,0) == 0);
	load_icode(e,binary);
	e->env_type = type;
f0105292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105295:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105298:	89 50 50             	mov    %edx,0x50(%eax)
}
f010529b:	83 c4 3c             	add    $0x3c,%esp
f010529e:	5b                   	pop    %ebx
f010529f:	5e                   	pop    %esi
f01052a0:	5f                   	pop    %edi
f01052a1:	5d                   	pop    %ebp
f01052a2:	c3                   	ret    

f01052a3 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01052a3:	55                   	push   %ebp
f01052a4:	89 e5                	mov    %esp,%ebp
f01052a6:	57                   	push   %edi
f01052a7:	56                   	push   %esi
f01052a8:	53                   	push   %ebx
f01052a9:	83 ec 2c             	sub    $0x2c,%esp
f01052ac:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01052af:	e8 bc 2e 00 00       	call   f0108170 <cpunum>
f01052b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052bb:	29 c2                	sub    %eax,%edx
f01052bd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052c0:	39 3c 85 28 70 35 f0 	cmp    %edi,-0xfca8fd8(,%eax,4)
f01052c7:	75 34                	jne    f01052fd <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f01052c9:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01052ce:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01052d3:	77 20                	ja     f01052f5 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01052d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01052d9:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f01052e0:	f0 
f01052e1:	c7 44 24 04 af 01 00 	movl   $0x1af,0x4(%esp)
f01052e8:	00 
f01052e9:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f01052f0:	e8 4b ad ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01052f5:	05 00 00 00 10       	add    $0x10000000,%eax
f01052fa:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01052fd:	8b 5f 48             	mov    0x48(%edi),%ebx
f0105300:	e8 6b 2e 00 00       	call   f0108170 <cpunum>
f0105305:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010530c:	29 c2                	sub    %eax,%edx
f010530e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105311:	83 3c 85 28 70 35 f0 	cmpl   $0x0,-0xfca8fd8(,%eax,4)
f0105318:	00 
f0105319:	74 1d                	je     f0105338 <env_free+0x95>
f010531b:	e8 50 2e 00 00       	call   f0108170 <cpunum>
f0105320:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105327:	29 c2                	sub    %eax,%edx
f0105329:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010532c:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0105333:	8b 40 48             	mov    0x48(%eax),%eax
f0105336:	eb 05                	jmp    f010533d <env_free+0x9a>
f0105338:	b8 00 00 00 00       	mov    $0x0,%eax
f010533d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105341:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105345:	c7 04 24 d5 aa 10 f0 	movl   $0xf010aad5,(%esp)
f010534c:	e8 9d 04 00 00       	call   f01057ee <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0105351:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0105358:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010535b:	c1 e0 02             	shl    $0x2,%eax
f010535e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105361:	8b 47 60             	mov    0x60(%edi),%eax
f0105364:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105367:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010536a:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0105370:	0f 84 b6 00 00 00    	je     f010542c <env_free+0x189>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0105376:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010537c:	89 f0                	mov    %esi,%eax
f010537e:	c1 e8 0c             	shr    $0xc,%eax
f0105381:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105384:	3b 05 88 6e 35 f0    	cmp    0xf0356e88,%eax
f010538a:	72 20                	jb     f01053ac <env_free+0x109>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010538c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105390:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0105397:	f0 
f0105398:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f010539f:	00 
f01053a0:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f01053a7:	e8 94 ac ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01053ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01053af:	c1 e2 16             	shl    $0x16,%edx
f01053b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01053b5:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01053ba:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01053c1:	01 
f01053c2:	74 17                	je     f01053db <env_free+0x138>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01053c4:	89 d8                	mov    %ebx,%eax
f01053c6:	c1 e0 0c             	shl    $0xc,%eax
f01053c9:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01053cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053d0:	8b 47 60             	mov    0x60(%edi),%eax
f01053d3:	89 04 24             	mov    %eax,(%esp)
f01053d6:	e8 bb d6 ff ff       	call   f0102a96 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01053db:	43                   	inc    %ebx
f01053dc:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01053e2:	75 d6                	jne    f01053ba <env_free+0x117>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01053e4:	8b 47 60             	mov    0x60(%edi),%eax
f01053e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01053ea:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01053f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053f4:	3b 05 88 6e 35 f0    	cmp    0xf0356e88,%eax
f01053fa:	72 1c                	jb     f0105418 <env_free+0x175>
		panic("pa2page called with invalid pa");
f01053fc:	c7 44 24 08 30 9e 10 	movl   $0xf0109e30,0x8(%esp)
f0105403:	f0 
f0105404:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010540b:	00 
f010540c:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0105413:	e8 28 ac ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0105418:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010541b:	c1 e0 03             	shl    $0x3,%eax
f010541e:	03 05 90 6e 35 f0    	add    0xf0356e90,%eax
		page_decref(pa2page(pa));
f0105424:	89 04 24             	mov    %eax,(%esp)
f0105427:	e8 01 d4 ff ff       	call   f010282d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010542c:	ff 45 e0             	incl   -0x20(%ebp)
f010542f:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0105436:	0f 85 1c ff ff ff    	jne    f0105358 <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010543c:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010543f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0105444:	77 20                	ja     f0105466 <env_free+0x1c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105446:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010544a:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f0105451:	f0 
f0105452:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f0105459:	00 
f010545a:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f0105461:	e8 da ab ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0105466:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010546d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105472:	c1 e8 0c             	shr    $0xc,%eax
f0105475:	3b 05 88 6e 35 f0    	cmp    0xf0356e88,%eax
f010547b:	72 1c                	jb     f0105499 <env_free+0x1f6>
		panic("pa2page called with invalid pa");
f010547d:	c7 44 24 08 30 9e 10 	movl   $0xf0109e30,0x8(%esp)
f0105484:	f0 
f0105485:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010548c:	00 
f010548d:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0105494:	e8 a7 ab ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0105499:	c1 e0 03             	shl    $0x3,%eax
f010549c:	03 05 90 6e 35 f0    	add    0xf0356e90,%eax
	page_decref(pa2page(pa));
f01054a2:	89 04 24             	mov    %eax,(%esp)
f01054a5:	e8 83 d3 ff ff       	call   f010282d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01054aa:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01054b1:	a1 54 62 35 f0       	mov    0xf0356254,%eax
f01054b6:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01054b9:	89 3d 54 62 35 f0    	mov    %edi,0xf0356254
}
f01054bf:	83 c4 2c             	add    $0x2c,%esp
f01054c2:	5b                   	pop    %ebx
f01054c3:	5e                   	pop    %esi
f01054c4:	5f                   	pop    %edi
f01054c5:	5d                   	pop    %ebp
f01054c6:	c3                   	ret    

f01054c7 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01054c7:	55                   	push   %ebp
f01054c8:	89 e5                	mov    %esp,%ebp
f01054ca:	53                   	push   %ebx
f01054cb:	83 ec 14             	sub    $0x14,%esp
f01054ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01054d1:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01054d5:	75 23                	jne    f01054fa <env_destroy+0x33>
f01054d7:	e8 94 2c 00 00       	call   f0108170 <cpunum>
f01054dc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01054e3:	29 c2                	sub    %eax,%edx
f01054e5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01054e8:	39 1c 85 28 70 35 f0 	cmp    %ebx,-0xfca8fd8(,%eax,4)
f01054ef:	74 09                	je     f01054fa <env_destroy+0x33>
		e->env_status = ENV_DYING;
f01054f1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01054f8:	eb 39                	jmp    f0105533 <env_destroy+0x6c>
	}

	env_free(e);
f01054fa:	89 1c 24             	mov    %ebx,(%esp)
f01054fd:	e8 a1 fd ff ff       	call   f01052a3 <env_free>

	if (curenv == e) {
f0105502:	e8 69 2c 00 00       	call   f0108170 <cpunum>
f0105507:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010550e:	29 c2                	sub    %eax,%edx
f0105510:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105513:	39 1c 85 28 70 35 f0 	cmp    %ebx,-0xfca8fd8(,%eax,4)
f010551a:	75 17                	jne    f0105533 <env_destroy+0x6c>
		curenv = NULL;
f010551c:	e8 4f 2c 00 00       	call   f0108170 <cpunum>
f0105521:	6b c0 74             	imul   $0x74,%eax,%eax
f0105524:	c7 80 28 70 35 f0 00 	movl   $0x0,-0xfca8fd8(%eax)
f010552b:	00 00 00 
		sched_yield();
f010552e:	e8 bf 12 00 00       	call   f01067f2 <sched_yield>
	}
}
f0105533:	83 c4 14             	add    $0x14,%esp
f0105536:	5b                   	pop    %ebx
f0105537:	5d                   	pop    %ebp
f0105538:	c3                   	ret    

f0105539 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0105539:	55                   	push   %ebp
f010553a:	89 e5                	mov    %esp,%ebp
f010553c:	53                   	push   %ebx
f010553d:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0105540:	e8 2b 2c 00 00       	call   f0108170 <cpunum>
f0105545:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010554c:	29 c2                	sub    %eax,%edx
f010554e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105551:	8b 1c 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%ebx
f0105558:	e8 13 2c 00 00       	call   f0108170 <cpunum>
f010555d:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0105560:	8b 65 08             	mov    0x8(%ebp),%esp
f0105563:	61                   	popa   
f0105564:	07                   	pop    %es
f0105565:	1f                   	pop    %ds
f0105566:	83 c4 08             	add    $0x8,%esp
f0105569:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010556a:	c7 44 24 08 eb aa 10 	movl   $0xf010aaeb,0x8(%esp)
f0105571:	f0 
f0105572:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
f0105579:	00 
f010557a:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f0105581:	e8 ba aa ff ff       	call   f0100040 <_panic>

f0105586 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0105586:	55                   	push   %ebp
f0105587:	89 e5                	mov    %esp,%ebp
f0105589:	83 ec 18             	sub    $0x18,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f010558c:	e8 df 2b 00 00       	call   f0108170 <cpunum>
f0105591:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105598:	29 c2                	sub    %eax,%edx
f010559a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010559d:	83 3c 85 28 70 35 f0 	cmpl   $0x0,-0xfca8fd8(,%eax,4)
f01055a4:	00 
f01055a5:	74 33                	je     f01055da <env_run+0x54>
f01055a7:	e8 c4 2b 00 00       	call   f0108170 <cpunum>
f01055ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01055b3:	29 c2                	sub    %eax,%edx
f01055b5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01055b8:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f01055bf:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01055c3:	75 15                	jne    f01055da <env_run+0x54>
        curenv->env_status = ENV_RUNNABLE;
f01055c5:	e8 a6 2b 00 00       	call   f0108170 <cpunum>
f01055ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01055cd:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f01055d3:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	// cprintf("env_run: %x %x\n",curenv,curenv->env_tf.tf_eip);
    curenv = e;
f01055da:	e8 91 2b 00 00       	call   f0108170 <cpunum>
f01055df:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01055e6:	29 c2                	sub    %eax,%edx
f01055e8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01055eb:	8b 55 08             	mov    0x8(%ebp),%edx
f01055ee:	89 14 85 28 70 35 f0 	mov    %edx,-0xfca8fd8(,%eax,4)
	// cprintf("env %x\n",e);
    curenv->env_status = ENV_RUNNING;
f01055f5:	e8 76 2b 00 00       	call   f0108170 <cpunum>
f01055fa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105601:	29 c2                	sub    %eax,%edx
f0105603:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105606:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f010560d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0105614:	e8 57 2b 00 00       	call   f0108170 <cpunum>
f0105619:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105620:	29 c2                	sub    %eax,%edx
f0105622:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105625:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f010562c:	ff 40 58             	incl   0x58(%eax)
    lcr3(PADDR(curenv->env_pgdir));
f010562f:	e8 3c 2b 00 00       	call   f0108170 <cpunum>
f0105634:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010563b:	29 c2                	sub    %eax,%edx
f010563d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105640:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0105647:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010564a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010564f:	77 20                	ja     f0105671 <env_run+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0105651:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105655:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f010565c:	f0 
f010565d:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
f0105664:	00 
f0105665:	c7 04 24 6e aa 10 f0 	movl   $0xf010aa6e,(%esp)
f010566c:	e8 cf a9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0105671:	05 00 00 00 10       	add    $0x10000000,%eax
f0105676:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105679:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f0105680:	e8 4d 2e 00 00       	call   f01084d2 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105685:	f3 90                	pause  
	unlock_kernel();
	// cprintf("env_run: %x %x\n",curenv,curenv->env_tf.tf_eip);
    env_pop_tf(&curenv->env_tf);
f0105687:	e8 e4 2a 00 00       	call   f0108170 <cpunum>
f010568c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105693:	29 c2                	sub    %eax,%edx
f0105695:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105698:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f010569f:	89 04 24             	mov    %eax,(%esp)
f01056a2:	e8 92 fe ff ff       	call   f0105539 <env_pop_tf>
	...

f01056a8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01056a8:	55                   	push   %ebp
f01056a9:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01056ab:	ba 70 00 00 00       	mov    $0x70,%edx
f01056b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01056b3:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01056b4:	b2 71                	mov    $0x71,%dl
f01056b6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01056b7:	0f b6 c0             	movzbl %al,%eax
}
f01056ba:	5d                   	pop    %ebp
f01056bb:	c3                   	ret    

f01056bc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01056bc:	55                   	push   %ebp
f01056bd:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01056bf:	ba 70 00 00 00       	mov    $0x70,%edx
f01056c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01056c7:	ee                   	out    %al,(%dx)
f01056c8:	b2 71                	mov    $0x71,%dl
f01056ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056cd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01056ce:	5d                   	pop    %ebp
f01056cf:	c3                   	ret    

f01056d0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01056d0:	55                   	push   %ebp
f01056d1:	89 e5                	mov    %esp,%ebp
f01056d3:	56                   	push   %esi
f01056d4:	53                   	push   %ebx
f01056d5:	83 ec 10             	sub    $0x10,%esp
f01056d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01056db:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01056dd:	66 a3 e8 f1 14 f0    	mov    %ax,0xf014f1e8
	if (!didinit)
f01056e3:	80 3d 58 62 35 f0 00 	cmpb   $0x0,0xf0356258
f01056ea:	74 51                	je     f010573d <irq_setmask_8259A+0x6d>
f01056ec:	ba 21 00 00 00       	mov    $0x21,%edx
f01056f1:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01056f2:	89 f0                	mov    %esi,%eax
f01056f4:	66 c1 e8 08          	shr    $0x8,%ax
f01056f8:	b2 a1                	mov    $0xa1,%dl
f01056fa:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01056fb:	c7 04 24 f7 aa 10 f0 	movl   $0xf010aaf7,(%esp)
f0105702:	e8 e7 00 00 00       	call   f01057ee <cprintf>
	for (i = 0; i < 16; i++)
f0105707:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010570c:	0f b7 f6             	movzwl %si,%esi
f010570f:	f7 d6                	not    %esi
f0105711:	89 f0                	mov    %esi,%eax
f0105713:	88 d9                	mov    %bl,%cl
f0105715:	d3 f8                	sar    %cl,%eax
f0105717:	a8 01                	test   $0x1,%al
f0105719:	74 10                	je     f010572b <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f010571b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010571f:	c7 04 24 db af 10 f0 	movl   $0xf010afdb,(%esp)
f0105726:	e8 c3 00 00 00       	call   f01057ee <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010572b:	43                   	inc    %ebx
f010572c:	83 fb 10             	cmp    $0x10,%ebx
f010572f:	75 e0                	jne    f0105711 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0105731:	c7 04 24 c8 a9 10 f0 	movl   $0xf010a9c8,(%esp)
f0105738:	e8 b1 00 00 00       	call   f01057ee <cprintf>
}
f010573d:	83 c4 10             	add    $0x10,%esp
f0105740:	5b                   	pop    %ebx
f0105741:	5e                   	pop    %esi
f0105742:	5d                   	pop    %ebp
f0105743:	c3                   	ret    

f0105744 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0105744:	55                   	push   %ebp
f0105745:	89 e5                	mov    %esp,%ebp
f0105747:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010574a:	c6 05 58 62 35 f0 01 	movb   $0x1,0xf0356258
f0105751:	ba 21 00 00 00       	mov    $0x21,%edx
f0105756:	b0 ff                	mov    $0xff,%al
f0105758:	ee                   	out    %al,(%dx)
f0105759:	b2 a1                	mov    $0xa1,%dl
f010575b:	ee                   	out    %al,(%dx)
f010575c:	b2 20                	mov    $0x20,%dl
f010575e:	b0 11                	mov    $0x11,%al
f0105760:	ee                   	out    %al,(%dx)
f0105761:	b2 21                	mov    $0x21,%dl
f0105763:	b0 20                	mov    $0x20,%al
f0105765:	ee                   	out    %al,(%dx)
f0105766:	b0 04                	mov    $0x4,%al
f0105768:	ee                   	out    %al,(%dx)
f0105769:	b0 03                	mov    $0x3,%al
f010576b:	ee                   	out    %al,(%dx)
f010576c:	b2 a0                	mov    $0xa0,%dl
f010576e:	b0 11                	mov    $0x11,%al
f0105770:	ee                   	out    %al,(%dx)
f0105771:	b2 a1                	mov    $0xa1,%dl
f0105773:	b0 28                	mov    $0x28,%al
f0105775:	ee                   	out    %al,(%dx)
f0105776:	b0 02                	mov    $0x2,%al
f0105778:	ee                   	out    %al,(%dx)
f0105779:	b0 01                	mov    $0x1,%al
f010577b:	ee                   	out    %al,(%dx)
f010577c:	b2 20                	mov    $0x20,%dl
f010577e:	b0 68                	mov    $0x68,%al
f0105780:	ee                   	out    %al,(%dx)
f0105781:	b0 0a                	mov    $0xa,%al
f0105783:	ee                   	out    %al,(%dx)
f0105784:	b2 a0                	mov    $0xa0,%dl
f0105786:	b0 68                	mov    $0x68,%al
f0105788:	ee                   	out    %al,(%dx)
f0105789:	b0 0a                	mov    $0xa,%al
f010578b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010578c:	66 a1 e8 f1 14 f0    	mov    0xf014f1e8,%ax
f0105792:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0105796:	74 0b                	je     f01057a3 <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0105798:	0f b7 c0             	movzwl %ax,%eax
f010579b:	89 04 24             	mov    %eax,(%esp)
f010579e:	e8 2d ff ff ff       	call   f01056d0 <irq_setmask_8259A>
}
f01057a3:	c9                   	leave  
f01057a4:	c3                   	ret    
f01057a5:	00 00                	add    %al,(%eax)
	...

f01057a8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01057a8:	55                   	push   %ebp
f01057a9:	89 e5                	mov    %esp,%ebp
f01057ab:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01057ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01057b1:	89 04 24             	mov    %eax,(%esp)
f01057b4:	e8 87 b2 ff ff       	call   f0100a40 <cputchar>
	*cnt++;
}
f01057b9:	c9                   	leave  
f01057ba:	c3                   	ret    

f01057bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01057bb:	55                   	push   %ebp
f01057bc:	89 e5                	mov    %esp,%ebp
f01057be:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01057c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01057c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01057cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01057d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01057d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057dd:	c7 04 24 a8 57 10 f0 	movl   $0xf01057a8,(%esp)
f01057e4:	e8 19 1d 00 00       	call   f0107502 <vprintfmt>
	return cnt;
}
f01057e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01057ec:	c9                   	leave  
f01057ed:	c3                   	ret    

f01057ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01057ee:	55                   	push   %ebp
f01057ef:	89 e5                	mov    %esp,%ebp
f01057f1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01057f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01057f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01057fe:	89 04 24             	mov    %eax,(%esp)
f0105801:	e8 b5 ff ff ff       	call   f01057bb <vcprintf>
	va_end(ap);

	return cnt;
}
f0105806:	c9                   	leave  
f0105807:	c3                   	ret    

f0105808 <trap_init_percpu>:
void Handler_IRQ13();
void Handler_IRQ14();
void Handler_IRQ15();
void
trap_init_percpu(void)
{
f0105808:	55                   	push   %ebp
f0105809:	89 e5                	mov    %esp,%ebp
f010580b:	57                   	push   %edi
f010580c:	56                   	push   %esi
f010580d:	53                   	push   %ebx
f010580e:	83 ec 7c             	sub    $0x7c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	SETGATE(idt[IRQ_OFFSET],0,GD_KT,Handler_IRQ0,0);
f0105811:	b8 84 66 10 f0       	mov    $0xf0106684,%eax
f0105816:	66 a3 60 63 35 f0    	mov    %ax,0xf0356360
f010581c:	66 c7 05 62 63 35 f0 	movw   $0x8,0xf0356362
f0105823:	08 00 
f0105825:	c6 05 64 63 35 f0 00 	movb   $0x0,0xf0356364
f010582c:	c6 05 65 63 35 f0 8e 	movb   $0x8e,0xf0356365
f0105833:	c1 e8 10             	shr    $0x10,%eax
f0105836:	66 a3 66 63 35 f0    	mov    %ax,0xf0356366
	SETGATE(idt[IRQ_OFFSET+1],0,GD_KT,Handler_IRQ1,0);
f010583c:	b8 8a 66 10 f0       	mov    $0xf010668a,%eax
f0105841:	66 a3 68 63 35 f0    	mov    %ax,0xf0356368
f0105847:	66 c7 05 6a 63 35 f0 	movw   $0x8,0xf035636a
f010584e:	08 00 
f0105850:	c6 05 6c 63 35 f0 00 	movb   $0x0,0xf035636c
f0105857:	c6 05 6d 63 35 f0 8e 	movb   $0x8e,0xf035636d
f010585e:	c1 e8 10             	shr    $0x10,%eax
f0105861:	66 a3 6e 63 35 f0    	mov    %ax,0xf035636e
	SETGATE(idt[IRQ_OFFSET+2],0,GD_KT,Handler_IRQ2,0);
f0105867:	b8 90 66 10 f0       	mov    $0xf0106690,%eax
f010586c:	66 a3 70 63 35 f0    	mov    %ax,0xf0356370
f0105872:	66 c7 05 72 63 35 f0 	movw   $0x8,0xf0356372
f0105879:	08 00 
f010587b:	c6 05 74 63 35 f0 00 	movb   $0x0,0xf0356374
f0105882:	c6 05 75 63 35 f0 8e 	movb   $0x8e,0xf0356375
f0105889:	c1 e8 10             	shr    $0x10,%eax
f010588c:	66 a3 76 63 35 f0    	mov    %ax,0xf0356376
	SETGATE(idt[IRQ_OFFSET+3],0,GD_KT,Handler_IRQ3,0);
f0105892:	b8 96 66 10 f0       	mov    $0xf0106696,%eax
f0105897:	66 a3 78 63 35 f0    	mov    %ax,0xf0356378
f010589d:	66 c7 05 7a 63 35 f0 	movw   $0x8,0xf035637a
f01058a4:	08 00 
f01058a6:	c6 05 7c 63 35 f0 00 	movb   $0x0,0xf035637c
f01058ad:	c6 05 7d 63 35 f0 8e 	movb   $0x8e,0xf035637d
f01058b4:	c1 e8 10             	shr    $0x10,%eax
f01058b7:	66 a3 7e 63 35 f0    	mov    %ax,0xf035637e
	SETGATE(idt[IRQ_OFFSET+4],0,GD_KT,Handler_IRQ4,0);
f01058bd:	b8 9c 66 10 f0       	mov    $0xf010669c,%eax
f01058c2:	66 a3 80 63 35 f0    	mov    %ax,0xf0356380
f01058c8:	66 c7 05 82 63 35 f0 	movw   $0x8,0xf0356382
f01058cf:	08 00 
f01058d1:	c6 05 84 63 35 f0 00 	movb   $0x0,0xf0356384
f01058d8:	c6 05 85 63 35 f0 8e 	movb   $0x8e,0xf0356385
f01058df:	c1 e8 10             	shr    $0x10,%eax
f01058e2:	66 a3 86 63 35 f0    	mov    %ax,0xf0356386
	SETGATE(idt[IRQ_OFFSET+5],0,GD_KT,Handler_IRQ5,0);
f01058e8:	b8 a2 66 10 f0       	mov    $0xf01066a2,%eax
f01058ed:	66 a3 88 63 35 f0    	mov    %ax,0xf0356388
f01058f3:	66 c7 05 8a 63 35 f0 	movw   $0x8,0xf035638a
f01058fa:	08 00 
f01058fc:	c6 05 8c 63 35 f0 00 	movb   $0x0,0xf035638c
f0105903:	c6 05 8d 63 35 f0 8e 	movb   $0x8e,0xf035638d
f010590a:	c1 e8 10             	shr    $0x10,%eax
f010590d:	66 a3 8e 63 35 f0    	mov    %ax,0xf035638e
	SETGATE(idt[IRQ_OFFSET+6],0,GD_KT,Handler_IRQ6,0);
f0105913:	b8 a8 66 10 f0       	mov    $0xf01066a8,%eax
f0105918:	66 a3 90 63 35 f0    	mov    %ax,0xf0356390
f010591e:	66 c7 05 92 63 35 f0 	movw   $0x8,0xf0356392
f0105925:	08 00 
f0105927:	c6 05 94 63 35 f0 00 	movb   $0x0,0xf0356394
f010592e:	c6 05 95 63 35 f0 8e 	movb   $0x8e,0xf0356395
f0105935:	c1 e8 10             	shr    $0x10,%eax
f0105938:	66 a3 96 63 35 f0    	mov    %ax,0xf0356396
	SETGATE(idt[IRQ_OFFSET+7],0,GD_KT,Handler_IRQ7,0);
f010593e:	b8 ae 66 10 f0       	mov    $0xf01066ae,%eax
f0105943:	66 a3 98 63 35 f0    	mov    %ax,0xf0356398
f0105949:	66 c7 05 9a 63 35 f0 	movw   $0x8,0xf035639a
f0105950:	08 00 
f0105952:	c6 05 9c 63 35 f0 00 	movb   $0x0,0xf035639c
f0105959:	c6 05 9d 63 35 f0 8e 	movb   $0x8e,0xf035639d
f0105960:	c1 e8 10             	shr    $0x10,%eax
f0105963:	66 a3 9e 63 35 f0    	mov    %ax,0xf035639e
	SETGATE(idt[IRQ_OFFSET+8],0,GD_KT,Handler_IRQ8,0);
f0105969:	b8 b4 66 10 f0       	mov    $0xf01066b4,%eax
f010596e:	66 a3 a0 63 35 f0    	mov    %ax,0xf03563a0
f0105974:	66 c7 05 a2 63 35 f0 	movw   $0x8,0xf03563a2
f010597b:	08 00 
f010597d:	c6 05 a4 63 35 f0 00 	movb   $0x0,0xf03563a4
f0105984:	c6 05 a5 63 35 f0 8e 	movb   $0x8e,0xf03563a5
f010598b:	c1 e8 10             	shr    $0x10,%eax
f010598e:	66 a3 a6 63 35 f0    	mov    %ax,0xf03563a6
	SETGATE(idt[IRQ_OFFSET+9],0,GD_KT,Handler_IRQ9,0);
f0105994:	b8 ba 66 10 f0       	mov    $0xf01066ba,%eax
f0105999:	66 a3 a8 63 35 f0    	mov    %ax,0xf03563a8
f010599f:	66 c7 05 aa 63 35 f0 	movw   $0x8,0xf03563aa
f01059a6:	08 00 
f01059a8:	c6 05 ac 63 35 f0 00 	movb   $0x0,0xf03563ac
f01059af:	c6 05 ad 63 35 f0 8e 	movb   $0x8e,0xf03563ad
f01059b6:	c1 e8 10             	shr    $0x10,%eax
f01059b9:	66 a3 ae 63 35 f0    	mov    %ax,0xf03563ae
	SETGATE(idt[IRQ_OFFSET+10],0,GD_KT,Handler_IRQ10,0);
f01059bf:	b8 c0 66 10 f0       	mov    $0xf01066c0,%eax
f01059c4:	66 a3 b0 63 35 f0    	mov    %ax,0xf03563b0
f01059ca:	66 c7 05 b2 63 35 f0 	movw   $0x8,0xf03563b2
f01059d1:	08 00 
f01059d3:	c6 05 b4 63 35 f0 00 	movb   $0x0,0xf03563b4
f01059da:	c6 05 b5 63 35 f0 8e 	movb   $0x8e,0xf03563b5
f01059e1:	c1 e8 10             	shr    $0x10,%eax
f01059e4:	66 a3 b6 63 35 f0    	mov    %ax,0xf03563b6
	SETGATE(idt[IRQ_OFFSET+11],0,GD_KT,Handler_IRQ11,0);
f01059ea:	b8 c6 66 10 f0       	mov    $0xf01066c6,%eax
f01059ef:	66 a3 b8 63 35 f0    	mov    %ax,0xf03563b8
f01059f5:	66 c7 05 ba 63 35 f0 	movw   $0x8,0xf03563ba
f01059fc:	08 00 
f01059fe:	c6 05 bc 63 35 f0 00 	movb   $0x0,0xf03563bc
f0105a05:	c6 05 bd 63 35 f0 8e 	movb   $0x8e,0xf03563bd
f0105a0c:	c1 e8 10             	shr    $0x10,%eax
f0105a0f:	66 a3 be 63 35 f0    	mov    %ax,0xf03563be
	SETGATE(idt[IRQ_OFFSET+12],0,GD_KT,Handler_IRQ12,0);
f0105a15:	b8 cc 66 10 f0       	mov    $0xf01066cc,%eax
f0105a1a:	66 a3 c0 63 35 f0    	mov    %ax,0xf03563c0
f0105a20:	66 c7 05 c2 63 35 f0 	movw   $0x8,0xf03563c2
f0105a27:	08 00 
f0105a29:	c6 05 c4 63 35 f0 00 	movb   $0x0,0xf03563c4
f0105a30:	c6 05 c5 63 35 f0 8e 	movb   $0x8e,0xf03563c5
f0105a37:	c1 e8 10             	shr    $0x10,%eax
f0105a3a:	66 a3 c6 63 35 f0    	mov    %ax,0xf03563c6
	SETGATE(idt[IRQ_OFFSET+13],0,GD_KT,Handler_IRQ13,0);
f0105a40:	b8 d2 66 10 f0       	mov    $0xf01066d2,%eax
f0105a45:	66 a3 c8 63 35 f0    	mov    %ax,0xf03563c8
f0105a4b:	66 c7 05 ca 63 35 f0 	movw   $0x8,0xf03563ca
f0105a52:	08 00 
f0105a54:	c6 05 cc 63 35 f0 00 	movb   $0x0,0xf03563cc
f0105a5b:	c6 05 cd 63 35 f0 8e 	movb   $0x8e,0xf03563cd
f0105a62:	c1 e8 10             	shr    $0x10,%eax
f0105a65:	66 a3 ce 63 35 f0    	mov    %ax,0xf03563ce
	SETGATE(idt[IRQ_OFFSET+14],0,GD_KT,Handler_IRQ14,0);
f0105a6b:	b8 d8 66 10 f0       	mov    $0xf01066d8,%eax
f0105a70:	66 a3 d0 63 35 f0    	mov    %ax,0xf03563d0
f0105a76:	66 c7 05 d2 63 35 f0 	movw   $0x8,0xf03563d2
f0105a7d:	08 00 
f0105a7f:	c6 05 d4 63 35 f0 00 	movb   $0x0,0xf03563d4
f0105a86:	c6 05 d5 63 35 f0 8e 	movb   $0x8e,0xf03563d5
f0105a8d:	c1 e8 10             	shr    $0x10,%eax
f0105a90:	66 a3 d6 63 35 f0    	mov    %ax,0xf03563d6
	SETGATE(idt[IRQ_OFFSET+15],0,GD_KT,Handler_IRQ15,0);
f0105a96:	b8 de 66 10 f0       	mov    $0xf01066de,%eax
f0105a9b:	66 a3 d8 63 35 f0    	mov    %ax,0xf03563d8
f0105aa1:	66 c7 05 da 63 35 f0 	movw   $0x8,0xf03563da
f0105aa8:	08 00 
f0105aaa:	c6 05 dc 63 35 f0 00 	movb   $0x0,0xf03563dc
f0105ab1:	c6 05 dd 63 35 f0 8e 	movb   $0x8e,0xf03563dd
f0105ab8:	c1 e8 10             	shr    $0x10,%eax
f0105abb:	66 a3 de 63 35 f0    	mov    %ax,0xf03563de
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	cprintf("%x\n",thiscpu->cpu_ts);
f0105ac1:	e8 aa 26 00 00       	call   f0108170 <cpunum>
f0105ac6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105acd:	29 c2                	sub    %eax,%edx
f0105acf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105ad2:	8d 7c 24 04          	lea    0x4(%esp),%edi
f0105ad6:	8d 34 85 2c 70 35 f0 	lea    -0xfca8fd4(,%eax,4),%esi
f0105add:	b9 1a 00 00 00       	mov    $0x1a,%ecx
f0105ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105ae4:	c7 04 24 6f b4 10 f0 	movl   $0xf010b46f,(%esp)
f0105aeb:	e8 fe fc ff ff       	call   f01057ee <cprintf>
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP);
f0105af0:	e8 7b 26 00 00       	call   f0108170 <cpunum>
f0105af5:	89 c3                	mov    %eax,%ebx
f0105af7:	e8 74 26 00 00       	call   f0108170 <cpunum>
f0105afc:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0105b03:	29 da                	sub    %ebx,%edx
f0105b05:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0105b08:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0105b0f:	29 c1                	sub    %eax,%ecx
f0105b11:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0105b14:	0f b6 04 85 20 70 35 	movzbl -0xfca8fe0(,%eax,4),%eax
f0105b1b:	f0 
f0105b1c:	f7 d8                	neg    %eax
f0105b1e:	c1 e0 10             	shl    $0x10,%eax
f0105b21:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105b26:	89 04 95 30 70 35 f0 	mov    %eax,-0xfca8fd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0105b2d:	e8 3e 26 00 00       	call   f0108170 <cpunum>
f0105b32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105b39:	29 c2                	sub    %eax,%edx
f0105b3b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105b3e:	66 c7 04 85 34 70 35 	movw   $0x10,-0xfca8fcc(,%eax,4)
f0105b45:	f0 10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0105b48:	e8 23 26 00 00       	call   f0108170 <cpunum>
f0105b4d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105b54:	29 c2                	sub    %eax,%edx
f0105b56:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105b59:	66 c7 04 85 92 70 35 	movw   $0x68,-0xfca8f6e(,%eax,4)
f0105b60:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id ] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0105b63:	e8 08 26 00 00       	call   f0108170 <cpunum>
f0105b68:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105b6f:	29 c2                	sub    %eax,%edx
f0105b71:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105b74:	0f b6 1c 85 20 70 35 	movzbl -0xfca8fe0(,%eax,4),%ebx
f0105b7b:	f0 
f0105b7c:	83 c3 05             	add    $0x5,%ebx
f0105b7f:	e8 ec 25 00 00       	call   f0108170 <cpunum>
f0105b84:	89 c6                	mov    %eax,%esi
f0105b86:	e8 e5 25 00 00       	call   f0108170 <cpunum>
f0105b8b:	89 c7                	mov    %eax,%edi
f0105b8d:	e8 de 25 00 00       	call   f0108170 <cpunum>
f0105b92:	66 c7 04 dd 80 f1 14 	movw   $0x67,-0xfeb0e80(,%ebx,8)
f0105b99:	f0 67 00 
f0105b9c:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0105ba3:	29 f2                	sub    %esi,%edx
f0105ba5:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105ba8:	8d 14 95 2c 70 35 f0 	lea    -0xfca8fd4(,%edx,4),%edx
f0105baf:	66 89 14 dd 82 f1 14 	mov    %dx,-0xfeb0e7e(,%ebx,8)
f0105bb6:	f0 
f0105bb7:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0105bbe:	29 fa                	sub    %edi,%edx
f0105bc0:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105bc3:	8d 14 95 2c 70 35 f0 	lea    -0xfca8fd4(,%edx,4),%edx
f0105bca:	c1 ea 10             	shr    $0x10,%edx
f0105bcd:	88 14 dd 84 f1 14 f0 	mov    %dl,-0xfeb0e7c(,%ebx,8)
f0105bd4:	c6 04 dd 85 f1 14 f0 	movb   $0x99,-0xfeb0e7b(,%ebx,8)
f0105bdb:	99 
f0105bdc:	c6 04 dd 86 f1 14 f0 	movb   $0x40,-0xfeb0e7a(,%ebx,8)
f0105be3:	40 
f0105be4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105beb:	29 c2                	sub    %eax,%edx
f0105bed:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105bf0:	8d 04 85 2c 70 35 f0 	lea    -0xfca8fd4(,%eax,4),%eax
f0105bf7:	c1 e8 18             	shr    $0x18,%eax
f0105bfa:	88 04 dd 87 f1 14 f0 	mov    %al,-0xfeb0e79(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id ].sd_s = 0;
f0105c01:	e8 6a 25 00 00       	call   f0108170 <cpunum>
f0105c06:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105c0d:	29 c2                	sub    %eax,%edx
f0105c0f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105c12:	0f b6 04 85 20 70 35 	movzbl -0xfca8fe0(,%eax,4),%eax
f0105c19:	f0 
f0105c1a:	80 24 c5 ad f1 14 f0 	andb   $0xef,-0xfeb0e53(,%eax,8)
f0105c21:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + thiscpu->cpu_id * 8);
f0105c22:	e8 49 25 00 00       	call   f0108170 <cpunum>
f0105c27:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105c2e:	29 c2                	sub    %eax,%edx
f0105c30:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105c33:	0f b6 04 85 20 70 35 	movzbl -0xfca8fe0(,%eax,4),%eax
f0105c3a:	f0 
f0105c3b:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0105c42:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0105c45:	b8 ec f1 14 f0       	mov    $0xf014f1ec,%eax
f0105c4a:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0105c4d:	83 c4 7c             	add    $0x7c,%esp
f0105c50:	5b                   	pop    %ebx
f0105c51:	5e                   	pop    %esi
f0105c52:	5f                   	pop    %edi
f0105c53:	5d                   	pop    %ebp
f0105c54:	c3                   	ret    

f0105c55 <trap_init>:
void Handler_SIMDERR();
void Handler_SYSCALL();

void 
trap_init(void)
{
f0105c55:	55                   	push   %ebp
f0105c56:	89 e5                	mov    %esp,%ebp
f0105c58:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
    SETGATE(idt[T_DIVIDE],0,GD_KT,Handler_DIVIDE,0);
f0105c5b:	b8 ec 65 10 f0       	mov    $0xf01065ec,%eax
f0105c60:	66 a3 60 62 35 f0    	mov    %ax,0xf0356260
f0105c66:	66 c7 05 62 62 35 f0 	movw   $0x8,0xf0356262
f0105c6d:	08 00 
f0105c6f:	c6 05 64 62 35 f0 00 	movb   $0x0,0xf0356264
f0105c76:	c6 05 65 62 35 f0 8e 	movb   $0x8e,0xf0356265
f0105c7d:	c1 e8 10             	shr    $0x10,%eax
f0105c80:	66 a3 66 62 35 f0    	mov    %ax,0xf0356266
    SETGATE(idt[T_DEBUG],0,GD_KT,Handler_DEBUG,3);
f0105c86:	b8 f6 65 10 f0       	mov    $0xf01065f6,%eax
f0105c8b:	66 a3 68 62 35 f0    	mov    %ax,0xf0356268
f0105c91:	66 c7 05 6a 62 35 f0 	movw   $0x8,0xf035626a
f0105c98:	08 00 
f0105c9a:	c6 05 6c 62 35 f0 00 	movb   $0x0,0xf035626c
f0105ca1:	c6 05 6d 62 35 f0 ee 	movb   $0xee,0xf035626d
f0105ca8:	c1 e8 10             	shr    $0x10,%eax
f0105cab:	66 a3 6e 62 35 f0    	mov    %ax,0xf035626e
    SETGATE(idt[T_NMI],0,GD_KT,Handler_NMI,0);
f0105cb1:	b8 00 66 10 f0       	mov    $0xf0106600,%eax
f0105cb6:	66 a3 70 62 35 f0    	mov    %ax,0xf0356270
f0105cbc:	66 c7 05 72 62 35 f0 	movw   $0x8,0xf0356272
f0105cc3:	08 00 
f0105cc5:	c6 05 74 62 35 f0 00 	movb   $0x0,0xf0356274
f0105ccc:	c6 05 75 62 35 f0 8e 	movb   $0x8e,0xf0356275
f0105cd3:	c1 e8 10             	shr    $0x10,%eax
f0105cd6:	66 a3 76 62 35 f0    	mov    %ax,0xf0356276
    SETGATE(idt[T_BRKPT],1,GD_KT,Handler_BRKPT,3);
f0105cdc:	b8 0a 66 10 f0       	mov    $0xf010660a,%eax
f0105ce1:	66 a3 78 62 35 f0    	mov    %ax,0xf0356278
f0105ce7:	66 c7 05 7a 62 35 f0 	movw   $0x8,0xf035627a
f0105cee:	08 00 
f0105cf0:	c6 05 7c 62 35 f0 00 	movb   $0x0,0xf035627c
f0105cf7:	c6 05 7d 62 35 f0 ef 	movb   $0xef,0xf035627d
f0105cfe:	c1 e8 10             	shr    $0x10,%eax
f0105d01:	66 a3 7e 62 35 f0    	mov    %ax,0xf035627e
    SETGATE(idt[T_OFLOW],1,GD_KT,Handler_OFLOW,0);
f0105d07:	b8 14 66 10 f0       	mov    $0xf0106614,%eax
f0105d0c:	66 a3 80 62 35 f0    	mov    %ax,0xf0356280
f0105d12:	66 c7 05 82 62 35 f0 	movw   $0x8,0xf0356282
f0105d19:	08 00 
f0105d1b:	c6 05 84 62 35 f0 00 	movb   $0x0,0xf0356284
f0105d22:	c6 05 85 62 35 f0 8f 	movb   $0x8f,0xf0356285
f0105d29:	c1 e8 10             	shr    $0x10,%eax
f0105d2c:	66 a3 86 62 35 f0    	mov    %ax,0xf0356286
    SETGATE(idt[T_BOUND],0,GD_KT,Handler_BOUND,0);
f0105d32:	b8 1e 66 10 f0       	mov    $0xf010661e,%eax
f0105d37:	66 a3 88 62 35 f0    	mov    %ax,0xf0356288
f0105d3d:	66 c7 05 8a 62 35 f0 	movw   $0x8,0xf035628a
f0105d44:	08 00 
f0105d46:	c6 05 8c 62 35 f0 00 	movb   $0x0,0xf035628c
f0105d4d:	c6 05 8d 62 35 f0 8e 	movb   $0x8e,0xf035628d
f0105d54:	c1 e8 10             	shr    $0x10,%eax
f0105d57:	66 a3 8e 62 35 f0    	mov    %ax,0xf035628e
    SETGATE(idt[T_ILLOP],0,GD_KT,Handler_ILLOP,0);
f0105d5d:	b8 28 66 10 f0       	mov    $0xf0106628,%eax
f0105d62:	66 a3 90 62 35 f0    	mov    %ax,0xf0356290
f0105d68:	66 c7 05 92 62 35 f0 	movw   $0x8,0xf0356292
f0105d6f:	08 00 
f0105d71:	c6 05 94 62 35 f0 00 	movb   $0x0,0xf0356294
f0105d78:	c6 05 95 62 35 f0 8e 	movb   $0x8e,0xf0356295
f0105d7f:	c1 e8 10             	shr    $0x10,%eax
f0105d82:	66 a3 96 62 35 f0    	mov    %ax,0xf0356296
    SETGATE(idt[T_DEVICE],0,GD_KT,Handler_DEVICE,0);
f0105d88:	b8 32 66 10 f0       	mov    $0xf0106632,%eax
f0105d8d:	66 a3 98 62 35 f0    	mov    %ax,0xf0356298
f0105d93:	66 c7 05 9a 62 35 f0 	movw   $0x8,0xf035629a
f0105d9a:	08 00 
f0105d9c:	c6 05 9c 62 35 f0 00 	movb   $0x0,0xf035629c
f0105da3:	c6 05 9d 62 35 f0 8e 	movb   $0x8e,0xf035629d
f0105daa:	c1 e8 10             	shr    $0x10,%eax
f0105dad:	66 a3 9e 62 35 f0    	mov    %ax,0xf035629e
    SETGATE(idt[T_DBLFLT],0,GD_KT,Handler_DBLFLT,0);
f0105db3:	b8 3c 66 10 f0       	mov    $0xf010663c,%eax
f0105db8:	66 a3 a0 62 35 f0    	mov    %ax,0xf03562a0
f0105dbe:	66 c7 05 a2 62 35 f0 	movw   $0x8,0xf03562a2
f0105dc5:	08 00 
f0105dc7:	c6 05 a4 62 35 f0 00 	movb   $0x0,0xf03562a4
f0105dce:	c6 05 a5 62 35 f0 8e 	movb   $0x8e,0xf03562a5
f0105dd5:	c1 e8 10             	shr    $0x10,%eax
f0105dd8:	66 a3 a6 62 35 f0    	mov    %ax,0xf03562a6
    SETGATE(idt[T_TSS],0,GD_KT,Handler_TSS,0);
f0105dde:	b8 44 66 10 f0       	mov    $0xf0106644,%eax
f0105de3:	66 a3 b0 62 35 f0    	mov    %ax,0xf03562b0
f0105de9:	66 c7 05 b2 62 35 f0 	movw   $0x8,0xf03562b2
f0105df0:	08 00 
f0105df2:	c6 05 b4 62 35 f0 00 	movb   $0x0,0xf03562b4
f0105df9:	c6 05 b5 62 35 f0 8e 	movb   $0x8e,0xf03562b5
f0105e00:	c1 e8 10             	shr    $0x10,%eax
f0105e03:	66 a3 b6 62 35 f0    	mov    %ax,0xf03562b6
    SETGATE(idt[T_SEGNP],0,GD_KT,Handler_SEGNP,0);
f0105e09:	b8 4c 66 10 f0       	mov    $0xf010664c,%eax
f0105e0e:	66 a3 b8 62 35 f0    	mov    %ax,0xf03562b8
f0105e14:	66 c7 05 ba 62 35 f0 	movw   $0x8,0xf03562ba
f0105e1b:	08 00 
f0105e1d:	c6 05 bc 62 35 f0 00 	movb   $0x0,0xf03562bc
f0105e24:	c6 05 bd 62 35 f0 8e 	movb   $0x8e,0xf03562bd
f0105e2b:	c1 e8 10             	shr    $0x10,%eax
f0105e2e:	66 a3 be 62 35 f0    	mov    %ax,0xf03562be
    SETGATE(idt[T_STACK],0,GD_KT,Handler_STACK,0);
f0105e34:	b8 54 66 10 f0       	mov    $0xf0106654,%eax
f0105e39:	66 a3 c0 62 35 f0    	mov    %ax,0xf03562c0
f0105e3f:	66 c7 05 c2 62 35 f0 	movw   $0x8,0xf03562c2
f0105e46:	08 00 
f0105e48:	c6 05 c4 62 35 f0 00 	movb   $0x0,0xf03562c4
f0105e4f:	c6 05 c5 62 35 f0 8e 	movb   $0x8e,0xf03562c5
f0105e56:	c1 e8 10             	shr    $0x10,%eax
f0105e59:	66 a3 c6 62 35 f0    	mov    %ax,0xf03562c6
    SETGATE(idt[T_GPFLT],0,GD_KT,Handler_GPFLT,0);
f0105e5f:	b8 5c 66 10 f0       	mov    $0xf010665c,%eax
f0105e64:	66 a3 c8 62 35 f0    	mov    %ax,0xf03562c8
f0105e6a:	66 c7 05 ca 62 35 f0 	movw   $0x8,0xf03562ca
f0105e71:	08 00 
f0105e73:	c6 05 cc 62 35 f0 00 	movb   $0x0,0xf03562cc
f0105e7a:	c6 05 cd 62 35 f0 8e 	movb   $0x8e,0xf03562cd
f0105e81:	c1 e8 10             	shr    $0x10,%eax
f0105e84:	66 a3 ce 62 35 f0    	mov    %ax,0xf03562ce
    SETGATE(idt[T_PGFLT],0,GD_KT,Handler_PGFLT,0);
f0105e8a:	b8 64 66 10 f0       	mov    $0xf0106664,%eax
f0105e8f:	66 a3 d0 62 35 f0    	mov    %ax,0xf03562d0
f0105e95:	66 c7 05 d2 62 35 f0 	movw   $0x8,0xf03562d2
f0105e9c:	08 00 
f0105e9e:	c6 05 d4 62 35 f0 00 	movb   $0x0,0xf03562d4
f0105ea5:	c6 05 d5 62 35 f0 8e 	movb   $0x8e,0xf03562d5
f0105eac:	c1 e8 10             	shr    $0x10,%eax
f0105eaf:	66 a3 d6 62 35 f0    	mov    %ax,0xf03562d6
    SETGATE(idt[T_FPERR],0,GD_KT,Handler_FPERR,0);
f0105eb5:	b8 68 66 10 f0       	mov    $0xf0106668,%eax
f0105eba:	66 a3 e0 62 35 f0    	mov    %ax,0xf03562e0
f0105ec0:	66 c7 05 e2 62 35 f0 	movw   $0x8,0xf03562e2
f0105ec7:	08 00 
f0105ec9:	c6 05 e4 62 35 f0 00 	movb   $0x0,0xf03562e4
f0105ed0:	c6 05 e5 62 35 f0 8e 	movb   $0x8e,0xf03562e5
f0105ed7:	c1 e8 10             	shr    $0x10,%eax
f0105eda:	66 a3 e6 62 35 f0    	mov    %ax,0xf03562e6
    SETGATE(idt[T_ALIGN],0,GD_KT,Handler_ALIGN,0);
f0105ee0:	b8 6e 66 10 f0       	mov    $0xf010666e,%eax
f0105ee5:	66 a3 e8 62 35 f0    	mov    %ax,0xf03562e8
f0105eeb:	66 c7 05 ea 62 35 f0 	movw   $0x8,0xf03562ea
f0105ef2:	08 00 
f0105ef4:	c6 05 ec 62 35 f0 00 	movb   $0x0,0xf03562ec
f0105efb:	c6 05 ed 62 35 f0 8e 	movb   $0x8e,0xf03562ed
f0105f02:	c1 e8 10             	shr    $0x10,%eax
f0105f05:	66 a3 ee 62 35 f0    	mov    %ax,0xf03562ee
    SETGATE(idt[T_MCHK],0,GD_KT,Handler_MCHK,0);
f0105f0b:	b8 72 66 10 f0       	mov    $0xf0106672,%eax
f0105f10:	66 a3 f0 62 35 f0    	mov    %ax,0xf03562f0
f0105f16:	66 c7 05 f2 62 35 f0 	movw   $0x8,0xf03562f2
f0105f1d:	08 00 
f0105f1f:	c6 05 f4 62 35 f0 00 	movb   $0x0,0xf03562f4
f0105f26:	c6 05 f5 62 35 f0 8e 	movb   $0x8e,0xf03562f5
f0105f2d:	c1 e8 10             	shr    $0x10,%eax
f0105f30:	66 a3 f6 62 35 f0    	mov    %ax,0xf03562f6
    SETGATE(idt[T_SIMDERR],0,GD_KT,Handler_SIMDERR,0);
f0105f36:	b8 78 66 10 f0       	mov    $0xf0106678,%eax
f0105f3b:	66 a3 f8 62 35 f0    	mov    %ax,0xf03562f8
f0105f41:	66 c7 05 fa 62 35 f0 	movw   $0x8,0xf03562fa
f0105f48:	08 00 
f0105f4a:	c6 05 fc 62 35 f0 00 	movb   $0x0,0xf03562fc
f0105f51:	c6 05 fd 62 35 f0 8e 	movb   $0x8e,0xf03562fd
f0105f58:	c1 e8 10             	shr    $0x10,%eax
f0105f5b:	66 a3 fe 62 35 f0    	mov    %ax,0xf03562fe
    SETGATE(idt[T_SYSCALL],0,GD_KT,Handler_SYSCALL,3);
f0105f61:	b8 7e 66 10 f0       	mov    $0xf010667e,%eax
f0105f66:	66 a3 e0 63 35 f0    	mov    %ax,0xf03563e0
f0105f6c:	66 c7 05 e2 63 35 f0 	movw   $0x8,0xf03563e2
f0105f73:	08 00 
f0105f75:	c6 05 e4 63 35 f0 00 	movb   $0x0,0xf03563e4
f0105f7c:	c6 05 e5 63 35 f0 ee 	movb   $0xee,0xf03563e5
f0105f83:	c1 e8 10             	shr    $0x10,%eax
f0105f86:	66 a3 e6 63 35 f0    	mov    %ax,0xf03563e6
	// Per-CPU setup 
	trap_init_percpu();
f0105f8c:	e8 77 f8 ff ff       	call   f0105808 <trap_init_percpu>
}
f0105f91:	c9                   	leave  
f0105f92:	c3                   	ret    

f0105f93 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0105f93:	55                   	push   %ebp
f0105f94:	89 e5                	mov    %esp,%ebp
f0105f96:	53                   	push   %ebx
f0105f97:	83 ec 14             	sub    $0x14,%esp
f0105f9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0105f9d:	8b 03                	mov    (%ebx),%eax
f0105f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fa3:	c7 04 24 0b ab 10 f0 	movl   $0xf010ab0b,(%esp)
f0105faa:	e8 3f f8 ff ff       	call   f01057ee <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0105faf:	8b 43 04             	mov    0x4(%ebx),%eax
f0105fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fb6:	c7 04 24 1a ab 10 f0 	movl   $0xf010ab1a,(%esp)
f0105fbd:	e8 2c f8 ff ff       	call   f01057ee <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0105fc2:	8b 43 08             	mov    0x8(%ebx),%eax
f0105fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fc9:	c7 04 24 29 ab 10 f0 	movl   $0xf010ab29,(%esp)
f0105fd0:	e8 19 f8 ff ff       	call   f01057ee <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0105fd5:	8b 43 0c             	mov    0xc(%ebx),%eax
f0105fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fdc:	c7 04 24 38 ab 10 f0 	movl   $0xf010ab38,(%esp)
f0105fe3:	e8 06 f8 ff ff       	call   f01057ee <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0105fe8:	8b 43 10             	mov    0x10(%ebx),%eax
f0105feb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fef:	c7 04 24 47 ab 10 f0 	movl   $0xf010ab47,(%esp)
f0105ff6:	e8 f3 f7 ff ff       	call   f01057ee <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0105ffb:	8b 43 14             	mov    0x14(%ebx),%eax
f0105ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106002:	c7 04 24 56 ab 10 f0 	movl   $0xf010ab56,(%esp)
f0106009:	e8 e0 f7 ff ff       	call   f01057ee <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010600e:	8b 43 18             	mov    0x18(%ebx),%eax
f0106011:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106015:	c7 04 24 65 ab 10 f0 	movl   $0xf010ab65,(%esp)
f010601c:	e8 cd f7 ff ff       	call   f01057ee <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0106021:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0106024:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106028:	c7 04 24 74 ab 10 f0 	movl   $0xf010ab74,(%esp)
f010602f:	e8 ba f7 ff ff       	call   f01057ee <cprintf>
}
f0106034:	83 c4 14             	add    $0x14,%esp
f0106037:	5b                   	pop    %ebx
f0106038:	5d                   	pop    %ebp
f0106039:	c3                   	ret    

f010603a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010603a:	55                   	push   %ebp
f010603b:	89 e5                	mov    %esp,%ebp
f010603d:	53                   	push   %ebx
f010603e:	83 ec 14             	sub    $0x14,%esp
f0106041:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0106044:	e8 27 21 00 00       	call   f0108170 <cpunum>
f0106049:	89 44 24 08          	mov    %eax,0x8(%esp)
f010604d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106051:	c7 04 24 d8 ab 10 f0 	movl   $0xf010abd8,(%esp)
f0106058:	e8 91 f7 ff ff       	call   f01057ee <cprintf>
	print_regs(&tf->tf_regs);
f010605d:	89 1c 24             	mov    %ebx,(%esp)
f0106060:	e8 2e ff ff ff       	call   f0105f93 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0106065:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0106069:	89 44 24 04          	mov    %eax,0x4(%esp)
f010606d:	c7 04 24 f6 ab 10 f0 	movl   $0xf010abf6,(%esp)
f0106074:	e8 75 f7 ff ff       	call   f01057ee <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0106079:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010607d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106081:	c7 04 24 09 ac 10 f0 	movl   $0xf010ac09,(%esp)
f0106088:	e8 61 f7 ff ff       	call   f01057ee <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010608d:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0106090:	83 f8 13             	cmp    $0x13,%eax
f0106093:	77 09                	ja     f010609e <print_trapframe+0x64>
		return excnames[trapno];
f0106095:	8b 14 85 c0 ae 10 f0 	mov    -0xfef5140(,%eax,4),%edx
f010609c:	eb 20                	jmp    f01060be <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f010609e:	83 f8 30             	cmp    $0x30,%eax
f01060a1:	74 0f                	je     f01060b2 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01060a3:	8d 50 e0             	lea    -0x20(%eax),%edx
f01060a6:	83 fa 0f             	cmp    $0xf,%edx
f01060a9:	77 0e                	ja     f01060b9 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01060ab:	ba 8f ab 10 f0       	mov    $0xf010ab8f,%edx
f01060b0:	eb 0c                	jmp    f01060be <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01060b2:	ba 83 ab 10 f0       	mov    $0xf010ab83,%edx
f01060b7:	eb 05                	jmp    f01060be <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01060b9:	ba a2 ab 10 f0       	mov    $0xf010aba2,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01060be:	89 54 24 08          	mov    %edx,0x8(%esp)
f01060c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060c6:	c7 04 24 1c ac 10 f0 	movl   $0xf010ac1c,(%esp)
f01060cd:	e8 1c f7 ff ff       	call   f01057ee <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01060d2:	3b 1d 60 6a 35 f0    	cmp    0xf0356a60,%ebx
f01060d8:	75 19                	jne    f01060f3 <print_trapframe+0xb9>
f01060da:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01060de:	75 13                	jne    f01060f3 <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01060e0:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01060e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060e7:	c7 04 24 2e ac 10 f0 	movl   $0xf010ac2e,(%esp)
f01060ee:	e8 fb f6 ff ff       	call   f01057ee <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01060f3:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01060f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060fa:	c7 04 24 3d ac 10 f0 	movl   $0xf010ac3d,(%esp)
f0106101:	e8 e8 f6 ff ff       	call   f01057ee <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0106106:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010610a:	75 4d                	jne    f0106159 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010610c:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010610f:	a8 01                	test   $0x1,%al
f0106111:	74 07                	je     f010611a <print_trapframe+0xe0>
f0106113:	b9 b1 ab 10 f0       	mov    $0xf010abb1,%ecx
f0106118:	eb 05                	jmp    f010611f <print_trapframe+0xe5>
f010611a:	b9 bc ab 10 f0       	mov    $0xf010abbc,%ecx
f010611f:	a8 02                	test   $0x2,%al
f0106121:	74 07                	je     f010612a <print_trapframe+0xf0>
f0106123:	ba c8 ab 10 f0       	mov    $0xf010abc8,%edx
f0106128:	eb 05                	jmp    f010612f <print_trapframe+0xf5>
f010612a:	ba ce ab 10 f0       	mov    $0xf010abce,%edx
f010612f:	a8 04                	test   $0x4,%al
f0106131:	74 07                	je     f010613a <print_trapframe+0x100>
f0106133:	b8 d3 ab 10 f0       	mov    $0xf010abd3,%eax
f0106138:	eb 05                	jmp    f010613f <print_trapframe+0x105>
f010613a:	b8 08 ad 10 f0       	mov    $0xf010ad08,%eax
f010613f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106143:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106147:	89 44 24 04          	mov    %eax,0x4(%esp)
f010614b:	c7 04 24 4b ac 10 f0 	movl   $0xf010ac4b,(%esp)
f0106152:	e8 97 f6 ff ff       	call   f01057ee <cprintf>
f0106157:	eb 0c                	jmp    f0106165 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0106159:	c7 04 24 c8 a9 10 f0 	movl   $0xf010a9c8,(%esp)
f0106160:	e8 89 f6 ff ff       	call   f01057ee <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0106165:	8b 43 30             	mov    0x30(%ebx),%eax
f0106168:	89 44 24 04          	mov    %eax,0x4(%esp)
f010616c:	c7 04 24 5a ac 10 f0 	movl   $0xf010ac5a,(%esp)
f0106173:	e8 76 f6 ff ff       	call   f01057ee <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0106178:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010617c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106180:	c7 04 24 69 ac 10 f0 	movl   $0xf010ac69,(%esp)
f0106187:	e8 62 f6 ff ff       	call   f01057ee <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010618c:	8b 43 38             	mov    0x38(%ebx),%eax
f010618f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106193:	c7 04 24 7c ac 10 f0 	movl   $0xf010ac7c,(%esp)
f010619a:	e8 4f f6 ff ff       	call   f01057ee <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010619f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01061a3:	74 27                	je     f01061cc <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01061a5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061ac:	c7 04 24 8b ac 10 f0 	movl   $0xf010ac8b,(%esp)
f01061b3:	e8 36 f6 ff ff       	call   f01057ee <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01061b8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01061bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061c0:	c7 04 24 9a ac 10 f0 	movl   $0xf010ac9a,(%esp)
f01061c7:	e8 22 f6 ff ff       	call   f01057ee <cprintf>
	}
}
f01061cc:	83 c4 14             	add    $0x14,%esp
f01061cf:	5b                   	pop    %ebx
f01061d0:	5d                   	pop    %ebp
f01061d1:	c3                   	ret    

f01061d2 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01061d2:	55                   	push   %ebp
f01061d3:	89 e5                	mov    %esp,%ebp
f01061d5:	57                   	push   %edi
f01061d6:	56                   	push   %esi
f01061d7:	53                   	push   %ebx
f01061d8:	83 ec 2c             	sub    $0x2c,%esp
f01061db:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01061de:	0f 20 d0             	mov    %cr2,%eax
f01061e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// cprintf("tf_cs:  %x\n",tf->tf_cs);
	if ( (tf->tf_cs&1)!=1 )
f01061e4:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f01061e8:	75 1c                	jne    f0106206 <page_fault_handler+0x34>
		panic("page_fault_handler: kernel page fault!\n");
f01061ea:	c7 44 24 08 54 ae 10 	movl   $0xf010ae54,0x8(%esp)
f01061f1:	f0 
f01061f2:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01061f9:	00 
f01061fa:	c7 04 24 ad ac 10 f0 	movl   $0xf010acad,(%esp)
f0106201:	e8 3a 9e ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall!=NULL){
f0106206:	e8 65 1f 00 00       	call   f0108170 <cpunum>
f010620b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106212:	29 c2                	sub    %eax,%edx
f0106214:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106217:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f010621e:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0106222:	0f 84 d4 00 00 00    	je     f01062fc <page_fault_handler+0x12a>
		// cprintf("%x\n",tf->tf_esp);
		struct UTrapframe *utf = (tf->tf_esp >= UXSTACKTOP || tf->tf_esp < UXSTACKTOP - PGSIZE) ? 
f0106228:	8b 43 3c             	mov    0x3c(%ebx),%eax
		(struct UTrapframe *)(UXSTACKTOP -  sizeof(struct UTrapframe)): (struct UTrapframe *)(tf->tf_esp - 4 - sizeof(struct UTrapframe));
f010622b:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0106231:	c7 45 e0 cc ff bf ee 	movl   $0xeebfffcc,-0x20(%ebp)
f0106238:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010623e:	77 06                	ja     f0106246 <page_fault_handler+0x74>
f0106240:	83 e8 38             	sub    $0x38,%eax
f0106243:	89 45 e0             	mov    %eax,-0x20(%ebp)
		// cprintf("find %x\n",utf);
		user_mem_assert(curenv,(const void*)utf,sizeof(struct UTrapframe),PTE_U|PTE_W|PTE_P);
f0106246:	e8 25 1f 00 00       	call   f0108170 <cpunum>
f010624b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0106252:	00 
f0106253:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f010625a:	00 
f010625b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010625e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106262:	6b c0 74             	imul   $0x74,%eax,%eax
f0106265:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f010626b:	89 04 24             	mov    %eax,(%esp)
f010626e:	e8 6f ea ff ff       	call   f0104ce2 <user_mem_assert>
		// cprintf("find2\n");
		utf->utf_esp = tf->tf_esp;
f0106273:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0106276:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106279:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010627c:	8b 43 38             	mov    0x38(%ebx),%eax
f010627f:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_eip = tf->tf_eip;
f0106282:	8b 43 30             	mov    0x30(%ebx),%eax
f0106285:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_regs = tf->tf_regs;
f0106288:	89 d7                	mov    %edx,%edi
f010628a:	83 c7 08             	add    $0x8,%edi
f010628d:	89 de                	mov    %ebx,%esi
f010628f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106294:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010629a:	74 03                	je     f010629f <page_fault_handler+0xcd>
f010629c:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f010629d:	b0 1f                	mov    $0x1f,%al
f010629f:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01062a5:	74 05                	je     f01062ac <page_fault_handler+0xda>
f01062a7:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01062a9:	83 e8 02             	sub    $0x2,%eax
f01062ac:	89 c1                	mov    %eax,%ecx
f01062ae:	c1 e9 02             	shr    $0x2,%ecx
f01062b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01062b3:	a8 02                	test   $0x2,%al
f01062b5:	74 02                	je     f01062b9 <page_fault_handler+0xe7>
f01062b7:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01062b9:	a8 01                	test   $0x1,%al
f01062bb:	74 01                	je     f01062be <page_fault_handler+0xec>
f01062bd:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_err = tf->tf_trapno;
f01062be:	8b 43 28             	mov    0x28(%ebx),%eax
f01062c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01062c4:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_fault_va = fault_va;
f01062c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062ca:	89 02                	mov    %eax,(%edx)
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01062cc:	e8 9f 1e 00 00       	call   f0108170 <cpunum>
f01062d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01062d4:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f01062da:	8b 40 64             	mov    0x64(%eax),%eax
f01062dd:	89 43 30             	mov    %eax,0x30(%ebx)
		// cprintf("eip %x\n",tf->tf_eip);
		tf->tf_esp = (uintptr_t) utf;
f01062e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01062e3:	89 53 3c             	mov    %edx,0x3c(%ebx)
		env_run(curenv);
f01062e6:	e8 85 1e 00 00       	call   f0108170 <cpunum>
f01062eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01062ee:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f01062f4:	89 04 24             	mov    %eax,(%esp)
f01062f7:	e8 8a f2 ff ff       	call   f0105586 <env_run>
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01062fc:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f01062ff:	e8 6c 1e 00 00       	call   f0108170 <cpunum>
		// cprintf("eip %x\n",tf->tf_eip);
		tf->tf_esp = (uintptr_t) utf;
		env_run(curenv);
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0106304:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106308:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010630b:	89 54 24 08          	mov    %edx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f010630f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106316:	29 c2                	sub    %eax,%edx
f0106318:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010631b:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
		// cprintf("eip %x\n",tf->tf_eip);
		tf->tf_esp = (uintptr_t) utf;
		env_run(curenv);
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0106322:	8b 40 48             	mov    0x48(%eax),%eax
f0106325:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106329:	c7 04 24 7c ae 10 f0 	movl   $0xf010ae7c,(%esp)
f0106330:	e8 b9 f4 ff ff       	call   f01057ee <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0106335:	89 1c 24             	mov    %ebx,(%esp)
f0106338:	e8 fd fc ff ff       	call   f010603a <print_trapframe>
	env_destroy(curenv);
f010633d:	e8 2e 1e 00 00       	call   f0108170 <cpunum>
f0106342:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106349:	29 c2                	sub    %eax,%edx
f010634b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010634e:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0106355:	89 04 24             	mov    %eax,(%esp)
f0106358:	e8 6a f1 ff ff       	call   f01054c7 <env_destroy>
}
f010635d:	83 c4 2c             	add    $0x2c,%esp
f0106360:	5b                   	pop    %ebx
f0106361:	5e                   	pop    %esi
f0106362:	5f                   	pop    %edi
f0106363:	5d                   	pop    %ebp
f0106364:	c3                   	ret    

f0106365 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0106365:	55                   	push   %ebp
f0106366:	89 e5                	mov    %esp,%ebp
f0106368:	57                   	push   %edi
f0106369:	56                   	push   %esi
f010636a:	83 ec 20             	sub    $0x20,%esp
f010636d:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0106370:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0106371:	83 3d 80 6e 35 f0 00 	cmpl   $0x0,0xf0356e80
f0106378:	74 01                	je     f010637b <trap+0x16>
		asm volatile("hlt");
f010637a:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010637b:	e8 f0 1d 00 00       	call   f0108170 <cpunum>
f0106380:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106387:	29 c2                	sub    %eax,%edx
f0106389:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010638c:	8d 14 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106393:	b8 01 00 00 00       	mov    $0x1,%eax
f0106398:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010639c:	83 f8 02             	cmp    $0x2,%eax
f010639f:	75 0c                	jne    f01063ad <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01063a1:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f01063a8:	e8 82 20 00 00       	call   f010842f <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01063ad:	9c                   	pushf  
f01063ae:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01063af:	f6 c4 02             	test   $0x2,%ah
f01063b2:	74 24                	je     f01063d8 <trap+0x73>
f01063b4:	c7 44 24 0c b9 ac 10 	movl   $0xf010acb9,0xc(%esp)
f01063bb:	f0 
f01063bc:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f01063c3:	f0 
f01063c4:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f01063cb:	00 
f01063cc:	c7 04 24 ad ac 10 f0 	movl   $0xf010acad,(%esp)
f01063d3:	e8 68 9c ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01063d8:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01063dc:	83 e0 03             	and    $0x3,%eax
f01063df:	83 f8 03             	cmp    $0x3,%eax
f01063e2:	0f 85 a7 00 00 00    	jne    f010648f <trap+0x12a>
f01063e8:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f01063ef:	e8 3b 20 00 00       	call   f010842f <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f01063f4:	e8 77 1d 00 00       	call   f0108170 <cpunum>
f01063f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01063fc:	83 b8 28 70 35 f0 00 	cmpl   $0x0,-0xfca8fd8(%eax)
f0106403:	75 24                	jne    f0106429 <trap+0xc4>
f0106405:	c7 44 24 0c d2 ac 10 	movl   $0xf010acd2,0xc(%esp)
f010640c:	f0 
f010640d:	c7 44 24 08 a9 a6 10 	movl   $0xf010a6a9,0x8(%esp)
f0106414:	f0 
f0106415:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
f010641c:	00 
f010641d:	c7 04 24 ad ac 10 f0 	movl   $0xf010acad,(%esp)
f0106424:	e8 17 9c ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0106429:	e8 42 1d 00 00       	call   f0108170 <cpunum>
f010642e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106431:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f0106437:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010643b:	75 2d                	jne    f010646a <trap+0x105>
			env_free(curenv);
f010643d:	e8 2e 1d 00 00       	call   f0108170 <cpunum>
f0106442:	6b c0 74             	imul   $0x74,%eax,%eax
f0106445:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f010644b:	89 04 24             	mov    %eax,(%esp)
f010644e:	e8 50 ee ff ff       	call   f01052a3 <env_free>
			curenv = NULL;
f0106453:	e8 18 1d 00 00       	call   f0108170 <cpunum>
f0106458:	6b c0 74             	imul   $0x74,%eax,%eax
f010645b:	c7 80 28 70 35 f0 00 	movl   $0x0,-0xfca8fd8(%eax)
f0106462:	00 00 00 
			sched_yield();
f0106465:	e8 88 03 00 00       	call   f01067f2 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010646a:	e8 01 1d 00 00       	call   f0108170 <cpunum>
f010646f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106472:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f0106478:	b9 11 00 00 00       	mov    $0x11,%ecx
f010647d:	89 c7                	mov    %eax,%edi
f010647f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0106481:	e8 ea 1c 00 00       	call   f0108170 <cpunum>
f0106486:	6b c0 74             	imul   $0x74,%eax,%eax
f0106489:	8b b0 28 70 35 f0    	mov    -0xfca8fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010648f:	89 35 60 6a 35 f0    	mov    %esi,0xf0356a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// cprintf("trap_dispatch %x\n",tf->tf_trapno);
	switch (tf->tf_trapno){
f0106495:	8b 46 28             	mov    0x28(%esi),%eax
f0106498:	83 f8 03             	cmp    $0x3,%eax
f010649b:	74 2a                	je     f01064c7 <trap+0x162>
f010649d:	83 f8 03             	cmp    $0x3,%eax
f01064a0:	77 0b                	ja     f01064ad <trap+0x148>
f01064a2:	83 f8 01             	cmp    $0x1,%eax
f01064a5:	0f 85 91 00 00 00    	jne    f010653c <trap+0x1d7>
f01064ab:	eb 27                	jmp    f01064d4 <trap+0x16f>
f01064ad:	83 f8 0e             	cmp    $0xe,%eax
f01064b0:	74 0b                	je     f01064bd <trap+0x158>
f01064b2:	83 f8 30             	cmp    $0x30,%eax
f01064b5:	0f 85 81 00 00 00    	jne    f010653c <trap+0x1d7>
f01064bb:	eb 24                	jmp    f01064e1 <trap+0x17c>
		case T_PGFLT: page_fault_handler(tf);break;
f01064bd:	89 34 24             	mov    %esi,(%esp)
f01064c0:	e8 0d fd ff ff       	call   f01061d2 <page_fault_handler>
f01064c5:	eb 75                	jmp    f010653c <trap+0x1d7>
		case T_BRKPT: monitor(tf);return;
f01064c7:	89 34 24             	mov    %esi,(%esp)
f01064ca:	e8 ac b7 ff ff       	call   f0101c7b <monitor>
f01064cf:	e9 d6 00 00 00       	jmp    f01065aa <trap+0x245>
		case T_DEBUG: monitor(tf);return;
f01064d4:	89 34 24             	mov    %esi,(%esp)
f01064d7:	e8 9f b7 ff ff       	call   f0101c7b <monitor>
f01064dc:	e9 c9 00 00 00       	jmp    f01065aa <trap+0x245>
		case T_SYSCALL: {
			int32_t ret = syscall(tf->tf_regs.reg_eax,
f01064e1:	8b 46 04             	mov    0x4(%esi),%eax
f01064e4:	89 44 24 14          	mov    %eax,0x14(%esp)
f01064e8:	8b 06                	mov    (%esi),%eax
f01064ea:	89 44 24 10          	mov    %eax,0x10(%esp)
f01064ee:	8b 46 10             	mov    0x10(%esi),%eax
f01064f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01064f5:	8b 46 18             	mov    0x18(%esi),%eax
f01064f8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01064fc:	8b 46 14             	mov    0x14(%esi),%eax
f01064ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106503:	8b 46 1c             	mov    0x1c(%esi),%eax
f0106506:	89 04 24             	mov    %eax,(%esp)
f0106509:	e8 c0 03 00 00       	call   f01068ce <syscall>
							   	  tf->tf_regs.reg_edx,
								  tf->tf_regs.reg_ecx,
								  tf->tf_regs.reg_ebx,
								  tf->tf_regs.reg_edi,
								  tf->tf_regs.reg_esi);
			if (ret < 0 && ret != -7)
f010650e:	85 c0                	test   %eax,%eax
f0106510:	79 25                	jns    f0106537 <trap+0x1d2>
f0106512:	83 f8 f9             	cmp    $0xfffffff9,%eax
f0106515:	74 20                	je     f0106537 <trap+0x1d2>
				panic("trap_dispatch: system call %d\n",ret);
f0106517:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010651b:	c7 44 24 08 a0 ae 10 	movl   $0xf010aea0,0x8(%esp)
f0106522:	f0 
f0106523:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
f010652a:	00 
f010652b:	c7 04 24 ad ac 10 f0 	movl   $0xf010acad,(%esp)
f0106532:	e8 09 9b ff ff       	call   f0100040 <_panic>
			tf->tf_regs.reg_eax = ret;
f0106537:	89 46 1c             	mov    %eax,0x1c(%esi)
f010653a:	eb 6e                	jmp    f01065aa <trap+0x245>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010653c:	8b 46 28             	mov    0x28(%esi),%eax
f010653f:	83 f8 27             	cmp    $0x27,%eax
f0106542:	75 16                	jne    f010655a <trap+0x1f5>
		cprintf("Spurious interrupt on irq 7\n");
f0106544:	c7 04 24 d9 ac 10 f0 	movl   $0xf010acd9,(%esp)
f010654b:	e8 9e f2 ff ff       	call   f01057ee <cprintf>
		print_trapframe(tf);
f0106550:	89 34 24             	mov    %esi,(%esp)
f0106553:	e8 e2 fa ff ff       	call   f010603a <print_trapframe>
f0106558:	eb 50                	jmp    f01065aa <trap+0x245>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	switch (tf->tf_trapno){
f010655a:	83 f8 20             	cmp    $0x20,%eax
f010655d:	75 0a                	jne    f0106569 <trap+0x204>
		case IRQ_OFFSET + IRQ_TIMER: {
			lapic_eoi();
f010655f:	e8 63 1d 00 00       	call   f01082c7 <lapic_eoi>
        	sched_yield();
f0106564:	e8 89 02 00 00       	call   f01067f2 <sched_yield>
        	return;
		}
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0106569:	89 34 24             	mov    %esi,(%esp)
f010656c:	e8 c9 fa ff ff       	call   f010603a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0106571:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0106576:	75 1c                	jne    f0106594 <trap+0x22f>
		panic("unhandled trap in kernel");
f0106578:	c7 44 24 08 f6 ac 10 	movl   $0xf010acf6,0x8(%esp)
f010657f:	f0 
f0106580:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0106587:	00 
f0106588:	c7 04 24 ad ac 10 f0 	movl   $0xf010acad,(%esp)
f010658f:	e8 ac 9a ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0106594:	e8 d7 1b 00 00       	call   f0108170 <cpunum>
f0106599:	6b c0 74             	imul   $0x74,%eax,%eax
f010659c:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f01065a2:	89 04 24             	mov    %eax,(%esp)
f01065a5:	e8 1d ef ff ff       	call   f01054c7 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01065aa:	e8 c1 1b 00 00       	call   f0108170 <cpunum>
f01065af:	6b c0 74             	imul   $0x74,%eax,%eax
f01065b2:	83 b8 28 70 35 f0 00 	cmpl   $0x0,-0xfca8fd8(%eax)
f01065b9:	74 2a                	je     f01065e5 <trap+0x280>
f01065bb:	e8 b0 1b 00 00       	call   f0108170 <cpunum>
f01065c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01065c3:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f01065c9:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01065cd:	75 16                	jne    f01065e5 <trap+0x280>
		env_run(curenv);
f01065cf:	e8 9c 1b 00 00       	call   f0108170 <cpunum>
f01065d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01065d7:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f01065dd:	89 04 24             	mov    %eax,(%esp)
f01065e0:	e8 a1 ef ff ff       	call   f0105586 <env_run>
	else
		sched_yield();
f01065e5:	e8 08 02 00 00       	call   f01067f2 <sched_yield>
	...

f01065ec <Handler_DIVIDE>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(Handler_DIVIDE, T_DIVIDE)
f01065ec:	6a 00                	push   $0x0
f01065ee:	6a 00                	push   $0x0
f01065f0:	e9 ef 00 00 00       	jmp    f01066e4 <_alltraps>
f01065f5:	90                   	nop

f01065f6 <Handler_DEBUG>:
TRAPHANDLER_NOEC(Handler_DEBUG, T_DEBUG)
f01065f6:	6a 00                	push   $0x0
f01065f8:	6a 01                	push   $0x1
f01065fa:	e9 e5 00 00 00       	jmp    f01066e4 <_alltraps>
f01065ff:	90                   	nop

f0106600 <Handler_NMI>:
TRAPHANDLER_NOEC(Handler_NMI, T_NMI)
f0106600:	6a 00                	push   $0x0
f0106602:	6a 02                	push   $0x2
f0106604:	e9 db 00 00 00       	jmp    f01066e4 <_alltraps>
f0106609:	90                   	nop

f010660a <Handler_BRKPT>:
TRAPHANDLER_NOEC(Handler_BRKPT, T_BRKPT)
f010660a:	6a 00                	push   $0x0
f010660c:	6a 03                	push   $0x3
f010660e:	e9 d1 00 00 00       	jmp    f01066e4 <_alltraps>
f0106613:	90                   	nop

f0106614 <Handler_OFLOW>:
TRAPHANDLER_NOEC(Handler_OFLOW, T_OFLOW)
f0106614:	6a 00                	push   $0x0
f0106616:	6a 04                	push   $0x4
f0106618:	e9 c7 00 00 00       	jmp    f01066e4 <_alltraps>
f010661d:	90                   	nop

f010661e <Handler_BOUND>:
TRAPHANDLER_NOEC(Handler_BOUND, T_BOUND)
f010661e:	6a 00                	push   $0x0
f0106620:	6a 05                	push   $0x5
f0106622:	e9 bd 00 00 00       	jmp    f01066e4 <_alltraps>
f0106627:	90                   	nop

f0106628 <Handler_ILLOP>:
TRAPHANDLER_NOEC(Handler_ILLOP, T_ILLOP)
f0106628:	6a 00                	push   $0x0
f010662a:	6a 06                	push   $0x6
f010662c:	e9 b3 00 00 00       	jmp    f01066e4 <_alltraps>
f0106631:	90                   	nop

f0106632 <Handler_DEVICE>:
TRAPHANDLER_NOEC(Handler_DEVICE, T_DEVICE)
f0106632:	6a 00                	push   $0x0
f0106634:	6a 07                	push   $0x7
f0106636:	e9 a9 00 00 00       	jmp    f01066e4 <_alltraps>
f010663b:	90                   	nop

f010663c <Handler_DBLFLT>:
TRAPHANDLER(Handler_DBLFLT, T_DBLFLT)
f010663c:	6a 08                	push   $0x8
f010663e:	e9 a1 00 00 00       	jmp    f01066e4 <_alltraps>
f0106643:	90                   	nop

f0106644 <Handler_TSS>:
TRAPHANDLER(Handler_TSS, T_TSS)
f0106644:	6a 0a                	push   $0xa
f0106646:	e9 99 00 00 00       	jmp    f01066e4 <_alltraps>
f010664b:	90                   	nop

f010664c <Handler_SEGNP>:
TRAPHANDLER(Handler_SEGNP, T_SEGNP)
f010664c:	6a 0b                	push   $0xb
f010664e:	e9 91 00 00 00       	jmp    f01066e4 <_alltraps>
f0106653:	90                   	nop

f0106654 <Handler_STACK>:
TRAPHANDLER(Handler_STACK, T_STACK)
f0106654:	6a 0c                	push   $0xc
f0106656:	e9 89 00 00 00       	jmp    f01066e4 <_alltraps>
f010665b:	90                   	nop

f010665c <Handler_GPFLT>:
TRAPHANDLER(Handler_GPFLT, T_GPFLT)
f010665c:	6a 0d                	push   $0xd
f010665e:	e9 81 00 00 00       	jmp    f01066e4 <_alltraps>
f0106663:	90                   	nop

f0106664 <Handler_PGFLT>:
TRAPHANDLER(Handler_PGFLT, T_PGFLT)
f0106664:	6a 0e                	push   $0xe
f0106666:	eb 7c                	jmp    f01066e4 <_alltraps>

f0106668 <Handler_FPERR>:
TRAPHANDLER_NOEC(Handler_FPERR, T_FPERR)
f0106668:	6a 00                	push   $0x0
f010666a:	6a 10                	push   $0x10
f010666c:	eb 76                	jmp    f01066e4 <_alltraps>

f010666e <Handler_ALIGN>:
TRAPHANDLER(Handler_ALIGN, T_ALIGN)
f010666e:	6a 11                	push   $0x11
f0106670:	eb 72                	jmp    f01066e4 <_alltraps>

f0106672 <Handler_MCHK>:
TRAPHANDLER_NOEC(Handler_MCHK, T_MCHK)
f0106672:	6a 00                	push   $0x0
f0106674:	6a 12                	push   $0x12
f0106676:	eb 6c                	jmp    f01066e4 <_alltraps>

f0106678 <Handler_SIMDERR>:
TRAPHANDLER_NOEC(Handler_SIMDERR, T_SIMDERR)
f0106678:	6a 00                	push   $0x0
f010667a:	6a 13                	push   $0x13
f010667c:	eb 66                	jmp    f01066e4 <_alltraps>

f010667e <Handler_SYSCALL>:
TRAPHANDLER_NOEC(Handler_SYSCALL, T_SYSCALL)
f010667e:	6a 00                	push   $0x0
f0106680:	6a 30                	push   $0x30
f0106682:	eb 60                	jmp    f01066e4 <_alltraps>

f0106684 <Handler_IRQ0>:



TRAPHANDLER_NOEC(Handler_IRQ0, IRQ_OFFSET)
f0106684:	6a 00                	push   $0x0
f0106686:	6a 20                	push   $0x20
f0106688:	eb 5a                	jmp    f01066e4 <_alltraps>

f010668a <Handler_IRQ1>:
TRAPHANDLER_NOEC(Handler_IRQ1, IRQ_OFFSET+1)
f010668a:	6a 00                	push   $0x0
f010668c:	6a 21                	push   $0x21
f010668e:	eb 54                	jmp    f01066e4 <_alltraps>

f0106690 <Handler_IRQ2>:
TRAPHANDLER_NOEC(Handler_IRQ2, IRQ_OFFSET+2)
f0106690:	6a 00                	push   $0x0
f0106692:	6a 22                	push   $0x22
f0106694:	eb 4e                	jmp    f01066e4 <_alltraps>

f0106696 <Handler_IRQ3>:
TRAPHANDLER_NOEC(Handler_IRQ3, IRQ_OFFSET+3)
f0106696:	6a 00                	push   $0x0
f0106698:	6a 23                	push   $0x23
f010669a:	eb 48                	jmp    f01066e4 <_alltraps>

f010669c <Handler_IRQ4>:
TRAPHANDLER_NOEC(Handler_IRQ4, IRQ_OFFSET+4)
f010669c:	6a 00                	push   $0x0
f010669e:	6a 24                	push   $0x24
f01066a0:	eb 42                	jmp    f01066e4 <_alltraps>

f01066a2 <Handler_IRQ5>:
TRAPHANDLER_NOEC(Handler_IRQ5, IRQ_OFFSET+5)
f01066a2:	6a 00                	push   $0x0
f01066a4:	6a 25                	push   $0x25
f01066a6:	eb 3c                	jmp    f01066e4 <_alltraps>

f01066a8 <Handler_IRQ6>:
TRAPHANDLER_NOEC(Handler_IRQ6, IRQ_OFFSET+6)
f01066a8:	6a 00                	push   $0x0
f01066aa:	6a 26                	push   $0x26
f01066ac:	eb 36                	jmp    f01066e4 <_alltraps>

f01066ae <Handler_IRQ7>:
TRAPHANDLER_NOEC(Handler_IRQ7, IRQ_OFFSET+7)
f01066ae:	6a 00                	push   $0x0
f01066b0:	6a 27                	push   $0x27
f01066b2:	eb 30                	jmp    f01066e4 <_alltraps>

f01066b4 <Handler_IRQ8>:
TRAPHANDLER_NOEC(Handler_IRQ8, IRQ_OFFSET+8)
f01066b4:	6a 00                	push   $0x0
f01066b6:	6a 28                	push   $0x28
f01066b8:	eb 2a                	jmp    f01066e4 <_alltraps>

f01066ba <Handler_IRQ9>:
TRAPHANDLER_NOEC(Handler_IRQ9, IRQ_OFFSET+9)
f01066ba:	6a 00                	push   $0x0
f01066bc:	6a 29                	push   $0x29
f01066be:	eb 24                	jmp    f01066e4 <_alltraps>

f01066c0 <Handler_IRQ10>:
TRAPHANDLER_NOEC(Handler_IRQ10, IRQ_OFFSET+10)
f01066c0:	6a 00                	push   $0x0
f01066c2:	6a 2a                	push   $0x2a
f01066c4:	eb 1e                	jmp    f01066e4 <_alltraps>

f01066c6 <Handler_IRQ11>:
TRAPHANDLER_NOEC(Handler_IRQ11, IRQ_OFFSET+11)
f01066c6:	6a 00                	push   $0x0
f01066c8:	6a 2b                	push   $0x2b
f01066ca:	eb 18                	jmp    f01066e4 <_alltraps>

f01066cc <Handler_IRQ12>:
TRAPHANDLER_NOEC(Handler_IRQ12, IRQ_OFFSET+12)
f01066cc:	6a 00                	push   $0x0
f01066ce:	6a 2c                	push   $0x2c
f01066d0:	eb 12                	jmp    f01066e4 <_alltraps>

f01066d2 <Handler_IRQ13>:
TRAPHANDLER_NOEC(Handler_IRQ13, IRQ_OFFSET+13)
f01066d2:	6a 00                	push   $0x0
f01066d4:	6a 2d                	push   $0x2d
f01066d6:	eb 0c                	jmp    f01066e4 <_alltraps>

f01066d8 <Handler_IRQ14>:
TRAPHANDLER_NOEC(Handler_IRQ14, IRQ_OFFSET+14)
f01066d8:	6a 00                	push   $0x0
f01066da:	6a 2e                	push   $0x2e
f01066dc:	eb 06                	jmp    f01066e4 <_alltraps>

f01066de <Handler_IRQ15>:
TRAPHANDLER_NOEC(Handler_IRQ15, IRQ_OFFSET+15)
f01066de:	6a 00                	push   $0x0
f01066e0:	6a 2f                	push   $0x2f
f01066e2:	eb 00                	jmp    f01066e4 <_alltraps>

f01066e4 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushw $0x0
f01066e4:	66 6a 00             	pushw  $0x0
    pushw %ds
f01066e7:	66 1e                	pushw  %ds
	pushw $0x0
f01066e9:	66 6a 00             	pushw  $0x0
    pushw %es
f01066ec:	66 06                	pushw  %es
    pushal
f01066ee:	60                   	pusha  
    movl $GD_KD, %eax
f01066ef:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
f01066f4:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f01066f6:	8e c0                	mov    %eax,%es
    push %esp
f01066f8:	54                   	push   %esp
f01066f9:	e8 67 fc ff ff       	call   f0106365 <trap>
	...

f0106700 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0106700:	55                   	push   %ebp
f0106701:	89 e5                	mov    %esp,%ebp
f0106703:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0106706:	8b 15 50 62 35 f0    	mov    0xf0356250,%edx
f010670c:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010670f:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0106714:	8b 0a                	mov    (%edx),%ecx
f0106716:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0106717:	83 f9 02             	cmp    $0x2,%ecx
f010671a:	76 0d                	jbe    f0106729 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010671c:	40                   	inc    %eax
f010671d:	83 c2 7c             	add    $0x7c,%edx
f0106720:	3d 00 04 00 00       	cmp    $0x400,%eax
f0106725:	75 ed                	jne    f0106714 <sched_halt+0x14>
f0106727:	eb 07                	jmp    f0106730 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0106729:	3d 00 04 00 00       	cmp    $0x400,%eax
f010672e:	75 1a                	jne    f010674a <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0106730:	c7 04 24 10 af 10 f0 	movl   $0xf010af10,(%esp)
f0106737:	e8 b2 f0 ff ff       	call   f01057ee <cprintf>
		while (1)
			monitor(NULL);
f010673c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106743:	e8 33 b5 ff ff       	call   f0101c7b <monitor>
f0106748:	eb f2                	jmp    f010673c <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010674a:	e8 21 1a 00 00       	call   f0108170 <cpunum>
f010674f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106756:	29 c2                	sub    %eax,%edx
f0106758:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010675b:	c7 04 85 28 70 35 f0 	movl   $0x0,-0xfca8fd8(,%eax,4)
f0106762:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0106766:	a1 8c 6e 35 f0       	mov    0xf0356e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010676b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0106770:	77 20                	ja     f0106792 <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106772:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106776:	c7 44 24 08 64 88 10 	movl   $0xf0108864,0x8(%esp)
f010677d:	f0 
f010677e:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
f0106785:	00 
f0106786:	c7 04 24 39 af 10 f0 	movl   $0xf010af39,(%esp)
f010678d:	e8 ae 98 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0106792:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0106797:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010679a:	e8 d1 19 00 00       	call   f0108170 <cpunum>
f010679f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067a6:	29 c2                	sub    %eax,%edx
f01067a8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01067ab:	8d 14 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01067b2:	b8 02 00 00 00       	mov    $0x2,%eax
f01067b7:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01067bb:	c7 04 24 00 f2 14 f0 	movl   $0xf014f200,(%esp)
f01067c2:	e8 0b 1d 00 00       	call   f01084d2 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01067c7:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01067c9:	e8 a2 19 00 00       	call   f0108170 <cpunum>
f01067ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067d5:	29 c2                	sub    %eax,%edx
f01067d7:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01067da:	8b 04 85 30 70 35 f0 	mov    -0xfca8fd0(,%eax,4),%eax
f01067e1:	bd 00 00 00 00       	mov    $0x0,%ebp
f01067e6:	89 c4                	mov    %eax,%esp
f01067e8:	6a 00                	push   $0x0
f01067ea:	6a 00                	push   $0x0
f01067ec:	fb                   	sti    
f01067ed:	f4                   	hlt    
f01067ee:	eb fd                	jmp    f01067ed <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01067f0:	c9                   	leave  
f01067f1:	c3                   	ret    

f01067f2 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01067f2:	55                   	push   %ebp
f01067f3:	89 e5                	mov    %esp,%ebp
f01067f5:	57                   	push   %edi
f01067f6:	56                   	push   %esi
f01067f7:	53                   	push   %ebx
f01067f8:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("cpu_env: %x\n",thiscpu->cpu_env);
	struct Env*current_env = thiscpu->cpu_env;
f01067fb:	e8 70 19 00 00       	call   f0108170 <cpunum>
f0106800:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106807:	29 c2                	sub    %eax,%edx
f0106809:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010680c:	8b 3c 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%edi
	size_t id = 0;
	if (current_env != NULL)id = (ENVX(current_env->env_id) + 1) % NENV;
f0106813:	85 ff                	test   %edi,%edi
f0106815:	74 74                	je     f010688b <sched_yield+0x99>
f0106817:	8b 47 48             	mov    0x48(%edi),%eax
f010681a:	8d 40 01             	lea    0x1(%eax),%eax
f010681d:	25 ff 03 00 00       	and    $0x3ff,%eax
f0106822:	79 6c                	jns    f0106890 <sched_yield+0x9e>
f0106824:	48                   	dec    %eax
f0106825:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f010682a:	40                   	inc    %eax
f010682b:	eb 63                	jmp    f0106890 <sched_yield+0x9e>
	for (int i = 0; i < NENV; i++,id = (id + 1) % NENV){
		if (envs[id].env_status == ENV_RUNNABLE){
f010682d:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f0106834:	89 c3                	mov    %eax,%ebx
f0106836:	c1 e3 07             	shl    $0x7,%ebx
f0106839:	29 f3                	sub    %esi,%ebx
f010683b:	89 de                	mov    %ebx,%esi
f010683d:	01 cb                	add    %ecx,%ebx
f010683f:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0106843:	75 16                	jne    f010685b <sched_yield+0x69>
			envs[id].env_cpunum = cpunum();
f0106845:	e8 26 19 00 00       	call   f0108170 <cpunum>
f010684a:	89 43 5c             	mov    %eax,0x5c(%ebx)
			env_run(&envs[id]);
f010684d:	03 35 50 62 35 f0    	add    0xf0356250,%esi
f0106853:	89 34 24             	mov    %esi,(%esp)
f0106856:	e8 2b ed ff ff       	call   f0105586 <env_run>
	// LAB 4: Your code here.
	// cprintf("cpu_env: %x\n",thiscpu->cpu_env);
	struct Env*current_env = thiscpu->cpu_env;
	size_t id = 0;
	if (current_env != NULL)id = (ENVX(current_env->env_id) + 1) % NENV;
	for (int i = 0; i < NENV; i++,id = (id + 1) % NENV){
f010685b:	40                   	inc    %eax
f010685c:	25 ff 03 00 00       	and    $0x3ff,%eax
f0106861:	4a                   	dec    %edx
f0106862:	75 c9                	jne    f010682d <sched_yield+0x3b>
			envs[id].env_cpunum = cpunum();
			env_run(&envs[id]);
			return;
		}
	}
	if (current_env != NULL && current_env->env_status == ENV_RUNNING){
f0106864:	85 ff                	test   %edi,%edi
f0106866:	74 16                	je     f010687e <sched_yield+0x8c>
f0106868:	83 7f 54 03          	cmpl   $0x3,0x54(%edi)
f010686c:	75 10                	jne    f010687e <sched_yield+0x8c>
		current_env->env_cpunum = cpunum();
f010686e:	e8 fd 18 00 00       	call   f0108170 <cpunum>
f0106873:	89 47 5c             	mov    %eax,0x5c(%edi)
		env_run(current_env);
f0106876:	89 3c 24             	mov    %edi,(%esp)
f0106879:	e8 08 ed ff ff       	call   f0105586 <env_run>
		return;
	}
	// sched_halt never returns
	sched_halt();
f010687e:	e8 7d fe ff ff       	call   f0106700 <sched_halt>
}
f0106883:	83 c4 1c             	add    $0x1c,%esp
f0106886:	5b                   	pop    %ebx
f0106887:	5e                   	pop    %esi
f0106888:	5f                   	pop    %edi
f0106889:	5d                   	pop    %ebp
f010688a:	c3                   	ret    
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("cpu_env: %x\n",thiscpu->cpu_env);
	struct Env*current_env = thiscpu->cpu_env;
	size_t id = 0;
f010688b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (current_env != NULL)id = (ENVX(current_env->env_id) + 1) % NENV;
	for (int i = 0; i < NENV; i++,id = (id + 1) % NENV){
		if (envs[id].env_status == ENV_RUNNABLE){
f0106890:	8b 0d 50 62 35 f0    	mov    0xf0356250,%ecx
f0106896:	ba 00 04 00 00       	mov    $0x400,%edx
f010689b:	eb 90                	jmp    f010682d <sched_yield+0x3b>
f010689d:	00 00                	add    %al,(%eax)
	...

f01068a0 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f01068a0:	55                   	push   %ebp
f01068a1:	89 e5                	mov    %esp,%ebp
f01068a3:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f01068a6:	e8 c5 18 00 00       	call   f0108170 <cpunum>
f01068ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01068b2:	29 c2                	sub    %eax,%edx
f01068b4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01068b7:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f01068be:	8b 40 48             	mov    0x48(%eax),%eax
}
f01068c1:	c9                   	leave  
f01068c2:	c3                   	ret    

f01068c3 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f01068c3:	55                   	push   %ebp
f01068c4:	89 e5                	mov    %esp,%ebp
f01068c6:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f01068c9:	e8 24 ff ff ff       	call   f01067f2 <sched_yield>

f01068ce <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01068ce:	55                   	push   %ebp
f01068cf:	89 e5                	mov    %esp,%ebp
f01068d1:	57                   	push   %edi
f01068d2:	56                   	push   %esi
f01068d3:	53                   	push   %ebx
f01068d4:	83 ec 3c             	sub    $0x3c,%esp
f01068d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01068da:	8b 75 0c             	mov    0xc(%ebp),%esi
f01068dd:	8b 7d 10             	mov    0x10(%ebp),%edi
f01068e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	// cprintf("syscall %x\n",syscallno);
	int32_t res = 0;
	switch (syscallno){
f01068e3:	83 f8 0c             	cmp    $0xc,%eax
f01068e6:	0f 87 01 06 00 00    	ja     f0106eed <syscall+0x61f>
f01068ec:	ff 24 85 80 af 10 f0 	jmp    *-0xfef5080(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(const void *)s,len,PTE_U);
f01068f3:	e8 78 18 00 00       	call   f0108170 <cpunum>
f01068f8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01068ff:	00 
f0106900:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106904:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106908:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010690f:	29 c2                	sub    %eax,%edx
f0106911:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106914:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f010691b:	89 04 24             	mov    %eax,(%esp)
f010691e:	e8 bf e3 ff ff       	call   f0104ce2 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0106923:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106927:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010692b:	c7 04 24 46 af 10 f0 	movl   $0xf010af46,(%esp)
f0106932:	e8 b7 ee ff ff       	call   f01057ee <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	// cprintf("syscall %x\n",syscallno);
	int32_t res = 0;
f0106937:	b8 00 00 00 00       	mov    $0x0,%eax
f010693c:	e9 b8 05 00 00       	jmp    f0106ef9 <syscall+0x62b>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0106941:	e8 bf 9f ff ff       	call   f0100905 <cons_getc>
	int32_t res = 0;
	switch (syscallno){
		case SYS_cputs:
			sys_cputs((const char *)a1,a2);
			break;
		case SYS_cgetc:res = sys_cgetc();break;
f0106946:	e9 ae 05 00 00       	jmp    f0106ef9 <syscall+0x62b>
		case SYS_getenvid:res = sys_getenvid();break;
f010694b:	e8 50 ff ff ff       	call   f01068a0 <sys_getenvid>
f0106950:	e9 a4 05 00 00       	jmp    f0106ef9 <syscall+0x62b>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0106955:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010695c:	00 
f010695d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106960:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106964:	89 34 24             	mov    %esi,(%esp)
f0106967:	e8 6b e4 ff ff       	call   f0104dd7 <envid2env>
f010696c:	85 c0                	test   %eax,%eax
f010696e:	0f 88 85 05 00 00    	js     f0106ef9 <syscall+0x62b>
		return r;
	if (e == curenv)
f0106974:	e8 f7 17 00 00       	call   f0108170 <cpunum>
f0106979:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010697c:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0106983:	29 c1                	sub    %eax,%ecx
f0106985:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0106988:	39 14 85 28 70 35 f0 	cmp    %edx,-0xfca8fd8(,%eax,4)
f010698f:	75 2d                	jne    f01069be <syscall+0xf0>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0106991:	e8 da 17 00 00       	call   f0108170 <cpunum>
f0106996:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010699d:	29 c2                	sub    %eax,%edx
f010699f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069a2:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f01069a9:	8b 40 48             	mov    0x48(%eax),%eax
f01069ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069b0:	c7 04 24 4b af 10 f0 	movl   $0xf010af4b,(%esp)
f01069b7:	e8 32 ee ff ff       	call   f01057ee <cprintf>
f01069bc:	eb 32                	jmp    f01069f0 <syscall+0x122>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01069be:	8b 5a 48             	mov    0x48(%edx),%ebx
f01069c1:	e8 aa 17 00 00       	call   f0108170 <cpunum>
f01069c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01069ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01069d1:	29 c2                	sub    %eax,%edx
f01069d3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069d6:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f01069dd:	8b 40 48             	mov    0x48(%eax),%eax
f01069e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069e4:	c7 04 24 66 af 10 f0 	movl   $0xf010af66,(%esp)
f01069eb:	e8 fe ed ff ff       	call   f01057ee <cprintf>
	env_destroy(e);
f01069f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01069f3:	89 04 24             	mov    %eax,(%esp)
f01069f6:	e8 cc ea ff ff       	call   f01054c7 <env_destroy>
	return 0;
f01069fb:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cputs:
			sys_cputs((const char *)a1,a2);
			break;
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
f0106a00:	e9 f4 04 00 00       	jmp    f0106ef9 <syscall+0x62b>
		case SYS_yield:sys_yield();break;
f0106a05:	e8 b9 fe ff ff       	call   f01068c3 <sys_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *e;
	int err = env_alloc(&e,curenv->env_id);
f0106a0a:	e8 61 17 00 00       	call   f0108170 <cpunum>
f0106a0f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a16:	29 c2                	sub    %eax,%edx
f0106a18:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a1b:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0106a22:	8b 40 48             	mov    0x48(%eax),%eax
f0106a25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a29:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106a2c:	89 04 24             	mov    %eax,(%esp)
f0106a2f:	e8 10 e5 ff ff       	call   f0104f44 <env_alloc>
	if (err < 0)return err;
f0106a34:	85 c0                	test   %eax,%eax
f0106a36:	0f 88 bd 04 00 00    	js     f0106ef9 <syscall+0x62b>
	e->env_status = ENV_NOT_RUNNABLE;
f0106a3c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106a3f:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0106a46:	e8 25 17 00 00       	call   f0108170 <cpunum>
f0106a4b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a52:	29 c2                	sub    %eax,%edx
f0106a54:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a57:	8b 34 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%esi
f0106a5e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0106a63:	89 df                	mov    %ebx,%edi
f0106a65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0106a67:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106a6a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0106a71:	8b 40 48             	mov    0x48(%eax),%eax
			break;
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
f0106a74:	e9 80 04 00 00       	jmp    f0106ef9 <syscall+0x62b>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_RUNNABLE && status != ENV_RUNNABLE)
f0106a79:	83 ff 02             	cmp    $0x2,%edi
f0106a7c:	75 33                	jne    f0106ab1 <syscall+0x1e3>
		return -E_INVAL;
	struct Env *e;
	int err = envid2env(envid,&e,1);
f0106a7e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106a85:	00 
f0106a86:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106a89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a8d:	89 34 24             	mov    %esi,(%esp)
f0106a90:	e8 42 e3 ff ff       	call   f0104dd7 <envid2env>
	if (err < 0)return err;
f0106a95:	85 c0                	test   %eax,%eax
f0106a97:	0f 88 5c 04 00 00    	js     f0106ef9 <syscall+0x62b>
	e->env_status = status;
f0106a9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106aa0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0106aa7:	b8 00 00 00 00       	mov    $0x0,%eax
f0106aac:	e9 48 04 00 00       	jmp    f0106ef9 <syscall+0x62b>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_RUNNABLE && status != ENV_RUNNABLE)
		return -E_INVAL;
f0106ab1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
f0106ab6:	e9 3e 04 00 00       	jmp    f0106ef9 <syscall+0x62b>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
f0106abb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106ac2:	00 
f0106ac3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106aca:	89 34 24             	mov    %esi,(%esp)
f0106acd:	e8 05 e3 ff ff       	call   f0104dd7 <envid2env>
	if (err < 0)return err;
f0106ad2:	85 c0                	test   %eax,%eax
f0106ad4:	0f 88 1f 04 00 00    	js     f0106ef9 <syscall+0x62b>
	// cprintf("sys_env_pgfault_upcall: %x\n",func);
	e->env_pgfault_upcall = func;
f0106ada:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106add:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0106ae0:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
f0106ae5:	e9 0f 04 00 00       	jmp    f0106ef9 <syscall+0x62b>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
f0106aea:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106af1:	00 
f0106af2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106af5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106af9:	89 34 24             	mov    %esi,(%esp)
f0106afc:	e8 d6 e2 ff ff       	call   f0104dd7 <envid2env>
	if (err < 0)return err;
f0106b01:	85 c0                	test   %eax,%eax
f0106b03:	0f 88 f0 03 00 00    	js     f0106ef9 <syscall+0x62b>
	if ((uint32_t)va >= UTOP || PGOFF(va))return -E_INVAL;
f0106b09:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0106b0f:	77 56                	ja     f0106b67 <syscall+0x299>
f0106b11:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0106b17:	75 58                	jne    f0106b71 <syscall+0x2a3>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
f0106b19:	89 d8                	mov    %ebx,%eax
f0106b1b:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0106b20:	83 f8 05             	cmp    $0x5,%eax
f0106b23:	75 56                	jne    f0106b7b <syscall+0x2ad>
		return -E_INVAL;
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0106b25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106b2c:	e8 38 bc ff ff       	call   f0102769 <page_alloc>
f0106b31:	89 c6                	mov    %eax,%esi
	if (page == NULL) return -E_NO_MEM;
f0106b33:	85 c0                	test   %eax,%eax
f0106b35:	74 4e                	je     f0106b85 <syscall+0x2b7>
	err = page_insert(e->env_pgdir,page,va,perm);
f0106b37:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106b3b:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b43:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106b46:	8b 40 60             	mov    0x60(%eax),%eax
f0106b49:	89 04 24             	mov    %eax,(%esp)
f0106b4c:	e8 8e bf ff ff       	call   f0102adf <page_insert>
	if (err<0){
f0106b51:	85 c0                	test   %eax,%eax
f0106b53:	79 3a                	jns    f0106b8f <syscall+0x2c1>
		page_free(page);
f0106b55:	89 34 24             	mov    %esi,(%esp)
f0106b58:	e8 90 bc ff ff       	call   f01027ed <page_free>
		return -E_NO_MEM;
f0106b5d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106b62:	e9 92 03 00 00       	jmp    f0106ef9 <syscall+0x62b>

	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
	if (err < 0)return err;
	if ((uint32_t)va >= UTOP || PGOFF(va))return -E_INVAL;
f0106b67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b6c:	e9 88 03 00 00       	jmp    f0106ef9 <syscall+0x62b>
f0106b71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b76:	e9 7e 03 00 00       	jmp    f0106ef9 <syscall+0x62b>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
		return -E_INVAL;
f0106b7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b80:	e9 74 03 00 00       	jmp    f0106ef9 <syscall+0x62b>
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
	if (page == NULL) return -E_NO_MEM;
f0106b85:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106b8a:	e9 6a 03 00 00       	jmp    f0106ef9 <syscall+0x62b>
	err = page_insert(e->env_pgdir,page,va,perm);
	if (err<0){
		page_free(page);
		return -E_NO_MEM;
	}
	return 0;
f0106b8f:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
f0106b94:	e9 60 03 00 00       	jmp    f0106ef9 <syscall+0x62b>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env*esrc,*edst;
	int errsrc = envid2env(srcenvid,&esrc,1),errdst = envid2env(dstenvid,&edst,1);
f0106b99:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106ba0:	00 
f0106ba1:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ba8:	89 34 24             	mov    %esi,(%esp)
f0106bab:	e8 27 e2 ff ff       	call   f0104dd7 <envid2env>
f0106bb0:	89 c6                	mov    %eax,%esi
f0106bb2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106bb9:	00 
f0106bba:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bc1:	89 1c 24             	mov    %ebx,(%esp)
f0106bc4:	e8 0e e2 ff ff       	call   f0104dd7 <envid2env>
	if (errsrc < 0 || errdst < 0)return -E_BAD_ENV;
f0106bc9:	85 f6                	test   %esi,%esi
f0106bcb:	0f 88 c4 00 00 00    	js     f0106c95 <syscall+0x3c7>
f0106bd1:	85 c0                	test   %eax,%eax
f0106bd3:	0f 88 c6 00 00 00    	js     f0106c9f <syscall+0x3d1>
	if ((uint32_t)srcva >= UTOP || PGOFF(srcva) || (uint32_t)dstva >= UTOP || PGOFF(dstva))return -E_INVAL;
f0106bd9:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0106bdf:	0f 87 c4 00 00 00    	ja     f0106ca9 <syscall+0x3db>
f0106be5:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0106beb:	0f 85 c2 00 00 00    	jne    f0106cb3 <syscall+0x3e5>
f0106bf1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0106bf8:	0f 87 bf 00 00 00    	ja     f0106cbd <syscall+0x3ef>
f0106bfe:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0106c05:	0f 85 bc 00 00 00    	jne    f0106cc7 <syscall+0x3f9>
	pte_t* pte;
	struct PageInfo* page = page_lookup(esrc->env_pgdir, srcva, &pte);
f0106c0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106c12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106c16:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106c19:	8b 40 60             	mov    0x60(%eax),%eax
f0106c1c:	89 04 24             	mov    %eax,(%esp)
f0106c1f:	e8 bc bd ff ff       	call   f01029e0 <page_lookup>
f0106c24:	89 c6                	mov    %eax,%esi
	if (page == NULL) return -E_INVAL;
f0106c26:	85 c0                	test   %eax,%eax
f0106c28:	0f 84 a3 00 00 00    	je     f0106cd1 <syscall+0x403>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
f0106c2e:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0106c31:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0106c36:	83 f8 05             	cmp    $0x5,%eax
f0106c39:	0f 85 9c 00 00 00    	jne    f0106cdb <syscall+0x40d>
		return -E_INVAL;
	if ((perm & PTE_W)&&!(*pte & PTE_W))return -E_INVAL;
f0106c3f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0106c43:	74 0c                	je     f0106c51 <syscall+0x383>
f0106c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106c48:	f6 00 02             	testb  $0x2,(%eax)
f0106c4b:	0f 84 94 00 00 00    	je     f0106ce5 <syscall+0x417>
	struct PageInfo* pagedst = page_alloc(ALLOC_ZERO);
f0106c51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106c58:	e8 0c bb ff ff       	call   f0102769 <page_alloc>
f0106c5d:	89 c3                	mov    %eax,%ebx
	if (page == NULL) return -E_NO_MEM;
	int err = page_insert(edst->env_pgdir,page,dstva,perm);
f0106c5f:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0106c62:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c66:	8b 55 18             	mov    0x18(%ebp),%edx
f0106c69:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c6d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106c74:	8b 40 60             	mov    0x60(%eax),%eax
f0106c77:	89 04 24             	mov    %eax,(%esp)
f0106c7a:	e8 60 be ff ff       	call   f0102adf <page_insert>
	if (err < 0){
f0106c7f:	85 c0                	test   %eax,%eax
f0106c81:	79 6c                	jns    f0106cef <syscall+0x421>
		page_free(pagedst);
f0106c83:	89 1c 24             	mov    %ebx,(%esp)
f0106c86:	e8 62 bb ff ff       	call   f01027ed <page_free>
		return -E_NO_MEM;
f0106c8b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106c90:	e9 64 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env*esrc,*edst;
	int errsrc = envid2env(srcenvid,&esrc,1),errdst = envid2env(dstenvid,&edst,1);
	if (errsrc < 0 || errdst < 0)return -E_BAD_ENV;
f0106c95:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106c9a:	e9 5a 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
f0106c9f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106ca4:	e9 50 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
	if ((uint32_t)srcva >= UTOP || PGOFF(srcva) || (uint32_t)dstva >= UTOP || PGOFF(dstva))return -E_INVAL;
f0106ca9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106cae:	e9 46 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
f0106cb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106cb8:	e9 3c 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
f0106cbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106cc2:	e9 32 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
f0106cc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ccc:	e9 28 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
	pte_t* pte;
	struct PageInfo* page = page_lookup(esrc->env_pgdir, srcva, &pte);
	if (page == NULL) return -E_INVAL;
f0106cd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106cd6:	e9 1e 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
	if ((perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))
		return -E_INVAL;
f0106cdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ce0:	e9 14 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
	if ((perm & PTE_W)&&!(*pte & PTE_W))return -E_INVAL;
f0106ce5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106cea:	e9 0a 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
	int err = page_insert(edst->env_pgdir,page,dstva,perm);
	if (err < 0){
		page_free(pagedst);
		return -E_NO_MEM;
	}
	return 0;
f0106cef:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_yield:sys_yield();break;
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
f0106cf4:	e9 00 02 00 00       	jmp    f0106ef9 <syscall+0x62b>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e;
	int err = envid2env(envid,&e,1);
f0106cf9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106d00:	00 
f0106d01:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106d04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d08:	89 34 24             	mov    %esi,(%esp)
f0106d0b:	e8 c7 e0 ff ff       	call   f0104dd7 <envid2env>
	if (err < 0)return err;
f0106d10:	85 c0                	test   %eax,%eax
f0106d12:	0f 88 e1 01 00 00    	js     f0106ef9 <syscall+0x62b>
	pte_t*pte;
	struct PageInfo* page = page_lookup(e->env_pgdir,va,&pte);
f0106d18:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106d1b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106d1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106d23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106d26:	8b 40 60             	mov    0x60(%eax),%eax
f0106d29:	89 04 24             	mov    %eax,(%esp)
f0106d2c:	e8 af bc ff ff       	call   f01029e0 <page_lookup>
	if (pte == NULL || !(*pte & PTE_W))return -E_BAD_ENV;
f0106d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106d34:	85 c0                	test   %eax,%eax
f0106d36:	74 31                	je     f0106d69 <syscall+0x49b>
f0106d38:	f6 00 02             	testb  $0x2,(%eax)
f0106d3b:	74 36                	je     f0106d73 <syscall+0x4a5>
	if ((uint32_t)va >= UTOP || PGOFF(va)) return -E_INVAL;
f0106d3d:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0106d43:	77 38                	ja     f0106d7d <syscall+0x4af>
f0106d45:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0106d4b:	75 3a                	jne    f0106d87 <syscall+0x4b9>
	page_remove(e->env_pgdir,va);
f0106d4d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106d51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106d54:	8b 40 60             	mov    0x60(%eax),%eax
f0106d57:	89 04 24             	mov    %eax,(%esp)
f0106d5a:	e8 37 bd ff ff       	call   f0102a96 <page_remove>
	return 0;
f0106d5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d64:	e9 90 01 00 00       	jmp    f0106ef9 <syscall+0x62b>
	struct Env *e;
	int err = envid2env(envid,&e,1);
	if (err < 0)return err;
	pte_t*pte;
	struct PageInfo* page = page_lookup(e->env_pgdir,va,&pte);
	if (pte == NULL || !(*pte & PTE_W))return -E_BAD_ENV;
f0106d69:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106d6e:	e9 86 01 00 00       	jmp    f0106ef9 <syscall+0x62b>
f0106d73:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0106d78:	e9 7c 01 00 00       	jmp    f0106ef9 <syscall+0x62b>
	if ((uint32_t)va >= UTOP || PGOFF(va)) return -E_INVAL;
f0106d7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d82:	e9 72 01 00 00       	jmp    f0106ef9 <syscall+0x62b>
f0106d87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_exofork:res = (int32_t)sys_exofork();break;
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
f0106d8c:	e9 68 01 00 00       	jmp    f0106ef9 <syscall+0x62b>
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	envid_t src_envid = sys_getenvid(); 
f0106d91:	e8 0a fb ff ff       	call   f01068a0 <sys_getenvid>
f0106d96:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    struct Env *e;
	int err;
    err = envid2env(envid,&e,0);
f0106d99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106da0:	00 
f0106da1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106da4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106da8:	89 34 24             	mov    %esi,(%esp)
f0106dab:	e8 27 e0 ff ff       	call   f0104dd7 <envid2env>
	// cprintf("send: err %x\n",err);
	if (err<0)return err;
f0106db0:	85 c0                	test   %eax,%eax
f0106db2:	0f 88 41 01 00 00    	js     f0106ef9 <syscall+0x62b>
    if (!e->env_ipc_recving)return -E_IPC_NOT_RECV;
f0106db8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106dbb:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0106dbf:	0f 84 b8 00 00 00    	je     f0106e7d <syscall+0x5af>
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
f0106dc5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0106dcb:	77 22                	ja     f0106def <syscall+0x521>
f0106dcd:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0106dd3:	0f 85 ab 00 00 00    	jne    f0106e84 <syscall+0x5b6>
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
f0106dd9:	8b 45 18             	mov    0x18(%ebp),%eax
f0106ddc:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0106de1:	83 f8 05             	cmp    $0x5,%eax
f0106de4:	0f 84 17 01 00 00    	je     f0106f01 <syscall+0x633>
f0106dea:	e9 9c 00 00 00       	jmp    f0106e8b <syscall+0x5bd>
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
f0106def:	e8 7c 13 00 00       	call   f0108170 <cpunum>
f0106df4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0106df7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106dfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106dff:	6b c0 74             	imul   $0x74,%eax,%eax
f0106e02:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f0106e08:	8b 40 60             	mov    0x60(%eax),%eax
f0106e0b:	89 04 24             	mov    %eax,(%esp)
f0106e0e:	e8 cd bb ff ff       	call   f01029e0 <page_lookup>
	if ((uint32_t)srcva < UTOP){
		err = page_insert(e->env_pgdir,page,e->env_ipc_dstva,perm);
		if (err<0)return err;
	}
// cprintf("find\n");
    e->env_ipc_recving = false;
f0106e13:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106e16:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = src_envid;
f0106e1a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0106e1d:	89 48 74             	mov    %ecx,0x74(%eax)
	e->env_ipc_value = value;
f0106e20:	89 78 70             	mov    %edi,0x70(%eax)
	e->env_ipc_perm = ((uint32_t)srcva < UTOP)?perm:0;
f0106e23:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106e28:	eb 3b                	jmp    f0106e65 <syscall+0x597>
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & PTE_W) && (~*pte & PTE_W))return -E_INVAL;
f0106e2a:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0106e2e:	74 08                	je     f0106e38 <syscall+0x56a>
f0106e30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106e33:	f6 02 02             	testb  $0x2,(%edx)
f0106e36:	74 5a                	je     f0106e92 <syscall+0x5c4>
	if ((uint32_t)srcva < UTOP){
		err = page_insert(e->env_pgdir,page,e->env_ipc_dstva,perm);
f0106e38:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0106e3b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106e3e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106e42:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0106e45:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e4d:	8b 42 60             	mov    0x60(%edx),%eax
f0106e50:	89 04 24             	mov    %eax,(%esp)
f0106e53:	e8 87 bc ff ff       	call   f0102adf <page_insert>
		if (err<0)return err;
f0106e58:	85 c0                	test   %eax,%eax
f0106e5a:	0f 89 dc 00 00 00    	jns    f0106f3c <syscall+0x66e>
f0106e60:	e9 94 00 00 00       	jmp    f0106ef9 <syscall+0x62b>
	}
// cprintf("find\n");
    e->env_ipc_recving = false;
	e->env_ipc_from = src_envid;
	e->env_ipc_value = value;
	e->env_ipc_perm = ((uint32_t)srcva < UTOP)?perm:0;
f0106e65:	89 58 78             	mov    %ebx,0x78(%eax)
 	e->env_status = ENV_RUNNABLE;
f0106e68:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	 
	e->env_tf.tf_regs.reg_eax = 0;
f0106e6f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0106e76:	b8 00 00 00 00       	mov    $0x0,%eax
f0106e7b:	eb 7c                	jmp    f0106ef9 <syscall+0x62b>
    struct Env *e;
	int err;
    err = envid2env(envid,&e,0);
	// cprintf("send: err %x\n",err);
	if (err<0)return err;
    if (!e->env_ipc_recving)return -E_IPC_NOT_RECV;
f0106e7d:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0106e82:	eb 75                	jmp    f0106ef9 <syscall+0x62b>
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
f0106e84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e89:	eb 6e                	jmp    f0106ef9 <syscall+0x62b>
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
f0106e8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e90:	eb 67                	jmp    f0106ef9 <syscall+0x62b>
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & PTE_W) && (~*pte & PTE_W))return -E_INVAL;
f0106e92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e97:	eb 60                	jmp    f0106ef9 <syscall+0x62b>
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
f0106e99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_status:res = (int32_t)sys_env_set_status((envid_t)a1,a2);break;
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
		case SYS_ipc_try_send:res = (int32_t)sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void *)a3,(unsigned)a4);break;                               
f0106e9e:	eb 59                	jmp    f0106ef9 <syscall+0x62b>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva<UTOP&&PGOFF(dstva))return -E_INVAL;
f0106ea0:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0106ea6:	77 08                	ja     f0106eb0 <syscall+0x5e2>
f0106ea8:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0106eae:	75 44                	jne    f0106ef4 <syscall+0x626>
	curenv->env_ipc_recving = true;
f0106eb0:	e8 bb 12 00 00       	call   f0108170 <cpunum>
f0106eb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0106eb8:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f0106ebe:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0106ec2:	e8 a9 12 00 00       	call   f0108170 <cpunum>
f0106ec7:	6b c0 74             	imul   $0x74,%eax,%eax
f0106eca:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f0106ed0:	89 70 6c             	mov    %esi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0106ed3:	e8 98 12 00 00       	call   f0108170 <cpunum>
f0106ed8:	6b c0 74             	imul   $0x74,%eax,%eax
f0106edb:	8b 80 28 70 35 f0    	mov    -0xfca8fd8(%eax),%eax
f0106ee1:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sys_yield();
f0106ee8:	e8 d6 f9 ff ff       	call   f01068c3 <sys_yield>
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
		case SYS_ipc_try_send:res = (int32_t)sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void *)a3,(unsigned)a4);break;                               
		case SYS_ipc_recv:res = (int32_t)sys_ipc_recv((void *)a1);break;
		default:res = -E_INVAL;
f0106eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ef2:	eb 05                	jmp    f0106ef9 <syscall+0x62b>
		case SYS_env_set_pgfault_upcall:res = (int32_t)sys_env_set_pgfault_upcall((envid_t)a1,(void *)a2);break;
		case SYS_page_alloc:res = (int32_t)sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);break;
		case SYS_page_map:res = (int32_t)sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);break;
		case SYS_page_unmap:res = (int32_t)sys_page_unmap((envid_t)a1,(void*)a2);break;
		case SYS_ipc_try_send:res = (int32_t)sys_ipc_try_send((envid_t)a1,(uint32_t)a2,(void *)a3,(unsigned)a4);break;                               
		case SYS_ipc_recv:res = (int32_t)sys_ipc_recv((void *)a1);break;
f0106ef4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	switch (syscallno) {
	default:
		return -E_INVAL;
	}
}
f0106ef9:	83 c4 3c             	add    $0x3c,%esp
f0106efc:	5b                   	pop    %ebx
f0106efd:	5e                   	pop    %esi
f0106efe:	5f                   	pop    %edi
f0106eff:	5d                   	pop    %ebp
f0106f00:	c3                   	ret    
    if (!e->env_ipc_recving)return -E_IPC_NOT_RECV;
	// cprintf("%x %x %x\n",srcva,UTOP);
	if ((uint32_t)srcva < UTOP && PGOFF(srcva))return -E_INVAL;
	if ((uint32_t)srcva < UTOP && (perm & ~(PTE_AVAIL|PTE_W))^(PTE_U|PTE_P))return -E_INVAL;
	pte_t *pte;
	struct PageInfo *page = page_lookup(curenv->env_pgdir,srcva,&pte);
f0106f01:	e8 6a 12 00 00       	call   f0108170 <cpunum>
f0106f06:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0106f09:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106f11:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106f18:	29 c2                	sub    %eax,%edx
f0106f1a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106f1d:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f0106f24:	8b 40 60             	mov    0x60(%eax),%eax
f0106f27:	89 04 24             	mov    %eax,(%esp)
f0106f2a:	e8 b1 ba ff ff       	call   f01029e0 <page_lookup>
	if ((uint32_t)srcva < UTOP && page == NULL)return -E_INVAL;
f0106f2f:	85 c0                	test   %eax,%eax
f0106f31:	0f 85 f3 fe ff ff    	jne    f0106e2a <syscall+0x55c>
f0106f37:	e9 5d ff ff ff       	jmp    f0106e99 <syscall+0x5cb>
	if ((uint32_t)srcva < UTOP){
		err = page_insert(e->env_pgdir,page,e->env_ipc_dstva,perm);
		if (err<0)return err;
	}
// cprintf("find\n");
    e->env_ipc_recving = false;
f0106f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106f3f:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = src_envid;
f0106f43:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106f46:	89 50 74             	mov    %edx,0x74(%eax)
	e->env_ipc_value = value;
f0106f49:	89 78 70             	mov    %edi,0x70(%eax)
f0106f4c:	e9 14 ff ff ff       	jmp    f0106e65 <syscall+0x597>
f0106f51:	00 00                	add    %al,(%eax)
	...

f0106f54 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0106f54:	55                   	push   %ebp
f0106f55:	89 e5                	mov    %esp,%ebp
f0106f57:	57                   	push   %edi
f0106f58:	56                   	push   %esi
f0106f59:	53                   	push   %ebx
f0106f5a:	83 ec 14             	sub    $0x14,%esp
f0106f5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106f60:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0106f63:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0106f66:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0106f69:	8b 1a                	mov    (%edx),%ebx
f0106f6b:	8b 01                	mov    (%ecx),%eax
f0106f6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106f70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0106f77:	e9 83 00 00 00       	jmp    f0106fff <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0106f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106f7f:	01 d8                	add    %ebx,%eax
f0106f81:	89 c7                	mov    %eax,%edi
f0106f83:	c1 ef 1f             	shr    $0x1f,%edi
f0106f86:	01 c7                	add    %eax,%edi
f0106f88:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106f8a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0106f8d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0106f90:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0106f94:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106f96:	eb 01                	jmp    f0106f99 <stab_binsearch+0x45>
			m--;
f0106f98:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0106f99:	39 c3                	cmp    %eax,%ebx
f0106f9b:	7f 1e                	jg     f0106fbb <stab_binsearch+0x67>
f0106f9d:	0f b6 0a             	movzbl (%edx),%ecx
f0106fa0:	83 ea 0c             	sub    $0xc,%edx
f0106fa3:	39 f1                	cmp    %esi,%ecx
f0106fa5:	75 f1                	jne    f0106f98 <stab_binsearch+0x44>
f0106fa7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0106faa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0106fad:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0106fb0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0106fb4:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0106fb7:	76 18                	jbe    f0106fd1 <stab_binsearch+0x7d>
f0106fb9:	eb 05                	jmp    f0106fc0 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0106fbb:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0106fbe:	eb 3f                	jmp    f0106fff <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0106fc0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106fc3:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0106fc5:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0106fc8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0106fcf:	eb 2e                	jmp    f0106fff <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0106fd1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0106fd4:	73 15                	jae    f0106feb <stab_binsearch+0x97>
			*region_right = m - 1;
f0106fd6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106fd9:	49                   	dec    %ecx
f0106fda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106fe0:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0106fe2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0106fe9:	eb 14                	jmp    f0106fff <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0106feb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106fee:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106ff1:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f0106ff3:	ff 45 0c             	incl   0xc(%ebp)
f0106ff6:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0106ff8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0106fff:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0107002:	0f 8e 74 ff ff ff    	jle    f0106f7c <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0107008:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010700c:	75 0d                	jne    f010701b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010700e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107011:	8b 02                	mov    (%edx),%eax
f0107013:	48                   	dec    %eax
f0107014:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0107017:	89 01                	mov    %eax,(%ecx)
f0107019:	eb 2a                	jmp    f0107045 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010701b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010701e:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0107020:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107023:	8b 0a                	mov    (%edx),%ecx
f0107025:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0107028:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010702b:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010702f:	eb 01                	jmp    f0107032 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0107031:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0107032:	39 c8                	cmp    %ecx,%eax
f0107034:	7e 0a                	jle    f0107040 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0107036:	0f b6 1a             	movzbl (%edx),%ebx
f0107039:	83 ea 0c             	sub    $0xc,%edx
f010703c:	39 f3                	cmp    %esi,%ebx
f010703e:	75 f1                	jne    f0107031 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0107040:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107043:	89 02                	mov    %eax,(%edx)
	}
}
f0107045:	83 c4 14             	add    $0x14,%esp
f0107048:	5b                   	pop    %ebx
f0107049:	5e                   	pop    %esi
f010704a:	5f                   	pop    %edi
f010704b:	5d                   	pop    %ebp
f010704c:	c3                   	ret    

f010704d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010704d:	55                   	push   %ebp
f010704e:	89 e5                	mov    %esp,%ebp
f0107050:	57                   	push   %edi
f0107051:	56                   	push   %esi
f0107052:	53                   	push   %ebx
f0107053:	83 ec 5c             	sub    $0x5c,%esp
f0107056:	8b 75 08             	mov    0x8(%ebp),%esi
f0107059:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010705c:	c7 03 b4 af 10 f0    	movl   $0xf010afb4,(%ebx)
	info->eip_line = 0;
f0107062:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0107069:	c7 43 08 b4 af 10 f0 	movl   $0xf010afb4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0107070:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0107077:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010707a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0107081:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0107087:	0f 87 0f 01 00 00    	ja     f010719c <debuginfo_eip+0x14f>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd,sizeof(struct UserStabData),PTE_U)<0)return -1;
f010708d:	e8 de 10 00 00       	call   f0108170 <cpunum>
f0107092:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107099:	00 
f010709a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01070a1:	00 
f01070a2:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01070a9:	00 
f01070aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01070b1:	29 c2                	sub    %eax,%edx
f01070b3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01070b6:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f01070bd:	89 04 24             	mov    %eax,(%esp)
f01070c0:	e8 7e db ff ff       	call   f0104c43 <user_mem_check>
f01070c5:	85 c0                	test   %eax,%eax
f01070c7:	0f 88 85 02 00 00    	js     f0107352 <debuginfo_eip+0x305>
		stabs = usd->stabs;
f01070cd:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01070d3:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01070d6:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01070dc:	a1 08 00 20 00       	mov    0x200008,%eax
f01070e1:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01070e4:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01070ea:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
f01070ed:	e8 7e 10 00 00       	call   f0108170 <cpunum>
f01070f2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01070f9:	00 
f01070fa:	89 fa                	mov    %edi,%edx
f01070fc:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01070ff:	c1 fa 02             	sar    $0x2,%edx
f0107102:	8d 0c 92             	lea    (%edx,%edx,4),%ecx
f0107105:	8d 0c 8a             	lea    (%edx,%ecx,4),%ecx
f0107108:	8d 0c 8a             	lea    (%edx,%ecx,4),%ecx
f010710b:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f010710e:	c1 e1 08             	shl    $0x8,%ecx
f0107111:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0107114:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0107117:	03 4d b8             	add    -0x48(%ebp),%ecx
f010711a:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f010711d:	c1 e1 10             	shl    $0x10,%ecx
f0107120:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0107123:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0107126:	03 4d b8             	add    -0x48(%ebp),%ecx
f0107129:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
f010712c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107130:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0107133:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107137:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010713e:	29 c2                	sub    %eax,%edx
f0107140:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0107143:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f010714a:	89 04 24             	mov    %eax,(%esp)
f010714d:	e8 f1 da ff ff       	call   f0104c43 <user_mem_check>
f0107152:	85 c0                	test   %eax,%eax
f0107154:	0f 88 ff 01 00 00    	js     f0107359 <debuginfo_eip+0x30c>
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
f010715a:	e8 11 10 00 00       	call   f0108170 <cpunum>
f010715f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107166:	00 
f0107167:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010716a:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010716d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107171:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0107174:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0107178:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010717f:	29 c2                	sub    %eax,%edx
f0107181:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0107184:	8b 04 85 28 70 35 f0 	mov    -0xfca8fd8(,%eax,4),%eax
f010718b:	89 04 24             	mov    %eax,(%esp)
f010718e:	e8 b0 da ff ff       	call   f0104c43 <user_mem_check>
f0107193:	85 c0                	test   %eax,%eax
f0107195:	79 1f                	jns    f01071b6 <debuginfo_eip+0x169>
f0107197:	e9 c4 01 00 00       	jmp    f0107360 <debuginfo_eip+0x313>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010719c:	c7 45 c0 a8 39 12 f0 	movl   $0xf01239a8,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01071a3:	c7 45 bc 59 89 11 f0 	movl   $0xf0118959,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01071aa:	bf 58 89 11 f0       	mov    $0xf0118958,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01071af:	c7 45 c4 94 b4 10 f0 	movl   $0xf010b494,-0x3c(%ebp)
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01071b6:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01071b9:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f01071bc:	0f 83 a5 01 00 00    	jae    f0107367 <debuginfo_eip+0x31a>
f01071c2:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01071c6:	0f 85 a2 01 00 00    	jne    f010736e <debuginfo_eip+0x321>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01071cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01071d3:	89 f8                	mov    %edi,%eax
f01071d5:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f01071d8:	c1 f8 02             	sar    $0x2,%eax
f01071db:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01071de:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01071e1:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01071e4:	89 d1                	mov    %edx,%ecx
f01071e6:	c1 e1 08             	shl    $0x8,%ecx
f01071e9:	01 ca                	add    %ecx,%edx
f01071eb:	89 d1                	mov    %edx,%ecx
f01071ed:	c1 e1 10             	shl    $0x10,%ecx
f01071f0:	01 ca                	add    %ecx,%edx
f01071f2:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f01071f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01071f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01071fd:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0107204:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0107207:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010720a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010720d:	e8 42 fd ff ff       	call   f0106f54 <stab_binsearch>
	if (lfile == 0)
f0107212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107215:	85 c0                	test   %eax,%eax
f0107217:	0f 84 58 01 00 00    	je     f0107375 <debuginfo_eip+0x328>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010721d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0107220:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107223:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0107226:	89 74 24 04          	mov    %esi,0x4(%esp)
f010722a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0107231:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0107234:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0107237:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010723a:	e8 15 fd ff ff       	call   f0106f54 <stab_binsearch>

	if (lfun <= rfun) {
f010723f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107242:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107245:	39 d0                	cmp    %edx,%eax
f0107247:	7f 32                	jg     f010727b <debuginfo_eip+0x22e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0107249:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010724c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010724f:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0107252:	8b 39                	mov    (%ecx),%edi
f0107254:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0107257:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010725a:	2b 7d bc             	sub    -0x44(%ebp),%edi
f010725d:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0107260:	73 09                	jae    f010726b <debuginfo_eip+0x21e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0107262:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0107265:	03 7d bc             	add    -0x44(%ebp),%edi
f0107268:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010726b:	8b 49 08             	mov    0x8(%ecx),%ecx
f010726e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0107271:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0107273:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0107276:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0107279:	eb 0f                	jmp    f010728a <debuginfo_eip+0x23d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010727b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010727e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107281:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0107284:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107287:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010728a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0107291:	00 
f0107292:	8b 43 08             	mov    0x8(%ebx),%eax
f0107295:	89 04 24             	mov    %eax,(%esp)
f0107298:	e8 8d 08 00 00       	call   f0107b2a <strfind>
f010729d:	2b 43 08             	sub    0x8(%ebx),%eax
f01072a0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01072a3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01072a7:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01072ae:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01072b1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01072b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01072b7:	e8 98 fc ff ff       	call   f0106f54 <stab_binsearch>
	if (lline <= rline){
f01072bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01072bf:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01072c2:	0f 8f b4 00 00 00    	jg     f010737c <debuginfo_eip+0x32f>
		info->eip_line = stabs[lline].n_desc;
f01072c8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01072cb:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01072ce:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01072d3:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01072d6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01072d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01072dc:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01072df:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f01072e3:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01072e6:	eb 04                	jmp    f01072ec <debuginfo_eip+0x29f>
f01072e8:	48                   	dec    %eax
f01072e9:	83 ea 0c             	sub    $0xc,%edx
f01072ec:	89 c7                	mov    %eax,%edi
f01072ee:	39 c6                	cmp    %eax,%esi
f01072f0:	7f 28                	jg     f010731a <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f01072f2:	8a 4a fc             	mov    -0x4(%edx),%cl
f01072f5:	80 f9 84             	cmp    $0x84,%cl
f01072f8:	0f 84 99 00 00 00    	je     f0107397 <debuginfo_eip+0x34a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01072fe:	80 f9 64             	cmp    $0x64,%cl
f0107301:	75 e5                	jne    f01072e8 <debuginfo_eip+0x29b>
f0107303:	83 3a 00             	cmpl   $0x0,(%edx)
f0107306:	74 e0                	je     f01072e8 <debuginfo_eip+0x29b>
f0107308:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010730b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010730e:	e9 8a 00 00 00       	jmp    f010739d <debuginfo_eip+0x350>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0107313:	03 45 bc             	add    -0x44(%ebp),%eax
f0107316:	89 03                	mov    %eax,(%ebx)
f0107318:	eb 03                	jmp    f010731d <debuginfo_eip+0x2d0>
f010731a:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010731d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107320:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0107323:	39 f2                	cmp    %esi,%edx
f0107325:	7d 5c                	jge    f0107383 <debuginfo_eip+0x336>
		for (lline = lfun + 1;
f0107327:	42                   	inc    %edx
f0107328:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010732b:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010732d:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0107330:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0107333:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0107337:	eb 03                	jmp    f010733c <debuginfo_eip+0x2ef>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0107339:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010733c:	39 f0                	cmp    %esi,%eax
f010733e:	7d 4a                	jge    f010738a <debuginfo_eip+0x33d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0107340:	8a 0a                	mov    (%edx),%cl
f0107342:	40                   	inc    %eax
f0107343:	83 c2 0c             	add    $0xc,%edx
f0107346:	80 f9 a0             	cmp    $0xa0,%cl
f0107349:	74 ee                	je     f0107339 <debuginfo_eip+0x2ec>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010734b:	b8 00 00 00 00       	mov    $0x0,%eax
f0107350:	eb 3d                	jmp    f010738f <debuginfo_eip+0x342>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd,sizeof(struct UserStabData),PTE_U)<0)return -1;
f0107352:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107357:	eb 36                	jmp    f010738f <debuginfo_eip+0x342>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
f0107359:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010735e:	eb 2f                	jmp    f010738f <debuginfo_eip+0x342>
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
f0107360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107365:	eb 28                	jmp    f010738f <debuginfo_eip+0x342>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0107367:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010736c:	eb 21                	jmp    f010738f <debuginfo_eip+0x342>
f010736e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107373:	eb 1a                	jmp    f010738f <debuginfo_eip+0x342>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0107375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010737a:	eb 13                	jmp    f010738f <debuginfo_eip+0x342>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline){
		info->eip_line = stabs[lline].n_desc;
	}
	else return -1;
f010737c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107381:	eb 0c                	jmp    f010738f <debuginfo_eip+0x342>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0107383:	b8 00 00 00 00       	mov    $0x0,%eax
f0107388:	eb 05                	jmp    f010738f <debuginfo_eip+0x342>
f010738a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010738f:	83 c4 5c             	add    $0x5c,%esp
f0107392:	5b                   	pop    %ebx
f0107393:	5e                   	pop    %esi
f0107394:	5f                   	pop    %edi
f0107395:	5d                   	pop    %ebp
f0107396:	c3                   	ret    
f0107397:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010739a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010739d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01073a0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01073a3:	8b 04 87             	mov    (%edi,%eax,4),%eax
f01073a6:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01073a9:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01073ac:	39 d0                	cmp    %edx,%eax
f01073ae:	0f 82 5f ff ff ff    	jb     f0107313 <debuginfo_eip+0x2c6>
f01073b4:	e9 64 ff ff ff       	jmp    f010731d <debuginfo_eip+0x2d0>
f01073b9:	00 00                	add    %al,(%eax)
	...

f01073bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01073bc:	55                   	push   %ebp
f01073bd:	89 e5                	mov    %esp,%ebp
f01073bf:	57                   	push   %edi
f01073c0:	56                   	push   %esi
f01073c1:	53                   	push   %ebx
f01073c2:	83 ec 3c             	sub    $0x3c,%esp
f01073c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01073c8:	89 d7                	mov    %edx,%edi
f01073ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01073cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01073d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01073d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01073d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01073d9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01073dc:	85 c0                	test   %eax,%eax
f01073de:	75 08                	jne    f01073e8 <printnum+0x2c>
f01073e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01073e3:	39 45 10             	cmp    %eax,0x10(%ebp)
f01073e6:	77 57                	ja     f010743f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01073e8:	89 74 24 10          	mov    %esi,0x10(%esp)
f01073ec:	4b                   	dec    %ebx
f01073ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01073f1:	8b 45 10             	mov    0x10(%ebp),%eax
f01073f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01073f8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01073fc:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0107400:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0107407:	00 
f0107408:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010740b:	89 04 24             	mov    %eax,(%esp)
f010740e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107411:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107415:	e8 c6 11 00 00       	call   f01085e0 <__udivdi3>
f010741a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010741e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107422:	89 04 24             	mov    %eax,(%esp)
f0107425:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107429:	89 fa                	mov    %edi,%edx
f010742b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010742e:	e8 89 ff ff ff       	call   f01073bc <printnum>
f0107433:	eb 0f                	jmp    f0107444 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0107435:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107439:	89 34 24             	mov    %esi,(%esp)
f010743c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010743f:	4b                   	dec    %ebx
f0107440:	85 db                	test   %ebx,%ebx
f0107442:	7f f1                	jg     f0107435 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0107444:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107448:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010744c:	8b 45 10             	mov    0x10(%ebp),%eax
f010744f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107453:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010745a:	00 
f010745b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010745e:	89 04 24             	mov    %eax,(%esp)
f0107461:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107464:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107468:	e8 93 12 00 00       	call   f0108700 <__umoddi3>
f010746d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107471:	0f be 80 be af 10 f0 	movsbl -0xfef5042(%eax),%eax
f0107478:	89 04 24             	mov    %eax,(%esp)
f010747b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010747e:	83 c4 3c             	add    $0x3c,%esp
f0107481:	5b                   	pop    %ebx
f0107482:	5e                   	pop    %esi
f0107483:	5f                   	pop    %edi
f0107484:	5d                   	pop    %ebp
f0107485:	c3                   	ret    

f0107486 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0107486:	55                   	push   %ebp
f0107487:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0107489:	83 fa 01             	cmp    $0x1,%edx
f010748c:	7e 0e                	jle    f010749c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010748e:	8b 10                	mov    (%eax),%edx
f0107490:	8d 4a 08             	lea    0x8(%edx),%ecx
f0107493:	89 08                	mov    %ecx,(%eax)
f0107495:	8b 02                	mov    (%edx),%eax
f0107497:	8b 52 04             	mov    0x4(%edx),%edx
f010749a:	eb 22                	jmp    f01074be <getuint+0x38>
	else if (lflag)
f010749c:	85 d2                	test   %edx,%edx
f010749e:	74 10                	je     f01074b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01074a0:	8b 10                	mov    (%eax),%edx
f01074a2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01074a5:	89 08                	mov    %ecx,(%eax)
f01074a7:	8b 02                	mov    (%edx),%eax
f01074a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01074ae:	eb 0e                	jmp    f01074be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01074b0:	8b 10                	mov    (%eax),%edx
f01074b2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01074b5:	89 08                	mov    %ecx,(%eax)
f01074b7:	8b 02                	mov    (%edx),%eax
f01074b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01074be:	5d                   	pop    %ebp
f01074bf:	c3                   	ret    

f01074c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01074c0:	55                   	push   %ebp
f01074c1:	89 e5                	mov    %esp,%ebp
f01074c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01074c6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01074c9:	8b 10                	mov    (%eax),%edx
f01074cb:	3b 50 04             	cmp    0x4(%eax),%edx
f01074ce:	73 08                	jae    f01074d8 <sprintputch+0x18>
		*b->buf++ = ch;
f01074d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01074d3:	88 0a                	mov    %cl,(%edx)
f01074d5:	42                   	inc    %edx
f01074d6:	89 10                	mov    %edx,(%eax)
}
f01074d8:	5d                   	pop    %ebp
f01074d9:	c3                   	ret    

f01074da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01074da:	55                   	push   %ebp
f01074db:	89 e5                	mov    %esp,%ebp
f01074dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01074e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01074e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01074e7:	8b 45 10             	mov    0x10(%ebp),%eax
f01074ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01074ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01074f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01074f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01074f8:	89 04 24             	mov    %eax,(%esp)
f01074fb:	e8 02 00 00 00       	call   f0107502 <vprintfmt>
	va_end(ap);
}
f0107500:	c9                   	leave  
f0107501:	c3                   	ret    

f0107502 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0107502:	55                   	push   %ebp
f0107503:	89 e5                	mov    %esp,%ebp
f0107505:	57                   	push   %edi
f0107506:	56                   	push   %esi
f0107507:	53                   	push   %ebx
f0107508:	83 ec 4c             	sub    $0x4c,%esp
f010750b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010750e:	8b 75 10             	mov    0x10(%ebp),%esi
f0107511:	eb 12                	jmp    f0107525 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0107513:	85 c0                	test   %eax,%eax
f0107515:	0f 84 6b 03 00 00    	je     f0107886 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f010751b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010751f:	89 04 24             	mov    %eax,(%esp)
f0107522:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0107525:	0f b6 06             	movzbl (%esi),%eax
f0107528:	46                   	inc    %esi
f0107529:	83 f8 25             	cmp    $0x25,%eax
f010752c:	75 e5                	jne    f0107513 <vprintfmt+0x11>
f010752e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0107532:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0107539:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010753e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0107545:	b9 00 00 00 00       	mov    $0x0,%ecx
f010754a:	eb 26                	jmp    f0107572 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010754c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010754f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0107553:	eb 1d                	jmp    f0107572 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107555:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0107558:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010755c:	eb 14                	jmp    f0107572 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010755e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0107561:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0107568:	eb 08                	jmp    f0107572 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010756a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010756d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107572:	0f b6 06             	movzbl (%esi),%eax
f0107575:	8d 56 01             	lea    0x1(%esi),%edx
f0107578:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010757b:	8a 16                	mov    (%esi),%dl
f010757d:	83 ea 23             	sub    $0x23,%edx
f0107580:	80 fa 55             	cmp    $0x55,%dl
f0107583:	0f 87 e1 02 00 00    	ja     f010786a <vprintfmt+0x368>
f0107589:	0f b6 d2             	movzbl %dl,%edx
f010758c:	ff 24 95 80 b0 10 f0 	jmp    *-0xfef4f80(,%edx,4)
f0107593:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0107596:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010759b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010759e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01075a2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01075a5:	8d 50 d0             	lea    -0x30(%eax),%edx
f01075a8:	83 fa 09             	cmp    $0x9,%edx
f01075ab:	77 2a                	ja     f01075d7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01075ad:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01075ae:	eb eb                	jmp    f010759b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01075b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01075b3:	8d 50 04             	lea    0x4(%eax),%edx
f01075b6:	89 55 14             	mov    %edx,0x14(%ebp)
f01075b9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01075bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01075be:	eb 17                	jmp    f01075d7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f01075c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01075c4:	78 98                	js     f010755e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01075c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01075c9:	eb a7                	jmp    f0107572 <vprintfmt+0x70>
f01075cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01075ce:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01075d5:	eb 9b                	jmp    f0107572 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f01075d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01075db:	79 95                	jns    f0107572 <vprintfmt+0x70>
f01075dd:	eb 8b                	jmp    f010756a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01075df:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01075e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01075e3:	eb 8d                	jmp    f0107572 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01075e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01075e8:	8d 50 04             	lea    0x4(%eax),%edx
f01075eb:	89 55 14             	mov    %edx,0x14(%ebp)
f01075ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01075f2:	8b 00                	mov    (%eax),%eax
f01075f4:	89 04 24             	mov    %eax,(%esp)
f01075f7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01075fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01075fd:	e9 23 ff ff ff       	jmp    f0107525 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0107602:	8b 45 14             	mov    0x14(%ebp),%eax
f0107605:	8d 50 04             	lea    0x4(%eax),%edx
f0107608:	89 55 14             	mov    %edx,0x14(%ebp)
f010760b:	8b 00                	mov    (%eax),%eax
f010760d:	85 c0                	test   %eax,%eax
f010760f:	79 02                	jns    f0107613 <vprintfmt+0x111>
f0107611:	f7 d8                	neg    %eax
f0107613:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0107615:	83 f8 08             	cmp    $0x8,%eax
f0107618:	7f 0b                	jg     f0107625 <vprintfmt+0x123>
f010761a:	8b 04 85 e0 b1 10 f0 	mov    -0xfef4e20(,%eax,4),%eax
f0107621:	85 c0                	test   %eax,%eax
f0107623:	75 23                	jne    f0107648 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0107625:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107629:	c7 44 24 08 d6 af 10 	movl   $0xf010afd6,0x8(%esp)
f0107630:	f0 
f0107631:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107635:	8b 45 08             	mov    0x8(%ebp),%eax
f0107638:	89 04 24             	mov    %eax,(%esp)
f010763b:	e8 9a fe ff ff       	call   f01074da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107640:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0107643:	e9 dd fe ff ff       	jmp    f0107525 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0107648:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010764c:	c7 44 24 08 bb a6 10 	movl   $0xf010a6bb,0x8(%esp)
f0107653:	f0 
f0107654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0107658:	8b 55 08             	mov    0x8(%ebp),%edx
f010765b:	89 14 24             	mov    %edx,(%esp)
f010765e:	e8 77 fe ff ff       	call   f01074da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107663:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0107666:	e9 ba fe ff ff       	jmp    f0107525 <vprintfmt+0x23>
f010766b:	89 f9                	mov    %edi,%ecx
f010766d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107670:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0107673:	8b 45 14             	mov    0x14(%ebp),%eax
f0107676:	8d 50 04             	lea    0x4(%eax),%edx
f0107679:	89 55 14             	mov    %edx,0x14(%ebp)
f010767c:	8b 30                	mov    (%eax),%esi
f010767e:	85 f6                	test   %esi,%esi
f0107680:	75 05                	jne    f0107687 <vprintfmt+0x185>
				p = "(null)";
f0107682:	be cf af 10 f0       	mov    $0xf010afcf,%esi
			if (width > 0 && padc != '-')
f0107687:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010768b:	0f 8e 84 00 00 00    	jle    f0107715 <vprintfmt+0x213>
f0107691:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0107695:	74 7e                	je     f0107715 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0107697:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010769b:	89 34 24             	mov    %esi,(%esp)
f010769e:	e8 53 03 00 00       	call   f01079f6 <strnlen>
f01076a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01076a6:	29 c2                	sub    %eax,%edx
f01076a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f01076ab:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01076af:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01076b2:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01076b5:	89 de                	mov    %ebx,%esi
f01076b7:	89 d3                	mov    %edx,%ebx
f01076b9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01076bb:	eb 0b                	jmp    f01076c8 <vprintfmt+0x1c6>
					putch(padc, putdat);
f01076bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01076c1:	89 3c 24             	mov    %edi,(%esp)
f01076c4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01076c7:	4b                   	dec    %ebx
f01076c8:	85 db                	test   %ebx,%ebx
f01076ca:	7f f1                	jg     f01076bd <vprintfmt+0x1bb>
f01076cc:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01076cf:	89 f3                	mov    %esi,%ebx
f01076d1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f01076d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01076d7:	85 c0                	test   %eax,%eax
f01076d9:	79 05                	jns    f01076e0 <vprintfmt+0x1de>
f01076db:	b8 00 00 00 00       	mov    $0x0,%eax
f01076e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01076e3:	29 c2                	sub    %eax,%edx
f01076e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01076e8:	eb 2b                	jmp    f0107715 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01076ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01076ee:	74 18                	je     f0107708 <vprintfmt+0x206>
f01076f0:	8d 50 e0             	lea    -0x20(%eax),%edx
f01076f3:	83 fa 5e             	cmp    $0x5e,%edx
f01076f6:	76 10                	jbe    f0107708 <vprintfmt+0x206>
					putch('?', putdat);
f01076f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01076fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0107703:	ff 55 08             	call   *0x8(%ebp)
f0107706:	eb 0a                	jmp    f0107712 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0107708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010770c:	89 04 24             	mov    %eax,(%esp)
f010770f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0107712:	ff 4d e4             	decl   -0x1c(%ebp)
f0107715:	0f be 06             	movsbl (%esi),%eax
f0107718:	46                   	inc    %esi
f0107719:	85 c0                	test   %eax,%eax
f010771b:	74 21                	je     f010773e <vprintfmt+0x23c>
f010771d:	85 ff                	test   %edi,%edi
f010771f:	78 c9                	js     f01076ea <vprintfmt+0x1e8>
f0107721:	4f                   	dec    %edi
f0107722:	79 c6                	jns    f01076ea <vprintfmt+0x1e8>
f0107724:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107727:	89 de                	mov    %ebx,%esi
f0107729:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010772c:	eb 18                	jmp    f0107746 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010772e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107732:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0107739:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010773b:	4b                   	dec    %ebx
f010773c:	eb 08                	jmp    f0107746 <vprintfmt+0x244>
f010773e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107741:	89 de                	mov    %ebx,%esi
f0107743:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0107746:	85 db                	test   %ebx,%ebx
f0107748:	7f e4                	jg     f010772e <vprintfmt+0x22c>
f010774a:	89 7d 08             	mov    %edi,0x8(%ebp)
f010774d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010774f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0107752:	e9 ce fd ff ff       	jmp    f0107525 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0107757:	83 f9 01             	cmp    $0x1,%ecx
f010775a:	7e 10                	jle    f010776c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f010775c:	8b 45 14             	mov    0x14(%ebp),%eax
f010775f:	8d 50 08             	lea    0x8(%eax),%edx
f0107762:	89 55 14             	mov    %edx,0x14(%ebp)
f0107765:	8b 30                	mov    (%eax),%esi
f0107767:	8b 78 04             	mov    0x4(%eax),%edi
f010776a:	eb 26                	jmp    f0107792 <vprintfmt+0x290>
	else if (lflag)
f010776c:	85 c9                	test   %ecx,%ecx
f010776e:	74 12                	je     f0107782 <vprintfmt+0x280>
		return va_arg(*ap, long);
f0107770:	8b 45 14             	mov    0x14(%ebp),%eax
f0107773:	8d 50 04             	lea    0x4(%eax),%edx
f0107776:	89 55 14             	mov    %edx,0x14(%ebp)
f0107779:	8b 30                	mov    (%eax),%esi
f010777b:	89 f7                	mov    %esi,%edi
f010777d:	c1 ff 1f             	sar    $0x1f,%edi
f0107780:	eb 10                	jmp    f0107792 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0107782:	8b 45 14             	mov    0x14(%ebp),%eax
f0107785:	8d 50 04             	lea    0x4(%eax),%edx
f0107788:	89 55 14             	mov    %edx,0x14(%ebp)
f010778b:	8b 30                	mov    (%eax),%esi
f010778d:	89 f7                	mov    %esi,%edi
f010778f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0107792:	85 ff                	test   %edi,%edi
f0107794:	78 0a                	js     f01077a0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0107796:	b8 0a 00 00 00       	mov    $0xa,%eax
f010779b:	e9 8c 00 00 00       	jmp    f010782c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01077a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01077a4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01077ab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01077ae:	f7 de                	neg    %esi
f01077b0:	83 d7 00             	adc    $0x0,%edi
f01077b3:	f7 df                	neg    %edi
			}
			base = 10;
f01077b5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01077ba:	eb 70                	jmp    f010782c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01077bc:	89 ca                	mov    %ecx,%edx
f01077be:	8d 45 14             	lea    0x14(%ebp),%eax
f01077c1:	e8 c0 fc ff ff       	call   f0107486 <getuint>
f01077c6:	89 c6                	mov    %eax,%esi
f01077c8:	89 d7                	mov    %edx,%edi
			base = 10;
f01077ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01077cf:	eb 5b                	jmp    f010782c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f01077d1:	89 ca                	mov    %ecx,%edx
f01077d3:	8d 45 14             	lea    0x14(%ebp),%eax
f01077d6:	e8 ab fc ff ff       	call   f0107486 <getuint>
f01077db:	89 c6                	mov    %eax,%esi
f01077dd:	89 d7                	mov    %edx,%edi
			base = 8;
f01077df:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01077e4:	eb 46                	jmp    f010782c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01077e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01077ea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01077f1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01077f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01077f8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01077ff:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0107802:	8b 45 14             	mov    0x14(%ebp),%eax
f0107805:	8d 50 04             	lea    0x4(%eax),%edx
f0107808:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010780b:	8b 30                	mov    (%eax),%esi
f010780d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0107812:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0107817:	eb 13                	jmp    f010782c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0107819:	89 ca                	mov    %ecx,%edx
f010781b:	8d 45 14             	lea    0x14(%ebp),%eax
f010781e:	e8 63 fc ff ff       	call   f0107486 <getuint>
f0107823:	89 c6                	mov    %eax,%esi
f0107825:	89 d7                	mov    %edx,%edi
			base = 16;
f0107827:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010782c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0107830:	89 54 24 10          	mov    %edx,0x10(%esp)
f0107834:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107837:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010783b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010783f:	89 34 24             	mov    %esi,(%esp)
f0107842:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107846:	89 da                	mov    %ebx,%edx
f0107848:	8b 45 08             	mov    0x8(%ebp),%eax
f010784b:	e8 6c fb ff ff       	call   f01073bc <printnum>
			break;
f0107850:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0107853:	e9 cd fc ff ff       	jmp    f0107525 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0107858:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010785c:	89 04 24             	mov    %eax,(%esp)
f010785f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107862:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0107865:	e9 bb fc ff ff       	jmp    f0107525 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010786a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010786e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0107875:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0107878:	eb 01                	jmp    f010787b <vprintfmt+0x379>
f010787a:	4e                   	dec    %esi
f010787b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010787f:	75 f9                	jne    f010787a <vprintfmt+0x378>
f0107881:	e9 9f fc ff ff       	jmp    f0107525 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0107886:	83 c4 4c             	add    $0x4c,%esp
f0107889:	5b                   	pop    %ebx
f010788a:	5e                   	pop    %esi
f010788b:	5f                   	pop    %edi
f010788c:	5d                   	pop    %ebp
f010788d:	c3                   	ret    

f010788e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010788e:	55                   	push   %ebp
f010788f:	89 e5                	mov    %esp,%ebp
f0107891:	83 ec 28             	sub    $0x28,%esp
f0107894:	8b 45 08             	mov    0x8(%ebp),%eax
f0107897:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010789a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010789d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01078a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01078a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01078ab:	85 c0                	test   %eax,%eax
f01078ad:	74 30                	je     f01078df <vsnprintf+0x51>
f01078af:	85 d2                	test   %edx,%edx
f01078b1:	7e 33                	jle    f01078e6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01078b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01078b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01078ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01078bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01078c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01078c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01078c8:	c7 04 24 c0 74 10 f0 	movl   $0xf01074c0,(%esp)
f01078cf:	e8 2e fc ff ff       	call   f0107502 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01078d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01078d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01078da:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01078dd:	eb 0c                	jmp    f01078eb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01078df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01078e4:	eb 05                	jmp    f01078eb <vsnprintf+0x5d>
f01078e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01078eb:	c9                   	leave  
f01078ec:	c3                   	ret    

f01078ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01078ed:	55                   	push   %ebp
f01078ee:	89 e5                	mov    %esp,%ebp
f01078f0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01078f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01078f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01078fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01078fd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107901:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107904:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107908:	8b 45 08             	mov    0x8(%ebp),%eax
f010790b:	89 04 24             	mov    %eax,(%esp)
f010790e:	e8 7b ff ff ff       	call   f010788e <vsnprintf>
	va_end(ap);

	return rc;
}
f0107913:	c9                   	leave  
f0107914:	c3                   	ret    
f0107915:	00 00                	add    %al,(%eax)
	...

f0107918 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0107918:	55                   	push   %ebp
f0107919:	89 e5                	mov    %esp,%ebp
f010791b:	57                   	push   %edi
f010791c:	56                   	push   %esi
f010791d:	53                   	push   %ebx
f010791e:	83 ec 1c             	sub    $0x1c,%esp
f0107921:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0107924:	85 c0                	test   %eax,%eax
f0107926:	74 10                	je     f0107938 <readline+0x20>
		cprintf("%s", prompt);
f0107928:	89 44 24 04          	mov    %eax,0x4(%esp)
f010792c:	c7 04 24 bb a6 10 f0 	movl   $0xf010a6bb,(%esp)
f0107933:	e8 b6 de ff ff       	call   f01057ee <cprintf>

	i = 0;
	echoing = iscons(0);
f0107938:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010793f:	e8 1d 91 ff ff       	call   f0100a61 <iscons>
f0107944:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0107946:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010794b:	e8 00 91 ff ff       	call   f0100a50 <getchar>
f0107950:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0107952:	85 c0                	test   %eax,%eax
f0107954:	79 17                	jns    f010796d <readline+0x55>
			cprintf("read error: %e\n", c);
f0107956:	89 44 24 04          	mov    %eax,0x4(%esp)
f010795a:	c7 04 24 04 b2 10 f0 	movl   $0xf010b204,(%esp)
f0107961:	e8 88 de ff ff       	call   f01057ee <cprintf>
			return NULL;
f0107966:	b8 00 00 00 00       	mov    $0x0,%eax
f010796b:	eb 69                	jmp    f01079d6 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010796d:	83 f8 08             	cmp    $0x8,%eax
f0107970:	74 05                	je     f0107977 <readline+0x5f>
f0107972:	83 f8 7f             	cmp    $0x7f,%eax
f0107975:	75 17                	jne    f010798e <readline+0x76>
f0107977:	85 f6                	test   %esi,%esi
f0107979:	7e 13                	jle    f010798e <readline+0x76>
			if (echoing)
f010797b:	85 ff                	test   %edi,%edi
f010797d:	74 0c                	je     f010798b <readline+0x73>
				cputchar('\b');
f010797f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0107986:	e8 b5 90 ff ff       	call   f0100a40 <cputchar>
			i--;
f010798b:	4e                   	dec    %esi
f010798c:	eb bd                	jmp    f010794b <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010798e:	83 fb 1f             	cmp    $0x1f,%ebx
f0107991:	7e 1d                	jle    f01079b0 <readline+0x98>
f0107993:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0107999:	7f 15                	jg     f01079b0 <readline+0x98>
			if (echoing)
f010799b:	85 ff                	test   %edi,%edi
f010799d:	74 08                	je     f01079a7 <readline+0x8f>
				cputchar(c);
f010799f:	89 1c 24             	mov    %ebx,(%esp)
f01079a2:	e8 99 90 ff ff       	call   f0100a40 <cputchar>
			buf[i++] = c;
f01079a7:	88 9e 80 6a 35 f0    	mov    %bl,-0xfca9580(%esi)
f01079ad:	46                   	inc    %esi
f01079ae:	eb 9b                	jmp    f010794b <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01079b0:	83 fb 0a             	cmp    $0xa,%ebx
f01079b3:	74 05                	je     f01079ba <readline+0xa2>
f01079b5:	83 fb 0d             	cmp    $0xd,%ebx
f01079b8:	75 91                	jne    f010794b <readline+0x33>
			if (echoing)
f01079ba:	85 ff                	test   %edi,%edi
f01079bc:	74 0c                	je     f01079ca <readline+0xb2>
				cputchar('\n');
f01079be:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01079c5:	e8 76 90 ff ff       	call   f0100a40 <cputchar>
			buf[i] = 0;
f01079ca:	c6 86 80 6a 35 f0 00 	movb   $0x0,-0xfca9580(%esi)
			return buf;
f01079d1:	b8 80 6a 35 f0       	mov    $0xf0356a80,%eax
		}
	}
}
f01079d6:	83 c4 1c             	add    $0x1c,%esp
f01079d9:	5b                   	pop    %ebx
f01079da:	5e                   	pop    %esi
f01079db:	5f                   	pop    %edi
f01079dc:	5d                   	pop    %ebp
f01079dd:	c3                   	ret    
	...

f01079e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01079e0:	55                   	push   %ebp
f01079e1:	89 e5                	mov    %esp,%ebp
f01079e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01079e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01079eb:	eb 01                	jmp    f01079ee <strlen+0xe>
		n++;
f01079ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01079ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01079f2:	75 f9                	jne    f01079ed <strlen+0xd>
		n++;
	return n;
}
f01079f4:	5d                   	pop    %ebp
f01079f5:	c3                   	ret    

f01079f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01079f6:	55                   	push   %ebp
f01079f7:	89 e5                	mov    %esp,%ebp
f01079f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01079fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01079ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0107a04:	eb 01                	jmp    f0107a07 <strnlen+0x11>
		n++;
f0107a06:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107a07:	39 d0                	cmp    %edx,%eax
f0107a09:	74 06                	je     f0107a11 <strnlen+0x1b>
f0107a0b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0107a0f:	75 f5                	jne    f0107a06 <strnlen+0x10>
		n++;
	return n;
}
f0107a11:	5d                   	pop    %ebp
f0107a12:	c3                   	ret    

f0107a13 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0107a13:	55                   	push   %ebp
f0107a14:	89 e5                	mov    %esp,%ebp
f0107a16:	53                   	push   %ebx
f0107a17:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0107a1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0107a22:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0107a25:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0107a28:	42                   	inc    %edx
f0107a29:	84 c9                	test   %cl,%cl
f0107a2b:	75 f5                	jne    f0107a22 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0107a2d:	5b                   	pop    %ebx
f0107a2e:	5d                   	pop    %ebp
f0107a2f:	c3                   	ret    

f0107a30 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0107a30:	55                   	push   %ebp
f0107a31:	89 e5                	mov    %esp,%ebp
f0107a33:	53                   	push   %ebx
f0107a34:	83 ec 08             	sub    $0x8,%esp
f0107a37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0107a3a:	89 1c 24             	mov    %ebx,(%esp)
f0107a3d:	e8 9e ff ff ff       	call   f01079e0 <strlen>
	strcpy(dst + len, src);
f0107a42:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107a45:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a49:	01 d8                	add    %ebx,%eax
f0107a4b:	89 04 24             	mov    %eax,(%esp)
f0107a4e:	e8 c0 ff ff ff       	call   f0107a13 <strcpy>
	return dst;
}
f0107a53:	89 d8                	mov    %ebx,%eax
f0107a55:	83 c4 08             	add    $0x8,%esp
f0107a58:	5b                   	pop    %ebx
f0107a59:	5d                   	pop    %ebp
f0107a5a:	c3                   	ret    

f0107a5b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0107a5b:	55                   	push   %ebp
f0107a5c:	89 e5                	mov    %esp,%ebp
f0107a5e:	56                   	push   %esi
f0107a5f:	53                   	push   %ebx
f0107a60:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a63:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107a66:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0107a69:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107a6e:	eb 0c                	jmp    f0107a7c <strncpy+0x21>
		*dst++ = *src;
f0107a70:	8a 1a                	mov    (%edx),%bl
f0107a72:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0107a75:	80 3a 01             	cmpb   $0x1,(%edx)
f0107a78:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0107a7b:	41                   	inc    %ecx
f0107a7c:	39 f1                	cmp    %esi,%ecx
f0107a7e:	75 f0                	jne    f0107a70 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0107a80:	5b                   	pop    %ebx
f0107a81:	5e                   	pop    %esi
f0107a82:	5d                   	pop    %ebp
f0107a83:	c3                   	ret    

f0107a84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0107a84:	55                   	push   %ebp
f0107a85:	89 e5                	mov    %esp,%ebp
f0107a87:	56                   	push   %esi
f0107a88:	53                   	push   %ebx
f0107a89:	8b 75 08             	mov    0x8(%ebp),%esi
f0107a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0107a8f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0107a92:	85 d2                	test   %edx,%edx
f0107a94:	75 0a                	jne    f0107aa0 <strlcpy+0x1c>
f0107a96:	89 f0                	mov    %esi,%eax
f0107a98:	eb 1a                	jmp    f0107ab4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0107a9a:	88 18                	mov    %bl,(%eax)
f0107a9c:	40                   	inc    %eax
f0107a9d:	41                   	inc    %ecx
f0107a9e:	eb 02                	jmp    f0107aa2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0107aa0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0107aa2:	4a                   	dec    %edx
f0107aa3:	74 0a                	je     f0107aaf <strlcpy+0x2b>
f0107aa5:	8a 19                	mov    (%ecx),%bl
f0107aa7:	84 db                	test   %bl,%bl
f0107aa9:	75 ef                	jne    f0107a9a <strlcpy+0x16>
f0107aab:	89 c2                	mov    %eax,%edx
f0107aad:	eb 02                	jmp    f0107ab1 <strlcpy+0x2d>
f0107aaf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0107ab1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0107ab4:	29 f0                	sub    %esi,%eax
}
f0107ab6:	5b                   	pop    %ebx
f0107ab7:	5e                   	pop    %esi
f0107ab8:	5d                   	pop    %ebp
f0107ab9:	c3                   	ret    

f0107aba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0107aba:	55                   	push   %ebp
f0107abb:	89 e5                	mov    %esp,%ebp
f0107abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0107ac3:	eb 02                	jmp    f0107ac7 <strcmp+0xd>
		p++, q++;
f0107ac5:	41                   	inc    %ecx
f0107ac6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0107ac7:	8a 01                	mov    (%ecx),%al
f0107ac9:	84 c0                	test   %al,%al
f0107acb:	74 04                	je     f0107ad1 <strcmp+0x17>
f0107acd:	3a 02                	cmp    (%edx),%al
f0107acf:	74 f4                	je     f0107ac5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0107ad1:	0f b6 c0             	movzbl %al,%eax
f0107ad4:	0f b6 12             	movzbl (%edx),%edx
f0107ad7:	29 d0                	sub    %edx,%eax
}
f0107ad9:	5d                   	pop    %ebp
f0107ada:	c3                   	ret    

f0107adb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0107adb:	55                   	push   %ebp
f0107adc:	89 e5                	mov    %esp,%ebp
f0107ade:	53                   	push   %ebx
f0107adf:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0107ae5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0107ae8:	eb 03                	jmp    f0107aed <strncmp+0x12>
		n--, p++, q++;
f0107aea:	4a                   	dec    %edx
f0107aeb:	40                   	inc    %eax
f0107aec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0107aed:	85 d2                	test   %edx,%edx
f0107aef:	74 14                	je     f0107b05 <strncmp+0x2a>
f0107af1:	8a 18                	mov    (%eax),%bl
f0107af3:	84 db                	test   %bl,%bl
f0107af5:	74 04                	je     f0107afb <strncmp+0x20>
f0107af7:	3a 19                	cmp    (%ecx),%bl
f0107af9:	74 ef                	je     f0107aea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0107afb:	0f b6 00             	movzbl (%eax),%eax
f0107afe:	0f b6 11             	movzbl (%ecx),%edx
f0107b01:	29 d0                	sub    %edx,%eax
f0107b03:	eb 05                	jmp    f0107b0a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0107b05:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0107b0a:	5b                   	pop    %ebx
f0107b0b:	5d                   	pop    %ebp
f0107b0c:	c3                   	ret    

f0107b0d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0107b0d:	55                   	push   %ebp
f0107b0e:	89 e5                	mov    %esp,%ebp
f0107b10:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b13:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0107b16:	eb 05                	jmp    f0107b1d <strchr+0x10>
		if (*s == c)
f0107b18:	38 ca                	cmp    %cl,%dl
f0107b1a:	74 0c                	je     f0107b28 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0107b1c:	40                   	inc    %eax
f0107b1d:	8a 10                	mov    (%eax),%dl
f0107b1f:	84 d2                	test   %dl,%dl
f0107b21:	75 f5                	jne    f0107b18 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0107b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107b28:	5d                   	pop    %ebp
f0107b29:	c3                   	ret    

f0107b2a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0107b2a:	55                   	push   %ebp
f0107b2b:	89 e5                	mov    %esp,%ebp
f0107b2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b30:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0107b33:	eb 05                	jmp    f0107b3a <strfind+0x10>
		if (*s == c)
f0107b35:	38 ca                	cmp    %cl,%dl
f0107b37:	74 07                	je     f0107b40 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0107b39:	40                   	inc    %eax
f0107b3a:	8a 10                	mov    (%eax),%dl
f0107b3c:	84 d2                	test   %dl,%dl
f0107b3e:	75 f5                	jne    f0107b35 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0107b40:	5d                   	pop    %ebp
f0107b41:	c3                   	ret    

f0107b42 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0107b42:	55                   	push   %ebp
f0107b43:	89 e5                	mov    %esp,%ebp
f0107b45:	57                   	push   %edi
f0107b46:	56                   	push   %esi
f0107b47:	53                   	push   %ebx
f0107b48:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0107b51:	85 c9                	test   %ecx,%ecx
f0107b53:	74 30                	je     f0107b85 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0107b55:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0107b5b:	75 25                	jne    f0107b82 <memset+0x40>
f0107b5d:	f6 c1 03             	test   $0x3,%cl
f0107b60:	75 20                	jne    f0107b82 <memset+0x40>
		c &= 0xFF;
f0107b62:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0107b65:	89 d3                	mov    %edx,%ebx
f0107b67:	c1 e3 08             	shl    $0x8,%ebx
f0107b6a:	89 d6                	mov    %edx,%esi
f0107b6c:	c1 e6 18             	shl    $0x18,%esi
f0107b6f:	89 d0                	mov    %edx,%eax
f0107b71:	c1 e0 10             	shl    $0x10,%eax
f0107b74:	09 f0                	or     %esi,%eax
f0107b76:	09 d0                	or     %edx,%eax
f0107b78:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0107b7a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0107b7d:	fc                   	cld    
f0107b7e:	f3 ab                	rep stos %eax,%es:(%edi)
f0107b80:	eb 03                	jmp    f0107b85 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0107b82:	fc                   	cld    
f0107b83:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0107b85:	89 f8                	mov    %edi,%eax
f0107b87:	5b                   	pop    %ebx
f0107b88:	5e                   	pop    %esi
f0107b89:	5f                   	pop    %edi
f0107b8a:	5d                   	pop    %ebp
f0107b8b:	c3                   	ret    

f0107b8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0107b8c:	55                   	push   %ebp
f0107b8d:	89 e5                	mov    %esp,%ebp
f0107b8f:	57                   	push   %edi
f0107b90:	56                   	push   %esi
f0107b91:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b94:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107b97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0107b9a:	39 c6                	cmp    %eax,%esi
f0107b9c:	73 34                	jae    f0107bd2 <memmove+0x46>
f0107b9e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0107ba1:	39 d0                	cmp    %edx,%eax
f0107ba3:	73 2d                	jae    f0107bd2 <memmove+0x46>
		s += n;
		d += n;
f0107ba5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107ba8:	f6 c2 03             	test   $0x3,%dl
f0107bab:	75 1b                	jne    f0107bc8 <memmove+0x3c>
f0107bad:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0107bb3:	75 13                	jne    f0107bc8 <memmove+0x3c>
f0107bb5:	f6 c1 03             	test   $0x3,%cl
f0107bb8:	75 0e                	jne    f0107bc8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0107bba:	83 ef 04             	sub    $0x4,%edi
f0107bbd:	8d 72 fc             	lea    -0x4(%edx),%esi
f0107bc0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0107bc3:	fd                   	std    
f0107bc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107bc6:	eb 07                	jmp    f0107bcf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0107bc8:	4f                   	dec    %edi
f0107bc9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0107bcc:	fd                   	std    
f0107bcd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0107bcf:	fc                   	cld    
f0107bd0:	eb 20                	jmp    f0107bf2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0107bd2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0107bd8:	75 13                	jne    f0107bed <memmove+0x61>
f0107bda:	a8 03                	test   $0x3,%al
f0107bdc:	75 0f                	jne    f0107bed <memmove+0x61>
f0107bde:	f6 c1 03             	test   $0x3,%cl
f0107be1:	75 0a                	jne    f0107bed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0107be3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0107be6:	89 c7                	mov    %eax,%edi
f0107be8:	fc                   	cld    
f0107be9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0107beb:	eb 05                	jmp    f0107bf2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0107bed:	89 c7                	mov    %eax,%edi
f0107bef:	fc                   	cld    
f0107bf0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0107bf2:	5e                   	pop    %esi
f0107bf3:	5f                   	pop    %edi
f0107bf4:	5d                   	pop    %ebp
f0107bf5:	c3                   	ret    

f0107bf6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0107bf6:	55                   	push   %ebp
f0107bf7:	89 e5                	mov    %esp,%ebp
f0107bf9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0107bfc:	8b 45 10             	mov    0x10(%ebp),%eax
f0107bff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107c03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c0d:	89 04 24             	mov    %eax,(%esp)
f0107c10:	e8 77 ff ff ff       	call   f0107b8c <memmove>
}
f0107c15:	c9                   	leave  
f0107c16:	c3                   	ret    

f0107c17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0107c17:	55                   	push   %ebp
f0107c18:	89 e5                	mov    %esp,%ebp
f0107c1a:	57                   	push   %edi
f0107c1b:	56                   	push   %esi
f0107c1c:	53                   	push   %ebx
f0107c1d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0107c20:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107c26:	ba 00 00 00 00       	mov    $0x0,%edx
f0107c2b:	eb 16                	jmp    f0107c43 <memcmp+0x2c>
		if (*s1 != *s2)
f0107c2d:	8a 04 17             	mov    (%edi,%edx,1),%al
f0107c30:	42                   	inc    %edx
f0107c31:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0107c35:	38 c8                	cmp    %cl,%al
f0107c37:	74 0a                	je     f0107c43 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0107c39:	0f b6 c0             	movzbl %al,%eax
f0107c3c:	0f b6 c9             	movzbl %cl,%ecx
f0107c3f:	29 c8                	sub    %ecx,%eax
f0107c41:	eb 09                	jmp    f0107c4c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0107c43:	39 da                	cmp    %ebx,%edx
f0107c45:	75 e6                	jne    f0107c2d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0107c47:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107c4c:	5b                   	pop    %ebx
f0107c4d:	5e                   	pop    %esi
f0107c4e:	5f                   	pop    %edi
f0107c4f:	5d                   	pop    %ebp
f0107c50:	c3                   	ret    

f0107c51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0107c51:	55                   	push   %ebp
f0107c52:	89 e5                	mov    %esp,%ebp
f0107c54:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0107c5a:	89 c2                	mov    %eax,%edx
f0107c5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0107c5f:	eb 05                	jmp    f0107c66 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0107c61:	38 08                	cmp    %cl,(%eax)
f0107c63:	74 05                	je     f0107c6a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0107c65:	40                   	inc    %eax
f0107c66:	39 d0                	cmp    %edx,%eax
f0107c68:	72 f7                	jb     f0107c61 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0107c6a:	5d                   	pop    %ebp
f0107c6b:	c3                   	ret    

f0107c6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0107c6c:	55                   	push   %ebp
f0107c6d:	89 e5                	mov    %esp,%ebp
f0107c6f:	57                   	push   %edi
f0107c70:	56                   	push   %esi
f0107c71:	53                   	push   %ebx
f0107c72:	8b 55 08             	mov    0x8(%ebp),%edx
f0107c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107c78:	eb 01                	jmp    f0107c7b <strtol+0xf>
		s++;
f0107c7a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0107c7b:	8a 02                	mov    (%edx),%al
f0107c7d:	3c 20                	cmp    $0x20,%al
f0107c7f:	74 f9                	je     f0107c7a <strtol+0xe>
f0107c81:	3c 09                	cmp    $0x9,%al
f0107c83:	74 f5                	je     f0107c7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0107c85:	3c 2b                	cmp    $0x2b,%al
f0107c87:	75 08                	jne    f0107c91 <strtol+0x25>
		s++;
f0107c89:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0107c8a:	bf 00 00 00 00       	mov    $0x0,%edi
f0107c8f:	eb 13                	jmp    f0107ca4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0107c91:	3c 2d                	cmp    $0x2d,%al
f0107c93:	75 0a                	jne    f0107c9f <strtol+0x33>
		s++, neg = 1;
f0107c95:	8d 52 01             	lea    0x1(%edx),%edx
f0107c98:	bf 01 00 00 00       	mov    $0x1,%edi
f0107c9d:	eb 05                	jmp    f0107ca4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0107c9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0107ca4:	85 db                	test   %ebx,%ebx
f0107ca6:	74 05                	je     f0107cad <strtol+0x41>
f0107ca8:	83 fb 10             	cmp    $0x10,%ebx
f0107cab:	75 28                	jne    f0107cd5 <strtol+0x69>
f0107cad:	8a 02                	mov    (%edx),%al
f0107caf:	3c 30                	cmp    $0x30,%al
f0107cb1:	75 10                	jne    f0107cc3 <strtol+0x57>
f0107cb3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0107cb7:	75 0a                	jne    f0107cc3 <strtol+0x57>
		s += 2, base = 16;
f0107cb9:	83 c2 02             	add    $0x2,%edx
f0107cbc:	bb 10 00 00 00       	mov    $0x10,%ebx
f0107cc1:	eb 12                	jmp    f0107cd5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0107cc3:	85 db                	test   %ebx,%ebx
f0107cc5:	75 0e                	jne    f0107cd5 <strtol+0x69>
f0107cc7:	3c 30                	cmp    $0x30,%al
f0107cc9:	75 05                	jne    f0107cd0 <strtol+0x64>
		s++, base = 8;
f0107ccb:	42                   	inc    %edx
f0107ccc:	b3 08                	mov    $0x8,%bl
f0107cce:	eb 05                	jmp    f0107cd5 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0107cd0:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0107cd5:	b8 00 00 00 00       	mov    $0x0,%eax
f0107cda:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0107cdc:	8a 0a                	mov    (%edx),%cl
f0107cde:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0107ce1:	80 fb 09             	cmp    $0x9,%bl
f0107ce4:	77 08                	ja     f0107cee <strtol+0x82>
			dig = *s - '0';
f0107ce6:	0f be c9             	movsbl %cl,%ecx
f0107ce9:	83 e9 30             	sub    $0x30,%ecx
f0107cec:	eb 1e                	jmp    f0107d0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0107cee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0107cf1:	80 fb 19             	cmp    $0x19,%bl
f0107cf4:	77 08                	ja     f0107cfe <strtol+0x92>
			dig = *s - 'a' + 10;
f0107cf6:	0f be c9             	movsbl %cl,%ecx
f0107cf9:	83 e9 57             	sub    $0x57,%ecx
f0107cfc:	eb 0e                	jmp    f0107d0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0107cfe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0107d01:	80 fb 19             	cmp    $0x19,%bl
f0107d04:	77 12                	ja     f0107d18 <strtol+0xac>
			dig = *s - 'A' + 10;
f0107d06:	0f be c9             	movsbl %cl,%ecx
f0107d09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0107d0c:	39 f1                	cmp    %esi,%ecx
f0107d0e:	7d 0c                	jge    f0107d1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0107d10:	42                   	inc    %edx
f0107d11:	0f af c6             	imul   %esi,%eax
f0107d14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0107d16:	eb c4                	jmp    f0107cdc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0107d18:	89 c1                	mov    %eax,%ecx
f0107d1a:	eb 02                	jmp    f0107d1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0107d1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0107d1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107d22:	74 05                	je     f0107d29 <strtol+0xbd>
		*endptr = (char *) s;
f0107d24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0107d27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0107d29:	85 ff                	test   %edi,%edi
f0107d2b:	74 04                	je     f0107d31 <strtol+0xc5>
f0107d2d:	89 c8                	mov    %ecx,%eax
f0107d2f:	f7 d8                	neg    %eax
}
f0107d31:	5b                   	pop    %ebx
f0107d32:	5e                   	pop    %esi
f0107d33:	5f                   	pop    %edi
f0107d34:	5d                   	pop    %ebp
f0107d35:	c3                   	ret    
	...

f0107d38 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0107d38:	fa                   	cli    

	xorw    %ax, %ax
f0107d39:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0107d3b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107d3d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107d3f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0107d41:	0f 01 16             	lgdtl  (%esi)
f0107d44:	74 70                	je     f0107db6 <sum+0x2>
	movl    %cr0, %eax
f0107d46:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0107d49:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0107d4d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0107d50:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0107d56:	08 00                	or     %al,(%eax)

f0107d58 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0107d58:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0107d5c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0107d5e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0107d60:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0107d62:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0107d66:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0107d68:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0107d6a:	b8 00 c0 12 00       	mov    $0x12c000,%eax
	movl    %eax, %cr3
f0107d6f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0107d72:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0107d75:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0107d7a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0107d7d:	8b 25 84 6e 35 f0    	mov    0xf0356e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0107d83:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0107d88:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0107d8d:	ff d0                	call   *%eax

f0107d8f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0107d8f:	eb fe                	jmp    f0107d8f <spin>
f0107d91:	8d 76 00             	lea    0x0(%esi),%esi

f0107d94 <gdt>:
	...
f0107d9c:	ff                   	(bad)  
f0107d9d:	ff 00                	incl   (%eax)
f0107d9f:	00 00                	add    %al,(%eax)
f0107da1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0107da8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0107dac <gdtdesc>:
f0107dac:	17                   	pop    %ss
f0107dad:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0107db2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0107db2:	90                   	nop
	...

f0107db4 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0107db4:	55                   	push   %ebp
f0107db5:	89 e5                	mov    %esp,%ebp
f0107db7:	56                   	push   %esi
f0107db8:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0107db9:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0107dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0107dc3:	eb 07                	jmp    f0107dcc <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f0107dc5:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0107dc9:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0107dcb:	41                   	inc    %ecx
f0107dcc:	39 d1                	cmp    %edx,%ecx
f0107dce:	7c f5                	jl     f0107dc5 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0107dd0:	88 d8                	mov    %bl,%al
f0107dd2:	5b                   	pop    %ebx
f0107dd3:	5e                   	pop    %esi
f0107dd4:	5d                   	pop    %ebp
f0107dd5:	c3                   	ret    

f0107dd6 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0107dd6:	55                   	push   %ebp
f0107dd7:	89 e5                	mov    %esp,%ebp
f0107dd9:	56                   	push   %esi
f0107dda:	53                   	push   %ebx
f0107ddb:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107dde:	8b 0d 88 6e 35 f0    	mov    0xf0356e88,%ecx
f0107de4:	89 c3                	mov    %eax,%ebx
f0107de6:	c1 eb 0c             	shr    $0xc,%ebx
f0107de9:	39 cb                	cmp    %ecx,%ebx
f0107deb:	72 20                	jb     f0107e0d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107ded:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107df1:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0107df8:	f0 
f0107df9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107e00:	00 
f0107e01:	c7 04 24 a1 b3 10 f0 	movl   $0xf010b3a1,(%esp)
f0107e08:	e8 33 82 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0107e0d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107e10:	89 f2                	mov    %esi,%edx
f0107e12:	c1 ea 0c             	shr    $0xc,%edx
f0107e15:	39 d1                	cmp    %edx,%ecx
f0107e17:	77 20                	ja     f0107e39 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107e19:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107e1d:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0107e24:	f0 
f0107e25:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0107e2c:	00 
f0107e2d:	c7 04 24 a1 b3 10 f0 	movl   $0xf010b3a1,(%esp)
f0107e34:	e8 07 82 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0107e39:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0107e3f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0107e45:	eb 2f                	jmp    f0107e76 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107e47:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107e4e:	00 
f0107e4f:	c7 44 24 04 b1 b3 10 	movl   $0xf010b3b1,0x4(%esp)
f0107e56:	f0 
f0107e57:	89 1c 24             	mov    %ebx,(%esp)
f0107e5a:	e8 b8 fd ff ff       	call   f0107c17 <memcmp>
f0107e5f:	85 c0                	test   %eax,%eax
f0107e61:	75 10                	jne    f0107e73 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0107e63:	ba 10 00 00 00       	mov    $0x10,%edx
f0107e68:	89 d8                	mov    %ebx,%eax
f0107e6a:	e8 45 ff ff ff       	call   f0107db4 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0107e6f:	84 c0                	test   %al,%al
f0107e71:	74 0c                	je     f0107e7f <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0107e73:	83 c3 10             	add    $0x10,%ebx
f0107e76:	39 f3                	cmp    %esi,%ebx
f0107e78:	72 cd                	jb     f0107e47 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0107e7a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0107e7f:	89 d8                	mov    %ebx,%eax
f0107e81:	83 c4 10             	add    $0x10,%esp
f0107e84:	5b                   	pop    %ebx
f0107e85:	5e                   	pop    %esi
f0107e86:	5d                   	pop    %ebp
f0107e87:	c3                   	ret    

f0107e88 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0107e88:	55                   	push   %ebp
f0107e89:	89 e5                	mov    %esp,%ebp
f0107e8b:	57                   	push   %edi
f0107e8c:	56                   	push   %esi
f0107e8d:	53                   	push   %ebx
f0107e8e:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0107e91:	c7 05 c0 73 35 f0 20 	movl   $0xf0357020,0xf03573c0
f0107e98:	70 35 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107e9b:	83 3d 88 6e 35 f0 00 	cmpl   $0x0,0xf0356e88
f0107ea2:	75 24                	jne    f0107ec8 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107ea4:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0107eab:	00 
f0107eac:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0107eb3:	f0 
f0107eb4:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0107ebb:	00 
f0107ebc:	c7 04 24 a1 b3 10 f0 	movl   $0xf010b3a1,(%esp)
f0107ec3:	e8 78 81 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0107ec8:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0107ecf:	85 c0                	test   %eax,%eax
f0107ed1:	74 16                	je     f0107ee9 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0107ed3:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0107ed6:	ba 00 04 00 00       	mov    $0x400,%edx
f0107edb:	e8 f6 fe ff ff       	call   f0107dd6 <mpsearch1>
f0107ee0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107ee3:	85 c0                	test   %eax,%eax
f0107ee5:	75 3c                	jne    f0107f23 <mp_init+0x9b>
f0107ee7:	eb 20                	jmp    f0107f09 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0107ee9:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0107ef0:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0107ef3:	2d 00 04 00 00       	sub    $0x400,%eax
f0107ef8:	ba 00 04 00 00       	mov    $0x400,%edx
f0107efd:	e8 d4 fe ff ff       	call   f0107dd6 <mpsearch1>
f0107f02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107f05:	85 c0                	test   %eax,%eax
f0107f07:	75 1a                	jne    f0107f23 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0107f09:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107f0e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0107f13:	e8 be fe ff ff       	call   f0107dd6 <mpsearch1>
f0107f18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0107f1b:	85 c0                	test   %eax,%eax
f0107f1d:	0f 84 2c 02 00 00    	je     f010814f <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0107f23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107f26:	8b 58 04             	mov    0x4(%eax),%ebx
f0107f29:	85 db                	test   %ebx,%ebx
f0107f2b:	74 06                	je     f0107f33 <mp_init+0xab>
f0107f2d:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0107f31:	74 11                	je     f0107f44 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0107f33:	c7 04 24 14 b2 10 f0 	movl   $0xf010b214,(%esp)
f0107f3a:	e8 af d8 ff ff       	call   f01057ee <cprintf>
f0107f3f:	e9 0b 02 00 00       	jmp    f010814f <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0107f44:	89 d8                	mov    %ebx,%eax
f0107f46:	c1 e8 0c             	shr    $0xc,%eax
f0107f49:	3b 05 88 6e 35 f0    	cmp    0xf0356e88,%eax
f0107f4f:	72 20                	jb     f0107f71 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107f51:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107f55:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0107f5c:	f0 
f0107f5d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0107f64:	00 
f0107f65:	c7 04 24 a1 b3 10 f0 	movl   $0xf010b3a1,(%esp)
f0107f6c:	e8 cf 80 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0107f71:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0107f77:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0107f7e:	00 
f0107f7f:	c7 44 24 04 b6 b3 10 	movl   $0xf010b3b6,0x4(%esp)
f0107f86:	f0 
f0107f87:	89 1c 24             	mov    %ebx,(%esp)
f0107f8a:	e8 88 fc ff ff       	call   f0107c17 <memcmp>
f0107f8f:	85 c0                	test   %eax,%eax
f0107f91:	74 11                	je     f0107fa4 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0107f93:	c7 04 24 44 b2 10 f0 	movl   $0xf010b244,(%esp)
f0107f9a:	e8 4f d8 ff ff       	call   f01057ee <cprintf>
f0107f9f:	e9 ab 01 00 00       	jmp    f010814f <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0107fa4:	66 8b 73 04          	mov    0x4(%ebx),%si
f0107fa8:	0f b7 d6             	movzwl %si,%edx
f0107fab:	89 d8                	mov    %ebx,%eax
f0107fad:	e8 02 fe ff ff       	call   f0107db4 <sum>
f0107fb2:	84 c0                	test   %al,%al
f0107fb4:	74 11                	je     f0107fc7 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0107fb6:	c7 04 24 78 b2 10 f0 	movl   $0xf010b278,(%esp)
f0107fbd:	e8 2c d8 ff ff       	call   f01057ee <cprintf>
f0107fc2:	e9 88 01 00 00       	jmp    f010814f <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0107fc7:	8a 43 06             	mov    0x6(%ebx),%al
f0107fca:	3c 01                	cmp    $0x1,%al
f0107fcc:	74 1c                	je     f0107fea <mp_init+0x162>
f0107fce:	3c 04                	cmp    $0x4,%al
f0107fd0:	74 18                	je     f0107fea <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0107fd2:	0f b6 c0             	movzbl %al,%eax
f0107fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107fd9:	c7 04 24 9c b2 10 f0 	movl   $0xf010b29c,(%esp)
f0107fe0:	e8 09 d8 ff ff       	call   f01057ee <cprintf>
f0107fe5:	e9 65 01 00 00       	jmp    f010814f <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0107fea:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0107fee:	0f b7 c6             	movzwl %si,%eax
f0107ff1:	01 d8                	add    %ebx,%eax
f0107ff3:	e8 bc fd ff ff       	call   f0107db4 <sum>
f0107ff8:	02 43 2a             	add    0x2a(%ebx),%al
f0107ffb:	84 c0                	test   %al,%al
f0107ffd:	74 11                	je     f0108010 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0107fff:	c7 04 24 bc b2 10 f0 	movl   $0xf010b2bc,(%esp)
f0108006:	e8 e3 d7 ff ff       	call   f01057ee <cprintf>
f010800b:	e9 3f 01 00 00       	jmp    f010814f <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0108010:	85 db                	test   %ebx,%ebx
f0108012:	0f 84 37 01 00 00    	je     f010814f <mp_init+0x2c7>
		return;
	ismp = 1;
f0108018:	c7 05 00 70 35 f0 01 	movl   $0x1,0xf0357000
f010801f:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0108022:	8b 43 24             	mov    0x24(%ebx),%eax
f0108025:	a3 00 80 39 f0       	mov    %eax,0xf0398000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010802a:	8d 73 2c             	lea    0x2c(%ebx),%esi
f010802d:	bf 00 00 00 00       	mov    $0x0,%edi
f0108032:	e9 94 00 00 00       	jmp    f01080cb <mp_init+0x243>
		switch (*p) {
f0108037:	8a 06                	mov    (%esi),%al
f0108039:	84 c0                	test   %al,%al
f010803b:	74 06                	je     f0108043 <mp_init+0x1bb>
f010803d:	3c 04                	cmp    $0x4,%al
f010803f:	77 68                	ja     f01080a9 <mp_init+0x221>
f0108041:	eb 61                	jmp    f01080a4 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0108043:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0108047:	74 1d                	je     f0108066 <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f0108049:	a1 c4 73 35 f0       	mov    0xf03573c4,%eax
f010804e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0108055:	29 c2                	sub    %eax,%edx
f0108057:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010805a:	8d 04 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%eax
f0108061:	a3 c0 73 35 f0       	mov    %eax,0xf03573c0
			if (ncpu < NCPU) {
f0108066:	a1 c4 73 35 f0       	mov    0xf03573c4,%eax
f010806b:	83 f8 07             	cmp    $0x7,%eax
f010806e:	7f 1b                	jg     f010808b <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0108070:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0108077:	29 c2                	sub    %eax,%edx
f0108079:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010807c:	88 04 95 20 70 35 f0 	mov    %al,-0xfca8fe0(,%edx,4)
				ncpu++;
f0108083:	40                   	inc    %eax
f0108084:	a3 c4 73 35 f0       	mov    %eax,0xf03573c4
f0108089:	eb 14                	jmp    f010809f <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010808b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010808f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108093:	c7 04 24 ec b2 10 f0 	movl   $0xf010b2ec,(%esp)
f010809a:	e8 4f d7 ff ff       	call   f01057ee <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010809f:	83 c6 14             	add    $0x14,%esi
			continue;
f01080a2:	eb 26                	jmp    f01080ca <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01080a4:	83 c6 08             	add    $0x8,%esi
			continue;
f01080a7:	eb 21                	jmp    f01080ca <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01080a9:	0f b6 c0             	movzbl %al,%eax
f01080ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01080b0:	c7 04 24 14 b3 10 f0 	movl   $0xf010b314,(%esp)
f01080b7:	e8 32 d7 ff ff       	call   f01057ee <cprintf>
			ismp = 0;
f01080bc:	c7 05 00 70 35 f0 00 	movl   $0x0,0xf0357000
f01080c3:	00 00 00 
			i = conf->entry;
f01080c6:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01080ca:	47                   	inc    %edi
f01080cb:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01080cf:	39 c7                	cmp    %eax,%edi
f01080d1:	0f 82 60 ff ff ff    	jb     f0108037 <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01080d7:	a1 c0 73 35 f0       	mov    0xf03573c0,%eax
f01080dc:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01080e3:	83 3d 00 70 35 f0 00 	cmpl   $0x0,0xf0357000
f01080ea:	75 22                	jne    f010810e <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01080ec:	c7 05 c4 73 35 f0 01 	movl   $0x1,0xf03573c4
f01080f3:	00 00 00 
		lapicaddr = 0;
f01080f6:	c7 05 00 80 39 f0 00 	movl   $0x0,0xf0398000
f01080fd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0108100:	c7 04 24 34 b3 10 f0 	movl   $0xf010b334,(%esp)
f0108107:	e8 e2 d6 ff ff       	call   f01057ee <cprintf>
		return;
f010810c:	eb 41                	jmp    f010814f <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010810e:	8b 15 c4 73 35 f0    	mov    0xf03573c4,%edx
f0108114:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108118:	0f b6 00             	movzbl (%eax),%eax
f010811b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010811f:	c7 04 24 bb b3 10 f0 	movl   $0xf010b3bb,(%esp)
f0108126:	e8 c3 d6 ff ff       	call   f01057ee <cprintf>

	if (mp->imcrp) {
f010812b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010812e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0108132:	74 1b                	je     f010814f <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0108134:	c7 04 24 60 b3 10 f0 	movl   $0xf010b360,(%esp)
f010813b:	e8 ae d6 ff ff       	call   f01057ee <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0108140:	ba 22 00 00 00       	mov    $0x22,%edx
f0108145:	b0 70                	mov    $0x70,%al
f0108147:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0108148:	b2 23                	mov    $0x23,%dl
f010814a:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010814b:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010814e:	ee                   	out    %al,(%dx)
	}
}
f010814f:	83 c4 2c             	add    $0x2c,%esp
f0108152:	5b                   	pop    %ebx
f0108153:	5e                   	pop    %esi
f0108154:	5f                   	pop    %edi
f0108155:	5d                   	pop    %ebp
f0108156:	c3                   	ret    
	...

f0108158 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0108158:	55                   	push   %ebp
f0108159:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010815b:	c1 e0 02             	shl    $0x2,%eax
f010815e:	03 05 04 80 39 f0    	add    0xf0398004,%eax
f0108164:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0108166:	a1 04 80 39 f0       	mov    0xf0398004,%eax
f010816b:	8b 40 20             	mov    0x20(%eax),%eax
}
f010816e:	5d                   	pop    %ebp
f010816f:	c3                   	ret    

f0108170 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0108170:	55                   	push   %ebp
f0108171:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0108173:	a1 04 80 39 f0       	mov    0xf0398004,%eax
f0108178:	85 c0                	test   %eax,%eax
f010817a:	74 08                	je     f0108184 <cpunum+0x14>
		return lapic[ID] >> 24;
f010817c:	8b 40 20             	mov    0x20(%eax),%eax
f010817f:	c1 e8 18             	shr    $0x18,%eax
f0108182:	eb 05                	jmp    f0108189 <cpunum+0x19>
	return 0;
f0108184:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108189:	5d                   	pop    %ebp
f010818a:	c3                   	ret    

f010818b <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010818b:	55                   	push   %ebp
f010818c:	89 e5                	mov    %esp,%ebp
f010818e:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0108191:	a1 00 80 39 f0       	mov    0xf0398000,%eax
f0108196:	85 c0                	test   %eax,%eax
f0108198:	0f 84 27 01 00 00    	je     f01082c5 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010819e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01081a5:	00 
f01081a6:	89 04 24             	mov    %eax,(%esp)
f01081a9:	e8 b2 a9 ff ff       	call   f0102b60 <mmio_map_region>
f01081ae:	a3 04 80 39 f0       	mov    %eax,0xf0398004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01081b3:	ba 27 01 00 00       	mov    $0x127,%edx
f01081b8:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01081bd:	e8 96 ff ff ff       	call   f0108158 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01081c2:	ba 0b 00 00 00       	mov    $0xb,%edx
f01081c7:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01081cc:	e8 87 ff ff ff       	call   f0108158 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01081d1:	ba 20 00 02 00       	mov    $0x20020,%edx
f01081d6:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01081db:	e8 78 ff ff ff       	call   f0108158 <lapicw>
	lapicw(TICR, 10000000); 
f01081e0:	ba 80 96 98 00       	mov    $0x989680,%edx
f01081e5:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01081ea:	e8 69 ff ff ff       	call   f0108158 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01081ef:	e8 7c ff ff ff       	call   f0108170 <cpunum>
f01081f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01081fb:	29 c2                	sub    %eax,%edx
f01081fd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0108200:	8d 04 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%eax
f0108207:	39 05 c0 73 35 f0    	cmp    %eax,0xf03573c0
f010820d:	74 0f                	je     f010821e <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f010820f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0108214:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0108219:	e8 3a ff ff ff       	call   f0108158 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010821e:	ba 00 00 01 00       	mov    $0x10000,%edx
f0108223:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0108228:	e8 2b ff ff ff       	call   f0108158 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010822d:	a1 04 80 39 f0       	mov    0xf0398004,%eax
f0108232:	8b 40 30             	mov    0x30(%eax),%eax
f0108235:	c1 e8 10             	shr    $0x10,%eax
f0108238:	3c 03                	cmp    $0x3,%al
f010823a:	76 0f                	jbe    f010824b <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f010823c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0108241:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0108246:	e8 0d ff ff ff       	call   f0108158 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010824b:	ba 33 00 00 00       	mov    $0x33,%edx
f0108250:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0108255:	e8 fe fe ff ff       	call   f0108158 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010825a:	ba 00 00 00 00       	mov    $0x0,%edx
f010825f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0108264:	e8 ef fe ff ff       	call   f0108158 <lapicw>
	lapicw(ESR, 0);
f0108269:	ba 00 00 00 00       	mov    $0x0,%edx
f010826e:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0108273:	e8 e0 fe ff ff       	call   f0108158 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0108278:	ba 00 00 00 00       	mov    $0x0,%edx
f010827d:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0108282:	e8 d1 fe ff ff       	call   f0108158 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0108287:	ba 00 00 00 00       	mov    $0x0,%edx
f010828c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0108291:	e8 c2 fe ff ff       	call   f0108158 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0108296:	ba 00 85 08 00       	mov    $0x88500,%edx
f010829b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01082a0:	e8 b3 fe ff ff       	call   f0108158 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01082a5:	8b 15 04 80 39 f0    	mov    0xf0398004,%edx
f01082ab:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01082b1:	f6 c4 10             	test   $0x10,%ah
f01082b4:	75 f5                	jne    f01082ab <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01082b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01082bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01082c0:	e8 93 fe ff ff       	call   f0108158 <lapicw>
}
f01082c5:	c9                   	leave  
f01082c6:	c3                   	ret    

f01082c7 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01082c7:	55                   	push   %ebp
f01082c8:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01082ca:	83 3d 04 80 39 f0 00 	cmpl   $0x0,0xf0398004
f01082d1:	74 0f                	je     f01082e2 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01082d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01082d8:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01082dd:	e8 76 fe ff ff       	call   f0108158 <lapicw>
}
f01082e2:	5d                   	pop    %ebp
f01082e3:	c3                   	ret    

f01082e4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01082e4:	55                   	push   %ebp
f01082e5:	89 e5                	mov    %esp,%ebp
f01082e7:	56                   	push   %esi
f01082e8:	53                   	push   %ebx
f01082e9:	83 ec 10             	sub    $0x10,%esp
f01082ec:	8b 75 0c             	mov    0xc(%ebp),%esi
f01082ef:	8a 5d 08             	mov    0x8(%ebp),%bl
f01082f2:	ba 70 00 00 00       	mov    $0x70,%edx
f01082f7:	b0 0f                	mov    $0xf,%al
f01082f9:	ee                   	out    %al,(%dx)
f01082fa:	b2 71                	mov    $0x71,%dl
f01082fc:	b0 0a                	mov    $0xa,%al
f01082fe:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01082ff:	83 3d 88 6e 35 f0 00 	cmpl   $0x0,0xf0356e88
f0108306:	75 24                	jne    f010832c <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0108308:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010830f:	00 
f0108310:	c7 44 24 08 88 88 10 	movl   $0xf0108888,0x8(%esp)
f0108317:	f0 
f0108318:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010831f:	00 
f0108320:	c7 04 24 d8 b3 10 f0 	movl   $0xf010b3d8,(%esp)
f0108327:	e8 14 7d ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010832c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0108333:	00 00 
	wrv[1] = addr >> 4;
f0108335:	89 f0                	mov    %esi,%eax
f0108337:	c1 e8 04             	shr    $0x4,%eax
f010833a:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0108340:	c1 e3 18             	shl    $0x18,%ebx
f0108343:	89 da                	mov    %ebx,%edx
f0108345:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010834a:	e8 09 fe ff ff       	call   f0108158 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010834f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0108354:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108359:	e8 fa fd ff ff       	call   f0108158 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010835e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0108363:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108368:	e8 eb fd ff ff       	call   f0108158 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010836d:	c1 ee 0c             	shr    $0xc,%esi
f0108370:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0108376:	89 da                	mov    %ebx,%edx
f0108378:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010837d:	e8 d6 fd ff ff       	call   f0108158 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0108382:	89 f2                	mov    %esi,%edx
f0108384:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0108389:	e8 ca fd ff ff       	call   f0108158 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010838e:	89 da                	mov    %ebx,%edx
f0108390:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0108395:	e8 be fd ff ff       	call   f0108158 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010839a:	89 f2                	mov    %esi,%edx
f010839c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01083a1:	e8 b2 fd ff ff       	call   f0108158 <lapicw>
		microdelay(200);
	}
}
f01083a6:	83 c4 10             	add    $0x10,%esp
f01083a9:	5b                   	pop    %ebx
f01083aa:	5e                   	pop    %esi
f01083ab:	5d                   	pop    %ebp
f01083ac:	c3                   	ret    

f01083ad <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01083ad:	55                   	push   %ebp
f01083ae:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01083b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01083b3:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01083b9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01083be:	e8 95 fd ff ff       	call   f0108158 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01083c3:	8b 15 04 80 39 f0    	mov    0xf0398004,%edx
f01083c9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01083cf:	f6 c4 10             	test   $0x10,%ah
f01083d2:	75 f5                	jne    f01083c9 <lapic_ipi+0x1c>
		;
}
f01083d4:	5d                   	pop    %ebp
f01083d5:	c3                   	ret    
	...

f01083d8 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01083d8:	55                   	push   %ebp
f01083d9:	89 e5                	mov    %esp,%ebp
f01083db:	53                   	push   %ebx
f01083dc:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01083df:	83 38 00             	cmpl   $0x0,(%eax)
f01083e2:	74 25                	je     f0108409 <holding+0x31>
f01083e4:	8b 58 08             	mov    0x8(%eax),%ebx
f01083e7:	e8 84 fd ff ff       	call   f0108170 <cpunum>
f01083ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01083f3:	29 c2                	sub    %eax,%edx
f01083f5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01083f8:	8d 04 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01083ff:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0108401:	0f 94 c0             	sete   %al
f0108404:	0f b6 c0             	movzbl %al,%eax
f0108407:	eb 05                	jmp    f010840e <holding+0x36>
f0108409:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010840e:	83 c4 04             	add    $0x4,%esp
f0108411:	5b                   	pop    %ebx
f0108412:	5d                   	pop    %ebp
f0108413:	c3                   	ret    

f0108414 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0108414:	55                   	push   %ebp
f0108415:	89 e5                	mov    %esp,%ebp
f0108417:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010841a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0108420:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108423:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0108426:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010842d:	5d                   	pop    %ebp
f010842e:	c3                   	ret    

f010842f <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010842f:	55                   	push   %ebp
f0108430:	89 e5                	mov    %esp,%ebp
f0108432:	53                   	push   %ebx
f0108433:	83 ec 24             	sub    $0x24,%esp
f0108436:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0108439:	89 d8                	mov    %ebx,%eax
f010843b:	e8 98 ff ff ff       	call   f01083d8 <holding>
f0108440:	85 c0                	test   %eax,%eax
f0108442:	74 30                	je     f0108474 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0108444:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0108447:	e8 24 fd ff ff       	call   f0108170 <cpunum>
f010844c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0108450:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108454:	c7 44 24 08 e8 b3 10 	movl   $0xf010b3e8,0x8(%esp)
f010845b:	f0 
f010845c:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0108463:	00 
f0108464:	c7 04 24 4c b4 10 f0 	movl   $0xf010b44c,(%esp)
f010846b:	e8 d0 7b ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0108470:	f3 90                	pause  
f0108472:	eb 05                	jmp    f0108479 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0108474:	ba 01 00 00 00       	mov    $0x1,%edx
f0108479:	89 d0                	mov    %edx,%eax
f010847b:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010847e:	85 c0                	test   %eax,%eax
f0108480:	75 ee                	jne    f0108470 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0108482:	e8 e9 fc ff ff       	call   f0108170 <cpunum>
f0108487:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010848e:	29 c2                	sub    %eax,%edx
f0108490:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0108493:	8d 04 85 20 70 35 f0 	lea    -0xfca8fe0(,%eax,4),%eax
f010849a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010849d:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01084a0:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01084a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01084a7:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01084ad:	76 10                	jbe    f01084bf <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01084af:	8b 4a 04             	mov    0x4(%edx),%ecx
f01084b2:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01084b5:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01084b7:	40                   	inc    %eax
f01084b8:	83 f8 0a             	cmp    $0xa,%eax
f01084bb:	75 ea                	jne    f01084a7 <spin_lock+0x78>
f01084bd:	eb 0d                	jmp    f01084cc <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01084bf:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01084c6:	40                   	inc    %eax
f01084c7:	83 f8 09             	cmp    $0x9,%eax
f01084ca:	7e f3                	jle    f01084bf <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01084cc:	83 c4 24             	add    $0x24,%esp
f01084cf:	5b                   	pop    %ebx
f01084d0:	5d                   	pop    %ebp
f01084d1:	c3                   	ret    

f01084d2 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01084d2:	55                   	push   %ebp
f01084d3:	89 e5                	mov    %esp,%ebp
f01084d5:	57                   	push   %edi
f01084d6:	56                   	push   %esi
f01084d7:	53                   	push   %ebx
f01084d8:	83 ec 7c             	sub    $0x7c,%esp
f01084db:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01084de:	89 d8                	mov    %ebx,%eax
f01084e0:	e8 f3 fe ff ff       	call   f01083d8 <holding>
f01084e5:	85 c0                	test   %eax,%eax
f01084e7:	0f 85 d3 00 00 00    	jne    f01085c0 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01084ed:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01084f4:	00 
f01084f5:	8d 43 0c             	lea    0xc(%ebx),%eax
f01084f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01084fc:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01084ff:	89 34 24             	mov    %esi,(%esp)
f0108502:	e8 85 f6 ff ff       	call   f0107b8c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0108507:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010850a:	0f b6 38             	movzbl (%eax),%edi
f010850d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0108510:	e8 5b fc ff ff       	call   f0108170 <cpunum>
f0108515:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0108519:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010851d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108521:	c7 04 24 14 b4 10 f0 	movl   $0xf010b414,(%esp)
f0108528:	e8 c1 d2 ff ff       	call   f01057ee <cprintf>
f010852d:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010852f:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0108532:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0108535:	89 c7                	mov    %eax,%edi
f0108537:	eb 63                	jmp    f010859c <spin_unlock+0xca>
f0108539:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010853d:	89 04 24             	mov    %eax,(%esp)
f0108540:	e8 08 eb ff ff       	call   f010704d <debuginfo_eip>
f0108545:	85 c0                	test   %eax,%eax
f0108547:	78 39                	js     f0108582 <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0108549:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010854b:	89 c2                	mov    %eax,%edx
f010854d:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0108550:	89 54 24 18          	mov    %edx,0x18(%esp)
f0108554:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0108557:	89 54 24 14          	mov    %edx,0x14(%esp)
f010855b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010855e:	89 54 24 10          	mov    %edx,0x10(%esp)
f0108562:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0108565:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108569:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010856c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108570:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108574:	c7 04 24 5c b4 10 f0 	movl   $0xf010b45c,(%esp)
f010857b:	e8 6e d2 ff ff       	call   f01057ee <cprintf>
f0108580:	eb 12                	jmp    f0108594 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0108582:	8b 06                	mov    (%esi),%eax
f0108584:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108588:	c7 04 24 73 b4 10 f0 	movl   $0xf010b473,(%esp)
f010858f:	e8 5a d2 ff ff       	call   f01057ee <cprintf>
f0108594:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0108597:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f010859a:	74 08                	je     f01085a4 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010859c:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010859e:	8b 03                	mov    (%ebx),%eax
f01085a0:	85 c0                	test   %eax,%eax
f01085a2:	75 95                	jne    f0108539 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01085a4:	c7 44 24 08 7b b4 10 	movl   $0xf010b47b,0x8(%esp)
f01085ab:	f0 
f01085ac:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01085b3:	00 
f01085b4:	c7 04 24 4c b4 10 f0 	movl   $0xf010b44c,(%esp)
f01085bb:	e8 80 7a ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01085c0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01085c7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f01085ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01085d3:	f0 87 03             	lock xchg %eax,(%ebx)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01085d6:	83 c4 7c             	add    $0x7c,%esp
f01085d9:	5b                   	pop    %ebx
f01085da:	5e                   	pop    %esi
f01085db:	5f                   	pop    %edi
f01085dc:	5d                   	pop    %ebp
f01085dd:	c3                   	ret    
	...

f01085e0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01085e0:	55                   	push   %ebp
f01085e1:	57                   	push   %edi
f01085e2:	56                   	push   %esi
f01085e3:	83 ec 10             	sub    $0x10,%esp
f01085e6:	8b 74 24 20          	mov    0x20(%esp),%esi
f01085ea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01085ee:	89 74 24 04          	mov    %esi,0x4(%esp)
f01085f2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f01085f6:	89 cd                	mov    %ecx,%ebp
f01085f8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01085fc:	85 c0                	test   %eax,%eax
f01085fe:	75 2c                	jne    f010862c <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0108600:	39 f9                	cmp    %edi,%ecx
f0108602:	77 68                	ja     f010866c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0108604:	85 c9                	test   %ecx,%ecx
f0108606:	75 0b                	jne    f0108613 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0108608:	b8 01 00 00 00       	mov    $0x1,%eax
f010860d:	31 d2                	xor    %edx,%edx
f010860f:	f7 f1                	div    %ecx
f0108611:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0108613:	31 d2                	xor    %edx,%edx
f0108615:	89 f8                	mov    %edi,%eax
f0108617:	f7 f1                	div    %ecx
f0108619:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010861b:	89 f0                	mov    %esi,%eax
f010861d:	f7 f1                	div    %ecx
f010861f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0108621:	89 f0                	mov    %esi,%eax
f0108623:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0108625:	83 c4 10             	add    $0x10,%esp
f0108628:	5e                   	pop    %esi
f0108629:	5f                   	pop    %edi
f010862a:	5d                   	pop    %ebp
f010862b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010862c:	39 f8                	cmp    %edi,%eax
f010862e:	77 2c                	ja     f010865c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0108630:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0108633:	83 f6 1f             	xor    $0x1f,%esi
f0108636:	75 4c                	jne    f0108684 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0108638:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010863a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010863f:	72 0a                	jb     f010864b <__udivdi3+0x6b>
f0108641:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0108645:	0f 87 ad 00 00 00    	ja     f01086f8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010864b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0108650:	89 f0                	mov    %esi,%eax
f0108652:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0108654:	83 c4 10             	add    $0x10,%esp
f0108657:	5e                   	pop    %esi
f0108658:	5f                   	pop    %edi
f0108659:	5d                   	pop    %ebp
f010865a:	c3                   	ret    
f010865b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010865c:	31 ff                	xor    %edi,%edi
f010865e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0108660:	89 f0                	mov    %esi,%eax
f0108662:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0108664:	83 c4 10             	add    $0x10,%esp
f0108667:	5e                   	pop    %esi
f0108668:	5f                   	pop    %edi
f0108669:	5d                   	pop    %ebp
f010866a:	c3                   	ret    
f010866b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010866c:	89 fa                	mov    %edi,%edx
f010866e:	89 f0                	mov    %esi,%eax
f0108670:	f7 f1                	div    %ecx
f0108672:	89 c6                	mov    %eax,%esi
f0108674:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0108676:	89 f0                	mov    %esi,%eax
f0108678:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010867a:	83 c4 10             	add    $0x10,%esp
f010867d:	5e                   	pop    %esi
f010867e:	5f                   	pop    %edi
f010867f:	5d                   	pop    %ebp
f0108680:	c3                   	ret    
f0108681:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0108684:	89 f1                	mov    %esi,%ecx
f0108686:	d3 e0                	shl    %cl,%eax
f0108688:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010868c:	b8 20 00 00 00       	mov    $0x20,%eax
f0108691:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0108693:	89 ea                	mov    %ebp,%edx
f0108695:	88 c1                	mov    %al,%cl
f0108697:	d3 ea                	shr    %cl,%edx
f0108699:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f010869d:	09 ca                	or     %ecx,%edx
f010869f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f01086a3:	89 f1                	mov    %esi,%ecx
f01086a5:	d3 e5                	shl    %cl,%ebp
f01086a7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f01086ab:	89 fd                	mov    %edi,%ebp
f01086ad:	88 c1                	mov    %al,%cl
f01086af:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f01086b1:	89 fa                	mov    %edi,%edx
f01086b3:	89 f1                	mov    %esi,%ecx
f01086b5:	d3 e2                	shl    %cl,%edx
f01086b7:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01086bb:	88 c1                	mov    %al,%cl
f01086bd:	d3 ef                	shr    %cl,%edi
f01086bf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01086c1:	89 f8                	mov    %edi,%eax
f01086c3:	89 ea                	mov    %ebp,%edx
f01086c5:	f7 74 24 08          	divl   0x8(%esp)
f01086c9:	89 d1                	mov    %edx,%ecx
f01086cb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01086cd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01086d1:	39 d1                	cmp    %edx,%ecx
f01086d3:	72 17                	jb     f01086ec <__udivdi3+0x10c>
f01086d5:	74 09                	je     f01086e0 <__udivdi3+0x100>
f01086d7:	89 fe                	mov    %edi,%esi
f01086d9:	31 ff                	xor    %edi,%edi
f01086db:	e9 41 ff ff ff       	jmp    f0108621 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01086e0:	8b 54 24 04          	mov    0x4(%esp),%edx
f01086e4:	89 f1                	mov    %esi,%ecx
f01086e6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01086e8:	39 c2                	cmp    %eax,%edx
f01086ea:	73 eb                	jae    f01086d7 <__udivdi3+0xf7>
		{
		  q0--;
f01086ec:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01086ef:	31 ff                	xor    %edi,%edi
f01086f1:	e9 2b ff ff ff       	jmp    f0108621 <__udivdi3+0x41>
f01086f6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01086f8:	31 f6                	xor    %esi,%esi
f01086fa:	e9 22 ff ff ff       	jmp    f0108621 <__udivdi3+0x41>
	...

f0108700 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0108700:	55                   	push   %ebp
f0108701:	57                   	push   %edi
f0108702:	56                   	push   %esi
f0108703:	83 ec 20             	sub    $0x20,%esp
f0108706:	8b 44 24 30          	mov    0x30(%esp),%eax
f010870a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010870e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0108712:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0108716:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010871a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f010871e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0108720:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0108722:	85 ed                	test   %ebp,%ebp
f0108724:	75 16                	jne    f010873c <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0108726:	39 f1                	cmp    %esi,%ecx
f0108728:	0f 86 a6 00 00 00    	jbe    f01087d4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010872e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0108730:	89 d0                	mov    %edx,%eax
f0108732:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0108734:	83 c4 20             	add    $0x20,%esp
f0108737:	5e                   	pop    %esi
f0108738:	5f                   	pop    %edi
f0108739:	5d                   	pop    %ebp
f010873a:	c3                   	ret    
f010873b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010873c:	39 f5                	cmp    %esi,%ebp
f010873e:	0f 87 ac 00 00 00    	ja     f01087f0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0108744:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0108747:	83 f0 1f             	xor    $0x1f,%eax
f010874a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010874e:	0f 84 a8 00 00 00    	je     f01087fc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0108754:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0108758:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010875a:	bf 20 00 00 00       	mov    $0x20,%edi
f010875f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0108763:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0108767:	89 f9                	mov    %edi,%ecx
f0108769:	d3 e8                	shr    %cl,%eax
f010876b:	09 e8                	or     %ebp,%eax
f010876d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0108771:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0108775:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0108779:	d3 e0                	shl    %cl,%eax
f010877b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010877f:	89 f2                	mov    %esi,%edx
f0108781:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0108783:	8b 44 24 14          	mov    0x14(%esp),%eax
f0108787:	d3 e0                	shl    %cl,%eax
f0108789:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010878d:	8b 44 24 14          	mov    0x14(%esp),%eax
f0108791:	89 f9                	mov    %edi,%ecx
f0108793:	d3 e8                	shr    %cl,%eax
f0108795:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0108797:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0108799:	89 f2                	mov    %esi,%edx
f010879b:	f7 74 24 18          	divl   0x18(%esp)
f010879f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01087a1:	f7 64 24 0c          	mull   0xc(%esp)
f01087a5:	89 c5                	mov    %eax,%ebp
f01087a7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01087a9:	39 d6                	cmp    %edx,%esi
f01087ab:	72 67                	jb     f0108814 <__umoddi3+0x114>
f01087ad:	74 75                	je     f0108824 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01087af:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01087b3:	29 e8                	sub    %ebp,%eax
f01087b5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01087b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01087bb:	d3 e8                	shr    %cl,%eax
f01087bd:	89 f2                	mov    %esi,%edx
f01087bf:	89 f9                	mov    %edi,%ecx
f01087c1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01087c3:	09 d0                	or     %edx,%eax
f01087c5:	89 f2                	mov    %esi,%edx
f01087c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01087cb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01087cd:	83 c4 20             	add    $0x20,%esp
f01087d0:	5e                   	pop    %esi
f01087d1:	5f                   	pop    %edi
f01087d2:	5d                   	pop    %ebp
f01087d3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01087d4:	85 c9                	test   %ecx,%ecx
f01087d6:	75 0b                	jne    f01087e3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01087d8:	b8 01 00 00 00       	mov    $0x1,%eax
f01087dd:	31 d2                	xor    %edx,%edx
f01087df:	f7 f1                	div    %ecx
f01087e1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01087e3:	89 f0                	mov    %esi,%eax
f01087e5:	31 d2                	xor    %edx,%edx
f01087e7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01087e9:	89 f8                	mov    %edi,%eax
f01087eb:	e9 3e ff ff ff       	jmp    f010872e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01087f0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01087f2:	83 c4 20             	add    $0x20,%esp
f01087f5:	5e                   	pop    %esi
f01087f6:	5f                   	pop    %edi
f01087f7:	5d                   	pop    %ebp
f01087f8:	c3                   	ret    
f01087f9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01087fc:	39 f5                	cmp    %esi,%ebp
f01087fe:	72 04                	jb     f0108804 <__umoddi3+0x104>
f0108800:	39 f9                	cmp    %edi,%ecx
f0108802:	77 06                	ja     f010880a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0108804:	89 f2                	mov    %esi,%edx
f0108806:	29 cf                	sub    %ecx,%edi
f0108808:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f010880a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010880c:	83 c4 20             	add    $0x20,%esp
f010880f:	5e                   	pop    %esi
f0108810:	5f                   	pop    %edi
f0108811:	5d                   	pop    %ebp
f0108812:	c3                   	ret    
f0108813:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0108814:	89 d1                	mov    %edx,%ecx
f0108816:	89 c5                	mov    %eax,%ebp
f0108818:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f010881c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0108820:	eb 8d                	jmp    f01087af <__umoddi3+0xaf>
f0108822:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0108824:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0108828:	72 ea                	jb     f0108814 <__umoddi3+0x114>
f010882a:	89 f1                	mov    %esi,%ecx
f010882c:	eb 81                	jmp    f01087af <__umoddi3+0xaf>
