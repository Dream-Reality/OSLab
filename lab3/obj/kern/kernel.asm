
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
f0100015:	b8 00 60 12 00       	mov    $0x126000,%eax
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
f0100034:	bc 00 60 12 f0       	mov    $0xf0126000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 a0 bc 20 f0       	mov    $0xf020bca0,%eax
f010004b:	2d c0 ad 20 f0       	sub    $0xf020adc0,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 c0 ad 20 f0 	movl   $0xf020adc0,(%esp)
f0100063:	e8 86 63 00 00       	call   f01063ee <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 7b 07 00 00       	call   f01007e8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 40 68 10 f0 	movl   $0xf0106840,(%esp)
f010007c:	e8 55 4e 00 00       	call   f0104ed6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 c7 28 00 00       	call   f010294d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 95 47 00 00       	call   f0104820 <env_init>
	trap_init();
f010008b:	e8 c6 4e 00 00       	call   f0104f56 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100097:	00 
f0100098:	c7 04 24 ab 33 1a f0 	movl   $0xf01a33ab,(%esp)
f010009f:	e8 c3 49 00 00       	call   f0104a67 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a4:	a1 14 b0 20 f0       	mov    0xf020b014,%eax
f01000a9:	89 04 24             	mov    %eax,(%esp)
f01000ac:	e8 4b 4d 00 00       	call   f0104dfc <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	56                   	push   %esi
f01000b5:	53                   	push   %ebx
f01000b6:	83 ec 10             	sub    $0x10,%esp
f01000b9:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000bc:	83 3d a4 bc 20 f0 00 	cmpl   $0x0,0xf020bca4
f01000c3:	75 3d                	jne    f0100102 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000c5:	89 35 a4 bc 20 f0    	mov    %esi,0xf020bca4

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000cb:	fa                   	cli    
f01000cc:	fc                   	cld    

	va_start(ap, fmt);
f01000cd:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01000da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000de:	c7 04 24 5b 68 10 f0 	movl   $0xf010685b,(%esp)
f01000e5:	e8 ec 4d 00 00       	call   f0104ed6 <cprintf>
	vcprintf(fmt, ap);
f01000ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000ee:	89 34 24             	mov    %esi,(%esp)
f01000f1:	e8 ad 4d 00 00       	call   f0104ea3 <vcprintf>
	cprintf("\n");
f01000f6:	c7 04 24 a0 87 10 f0 	movl   $0xf01087a0,(%esp)
f01000fd:	e8 d4 4d 00 00       	call   f0104ed6 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100109:	e8 f1 19 00 00       	call   f0101aff <monitor>
f010010e:	eb f2                	jmp    f0100102 <_panic+0x51>

f0100110 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100110:	55                   	push   %ebp
f0100111:	89 e5                	mov    %esp,%ebp
f0100113:	53                   	push   %ebx
f0100114:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100117:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010011a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100121:	8b 45 08             	mov    0x8(%ebp),%eax
f0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100128:	c7 04 24 73 68 10 f0 	movl   $0xf0106873,(%esp)
f010012f:	e8 a2 4d 00 00       	call   f0104ed6 <cprintf>
	vcprintf(fmt, ap);
f0100134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100138:	8b 45 10             	mov    0x10(%ebp),%eax
f010013b:	89 04 24             	mov    %eax,(%esp)
f010013e:	e8 60 4d 00 00       	call   f0104ea3 <vcprintf>
	cprintf("\n");
f0100143:	c7 04 24 a0 87 10 f0 	movl   $0xf01087a0,(%esp)
f010014a:	e8 87 4d 00 00       	call   f0104ed6 <cprintf>
	va_end(ap);
}
f010014f:	83 c4 14             	add    $0x14,%esp
f0100152:	5b                   	pop    %ebx
f0100153:	5d                   	pop    %ebp
f0100154:	c3                   	ret    
f0100155:	00 00                	add    %al,(%eax)
	...

f0100158 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100158:	55                   	push   %ebp
f0100159:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010015b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100160:	ec                   	in     (%dx),%al
f0100161:	ec                   	in     (%dx),%al
f0100162:	ec                   	in     (%dx),%al
f0100163:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100164:	5d                   	pop    %ebp
f0100165:	c3                   	ret    

f0100166 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100166:	55                   	push   %ebp
f0100167:	89 e5                	mov    %esp,%ebp
f0100169:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010016e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010016f:	a8 01                	test   $0x1,%al
f0100171:	74 08                	je     f010017b <serial_proc_data+0x15>
f0100173:	b2 f8                	mov    $0xf8,%dl
f0100175:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100176:	0f b6 c0             	movzbl %al,%eax
f0100179:	eb 05                	jmp    f0100180 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010017b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100180:	5d                   	pop    %ebp
f0100181:	c3                   	ret    

f0100182 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100182:	55                   	push   %ebp
f0100183:	89 e5                	mov    %esp,%ebp
f0100185:	53                   	push   %ebx
f0100186:	83 ec 04             	sub    $0x4,%esp
f0100189:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010018b:	eb 29                	jmp    f01001b6 <cons_intr+0x34>
		if (c == 0)
f010018d:	85 c0                	test   %eax,%eax
f010018f:	74 25                	je     f01001b6 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100191:	8b 15 e4 af 20 f0    	mov    0xf020afe4,%edx
f0100197:	88 82 e0 ad 20 f0    	mov    %al,-0xfdf5220(%edx)
f010019d:	8d 42 01             	lea    0x1(%edx),%eax
f01001a0:	a3 e4 af 20 f0       	mov    %eax,0xf020afe4
		if (cons.wpos == CONSBUFSIZE)
f01001a5:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001aa:	75 0a                	jne    f01001b6 <cons_intr+0x34>
			cons.wpos = 0;
f01001ac:	c7 05 e4 af 20 f0 00 	movl   $0x0,0xf020afe4
f01001b3:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001b6:	ff d3                	call   *%ebx
f01001b8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001bb:	75 d0                	jne    f010018d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001bd:	83 c4 04             	add    $0x4,%esp
f01001c0:	5b                   	pop    %ebx
f01001c1:	5d                   	pop    %ebp
f01001c2:	c3                   	ret    

f01001c3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001c3:	55                   	push   %ebp
f01001c4:	89 e5                	mov    %esp,%ebp
f01001c6:	57                   	push   %edi
f01001c7:	56                   	push   %esi
f01001c8:	53                   	push   %ebx
f01001c9:	83 ec 2c             	sub    $0x2c,%esp
f01001cc:	89 c6                	mov    %eax,%esi
f01001ce:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01001d3:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01001d8:	eb 05                	jmp    f01001df <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001da:	e8 79 ff ff ff       	call   f0100158 <delay>
f01001df:	89 fa                	mov    %edi,%edx
f01001e1:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001e2:	a8 20                	test   $0x20,%al
f01001e4:	75 03                	jne    f01001e9 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001e6:	4b                   	dec    %ebx
f01001e7:	75 f1                	jne    f01001da <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001e9:	89 f2                	mov    %esi,%edx
f01001eb:	89 f0                	mov    %esi,%eax
f01001ed:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001f5:	ee                   	out    %al,(%dx)
f01001f6:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001fb:	bf 79 03 00 00       	mov    $0x379,%edi
f0100200:	eb 05                	jmp    f0100207 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100202:	e8 51 ff ff ff       	call   f0100158 <delay>
f0100207:	89 fa                	mov    %edi,%edx
f0100209:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010020a:	84 c0                	test   %al,%al
f010020c:	78 03                	js     f0100211 <cons_putc+0x4e>
f010020e:	4b                   	dec    %ebx
f010020f:	75 f1                	jne    f0100202 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100211:	ba 78 03 00 00       	mov    $0x378,%edx
f0100216:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100219:	ee                   	out    %al,(%dx)
f010021a:	b2 7a                	mov    $0x7a,%dl
f010021c:	b0 0d                	mov    $0xd,%al
f010021e:	ee                   	out    %al,(%dx)
f010021f:	b0 08                	mov    $0x8,%al
f0100221:	ee                   	out    %al,(%dx)
{
	// if no attribute given, then use black on white
	static int Color = 0x0700;
	static int State = 0;
	static int Number = 0;
	if (!(c & ~0xFF))
f0100222:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100228:	75 06                	jne    f0100230 <cons_putc+0x6d>
		c |= Color;
f010022a:	0b 35 00 80 12 f0    	or     0xf0128000,%esi
	switch (c & 0xff) {
f0100230:	89 f2                	mov    %esi,%edx
f0100232:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100238:	8d 42 f8             	lea    -0x8(%edx),%eax
f010023b:	83 f8 13             	cmp    $0x13,%eax
f010023e:	0f 87 ab 00 00 00    	ja     f01002ef <cons_putc+0x12c>
f0100244:	ff 24 85 a0 68 10 f0 	jmp    *-0xfef9760(,%eax,4)
	case '\b':
		if (crt_pos > 0) {
f010024b:	66 a1 f4 af 20 f0    	mov    0xf020aff4,%ax
f0100251:	66 85 c0             	test   %ax,%ax
f0100254:	0f 84 de 03 00 00    	je     f0100638 <cons_putc+0x475>
			crt_pos--;
f010025a:	48                   	dec    %eax
f010025b:	66 a3 f4 af 20 f0    	mov    %ax,0xf020aff4
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100261:	0f b7 c0             	movzwl %ax,%eax
f0100264:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010026a:	83 ce 20             	or     $0x20,%esi
f010026d:	8b 15 f0 af 20 f0    	mov    0xf020aff0,%edx
f0100273:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100277:	e9 71 03 00 00       	jmp    f01005ed <cons_putc+0x42a>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010027c:	66 83 05 f4 af 20 f0 	addw   $0x50,0xf020aff4
f0100283:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100284:	66 8b 0d f4 af 20 f0 	mov    0xf020aff4,%cx
f010028b:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100290:	89 c8                	mov    %ecx,%eax
f0100292:	ba 00 00 00 00       	mov    $0x0,%edx
f0100297:	66 f7 f3             	div    %bx
f010029a:	66 29 d1             	sub    %dx,%cx
f010029d:	66 89 0d f4 af 20 f0 	mov    %cx,0xf020aff4
f01002a4:	e9 44 03 00 00       	jmp    f01005ed <cons_putc+0x42a>
		break;
	case '\t':
		cons_putc(' ');
f01002a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ae:	e8 10 ff ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b8:	e8 06 ff ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002bd:	b8 20 00 00 00       	mov    $0x20,%eax
f01002c2:	e8 fc fe ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002c7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002cc:	e8 f2 fe ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002d1:	b8 20 00 00 00       	mov    $0x20,%eax
f01002d6:	e8 e8 fe ff ff       	call   f01001c3 <cons_putc>
f01002db:	e9 0d 03 00 00       	jmp    f01005ed <cons_putc+0x42a>
		break;
	case '\033':
		State = 1;
f01002e0:	c7 05 f8 af 20 f0 01 	movl   $0x1,0xf020aff8
f01002e7:	00 00 00 
f01002ea:	e9 fe 02 00 00       	jmp    f01005ed <cons_putc+0x42a>
		break;
	default:
		if (State == 1){
f01002ef:	83 3d f8 af 20 f0 01 	cmpl   $0x1,0xf020aff8
f01002f6:	0f 85 d7 02 00 00    	jne    f01005d3 <cons_putc+0x410>
			switch (c&0xff){
f01002fc:	83 fa 5b             	cmp    $0x5b,%edx
f01002ff:	0f 84 e8 02 00 00    	je     f01005ed <cons_putc+0x42a>
f0100305:	83 fa 6d             	cmp    $0x6d,%edx
f0100308:	0f 84 5a 01 00 00    	je     f0100468 <cons_putc+0x2a5>
f010030e:	83 fa 3b             	cmp    $0x3b,%edx
f0100311:	0f 85 a9 02 00 00    	jne    f01005c0 <cons_putc+0x3fd>
				case '[':
					break;
				case ';':
					switch (Number){
f0100317:	a1 fc af 20 f0       	mov    0xf020affc,%eax
f010031c:	83 e8 1e             	sub    $0x1e,%eax
f010031f:	83 f8 11             	cmp    $0x11,%eax
f0100322:	0f 87 31 01 00 00    	ja     f0100459 <cons_putc+0x296>
f0100328:	ff 24 85 f0 68 10 f0 	jmp    *-0xfef9710(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f010032f:	81 25 00 80 12 f0 ff 	andl   $0xfffff0ff,0xf0128000
f0100336:	f0 ff ff 
f0100339:	e9 1b 01 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f010033e:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100343:	80 e4 f0             	and    $0xf0,%ah
f0100346:	80 cc 04             	or     $0x4,%ah
f0100349:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f010034e:	e9 06 01 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f0100353:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100358:	80 e4 f0             	and    $0xf0,%ah
f010035b:	80 cc 02             	or     $0x2,%ah
f010035e:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100363:	e9 f1 00 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f0100368:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f010036d:	80 e4 f0             	and    $0xf0,%ah
f0100370:	80 cc 06             	or     $0x6,%ah
f0100373:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100378:	e9 dc 00 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f010037d:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100382:	80 e4 f0             	and    $0xf0,%ah
f0100385:	80 cc 01             	or     $0x1,%ah
f0100388:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f010038d:	e9 c7 00 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f0100392:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100397:	80 e4 f0             	and    $0xf0,%ah
f010039a:	80 cc 05             	or     $0x5,%ah
f010039d:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01003a2:	e9 b2 00 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f01003a7:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01003ac:	80 e4 f0             	and    $0xf0,%ah
f01003af:	80 cc 03             	or     $0x3,%ah
f01003b2:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01003b7:	e9 9d 00 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f01003bc:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01003c1:	80 e4 f0             	and    $0xf0,%ah
f01003c4:	80 cc 07             	or     $0x7,%ah
f01003c7:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01003cc:	e9 88 00 00 00       	jmp    f0100459 <cons_putc+0x296>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f01003d1:	81 25 00 80 12 f0 ff 	andl   $0xffff0fff,0xf0128000
f01003d8:	0f ff ff 
f01003db:	eb 7c                	jmp    f0100459 <cons_putc+0x296>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f01003dd:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01003e2:	80 e4 0f             	and    $0xf,%ah
f01003e5:	80 cc 40             	or     $0x40,%ah
f01003e8:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01003ed:	eb 6a                	jmp    f0100459 <cons_putc+0x296>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f01003ef:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01003f4:	80 e4 0f             	and    $0xf,%ah
f01003f7:	80 cc 20             	or     $0x20,%ah
f01003fa:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01003ff:	eb 58                	jmp    f0100459 <cons_putc+0x296>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f0100401:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100406:	80 e4 0f             	and    $0xf,%ah
f0100409:	80 cc 60             	or     $0x60,%ah
f010040c:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100411:	eb 46                	jmp    f0100459 <cons_putc+0x296>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f0100413:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100418:	80 e4 0f             	and    $0xf,%ah
f010041b:	80 cc 10             	or     $0x10,%ah
f010041e:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100423:	eb 34                	jmp    f0100459 <cons_putc+0x296>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f0100425:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f010042a:	80 e4 0f             	and    $0xf,%ah
f010042d:	80 cc 50             	or     $0x50,%ah
f0100430:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100435:	eb 22                	jmp    f0100459 <cons_putc+0x296>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f0100437:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f010043c:	80 e4 0f             	and    $0xf,%ah
f010043f:	80 cc 30             	or     $0x30,%ah
f0100442:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100447:	eb 10                	jmp    f0100459 <cons_putc+0x296>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f0100449:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f010044e:	80 e4 0f             	and    $0xf,%ah
f0100451:	80 cc 70             	or     $0x70,%ah
f0100454:	a3 00 80 12 f0       	mov    %eax,0xf0128000
						default:break;
					}
					Number = 0;
f0100459:	c7 05 fc af 20 f0 00 	movl   $0x0,0xf020affc
f0100460:	00 00 00 
f0100463:	e9 85 01 00 00       	jmp    f01005ed <cons_putc+0x42a>
					break;
				case 'm':
					switch (Number){
f0100468:	a1 fc af 20 f0       	mov    0xf020affc,%eax
f010046d:	83 e8 1e             	sub    $0x1e,%eax
f0100470:	83 f8 11             	cmp    $0x11,%eax
f0100473:	0f 87 31 01 00 00    	ja     f01005aa <cons_putc+0x3e7>
f0100479:	ff 24 85 38 69 10 f0 	jmp    *-0xfef96c8(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f0100480:	81 25 00 80 12 f0 ff 	andl   $0xfffff0ff,0xf0128000
f0100487:	f0 ff ff 
f010048a:	e9 1b 01 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f010048f:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100494:	80 e4 f0             	and    $0xf0,%ah
f0100497:	80 cc 04             	or     $0x4,%ah
f010049a:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f010049f:	e9 06 01 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f01004a4:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01004a9:	80 e4 f0             	and    $0xf0,%ah
f01004ac:	80 cc 02             	or     $0x2,%ah
f01004af:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01004b4:	e9 f1 00 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f01004b9:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01004be:	80 e4 f0             	and    $0xf0,%ah
f01004c1:	80 cc 06             	or     $0x6,%ah
f01004c4:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01004c9:	e9 dc 00 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f01004ce:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01004d3:	80 e4 f0             	and    $0xf0,%ah
f01004d6:	80 cc 01             	or     $0x1,%ah
f01004d9:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01004de:	e9 c7 00 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f01004e3:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01004e8:	80 e4 f0             	and    $0xf0,%ah
f01004eb:	80 cc 05             	or     $0x5,%ah
f01004ee:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f01004f3:	e9 b2 00 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f01004f8:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f01004fd:	80 e4 f0             	and    $0xf0,%ah
f0100500:	80 cc 03             	or     $0x3,%ah
f0100503:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100508:	e9 9d 00 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f010050d:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100512:	80 e4 f0             	and    $0xf0,%ah
f0100515:	80 cc 07             	or     $0x7,%ah
f0100518:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f010051d:	e9 88 00 00 00       	jmp    f01005aa <cons_putc+0x3e7>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f0100522:	81 25 00 80 12 f0 ff 	andl   $0xffff0fff,0xf0128000
f0100529:	0f ff ff 
f010052c:	eb 7c                	jmp    f01005aa <cons_putc+0x3e7>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f010052e:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100533:	80 e4 0f             	and    $0xf,%ah
f0100536:	80 cc 40             	or     $0x40,%ah
f0100539:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f010053e:	eb 6a                	jmp    f01005aa <cons_putc+0x3e7>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f0100540:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100545:	80 e4 0f             	and    $0xf,%ah
f0100548:	80 cc 20             	or     $0x20,%ah
f010054b:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100550:	eb 58                	jmp    f01005aa <cons_putc+0x3e7>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f0100552:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100557:	80 e4 0f             	and    $0xf,%ah
f010055a:	80 cc 60             	or     $0x60,%ah
f010055d:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100562:	eb 46                	jmp    f01005aa <cons_putc+0x3e7>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f0100564:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f0100569:	80 e4 0f             	and    $0xf,%ah
f010056c:	80 cc 10             	or     $0x10,%ah
f010056f:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100574:	eb 34                	jmp    f01005aa <cons_putc+0x3e7>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f0100576:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f010057b:	80 e4 0f             	and    $0xf,%ah
f010057e:	80 cc 50             	or     $0x50,%ah
f0100581:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100586:	eb 22                	jmp    f01005aa <cons_putc+0x3e7>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f0100588:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f010058d:	80 e4 0f             	and    $0xf,%ah
f0100590:	80 cc 30             	or     $0x30,%ah
f0100593:	a3 00 80 12 f0       	mov    %eax,0xf0128000
f0100598:	eb 10                	jmp    f01005aa <cons_putc+0x3e7>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f010059a:	a1 00 80 12 f0       	mov    0xf0128000,%eax
f010059f:	80 e4 0f             	and    $0xf,%ah
f01005a2:	80 cc 70             	or     $0x70,%ah
f01005a5:	a3 00 80 12 f0       	mov    %eax,0xf0128000
						default:break;
					}
					Number = 0;
f01005aa:	c7 05 fc af 20 f0 00 	movl   $0x0,0xf020affc
f01005b1:	00 00 00 
					State = 0;
f01005b4:	c7 05 f8 af 20 f0 00 	movl   $0x0,0xf020aff8
f01005bb:	00 00 00 
f01005be:	eb 2d                	jmp    f01005ed <cons_putc+0x42a>
					break;
				default:
					Number = Number * 10 + (c&0xff) - '0';
f01005c0:	a1 fc af 20 f0       	mov    0xf020affc,%eax
f01005c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01005c8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
f01005cc:	a3 fc af 20 f0       	mov    %eax,0xf020affc
f01005d1:	eb 1a                	jmp    f01005ed <cons_putc+0x42a>
					break;
			}
		}
		else crt_buf[crt_pos++] = c;		/* write the character */
f01005d3:	66 a1 f4 af 20 f0    	mov    0xf020aff4,%ax
f01005d9:	0f b7 c8             	movzwl %ax,%ecx
f01005dc:	8b 15 f0 af 20 f0    	mov    0xf020aff0,%edx
f01005e2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01005e6:	40                   	inc    %eax
f01005e7:	66 a3 f4 af 20 f0    	mov    %ax,0xf020aff4
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005ed:	66 81 3d f4 af 20 f0 	cmpw   $0x7cf,0xf020aff4
f01005f4:	cf 07 
f01005f6:	76 40                	jbe    f0100638 <cons_putc+0x475>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005f8:	a1 f0 af 20 f0       	mov    0xf020aff0,%eax
f01005fd:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100604:	00 
f0100605:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010060b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010060f:	89 04 24             	mov    %eax,(%esp)
f0100612:	e8 21 5e 00 00       	call   f0106438 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100617:	8b 15 f0 af 20 f0    	mov    0xf020aff0,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010061d:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100622:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100628:	40                   	inc    %eax
f0100629:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010062e:	75 f2                	jne    f0100622 <cons_putc+0x45f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100630:	66 83 2d f4 af 20 f0 	subw   $0x50,0xf020aff4
f0100637:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100638:	8b 0d ec af 20 f0    	mov    0xf020afec,%ecx
f010063e:	b0 0e                	mov    $0xe,%al
f0100640:	89 ca                	mov    %ecx,%edx
f0100642:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100643:	66 8b 35 f4 af 20 f0 	mov    0xf020aff4,%si
f010064a:	8d 59 01             	lea    0x1(%ecx),%ebx
f010064d:	89 f0                	mov    %esi,%eax
f010064f:	66 c1 e8 08          	shr    $0x8,%ax
f0100653:	89 da                	mov    %ebx,%edx
f0100655:	ee                   	out    %al,(%dx)
f0100656:	b0 0f                	mov    $0xf,%al
f0100658:	89 ca                	mov    %ecx,%edx
f010065a:	ee                   	out    %al,(%dx)
f010065b:	89 f0                	mov    %esi,%eax
f010065d:	89 da                	mov    %ebx,%edx
f010065f:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100660:	83 c4 2c             	add    $0x2c,%esp
f0100663:	5b                   	pop    %ebx
f0100664:	5e                   	pop    %esi
f0100665:	5f                   	pop    %edi
f0100666:	5d                   	pop    %ebp
f0100667:	c3                   	ret    

f0100668 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100668:	55                   	push   %ebp
f0100669:	89 e5                	mov    %esp,%ebp
f010066b:	53                   	push   %ebx
f010066c:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100674:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100675:	0f b6 c0             	movzbl %al,%eax
f0100678:	a8 01                	test   $0x1,%al
f010067a:	0f 84 e0 00 00 00    	je     f0100760 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100680:	a8 20                	test   $0x20,%al
f0100682:	0f 85 df 00 00 00    	jne    f0100767 <kbd_proc_data+0xff>
f0100688:	b2 60                	mov    $0x60,%dl
f010068a:	ec                   	in     (%dx),%al
f010068b:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010068d:	3c e0                	cmp    $0xe0,%al
f010068f:	75 11                	jne    f01006a2 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f0100691:	83 0d e8 af 20 f0 40 	orl    $0x40,0xf020afe8
		return 0;
f0100698:	bb 00 00 00 00       	mov    $0x0,%ebx
f010069d:	e9 ca 00 00 00       	jmp    f010076c <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f01006a2:	84 c0                	test   %al,%al
f01006a4:	79 33                	jns    f01006d9 <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006a6:	8b 0d e8 af 20 f0    	mov    0xf020afe8,%ecx
f01006ac:	f6 c1 40             	test   $0x40,%cl
f01006af:	75 05                	jne    f01006b6 <kbd_proc_data+0x4e>
f01006b1:	88 c2                	mov    %al,%dl
f01006b3:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01006b6:	0f b6 d2             	movzbl %dl,%edx
f01006b9:	8a 82 80 69 10 f0    	mov    -0xfef9680(%edx),%al
f01006bf:	83 c8 40             	or     $0x40,%eax
f01006c2:	0f b6 c0             	movzbl %al,%eax
f01006c5:	f7 d0                	not    %eax
f01006c7:	21 c1                	and    %eax,%ecx
f01006c9:	89 0d e8 af 20 f0    	mov    %ecx,0xf020afe8
		return 0;
f01006cf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006d4:	e9 93 00 00 00       	jmp    f010076c <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f01006d9:	8b 0d e8 af 20 f0    	mov    0xf020afe8,%ecx
f01006df:	f6 c1 40             	test   $0x40,%cl
f01006e2:	74 0e                	je     f01006f2 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01006e4:	88 c2                	mov    %al,%dl
f01006e6:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01006e9:	83 e1 bf             	and    $0xffffffbf,%ecx
f01006ec:	89 0d e8 af 20 f0    	mov    %ecx,0xf020afe8
	}

	shift |= shiftcode[data];
f01006f2:	0f b6 d2             	movzbl %dl,%edx
f01006f5:	0f b6 82 80 69 10 f0 	movzbl -0xfef9680(%edx),%eax
f01006fc:	0b 05 e8 af 20 f0    	or     0xf020afe8,%eax
	shift ^= togglecode[data];
f0100702:	0f b6 8a 80 6a 10 f0 	movzbl -0xfef9580(%edx),%ecx
f0100709:	31 c8                	xor    %ecx,%eax
f010070b:	a3 e8 af 20 f0       	mov    %eax,0xf020afe8

	c = charcode[shift & (CTL | SHIFT)][data];
f0100710:	89 c1                	mov    %eax,%ecx
f0100712:	83 e1 03             	and    $0x3,%ecx
f0100715:	8b 0c 8d 80 6b 10 f0 	mov    -0xfef9480(,%ecx,4),%ecx
f010071c:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100720:	a8 08                	test   $0x8,%al
f0100722:	74 18                	je     f010073c <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f0100724:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100727:	83 fa 19             	cmp    $0x19,%edx
f010072a:	77 05                	ja     f0100731 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f010072c:	83 eb 20             	sub    $0x20,%ebx
f010072f:	eb 0b                	jmp    f010073c <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f0100731:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100734:	83 fa 19             	cmp    $0x19,%edx
f0100737:	77 03                	ja     f010073c <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f0100739:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010073c:	f7 d0                	not    %eax
f010073e:	a8 06                	test   $0x6,%al
f0100740:	75 2a                	jne    f010076c <kbd_proc_data+0x104>
f0100742:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100748:	75 22                	jne    f010076c <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010074a:	c7 04 24 90 6b 10 f0 	movl   $0xf0106b90,(%esp)
f0100751:	e8 80 47 00 00       	call   f0104ed6 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100756:	ba 92 00 00 00       	mov    $0x92,%edx
f010075b:	b0 03                	mov    $0x3,%al
f010075d:	ee                   	out    %al,(%dx)
f010075e:	eb 0c                	jmp    f010076c <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100760:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100765:	eb 05                	jmp    f010076c <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100767:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010076c:	89 d8                	mov    %ebx,%eax
f010076e:	83 c4 14             	add    $0x14,%esp
f0100771:	5b                   	pop    %ebx
f0100772:	5d                   	pop    %ebp
f0100773:	c3                   	ret    

f0100774 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010077a:	80 3d c0 ad 20 f0 00 	cmpb   $0x0,0xf020adc0
f0100781:	74 0a                	je     f010078d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100783:	b8 66 01 10 f0       	mov    $0xf0100166,%eax
f0100788:	e8 f5 f9 ff ff       	call   f0100182 <cons_intr>
}
f010078d:	c9                   	leave  
f010078e:	c3                   	ret    

f010078f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010078f:	55                   	push   %ebp
f0100790:	89 e5                	mov    %esp,%ebp
f0100792:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100795:	b8 68 06 10 f0       	mov    $0xf0100668,%eax
f010079a:	e8 e3 f9 ff ff       	call   f0100182 <cons_intr>
}
f010079f:	c9                   	leave  
f01007a0:	c3                   	ret    

f01007a1 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01007a1:	55                   	push   %ebp
f01007a2:	89 e5                	mov    %esp,%ebp
f01007a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01007a7:	e8 c8 ff ff ff       	call   f0100774 <serial_intr>
	kbd_intr();
f01007ac:	e8 de ff ff ff       	call   f010078f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01007b1:	8b 15 e0 af 20 f0    	mov    0xf020afe0,%edx
f01007b7:	3b 15 e4 af 20 f0    	cmp    0xf020afe4,%edx
f01007bd:	74 22                	je     f01007e1 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01007bf:	0f b6 82 e0 ad 20 f0 	movzbl -0xfdf5220(%edx),%eax
f01007c6:	42                   	inc    %edx
f01007c7:	89 15 e0 af 20 f0    	mov    %edx,0xf020afe0
		if (cons.rpos == CONSBUFSIZE)
f01007cd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01007d3:	75 11                	jne    f01007e6 <cons_getc+0x45>
			cons.rpos = 0;
f01007d5:	c7 05 e0 af 20 f0 00 	movl   $0x0,0xf020afe0
f01007dc:	00 00 00 
f01007df:	eb 05                	jmp    f01007e6 <cons_getc+0x45>
		return c;
	}
	return 0;
f01007e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01007e6:	c9                   	leave  
f01007e7:	c3                   	ret    

f01007e8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01007e8:	55                   	push   %ebp
f01007e9:	89 e5                	mov    %esp,%ebp
f01007eb:	57                   	push   %edi
f01007ec:	56                   	push   %esi
f01007ed:	53                   	push   %ebx
f01007ee:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01007f1:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01007f8:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01007ff:	5a a5 
	if (*cp != 0xA55A) {
f0100801:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100807:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010080b:	74 11                	je     f010081e <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010080d:	c7 05 ec af 20 f0 b4 	movl   $0x3b4,0xf020afec
f0100814:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100817:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010081c:	eb 16                	jmp    f0100834 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010081e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100825:	c7 05 ec af 20 f0 d4 	movl   $0x3d4,0xf020afec
f010082c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010082f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100834:	8b 0d ec af 20 f0    	mov    0xf020afec,%ecx
f010083a:	b0 0e                	mov    $0xe,%al
f010083c:	89 ca                	mov    %ecx,%edx
f010083e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010083f:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100842:	89 da                	mov    %ebx,%edx
f0100844:	ec                   	in     (%dx),%al
f0100845:	0f b6 f8             	movzbl %al,%edi
f0100848:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010084b:	b0 0f                	mov    $0xf,%al
f010084d:	89 ca                	mov    %ecx,%edx
f010084f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100850:	89 da                	mov    %ebx,%edx
f0100852:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100853:	89 35 f0 af 20 f0    	mov    %esi,0xf020aff0

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100859:	0f b6 d8             	movzbl %al,%ebx
f010085c:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010085e:	66 89 3d f4 af 20 f0 	mov    %di,0xf020aff4
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100865:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010086a:	b0 00                	mov    $0x0,%al
f010086c:	89 da                	mov    %ebx,%edx
f010086e:	ee                   	out    %al,(%dx)
f010086f:	b2 fb                	mov    $0xfb,%dl
f0100871:	b0 80                	mov    $0x80,%al
f0100873:	ee                   	out    %al,(%dx)
f0100874:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100879:	b0 0c                	mov    $0xc,%al
f010087b:	89 ca                	mov    %ecx,%edx
f010087d:	ee                   	out    %al,(%dx)
f010087e:	b2 f9                	mov    $0xf9,%dl
f0100880:	b0 00                	mov    $0x0,%al
f0100882:	ee                   	out    %al,(%dx)
f0100883:	b2 fb                	mov    $0xfb,%dl
f0100885:	b0 03                	mov    $0x3,%al
f0100887:	ee                   	out    %al,(%dx)
f0100888:	b2 fc                	mov    $0xfc,%dl
f010088a:	b0 00                	mov    $0x0,%al
f010088c:	ee                   	out    %al,(%dx)
f010088d:	b2 f9                	mov    $0xf9,%dl
f010088f:	b0 01                	mov    $0x1,%al
f0100891:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100892:	b2 fd                	mov    $0xfd,%dl
f0100894:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100895:	3c ff                	cmp    $0xff,%al
f0100897:	0f 95 45 e7          	setne  -0x19(%ebp)
f010089b:	8a 45 e7             	mov    -0x19(%ebp),%al
f010089e:	a2 c0 ad 20 f0       	mov    %al,0xf020adc0
f01008a3:	89 da                	mov    %ebx,%edx
f01008a5:	ec                   	in     (%dx),%al
f01008a6:	89 ca                	mov    %ecx,%edx
f01008a8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01008a9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01008ad:	75 0c                	jne    f01008bb <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f01008af:	c7 04 24 9c 6b 10 f0 	movl   $0xf0106b9c,(%esp)
f01008b6:	e8 1b 46 00 00       	call   f0104ed6 <cprintf>
}
f01008bb:	83 c4 2c             	add    $0x2c,%esp
f01008be:	5b                   	pop    %ebx
f01008bf:	5e                   	pop    %esi
f01008c0:	5f                   	pop    %edi
f01008c1:	5d                   	pop    %ebp
f01008c2:	c3                   	ret    

f01008c3 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01008c3:	55                   	push   %ebp
f01008c4:	89 e5                	mov    %esp,%ebp
f01008c6:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01008c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01008cc:	e8 f2 f8 ff ff       	call   f01001c3 <cons_putc>
}
f01008d1:	c9                   	leave  
f01008d2:	c3                   	ret    

f01008d3 <getchar>:

int
getchar(void)
{
f01008d3:	55                   	push   %ebp
f01008d4:	89 e5                	mov    %esp,%ebp
f01008d6:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01008d9:	e8 c3 fe ff ff       	call   f01007a1 <cons_getc>
f01008de:	85 c0                	test   %eax,%eax
f01008e0:	74 f7                	je     f01008d9 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01008e2:	c9                   	leave  
f01008e3:	c3                   	ret    

f01008e4 <iscons>:

int
iscons(int fdnum)
{
f01008e4:	55                   	push   %ebp
f01008e5:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01008e7:	b8 01 00 00 00       	mov    $0x1,%eax
f01008ec:	5d                   	pop    %ebp
f01008ed:	c3                   	ret    
	...

f01008f0 <mon_stepi>:
        	return 0;
    }
}

int
mon_stepi(int argc, char **argv, struct Trapframe *tf){
f01008f0:	55                   	push   %ebp
f01008f1:	89 e5                	mov    %esp,%ebp
f01008f3:	83 ec 18             	sub    $0x18,%esp
f01008f6:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!tf){cprintf("mon_stepi: No Trapframe!\n");return 0;}
f01008f9:	85 c0                	test   %eax,%eax
f01008fb:	75 13                	jne    f0100910 <mon_stepi+0x20>
f01008fd:	c7 04 24 b9 6b 10 f0 	movl   $0xf0106bb9,(%esp)
f0100904:	e8 cd 45 00 00       	call   f0104ed6 <cprintf>
f0100909:	b8 00 00 00 00       	mov    $0x0,%eax
f010090e:	eb 31                	jmp    f0100941 <mon_stepi+0x51>
    switch (tf->tf_trapno){
f0100910:	8b 50 28             	mov    0x28(%eax),%edx
f0100913:	83 fa 01             	cmp    $0x1,%edx
f0100916:	74 13                	je     f010092b <mon_stepi+0x3b>
f0100918:	83 fa 03             	cmp    $0x3,%edx
f010091b:	75 1f                	jne    f010093c <mon_stepi+0x4c>
    	case T_BRKPT:tf->tf_eflags|=FL_TF;return -1;
f010091d:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
f0100924:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100929:	eb 16                	jmp    f0100941 <mon_stepi+0x51>
    	case T_DEBUG:
        	if (tf->tf_eflags&FL_TF)return -1;
f010092b:	8b 40 38             	mov    0x38(%eax),%eax
f010092e:	25 00 01 00 00       	and    $0x100,%eax
    	default:
        	return 0;
f0100933:	83 f8 01             	cmp    $0x1,%eax
f0100936:	19 c0                	sbb    %eax,%eax
f0100938:	f7 d0                	not    %eax
f010093a:	eb 05                	jmp    f0100941 <mon_stepi+0x51>
f010093c:	b8 00 00 00 00       	mov    $0x0,%eax
    }    
}
f0100941:	c9                   	leave  
f0100942:	c3                   	ret    

f0100943 <mon_continue>:
	else cprintf(".\n");
	return 0;
}

int
mon_continue(int argc, char **argv, struct Trapframe *tf){
f0100943:	55                   	push   %ebp
f0100944:	89 e5                	mov    %esp,%ebp
f0100946:	83 ec 18             	sub    $0x18,%esp
f0100949:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!tf){cprintf("mon_continue: No Trapframe!\n");return 0;}
f010094c:	85 c0                	test   %eax,%eax
f010094e:	75 13                	jne    f0100963 <mon_continue+0x20>
f0100950:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f0100957:	e8 7a 45 00 00       	call   f0104ed6 <cprintf>
f010095c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100961:	eb 2e                	jmp    f0100991 <mon_continue+0x4e>
	switch (tf->tf_trapno){
f0100963:	8b 50 28             	mov    0x28(%eax),%edx
f0100966:	83 fa 01             	cmp    $0x1,%edx
f0100969:	74 13                	je     f010097e <mon_continue+0x3b>
f010096b:	83 fa 03             	cmp    $0x3,%edx
f010096e:	75 1c                	jne    f010098c <mon_continue+0x49>
    	case T_BRKPT:
            tf->tf_eflags &= ~FL_TF;return -1;
f0100970:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
f0100977:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010097c:	eb 13                	jmp    f0100991 <mon_continue+0x4e>
    	case T_DEBUG:
            tf->tf_eflags &= ~FL_TF;return -1;
f010097e:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
f0100985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010098a:	eb 05                	jmp    f0100991 <mon_continue+0x4e>
    	default:
        	return 0;
f010098c:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
f0100991:	c9                   	leave  
f0100992:	c3                   	ret    

f0100993 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100993:	55                   	push   %ebp
f0100994:	89 e5                	mov    %esp,%ebp
f0100996:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100999:	c7 04 24 f0 6b 10 f0 	movl   $0xf0106bf0,(%esp)
f01009a0:	e8 31 45 00 00       	call   f0104ed6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01009a5:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01009ac:	00 
f01009ad:	c7 04 24 48 6e 10 f0 	movl   $0xf0106e48,(%esp)
f01009b4:	e8 1d 45 00 00       	call   f0104ed6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01009b9:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01009c0:	00 
f01009c1:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01009c8:	f0 
f01009c9:	c7 04 24 70 6e 10 f0 	movl   $0xf0106e70,(%esp)
f01009d0:	e8 01 45 00 00       	call   f0104ed6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01009d5:	c7 44 24 08 32 68 10 	movl   $0x106832,0x8(%esp)
f01009dc:	00 
f01009dd:	c7 44 24 04 32 68 10 	movl   $0xf0106832,0x4(%esp)
f01009e4:	f0 
f01009e5:	c7 04 24 94 6e 10 f0 	movl   $0xf0106e94,(%esp)
f01009ec:	e8 e5 44 00 00       	call   f0104ed6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01009f1:	c7 44 24 08 c0 ad 20 	movl   $0x20adc0,0x8(%esp)
f01009f8:	00 
f01009f9:	c7 44 24 04 c0 ad 20 	movl   $0xf020adc0,0x4(%esp)
f0100a00:	f0 
f0100a01:	c7 04 24 b8 6e 10 f0 	movl   $0xf0106eb8,(%esp)
f0100a08:	e8 c9 44 00 00       	call   f0104ed6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100a0d:	c7 44 24 08 a0 bc 20 	movl   $0x20bca0,0x8(%esp)
f0100a14:	00 
f0100a15:	c7 44 24 04 a0 bc 20 	movl   $0xf020bca0,0x4(%esp)
f0100a1c:	f0 
f0100a1d:	c7 04 24 dc 6e 10 f0 	movl   $0xf0106edc,(%esp)
f0100a24:	e8 ad 44 00 00       	call   f0104ed6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100a29:	b8 9f c0 20 f0       	mov    $0xf020c09f,%eax
f0100a2e:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100a33:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a38:	89 c2                	mov    %eax,%edx
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	79 06                	jns    f0100a44 <mon_kerninfo+0xb1>
f0100a3e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100a44:	c1 fa 0a             	sar    $0xa,%edx
f0100a47:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a4b:	c7 04 24 00 6f 10 f0 	movl   $0xf0106f00,(%esp)
f0100a52:	e8 7f 44 00 00       	call   f0104ed6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100a57:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a5c:	c9                   	leave  
f0100a5d:	c3                   	ret    

f0100a5e <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100a5e:	55                   	push   %ebp
f0100a5f:	89 e5                	mov    %esp,%ebp
f0100a61:	56                   	push   %esi
f0100a62:	53                   	push   %ebx
f0100a63:	83 ec 10             	sub    $0x10,%esp
f0100a66:	bb a4 7b 10 f0       	mov    $0xf0107ba4,%ebx
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f0100a6b:	be 34 7c 10 f0       	mov    $0xf0107c34,%esi
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100a70:	8b 03                	mov    (%ebx),%eax
f0100a72:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a76:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100a79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a7d:	c7 04 24 09 6c 10 f0 	movl   $0xf0106c09,(%esp)
f0100a84:	e8 4d 44 00 00       	call   f0104ed6 <cprintf>
f0100a89:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100a8c:	39 f3                	cmp    %esi,%ebx
f0100a8e:	75 e0                	jne    f0100a70 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100a90:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a95:	83 c4 10             	add    $0x10,%esp
f0100a98:	5b                   	pop    %ebx
f0100a99:	5e                   	pop    %esi
f0100a9a:	5d                   	pop    %ebp
f0100a9b:	c3                   	ret    

f0100a9c <mon_showvirtualmemory>:

    return 0;
}

int
mon_showvirtualmemory(int argc, char **argv, struct Trapframe *tf){
f0100a9c:	55                   	push   %ebp
f0100a9d:	89 e5                	mov    %esp,%ebp
f0100a9f:	57                   	push   %edi
f0100aa0:	56                   	push   %esi
f0100aa1:	53                   	push   %ebx
f0100aa2:	83 ec 2c             	sub    $0x2c,%esp
f0100aa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f0100aa8:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100aac:	74 11                	je     f0100abf <mon_showvirtualmemory+0x23>
		cprintf("mon_showvvirtualmemory: The number of parameters is two.\n");
f0100aae:	c7 04 24 2c 6f 10 f0 	movl   $0xf0106f2c,(%esp)
f0100ab5:	e8 1c 44 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100aba:	e9 37 01 00 00       	jmp    f0100bf6 <mon_showvirtualmemory+0x15a>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0100abf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ac6:	00 
f0100ac7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100aca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ace:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ad1:	89 04 24             	mov    %eax,(%esp)
f0100ad4:	e8 3f 5a 00 00       	call   f0106518 <strtol>
f0100ad9:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0100adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ade:	80 38 00             	cmpb   $0x0,(%eax)
f0100ae1:	74 11                	je     f0100af4 <mon_showvirtualmemory+0x58>
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
f0100ae3:	c7 04 24 68 6f 10 f0 	movl   $0xf0106f68,(%esp)
f0100aea:	e8 e7 43 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100aef:	e9 02 01 00 00       	jmp    f0100bf6 <mon_showvirtualmemory+0x15a>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100af4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100afb:	00 
f0100afc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100aff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b03:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b06:	89 04 24             	mov    %eax,(%esp)
f0100b09:	e8 0a 5a 00 00       	call   f0106518 <strtol>
	if (*errChar){
f0100b0e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b11:	80 3a 00             	cmpb   $0x0,(%edx)
f0100b14:	74 11                	je     f0100b27 <mon_showvirtualmemory+0x8b>
		cprintf("mon_showvvirtualmemory: The second argument is not a number.\n");
f0100b16:	c7 04 24 a8 6f 10 f0 	movl   $0xf0106fa8,(%esp)
f0100b1d:	e8 b4 43 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100b22:	e9 cf 00 00 00       	jmp    f0100bf6 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr&0x3){
f0100b27:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0100b2d:	74 11                	je     f0100b40 <mon_showvirtualmemory+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f0100b2f:	c7 04 24 e8 6f 10 f0 	movl   $0xf0106fe8,(%esp)
f0100b36:	e8 9b 43 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100b3b:	e9 b6 00 00 00       	jmp    f0100bf6 <mon_showvirtualmemory+0x15a>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100b40:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3){
f0100b42:	a8 03                	test   $0x3,%al
f0100b44:	74 11                	je     f0100b57 <mon_showvirtualmemory+0xbb>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0100b46:	c7 04 24 24 70 10 f0 	movl   $0xf0107024,(%esp)
f0100b4d:	e8 84 43 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100b52:	e9 9f 00 00 00       	jmp    f0100bf6 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr > EndAddr){
f0100b57:	39 c6                	cmp    %eax,%esi
f0100b59:	0f 86 88 00 00 00    	jbe    f0100be7 <mon_showvirtualmemory+0x14b>
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
f0100b5f:	c7 04 24 60 70 10 f0 	movl   $0xf0107060,(%esp)
f0100b66:	e8 6b 43 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100b6b:	e9 86 00 00 00       	jmp    f0100bf6 <mon_showvirtualmemory+0x15a>
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
		switch (c){
f0100b70:	83 fe 01             	cmp    $0x1,%esi
f0100b73:	74 2f                	je     f0100ba4 <mon_showvirtualmemory+0x108>
f0100b75:	83 fe 01             	cmp    $0x1,%esi
f0100b78:	7f 06                	jg     f0100b80 <mon_showvirtualmemory+0xe4>
f0100b7a:	85 f6                	test   %esi,%esi
f0100b7c:	74 0e                	je     f0100b8c <mon_showvirtualmemory+0xf0>
f0100b7e:	eb 5e                	jmp    f0100bde <mon_showvirtualmemory+0x142>
f0100b80:	83 fe 02             	cmp    $0x2,%esi
f0100b83:	74 33                	je     f0100bb8 <mon_showvirtualmemory+0x11c>
f0100b85:	83 fe 03             	cmp    $0x3,%esi
f0100b88:	75 54                	jne    f0100bde <mon_showvirtualmemory+0x142>
f0100b8a:	eb 40                	jmp    f0100bcc <mon_showvirtualmemory+0x130>
			case 0:cprintf("0x%08x   :0x%08x    ",Address,*(int*)Address);break;
f0100b8c:	8b 03                	mov    (%ebx),%eax
f0100b8e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b96:	c7 04 24 12 6c 10 f0 	movl   $0xf0106c12,(%esp)
f0100b9d:	e8 34 43 00 00       	call   f0104ed6 <cprintf>
f0100ba2:	eb 3a                	jmp    f0100bde <mon_showvirtualmemory+0x142>
			case 1:cprintf("0x%08x    ",*(int*)Address);break;
f0100ba4:	8b 03                	mov    (%ebx),%eax
f0100ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100baa:	c7 04 24 1c 6c 10 f0 	movl   $0xf0106c1c,(%esp)
f0100bb1:	e8 20 43 00 00       	call   f0104ed6 <cprintf>
f0100bb6:	eb 26                	jmp    f0100bde <mon_showvirtualmemory+0x142>
			case 2:cprintf("0x%08x    ",*(int*)Address);break;
f0100bb8:	8b 03                	mov    (%ebx),%eax
f0100bba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bbe:	c7 04 24 1c 6c 10 f0 	movl   $0xf0106c1c,(%esp)
f0100bc5:	e8 0c 43 00 00       	call   f0104ed6 <cprintf>
f0100bca:	eb 12                	jmp    f0100bde <mon_showvirtualmemory+0x142>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
f0100bcc:	8b 03                	mov    (%ebx),%eax
f0100bce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bd2:	c7 04 24 00 8a 10 f0 	movl   $0xf0108a00,(%esp)
f0100bd9:	e8 f8 42 00 00       	call   f0104ed6 <cprintf>
		}
		c = (c+1)&3;
f0100bde:	46                   	inc    %esi
f0100bdf:	83 e6 03             	and    $0x3,%esi
	if (StartAddr > EndAddr){
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100be2:	83 c3 04             	add    $0x4,%ebx
f0100be5:	eb 07                	jmp    f0100bee <mon_showvirtualmemory+0x152>
	}
	if (EndAddr&0x3){
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
f0100be7:	89 f3                	mov    %esi,%ebx
f0100be9:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100bee:	39 fb                	cmp    %edi,%ebx
f0100bf0:	0f 82 7a ff ff ff    	jb     f0100b70 <mon_showvirtualmemory+0xd4>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
		}
		c = (c+1)&3;
	}
	return 0;
}
f0100bf6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bfb:	83 c4 2c             	add    $0x2c,%esp
f0100bfe:	5b                   	pop    %ebx
f0100bff:	5e                   	pop    %esi
f0100c00:	5f                   	pop    %edi
f0100c01:	5d                   	pop    %ebp
f0100c02:	c3                   	ret    

f0100c03 <mon_va2pa>:
int
mon_va2pa(int argc, char **argv, struct Trapframe *tf){
f0100c03:	55                   	push   %ebp
f0100c04:	89 e5                	mov    %esp,%ebp
f0100c06:	83 ec 28             	sub    $0x28,%esp
	if(argc!=2){
f0100c09:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100c0d:	74 11                	je     f0100c20 <mon_va2pa+0x1d>
		cprintf("mon_va2pa: The number of parameters is one.\n");
f0100c0f:	c7 04 24 b4 70 10 f0 	movl   $0xf01070b4,(%esp)
f0100c16:	e8 bb 42 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100c1b:	e9 cc 00 00 00       	jmp    f0100cec <mon_va2pa+0xe9>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100c20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c27:	00 
f0100c28:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c32:	8b 40 04             	mov    0x4(%eax),%eax
f0100c35:	89 04 24             	mov    %eax,(%esp)
f0100c38:	e8 db 58 00 00       	call   f0106518 <strtol>
	if (*errChar){
f0100c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100c40:	80 3a 00             	cmpb   $0x0,(%edx)
f0100c43:	74 11                	je     f0100c56 <mon_va2pa+0x53>
		cprintf("mon_va2pa: The argument is not a number.\n");
f0100c45:	c7 04 24 e4 70 10 f0 	movl   $0xf01070e4,(%esp)
f0100c4c:	e8 85 42 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100c51:	e9 96 00 00 00       	jmp    f0100cec <mon_va2pa+0xe9>
	}
	pde_t *pde = &kern_pgdir[PDX(Address)];
f0100c56:	89 c1                	mov    %eax,%ecx
f0100c58:	c1 e9 16             	shr    $0x16,%ecx
	if (*pde & PTE_P){
f0100c5b:	8b 15 ac bc 20 f0    	mov    0xf020bcac,%edx
f0100c61:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0100c64:	f6 c2 01             	test   $0x1,%dl
f0100c67:	74 77                	je     f0100ce0 <mon_va2pa+0xdd>
		pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0100c69:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c6f:	89 d1                	mov    %edx,%ecx
f0100c71:	c1 e9 0c             	shr    $0xc,%ecx
f0100c74:	3b 0d a8 bc 20 f0    	cmp    0xf020bca8,%ecx
f0100c7a:	72 20                	jb     f0100c9c <mon_va2pa+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c80:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0100c87:	f0 
f0100c88:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0100c8f:	00 
f0100c90:	c7 04 24 27 6c 10 f0 	movl   $0xf0106c27,(%esp)
f0100c97:	e8 15 f4 ff ff       	call   f01000b1 <_panic>
f0100c9c:	89 c1                	mov    %eax,%ecx
f0100c9e:	c1 e9 0c             	shr    $0xc,%ecx
f0100ca1:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		if (*pte & PTE_P){
f0100ca7:	8b 94 8a 00 00 00 f0 	mov    -0x10000000(%edx,%ecx,4),%edx
f0100cae:	f6 c2 01             	test   $0x1,%dl
f0100cb1:	74 1f                	je     f0100cd2 <mon_va2pa+0xcf>
			cprintf("The physical address is 0x%08x.\n",PTE_ADDR(*pte)|(Address&0x3ff));
f0100cb3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100cb9:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100cbe:	09 d0                	or     %edx,%eax
f0100cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cc4:	c7 04 24 34 71 10 f0 	movl   $0xf0107134,(%esp)
f0100ccb:	e8 06 42 00 00       	call   f0104ed6 <cprintf>
f0100cd0:	eb 1a                	jmp    f0100cec <mon_va2pa+0xe9>
		}
		else 
			cprintf("This is not a valid virtual address.\n");
f0100cd2:	c7 04 24 58 71 10 f0 	movl   $0xf0107158,(%esp)
f0100cd9:	e8 f8 41 00 00       	call   f0104ed6 <cprintf>
f0100cde:	eb 0c                	jmp    f0100cec <mon_va2pa+0xe9>
	}
	else 
		cprintf("This is not a valid virtual address.\n");
f0100ce0:	c7 04 24 58 71 10 f0 	movl   $0xf0107158,(%esp)
f0100ce7:	e8 ea 41 00 00       	call   f0104ed6 <cprintf>
	return 0;
}
f0100cec:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cf1:	c9                   	leave  
f0100cf2:	c3                   	ret    

f0100cf3 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100cf3:	55                   	push   %ebp
f0100cf4:	89 e5                	mov    %esp,%ebp
f0100cf6:	57                   	push   %edi
f0100cf7:	56                   	push   %esi
f0100cf8:	53                   	push   %ebx
f0100cf9:	83 ec 6c             	sub    $0x6c,%esp
	cprintf("\033[34;45mThe parameters are: 34 and 45\n");
	cprintf("\033[35;46mThe parameters are: 35 and 46\n");
	cprintf("\033[36;47mThe parameters are: 36 and 47\n");
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
f0100cfc:	c7 04 24 36 6c 10 f0 	movl   $0xf0106c36,(%esp)
f0100d03:	e8 ce 41 00 00       	call   f0104ed6 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d08:	89 eb                	mov    %ebp,%ebx
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
		eip = *((uint32_t *) ebp + 1);
		debuginfo_eip(eip, &info);
f0100d0a:	8d 7d d0             	lea    -0x30(%ebp),%edi
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100d0d:	eb 6d                	jmp    f0100d7c <mon_backtrace+0x89>
		eip = *((uint32_t *) ebp + 1);
f0100d0f:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f0100d12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d16:	89 34 24             	mov    %esi,(%esp)
f0100d19:	e8 27 4c 00 00       	call   f0105945 <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n         %s:%d: %.*s+%d\n",
f0100d1e:	89 f0                	mov    %esi,%eax
f0100d20:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100d23:	89 44 24 30          	mov    %eax,0x30(%esp)
f0100d27:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d2a:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100d2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d31:	89 44 24 28          	mov    %eax,0x28(%esp)
f0100d35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d38:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100d3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d3f:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100d43:	8b 43 18             	mov    0x18(%ebx),%eax
f0100d46:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100d4a:	8b 43 14             	mov    0x14(%ebx),%eax
f0100d4d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100d51:	8b 43 10             	mov    0x10(%ebx),%eax
f0100d54:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100d58:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100d5b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100d5f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100d62:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d66:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100d6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d6e:	c7 04 24 80 71 10 f0 	movl   $0xf0107180,(%esp)
f0100d75:	e8 5c 41 00 00       	call   f0104ed6 <cprintf>
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100d7a:	8b 1b                	mov    (%ebx),%ebx
f0100d7c:	85 db                	test   %ebx,%ebx
f0100d7e:	75 8f                	jne    f0100d0f <mon_backtrace+0x1c>
				info.eip_fn_namelen,
				info.eip_fn_name,
				eip - info.eip_fn_addr);
	}
	return 0;
}
f0100d80:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d85:	83 c4 6c             	add    $0x6c,%esp
f0100d88:	5b                   	pop    %ebx
f0100d89:	5e                   	pop    %esi
f0100d8a:	5f                   	pop    %edi
f0100d8b:	5d                   	pop    %ebp
f0100d8c:	c3                   	ret    

f0100d8d <mon_pa2va>:
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100d8d:	55                   	push   %ebp
f0100d8e:	89 e5                	mov    %esp,%ebp
f0100d90:	57                   	push   %edi
f0100d91:	56                   	push   %esi
f0100d92:	53                   	push   %ebx
f0100d93:	83 ec 3c             	sub    $0x3c,%esp
	if(argc!=2){
f0100d96:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100d9a:	74 11                	je     f0100dad <mon_pa2va+0x20>
		cprintf("mon_pa2va: The number of parameters is one.\n");
f0100d9c:	c7 04 24 d0 71 10 f0 	movl   $0xf01071d0,(%esp)
f0100da3:	e8 2e 41 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100da8:	e9 34 01 00 00       	jmp    f0100ee1 <mon_pa2va+0x154>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100dad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100db4:	00 
f0100db5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100db8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dbf:	8b 40 04             	mov    0x4(%eax),%eax
f0100dc2:	89 04 24             	mov    %eax,(%esp)
f0100dc5:	e8 4e 57 00 00       	call   f0106518 <strtol>
f0100dca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (*errChar){
f0100dcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dd0:	80 38 00             	cmpb   $0x0,(%eax)
f0100dd3:	74 11                	je     f0100de6 <mon_pa2va+0x59>
		cprintf("mon_pa2va: The argument is not a number.\n");
f0100dd5:	c7 04 24 00 72 10 f0 	movl   $0xf0107200,(%esp)
f0100ddc:	e8 f5 40 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100de1:	e9 fb 00 00 00       	jmp    f0100ee1 <mon_pa2va+0x154>
		cprintf("mon_pa2va: The number of parameters is one.\n");
		return 0;
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
	if (*errChar){
f0100de6:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0100ded:	bf 00 00 00 00       	mov    $0x0,%edi
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100df2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100df5:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100dfa:	89 45 cc             	mov    %eax,-0x34(%ebp)
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100dfd:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100e00:	c1 e6 02             	shl    $0x2,%esi
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
f0100e03:	03 35 ac bc 20 f0    	add    0xf020bcac,%esi
		if (*pde & PTE_P){
f0100e09:	f6 06 01             	testb  $0x1,(%esi)
f0100e0c:	0f 84 a1 00 00 00    	je     f0100eb3 <mon_pa2va+0x126>
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100e12:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100e15:	c1 e0 16             	shl    $0x16,%eax
f0100e18:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
f0100e20:	8b 06                	mov    (%esi),%eax
f0100e22:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e27:	89 c2                	mov    %eax,%edx
f0100e29:	c1 ea 0c             	shr    $0xc,%edx
f0100e2c:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f0100e32:	72 20                	jb     f0100e54 <mon_pa2va+0xc7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e34:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e38:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0100e3f:	f0 
f0100e40:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0100e47:	00 
f0100e48:	c7 04 24 27 6c 10 f0 	movl   $0xf0106c27,(%esp)
f0100e4f:	e8 5d f2 ff ff       	call   f01000b1 <_panic>
				if (*pte & PTE_P){
f0100e54:	8b 84 98 00 00 00 f0 	mov    -0x10000000(%eax,%ebx,4),%eax
f0100e5b:	a8 01                	test   $0x1,%al
f0100e5d:	74 47                	je     f0100ea6 <mon_pa2va+0x119>
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
f0100e5f:	33 45 d4             	xor    -0x2c(%ebp),%eax
f0100e62:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
f0100e67:	75 3d                	jne    f0100ea6 <mon_pa2va+0x119>
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100e69:	85 ff                	test   %edi,%edi
f0100e6b:	75 1d                	jne    f0100e8a <mon_pa2va+0xfd>
f0100e6d:	89 d8                	mov    %ebx,%eax
f0100e6f:	c1 e0 0c             	shl    $0xc,%eax
f0100e72:	0b 45 d0             	or     -0x30(%ebp),%eax
f0100e75:	0b 45 cc             	or     -0x34(%ebp),%eax
f0100e78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e7c:	c7 04 24 2c 72 10 f0 	movl   $0xf010722c,(%esp)
f0100e83:	e8 4e 40 00 00       	call   f0104ed6 <cprintf>
f0100e88:	eb 1b                	jmp    f0100ea5 <mon_pa2va+0x118>
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100e8a:	89 d8                	mov    %ebx,%eax
f0100e8c:	c1 e0 0c             	shl    $0xc,%eax
f0100e8f:	0b 45 d0             	or     -0x30(%ebp),%eax
f0100e92:	0b 45 cc             	or     -0x34(%ebp),%eax
f0100e95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e99:	c7 04 24 47 6c 10 f0 	movl   $0xf0106c47,(%esp)
f0100ea0:	e8 31 40 00 00       	call   f0104ed6 <cprintf>
						cnt++;
f0100ea5:	47                   	inc    %edi
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
f0100ea6:	43                   	inc    %ebx
f0100ea7:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100ead:	0f 85 6d ff ff ff    	jne    f0100e20 <mon_pa2va+0x93>
	if (*errChar){
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
f0100eb3:	ff 45 c8             	incl   -0x38(%ebp)
f0100eb6:	81 7d c8 00 04 00 00 	cmpl   $0x400,-0x38(%ebp)
f0100ebd:	0f 85 3a ff ff ff    	jne    f0100dfd <mon_pa2va+0x70>
					}
				}
			}
		}
	}
	if (cnt == 0)
f0100ec3:	85 ff                	test   %edi,%edi
f0100ec5:	75 0e                	jne    f0100ed5 <mon_pa2va+0x148>
		cprintf("There is no virtual address.\n");
f0100ec7:	c7 04 24 4f 6c 10 f0 	movl   $0xf0106c4f,(%esp)
f0100ece:	e8 03 40 00 00       	call   f0104ed6 <cprintf>
f0100ed3:	eb 0c                	jmp    f0100ee1 <mon_pa2va+0x154>
	else cprintf(".\n");
f0100ed5:	c7 04 24 6a 6c 10 f0 	movl   $0xf0106c6a,(%esp)
f0100edc:	e8 f5 3f 00 00       	call   f0104ed6 <cprintf>
	return 0;
}
f0100ee1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee6:	83 c4 3c             	add    $0x3c,%esp
f0100ee9:	5b                   	pop    %ebx
f0100eea:	5e                   	pop    %esi
f0100eeb:	5f                   	pop    %edi
f0100eec:	5d                   	pop    %ebp
f0100eed:	c3                   	ret    

f0100eee <mon_showmappings>:
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f0100eee:	55                   	push   %ebp
f0100eef:	89 e5                	mov    %esp,%ebp
f0100ef1:	57                   	push   %edi
f0100ef2:	56                   	push   %esi
f0100ef3:	53                   	push   %ebx
f0100ef4:	83 ec 3c             	sub    $0x3c,%esp
f0100ef7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f0100efa:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100efe:	74 11                	je     f0100f11 <mon_showmappings+0x23>
		cprintf("mon_showmappings: The number of parameters is two.\n");
f0100f00:	c7 04 24 50 72 10 f0 	movl   $0xf0107250,(%esp)
f0100f07:	e8 ca 3f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100f0c:	e9 9d 01 00 00       	jmp    f01010ae <mon_showmappings+0x1c0>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0100f11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f18:	00 
f0100f19:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f20:	8b 43 04             	mov    0x4(%ebx),%eax
f0100f23:	89 04 24             	mov    %eax,(%esp)
f0100f26:	e8 ed 55 00 00       	call   f0106518 <strtol>
f0100f2b:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0100f2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f30:	80 38 00             	cmpb   $0x0,(%eax)
f0100f33:	74 11                	je     f0100f46 <mon_showmappings+0x58>
		cprintf("mon_showmappings: The first argument is not a number.\n");
f0100f35:	c7 04 24 84 72 10 f0 	movl   $0xf0107284,(%esp)
f0100f3c:	e8 95 3f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100f41:	e9 68 01 00 00       	jmp    f01010ae <mon_showmappings+0x1c0>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100f46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f4d:	00 
f0100f4e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f55:	8b 43 08             	mov    0x8(%ebx),%eax
f0100f58:	89 04 24             	mov    %eax,(%esp)
f0100f5b:	e8 b8 55 00 00       	call   f0106518 <strtol>
	if (*errChar){
f0100f60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f63:	80 3a 00             	cmpb   $0x0,(%edx)
f0100f66:	74 11                	je     f0100f79 <mon_showmappings+0x8b>
		cprintf("mon_showmappings: The second argument is not a number.\n");
f0100f68:	c7 04 24 bc 72 10 f0 	movl   $0xf01072bc,(%esp)
f0100f6f:	e8 62 3f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100f74:	e9 35 01 00 00       	jmp    f01010ae <mon_showmappings+0x1c0>
	}
	if (StartAddr&0x3ff){
f0100f79:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0100f7f:	74 11                	je     f0100f92 <mon_showmappings+0xa4>
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
f0100f81:	c7 04 24 f4 72 10 f0 	movl   $0xf01072f4,(%esp)
f0100f88:	e8 49 3f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100f8d:	e9 1c 01 00 00       	jmp    f01010ae <mon_showmappings+0x1c0>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showmappings: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100f92:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	}
	if (StartAddr&0x3ff){
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0100f95:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0100f9a:	74 11                	je     f0100fad <mon_showmappings+0xbf>
		cprintf("mon_showmappings: The second parameter is not aligned.\n");
f0100f9c:	c7 04 24 2c 73 10 f0 	movl   $0xf010732c,(%esp)
f0100fa3:	e8 2e 3f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100fa8:	e9 01 01 00 00       	jmp    f01010ae <mon_showmappings+0x1c0>
	}
	if (StartAddr > EndAddr){
f0100fad:	39 c6                	cmp    %eax,%esi
f0100faf:	76 11                	jbe    f0100fc2 <mon_showmappings+0xd4>
		cprintf("mon_shopmappings: The first parameter is larger than the second parameter.\n");
f0100fb1:	c7 04 24 64 73 10 f0 	movl   $0xf0107364,(%esp)
f0100fb8:	e8 19 3f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0100fbd:	e9 ec 00 00 00       	jmp    f01010ae <mon_showmappings+0x1c0>
	}

    cprintf(
f0100fc2:	c7 04 24 b0 73 10 f0 	movl   $0xf01073b0,(%esp)
f0100fc9:	e8 08 3f 00 00       	call   f0104ed6 <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0100fce:	89 f3                	mov    %esi,%ebx
f0100fd0:	e9 d0 00 00 00       	jmp    f01010a5 <mon_showmappings+0x1b7>
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0100fd5:	89 da                	mov    %ebx,%edx
f0100fd7:	c1 ea 16             	shr    $0x16,%edx
		if (*pde & PTE_P){
f0100fda:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0100fdf:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100fe2:	a8 01                	test   $0x1,%al
f0100fe4:	0f 84 a5 00 00 00    	je     f010108f <mon_showmappings+0x1a1>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0100fea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fef:	89 c2                	mov    %eax,%edx
f0100ff1:	c1 ea 0c             	shr    $0xc,%edx
f0100ff4:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f0100ffa:	72 20                	jb     f010101c <mon_showmappings+0x12e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ffc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101000:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0101007:	f0 
f0101008:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f010100f:	00 
f0101010:	c7 04 24 27 6c 10 f0 	movl   $0xf0106c27,(%esp)
f0101017:	e8 95 f0 ff ff       	call   f01000b1 <_panic>
f010101c:	89 da                	mov    %ebx,%edx
f010101e:	c1 ea 0a             	shr    $0xa,%edx
f0101021:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101027:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f010102e:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if (*pte & PTE_P){
f0101031:	8b 10                	mov    (%eax),%edx
f0101033:	f6 c2 01             	test   $0x1,%dl
f0101036:	74 57                	je     f010108f <mon_showmappings+0x1a1>
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f0101038:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f010103e:	b8 08 00 00 00       	mov    $0x8,%eax
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f0101043:	bf 08 00 00 00       	mov    $0x8,%edi
f0101048:	89 fe                	mov    %edi,%esi
f010104a:	29 c6                	sub    %eax,%esi
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
					permission[i] = Bit2Sign[8-i][(perm&1)];
f010104c:	89 d1                	mov    %edx,%ecx
f010104e:	83 e1 01             	and    $0x1,%ecx
f0101051:	8a 8c 71 84 7b 10 f0 	mov    -0xfef847c(%ecx,%esi,2),%cl
f0101058:	88 4c 05 da          	mov    %cl,-0x26(%ebp,%eax,1)
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f010105c:	48                   	dec    %eax
f010105d:	d1 fa                	sar    %edx
f010105f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101062:	75 e4                	jne    f0101048 <mon_showmappings+0x15a>
					permission[i] = Bit2Sign[8-i][(perm&1)];
				}
				permission[9]='\0';
f0101064:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
				cprintf("0x%08x             0x%08x             %s\n",Address,PTE_ADDR(*pte),permission);
f0101068:	8d 45 da             	lea    -0x26(%ebp),%eax
f010106b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010106f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101072:	8b 02                	mov    (%edx),%eax
f0101074:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101079:	89 44 24 08          	mov    %eax,0x8(%esp)
f010107d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101081:	c7 04 24 e4 74 10 f0 	movl   $0xf01074e4,(%esp)
f0101088:	e8 49 3e 00 00       	call   f0104ed6 <cprintf>
				continue;
f010108d:	eb 10                	jmp    f010109f <mon_showmappings+0x1b1>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
f010108f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101093:	c7 04 24 10 75 10 f0 	movl   $0xf0107510,(%esp)
f010109a:	e8 37 3e 00 00       	call   f0104ed6 <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f010109f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010a5:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01010a8:	0f 82 27 ff ff ff    	jb     f0100fd5 <mon_showmappings+0xe7>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}
f01010ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b3:	83 c4 3c             	add    $0x3c,%esp
f01010b6:	5b                   	pop    %ebx
f01010b7:	5e                   	pop    %esi
f01010b8:	5f                   	pop    %edi
f01010b9:	5d                   	pop    %ebp
f01010ba:	c3                   	ret    

f01010bb <disassemble>:
// #include <stdlib.h>
#include <inc/string.h>

unsigned int disassemble(unsigned char *bytes, unsigned int max, int offset, char *output);

unsigned int disassemble(unsigned char *bytes, unsigned int max, int offset, char *output) {
f01010bb:	55                   	push   %ebp
f01010bc:	89 e5                	mov    %esp,%ebp
f01010be:	57                   	push   %edi
f01010bf:	56                   	push   %esi
f01010c0:	53                   	push   %ebx
f01010c1:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f01010c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01010ca:	8a 00                	mov    (%eax),%al
f01010cc:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)

	INSTRUCTION *instructions= standard_instructions;
	if (opcode == 0x0F) { // Extended opcodes
f01010d2:	3c 0f                	cmp    $0xf,%al
f01010d4:	74 11                	je     f01010e7 <disassemble+0x2c>
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f01010d6:	8b 55 08             	mov    0x8(%ebp),%edx
f01010d9:	42                   	inc    %edx
f01010da:	89 95 e4 fd ff ff    	mov    %edx,-0x21c(%ebp)

	INSTRUCTION *instructions= standard_instructions;
f01010e0:	b9 20 83 12 f0       	mov    $0xf0128320,%ecx
f01010e5:	eb 4c                	jmp    f0101133 <disassemble+0x78>
	if (opcode == 0x0F) { // Extended opcodes
		if (max < 2 || *bytes == 0x0F || *bytes == 0xA6 || *bytes == 0xA7 || *bytes == 0xF7 || *bytes == 0xFF) {
f01010e7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f01010eb:	0f 86 4d 08 00 00    	jbe    f010193e <disassemble+0x883>
f01010f1:	8b 55 08             	mov    0x8(%ebp),%edx
f01010f4:	8a 42 01             	mov    0x1(%edx),%al
f01010f7:	3c 0f                	cmp    $0xf,%al
f01010f9:	0f 84 39 08 00 00    	je     f0101938 <disassemble+0x87d>
f01010ff:	3c a6                	cmp    $0xa6,%al
f0101101:	0f 84 37 08 00 00    	je     f010193e <disassemble+0x883>
f0101107:	3c a7                	cmp    $0xa7,%al
f0101109:	0f 84 2f 08 00 00    	je     f010193e <disassemble+0x883>
f010110f:	3c f7                	cmp    $0xf7,%al
f0101111:	0f 84 27 08 00 00    	je     f010193e <disassemble+0x883>
f0101117:	3c ff                	cmp    $0xff,%al
f0101119:	0f 84 1f 08 00 00    	je     f010193e <disassemble+0x883>
			goto ILLEGAL;
		}

		instructions = extended_instructions;
		opcode = *bytes++;
f010111f:	83 c2 02             	add    $0x2,%edx
f0101122:	89 95 e4 fd ff ff    	mov    %edx,-0x21c(%ebp)
f0101128:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)
	if (opcode == 0x0F) { // Extended opcodes
		if (max < 2 || *bytes == 0x0F || *bytes == 0xA6 || *bytes == 0xA7 || *bytes == 0xF7 || *bytes == 0xFF) {
			goto ILLEGAL;
		}

		instructions = extended_instructions;
f010112e:	b9 20 89 13 f0       	mov    $0xf0138920,%ecx
		opcode = *bytes++;
	}

	if (!instructions[opcode].hasModRM) {
f0101133:	0f b6 85 e3 fd ff ff 	movzbl -0x21d(%ebp),%eax
f010113a:	89 c2                	mov    %eax,%edx
f010113c:	c1 e2 06             	shl    $0x6,%edx
f010113f:	01 c2                	add    %eax,%edx
f0101141:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0101144:	8d 3c 41             	lea    (%ecx,%eax,2),%edi
f0101147:	80 3f 00             	cmpb   $0x0,(%edi)
f010114a:	0f 84 02 04 00 00    	je     f0101552 <disassemble+0x497>
	}

	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f0101150:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f0101156:	8a 02                	mov    (%edx),%al
f0101158:	88 c3                	mov    %al,%bl
f010115a:	c0 eb 06             	shr    $0x6,%bl
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
f010115d:	88 c2                	mov    %al,%dl
f010115f:	c0 ea 03             	shr    $0x3,%dl
f0101162:	83 e2 07             	and    $0x7,%edx
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f0101165:	83 e0 07             	and    $0x7,%eax
f0101168:	88 85 dc fd ff ff    	mov    %al,-0x224(%ebp)
f010116e:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f0101174:	46                   	inc    %esi

	switch (instructions[opcode].size) {
f0101175:	8a 47 01             	mov    0x1(%edi),%al
f0101178:	3c 14                	cmp    $0x14,%al
f010117a:	74 25                	je     f01011a1 <disassemble+0xe6>
f010117c:	3c 15                	cmp    $0x15,%al
f010117e:	75 42                	jne    f01011c2 <disassemble+0x107>
		case WORD:
			strcpy(R_output, register_mnemonics16[(int)modRM_reg]);
f0101180:	0f be d2             	movsbl %dl,%edx
f0101183:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101186:	8d 84 80 20 8f 14 f0 	lea    -0xfeb70e0(%eax,%eax,4),%eax
f010118d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101191:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101197:	89 04 24             	mov    %eax,(%esp)
f010119a:	e8 20 51 00 00       	call   f01062bf <strcpy>
			break;
f010119f:	eb 40                	jmp    f01011e1 <disassemble+0x126>
		case BYTE:
			strcpy(R_output, register_mnemonics8[(int)modRM_reg]);
f01011a1:	0f be d2             	movsbl %dl,%edx
f01011a4:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01011a7:	8d 84 80 a0 8f 14 f0 	lea    -0xfeb7060(%eax,%eax,4),%eax
f01011ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011b2:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f01011b8:	89 04 24             	mov    %eax,(%esp)
f01011bb:	e8 ff 50 00 00       	call   f01062bf <strcpy>
			break;
f01011c0:	eb 1f                	jmp    f01011e1 <disassemble+0x126>
		default:
			strcpy(R_output, register_mnemonics32[(int)modRM_reg]);
f01011c2:	0f be d2             	movsbl %dl,%edx
f01011c5:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01011c8:	8d 84 80 20 90 14 f0 	lea    -0xfeb6fe0(%eax,%eax,4),%eax
f01011cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d3:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f01011d9:	89 04 24             	mov    %eax,(%esp)
f01011dc:	e8 de 50 00 00       	call   f01062bf <strcpy>
	}

	if (modRM_mod == 0b11) { // Register addressing mode.
f01011e1:	80 fb 03             	cmp    $0x3,%bl
f01011e4:	0f 85 c7 00 00 00    	jne    f01012b1 <disassemble+0x1f6>
		switch (instructions[opcode].size) {
f01011ea:	8a 47 01             	mov    0x1(%edi),%al
f01011ed:	3c 14                	cmp    $0x14,%al
f01011ef:	74 06                	je     f01011f7 <disassemble+0x13c>
f01011f1:	3c 15                	cmp    $0x15,%al
f01011f3:	75 7e                	jne    f0101273 <disassemble+0x1b8>
f01011f5:	eb 3e                	jmp    f0101235 <disassemble+0x17a>
			case BYTE:
				//sprintf(RM_output, "%s", register_mnemonics8[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
f01011f7:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f01011fe:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101201:	8d 84 80 a0 8f 14 f0 	lea    -0xfeb7060(%eax,%eax,4),%eax
f0101208:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010120c:	c7 44 24 08 f7 84 10 	movl   $0xf01084f7,0x8(%esp)
f0101213:	f0 
f0101214:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f010121b:	00 
f010121c:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101222:	89 04 24             	mov    %eax,(%esp)
f0101225:	e8 6f 4f 00 00       	call   f0106199 <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f010122a:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
	if (modRM_mod == 0b11) { // Register addressing mode.
		switch (instructions[opcode].size) {
			case BYTE:
				//sprintf(RM_output, "%s", register_mnemonics8[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
				break;
f0101230:	e9 1d 03 00 00       	jmp    f0101552 <disassemble+0x497>
			case WORD:
				//sprintf(RM_output, "%s", register_mnemonics16[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics16[(int)modRM_rm]);
f0101235:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f010123c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010123f:	8d 84 80 20 8f 14 f0 	lea    -0xfeb70e0(%eax,%eax,4),%eax
f0101246:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010124a:	c7 44 24 08 f7 84 10 	movl   $0xf01084f7,0x8(%esp)
f0101251:	f0 
f0101252:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101259:	00 
f010125a:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101260:	89 04 24             	mov    %eax,(%esp)
f0101263:	e8 31 4f 00 00       	call   f0106199 <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f0101268:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
				snprintf(RM_output,0xf,"%s",register_mnemonics8[(int)modRM_rm]);
				break;
			case WORD:
				//sprintf(RM_output, "%s", register_mnemonics16[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics16[(int)modRM_rm]);
				break;
f010126e:	e9 df 02 00 00       	jmp    f0101552 <disassemble+0x497>
			default:
				//sprintf(RM_output, "%s", register_mnemonics32[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics32[(int)modRM_rm]);
f0101273:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f010127a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010127d:	8d 84 80 20 90 14 f0 	lea    -0xfeb6fe0(%eax,%eax,4),%eax
f0101284:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101288:	c7 44 24 08 f7 84 10 	movl   $0xf01084f7,0x8(%esp)
f010128f:	f0 
f0101290:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101297:	00 
f0101298:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010129e:	89 04 24             	mov    %eax,(%esp)
f01012a1:	e8 f3 4e 00 00       	call   f0106199 <snprintf>
	char RM_output[0xFF];
	char R_output[0xFF];

	char modRM_mod = ((*bytes) >> 6) & 0b11; // Bits 7-6.
	char modRM_reg = ((*bytes) >> 3) & 0b111; // Bits 5-3.
	char modRM_rm = (*bytes++) & 0b111; // Bits 2-0.
f01012a6:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f01012ac:	e9 a1 02 00 00       	jmp    f0101552 <disassemble+0x497>
				break;
			default:
				//sprintf(RM_output, "%s", register_mnemonics32[(int)modRM_rm]);
				snprintf(RM_output,0xf,"%s",register_mnemonics32[(int)modRM_rm]);
		}
	} else if (modRM_mod == 0b00 && modRM_rm == 0b101) { // Displacement only addressing mode.
f01012b1:	84 db                	test   %bl,%bl
f01012b3:	75 40                	jne    f01012f5 <disassemble+0x23a>
f01012b5:	80 bd dc fd ff ff 05 	cmpb   $0x5,-0x224(%ebp)
f01012bc:	75 37                	jne    f01012f5 <disassemble+0x23a>
		//sprintf(RM_output, "[0x%x]", *(int *)bytes);
		snprintf(RM_output,0xff, "[0x%x]", *(int *)bytes);
f01012be:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f01012c4:	8b 42 01             	mov    0x1(%edx),%eax
f01012c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012cb:	c7 44 24 08 6d 6c 10 	movl   $0xf0106c6d,0x8(%esp)
f01012d2:	f0 
f01012d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01012da:	00 
f01012db:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01012e1:	89 04 24             	mov    %eax,(%esp)
f01012e4:	e8 b0 4e 00 00       	call   f0106199 <snprintf>
		bytes += 4;
f01012e9:	83 85 e4 fd ff ff 05 	addl   $0x5,-0x21c(%ebp)
f01012f0:	e9 5d 02 00 00       	jmp    f0101552 <disassemble+0x497>
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
f01012f5:	80 bd dc fd ff ff 04 	cmpb   $0x4,-0x224(%ebp)
f01012fc:	0f 85 fa 00 00 00    	jne    f01013fc <disassemble+0x341>
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f0101302:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101308:	8a 40 01             	mov    0x1(%eax),%al
f010130b:	88 85 dc fd ff ff    	mov    %al,-0x224(%ebp)
			char SIB_index = ((*bytes) >> 3) & 0b111; // Bits 5-3.
f0101311:	c0 e8 03             	shr    $0x3,%al
f0101314:	83 e0 07             	and    $0x7,%eax
f0101317:	88 85 e2 fd ff ff    	mov    %al,-0x21e(%ebp)
			char SIB_base = (*bytes++) & 0b111; // Bits 2-0.
f010131d:	8a 85 dc fd ff ff    	mov    -0x224(%ebp),%al
f0101323:	83 e0 07             	and    $0x7,%eax

			if (SIB_base == 0b101 && modRM_mod == 0b00) {
f0101326:	3c 05                	cmp    $0x5,%al
f0101328:	75 3a                	jne    f0101364 <disassemble+0x2a9>
f010132a:	84 db                	test   %bl,%bl
f010132c:	75 36                	jne    f0101364 <disassemble+0x2a9>
				//sprintf(RM_output, "[0x%x", *(int *)bytes);
				snprintf(RM_output,0xff, "[0x%x", *(int *)bytes);
f010132e:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f0101334:	8b 42 02             	mov    0x2(%edx),%eax
f0101337:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010133b:	c7 44 24 08 74 6c 10 	movl   $0xf0106c74,0x8(%esp)
f0101342:	f0 
f0101343:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010134a:	00 
f010134b:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101351:	89 04 24             	mov    %eax,(%esp)
f0101354:	e8 40 4e 00 00       	call   f0106199 <snprintf>
				bytes += 4;
f0101359:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f010135f:	83 c6 06             	add    $0x6,%esi
f0101362:	eb 28                	jmp    f010138c <disassemble+0x2d1>
		bytes += 4;
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
			char SIB_index = ((*bytes) >> 3) & 0b111; // Bits 5-3.
			char SIB_base = (*bytes++) & 0b111; // Bits 2-0.
f0101364:	8b b5 e4 fd ff ff    	mov    -0x21c(%ebp),%esi
f010136a:	83 c6 02             	add    $0x2,%esi
			if (SIB_base == 0b101 && modRM_mod == 0b00) {
				//sprintf(RM_output, "[0x%x", *(int *)bytes);
				snprintf(RM_output,0xff, "[0x%x", *(int *)bytes);
				bytes += 4;
			} else {
				strcpy(RM_output, sib_base_mnemonics[(int)SIB_base]);
f010136d:	0f be c0             	movsbl %al,%eax
f0101370:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101373:	8d 84 80 a0 90 14 f0 	lea    -0xfeb6f60(%eax,%eax,4),%eax
f010137a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010137e:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101384:	89 04 24             	mov    %eax,(%esp)
f0101387:	e8 33 4f 00 00       	call   f01062bf <strcpy>
			}

			if (SIB_index != 0b100) {
f010138c:	80 bd e2 fd ff ff 04 	cmpb   $0x4,-0x21e(%ebp)
f0101393:	0f 84 96 00 00 00    	je     f010142f <disassemble+0x374>
				strcat(RM_output, "+");
f0101399:	c7 44 24 04 7a 6c 10 	movl   $0xf0106c7a,0x4(%esp)
f01013a0:	f0 
f01013a1:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01013a7:	89 04 24             	mov    %eax,(%esp)
f01013aa:	e8 2d 4f 00 00       	call   f01062dc <strcat>
				strcat(RM_output, register_mnemonics32[(int)SIB_index]);
f01013af:	0f be 85 e2 fd ff ff 	movsbl -0x21e(%ebp),%eax
f01013b6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01013b9:	8d 84 80 20 90 14 f0 	lea    -0xfeb6fe0(%eax,%eax,4),%eax
f01013c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013c4:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f01013ca:	89 14 24             	mov    %edx,(%esp)
f01013cd:	e8 0a 4f 00 00       	call   f01062dc <strcat>
		//sprintf(RM_output, "[0x%x]", *(int *)bytes);
		snprintf(RM_output,0xff, "[0x%x]", *(int *)bytes);
		bytes += 4;
	} else { // One-byte or four-byte signed displacement follows addressing mode byte(s).
		if (modRM_rm == 0b100) { // Contains SIB byte
			char SIB_scale = ((*bytes) >> 6) & 0b11; // Bits 7-6.
f01013d2:	8a 85 dc fd ff ff    	mov    -0x224(%ebp),%al
f01013d8:	c0 e8 06             	shr    $0x6,%al
			}

			if (SIB_index != 0b100) {
				strcat(RM_output, "+");
				strcat(RM_output, register_mnemonics32[(int)SIB_index]);
				strcat(RM_output, sib_scale_mnemonics[(int)SIB_scale]);
f01013db:	0f be c0             	movsbl %al,%eax
f01013de:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01013e1:	8d 84 80 20 91 14 f0 	lea    -0xfeb6ee0(%eax,%eax,4),%eax
f01013e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013ec:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01013f2:	89 04 24             	mov    %eax,(%esp)
f01013f5:	e8 e2 4e 00 00       	call   f01062dc <strcat>
f01013fa:	eb 33                	jmp    f010142f <disassemble+0x374>
			}
		} else {
			//sprintf(RM_output, "[%s", register_mnemonics32[(int)modRM_rm]);
			snprintf(RM_output,0xf, "[%s", register_mnemonics32[(int)modRM_rm]);
f01013fc:	0f be 85 dc fd ff ff 	movsbl -0x224(%ebp),%eax
f0101403:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101406:	8d 84 80 20 90 14 f0 	lea    -0xfeb6fe0(%eax,%eax,4),%eax
f010140d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101411:	c7 44 24 08 7c 6c 10 	movl   $0xf0106c7c,0x8(%esp)
f0101418:	f0 
f0101419:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101420:	00 
f0101421:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101427:	89 04 24             	mov    %eax,(%esp)
f010142a:	e8 6a 4d 00 00       	call   f0106199 <snprintf>
		}

		if (modRM_mod == 0b01) { // One-byte signed displacement follows addressing mode byte(s).
f010142f:	80 fb 01             	cmp    $0x1,%bl
f0101432:	0f 85 80 00 00 00    	jne    f01014b8 <disassemble+0x3fd>
			if (*bytes > 0x7F) {
f0101438:	8a 1e                	mov    (%esi),%bl
f010143a:	84 db                	test   %bl,%bl
f010143c:	79 3d                	jns    f010147b <disassemble+0x3c0>
				//sprintf(RM_output + strlen(RM_output), "-0x%x]", -*(char *)bytes++);
				snprintf(RM_output + strlen(RM_output),0xff, "-0x%x]", -*(char *)bytes++);
f010143e:	46                   	inc    %esi
f010143f:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f0101445:	8d b5 e9 fe ff ff    	lea    -0x117(%ebp),%esi
f010144b:	89 34 24             	mov    %esi,(%esp)
f010144e:	e8 39 4e 00 00       	call   f010628c <strlen>
f0101453:	0f be db             	movsbl %bl,%ebx
f0101456:	f7 db                	neg    %ebx
f0101458:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010145c:	c7 44 24 08 80 6c 10 	movl   $0xf0106c80,0x8(%esp)
f0101463:	f0 
f0101464:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010146b:	00 
f010146c:	01 f0                	add    %esi,%eax
f010146e:	89 04 24             	mov    %eax,(%esp)
f0101471:	e8 23 4d 00 00       	call   f0106199 <snprintf>
f0101476:	e9 d7 00 00 00       	jmp    f0101552 <disassemble+0x497>
			} else {
				//sprintf(RM_output + strlen(RM_output), "+0x%x]", *(char *)bytes++);
				snprintf(RM_output + strlen(RM_output),0xff, "+0x%x]", *(char *)bytes++);
f010147b:	46                   	inc    %esi
f010147c:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f0101482:	8d b5 e9 fe ff ff    	lea    -0x117(%ebp),%esi
f0101488:	89 34 24             	mov    %esi,(%esp)
f010148b:	e8 fc 4d 00 00       	call   f010628c <strlen>
f0101490:	89 c2                	mov    %eax,%edx
f0101492:	0f be c3             	movsbl %bl,%eax
f0101495:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101499:	c7 44 24 08 87 6c 10 	movl   $0xf0106c87,0x8(%esp)
f01014a0:	f0 
f01014a1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01014a8:	00 
f01014a9:	01 f2                	add    %esi,%edx
f01014ab:	89 14 24             	mov    %edx,(%esp)
f01014ae:	e8 e6 4c 00 00       	call   f0106199 <snprintf>
f01014b3:	e9 9a 00 00 00       	jmp    f0101552 <disassemble+0x497>
			}
		} else if (modRM_mod == 0b10) { // Four-byte signed displacement follows addressing mode byte(s).
f01014b8:	80 fb 02             	cmp    $0x2,%bl
f01014bb:	75 79                	jne    f0101536 <disassemble+0x47b>
			if (*(unsigned int *)bytes > 0x7FFFFFFF) {
f01014bd:	8b 1e                	mov    (%esi),%ebx
f01014bf:	85 db                	test   %ebx,%ebx
f01014c1:	79 36                	jns    f01014f9 <disassemble+0x43e>
				//sprintf(RM_output + strlen(RM_output), "-0x%x]", -*(int *)bytes);
				snprintf(RM_output + strlen(RM_output),0xff, "-0x%x]", -*(int *)bytes);
f01014c3:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f01014c9:	89 14 24             	mov    %edx,(%esp)
f01014cc:	e8 bb 4d 00 00       	call   f010628c <strlen>
f01014d1:	f7 db                	neg    %ebx
f01014d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01014d7:	c7 44 24 08 80 6c 10 	movl   $0xf0106c80,0x8(%esp)
f01014de:	f0 
f01014df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01014e6:	00 
f01014e7:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f01014ed:	01 d0                	add    %edx,%eax
f01014ef:	89 04 24             	mov    %eax,(%esp)
f01014f2:	e8 a2 4c 00 00       	call   f0106199 <snprintf>
f01014f7:	eb 32                	jmp    f010152b <disassemble+0x470>
			} else {
				//sprintf(RM_output + strlen(RM_output), "+0x%x]", *(unsigned int *)bytes);
				snprintf(RM_output + strlen(RM_output),0xff, "+0x%x]", *(unsigned int *)bytes);
f01014f9:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f01014ff:	89 04 24             	mov    %eax,(%esp)
f0101502:	e8 85 4d 00 00       	call   f010628c <strlen>
f0101507:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010150b:	c7 44 24 08 87 6c 10 	movl   $0xf0106c87,0x8(%esp)
f0101512:	f0 
f0101513:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010151a:	00 
f010151b:	8d 95 e9 fe ff ff    	lea    -0x117(%ebp),%edx
f0101521:	01 d0                	add    %edx,%eax
f0101523:	89 04 24             	mov    %eax,(%esp)
f0101526:	e8 6e 4c 00 00       	call   f0106199 <snprintf>
			}

			bytes += 4;
f010152b:	83 c6 04             	add    $0x4,%esi
f010152e:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
f0101534:	eb 1c                	jmp    f0101552 <disassemble+0x497>
		} else {
			strcat(RM_output, "]");
f0101536:	c7 44 24 04 8c 6c 10 	movl   $0xf0106c8c,0x4(%esp)
f010153d:	f0 
f010153e:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f0101544:	89 04 24             	mov    %eax,(%esp)
f0101547:	e8 90 4d 00 00       	call   f01062dc <strcat>
f010154c:	89 b5 e4 fd ff ff    	mov    %esi,-0x21c(%ebp)
		}
	}

OUTPUT:
	modRM_mod = 0x0;
	strcpy(output, instructions[opcode].mnemonic);
f0101552:	8d 47 02             	lea    0x2(%edi),%eax
f0101555:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101559:	8b 45 14             	mov    0x14(%ebp),%eax
f010155c:	89 04 24             	mov    %eax,(%esp)
f010155f:	e8 5b 4d 00 00       	call   f01062bf <strcpy>
	for (int i = 0; i < instructions[opcode].argument_count; i++) {
f0101564:	be 00 00 00 00       	mov    $0x0,%esi
f0101569:	e9 ab 03 00 00       	jmp    f0101919 <disassemble+0x85e>
		if (i > 0) {
f010156e:	85 f6                	test   %esi,%esi
f0101570:	7e 13                	jle    f0101585 <disassemble+0x4ca>
			strcat(output, ",");
f0101572:	c7 44 24 04 8e 6c 10 	movl   $0xf0106c8e,0x4(%esp)
f0101579:	f0 
f010157a:	8b 55 14             	mov    0x14(%ebp),%edx
f010157d:	89 14 24             	mov    %edx,(%esp)
f0101580:	e8 57 4d 00 00       	call   f01062dc <strcat>
		}

		switch (instructions[opcode].arguments[i]) {
f0101585:	80 bc 37 02 01 00 00 	cmpb   $0x13,0x102(%edi,%esi,1)
f010158c:	13 
f010158d:	0f 87 85 03 00 00    	ja     f0101918 <disassemble+0x85d>
f0101593:	0f b6 84 37 02 01 00 	movzbl 0x102(%edi,%esi,1),%eax
f010159a:	00 
f010159b:	ff 24 85 c0 7a 10 f0 	jmp    *-0xfef8540(,%eax,4)
			case RM:
				if (modRM_mod != 0b11) {
					switch (instructions[opcode].size) {
f01015a2:	8a 47 01             	mov    0x1(%edi),%al
f01015a5:	83 e8 14             	sub    $0x14,%eax
f01015a8:	3c 05                	cmp    $0x5,%al
f01015aa:	0f 87 86 00 00 00    	ja     f0101636 <disassemble+0x57b>
f01015b0:	0f b6 c0             	movzbl %al,%eax
f01015b3:	ff 24 85 10 7b 10 f0 	jmp    *-0xfef84f0(,%eax,4)
						case BYTE:
							strcat(output, "BYTE PTR ");
f01015ba:	c7 44 24 04 90 6c 10 	movl   $0xf0106c90,0x4(%esp)
f01015c1:	f0 
f01015c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01015c5:	89 04 24             	mov    %eax,(%esp)
f01015c8:	e8 0f 4d 00 00       	call   f01062dc <strcat>
							break;
f01015cd:	eb 67                	jmp    f0101636 <disassemble+0x57b>
						case WORD:
							strcat(output, "WORD PTR ");
f01015cf:	c7 44 24 04 9b 6c 10 	movl   $0xf0106c9b,0x4(%esp)
f01015d6:	f0 
f01015d7:	8b 55 14             	mov    0x14(%ebp),%edx
f01015da:	89 14 24             	mov    %edx,(%esp)
f01015dd:	e8 fa 4c 00 00       	call   f01062dc <strcat>
							break;
f01015e2:	eb 52                	jmp    f0101636 <disassemble+0x57b>
						case DWORD:
							strcat(output, "DWORD PTR ");
f01015e4:	c7 44 24 04 9a 6c 10 	movl   $0xf0106c9a,0x4(%esp)
f01015eb:	f0 
f01015ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01015ef:	89 04 24             	mov    %eax,(%esp)
f01015f2:	e8 e5 4c 00 00       	call   f01062dc <strcat>
							break;
f01015f7:	eb 3d                	jmp    f0101636 <disassemble+0x57b>
						case QWORD:
							strcat(output, "QWORD PTR ");
f01015f9:	c7 44 24 04 a5 6c 10 	movl   $0xf0106ca5,0x4(%esp)
f0101600:	f0 
f0101601:	8b 55 14             	mov    0x14(%ebp),%edx
f0101604:	89 14 24             	mov    %edx,(%esp)
f0101607:	e8 d0 4c 00 00       	call   f01062dc <strcat>
							break;
f010160c:	eb 28                	jmp    f0101636 <disassemble+0x57b>
						case FWORD:
							strcat(output, "FWORD PTR ");
f010160e:	c7 44 24 04 b0 6c 10 	movl   $0xf0106cb0,0x4(%esp)
f0101615:	f0 
f0101616:	8b 45 14             	mov    0x14(%ebp),%eax
f0101619:	89 04 24             	mov    %eax,(%esp)
f010161c:	e8 bb 4c 00 00       	call   f01062dc <strcat>
							break;
f0101621:	eb 13                	jmp    f0101636 <disassemble+0x57b>
						case XMMWORD:
							strcat(output, "XMMWORD PTR ");
f0101623:	c7 44 24 04 bb 6c 10 	movl   $0xf0106cbb,0x4(%esp)
f010162a:	f0 
f010162b:	8b 55 14             	mov    0x14(%ebp),%edx
f010162e:	89 14 24             	mov    %edx,(%esp)
f0101631:	e8 a6 4c 00 00       	call   f01062dc <strcat>
							break;
					}
				}

				strcat(output, RM_output);
f0101636:	8d 85 e9 fe ff ff    	lea    -0x117(%ebp),%eax
f010163c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101640:	8b 55 14             	mov    0x14(%ebp),%edx
f0101643:	89 14 24             	mov    %edx,(%esp)
f0101646:	e8 91 4c 00 00       	call   f01062dc <strcat>
				break;
f010164b:	e9 c8 02 00 00       	jmp    f0101918 <disassemble+0x85d>
			case R:
				strcat(output, R_output);
f0101650:	8d 85 ea fd ff ff    	lea    -0x216(%ebp),%eax
f0101656:	89 44 24 04          	mov    %eax,0x4(%esp)
f010165a:	8b 55 14             	mov    0x14(%ebp),%edx
f010165d:	89 14 24             	mov    %edx,(%esp)
f0101660:	e8 77 4c 00 00       	call   f01062dc <strcat>
				break;
f0101665:	e9 ae 02 00 00       	jmp    f0101918 <disassemble+0x85d>
			case IMM8:
				//sprintf(output + strlen(output), "0x%x", *bytes++);
				snprintf(output + strlen(output),0xff, "0x%x", *bytes++);
f010166a:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f0101670:	0f b6 18             	movzbl (%eax),%ebx
f0101673:	40                   	inc    %eax
f0101674:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
f010167a:	8b 55 14             	mov    0x14(%ebp),%edx
f010167d:	89 14 24             	mov    %edx,(%esp)
f0101680:	e8 07 4c 00 00       	call   f010628c <strlen>
f0101685:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101689:	c7 44 24 08 d3 6c 10 	movl   $0xf0106cd3,0x8(%esp)
f0101690:	f0 
f0101691:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101698:	00 
f0101699:	03 45 14             	add    0x14(%ebp),%eax
f010169c:	89 04 24             	mov    %eax,(%esp)
f010169f:	e8 f5 4a 00 00       	call   f0106199 <snprintf>
				break;
f01016a4:	e9 6f 02 00 00       	jmp    f0101918 <disassemble+0x85d>
			case IMM16:
				//sprintf(output + strlen(output), "0x%x", *(short *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x", *(short *)bytes);
f01016a9:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01016af:	0f bf 18             	movswl (%eax),%ebx
f01016b2:	8b 55 14             	mov    0x14(%ebp),%edx
f01016b5:	89 14 24             	mov    %edx,(%esp)
f01016b8:	e8 cf 4b 00 00       	call   f010628c <strlen>
f01016bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01016c1:	c7 44 24 08 d3 6c 10 	movl   $0xf0106cd3,0x8(%esp)
f01016c8:	f0 
f01016c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01016d0:	00 
f01016d1:	03 45 14             	add    0x14(%ebp),%eax
f01016d4:	89 04 24             	mov    %eax,(%esp)
f01016d7:	e8 bd 4a 00 00       	call   f0106199 <snprintf>
				bytes += 2;
f01016dc:	83 85 e4 fd ff ff 02 	addl   $0x2,-0x21c(%ebp)
				break;
f01016e3:	e9 30 02 00 00       	jmp    f0101918 <disassemble+0x85d>
			case IMM32:
				//sprintf(output + strlen(output), "0x%x", *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x", *(int *)bytes);
f01016e8:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01016ee:	8b 18                	mov    (%eax),%ebx
f01016f0:	8b 55 14             	mov    0x14(%ebp),%edx
f01016f3:	89 14 24             	mov    %edx,(%esp)
f01016f6:	e8 91 4b 00 00       	call   f010628c <strlen>
f01016fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01016ff:	c7 44 24 08 d3 6c 10 	movl   $0xf0106cd3,0x8(%esp)
f0101706:	f0 
f0101707:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010170e:	00 
f010170f:	03 45 14             	add    0x14(%ebp),%eax
f0101712:	89 04 24             	mov    %eax,(%esp)
f0101715:	e8 7f 4a 00 00       	call   f0106199 <snprintf>
				bytes += 4;
f010171a:	83 85 e4 fd ff ff 04 	addl   $0x4,-0x21c(%ebp)
				break;
f0101721:	e9 f2 01 00 00       	jmp    f0101918 <disassemble+0x85d>
			case REL8:
				//sprintf(output + strlen(output), "0x%lx", offset + ((bytes - base) + 1) + *(char *)bytes);
				snprintf(output + strlen(output),0xff, "0x%lx", offset + ((bytes - base) + 1) + *(char *)bytes);
f0101726:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010172c:	2b 45 08             	sub    0x8(%ebp),%eax
f010172f:	8b 55 10             	mov    0x10(%ebp),%edx
f0101732:	8d 5c 02 01          	lea    0x1(%edx,%eax,1),%ebx
f0101736:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f010173c:	0f be 02             	movsbl (%edx),%eax
f010173f:	01 c3                	add    %eax,%ebx
f0101741:	8b 45 14             	mov    0x14(%ebp),%eax
f0101744:	89 04 24             	mov    %eax,(%esp)
f0101747:	e8 40 4b 00 00       	call   f010628c <strlen>
f010174c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101750:	c7 44 24 08 c8 6c 10 	movl   $0xf0106cc8,0x8(%esp)
f0101757:	f0 
f0101758:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010175f:	00 
f0101760:	03 45 14             	add    0x14(%ebp),%eax
f0101763:	89 04 24             	mov    %eax,(%esp)
f0101766:	e8 2e 4a 00 00       	call   f0106199 <snprintf>
                bytes++;
f010176b:	ff 85 e4 fd ff ff    	incl   -0x21c(%ebp)
				break;
f0101771:	e9 a2 01 00 00       	jmp    f0101918 <disassemble+0x85d>
			case REL32:
				//sprintf(output + strlen(output), "0x%lx", offset + ((bytes - base) + 4) + *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%lx", offset + ((bytes - base) + 4) + *(int *)bytes);
f0101776:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010177c:	2b 45 08             	sub    0x8(%ebp),%eax
f010177f:	8b 55 10             	mov    0x10(%ebp),%edx
f0101782:	8d 5c 02 04          	lea    0x4(%edx,%eax,1),%ebx
f0101786:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010178c:	03 18                	add    (%eax),%ebx
f010178e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101791:	89 14 24             	mov    %edx,(%esp)
f0101794:	e8 f3 4a 00 00       	call   f010628c <strlen>
f0101799:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010179d:	c7 44 24 08 c8 6c 10 	movl   $0xf0106cc8,0x8(%esp)
f01017a4:	f0 
f01017a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01017ac:	00 
f01017ad:	03 45 14             	add    0x14(%ebp),%eax
f01017b0:	89 04 24             	mov    %eax,(%esp)
f01017b3:	e8 e1 49 00 00       	call   f0106199 <snprintf>
				bytes += 4;
f01017b8:	83 85 e4 fd ff ff 04 	addl   $0x4,-0x21c(%ebp)
				break;
f01017bf:	e9 54 01 00 00       	jmp    f0101918 <disassemble+0x85d>
			case PTR1632:
				//sprintf(output + strlen(output), "0x%x:0x%x", *(short *)(bytes + 4), *(int *)bytes);
				snprintf(output + strlen(output),0xff, "0x%x:0x%x", *(short *)(bytes + 4), *(int *)bytes);
f01017c4:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f01017ca:	8b 00                	mov    (%eax),%eax
f01017cc:	89 85 dc fd ff ff    	mov    %eax,-0x224(%ebp)
f01017d2:	8b 95 e4 fd ff ff    	mov    -0x21c(%ebp),%edx
f01017d8:	0f bf 5a 04          	movswl 0x4(%edx),%ebx
f01017dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01017df:	89 04 24             	mov    %eax,(%esp)
f01017e2:	e8 a5 4a 00 00       	call   f010628c <strlen>
f01017e7:	8b 95 dc fd ff ff    	mov    -0x224(%ebp),%edx
f01017ed:	89 54 24 10          	mov    %edx,0x10(%esp)
f01017f1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01017f5:	c7 44 24 08 ce 6c 10 	movl   $0xf0106cce,0x8(%esp)
f01017fc:	f0 
f01017fd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101804:	00 
f0101805:	03 45 14             	add    0x14(%ebp),%eax
f0101808:	89 04 24             	mov    %eax,(%esp)
f010180b:	e8 89 49 00 00       	call   f0106199 <snprintf>
				bytes += 6;
f0101810:	83 85 e4 fd ff ff 06 	addl   $0x6,-0x21c(%ebp)
				break;
f0101817:	e9 fc 00 00 00       	jmp    f0101918 <disassemble+0x85d>
			case AL:
				strcat(output, "al");
f010181c:	c7 44 24 04 d8 6c 10 	movl   $0xf0106cd8,0x4(%esp)
f0101823:	f0 
f0101824:	8b 45 14             	mov    0x14(%ebp),%eax
f0101827:	89 04 24             	mov    %eax,(%esp)
f010182a:	e8 ad 4a 00 00       	call   f01062dc <strcat>
				break;
f010182f:	e9 e4 00 00 00       	jmp    f0101918 <disassemble+0x85d>
			case EAX:
				strcat(output, "eax");
f0101834:	c7 44 24 04 db 6c 10 	movl   $0xf0106cdb,0x4(%esp)
f010183b:	f0 
f010183c:	8b 55 14             	mov    0x14(%ebp),%edx
f010183f:	89 14 24             	mov    %edx,(%esp)
f0101842:	e8 95 4a 00 00       	call   f01062dc <strcat>
				break;
f0101847:	e9 cc 00 00 00       	jmp    f0101918 <disassemble+0x85d>
			case ES:
				strcat(output, "es");
f010184c:	c7 44 24 04 e2 84 10 	movl   $0xf01084e2,0x4(%esp)
f0101853:	f0 
f0101854:	8b 45 14             	mov    0x14(%ebp),%eax
f0101857:	89 04 24             	mov    %eax,(%esp)
f010185a:	e8 7d 4a 00 00       	call   f01062dc <strcat>
				break;
f010185f:	e9 b4 00 00 00       	jmp    f0101918 <disassemble+0x85d>
			case CS:
				strcat(output, "cs");
f0101864:	c7 44 24 04 df 6c 10 	movl   $0xf0106cdf,0x4(%esp)
f010186b:	f0 
f010186c:	8b 55 14             	mov    0x14(%ebp),%edx
f010186f:	89 14 24             	mov    %edx,(%esp)
f0101872:	e8 65 4a 00 00       	call   f01062dc <strcat>
				break;
f0101877:	e9 9c 00 00 00       	jmp    f0101918 <disassemble+0x85d>
			case SS:
				strcat(output, "ss");
f010187c:	c7 44 24 04 e2 6c 10 	movl   $0xf0106ce2,0x4(%esp)
f0101883:	f0 
f0101884:	8b 45 14             	mov    0x14(%ebp),%eax
f0101887:	89 04 24             	mov    %eax,(%esp)
f010188a:	e8 4d 4a 00 00       	call   f01062dc <strcat>
				break;
f010188f:	e9 84 00 00 00       	jmp    f0101918 <disassemble+0x85d>
			case DS:
				strcat(output, "ds");
f0101894:	c7 44 24 04 91 6d 10 	movl   $0xf0106d91,0x4(%esp)
f010189b:	f0 
f010189c:	8b 55 14             	mov    0x14(%ebp),%edx
f010189f:	89 14 24             	mov    %edx,(%esp)
f01018a2:	e8 35 4a 00 00       	call   f01062dc <strcat>
				break;
f01018a7:	eb 6f                	jmp    f0101918 <disassemble+0x85d>
			case ONE:
				strcat(output, "1");
f01018a9:	c7 44 24 04 dd 86 10 	movl   $0xf01086dd,0x4(%esp)
f01018b0:	f0 
f01018b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01018b4:	89 04 24             	mov    %eax,(%esp)
f01018b7:	e8 20 4a 00 00       	call   f01062dc <strcat>
				break;
f01018bc:	eb 5a                	jmp    f0101918 <disassemble+0x85d>
			case CL:
				strcat(output, "cl");
f01018be:	c7 44 24 04 e5 6c 10 	movl   $0xf0106ce5,0x4(%esp)
f01018c5:	f0 
f01018c6:	8b 55 14             	mov    0x14(%ebp),%edx
f01018c9:	89 14 24             	mov    %edx,(%esp)
f01018cc:	e8 0b 4a 00 00       	call   f01062dc <strcat>
				break;
f01018d1:	eb 45                	jmp    f0101918 <disassemble+0x85d>
			case XMM0:
				strcat(output, "xmm0");
f01018d3:	c7 44 24 04 e8 6c 10 	movl   $0xf0106ce8,0x4(%esp)
f01018da:	f0 
f01018db:	8b 45 14             	mov    0x14(%ebp),%eax
f01018de:	89 04 24             	mov    %eax,(%esp)
f01018e1:	e8 f6 49 00 00       	call   f01062dc <strcat>
				break;
f01018e6:	eb 30                	jmp    f0101918 <disassemble+0x85d>
			case BND0:
				strcat(output, "bnd0");
f01018e8:	c7 44 24 04 ed 6c 10 	movl   $0xf0106ced,0x4(%esp)
f01018ef:	f0 
f01018f0:	8b 55 14             	mov    0x14(%ebp),%edx
f01018f3:	89 14 24             	mov    %edx,(%esp)
f01018f6:	e8 e1 49 00 00       	call   f01062dc <strcat>
				break;
f01018fb:	eb 1b                	jmp    f0101918 <disassemble+0x85d>
			case BAD:
				bytes++;
f01018fd:	ff 85 e4 fd ff ff    	incl   -0x21c(%ebp)
				break;
f0101903:	eb 13                	jmp    f0101918 <disassemble+0x85d>
			case MM0:
				strcat(output, "mm0");
f0101905:	c7 44 24 04 e9 6c 10 	movl   $0xf0106ce9,0x4(%esp)
f010190c:	f0 
f010190d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101910:	89 04 24             	mov    %eax,(%esp)
f0101913:	e8 c4 49 00 00       	call   f01062dc <strcat>
	}

OUTPUT:
	modRM_mod = 0x0;
	strcpy(output, instructions[opcode].mnemonic);
	for (int i = 0; i < instructions[opcode].argument_count; i++) {
f0101918:	46                   	inc    %esi
f0101919:	0f be 87 01 01 00 00 	movsbl 0x101(%edi),%eax
f0101920:	39 c6                	cmp    %eax,%esi
f0101922:	0f 8c 46 fc ff ff    	jl     f010156e <disassemble+0x4b3>
				strcat(output, "mm0");
				break;
		}
	}

	if (((unsigned int)(bytes - base)) <= max) {
f0101928:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
f010192e:	2b 45 08             	sub    0x8(%ebp),%eax
f0101931:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0101934:	72 08                	jb     f010193e <disassemble+0x883>
f0101936:	eb 31                	jmp    f0101969 <disassemble+0x8ae>
		{ 1, QWORD, "paddd mm0,", 1, {RM} }, // FE
		{ 0 }, // FF - Illegal
	};

	unsigned char *base = bytes;
	unsigned char opcode = *bytes++;
f0101938:	88 85 e3 fd ff ff    	mov    %al,-0x21d(%ebp)
	if (((unsigned int)(bytes - base)) <= max) {
		return bytes - base;
	}

ILLEGAL:
	snprintf(output,0xff, ".byte 0x%02x\n", opcode);
f010193e:	0f b6 85 e3 fd ff ff 	movzbl -0x21d(%ebp),%eax
f0101945:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101949:	c7 44 24 08 f2 6c 10 	movl   $0xf0106cf2,0x8(%esp)
f0101950:	f0 
f0101951:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0101958:	00 
f0101959:	8b 55 14             	mov    0x14(%ebp),%edx
f010195c:	89 14 24             	mov    %edx,(%esp)
f010195f:	e8 35 48 00 00       	call   f0106199 <snprintf>
	return 1;
f0101964:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0101969:	81 c4 3c 02 00 00    	add    $0x23c,%esp
f010196f:	5b                   	pop    %ebx
f0101970:	5e                   	pop    %esi
f0101971:	5f                   	pop    %edi
f0101972:	5d                   	pop    %ebp
f0101973:	c3                   	ret    

f0101974 <mon_disassembler>:
        	return 0;
    }    
}

int
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
f0101974:	55                   	push   %ebp
f0101975:	89 e5                	mov    %esp,%ebp
f0101977:	57                   	push   %edi
f0101978:	56                   	push   %esi
f0101979:	53                   	push   %ebx
f010197a:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
f0101980:	8b 45 08             	mov    0x8(%ebp),%eax
f0101983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(argc>2){
f0101986:	83 f8 02             	cmp    $0x2,%eax
f0101989:	7e 11                	jle    f010199c <mon_disassembler+0x28>
		cprintf("mon_disassembler: The number of parameters is two.\n");
f010198b:	c7 04 24 44 75 10 f0 	movl   $0xf0107544,(%esp)
f0101992:	e8 3f 35 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101997:	e9 53 01 00 00       	jmp    f0101aef <mon_disassembler+0x17b>
	}
	int InstructionNumber = 1;
	if (argc == 2){
f010199c:	83 f8 02             	cmp    $0x2,%eax
f010199f:	75 3c                	jne    f01019dd <mon_disassembler+0x69>
		char *errChar;
		InstructionNumber = strtol(argv[1], &errChar, 0);
f01019a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01019a8:	00 
f01019a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019b3:	8b 40 04             	mov    0x4(%eax),%eax
f01019b6:	89 04 24             	mov    %eax,(%esp)
f01019b9:	e8 5a 4b 00 00       	call   f0106518 <strtol>
f01019be:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
		if (*errChar){
f01019c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01019c7:	80 38 00             	cmpb   $0x0,(%eax)
f01019ca:	74 1b                	je     f01019e7 <mon_disassembler+0x73>
			cprintf("mon_disassembler: The first argument is not a number.\n");
f01019cc:	c7 04 24 78 75 10 f0 	movl   $0xf0107578,(%esp)
f01019d3:	e8 fe 34 00 00       	call   f0104ed6 <cprintf>
			return 0;
f01019d8:	e9 12 01 00 00       	jmp    f0101aef <mon_disassembler+0x17b>
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
	if(argc>2){
		cprintf("mon_disassembler: The number of parameters is two.\n");
		return 0;
	}
	int InstructionNumber = 1;
f01019dd:	c7 85 c4 fd ff ff 01 	movl   $0x1,-0x23c(%ebp)
f01019e4:	00 00 00 
			cprintf("mon_disassembler: The first argument is not a number.\n");
			return 0;
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
f01019e7:	85 db                	test   %ebx,%ebx
f01019e9:	75 11                	jne    f01019fc <mon_disassembler+0x88>
f01019eb:	c7 04 24 b0 75 10 f0 	movl   $0xf01075b0,(%esp)
f01019f2:	e8 df 34 00 00       	call   f0104ed6 <cprintf>
f01019f7:	e9 f3 00 00 00       	jmp    f0101aef <mon_disassembler+0x17b>
	unsigned char* address = (unsigned char*)tf->tf_eip;
f01019fc:	8b 5b 30             	mov    0x30(%ebx),%ebx
f01019ff:	89 9d d4 fd ff ff    	mov    %ebx,-0x22c(%ebp)
	for (int i = 0;i<InstructionNumber;i++){
f0101a05:	c7 85 cc fd ff ff 00 	movl   $0x0,-0x234(%ebp)
f0101a0c:	00 00 00 
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
f0101a0f:	8d bd e5 fe ff ff    	lea    -0x11b(%ebp),%edi
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
	unsigned char* address = (unsigned char*)tf->tf_eip;
	for (int i = 0;i<InstructionNumber;i++){
f0101a15:	e9 c3 00 00 00       	jmp    f0101add <mon_disassembler+0x169>
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
f0101a1a:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
f0101a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a2b:	00 
f0101a2c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101a33:	00 
f0101a34:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101a3a:	89 04 24             	mov    %eax,(%esp)
f0101a3d:	e8 79 f6 ff ff       	call   f01010bb <disassemble>
f0101a42:	89 85 c8 fd ff ff    	mov    %eax,-0x238(%ebp)
		cprintf("%08x: ", address);
f0101a48:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a52:	c7 04 24 00 6d 10 f0 	movl   $0xf0106d00,(%esp)
f0101a59:	e8 78 34 00 00       	call   f0104ed6 <cprintf>
		instruction[0] = 0;
f0101a5e:	c6 85 e5 fe ff ff 00 	movb   $0x0,-0x11b(%ebp)
        	return 0;
    }    
}

int
mon_disassembler(int argc, char **argv, struct Trapframe *tf){
f0101a65:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
f0101a6b:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
f0101a71:	be 00 00 00 00       	mov    $0x0,%esi
f0101a76:	eb 31                	jmp    f0101aa9 <mon_disassembler+0x135>
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
f0101a78:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
f0101a7e:	0f b6 1c 30          	movzbl (%eax,%esi,1),%ebx
f0101a82:	89 3c 24             	mov    %edi,(%esp)
f0101a85:	e8 02 48 00 00       	call   f010628c <strlen>
f0101a8a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101a8e:	c7 44 24 08 07 6d 10 	movl   $0xf0106d07,0x8(%esp)
f0101a95:	f0 
f0101a96:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
f0101a9d:	00 
f0101a9e:	01 f8                	add    %edi,%eax
f0101aa0:	89 04 24             	mov    %eax,(%esp)
f0101aa3:	e8 f1 46 00 00       	call   f0106199 <snprintf>
		char disassembled[0xFF];
		char instruction[0xFF];
		uint32_t count = disassemble(address, 0x10, 0x0, disassembled);
		cprintf("%08x: ", address);
		instruction[0] = 0;
		for (int e = 0; e < count; e++) {
f0101aa8:	46                   	inc    %esi
f0101aa9:	3b b5 d0 fd ff ff    	cmp    -0x230(%ebp),%esi
f0101aaf:	75 c7                	jne    f0101a78 <mon_disassembler+0x104>
			snprintf(instruction + strlen(instruction),0xf, "%02x ", address[e]);
		}
		cprintf("%-30s %s\n", instruction, disassembled);
f0101ab1:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
f0101ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101abb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101abf:	c7 04 24 0d 6d 10 f0 	movl   $0xf0106d0d,(%esp)
f0101ac6:	e8 0b 34 00 00       	call   f0104ed6 <cprintf>
		address = (unsigned char*)((uint32_t)address + count);
f0101acb:	8b 85 c8 fd ff ff    	mov    -0x238(%ebp),%eax
f0101ad1:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)
		}
	}
	// cprintf("%d %d\n",argc,InstructionNumber);
    if (!tf){cprintf("mon_disassembler: No Trapframe!\n");return 0;}
	unsigned char* address = (unsigned char*)tf->tf_eip;
	for (int i = 0;i<InstructionNumber;i++){
f0101ad7:	ff 85 cc fd ff ff    	incl   -0x234(%ebp)
f0101add:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
f0101ae3:	39 85 c4 fd ff ff    	cmp    %eax,-0x23c(%ebp)
f0101ae9:	0f 8f 2b ff ff ff    	jg     f0101a1a <mon_disassembler+0xa6>
		}
		cprintf("%-30s %s\n", instruction, disassembled);
		address = (unsigned char*)((uint32_t)address + count);
	}
	return 0;
f0101aef:	b8 00 00 00 00       	mov    $0x0,%eax
f0101af4:	81 c4 4c 02 00 00    	add    $0x24c,%esp
f0101afa:	5b                   	pop    %ebx
f0101afb:	5e                   	pop    %esi
f0101afc:	5f                   	pop    %edi
f0101afd:	5d                   	pop    %ebp
f0101afe:	c3                   	ret    

f0101aff <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0101aff:	55                   	push   %ebp
f0101b00:	89 e5                	mov    %esp,%ebp
f0101b02:	57                   	push   %edi
f0101b03:	56                   	push   %esi
f0101b04:	53                   	push   %ebx
f0101b05:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101b08:	c7 04 24 d4 75 10 f0 	movl   $0xf01075d4,(%esp)
f0101b0f:	e8 c2 33 00 00       	call   f0104ed6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101b14:	c7 04 24 f8 75 10 f0 	movl   $0xf01075f8,(%esp)
f0101b1b:	e8 b6 33 00 00       	call   f0104ed6 <cprintf>

	if (tf != NULL)
f0101b20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101b24:	74 0b                	je     f0101b31 <monitor+0x32>
		print_trapframe(tf);
f0101b26:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b29:	89 04 24             	mov    %eax,(%esp)
f0101b2c:	e8 07 38 00 00       	call   f0105338 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0101b31:	c7 04 24 17 6d 10 f0 	movl   $0xf0106d17,(%esp)
f0101b38:	e8 87 46 00 00       	call   f01061c4 <readline>
f0101b3d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101b3f:	85 c0                	test   %eax,%eax
f0101b41:	74 ee                	je     f0101b31 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0101b43:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0101b4a:	be 00 00 00 00       	mov    $0x0,%esi
f0101b4f:	eb 04                	jmp    f0101b55 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101b51:	c6 03 00             	movb   $0x0,(%ebx)
f0101b54:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0101b55:	8a 03                	mov    (%ebx),%al
f0101b57:	84 c0                	test   %al,%al
f0101b59:	74 5e                	je     f0101bb9 <monitor+0xba>
f0101b5b:	0f be c0             	movsbl %al,%eax
f0101b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b62:	c7 04 24 1b 6d 10 f0 	movl   $0xf0106d1b,(%esp)
f0101b69:	e8 4b 48 00 00       	call   f01063b9 <strchr>
f0101b6e:	85 c0                	test   %eax,%eax
f0101b70:	75 df                	jne    f0101b51 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0101b72:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101b75:	74 42                	je     f0101bb9 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0101b77:	83 fe 0f             	cmp    $0xf,%esi
f0101b7a:	75 16                	jne    f0101b92 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101b7c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101b83:	00 
f0101b84:	c7 04 24 20 6d 10 f0 	movl   $0xf0106d20,(%esp)
f0101b8b:	e8 46 33 00 00       	call   f0104ed6 <cprintf>
f0101b90:	eb 9f                	jmp    f0101b31 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0101b92:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0101b96:	46                   	inc    %esi
f0101b97:	eb 01                	jmp    f0101b9a <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0101b99:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101b9a:	8a 03                	mov    (%ebx),%al
f0101b9c:	84 c0                	test   %al,%al
f0101b9e:	74 b5                	je     f0101b55 <monitor+0x56>
f0101ba0:	0f be c0             	movsbl %al,%eax
f0101ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ba7:	c7 04 24 1b 6d 10 f0 	movl   $0xf0106d1b,(%esp)
f0101bae:	e8 06 48 00 00       	call   f01063b9 <strchr>
f0101bb3:	85 c0                	test   %eax,%eax
f0101bb5:	74 e2                	je     f0101b99 <monitor+0x9a>
f0101bb7:	eb 9c                	jmp    f0101b55 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0101bb9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101bc0:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101bc1:	85 f6                	test   %esi,%esi
f0101bc3:	0f 84 68 ff ff ff    	je     f0101b31 <monitor+0x32>
f0101bc9:	bb a0 7b 10 f0       	mov    $0xf0107ba0,%ebx
f0101bce:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101bd3:	8b 03                	mov    (%ebx),%eax
f0101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bd9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101bdc:	89 04 24             	mov    %eax,(%esp)
f0101bdf:	e8 82 47 00 00       	call   f0106366 <strcmp>
f0101be4:	85 c0                	test   %eax,%eax
f0101be6:	75 24                	jne    f0101c0c <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0101be8:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0101beb:	8b 55 08             	mov    0x8(%ebp),%edx
f0101bee:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101bf2:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101bf5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101bf9:	89 34 24             	mov    %esi,(%esp)
f0101bfc:	ff 14 85 a8 7b 10 f0 	call   *-0xfef8458(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101c03:	85 c0                	test   %eax,%eax
f0101c05:	78 26                	js     f0101c2d <monitor+0x12e>
f0101c07:	e9 25 ff ff ff       	jmp    f0101b31 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0101c0c:	47                   	inc    %edi
f0101c0d:	83 c3 0c             	add    $0xc,%ebx
f0101c10:	83 ff 0c             	cmp    $0xc,%edi
f0101c13:	75 be                	jne    f0101bd3 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101c15:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101c18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c1c:	c7 04 24 3d 6d 10 f0 	movl   $0xf0106d3d,(%esp)
f0101c23:	e8 ae 32 00 00       	call   f0104ed6 <cprintf>
f0101c28:	e9 04 ff ff ff       	jmp    f0101b31 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101c2d:	83 c4 5c             	add    $0x5c,%esp
f0101c30:	5b                   	pop    %ebx
f0101c31:	5e                   	pop    %esi
f0101c32:	5f                   	pop    %edi
f0101c33:	5d                   	pop    %ebp
f0101c34:	c3                   	ret    

f0101c35 <Sign2Perm>:
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}

int Sign2Perm(char *s){
f0101c35:	55                   	push   %ebp
f0101c36:	89 e5                	mov    %esp,%ebp
f0101c38:	56                   	push   %esi
f0101c39:	53                   	push   %ebx
f0101c3a:	83 ec 10             	sub    $0x10,%esp
f0101c3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int l = strlen(s);
f0101c40:	89 1c 24             	mov    %ebx,(%esp)
f0101c43:	e8 44 46 00 00       	call   f010628c <strlen>
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101c48:	ba 00 00 00 00       	mov    $0x0,%edx
    return 0;
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
f0101c4d:	be 00 00 00 00       	mov    $0x0,%esi
	for (int i=0;i<l;i++){
f0101c52:	eb 47                	jmp    f0101c9b <Sign2Perm+0x66>
		switch(s[i]){
f0101c54:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0101c57:	83 e9 41             	sub    $0x41,%ecx
f0101c5a:	80 f9 16             	cmp    $0x16,%cl
f0101c5d:	77 42                	ja     f0101ca1 <Sign2Perm+0x6c>
f0101c5f:	0f b6 c9             	movzbl %cl,%ecx
f0101c62:	ff 24 8d 28 7b 10 f0 	jmp    *-0xfef84d8(,%ecx,4)
			case 'P':Perm|=PTE_P;break;
f0101c69:	83 ce 01             	or     $0x1,%esi
f0101c6c:	eb 2c                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'W':Perm|=PTE_W;break;
f0101c6e:	83 ce 02             	or     $0x2,%esi
f0101c71:	eb 27                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'U':Perm|=PTE_U;break;
f0101c73:	83 ce 04             	or     $0x4,%esi
f0101c76:	eb 22                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'T':Perm|=PTE_PWT;break;
f0101c78:	83 ce 08             	or     $0x8,%esi
f0101c7b:	eb 1d                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'C':Perm|=PTE_PCD;break;
f0101c7d:	83 ce 10             	or     $0x10,%esi
f0101c80:	eb 18                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'A':Perm|=PTE_A;break;
f0101c82:	83 ce 20             	or     $0x20,%esi
f0101c85:	eb 13                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'D':Perm|=PTE_D;break;
f0101c87:	83 ce 40             	or     $0x40,%esi
f0101c8a:	eb 0e                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'I':Perm|=PTE_PS;break;
f0101c8c:	81 ce 80 00 00 00    	or     $0x80,%esi
f0101c92:	eb 06                	jmp    f0101c9a <Sign2Perm+0x65>
			case 'G':Perm|=PTE_G;break;
f0101c94:	81 ce 00 01 00 00    	or     $0x100,%esi
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101c9a:	42                   	inc    %edx
f0101c9b:	39 c2                	cmp    %eax,%edx
f0101c9d:	7c b5                	jl     f0101c54 <Sign2Perm+0x1f>
f0101c9f:	eb 05                	jmp    f0101ca6 <Sign2Perm+0x71>
			case 'C':Perm|=PTE_PCD;break;
			case 'A':Perm|=PTE_A;break;
			case 'D':Perm|=PTE_D;break;
			case 'I':Perm|=PTE_PS;break;
			case 'G':Perm|=PTE_G;break;
			default:return -1;
f0101ca1:	be ff ff ff ff       	mov    $0xffffffff,%esi
		}
	}
	return Perm;
}
f0101ca6:	89 f0                	mov    %esi,%eax
f0101ca8:	83 c4 10             	add    $0x10,%esp
f0101cab:	5b                   	pop    %ebx
f0101cac:	5e                   	pop    %esi
f0101cad:	5d                   	pop    %ebp
f0101cae:	c3                   	ret    

f0101caf <mon_clearpermissions>:
    cprintf("Permission has been updated:\n");
    mon_showmappings(argc-1,argv,tf);
    return 0;
}

int mon_clearpermissions(int argc, char **argv, struct Trapframe *tf){
f0101caf:	55                   	push   %ebp
f0101cb0:	89 e5                	mov    %esp,%ebp
f0101cb2:	57                   	push   %edi
f0101cb3:	56                   	push   %esi
f0101cb4:	53                   	push   %ebx
f0101cb5:	83 ec 2c             	sub    $0x2c,%esp
f0101cb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc!=4){
f0101cbb:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0101cbf:	74 11                	je     f0101cd2 <mon_clearpermissions+0x23>
		cprintf("mon_clearpermissions: The number of parameters is three.\n");
f0101cc1:	c7 04 24 20 76 10 f0 	movl   $0xf0107620,(%esp)
f0101cc8:	e8 09 32 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101ccd:	e9 65 01 00 00       	jmp    f0101e37 <mon_clearpermissions+0x188>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0101cd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cd9:	00 
f0101cda:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ce1:	8b 43 04             	mov    0x4(%ebx),%eax
f0101ce4:	89 04 24             	mov    %eax,(%esp)
f0101ce7:	e8 2c 48 00 00       	call   f0106518 <strtol>
f0101cec:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0101cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101cf1:	80 38 00             	cmpb   $0x0,(%eax)
f0101cf4:	74 11                	je     f0101d07 <mon_clearpermissions+0x58>
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
f0101cf6:	c7 04 24 5c 76 10 f0 	movl   $0xf010765c,(%esp)
f0101cfd:	e8 d4 31 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101d02:	e9 30 01 00 00       	jmp    f0101e37 <mon_clearpermissions+0x188>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101d07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d0e:	00 
f0101d0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d16:	8b 43 08             	mov    0x8(%ebx),%eax
f0101d19:	89 04 24             	mov    %eax,(%esp)
f0101d1c:	e8 f7 47 00 00       	call   f0106518 <strtol>
	if (*errChar){
f0101d21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101d24:	80 3a 00             	cmpb   $0x0,(%edx)
f0101d27:	74 11                	je     f0101d3a <mon_clearpermissions+0x8b>
		cprintf("mon_clearpermissions: The second argument is not a number.\n");
f0101d29:	c7 04 24 98 76 10 f0 	movl   $0xf0107698,(%esp)
f0101d30:	e8 a1 31 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101d35:	e9 fd 00 00 00       	jmp    f0101e37 <mon_clearpermissions+0x188>
	}
	if (StartAddr&0x3ff){
f0101d3a:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0101d40:	74 11                	je     f0101d53 <mon_clearpermissions+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f0101d42:	c7 04 24 e8 6f 10 f0 	movl   $0xf0106fe8,(%esp)
f0101d49:	e8 88 31 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101d4e:	e9 e4 00 00 00       	jmp    f0101e37 <mon_clearpermissions+0x188>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101d53:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0101d55:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0101d5a:	74 11                	je     f0101d6d <mon_clearpermissions+0xbe>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0101d5c:	c7 04 24 24 70 10 f0 	movl   $0xf0107024,(%esp)
f0101d63:	e8 6e 31 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101d68:	e9 ca 00 00 00       	jmp    f0101e37 <mon_clearpermissions+0x188>
	}
	if (StartAddr > EndAddr){
f0101d6d:	39 c6                	cmp    %eax,%esi
f0101d6f:	76 11                	jbe    f0101d82 <mon_clearpermissions+0xd3>
		cprintf("mon_clearpermissions: The first parameter is larger than the second parameter.\n");
f0101d71:	c7 04 24 d4 76 10 f0 	movl   $0xf01076d4,(%esp)
f0101d78:	e8 59 31 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101d7d:	e9 b5 00 00 00       	jmp    f0101e37 <mon_clearpermissions+0x188>
	}
	int Perm = Sign2Perm(argv[3]);
f0101d82:	8b 43 0c             	mov    0xc(%ebx),%eax
f0101d85:	89 04 24             	mov    %eax,(%esp)
f0101d88:	e8 a8 fe ff ff       	call   f0101c35 <Sign2Perm>
	if (Perm == -1){
f0101d8d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d90:	75 7c                	jne    f0101e0e <mon_clearpermissions+0x15f>
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
f0101d92:	c7 04 24 24 77 10 f0 	movl   $0xf0107724,(%esp)
f0101d99:	e8 38 31 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101d9e:	e9 94 00 00 00       	jmp    f0101e37 <mon_clearpermissions+0x188>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0101da3:	89 f1                	mov    %esi,%ecx
f0101da5:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f0101da8:	8b 15 ac bc 20 f0    	mov    0xf020bcac,%edx
f0101dae:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0101db1:	f6 c2 01             	test   $0x1,%dl
f0101db4:	74 50                	je     f0101e06 <mon_clearpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0101db6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101dbc:	89 d1                	mov    %edx,%ecx
f0101dbe:	c1 e9 0c             	shr    $0xc,%ecx
f0101dc1:	3b 0d a8 bc 20 f0    	cmp    0xf020bca8,%ecx
f0101dc7:	72 20                	jb     f0101de9 <mon_clearpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dc9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101dcd:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0101dd4:	f0 
f0101dd5:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f0101ddc:	00 
f0101ddd:	c7 04 24 27 6c 10 f0 	movl   $0xf0106c27,(%esp)
f0101de4:	e8 c8 e2 ff ff       	call   f01000b1 <_panic>
f0101de9:	89 f1                	mov    %esi,%ecx
f0101deb:	c1 e9 0a             	shr    $0xa,%ecx
f0101dee:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f0101df4:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f0101dfb:	8b 0a                	mov    (%edx),%ecx
f0101dfd:	f6 c1 01             	test   $0x1,%cl
f0101e00:	74 04                	je     f0101e06 <mon_clearpermissions+0x157>
				*pte = *pte & ~Perm;
f0101e02:	21 c1                	and    %eax,%ecx
f0101e04:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101e06:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101e0c:	eb 02                	jmp    f0101e10 <mon_clearpermissions+0x161>
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				*pte = *pte & ~Perm;
f0101e0e:	f7 d0                	not    %eax
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101e10:	39 fe                	cmp    %edi,%esi
f0101e12:	72 8f                	jb     f0101da3 <mon_clearpermissions+0xf4>
				*pte = *pte & ~Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f0101e14:	c7 04 24 53 6d 10 f0 	movl   $0xf0106d53,(%esp)
f0101e1b:	e8 b6 30 00 00       	call   f0104ed6 <cprintf>
    mon_showmappings(argc-1,argv,tf);
f0101e20:	8b 45 10             	mov    0x10(%ebp),%eax
f0101e23:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e2b:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f0101e32:	e8 b7 f0 ff ff       	call   f0100eee <mon_showmappings>

    return 0;
}
f0101e37:	b8 00 00 00 00       	mov    $0x0,%eax
f0101e3c:	83 c4 2c             	add    $0x2c,%esp
f0101e3f:	5b                   	pop    %ebx
f0101e40:	5e                   	pop    %esi
f0101e41:	5f                   	pop    %edi
f0101e42:	5d                   	pop    %ebp
f0101e43:	c3                   	ret    

f0101e44 <mon_setpermissions>:
			default:return -1;
		}
	}
	return Perm;
}
int mon_setpermissions(int argc, char **argv, struct Trapframe *tf){
f0101e44:	55                   	push   %ebp
f0101e45:	89 e5                	mov    %esp,%ebp
f0101e47:	57                   	push   %edi
f0101e48:	56                   	push   %esi
f0101e49:	53                   	push   %ebx
f0101e4a:	83 ec 2c             	sub    $0x2c,%esp
f0101e4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=4){
f0101e50:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0101e54:	74 11                	je     f0101e67 <mon_setpermissions+0x23>
		cprintf("mon_setpermissions: The number of parameters is three.\n");
f0101e56:	c7 04 24 64 77 10 f0 	movl   $0xf0107764,(%esp)
f0101e5d:	e8 74 30 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101e62:	e9 61 01 00 00       	jmp    f0101fc8 <mon_setpermissions+0x184>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0101e67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e6e:	00 
f0101e6f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e76:	8b 43 04             	mov    0x4(%ebx),%eax
f0101e79:	89 04 24             	mov    %eax,(%esp)
f0101e7c:	e8 97 46 00 00       	call   f0106518 <strtol>
f0101e81:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0101e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101e86:	80 38 00             	cmpb   $0x0,(%eax)
f0101e89:	74 11                	je     f0101e9c <mon_setpermissions+0x58>
		cprintf("mon_setpermissions: The first argument is not a number.\n");
f0101e8b:	c7 04 24 9c 77 10 f0 	movl   $0xf010779c,(%esp)
f0101e92:	e8 3f 30 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101e97:	e9 2c 01 00 00       	jmp    f0101fc8 <mon_setpermissions+0x184>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101e9c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ea3:	00 
f0101ea4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101eab:	8b 43 08             	mov    0x8(%ebx),%eax
f0101eae:	89 04 24             	mov    %eax,(%esp)
f0101eb1:	e8 62 46 00 00       	call   f0106518 <strtol>
	if (*errChar){
f0101eb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101eb9:	80 3a 00             	cmpb   $0x0,(%edx)
f0101ebc:	74 11                	je     f0101ecf <mon_setpermissions+0x8b>
		cprintf("mon_setpermissions: The second argument is not a number\n");
f0101ebe:	c7 04 24 d8 77 10 f0 	movl   $0xf01077d8,(%esp)
f0101ec5:	e8 0c 30 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101eca:	e9 f9 00 00 00       	jmp    f0101fc8 <mon_setpermissions+0x184>
	}
	if (StartAddr&0x3ff){
f0101ecf:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0101ed5:	74 11                	je     f0101ee8 <mon_setpermissions+0xa4>
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
f0101ed7:	c7 04 24 14 78 10 f0 	movl   $0xf0107814,(%esp)
f0101ede:	e8 f3 2f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101ee3:	e9 e0 00 00 00       	jmp    f0101fc8 <mon_setpermissions+0x184>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_setpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101ee8:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0101eea:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0101eef:	74 11                	je     f0101f02 <mon_setpermissions+0xbe>
		cprintf("mon_setpermissions: The second parameter is not aligned.\n");
f0101ef1:	c7 04 24 50 78 10 f0 	movl   $0xf0107850,(%esp)
f0101ef8:	e8 d9 2f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101efd:	e9 c6 00 00 00       	jmp    f0101fc8 <mon_setpermissions+0x184>
	}
	if (StartAddr > EndAddr){
f0101f02:	39 c6                	cmp    %eax,%esi
f0101f04:	76 11                	jbe    f0101f17 <mon_setpermissions+0xd3>
		cprintf("mon_setpermissions: The first parameter is larger than the second parameter.\n");
f0101f06:	c7 04 24 8c 78 10 f0 	movl   $0xf010788c,(%esp)
f0101f0d:	e8 c4 2f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101f12:	e9 b1 00 00 00       	jmp    f0101fc8 <mon_setpermissions+0x184>
	}
	int Perm = Sign2Perm(argv[3]);
f0101f17:	8b 43 0c             	mov    0xc(%ebx),%eax
f0101f1a:	89 04 24             	mov    %eax,(%esp)
f0101f1d:	e8 13 fd ff ff       	call   f0101c35 <Sign2Perm>
	if (Perm == -1){
f0101f22:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f25:	75 7a                	jne    f0101fa1 <mon_setpermissions+0x15d>
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
f0101f27:	c7 04 24 dc 78 10 f0 	movl   $0xf01078dc,(%esp)
f0101f2e:	e8 a3 2f 00 00       	call   f0104ed6 <cprintf>
		return 0;
f0101f33:	e9 90 00 00 00       	jmp    f0101fc8 <mon_setpermissions+0x184>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0101f38:	89 f1                	mov    %esi,%ecx
f0101f3a:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f0101f3d:	8b 15 ac bc 20 f0    	mov    0xf020bcac,%edx
f0101f43:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0101f46:	f6 c2 01             	test   $0x1,%dl
f0101f49:	74 50                	je     f0101f9b <mon_setpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0101f4b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f51:	89 d1                	mov    %edx,%ecx
f0101f53:	c1 e9 0c             	shr    $0xc,%ecx
f0101f56:	3b 0d a8 bc 20 f0    	cmp    0xf020bca8,%ecx
f0101f5c:	72 20                	jb     f0101f7e <mon_setpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f5e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101f62:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0101f69:	f0 
f0101f6a:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0101f71:	00 
f0101f72:	c7 04 24 27 6c 10 f0 	movl   $0xf0106c27,(%esp)
f0101f79:	e8 33 e1 ff ff       	call   f01000b1 <_panic>
f0101f7e:	89 f1                	mov    %esi,%ecx
f0101f80:	c1 e9 0a             	shr    $0xa,%ecx
f0101f83:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f0101f89:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f0101f90:	8b 0a                	mov    (%edx),%ecx
f0101f92:	f6 c1 01             	test   $0x1,%cl
f0101f95:	74 04                	je     f0101f9b <mon_setpermissions+0x157>
				*pte = *pte | Perm;
f0101f97:	09 c1                	or     %eax,%ecx
f0101f99:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101f9b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101fa1:	39 fe                	cmp    %edi,%esi
f0101fa3:	72 93                	jb     f0101f38 <mon_setpermissions+0xf4>
				*pte = *pte | Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f0101fa5:	c7 04 24 53 6d 10 f0 	movl   $0xf0106d53,(%esp)
f0101fac:	e8 25 2f 00 00       	call   f0104ed6 <cprintf>
    mon_showmappings(argc-1,argv,tf);
f0101fb1:	8b 45 10             	mov    0x10(%ebp),%eax
f0101fb4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fb8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fbc:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f0101fc3:	e8 26 ef ff ff       	call   f0100eee <mon_showmappings>
    return 0;
}
f0101fc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0101fcd:	83 c4 2c             	add    $0x2c,%esp
f0101fd0:	5b                   	pop    %ebx
f0101fd1:	5e                   	pop    %esi
f0101fd2:	5f                   	pop    %edi
f0101fd3:	5d                   	pop    %ebp
f0101fd4:	c3                   	ret    
f0101fd5:	00 00                	add    %al,(%eax)
	...

f0101fd8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101fd8:	55                   	push   %ebp
f0101fd9:	89 e5                	mov    %esp,%ebp
f0101fdb:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101fde:	89 d1                	mov    %edx,%ecx
f0101fe0:	c1 e9 16             	shr    $0x16,%ecx
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
f0101fe3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101fe6:	a8 01                	test   $0x1,%al
f0101fe8:	74 4d                	je     f0102037 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101fea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fef:	89 c1                	mov    %eax,%ecx
f0101ff1:	c1 e9 0c             	shr    $0xc,%ecx
f0101ff4:	3b 0d a8 bc 20 f0    	cmp    0xf020bca8,%ecx
f0101ffa:	72 20                	jb     f010201c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ffc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102000:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0102007:	f0 
f0102008:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f010200f:	00 
f0102010:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102017:	e8 95 e0 ff ff       	call   f01000b1 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f010201c:	c1 ea 0c             	shr    $0xc,%edx
f010201f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102025:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010202c:	a8 01                	test   $0x1,%al
f010202e:	74 0e                	je     f010203e <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0102030:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102035:	eb 0c                	jmp    f0102043 <check_va2pa+0x6b>
	pgdir = &pgdir[PDX(va)];
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
		return ~0;
f0102037:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010203c:	eb 05                	jmp    f0102043 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f010203e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0102043:	c9                   	leave  
f0102044:	c3                   	ret    

f0102045 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0102045:	55                   	push   %ebp
f0102046:	89 e5                	mov    %esp,%ebp
f0102048:	83 ec 18             	sub    $0x18,%esp
f010204b:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010204d:	83 3d 04 b0 20 f0 00 	cmpl   $0x0,0xf020b004
f0102054:	75 0f                	jne    f0102065 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0102056:	b8 9f cc 20 f0       	mov    $0xf020cc9f,%eax
f010205b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102060:	a3 04 b0 20 f0       	mov    %eax,0xf020b004
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n>0){
f0102065:	85 d2                	test   %edx,%edx
f0102067:	74 6d                	je     f01020d6 <boot_alloc+0x91>
		result = nextfree;
f0102069:	a1 04 b0 20 f0       	mov    0xf020b004,%eax
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010206e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0102075:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010207b:	89 15 04 b0 20 f0    	mov    %edx,0xf020b004
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102081:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102087:	77 20                	ja     f01020a9 <boot_alloc+0x64>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102089:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010208d:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0102094:	f0 
f0102095:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f010209c:	00 
f010209d:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01020a4:	e8 08 e0 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01020a9:	81 c2 00 00 00 10    	add    $0x10000000,%edx
		if (PGNUM(PADDR(nextfree))>=npages)
f01020af:	c1 ea 0c             	shr    $0xc,%edx
f01020b2:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f01020b8:	72 21                	jb     f01020db <boot_alloc+0x96>
			panic("boot_alloc: out of memory");
f01020ba:	c7 44 24 08 b1 84 10 	movl   $0xf01084b1,0x8(%esp)
f01020c1:	f0 
f01020c2:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f01020c9:	00 
f01020ca:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01020d1:	e8 db df ff ff       	call   f01000b1 <_panic>
	}
	else{
		result = nextfree;
f01020d6:	a1 04 b0 20 f0       	mov    0xf020b004,%eax
	}
	// cprintf("boot_alloc %x %d\n",result,n);
	return result;
	// return NULL;
}
f01020db:	c9                   	leave  
f01020dc:	c3                   	ret    

f01020dd <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01020dd:	55                   	push   %ebp
f01020de:	89 e5                	mov    %esp,%ebp
f01020e0:	56                   	push   %esi
f01020e1:	53                   	push   %ebx
f01020e2:	83 ec 10             	sub    $0x10,%esp
f01020e5:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01020e7:	89 04 24             	mov    %eax,(%esp)
f01020ea:	e8 79 2d 00 00       	call   f0104e68 <mc146818_read>
f01020ef:	89 c6                	mov    %eax,%esi
f01020f1:	43                   	inc    %ebx
f01020f2:	89 1c 24             	mov    %ebx,(%esp)
f01020f5:	e8 6e 2d 00 00       	call   f0104e68 <mc146818_read>
f01020fa:	c1 e0 08             	shl    $0x8,%eax
f01020fd:	09 f0                	or     %esi,%eax
}
f01020ff:	83 c4 10             	add    $0x10,%esp
f0102102:	5b                   	pop    %ebx
f0102103:	5e                   	pop    %esi
f0102104:	5d                   	pop    %ebp
f0102105:	c3                   	ret    

f0102106 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0102106:	55                   	push   %ebp
f0102107:	89 e5                	mov    %esp,%ebp
f0102109:	57                   	push   %edi
f010210a:	56                   	push   %esi
f010210b:	53                   	push   %ebx
f010210c:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010210f:	3c 01                	cmp    $0x1,%al
f0102111:	19 f6                	sbb    %esi,%esi
f0102113:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0102119:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010211a:	8b 15 08 b0 20 f0    	mov    0xf020b008,%edx
f0102120:	85 d2                	test   %edx,%edx
f0102122:	75 1c                	jne    f0102140 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0102124:	c7 44 24 08 54 7c 10 	movl   $0xf0107c54,0x8(%esp)
f010212b:	f0 
f010212c:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
f0102133:	00 
f0102134:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010213b:	e8 71 df ff ff       	call   f01000b1 <_panic>

	if (only_low_memory) {
f0102140:	84 c0                	test   %al,%al
f0102142:	74 4b                	je     f010218f <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0102144:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0102147:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010214a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010214d:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102150:	89 d0                	mov    %edx,%eax
f0102152:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f0102158:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010215b:	c1 e8 16             	shr    $0x16,%eax
f010215e:	39 c6                	cmp    %eax,%esi
f0102160:	0f 96 c0             	setbe  %al
f0102163:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0102166:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f010216a:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010216c:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102170:	8b 12                	mov    (%edx),%edx
f0102172:	85 d2                	test   %edx,%edx
f0102174:	75 da                	jne    f0102150 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0102176:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102179:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010217f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102182:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102185:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0102187:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010218a:	a3 08 b0 20 f0       	mov    %eax,0xf020b008
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f010218f:	8b 1d 08 b0 20 f0    	mov    0xf020b008,%ebx
f0102195:	eb 63                	jmp    f01021fa <check_page_free_list+0xf4>
f0102197:	89 d8                	mov    %ebx,%eax
f0102199:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f010219f:	c1 f8 03             	sar    $0x3,%eax
f01021a2:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01021a5:	89 c2                	mov    %eax,%edx
f01021a7:	c1 ea 16             	shr    $0x16,%edx
f01021aa:	39 d6                	cmp    %edx,%esi
f01021ac:	76 4a                	jbe    f01021f8 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021ae:	89 c2                	mov    %eax,%edx
f01021b0:	c1 ea 0c             	shr    $0xc,%edx
f01021b3:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f01021b9:	72 20                	jb     f01021db <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01021bf:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f01021c6:	f0 
f01021c7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01021ce:	00 
f01021cf:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f01021d6:	e8 d6 de ff ff       	call   f01000b1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01021db:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01021e2:	00 
f01021e3:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01021ea:	00 
	return (void *)(pa + KERNBASE);
f01021eb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021f0:	89 04 24             	mov    %eax,(%esp)
f01021f3:	e8 f6 41 00 00       	call   f01063ee <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01021f8:	8b 1b                	mov    (%ebx),%ebx
f01021fa:	85 db                	test   %ebx,%ebx
f01021fc:	75 99                	jne    f0102197 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f01021fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0102203:	e8 3d fe ff ff       	call   f0102045 <boot_alloc>
f0102208:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010220b:	8b 15 08 b0 20 f0    	mov    0xf020b008,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0102211:	8b 0d b0 bc 20 f0    	mov    0xf020bcb0,%ecx
		assert(pp < pages + npages);
f0102217:	a1 a8 bc 20 f0       	mov    0xf020bca8,%eax
f010221c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010221f:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0102222:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0102225:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0102228:	be 00 00 00 00       	mov    $0x0,%esi
f010222d:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102230:	e9 91 01 00 00       	jmp    f01023c6 <check_page_free_list+0x2c0>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0102235:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0102238:	73 24                	jae    f010225e <check_page_free_list+0x158>
f010223a:	c7 44 24 0c d9 84 10 	movl   $0xf01084d9,0xc(%esp)
f0102241:	f0 
f0102242:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102249:	f0 
f010224a:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f0102251:	00 
f0102252:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102259:	e8 53 de ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f010225e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0102261:	72 24                	jb     f0102287 <check_page_free_list+0x181>
f0102263:	c7 44 24 0c fa 84 10 	movl   $0xf01084fa,0xc(%esp)
f010226a:	f0 
f010226b:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102272:	f0 
f0102273:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f010227a:	00 
f010227b:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102282:	e8 2a de ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0102287:	89 d0                	mov    %edx,%eax
f0102289:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010228c:	a8 07                	test   $0x7,%al
f010228e:	74 24                	je     f01022b4 <check_page_free_list+0x1ae>
f0102290:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f0102297:	f0 
f0102298:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010229f:	f0 
f01022a0:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f01022a7:	00 
f01022a8:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01022af:	e8 fd dd ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022b4:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01022b7:	c1 e0 0c             	shl    $0xc,%eax
f01022ba:	75 24                	jne    f01022e0 <check_page_free_list+0x1da>
f01022bc:	c7 44 24 0c 0e 85 10 	movl   $0xf010850e,0xc(%esp)
f01022c3:	f0 
f01022c4:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01022cb:	f0 
f01022cc:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f01022d3:	00 
f01022d4:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01022db:	e8 d1 dd ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01022e0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01022e5:	75 24                	jne    f010230b <check_page_free_list+0x205>
f01022e7:	c7 44 24 0c 1f 85 10 	movl   $0xf010851f,0xc(%esp)
f01022ee:	f0 
f01022ef:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01022f6:	f0 
f01022f7:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f01022fe:	00 
f01022ff:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102306:	e8 a6 dd ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010230b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0102310:	75 24                	jne    f0102336 <check_page_free_list+0x230>
f0102312:	c7 44 24 0c ac 7c 10 	movl   $0xf0107cac,0xc(%esp)
f0102319:	f0 
f010231a:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102321:	f0 
f0102322:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0102329:	00 
f010232a:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102331:	e8 7b dd ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0102336:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010233b:	75 24                	jne    f0102361 <check_page_free_list+0x25b>
f010233d:	c7 44 24 0c 38 85 10 	movl   $0xf0108538,0xc(%esp)
f0102344:	f0 
f0102345:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010234c:	f0 
f010234d:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
f0102354:	00 
f0102355:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010235c:	e8 50 dd ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0102361:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0102366:	76 58                	jbe    f01023c0 <check_page_free_list+0x2ba>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102368:	89 c1                	mov    %eax,%ecx
f010236a:	c1 e9 0c             	shr    $0xc,%ecx
f010236d:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102370:	77 20                	ja     f0102392 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102372:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102376:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f010237d:	f0 
f010237e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102385:	00 
f0102386:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f010238d:	e8 1f dd ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0102392:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102397:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f010239a:	76 27                	jbe    f01023c3 <check_page_free_list+0x2bd>
f010239c:	c7 44 24 0c d0 7c 10 	movl   $0xf0107cd0,0xc(%esp)
f01023a3:	f0 
f01023a4:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01023ab:	f0 
f01023ac:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
f01023b3:	00 
f01023b4:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01023bb:	e8 f1 dc ff ff       	call   f01000b1 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01023c0:	46                   	inc    %esi
f01023c1:	eb 01                	jmp    f01023c4 <check_page_free_list+0x2be>
		else
			++nfree_extmem;
f01023c3:	43                   	inc    %ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01023c4:	8b 12                	mov    (%edx),%edx
f01023c6:	85 d2                	test   %edx,%edx
f01023c8:	0f 85 67 fe ff ff    	jne    f0102235 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01023ce:	85 f6                	test   %esi,%esi
f01023d0:	7f 24                	jg     f01023f6 <check_page_free_list+0x2f0>
f01023d2:	c7 44 24 0c 52 85 10 	movl   $0xf0108552,0xc(%esp)
f01023d9:	f0 
f01023da:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01023e1:	f0 
f01023e2:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f01023e9:	00 
f01023ea:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01023f1:	e8 bb dc ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f01023f6:	85 db                	test   %ebx,%ebx
f01023f8:	7f 24                	jg     f010241e <check_page_free_list+0x318>
f01023fa:	c7 44 24 0c 64 85 10 	movl   $0xf0108564,0xc(%esp)
f0102401:	f0 
f0102402:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102409:	f0 
f010240a:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0102411:	00 
f0102412:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102419:	e8 93 dc ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f010241e:	c7 04 24 18 7d 10 f0 	movl   $0xf0107d18,(%esp)
f0102425:	e8 ac 2a 00 00       	call   f0104ed6 <cprintf>
}
f010242a:	83 c4 4c             	add    $0x4c,%esp
f010242d:	5b                   	pop    %ebx
f010242e:	5e                   	pop    %esi
f010242f:	5f                   	pop    %edi
f0102430:	5d                   	pop    %ebp
f0102431:	c3                   	ret    

f0102432 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0102432:	55                   	push   %ebp
f0102433:	89 e5                	mov    %esp,%ebp
f0102435:	53                   	push   %ebx
f0102436:	83 ec 14             	sub    $0x14,%esp
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	size_t i;
	pages[0].pp_ref = 1;
f0102439:	a1 b0 bc 20 f0       	mov    0xf020bcb0,%eax
f010243e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0102444:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	size_t IOPAGE =  PGNUM(IOPHYSMEM);
	size_t EXTPAGE = PGNUM(EXTPHYSMEM);
	size_t FREEPAGE = PGNUM(PADDR(boot_alloc(0)));
f010244a:	b8 00 00 00 00       	mov    $0x0,%eax
f010244f:	e8 f1 fb ff ff       	call   f0102045 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102454:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102459:	77 20                	ja     f010247b <page_init+0x49>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010245b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010245f:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0102466:	f0 
f0102467:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f010246e:	00 
f010246f:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102476:	e8 36 dc ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010247b:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0102481:	c1 eb 0c             	shr    $0xc,%ebx
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
f0102484:	83 3d 08 b0 20 f0 00 	cmpl   $0x0,0xf020b008
f010248b:	74 24                	je     f01024b1 <page_init+0x7f>
f010248d:	c7 44 24 0c 75 85 10 	movl   $0xf0108575,0xc(%esp)
f0102494:	f0 
f0102495:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010249c:	f0 
f010249d:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
f01024a4:	00 
f01024a5:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01024ac:	e8 00 dc ff ff       	call   f01000b1 <_panic>
 	assert(npages_basemem == IOPAGE);
f01024b1:	81 3d 00 b0 20 f0 a0 	cmpl   $0xa0,0xf020b000
f01024b8:	00 00 00 
f01024bb:	74 24                	je     f01024e1 <page_init+0xaf>
f01024bd:	c7 44 24 0c 8c 85 10 	movl   $0xf010858c,0xc(%esp)
f01024c4:	f0 
f01024c5:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01024cc:	f0 
f01024cd:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f01024d4:	00 
f01024d5:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01024dc:	e8 d0 db ff ff       	call   f01000b1 <_panic>
f01024e1:	b8 08 00 00 00       	mov    $0x8,%eax
f01024e6:	b9 00 00 00 00       	mov    $0x0,%ecx
    for (i = 1; i < IOPAGE; i++) {
        pages[i].pp_ref = 0;
f01024eb:	89 c2                	mov    %eax,%edx
f01024ed:	03 15 b0 bc 20 f0    	add    0xf020bcb0,%edx
f01024f3:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f01024f9:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f01024fb:	89 c1                	mov    %eax,%ecx
f01024fd:	03 0d b0 bc 20 f0    	add    0xf020bcb0,%ecx
f0102503:	83 c0 08             	add    $0x8,%eax
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
 	assert(npages_basemem == IOPAGE);
    for (i = 1; i < IOPAGE; i++) {
f0102506:	3d 00 05 00 00       	cmp    $0x500,%eax
f010250b:	75 de                	jne    f01024eb <page_init+0xb9>
f010250d:	89 0d 08 b0 20 f0    	mov    %ecx,0xf020b008
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
f0102513:	89 c2                	mov    %eax,%edx
f0102515:	03 15 b0 bc 20 f0    	add    0xf020bcb0,%edx
f010251b:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f0102521:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0102527:	83 c0 08             	add    $0x8,%eax
    for (i = 1; i < IOPAGE; i++) {
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
f010252a:	3d 00 08 00 00       	cmp    $0x800,%eax
f010252f:	75 e2                	jne    f0102513 <page_init+0xe1>
f0102531:	66 b8 00 01          	mov    $0x100,%ax
f0102535:	eb 1a                	jmp    f0102551 <page_init+0x11f>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
f0102537:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010253e:	03 15 b0 bc 20 f0    	add    0xf020bcb0,%edx
f0102544:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f010254a:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
f0102550:	40                   	inc    %eax
f0102551:	39 d8                	cmp    %ebx,%eax
f0102553:	72 e2                	jb     f0102537 <page_init+0x105>
f0102555:	8b 0d 08 b0 20 f0    	mov    0xf020b008,%ecx
f010255b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0102562:	eb 1c                	jmp    f0102580 <page_init+0x14e>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
        pages[i].pp_ref = 0;
f0102564:	89 c2                	mov    %eax,%edx
f0102566:	03 15 b0 bc 20 f0    	add    0xf020bcb0,%edx
f010256c:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0102572:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f0102574:	89 c1                	mov    %eax,%ecx
f0102576:	03 0d b0 bc 20 f0    	add    0xf020bcb0,%ecx
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
f010257c:	43                   	inc    %ebx
f010257d:	83 c0 08             	add    $0x8,%eax
f0102580:	3b 1d a8 bc 20 f0    	cmp    0xf020bca8,%ebx
f0102586:	72 dc                	jb     f0102564 <page_init+0x132>
f0102588:	89 0d 08 b0 20 f0    	mov    %ecx,0xf020b008
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	return;
}
f010258e:	83 c4 14             	add    $0x14,%esp
f0102591:	5b                   	pop    %ebx
f0102592:	5d                   	pop    %ebp
f0102593:	c3                   	ret    

f0102594 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0102594:	55                   	push   %ebp
f0102595:	89 e5                	mov    %esp,%ebp
f0102597:	53                   	push   %ebx
f0102598:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	// assert(page_free_list != NULL);
	// cprintf("page_alloc %x\n",page_free_list);
	// cprintf("page_alloc %x\n",page_free_list);
	if (page_free_list == NULL)return NULL;
f010259b:	8b 1d 08 b0 20 f0    	mov    0xf020b008,%ebx
f01025a1:	85 db                	test   %ebx,%ebx
f01025a3:	74 6b                	je     f0102610 <page_alloc+0x7c>
	struct PageInfo *alloc_page = page_free_list;
	page_free_list = alloc_page->pp_link;
f01025a5:	8b 03                	mov    (%ebx),%eax
f01025a7:	a3 08 b0 20 f0       	mov    %eax,0xf020b008
	alloc_page->pp_link = NULL;
f01025ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO){
f01025b2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01025b6:	74 58                	je     f0102610 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025b8:	89 d8                	mov    %ebx,%eax
f01025ba:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f01025c0:	c1 f8 03             	sar    $0x3,%eax
f01025c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025c6:	89 c2                	mov    %eax,%edx
f01025c8:	c1 ea 0c             	shr    $0xc,%edx
f01025cb:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f01025d1:	72 20                	jb     f01025f3 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025d7:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f01025de:	f0 
f01025df:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01025e6:	00 
f01025e7:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f01025ee:	e8 be da ff ff       	call   f01000b1 <_panic>
		memset(page2kva(alloc_page),'\0',PGSIZE);
f01025f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025fa:	00 
f01025fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102602:	00 
	return (void *)(pa + KERNBASE);
f0102603:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102608:	89 04 24             	mov    %eax,(%esp)
f010260b:	e8 de 3d 00 00       	call   f01063ee <memset>
	}
	return alloc_page;
}
f0102610:	89 d8                	mov    %ebx,%eax
f0102612:	83 c4 14             	add    $0x14,%esp
f0102615:	5b                   	pop    %ebx
f0102616:	5d                   	pop    %ebp
f0102617:	c3                   	ret    

f0102618 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0102618:	55                   	push   %ebp
f0102619:	89 e5                	mov    %esp,%ebp
f010261b:	83 ec 18             	sub    $0x18,%esp
f010261e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link !=NULL)
f0102621:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102626:	75 05                	jne    f010262d <page_free+0x15>
f0102628:	83 38 00             	cmpl   $0x0,(%eax)
f010262b:	74 1c                	je     f0102649 <page_free+0x31>
		panic("Something went wrong at page_free");
f010262d:	c7 44 24 08 3c 7d 10 	movl   $0xf0107d3c,0x8(%esp)
f0102634:	f0 
f0102635:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f010263c:	00 
f010263d:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102644:	e8 68 da ff ff       	call   f01000b1 <_panic>
	pp->pp_link = page_free_list;
f0102649:	8b 15 08 b0 20 f0    	mov    0xf020b008,%edx
f010264f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0102651:	a3 08 b0 20 f0       	mov    %eax,0xf020b008
	return;
}
f0102656:	c9                   	leave  
f0102657:	c3                   	ret    

f0102658 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0102658:	55                   	push   %ebp
f0102659:	89 e5                	mov    %esp,%ebp
f010265b:	83 ec 18             	sub    $0x18,%esp
f010265e:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0102661:	8b 50 04             	mov    0x4(%eax),%edx
f0102664:	4a                   	dec    %edx
f0102665:	66 89 50 04          	mov    %dx,0x4(%eax)
f0102669:	66 85 d2             	test   %dx,%dx
f010266c:	75 08                	jne    f0102676 <page_decref+0x1e>
		page_free(pp);
f010266e:	89 04 24             	mov    %eax,(%esp)
f0102671:	e8 a2 ff ff ff       	call   f0102618 <page_free>
}
f0102676:	c9                   	leave  
f0102677:	c3                   	ret    

f0102678 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0102678:	55                   	push   %ebp
f0102679:	89 e5                	mov    %esp,%ebp
f010267b:	56                   	push   %esi
f010267c:	53                   	push   %ebx
f010267d:	83 ec 10             	sub    $0x10,%esp
f0102680:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102683:	8b 45 10             	mov    0x10(%ebp),%eax
	// Fill this function in
	if (!((create == 0) || (create == 1)))
f0102686:	83 f8 01             	cmp    $0x1,%eax
f0102689:	76 1c                	jbe    f01026a7 <pgdir_walk+0x2f>
		panic("pgdir_walk: create is wrong!!!");
f010268b:	c7 44 24 08 60 7d 10 	movl   $0xf0107d60,0x8(%esp)
f0102692:	f0 
f0102693:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
f010269a:	00 
f010269b:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01026a2:	e8 0a da ff ff       	call   f01000b1 <_panic>
	
	pde_t *pde = &pgdir[PDX(va)];
f01026a7:	89 f1                	mov    %esi,%ecx
f01026a9:	c1 e9 16             	shr    $0x16,%ecx
f01026ac:	8b 55 08             	mov    0x8(%ebp),%edx
f01026af:	8d 1c 8a             	lea    (%edx,%ecx,4),%ebx
	if ((*pde & PTE_P) == 0){
f01026b2:	f6 03 01             	testb  $0x1,(%ebx)
f01026b5:	75 29                	jne    f01026e0 <pgdir_walk+0x68>
		if (create == false){
f01026b7:	85 c0                	test   %eax,%eax
f01026b9:	74 6b                	je     f0102726 <pgdir_walk+0xae>
			return NULL;
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
f01026bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01026c2:	e8 cd fe ff ff       	call   f0102594 <page_alloc>
			if (page==NULL) return NULL;
f01026c7:	85 c0                	test   %eax,%eax
f01026c9:	74 62                	je     f010272d <pgdir_walk+0xb5>
			page->pp_ref++;
f01026cb:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026cf:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f01026d5:	c1 f8 03             	sar    $0x3,%eax
f01026d8:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f01026db:	83 c8 07             	or     $0x7,%eax
f01026de:	89 03                	mov    %eax,(%ebx)
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
f01026e0:	8b 03                	mov    (%ebx),%eax
f01026e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026e7:	89 c2                	mov    %eax,%edx
f01026e9:	c1 ea 0c             	shr    $0xc,%edx
f01026ec:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f01026f2:	72 20                	jb     f0102714 <pgdir_walk+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026f8:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f01026ff:	f0 
f0102700:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0102707:	00 
f0102708:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010270f:	e8 9d d9 ff ff       	call   f01000b1 <_panic>
	return &pgtable[PTX(va)];
f0102714:	c1 ee 0a             	shr    $0xa,%esi
f0102717:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010271d:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0102724:	eb 0c                	jmp    f0102732 <pgdir_walk+0xba>
		panic("pgdir_walk: create is wrong!!!");
	
	pde_t *pde = &pgdir[PDX(va)];
	if ((*pde & PTE_P) == 0){
		if (create == false){
			return NULL;
f0102726:	b8 00 00 00 00       	mov    $0x0,%eax
f010272b:	eb 05                	jmp    f0102732 <pgdir_walk+0xba>
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
			if (page==NULL) return NULL;
f010272d:	b8 00 00 00 00       	mov    $0x0,%eax
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	return &pgtable[PTX(va)];
}
f0102732:	83 c4 10             	add    $0x10,%esp
f0102735:	5b                   	pop    %ebx
f0102736:	5e                   	pop    %esi
f0102737:	5d                   	pop    %ebp
f0102738:	c3                   	ret    

f0102739 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0102739:	55                   	push   %ebp
f010273a:	89 e5                	mov    %esp,%ebp
f010273c:	57                   	push   %edi
f010273d:	56                   	push   %esi
f010273e:	53                   	push   %ebx
f010273f:	83 ec 2c             	sub    $0x2c,%esp
f0102742:	89 c6                	mov    %eax,%esi
f0102744:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102747:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// assert(size % PGSIZE == 0);
	if (size % PGSIZE != 0){
f010274a:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f0102750:	74 1c                	je     f010276e <boot_map_region+0x35>
		panic("boot_map_region: size % PGSIZE != 0");
f0102752:	c7 44 24 08 80 7d 10 	movl   $0xf0107d80,0x8(%esp)
f0102759:	f0 
f010275a:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f0102761:	00 
f0102762:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102769:	e8 43 d9 ff ff       	call   f01000b1 <_panic>
	}
	if (PTE_ADDR(va) != va)
f010276e:	89 d1                	mov    %edx,%ecx
f0102770:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102776:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102779:	39 d1                	cmp    %edx,%ecx
f010277b:	74 1c                	je     f0102799 <boot_map_region+0x60>
		panic("boot_map_region: va is not page_aligned");
f010277d:	c7 44 24 08 a4 7d 10 	movl   $0xf0107da4,0x8(%esp)
f0102784:	f0 
f0102785:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f010278c:	00 
f010278d:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102794:	e8 18 d9 ff ff       	call   f01000b1 <_panic>
	if (PTE_ADDR(pa) != pa)
f0102799:	89 c7                	mov    %eax,%edi
f010279b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01027a1:	39 c7                	cmp    %eax,%edi
f01027a3:	74 4b                	je     f01027f0 <boot_map_region+0xb7>
		panic("boot_map_region: pa is not page_aligned");
f01027a5:	c7 44 24 08 cc 7d 10 	movl   $0xf0107dcc,0x8(%esp)
f01027ac:	f0 
f01027ad:	c7 44 24 04 ce 01 00 	movl   $0x1ce,0x4(%esp)
f01027b4:	00 
f01027b5:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01027bc:	e8 f0 d8 ff ff       	call   f01000b1 <_panic>
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f01027c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027c8:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01027c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01027cc:	01 d8                	add    %ebx,%eax
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f01027ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027d2:	89 34 24             	mov    %esi,(%esp)
f01027d5:	e8 9e fe ff ff       	call   f0102678 <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01027da:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f01027dd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027e3:	0b 55 dc             	or     -0x24(%ebp),%edx
f01027e6:	89 10                	mov    %edx,(%eax)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f01027e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027ee:	eb 0e                	jmp    f01027fe <boot_map_region+0xc5>
	if (size % PGSIZE != 0){
		panic("boot_map_region: size % PGSIZE != 0");
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
f01027f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f01027f5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027f8:	83 c8 01             	or     $0x1,%eax
f01027fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f01027fe:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102801:	72 be                	jb     f01027c1 <boot_map_region+0x88>
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
	}
}
f0102803:	83 c4 2c             	add    $0x2c,%esp
f0102806:	5b                   	pop    %ebx
f0102807:	5e                   	pop    %esi
f0102808:	5f                   	pop    %edi
f0102809:	5d                   	pop    %ebp
f010280a:	c3                   	ret    

f010280b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010280b:	55                   	push   %ebp
f010280c:	89 e5                	mov    %esp,%ebp
f010280e:	53                   	push   %ebx
f010280f:	83 ec 14             	sub    $0x14,%esp
f0102812:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
f0102815:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010281c:	00 
f010281d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102820:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102824:	8b 45 08             	mov    0x8(%ebp),%eax
f0102827:	89 04 24             	mov    %eax,(%esp)
f010282a:	e8 49 fe ff ff       	call   f0102678 <pgdir_walk>
	if (pte == NULL) return NULL;
f010282f:	85 c0                	test   %eax,%eax
f0102831:	74 3a                	je     f010286d <page_lookup+0x62>
	if (pte_store != NULL)
f0102833:	85 db                	test   %ebx,%ebx
f0102835:	74 02                	je     f0102839 <page_lookup+0x2e>
		*pte_store = pte;
f0102837:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));
f0102839:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010283b:	c1 e8 0c             	shr    $0xc,%eax
f010283e:	3b 05 a8 bc 20 f0    	cmp    0xf020bca8,%eax
f0102844:	72 1c                	jb     f0102862 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0102846:	c7 44 24 08 f4 7d 10 	movl   $0xf0107df4,0x8(%esp)
f010284d:	f0 
f010284e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0102855:	00 
f0102856:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f010285d:	e8 4f d8 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0102862:	c1 e0 03             	shl    $0x3,%eax
f0102865:	03 05 b0 bc 20 f0    	add    0xf020bcb0,%eax
f010286b:	eb 05                	jmp    f0102872 <page_lookup+0x67>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
	if (pte == NULL) return NULL;
f010286d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store != NULL)
		*pte_store = pte;
	return pa2page(PTE_ADDR(*pte));
}
f0102872:	83 c4 14             	add    $0x14,%esp
f0102875:	5b                   	pop    %ebx
f0102876:	5d                   	pop    %ebp
f0102877:	c3                   	ret    

f0102878 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102878:	55                   	push   %ebp
f0102879:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010287b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010287e:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102881:	5d                   	pop    %ebp
f0102882:	c3                   	ret    

f0102883 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0102883:	55                   	push   %ebp
f0102884:	89 e5                	mov    %esp,%ebp
f0102886:	56                   	push   %esi
f0102887:	53                   	push   %ebx
f0102888:	83 ec 20             	sub    $0x20,%esp
f010288b:	8b 75 08             	mov    0x8(%ebp),%esi
f010288e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0102891:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102894:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102898:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010289c:	89 34 24             	mov    %esi,(%esp)
f010289f:	e8 67 ff ff ff       	call   f010280b <page_lookup>
	if(page != NULL){
f01028a4:	85 c0                	test   %eax,%eax
f01028a6:	74 1d                	je     f01028c5 <page_remove+0x42>
		*pte = 0;
f01028a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01028ab:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(page);
f01028b1:	89 04 24             	mov    %eax,(%esp)
f01028b4:	e8 9f fd ff ff       	call   f0102658 <page_decref>
		tlb_invalidate(pgdir, va);
f01028b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01028bd:	89 34 24             	mov    %esi,(%esp)
f01028c0:	e8 b3 ff ff ff       	call   f0102878 <tlb_invalidate>
	}
	return;
}
f01028c5:	83 c4 20             	add    $0x20,%esp
f01028c8:	5b                   	pop    %ebx
f01028c9:	5e                   	pop    %esi
f01028ca:	5d                   	pop    %ebp
f01028cb:	c3                   	ret    

f01028cc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01028cc:	55                   	push   %ebp
f01028cd:	89 e5                	mov    %esp,%ebp
f01028cf:	57                   	push   %edi
f01028d0:	56                   	push   %esi
f01028d1:	53                   	push   %ebx
f01028d2:	83 ec 1c             	sub    $0x1c,%esp
f01028d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01028d8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
f01028db:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028e2:	00 
f01028e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01028e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01028ea:	89 04 24             	mov    %eax,(%esp)
f01028ed:	e8 86 fd ff ff       	call   f0102678 <pgdir_walk>
f01028f2:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f01028f4:	85 c0                	test   %eax,%eax
f01028f6:	74 48                	je     f0102940 <page_insert+0x74>
    pp->pp_ref++;
f01028f8:	66 ff 46 04          	incw   0x4(%esi)
    if ((*pte & PTE_P) != 0) {
f01028fc:	f6 00 01             	testb  $0x1,(%eax)
f01028ff:	74 1e                	je     f010291f <page_insert+0x53>
        page_remove(pgdir,va);
f0102901:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102905:	8b 45 08             	mov    0x8(%ebp),%eax
f0102908:	89 04 24             	mov    %eax,(%esp)
f010290b:	e8 73 ff ff ff       	call   f0102883 <page_remove>
        tlb_invalidate(pgdir,va);
f0102910:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102914:	8b 45 08             	mov    0x8(%ebp),%eax
f0102917:	89 04 24             	mov    %eax,(%esp)
f010291a:	e8 59 ff ff ff       	call   f0102878 <tlb_invalidate>
    }
    *pte = page2pa(pp) | perm | PTE_P;
f010291f:	8b 55 14             	mov    0x14(%ebp),%edx
f0102922:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102925:	2b 35 b0 bc 20 f0    	sub    0xf020bcb0,%esi
f010292b:	c1 fe 03             	sar    $0x3,%esi
f010292e:	89 f0                	mov    %esi,%eax
f0102930:	c1 e0 0c             	shl    $0xc,%eax
f0102933:	89 d6                	mov    %edx,%esi
f0102935:	09 c6                	or     %eax,%esi
f0102937:	89 33                	mov    %esi,(%ebx)
	return 0;
f0102939:	b8 00 00 00 00       	mov    $0x0,%eax
f010293e:	eb 05                	jmp    f0102945 <page_insert+0x79>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
    if (pte == NULL) return -E_NO_MEM;
f0102940:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir,va);
        tlb_invalidate(pgdir,va);
    }
    *pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0102945:	83 c4 1c             	add    $0x1c,%esp
f0102948:	5b                   	pop    %ebx
f0102949:	5e                   	pop    %esi
f010294a:	5f                   	pop    %edi
f010294b:	5d                   	pop    %ebp
f010294c:	c3                   	ret    

f010294d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010294d:	55                   	push   %ebp
f010294e:	89 e5                	mov    %esp,%ebp
f0102950:	57                   	push   %edi
f0102951:	56                   	push   %esi
f0102952:	53                   	push   %ebx
f0102953:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0102956:	b8 15 00 00 00       	mov    $0x15,%eax
f010295b:	e8 7d f7 ff ff       	call   f01020dd <nvram_read>
f0102960:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0102962:	b8 17 00 00 00       	mov    $0x17,%eax
f0102967:	e8 71 f7 ff ff       	call   f01020dd <nvram_read>
f010296c:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010296e:	b8 34 00 00 00       	mov    $0x34,%eax
f0102973:	e8 65 f7 ff ff       	call   f01020dd <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0102978:	c1 e0 06             	shl    $0x6,%eax
f010297b:	74 08                	je     f0102985 <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f010297d:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f0102983:	eb 0e                	jmp    f0102993 <mem_init+0x46>
	else if (extmem)
f0102985:	85 f6                	test   %esi,%esi
f0102987:	74 08                	je     f0102991 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0102989:	81 c6 00 04 00 00    	add    $0x400,%esi
f010298f:	eb 02                	jmp    f0102993 <mem_init+0x46>
	else
		totalmem = basemem;
f0102991:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f0102993:	89 f0                	mov    %esi,%eax
f0102995:	c1 e8 02             	shr    $0x2,%eax
f0102998:	a3 a8 bc 20 f0       	mov    %eax,0xf020bca8
	npages_basemem = basemem / (PGSIZE / 1024);
f010299d:	89 d8                	mov    %ebx,%eax
f010299f:	c1 e8 02             	shr    $0x2,%eax
f01029a2:	a3 00 b0 20 f0       	mov    %eax,0xf020b000
	// cprintf("%u\n",ext16mem);
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01029a7:	89 f0                	mov    %esi,%eax
f01029a9:	29 d8                	sub    %ebx,%eax
f01029ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01029b3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01029b7:	c7 04 24 14 7e 10 f0 	movl   $0xf0107e14,(%esp)
f01029be:	e8 13 25 00 00       	call   f0104ed6 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01029c3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01029c8:	e8 78 f6 ff ff       	call   f0102045 <boot_alloc>
f01029cd:	a3 ac bc 20 f0       	mov    %eax,0xf020bcac
	memset(kern_pgdir, 0, PGSIZE);
f01029d2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01029d9:	00 
f01029da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01029e1:	00 
f01029e2:	89 04 24             	mov    %eax,(%esp)
f01029e5:	e8 04 3a 00 00       	call   f01063ee <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01029ea:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029f4:	77 20                	ja     f0102a16 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029fa:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0102a01:	f0 
f0102a02:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
f0102a09:	00 
f0102a0a:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102a11:	e8 9b d6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a16:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102a1c:	83 ca 05             	or     $0x5,%edx
f0102a1f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);
f0102a25:	a1 a8 bc 20 f0       	mov    0xf020bca8,%eax
f0102a2a:	c1 e0 03             	shl    $0x3,%eax
f0102a2d:	e8 13 f6 ff ff       	call   f0102045 <boot_alloc>
f0102a32:	a3 b0 bc 20 f0       	mov    %eax,0xf020bcb0
	// cprintf("npages: %x\n",npages);
	// cprintf("pages: %x\n",pages);
	memset(pages,0,sizeof(struct PageInfo) * npages);
f0102a37:	8b 15 a8 bc 20 f0    	mov    0xf020bca8,%edx
f0102a3d:	c1 e2 03             	shl    $0x3,%edx
f0102a40:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102a44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a4b:	00 
f0102a4c:	89 04 24             	mov    %eax,(%esp)
f0102a4f:	e8 9a 39 00 00       	call   f01063ee <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f0102a54:	b8 00 80 01 00       	mov    $0x18000,%eax
f0102a59:	e8 e7 f5 ff ff       	call   f0102045 <boot_alloc>
f0102a5e:	a3 14 b0 20 f0       	mov    %eax,0xf020b014
	memset(envs, 0 ,sizeof(struct Env) * NENV);
f0102a63:	c7 44 24 08 00 80 01 	movl   $0x18000,0x8(%esp)
f0102a6a:	00 
f0102a6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a72:	00 
f0102a73:	89 04 24             	mov    %eax,(%esp)
f0102a76:	e8 73 39 00 00       	call   f01063ee <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0102a7b:	e8 b2 f9 ff ff       	call   f0102432 <page_init>

	check_page_free_list(1);
f0102a80:	b8 01 00 00 00       	mov    $0x1,%eax
f0102a85:	e8 7c f6 ff ff       	call   f0102106 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0102a8a:	83 3d b0 bc 20 f0 00 	cmpl   $0x0,0xf020bcb0
f0102a91:	75 1c                	jne    f0102aaf <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0102a93:	c7 44 24 08 a5 85 10 	movl   $0xf01085a5,0x8(%esp)
f0102a9a:	f0 
f0102a9b:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f0102aa2:	00 
f0102aa3:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102aaa:	e8 02 d6 ff ff       	call   f01000b1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102aaf:	a1 08 b0 20 f0       	mov    0xf020b008,%eax
f0102ab4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ab9:	eb 03                	jmp    f0102abe <mem_init+0x171>
		++nfree;
f0102abb:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102abc:	8b 00                	mov    (%eax),%eax
f0102abe:	85 c0                	test   %eax,%eax
f0102ac0:	75 f9                	jne    f0102abb <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ac2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ac9:	e8 c6 fa ff ff       	call   f0102594 <page_alloc>
f0102ace:	89 c6                	mov    %eax,%esi
f0102ad0:	85 c0                	test   %eax,%eax
f0102ad2:	75 24                	jne    f0102af8 <mem_init+0x1ab>
f0102ad4:	c7 44 24 0c c0 85 10 	movl   $0xf01085c0,0xc(%esp)
f0102adb:	f0 
f0102adc:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102ae3:	f0 
f0102ae4:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0102aeb:	00 
f0102aec:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102af3:	e8 b9 d5 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102af8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aff:	e8 90 fa ff ff       	call   f0102594 <page_alloc>
f0102b04:	89 c7                	mov    %eax,%edi
f0102b06:	85 c0                	test   %eax,%eax
f0102b08:	75 24                	jne    f0102b2e <mem_init+0x1e1>
f0102b0a:	c7 44 24 0c d6 85 10 	movl   $0xf01085d6,0xc(%esp)
f0102b11:	f0 
f0102b12:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102b19:	f0 
f0102b1a:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0102b21:	00 
f0102b22:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102b29:	e8 83 d5 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b35:	e8 5a fa ff ff       	call   f0102594 <page_alloc>
f0102b3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b3d:	85 c0                	test   %eax,%eax
f0102b3f:	75 24                	jne    f0102b65 <mem_init+0x218>
f0102b41:	c7 44 24 0c ec 85 10 	movl   $0xf01085ec,0xc(%esp)
f0102b48:	f0 
f0102b49:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102b50:	f0 
f0102b51:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0102b58:	00 
f0102b59:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102b60:	e8 4c d5 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102b65:	39 fe                	cmp    %edi,%esi
f0102b67:	75 24                	jne    f0102b8d <mem_init+0x240>
f0102b69:	c7 44 24 0c 02 86 10 	movl   $0xf0108602,0xc(%esp)
f0102b70:	f0 
f0102b71:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102b78:	f0 
f0102b79:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0102b80:	00 
f0102b81:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102b88:	e8 24 d5 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102b8d:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102b90:	74 05                	je     f0102b97 <mem_init+0x24a>
f0102b92:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102b95:	75 24                	jne    f0102bbb <mem_init+0x26e>
f0102b97:	c7 44 24 0c 50 7e 10 	movl   $0xf0107e50,0xc(%esp)
f0102b9e:	f0 
f0102b9f:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102ba6:	f0 
f0102ba7:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0102bae:	00 
f0102baf:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102bb6:	e8 f6 d4 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bbb:	8b 15 b0 bc 20 f0    	mov    0xf020bcb0,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102bc1:	a1 a8 bc 20 f0       	mov    0xf020bca8,%eax
f0102bc6:	c1 e0 0c             	shl    $0xc,%eax
f0102bc9:	89 f1                	mov    %esi,%ecx
f0102bcb:	29 d1                	sub    %edx,%ecx
f0102bcd:	c1 f9 03             	sar    $0x3,%ecx
f0102bd0:	c1 e1 0c             	shl    $0xc,%ecx
f0102bd3:	39 c1                	cmp    %eax,%ecx
f0102bd5:	72 24                	jb     f0102bfb <mem_init+0x2ae>
f0102bd7:	c7 44 24 0c 14 86 10 	movl   $0xf0108614,0xc(%esp)
f0102bde:	f0 
f0102bdf:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102be6:	f0 
f0102be7:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f0102bee:	00 
f0102bef:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102bf6:	e8 b6 d4 ff ff       	call   f01000b1 <_panic>
f0102bfb:	89 f9                	mov    %edi,%ecx
f0102bfd:	29 d1                	sub    %edx,%ecx
f0102bff:	c1 f9 03             	sar    $0x3,%ecx
f0102c02:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0102c05:	39 c8                	cmp    %ecx,%eax
f0102c07:	77 24                	ja     f0102c2d <mem_init+0x2e0>
f0102c09:	c7 44 24 0c 31 86 10 	movl   $0xf0108631,0xc(%esp)
f0102c10:	f0 
f0102c11:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102c18:	f0 
f0102c19:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0102c20:	00 
f0102c21:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102c28:	e8 84 d4 ff ff       	call   f01000b1 <_panic>
f0102c2d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c30:	29 d1                	sub    %edx,%ecx
f0102c32:	89 ca                	mov    %ecx,%edx
f0102c34:	c1 fa 03             	sar    $0x3,%edx
f0102c37:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0102c3a:	39 d0                	cmp    %edx,%eax
f0102c3c:	77 24                	ja     f0102c62 <mem_init+0x315>
f0102c3e:	c7 44 24 0c 4e 86 10 	movl   $0xf010864e,0xc(%esp)
f0102c45:	f0 
f0102c46:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102c4d:	f0 
f0102c4e:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0102c55:	00 
f0102c56:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102c5d:	e8 4f d4 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102c62:	a1 08 b0 20 f0       	mov    0xf020b008,%eax
f0102c67:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0102c6a:	c7 05 08 b0 20 f0 00 	movl   $0x0,0xf020b008
f0102c71:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102c74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c7b:	e8 14 f9 ff ff       	call   f0102594 <page_alloc>
f0102c80:	85 c0                	test   %eax,%eax
f0102c82:	74 24                	je     f0102ca8 <mem_init+0x35b>
f0102c84:	c7 44 24 0c 6b 86 10 	movl   $0xf010866b,0xc(%esp)
f0102c8b:	f0 
f0102c8c:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102c93:	f0 
f0102c94:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0102c9b:	00 
f0102c9c:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102ca3:	e8 09 d4 ff ff       	call   f01000b1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102ca8:	89 34 24             	mov    %esi,(%esp)
f0102cab:	e8 68 f9 ff ff       	call   f0102618 <page_free>
	page_free(pp1);
f0102cb0:	89 3c 24             	mov    %edi,(%esp)
f0102cb3:	e8 60 f9 ff ff       	call   f0102618 <page_free>
	page_free(pp2);
f0102cb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cbb:	89 04 24             	mov    %eax,(%esp)
f0102cbe:	e8 55 f9 ff ff       	call   f0102618 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102cc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cca:	e8 c5 f8 ff ff       	call   f0102594 <page_alloc>
f0102ccf:	89 c6                	mov    %eax,%esi
f0102cd1:	85 c0                	test   %eax,%eax
f0102cd3:	75 24                	jne    f0102cf9 <mem_init+0x3ac>
f0102cd5:	c7 44 24 0c c0 85 10 	movl   $0xf01085c0,0xc(%esp)
f0102cdc:	f0 
f0102cdd:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102ce4:	f0 
f0102ce5:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0102cec:	00 
f0102ced:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102cf4:	e8 b8 d3 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102cf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d00:	e8 8f f8 ff ff       	call   f0102594 <page_alloc>
f0102d05:	89 c7                	mov    %eax,%edi
f0102d07:	85 c0                	test   %eax,%eax
f0102d09:	75 24                	jne    f0102d2f <mem_init+0x3e2>
f0102d0b:	c7 44 24 0c d6 85 10 	movl   $0xf01085d6,0xc(%esp)
f0102d12:	f0 
f0102d13:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102d1a:	f0 
f0102d1b:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0102d22:	00 
f0102d23:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102d2a:	e8 82 d3 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d36:	e8 59 f8 ff ff       	call   f0102594 <page_alloc>
f0102d3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d3e:	85 c0                	test   %eax,%eax
f0102d40:	75 24                	jne    f0102d66 <mem_init+0x419>
f0102d42:	c7 44 24 0c ec 85 10 	movl   $0xf01085ec,0xc(%esp)
f0102d49:	f0 
f0102d4a:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102d51:	f0 
f0102d52:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102d59:	00 
f0102d5a:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102d61:	e8 4b d3 ff ff       	call   f01000b1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102d66:	39 fe                	cmp    %edi,%esi
f0102d68:	75 24                	jne    f0102d8e <mem_init+0x441>
f0102d6a:	c7 44 24 0c 02 86 10 	movl   $0xf0108602,0xc(%esp)
f0102d71:	f0 
f0102d72:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102d79:	f0 
f0102d7a:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f0102d81:	00 
f0102d82:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102d89:	e8 23 d3 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102d8e:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102d91:	74 05                	je     f0102d98 <mem_init+0x44b>
f0102d93:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102d96:	75 24                	jne    f0102dbc <mem_init+0x46f>
f0102d98:	c7 44 24 0c 50 7e 10 	movl   $0xf0107e50,0xc(%esp)
f0102d9f:	f0 
f0102da0:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102da7:	f0 
f0102da8:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f0102daf:	00 
f0102db0:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102db7:	e8 f5 d2 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102dbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dc3:	e8 cc f7 ff ff       	call   f0102594 <page_alloc>
f0102dc8:	85 c0                	test   %eax,%eax
f0102dca:	74 24                	je     f0102df0 <mem_init+0x4a3>
f0102dcc:	c7 44 24 0c 6b 86 10 	movl   $0xf010866b,0xc(%esp)
f0102dd3:	f0 
f0102dd4:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102ddb:	f0 
f0102ddc:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0102de3:	00 
f0102de4:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102deb:	e8 c1 d2 ff ff       	call   f01000b1 <_panic>
f0102df0:	89 f0                	mov    %esi,%eax
f0102df2:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f0102df8:	c1 f8 03             	sar    $0x3,%eax
f0102dfb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dfe:	89 c2                	mov    %eax,%edx
f0102e00:	c1 ea 0c             	shr    $0xc,%edx
f0102e03:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f0102e09:	72 20                	jb     f0102e2b <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e0f:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0102e16:	f0 
f0102e17:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102e1e:	00 
f0102e1f:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0102e26:	e8 86 d2 ff ff       	call   f01000b1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102e2b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102e32:	00 
f0102e33:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102e3a:	00 
	return (void *)(pa + KERNBASE);
f0102e3b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e40:	89 04 24             	mov    %eax,(%esp)
f0102e43:	e8 a6 35 00 00       	call   f01063ee <memset>
	page_free(pp0);
f0102e48:	89 34 24             	mov    %esi,(%esp)
f0102e4b:	e8 c8 f7 ff ff       	call   f0102618 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102e50:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102e57:	e8 38 f7 ff ff       	call   f0102594 <page_alloc>
f0102e5c:	85 c0                	test   %eax,%eax
f0102e5e:	75 24                	jne    f0102e84 <mem_init+0x537>
f0102e60:	c7 44 24 0c 7a 86 10 	movl   $0xf010867a,0xc(%esp)
f0102e67:	f0 
f0102e68:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102e6f:	f0 
f0102e70:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0102e77:	00 
f0102e78:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102e7f:	e8 2d d2 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0102e84:	39 c6                	cmp    %eax,%esi
f0102e86:	74 24                	je     f0102eac <mem_init+0x55f>
f0102e88:	c7 44 24 0c 98 86 10 	movl   $0xf0108698,0xc(%esp)
f0102e8f:	f0 
f0102e90:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102e97:	f0 
f0102e98:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0102e9f:	00 
f0102ea0:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102ea7:	e8 05 d2 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102eac:	89 f2                	mov    %esi,%edx
f0102eae:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f0102eb4:	c1 fa 03             	sar    $0x3,%edx
f0102eb7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102eba:	89 d0                	mov    %edx,%eax
f0102ebc:	c1 e8 0c             	shr    $0xc,%eax
f0102ebf:	3b 05 a8 bc 20 f0    	cmp    0xf020bca8,%eax
f0102ec5:	72 20                	jb     f0102ee7 <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ec7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ecb:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0102ed2:	f0 
f0102ed3:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102eda:	00 
f0102edb:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0102ee2:	e8 ca d1 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0102ee7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102eed:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102ef3:	80 38 00             	cmpb   $0x0,(%eax)
f0102ef6:	74 24                	je     f0102f1c <mem_init+0x5cf>
f0102ef8:	c7 44 24 0c a8 86 10 	movl   $0xf01086a8,0xc(%esp)
f0102eff:	f0 
f0102f00:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102f07:	f0 
f0102f08:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0102f0f:	00 
f0102f10:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102f17:	e8 95 d1 ff ff       	call   f01000b1 <_panic>
f0102f1c:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102f1d:	39 d0                	cmp    %edx,%eax
f0102f1f:	75 d2                	jne    f0102ef3 <mem_init+0x5a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102f21:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102f24:	89 15 08 b0 20 f0    	mov    %edx,0xf020b008

	// free the pages we took
	page_free(pp0);
f0102f2a:	89 34 24             	mov    %esi,(%esp)
f0102f2d:	e8 e6 f6 ff ff       	call   f0102618 <page_free>
	page_free(pp1);
f0102f32:	89 3c 24             	mov    %edi,(%esp)
f0102f35:	e8 de f6 ff ff       	call   f0102618 <page_free>
	page_free(pp2);
f0102f3a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f3d:	89 04 24             	mov    %eax,(%esp)
f0102f40:	e8 d3 f6 ff ff       	call   f0102618 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102f45:	a1 08 b0 20 f0       	mov    0xf020b008,%eax
f0102f4a:	eb 03                	jmp    f0102f4f <mem_init+0x602>
		--nfree;
f0102f4c:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102f4d:	8b 00                	mov    (%eax),%eax
f0102f4f:	85 c0                	test   %eax,%eax
f0102f51:	75 f9                	jne    f0102f4c <mem_init+0x5ff>
		--nfree;
	assert(nfree == 0);
f0102f53:	85 db                	test   %ebx,%ebx
f0102f55:	74 24                	je     f0102f7b <mem_init+0x62e>
f0102f57:	c7 44 24 0c b2 86 10 	movl   $0xf01086b2,0xc(%esp)
f0102f5e:	f0 
f0102f5f:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102f66:	f0 
f0102f67:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0102f6e:	00 
f0102f6f:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102f76:	e8 36 d1 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102f7b:	c7 04 24 70 7e 10 f0 	movl   $0xf0107e70,(%esp)
f0102f82:	e8 4f 1f 00 00       	call   f0104ed6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f8e:	e8 01 f6 ff ff       	call   f0102594 <page_alloc>
f0102f93:	89 c7                	mov    %eax,%edi
f0102f95:	85 c0                	test   %eax,%eax
f0102f97:	75 24                	jne    f0102fbd <mem_init+0x670>
f0102f99:	c7 44 24 0c c0 85 10 	movl   $0xf01085c0,0xc(%esp)
f0102fa0:	f0 
f0102fa1:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102fa8:	f0 
f0102fa9:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0102fb0:	00 
f0102fb1:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102fb8:	e8 f4 d0 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fc4:	e8 cb f5 ff ff       	call   f0102594 <page_alloc>
f0102fc9:	89 c6                	mov    %eax,%esi
f0102fcb:	85 c0                	test   %eax,%eax
f0102fcd:	75 24                	jne    f0102ff3 <mem_init+0x6a6>
f0102fcf:	c7 44 24 0c d6 85 10 	movl   $0xf01085d6,0xc(%esp)
f0102fd6:	f0 
f0102fd7:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0102fde:	f0 
f0102fdf:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102fe6:	00 
f0102fe7:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0102fee:	e8 be d0 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ff3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ffa:	e8 95 f5 ff ff       	call   f0102594 <page_alloc>
f0102fff:	89 c3                	mov    %eax,%ebx
f0103001:	85 c0                	test   %eax,%eax
f0103003:	75 24                	jne    f0103029 <mem_init+0x6dc>
f0103005:	c7 44 24 0c ec 85 10 	movl   $0xf01085ec,0xc(%esp)
f010300c:	f0 
f010300d:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103014:	f0 
f0103015:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f010301c:	00 
f010301d:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103024:	e8 88 d0 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0103029:	39 f7                	cmp    %esi,%edi
f010302b:	75 24                	jne    f0103051 <mem_init+0x704>
f010302d:	c7 44 24 0c 02 86 10 	movl   $0xf0108602,0xc(%esp)
f0103034:	f0 
f0103035:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010303c:	f0 
f010303d:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0103044:	00 
f0103045:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010304c:	e8 60 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0103051:	39 c6                	cmp    %eax,%esi
f0103053:	74 04                	je     f0103059 <mem_init+0x70c>
f0103055:	39 c7                	cmp    %eax,%edi
f0103057:	75 24                	jne    f010307d <mem_init+0x730>
f0103059:	c7 44 24 0c 50 7e 10 	movl   $0xf0107e50,0xc(%esp)
f0103060:	f0 
f0103061:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103068:	f0 
f0103069:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0103070:	00 
f0103071:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103078:	e8 34 d0 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010307d:	8b 15 08 b0 20 f0    	mov    0xf020b008,%edx
f0103083:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0103086:	c7 05 08 b0 20 f0 00 	movl   $0x0,0xf020b008
f010308d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0103090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103097:	e8 f8 f4 ff ff       	call   f0102594 <page_alloc>
f010309c:	85 c0                	test   %eax,%eax
f010309e:	74 24                	je     f01030c4 <mem_init+0x777>
f01030a0:	c7 44 24 0c 6b 86 10 	movl   $0xf010866b,0xc(%esp)
f01030a7:	f0 
f01030a8:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01030af:	f0 
f01030b0:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f01030b7:	00 
f01030b8:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01030bf:	e8 ed cf ff ff       	call   f01000b1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01030c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01030d2:	00 
f01030d3:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01030d8:	89 04 24             	mov    %eax,(%esp)
f01030db:	e8 2b f7 ff ff       	call   f010280b <page_lookup>
f01030e0:	85 c0                	test   %eax,%eax
f01030e2:	74 24                	je     f0103108 <mem_init+0x7bb>
f01030e4:	c7 44 24 0c 90 7e 10 	movl   $0xf0107e90,0xc(%esp)
f01030eb:	f0 
f01030ec:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01030f3:	f0 
f01030f4:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f01030fb:	00 
f01030fc:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103103:	e8 a9 cf ff ff       	call   f01000b1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0103108:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010310f:	00 
f0103110:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103117:	00 
f0103118:	89 74 24 04          	mov    %esi,0x4(%esp)
f010311c:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103121:	89 04 24             	mov    %eax,(%esp)
f0103124:	e8 a3 f7 ff ff       	call   f01028cc <page_insert>
f0103129:	85 c0                	test   %eax,%eax
f010312b:	78 24                	js     f0103151 <mem_init+0x804>
f010312d:	c7 44 24 0c c8 7e 10 	movl   $0xf0107ec8,0xc(%esp)
f0103134:	f0 
f0103135:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010313c:	f0 
f010313d:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0103144:	00 
f0103145:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010314c:	e8 60 cf ff ff       	call   f01000b1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0103151:	89 3c 24             	mov    %edi,(%esp)
f0103154:	e8 bf f4 ff ff       	call   f0102618 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0103159:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103160:	00 
f0103161:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103168:	00 
f0103169:	89 74 24 04          	mov    %esi,0x4(%esp)
f010316d:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103172:	89 04 24             	mov    %eax,(%esp)
f0103175:	e8 52 f7 ff ff       	call   f01028cc <page_insert>
f010317a:	85 c0                	test   %eax,%eax
f010317c:	74 24                	je     f01031a2 <mem_init+0x855>
f010317e:	c7 44 24 0c f8 7e 10 	movl   $0xf0107ef8,0xc(%esp)
f0103185:	f0 
f0103186:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010318d:	f0 
f010318e:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0103195:	00 
f0103196:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010319d:	e8 0f cf ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031a2:	8b 0d ac bc 20 f0    	mov    0xf020bcac,%ecx
f01031a8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031ab:	a1 b0 bc 20 f0       	mov    0xf020bcb0,%eax
f01031b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01031b3:	8b 11                	mov    (%ecx),%edx
f01031b5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01031bb:	89 f8                	mov    %edi,%eax
f01031bd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01031c0:	c1 f8 03             	sar    $0x3,%eax
f01031c3:	c1 e0 0c             	shl    $0xc,%eax
f01031c6:	39 c2                	cmp    %eax,%edx
f01031c8:	74 24                	je     f01031ee <mem_init+0x8a1>
f01031ca:	c7 44 24 0c 28 7f 10 	movl   $0xf0107f28,0xc(%esp)
f01031d1:	f0 
f01031d2:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01031d9:	f0 
f01031da:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f01031e1:	00 
f01031e2:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01031e9:	e8 c3 ce ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01031ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01031f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031f6:	e8 dd ed ff ff       	call   f0101fd8 <check_va2pa>
f01031fb:	89 f2                	mov    %esi,%edx
f01031fd:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0103200:	c1 fa 03             	sar    $0x3,%edx
f0103203:	c1 e2 0c             	shl    $0xc,%edx
f0103206:	39 d0                	cmp    %edx,%eax
f0103208:	74 24                	je     f010322e <mem_init+0x8e1>
f010320a:	c7 44 24 0c 50 7f 10 	movl   $0xf0107f50,0xc(%esp)
f0103211:	f0 
f0103212:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103219:	f0 
f010321a:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0103221:	00 
f0103222:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103229:	e8 83 ce ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010322e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103233:	74 24                	je     f0103259 <mem_init+0x90c>
f0103235:	c7 44 24 0c bd 86 10 	movl   $0xf01086bd,0xc(%esp)
f010323c:	f0 
f010323d:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103244:	f0 
f0103245:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f010324c:	00 
f010324d:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103254:	e8 58 ce ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0103259:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010325e:	74 24                	je     f0103284 <mem_init+0x937>
f0103260:	c7 44 24 0c ce 86 10 	movl   $0xf01086ce,0xc(%esp)
f0103267:	f0 
f0103268:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010326f:	f0 
f0103270:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0103277:	00 
f0103278:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010327f:	e8 2d ce ff ff       	call   f01000b1 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103284:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010328b:	00 
f010328c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103293:	00 
f0103294:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103298:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010329b:	89 14 24             	mov    %edx,(%esp)
f010329e:	e8 29 f6 ff ff       	call   f01028cc <page_insert>
f01032a3:	85 c0                	test   %eax,%eax
f01032a5:	74 24                	je     f01032cb <mem_init+0x97e>
f01032a7:	c7 44 24 0c 80 7f 10 	movl   $0xf0107f80,0xc(%esp)
f01032ae:	f0 
f01032af:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01032b6:	f0 
f01032b7:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f01032be:	00 
f01032bf:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01032c6:	e8 e6 cd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01032cb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032d0:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01032d5:	e8 fe ec ff ff       	call   f0101fd8 <check_va2pa>
f01032da:	89 da                	mov    %ebx,%edx
f01032dc:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f01032e2:	c1 fa 03             	sar    $0x3,%edx
f01032e5:	c1 e2 0c             	shl    $0xc,%edx
f01032e8:	39 d0                	cmp    %edx,%eax
f01032ea:	74 24                	je     f0103310 <mem_init+0x9c3>
f01032ec:	c7 44 24 0c bc 7f 10 	movl   $0xf0107fbc,0xc(%esp)
f01032f3:	f0 
f01032f4:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01032fb:	f0 
f01032fc:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0103303:	00 
f0103304:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010330b:	e8 a1 cd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0103310:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103315:	74 24                	je     f010333b <mem_init+0x9ee>
f0103317:	c7 44 24 0c df 86 10 	movl   $0xf01086df,0xc(%esp)
f010331e:	f0 
f010331f:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103326:	f0 
f0103327:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f010332e:	00 
f010332f:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103336:	e8 76 cd ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010333b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103342:	e8 4d f2 ff ff       	call   f0102594 <page_alloc>
f0103347:	85 c0                	test   %eax,%eax
f0103349:	74 24                	je     f010336f <mem_init+0xa22>
f010334b:	c7 44 24 0c 6b 86 10 	movl   $0xf010866b,0xc(%esp)
f0103352:	f0 
f0103353:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010335a:	f0 
f010335b:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0103362:	00 
f0103363:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010336a:	e8 42 cd ff ff       	call   f01000b1 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010336f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103376:	00 
f0103377:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010337e:	00 
f010337f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103383:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103388:	89 04 24             	mov    %eax,(%esp)
f010338b:	e8 3c f5 ff ff       	call   f01028cc <page_insert>
f0103390:	85 c0                	test   %eax,%eax
f0103392:	74 24                	je     f01033b8 <mem_init+0xa6b>
f0103394:	c7 44 24 0c 80 7f 10 	movl   $0xf0107f80,0xc(%esp)
f010339b:	f0 
f010339c:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01033a3:	f0 
f01033a4:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01033ab:	00 
f01033ac:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01033b3:	e8 f9 cc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01033b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01033bd:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01033c2:	e8 11 ec ff ff       	call   f0101fd8 <check_va2pa>
f01033c7:	89 da                	mov    %ebx,%edx
f01033c9:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f01033cf:	c1 fa 03             	sar    $0x3,%edx
f01033d2:	c1 e2 0c             	shl    $0xc,%edx
f01033d5:	39 d0                	cmp    %edx,%eax
f01033d7:	74 24                	je     f01033fd <mem_init+0xab0>
f01033d9:	c7 44 24 0c bc 7f 10 	movl   $0xf0107fbc,0xc(%esp)
f01033e0:	f0 
f01033e1:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01033e8:	f0 
f01033e9:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01033f0:	00 
f01033f1:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01033f8:	e8 b4 cc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01033fd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103402:	74 24                	je     f0103428 <mem_init+0xadb>
f0103404:	c7 44 24 0c df 86 10 	movl   $0xf01086df,0xc(%esp)
f010340b:	f0 
f010340c:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103413:	f0 
f0103414:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f010341b:	00 
f010341c:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103423:	e8 89 cc ff ff       	call   f01000b1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0103428:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010342f:	e8 60 f1 ff ff       	call   f0102594 <page_alloc>
f0103434:	85 c0                	test   %eax,%eax
f0103436:	74 24                	je     f010345c <mem_init+0xb0f>
f0103438:	c7 44 24 0c 6b 86 10 	movl   $0xf010866b,0xc(%esp)
f010343f:	f0 
f0103440:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103447:	f0 
f0103448:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f010344f:	00 
f0103450:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103457:	e8 55 cc ff ff       	call   f01000b1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010345c:	8b 15 ac bc 20 f0    	mov    0xf020bcac,%edx
f0103462:	8b 02                	mov    (%edx),%eax
f0103464:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103469:	89 c1                	mov    %eax,%ecx
f010346b:	c1 e9 0c             	shr    $0xc,%ecx
f010346e:	3b 0d a8 bc 20 f0    	cmp    0xf020bca8,%ecx
f0103474:	72 20                	jb     f0103496 <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103476:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010347a:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0103481:	f0 
f0103482:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0103489:	00 
f010348a:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103491:	e8 1b cc ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0103496:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010349b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010349e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034a5:	00 
f01034a6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01034ad:	00 
f01034ae:	89 14 24             	mov    %edx,(%esp)
f01034b1:	e8 c2 f1 ff ff       	call   f0102678 <pgdir_walk>
f01034b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01034b9:	83 c2 04             	add    $0x4,%edx
f01034bc:	39 d0                	cmp    %edx,%eax
f01034be:	74 24                	je     f01034e4 <mem_init+0xb97>
f01034c0:	c7 44 24 0c ec 7f 10 	movl   $0xf0107fec,0xc(%esp)
f01034c7:	f0 
f01034c8:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01034cf:	f0 
f01034d0:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01034d7:	00 
f01034d8:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01034df:	e8 cd cb ff ff       	call   f01000b1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01034e4:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01034eb:	00 
f01034ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01034f3:	00 
f01034f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034f8:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01034fd:	89 04 24             	mov    %eax,(%esp)
f0103500:	e8 c7 f3 ff ff       	call   f01028cc <page_insert>
f0103505:	85 c0                	test   %eax,%eax
f0103507:	74 24                	je     f010352d <mem_init+0xbe0>
f0103509:	c7 44 24 0c 2c 80 10 	movl   $0xf010802c,0xc(%esp)
f0103510:	f0 
f0103511:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103518:	f0 
f0103519:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0103520:	00 
f0103521:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103528:	e8 84 cb ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010352d:	8b 0d ac bc 20 f0    	mov    0xf020bcac,%ecx
f0103533:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103536:	ba 00 10 00 00       	mov    $0x1000,%edx
f010353b:	89 c8                	mov    %ecx,%eax
f010353d:	e8 96 ea ff ff       	call   f0101fd8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103542:	89 da                	mov    %ebx,%edx
f0103544:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f010354a:	c1 fa 03             	sar    $0x3,%edx
f010354d:	c1 e2 0c             	shl    $0xc,%edx
f0103550:	39 d0                	cmp    %edx,%eax
f0103552:	74 24                	je     f0103578 <mem_init+0xc2b>
f0103554:	c7 44 24 0c bc 7f 10 	movl   $0xf0107fbc,0xc(%esp)
f010355b:	f0 
f010355c:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103563:	f0 
f0103564:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f010356b:	00 
f010356c:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103573:	e8 39 cb ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0103578:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010357d:	74 24                	je     f01035a3 <mem_init+0xc56>
f010357f:	c7 44 24 0c df 86 10 	movl   $0xf01086df,0xc(%esp)
f0103586:	f0 
f0103587:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010358e:	f0 
f010358f:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0103596:	00 
f0103597:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010359e:	e8 0e cb ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01035a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01035aa:	00 
f01035ab:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01035b2:	00 
f01035b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035b6:	89 04 24             	mov    %eax,(%esp)
f01035b9:	e8 ba f0 ff ff       	call   f0102678 <pgdir_walk>
f01035be:	f6 00 04             	testb  $0x4,(%eax)
f01035c1:	75 24                	jne    f01035e7 <mem_init+0xc9a>
f01035c3:	c7 44 24 0c 6c 80 10 	movl   $0xf010806c,0xc(%esp)
f01035ca:	f0 
f01035cb:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01035d2:	f0 
f01035d3:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f01035da:	00 
f01035db:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01035e2:	e8 ca ca ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01035e7:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01035ec:	f6 00 04             	testb  $0x4,(%eax)
f01035ef:	75 24                	jne    f0103615 <mem_init+0xcc8>
f01035f1:	c7 44 24 0c f0 86 10 	movl   $0xf01086f0,0xc(%esp)
f01035f8:	f0 
f01035f9:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103600:	f0 
f0103601:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0103608:	00 
f0103609:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103610:	e8 9c ca ff ff       	call   f01000b1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103615:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010361c:	00 
f010361d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103624:	00 
f0103625:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103629:	89 04 24             	mov    %eax,(%esp)
f010362c:	e8 9b f2 ff ff       	call   f01028cc <page_insert>
f0103631:	85 c0                	test   %eax,%eax
f0103633:	74 24                	je     f0103659 <mem_init+0xd0c>
f0103635:	c7 44 24 0c 80 7f 10 	movl   $0xf0107f80,0xc(%esp)
f010363c:	f0 
f010363d:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103644:	f0 
f0103645:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010364c:	00 
f010364d:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103654:	e8 58 ca ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0103659:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103660:	00 
f0103661:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103668:	00 
f0103669:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f010366e:	89 04 24             	mov    %eax,(%esp)
f0103671:	e8 02 f0 ff ff       	call   f0102678 <pgdir_walk>
f0103676:	f6 00 02             	testb  $0x2,(%eax)
f0103679:	75 24                	jne    f010369f <mem_init+0xd52>
f010367b:	c7 44 24 0c a0 80 10 	movl   $0xf01080a0,0xc(%esp)
f0103682:	f0 
f0103683:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010368a:	f0 
f010368b:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0103692:	00 
f0103693:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010369a:	e8 12 ca ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010369f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01036a6:	00 
f01036a7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01036ae:	00 
f01036af:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01036b4:	89 04 24             	mov    %eax,(%esp)
f01036b7:	e8 bc ef ff ff       	call   f0102678 <pgdir_walk>
f01036bc:	f6 00 04             	testb  $0x4,(%eax)
f01036bf:	74 24                	je     f01036e5 <mem_init+0xd98>
f01036c1:	c7 44 24 0c d4 80 10 	movl   $0xf01080d4,0xc(%esp)
f01036c8:	f0 
f01036c9:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01036d0:	f0 
f01036d1:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01036d8:	00 
f01036d9:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01036e0:	e8 cc c9 ff ff       	call   f01000b1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01036e5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01036ec:	00 
f01036ed:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01036f4:	00 
f01036f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01036f9:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01036fe:	89 04 24             	mov    %eax,(%esp)
f0103701:	e8 c6 f1 ff ff       	call   f01028cc <page_insert>
f0103706:	85 c0                	test   %eax,%eax
f0103708:	78 24                	js     f010372e <mem_init+0xde1>
f010370a:	c7 44 24 0c 0c 81 10 	movl   $0xf010810c,0xc(%esp)
f0103711:	f0 
f0103712:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103719:	f0 
f010371a:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0103721:	00 
f0103722:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103729:	e8 83 c9 ff ff       	call   f01000b1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010372e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103735:	00 
f0103736:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010373d:	00 
f010373e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103742:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103747:	89 04 24             	mov    %eax,(%esp)
f010374a:	e8 7d f1 ff ff       	call   f01028cc <page_insert>
f010374f:	85 c0                	test   %eax,%eax
f0103751:	74 24                	je     f0103777 <mem_init+0xe2a>
f0103753:	c7 44 24 0c 44 81 10 	movl   $0xf0108144,0xc(%esp)
f010375a:	f0 
f010375b:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103762:	f0 
f0103763:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f010376a:	00 
f010376b:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103772:	e8 3a c9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103777:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010377e:	00 
f010377f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103786:	00 
f0103787:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f010378c:	89 04 24             	mov    %eax,(%esp)
f010378f:	e8 e4 ee ff ff       	call   f0102678 <pgdir_walk>
f0103794:	f6 00 04             	testb  $0x4,(%eax)
f0103797:	74 24                	je     f01037bd <mem_init+0xe70>
f0103799:	c7 44 24 0c d4 80 10 	movl   $0xf01080d4,0xc(%esp)
f01037a0:	f0 
f01037a1:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01037a8:	f0 
f01037a9:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01037b0:	00 
f01037b1:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01037b8:	e8 f4 c8 ff ff       	call   f01000b1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01037bd:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01037c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01037c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01037ca:	e8 09 e8 ff ff       	call   f0101fd8 <check_va2pa>
f01037cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01037d2:	89 f0                	mov    %esi,%eax
f01037d4:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f01037da:	c1 f8 03             	sar    $0x3,%eax
f01037dd:	c1 e0 0c             	shl    $0xc,%eax
f01037e0:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01037e3:	74 24                	je     f0103809 <mem_init+0xebc>
f01037e5:	c7 44 24 0c 80 81 10 	movl   $0xf0108180,0xc(%esp)
f01037ec:	f0 
f01037ed:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01037f4:	f0 
f01037f5:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f01037fc:	00 
f01037fd:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103804:	e8 a8 c8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103809:	ba 00 10 00 00       	mov    $0x1000,%edx
f010380e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103811:	e8 c2 e7 ff ff       	call   f0101fd8 <check_va2pa>
f0103816:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0103819:	74 24                	je     f010383f <mem_init+0xef2>
f010381b:	c7 44 24 0c ac 81 10 	movl   $0xf01081ac,0xc(%esp)
f0103822:	f0 
f0103823:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010382a:	f0 
f010382b:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0103832:	00 
f0103833:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010383a:	e8 72 c8 ff ff       	call   f01000b1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010383f:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0103844:	74 24                	je     f010386a <mem_init+0xf1d>
f0103846:	c7 44 24 0c 06 87 10 	movl   $0xf0108706,0xc(%esp)
f010384d:	f0 
f010384e:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103855:	f0 
f0103856:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f010385d:	00 
f010385e:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103865:	e8 47 c8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010386a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010386f:	74 24                	je     f0103895 <mem_init+0xf48>
f0103871:	c7 44 24 0c 17 87 10 	movl   $0xf0108717,0xc(%esp)
f0103878:	f0 
f0103879:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103880:	f0 
f0103881:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0103888:	00 
f0103889:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103890:	e8 1c c8 ff ff       	call   f01000b1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0103895:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010389c:	e8 f3 ec ff ff       	call   f0102594 <page_alloc>
f01038a1:	85 c0                	test   %eax,%eax
f01038a3:	74 04                	je     f01038a9 <mem_init+0xf5c>
f01038a5:	39 c3                	cmp    %eax,%ebx
f01038a7:	74 24                	je     f01038cd <mem_init+0xf80>
f01038a9:	c7 44 24 0c dc 81 10 	movl   $0xf01081dc,0xc(%esp)
f01038b0:	f0 
f01038b1:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01038b8:	f0 
f01038b9:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01038c0:	00 
f01038c1:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01038c8:	e8 e4 c7 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01038cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038d4:	00 
f01038d5:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f01038da:	89 04 24             	mov    %eax,(%esp)
f01038dd:	e8 a1 ef ff ff       	call   f0102883 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01038e2:	8b 15 ac bc 20 f0    	mov    0xf020bcac,%edx
f01038e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01038eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01038f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01038f3:	e8 e0 e6 ff ff       	call   f0101fd8 <check_va2pa>
f01038f8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01038fb:	74 24                	je     f0103921 <mem_init+0xfd4>
f01038fd:	c7 44 24 0c 00 82 10 	movl   $0xf0108200,0xc(%esp)
f0103904:	f0 
f0103905:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010390c:	f0 
f010390d:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0103914:	00 
f0103915:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010391c:	e8 90 c7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103921:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103926:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103929:	e8 aa e6 ff ff       	call   f0101fd8 <check_va2pa>
f010392e:	89 f2                	mov    %esi,%edx
f0103930:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f0103936:	c1 fa 03             	sar    $0x3,%edx
f0103939:	c1 e2 0c             	shl    $0xc,%edx
f010393c:	39 d0                	cmp    %edx,%eax
f010393e:	74 24                	je     f0103964 <mem_init+0x1017>
f0103940:	c7 44 24 0c ac 81 10 	movl   $0xf01081ac,0xc(%esp)
f0103947:	f0 
f0103948:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010394f:	f0 
f0103950:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0103957:	00 
f0103958:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010395f:	e8 4d c7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0103964:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103969:	74 24                	je     f010398f <mem_init+0x1042>
f010396b:	c7 44 24 0c bd 86 10 	movl   $0xf01086bd,0xc(%esp)
f0103972:	f0 
f0103973:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010397a:	f0 
f010397b:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0103982:	00 
f0103983:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010398a:	e8 22 c7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010398f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103994:	74 24                	je     f01039ba <mem_init+0x106d>
f0103996:	c7 44 24 0c 17 87 10 	movl   $0xf0108717,0xc(%esp)
f010399d:	f0 
f010399e:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01039a5:	f0 
f01039a6:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f01039ad:	00 
f01039ae:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01039b5:	e8 f7 c6 ff ff       	call   f01000b1 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01039ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01039c1:	00 
f01039c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01039c9:	00 
f01039ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01039ce:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01039d1:	89 0c 24             	mov    %ecx,(%esp)
f01039d4:	e8 f3 ee ff ff       	call   f01028cc <page_insert>
f01039d9:	85 c0                	test   %eax,%eax
f01039db:	74 24                	je     f0103a01 <mem_init+0x10b4>
f01039dd:	c7 44 24 0c 24 82 10 	movl   $0xf0108224,0xc(%esp)
f01039e4:	f0 
f01039e5:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01039ec:	f0 
f01039ed:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f01039f4:	00 
f01039f5:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01039fc:	e8 b0 c6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f0103a01:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103a06:	75 24                	jne    f0103a2c <mem_init+0x10df>
f0103a08:	c7 44 24 0c 28 87 10 	movl   $0xf0108728,0xc(%esp)
f0103a0f:	f0 
f0103a10:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103a17:	f0 
f0103a18:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0103a1f:	00 
f0103a20:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103a27:	e8 85 c6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0103a2c:	83 3e 00             	cmpl   $0x0,(%esi)
f0103a2f:	74 24                	je     f0103a55 <mem_init+0x1108>
f0103a31:	c7 44 24 0c 34 87 10 	movl   $0xf0108734,0xc(%esp)
f0103a38:	f0 
f0103a39:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103a40:	f0 
f0103a41:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0103a48:	00 
f0103a49:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103a50:	e8 5c c6 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103a55:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103a5c:	00 
f0103a5d:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103a62:	89 04 24             	mov    %eax,(%esp)
f0103a65:	e8 19 ee ff ff       	call   f0102883 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103a6a:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103a6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a72:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a77:	e8 5c e5 ff ff       	call   f0101fd8 <check_va2pa>
f0103a7c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103a7f:	74 24                	je     f0103aa5 <mem_init+0x1158>
f0103a81:	c7 44 24 0c 00 82 10 	movl   $0xf0108200,0xc(%esp)
f0103a88:	f0 
f0103a89:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103a90:	f0 
f0103a91:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0103a98:	00 
f0103a99:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103aa0:	e8 0c c6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0103aa5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103aaa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103aad:	e8 26 e5 ff ff       	call   f0101fd8 <check_va2pa>
f0103ab2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103ab5:	74 24                	je     f0103adb <mem_init+0x118e>
f0103ab7:	c7 44 24 0c 5c 82 10 	movl   $0xf010825c,0xc(%esp)
f0103abe:	f0 
f0103abf:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103ac6:	f0 
f0103ac7:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0103ace:	00 
f0103acf:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103ad6:	e8 d6 c5 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0103adb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103ae0:	74 24                	je     f0103b06 <mem_init+0x11b9>
f0103ae2:	c7 44 24 0c 49 87 10 	movl   $0xf0108749,0xc(%esp)
f0103ae9:	f0 
f0103aea:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103af1:	f0 
f0103af2:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0103af9:	00 
f0103afa:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103b01:	e8 ab c5 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0103b06:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103b0b:	74 24                	je     f0103b31 <mem_init+0x11e4>
f0103b0d:	c7 44 24 0c 17 87 10 	movl   $0xf0108717,0xc(%esp)
f0103b14:	f0 
f0103b15:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103b1c:	f0 
f0103b1d:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0103b24:	00 
f0103b25:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103b2c:	e8 80 c5 ff ff       	call   f01000b1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0103b31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b38:	e8 57 ea ff ff       	call   f0102594 <page_alloc>
f0103b3d:	85 c0                	test   %eax,%eax
f0103b3f:	74 04                	je     f0103b45 <mem_init+0x11f8>
f0103b41:	39 c6                	cmp    %eax,%esi
f0103b43:	74 24                	je     f0103b69 <mem_init+0x121c>
f0103b45:	c7 44 24 0c 84 82 10 	movl   $0xf0108284,0xc(%esp)
f0103b4c:	f0 
f0103b4d:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103b54:	f0 
f0103b55:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0103b5c:	00 
f0103b5d:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103b64:	e8 48 c5 ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103b69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b70:	e8 1f ea ff ff       	call   f0102594 <page_alloc>
f0103b75:	85 c0                	test   %eax,%eax
f0103b77:	74 24                	je     f0103b9d <mem_init+0x1250>
f0103b79:	c7 44 24 0c 6b 86 10 	movl   $0xf010866b,0xc(%esp)
f0103b80:	f0 
f0103b81:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103b88:	f0 
f0103b89:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0103b90:	00 
f0103b91:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103b98:	e8 14 c5 ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103b9d:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103ba2:	8b 08                	mov    (%eax),%ecx
f0103ba4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103baa:	89 fa                	mov    %edi,%edx
f0103bac:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f0103bb2:	c1 fa 03             	sar    $0x3,%edx
f0103bb5:	c1 e2 0c             	shl    $0xc,%edx
f0103bb8:	39 d1                	cmp    %edx,%ecx
f0103bba:	74 24                	je     f0103be0 <mem_init+0x1293>
f0103bbc:	c7 44 24 0c 28 7f 10 	movl   $0xf0107f28,0xc(%esp)
f0103bc3:	f0 
f0103bc4:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103bcb:	f0 
f0103bcc:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0103bd3:	00 
f0103bd4:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103bdb:	e8 d1 c4 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f0103be0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103be6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103beb:	74 24                	je     f0103c11 <mem_init+0x12c4>
f0103bed:	c7 44 24 0c ce 86 10 	movl   $0xf01086ce,0xc(%esp)
f0103bf4:	f0 
f0103bf5:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103bfc:	f0 
f0103bfd:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0103c04:	00 
f0103c05:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103c0c:	e8 a0 c4 ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0103c11:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0103c17:	89 3c 24             	mov    %edi,(%esp)
f0103c1a:	e8 f9 e9 ff ff       	call   f0102618 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0103c1f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103c26:	00 
f0103c27:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0103c2e:	00 
f0103c2f:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103c34:	89 04 24             	mov    %eax,(%esp)
f0103c37:	e8 3c ea ff ff       	call   f0102678 <pgdir_walk>
f0103c3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103c3f:	8b 0d ac bc 20 f0    	mov    0xf020bcac,%ecx
f0103c45:	8b 51 04             	mov    0x4(%ecx),%edx
f0103c48:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103c4e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c51:	8b 15 a8 bc 20 f0    	mov    0xf020bca8,%edx
f0103c57:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0103c5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c5d:	c1 ea 0c             	shr    $0xc,%edx
f0103c60:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103c63:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103c66:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0103c69:	72 23                	jb     f0103c8e <mem_init+0x1341>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103c6b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103c6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103c72:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0103c79:	f0 
f0103c7a:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0103c81:	00 
f0103c82:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103c89:	e8 23 c4 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0103c8e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c91:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0103c97:	39 d0                	cmp    %edx,%eax
f0103c99:	74 24                	je     f0103cbf <mem_init+0x1372>
f0103c9b:	c7 44 24 0c 5a 87 10 	movl   $0xf010875a,0xc(%esp)
f0103ca2:	f0 
f0103ca3:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103caa:	f0 
f0103cab:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0103cb2:	00 
f0103cb3:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103cba:	e8 f2 c3 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103cbf:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0103cc6:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103ccc:	89 f8                	mov    %edi,%eax
f0103cce:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f0103cd4:	c1 f8 03             	sar    $0x3,%eax
f0103cd7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103cda:	89 c1                	mov    %eax,%ecx
f0103cdc:	c1 e9 0c             	shr    $0xc,%ecx
f0103cdf:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0103ce2:	77 20                	ja     f0103d04 <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103ce4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ce8:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0103cef:	f0 
f0103cf0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103cf7:	00 
f0103cf8:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0103cff:	e8 ad c3 ff ff       	call   f01000b1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103d04:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103d0b:	00 
f0103d0c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103d13:	00 
	return (void *)(pa + KERNBASE);
f0103d14:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103d19:	89 04 24             	mov    %eax,(%esp)
f0103d1c:	e8 cd 26 00 00       	call   f01063ee <memset>
	page_free(pp0);
f0103d21:	89 3c 24             	mov    %edi,(%esp)
f0103d24:	e8 ef e8 ff ff       	call   f0102618 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103d29:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103d30:	00 
f0103d31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d38:	00 
f0103d39:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103d3e:	89 04 24             	mov    %eax,(%esp)
f0103d41:	e8 32 e9 ff ff       	call   f0102678 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103d46:	89 fa                	mov    %edi,%edx
f0103d48:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f0103d4e:	c1 fa 03             	sar    $0x3,%edx
f0103d51:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d54:	89 d0                	mov    %edx,%eax
f0103d56:	c1 e8 0c             	shr    $0xc,%eax
f0103d59:	3b 05 a8 bc 20 f0    	cmp    0xf020bca8,%eax
f0103d5f:	72 20                	jb     f0103d81 <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103d61:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d65:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0103d6c:	f0 
f0103d6d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103d74:	00 
f0103d75:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0103d7c:	e8 30 c3 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0103d81:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0103d87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103d8a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103d90:	f6 00 01             	testb  $0x1,(%eax)
f0103d93:	74 24                	je     f0103db9 <mem_init+0x146c>
f0103d95:	c7 44 24 0c 72 87 10 	movl   $0xf0108772,0xc(%esp)
f0103d9c:	f0 
f0103d9d:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103da4:	f0 
f0103da5:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0103dac:	00 
f0103dad:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103db4:	e8 f8 c2 ff ff       	call   f01000b1 <_panic>
f0103db9:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0103dbc:	39 d0                	cmp    %edx,%eax
f0103dbe:	75 d0                	jne    f0103d90 <mem_init+0x1443>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103dc0:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103dc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103dcb:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0103dd1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103dd4:	89 0d 08 b0 20 f0    	mov    %ecx,0xf020b008

	// free the pages we took
	page_free(pp0);
f0103dda:	89 3c 24             	mov    %edi,(%esp)
f0103ddd:	e8 36 e8 ff ff       	call   f0102618 <page_free>
	page_free(pp1);
f0103de2:	89 34 24             	mov    %esi,(%esp)
f0103de5:	e8 2e e8 ff ff       	call   f0102618 <page_free>
	page_free(pp2);
f0103dea:	89 1c 24             	mov    %ebx,(%esp)
f0103ded:	e8 26 e8 ff ff       	call   f0102618 <page_free>

	cprintf("check_page() succeeded!\n");
f0103df2:	c7 04 24 89 87 10 f0 	movl   $0xf0108789,(%esp)
f0103df9:	e8 d8 10 00 00       	call   f0104ed6 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f0103dfe:	a1 b0 bc 20 f0       	mov    0xf020bcb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e03:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e08:	77 20                	ja     f0103e2a <mem_init+0x14dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e0e:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0103e15:	f0 
f0103e16:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
f0103e1d:	00 
f0103e1e:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103e25:	e8 87 c2 ff ff       	call   f01000b1 <_panic>
f0103e2a:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0103e31:	00 
	return (physaddr_t)kva - KERNBASE;
f0103e32:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e37:	89 04 24             	mov    %eax,(%esp)
f0103e3a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103e3f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103e44:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103e49:	e8 eb e8 ff ff       	call   f0102739 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U);
f0103e4e:	a1 14 b0 20 f0       	mov    0xf020b014,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e53:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e58:	77 20                	ja     f0103e7a <mem_init+0x152d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e5e:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0103e65:	f0 
f0103e66:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0103e6d:	00 
f0103e6e:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103e75:	e8 37 c2 ff ff       	call   f01000b1 <_panic>
f0103e7a:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0103e81:	00 
	return (physaddr_t)kva - KERNBASE;
f0103e82:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e87:	89 04 24             	mov    %eax,(%esp)
f0103e8a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103e8f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103e94:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103e99:	e8 9b e8 ff ff       	call   f0102739 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e9e:	b8 00 e0 11 f0       	mov    $0xf011e000,%eax
f0103ea3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ea8:	77 20                	ja     f0103eca <mem_init+0x157d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103eaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103eae:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0103eb5:	f0 
f0103eb6:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0103ebd:	00 
f0103ebe:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103ec5:	e8 e7 c1 ff ff       	call   f01000b1 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
   boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f0103eca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103ed1:	00 
f0103ed2:	c7 04 24 00 e0 11 00 	movl   $0x11e000,(%esp)
f0103ed9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103ede:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103ee3:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103ee8:	e8 4c e8 ff ff       	call   f0102739 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	assert(KERNBASE == 0xf0000000); // 0x100000000 - KERNBASE
	boot_map_region(kern_pgdir,KERNBASE,0x10000000,0x0,PTE_W);
f0103eed:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103ef4:	00 
f0103ef5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103efc:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0103f01:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103f06:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0103f0b:	e8 29 e8 ff ff       	call   f0102739 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103f10:	8b 1d ac bc 20 f0    	mov    0xf020bcac,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0103f16:	8b 15 a8 bc 20 f0    	mov    0xf020bca8,%edx
f0103f1c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103f1f:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
f0103f26:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0103f2c:	be 00 00 00 00       	mov    $0x0,%esi
f0103f31:	eb 70                	jmp    f0103fa3 <mem_init+0x1656>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103f33:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103f39:	89 d8                	mov    %ebx,%eax
f0103f3b:	e8 98 e0 ff ff       	call   f0101fd8 <check_va2pa>
f0103f40:	8b 15 b0 bc 20 f0    	mov    0xf020bcb0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f46:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103f4c:	77 20                	ja     f0103f6e <mem_init+0x1621>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f52:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0103f59:	f0 
f0103f5a:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0103f61:	00 
f0103f62:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103f69:	e8 43 c1 ff ff       	call   f01000b1 <_panic>
f0103f6e:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103f75:	39 d0                	cmp    %edx,%eax
f0103f77:	74 24                	je     f0103f9d <mem_init+0x1650>
f0103f79:	c7 44 24 0c a8 82 10 	movl   $0xf01082a8,0xc(%esp)
f0103f80:	f0 
f0103f81:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0103f88:	f0 
f0103f89:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0103f90:	00 
f0103f91:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103f98:	e8 14 c1 ff ff       	call   f01000b1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103f9d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103fa3:	39 f7                	cmp    %esi,%edi
f0103fa5:	77 8c                	ja     f0103f33 <mem_init+0x15e6>
f0103fa7:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103fac:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103fb2:	89 d8                	mov    %ebx,%eax
f0103fb4:	e8 1f e0 ff ff       	call   f0101fd8 <check_va2pa>
f0103fb9:	8b 15 14 b0 20 f0    	mov    0xf020b014,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103fbf:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103fc5:	77 20                	ja     f0103fe7 <mem_init+0x169a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103fc7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103fcb:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0103fd2:	f0 
f0103fd3:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0103fda:	00 
f0103fdb:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0103fe2:	e8 ca c0 ff ff       	call   f01000b1 <_panic>
f0103fe7:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103fee:	39 d0                	cmp    %edx,%eax
f0103ff0:	74 24                	je     f0104016 <mem_init+0x16c9>
f0103ff2:	c7 44 24 0c dc 82 10 	movl   $0xf01082dc,0xc(%esp)
f0103ff9:	f0 
f0103ffa:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104001:	f0 
f0104002:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0104009:	00 
f010400a:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104011:	e8 9b c0 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0104016:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010401c:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0104022:	75 88                	jne    f0103fac <mem_init+0x165f>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0104024:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104027:	c1 e7 0c             	shl    $0xc,%edi
f010402a:	be 00 00 00 00       	mov    $0x0,%esi
f010402f:	eb 3b                	jmp    f010406c <mem_init+0x171f>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104031:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
		#ifdef DEBUG
		cprintf("%x %x\n",i,check_va2pa(pgdir, KERNBASE + i));
		#endif
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0104037:	89 d8                	mov    %ebx,%eax
f0104039:	e8 9a df ff ff       	call   f0101fd8 <check_va2pa>
f010403e:	39 c6                	cmp    %eax,%esi
f0104040:	74 24                	je     f0104066 <mem_init+0x1719>
f0104042:	c7 44 24 0c 10 83 10 	movl   $0xf0108310,0xc(%esp)
f0104049:	f0 
f010404a:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104051:	f0 
f0104052:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0104059:	00 
f010405a:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104061:	e8 4b c0 ff ff       	call   f01000b1 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0104066:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010406c:	39 fe                	cmp    %edi,%esi
f010406e:	72 c1                	jb     f0104031 <mem_init+0x16e4>
f0104070:	be 00 80 ff ef       	mov    $0xefff8000,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104075:	bf 00 e0 11 f0       	mov    $0xf011e000,%edi
f010407a:	81 c7 00 80 00 20    	add    $0x20008000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0104080:	89 f2                	mov    %esi,%edx
f0104082:	89 d8                	mov    %ebx,%eax
f0104084:	e8 4f df ff ff       	call   f0101fd8 <check_va2pa>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0104089:	8d 14 37             	lea    (%edi,%esi,1),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010408c:	39 d0                	cmp    %edx,%eax
f010408e:	74 24                	je     f01040b4 <mem_init+0x1767>
f0104090:	c7 44 24 0c 38 83 10 	movl   $0xf0108338,0xc(%esp)
f0104097:	f0 
f0104098:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010409f:	f0 
f01040a0:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f01040a7:	00 
f01040a8:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01040af:	e8 fd bf ff ff       	call   f01000b1 <_panic>
f01040b4:	81 c6 00 10 00 00    	add    $0x1000,%esi
		#endif
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01040ba:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01040c0:	75 be                	jne    f0104080 <mem_init+0x1733>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01040c2:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01040c7:	89 d8                	mov    %ebx,%eax
f01040c9:	e8 0a df ff ff       	call   f0101fd8 <check_va2pa>
f01040ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01040d1:	74 24                	je     f01040f7 <mem_init+0x17aa>
f01040d3:	c7 44 24 0c 80 83 10 	movl   $0xf0108380,0xc(%esp)
f01040da:	f0 
f01040db:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01040e2:	f0 
f01040e3:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f01040ea:	00 
f01040eb:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01040f2:	e8 ba bf ff ff       	call   f01000b1 <_panic>
f01040f7:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01040fc:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0104101:	72 3c                	jb     f010413f <mem_init+0x17f2>
f0104103:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0104108:	76 07                	jbe    f0104111 <mem_init+0x17c4>
f010410a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010410f:	75 2e                	jne    f010413f <mem_init+0x17f2>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0104111:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0104115:	0f 85 aa 00 00 00    	jne    f01041c5 <mem_init+0x1878>
f010411b:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f0104122:	f0 
f0104123:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010412a:	f0 
f010412b:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0104132:	00 
f0104133:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010413a:	e8 72 bf ff ff       	call   f01000b1 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010413f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0104144:	76 55                	jbe    f010419b <mem_init+0x184e>
				assert(pgdir[i] & PTE_P);
f0104146:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0104149:	f6 c2 01             	test   $0x1,%dl
f010414c:	75 24                	jne    f0104172 <mem_init+0x1825>
f010414e:	c7 44 24 0c a2 87 10 	movl   $0xf01087a2,0xc(%esp)
f0104155:	f0 
f0104156:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010415d:	f0 
f010415e:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0104165:	00 
f0104166:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010416d:	e8 3f bf ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_W);
f0104172:	f6 c2 02             	test   $0x2,%dl
f0104175:	75 4e                	jne    f01041c5 <mem_init+0x1878>
f0104177:	c7 44 24 0c b3 87 10 	movl   $0xf01087b3,0xc(%esp)
f010417e:	f0 
f010417f:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104186:	f0 
f0104187:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f010418e:	00 
f010418f:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104196:	e8 16 bf ff ff       	call   f01000b1 <_panic>
			} else
				assert(pgdir[i] == 0);
f010419b:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010419f:	74 24                	je     f01041c5 <mem_init+0x1878>
f01041a1:	c7 44 24 0c c4 87 10 	movl   $0xf01087c4,0xc(%esp)
f01041a8:	f0 
f01041a9:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01041b0:	f0 
f01041b1:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01041b8:	00 
f01041b9:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01041c0:	e8 ec be ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01041c5:	40                   	inc    %eax
f01041c6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01041cb:	0f 85 2b ff ff ff    	jne    f01040fc <mem_init+0x17af>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01041d1:	c7 04 24 b0 83 10 f0 	movl   $0xf01083b0,(%esp)
f01041d8:	e8 f9 0c 00 00       	call   f0104ed6 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01041dd:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01041e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01041e7:	77 20                	ja     f0104209 <mem_init+0x18bc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01041e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041ed:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f01041f4:	f0 
f01041f5:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f01041fc:	00 
f01041fd:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104204:	e8 a8 be ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104209:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010420e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0104211:	b8 00 00 00 00       	mov    $0x0,%eax
f0104216:	e8 eb de ff ff       	call   f0102106 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010421b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010421e:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0104223:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0104226:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0104229:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104230:	e8 5f e3 ff ff       	call   f0102594 <page_alloc>
f0104235:	89 c6                	mov    %eax,%esi
f0104237:	85 c0                	test   %eax,%eax
f0104239:	75 24                	jne    f010425f <mem_init+0x1912>
f010423b:	c7 44 24 0c c0 85 10 	movl   $0xf01085c0,0xc(%esp)
f0104242:	f0 
f0104243:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010424a:	f0 
f010424b:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0104252:	00 
f0104253:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010425a:	e8 52 be ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010425f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104266:	e8 29 e3 ff ff       	call   f0102594 <page_alloc>
f010426b:	89 c7                	mov    %eax,%edi
f010426d:	85 c0                	test   %eax,%eax
f010426f:	75 24                	jne    f0104295 <mem_init+0x1948>
f0104271:	c7 44 24 0c d6 85 10 	movl   $0xf01085d6,0xc(%esp)
f0104278:	f0 
f0104279:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104280:	f0 
f0104281:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0104288:	00 
f0104289:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104290:	e8 1c be ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0104295:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010429c:	e8 f3 e2 ff ff       	call   f0102594 <page_alloc>
f01042a1:	89 c3                	mov    %eax,%ebx
f01042a3:	85 c0                	test   %eax,%eax
f01042a5:	75 24                	jne    f01042cb <mem_init+0x197e>
f01042a7:	c7 44 24 0c ec 85 10 	movl   $0xf01085ec,0xc(%esp)
f01042ae:	f0 
f01042af:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01042b6:	f0 
f01042b7:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f01042be:	00 
f01042bf:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01042c6:	e8 e6 bd ff ff       	call   f01000b1 <_panic>
	page_free(pp0);
f01042cb:	89 34 24             	mov    %esi,(%esp)
f01042ce:	e8 45 e3 ff ff       	call   f0102618 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01042d3:	89 f8                	mov    %edi,%eax
f01042d5:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f01042db:	c1 f8 03             	sar    $0x3,%eax
f01042de:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01042e1:	89 c2                	mov    %eax,%edx
f01042e3:	c1 ea 0c             	shr    $0xc,%edx
f01042e6:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f01042ec:	72 20                	jb     f010430e <mem_init+0x19c1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01042ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042f2:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f01042f9:	f0 
f01042fa:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0104301:	00 
f0104302:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0104309:	e8 a3 bd ff ff       	call   f01000b1 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010430e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104315:	00 
f0104316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010431d:	00 
	return (void *)(pa + KERNBASE);
f010431e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0104323:	89 04 24             	mov    %eax,(%esp)
f0104326:	e8 c3 20 00 00       	call   f01063ee <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010432b:	89 d8                	mov    %ebx,%eax
f010432d:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f0104333:	c1 f8 03             	sar    $0x3,%eax
f0104336:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104339:	89 c2                	mov    %eax,%edx
f010433b:	c1 ea 0c             	shr    $0xc,%edx
f010433e:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f0104344:	72 20                	jb     f0104366 <mem_init+0x1a19>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104346:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010434a:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0104351:	f0 
f0104352:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0104359:	00 
f010435a:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0104361:	e8 4b bd ff ff       	call   f01000b1 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0104366:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010436d:	00 
f010436e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0104375:	00 
	return (void *)(pa + KERNBASE);
f0104376:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010437b:	89 04 24             	mov    %eax,(%esp)
f010437e:	e8 6b 20 00 00       	call   f01063ee <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0104383:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010438a:	00 
f010438b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104392:	00 
f0104393:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104397:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f010439c:	89 04 24             	mov    %eax,(%esp)
f010439f:	e8 28 e5 ff ff       	call   f01028cc <page_insert>
	assert(pp1->pp_ref == 1);
f01043a4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01043a9:	74 24                	je     f01043cf <mem_init+0x1a82>
f01043ab:	c7 44 24 0c bd 86 10 	movl   $0xf01086bd,0xc(%esp)
f01043b2:	f0 
f01043b3:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01043ba:	f0 
f01043bb:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01043c2:	00 
f01043c3:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01043ca:	e8 e2 bc ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01043cf:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01043d6:	01 01 01 
f01043d9:	74 24                	je     f01043ff <mem_init+0x1ab2>
f01043db:	c7 44 24 0c d0 83 10 	movl   $0xf01083d0,0xc(%esp)
f01043e2:	f0 
f01043e3:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01043ea:	f0 
f01043eb:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f01043f2:	00 
f01043f3:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01043fa:	e8 b2 bc ff ff       	call   f01000b1 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01043ff:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104406:	00 
f0104407:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010440e:	00 
f010440f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104413:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0104418:	89 04 24             	mov    %eax,(%esp)
f010441b:	e8 ac e4 ff ff       	call   f01028cc <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0104420:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0104427:	02 02 02 
f010442a:	74 24                	je     f0104450 <mem_init+0x1b03>
f010442c:	c7 44 24 0c f4 83 10 	movl   $0xf01083f4,0xc(%esp)
f0104433:	f0 
f0104434:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f010443b:	f0 
f010443c:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0104443:	00 
f0104444:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f010444b:	e8 61 bc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0104450:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0104455:	74 24                	je     f010447b <mem_init+0x1b2e>
f0104457:	c7 44 24 0c df 86 10 	movl   $0xf01086df,0xc(%esp)
f010445e:	f0 
f010445f:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104466:	f0 
f0104467:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f010446e:	00 
f010446f:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104476:	e8 36 bc ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f010447b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0104480:	74 24                	je     f01044a6 <mem_init+0x1b59>
f0104482:	c7 44 24 0c 49 87 10 	movl   $0xf0108749,0xc(%esp)
f0104489:	f0 
f010448a:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104491:	f0 
f0104492:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0104499:	00 
f010449a:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01044a1:	e8 0b bc ff ff       	call   f01000b1 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01044a6:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01044ad:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01044b0:	89 d8                	mov    %ebx,%eax
f01044b2:	2b 05 b0 bc 20 f0    	sub    0xf020bcb0,%eax
f01044b8:	c1 f8 03             	sar    $0x3,%eax
f01044bb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01044be:	89 c2                	mov    %eax,%edx
f01044c0:	c1 ea 0c             	shr    $0xc,%edx
f01044c3:	3b 15 a8 bc 20 f0    	cmp    0xf020bca8,%edx
f01044c9:	72 20                	jb     f01044eb <mem_init+0x1b9e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01044cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01044cf:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f01044d6:	f0 
f01044d7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01044de:	00 
f01044df:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f01044e6:	e8 c6 bb ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01044eb:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01044f2:	03 03 03 
f01044f5:	74 24                	je     f010451b <mem_init+0x1bce>
f01044f7:	c7 44 24 0c 18 84 10 	movl   $0xf0108418,0xc(%esp)
f01044fe:	f0 
f01044ff:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104506:	f0 
f0104507:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f010450e:	00 
f010450f:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104516:	e8 96 bb ff ff       	call   f01000b1 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010451b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0104522:	00 
f0104523:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0104528:	89 04 24             	mov    %eax,(%esp)
f010452b:	e8 53 e3 ff ff       	call   f0102883 <page_remove>
	assert(pp2->pp_ref == 0);
f0104530:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0104535:	74 24                	je     f010455b <mem_init+0x1c0e>
f0104537:	c7 44 24 0c 17 87 10 	movl   $0xf0108717,0xc(%esp)
f010453e:	f0 
f010453f:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104546:	f0 
f0104547:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f010454e:	00 
f010454f:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104556:	e8 56 bb ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010455b:	a1 ac bc 20 f0       	mov    0xf020bcac,%eax
f0104560:	8b 08                	mov    (%eax),%ecx
f0104562:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0104568:	89 f2                	mov    %esi,%edx
f010456a:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f0104570:	c1 fa 03             	sar    $0x3,%edx
f0104573:	c1 e2 0c             	shl    $0xc,%edx
f0104576:	39 d1                	cmp    %edx,%ecx
f0104578:	74 24                	je     f010459e <mem_init+0x1c51>
f010457a:	c7 44 24 0c 28 7f 10 	movl   $0xf0107f28,0xc(%esp)
f0104581:	f0 
f0104582:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104589:	f0 
f010458a:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0104591:	00 
f0104592:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f0104599:	e8 13 bb ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f010459e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01045a4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01045a9:	74 24                	je     f01045cf <mem_init+0x1c82>
f01045ab:	c7 44 24 0c ce 86 10 	movl   $0xf01086ce,0xc(%esp)
f01045b2:	f0 
f01045b3:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01045ba:	f0 
f01045bb:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01045c2:	00 
f01045c3:	c7 04 24 a5 84 10 f0 	movl   $0xf01084a5,(%esp)
f01045ca:	e8 e2 ba ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f01045cf:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01045d5:	89 34 24             	mov    %esi,(%esp)
f01045d8:	e8 3b e0 ff ff       	call   f0102618 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01045dd:	c7 04 24 44 84 10 f0 	movl   $0xf0108444,(%esp)
f01045e4:	e8 ed 08 00 00       	call   f0104ed6 <cprintf>
	// 	cprintf("%x %x %x\n",i,&kern_pgdir[i],KADDR(PTE_ADDR(kern_pgdir[i])));

	// pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	// cprintf("%x\n",*(int*)0x00400000);
	// cprintf("pages: %x\n",pages);
}
f01045e9:	83 c4 3c             	add    $0x3c,%esp
f01045ec:	5b                   	pop    %ebx
f01045ed:	5e                   	pop    %esi
f01045ee:	5f                   	pop    %edi
f01045ef:	5d                   	pop    %ebp
f01045f0:	c3                   	ret    

f01045f1 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01045f1:	55                   	push   %ebp
f01045f2:	89 e5                	mov    %esp,%ebp
f01045f4:	57                   	push   %edi
f01045f5:	56                   	push   %esi
f01045f6:	53                   	push   %ebx
f01045f7:	83 ec 2c             	sub    $0x2c,%esp
f01045fa:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t start = (uintptr_t)ROUNDDOWN(va,PGSIZE);
f01045fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104600:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t end = (uintptr_t)ROUNDUP(va+len,PGSIZE);
f0104606:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104609:	03 45 10             	add    0x10(%ebp),%eax
f010460c:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104611:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	perm |= PTE_P;
f0104619:	8b 7d 14             	mov    0x14(%ebp),%edi
f010461c:	83 cf 01             	or     $0x1,%edi

	for (uintptr_t address = start; address < end; address+= PGSIZE){
f010461f:	eb 59                	jmp    f010467a <user_mem_check+0x89>
		if (address >= ULIM){
f0104621:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0104627:	76 16                	jbe    f010463f <user_mem_check+0x4e>
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
f0104629:	89 d8                	mov    %ebx,%eax
f010462b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010462e:	73 03                	jae    f0104633 <user_mem_check+0x42>
f0104630:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104633:	a3 0c b0 20 f0       	mov    %eax,0xf020b00c
			return -E_FAULT;
f0104638:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010463d:	eb 45                	jmp    f0104684 <user_mem_check+0x93>
		}
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)address, 0);
f010463f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104646:	00 
f0104647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010464b:	8b 46 5c             	mov    0x5c(%esi),%eax
f010464e:	89 04 24             	mov    %eax,(%esp)
f0104651:	e8 22 e0 ff ff       	call   f0102678 <pgdir_walk>
		if ((*pte & perm) != perm){
f0104656:	8b 00                	mov    (%eax),%eax
f0104658:	21 f8                	and    %edi,%eax
f010465a:	39 c7                	cmp    %eax,%edi
f010465c:	74 16                	je     f0104674 <user_mem_check+0x83>
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
f010465e:	89 d8                	mov    %ebx,%eax
f0104660:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0104663:	73 03                	jae    f0104668 <user_mem_check+0x77>
f0104665:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104668:	a3 0c b0 20 f0       	mov    %eax,0xf020b00c
			return -E_FAULT;
f010466d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0104672:	eb 10                	jmp    f0104684 <user_mem_check+0x93>
	// LAB 3: Your code here.
	uintptr_t start = (uintptr_t)ROUNDDOWN(va,PGSIZE);
	uintptr_t end = (uintptr_t)ROUNDUP(va+len,PGSIZE);
	perm |= PTE_P;

	for (uintptr_t address = start; address < end; address+= PGSIZE){
f0104674:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010467a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010467d:	72 a2                	jb     f0104621 <user_mem_check+0x30>
		if ((*pte & perm) != perm){
			user_mem_check_addr = (address>(uintptr_t)va)?address:(uintptr_t)va;
			return -E_FAULT;
		}
	}
	return 0;
f010467f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104684:	83 c4 2c             	add    $0x2c,%esp
f0104687:	5b                   	pop    %ebx
f0104688:	5e                   	pop    %esi
f0104689:	5f                   	pop    %edi
f010468a:	5d                   	pop    %ebp
f010468b:	c3                   	ret    

f010468c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010468c:	55                   	push   %ebp
f010468d:	89 e5                	mov    %esp,%ebp
f010468f:	53                   	push   %ebx
f0104690:	83 ec 14             	sub    $0x14,%esp
f0104693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0104696:	8b 45 14             	mov    0x14(%ebp),%eax
f0104699:	83 c8 04             	or     $0x4,%eax
f010469c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01046a0:	8b 45 10             	mov    0x10(%ebp),%eax
f01046a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ae:	89 1c 24             	mov    %ebx,(%esp)
f01046b1:	e8 3b ff ff ff       	call   f01045f1 <user_mem_check>
f01046b6:	85 c0                	test   %eax,%eax
f01046b8:	79 24                	jns    f01046de <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01046ba:	a1 0c b0 20 f0       	mov    0xf020b00c,%eax
f01046bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046c3:	8b 43 48             	mov    0x48(%ebx),%eax
f01046c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ca:	c7 04 24 70 84 10 f0 	movl   $0xf0108470,(%esp)
f01046d1:	e8 00 08 00 00       	call   f0104ed6 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01046d6:	89 1c 24             	mov    %ebx,(%esp)
f01046d9:	e8 c7 06 00 00       	call   f0104da5 <env_destroy>
	}
}
f01046de:	83 c4 14             	add    $0x14,%esp
f01046e1:	5b                   	pop    %ebx
f01046e2:	5d                   	pop    %ebp
f01046e3:	c3                   	ret    

f01046e4 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01046e4:	55                   	push   %ebp
f01046e5:	89 e5                	mov    %esp,%ebp
f01046e7:	57                   	push   %edi
f01046e8:	56                   	push   %esi
f01046e9:	53                   	push   %ebx
f01046ea:	83 ec 1c             	sub    $0x1c,%esp
f01046ed:	89 c6                	mov    %eax,%esi
	// LAB 3: Your code here.
	void *start = ROUNDDOWN(va,PGSIZE);
	void *end =ROUNDUP(va+len,PGSIZE);
f01046ef:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01046f6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (void *address = start; address < end; address += PGSIZE){
f01046fc:	89 d3                	mov    %edx,%ebx
f01046fe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0104704:	eb 6d                	jmp    f0104773 <region_alloc+0x8f>
		struct PageInfo *page = page_alloc(0);
f0104706:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010470d:	e8 82 de ff ff       	call   f0102594 <page_alloc>
		if (page == NULL)panic("region_alloc: page_alloc failed!");
f0104712:	85 c0                	test   %eax,%eax
f0104714:	75 1c                	jne    f0104732 <region_alloc+0x4e>
f0104716:	c7 44 24 08 d4 87 10 	movl   $0xf01087d4,0x8(%esp)
f010471d:	f0 
f010471e:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f0104725:	00 
f0104726:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f010472d:	e8 7f b9 ff ff       	call   f01000b1 <_panic>
		if (page_insert(e->env_pgdir,page,address,PTE_W|PTE_U))
f0104732:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104739:	00 
f010473a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010473e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104742:	8b 46 5c             	mov    0x5c(%esi),%eax
f0104745:	89 04 24             	mov    %eax,(%esp)
f0104748:	e8 7f e1 ff ff       	call   f01028cc <page_insert>
f010474d:	85 c0                	test   %eax,%eax
f010474f:	74 1c                	je     f010476d <region_alloc+0x89>
			panic("region_alloc: page_insert failed!");
f0104751:	c7 44 24 08 f8 87 10 	movl   $0xf01087f8,0x8(%esp)
f0104758:	f0 
f0104759:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f0104760:	00 
f0104761:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104768:	e8 44 b9 ff ff       	call   f01000b1 <_panic>
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *start = ROUNDDOWN(va,PGSIZE);
	void *end =ROUNDUP(va+len,PGSIZE);
	for (void *address = start; address < end; address += PGSIZE){
f010476d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104773:	39 fb                	cmp    %edi,%ebx
f0104775:	72 8f                	jb     f0104706 <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0104777:	83 c4 1c             	add    $0x1c,%esp
f010477a:	5b                   	pop    %ebx
f010477b:	5e                   	pop    %esi
f010477c:	5f                   	pop    %edi
f010477d:	5d                   	pop    %ebp
f010477e:	c3                   	ret    

f010477f <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010477f:	55                   	push   %ebp
f0104780:	89 e5                	mov    %esp,%ebp
f0104782:	53                   	push   %ebx
f0104783:	8b 45 08             	mov    0x8(%ebp),%eax
f0104786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104789:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010478c:	85 c0                	test   %eax,%eax
f010478e:	75 0e                	jne    f010479e <envid2env+0x1f>
		*env_store = curenv;
f0104790:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f0104795:	89 01                	mov    %eax,(%ecx)
		return 0;
f0104797:	b8 00 00 00 00       	mov    $0x0,%eax
f010479c:	eb 55                	jmp    f01047f3 <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010479e:	89 c2                	mov    %eax,%edx
f01047a0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01047a6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01047a9:	c1 e2 05             	shl    $0x5,%edx
f01047ac:	03 15 14 b0 20 f0    	add    0xf020b014,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01047b2:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01047b6:	74 05                	je     f01047bd <envid2env+0x3e>
f01047b8:	39 42 48             	cmp    %eax,0x48(%edx)
f01047bb:	74 0d                	je     f01047ca <envid2env+0x4b>
		*env_store = 0;
f01047bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01047c3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01047c8:	eb 29                	jmp    f01047f3 <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01047ca:	84 db                	test   %bl,%bl
f01047cc:	74 1e                	je     f01047ec <envid2env+0x6d>
f01047ce:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f01047d3:	39 c2                	cmp    %eax,%edx
f01047d5:	74 15                	je     f01047ec <envid2env+0x6d>
f01047d7:	8b 58 48             	mov    0x48(%eax),%ebx
f01047da:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f01047dd:	74 0d                	je     f01047ec <envid2env+0x6d>
		*env_store = 0;
f01047df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01047e5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01047ea:	eb 07                	jmp    f01047f3 <envid2env+0x74>
	}

	*env_store = e;
f01047ec:	89 11                	mov    %edx,(%ecx)
	return 0;
f01047ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047f3:	5b                   	pop    %ebx
f01047f4:	5d                   	pop    %ebp
f01047f5:	c3                   	ret    

f01047f6 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01047f6:	55                   	push   %ebp
f01047f7:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01047f9:	b8 60 91 14 f0       	mov    $0xf0149160,%eax
f01047fe:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0104801:	b8 23 00 00 00       	mov    $0x23,%eax
f0104806:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0104808:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010480a:	b0 10                	mov    $0x10,%al
f010480c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010480e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0104810:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0104812:	ea 19 48 10 f0 08 00 	ljmp   $0x8,$0xf0104819
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0104819:	b0 00                	mov    $0x0,%al
f010481b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010481e:	5d                   	pop    %ebp
f010481f:	c3                   	ret    

f0104820 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0104820:	55                   	push   %ebp
f0104821:	89 e5                	mov    %esp,%ebp
f0104823:	56                   	push   %esi
f0104824:	53                   	push   %ebx
f0104825:	83 ec 10             	sub    $0x10,%esp
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
f0104828:	83 3d 18 b0 20 f0 00 	cmpl   $0x0,0xf020b018
f010482f:	74 24                	je     f0104855 <env_init+0x35>
f0104831:	c7 44 24 0c 89 88 10 	movl   $0xf0108889,0xc(%esp)
f0104838:	f0 
f0104839:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104840:	f0 
f0104841:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f0104848:	00 
f0104849:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104850:	e8 5c b8 ff ff       	call   f01000b1 <_panic>
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
f0104855:	8b 35 14 b0 20 f0    	mov    0xf020b014,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010485b:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0104861:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104866:	ba ff 03 00 00       	mov    $0x3ff,%edx
f010486b:	eb 02                	jmp    f010486f <env_init+0x4f>
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f010486d:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
		envs[i].env_id = 0;
f010486f:	89 c3                	mov    %eax,%ebx
f0104871:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0104878:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f010487f:	89 48 44             	mov    %ecx,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	assert(env_free_list == NULL);
	for (int i = NENV - 1 ; i>=0; i--){
f0104882:	4a                   	dec    %edx
f0104883:	83 e8 60             	sub    $0x60,%eax
f0104886:	83 fa ff             	cmp    $0xffffffff,%edx
f0104889:	75 e2                	jne    f010486d <env_init+0x4d>
f010488b:	89 35 18 b0 20 f0    	mov    %esi,0xf020b018
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0104891:	e8 60 ff ff ff       	call   f01047f6 <env_init_percpu>
}
f0104896:	83 c4 10             	add    $0x10,%esp
f0104899:	5b                   	pop    %ebx
f010489a:	5e                   	pop    %esi
f010489b:	5d                   	pop    %ebp
f010489c:	c3                   	ret    

f010489d <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010489d:	55                   	push   %ebp
f010489e:	89 e5                	mov    %esp,%ebp
f01048a0:	56                   	push   %esi
f01048a1:	53                   	push   %ebx
f01048a2:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01048a5:	8b 1d 18 b0 20 f0    	mov    0xf020b018,%ebx
f01048ab:	85 db                	test   %ebx,%ebx
f01048ad:	0f 84 a1 01 00 00    	je     f0104a54 <env_alloc+0x1b7>
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01048b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01048ba:	e8 d5 dc ff ff       	call   f0102594 <page_alloc>
f01048bf:	85 c0                	test   %eax,%eax
f01048c1:	0f 84 94 01 00 00    	je     f0104a5b <env_alloc+0x1be>
f01048c7:	89 c2                	mov    %eax,%edx
f01048c9:	2b 15 b0 bc 20 f0    	sub    0xf020bcb0,%edx
f01048cf:	c1 fa 03             	sar    $0x3,%edx
f01048d2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01048d5:	89 d1                	mov    %edx,%ecx
f01048d7:	c1 e9 0c             	shr    $0xc,%ecx
f01048da:	3b 0d a8 bc 20 f0    	cmp    0xf020bca8,%ecx
f01048e0:	72 20                	jb     f0104902 <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01048e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01048e6:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f01048ed:	f0 
f01048ee:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01048f5:	00 
f01048f6:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f01048fd:	e8 af b7 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0104902:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0104908:	89 53 5c             	mov    %edx,0x5c(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t*)page2kva(p);
	p->pp_ref++;
f010490b:	66 ff 40 04          	incw   0x4(%eax)

	for (int i = 0; i < PDX(UTOP); i++){
f010490f:	ba 00 00 00 00       	mov    $0x0,%edx
f0104914:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = 0;
f0104919:	8b 4b 5c             	mov    0x5c(%ebx),%ecx
f010491c:	c7 04 91 00 00 00 00 	movl   $0x0,(%ecx,%edx,4)

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t*)page2kva(p);
	p->pp_ref++;

	for (int i = 0; i < PDX(UTOP); i++){
f0104923:	40                   	inc    %eax
f0104924:	89 c2                	mov    %eax,%edx
f0104926:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010492b:	75 ec                	jne    f0104919 <env_alloc+0x7c>
f010492d:	66 b8 ec 0e          	mov    $0xeec,%ax
		e->env_pgdir[i] = 0;
	}

	for (int i = PDX(UTOP); i < NPDENTRIES; i++){
		e->env_pgdir[i] = kern_pgdir[i];
f0104931:	8b 15 ac bc 20 f0    	mov    0xf020bcac,%edx
f0104937:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010493a:	8b 53 5c             	mov    0x5c(%ebx),%edx
f010493d:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0104940:	83 c0 04             	add    $0x4,%eax

	for (int i = 0; i < PDX(UTOP); i++){
		e->env_pgdir[i] = 0;
	}

	for (int i = PDX(UTOP); i < NPDENTRIES; i++){
f0104943:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0104948:	75 e7                	jne    f0104931 <env_alloc+0x94>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010494a:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010494d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104952:	77 20                	ja     f0104974 <env_alloc+0xd7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104954:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104958:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f010495f:	f0 
f0104960:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
f0104967:	00 
f0104968:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f010496f:	e8 3d b7 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104974:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010497a:	83 ca 05             	or     $0x5,%edx
f010497d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0104983:	8b 43 48             	mov    0x48(%ebx),%eax
f0104986:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010498b:	89 c1                	mov    %eax,%ecx
f010498d:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0104993:	7f 05                	jg     f010499a <env_alloc+0xfd>
		generation = 1 << ENVGENSHIFT;
f0104995:	b9 00 10 00 00       	mov    $0x1000,%ecx
	
	e->env_id = generation | (e - envs);
f010499a:	89 d8                	mov    %ebx,%eax
f010499c:	2b 05 14 b0 20 f0    	sub    0xf020b014,%eax
f01049a2:	c1 f8 05             	sar    $0x5,%eax
f01049a5:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01049a8:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01049ab:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01049ae:	89 d6                	mov    %edx,%esi
f01049b0:	c1 e6 08             	shl    $0x8,%esi
f01049b3:	01 f2                	add    %esi,%edx
f01049b5:	89 d6                	mov    %edx,%esi
f01049b7:	c1 e6 10             	shl    $0x10,%esi
f01049ba:	01 f2                	add    %esi,%edx
f01049bc:	8d 04 50             	lea    (%eax,%edx,2),%eax
f01049bf:	09 c1                	or     %eax,%ecx
f01049c1:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01049c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049c7:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01049ca:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01049d1:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01049d8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01049df:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01049e6:	00 
f01049e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01049ee:	00 
f01049ef:	89 1c 24             	mov    %ebx,(%esp)
f01049f2:	e8 f7 19 00 00       	call   f01063ee <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01049f7:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01049fd:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0104a03:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0104a09:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0104a10:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0104a16:	8b 43 44             	mov    0x44(%ebx),%eax
f0104a19:	a3 18 b0 20 f0       	mov    %eax,0xf020b018
	*newenv_store = e;
f0104a1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a21:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0104a23:	8b 53 48             	mov    0x48(%ebx),%edx
f0104a26:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f0104a2b:	85 c0                	test   %eax,%eax
f0104a2d:	74 05                	je     f0104a34 <env_alloc+0x197>
f0104a2f:	8b 40 48             	mov    0x48(%eax),%eax
f0104a32:	eb 05                	jmp    f0104a39 <env_alloc+0x19c>
f0104a34:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a39:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a41:	c7 04 24 9f 88 10 f0 	movl   $0xf010889f,(%esp)
f0104a48:	e8 89 04 00 00       	call   f0104ed6 <cprintf>
	return 0;
f0104a4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a52:	eb 0c                	jmp    f0104a60 <env_alloc+0x1c3>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0104a54:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0104a59:	eb 05                	jmp    f0104a60 <env_alloc+0x1c3>
{
	int i;
	struct PageInfo *p = NULL;
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0104a5b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0104a60:	83 c4 10             	add    $0x10,%esp
f0104a63:	5b                   	pop    %ebx
f0104a64:	5e                   	pop    %esi
f0104a65:	5d                   	pop    %ebp
f0104a66:	c3                   	ret    

f0104a67 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0104a67:	55                   	push   %ebp
f0104a68:	89 e5                	mov    %esp,%ebp
f0104a6a:	57                   	push   %edi
f0104a6b:	56                   	push   %esi
f0104a6c:	53                   	push   %ebx
f0104a6d:	83 ec 3c             	sub    $0x3c,%esp
f0104a70:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	assert(env_alloc(&e,0) == 0);
f0104a73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104a7a:	00 
f0104a7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a7e:	89 04 24             	mov    %eax,(%esp)
f0104a81:	e8 17 fe ff ff       	call   f010489d <env_alloc>
f0104a86:	85 c0                	test   %eax,%eax
f0104a88:	74 24                	je     f0104aae <env_create+0x47>
f0104a8a:	c7 44 24 0c b4 88 10 	movl   $0xf01088b4,0xc(%esp)
f0104a91:	f0 
f0104a92:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104a99:	f0 
f0104a9a:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
f0104aa1:	00 
f0104aa2:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104aa9:	e8 03 b6 ff ff       	call   f01000b1 <_panic>
	load_icode(e,binary);
f0104aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ab1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.

	struct Elf *ELFHDR = (struct Elf *)binary;
	if (ELFHDR->e_magic != ELF_MAGIC)
f0104ab4:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0104aba:	74 1c                	je     f0104ad8 <env_create+0x71>
		panic("load_icode: ELFHDR->e_magic != ELF_MAGIC\n");
f0104abc:	c7 44 24 08 1c 88 10 	movl   $0xf010881c,0x8(%esp)
f0104ac3:	f0 
f0104ac4:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0104acb:	00 
f0104acc:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104ad3:	e8 d9 b5 ff ff       	call   f01000b1 <_panic>
	
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0104ad8:	8b 47 18             	mov    0x18(%edi),%eax
f0104adb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104ade:	89 42 30             	mov    %eax,0x30(%edx)
	lcr3(PADDR(e->env_pgdir));
f0104ae1:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104ae4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104ae9:	77 20                	ja     f0104b0b <env_create+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104aef:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0104af6:	f0 
f0104af7:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0104afe:	00 
f0104aff:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104b06:	e8 a6 b5 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104b0b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104b10:	0f 22 d8             	mov    %eax,%cr3

	struct Proghdr *ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
f0104b13:	89 fb                	mov    %edi,%ebx
f0104b15:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr *eph = ph + ELFHDR->e_phnum;
f0104b18:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0104b1c:	c1 e6 05             	shl    $0x5,%esi
f0104b1f:	01 de                	add    %ebx,%esi
f0104b21:	eb 74                	jmp    f0104b97 <env_create+0x130>
    for (; ph < eph; ph++){
		#ifdef DEBUG
			cprintf("memory size: %x\nfile size: %x\nvirtual address: %x\noffset: %x\n\n",ph->p_memsz,ph->p_filesz,ph->p_va,ph->p_offset);
		#endif
		if (ph->p_type == ELF_PROG_LOAD){
f0104b23:	83 3b 01             	cmpl   $0x1,(%ebx)
f0104b26:	75 6c                	jne    f0104b94 <env_create+0x12d>
			assert(ph->p_memsz >= ph->p_filesz);
f0104b28:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0104b2b:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f0104b2e:	73 24                	jae    f0104b54 <env_create+0xed>
f0104b30:	c7 44 24 0c c9 88 10 	movl   $0xf01088c9,0xc(%esp)
f0104b37:	f0 
f0104b38:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0104b3f:	f0 
f0104b40:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0104b47:	00 
f0104b48:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104b4f:	e8 5d b5 ff ff       	call   f01000b1 <_panic>
			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f0104b54:	8b 53 08             	mov    0x8(%ebx),%edx
f0104b57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104b5a:	e8 85 fb ff ff       	call   f01046e4 <region_alloc>
            memset((void *)ph->p_va, 0, ph->p_memsz);
f0104b5f:	8b 43 14             	mov    0x14(%ebx),%eax
f0104b62:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104b6d:	00 
f0104b6e:	8b 43 08             	mov    0x8(%ebx),%eax
f0104b71:	89 04 24             	mov    %eax,(%esp)
f0104b74:	e8 75 18 00 00       	call   f01063ee <memset>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0104b79:	8b 43 10             	mov    0x10(%ebx),%eax
f0104b7c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b80:	89 f8                	mov    %edi,%eax
f0104b82:	03 43 04             	add    0x4(%ebx),%eax
f0104b85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b89:	8b 43 08             	mov    0x8(%ebx),%eax
f0104b8c:	89 04 24             	mov    %eax,(%esp)
f0104b8f:	e8 0e 19 00 00       	call   f01064a2 <memcpy>
	e->env_tf.tf_eip = ELFHDR->e_entry;
	lcr3(PADDR(e->env_pgdir));

	struct Proghdr *ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
	struct Proghdr *eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph++){
f0104b94:	83 c3 20             	add    $0x20,%ebx
f0104b97:	39 de                	cmp    %ebx,%esi
f0104b99:	77 88                	ja     f0104b23 <env_create+0xbc>

    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f0104b9b:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0104ba0:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104ba5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104ba8:	e8 37 fb ff ff       	call   f01046e4 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *e;
	assert(env_alloc(&e,0) == 0);
	load_icode(e,binary);
	e->env_type = type;
f0104bad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bb3:	89 50 50             	mov    %edx,0x50(%eax)
}
f0104bb6:	83 c4 3c             	add    $0x3c,%esp
f0104bb9:	5b                   	pop    %ebx
f0104bba:	5e                   	pop    %esi
f0104bbb:	5f                   	pop    %edi
f0104bbc:	5d                   	pop    %ebp
f0104bbd:	c3                   	ret    

f0104bbe <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0104bbe:	55                   	push   %ebp
f0104bbf:	89 e5                	mov    %esp,%ebp
f0104bc1:	57                   	push   %edi
f0104bc2:	56                   	push   %esi
f0104bc3:	53                   	push   %ebx
f0104bc4:	83 ec 2c             	sub    $0x2c,%esp
f0104bc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0104bca:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f0104bcf:	39 c7                	cmp    %eax,%edi
f0104bd1:	75 37                	jne    f0104c0a <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0104bd3:	8b 15 ac bc 20 f0    	mov    0xf020bcac,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104bd9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0104bdf:	77 20                	ja     f0104c01 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104be1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104be5:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0104bec:	f0 
f0104bed:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
f0104bf4:	00 
f0104bf5:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104bfc:	e8 b0 b4 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c01:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0104c07:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0104c0a:	8b 57 48             	mov    0x48(%edi),%edx
f0104c0d:	85 c0                	test   %eax,%eax
f0104c0f:	74 05                	je     f0104c16 <env_free+0x58>
f0104c11:	8b 40 48             	mov    0x48(%eax),%eax
f0104c14:	eb 05                	jmp    f0104c1b <env_free+0x5d>
f0104c16:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c23:	c7 04 24 e5 88 10 f0 	movl   $0xf01088e5,(%esp)
f0104c2a:	e8 a7 02 00 00       	call   f0104ed6 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104c2f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0104c36:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c39:	c1 e0 02             	shl    $0x2,%eax
f0104c3c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104c3f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0104c42:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104c45:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0104c48:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0104c4e:	0f 84 b6 00 00 00    	je     f0104d0a <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0104c54:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104c5a:	89 f0                	mov    %esi,%eax
f0104c5c:	c1 e8 0c             	shr    $0xc,%eax
f0104c5f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c62:	3b 05 a8 bc 20 f0    	cmp    0xf020bca8,%eax
f0104c68:	72 20                	jb     f0104c8a <env_free+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104c6a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104c6e:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0104c75:	f0 
f0104c76:	c7 44 24 04 b1 01 00 	movl   $0x1b1,0x4(%esp)
f0104c7d:	00 
f0104c7e:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104c85:	e8 27 b4 ff ff       	call   f01000b1 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104c8a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104c8d:	c1 e2 16             	shl    $0x16,%edx
f0104c90:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104c93:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0104c98:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0104c9f:	01 
f0104ca0:	74 17                	je     f0104cb9 <env_free+0xfb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104ca2:	89 d8                	mov    %ebx,%eax
f0104ca4:	c1 e0 0c             	shl    $0xc,%eax
f0104ca7:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0104caa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cae:	8b 47 5c             	mov    0x5c(%edi),%eax
f0104cb1:	89 04 24             	mov    %eax,(%esp)
f0104cb4:	e8 ca db ff ff       	call   f0102883 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104cb9:	43                   	inc    %ebx
f0104cba:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104cc0:	75 d6                	jne    f0104c98 <env_free+0xda>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104cc2:	8b 47 5c             	mov    0x5c(%edi),%eax
f0104cc5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104cc8:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104ccf:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104cd2:	3b 05 a8 bc 20 f0    	cmp    0xf020bca8,%eax
f0104cd8:	72 1c                	jb     f0104cf6 <env_free+0x138>
		panic("pa2page called with invalid pa");
f0104cda:	c7 44 24 08 f4 7d 10 	movl   $0xf0107df4,0x8(%esp)
f0104ce1:	f0 
f0104ce2:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0104ce9:	00 
f0104cea:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0104cf1:	e8 bb b3 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0104cf6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104cf9:	c1 e0 03             	shl    $0x3,%eax
f0104cfc:	03 05 b0 bc 20 f0    	add    0xf020bcb0,%eax
		page_decref(pa2page(pa));
f0104d02:	89 04 24             	mov    %eax,(%esp)
f0104d05:	e8 4e d9 ff ff       	call   f0102658 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104d0a:	ff 45 e0             	incl   -0x20(%ebp)
f0104d0d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104d14:	0f 85 1c ff ff ff    	jne    f0104c36 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104d1a:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104d1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104d22:	77 20                	ja     f0104d44 <env_free+0x186>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104d24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d28:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0104d2f:	f0 
f0104d30:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
f0104d37:	00 
f0104d38:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104d3f:	e8 6d b3 ff ff       	call   f01000b1 <_panic>
	e->env_pgdir = 0;
f0104d44:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0104d4b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104d50:	c1 e8 0c             	shr    $0xc,%eax
f0104d53:	3b 05 a8 bc 20 f0    	cmp    0xf020bca8,%eax
f0104d59:	72 1c                	jb     f0104d77 <env_free+0x1b9>
		panic("pa2page called with invalid pa");
f0104d5b:	c7 44 24 08 f4 7d 10 	movl   $0xf0107df4,0x8(%esp)
f0104d62:	f0 
f0104d63:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0104d6a:	00 
f0104d6b:	c7 04 24 cb 84 10 f0 	movl   $0xf01084cb,(%esp)
f0104d72:	e8 3a b3 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0104d77:	c1 e0 03             	shl    $0x3,%eax
f0104d7a:	03 05 b0 bc 20 f0    	add    0xf020bcb0,%eax
	page_decref(pa2page(pa));
f0104d80:	89 04 24             	mov    %eax,(%esp)
f0104d83:	e8 d0 d8 ff ff       	call   f0102658 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104d88:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104d8f:	a1 18 b0 20 f0       	mov    0xf020b018,%eax
f0104d94:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0104d97:	89 3d 18 b0 20 f0    	mov    %edi,0xf020b018
}
f0104d9d:	83 c4 2c             	add    $0x2c,%esp
f0104da0:	5b                   	pop    %ebx
f0104da1:	5e                   	pop    %esi
f0104da2:	5f                   	pop    %edi
f0104da3:	5d                   	pop    %ebp
f0104da4:	c3                   	ret    

f0104da5 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0104da5:	55                   	push   %ebp
f0104da6:	89 e5                	mov    %esp,%ebp
f0104da8:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0104dab:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dae:	89 04 24             	mov    %eax,(%esp)
f0104db1:	e8 08 fe ff ff       	call   f0104bbe <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0104db6:	c7 04 24 48 88 10 f0 	movl   $0xf0108848,(%esp)
f0104dbd:	e8 14 01 00 00       	call   f0104ed6 <cprintf>
	while (1)
		monitor(NULL);
f0104dc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104dc9:	e8 31 cd ff ff       	call   f0101aff <monitor>
f0104dce:	eb f2                	jmp    f0104dc2 <env_destroy+0x1d>

f0104dd0 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104dd0:	55                   	push   %ebp
f0104dd1:	89 e5                	mov    %esp,%ebp
f0104dd3:	83 ec 18             	sub    $0x18,%esp
	asm volatile(
f0104dd6:	8b 65 08             	mov    0x8(%ebp),%esp
f0104dd9:	61                   	popa   
f0104dda:	07                   	pop    %es
f0104ddb:	1f                   	pop    %ds
f0104ddc:	83 c4 08             	add    $0x8,%esp
f0104ddf:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104de0:	c7 44 24 08 fb 88 10 	movl   $0xf01088fb,0x8(%esp)
f0104de7:	f0 
f0104de8:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
f0104def:	00 
f0104df0:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104df7:	e8 b5 b2 ff ff       	call   f01000b1 <_panic>

f0104dfc <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104dfc:	55                   	push   %ebp
f0104dfd:	89 e5                	mov    %esp,%ebp
f0104dff:	83 ec 18             	sub    $0x18,%esp
f0104e02:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f0104e05:	8b 15 10 b0 20 f0    	mov    0xf020b010,%edx
f0104e0b:	85 d2                	test   %edx,%edx
f0104e0d:	74 0d                	je     f0104e1c <env_run+0x20>
f0104e0f:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0104e13:	75 07                	jne    f0104e1c <env_run+0x20>
        curenv->env_status = ENV_RUNNABLE;
f0104e15:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	// cprintf("env_run: %x %x\n",curenv,curenv->env_tf.tf_eip);
    curenv = e;
f0104e1c:	a3 10 b0 20 f0       	mov    %eax,0xf020b010
    curenv->env_status = ENV_RUNNING;
f0104e21:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0104e28:	ff 40 58             	incl   0x58(%eax)
    lcr3(PADDR(curenv->env_pgdir));
f0104e2b:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104e2e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0104e34:	77 20                	ja     f0104e56 <env_run+0x5a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104e36:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104e3a:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0104e41:	f0 
f0104e42:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0104e49:	00 
f0104e4a:	c7 04 24 7e 88 10 f0 	movl   $0xf010887e,(%esp)
f0104e51:	e8 5b b2 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104e56:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0104e5c:	0f 22 da             	mov    %edx,%cr3
	// cprintf("env_run: %x %x\n",curenv,curenv->env_tf.tf_eip);
    env_pop_tf(&curenv->env_tf);
f0104e5f:	89 04 24             	mov    %eax,(%esp)
f0104e62:	e8 69 ff ff ff       	call   f0104dd0 <env_pop_tf>
	...

f0104e68 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104e68:	55                   	push   %ebp
f0104e69:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104e6b:	ba 70 00 00 00       	mov    $0x70,%edx
f0104e70:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e73:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104e74:	b2 71                	mov    $0x71,%dl
f0104e76:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104e77:	0f b6 c0             	movzbl %al,%eax
}
f0104e7a:	5d                   	pop    %ebp
f0104e7b:	c3                   	ret    

f0104e7c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104e7c:	55                   	push   %ebp
f0104e7d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104e7f:	ba 70 00 00 00       	mov    $0x70,%edx
f0104e84:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e87:	ee                   	out    %al,(%dx)
f0104e88:	b2 71                	mov    $0x71,%dl
f0104e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e8d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104e8e:	5d                   	pop    %ebp
f0104e8f:	c3                   	ret    

f0104e90 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104e90:	55                   	push   %ebp
f0104e91:	89 e5                	mov    %esp,%ebp
f0104e93:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104e96:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e99:	89 04 24             	mov    %eax,(%esp)
f0104e9c:	e8 22 ba ff ff       	call   f01008c3 <cputchar>
	*cnt++;
}
f0104ea1:	c9                   	leave  
f0104ea2:	c3                   	ret    

f0104ea3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104ea3:	55                   	push   %ebp
f0104ea4:	89 e5                	mov    %esp,%ebp
f0104ea6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104ea9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104eb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104eb7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104eba:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ebe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ec5:	c7 04 24 90 4e 10 f0 	movl   $0xf0104e90,(%esp)
f0104ecc:	e8 dd 0e 00 00       	call   f0105dae <vprintfmt>
	return cnt;
}
f0104ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ed4:	c9                   	leave  
f0104ed5:	c3                   	ret    

f0104ed6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104ed6:	55                   	push   %ebp
f0104ed7:	89 e5                	mov    %esp,%ebp
f0104ed9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104edc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104edf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ee3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ee6:	89 04 24             	mov    %eax,(%esp)
f0104ee9:	e8 b5 ff ff ff       	call   f0104ea3 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104eee:	c9                   	leave  
f0104eef:	c3                   	ret    

f0104ef0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104ef0:	55                   	push   %ebp
f0104ef1:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0104ef3:	c7 05 24 b8 20 f0 00 	movl   $0xf0000000,0xf020b824
f0104efa:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0104efd:	66 c7 05 28 b8 20 f0 	movw   $0x10,0xf020b828
f0104f04:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0104f06:	66 c7 05 86 b8 20 f0 	movw   $0x68,0xf020b886
f0104f0d:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0104f0f:	66 c7 05 a8 91 14 f0 	movw   $0x67,0xf01491a8
f0104f16:	67 00 
f0104f18:	b8 20 b8 20 f0       	mov    $0xf020b820,%eax
f0104f1d:	66 a3 aa 91 14 f0    	mov    %ax,0xf01491aa
f0104f23:	89 c2                	mov    %eax,%edx
f0104f25:	c1 ea 10             	shr    $0x10,%edx
f0104f28:	88 15 ac 91 14 f0    	mov    %dl,0xf01491ac
f0104f2e:	c6 05 ae 91 14 f0 40 	movb   $0x40,0xf01491ae
f0104f35:	c1 e8 18             	shr    $0x18,%eax
f0104f38:	a2 af 91 14 f0       	mov    %al,0xf01491af
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0104f3d:	c6 05 ad 91 14 f0 89 	movb   $0x89,0xf01491ad
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0104f44:	b8 28 00 00 00       	mov    $0x28,%eax
f0104f49:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0104f4c:	b8 b0 91 14 f0       	mov    $0xf01491b0,%eax
f0104f51:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0104f54:	5d                   	pop    %ebp
f0104f55:	c3                   	ret    

f0104f56 <trap_init>:
void Handler_SIMDERR();
void Handler_SYSCALL();

void 
trap_init(void)
{
f0104f56:	55                   	push   %ebp
f0104f57:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
    SETGATE(idt[T_DIVIDE],0,GD_KT,Handler_DIVIDE,0);
f0104f59:	b8 e0 56 10 f0       	mov    $0xf01056e0,%eax
f0104f5e:	66 a3 20 b0 20 f0    	mov    %ax,0xf020b020
f0104f64:	66 c7 05 22 b0 20 f0 	movw   $0x8,0xf020b022
f0104f6b:	08 00 
f0104f6d:	c6 05 24 b0 20 f0 00 	movb   $0x0,0xf020b024
f0104f74:	c6 05 25 b0 20 f0 8e 	movb   $0x8e,0xf020b025
f0104f7b:	c1 e8 10             	shr    $0x10,%eax
f0104f7e:	66 a3 26 b0 20 f0    	mov    %ax,0xf020b026
    SETGATE(idt[T_DEBUG],0,GD_KT,Handler_DEBUG,3);
f0104f84:	b8 e6 56 10 f0       	mov    $0xf01056e6,%eax
f0104f89:	66 a3 28 b0 20 f0    	mov    %ax,0xf020b028
f0104f8f:	66 c7 05 2a b0 20 f0 	movw   $0x8,0xf020b02a
f0104f96:	08 00 
f0104f98:	c6 05 2c b0 20 f0 00 	movb   $0x0,0xf020b02c
f0104f9f:	c6 05 2d b0 20 f0 ee 	movb   $0xee,0xf020b02d
f0104fa6:	c1 e8 10             	shr    $0x10,%eax
f0104fa9:	66 a3 2e b0 20 f0    	mov    %ax,0xf020b02e
    SETGATE(idt[T_NMI],0,GD_KT,Handler_NMI,0);
f0104faf:	b8 ec 56 10 f0       	mov    $0xf01056ec,%eax
f0104fb4:	66 a3 30 b0 20 f0    	mov    %ax,0xf020b030
f0104fba:	66 c7 05 32 b0 20 f0 	movw   $0x8,0xf020b032
f0104fc1:	08 00 
f0104fc3:	c6 05 34 b0 20 f0 00 	movb   $0x0,0xf020b034
f0104fca:	c6 05 35 b0 20 f0 8e 	movb   $0x8e,0xf020b035
f0104fd1:	c1 e8 10             	shr    $0x10,%eax
f0104fd4:	66 a3 36 b0 20 f0    	mov    %ax,0xf020b036
    SETGATE(idt[T_BRKPT],1,GD_KT,Handler_BRKPT,3);
f0104fda:	b8 f2 56 10 f0       	mov    $0xf01056f2,%eax
f0104fdf:	66 a3 38 b0 20 f0    	mov    %ax,0xf020b038
f0104fe5:	66 c7 05 3a b0 20 f0 	movw   $0x8,0xf020b03a
f0104fec:	08 00 
f0104fee:	c6 05 3c b0 20 f0 00 	movb   $0x0,0xf020b03c
f0104ff5:	c6 05 3d b0 20 f0 ef 	movb   $0xef,0xf020b03d
f0104ffc:	c1 e8 10             	shr    $0x10,%eax
f0104fff:	66 a3 3e b0 20 f0    	mov    %ax,0xf020b03e
    SETGATE(idt[T_OFLOW],1,GD_KT,Handler_OFLOW,0);
f0105005:	b8 f8 56 10 f0       	mov    $0xf01056f8,%eax
f010500a:	66 a3 40 b0 20 f0    	mov    %ax,0xf020b040
f0105010:	66 c7 05 42 b0 20 f0 	movw   $0x8,0xf020b042
f0105017:	08 00 
f0105019:	c6 05 44 b0 20 f0 00 	movb   $0x0,0xf020b044
f0105020:	c6 05 45 b0 20 f0 8f 	movb   $0x8f,0xf020b045
f0105027:	c1 e8 10             	shr    $0x10,%eax
f010502a:	66 a3 46 b0 20 f0    	mov    %ax,0xf020b046
    SETGATE(idt[T_BOUND],0,GD_KT,Handler_BOUND,0);
f0105030:	b8 fe 56 10 f0       	mov    $0xf01056fe,%eax
f0105035:	66 a3 48 b0 20 f0    	mov    %ax,0xf020b048
f010503b:	66 c7 05 4a b0 20 f0 	movw   $0x8,0xf020b04a
f0105042:	08 00 
f0105044:	c6 05 4c b0 20 f0 00 	movb   $0x0,0xf020b04c
f010504b:	c6 05 4d b0 20 f0 8e 	movb   $0x8e,0xf020b04d
f0105052:	c1 e8 10             	shr    $0x10,%eax
f0105055:	66 a3 4e b0 20 f0    	mov    %ax,0xf020b04e
    SETGATE(idt[T_ILLOP],0,GD_KT,Handler_ILLOP,0);
f010505b:	b8 04 57 10 f0       	mov    $0xf0105704,%eax
f0105060:	66 a3 50 b0 20 f0    	mov    %ax,0xf020b050
f0105066:	66 c7 05 52 b0 20 f0 	movw   $0x8,0xf020b052
f010506d:	08 00 
f010506f:	c6 05 54 b0 20 f0 00 	movb   $0x0,0xf020b054
f0105076:	c6 05 55 b0 20 f0 8e 	movb   $0x8e,0xf020b055
f010507d:	c1 e8 10             	shr    $0x10,%eax
f0105080:	66 a3 56 b0 20 f0    	mov    %ax,0xf020b056
    SETGATE(idt[T_DEVICE],0,GD_KT,Handler_DEVICE,0);
f0105086:	b8 0a 57 10 f0       	mov    $0xf010570a,%eax
f010508b:	66 a3 58 b0 20 f0    	mov    %ax,0xf020b058
f0105091:	66 c7 05 5a b0 20 f0 	movw   $0x8,0xf020b05a
f0105098:	08 00 
f010509a:	c6 05 5c b0 20 f0 00 	movb   $0x0,0xf020b05c
f01050a1:	c6 05 5d b0 20 f0 8e 	movb   $0x8e,0xf020b05d
f01050a8:	c1 e8 10             	shr    $0x10,%eax
f01050ab:	66 a3 5e b0 20 f0    	mov    %ax,0xf020b05e
    SETGATE(idt[T_DBLFLT],0,GD_KT,Handler_DBLFLT,0);
f01050b1:	b8 10 57 10 f0       	mov    $0xf0105710,%eax
f01050b6:	66 a3 60 b0 20 f0    	mov    %ax,0xf020b060
f01050bc:	66 c7 05 62 b0 20 f0 	movw   $0x8,0xf020b062
f01050c3:	08 00 
f01050c5:	c6 05 64 b0 20 f0 00 	movb   $0x0,0xf020b064
f01050cc:	c6 05 65 b0 20 f0 8e 	movb   $0x8e,0xf020b065
f01050d3:	c1 e8 10             	shr    $0x10,%eax
f01050d6:	66 a3 66 b0 20 f0    	mov    %ax,0xf020b066
    SETGATE(idt[T_TSS],0,GD_KT,Handler_TSS,0);
f01050dc:	b8 14 57 10 f0       	mov    $0xf0105714,%eax
f01050e1:	66 a3 70 b0 20 f0    	mov    %ax,0xf020b070
f01050e7:	66 c7 05 72 b0 20 f0 	movw   $0x8,0xf020b072
f01050ee:	08 00 
f01050f0:	c6 05 74 b0 20 f0 00 	movb   $0x0,0xf020b074
f01050f7:	c6 05 75 b0 20 f0 8e 	movb   $0x8e,0xf020b075
f01050fe:	c1 e8 10             	shr    $0x10,%eax
f0105101:	66 a3 76 b0 20 f0    	mov    %ax,0xf020b076
    SETGATE(idt[T_SEGNP],0,GD_KT,Handler_SEGNP,0);
f0105107:	b8 18 57 10 f0       	mov    $0xf0105718,%eax
f010510c:	66 a3 78 b0 20 f0    	mov    %ax,0xf020b078
f0105112:	66 c7 05 7a b0 20 f0 	movw   $0x8,0xf020b07a
f0105119:	08 00 
f010511b:	c6 05 7c b0 20 f0 00 	movb   $0x0,0xf020b07c
f0105122:	c6 05 7d b0 20 f0 8e 	movb   $0x8e,0xf020b07d
f0105129:	c1 e8 10             	shr    $0x10,%eax
f010512c:	66 a3 7e b0 20 f0    	mov    %ax,0xf020b07e
    SETGATE(idt[T_STACK],0,GD_KT,Handler_STACK,0);
f0105132:	b8 1c 57 10 f0       	mov    $0xf010571c,%eax
f0105137:	66 a3 80 b0 20 f0    	mov    %ax,0xf020b080
f010513d:	66 c7 05 82 b0 20 f0 	movw   $0x8,0xf020b082
f0105144:	08 00 
f0105146:	c6 05 84 b0 20 f0 00 	movb   $0x0,0xf020b084
f010514d:	c6 05 85 b0 20 f0 8e 	movb   $0x8e,0xf020b085
f0105154:	c1 e8 10             	shr    $0x10,%eax
f0105157:	66 a3 86 b0 20 f0    	mov    %ax,0xf020b086
    SETGATE(idt[T_GPFLT],0,GD_KT,Handler_GPFLT,0);
f010515d:	b8 20 57 10 f0       	mov    $0xf0105720,%eax
f0105162:	66 a3 88 b0 20 f0    	mov    %ax,0xf020b088
f0105168:	66 c7 05 8a b0 20 f0 	movw   $0x8,0xf020b08a
f010516f:	08 00 
f0105171:	c6 05 8c b0 20 f0 00 	movb   $0x0,0xf020b08c
f0105178:	c6 05 8d b0 20 f0 8e 	movb   $0x8e,0xf020b08d
f010517f:	c1 e8 10             	shr    $0x10,%eax
f0105182:	66 a3 8e b0 20 f0    	mov    %ax,0xf020b08e
    SETGATE(idt[T_PGFLT],0,GD_KT,Handler_PGFLT,0);
f0105188:	b8 24 57 10 f0       	mov    $0xf0105724,%eax
f010518d:	66 a3 90 b0 20 f0    	mov    %ax,0xf020b090
f0105193:	66 c7 05 92 b0 20 f0 	movw   $0x8,0xf020b092
f010519a:	08 00 
f010519c:	c6 05 94 b0 20 f0 00 	movb   $0x0,0xf020b094
f01051a3:	c6 05 95 b0 20 f0 8e 	movb   $0x8e,0xf020b095
f01051aa:	c1 e8 10             	shr    $0x10,%eax
f01051ad:	66 a3 96 b0 20 f0    	mov    %ax,0xf020b096
    SETGATE(idt[T_FPERR],0,GD_KT,Handler_FPERR,0);
f01051b3:	b8 28 57 10 f0       	mov    $0xf0105728,%eax
f01051b8:	66 a3 a0 b0 20 f0    	mov    %ax,0xf020b0a0
f01051be:	66 c7 05 a2 b0 20 f0 	movw   $0x8,0xf020b0a2
f01051c5:	08 00 
f01051c7:	c6 05 a4 b0 20 f0 00 	movb   $0x0,0xf020b0a4
f01051ce:	c6 05 a5 b0 20 f0 8e 	movb   $0x8e,0xf020b0a5
f01051d5:	c1 e8 10             	shr    $0x10,%eax
f01051d8:	66 a3 a6 b0 20 f0    	mov    %ax,0xf020b0a6
    SETGATE(idt[T_ALIGN],0,GD_KT,Handler_ALIGN,0);
f01051de:	b8 2e 57 10 f0       	mov    $0xf010572e,%eax
f01051e3:	66 a3 a8 b0 20 f0    	mov    %ax,0xf020b0a8
f01051e9:	66 c7 05 aa b0 20 f0 	movw   $0x8,0xf020b0aa
f01051f0:	08 00 
f01051f2:	c6 05 ac b0 20 f0 00 	movb   $0x0,0xf020b0ac
f01051f9:	c6 05 ad b0 20 f0 8e 	movb   $0x8e,0xf020b0ad
f0105200:	c1 e8 10             	shr    $0x10,%eax
f0105203:	66 a3 ae b0 20 f0    	mov    %ax,0xf020b0ae
    SETGATE(idt[T_MCHK],0,GD_KT,Handler_MCHK,0);
f0105209:	b8 32 57 10 f0       	mov    $0xf0105732,%eax
f010520e:	66 a3 b0 b0 20 f0    	mov    %ax,0xf020b0b0
f0105214:	66 c7 05 b2 b0 20 f0 	movw   $0x8,0xf020b0b2
f010521b:	08 00 
f010521d:	c6 05 b4 b0 20 f0 00 	movb   $0x0,0xf020b0b4
f0105224:	c6 05 b5 b0 20 f0 8e 	movb   $0x8e,0xf020b0b5
f010522b:	c1 e8 10             	shr    $0x10,%eax
f010522e:	66 a3 b6 b0 20 f0    	mov    %ax,0xf020b0b6
    SETGATE(idt[T_SIMDERR],0,GD_KT,Handler_SIMDERR,0);
f0105234:	b8 38 57 10 f0       	mov    $0xf0105738,%eax
f0105239:	66 a3 b8 b0 20 f0    	mov    %ax,0xf020b0b8
f010523f:	66 c7 05 ba b0 20 f0 	movw   $0x8,0xf020b0ba
f0105246:	08 00 
f0105248:	c6 05 bc b0 20 f0 00 	movb   $0x0,0xf020b0bc
f010524f:	c6 05 bd b0 20 f0 8e 	movb   $0x8e,0xf020b0bd
f0105256:	c1 e8 10             	shr    $0x10,%eax
f0105259:	66 a3 be b0 20 f0    	mov    %ax,0xf020b0be
    SETGATE(idt[T_SYSCALL],0,GD_KT,Handler_SYSCALL,3);
f010525f:	b8 3e 57 10 f0       	mov    $0xf010573e,%eax
f0105264:	66 a3 a0 b1 20 f0    	mov    %ax,0xf020b1a0
f010526a:	66 c7 05 a2 b1 20 f0 	movw   $0x8,0xf020b1a2
f0105271:	08 00 
f0105273:	c6 05 a4 b1 20 f0 00 	movb   $0x0,0xf020b1a4
f010527a:	c6 05 a5 b1 20 f0 ee 	movb   $0xee,0xf020b1a5
f0105281:	c1 e8 10             	shr    $0x10,%eax
f0105284:	66 a3 a6 b1 20 f0    	mov    %ax,0xf020b1a6
	// Per-CPU setup 
	trap_init_percpu();
f010528a:	e8 61 fc ff ff       	call   f0104ef0 <trap_init_percpu>
}
f010528f:	5d                   	pop    %ebp
f0105290:	c3                   	ret    

f0105291 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0105291:	55                   	push   %ebp
f0105292:	89 e5                	mov    %esp,%ebp
f0105294:	53                   	push   %ebx
f0105295:	83 ec 14             	sub    $0x14,%esp
f0105298:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010529b:	8b 03                	mov    (%ebx),%eax
f010529d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052a1:	c7 04 24 07 89 10 f0 	movl   $0xf0108907,(%esp)
f01052a8:	e8 29 fc ff ff       	call   f0104ed6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01052ad:	8b 43 04             	mov    0x4(%ebx),%eax
f01052b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052b4:	c7 04 24 16 89 10 f0 	movl   $0xf0108916,(%esp)
f01052bb:	e8 16 fc ff ff       	call   f0104ed6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01052c0:	8b 43 08             	mov    0x8(%ebx),%eax
f01052c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052c7:	c7 04 24 25 89 10 f0 	movl   $0xf0108925,(%esp)
f01052ce:	e8 03 fc ff ff       	call   f0104ed6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01052d3:	8b 43 0c             	mov    0xc(%ebx),%eax
f01052d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052da:	c7 04 24 34 89 10 f0 	movl   $0xf0108934,(%esp)
f01052e1:	e8 f0 fb ff ff       	call   f0104ed6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01052e6:	8b 43 10             	mov    0x10(%ebx),%eax
f01052e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052ed:	c7 04 24 43 89 10 f0 	movl   $0xf0108943,(%esp)
f01052f4:	e8 dd fb ff ff       	call   f0104ed6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01052f9:	8b 43 14             	mov    0x14(%ebx),%eax
f01052fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105300:	c7 04 24 52 89 10 f0 	movl   $0xf0108952,(%esp)
f0105307:	e8 ca fb ff ff       	call   f0104ed6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010530c:	8b 43 18             	mov    0x18(%ebx),%eax
f010530f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105313:	c7 04 24 61 89 10 f0 	movl   $0xf0108961,(%esp)
f010531a:	e8 b7 fb ff ff       	call   f0104ed6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010531f:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0105322:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105326:	c7 04 24 70 89 10 f0 	movl   $0xf0108970,(%esp)
f010532d:	e8 a4 fb ff ff       	call   f0104ed6 <cprintf>
}
f0105332:	83 c4 14             	add    $0x14,%esp
f0105335:	5b                   	pop    %ebx
f0105336:	5d                   	pop    %ebp
f0105337:	c3                   	ret    

f0105338 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0105338:	55                   	push   %ebp
f0105339:	89 e5                	mov    %esp,%ebp
f010533b:	53                   	push   %ebx
f010533c:	83 ec 14             	sub    $0x14,%esp
f010533f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0105342:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105346:	c7 04 24 a6 8a 10 f0 	movl   $0xf0108aa6,(%esp)
f010534d:	e8 84 fb ff ff       	call   f0104ed6 <cprintf>
	print_regs(&tf->tf_regs);
f0105352:	89 1c 24             	mov    %ebx,(%esp)
f0105355:	e8 37 ff ff ff       	call   f0105291 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010535a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010535e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105362:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f0105369:	e8 68 fb ff ff       	call   f0104ed6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010536e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0105372:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105376:	c7 04 24 d4 89 10 f0 	movl   $0xf01089d4,(%esp)
f010537d:	e8 54 fb ff ff       	call   f0104ed6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0105382:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0105385:	83 f8 13             	cmp    $0x13,%eax
f0105388:	77 09                	ja     f0105393 <print_trapframe+0x5b>
		return excnames[trapno];
f010538a:	8b 14 85 e0 8c 10 f0 	mov    -0xfef7320(,%eax,4),%edx
f0105391:	eb 11                	jmp    f01053a4 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
f0105393:	83 f8 30             	cmp    $0x30,%eax
f0105396:	75 07                	jne    f010539f <print_trapframe+0x67>
		return "System call";
f0105398:	ba 7f 89 10 f0       	mov    $0xf010897f,%edx
f010539d:	eb 05                	jmp    f01053a4 <print_trapframe+0x6c>
	return "(unknown trap)";
f010539f:	ba 8b 89 10 f0       	mov    $0xf010898b,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01053a4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053ac:	c7 04 24 e7 89 10 f0 	movl   $0xf01089e7,(%esp)
f01053b3:	e8 1e fb ff ff       	call   f0104ed6 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01053b8:	3b 1d 88 b8 20 f0    	cmp    0xf020b888,%ebx
f01053be:	75 19                	jne    f01053d9 <print_trapframe+0xa1>
f01053c0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01053c4:	75 13                	jne    f01053d9 <print_trapframe+0xa1>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01053c6:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01053c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053cd:	c7 04 24 f9 89 10 f0 	movl   $0xf01089f9,(%esp)
f01053d4:	e8 fd fa ff ff       	call   f0104ed6 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01053d9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01053dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053e0:	c7 04 24 08 8a 10 f0 	movl   $0xf0108a08,(%esp)
f01053e7:	e8 ea fa ff ff       	call   f0104ed6 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01053ec:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01053f0:	75 4d                	jne    f010543f <print_trapframe+0x107>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01053f2:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01053f5:	a8 01                	test   $0x1,%al
f01053f7:	74 07                	je     f0105400 <print_trapframe+0xc8>
f01053f9:	b9 9a 89 10 f0       	mov    $0xf010899a,%ecx
f01053fe:	eb 05                	jmp    f0105405 <print_trapframe+0xcd>
f0105400:	b9 a5 89 10 f0       	mov    $0xf01089a5,%ecx
f0105405:	a8 02                	test   $0x2,%al
f0105407:	74 07                	je     f0105410 <print_trapframe+0xd8>
f0105409:	ba b1 89 10 f0       	mov    $0xf01089b1,%edx
f010540e:	eb 05                	jmp    f0105415 <print_trapframe+0xdd>
f0105410:	ba b7 89 10 f0       	mov    $0xf01089b7,%edx
f0105415:	a8 04                	test   $0x4,%al
f0105417:	74 07                	je     f0105420 <print_trapframe+0xe8>
f0105419:	b8 bc 89 10 f0       	mov    $0xf01089bc,%eax
f010541e:	eb 05                	jmp    f0105425 <print_trapframe+0xed>
f0105420:	b8 e3 8a 10 f0       	mov    $0xf0108ae3,%eax
f0105425:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105429:	89 54 24 08          	mov    %edx,0x8(%esp)
f010542d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105431:	c7 04 24 16 8a 10 f0 	movl   $0xf0108a16,(%esp)
f0105438:	e8 99 fa ff ff       	call   f0104ed6 <cprintf>
f010543d:	eb 0c                	jmp    f010544b <print_trapframe+0x113>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010543f:	c7 04 24 a0 87 10 f0 	movl   $0xf01087a0,(%esp)
f0105446:	e8 8b fa ff ff       	call   f0104ed6 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010544b:	8b 43 30             	mov    0x30(%ebx),%eax
f010544e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105452:	c7 04 24 25 8a 10 f0 	movl   $0xf0108a25,(%esp)
f0105459:	e8 78 fa ff ff       	call   f0104ed6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010545e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0105462:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105466:	c7 04 24 34 8a 10 f0 	movl   $0xf0108a34,(%esp)
f010546d:	e8 64 fa ff ff       	call   f0104ed6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0105472:	8b 43 38             	mov    0x38(%ebx),%eax
f0105475:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105479:	c7 04 24 47 8a 10 f0 	movl   $0xf0108a47,(%esp)
f0105480:	e8 51 fa ff ff       	call   f0104ed6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0105485:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0105489:	74 27                	je     f01054b2 <print_trapframe+0x17a>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010548b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010548e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105492:	c7 04 24 56 8a 10 f0 	movl   $0xf0108a56,(%esp)
f0105499:	e8 38 fa ff ff       	call   f0104ed6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010549e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01054a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054a6:	c7 04 24 65 8a 10 f0 	movl   $0xf0108a65,(%esp)
f01054ad:	e8 24 fa ff ff       	call   f0104ed6 <cprintf>
	}
}
f01054b2:	83 c4 14             	add    $0x14,%esp
f01054b5:	5b                   	pop    %ebx
f01054b6:	5d                   	pop    %ebp
f01054b7:	c3                   	ret    

f01054b8 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01054b8:	55                   	push   %ebp
f01054b9:	89 e5                	mov    %esp,%ebp
f01054bb:	53                   	push   %ebx
f01054bc:	83 ec 14             	sub    $0x14,%esp
f01054bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01054c2:	0f 20 d0             	mov    %cr2,%eax
	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	// cprintf("tf_cs:  %x\n",tf->tf_cs);
	if ( (tf->tf_cs&1)!=1 )
f01054c5:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f01054c9:	75 1c                	jne    f01054e7 <page_fault_handler+0x2f>
		panic("page_fault_handler: kernel page fault!\n");
f01054cb:	c7 44 24 08 30 8c 10 	movl   $0xf0108c30,0x8(%esp)
f01054d2:	f0 
f01054d3:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
f01054da:	00 
f01054db:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f01054e2:	e8 ca ab ff ff       	call   f01000b1 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01054e7:	8b 53 30             	mov    0x30(%ebx),%edx
f01054ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01054ee:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01054f2:	a1 10 b0 20 f0       	mov    0xf020b010,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01054f7:	8b 40 48             	mov    0x48(%eax),%eax
f01054fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054fe:	c7 04 24 58 8c 10 f0 	movl   $0xf0108c58,(%esp)
f0105505:	e8 cc f9 ff ff       	call   f0104ed6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010550a:	89 1c 24             	mov    %ebx,(%esp)
f010550d:	e8 26 fe ff ff       	call   f0105338 <print_trapframe>
	env_destroy(curenv);
f0105512:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f0105517:	89 04 24             	mov    %eax,(%esp)
f010551a:	e8 86 f8 ff ff       	call   f0104da5 <env_destroy>
}
f010551f:	83 c4 14             	add    $0x14,%esp
f0105522:	5b                   	pop    %ebx
f0105523:	5d                   	pop    %ebp
f0105524:	c3                   	ret    

f0105525 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0105525:	55                   	push   %ebp
f0105526:	89 e5                	mov    %esp,%ebp
f0105528:	57                   	push   %edi
f0105529:	56                   	push   %esi
f010552a:	83 ec 20             	sub    $0x20,%esp
f010552d:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0105530:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0105531:	9c                   	pushf  
f0105532:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0105533:	f6 c4 02             	test   $0x2,%ah
f0105536:	74 24                	je     f010555c <trap+0x37>
f0105538:	c7 44 24 0c 84 8a 10 	movl   $0xf0108a84,0xc(%esp)
f010553f:	f0 
f0105540:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0105547:	f0 
f0105548:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
f010554f:	00 
f0105550:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f0105557:	e8 55 ab ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f010555c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105560:	c7 04 24 9d 8a 10 f0 	movl   $0xf0108a9d,(%esp)
f0105567:	e8 6a f9 ff ff       	call   f0104ed6 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f010556c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0105570:	83 e0 03             	and    $0x3,%eax
f0105573:	83 f8 03             	cmp    $0x3,%eax
f0105576:	75 3c                	jne    f01055b4 <trap+0x8f>
		// Trapped from user mode.
		assert(curenv);
f0105578:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f010557d:	85 c0                	test   %eax,%eax
f010557f:	75 24                	jne    f01055a5 <trap+0x80>
f0105581:	c7 44 24 0c b8 8a 10 	movl   $0xf0108ab8,0xc(%esp)
f0105588:	f0 
f0105589:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f0105590:	f0 
f0105591:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
f0105598:	00 
f0105599:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f01055a0:	e8 0c ab ff ff       	call   f01000b1 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01055a5:	b9 11 00 00 00       	mov    $0x11,%ecx
f01055aa:	89 c7                	mov    %eax,%edi
f01055ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01055ae:	8b 35 10 b0 20 f0    	mov    0xf020b010,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01055b4:	89 35 88 b8 20 f0    	mov    %esi,0xf020b888
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	cprintf("trap_dispatch %x\n",tf->tf_trapno);
f01055ba:	8b 46 28             	mov    0x28(%esi),%eax
f01055bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055c1:	c7 04 24 bf 8a 10 f0 	movl   $0xf0108abf,(%esp)
f01055c8:	e8 09 f9 ff ff       	call   f0104ed6 <cprintf>
	switch (tf->tf_trapno){
f01055cd:	8b 46 28             	mov    0x28(%esi),%eax
f01055d0:	83 f8 03             	cmp    $0x3,%eax
f01055d3:	74 26                	je     f01055fb <trap+0xd6>
f01055d5:	83 f8 03             	cmp    $0x3,%eax
f01055d8:	77 0b                	ja     f01055e5 <trap+0xc0>
f01055da:	83 f8 01             	cmp    $0x1,%eax
f01055dd:	0f 85 88 00 00 00    	jne    f010566b <trap+0x146>
f01055e3:	eb 23                	jmp    f0105608 <trap+0xe3>
f01055e5:	83 f8 0e             	cmp    $0xe,%eax
f01055e8:	74 07                	je     f01055f1 <trap+0xcc>
f01055ea:	83 f8 30             	cmp    $0x30,%eax
f01055ed:	75 7c                	jne    f010566b <trap+0x146>
f01055ef:	eb 24                	jmp    f0105615 <trap+0xf0>
		case T_PGFLT: page_fault_handler(tf);break;
f01055f1:	89 34 24             	mov    %esi,(%esp)
f01055f4:	e8 bf fe ff ff       	call   f01054b8 <page_fault_handler>
f01055f9:	eb 70                	jmp    f010566b <trap+0x146>
		case T_BRKPT: monitor(tf);return;
f01055fb:	89 34 24             	mov    %esi,(%esp)
f01055fe:	e8 fc c4 ff ff       	call   f0101aff <monitor>
f0105603:	e9 9b 00 00 00       	jmp    f01056a3 <trap+0x17e>
		case T_DEBUG: monitor(tf);return;
f0105608:	89 34 24             	mov    %esi,(%esp)
f010560b:	e8 ef c4 ff ff       	call   f0101aff <monitor>
f0105610:	e9 8e 00 00 00       	jmp    f01056a3 <trap+0x17e>
		case T_SYSCALL: {
			int32_t ret = syscall(tf->tf_regs.reg_eax,
f0105615:	8b 46 04             	mov    0x4(%esi),%eax
f0105618:	89 44 24 14          	mov    %eax,0x14(%esp)
f010561c:	8b 06                	mov    (%esi),%eax
f010561e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105622:	8b 46 10             	mov    0x10(%esi),%eax
f0105625:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105629:	8b 46 18             	mov    0x18(%esi),%eax
f010562c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105630:	8b 46 14             	mov    0x14(%esi),%eax
f0105633:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105637:	8b 46 1c             	mov    0x1c(%esi),%eax
f010563a:	89 04 24             	mov    %eax,(%esp)
f010563d:	e8 1e 01 00 00       	call   f0105760 <syscall>
							   	  tf->tf_regs.reg_edx,
								  tf->tf_regs.reg_ecx,
								  tf->tf_regs.reg_ebx,
								  tf->tf_regs.reg_edi,
								  tf->tf_regs.reg_esi);
			if (ret < 0 )
f0105642:	85 c0                	test   %eax,%eax
f0105644:	79 20                	jns    f0105666 <trap+0x141>
				panic("trap_dispatch: system call %d\n",ret);
f0105646:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010564a:	c7 44 24 08 7c 8c 10 	movl   $0xf0108c7c,0x8(%esp)
f0105651:	f0 
f0105652:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0105659:	00 
f010565a:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f0105661:	e8 4b aa ff ff       	call   f01000b1 <_panic>
			tf->tf_regs.reg_eax = ret;
f0105666:	89 46 1c             	mov    %eax,0x1c(%esi)
f0105669:	eb 38                	jmp    f01056a3 <trap+0x17e>
			return;
		}
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010566b:	89 34 24             	mov    %esi,(%esp)
f010566e:	e8 c5 fc ff ff       	call   f0105338 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0105673:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0105678:	75 1c                	jne    f0105696 <trap+0x171>
		panic("unhandled trap in kernel");
f010567a:	c7 44 24 08 d1 8a 10 	movl   $0xf0108ad1,0x8(%esp)
f0105681:	f0 
f0105682:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0105689:	00 
f010568a:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f0105691:	e8 1b aa ff ff       	call   f01000b1 <_panic>
	else {
		env_destroy(curenv);
f0105696:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f010569b:	89 04 24             	mov    %eax,(%esp)
f010569e:	e8 02 f7 ff ff       	call   f0104da5 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01056a3:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f01056a8:	85 c0                	test   %eax,%eax
f01056aa:	74 06                	je     f01056b2 <trap+0x18d>
f01056ac:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01056b0:	74 24                	je     f01056d6 <trap+0x1b1>
f01056b2:	c7 44 24 0c 9c 8c 10 	movl   $0xf0108c9c,0xc(%esp)
f01056b9:	f0 
f01056ba:	c7 44 24 08 e5 84 10 	movl   $0xf01084e5,0x8(%esp)
f01056c1:	f0 
f01056c2:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
f01056c9:	00 
f01056ca:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f01056d1:	e8 db a9 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f01056d6:	89 04 24             	mov    %eax,(%esp)
f01056d9:	e8 1e f7 ff ff       	call   f0104dfc <env_run>
	...

f01056e0 <Handler_DIVIDE>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(Handler_DIVIDE, T_DIVIDE)
f01056e0:	6a 00                	push   $0x0
f01056e2:	6a 00                	push   $0x0
f01056e4:	eb 5e                	jmp    f0105744 <_alltraps>

f01056e6 <Handler_DEBUG>:
TRAPHANDLER_NOEC(Handler_DEBUG, T_DEBUG)
f01056e6:	6a 00                	push   $0x0
f01056e8:	6a 01                	push   $0x1
f01056ea:	eb 58                	jmp    f0105744 <_alltraps>

f01056ec <Handler_NMI>:
TRAPHANDLER_NOEC(Handler_NMI, T_NMI)
f01056ec:	6a 00                	push   $0x0
f01056ee:	6a 02                	push   $0x2
f01056f0:	eb 52                	jmp    f0105744 <_alltraps>

f01056f2 <Handler_BRKPT>:
TRAPHANDLER_NOEC(Handler_BRKPT, T_BRKPT)
f01056f2:	6a 00                	push   $0x0
f01056f4:	6a 03                	push   $0x3
f01056f6:	eb 4c                	jmp    f0105744 <_alltraps>

f01056f8 <Handler_OFLOW>:
TRAPHANDLER_NOEC(Handler_OFLOW, T_OFLOW)
f01056f8:	6a 00                	push   $0x0
f01056fa:	6a 04                	push   $0x4
f01056fc:	eb 46                	jmp    f0105744 <_alltraps>

f01056fe <Handler_BOUND>:
TRAPHANDLER_NOEC(Handler_BOUND, T_BOUND)
f01056fe:	6a 00                	push   $0x0
f0105700:	6a 05                	push   $0x5
f0105702:	eb 40                	jmp    f0105744 <_alltraps>

f0105704 <Handler_ILLOP>:
TRAPHANDLER_NOEC(Handler_ILLOP, T_ILLOP)
f0105704:	6a 00                	push   $0x0
f0105706:	6a 06                	push   $0x6
f0105708:	eb 3a                	jmp    f0105744 <_alltraps>

f010570a <Handler_DEVICE>:
TRAPHANDLER_NOEC(Handler_DEVICE, T_DEVICE)
f010570a:	6a 00                	push   $0x0
f010570c:	6a 07                	push   $0x7
f010570e:	eb 34                	jmp    f0105744 <_alltraps>

f0105710 <Handler_DBLFLT>:
TRAPHANDLER(Handler_DBLFLT, T_DBLFLT)
f0105710:	6a 08                	push   $0x8
f0105712:	eb 30                	jmp    f0105744 <_alltraps>

f0105714 <Handler_TSS>:
TRAPHANDLER(Handler_TSS, T_TSS)
f0105714:	6a 0a                	push   $0xa
f0105716:	eb 2c                	jmp    f0105744 <_alltraps>

f0105718 <Handler_SEGNP>:
TRAPHANDLER(Handler_SEGNP, T_SEGNP)
f0105718:	6a 0b                	push   $0xb
f010571a:	eb 28                	jmp    f0105744 <_alltraps>

f010571c <Handler_STACK>:
TRAPHANDLER(Handler_STACK, T_STACK)
f010571c:	6a 0c                	push   $0xc
f010571e:	eb 24                	jmp    f0105744 <_alltraps>

f0105720 <Handler_GPFLT>:
TRAPHANDLER(Handler_GPFLT, T_GPFLT)
f0105720:	6a 0d                	push   $0xd
f0105722:	eb 20                	jmp    f0105744 <_alltraps>

f0105724 <Handler_PGFLT>:
TRAPHANDLER(Handler_PGFLT, T_PGFLT)
f0105724:	6a 0e                	push   $0xe
f0105726:	eb 1c                	jmp    f0105744 <_alltraps>

f0105728 <Handler_FPERR>:
TRAPHANDLER_NOEC(Handler_FPERR, T_FPERR)
f0105728:	6a 00                	push   $0x0
f010572a:	6a 10                	push   $0x10
f010572c:	eb 16                	jmp    f0105744 <_alltraps>

f010572e <Handler_ALIGN>:
TRAPHANDLER(Handler_ALIGN, T_ALIGN)
f010572e:	6a 11                	push   $0x11
f0105730:	eb 12                	jmp    f0105744 <_alltraps>

f0105732 <Handler_MCHK>:
TRAPHANDLER_NOEC(Handler_MCHK, T_MCHK)
f0105732:	6a 00                	push   $0x0
f0105734:	6a 12                	push   $0x12
f0105736:	eb 0c                	jmp    f0105744 <_alltraps>

f0105738 <Handler_SIMDERR>:
TRAPHANDLER_NOEC(Handler_SIMDERR, T_SIMDERR)
f0105738:	6a 00                	push   $0x0
f010573a:	6a 13                	push   $0x13
f010573c:	eb 06                	jmp    f0105744 <_alltraps>

f010573e <Handler_SYSCALL>:
TRAPHANDLER_NOEC(Handler_SYSCALL, T_SYSCALL)
f010573e:	6a 00                	push   $0x0
f0105740:	6a 30                	push   $0x30
f0105742:	eb 00                	jmp    f0105744 <_alltraps>

f0105744 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushw $0x0
f0105744:	66 6a 00             	pushw  $0x0
    pushw %ds
f0105747:	66 1e                	pushw  %ds
	pushw $0x0
f0105749:	66 6a 00             	pushw  $0x0
    pushw %es
f010574c:	66 06                	pushw  %es
    pushal
f010574e:	60                   	pusha  
    movl $GD_KD, %eax
f010574f:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
f0105754:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f0105756:	8e c0                	mov    %eax,%es
    push %esp
f0105758:	54                   	push   %esp
f0105759:	e8 c7 fd ff ff       	call   f0105525 <trap>
	...

f0105760 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105760:	55                   	push   %ebp
f0105761:	89 e5                	mov    %esp,%ebp
f0105763:	56                   	push   %esi
f0105764:	53                   	push   %ebx
f0105765:	83 ec 20             	sub    $0x20,%esp
f0105768:	8b 45 08             	mov    0x8(%ebp),%eax
f010576b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010576e:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t res = 0;
	switch (syscallno){
f0105771:	83 f8 01             	cmp    $0x1,%eax
f0105774:	74 4d                	je     f01057c3 <syscall+0x63>
f0105776:	83 f8 01             	cmp    $0x1,%eax
f0105779:	72 10                	jb     f010578b <syscall+0x2b>
f010577b:	83 f8 02             	cmp    $0x2,%eax
f010577e:	74 4a                	je     f01057ca <syscall+0x6a>
f0105780:	83 f8 03             	cmp    $0x3,%eax
f0105783:	0f 85 b4 00 00 00    	jne    f010583d <syscall+0xdd>
f0105789:	eb 49                	jmp    f01057d4 <syscall+0x74>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(const void *)s,len,PTE_U);
f010578b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105792:	00 
f0105793:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010579b:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f01057a0:	89 04 24             	mov    %eax,(%esp)
f01057a3:	e8 e4 ee ff ff       	call   f010468c <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01057a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01057ac:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057b0:	c7 04 24 30 8d 10 f0 	movl   $0xf0108d30,(%esp)
f01057b7:	e8 1a f7 ff ff       	call   f0104ed6 <cprintf>
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t res = 0;
f01057bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01057c1:	eb 7f                	jmp    f0105842 <syscall+0xe2>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01057c3:	e8 d9 af ff ff       	call   f01007a1 <cons_getc>
	int32_t res = 0;
	switch (syscallno){
		case SYS_cputs:
			sys_cputs((const char *)a1,a2);
			break;
		case SYS_cgetc:res = sys_cgetc();break;
f01057c8:	eb 78                	jmp    f0105842 <syscall+0xe2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01057ca:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f01057cf:	8b 40 48             	mov    0x48(%eax),%eax
	switch (syscallno){
		case SYS_cputs:
			sys_cputs((const char *)a1,a2);
			break;
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
f01057d2:	eb 6e                	jmp    f0105842 <syscall+0xe2>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01057d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01057db:	00 
f01057dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01057df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057e3:	89 1c 24             	mov    %ebx,(%esp)
f01057e6:	e8 94 ef ff ff       	call   f010477f <envid2env>
f01057eb:	85 c0                	test   %eax,%eax
f01057ed:	78 53                	js     f0105842 <syscall+0xe2>
		return r;
	if (e == curenv)
f01057ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01057f2:	8b 15 10 b0 20 f0    	mov    0xf020b010,%edx
f01057f8:	39 d0                	cmp    %edx,%eax
f01057fa:	75 15                	jne    f0105811 <syscall+0xb1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01057fc:	8b 40 48             	mov    0x48(%eax),%eax
f01057ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105803:	c7 04 24 35 8d 10 f0 	movl   $0xf0108d35,(%esp)
f010580a:	e8 c7 f6 ff ff       	call   f0104ed6 <cprintf>
f010580f:	eb 1a                	jmp    f010582b <syscall+0xcb>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105811:	8b 40 48             	mov    0x48(%eax),%eax
f0105814:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105818:	8b 42 48             	mov    0x48(%edx),%eax
f010581b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010581f:	c7 04 24 50 8d 10 f0 	movl   $0xf0108d50,(%esp)
f0105826:	e8 ab f6 ff ff       	call   f0104ed6 <cprintf>
	env_destroy(e);
f010582b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010582e:	89 04 24             	mov    %eax,(%esp)
f0105831:	e8 6f f5 ff ff       	call   f0104da5 <env_destroy>
	return 0;
f0105836:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cputs:
			sys_cputs((const char *)a1,a2);
			break;
		case SYS_cgetc:res = sys_cgetc();break;
		case SYS_getenvid:res = sys_getenvid();break;
		case SYS_env_destroy:res = sys_env_destroy(a1);break;
f010583b:	eb 05                	jmp    f0105842 <syscall+0xe2>
		default:res = -E_INVAL;
f010583d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	switch (syscallno) {
	default:
		return -E_INVAL;
	}
}
f0105842:	83 c4 20             	add    $0x20,%esp
f0105845:	5b                   	pop    %ebx
f0105846:	5e                   	pop    %esi
f0105847:	5d                   	pop    %ebp
f0105848:	c3                   	ret    
f0105849:	00 00                	add    %al,(%eax)
	...

f010584c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010584c:	55                   	push   %ebp
f010584d:	89 e5                	mov    %esp,%ebp
f010584f:	57                   	push   %edi
f0105850:	56                   	push   %esi
f0105851:	53                   	push   %ebx
f0105852:	83 ec 14             	sub    $0x14,%esp
f0105855:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105858:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010585b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010585e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105861:	8b 1a                	mov    (%edx),%ebx
f0105863:	8b 01                	mov    (%ecx),%eax
f0105865:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105868:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f010586f:	e9 83 00 00 00       	jmp    f01058f7 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0105874:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105877:	01 d8                	add    %ebx,%eax
f0105879:	89 c7                	mov    %eax,%edi
f010587b:	c1 ef 1f             	shr    $0x1f,%edi
f010587e:	01 c7                	add    %eax,%edi
f0105880:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105882:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105885:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105888:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010588c:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010588e:	eb 01                	jmp    f0105891 <stab_binsearch+0x45>
			m--;
f0105890:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105891:	39 c3                	cmp    %eax,%ebx
f0105893:	7f 1e                	jg     f01058b3 <stab_binsearch+0x67>
f0105895:	0f b6 0a             	movzbl (%edx),%ecx
f0105898:	83 ea 0c             	sub    $0xc,%edx
f010589b:	39 f1                	cmp    %esi,%ecx
f010589d:	75 f1                	jne    f0105890 <stab_binsearch+0x44>
f010589f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01058a2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01058a5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01058a8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01058ac:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01058af:	76 18                	jbe    f01058c9 <stab_binsearch+0x7d>
f01058b1:	eb 05                	jmp    f01058b8 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01058b3:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01058b6:	eb 3f                	jmp    f01058f7 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01058b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01058bb:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01058bd:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01058c0:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01058c7:	eb 2e                	jmp    f01058f7 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01058c9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01058cc:	73 15                	jae    f01058e3 <stab_binsearch+0x97>
			*region_right = m - 1;
f01058ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01058d1:	49                   	dec    %ecx
f01058d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01058d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058d8:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01058da:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01058e1:	eb 14                	jmp    f01058f7 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01058e3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01058e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01058e9:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f01058eb:	ff 45 0c             	incl   0xc(%ebp)
f01058ee:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01058f0:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01058f7:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01058fa:	0f 8e 74 ff ff ff    	jle    f0105874 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105900:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105904:	75 0d                	jne    f0105913 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0105906:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105909:	8b 02                	mov    (%edx),%eax
f010590b:	48                   	dec    %eax
f010590c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010590f:	89 01                	mov    %eax,(%ecx)
f0105911:	eb 2a                	jmp    f010593d <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105913:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105916:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105918:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010591b:	8b 0a                	mov    (%edx),%ecx
f010591d:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105920:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0105923:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105927:	eb 01                	jmp    f010592a <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105929:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010592a:	39 c8                	cmp    %ecx,%eax
f010592c:	7e 0a                	jle    f0105938 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f010592e:	0f b6 1a             	movzbl (%edx),%ebx
f0105931:	83 ea 0c             	sub    $0xc,%edx
f0105934:	39 f3                	cmp    %esi,%ebx
f0105936:	75 f1                	jne    f0105929 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105938:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010593b:	89 02                	mov    %eax,(%edx)
	}
}
f010593d:	83 c4 14             	add    $0x14,%esp
f0105940:	5b                   	pop    %ebx
f0105941:	5e                   	pop    %esi
f0105942:	5f                   	pop    %edi
f0105943:	5d                   	pop    %ebp
f0105944:	c3                   	ret    

f0105945 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105945:	55                   	push   %ebp
f0105946:	89 e5                	mov    %esp,%ebp
f0105948:	57                   	push   %edi
f0105949:	56                   	push   %esi
f010594a:	53                   	push   %ebx
f010594b:	83 ec 5c             	sub    $0x5c,%esp
f010594e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105954:	c7 03 68 8d 10 f0    	movl   $0xf0108d68,(%ebx)
	info->eip_line = 0;
f010595a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105961:	c7 43 08 68 8d 10 f0 	movl   $0xf0108d68,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105968:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010596f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105972:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105979:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010597f:	0f 87 c6 00 00 00    	ja     f0105a4b <debuginfo_eip+0x106>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd,sizeof(struct UserStabData),PTE_U)<0)return -1;
f0105985:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010598c:	00 
f010598d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105994:	00 
f0105995:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010599c:	00 
f010599d:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f01059a2:	89 04 24             	mov    %eax,(%esp)
f01059a5:	e8 47 ec ff ff       	call   f01045f1 <user_mem_check>
f01059aa:	85 c0                	test   %eax,%eax
f01059ac:	0f 88 4d 02 00 00    	js     f0105bff <debuginfo_eip+0x2ba>
		stabs = usd->stabs;
f01059b2:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01059b8:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01059bb:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01059c1:	a1 08 00 20 00       	mov    0x200008,%eax
f01059c6:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01059c9:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01059cf:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
f01059d2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01059d9:	00 
f01059da:	89 f8                	mov    %edi,%eax
f01059dc:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f01059df:	c1 f8 02             	sar    $0x2,%eax
f01059e2:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01059e5:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01059e8:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01059eb:	89 d1                	mov    %edx,%ecx
f01059ed:	c1 e1 08             	shl    $0x8,%ecx
f01059f0:	01 ca                	add    %ecx,%edx
f01059f2:	89 d1                	mov    %edx,%ecx
f01059f4:	c1 e1 10             	shl    $0x10,%ecx
f01059f7:	01 ca                	add    %ecx,%edx
f01059f9:	8d 04 50             	lea    (%eax,%edx,2),%eax
f01059fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a00:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105a03:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105a07:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f0105a0c:	89 04 24             	mov    %eax,(%esp)
f0105a0f:	e8 dd eb ff ff       	call   f01045f1 <user_mem_check>
f0105a14:	85 c0                	test   %eax,%eax
f0105a16:	0f 88 ea 01 00 00    	js     f0105c06 <debuginfo_eip+0x2c1>
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
f0105a1c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105a23:	00 
f0105a24:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105a27:	2b 45 bc             	sub    -0x44(%ebp),%eax
f0105a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a2e:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105a31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a35:	a1 10 b0 20 f0       	mov    0xf020b010,%eax
f0105a3a:	89 04 24             	mov    %eax,(%esp)
f0105a3d:	e8 af eb ff ff       	call   f01045f1 <user_mem_check>
f0105a42:	85 c0                	test   %eax,%eax
f0105a44:	79 1f                	jns    f0105a65 <debuginfo_eip+0x120>
f0105a46:	e9 c2 01 00 00       	jmp    f0105c0d <debuginfo_eip+0x2c8>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105a4b:	c7 45 c0 a0 dd 11 f0 	movl   $0xf011dda0,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105a52:	c7 45 bc 39 3a 11 f0 	movl   $0xf0113a39,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105a59:	bf 38 3a 11 f0       	mov    $0xf0113a38,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105a5e:	c7 45 c4 74 8f 10 f0 	movl   $0xf0108f74,-0x3c(%ebp)
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105a65:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105a68:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0105a6b:	0f 83 a3 01 00 00    	jae    f0105c14 <debuginfo_eip+0x2cf>
f0105a71:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f0105a75:	0f 85 a0 01 00 00    	jne    f0105c1b <debuginfo_eip+0x2d6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105a7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105a82:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105a85:	c1 ff 02             	sar    $0x2,%edi
f0105a88:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0105a8b:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0105a8e:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0105a91:	89 c2                	mov    %eax,%edx
f0105a93:	c1 e2 08             	shl    $0x8,%edx
f0105a96:	01 d0                	add    %edx,%eax
f0105a98:	89 c2                	mov    %eax,%edx
f0105a9a:	c1 e2 10             	shl    $0x10,%edx
f0105a9d:	01 d0                	add    %edx,%eax
f0105a9f:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f0105aa3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105aaa:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105ab1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105ab4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105ab7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105aba:	e8 8d fd ff ff       	call   f010584c <stab_binsearch>
	if (lfile == 0)
f0105abf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ac2:	85 c0                	test   %eax,%eax
f0105ac4:	0f 84 58 01 00 00    	je     f0105c22 <debuginfo_eip+0x2dd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105aca:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105acd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ad0:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105ad3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105ad7:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105ade:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105ae1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105ae4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105ae7:	e8 60 fd ff ff       	call   f010584c <stab_binsearch>

	if (lfun <= rfun) {
f0105aec:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105aef:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105af2:	39 d0                	cmp    %edx,%eax
f0105af4:	7f 32                	jg     f0105b28 <debuginfo_eip+0x1e3>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105af6:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105af9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105afc:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0105aff:	8b 39                	mov    (%ecx),%edi
f0105b01:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105b04:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105b07:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105b0a:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105b0d:	73 09                	jae    f0105b18 <debuginfo_eip+0x1d3>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105b0f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105b12:	03 7d bc             	add    -0x44(%ebp),%edi
f0105b15:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105b18:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105b1b:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105b1e:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105b20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105b23:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105b26:	eb 0f                	jmp    f0105b37 <debuginfo_eip+0x1f2>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105b28:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105b31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b34:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105b37:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105b3e:	00 
f0105b3f:	8b 43 08             	mov    0x8(%ebx),%eax
f0105b42:	89 04 24             	mov    %eax,(%esp)
f0105b45:	e8 8c 08 00 00       	call   f01063d6 <strfind>
f0105b4a:	2b 43 08             	sub    0x8(%ebx),%eax
f0105b4d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105b50:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b54:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105b5b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105b5e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105b61:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105b64:	e8 e3 fc ff ff       	call   f010584c <stab_binsearch>
	if (lline <= rline){
f0105b69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105b6c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105b6f:	0f 8f b4 00 00 00    	jg     f0105c29 <debuginfo_eip+0x2e4>
		info->eip_line = stabs[lline].n_desc;
f0105b75:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105b78:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105b7b:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0105b80:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105b83:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105b86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105b89:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105b8c:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f0105b90:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105b93:	eb 04                	jmp    f0105b99 <debuginfo_eip+0x254>
f0105b95:	48                   	dec    %eax
f0105b96:	83 ea 0c             	sub    $0xc,%edx
f0105b99:	89 c7                	mov    %eax,%edi
f0105b9b:	39 c6                	cmp    %eax,%esi
f0105b9d:	7f 28                	jg     f0105bc7 <debuginfo_eip+0x282>
	       && stabs[lline].n_type != N_SOL
f0105b9f:	8a 4a fc             	mov    -0x4(%edx),%cl
f0105ba2:	80 f9 84             	cmp    $0x84,%cl
f0105ba5:	0f 84 99 00 00 00    	je     f0105c44 <debuginfo_eip+0x2ff>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105bab:	80 f9 64             	cmp    $0x64,%cl
f0105bae:	75 e5                	jne    f0105b95 <debuginfo_eip+0x250>
f0105bb0:	83 3a 00             	cmpl   $0x0,(%edx)
f0105bb3:	74 e0                	je     f0105b95 <debuginfo_eip+0x250>
f0105bb5:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105bb8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105bbb:	e9 8a 00 00 00       	jmp    f0105c4a <debuginfo_eip+0x305>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105bc0:	03 45 bc             	add    -0x44(%ebp),%eax
f0105bc3:	89 03                	mov    %eax,(%ebx)
f0105bc5:	eb 03                	jmp    f0105bca <debuginfo_eip+0x285>
f0105bc7:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105bca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105bcd:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105bd0:	39 f2                	cmp    %esi,%edx
f0105bd2:	7d 5c                	jge    f0105c30 <debuginfo_eip+0x2eb>
		for (lline = lfun + 1;
f0105bd4:	42                   	inc    %edx
f0105bd5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105bd8:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105bda:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105bdd:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105be0:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105be4:	eb 03                	jmp    f0105be9 <debuginfo_eip+0x2a4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105be6:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105be9:	39 f0                	cmp    %esi,%eax
f0105beb:	7d 4a                	jge    f0105c37 <debuginfo_eip+0x2f2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105bed:	8a 0a                	mov    (%edx),%cl
f0105bef:	40                   	inc    %eax
f0105bf0:	83 c2 0c             	add    $0xc,%edx
f0105bf3:	80 f9 a0             	cmp    $0xa0,%cl
f0105bf6:	74 ee                	je     f0105be6 <debuginfo_eip+0x2a1>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105bf8:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bfd:	eb 3d                	jmp    f0105c3c <debuginfo_eip+0x2f7>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd,sizeof(struct UserStabData),PTE_U)<0)return -1;
f0105bff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c04:	eb 36                	jmp    f0105c3c <debuginfo_eip+0x2f7>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv,stabs,stab_end-stabs,PTE_U)<0)return -1;
f0105c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c0b:	eb 2f                	jmp    f0105c3c <debuginfo_eip+0x2f7>
		if (user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)<0)return -1;
f0105c0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c12:	eb 28                	jmp    f0105c3c <debuginfo_eip+0x2f7>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105c14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c19:	eb 21                	jmp    f0105c3c <debuginfo_eip+0x2f7>
f0105c1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c20:	eb 1a                	jmp    f0105c3c <debuginfo_eip+0x2f7>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105c22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c27:	eb 13                	jmp    f0105c3c <debuginfo_eip+0x2f7>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline){
		info->eip_line = stabs[lline].n_desc;
	}
	else return -1;
f0105c29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c2e:	eb 0c                	jmp    f0105c3c <debuginfo_eip+0x2f7>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105c30:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c35:	eb 05                	jmp    f0105c3c <debuginfo_eip+0x2f7>
f0105c37:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c3c:	83 c4 5c             	add    $0x5c,%esp
f0105c3f:	5b                   	pop    %ebx
f0105c40:	5e                   	pop    %esi
f0105c41:	5f                   	pop    %edi
f0105c42:	5d                   	pop    %ebp
f0105c43:	c3                   	ret    
f0105c44:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105c47:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105c4a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105c4d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105c50:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105c53:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105c56:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105c59:	39 d0                	cmp    %edx,%eax
f0105c5b:	0f 82 5f ff ff ff    	jb     f0105bc0 <debuginfo_eip+0x27b>
f0105c61:	e9 64 ff ff ff       	jmp    f0105bca <debuginfo_eip+0x285>
	...

f0105c68 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105c68:	55                   	push   %ebp
f0105c69:	89 e5                	mov    %esp,%ebp
f0105c6b:	57                   	push   %edi
f0105c6c:	56                   	push   %esi
f0105c6d:	53                   	push   %ebx
f0105c6e:	83 ec 3c             	sub    $0x3c,%esp
f0105c71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c74:	89 d7                	mov    %edx,%edi
f0105c76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c79:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105c82:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105c85:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105c88:	85 c0                	test   %eax,%eax
f0105c8a:	75 08                	jne    f0105c94 <printnum+0x2c>
f0105c8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105c8f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105c92:	77 57                	ja     f0105ceb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105c94:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105c98:	4b                   	dec    %ebx
f0105c99:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105c9d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ca0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ca4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105ca8:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105cac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105cb3:	00 
f0105cb4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105cb7:	89 04 24             	mov    %eax,(%esp)
f0105cba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cc1:	e8 1e 09 00 00       	call   f01065e4 <__udivdi3>
f0105cc6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105cca:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105cce:	89 04 24             	mov    %eax,(%esp)
f0105cd1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105cd5:	89 fa                	mov    %edi,%edx
f0105cd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105cda:	e8 89 ff ff ff       	call   f0105c68 <printnum>
f0105cdf:	eb 0f                	jmp    f0105cf0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105ce1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ce5:	89 34 24             	mov    %esi,(%esp)
f0105ce8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105ceb:	4b                   	dec    %ebx
f0105cec:	85 db                	test   %ebx,%ebx
f0105cee:	7f f1                	jg     f0105ce1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105cf0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105cf4:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105cf8:	8b 45 10             	mov    0x10(%ebp),%eax
f0105cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105cff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105d06:	00 
f0105d07:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105d0a:	89 04 24             	mov    %eax,(%esp)
f0105d0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d14:	e8 eb 09 00 00       	call   f0106704 <__umoddi3>
f0105d19:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d1d:	0f be 80 72 8d 10 f0 	movsbl -0xfef728e(%eax),%eax
f0105d24:	89 04 24             	mov    %eax,(%esp)
f0105d27:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105d2a:	83 c4 3c             	add    $0x3c,%esp
f0105d2d:	5b                   	pop    %ebx
f0105d2e:	5e                   	pop    %esi
f0105d2f:	5f                   	pop    %edi
f0105d30:	5d                   	pop    %ebp
f0105d31:	c3                   	ret    

f0105d32 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105d32:	55                   	push   %ebp
f0105d33:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105d35:	83 fa 01             	cmp    $0x1,%edx
f0105d38:	7e 0e                	jle    f0105d48 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105d3a:	8b 10                	mov    (%eax),%edx
f0105d3c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105d3f:	89 08                	mov    %ecx,(%eax)
f0105d41:	8b 02                	mov    (%edx),%eax
f0105d43:	8b 52 04             	mov    0x4(%edx),%edx
f0105d46:	eb 22                	jmp    f0105d6a <getuint+0x38>
	else if (lflag)
f0105d48:	85 d2                	test   %edx,%edx
f0105d4a:	74 10                	je     f0105d5c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105d4c:	8b 10                	mov    (%eax),%edx
f0105d4e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105d51:	89 08                	mov    %ecx,(%eax)
f0105d53:	8b 02                	mov    (%edx),%eax
f0105d55:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d5a:	eb 0e                	jmp    f0105d6a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105d5c:	8b 10                	mov    (%eax),%edx
f0105d5e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105d61:	89 08                	mov    %ecx,(%eax)
f0105d63:	8b 02                	mov    (%edx),%eax
f0105d65:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105d6a:	5d                   	pop    %ebp
f0105d6b:	c3                   	ret    

f0105d6c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105d6c:	55                   	push   %ebp
f0105d6d:	89 e5                	mov    %esp,%ebp
f0105d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105d72:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105d75:	8b 10                	mov    (%eax),%edx
f0105d77:	3b 50 04             	cmp    0x4(%eax),%edx
f0105d7a:	73 08                	jae    f0105d84 <sprintputch+0x18>
		*b->buf++ = ch;
f0105d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d7f:	88 0a                	mov    %cl,(%edx)
f0105d81:	42                   	inc    %edx
f0105d82:	89 10                	mov    %edx,(%eax)
}
f0105d84:	5d                   	pop    %ebp
f0105d85:	c3                   	ret    

f0105d86 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105d86:	55                   	push   %ebp
f0105d87:	89 e5                	mov    %esp,%ebp
f0105d89:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105d8c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105d8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d93:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d96:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105da1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105da4:	89 04 24             	mov    %eax,(%esp)
f0105da7:	e8 02 00 00 00       	call   f0105dae <vprintfmt>
	va_end(ap);
}
f0105dac:	c9                   	leave  
f0105dad:	c3                   	ret    

f0105dae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105dae:	55                   	push   %ebp
f0105daf:	89 e5                	mov    %esp,%ebp
f0105db1:	57                   	push   %edi
f0105db2:	56                   	push   %esi
f0105db3:	53                   	push   %ebx
f0105db4:	83 ec 4c             	sub    $0x4c,%esp
f0105db7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105dba:	8b 75 10             	mov    0x10(%ebp),%esi
f0105dbd:	eb 12                	jmp    f0105dd1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105dbf:	85 c0                	test   %eax,%eax
f0105dc1:	0f 84 6b 03 00 00    	je     f0106132 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0105dc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105dcb:	89 04 24             	mov    %eax,(%esp)
f0105dce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105dd1:	0f b6 06             	movzbl (%esi),%eax
f0105dd4:	46                   	inc    %esi
f0105dd5:	83 f8 25             	cmp    $0x25,%eax
f0105dd8:	75 e5                	jne    f0105dbf <vprintfmt+0x11>
f0105dda:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105dde:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105de5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105dea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105df1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105df6:	eb 26                	jmp    f0105e1e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105df8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105dfb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105dff:	eb 1d                	jmp    f0105e1e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e01:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105e04:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105e08:	eb 14                	jmp    f0105e1e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e0a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105e0d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105e14:	eb 08                	jmp    f0105e1e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105e16:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105e19:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e1e:	0f b6 06             	movzbl (%esi),%eax
f0105e21:	8d 56 01             	lea    0x1(%esi),%edx
f0105e24:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105e27:	8a 16                	mov    (%esi),%dl
f0105e29:	83 ea 23             	sub    $0x23,%edx
f0105e2c:	80 fa 55             	cmp    $0x55,%dl
f0105e2f:	0f 87 e1 02 00 00    	ja     f0106116 <vprintfmt+0x368>
f0105e35:	0f b6 d2             	movzbl %dl,%edx
f0105e38:	ff 24 95 f0 8d 10 f0 	jmp    *-0xfef7210(,%edx,4)
f0105e3f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105e42:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105e47:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105e4a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105e4e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105e51:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105e54:	83 fa 09             	cmp    $0x9,%edx
f0105e57:	77 2a                	ja     f0105e83 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105e59:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105e5a:	eb eb                	jmp    f0105e47 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105e5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e5f:	8d 50 04             	lea    0x4(%eax),%edx
f0105e62:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e65:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e67:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105e6a:	eb 17                	jmp    f0105e83 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105e6c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105e70:	78 98                	js     f0105e0a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e72:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105e75:	eb a7                	jmp    f0105e1e <vprintfmt+0x70>
f0105e77:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105e7a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105e81:	eb 9b                	jmp    f0105e1e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105e83:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105e87:	79 95                	jns    f0105e1e <vprintfmt+0x70>
f0105e89:	eb 8b                	jmp    f0105e16 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105e8b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105e8f:	eb 8d                	jmp    f0105e1e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105e91:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e94:	8d 50 04             	lea    0x4(%eax),%edx
f0105e97:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e9e:	8b 00                	mov    (%eax),%eax
f0105ea0:	89 04 24             	mov    %eax,(%esp)
f0105ea3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ea6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105ea9:	e9 23 ff ff ff       	jmp    f0105dd1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105eae:	8b 45 14             	mov    0x14(%ebp),%eax
f0105eb1:	8d 50 04             	lea    0x4(%eax),%edx
f0105eb4:	89 55 14             	mov    %edx,0x14(%ebp)
f0105eb7:	8b 00                	mov    (%eax),%eax
f0105eb9:	85 c0                	test   %eax,%eax
f0105ebb:	79 02                	jns    f0105ebf <vprintfmt+0x111>
f0105ebd:	f7 d8                	neg    %eax
f0105ebf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105ec1:	83 f8 06             	cmp    $0x6,%eax
f0105ec4:	7f 0b                	jg     f0105ed1 <vprintfmt+0x123>
f0105ec6:	8b 04 85 48 8f 10 f0 	mov    -0xfef70b8(,%eax,4),%eax
f0105ecd:	85 c0                	test   %eax,%eax
f0105ecf:	75 23                	jne    f0105ef4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105ed1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ed5:	c7 44 24 08 8a 8d 10 	movl   $0xf0108d8a,0x8(%esp)
f0105edc:	f0 
f0105edd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ee1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ee4:	89 04 24             	mov    %eax,(%esp)
f0105ee7:	e8 9a fe ff ff       	call   f0105d86 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105eec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105eef:	e9 dd fe ff ff       	jmp    f0105dd1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105ef4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ef8:	c7 44 24 08 f7 84 10 	movl   $0xf01084f7,0x8(%esp)
f0105eff:	f0 
f0105f00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f04:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f07:	89 14 24             	mov    %edx,(%esp)
f0105f0a:	e8 77 fe ff ff       	call   f0105d86 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105f12:	e9 ba fe ff ff       	jmp    f0105dd1 <vprintfmt+0x23>
f0105f17:	89 f9                	mov    %edi,%ecx
f0105f19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f1c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105f1f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f22:	8d 50 04             	lea    0x4(%eax),%edx
f0105f25:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f28:	8b 30                	mov    (%eax),%esi
f0105f2a:	85 f6                	test   %esi,%esi
f0105f2c:	75 05                	jne    f0105f33 <vprintfmt+0x185>
				p = "(null)";
f0105f2e:	be 83 8d 10 f0       	mov    $0xf0108d83,%esi
			if (width > 0 && padc != '-')
f0105f33:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105f37:	0f 8e 84 00 00 00    	jle    f0105fc1 <vprintfmt+0x213>
f0105f3d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105f41:	74 7e                	je     f0105fc1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105f43:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105f47:	89 34 24             	mov    %esi,(%esp)
f0105f4a:	e8 53 03 00 00       	call   f01062a2 <strnlen>
f0105f4f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105f52:	29 c2                	sub    %eax,%edx
f0105f54:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105f57:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105f5b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105f5e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105f61:	89 de                	mov    %ebx,%esi
f0105f63:	89 d3                	mov    %edx,%ebx
f0105f65:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105f67:	eb 0b                	jmp    f0105f74 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105f69:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f6d:	89 3c 24             	mov    %edi,(%esp)
f0105f70:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105f73:	4b                   	dec    %ebx
f0105f74:	85 db                	test   %ebx,%ebx
f0105f76:	7f f1                	jg     f0105f69 <vprintfmt+0x1bb>
f0105f78:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105f7b:	89 f3                	mov    %esi,%ebx
f0105f7d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f83:	85 c0                	test   %eax,%eax
f0105f85:	79 05                	jns    f0105f8c <vprintfmt+0x1de>
f0105f87:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105f8f:	29 c2                	sub    %eax,%edx
f0105f91:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105f94:	eb 2b                	jmp    f0105fc1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105f96:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105f9a:	74 18                	je     f0105fb4 <vprintfmt+0x206>
f0105f9c:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105f9f:	83 fa 5e             	cmp    $0x5e,%edx
f0105fa2:	76 10                	jbe    f0105fb4 <vprintfmt+0x206>
					putch('?', putdat);
f0105fa4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105fa8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105faf:	ff 55 08             	call   *0x8(%ebp)
f0105fb2:	eb 0a                	jmp    f0105fbe <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105fb4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105fb8:	89 04 24             	mov    %eax,(%esp)
f0105fbb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105fbe:	ff 4d e4             	decl   -0x1c(%ebp)
f0105fc1:	0f be 06             	movsbl (%esi),%eax
f0105fc4:	46                   	inc    %esi
f0105fc5:	85 c0                	test   %eax,%eax
f0105fc7:	74 21                	je     f0105fea <vprintfmt+0x23c>
f0105fc9:	85 ff                	test   %edi,%edi
f0105fcb:	78 c9                	js     f0105f96 <vprintfmt+0x1e8>
f0105fcd:	4f                   	dec    %edi
f0105fce:	79 c6                	jns    f0105f96 <vprintfmt+0x1e8>
f0105fd0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105fd3:	89 de                	mov    %ebx,%esi
f0105fd5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105fd8:	eb 18                	jmp    f0105ff2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105fda:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105fde:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105fe5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105fe7:	4b                   	dec    %ebx
f0105fe8:	eb 08                	jmp    f0105ff2 <vprintfmt+0x244>
f0105fea:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105fed:	89 de                	mov    %ebx,%esi
f0105fef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105ff2:	85 db                	test   %ebx,%ebx
f0105ff4:	7f e4                	jg     f0105fda <vprintfmt+0x22c>
f0105ff6:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105ff9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ffb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105ffe:	e9 ce fd ff ff       	jmp    f0105dd1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0106003:	83 f9 01             	cmp    $0x1,%ecx
f0106006:	7e 10                	jle    f0106018 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0106008:	8b 45 14             	mov    0x14(%ebp),%eax
f010600b:	8d 50 08             	lea    0x8(%eax),%edx
f010600e:	89 55 14             	mov    %edx,0x14(%ebp)
f0106011:	8b 30                	mov    (%eax),%esi
f0106013:	8b 78 04             	mov    0x4(%eax),%edi
f0106016:	eb 26                	jmp    f010603e <vprintfmt+0x290>
	else if (lflag)
f0106018:	85 c9                	test   %ecx,%ecx
f010601a:	74 12                	je     f010602e <vprintfmt+0x280>
		return va_arg(*ap, long);
f010601c:	8b 45 14             	mov    0x14(%ebp),%eax
f010601f:	8d 50 04             	lea    0x4(%eax),%edx
f0106022:	89 55 14             	mov    %edx,0x14(%ebp)
f0106025:	8b 30                	mov    (%eax),%esi
f0106027:	89 f7                	mov    %esi,%edi
f0106029:	c1 ff 1f             	sar    $0x1f,%edi
f010602c:	eb 10                	jmp    f010603e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010602e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106031:	8d 50 04             	lea    0x4(%eax),%edx
f0106034:	89 55 14             	mov    %edx,0x14(%ebp)
f0106037:	8b 30                	mov    (%eax),%esi
f0106039:	89 f7                	mov    %esi,%edi
f010603b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010603e:	85 ff                	test   %edi,%edi
f0106040:	78 0a                	js     f010604c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0106042:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106047:	e9 8c 00 00 00       	jmp    f01060d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010604c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106050:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0106057:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010605a:	f7 de                	neg    %esi
f010605c:	83 d7 00             	adc    $0x0,%edi
f010605f:	f7 df                	neg    %edi
			}
			base = 10;
f0106061:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106066:	eb 70                	jmp    f01060d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0106068:	89 ca                	mov    %ecx,%edx
f010606a:	8d 45 14             	lea    0x14(%ebp),%eax
f010606d:	e8 c0 fc ff ff       	call   f0105d32 <getuint>
f0106072:	89 c6                	mov    %eax,%esi
f0106074:	89 d7                	mov    %edx,%edi
			base = 10;
f0106076:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010607b:	eb 5b                	jmp    f01060d8 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f010607d:	89 ca                	mov    %ecx,%edx
f010607f:	8d 45 14             	lea    0x14(%ebp),%eax
f0106082:	e8 ab fc ff ff       	call   f0105d32 <getuint>
f0106087:	89 c6                	mov    %eax,%esi
f0106089:	89 d7                	mov    %edx,%edi
			base = 8;
f010608b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0106090:	eb 46                	jmp    f01060d8 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0106092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106096:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010609d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01060a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01060ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01060ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01060b1:	8d 50 04             	lea    0x4(%eax),%edx
f01060b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01060b7:	8b 30                	mov    (%eax),%esi
f01060b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01060be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01060c3:	eb 13                	jmp    f01060d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01060c5:	89 ca                	mov    %ecx,%edx
f01060c7:	8d 45 14             	lea    0x14(%ebp),%eax
f01060ca:	e8 63 fc ff ff       	call   f0105d32 <getuint>
f01060cf:	89 c6                	mov    %eax,%esi
f01060d1:	89 d7                	mov    %edx,%edi
			base = 16;
f01060d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01060d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01060dc:	89 54 24 10          	mov    %edx,0x10(%esp)
f01060e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01060e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01060e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01060eb:	89 34 24             	mov    %esi,(%esp)
f01060ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01060f2:	89 da                	mov    %ebx,%edx
f01060f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01060f7:	e8 6c fb ff ff       	call   f0105c68 <printnum>
			break;
f01060fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01060ff:	e9 cd fc ff ff       	jmp    f0105dd1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0106104:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106108:	89 04 24             	mov    %eax,(%esp)
f010610b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010610e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0106111:	e9 bb fc ff ff       	jmp    f0105dd1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0106116:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010611a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106121:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106124:	eb 01                	jmp    f0106127 <vprintfmt+0x379>
f0106126:	4e                   	dec    %esi
f0106127:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010612b:	75 f9                	jne    f0106126 <vprintfmt+0x378>
f010612d:	e9 9f fc ff ff       	jmp    f0105dd1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0106132:	83 c4 4c             	add    $0x4c,%esp
f0106135:	5b                   	pop    %ebx
f0106136:	5e                   	pop    %esi
f0106137:	5f                   	pop    %edi
f0106138:	5d                   	pop    %ebp
f0106139:	c3                   	ret    

f010613a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010613a:	55                   	push   %ebp
f010613b:	89 e5                	mov    %esp,%ebp
f010613d:	83 ec 28             	sub    $0x28,%esp
f0106140:	8b 45 08             	mov    0x8(%ebp),%eax
f0106143:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0106146:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106149:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010614d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106150:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0106157:	85 c0                	test   %eax,%eax
f0106159:	74 30                	je     f010618b <vsnprintf+0x51>
f010615b:	85 d2                	test   %edx,%edx
f010615d:	7e 33                	jle    f0106192 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010615f:	8b 45 14             	mov    0x14(%ebp),%eax
f0106162:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106166:	8b 45 10             	mov    0x10(%ebp),%eax
f0106169:	89 44 24 08          	mov    %eax,0x8(%esp)
f010616d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0106170:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106174:	c7 04 24 6c 5d 10 f0 	movl   $0xf0105d6c,(%esp)
f010617b:	e8 2e fc ff ff       	call   f0105dae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0106180:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106183:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0106186:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106189:	eb 0c                	jmp    f0106197 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010618b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106190:	eb 05                	jmp    f0106197 <vsnprintf+0x5d>
f0106192:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0106197:	c9                   	leave  
f0106198:	c3                   	ret    

f0106199 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0106199:	55                   	push   %ebp
f010619a:	89 e5                	mov    %esp,%ebp
f010619c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010619f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01061a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01061a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01061b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01061b7:	89 04 24             	mov    %eax,(%esp)
f01061ba:	e8 7b ff ff ff       	call   f010613a <vsnprintf>
	va_end(ap);

	return rc;
}
f01061bf:	c9                   	leave  
f01061c0:	c3                   	ret    
f01061c1:	00 00                	add    %al,(%eax)
	...

f01061c4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01061c4:	55                   	push   %ebp
f01061c5:	89 e5                	mov    %esp,%ebp
f01061c7:	57                   	push   %edi
f01061c8:	56                   	push   %esi
f01061c9:	53                   	push   %ebx
f01061ca:	83 ec 1c             	sub    $0x1c,%esp
f01061cd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01061d0:	85 c0                	test   %eax,%eax
f01061d2:	74 10                	je     f01061e4 <readline+0x20>
		cprintf("%s", prompt);
f01061d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061d8:	c7 04 24 f7 84 10 f0 	movl   $0xf01084f7,(%esp)
f01061df:	e8 f2 ec ff ff       	call   f0104ed6 <cprintf>

	i = 0;
	echoing = iscons(0);
f01061e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01061eb:	e8 f4 a6 ff ff       	call   f01008e4 <iscons>
f01061f0:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01061f2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01061f7:	e8 d7 a6 ff ff       	call   f01008d3 <getchar>
f01061fc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01061fe:	85 c0                	test   %eax,%eax
f0106200:	79 17                	jns    f0106219 <readline+0x55>
			cprintf("read error: %e\n", c);
f0106202:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106206:	c7 04 24 64 8f 10 f0 	movl   $0xf0108f64,(%esp)
f010620d:	e8 c4 ec ff ff       	call   f0104ed6 <cprintf>
			return NULL;
f0106212:	b8 00 00 00 00       	mov    $0x0,%eax
f0106217:	eb 69                	jmp    f0106282 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106219:	83 f8 08             	cmp    $0x8,%eax
f010621c:	74 05                	je     f0106223 <readline+0x5f>
f010621e:	83 f8 7f             	cmp    $0x7f,%eax
f0106221:	75 17                	jne    f010623a <readline+0x76>
f0106223:	85 f6                	test   %esi,%esi
f0106225:	7e 13                	jle    f010623a <readline+0x76>
			if (echoing)
f0106227:	85 ff                	test   %edi,%edi
f0106229:	74 0c                	je     f0106237 <readline+0x73>
				cputchar('\b');
f010622b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0106232:	e8 8c a6 ff ff       	call   f01008c3 <cputchar>
			i--;
f0106237:	4e                   	dec    %esi
f0106238:	eb bd                	jmp    f01061f7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010623a:	83 fb 1f             	cmp    $0x1f,%ebx
f010623d:	7e 1d                	jle    f010625c <readline+0x98>
f010623f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106245:	7f 15                	jg     f010625c <readline+0x98>
			if (echoing)
f0106247:	85 ff                	test   %edi,%edi
f0106249:	74 08                	je     f0106253 <readline+0x8f>
				cputchar(c);
f010624b:	89 1c 24             	mov    %ebx,(%esp)
f010624e:	e8 70 a6 ff ff       	call   f01008c3 <cputchar>
			buf[i++] = c;
f0106253:	88 9e a0 b8 20 f0    	mov    %bl,-0xfdf4760(%esi)
f0106259:	46                   	inc    %esi
f010625a:	eb 9b                	jmp    f01061f7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010625c:	83 fb 0a             	cmp    $0xa,%ebx
f010625f:	74 05                	je     f0106266 <readline+0xa2>
f0106261:	83 fb 0d             	cmp    $0xd,%ebx
f0106264:	75 91                	jne    f01061f7 <readline+0x33>
			if (echoing)
f0106266:	85 ff                	test   %edi,%edi
f0106268:	74 0c                	je     f0106276 <readline+0xb2>
				cputchar('\n');
f010626a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0106271:	e8 4d a6 ff ff       	call   f01008c3 <cputchar>
			buf[i] = 0;
f0106276:	c6 86 a0 b8 20 f0 00 	movb   $0x0,-0xfdf4760(%esi)
			return buf;
f010627d:	b8 a0 b8 20 f0       	mov    $0xf020b8a0,%eax
		}
	}
}
f0106282:	83 c4 1c             	add    $0x1c,%esp
f0106285:	5b                   	pop    %ebx
f0106286:	5e                   	pop    %esi
f0106287:	5f                   	pop    %edi
f0106288:	5d                   	pop    %ebp
f0106289:	c3                   	ret    
	...

f010628c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010628c:	55                   	push   %ebp
f010628d:	89 e5                	mov    %esp,%ebp
f010628f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106292:	b8 00 00 00 00       	mov    $0x0,%eax
f0106297:	eb 01                	jmp    f010629a <strlen+0xe>
		n++;
f0106299:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010629a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010629e:	75 f9                	jne    f0106299 <strlen+0xd>
		n++;
	return n;
}
f01062a0:	5d                   	pop    %ebp
f01062a1:	c3                   	ret    

f01062a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01062a2:	55                   	push   %ebp
f01062a3:	89 e5                	mov    %esp,%ebp
f01062a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01062a8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01062ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01062b0:	eb 01                	jmp    f01062b3 <strnlen+0x11>
		n++;
f01062b2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01062b3:	39 d0                	cmp    %edx,%eax
f01062b5:	74 06                	je     f01062bd <strnlen+0x1b>
f01062b7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01062bb:	75 f5                	jne    f01062b2 <strnlen+0x10>
		n++;
	return n;
}
f01062bd:	5d                   	pop    %ebp
f01062be:	c3                   	ret    

f01062bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01062bf:	55                   	push   %ebp
f01062c0:	89 e5                	mov    %esp,%ebp
f01062c2:	53                   	push   %ebx
f01062c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01062c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01062c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01062ce:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01062d1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01062d4:	42                   	inc    %edx
f01062d5:	84 c9                	test   %cl,%cl
f01062d7:	75 f5                	jne    f01062ce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01062d9:	5b                   	pop    %ebx
f01062da:	5d                   	pop    %ebp
f01062db:	c3                   	ret    

f01062dc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01062dc:	55                   	push   %ebp
f01062dd:	89 e5                	mov    %esp,%ebp
f01062df:	53                   	push   %ebx
f01062e0:	83 ec 08             	sub    $0x8,%esp
f01062e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01062e6:	89 1c 24             	mov    %ebx,(%esp)
f01062e9:	e8 9e ff ff ff       	call   f010628c <strlen>
	strcpy(dst + len, src);
f01062ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01062f1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01062f5:	01 d8                	add    %ebx,%eax
f01062f7:	89 04 24             	mov    %eax,(%esp)
f01062fa:	e8 c0 ff ff ff       	call   f01062bf <strcpy>
	return dst;
}
f01062ff:	89 d8                	mov    %ebx,%eax
f0106301:	83 c4 08             	add    $0x8,%esp
f0106304:	5b                   	pop    %ebx
f0106305:	5d                   	pop    %ebp
f0106306:	c3                   	ret    

f0106307 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106307:	55                   	push   %ebp
f0106308:	89 e5                	mov    %esp,%ebp
f010630a:	56                   	push   %esi
f010630b:	53                   	push   %ebx
f010630c:	8b 45 08             	mov    0x8(%ebp),%eax
f010630f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106312:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106315:	b9 00 00 00 00       	mov    $0x0,%ecx
f010631a:	eb 0c                	jmp    f0106328 <strncpy+0x21>
		*dst++ = *src;
f010631c:	8a 1a                	mov    (%edx),%bl
f010631e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106321:	80 3a 01             	cmpb   $0x1,(%edx)
f0106324:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106327:	41                   	inc    %ecx
f0106328:	39 f1                	cmp    %esi,%ecx
f010632a:	75 f0                	jne    f010631c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010632c:	5b                   	pop    %ebx
f010632d:	5e                   	pop    %esi
f010632e:	5d                   	pop    %ebp
f010632f:	c3                   	ret    

f0106330 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106330:	55                   	push   %ebp
f0106331:	89 e5                	mov    %esp,%ebp
f0106333:	56                   	push   %esi
f0106334:	53                   	push   %ebx
f0106335:	8b 75 08             	mov    0x8(%ebp),%esi
f0106338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010633b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010633e:	85 d2                	test   %edx,%edx
f0106340:	75 0a                	jne    f010634c <strlcpy+0x1c>
f0106342:	89 f0                	mov    %esi,%eax
f0106344:	eb 1a                	jmp    f0106360 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0106346:	88 18                	mov    %bl,(%eax)
f0106348:	40                   	inc    %eax
f0106349:	41                   	inc    %ecx
f010634a:	eb 02                	jmp    f010634e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010634c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010634e:	4a                   	dec    %edx
f010634f:	74 0a                	je     f010635b <strlcpy+0x2b>
f0106351:	8a 19                	mov    (%ecx),%bl
f0106353:	84 db                	test   %bl,%bl
f0106355:	75 ef                	jne    f0106346 <strlcpy+0x16>
f0106357:	89 c2                	mov    %eax,%edx
f0106359:	eb 02                	jmp    f010635d <strlcpy+0x2d>
f010635b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010635d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0106360:	29 f0                	sub    %esi,%eax
}
f0106362:	5b                   	pop    %ebx
f0106363:	5e                   	pop    %esi
f0106364:	5d                   	pop    %ebp
f0106365:	c3                   	ret    

f0106366 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106366:	55                   	push   %ebp
f0106367:	89 e5                	mov    %esp,%ebp
f0106369:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010636c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010636f:	eb 02                	jmp    f0106373 <strcmp+0xd>
		p++, q++;
f0106371:	41                   	inc    %ecx
f0106372:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0106373:	8a 01                	mov    (%ecx),%al
f0106375:	84 c0                	test   %al,%al
f0106377:	74 04                	je     f010637d <strcmp+0x17>
f0106379:	3a 02                	cmp    (%edx),%al
f010637b:	74 f4                	je     f0106371 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010637d:	0f b6 c0             	movzbl %al,%eax
f0106380:	0f b6 12             	movzbl (%edx),%edx
f0106383:	29 d0                	sub    %edx,%eax
}
f0106385:	5d                   	pop    %ebp
f0106386:	c3                   	ret    

f0106387 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106387:	55                   	push   %ebp
f0106388:	89 e5                	mov    %esp,%ebp
f010638a:	53                   	push   %ebx
f010638b:	8b 45 08             	mov    0x8(%ebp),%eax
f010638e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106391:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0106394:	eb 03                	jmp    f0106399 <strncmp+0x12>
		n--, p++, q++;
f0106396:	4a                   	dec    %edx
f0106397:	40                   	inc    %eax
f0106398:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106399:	85 d2                	test   %edx,%edx
f010639b:	74 14                	je     f01063b1 <strncmp+0x2a>
f010639d:	8a 18                	mov    (%eax),%bl
f010639f:	84 db                	test   %bl,%bl
f01063a1:	74 04                	je     f01063a7 <strncmp+0x20>
f01063a3:	3a 19                	cmp    (%ecx),%bl
f01063a5:	74 ef                	je     f0106396 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01063a7:	0f b6 00             	movzbl (%eax),%eax
f01063aa:	0f b6 11             	movzbl (%ecx),%edx
f01063ad:	29 d0                	sub    %edx,%eax
f01063af:	eb 05                	jmp    f01063b6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01063b1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01063b6:	5b                   	pop    %ebx
f01063b7:	5d                   	pop    %ebp
f01063b8:	c3                   	ret    

f01063b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01063b9:	55                   	push   %ebp
f01063ba:	89 e5                	mov    %esp,%ebp
f01063bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01063bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01063c2:	eb 05                	jmp    f01063c9 <strchr+0x10>
		if (*s == c)
f01063c4:	38 ca                	cmp    %cl,%dl
f01063c6:	74 0c                	je     f01063d4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01063c8:	40                   	inc    %eax
f01063c9:	8a 10                	mov    (%eax),%dl
f01063cb:	84 d2                	test   %dl,%dl
f01063cd:	75 f5                	jne    f01063c4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01063cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063d4:	5d                   	pop    %ebp
f01063d5:	c3                   	ret    

f01063d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01063d6:	55                   	push   %ebp
f01063d7:	89 e5                	mov    %esp,%ebp
f01063d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01063dc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01063df:	eb 05                	jmp    f01063e6 <strfind+0x10>
		if (*s == c)
f01063e1:	38 ca                	cmp    %cl,%dl
f01063e3:	74 07                	je     f01063ec <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01063e5:	40                   	inc    %eax
f01063e6:	8a 10                	mov    (%eax),%dl
f01063e8:	84 d2                	test   %dl,%dl
f01063ea:	75 f5                	jne    f01063e1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01063ec:	5d                   	pop    %ebp
f01063ed:	c3                   	ret    

f01063ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01063ee:	55                   	push   %ebp
f01063ef:	89 e5                	mov    %esp,%ebp
f01063f1:	57                   	push   %edi
f01063f2:	56                   	push   %esi
f01063f3:	53                   	push   %ebx
f01063f4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01063f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01063fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01063fd:	85 c9                	test   %ecx,%ecx
f01063ff:	74 30                	je     f0106431 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106401:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106407:	75 25                	jne    f010642e <memset+0x40>
f0106409:	f6 c1 03             	test   $0x3,%cl
f010640c:	75 20                	jne    f010642e <memset+0x40>
		c &= 0xFF;
f010640e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106411:	89 d3                	mov    %edx,%ebx
f0106413:	c1 e3 08             	shl    $0x8,%ebx
f0106416:	89 d6                	mov    %edx,%esi
f0106418:	c1 e6 18             	shl    $0x18,%esi
f010641b:	89 d0                	mov    %edx,%eax
f010641d:	c1 e0 10             	shl    $0x10,%eax
f0106420:	09 f0                	or     %esi,%eax
f0106422:	09 d0                	or     %edx,%eax
f0106424:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106426:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106429:	fc                   	cld    
f010642a:	f3 ab                	rep stos %eax,%es:(%edi)
f010642c:	eb 03                	jmp    f0106431 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010642e:	fc                   	cld    
f010642f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0106431:	89 f8                	mov    %edi,%eax
f0106433:	5b                   	pop    %ebx
f0106434:	5e                   	pop    %esi
f0106435:	5f                   	pop    %edi
f0106436:	5d                   	pop    %ebp
f0106437:	c3                   	ret    

f0106438 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106438:	55                   	push   %ebp
f0106439:	89 e5                	mov    %esp,%ebp
f010643b:	57                   	push   %edi
f010643c:	56                   	push   %esi
f010643d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106440:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106443:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106446:	39 c6                	cmp    %eax,%esi
f0106448:	73 34                	jae    f010647e <memmove+0x46>
f010644a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010644d:	39 d0                	cmp    %edx,%eax
f010644f:	73 2d                	jae    f010647e <memmove+0x46>
		s += n;
		d += n;
f0106451:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106454:	f6 c2 03             	test   $0x3,%dl
f0106457:	75 1b                	jne    f0106474 <memmove+0x3c>
f0106459:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010645f:	75 13                	jne    f0106474 <memmove+0x3c>
f0106461:	f6 c1 03             	test   $0x3,%cl
f0106464:	75 0e                	jne    f0106474 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106466:	83 ef 04             	sub    $0x4,%edi
f0106469:	8d 72 fc             	lea    -0x4(%edx),%esi
f010646c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010646f:	fd                   	std    
f0106470:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106472:	eb 07                	jmp    f010647b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106474:	4f                   	dec    %edi
f0106475:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106478:	fd                   	std    
f0106479:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010647b:	fc                   	cld    
f010647c:	eb 20                	jmp    f010649e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010647e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106484:	75 13                	jne    f0106499 <memmove+0x61>
f0106486:	a8 03                	test   $0x3,%al
f0106488:	75 0f                	jne    f0106499 <memmove+0x61>
f010648a:	f6 c1 03             	test   $0x3,%cl
f010648d:	75 0a                	jne    f0106499 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010648f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106492:	89 c7                	mov    %eax,%edi
f0106494:	fc                   	cld    
f0106495:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106497:	eb 05                	jmp    f010649e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106499:	89 c7                	mov    %eax,%edi
f010649b:	fc                   	cld    
f010649c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010649e:	5e                   	pop    %esi
f010649f:	5f                   	pop    %edi
f01064a0:	5d                   	pop    %ebp
f01064a1:	c3                   	ret    

f01064a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01064a2:	55                   	push   %ebp
f01064a3:	89 e5                	mov    %esp,%ebp
f01064a5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01064a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01064ab:	89 44 24 08          	mov    %eax,0x8(%esp)
f01064af:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01064b9:	89 04 24             	mov    %eax,(%esp)
f01064bc:	e8 77 ff ff ff       	call   f0106438 <memmove>
}
f01064c1:	c9                   	leave  
f01064c2:	c3                   	ret    

f01064c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01064c3:	55                   	push   %ebp
f01064c4:	89 e5                	mov    %esp,%ebp
f01064c6:	57                   	push   %edi
f01064c7:	56                   	push   %esi
f01064c8:	53                   	push   %ebx
f01064c9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01064cc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01064cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01064d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01064d7:	eb 16                	jmp    f01064ef <memcmp+0x2c>
		if (*s1 != *s2)
f01064d9:	8a 04 17             	mov    (%edi,%edx,1),%al
f01064dc:	42                   	inc    %edx
f01064dd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01064e1:	38 c8                	cmp    %cl,%al
f01064e3:	74 0a                	je     f01064ef <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01064e5:	0f b6 c0             	movzbl %al,%eax
f01064e8:	0f b6 c9             	movzbl %cl,%ecx
f01064eb:	29 c8                	sub    %ecx,%eax
f01064ed:	eb 09                	jmp    f01064f8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01064ef:	39 da                	cmp    %ebx,%edx
f01064f1:	75 e6                	jne    f01064d9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01064f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01064f8:	5b                   	pop    %ebx
f01064f9:	5e                   	pop    %esi
f01064fa:	5f                   	pop    %edi
f01064fb:	5d                   	pop    %ebp
f01064fc:	c3                   	ret    

f01064fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01064fd:	55                   	push   %ebp
f01064fe:	89 e5                	mov    %esp,%ebp
f0106500:	8b 45 08             	mov    0x8(%ebp),%eax
f0106503:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0106506:	89 c2                	mov    %eax,%edx
f0106508:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010650b:	eb 05                	jmp    f0106512 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f010650d:	38 08                	cmp    %cl,(%eax)
f010650f:	74 05                	je     f0106516 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106511:	40                   	inc    %eax
f0106512:	39 d0                	cmp    %edx,%eax
f0106514:	72 f7                	jb     f010650d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106516:	5d                   	pop    %ebp
f0106517:	c3                   	ret    

f0106518 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106518:	55                   	push   %ebp
f0106519:	89 e5                	mov    %esp,%ebp
f010651b:	57                   	push   %edi
f010651c:	56                   	push   %esi
f010651d:	53                   	push   %ebx
f010651e:	8b 55 08             	mov    0x8(%ebp),%edx
f0106521:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106524:	eb 01                	jmp    f0106527 <strtol+0xf>
		s++;
f0106526:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106527:	8a 02                	mov    (%edx),%al
f0106529:	3c 20                	cmp    $0x20,%al
f010652b:	74 f9                	je     f0106526 <strtol+0xe>
f010652d:	3c 09                	cmp    $0x9,%al
f010652f:	74 f5                	je     f0106526 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106531:	3c 2b                	cmp    $0x2b,%al
f0106533:	75 08                	jne    f010653d <strtol+0x25>
		s++;
f0106535:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106536:	bf 00 00 00 00       	mov    $0x0,%edi
f010653b:	eb 13                	jmp    f0106550 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010653d:	3c 2d                	cmp    $0x2d,%al
f010653f:	75 0a                	jne    f010654b <strtol+0x33>
		s++, neg = 1;
f0106541:	8d 52 01             	lea    0x1(%edx),%edx
f0106544:	bf 01 00 00 00       	mov    $0x1,%edi
f0106549:	eb 05                	jmp    f0106550 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010654b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106550:	85 db                	test   %ebx,%ebx
f0106552:	74 05                	je     f0106559 <strtol+0x41>
f0106554:	83 fb 10             	cmp    $0x10,%ebx
f0106557:	75 28                	jne    f0106581 <strtol+0x69>
f0106559:	8a 02                	mov    (%edx),%al
f010655b:	3c 30                	cmp    $0x30,%al
f010655d:	75 10                	jne    f010656f <strtol+0x57>
f010655f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106563:	75 0a                	jne    f010656f <strtol+0x57>
		s += 2, base = 16;
f0106565:	83 c2 02             	add    $0x2,%edx
f0106568:	bb 10 00 00 00       	mov    $0x10,%ebx
f010656d:	eb 12                	jmp    f0106581 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010656f:	85 db                	test   %ebx,%ebx
f0106571:	75 0e                	jne    f0106581 <strtol+0x69>
f0106573:	3c 30                	cmp    $0x30,%al
f0106575:	75 05                	jne    f010657c <strtol+0x64>
		s++, base = 8;
f0106577:	42                   	inc    %edx
f0106578:	b3 08                	mov    $0x8,%bl
f010657a:	eb 05                	jmp    f0106581 <strtol+0x69>
	else if (base == 0)
		base = 10;
f010657c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106581:	b8 00 00 00 00       	mov    $0x0,%eax
f0106586:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106588:	8a 0a                	mov    (%edx),%cl
f010658a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010658d:	80 fb 09             	cmp    $0x9,%bl
f0106590:	77 08                	ja     f010659a <strtol+0x82>
			dig = *s - '0';
f0106592:	0f be c9             	movsbl %cl,%ecx
f0106595:	83 e9 30             	sub    $0x30,%ecx
f0106598:	eb 1e                	jmp    f01065b8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010659a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010659d:	80 fb 19             	cmp    $0x19,%bl
f01065a0:	77 08                	ja     f01065aa <strtol+0x92>
			dig = *s - 'a' + 10;
f01065a2:	0f be c9             	movsbl %cl,%ecx
f01065a5:	83 e9 57             	sub    $0x57,%ecx
f01065a8:	eb 0e                	jmp    f01065b8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01065aa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01065ad:	80 fb 19             	cmp    $0x19,%bl
f01065b0:	77 12                	ja     f01065c4 <strtol+0xac>
			dig = *s - 'A' + 10;
f01065b2:	0f be c9             	movsbl %cl,%ecx
f01065b5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01065b8:	39 f1                	cmp    %esi,%ecx
f01065ba:	7d 0c                	jge    f01065c8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01065bc:	42                   	inc    %edx
f01065bd:	0f af c6             	imul   %esi,%eax
f01065c0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01065c2:	eb c4                	jmp    f0106588 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01065c4:	89 c1                	mov    %eax,%ecx
f01065c6:	eb 02                	jmp    f01065ca <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01065c8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01065ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01065ce:	74 05                	je     f01065d5 <strtol+0xbd>
		*endptr = (char *) s;
f01065d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01065d3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01065d5:	85 ff                	test   %edi,%edi
f01065d7:	74 04                	je     f01065dd <strtol+0xc5>
f01065d9:	89 c8                	mov    %ecx,%eax
f01065db:	f7 d8                	neg    %eax
}
f01065dd:	5b                   	pop    %ebx
f01065de:	5e                   	pop    %esi
f01065df:	5f                   	pop    %edi
f01065e0:	5d                   	pop    %ebp
f01065e1:	c3                   	ret    
	...

f01065e4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01065e4:	55                   	push   %ebp
f01065e5:	57                   	push   %edi
f01065e6:	56                   	push   %esi
f01065e7:	83 ec 10             	sub    $0x10,%esp
f01065ea:	8b 74 24 20          	mov    0x20(%esp),%esi
f01065ee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01065f2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065f6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f01065fa:	89 cd                	mov    %ecx,%ebp
f01065fc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106600:	85 c0                	test   %eax,%eax
f0106602:	75 2c                	jne    f0106630 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0106604:	39 f9                	cmp    %edi,%ecx
f0106606:	77 68                	ja     f0106670 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106608:	85 c9                	test   %ecx,%ecx
f010660a:	75 0b                	jne    f0106617 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010660c:	b8 01 00 00 00       	mov    $0x1,%eax
f0106611:	31 d2                	xor    %edx,%edx
f0106613:	f7 f1                	div    %ecx
f0106615:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106617:	31 d2                	xor    %edx,%edx
f0106619:	89 f8                	mov    %edi,%eax
f010661b:	f7 f1                	div    %ecx
f010661d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010661f:	89 f0                	mov    %esi,%eax
f0106621:	f7 f1                	div    %ecx
f0106623:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106625:	89 f0                	mov    %esi,%eax
f0106627:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106629:	83 c4 10             	add    $0x10,%esp
f010662c:	5e                   	pop    %esi
f010662d:	5f                   	pop    %edi
f010662e:	5d                   	pop    %ebp
f010662f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106630:	39 f8                	cmp    %edi,%eax
f0106632:	77 2c                	ja     f0106660 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106634:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0106637:	83 f6 1f             	xor    $0x1f,%esi
f010663a:	75 4c                	jne    f0106688 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010663c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010663e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106643:	72 0a                	jb     f010664f <__udivdi3+0x6b>
f0106645:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106649:	0f 87 ad 00 00 00    	ja     f01066fc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010664f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106654:	89 f0                	mov    %esi,%eax
f0106656:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106658:	83 c4 10             	add    $0x10,%esp
f010665b:	5e                   	pop    %esi
f010665c:	5f                   	pop    %edi
f010665d:	5d                   	pop    %ebp
f010665e:	c3                   	ret    
f010665f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106660:	31 ff                	xor    %edi,%edi
f0106662:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106664:	89 f0                	mov    %esi,%eax
f0106666:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106668:	83 c4 10             	add    $0x10,%esp
f010666b:	5e                   	pop    %esi
f010666c:	5f                   	pop    %edi
f010666d:	5d                   	pop    %ebp
f010666e:	c3                   	ret    
f010666f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106670:	89 fa                	mov    %edi,%edx
f0106672:	89 f0                	mov    %esi,%eax
f0106674:	f7 f1                	div    %ecx
f0106676:	89 c6                	mov    %eax,%esi
f0106678:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010667a:	89 f0                	mov    %esi,%eax
f010667c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010667e:	83 c4 10             	add    $0x10,%esp
f0106681:	5e                   	pop    %esi
f0106682:	5f                   	pop    %edi
f0106683:	5d                   	pop    %ebp
f0106684:	c3                   	ret    
f0106685:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106688:	89 f1                	mov    %esi,%ecx
f010668a:	d3 e0                	shl    %cl,%eax
f010668c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106690:	b8 20 00 00 00       	mov    $0x20,%eax
f0106695:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0106697:	89 ea                	mov    %ebp,%edx
f0106699:	88 c1                	mov    %al,%cl
f010669b:	d3 ea                	shr    %cl,%edx
f010669d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f01066a1:	09 ca                	or     %ecx,%edx
f01066a3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f01066a7:	89 f1                	mov    %esi,%ecx
f01066a9:	d3 e5                	shl    %cl,%ebp
f01066ab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f01066af:	89 fd                	mov    %edi,%ebp
f01066b1:	88 c1                	mov    %al,%cl
f01066b3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f01066b5:	89 fa                	mov    %edi,%edx
f01066b7:	89 f1                	mov    %esi,%ecx
f01066b9:	d3 e2                	shl    %cl,%edx
f01066bb:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01066bf:	88 c1                	mov    %al,%cl
f01066c1:	d3 ef                	shr    %cl,%edi
f01066c3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01066c5:	89 f8                	mov    %edi,%eax
f01066c7:	89 ea                	mov    %ebp,%edx
f01066c9:	f7 74 24 08          	divl   0x8(%esp)
f01066cd:	89 d1                	mov    %edx,%ecx
f01066cf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01066d1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01066d5:	39 d1                	cmp    %edx,%ecx
f01066d7:	72 17                	jb     f01066f0 <__udivdi3+0x10c>
f01066d9:	74 09                	je     f01066e4 <__udivdi3+0x100>
f01066db:	89 fe                	mov    %edi,%esi
f01066dd:	31 ff                	xor    %edi,%edi
f01066df:	e9 41 ff ff ff       	jmp    f0106625 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01066e4:	8b 54 24 04          	mov    0x4(%esp),%edx
f01066e8:	89 f1                	mov    %esi,%ecx
f01066ea:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01066ec:	39 c2                	cmp    %eax,%edx
f01066ee:	73 eb                	jae    f01066db <__udivdi3+0xf7>
		{
		  q0--;
f01066f0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01066f3:	31 ff                	xor    %edi,%edi
f01066f5:	e9 2b ff ff ff       	jmp    f0106625 <__udivdi3+0x41>
f01066fa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01066fc:	31 f6                	xor    %esi,%esi
f01066fe:	e9 22 ff ff ff       	jmp    f0106625 <__udivdi3+0x41>
	...

f0106704 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106704:	55                   	push   %ebp
f0106705:	57                   	push   %edi
f0106706:	56                   	push   %esi
f0106707:	83 ec 20             	sub    $0x20,%esp
f010670a:	8b 44 24 30          	mov    0x30(%esp),%eax
f010670e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106712:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106716:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f010671a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010671e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106722:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0106724:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106726:	85 ed                	test   %ebp,%ebp
f0106728:	75 16                	jne    f0106740 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f010672a:	39 f1                	cmp    %esi,%ecx
f010672c:	0f 86 a6 00 00 00    	jbe    f01067d8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106732:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106734:	89 d0                	mov    %edx,%eax
f0106736:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106738:	83 c4 20             	add    $0x20,%esp
f010673b:	5e                   	pop    %esi
f010673c:	5f                   	pop    %edi
f010673d:	5d                   	pop    %ebp
f010673e:	c3                   	ret    
f010673f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106740:	39 f5                	cmp    %esi,%ebp
f0106742:	0f 87 ac 00 00 00    	ja     f01067f4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106748:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f010674b:	83 f0 1f             	xor    $0x1f,%eax
f010674e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106752:	0f 84 a8 00 00 00    	je     f0106800 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106758:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010675c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010675e:	bf 20 00 00 00       	mov    $0x20,%edi
f0106763:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0106767:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010676b:	89 f9                	mov    %edi,%ecx
f010676d:	d3 e8                	shr    %cl,%eax
f010676f:	09 e8                	or     %ebp,%eax
f0106771:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0106775:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106779:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010677d:	d3 e0                	shl    %cl,%eax
f010677f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106783:	89 f2                	mov    %esi,%edx
f0106785:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106787:	8b 44 24 14          	mov    0x14(%esp),%eax
f010678b:	d3 e0                	shl    %cl,%eax
f010678d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106791:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106795:	89 f9                	mov    %edi,%ecx
f0106797:	d3 e8                	shr    %cl,%eax
f0106799:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010679b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010679d:	89 f2                	mov    %esi,%edx
f010679f:	f7 74 24 18          	divl   0x18(%esp)
f01067a3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01067a5:	f7 64 24 0c          	mull   0xc(%esp)
f01067a9:	89 c5                	mov    %eax,%ebp
f01067ab:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01067ad:	39 d6                	cmp    %edx,%esi
f01067af:	72 67                	jb     f0106818 <__umoddi3+0x114>
f01067b1:	74 75                	je     f0106828 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01067b3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01067b7:	29 e8                	sub    %ebp,%eax
f01067b9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01067bb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01067bf:	d3 e8                	shr    %cl,%eax
f01067c1:	89 f2                	mov    %esi,%edx
f01067c3:	89 f9                	mov    %edi,%ecx
f01067c5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01067c7:	09 d0                	or     %edx,%eax
f01067c9:	89 f2                	mov    %esi,%edx
f01067cb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01067cf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01067d1:	83 c4 20             	add    $0x20,%esp
f01067d4:	5e                   	pop    %esi
f01067d5:	5f                   	pop    %edi
f01067d6:	5d                   	pop    %ebp
f01067d7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01067d8:	85 c9                	test   %ecx,%ecx
f01067da:	75 0b                	jne    f01067e7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01067dc:	b8 01 00 00 00       	mov    $0x1,%eax
f01067e1:	31 d2                	xor    %edx,%edx
f01067e3:	f7 f1                	div    %ecx
f01067e5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01067e7:	89 f0                	mov    %esi,%eax
f01067e9:	31 d2                	xor    %edx,%edx
f01067eb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01067ed:	89 f8                	mov    %edi,%eax
f01067ef:	e9 3e ff ff ff       	jmp    f0106732 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01067f4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01067f6:	83 c4 20             	add    $0x20,%esp
f01067f9:	5e                   	pop    %esi
f01067fa:	5f                   	pop    %edi
f01067fb:	5d                   	pop    %ebp
f01067fc:	c3                   	ret    
f01067fd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106800:	39 f5                	cmp    %esi,%ebp
f0106802:	72 04                	jb     f0106808 <__umoddi3+0x104>
f0106804:	39 f9                	cmp    %edi,%ecx
f0106806:	77 06                	ja     f010680e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106808:	89 f2                	mov    %esi,%edx
f010680a:	29 cf                	sub    %ecx,%edi
f010680c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f010680e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106810:	83 c4 20             	add    $0x20,%esp
f0106813:	5e                   	pop    %esi
f0106814:	5f                   	pop    %edi
f0106815:	5d                   	pop    %ebp
f0106816:	c3                   	ret    
f0106817:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106818:	89 d1                	mov    %edx,%ecx
f010681a:	89 c5                	mov    %eax,%ebp
f010681c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106820:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106824:	eb 8d                	jmp    f01067b3 <__umoddi3+0xaf>
f0106826:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106828:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f010682c:	72 ea                	jb     f0106818 <__umoddi3+0x114>
f010682e:	89 f1                	mov    %esi,%ecx
f0106830:	eb 81                	jmp    f01067b3 <__umoddi3+0xaf>
