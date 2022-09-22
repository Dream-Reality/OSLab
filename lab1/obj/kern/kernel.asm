
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 40 1b 10 f0 	movl   $0xf0101b40,(%esp)
f0100055:	e8 ec 0b 00 00       	call   f0100c46 <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 b7 09 00 00       	call   f0100a3e <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 5c 1b 10 f0 	movl   $0xf0101b5c,(%esp)
f0100092:	e8 af 0b 00 00       	call   f0100c46 <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 60 a9 11 f0       	mov    $0xf011a960,%eax
f01000a8:	2d 20 a3 11 f0       	sub    $0xf011a320,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 20 a3 11 f0 	movl   $0xf011a320,(%esp)
f01000c0:	e8 25 16 00 00       	call   f01016ea <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 62 07 00 00       	call   f010082c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 77 1b 10 f0 	movl   $0xf0101b77,(%esp)
f01000d9:	e8 68 0b 00 00       	call   f0100c46 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 e2 09 00 00       	call   f0100ad8 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 64 a9 11 f0 00 	cmpl   $0x0,0xf011a964
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 64 a9 11 f0    	mov    %esi,0xf011a964

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 92 1b 10 f0 	movl   $0xf0101b92,(%esp)
f010012c:	e8 15 0b 00 00       	call   f0100c46 <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 d6 0a 00 00       	call   f0100c13 <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 da 1e 10 f0 	movl   $0xf0101eda,(%esp)
f0100144:	e8 fd 0a 00 00       	call   f0100c46 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 83 09 00 00       	call   f0100ad8 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 aa 1b 10 f0 	movl   $0xf0101baa,(%esp)
f0100176:	e8 cb 0a 00 00       	call   f0100c46 <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 89 0a 00 00       	call   f0100c13 <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 da 1e 10 f0 	movl   $0xf0101eda,(%esp)
f0100191:	e8 b0 0a 00 00       	call   f0100c46 <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    

f010019c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010019f:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a4:	ec                   	in     (%dx),%al
f01001a5:	ec                   	in     (%dx),%al
f01001a6:	ec                   	in     (%dx),%al
f01001a7:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001a8:	5d                   	pop    %ebp
f01001a9:	c3                   	ret    

f01001aa <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001aa:	55                   	push   %ebp
f01001ab:	89 e5                	mov    %esp,%ebp
f01001ad:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b3:	a8 01                	test   $0x1,%al
f01001b5:	74 08                	je     f01001bf <serial_proc_data+0x15>
f01001b7:	b2 f8                	mov    $0xf8,%dl
f01001b9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ba:	0f b6 c0             	movzbl %al,%eax
f01001bd:	eb 05                	jmp    f01001c4 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001c4:	5d                   	pop    %ebp
f01001c5:	c3                   	ret    

f01001c6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001c6:	55                   	push   %ebp
f01001c7:	89 e5                	mov    %esp,%ebp
f01001c9:	53                   	push   %ebx
f01001ca:	83 ec 04             	sub    $0x4,%esp
f01001cd:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001cf:	eb 29                	jmp    f01001fa <cons_intr+0x34>
		if (c == 0)
f01001d1:	85 c0                	test   %eax,%eax
f01001d3:	74 25                	je     f01001fa <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001d5:	8b 15 44 a5 11 f0    	mov    0xf011a544,%edx
f01001db:	88 82 40 a3 11 f0    	mov    %al,-0xfee5cc0(%edx)
f01001e1:	8d 42 01             	lea    0x1(%edx),%eax
f01001e4:	a3 44 a5 11 f0       	mov    %eax,0xf011a544
		if (cons.wpos == CONSBUFSIZE)
f01001e9:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ee:	75 0a                	jne    f01001fa <cons_intr+0x34>
			cons.wpos = 0;
f01001f0:	c7 05 44 a5 11 f0 00 	movl   $0x0,0xf011a544
f01001f7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001fa:	ff d3                	call   *%ebx
f01001fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ff:	75 d0                	jne    f01001d1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100201:	83 c4 04             	add    $0x4,%esp
f0100204:	5b                   	pop    %ebx
f0100205:	5d                   	pop    %ebp
f0100206:	c3                   	ret    

f0100207 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100207:	55                   	push   %ebp
f0100208:	89 e5                	mov    %esp,%ebp
f010020a:	57                   	push   %edi
f010020b:	56                   	push   %esi
f010020c:	53                   	push   %ebx
f010020d:	83 ec 2c             	sub    $0x2c,%esp
f0100210:	89 c6                	mov    %eax,%esi
f0100212:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100217:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010021c:	eb 05                	jmp    f0100223 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010021e:	e8 79 ff ff ff       	call   f010019c <delay>
f0100223:	89 fa                	mov    %edi,%edx
f0100225:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100226:	a8 20                	test   $0x20,%al
f0100228:	75 03                	jne    f010022d <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010022a:	4b                   	dec    %ebx
f010022b:	75 f1                	jne    f010021e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010022d:	89 f2                	mov    %esi,%edx
f010022f:	89 f0                	mov    %esi,%eax
f0100231:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100234:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100239:	ee                   	out    %al,(%dx)
f010023a:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010023f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100244:	eb 05                	jmp    f010024b <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100246:	e8 51 ff ff ff       	call   f010019c <delay>
f010024b:	89 fa                	mov    %edi,%edx
f010024d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010024e:	84 c0                	test   %al,%al
f0100250:	78 03                	js     f0100255 <cons_putc+0x4e>
f0100252:	4b                   	dec    %ebx
f0100253:	75 f1                	jne    f0100246 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100255:	ba 78 03 00 00       	mov    $0x378,%edx
f010025a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010025d:	ee                   	out    %al,(%dx)
f010025e:	b2 7a                	mov    $0x7a,%dl
f0100260:	b0 0d                	mov    $0xd,%al
f0100262:	ee                   	out    %al,(%dx)
f0100263:	b0 08                	mov    $0x8,%al
f0100265:	ee                   	out    %al,(%dx)
{
	// if no attribute given, then use black on white
	static int Color = 0x0700;
	static int State = 0;
	static int Number = 0;
	if (!(c & ~0xFF))
f0100266:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010026c:	75 06                	jne    f0100274 <cons_putc+0x6d>
		c |= Color;
f010026e:	0b 35 00 a0 11 f0    	or     0xf011a000,%esi
	switch (c & 0xff) {
f0100274:	89 f2                	mov    %esi,%edx
f0100276:	81 e2 ff 00 00 00    	and    $0xff,%edx
f010027c:	8d 42 f8             	lea    -0x8(%edx),%eax
f010027f:	83 f8 13             	cmp    $0x13,%eax
f0100282:	0f 87 ab 00 00 00    	ja     f0100333 <cons_putc+0x12c>
f0100288:	ff 24 85 e0 1b 10 f0 	jmp    *-0xfefe420(,%eax,4)
	case '\b':
		if (crt_pos > 0) {
f010028f:	66 a1 54 a5 11 f0    	mov    0xf011a554,%ax
f0100295:	66 85 c0             	test   %ax,%ax
f0100298:	0f 84 de 03 00 00    	je     f010067c <cons_putc+0x475>
			crt_pos--;
f010029e:	48                   	dec    %eax
f010029f:	66 a3 54 a5 11 f0    	mov    %ax,0xf011a554
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002a5:	0f b7 c0             	movzwl %ax,%eax
f01002a8:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01002ae:	83 ce 20             	or     $0x20,%esi
f01002b1:	8b 15 50 a5 11 f0    	mov    0xf011a550,%edx
f01002b7:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002bb:	e9 71 03 00 00       	jmp    f0100631 <cons_putc+0x42a>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002c0:	66 83 05 54 a5 11 f0 	addw   $0x50,0xf011a554
f01002c7:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002c8:	66 8b 0d 54 a5 11 f0 	mov    0xf011a554,%cx
f01002cf:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002d4:	89 c8                	mov    %ecx,%eax
f01002d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01002db:	66 f7 f3             	div    %bx
f01002de:	66 29 d1             	sub    %dx,%cx
f01002e1:	66 89 0d 54 a5 11 f0 	mov    %cx,0xf011a554
f01002e8:	e9 44 03 00 00       	jmp    f0100631 <cons_putc+0x42a>
		break;
	case '\t':
		cons_putc(' ');
f01002ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f2:	e8 10 ff ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f01002f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fc:	e8 06 ff ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100301:	b8 20 00 00 00       	mov    $0x20,%eax
f0100306:	e8 fc fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f010030b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100310:	e8 f2 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100315:	b8 20 00 00 00       	mov    $0x20,%eax
f010031a:	e8 e8 fe ff ff       	call   f0100207 <cons_putc>
f010031f:	e9 0d 03 00 00       	jmp    f0100631 <cons_putc+0x42a>
		break;
	case '\033':
		State = 1;
f0100324:	c7 05 58 a5 11 f0 01 	movl   $0x1,0xf011a558
f010032b:	00 00 00 
f010032e:	e9 fe 02 00 00       	jmp    f0100631 <cons_putc+0x42a>
		break;
	default:
		if (State == 1){
f0100333:	83 3d 58 a5 11 f0 01 	cmpl   $0x1,0xf011a558
f010033a:	0f 85 d7 02 00 00    	jne    f0100617 <cons_putc+0x410>
			switch (c&0xff){
f0100340:	83 fa 5b             	cmp    $0x5b,%edx
f0100343:	0f 84 e8 02 00 00    	je     f0100631 <cons_putc+0x42a>
f0100349:	83 fa 6d             	cmp    $0x6d,%edx
f010034c:	0f 84 5a 01 00 00    	je     f01004ac <cons_putc+0x2a5>
f0100352:	83 fa 3b             	cmp    $0x3b,%edx
f0100355:	0f 85 a9 02 00 00    	jne    f0100604 <cons_putc+0x3fd>
				case '[':
					break;
				case ';':
					switch (Number){
f010035b:	a1 5c a5 11 f0       	mov    0xf011a55c,%eax
f0100360:	83 e8 1e             	sub    $0x1e,%eax
f0100363:	83 f8 11             	cmp    $0x11,%eax
f0100366:	0f 87 31 01 00 00    	ja     f010049d <cons_putc+0x296>
f010036c:	ff 24 85 30 1c 10 f0 	jmp    *-0xfefe3d0(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f0100373:	81 25 00 a0 11 f0 ff 	andl   $0xfffff0ff,0xf011a000
f010037a:	f0 ff ff 
f010037d:	e9 1b 01 00 00       	jmp    f010049d <cons_putc+0x296>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f0100382:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100387:	80 e4 f0             	and    $0xf0,%ah
f010038a:	80 cc 04             	or     $0x4,%ah
f010038d:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100392:	e9 06 01 00 00       	jmp    f010049d <cons_putc+0x296>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f0100397:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f010039c:	80 e4 f0             	and    $0xf0,%ah
f010039f:	80 cc 02             	or     $0x2,%ah
f01003a2:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01003a7:	e9 f1 00 00 00       	jmp    f010049d <cons_putc+0x296>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f01003ac:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01003b1:	80 e4 f0             	and    $0xf0,%ah
f01003b4:	80 cc 06             	or     $0x6,%ah
f01003b7:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01003bc:	e9 dc 00 00 00       	jmp    f010049d <cons_putc+0x296>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f01003c1:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01003c6:	80 e4 f0             	and    $0xf0,%ah
f01003c9:	80 cc 01             	or     $0x1,%ah
f01003cc:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01003d1:	e9 c7 00 00 00       	jmp    f010049d <cons_putc+0x296>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f01003d6:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01003db:	80 e4 f0             	and    $0xf0,%ah
f01003de:	80 cc 05             	or     $0x5,%ah
f01003e1:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01003e6:	e9 b2 00 00 00       	jmp    f010049d <cons_putc+0x296>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f01003eb:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01003f0:	80 e4 f0             	and    $0xf0,%ah
f01003f3:	80 cc 03             	or     $0x3,%ah
f01003f6:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01003fb:	e9 9d 00 00 00       	jmp    f010049d <cons_putc+0x296>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f0100400:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100405:	80 e4 f0             	and    $0xf0,%ah
f0100408:	80 cc 07             	or     $0x7,%ah
f010040b:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100410:	e9 88 00 00 00       	jmp    f010049d <cons_putc+0x296>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f0100415:	81 25 00 a0 11 f0 ff 	andl   $0xffff0fff,0xf011a000
f010041c:	0f ff ff 
f010041f:	eb 7c                	jmp    f010049d <cons_putc+0x296>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f0100421:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100426:	80 e4 0f             	and    $0xf,%ah
f0100429:	80 cc 40             	or     $0x40,%ah
f010042c:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100431:	eb 6a                	jmp    f010049d <cons_putc+0x296>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f0100433:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100438:	80 e4 0f             	and    $0xf,%ah
f010043b:	80 cc 20             	or     $0x20,%ah
f010043e:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100443:	eb 58                	jmp    f010049d <cons_putc+0x296>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f0100445:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f010044a:	80 e4 0f             	and    $0xf,%ah
f010044d:	80 cc 60             	or     $0x60,%ah
f0100450:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100455:	eb 46                	jmp    f010049d <cons_putc+0x296>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f0100457:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f010045c:	80 e4 0f             	and    $0xf,%ah
f010045f:	80 cc 10             	or     $0x10,%ah
f0100462:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100467:	eb 34                	jmp    f010049d <cons_putc+0x296>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f0100469:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f010046e:	80 e4 0f             	and    $0xf,%ah
f0100471:	80 cc 50             	or     $0x50,%ah
f0100474:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100479:	eb 22                	jmp    f010049d <cons_putc+0x296>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f010047b:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100480:	80 e4 0f             	and    $0xf,%ah
f0100483:	80 cc 30             	or     $0x30,%ah
f0100486:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f010048b:	eb 10                	jmp    f010049d <cons_putc+0x296>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f010048d:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100492:	80 e4 0f             	and    $0xf,%ah
f0100495:	80 cc 70             	or     $0x70,%ah
f0100498:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
						default:break;
					}
					Number = 0;
f010049d:	c7 05 5c a5 11 f0 00 	movl   $0x0,0xf011a55c
f01004a4:	00 00 00 
f01004a7:	e9 85 01 00 00       	jmp    f0100631 <cons_putc+0x42a>
					break;
				case 'm':
					switch (Number){
f01004ac:	a1 5c a5 11 f0       	mov    0xf011a55c,%eax
f01004b1:	83 e8 1e             	sub    $0x1e,%eax
f01004b4:	83 f8 11             	cmp    $0x11,%eax
f01004b7:	0f 87 31 01 00 00    	ja     f01005ee <cons_putc+0x3e7>
f01004bd:	ff 24 85 78 1c 10 f0 	jmp    *-0xfefe388(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f01004c4:	81 25 00 a0 11 f0 ff 	andl   $0xfffff0ff,0xf011a000
f01004cb:	f0 ff ff 
f01004ce:	e9 1b 01 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f01004d3:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01004d8:	80 e4 f0             	and    $0xf0,%ah
f01004db:	80 cc 04             	or     $0x4,%ah
f01004de:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01004e3:	e9 06 01 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f01004e8:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01004ed:	80 e4 f0             	and    $0xf0,%ah
f01004f0:	80 cc 02             	or     $0x2,%ah
f01004f3:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01004f8:	e9 f1 00 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f01004fd:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100502:	80 e4 f0             	and    $0xf0,%ah
f0100505:	80 cc 06             	or     $0x6,%ah
f0100508:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f010050d:	e9 dc 00 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f0100512:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100517:	80 e4 f0             	and    $0xf0,%ah
f010051a:	80 cc 01             	or     $0x1,%ah
f010051d:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100522:	e9 c7 00 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f0100527:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f010052c:	80 e4 f0             	and    $0xf0,%ah
f010052f:	80 cc 05             	or     $0x5,%ah
f0100532:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100537:	e9 b2 00 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f010053c:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100541:	80 e4 f0             	and    $0xf0,%ah
f0100544:	80 cc 03             	or     $0x3,%ah
f0100547:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f010054c:	e9 9d 00 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f0100551:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100556:	80 e4 f0             	and    $0xf0,%ah
f0100559:	80 cc 07             	or     $0x7,%ah
f010055c:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100561:	e9 88 00 00 00       	jmp    f01005ee <cons_putc+0x3e7>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f0100566:	81 25 00 a0 11 f0 ff 	andl   $0xffff0fff,0xf011a000
f010056d:	0f ff ff 
f0100570:	eb 7c                	jmp    f01005ee <cons_putc+0x3e7>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f0100572:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100577:	80 e4 0f             	and    $0xf,%ah
f010057a:	80 cc 40             	or     $0x40,%ah
f010057d:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100582:	eb 6a                	jmp    f01005ee <cons_putc+0x3e7>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f0100584:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f0100589:	80 e4 0f             	and    $0xf,%ah
f010058c:	80 cc 20             	or     $0x20,%ah
f010058f:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f0100594:	eb 58                	jmp    f01005ee <cons_putc+0x3e7>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f0100596:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f010059b:	80 e4 0f             	and    $0xf,%ah
f010059e:	80 cc 60             	or     $0x60,%ah
f01005a1:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01005a6:	eb 46                	jmp    f01005ee <cons_putc+0x3e7>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f01005a8:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01005ad:	80 e4 0f             	and    $0xf,%ah
f01005b0:	80 cc 10             	or     $0x10,%ah
f01005b3:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01005b8:	eb 34                	jmp    f01005ee <cons_putc+0x3e7>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f01005ba:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01005bf:	80 e4 0f             	and    $0xf,%ah
f01005c2:	80 cc 50             	or     $0x50,%ah
f01005c5:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01005ca:	eb 22                	jmp    f01005ee <cons_putc+0x3e7>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f01005cc:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01005d1:	80 e4 0f             	and    $0xf,%ah
f01005d4:	80 cc 30             	or     $0x30,%ah
f01005d7:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
f01005dc:	eb 10                	jmp    f01005ee <cons_putc+0x3e7>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f01005de:	a1 00 a0 11 f0       	mov    0xf011a000,%eax
f01005e3:	80 e4 0f             	and    $0xf,%ah
f01005e6:	80 cc 70             	or     $0x70,%ah
f01005e9:	a3 00 a0 11 f0       	mov    %eax,0xf011a000
						default:break;
					}
					Number = 0;
f01005ee:	c7 05 5c a5 11 f0 00 	movl   $0x0,0xf011a55c
f01005f5:	00 00 00 
					State = 0;
f01005f8:	c7 05 58 a5 11 f0 00 	movl   $0x0,0xf011a558
f01005ff:	00 00 00 
f0100602:	eb 2d                	jmp    f0100631 <cons_putc+0x42a>
					break;
				default:
					Number = Number * 10 + (c&0xff) - '0';
f0100604:	a1 5c a5 11 f0       	mov    0xf011a55c,%eax
f0100609:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010060c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
f0100610:	a3 5c a5 11 f0       	mov    %eax,0xf011a55c
f0100615:	eb 1a                	jmp    f0100631 <cons_putc+0x42a>
					break;
			}
		}
		else crt_buf[crt_pos++] = c;		/* write the character */
f0100617:	66 a1 54 a5 11 f0    	mov    0xf011a554,%ax
f010061d:	0f b7 c8             	movzwl %ax,%ecx
f0100620:	8b 15 50 a5 11 f0    	mov    0xf011a550,%edx
f0100626:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010062a:	40                   	inc    %eax
f010062b:	66 a3 54 a5 11 f0    	mov    %ax,0xf011a554
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100631:	66 81 3d 54 a5 11 f0 	cmpw   $0x7cf,0xf011a554
f0100638:	cf 07 
f010063a:	76 40                	jbe    f010067c <cons_putc+0x475>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010063c:	a1 50 a5 11 f0       	mov    0xf011a550,%eax
f0100641:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100648:	00 
f0100649:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010064f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100653:	89 04 24             	mov    %eax,(%esp)
f0100656:	e8 d9 10 00 00       	call   f0101734 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010065b:	8b 15 50 a5 11 f0    	mov    0xf011a550,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100661:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100666:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010066c:	40                   	inc    %eax
f010066d:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100672:	75 f2                	jne    f0100666 <cons_putc+0x45f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100674:	66 83 2d 54 a5 11 f0 	subw   $0x50,0xf011a554
f010067b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010067c:	8b 0d 4c a5 11 f0    	mov    0xf011a54c,%ecx
f0100682:	b0 0e                	mov    $0xe,%al
f0100684:	89 ca                	mov    %ecx,%edx
f0100686:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100687:	66 8b 35 54 a5 11 f0 	mov    0xf011a554,%si
f010068e:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100691:	89 f0                	mov    %esi,%eax
f0100693:	66 c1 e8 08          	shr    $0x8,%ax
f0100697:	89 da                	mov    %ebx,%edx
f0100699:	ee                   	out    %al,(%dx)
f010069a:	b0 0f                	mov    $0xf,%al
f010069c:	89 ca                	mov    %ecx,%edx
f010069e:	ee                   	out    %al,(%dx)
f010069f:	89 f0                	mov    %esi,%eax
f01006a1:	89 da                	mov    %ebx,%edx
f01006a3:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01006a4:	83 c4 2c             	add    $0x2c,%esp
f01006a7:	5b                   	pop    %ebx
f01006a8:	5e                   	pop    %esi
f01006a9:	5f                   	pop    %edi
f01006aa:	5d                   	pop    %ebp
f01006ab:	c3                   	ret    

f01006ac <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01006ac:	55                   	push   %ebp
f01006ad:	89 e5                	mov    %esp,%ebp
f01006af:	53                   	push   %ebx
f01006b0:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b3:	ba 64 00 00 00       	mov    $0x64,%edx
f01006b8:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01006b9:	0f b6 c0             	movzbl %al,%eax
f01006bc:	a8 01                	test   $0x1,%al
f01006be:	0f 84 e0 00 00 00    	je     f01007a4 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01006c4:	a8 20                	test   $0x20,%al
f01006c6:	0f 85 df 00 00 00    	jne    f01007ab <kbd_proc_data+0xff>
f01006cc:	b2 60                	mov    $0x60,%dl
f01006ce:	ec                   	in     (%dx),%al
f01006cf:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01006d1:	3c e0                	cmp    $0xe0,%al
f01006d3:	75 11                	jne    f01006e6 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f01006d5:	83 0d 48 a5 11 f0 40 	orl    $0x40,0xf011a548
		return 0;
f01006dc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e1:	e9 ca 00 00 00       	jmp    f01007b0 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f01006e6:	84 c0                	test   %al,%al
f01006e8:	79 33                	jns    f010071d <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006ea:	8b 0d 48 a5 11 f0    	mov    0xf011a548,%ecx
f01006f0:	f6 c1 40             	test   $0x40,%cl
f01006f3:	75 05                	jne    f01006fa <kbd_proc_data+0x4e>
f01006f5:	88 c2                	mov    %al,%dl
f01006f7:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01006fa:	0f b6 d2             	movzbl %dl,%edx
f01006fd:	8a 82 c0 1c 10 f0    	mov    -0xfefe340(%edx),%al
f0100703:	83 c8 40             	or     $0x40,%eax
f0100706:	0f b6 c0             	movzbl %al,%eax
f0100709:	f7 d0                	not    %eax
f010070b:	21 c1                	and    %eax,%ecx
f010070d:	89 0d 48 a5 11 f0    	mov    %ecx,0xf011a548
		return 0;
f0100713:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100718:	e9 93 00 00 00       	jmp    f01007b0 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f010071d:	8b 0d 48 a5 11 f0    	mov    0xf011a548,%ecx
f0100723:	f6 c1 40             	test   $0x40,%cl
f0100726:	74 0e                	je     f0100736 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100728:	88 c2                	mov    %al,%dl
f010072a:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010072d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100730:	89 0d 48 a5 11 f0    	mov    %ecx,0xf011a548
	}

	shift |= shiftcode[data];
f0100736:	0f b6 d2             	movzbl %dl,%edx
f0100739:	0f b6 82 c0 1c 10 f0 	movzbl -0xfefe340(%edx),%eax
f0100740:	0b 05 48 a5 11 f0    	or     0xf011a548,%eax
	shift ^= togglecode[data];
f0100746:	0f b6 8a c0 1d 10 f0 	movzbl -0xfefe240(%edx),%ecx
f010074d:	31 c8                	xor    %ecx,%eax
f010074f:	a3 48 a5 11 f0       	mov    %eax,0xf011a548

	c = charcode[shift & (CTL | SHIFT)][data];
f0100754:	89 c1                	mov    %eax,%ecx
f0100756:	83 e1 03             	and    $0x3,%ecx
f0100759:	8b 0c 8d c0 1e 10 f0 	mov    -0xfefe140(,%ecx,4),%ecx
f0100760:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100764:	a8 08                	test   $0x8,%al
f0100766:	74 18                	je     f0100780 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f0100768:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010076b:	83 fa 19             	cmp    $0x19,%edx
f010076e:	77 05                	ja     f0100775 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f0100770:	83 eb 20             	sub    $0x20,%ebx
f0100773:	eb 0b                	jmp    f0100780 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f0100775:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100778:	83 fa 19             	cmp    $0x19,%edx
f010077b:	77 03                	ja     f0100780 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f010077d:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100780:	f7 d0                	not    %eax
f0100782:	a8 06                	test   $0x6,%al
f0100784:	75 2a                	jne    f01007b0 <kbd_proc_data+0x104>
f0100786:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010078c:	75 22                	jne    f01007b0 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010078e:	c7 04 24 d0 1e 10 f0 	movl   $0xf0101ed0,(%esp)
f0100795:	e8 ac 04 00 00       	call   f0100c46 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010079a:	ba 92 00 00 00       	mov    $0x92,%edx
f010079f:	b0 03                	mov    $0x3,%al
f01007a1:	ee                   	out    %al,(%dx)
f01007a2:	eb 0c                	jmp    f01007b0 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01007a4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01007a9:	eb 05                	jmp    f01007b0 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01007ab:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01007b0:	89 d8                	mov    %ebx,%eax
f01007b2:	83 c4 14             	add    $0x14,%esp
f01007b5:	5b                   	pop    %ebx
f01007b6:	5d                   	pop    %ebp
f01007b7:	c3                   	ret    

f01007b8 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01007b8:	55                   	push   %ebp
f01007b9:	89 e5                	mov    %esp,%ebp
f01007bb:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01007be:	80 3d 20 a3 11 f0 00 	cmpb   $0x0,0xf011a320
f01007c5:	74 0a                	je     f01007d1 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01007c7:	b8 aa 01 10 f0       	mov    $0xf01001aa,%eax
f01007cc:	e8 f5 f9 ff ff       	call   f01001c6 <cons_intr>
}
f01007d1:	c9                   	leave  
f01007d2:	c3                   	ret    

f01007d3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01007d3:	55                   	push   %ebp
f01007d4:	89 e5                	mov    %esp,%ebp
f01007d6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01007d9:	b8 ac 06 10 f0       	mov    $0xf01006ac,%eax
f01007de:	e8 e3 f9 ff ff       	call   f01001c6 <cons_intr>
}
f01007e3:	c9                   	leave  
f01007e4:	c3                   	ret    

f01007e5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01007e5:	55                   	push   %ebp
f01007e6:	89 e5                	mov    %esp,%ebp
f01007e8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01007eb:	e8 c8 ff ff ff       	call   f01007b8 <serial_intr>
	kbd_intr();
f01007f0:	e8 de ff ff ff       	call   f01007d3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01007f5:	8b 15 40 a5 11 f0    	mov    0xf011a540,%edx
f01007fb:	3b 15 44 a5 11 f0    	cmp    0xf011a544,%edx
f0100801:	74 22                	je     f0100825 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100803:	0f b6 82 40 a3 11 f0 	movzbl -0xfee5cc0(%edx),%eax
f010080a:	42                   	inc    %edx
f010080b:	89 15 40 a5 11 f0    	mov    %edx,0xf011a540
		if (cons.rpos == CONSBUFSIZE)
f0100811:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100817:	75 11                	jne    f010082a <cons_getc+0x45>
			cons.rpos = 0;
f0100819:	c7 05 40 a5 11 f0 00 	movl   $0x0,0xf011a540
f0100820:	00 00 00 
f0100823:	eb 05                	jmp    f010082a <cons_getc+0x45>
		return c;
	}
	return 0;
f0100825:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010082a:	c9                   	leave  
f010082b:	c3                   	ret    

f010082c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010082c:	55                   	push   %ebp
f010082d:	89 e5                	mov    %esp,%ebp
f010082f:	57                   	push   %edi
f0100830:	56                   	push   %esi
f0100831:	53                   	push   %ebx
f0100832:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100835:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010083c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100843:	5a a5 
	if (*cp != 0xA55A) {
f0100845:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010084b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010084f:	74 11                	je     f0100862 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100851:	c7 05 4c a5 11 f0 b4 	movl   $0x3b4,0xf011a54c
f0100858:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010085b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100860:	eb 16                	jmp    f0100878 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100862:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100869:	c7 05 4c a5 11 f0 d4 	movl   $0x3d4,0xf011a54c
f0100870:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100873:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100878:	8b 0d 4c a5 11 f0    	mov    0xf011a54c,%ecx
f010087e:	b0 0e                	mov    $0xe,%al
f0100880:	89 ca                	mov    %ecx,%edx
f0100882:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100883:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100886:	89 da                	mov    %ebx,%edx
f0100888:	ec                   	in     (%dx),%al
f0100889:	0f b6 f8             	movzbl %al,%edi
f010088c:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010088f:	b0 0f                	mov    $0xf,%al
f0100891:	89 ca                	mov    %ecx,%edx
f0100893:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100894:	89 da                	mov    %ebx,%edx
f0100896:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100897:	89 35 50 a5 11 f0    	mov    %esi,0xf011a550

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010089d:	0f b6 d8             	movzbl %al,%ebx
f01008a0:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01008a2:	66 89 3d 54 a5 11 f0 	mov    %di,0xf011a554
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008a9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01008ae:	b0 00                	mov    $0x0,%al
f01008b0:	89 da                	mov    %ebx,%edx
f01008b2:	ee                   	out    %al,(%dx)
f01008b3:	b2 fb                	mov    $0xfb,%dl
f01008b5:	b0 80                	mov    $0x80,%al
f01008b7:	ee                   	out    %al,(%dx)
f01008b8:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01008bd:	b0 0c                	mov    $0xc,%al
f01008bf:	89 ca                	mov    %ecx,%edx
f01008c1:	ee                   	out    %al,(%dx)
f01008c2:	b2 f9                	mov    $0xf9,%dl
f01008c4:	b0 00                	mov    $0x0,%al
f01008c6:	ee                   	out    %al,(%dx)
f01008c7:	b2 fb                	mov    $0xfb,%dl
f01008c9:	b0 03                	mov    $0x3,%al
f01008cb:	ee                   	out    %al,(%dx)
f01008cc:	b2 fc                	mov    $0xfc,%dl
f01008ce:	b0 00                	mov    $0x0,%al
f01008d0:	ee                   	out    %al,(%dx)
f01008d1:	b2 f9                	mov    $0xf9,%dl
f01008d3:	b0 01                	mov    $0x1,%al
f01008d5:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008d6:	b2 fd                	mov    $0xfd,%dl
f01008d8:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01008d9:	3c ff                	cmp    $0xff,%al
f01008db:	0f 95 45 e7          	setne  -0x19(%ebp)
f01008df:	8a 45 e7             	mov    -0x19(%ebp),%al
f01008e2:	a2 20 a3 11 f0       	mov    %al,0xf011a320
f01008e7:	89 da                	mov    %ebx,%edx
f01008e9:	ec                   	in     (%dx),%al
f01008ea:	89 ca                	mov    %ecx,%edx
f01008ec:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01008ed:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01008f1:	75 0c                	jne    f01008ff <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f01008f3:	c7 04 24 dc 1e 10 f0 	movl   $0xf0101edc,(%esp)
f01008fa:	e8 47 03 00 00       	call   f0100c46 <cprintf>
}
f01008ff:	83 c4 2c             	add    $0x2c,%esp
f0100902:	5b                   	pop    %ebx
f0100903:	5e                   	pop    %esi
f0100904:	5f                   	pop    %edi
f0100905:	5d                   	pop    %ebp
f0100906:	c3                   	ret    

f0100907 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100907:	55                   	push   %ebp
f0100908:	89 e5                	mov    %esp,%ebp
f010090a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010090d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100910:	e8 f2 f8 ff ff       	call   f0100207 <cons_putc>
}
f0100915:	c9                   	leave  
f0100916:	c3                   	ret    

f0100917 <getchar>:

int
getchar(void)
{
f0100917:	55                   	push   %ebp
f0100918:	89 e5                	mov    %esp,%ebp
f010091a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010091d:	e8 c3 fe ff ff       	call   f01007e5 <cons_getc>
f0100922:	85 c0                	test   %eax,%eax
f0100924:	74 f7                	je     f010091d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100926:	c9                   	leave  
f0100927:	c3                   	ret    

f0100928 <iscons>:

int
iscons(int fdnum)
{
f0100928:	55                   	push   %ebp
f0100929:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010092b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100930:	5d                   	pop    %ebp
f0100931:	c3                   	ret    
	...

f0100934 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100934:	55                   	push   %ebp
f0100935:	89 e5                	mov    %esp,%ebp
f0100937:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010093a:	c7 04 24 f9 1e 10 f0 	movl   $0xf0101ef9,(%esp)
f0100941:	e8 00 03 00 00       	call   f0100c46 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100946:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010094d:	00 
f010094e:	c7 04 24 a0 1f 10 f0 	movl   $0xf0101fa0,(%esp)
f0100955:	e8 ec 02 00 00       	call   f0100c46 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010095a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100961:	00 
f0100962:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100969:	f0 
f010096a:	c7 04 24 c8 1f 10 f0 	movl   $0xf0101fc8,(%esp)
f0100971:	e8 d0 02 00 00       	call   f0100c46 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100976:	c7 44 24 08 2e 1b 10 	movl   $0x101b2e,0x8(%esp)
f010097d:	00 
f010097e:	c7 44 24 04 2e 1b 10 	movl   $0xf0101b2e,0x4(%esp)
f0100985:	f0 
f0100986:	c7 04 24 ec 1f 10 f0 	movl   $0xf0101fec,(%esp)
f010098d:	e8 b4 02 00 00       	call   f0100c46 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100992:	c7 44 24 08 20 a3 11 	movl   $0x11a320,0x8(%esp)
f0100999:	00 
f010099a:	c7 44 24 04 20 a3 11 	movl   $0xf011a320,0x4(%esp)
f01009a1:	f0 
f01009a2:	c7 04 24 10 20 10 f0 	movl   $0xf0102010,(%esp)
f01009a9:	e8 98 02 00 00       	call   f0100c46 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01009ae:	c7 44 24 08 60 a9 11 	movl   $0x11a960,0x8(%esp)
f01009b5:	00 
f01009b6:	c7 44 24 04 60 a9 11 	movl   $0xf011a960,0x4(%esp)
f01009bd:	f0 
f01009be:	c7 04 24 34 20 10 f0 	movl   $0xf0102034,(%esp)
f01009c5:	e8 7c 02 00 00       	call   f0100c46 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01009ca:	b8 5f ad 11 f0       	mov    $0xf011ad5f,%eax
f01009cf:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01009d4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01009d9:	89 c2                	mov    %eax,%edx
f01009db:	85 c0                	test   %eax,%eax
f01009dd:	79 06                	jns    f01009e5 <mon_kerninfo+0xb1>
f01009df:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01009e5:	c1 fa 0a             	sar    $0xa,%edx
f01009e8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009ec:	c7 04 24 58 20 10 f0 	movl   $0xf0102058,(%esp)
f01009f3:	e8 4e 02 00 00       	call   f0100c46 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01009f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01009fd:	c9                   	leave  
f01009fe:	c3                   	ret    

f01009ff <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01009ff:	55                   	push   %ebp
f0100a00:	89 e5                	mov    %esp,%ebp
f0100a02:	53                   	push   %ebx
f0100a03:	83 ec 14             	sub    $0x14,%esp
f0100a06:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100a0b:	8b 83 84 21 10 f0    	mov    -0xfefde7c(%ebx),%eax
f0100a11:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a15:	8b 83 80 21 10 f0    	mov    -0xfefde80(%ebx),%eax
f0100a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a1f:	c7 04 24 12 1f 10 f0 	movl   $0xf0101f12,(%esp)
f0100a26:	e8 1b 02 00 00       	call   f0100c46 <cprintf>
f0100a2b:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100a2e:	83 fb 24             	cmp    $0x24,%ebx
f0100a31:	75 d8                	jne    f0100a0b <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100a33:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a38:	83 c4 14             	add    $0x14,%esp
f0100a3b:	5b                   	pop    %ebx
f0100a3c:	5d                   	pop    %ebp
f0100a3d:	c3                   	ret    

f0100a3e <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a3e:	55                   	push   %ebp
f0100a3f:	89 e5                	mov    %esp,%ebp
f0100a41:	57                   	push   %edi
f0100a42:	56                   	push   %esi
f0100a43:	53                   	push   %ebx
f0100a44:	83 ec 6c             	sub    $0x6c,%esp
	cprintf("\033[34;45mThe parameters are: 34 and 45\n");
	cprintf("\033[35;46mThe parameters are: 35 and 46\n");
	cprintf("\033[36;47mThe parameters are: 36 and 47\n");
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
f0100a47:	c7 04 24 1b 1f 10 f0 	movl   $0xf0101f1b,(%esp)
f0100a4e:	e8 f3 01 00 00       	call   f0100c46 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a53:	89 eb                	mov    %ebp,%ebx
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
		eip = *((uint32_t *) ebp + 1);
		debuginfo_eip(eip, &info);
f0100a55:	8d 7d d0             	lea    -0x30(%ebp),%edi
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100a58:	eb 6d                	jmp    f0100ac7 <mon_backtrace+0x89>
		eip = *((uint32_t *) ebp + 1);
f0100a5a:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f0100a5d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100a61:	89 34 24             	mov    %esi,(%esp)
f0100a64:	e8 d7 02 00 00       	call   f0100d40 <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n         %s:%d: %.*s+%d\n",
f0100a69:	89 f0                	mov    %esi,%eax
f0100a6b:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100a6e:	89 44 24 30          	mov    %eax,0x30(%esp)
f0100a72:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a75:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100a79:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a7c:	89 44 24 28          	mov    %eax,0x28(%esp)
f0100a80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100a83:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100a87:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100a8a:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100a8e:	8b 43 18             	mov    0x18(%ebx),%eax
f0100a91:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100a95:	8b 43 14             	mov    0x14(%ebx),%eax
f0100a98:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100a9c:	8b 43 10             	mov    0x10(%ebx),%eax
f0100a9f:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100aa3:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100aa6:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100aaa:	8b 43 08             	mov    0x8(%ebx),%eax
f0100aad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ab1:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100ab5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ab9:	c7 04 24 84 20 10 f0 	movl   $0xf0102084,(%esp)
f0100ac0:	e8 81 01 00 00       	call   f0100c46 <cprintf>
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100ac5:	8b 1b                	mov    (%ebx),%ebx
f0100ac7:	85 db                	test   %ebx,%ebx
f0100ac9:	75 8f                	jne    f0100a5a <mon_backtrace+0x1c>
				info.eip_fn_namelen,
				info.eip_fn_name,
				eip - info.eip_fn_addr);
	}
	return 0;
}
f0100acb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ad0:	83 c4 6c             	add    $0x6c,%esp
f0100ad3:	5b                   	pop    %ebx
f0100ad4:	5e                   	pop    %esi
f0100ad5:	5f                   	pop    %edi
f0100ad6:	5d                   	pop    %ebp
f0100ad7:	c3                   	ret    

f0100ad8 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ad8:	55                   	push   %ebp
f0100ad9:	89 e5                	mov    %esp,%ebp
f0100adb:	57                   	push   %edi
f0100adc:	56                   	push   %esi
f0100add:	53                   	push   %ebx
f0100ade:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ae1:	c7 04 24 d4 20 10 f0 	movl   $0xf01020d4,(%esp)
f0100ae8:	e8 59 01 00 00       	call   f0100c46 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100aed:	c7 04 24 f8 20 10 f0 	movl   $0xf01020f8,(%esp)
f0100af4:	e8 4d 01 00 00       	call   f0100c46 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100af9:	c7 04 24 2c 1f 10 f0 	movl   $0xf0101f2c,(%esp)
f0100b00:	e8 bb 09 00 00       	call   f01014c0 <readline>
f0100b05:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b07:	85 c0                	test   %eax,%eax
f0100b09:	74 ee                	je     f0100af9 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b0b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b12:	be 00 00 00 00       	mov    $0x0,%esi
f0100b17:	eb 04                	jmp    f0100b1d <monitor+0x45>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b19:	c6 03 00             	movb   $0x0,(%ebx)
f0100b1c:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b1d:	8a 03                	mov    (%ebx),%al
f0100b1f:	84 c0                	test   %al,%al
f0100b21:	74 5e                	je     f0100b81 <monitor+0xa9>
f0100b23:	0f be c0             	movsbl %al,%eax
f0100b26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b2a:	c7 04 24 30 1f 10 f0 	movl   $0xf0101f30,(%esp)
f0100b31:	e8 7f 0b 00 00       	call   f01016b5 <strchr>
f0100b36:	85 c0                	test   %eax,%eax
f0100b38:	75 df                	jne    f0100b19 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100b3a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b3d:	74 42                	je     f0100b81 <monitor+0xa9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b3f:	83 fe 0f             	cmp    $0xf,%esi
f0100b42:	75 16                	jne    f0100b5a <monitor+0x82>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b44:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b4b:	00 
f0100b4c:	c7 04 24 35 1f 10 f0 	movl   $0xf0101f35,(%esp)
f0100b53:	e8 ee 00 00 00       	call   f0100c46 <cprintf>
f0100b58:	eb 9f                	jmp    f0100af9 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100b5a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b5e:	46                   	inc    %esi
f0100b5f:	eb 01                	jmp    f0100b62 <monitor+0x8a>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100b61:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b62:	8a 03                	mov    (%ebx),%al
f0100b64:	84 c0                	test   %al,%al
f0100b66:	74 b5                	je     f0100b1d <monitor+0x45>
f0100b68:	0f be c0             	movsbl %al,%eax
f0100b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b6f:	c7 04 24 30 1f 10 f0 	movl   $0xf0101f30,(%esp)
f0100b76:	e8 3a 0b 00 00       	call   f01016b5 <strchr>
f0100b7b:	85 c0                	test   %eax,%eax
f0100b7d:	74 e2                	je     f0100b61 <monitor+0x89>
f0100b7f:	eb 9c                	jmp    f0100b1d <monitor+0x45>
			buf++;
	}
	argv[argc] = 0;
f0100b81:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b88:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100b89:	85 f6                	test   %esi,%esi
f0100b8b:	0f 84 68 ff ff ff    	je     f0100af9 <monitor+0x21>
f0100b91:	bb 80 21 10 f0       	mov    $0xf0102180,%ebx
f0100b96:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b9b:	8b 03                	mov    (%ebx),%eax
f0100b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ba1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ba4:	89 04 24             	mov    %eax,(%esp)
f0100ba7:	e8 b6 0a 00 00       	call   f0101662 <strcmp>
f0100bac:	85 c0                	test   %eax,%eax
f0100bae:	75 24                	jne    f0100bd4 <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f0100bb0:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100bb3:	8b 55 08             	mov    0x8(%ebp),%edx
f0100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100bba:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100bbd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100bc1:	89 34 24             	mov    %esi,(%esp)
f0100bc4:	ff 14 85 88 21 10 f0 	call   *-0xfefde78(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100bcb:	85 c0                	test   %eax,%eax
f0100bcd:	78 26                	js     f0100bf5 <monitor+0x11d>
f0100bcf:	e9 25 ff ff ff       	jmp    f0100af9 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100bd4:	47                   	inc    %edi
f0100bd5:	83 c3 0c             	add    $0xc,%ebx
f0100bd8:	83 ff 03             	cmp    $0x3,%edi
f0100bdb:	75 be                	jne    f0100b9b <monitor+0xc3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100bdd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100be0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be4:	c7 04 24 52 1f 10 f0 	movl   $0xf0101f52,(%esp)
f0100beb:	e8 56 00 00 00       	call   f0100c46 <cprintf>
f0100bf0:	e9 04 ff ff ff       	jmp    f0100af9 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100bf5:	83 c4 5c             	add    $0x5c,%esp
f0100bf8:	5b                   	pop    %ebx
f0100bf9:	5e                   	pop    %esi
f0100bfa:	5f                   	pop    %edi
f0100bfb:	5d                   	pop    %ebp
f0100bfc:	c3                   	ret    
f0100bfd:	00 00                	add    %al,(%eax)
	...

f0100c00 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100c00:	55                   	push   %ebp
f0100c01:	89 e5                	mov    %esp,%ebp
f0100c03:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100c06:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c09:	89 04 24             	mov    %eax,(%esp)
f0100c0c:	e8 f6 fc ff ff       	call   f0100907 <cputchar>
	*cnt++;
}
f0100c11:	c9                   	leave  
f0100c12:	c3                   	ret    

f0100c13 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100c13:	55                   	push   %ebp
f0100c14:	89 e5                	mov    %esp,%ebp
f0100c16:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100c19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100c20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c23:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c27:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c2a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c35:	c7 04 24 00 0c 10 f0 	movl   $0xf0100c00,(%esp)
f0100c3c:	e8 69 04 00 00       	call   f01010aa <vprintfmt>
	return cnt;
}
f0100c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c44:	c9                   	leave  
f0100c45:	c3                   	ret    

f0100c46 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100c46:	55                   	push   %ebp
f0100c47:	89 e5                	mov    %esp,%ebp
f0100c49:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100c4c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c53:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c56:	89 04 24             	mov    %eax,(%esp)
f0100c59:	e8 b5 ff ff ff       	call   f0100c13 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100c5e:	c9                   	leave  
f0100c5f:	c3                   	ret    

f0100c60 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100c60:	55                   	push   %ebp
f0100c61:	89 e5                	mov    %esp,%ebp
f0100c63:	57                   	push   %edi
f0100c64:	56                   	push   %esi
f0100c65:	53                   	push   %ebx
f0100c66:	83 ec 10             	sub    $0x10,%esp
f0100c69:	89 c3                	mov    %eax,%ebx
f0100c6b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100c6e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100c71:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100c74:	8b 0a                	mov    (%edx),%ecx
f0100c76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c79:	8b 00                	mov    (%eax),%eax
f0100c7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c7e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100c85:	eb 77                	jmp    f0100cfe <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0100c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c8a:	01 c8                	add    %ecx,%eax
f0100c8c:	bf 02 00 00 00       	mov    $0x2,%edi
f0100c91:	99                   	cltd   
f0100c92:	f7 ff                	idiv   %edi
f0100c94:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100c96:	eb 01                	jmp    f0100c99 <stab_binsearch+0x39>
			m--;
f0100c98:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100c99:	39 ca                	cmp    %ecx,%edx
f0100c9b:	7c 1d                	jl     f0100cba <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100c9d:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ca0:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100ca5:	39 f7                	cmp    %esi,%edi
f0100ca7:	75 ef                	jne    f0100c98 <stab_binsearch+0x38>
f0100ca9:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100cac:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100caf:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100cb3:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100cb6:	73 18                	jae    f0100cd0 <stab_binsearch+0x70>
f0100cb8:	eb 05                	jmp    f0100cbf <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100cba:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0100cbd:	eb 3f                	jmp    f0100cfe <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100cbf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100cc2:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0100cc4:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100cc7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100cce:	eb 2e                	jmp    f0100cfe <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100cd0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100cd3:	76 15                	jbe    f0100cea <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100cd5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100cd8:	4f                   	dec    %edi
f0100cd9:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100cdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cdf:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ce1:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100ce8:	eb 14                	jmp    f0100cfe <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100cea:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100ced:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100cf0:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0100cf2:	ff 45 0c             	incl   0xc(%ebp)
f0100cf5:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100cf7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100cfe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0100d01:	7e 84                	jle    f0100c87 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100d03:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100d07:	75 0d                	jne    f0100d16 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0100d09:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100d0c:	8b 02                	mov    (%edx),%eax
f0100d0e:	48                   	dec    %eax
f0100d0f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d12:	89 01                	mov    %eax,(%ecx)
f0100d14:	eb 22                	jmp    f0100d38 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d16:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d19:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100d1b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100d1e:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d20:	eb 01                	jmp    f0100d23 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100d22:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d23:	39 c1                	cmp    %eax,%ecx
f0100d25:	7d 0c                	jge    f0100d33 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100d27:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100d2a:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100d2f:	39 f2                	cmp    %esi,%edx
f0100d31:	75 ef                	jne    f0100d22 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100d33:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100d36:	89 02                	mov    %eax,(%edx)
	}
}
f0100d38:	83 c4 10             	add    $0x10,%esp
f0100d3b:	5b                   	pop    %ebx
f0100d3c:	5e                   	pop    %esi
f0100d3d:	5f                   	pop    %edi
f0100d3e:	5d                   	pop    %ebp
f0100d3f:	c3                   	ret    

f0100d40 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100d40:	55                   	push   %ebp
f0100d41:	89 e5                	mov    %esp,%ebp
f0100d43:	57                   	push   %edi
f0100d44:	56                   	push   %esi
f0100d45:	53                   	push   %ebx
f0100d46:	83 ec 4c             	sub    $0x4c,%esp
f0100d49:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100d4f:	c7 03 a4 21 10 f0    	movl   $0xf01021a4,(%ebx)
	info->eip_line = 0;
f0100d55:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100d5c:	c7 43 08 a4 21 10 f0 	movl   $0xf01021a4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100d63:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100d6a:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100d6d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100d74:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100d7a:	76 12                	jbe    f0100d8e <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d7c:	b8 e5 f6 10 f0       	mov    $0xf010f6e5,%eax
f0100d81:	3d a1 6b 10 f0       	cmp    $0xf0106ba1,%eax
f0100d86:	0f 86 a7 01 00 00    	jbe    f0100f33 <debuginfo_eip+0x1f3>
f0100d8c:	eb 1c                	jmp    f0100daa <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100d8e:	c7 44 24 08 ae 21 10 	movl   $0xf01021ae,0x8(%esp)
f0100d95:	f0 
f0100d96:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100d9d:	00 
f0100d9e:	c7 04 24 bb 21 10 f0 	movl   $0xf01021bb,(%esp)
f0100da5:	e8 4e f3 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100daf:	80 3d e4 f6 10 f0 00 	cmpb   $0x0,0xf010f6e4
f0100db6:	0f 85 83 01 00 00    	jne    f0100f3f <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100dbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100dc3:	b8 a0 6b 10 f0       	mov    $0xf0106ba0,%eax
f0100dc8:	2d dc 23 10 f0       	sub    $0xf01023dc,%eax
f0100dcd:	c1 f8 02             	sar    $0x2,%eax
f0100dd0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100dd6:	48                   	dec    %eax
f0100dd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100dda:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100dde:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100de5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100de8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100deb:	b8 dc 23 10 f0       	mov    $0xf01023dc,%eax
f0100df0:	e8 6b fe ff ff       	call   f0100c60 <stab_binsearch>
	if (lfile == 0)
f0100df5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100df8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100dfd:	85 d2                	test   %edx,%edx
f0100dff:	0f 84 3a 01 00 00    	je     f0100f3f <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100e05:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100e08:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100e0e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e12:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100e19:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100e1c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e1f:	b8 dc 23 10 f0       	mov    $0xf01023dc,%eax
f0100e24:	e8 37 fe ff ff       	call   f0100c60 <stab_binsearch>

	if (lfun <= rfun) {
f0100e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e2c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100e2f:	39 d0                	cmp    %edx,%eax
f0100e31:	7f 3e                	jg     f0100e71 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100e33:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100e36:	8d b9 dc 23 10 f0    	lea    -0xfefdc24(%ecx),%edi
f0100e3c:	8b 89 dc 23 10 f0    	mov    -0xfefdc24(%ecx),%ecx
f0100e42:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100e45:	b9 e5 f6 10 f0       	mov    $0xf010f6e5,%ecx
f0100e4a:	81 e9 a1 6b 10 f0    	sub    $0xf0106ba1,%ecx
f0100e50:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0100e53:	73 0c                	jae    f0100e61 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100e55:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0100e58:	81 c1 a1 6b 10 f0    	add    $0xf0106ba1,%ecx
f0100e5e:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100e61:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100e64:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100e67:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100e69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100e6c:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100e6f:	eb 0f                	jmp    f0100e80 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100e71:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100e80:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100e87:	00 
f0100e88:	8b 43 08             	mov    0x8(%ebx),%eax
f0100e8b:	89 04 24             	mov    %eax,(%esp)
f0100e8e:	e8 3f 08 00 00       	call   f01016d2 <strfind>
f0100e93:	2b 43 08             	sub    0x8(%ebx),%eax
f0100e96:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100e99:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e9d:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100ea4:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100ea7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100eaa:	b8 dc 23 10 f0       	mov    $0xf01023dc,%eax
f0100eaf:	e8 ac fd ff ff       	call   f0100c60 <stab_binsearch>
	if (lline <= rline){
f0100eb4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	}
	else return -1;
f0100eb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline){
f0100ebc:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100ebf:	7f 7e                	jg     f0100f3f <debuginfo_eip+0x1ff>
		info->eip_line = stabs[lline].n_desc;
f0100ec1:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100ec4:	0f b7 82 e2 23 10 f0 	movzwl -0xfefdc1e(%edx),%eax
f0100ecb:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ece:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ed1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ed4:	eb 01                	jmp    f0100ed7 <debuginfo_eip+0x197>
f0100ed6:	48                   	dec    %eax
f0100ed7:	89 c6                	mov    %eax,%esi
f0100ed9:	39 c7                	cmp    %eax,%edi
f0100edb:	7f 26                	jg     f0100f03 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0100edd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ee0:	8d 0c 95 dc 23 10 f0 	lea    -0xfefdc24(,%edx,4),%ecx
f0100ee7:	8a 51 04             	mov    0x4(%ecx),%dl
f0100eea:	80 fa 84             	cmp    $0x84,%dl
f0100eed:	74 58                	je     f0100f47 <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100eef:	80 fa 64             	cmp    $0x64,%dl
f0100ef2:	75 e2                	jne    f0100ed6 <debuginfo_eip+0x196>
f0100ef4:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0100ef8:	74 dc                	je     f0100ed6 <debuginfo_eip+0x196>
f0100efa:	eb 4b                	jmp    f0100f47 <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100efc:	05 a1 6b 10 f0       	add    $0xf0106ba1,%eax
f0100f01:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100f03:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100f06:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100f09:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100f0e:	39 d1                	cmp    %edx,%ecx
f0100f10:	7d 2d                	jge    f0100f3f <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f0100f12:	8d 41 01             	lea    0x1(%ecx),%eax
f0100f15:	eb 03                	jmp    f0100f1a <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100f17:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100f1a:	39 d0                	cmp    %edx,%eax
f0100f1c:	7d 1c                	jge    f0100f3a <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100f1e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100f21:	40                   	inc    %eax
f0100f22:	80 3c 8d e0 23 10 f0 	cmpb   $0xa0,-0xfefdc20(,%ecx,4)
f0100f29:	a0 
f0100f2a:	74 eb                	je     f0100f17 <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100f2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f31:	eb 0c                	jmp    f0100f3f <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100f33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f38:	eb 05                	jmp    f0100f3f <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100f3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f3f:	83 c4 4c             	add    $0x4c,%esp
f0100f42:	5b                   	pop    %ebx
f0100f43:	5e                   	pop    %esi
f0100f44:	5f                   	pop    %edi
f0100f45:	5d                   	pop    %ebp
f0100f46:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f47:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100f4a:	8b 86 dc 23 10 f0    	mov    -0xfefdc24(%esi),%eax
f0100f50:	ba e5 f6 10 f0       	mov    $0xf010f6e5,%edx
f0100f55:	81 ea a1 6b 10 f0    	sub    $0xf0106ba1,%edx
f0100f5b:	39 d0                	cmp    %edx,%eax
f0100f5d:	72 9d                	jb     f0100efc <debuginfo_eip+0x1bc>
f0100f5f:	eb a2                	jmp    f0100f03 <debuginfo_eip+0x1c3>
f0100f61:	00 00                	add    %al,(%eax)
	...

f0100f64 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f64:	55                   	push   %ebp
f0100f65:	89 e5                	mov    %esp,%ebp
f0100f67:	57                   	push   %edi
f0100f68:	56                   	push   %esi
f0100f69:	53                   	push   %ebx
f0100f6a:	83 ec 3c             	sub    $0x3c,%esp
f0100f6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f70:	89 d7                	mov    %edx,%edi
f0100f72:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f75:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f7e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f81:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f84:	85 c0                	test   %eax,%eax
f0100f86:	75 08                	jne    f0100f90 <printnum+0x2c>
f0100f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f8b:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100f8e:	77 57                	ja     f0100fe7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f90:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100f94:	4b                   	dec    %ebx
f0100f95:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100f99:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f9c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fa0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100fa4:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100fa8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100faf:	00 
f0100fb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100fb3:	89 04 24             	mov    %eax,(%esp)
f0100fb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fbd:	e8 1e 09 00 00       	call   f01018e0 <__udivdi3>
f0100fc2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100fc6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100fca:	89 04 24             	mov    %eax,(%esp)
f0100fcd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100fd1:	89 fa                	mov    %edi,%edx
f0100fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fd6:	e8 89 ff ff ff       	call   f0100f64 <printnum>
f0100fdb:	eb 0f                	jmp    f0100fec <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100fdd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fe1:	89 34 24             	mov    %esi,(%esp)
f0100fe4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100fe7:	4b                   	dec    %ebx
f0100fe8:	85 db                	test   %ebx,%ebx
f0100fea:	7f f1                	jg     f0100fdd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ff0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100ff4:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ffb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101002:	00 
f0101003:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101006:	89 04 24             	mov    %eax,(%esp)
f0101009:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010100c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101010:	e8 eb 09 00 00       	call   f0101a00 <__umoddi3>
f0101015:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101019:	0f be 80 c9 21 10 f0 	movsbl -0xfefde37(%eax),%eax
f0101020:	89 04 24             	mov    %eax,(%esp)
f0101023:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0101026:	83 c4 3c             	add    $0x3c,%esp
f0101029:	5b                   	pop    %ebx
f010102a:	5e                   	pop    %esi
f010102b:	5f                   	pop    %edi
f010102c:	5d                   	pop    %ebp
f010102d:	c3                   	ret    

f010102e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010102e:	55                   	push   %ebp
f010102f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101031:	83 fa 01             	cmp    $0x1,%edx
f0101034:	7e 0e                	jle    f0101044 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101036:	8b 10                	mov    (%eax),%edx
f0101038:	8d 4a 08             	lea    0x8(%edx),%ecx
f010103b:	89 08                	mov    %ecx,(%eax)
f010103d:	8b 02                	mov    (%edx),%eax
f010103f:	8b 52 04             	mov    0x4(%edx),%edx
f0101042:	eb 22                	jmp    f0101066 <getuint+0x38>
	else if (lflag)
f0101044:	85 d2                	test   %edx,%edx
f0101046:	74 10                	je     f0101058 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101048:	8b 10                	mov    (%eax),%edx
f010104a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010104d:	89 08                	mov    %ecx,(%eax)
f010104f:	8b 02                	mov    (%edx),%eax
f0101051:	ba 00 00 00 00       	mov    $0x0,%edx
f0101056:	eb 0e                	jmp    f0101066 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101058:	8b 10                	mov    (%eax),%edx
f010105a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010105d:	89 08                	mov    %ecx,(%eax)
f010105f:	8b 02                	mov    (%edx),%eax
f0101061:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101066:	5d                   	pop    %ebp
f0101067:	c3                   	ret    

f0101068 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101068:	55                   	push   %ebp
f0101069:	89 e5                	mov    %esp,%ebp
f010106b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010106e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0101071:	8b 10                	mov    (%eax),%edx
f0101073:	3b 50 04             	cmp    0x4(%eax),%edx
f0101076:	73 08                	jae    f0101080 <sprintputch+0x18>
		*b->buf++ = ch;
f0101078:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010107b:	88 0a                	mov    %cl,(%edx)
f010107d:	42                   	inc    %edx
f010107e:	89 10                	mov    %edx,(%eax)
}
f0101080:	5d                   	pop    %ebp
f0101081:	c3                   	ret    

f0101082 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101082:	55                   	push   %ebp
f0101083:	89 e5                	mov    %esp,%ebp
f0101085:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0101088:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010108b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010108f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101092:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101096:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101099:	89 44 24 04          	mov    %eax,0x4(%esp)
f010109d:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a0:	89 04 24             	mov    %eax,(%esp)
f01010a3:	e8 02 00 00 00       	call   f01010aa <vprintfmt>
	va_end(ap);
}
f01010a8:	c9                   	leave  
f01010a9:	c3                   	ret    

f01010aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01010aa:	55                   	push   %ebp
f01010ab:	89 e5                	mov    %esp,%ebp
f01010ad:	57                   	push   %edi
f01010ae:	56                   	push   %esi
f01010af:	53                   	push   %ebx
f01010b0:	83 ec 4c             	sub    $0x4c,%esp
f01010b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010b6:	8b 75 10             	mov    0x10(%ebp),%esi
f01010b9:	eb 12                	jmp    f01010cd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01010bb:	85 c0                	test   %eax,%eax
f01010bd:	0f 84 6b 03 00 00    	je     f010142e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f01010c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010c7:	89 04 24             	mov    %eax,(%esp)
f01010ca:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01010cd:	0f b6 06             	movzbl (%esi),%eax
f01010d0:	46                   	inc    %esi
f01010d1:	83 f8 25             	cmp    $0x25,%eax
f01010d4:	75 e5                	jne    f01010bb <vprintfmt+0x11>
f01010d6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01010da:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01010e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01010e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01010ed:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010f2:	eb 26                	jmp    f010111a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010f4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01010f7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01010fb:	eb 1d                	jmp    f010111a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101100:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0101104:	eb 14                	jmp    f010111a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101106:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0101109:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101110:	eb 08                	jmp    f010111a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101112:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0101115:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010111a:	0f b6 06             	movzbl (%esi),%eax
f010111d:	8d 56 01             	lea    0x1(%esi),%edx
f0101120:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101123:	8a 16                	mov    (%esi),%dl
f0101125:	83 ea 23             	sub    $0x23,%edx
f0101128:	80 fa 55             	cmp    $0x55,%dl
f010112b:	0f 87 e1 02 00 00    	ja     f0101412 <vprintfmt+0x368>
f0101131:	0f b6 d2             	movzbl %dl,%edx
f0101134:	ff 24 95 58 22 10 f0 	jmp    *-0xfefdda8(,%edx,4)
f010113b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010113e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101143:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0101146:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010114a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010114d:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101150:	83 fa 09             	cmp    $0x9,%edx
f0101153:	77 2a                	ja     f010117f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101155:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101156:	eb eb                	jmp    f0101143 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101158:	8b 45 14             	mov    0x14(%ebp),%eax
f010115b:	8d 50 04             	lea    0x4(%eax),%edx
f010115e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101161:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101163:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101166:	eb 17                	jmp    f010117f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0101168:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010116c:	78 98                	js     f0101106 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010116e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101171:	eb a7                	jmp    f010111a <vprintfmt+0x70>
f0101173:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101176:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f010117d:	eb 9b                	jmp    f010111a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f010117f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101183:	79 95                	jns    f010111a <vprintfmt+0x70>
f0101185:	eb 8b                	jmp    f0101112 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101187:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101188:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010118b:	eb 8d                	jmp    f010111a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010118d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101190:	8d 50 04             	lea    0x4(%eax),%edx
f0101193:	89 55 14             	mov    %edx,0x14(%ebp)
f0101196:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010119a:	8b 00                	mov    (%eax),%eax
f010119c:	89 04 24             	mov    %eax,(%esp)
f010119f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01011a5:	e9 23 ff ff ff       	jmp    f01010cd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01011aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ad:	8d 50 04             	lea    0x4(%eax),%edx
f01011b0:	89 55 14             	mov    %edx,0x14(%ebp)
f01011b3:	8b 00                	mov    (%eax),%eax
f01011b5:	85 c0                	test   %eax,%eax
f01011b7:	79 02                	jns    f01011bb <vprintfmt+0x111>
f01011b9:	f7 d8                	neg    %eax
f01011bb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01011bd:	83 f8 06             	cmp    $0x6,%eax
f01011c0:	7f 0b                	jg     f01011cd <vprintfmt+0x123>
f01011c2:	8b 04 85 b0 23 10 f0 	mov    -0xfefdc50(,%eax,4),%eax
f01011c9:	85 c0                	test   %eax,%eax
f01011cb:	75 23                	jne    f01011f0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01011cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01011d1:	c7 44 24 08 e1 21 10 	movl   $0xf01021e1,0x8(%esp)
f01011d8:	f0 
f01011d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01011e0:	89 04 24             	mov    %eax,(%esp)
f01011e3:	e8 9a fe ff ff       	call   f0101082 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01011eb:	e9 dd fe ff ff       	jmp    f01010cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01011f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011f4:	c7 44 24 08 ea 21 10 	movl   $0xf01021ea,0x8(%esp)
f01011fb:	f0 
f01011fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101200:	8b 55 08             	mov    0x8(%ebp),%edx
f0101203:	89 14 24             	mov    %edx,(%esp)
f0101206:	e8 77 fe ff ff       	call   f0101082 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010120b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010120e:	e9 ba fe ff ff       	jmp    f01010cd <vprintfmt+0x23>
f0101213:	89 f9                	mov    %edi,%ecx
f0101215:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101218:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010121b:	8b 45 14             	mov    0x14(%ebp),%eax
f010121e:	8d 50 04             	lea    0x4(%eax),%edx
f0101221:	89 55 14             	mov    %edx,0x14(%ebp)
f0101224:	8b 30                	mov    (%eax),%esi
f0101226:	85 f6                	test   %esi,%esi
f0101228:	75 05                	jne    f010122f <vprintfmt+0x185>
				p = "(null)";
f010122a:	be da 21 10 f0       	mov    $0xf01021da,%esi
			if (width > 0 && padc != '-')
f010122f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101233:	0f 8e 84 00 00 00    	jle    f01012bd <vprintfmt+0x213>
f0101239:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010123d:	74 7e                	je     f01012bd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f010123f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101243:	89 34 24             	mov    %esi,(%esp)
f0101246:	e8 53 03 00 00       	call   f010159e <strnlen>
f010124b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010124e:	29 c2                	sub    %eax,%edx
f0101250:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0101253:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0101257:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010125a:	89 7d cc             	mov    %edi,-0x34(%ebp)
f010125d:	89 de                	mov    %ebx,%esi
f010125f:	89 d3                	mov    %edx,%ebx
f0101261:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101263:	eb 0b                	jmp    f0101270 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0101265:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101269:	89 3c 24             	mov    %edi,(%esp)
f010126c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010126f:	4b                   	dec    %ebx
f0101270:	85 db                	test   %ebx,%ebx
f0101272:	7f f1                	jg     f0101265 <vprintfmt+0x1bb>
f0101274:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0101277:	89 f3                	mov    %esi,%ebx
f0101279:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f010127c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010127f:	85 c0                	test   %eax,%eax
f0101281:	79 05                	jns    f0101288 <vprintfmt+0x1de>
f0101283:	b8 00 00 00 00       	mov    $0x0,%eax
f0101288:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010128b:	29 c2                	sub    %eax,%edx
f010128d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101290:	eb 2b                	jmp    f01012bd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101292:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101296:	74 18                	je     f01012b0 <vprintfmt+0x206>
f0101298:	8d 50 e0             	lea    -0x20(%eax),%edx
f010129b:	83 fa 5e             	cmp    $0x5e,%edx
f010129e:	76 10                	jbe    f01012b0 <vprintfmt+0x206>
					putch('?', putdat);
f01012a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01012ab:	ff 55 08             	call   *0x8(%ebp)
f01012ae:	eb 0a                	jmp    f01012ba <vprintfmt+0x210>
				else
					putch(ch, putdat);
f01012b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012b4:	89 04 24             	mov    %eax,(%esp)
f01012b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012ba:	ff 4d e4             	decl   -0x1c(%ebp)
f01012bd:	0f be 06             	movsbl (%esi),%eax
f01012c0:	46                   	inc    %esi
f01012c1:	85 c0                	test   %eax,%eax
f01012c3:	74 21                	je     f01012e6 <vprintfmt+0x23c>
f01012c5:	85 ff                	test   %edi,%edi
f01012c7:	78 c9                	js     f0101292 <vprintfmt+0x1e8>
f01012c9:	4f                   	dec    %edi
f01012ca:	79 c6                	jns    f0101292 <vprintfmt+0x1e8>
f01012cc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012cf:	89 de                	mov    %ebx,%esi
f01012d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01012d4:	eb 18                	jmp    f01012ee <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01012d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012da:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01012e1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01012e3:	4b                   	dec    %ebx
f01012e4:	eb 08                	jmp    f01012ee <vprintfmt+0x244>
f01012e6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012e9:	89 de                	mov    %ebx,%esi
f01012eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01012ee:	85 db                	test   %ebx,%ebx
f01012f0:	7f e4                	jg     f01012d6 <vprintfmt+0x22c>
f01012f2:	89 7d 08             	mov    %edi,0x8(%ebp)
f01012f5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01012fa:	e9 ce fd ff ff       	jmp    f01010cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01012ff:	83 f9 01             	cmp    $0x1,%ecx
f0101302:	7e 10                	jle    f0101314 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0101304:	8b 45 14             	mov    0x14(%ebp),%eax
f0101307:	8d 50 08             	lea    0x8(%eax),%edx
f010130a:	89 55 14             	mov    %edx,0x14(%ebp)
f010130d:	8b 30                	mov    (%eax),%esi
f010130f:	8b 78 04             	mov    0x4(%eax),%edi
f0101312:	eb 26                	jmp    f010133a <vprintfmt+0x290>
	else if (lflag)
f0101314:	85 c9                	test   %ecx,%ecx
f0101316:	74 12                	je     f010132a <vprintfmt+0x280>
		return va_arg(*ap, long);
f0101318:	8b 45 14             	mov    0x14(%ebp),%eax
f010131b:	8d 50 04             	lea    0x4(%eax),%edx
f010131e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101321:	8b 30                	mov    (%eax),%esi
f0101323:	89 f7                	mov    %esi,%edi
f0101325:	c1 ff 1f             	sar    $0x1f,%edi
f0101328:	eb 10                	jmp    f010133a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010132a:	8b 45 14             	mov    0x14(%ebp),%eax
f010132d:	8d 50 04             	lea    0x4(%eax),%edx
f0101330:	89 55 14             	mov    %edx,0x14(%ebp)
f0101333:	8b 30                	mov    (%eax),%esi
f0101335:	89 f7                	mov    %esi,%edi
f0101337:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010133a:	85 ff                	test   %edi,%edi
f010133c:	78 0a                	js     f0101348 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010133e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101343:	e9 8c 00 00 00       	jmp    f01013d4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0101348:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010134c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101353:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101356:	f7 de                	neg    %esi
f0101358:	83 d7 00             	adc    $0x0,%edi
f010135b:	f7 df                	neg    %edi
			}
			base = 10;
f010135d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101362:	eb 70                	jmp    f01013d4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101364:	89 ca                	mov    %ecx,%edx
f0101366:	8d 45 14             	lea    0x14(%ebp),%eax
f0101369:	e8 c0 fc ff ff       	call   f010102e <getuint>
f010136e:	89 c6                	mov    %eax,%esi
f0101370:	89 d7                	mov    %edx,%edi
			base = 10;
f0101372:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0101377:	eb 5b                	jmp    f01013d4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0101379:	89 ca                	mov    %ecx,%edx
f010137b:	8d 45 14             	lea    0x14(%ebp),%eax
f010137e:	e8 ab fc ff ff       	call   f010102e <getuint>
f0101383:	89 c6                	mov    %eax,%esi
f0101385:	89 d7                	mov    %edx,%edi
			base = 8;
f0101387:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f010138c:	eb 46                	jmp    f01013d4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010138e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101392:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101399:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010139c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01013a7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01013aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ad:	8d 50 04             	lea    0x4(%eax),%edx
f01013b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01013b3:	8b 30                	mov    (%eax),%esi
f01013b5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01013ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01013bf:	eb 13                	jmp    f01013d4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01013c1:	89 ca                	mov    %ecx,%edx
f01013c3:	8d 45 14             	lea    0x14(%ebp),%eax
f01013c6:	e8 63 fc ff ff       	call   f010102e <getuint>
f01013cb:	89 c6                	mov    %eax,%esi
f01013cd:	89 d7                	mov    %edx,%edi
			base = 16;
f01013cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01013d4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01013d8:	89 54 24 10          	mov    %edx,0x10(%esp)
f01013dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01013df:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01013e3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013e7:	89 34 24             	mov    %esi,(%esp)
f01013ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013ee:	89 da                	mov    %ebx,%edx
f01013f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f3:	e8 6c fb ff ff       	call   f0100f64 <printnum>
			break;
f01013f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01013fb:	e9 cd fc ff ff       	jmp    f01010cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101400:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101404:	89 04 24             	mov    %eax,(%esp)
f0101407:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010140a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010140d:	e9 bb fc ff ff       	jmp    f01010cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101412:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101416:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010141d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101420:	eb 01                	jmp    f0101423 <vprintfmt+0x379>
f0101422:	4e                   	dec    %esi
f0101423:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101427:	75 f9                	jne    f0101422 <vprintfmt+0x378>
f0101429:	e9 9f fc ff ff       	jmp    f01010cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f010142e:	83 c4 4c             	add    $0x4c,%esp
f0101431:	5b                   	pop    %ebx
f0101432:	5e                   	pop    %esi
f0101433:	5f                   	pop    %edi
f0101434:	5d                   	pop    %ebp
f0101435:	c3                   	ret    

f0101436 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101436:	55                   	push   %ebp
f0101437:	89 e5                	mov    %esp,%ebp
f0101439:	83 ec 28             	sub    $0x28,%esp
f010143c:	8b 45 08             	mov    0x8(%ebp),%eax
f010143f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101442:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101445:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101449:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010144c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101453:	85 c0                	test   %eax,%eax
f0101455:	74 30                	je     f0101487 <vsnprintf+0x51>
f0101457:	85 d2                	test   %edx,%edx
f0101459:	7e 33                	jle    f010148e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010145b:	8b 45 14             	mov    0x14(%ebp),%eax
f010145e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101462:	8b 45 10             	mov    0x10(%ebp),%eax
f0101465:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101469:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010146c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101470:	c7 04 24 68 10 10 f0 	movl   $0xf0101068,(%esp)
f0101477:	e8 2e fc ff ff       	call   f01010aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010147c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010147f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101482:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101485:	eb 0c                	jmp    f0101493 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101487:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010148c:	eb 05                	jmp    f0101493 <vsnprintf+0x5d>
f010148e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101493:	c9                   	leave  
f0101494:	c3                   	ret    

f0101495 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101495:	55                   	push   %ebp
f0101496:	89 e5                	mov    %esp,%ebp
f0101498:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010149b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010149e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014a2:	8b 45 10             	mov    0x10(%ebp),%eax
f01014a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b3:	89 04 24             	mov    %eax,(%esp)
f01014b6:	e8 7b ff ff ff       	call   f0101436 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014bb:	c9                   	leave  
f01014bc:	c3                   	ret    
f01014bd:	00 00                	add    %al,(%eax)
	...

f01014c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014c0:	55                   	push   %ebp
f01014c1:	89 e5                	mov    %esp,%ebp
f01014c3:	57                   	push   %edi
f01014c4:	56                   	push   %esi
f01014c5:	53                   	push   %ebx
f01014c6:	83 ec 1c             	sub    $0x1c,%esp
f01014c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014cc:	85 c0                	test   %eax,%eax
f01014ce:	74 10                	je     f01014e0 <readline+0x20>
		cprintf("%s", prompt);
f01014d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014d4:	c7 04 24 ea 21 10 f0 	movl   $0xf01021ea,(%esp)
f01014db:	e8 66 f7 ff ff       	call   f0100c46 <cprintf>

	i = 0;
	echoing = iscons(0);
f01014e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014e7:	e8 3c f4 ff ff       	call   f0100928 <iscons>
f01014ec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01014ee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01014f3:	e8 1f f4 ff ff       	call   f0100917 <getchar>
f01014f8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01014fa:	85 c0                	test   %eax,%eax
f01014fc:	79 17                	jns    f0101515 <readline+0x55>
			cprintf("read error: %e\n", c);
f01014fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101502:	c7 04 24 cc 23 10 f0 	movl   $0xf01023cc,(%esp)
f0101509:	e8 38 f7 ff ff       	call   f0100c46 <cprintf>
			return NULL;
f010150e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101513:	eb 69                	jmp    f010157e <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101515:	83 f8 08             	cmp    $0x8,%eax
f0101518:	74 05                	je     f010151f <readline+0x5f>
f010151a:	83 f8 7f             	cmp    $0x7f,%eax
f010151d:	75 17                	jne    f0101536 <readline+0x76>
f010151f:	85 f6                	test   %esi,%esi
f0101521:	7e 13                	jle    f0101536 <readline+0x76>
			if (echoing)
f0101523:	85 ff                	test   %edi,%edi
f0101525:	74 0c                	je     f0101533 <readline+0x73>
				cputchar('\b');
f0101527:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010152e:	e8 d4 f3 ff ff       	call   f0100907 <cputchar>
			i--;
f0101533:	4e                   	dec    %esi
f0101534:	eb bd                	jmp    f01014f3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101536:	83 fb 1f             	cmp    $0x1f,%ebx
f0101539:	7e 1d                	jle    f0101558 <readline+0x98>
f010153b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101541:	7f 15                	jg     f0101558 <readline+0x98>
			if (echoing)
f0101543:	85 ff                	test   %edi,%edi
f0101545:	74 08                	je     f010154f <readline+0x8f>
				cputchar(c);
f0101547:	89 1c 24             	mov    %ebx,(%esp)
f010154a:	e8 b8 f3 ff ff       	call   f0100907 <cputchar>
			buf[i++] = c;
f010154f:	88 9e 60 a5 11 f0    	mov    %bl,-0xfee5aa0(%esi)
f0101555:	46                   	inc    %esi
f0101556:	eb 9b                	jmp    f01014f3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101558:	83 fb 0a             	cmp    $0xa,%ebx
f010155b:	74 05                	je     f0101562 <readline+0xa2>
f010155d:	83 fb 0d             	cmp    $0xd,%ebx
f0101560:	75 91                	jne    f01014f3 <readline+0x33>
			if (echoing)
f0101562:	85 ff                	test   %edi,%edi
f0101564:	74 0c                	je     f0101572 <readline+0xb2>
				cputchar('\n');
f0101566:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010156d:	e8 95 f3 ff ff       	call   f0100907 <cputchar>
			buf[i] = 0;
f0101572:	c6 86 60 a5 11 f0 00 	movb   $0x0,-0xfee5aa0(%esi)
			return buf;
f0101579:	b8 60 a5 11 f0       	mov    $0xf011a560,%eax
		}
	}
}
f010157e:	83 c4 1c             	add    $0x1c,%esp
f0101581:	5b                   	pop    %ebx
f0101582:	5e                   	pop    %esi
f0101583:	5f                   	pop    %edi
f0101584:	5d                   	pop    %ebp
f0101585:	c3                   	ret    
	...

f0101588 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101588:	55                   	push   %ebp
f0101589:	89 e5                	mov    %esp,%ebp
f010158b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010158e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101593:	eb 01                	jmp    f0101596 <strlen+0xe>
		n++;
f0101595:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101596:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010159a:	75 f9                	jne    f0101595 <strlen+0xd>
		n++;
	return n;
}
f010159c:	5d                   	pop    %ebp
f010159d:	c3                   	ret    

f010159e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010159e:	55                   	push   %ebp
f010159f:	89 e5                	mov    %esp,%ebp
f01015a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01015a4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ac:	eb 01                	jmp    f01015af <strnlen+0x11>
		n++;
f01015ae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015af:	39 d0                	cmp    %edx,%eax
f01015b1:	74 06                	je     f01015b9 <strnlen+0x1b>
f01015b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015b7:	75 f5                	jne    f01015ae <strnlen+0x10>
		n++;
	return n;
}
f01015b9:	5d                   	pop    %ebp
f01015ba:	c3                   	ret    

f01015bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015bb:	55                   	push   %ebp
f01015bc:	89 e5                	mov    %esp,%ebp
f01015be:	53                   	push   %ebx
f01015bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01015c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01015ca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01015cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01015d0:	42                   	inc    %edx
f01015d1:	84 c9                	test   %cl,%cl
f01015d3:	75 f5                	jne    f01015ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01015d5:	5b                   	pop    %ebx
f01015d6:	5d                   	pop    %ebp
f01015d7:	c3                   	ret    

f01015d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015d8:	55                   	push   %ebp
f01015d9:	89 e5                	mov    %esp,%ebp
f01015db:	53                   	push   %ebx
f01015dc:	83 ec 08             	sub    $0x8,%esp
f01015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015e2:	89 1c 24             	mov    %ebx,(%esp)
f01015e5:	e8 9e ff ff ff       	call   f0101588 <strlen>
	strcpy(dst + len, src);
f01015ea:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015ed:	89 54 24 04          	mov    %edx,0x4(%esp)
f01015f1:	01 d8                	add    %ebx,%eax
f01015f3:	89 04 24             	mov    %eax,(%esp)
f01015f6:	e8 c0 ff ff ff       	call   f01015bb <strcpy>
	return dst;
}
f01015fb:	89 d8                	mov    %ebx,%eax
f01015fd:	83 c4 08             	add    $0x8,%esp
f0101600:	5b                   	pop    %ebx
f0101601:	5d                   	pop    %ebp
f0101602:	c3                   	ret    

f0101603 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101603:	55                   	push   %ebp
f0101604:	89 e5                	mov    %esp,%ebp
f0101606:	56                   	push   %esi
f0101607:	53                   	push   %ebx
f0101608:	8b 45 08             	mov    0x8(%ebp),%eax
f010160b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010160e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101611:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101616:	eb 0c                	jmp    f0101624 <strncpy+0x21>
		*dst++ = *src;
f0101618:	8a 1a                	mov    (%edx),%bl
f010161a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010161d:	80 3a 01             	cmpb   $0x1,(%edx)
f0101620:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101623:	41                   	inc    %ecx
f0101624:	39 f1                	cmp    %esi,%ecx
f0101626:	75 f0                	jne    f0101618 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101628:	5b                   	pop    %ebx
f0101629:	5e                   	pop    %esi
f010162a:	5d                   	pop    %ebp
f010162b:	c3                   	ret    

f010162c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010162c:	55                   	push   %ebp
f010162d:	89 e5                	mov    %esp,%ebp
f010162f:	56                   	push   %esi
f0101630:	53                   	push   %ebx
f0101631:	8b 75 08             	mov    0x8(%ebp),%esi
f0101634:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101637:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010163a:	85 d2                	test   %edx,%edx
f010163c:	75 0a                	jne    f0101648 <strlcpy+0x1c>
f010163e:	89 f0                	mov    %esi,%eax
f0101640:	eb 1a                	jmp    f010165c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101642:	88 18                	mov    %bl,(%eax)
f0101644:	40                   	inc    %eax
f0101645:	41                   	inc    %ecx
f0101646:	eb 02                	jmp    f010164a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101648:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010164a:	4a                   	dec    %edx
f010164b:	74 0a                	je     f0101657 <strlcpy+0x2b>
f010164d:	8a 19                	mov    (%ecx),%bl
f010164f:	84 db                	test   %bl,%bl
f0101651:	75 ef                	jne    f0101642 <strlcpy+0x16>
f0101653:	89 c2                	mov    %eax,%edx
f0101655:	eb 02                	jmp    f0101659 <strlcpy+0x2d>
f0101657:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0101659:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f010165c:	29 f0                	sub    %esi,%eax
}
f010165e:	5b                   	pop    %ebx
f010165f:	5e                   	pop    %esi
f0101660:	5d                   	pop    %ebp
f0101661:	c3                   	ret    

f0101662 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101662:	55                   	push   %ebp
f0101663:	89 e5                	mov    %esp,%ebp
f0101665:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101668:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010166b:	eb 02                	jmp    f010166f <strcmp+0xd>
		p++, q++;
f010166d:	41                   	inc    %ecx
f010166e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010166f:	8a 01                	mov    (%ecx),%al
f0101671:	84 c0                	test   %al,%al
f0101673:	74 04                	je     f0101679 <strcmp+0x17>
f0101675:	3a 02                	cmp    (%edx),%al
f0101677:	74 f4                	je     f010166d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101679:	0f b6 c0             	movzbl %al,%eax
f010167c:	0f b6 12             	movzbl (%edx),%edx
f010167f:	29 d0                	sub    %edx,%eax
}
f0101681:	5d                   	pop    %ebp
f0101682:	c3                   	ret    

f0101683 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101683:	55                   	push   %ebp
f0101684:	89 e5                	mov    %esp,%ebp
f0101686:	53                   	push   %ebx
f0101687:	8b 45 08             	mov    0x8(%ebp),%eax
f010168a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010168d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0101690:	eb 03                	jmp    f0101695 <strncmp+0x12>
		n--, p++, q++;
f0101692:	4a                   	dec    %edx
f0101693:	40                   	inc    %eax
f0101694:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101695:	85 d2                	test   %edx,%edx
f0101697:	74 14                	je     f01016ad <strncmp+0x2a>
f0101699:	8a 18                	mov    (%eax),%bl
f010169b:	84 db                	test   %bl,%bl
f010169d:	74 04                	je     f01016a3 <strncmp+0x20>
f010169f:	3a 19                	cmp    (%ecx),%bl
f01016a1:	74 ef                	je     f0101692 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016a3:	0f b6 00             	movzbl (%eax),%eax
f01016a6:	0f b6 11             	movzbl (%ecx),%edx
f01016a9:	29 d0                	sub    %edx,%eax
f01016ab:	eb 05                	jmp    f01016b2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01016ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01016b2:	5b                   	pop    %ebx
f01016b3:	5d                   	pop    %ebp
f01016b4:	c3                   	ret    

f01016b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016b5:	55                   	push   %ebp
f01016b6:	89 e5                	mov    %esp,%ebp
f01016b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01016bb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01016be:	eb 05                	jmp    f01016c5 <strchr+0x10>
		if (*s == c)
f01016c0:	38 ca                	cmp    %cl,%dl
f01016c2:	74 0c                	je     f01016d0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01016c4:	40                   	inc    %eax
f01016c5:	8a 10                	mov    (%eax),%dl
f01016c7:	84 d2                	test   %dl,%dl
f01016c9:	75 f5                	jne    f01016c0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01016cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016d0:	5d                   	pop    %ebp
f01016d1:	c3                   	ret    

f01016d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016d2:	55                   	push   %ebp
f01016d3:	89 e5                	mov    %esp,%ebp
f01016d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01016db:	eb 05                	jmp    f01016e2 <strfind+0x10>
		if (*s == c)
f01016dd:	38 ca                	cmp    %cl,%dl
f01016df:	74 07                	je     f01016e8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01016e1:	40                   	inc    %eax
f01016e2:	8a 10                	mov    (%eax),%dl
f01016e4:	84 d2                	test   %dl,%dl
f01016e6:	75 f5                	jne    f01016dd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01016e8:	5d                   	pop    %ebp
f01016e9:	c3                   	ret    

f01016ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01016ea:	55                   	push   %ebp
f01016eb:	89 e5                	mov    %esp,%ebp
f01016ed:	57                   	push   %edi
f01016ee:	56                   	push   %esi
f01016ef:	53                   	push   %ebx
f01016f0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01016f9:	85 c9                	test   %ecx,%ecx
f01016fb:	74 30                	je     f010172d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01016fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101703:	75 25                	jne    f010172a <memset+0x40>
f0101705:	f6 c1 03             	test   $0x3,%cl
f0101708:	75 20                	jne    f010172a <memset+0x40>
		c &= 0xFF;
f010170a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010170d:	89 d3                	mov    %edx,%ebx
f010170f:	c1 e3 08             	shl    $0x8,%ebx
f0101712:	89 d6                	mov    %edx,%esi
f0101714:	c1 e6 18             	shl    $0x18,%esi
f0101717:	89 d0                	mov    %edx,%eax
f0101719:	c1 e0 10             	shl    $0x10,%eax
f010171c:	09 f0                	or     %esi,%eax
f010171e:	09 d0                	or     %edx,%eax
f0101720:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101722:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101725:	fc                   	cld    
f0101726:	f3 ab                	rep stos %eax,%es:(%edi)
f0101728:	eb 03                	jmp    f010172d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010172a:	fc                   	cld    
f010172b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010172d:	89 f8                	mov    %edi,%eax
f010172f:	5b                   	pop    %ebx
f0101730:	5e                   	pop    %esi
f0101731:	5f                   	pop    %edi
f0101732:	5d                   	pop    %ebp
f0101733:	c3                   	ret    

f0101734 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101734:	55                   	push   %ebp
f0101735:	89 e5                	mov    %esp,%ebp
f0101737:	57                   	push   %edi
f0101738:	56                   	push   %esi
f0101739:	8b 45 08             	mov    0x8(%ebp),%eax
f010173c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010173f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101742:	39 c6                	cmp    %eax,%esi
f0101744:	73 34                	jae    f010177a <memmove+0x46>
f0101746:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101749:	39 d0                	cmp    %edx,%eax
f010174b:	73 2d                	jae    f010177a <memmove+0x46>
		s += n;
		d += n;
f010174d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101750:	f6 c2 03             	test   $0x3,%dl
f0101753:	75 1b                	jne    f0101770 <memmove+0x3c>
f0101755:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010175b:	75 13                	jne    f0101770 <memmove+0x3c>
f010175d:	f6 c1 03             	test   $0x3,%cl
f0101760:	75 0e                	jne    f0101770 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101762:	83 ef 04             	sub    $0x4,%edi
f0101765:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101768:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010176b:	fd                   	std    
f010176c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010176e:	eb 07                	jmp    f0101777 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101770:	4f                   	dec    %edi
f0101771:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101774:	fd                   	std    
f0101775:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101777:	fc                   	cld    
f0101778:	eb 20                	jmp    f010179a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010177a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101780:	75 13                	jne    f0101795 <memmove+0x61>
f0101782:	a8 03                	test   $0x3,%al
f0101784:	75 0f                	jne    f0101795 <memmove+0x61>
f0101786:	f6 c1 03             	test   $0x3,%cl
f0101789:	75 0a                	jne    f0101795 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010178b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010178e:	89 c7                	mov    %eax,%edi
f0101790:	fc                   	cld    
f0101791:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101793:	eb 05                	jmp    f010179a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101795:	89 c7                	mov    %eax,%edi
f0101797:	fc                   	cld    
f0101798:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010179a:	5e                   	pop    %esi
f010179b:	5f                   	pop    %edi
f010179c:	5d                   	pop    %ebp
f010179d:	c3                   	ret    

f010179e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010179e:	55                   	push   %ebp
f010179f:	89 e5                	mov    %esp,%ebp
f01017a1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01017a4:	8b 45 10             	mov    0x10(%ebp),%eax
f01017a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b5:	89 04 24             	mov    %eax,(%esp)
f01017b8:	e8 77 ff ff ff       	call   f0101734 <memmove>
}
f01017bd:	c9                   	leave  
f01017be:	c3                   	ret    

f01017bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017bf:	55                   	push   %ebp
f01017c0:	89 e5                	mov    %esp,%ebp
f01017c2:	57                   	push   %edi
f01017c3:	56                   	push   %esi
f01017c4:	53                   	push   %ebx
f01017c5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017c8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01017d3:	eb 16                	jmp    f01017eb <memcmp+0x2c>
		if (*s1 != *s2)
f01017d5:	8a 04 17             	mov    (%edi,%edx,1),%al
f01017d8:	42                   	inc    %edx
f01017d9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01017dd:	38 c8                	cmp    %cl,%al
f01017df:	74 0a                	je     f01017eb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01017e1:	0f b6 c0             	movzbl %al,%eax
f01017e4:	0f b6 c9             	movzbl %cl,%ecx
f01017e7:	29 c8                	sub    %ecx,%eax
f01017e9:	eb 09                	jmp    f01017f4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017eb:	39 da                	cmp    %ebx,%edx
f01017ed:	75 e6                	jne    f01017d5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01017ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017f4:	5b                   	pop    %ebx
f01017f5:	5e                   	pop    %esi
f01017f6:	5f                   	pop    %edi
f01017f7:	5d                   	pop    %ebp
f01017f8:	c3                   	ret    

f01017f9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01017f9:	55                   	push   %ebp
f01017fa:	89 e5                	mov    %esp,%ebp
f01017fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101802:	89 c2                	mov    %eax,%edx
f0101804:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101807:	eb 05                	jmp    f010180e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101809:	38 08                	cmp    %cl,(%eax)
f010180b:	74 05                	je     f0101812 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010180d:	40                   	inc    %eax
f010180e:	39 d0                	cmp    %edx,%eax
f0101810:	72 f7                	jb     f0101809 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101812:	5d                   	pop    %ebp
f0101813:	c3                   	ret    

f0101814 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101814:	55                   	push   %ebp
f0101815:	89 e5                	mov    %esp,%ebp
f0101817:	57                   	push   %edi
f0101818:	56                   	push   %esi
f0101819:	53                   	push   %ebx
f010181a:	8b 55 08             	mov    0x8(%ebp),%edx
f010181d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101820:	eb 01                	jmp    f0101823 <strtol+0xf>
		s++;
f0101822:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101823:	8a 02                	mov    (%edx),%al
f0101825:	3c 20                	cmp    $0x20,%al
f0101827:	74 f9                	je     f0101822 <strtol+0xe>
f0101829:	3c 09                	cmp    $0x9,%al
f010182b:	74 f5                	je     f0101822 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010182d:	3c 2b                	cmp    $0x2b,%al
f010182f:	75 08                	jne    f0101839 <strtol+0x25>
		s++;
f0101831:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101832:	bf 00 00 00 00       	mov    $0x0,%edi
f0101837:	eb 13                	jmp    f010184c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101839:	3c 2d                	cmp    $0x2d,%al
f010183b:	75 0a                	jne    f0101847 <strtol+0x33>
		s++, neg = 1;
f010183d:	8d 52 01             	lea    0x1(%edx),%edx
f0101840:	bf 01 00 00 00       	mov    $0x1,%edi
f0101845:	eb 05                	jmp    f010184c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101847:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010184c:	85 db                	test   %ebx,%ebx
f010184e:	74 05                	je     f0101855 <strtol+0x41>
f0101850:	83 fb 10             	cmp    $0x10,%ebx
f0101853:	75 28                	jne    f010187d <strtol+0x69>
f0101855:	8a 02                	mov    (%edx),%al
f0101857:	3c 30                	cmp    $0x30,%al
f0101859:	75 10                	jne    f010186b <strtol+0x57>
f010185b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010185f:	75 0a                	jne    f010186b <strtol+0x57>
		s += 2, base = 16;
f0101861:	83 c2 02             	add    $0x2,%edx
f0101864:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101869:	eb 12                	jmp    f010187d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010186b:	85 db                	test   %ebx,%ebx
f010186d:	75 0e                	jne    f010187d <strtol+0x69>
f010186f:	3c 30                	cmp    $0x30,%al
f0101871:	75 05                	jne    f0101878 <strtol+0x64>
		s++, base = 8;
f0101873:	42                   	inc    %edx
f0101874:	b3 08                	mov    $0x8,%bl
f0101876:	eb 05                	jmp    f010187d <strtol+0x69>
	else if (base == 0)
		base = 10;
f0101878:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010187d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101882:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101884:	8a 0a                	mov    (%edx),%cl
f0101886:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101889:	80 fb 09             	cmp    $0x9,%bl
f010188c:	77 08                	ja     f0101896 <strtol+0x82>
			dig = *s - '0';
f010188e:	0f be c9             	movsbl %cl,%ecx
f0101891:	83 e9 30             	sub    $0x30,%ecx
f0101894:	eb 1e                	jmp    f01018b4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0101896:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0101899:	80 fb 19             	cmp    $0x19,%bl
f010189c:	77 08                	ja     f01018a6 <strtol+0x92>
			dig = *s - 'a' + 10;
f010189e:	0f be c9             	movsbl %cl,%ecx
f01018a1:	83 e9 57             	sub    $0x57,%ecx
f01018a4:	eb 0e                	jmp    f01018b4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01018a6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01018a9:	80 fb 19             	cmp    $0x19,%bl
f01018ac:	77 12                	ja     f01018c0 <strtol+0xac>
			dig = *s - 'A' + 10;
f01018ae:	0f be c9             	movsbl %cl,%ecx
f01018b1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01018b4:	39 f1                	cmp    %esi,%ecx
f01018b6:	7d 0c                	jge    f01018c4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01018b8:	42                   	inc    %edx
f01018b9:	0f af c6             	imul   %esi,%eax
f01018bc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01018be:	eb c4                	jmp    f0101884 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01018c0:	89 c1                	mov    %eax,%ecx
f01018c2:	eb 02                	jmp    f01018c6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018c4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01018c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018ca:	74 05                	je     f01018d1 <strtol+0xbd>
		*endptr = (char *) s;
f01018cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01018cf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01018d1:	85 ff                	test   %edi,%edi
f01018d3:	74 04                	je     f01018d9 <strtol+0xc5>
f01018d5:	89 c8                	mov    %ecx,%eax
f01018d7:	f7 d8                	neg    %eax
}
f01018d9:	5b                   	pop    %ebx
f01018da:	5e                   	pop    %esi
f01018db:	5f                   	pop    %edi
f01018dc:	5d                   	pop    %ebp
f01018dd:	c3                   	ret    
	...

f01018e0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01018e0:	55                   	push   %ebp
f01018e1:	57                   	push   %edi
f01018e2:	56                   	push   %esi
f01018e3:	83 ec 10             	sub    $0x10,%esp
f01018e6:	8b 74 24 20          	mov    0x20(%esp),%esi
f01018ea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01018ee:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018f2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f01018f6:	89 cd                	mov    %ecx,%ebp
f01018f8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01018fc:	85 c0                	test   %eax,%eax
f01018fe:	75 2c                	jne    f010192c <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0101900:	39 f9                	cmp    %edi,%ecx
f0101902:	77 68                	ja     f010196c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101904:	85 c9                	test   %ecx,%ecx
f0101906:	75 0b                	jne    f0101913 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101908:	b8 01 00 00 00       	mov    $0x1,%eax
f010190d:	31 d2                	xor    %edx,%edx
f010190f:	f7 f1                	div    %ecx
f0101911:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101913:	31 d2                	xor    %edx,%edx
f0101915:	89 f8                	mov    %edi,%eax
f0101917:	f7 f1                	div    %ecx
f0101919:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010191b:	89 f0                	mov    %esi,%eax
f010191d:	f7 f1                	div    %ecx
f010191f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101921:	89 f0                	mov    %esi,%eax
f0101923:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101925:	83 c4 10             	add    $0x10,%esp
f0101928:	5e                   	pop    %esi
f0101929:	5f                   	pop    %edi
f010192a:	5d                   	pop    %ebp
f010192b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010192c:	39 f8                	cmp    %edi,%eax
f010192e:	77 2c                	ja     f010195c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0101930:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0101933:	83 f6 1f             	xor    $0x1f,%esi
f0101936:	75 4c                	jne    f0101984 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0101938:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010193a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010193f:	72 0a                	jb     f010194b <__udivdi3+0x6b>
f0101941:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0101945:	0f 87 ad 00 00 00    	ja     f01019f8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010194b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101950:	89 f0                	mov    %esi,%eax
f0101952:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101954:	83 c4 10             	add    $0x10,%esp
f0101957:	5e                   	pop    %esi
f0101958:	5f                   	pop    %edi
f0101959:	5d                   	pop    %ebp
f010195a:	c3                   	ret    
f010195b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010195c:	31 ff                	xor    %edi,%edi
f010195e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101960:	89 f0                	mov    %esi,%eax
f0101962:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101964:	83 c4 10             	add    $0x10,%esp
f0101967:	5e                   	pop    %esi
f0101968:	5f                   	pop    %edi
f0101969:	5d                   	pop    %ebp
f010196a:	c3                   	ret    
f010196b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010196c:	89 fa                	mov    %edi,%edx
f010196e:	89 f0                	mov    %esi,%eax
f0101970:	f7 f1                	div    %ecx
f0101972:	89 c6                	mov    %eax,%esi
f0101974:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101976:	89 f0                	mov    %esi,%eax
f0101978:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010197a:	83 c4 10             	add    $0x10,%esp
f010197d:	5e                   	pop    %esi
f010197e:	5f                   	pop    %edi
f010197f:	5d                   	pop    %ebp
f0101980:	c3                   	ret    
f0101981:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101984:	89 f1                	mov    %esi,%ecx
f0101986:	d3 e0                	shl    %cl,%eax
f0101988:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010198c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101991:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0101993:	89 ea                	mov    %ebp,%edx
f0101995:	88 c1                	mov    %al,%cl
f0101997:	d3 ea                	shr    %cl,%edx
f0101999:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f010199d:	09 ca                	or     %ecx,%edx
f010199f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f01019a3:	89 f1                	mov    %esi,%ecx
f01019a5:	d3 e5                	shl    %cl,%ebp
f01019a7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f01019ab:	89 fd                	mov    %edi,%ebp
f01019ad:	88 c1                	mov    %al,%cl
f01019af:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f01019b1:	89 fa                	mov    %edi,%edx
f01019b3:	89 f1                	mov    %esi,%ecx
f01019b5:	d3 e2                	shl    %cl,%edx
f01019b7:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01019bb:	88 c1                	mov    %al,%cl
f01019bd:	d3 ef                	shr    %cl,%edi
f01019bf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01019c1:	89 f8                	mov    %edi,%eax
f01019c3:	89 ea                	mov    %ebp,%edx
f01019c5:	f7 74 24 08          	divl   0x8(%esp)
f01019c9:	89 d1                	mov    %edx,%ecx
f01019cb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01019cd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01019d1:	39 d1                	cmp    %edx,%ecx
f01019d3:	72 17                	jb     f01019ec <__udivdi3+0x10c>
f01019d5:	74 09                	je     f01019e0 <__udivdi3+0x100>
f01019d7:	89 fe                	mov    %edi,%esi
f01019d9:	31 ff                	xor    %edi,%edi
f01019db:	e9 41 ff ff ff       	jmp    f0101921 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01019e0:	8b 54 24 04          	mov    0x4(%esp),%edx
f01019e4:	89 f1                	mov    %esi,%ecx
f01019e6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01019e8:	39 c2                	cmp    %eax,%edx
f01019ea:	73 eb                	jae    f01019d7 <__udivdi3+0xf7>
		{
		  q0--;
f01019ec:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01019ef:	31 ff                	xor    %edi,%edi
f01019f1:	e9 2b ff ff ff       	jmp    f0101921 <__udivdi3+0x41>
f01019f6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01019f8:	31 f6                	xor    %esi,%esi
f01019fa:	e9 22 ff ff ff       	jmp    f0101921 <__udivdi3+0x41>
	...

f0101a00 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0101a00:	55                   	push   %ebp
f0101a01:	57                   	push   %edi
f0101a02:	56                   	push   %esi
f0101a03:	83 ec 20             	sub    $0x20,%esp
f0101a06:	8b 44 24 30          	mov    0x30(%esp),%eax
f0101a0a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0101a0e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0101a12:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0101a16:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101a1a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0101a1e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0101a20:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101a22:	85 ed                	test   %ebp,%ebp
f0101a24:	75 16                	jne    f0101a3c <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0101a26:	39 f1                	cmp    %esi,%ecx
f0101a28:	0f 86 a6 00 00 00    	jbe    f0101ad4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101a2e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0101a30:	89 d0                	mov    %edx,%eax
f0101a32:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101a34:	83 c4 20             	add    $0x20,%esp
f0101a37:	5e                   	pop    %esi
f0101a38:	5f                   	pop    %edi
f0101a39:	5d                   	pop    %ebp
f0101a3a:	c3                   	ret    
f0101a3b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0101a3c:	39 f5                	cmp    %esi,%ebp
f0101a3e:	0f 87 ac 00 00 00    	ja     f0101af0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0101a44:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0101a47:	83 f0 1f             	xor    $0x1f,%eax
f0101a4a:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101a4e:	0f 84 a8 00 00 00    	je     f0101afc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101a54:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101a58:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0101a5a:	bf 20 00 00 00       	mov    $0x20,%edi
f0101a5f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0101a63:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101a67:	89 f9                	mov    %edi,%ecx
f0101a69:	d3 e8                	shr    %cl,%eax
f0101a6b:	09 e8                	or     %ebp,%eax
f0101a6d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0101a71:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101a75:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101a79:	d3 e0                	shl    %cl,%eax
f0101a7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101a7f:	89 f2                	mov    %esi,%edx
f0101a81:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0101a83:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101a87:	d3 e0                	shl    %cl,%eax
f0101a89:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101a8d:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101a91:	89 f9                	mov    %edi,%ecx
f0101a93:	d3 e8                	shr    %cl,%eax
f0101a95:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0101a97:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101a99:	89 f2                	mov    %esi,%edx
f0101a9b:	f7 74 24 18          	divl   0x18(%esp)
f0101a9f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0101aa1:	f7 64 24 0c          	mull   0xc(%esp)
f0101aa5:	89 c5                	mov    %eax,%ebp
f0101aa7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101aa9:	39 d6                	cmp    %edx,%esi
f0101aab:	72 67                	jb     f0101b14 <__umoddi3+0x114>
f0101aad:	74 75                	je     f0101b24 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0101aaf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0101ab3:	29 e8                	sub    %ebp,%eax
f0101ab5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0101ab7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101abb:	d3 e8                	shr    %cl,%eax
f0101abd:	89 f2                	mov    %esi,%edx
f0101abf:	89 f9                	mov    %edi,%ecx
f0101ac1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0101ac3:	09 d0                	or     %edx,%eax
f0101ac5:	89 f2                	mov    %esi,%edx
f0101ac7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101acb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101acd:	83 c4 20             	add    $0x20,%esp
f0101ad0:	5e                   	pop    %esi
f0101ad1:	5f                   	pop    %edi
f0101ad2:	5d                   	pop    %ebp
f0101ad3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0101ad4:	85 c9                	test   %ecx,%ecx
f0101ad6:	75 0b                	jne    f0101ae3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101ad8:	b8 01 00 00 00       	mov    $0x1,%eax
f0101add:	31 d2                	xor    %edx,%edx
f0101adf:	f7 f1                	div    %ecx
f0101ae1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101ae3:	89 f0                	mov    %esi,%eax
f0101ae5:	31 d2                	xor    %edx,%edx
f0101ae7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101ae9:	89 f8                	mov    %edi,%eax
f0101aeb:	e9 3e ff ff ff       	jmp    f0101a2e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0101af0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101af2:	83 c4 20             	add    $0x20,%esp
f0101af5:	5e                   	pop    %esi
f0101af6:	5f                   	pop    %edi
f0101af7:	5d                   	pop    %ebp
f0101af8:	c3                   	ret    
f0101af9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0101afc:	39 f5                	cmp    %esi,%ebp
f0101afe:	72 04                	jb     f0101b04 <__umoddi3+0x104>
f0101b00:	39 f9                	cmp    %edi,%ecx
f0101b02:	77 06                	ja     f0101b0a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101b04:	89 f2                	mov    %esi,%edx
f0101b06:	29 cf                	sub    %ecx,%edi
f0101b08:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0101b0a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101b0c:	83 c4 20             	add    $0x20,%esp
f0101b0f:	5e                   	pop    %esi
f0101b10:	5f                   	pop    %edi
f0101b11:	5d                   	pop    %ebp
f0101b12:	c3                   	ret    
f0101b13:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0101b14:	89 d1                	mov    %edx,%ecx
f0101b16:	89 c5                	mov    %eax,%ebp
f0101b18:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0101b1c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0101b20:	eb 8d                	jmp    f0101aaf <__umoddi3+0xaf>
f0101b22:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101b24:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0101b28:	72 ea                	jb     f0101b14 <__umoddi3+0x114>
f0101b2a:	89 f1                	mov    %esi,%ecx
f0101b2c:	eb 81                	jmp    f0101aaf <__umoddi3+0xaf>
