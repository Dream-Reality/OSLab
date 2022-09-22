
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 80 29 12 f0       	mov    $0xf0122980,%eax
f010004b:	2d 20 23 12 f0       	sub    $0xf0122320,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 20 23 12 f0 	movl   $0xf0122320,(%esp)
f0100063:	e8 92 44 00 00       	call   f01044fa <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 5b 07 00 00       	call   f01007c8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 40 49 10 f0 	movl   $0xf0104940,(%esp)
f010007c:	e8 d5 39 00 00       	call   f0103a56 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 af 1d 00 00       	call   f0101e35 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 66 0f 00 00       	call   f0100ff8 <monitor>
f0100092:	eb f2                	jmp    f0100086 <i386_init+0x46>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	83 ec 10             	sub    $0x10,%esp
f010009c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009f:	83 3d 84 29 12 f0 00 	cmpl   $0x0,0xf0122984
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 84 29 12 f0    	mov    %esi,0xf0122984

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000ae:	fa                   	cli    
f01000af:	fc                   	cld    

	va_start(ap, fmt);
f01000b0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01000bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c1:	c7 04 24 5b 49 10 f0 	movl   $0xf010495b,(%esp)
f01000c8:	e8 89 39 00 00       	call   f0103a56 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 4a 39 00 00       	call   f0103a23 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 b3 65 10 f0 	movl   $0xf01065b3,(%esp)
f01000e0:	e8 71 39 00 00       	call   f0103a56 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 07 0f 00 00       	call   f0100ff8 <monitor>
f01000f1:	eb f2                	jmp    f01000e5 <_panic+0x51>

f01000f3 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f3:	55                   	push   %ebp
f01000f4:	89 e5                	mov    %esp,%ebp
f01000f6:	53                   	push   %ebx
f01000f7:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fa:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100100:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100104:	8b 45 08             	mov    0x8(%ebp),%eax
f0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010b:	c7 04 24 73 49 10 f0 	movl   $0xf0104973,(%esp)
f0100112:	e8 3f 39 00 00       	call   f0103a56 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 fd 38 00 00       	call   f0103a23 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 b3 65 10 f0 	movl   $0xf01065b3,(%esp)
f010012d:	e8 24 39 00 00       	call   f0103a56 <cprintf>
	va_end(ap);
}
f0100132:	83 c4 14             	add    $0x14,%esp
f0100135:	5b                   	pop    %ebx
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    

f0100138 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100138:	55                   	push   %ebp
f0100139:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010013b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100140:	ec                   	in     (%dx),%al
f0100141:	ec                   	in     (%dx),%al
f0100142:	ec                   	in     (%dx),%al
f0100143:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100144:	5d                   	pop    %ebp
f0100145:	c3                   	ret    

f0100146 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100146:	55                   	push   %ebp
f0100147:	89 e5                	mov    %esp,%ebp
f0100149:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010014e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010014f:	a8 01                	test   $0x1,%al
f0100151:	74 08                	je     f010015b <serial_proc_data+0x15>
f0100153:	b2 f8                	mov    $0xf8,%dl
f0100155:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100156:	0f b6 c0             	movzbl %al,%eax
f0100159:	eb 05                	jmp    f0100160 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010015b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100160:	5d                   	pop    %ebp
f0100161:	c3                   	ret    

f0100162 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100162:	55                   	push   %ebp
f0100163:	89 e5                	mov    %esp,%ebp
f0100165:	53                   	push   %ebx
f0100166:	83 ec 04             	sub    $0x4,%esp
f0100169:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010016b:	eb 29                	jmp    f0100196 <cons_intr+0x34>
		if (c == 0)
f010016d:	85 c0                	test   %eax,%eax
f010016f:	74 25                	je     f0100196 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100171:	8b 15 44 25 12 f0    	mov    0xf0122544,%edx
f0100177:	88 82 40 23 12 f0    	mov    %al,-0xfeddcc0(%edx)
f010017d:	8d 42 01             	lea    0x1(%edx),%eax
f0100180:	a3 44 25 12 f0       	mov    %eax,0xf0122544
		if (cons.wpos == CONSBUFSIZE)
f0100185:	3d 00 02 00 00       	cmp    $0x200,%eax
f010018a:	75 0a                	jne    f0100196 <cons_intr+0x34>
			cons.wpos = 0;
f010018c:	c7 05 44 25 12 f0 00 	movl   $0x0,0xf0122544
f0100193:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100196:	ff d3                	call   *%ebx
f0100198:	83 f8 ff             	cmp    $0xffffffff,%eax
f010019b:	75 d0                	jne    f010016d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010019d:	83 c4 04             	add    $0x4,%esp
f01001a0:	5b                   	pop    %ebx
f01001a1:	5d                   	pop    %ebp
f01001a2:	c3                   	ret    

f01001a3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001a3:	55                   	push   %ebp
f01001a4:	89 e5                	mov    %esp,%ebp
f01001a6:	57                   	push   %edi
f01001a7:	56                   	push   %esi
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 2c             	sub    $0x2c,%esp
f01001ac:	89 c6                	mov    %eax,%esi
f01001ae:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01001b3:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01001b8:	eb 05                	jmp    f01001bf <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001ba:	e8 79 ff ff ff       	call   f0100138 <delay>
f01001bf:	89 fa                	mov    %edi,%edx
f01001c1:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001c2:	a8 20                	test   $0x20,%al
f01001c4:	75 03                	jne    f01001c9 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001c6:	4b                   	dec    %ebx
f01001c7:	75 f1                	jne    f01001ba <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001c9:	89 f2                	mov    %esi,%edx
f01001cb:	89 f0                	mov    %esi,%eax
f01001cd:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d5:	ee                   	out    %al,(%dx)
f01001d6:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001db:	bf 79 03 00 00       	mov    $0x379,%edi
f01001e0:	eb 05                	jmp    f01001e7 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01001e2:	e8 51 ff ff ff       	call   f0100138 <delay>
f01001e7:	89 fa                	mov    %edi,%edx
f01001e9:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001ea:	84 c0                	test   %al,%al
f01001ec:	78 03                	js     f01001f1 <cons_putc+0x4e>
f01001ee:	4b                   	dec    %ebx
f01001ef:	75 f1                	jne    f01001e2 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01001f6:	8a 45 e7             	mov    -0x19(%ebp),%al
f01001f9:	ee                   	out    %al,(%dx)
f01001fa:	b2 7a                	mov    $0x7a,%dl
f01001fc:	b0 0d                	mov    $0xd,%al
f01001fe:	ee                   	out    %al,(%dx)
f01001ff:	b0 08                	mov    $0x8,%al
f0100201:	ee                   	out    %al,(%dx)
{
	// if no attribute given, then use black on white
	static int Color = 0x0700;
	static int State = 0;
	static int Number = 0;
	if (!(c & ~0xFF))
f0100202:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100208:	75 06                	jne    f0100210 <cons_putc+0x6d>
		c |= Color;
f010020a:	0b 35 00 20 12 f0    	or     0xf0122000,%esi
	switch (c & 0xff) {
f0100210:	89 f2                	mov    %esi,%edx
f0100212:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100218:	8d 42 f8             	lea    -0x8(%edx),%eax
f010021b:	83 f8 13             	cmp    $0x13,%eax
f010021e:	0f 87 ab 00 00 00    	ja     f01002cf <cons_putc+0x12c>
f0100224:	ff 24 85 a0 49 10 f0 	jmp    *-0xfefb660(,%eax,4)
	case '\b':
		if (crt_pos > 0) {
f010022b:	66 a1 54 25 12 f0    	mov    0xf0122554,%ax
f0100231:	66 85 c0             	test   %ax,%ax
f0100234:	0f 84 de 03 00 00    	je     f0100618 <cons_putc+0x475>
			crt_pos--;
f010023a:	48                   	dec    %eax
f010023b:	66 a3 54 25 12 f0    	mov    %ax,0xf0122554
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100241:	0f b7 c0             	movzwl %ax,%eax
f0100244:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010024a:	83 ce 20             	or     $0x20,%esi
f010024d:	8b 15 50 25 12 f0    	mov    0xf0122550,%edx
f0100253:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100257:	e9 71 03 00 00       	jmp    f01005cd <cons_putc+0x42a>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010025c:	66 83 05 54 25 12 f0 	addw   $0x50,0xf0122554
f0100263:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100264:	66 8b 0d 54 25 12 f0 	mov    0xf0122554,%cx
f010026b:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100270:	89 c8                	mov    %ecx,%eax
f0100272:	ba 00 00 00 00       	mov    $0x0,%edx
f0100277:	66 f7 f3             	div    %bx
f010027a:	66 29 d1             	sub    %dx,%cx
f010027d:	66 89 0d 54 25 12 f0 	mov    %cx,0xf0122554
f0100284:	e9 44 03 00 00       	jmp    f01005cd <cons_putc+0x42a>
		break;
	case '\t':
		cons_putc(' ');
f0100289:	b8 20 00 00 00       	mov    $0x20,%eax
f010028e:	e8 10 ff ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f0100293:	b8 20 00 00 00       	mov    $0x20,%eax
f0100298:	e8 06 ff ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f010029d:	b8 20 00 00 00       	mov    $0x20,%eax
f01002a2:	e8 fc fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002a7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ac:	e8 f2 fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b6:	e8 e8 fe ff ff       	call   f01001a3 <cons_putc>
f01002bb:	e9 0d 03 00 00       	jmp    f01005cd <cons_putc+0x42a>
		break;
	case '\033':
		State = 1;
f01002c0:	c7 05 58 25 12 f0 01 	movl   $0x1,0xf0122558
f01002c7:	00 00 00 
f01002ca:	e9 fe 02 00 00       	jmp    f01005cd <cons_putc+0x42a>
		break;
	default:
		if (State == 1){
f01002cf:	83 3d 58 25 12 f0 01 	cmpl   $0x1,0xf0122558
f01002d6:	0f 85 d7 02 00 00    	jne    f01005b3 <cons_putc+0x410>
			switch (c&0xff){
f01002dc:	83 fa 5b             	cmp    $0x5b,%edx
f01002df:	0f 84 e8 02 00 00    	je     f01005cd <cons_putc+0x42a>
f01002e5:	83 fa 6d             	cmp    $0x6d,%edx
f01002e8:	0f 84 5a 01 00 00    	je     f0100448 <cons_putc+0x2a5>
f01002ee:	83 fa 3b             	cmp    $0x3b,%edx
f01002f1:	0f 85 a9 02 00 00    	jne    f01005a0 <cons_putc+0x3fd>
				case '[':
					break;
				case ';':
					switch (Number){
f01002f7:	a1 5c 25 12 f0       	mov    0xf012255c,%eax
f01002fc:	83 e8 1e             	sub    $0x1e,%eax
f01002ff:	83 f8 11             	cmp    $0x11,%eax
f0100302:	0f 87 31 01 00 00    	ja     f0100439 <cons_putc+0x296>
f0100308:	ff 24 85 f0 49 10 f0 	jmp    *-0xfefb610(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f010030f:	81 25 00 20 12 f0 ff 	andl   $0xfffff0ff,0xf0122000
f0100316:	f0 ff ff 
f0100319:	e9 1b 01 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f010031e:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100323:	80 e4 f0             	and    $0xf0,%ah
f0100326:	80 cc 04             	or     $0x4,%ah
f0100329:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f010032e:	e9 06 01 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f0100333:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100338:	80 e4 f0             	and    $0xf0,%ah
f010033b:	80 cc 02             	or     $0x2,%ah
f010033e:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100343:	e9 f1 00 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f0100348:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010034d:	80 e4 f0             	and    $0xf0,%ah
f0100350:	80 cc 06             	or     $0x6,%ah
f0100353:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100358:	e9 dc 00 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f010035d:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100362:	80 e4 f0             	and    $0xf0,%ah
f0100365:	80 cc 01             	or     $0x1,%ah
f0100368:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f010036d:	e9 c7 00 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f0100372:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100377:	80 e4 f0             	and    $0xf0,%ah
f010037a:	80 cc 05             	or     $0x5,%ah
f010037d:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100382:	e9 b2 00 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f0100387:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010038c:	80 e4 f0             	and    $0xf0,%ah
f010038f:	80 cc 03             	or     $0x3,%ah
f0100392:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100397:	e9 9d 00 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f010039c:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01003a1:	80 e4 f0             	and    $0xf0,%ah
f01003a4:	80 cc 07             	or     $0x7,%ah
f01003a7:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01003ac:	e9 88 00 00 00       	jmp    f0100439 <cons_putc+0x296>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f01003b1:	81 25 00 20 12 f0 ff 	andl   $0xffff0fff,0xf0122000
f01003b8:	0f ff ff 
f01003bb:	eb 7c                	jmp    f0100439 <cons_putc+0x296>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f01003bd:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01003c2:	80 e4 0f             	and    $0xf,%ah
f01003c5:	80 cc 40             	or     $0x40,%ah
f01003c8:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01003cd:	eb 6a                	jmp    f0100439 <cons_putc+0x296>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f01003cf:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01003d4:	80 e4 0f             	and    $0xf,%ah
f01003d7:	80 cc 20             	or     $0x20,%ah
f01003da:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01003df:	eb 58                	jmp    f0100439 <cons_putc+0x296>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f01003e1:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01003e6:	80 e4 0f             	and    $0xf,%ah
f01003e9:	80 cc 60             	or     $0x60,%ah
f01003ec:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01003f1:	eb 46                	jmp    f0100439 <cons_putc+0x296>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f01003f3:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01003f8:	80 e4 0f             	and    $0xf,%ah
f01003fb:	80 cc 10             	or     $0x10,%ah
f01003fe:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100403:	eb 34                	jmp    f0100439 <cons_putc+0x296>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f0100405:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010040a:	80 e4 0f             	and    $0xf,%ah
f010040d:	80 cc 50             	or     $0x50,%ah
f0100410:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100415:	eb 22                	jmp    f0100439 <cons_putc+0x296>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f0100417:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010041c:	80 e4 0f             	and    $0xf,%ah
f010041f:	80 cc 30             	or     $0x30,%ah
f0100422:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100427:	eb 10                	jmp    f0100439 <cons_putc+0x296>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f0100429:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010042e:	80 e4 0f             	and    $0xf,%ah
f0100431:	80 cc 70             	or     $0x70,%ah
f0100434:	a3 00 20 12 f0       	mov    %eax,0xf0122000
						default:break;
					}
					Number = 0;
f0100439:	c7 05 5c 25 12 f0 00 	movl   $0x0,0xf012255c
f0100440:	00 00 00 
f0100443:	e9 85 01 00 00       	jmp    f01005cd <cons_putc+0x42a>
					break;
				case 'm':
					switch (Number){
f0100448:	a1 5c 25 12 f0       	mov    0xf012255c,%eax
f010044d:	83 e8 1e             	sub    $0x1e,%eax
f0100450:	83 f8 11             	cmp    $0x11,%eax
f0100453:	0f 87 31 01 00 00    	ja     f010058a <cons_putc+0x3e7>
f0100459:	ff 24 85 38 4a 10 f0 	jmp    *-0xfefb5c8(,%eax,4)
						case 30:Color = (Color & (~0xf00)) | 0x000;break;
f0100460:	81 25 00 20 12 f0 ff 	andl   $0xfffff0ff,0xf0122000
f0100467:	f0 ff ff 
f010046a:	e9 1b 01 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 31:Color = (Color & (~0xf00)) | 0x400;break;
f010046f:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100474:	80 e4 f0             	and    $0xf0,%ah
f0100477:	80 cc 04             	or     $0x4,%ah
f010047a:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f010047f:	e9 06 01 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 32:Color = (Color & (~0xf00)) | 0x200;break;
f0100484:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100489:	80 e4 f0             	and    $0xf0,%ah
f010048c:	80 cc 02             	or     $0x2,%ah
f010048f:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100494:	e9 f1 00 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 33:Color = (Color & (~0xf00)) | 0x600;break;
f0100499:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010049e:	80 e4 f0             	and    $0xf0,%ah
f01004a1:	80 cc 06             	or     $0x6,%ah
f01004a4:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01004a9:	e9 dc 00 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 34:Color = (Color & (~0xf00)) | 0x100;break;
f01004ae:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01004b3:	80 e4 f0             	and    $0xf0,%ah
f01004b6:	80 cc 01             	or     $0x1,%ah
f01004b9:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01004be:	e9 c7 00 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 35:Color = (Color & (~0xf00)) | 0x500;break;
f01004c3:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01004c8:	80 e4 f0             	and    $0xf0,%ah
f01004cb:	80 cc 05             	or     $0x5,%ah
f01004ce:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01004d3:	e9 b2 00 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 36:Color = (Color & (~0xf00)) | 0x300;break;
f01004d8:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01004dd:	80 e4 f0             	and    $0xf0,%ah
f01004e0:	80 cc 03             	or     $0x3,%ah
f01004e3:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01004e8:	e9 9d 00 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 37:Color = (Color & (~0xf00)) | 0x700;break;
f01004ed:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f01004f2:	80 e4 f0             	and    $0xf0,%ah
f01004f5:	80 cc 07             	or     $0x7,%ah
f01004f8:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f01004fd:	e9 88 00 00 00       	jmp    f010058a <cons_putc+0x3e7>
						case 40:Color = (Color & (~0xf000)) | 0x0000;break;
f0100502:	81 25 00 20 12 f0 ff 	andl   $0xffff0fff,0xf0122000
f0100509:	0f ff ff 
f010050c:	eb 7c                	jmp    f010058a <cons_putc+0x3e7>
						case 41:Color = (Color & (~0xf000)) | 0x4000;break;
f010050e:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100513:	80 e4 0f             	and    $0xf,%ah
f0100516:	80 cc 40             	or     $0x40,%ah
f0100519:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f010051e:	eb 6a                	jmp    f010058a <cons_putc+0x3e7>
						case 42:Color = (Color & (~0xf000)) | 0x2000;break;
f0100520:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100525:	80 e4 0f             	and    $0xf,%ah
f0100528:	80 cc 20             	or     $0x20,%ah
f010052b:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100530:	eb 58                	jmp    f010058a <cons_putc+0x3e7>
						case 43:Color = (Color & (~0xf000)) | 0x6000;break;
f0100532:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100537:	80 e4 0f             	and    $0xf,%ah
f010053a:	80 cc 60             	or     $0x60,%ah
f010053d:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100542:	eb 46                	jmp    f010058a <cons_putc+0x3e7>
						case 44:Color = (Color & (~0xf000)) | 0x1000;break;
f0100544:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f0100549:	80 e4 0f             	and    $0xf,%ah
f010054c:	80 cc 10             	or     $0x10,%ah
f010054f:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100554:	eb 34                	jmp    f010058a <cons_putc+0x3e7>
						case 45:Color = (Color & (~0xf000)) | 0x5000;break;
f0100556:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010055b:	80 e4 0f             	and    $0xf,%ah
f010055e:	80 cc 50             	or     $0x50,%ah
f0100561:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100566:	eb 22                	jmp    f010058a <cons_putc+0x3e7>
						case 46:Color = (Color & (~0xf000)) | 0x3000;break;
f0100568:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010056d:	80 e4 0f             	and    $0xf,%ah
f0100570:	80 cc 30             	or     $0x30,%ah
f0100573:	a3 00 20 12 f0       	mov    %eax,0xf0122000
f0100578:	eb 10                	jmp    f010058a <cons_putc+0x3e7>
						case 47:Color = (Color & (~0xf000)) | 0x7000;break;
f010057a:	a1 00 20 12 f0       	mov    0xf0122000,%eax
f010057f:	80 e4 0f             	and    $0xf,%ah
f0100582:	80 cc 70             	or     $0x70,%ah
f0100585:	a3 00 20 12 f0       	mov    %eax,0xf0122000
						default:break;
					}
					Number = 0;
f010058a:	c7 05 5c 25 12 f0 00 	movl   $0x0,0xf012255c
f0100591:	00 00 00 
					State = 0;
f0100594:	c7 05 58 25 12 f0 00 	movl   $0x0,0xf0122558
f010059b:	00 00 00 
f010059e:	eb 2d                	jmp    f01005cd <cons_putc+0x42a>
					break;
				default:
					Number = Number * 10 + (c&0xff) - '0';
f01005a0:	a1 5c 25 12 f0       	mov    0xf012255c,%eax
f01005a5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01005a8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
f01005ac:	a3 5c 25 12 f0       	mov    %eax,0xf012255c
f01005b1:	eb 1a                	jmp    f01005cd <cons_putc+0x42a>
					break;
			}
		}
		else crt_buf[crt_pos++] = c;		/* write the character */
f01005b3:	66 a1 54 25 12 f0    	mov    0xf0122554,%ax
f01005b9:	0f b7 c8             	movzwl %ax,%ecx
f01005bc:	8b 15 50 25 12 f0    	mov    0xf0122550,%edx
f01005c2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01005c6:	40                   	inc    %eax
f01005c7:	66 a3 54 25 12 f0    	mov    %ax,0xf0122554
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005cd:	66 81 3d 54 25 12 f0 	cmpw   $0x7cf,0xf0122554
f01005d4:	cf 07 
f01005d6:	76 40                	jbe    f0100618 <cons_putc+0x475>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005d8:	a1 50 25 12 f0       	mov    0xf0122550,%eax
f01005dd:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005e4:	00 
f01005e5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005ef:	89 04 24             	mov    %eax,(%esp)
f01005f2:	e8 4d 3f 00 00       	call   f0104544 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005f7:	8b 15 50 25 12 f0    	mov    0xf0122550,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005fd:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100602:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100608:	40                   	inc    %eax
f0100609:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010060e:	75 f2                	jne    f0100602 <cons_putc+0x45f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100610:	66 83 2d 54 25 12 f0 	subw   $0x50,0xf0122554
f0100617:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100618:	8b 0d 4c 25 12 f0    	mov    0xf012254c,%ecx
f010061e:	b0 0e                	mov    $0xe,%al
f0100620:	89 ca                	mov    %ecx,%edx
f0100622:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100623:	66 8b 35 54 25 12 f0 	mov    0xf0122554,%si
f010062a:	8d 59 01             	lea    0x1(%ecx),%ebx
f010062d:	89 f0                	mov    %esi,%eax
f010062f:	66 c1 e8 08          	shr    $0x8,%ax
f0100633:	89 da                	mov    %ebx,%edx
f0100635:	ee                   	out    %al,(%dx)
f0100636:	b0 0f                	mov    $0xf,%al
f0100638:	89 ca                	mov    %ecx,%edx
f010063a:	ee                   	out    %al,(%dx)
f010063b:	89 f0                	mov    %esi,%eax
f010063d:	89 da                	mov    %ebx,%edx
f010063f:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100640:	83 c4 2c             	add    $0x2c,%esp
f0100643:	5b                   	pop    %ebx
f0100644:	5e                   	pop    %esi
f0100645:	5f                   	pop    %edi
f0100646:	5d                   	pop    %ebp
f0100647:	c3                   	ret    

f0100648 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100648:	55                   	push   %ebp
f0100649:	89 e5                	mov    %esp,%ebp
f010064b:	53                   	push   %ebx
f010064c:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010064f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100654:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100655:	0f b6 c0             	movzbl %al,%eax
f0100658:	a8 01                	test   $0x1,%al
f010065a:	0f 84 e0 00 00 00    	je     f0100740 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100660:	a8 20                	test   $0x20,%al
f0100662:	0f 85 df 00 00 00    	jne    f0100747 <kbd_proc_data+0xff>
f0100668:	b2 60                	mov    $0x60,%dl
f010066a:	ec                   	in     (%dx),%al
f010066b:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010066d:	3c e0                	cmp    $0xe0,%al
f010066f:	75 11                	jne    f0100682 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f0100671:	83 0d 48 25 12 f0 40 	orl    $0x40,0xf0122548
		return 0;
f0100678:	bb 00 00 00 00       	mov    $0x0,%ebx
f010067d:	e9 ca 00 00 00       	jmp    f010074c <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100682:	84 c0                	test   %al,%al
f0100684:	79 33                	jns    f01006b9 <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100686:	8b 0d 48 25 12 f0    	mov    0xf0122548,%ecx
f010068c:	f6 c1 40             	test   $0x40,%cl
f010068f:	75 05                	jne    f0100696 <kbd_proc_data+0x4e>
f0100691:	88 c2                	mov    %al,%dl
f0100693:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100696:	0f b6 d2             	movzbl %dl,%edx
f0100699:	8a 82 80 4a 10 f0    	mov    -0xfefb580(%edx),%al
f010069f:	83 c8 40             	or     $0x40,%eax
f01006a2:	0f b6 c0             	movzbl %al,%eax
f01006a5:	f7 d0                	not    %eax
f01006a7:	21 c1                	and    %eax,%ecx
f01006a9:	89 0d 48 25 12 f0    	mov    %ecx,0xf0122548
		return 0;
f01006af:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006b4:	e9 93 00 00 00       	jmp    f010074c <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f01006b9:	8b 0d 48 25 12 f0    	mov    0xf0122548,%ecx
f01006bf:	f6 c1 40             	test   $0x40,%cl
f01006c2:	74 0e                	je     f01006d2 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01006c4:	88 c2                	mov    %al,%dl
f01006c6:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01006c9:	83 e1 bf             	and    $0xffffffbf,%ecx
f01006cc:	89 0d 48 25 12 f0    	mov    %ecx,0xf0122548
	}

	shift |= shiftcode[data];
f01006d2:	0f b6 d2             	movzbl %dl,%edx
f01006d5:	0f b6 82 80 4a 10 f0 	movzbl -0xfefb580(%edx),%eax
f01006dc:	0b 05 48 25 12 f0    	or     0xf0122548,%eax
	shift ^= togglecode[data];
f01006e2:	0f b6 8a 80 4b 10 f0 	movzbl -0xfefb480(%edx),%ecx
f01006e9:	31 c8                	xor    %ecx,%eax
f01006eb:	a3 48 25 12 f0       	mov    %eax,0xf0122548

	c = charcode[shift & (CTL | SHIFT)][data];
f01006f0:	89 c1                	mov    %eax,%ecx
f01006f2:	83 e1 03             	and    $0x3,%ecx
f01006f5:	8b 0c 8d 80 4c 10 f0 	mov    -0xfefb380(,%ecx,4),%ecx
f01006fc:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100700:	a8 08                	test   $0x8,%al
f0100702:	74 18                	je     f010071c <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f0100704:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100707:	83 fa 19             	cmp    $0x19,%edx
f010070a:	77 05                	ja     f0100711 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f010070c:	83 eb 20             	sub    $0x20,%ebx
f010070f:	eb 0b                	jmp    f010071c <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f0100711:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100714:	83 fa 19             	cmp    $0x19,%edx
f0100717:	77 03                	ja     f010071c <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f0100719:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010071c:	f7 d0                	not    %eax
f010071e:	a8 06                	test   $0x6,%al
f0100720:	75 2a                	jne    f010074c <kbd_proc_data+0x104>
f0100722:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100728:	75 22                	jne    f010074c <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010072a:	c7 04 24 90 4c 10 f0 	movl   $0xf0104c90,(%esp)
f0100731:	e8 20 33 00 00       	call   f0103a56 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100736:	ba 92 00 00 00       	mov    $0x92,%edx
f010073b:	b0 03                	mov    $0x3,%al
f010073d:	ee                   	out    %al,(%dx)
f010073e:	eb 0c                	jmp    f010074c <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100740:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100745:	eb 05                	jmp    f010074c <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100747:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010074c:	89 d8                	mov    %ebx,%eax
f010074e:	83 c4 14             	add    $0x14,%esp
f0100751:	5b                   	pop    %ebx
f0100752:	5d                   	pop    %ebp
f0100753:	c3                   	ret    

f0100754 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
f0100757:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010075a:	80 3d 20 23 12 f0 00 	cmpb   $0x0,0xf0122320
f0100761:	74 0a                	je     f010076d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100763:	b8 46 01 10 f0       	mov    $0xf0100146,%eax
f0100768:	e8 f5 f9 ff ff       	call   f0100162 <cons_intr>
}
f010076d:	c9                   	leave  
f010076e:	c3                   	ret    

f010076f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010076f:	55                   	push   %ebp
f0100770:	89 e5                	mov    %esp,%ebp
f0100772:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100775:	b8 48 06 10 f0       	mov    $0xf0100648,%eax
f010077a:	e8 e3 f9 ff ff       	call   f0100162 <cons_intr>
}
f010077f:	c9                   	leave  
f0100780:	c3                   	ret    

f0100781 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100781:	55                   	push   %ebp
f0100782:	89 e5                	mov    %esp,%ebp
f0100784:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100787:	e8 c8 ff ff ff       	call   f0100754 <serial_intr>
	kbd_intr();
f010078c:	e8 de ff ff ff       	call   f010076f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100791:	8b 15 40 25 12 f0    	mov    0xf0122540,%edx
f0100797:	3b 15 44 25 12 f0    	cmp    0xf0122544,%edx
f010079d:	74 22                	je     f01007c1 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010079f:	0f b6 82 40 23 12 f0 	movzbl -0xfeddcc0(%edx),%eax
f01007a6:	42                   	inc    %edx
f01007a7:	89 15 40 25 12 f0    	mov    %edx,0xf0122540
		if (cons.rpos == CONSBUFSIZE)
f01007ad:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01007b3:	75 11                	jne    f01007c6 <cons_getc+0x45>
			cons.rpos = 0;
f01007b5:	c7 05 40 25 12 f0 00 	movl   $0x0,0xf0122540
f01007bc:	00 00 00 
f01007bf:	eb 05                	jmp    f01007c6 <cons_getc+0x45>
		return c;
	}
	return 0;
f01007c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01007c6:	c9                   	leave  
f01007c7:	c3                   	ret    

f01007c8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01007c8:	55                   	push   %ebp
f01007c9:	89 e5                	mov    %esp,%ebp
f01007cb:	57                   	push   %edi
f01007cc:	56                   	push   %esi
f01007cd:	53                   	push   %ebx
f01007ce:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01007d1:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01007d8:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01007df:	5a a5 
	if (*cp != 0xA55A) {
f01007e1:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01007e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01007eb:	74 11                	je     f01007fe <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01007ed:	c7 05 4c 25 12 f0 b4 	movl   $0x3b4,0xf012254c
f01007f4:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01007f7:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01007fc:	eb 16                	jmp    f0100814 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01007fe:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100805:	c7 05 4c 25 12 f0 d4 	movl   $0x3d4,0xf012254c
f010080c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010080f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100814:	8b 0d 4c 25 12 f0    	mov    0xf012254c,%ecx
f010081a:	b0 0e                	mov    $0xe,%al
f010081c:	89 ca                	mov    %ecx,%edx
f010081e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010081f:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100822:	89 da                	mov    %ebx,%edx
f0100824:	ec                   	in     (%dx),%al
f0100825:	0f b6 f8             	movzbl %al,%edi
f0100828:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010082b:	b0 0f                	mov    $0xf,%al
f010082d:	89 ca                	mov    %ecx,%edx
f010082f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100830:	89 da                	mov    %ebx,%edx
f0100832:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100833:	89 35 50 25 12 f0    	mov    %esi,0xf0122550

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100839:	0f b6 d8             	movzbl %al,%ebx
f010083c:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010083e:	66 89 3d 54 25 12 f0 	mov    %di,0xf0122554
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100845:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010084a:	b0 00                	mov    $0x0,%al
f010084c:	89 da                	mov    %ebx,%edx
f010084e:	ee                   	out    %al,(%dx)
f010084f:	b2 fb                	mov    $0xfb,%dl
f0100851:	b0 80                	mov    $0x80,%al
f0100853:	ee                   	out    %al,(%dx)
f0100854:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100859:	b0 0c                	mov    $0xc,%al
f010085b:	89 ca                	mov    %ecx,%edx
f010085d:	ee                   	out    %al,(%dx)
f010085e:	b2 f9                	mov    $0xf9,%dl
f0100860:	b0 00                	mov    $0x0,%al
f0100862:	ee                   	out    %al,(%dx)
f0100863:	b2 fb                	mov    $0xfb,%dl
f0100865:	b0 03                	mov    $0x3,%al
f0100867:	ee                   	out    %al,(%dx)
f0100868:	b2 fc                	mov    $0xfc,%dl
f010086a:	b0 00                	mov    $0x0,%al
f010086c:	ee                   	out    %al,(%dx)
f010086d:	b2 f9                	mov    $0xf9,%dl
f010086f:	b0 01                	mov    $0x1,%al
f0100871:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100872:	b2 fd                	mov    $0xfd,%dl
f0100874:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100875:	3c ff                	cmp    $0xff,%al
f0100877:	0f 95 45 e7          	setne  -0x19(%ebp)
f010087b:	8a 45 e7             	mov    -0x19(%ebp),%al
f010087e:	a2 20 23 12 f0       	mov    %al,0xf0122320
f0100883:	89 da                	mov    %ebx,%edx
f0100885:	ec                   	in     (%dx),%al
f0100886:	89 ca                	mov    %ecx,%edx
f0100888:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100889:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f010088d:	75 0c                	jne    f010089b <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f010088f:	c7 04 24 9c 4c 10 f0 	movl   $0xf0104c9c,(%esp)
f0100896:	e8 bb 31 00 00       	call   f0103a56 <cprintf>
}
f010089b:	83 c4 2c             	add    $0x2c,%esp
f010089e:	5b                   	pop    %ebx
f010089f:	5e                   	pop    %esi
f01008a0:	5f                   	pop    %edi
f01008a1:	5d                   	pop    %ebp
f01008a2:	c3                   	ret    

f01008a3 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01008a3:	55                   	push   %ebp
f01008a4:	89 e5                	mov    %esp,%ebp
f01008a6:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01008a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01008ac:	e8 f2 f8 ff ff       	call   f01001a3 <cons_putc>
}
f01008b1:	c9                   	leave  
f01008b2:	c3                   	ret    

f01008b3 <getchar>:

int
getchar(void)
{
f01008b3:	55                   	push   %ebp
f01008b4:	89 e5                	mov    %esp,%ebp
f01008b6:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01008b9:	e8 c3 fe ff ff       	call   f0100781 <cons_getc>
f01008be:	85 c0                	test   %eax,%eax
f01008c0:	74 f7                	je     f01008b9 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01008c2:	c9                   	leave  
f01008c3:	c3                   	ret    

f01008c4 <iscons>:

int
iscons(int fdnum)
{
f01008c4:	55                   	push   %ebp
f01008c5:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01008c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01008cc:	5d                   	pop    %ebp
f01008cd:	c3                   	ret    
	...

f01008d0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008d0:	55                   	push   %ebp
f01008d1:	89 e5                	mov    %esp,%ebp
f01008d3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008d6:	c7 04 24 b9 4c 10 f0 	movl   $0xf0104cb9,(%esp)
f01008dd:	e8 74 31 00 00       	call   f0103a56 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008e2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01008e9:	00 
f01008ea:	c7 04 24 30 4e 10 f0 	movl   $0xf0104e30,(%esp)
f01008f1:	e8 60 31 00 00       	call   f0103a56 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008f6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01008fd:	00 
f01008fe:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100905:	f0 
f0100906:	c7 04 24 58 4e 10 f0 	movl   $0xf0104e58,(%esp)
f010090d:	e8 44 31 00 00       	call   f0103a56 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100912:	c7 44 24 08 3e 49 10 	movl   $0x10493e,0x8(%esp)
f0100919:	00 
f010091a:	c7 44 24 04 3e 49 10 	movl   $0xf010493e,0x4(%esp)
f0100921:	f0 
f0100922:	c7 04 24 7c 4e 10 f0 	movl   $0xf0104e7c,(%esp)
f0100929:	e8 28 31 00 00       	call   f0103a56 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010092e:	c7 44 24 08 20 23 12 	movl   $0x122320,0x8(%esp)
f0100935:	00 
f0100936:	c7 44 24 04 20 23 12 	movl   $0xf0122320,0x4(%esp)
f010093d:	f0 
f010093e:	c7 04 24 a0 4e 10 f0 	movl   $0xf0104ea0,(%esp)
f0100945:	e8 0c 31 00 00       	call   f0103a56 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010094a:	c7 44 24 08 80 29 12 	movl   $0x122980,0x8(%esp)
f0100951:	00 
f0100952:	c7 44 24 04 80 29 12 	movl   $0xf0122980,0x4(%esp)
f0100959:	f0 
f010095a:	c7 04 24 c4 4e 10 f0 	movl   $0xf0104ec4,(%esp)
f0100961:	e8 f0 30 00 00       	call   f0103a56 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100966:	b8 7f 2d 12 f0       	mov    $0xf0122d7f,%eax
f010096b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100970:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100975:	89 c2                	mov    %eax,%edx
f0100977:	85 c0                	test   %eax,%eax
f0100979:	79 06                	jns    f0100981 <mon_kerninfo+0xb1>
f010097b:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100981:	c1 fa 0a             	sar    $0xa,%edx
f0100984:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100988:	c7 04 24 e8 4e 10 f0 	movl   $0xf0104ee8,(%esp)
f010098f:	e8 c2 30 00 00       	call   f0103a56 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100994:	b8 00 00 00 00       	mov    $0x0,%eax
f0100999:	c9                   	leave  
f010099a:	c3                   	ret    

f010099b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010099b:	55                   	push   %ebp
f010099c:	89 e5                	mov    %esp,%ebp
f010099e:	56                   	push   %esi
f010099f:	53                   	push   %ebx
f01009a0:	83 ec 10             	sub    $0x10,%esp
f01009a3:	bb 44 5a 10 f0       	mov    $0xf0105a44,%ebx
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
f01009a8:	be b0 5a 10 f0       	mov    $0xf0105ab0,%esi
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01009ad:	8b 03                	mov    (%ebx),%eax
f01009af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009b3:	8b 43 fc             	mov    -0x4(%ebx),%eax
f01009b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ba:	c7 04 24 d2 4c 10 f0 	movl   $0xf0104cd2,(%esp)
f01009c1:	e8 90 30 00 00       	call   f0103a56 <cprintf>
f01009c6:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01009c9:	39 f3                	cmp    %esi,%ebx
f01009cb:	75 e0                	jne    f01009ad <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01009cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01009d2:	83 c4 10             	add    $0x10,%esp
f01009d5:	5b                   	pop    %ebx
f01009d6:	5e                   	pop    %esi
f01009d7:	5d                   	pop    %ebp
f01009d8:	c3                   	ret    

f01009d9 <mon_showvirtualmemory>:

    return 0;
}

int
mon_showvirtualmemory(int argc, char **argv, struct Trapframe *tf){
f01009d9:	55                   	push   %ebp
f01009da:	89 e5                	mov    %esp,%ebp
f01009dc:	57                   	push   %edi
f01009dd:	56                   	push   %esi
f01009de:	53                   	push   %ebx
f01009df:	83 ec 2c             	sub    $0x2c,%esp
f01009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f01009e5:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01009e9:	74 11                	je     f01009fc <mon_showvirtualmemory+0x23>
		cprintf("mon_showvvirtualmemory: The number of parameters is two.\n");
f01009eb:	c7 04 24 14 4f 10 f0 	movl   $0xf0104f14,(%esp)
f01009f2:	e8 5f 30 00 00       	call   f0103a56 <cprintf>
		return 0;
f01009f7:	e9 37 01 00 00       	jmp    f0100b33 <mon_showvirtualmemory+0x15a>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f01009fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a03:	00 
f0100a04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100a07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a0b:	8b 43 04             	mov    0x4(%ebx),%eax
f0100a0e:	89 04 24             	mov    %eax,(%esp)
f0100a11:	e8 0e 3c 00 00       	call   f0104624 <strtol>
f0100a16:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0100a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1b:	80 38 00             	cmpb   $0x0,(%eax)
f0100a1e:	74 11                	je     f0100a31 <mon_showvirtualmemory+0x58>
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
f0100a20:	c7 04 24 50 4f 10 f0 	movl   $0xf0104f50,(%esp)
f0100a27:	e8 2a 30 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100a2c:	e9 02 01 00 00       	jmp    f0100b33 <mon_showvirtualmemory+0x15a>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100a31:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a38:	00 
f0100a39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a40:	8b 43 08             	mov    0x8(%ebx),%eax
f0100a43:	89 04 24             	mov    %eax,(%esp)
f0100a46:	e8 d9 3b 00 00       	call   f0104624 <strtol>
	if (*errChar){
f0100a4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100a4e:	80 3a 00             	cmpb   $0x0,(%edx)
f0100a51:	74 11                	je     f0100a64 <mon_showvirtualmemory+0x8b>
		cprintf("mon_showvvirtualmemory: The second argument is not a number.\n");
f0100a53:	c7 04 24 90 4f 10 f0 	movl   $0xf0104f90,(%esp)
f0100a5a:	e8 f7 2f 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100a5f:	e9 cf 00 00 00       	jmp    f0100b33 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr&0x3){
f0100a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0100a6a:	74 11                	je     f0100a7d <mon_showvirtualmemory+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f0100a6c:	c7 04 24 d0 4f 10 f0 	movl   $0xf0104fd0,(%esp)
f0100a73:	e8 de 2f 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100a78:	e9 b6 00 00 00       	jmp    f0100b33 <mon_showvirtualmemory+0x15a>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100a7d:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3){
f0100a7f:	a8 03                	test   $0x3,%al
f0100a81:	74 11                	je     f0100a94 <mon_showvirtualmemory+0xbb>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0100a83:	c7 04 24 0c 50 10 f0 	movl   $0xf010500c,(%esp)
f0100a8a:	e8 c7 2f 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100a8f:	e9 9f 00 00 00       	jmp    f0100b33 <mon_showvirtualmemory+0x15a>
	}
	if (StartAddr > EndAddr){
f0100a94:	39 c6                	cmp    %eax,%esi
f0100a96:	0f 86 88 00 00 00    	jbe    f0100b24 <mon_showvirtualmemory+0x14b>
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
f0100a9c:	c7 04 24 48 50 10 f0 	movl   $0xf0105048,(%esp)
f0100aa3:	e8 ae 2f 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100aa8:	e9 86 00 00 00       	jmp    f0100b33 <mon_showvirtualmemory+0x15a>
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
		switch (c){
f0100aad:	83 fe 01             	cmp    $0x1,%esi
f0100ab0:	74 2f                	je     f0100ae1 <mon_showvirtualmemory+0x108>
f0100ab2:	83 fe 01             	cmp    $0x1,%esi
f0100ab5:	7f 06                	jg     f0100abd <mon_showvirtualmemory+0xe4>
f0100ab7:	85 f6                	test   %esi,%esi
f0100ab9:	74 0e                	je     f0100ac9 <mon_showvirtualmemory+0xf0>
f0100abb:	eb 5e                	jmp    f0100b1b <mon_showvirtualmemory+0x142>
f0100abd:	83 fe 02             	cmp    $0x2,%esi
f0100ac0:	74 33                	je     f0100af5 <mon_showvirtualmemory+0x11c>
f0100ac2:	83 fe 03             	cmp    $0x3,%esi
f0100ac5:	75 54                	jne    f0100b1b <mon_showvirtualmemory+0x142>
f0100ac7:	eb 40                	jmp    f0100b09 <mon_showvirtualmemory+0x130>
			case 0:cprintf("0x%08x   :0x%08x    ",Address,*(int*)Address);break;
f0100ac9:	8b 03                	mov    (%ebx),%eax
f0100acb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100acf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ad3:	c7 04 24 db 4c 10 f0 	movl   $0xf0104cdb,(%esp)
f0100ada:	e8 77 2f 00 00       	call   f0103a56 <cprintf>
f0100adf:	eb 3a                	jmp    f0100b1b <mon_showvirtualmemory+0x142>
			case 1:cprintf("0x%08x    ",*(int*)Address);break;
f0100ae1:	8b 03                	mov    (%ebx),%eax
f0100ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae7:	c7 04 24 e5 4c 10 f0 	movl   $0xf0104ce5,(%esp)
f0100aee:	e8 63 2f 00 00       	call   f0103a56 <cprintf>
f0100af3:	eb 26                	jmp    f0100b1b <mon_showvirtualmemory+0x142>
			case 2:cprintf("0x%08x    ",*(int*)Address);break;
f0100af5:	8b 03                	mov    (%ebx),%eax
f0100af7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100afb:	c7 04 24 e5 4c 10 f0 	movl   $0xf0104ce5,(%esp)
f0100b02:	e8 4f 2f 00 00       	call   f0103a56 <cprintf>
f0100b07:	eb 12                	jmp    f0100b1b <mon_showvirtualmemory+0x142>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
f0100b09:	8b 03                	mov    (%ebx),%eax
f0100b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b0f:	c7 04 24 f0 4c 10 f0 	movl   $0xf0104cf0,(%esp)
f0100b16:	e8 3b 2f 00 00       	call   f0103a56 <cprintf>
		}
		c = (c+1)&3;
f0100b1b:	46                   	inc    %esi
f0100b1c:	83 e6 03             	and    $0x3,%esi
	if (StartAddr > EndAddr){
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100b1f:	83 c3 04             	add    $0x4,%ebx
f0100b22:	eb 07                	jmp    f0100b2b <mon_showvirtualmemory+0x152>
	}
	if (EndAddr&0x3){
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
f0100b24:	89 f3                	mov    %esi,%ebx
f0100b26:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
f0100b2b:	39 fb                	cmp    %edi,%ebx
f0100b2d:	0f 82 7a ff ff ff    	jb     f0100aad <mon_showvirtualmemory+0xd4>
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
		}
		c = (c+1)&3;
	}
	return 0;
}
f0100b33:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b38:	83 c4 2c             	add    $0x2c,%esp
f0100b3b:	5b                   	pop    %ebx
f0100b3c:	5e                   	pop    %esi
f0100b3d:	5f                   	pop    %edi
f0100b3e:	5d                   	pop    %ebp
f0100b3f:	c3                   	ret    

f0100b40 <mon_va2pa>:
int
mon_va2pa(int argc, char **argv, struct Trapframe *tf){
f0100b40:	55                   	push   %ebp
f0100b41:	89 e5                	mov    %esp,%ebp
f0100b43:	83 ec 28             	sub    $0x28,%esp
	if(argc!=2){
f0100b46:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100b4a:	74 11                	je     f0100b5d <mon_va2pa+0x1d>
		cprintf("mon_va2pa: The number of parameters is one.\n");
f0100b4c:	c7 04 24 9c 50 10 f0 	movl   $0xf010509c,(%esp)
f0100b53:	e8 fe 2e 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100b58:	e9 cc 00 00 00       	jmp    f0100c29 <mon_va2pa+0xe9>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100b5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b64:	00 
f0100b65:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b6f:	8b 40 04             	mov    0x4(%eax),%eax
f0100b72:	89 04 24             	mov    %eax,(%esp)
f0100b75:	e8 aa 3a 00 00       	call   f0104624 <strtol>
	if (*errChar){
f0100b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100b7d:	80 3a 00             	cmpb   $0x0,(%edx)
f0100b80:	74 11                	je     f0100b93 <mon_va2pa+0x53>
		cprintf("mon_va2pa: The argument is not a number.\n");
f0100b82:	c7 04 24 cc 50 10 f0 	movl   $0xf01050cc,(%esp)
f0100b89:	e8 c8 2e 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100b8e:	e9 96 00 00 00       	jmp    f0100c29 <mon_va2pa+0xe9>
	}
	pde_t *pde = &kern_pgdir[PDX(Address)];
f0100b93:	89 c1                	mov    %eax,%ecx
f0100b95:	c1 e9 16             	shr    $0x16,%ecx
	if (*pde & PTE_P){
f0100b98:	8b 15 8c 29 12 f0    	mov    0xf012298c,%edx
f0100b9e:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0100ba1:	f6 c2 01             	test   $0x1,%dl
f0100ba4:	74 77                	je     f0100c1d <mon_va2pa+0xdd>
		pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0100ba6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bac:	89 d1                	mov    %edx,%ecx
f0100bae:	c1 e9 0c             	shr    $0xc,%ecx
f0100bb1:	3b 0d 88 29 12 f0    	cmp    0xf0122988,%ecx
f0100bb7:	72 20                	jb     f0100bd9 <mon_va2pa+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bb9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100bbd:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0100bc4:	f0 
f0100bc5:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
f0100bcc:	00 
f0100bcd:	c7 04 24 f8 4c 10 f0 	movl   $0xf0104cf8,(%esp)
f0100bd4:	e8 bb f4 ff ff       	call   f0100094 <_panic>
f0100bd9:	89 c1                	mov    %eax,%ecx
f0100bdb:	c1 e9 0c             	shr    $0xc,%ecx
f0100bde:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		if (*pte & PTE_P){
f0100be4:	8b 94 8a 00 00 00 f0 	mov    -0x10000000(%edx,%ecx,4),%edx
f0100beb:	f6 c2 01             	test   $0x1,%dl
f0100bee:	74 1f                	je     f0100c0f <mon_va2pa+0xcf>
			cprintf("The physical address is 0x%08x.\n",PTE_ADDR(*pte)|(Address&0x3ff));
f0100bf0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bf6:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100bfb:	09 d0                	or     %edx,%eax
f0100bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c01:	c7 04 24 1c 51 10 f0 	movl   $0xf010511c,(%esp)
f0100c08:	e8 49 2e 00 00       	call   f0103a56 <cprintf>
f0100c0d:	eb 1a                	jmp    f0100c29 <mon_va2pa+0xe9>
		}
		else 
			cprintf("This is not a valid virtual address.\n");
f0100c0f:	c7 04 24 40 51 10 f0 	movl   $0xf0105140,(%esp)
f0100c16:	e8 3b 2e 00 00       	call   f0103a56 <cprintf>
f0100c1b:	eb 0c                	jmp    f0100c29 <mon_va2pa+0xe9>
	}
	else 
		cprintf("This is not a valid virtual address.\n");
f0100c1d:	c7 04 24 40 51 10 f0 	movl   $0xf0105140,(%esp)
f0100c24:	e8 2d 2e 00 00       	call   f0103a56 <cprintf>
	return 0;
}
f0100c29:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c2e:	c9                   	leave  
f0100c2f:	c3                   	ret    

f0100c30 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100c30:	55                   	push   %ebp
f0100c31:	89 e5                	mov    %esp,%ebp
f0100c33:	57                   	push   %edi
f0100c34:	56                   	push   %esi
f0100c35:	53                   	push   %ebx
f0100c36:	83 ec 6c             	sub    $0x6c,%esp
	cprintf("\033[34;45mThe parameters are: 34 and 45\n");
	cprintf("\033[35;46mThe parameters are: 35 and 46\n");
	cprintf("\033[36;47mThe parameters are: 36 and 47\n");
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
f0100c39:	c7 04 24 07 4d 10 f0 	movl   $0xf0104d07,(%esp)
f0100c40:	e8 11 2e 00 00       	call   f0103a56 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100c45:	89 eb                	mov    %ebp,%ebx
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
		eip = *((uint32_t *) ebp + 1);
		debuginfo_eip(eip, &info);
f0100c47:	8d 7d d0             	lea    -0x30(%ebp),%edi
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100c4a:	eb 6d                	jmp    f0100cb9 <mon_backtrace+0x89>
		eip = *((uint32_t *) ebp + 1);
f0100c4c:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f0100c4f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c53:	89 34 24             	mov    %esi,(%esp)
f0100c56:	e8 f5 2e 00 00       	call   f0103b50 <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n         %s:%d: %.*s+%d\n",
f0100c5b:	89 f0                	mov    %esi,%eax
f0100c5d:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100c60:	89 44 24 30          	mov    %eax,0x30(%esp)
f0100c64:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c67:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100c6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c6e:	89 44 24 28          	mov    %eax,0x28(%esp)
f0100c72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c75:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100c79:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c7c:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100c80:	8b 43 18             	mov    0x18(%ebx),%eax
f0100c83:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100c87:	8b 43 14             	mov    0x14(%ebx),%eax
f0100c8a:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100c8e:	8b 43 10             	mov    0x10(%ebx),%eax
f0100c91:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100c95:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100c98:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c9c:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ca3:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100ca7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cab:	c7 04 24 68 51 10 f0 	movl   $0xf0105168,(%esp)
f0100cb2:	e8 9f 2d 00 00       	call   f0103a56 <cprintf>
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
f0100cb7:	8b 1b                	mov    (%ebx),%ebx
f0100cb9:	85 db                	test   %ebx,%ebx
f0100cbb:	75 8f                	jne    f0100c4c <mon_backtrace+0x1c>
				info.eip_fn_namelen,
				info.eip_fn_name,
				eip - info.eip_fn_addr);
	}
	return 0;
}
f0100cbd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cc2:	83 c4 6c             	add    $0x6c,%esp
f0100cc5:	5b                   	pop    %ebx
f0100cc6:	5e                   	pop    %esi
f0100cc7:	5f                   	pop    %edi
f0100cc8:	5d                   	pop    %ebp
f0100cc9:	c3                   	ret    

f0100cca <mon_pa2va>:
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100cca:	55                   	push   %ebp
f0100ccb:	89 e5                	mov    %esp,%ebp
f0100ccd:	57                   	push   %edi
f0100cce:	56                   	push   %esi
f0100ccf:	53                   	push   %ebx
f0100cd0:	83 ec 3c             	sub    $0x3c,%esp
	if(argc!=2){
f0100cd3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100cd7:	74 11                	je     f0100cea <mon_pa2va+0x20>
		cprintf("mon_pa2va: The number of parameters is one.\n");
f0100cd9:	c7 04 24 b8 51 10 f0 	movl   $0xf01051b8,(%esp)
f0100ce0:	e8 71 2d 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100ce5:	e9 34 01 00 00       	jmp    f0100e1e <mon_pa2va+0x154>
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
f0100cea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100cf1:	00 
f0100cf2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cfc:	8b 40 04             	mov    0x4(%eax),%eax
f0100cff:	89 04 24             	mov    %eax,(%esp)
f0100d02:	e8 1d 39 00 00       	call   f0104624 <strtol>
f0100d07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (*errChar){
f0100d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d0d:	80 38 00             	cmpb   $0x0,(%eax)
f0100d10:	74 11                	je     f0100d23 <mon_pa2va+0x59>
		cprintf("mon_pa2va: The argument is not a number.\n");
f0100d12:	c7 04 24 e8 51 10 f0 	movl   $0xf01051e8,(%esp)
f0100d19:	e8 38 2d 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100d1e:	e9 fb 00 00 00       	jmp    f0100e1e <mon_pa2va+0x154>
		cprintf("mon_pa2va: The number of parameters is one.\n");
		return 0;
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
	if (*errChar){
f0100d23:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0100d2a:	bf 00 00 00 00       	mov    $0x0,%edi
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100d2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d32:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100d37:	89 45 cc             	mov    %eax,-0x34(%ebp)
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
f0100d3a:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0100d3d:	c1 e6 02             	shl    $0x2,%esi
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
f0100d40:	03 35 8c 29 12 f0    	add    0xf012298c,%esi
		if (*pde & PTE_P){
f0100d46:	f6 06 01             	testb  $0x1,(%esi)
f0100d49:	0f 84 a1 00 00 00    	je     f0100df0 <mon_pa2va+0x126>
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100d4f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100d52:	c1 e0 16             	shl    $0x16,%eax
f0100d55:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d58:	bb 00 00 00 00       	mov    $0x0,%ebx
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
f0100d5d:	8b 06                	mov    (%esi),%eax
f0100d5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d64:	89 c2                	mov    %eax,%edx
f0100d66:	c1 ea 0c             	shr    $0xc,%edx
f0100d69:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f0100d6f:	72 20                	jb     f0100d91 <mon_pa2va+0xc7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d71:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d75:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0100d7c:	f0 
f0100d7d:	c7 44 24 04 ac 01 00 	movl   $0x1ac,0x4(%esp)
f0100d84:	00 
f0100d85:	c7 04 24 f8 4c 10 f0 	movl   $0xf0104cf8,(%esp)
f0100d8c:	e8 03 f3 ff ff       	call   f0100094 <_panic>
				if (*pte & PTE_P){
f0100d91:	8b 84 98 00 00 00 f0 	mov    -0x10000000(%eax,%ebx,4),%eax
f0100d98:	a8 01                	test   $0x1,%al
f0100d9a:	74 47                	je     f0100de3 <mon_pa2va+0x119>
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
f0100d9c:	33 45 d4             	xor    -0x2c(%ebp),%eax
f0100d9f:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
f0100da4:	75 3d                	jne    f0100de3 <mon_pa2va+0x119>
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100da6:	85 ff                	test   %edi,%edi
f0100da8:	75 1d                	jne    f0100dc7 <mon_pa2va+0xfd>
f0100daa:	89 d8                	mov    %ebx,%eax
f0100dac:	c1 e0 0c             	shl    $0xc,%eax
f0100daf:	0b 45 d0             	or     -0x30(%ebp),%eax
f0100db2:	0b 45 cc             	or     -0x34(%ebp),%eax
f0100db5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100db9:	c7 04 24 14 52 10 f0 	movl   $0xf0105214,(%esp)
f0100dc0:	e8 91 2c 00 00       	call   f0103a56 <cprintf>
f0100dc5:	eb 1b                	jmp    f0100de2 <mon_pa2va+0x118>
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
f0100dc7:	89 d8                	mov    %ebx,%eax
f0100dc9:	c1 e0 0c             	shl    $0xc,%eax
f0100dcc:	0b 45 d0             	or     -0x30(%ebp),%eax
f0100dcf:	0b 45 cc             	or     -0x34(%ebp),%eax
f0100dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dd6:	c7 04 24 18 4d 10 f0 	movl   $0xf0104d18,(%esp)
f0100ddd:	e8 74 2c 00 00       	call   f0103a56 <cprintf>
						cnt++;
f0100de2:	47                   	inc    %edi
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
f0100de3:	43                   	inc    %ebx
f0100de4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100dea:	0f 85 6d ff ff ff    	jne    f0100d5d <mon_pa2va+0x93>
	if (*errChar){
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
f0100df0:	ff 45 c8             	incl   -0x38(%ebp)
f0100df3:	81 7d c8 00 04 00 00 	cmpl   $0x400,-0x38(%ebp)
f0100dfa:	0f 85 3a ff ff ff    	jne    f0100d3a <mon_pa2va+0x70>
					}
				}
			}
		}
	}
	if (cnt == 0)
f0100e00:	85 ff                	test   %edi,%edi
f0100e02:	75 0e                	jne    f0100e12 <mon_pa2va+0x148>
		cprintf("There is no virtual address.\n");
f0100e04:	c7 04 24 20 4d 10 f0 	movl   $0xf0104d20,(%esp)
f0100e0b:	e8 46 2c 00 00       	call   f0103a56 <cprintf>
f0100e10:	eb 0c                	jmp    f0100e1e <mon_pa2va+0x154>
	else cprintf(".\n");
f0100e12:	c7 04 24 3b 4d 10 f0 	movl   $0xf0104d3b,(%esp)
f0100e19:	e8 38 2c 00 00       	call   f0103a56 <cprintf>
	return 0;
f0100e1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e23:	83 c4 3c             	add    $0x3c,%esp
f0100e26:	5b                   	pop    %ebx
f0100e27:	5e                   	pop    %esi
f0100e28:	5f                   	pop    %edi
f0100e29:	5d                   	pop    %ebp
f0100e2a:	c3                   	ret    

f0100e2b <mon_showmappings>:
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f0100e2b:	55                   	push   %ebp
f0100e2c:	89 e5                	mov    %esp,%ebp
f0100e2e:	57                   	push   %edi
f0100e2f:	56                   	push   %esi
f0100e30:	53                   	push   %ebx
f0100e31:	83 ec 3c             	sub    $0x3c,%esp
f0100e34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3){
f0100e37:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100e3b:	74 11                	je     f0100e4e <mon_showmappings+0x23>
		cprintf("mon_showmappings: The number of parameters is two.\n");
f0100e3d:	c7 04 24 38 52 10 f0 	movl   $0xf0105238,(%esp)
f0100e44:	e8 0d 2c 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100e49:	e9 9d 01 00 00       	jmp    f0100feb <mon_showmappings+0x1c0>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f0100e4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100e55:	00 
f0100e56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100e59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100e60:	89 04 24             	mov    %eax,(%esp)
f0100e63:	e8 bc 37 00 00       	call   f0104624 <strtol>
f0100e68:	89 c6                	mov    %eax,%esi
	if (*errChar){
f0100e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e6d:	80 38 00             	cmpb   $0x0,(%eax)
f0100e70:	74 11                	je     f0100e83 <mon_showmappings+0x58>
		cprintf("mon_showmappings: The first argument is not a number.\n");
f0100e72:	c7 04 24 6c 52 10 f0 	movl   $0xf010526c,(%esp)
f0100e79:	e8 d8 2b 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100e7e:	e9 68 01 00 00       	jmp    f0100feb <mon_showmappings+0x1c0>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100e83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100e8a:	00 
f0100e8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e92:	8b 43 08             	mov    0x8(%ebx),%eax
f0100e95:	89 04 24             	mov    %eax,(%esp)
f0100e98:	e8 87 37 00 00       	call   f0104624 <strtol>
	if (*errChar){
f0100e9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ea0:	80 3a 00             	cmpb   $0x0,(%edx)
f0100ea3:	74 11                	je     f0100eb6 <mon_showmappings+0x8b>
		cprintf("mon_showmappings: The second argument is not a number.\n");
f0100ea5:	c7 04 24 a4 52 10 f0 	movl   $0xf01052a4,(%esp)
f0100eac:	e8 a5 2b 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100eb1:	e9 35 01 00 00       	jmp    f0100feb <mon_showmappings+0x1c0>
	}
	if (StartAddr&0x3ff){
f0100eb6:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0100ebc:	74 11                	je     f0100ecf <mon_showmappings+0xa4>
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
f0100ebe:	c7 04 24 dc 52 10 f0 	movl   $0xf01052dc,(%esp)
f0100ec5:	e8 8c 2b 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100eca:	e9 1c 01 00 00       	jmp    f0100feb <mon_showmappings+0x1c0>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showmappings: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0100ecf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	}
	if (StartAddr&0x3ff){
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f0100ed2:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0100ed7:	74 11                	je     f0100eea <mon_showmappings+0xbf>
		cprintf("mon_showmappings: The second parameter is not aligned.\n");
f0100ed9:	c7 04 24 14 53 10 f0 	movl   $0xf0105314,(%esp)
f0100ee0:	e8 71 2b 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100ee5:	e9 01 01 00 00       	jmp    f0100feb <mon_showmappings+0x1c0>
	}
	if (StartAddr > EndAddr){
f0100eea:	39 c6                	cmp    %eax,%esi
f0100eec:	76 11                	jbe    f0100eff <mon_showmappings+0xd4>
		cprintf("mon_shopmappings: The first parameter is larger than the second parameter.\n");
f0100eee:	c7 04 24 4c 53 10 f0 	movl   $0xf010534c,(%esp)
f0100ef5:	e8 5c 2b 00 00       	call   f0103a56 <cprintf>
		return 0;
f0100efa:	e9 ec 00 00 00       	jmp    f0100feb <mon_showmappings+0x1c0>
	}

    cprintf(
f0100eff:	c7 04 24 98 53 10 f0 	movl   $0xf0105398,(%esp)
f0100f06:	e8 4b 2b 00 00       	call   f0103a56 <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0100f0b:	89 f3                	mov    %esi,%ebx
f0100f0d:	e9 d0 00 00 00       	jmp    f0100fe2 <mon_showmappings+0x1b7>
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0100f12:	89 da                	mov    %ebx,%edx
f0100f14:	c1 ea 16             	shr    $0x16,%edx
		if (*pde & PTE_P){
f0100f17:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0100f1c:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100f1f:	a8 01                	test   $0x1,%al
f0100f21:	0f 84 a5 00 00 00    	je     f0100fcc <mon_showmappings+0x1a1>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0100f27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f2c:	89 c2                	mov    %eax,%edx
f0100f2e:	c1 ea 0c             	shr    $0xc,%edx
f0100f31:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f0100f37:	72 20                	jb     f0100f59 <mon_showmappings+0x12e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f3d:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0100f44:	f0 
f0100f45:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
f0100f4c:	00 
f0100f4d:	c7 04 24 f8 4c 10 f0 	movl   $0xf0104cf8,(%esp)
f0100f54:	e8 3b f1 ff ff       	call   f0100094 <_panic>
f0100f59:	89 da                	mov    %ebx,%edx
f0100f5b:	c1 ea 0a             	shr    $0xa,%edx
f0100f5e:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100f64:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0100f6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if (*pte & PTE_P){
f0100f6e:	8b 10                	mov    (%eax),%edx
f0100f70:	f6 c2 01             	test   $0x1,%dl
f0100f73:	74 57                	je     f0100fcc <mon_showmappings+0x1a1>
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f0100f75:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100f7b:	b8 08 00 00 00       	mov    $0x8,%eax
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
f0100f80:	bf 08 00 00 00       	mov    $0x8,%edi
f0100f85:	89 fe                	mov    %edi,%esi
f0100f87:	29 c6                	sub    %eax,%esi
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
					permission[i] = Bit2Sign[8-i][(perm&1)];
f0100f89:	89 d1                	mov    %edx,%ecx
f0100f8b:	83 e1 01             	and    $0x1,%ecx
f0100f8e:	8a 8c 71 1c 5a 10 f0 	mov    -0xfefa5e4(%ecx,%esi,2),%cl
f0100f95:	88 4c 05 da          	mov    %cl,-0x26(%ebp,%eax,1)
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
f0100f99:	48                   	dec    %eax
f0100f9a:	d1 fa                	sar    %edx
f0100f9c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100f9f:	75 e4                	jne    f0100f85 <mon_showmappings+0x15a>
					permission[i] = Bit2Sign[8-i][(perm&1)];
				}
				permission[9]='\0';
f0100fa1:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
				cprintf("0x%08x             0x%08x             %s\n",Address,PTE_ADDR(*pte),permission);
f0100fa5:	8d 45 da             	lea    -0x26(%ebp),%eax
f0100fa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fac:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100faf:	8b 02                	mov    (%edx),%eax
f0100fb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fb6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fbe:	c7 04 24 cc 54 10 f0 	movl   $0xf01054cc,(%esp)
f0100fc5:	e8 8c 2a 00 00       	call   f0103a56 <cprintf>
				continue;
f0100fca:	eb 10                	jmp    f0100fdc <mon_showmappings+0x1b1>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
f0100fcc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fd0:	c7 04 24 f8 54 10 f0 	movl   $0xf01054f8,(%esp)
f0100fd7:	e8 7a 2a 00 00       	call   f0103a56 <cprintf>
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0100fdc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100fe2:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0100fe5:	0f 82 27 ff ff ff    	jb     f0100f12 <mon_showmappings+0xe7>
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}
f0100feb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff0:	83 c4 3c             	add    $0x3c,%esp
f0100ff3:	5b                   	pop    %ebx
f0100ff4:	5e                   	pop    %esi
f0100ff5:	5f                   	pop    %edi
f0100ff6:	5d                   	pop    %ebp
f0100ff7:	c3                   	ret    

f0100ff8 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	57                   	push   %edi
f0100ffc:	56                   	push   %esi
f0100ffd:	53                   	push   %ebx
f0100ffe:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101001:	c7 04 24 2c 55 10 f0 	movl   $0xf010552c,(%esp)
f0101008:	e8 49 2a 00 00       	call   f0103a56 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010100d:	c7 04 24 50 55 10 f0 	movl   $0xf0105550,(%esp)
f0101014:	e8 3d 2a 00 00       	call   f0103a56 <cprintf>


	while (1) {
		buf = readline("K> ");
f0101019:	c7 04 24 3e 4d 10 f0 	movl   $0xf0104d3e,(%esp)
f0101020:	e8 ab 32 00 00       	call   f01042d0 <readline>
f0101025:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101027:	85 c0                	test   %eax,%eax
f0101029:	74 ee                	je     f0101019 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010102b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0101032:	be 00 00 00 00       	mov    $0x0,%esi
f0101037:	eb 04                	jmp    f010103d <monitor+0x45>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101039:	c6 03 00             	movb   $0x0,(%ebx)
f010103c:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010103d:	8a 03                	mov    (%ebx),%al
f010103f:	84 c0                	test   %al,%al
f0101041:	74 5e                	je     f01010a1 <monitor+0xa9>
f0101043:	0f be c0             	movsbl %al,%eax
f0101046:	89 44 24 04          	mov    %eax,0x4(%esp)
f010104a:	c7 04 24 42 4d 10 f0 	movl   $0xf0104d42,(%esp)
f0101051:	e8 6f 34 00 00       	call   f01044c5 <strchr>
f0101056:	85 c0                	test   %eax,%eax
f0101058:	75 df                	jne    f0101039 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f010105a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010105d:	74 42                	je     f01010a1 <monitor+0xa9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010105f:	83 fe 0f             	cmp    $0xf,%esi
f0101062:	75 16                	jne    f010107a <monitor+0x82>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101064:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010106b:	00 
f010106c:	c7 04 24 47 4d 10 f0 	movl   $0xf0104d47,(%esp)
f0101073:	e8 de 29 00 00       	call   f0103a56 <cprintf>
f0101078:	eb 9f                	jmp    f0101019 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f010107a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010107e:	46                   	inc    %esi
f010107f:	eb 01                	jmp    f0101082 <monitor+0x8a>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0101081:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101082:	8a 03                	mov    (%ebx),%al
f0101084:	84 c0                	test   %al,%al
f0101086:	74 b5                	je     f010103d <monitor+0x45>
f0101088:	0f be c0             	movsbl %al,%eax
f010108b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010108f:	c7 04 24 42 4d 10 f0 	movl   $0xf0104d42,(%esp)
f0101096:	e8 2a 34 00 00       	call   f01044c5 <strchr>
f010109b:	85 c0                	test   %eax,%eax
f010109d:	74 e2                	je     f0101081 <monitor+0x89>
f010109f:	eb 9c                	jmp    f010103d <monitor+0x45>
			buf++;
	}
	argv[argc] = 0;
f01010a1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01010a8:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01010a9:	85 f6                	test   %esi,%esi
f01010ab:	0f 84 68 ff ff ff    	je     f0101019 <monitor+0x21>
f01010b1:	bb 40 5a 10 f0       	mov    $0xf0105a40,%ebx
f01010b6:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01010bb:	8b 03                	mov    (%ebx),%eax
f01010bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010c1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01010c4:	89 04 24             	mov    %eax,(%esp)
f01010c7:	e8 a6 33 00 00       	call   f0104472 <strcmp>
f01010cc:	85 c0                	test   %eax,%eax
f01010ce:	75 24                	jne    f01010f4 <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f01010d0:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01010d3:	8b 55 08             	mov    0x8(%ebp),%edx
f01010d6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01010da:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01010dd:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010e1:	89 34 24             	mov    %esi,(%esp)
f01010e4:	ff 14 85 48 5a 10 f0 	call   *-0xfefa5b8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01010eb:	85 c0                	test   %eax,%eax
f01010ed:	78 26                	js     f0101115 <monitor+0x11d>
f01010ef:	e9 25 ff ff ff       	jmp    f0101019 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01010f4:	47                   	inc    %edi
f01010f5:	83 c3 0c             	add    $0xc,%ebx
f01010f8:	83 ff 09             	cmp    $0x9,%edi
f01010fb:	75 be                	jne    f01010bb <monitor+0xc3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01010fd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101100:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101104:	c7 04 24 64 4d 10 f0 	movl   $0xf0104d64,(%esp)
f010110b:	e8 46 29 00 00       	call   f0103a56 <cprintf>
f0101110:	e9 04 ff ff ff       	jmp    f0101019 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101115:	83 c4 5c             	add    $0x5c,%esp
f0101118:	5b                   	pop    %ebx
f0101119:	5e                   	pop    %esi
f010111a:	5f                   	pop    %edi
f010111b:	5d                   	pop    %ebp
f010111c:	c3                   	ret    

f010111d <Sign2Perm>:
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}

int Sign2Perm(char *s){
f010111d:	55                   	push   %ebp
f010111e:	89 e5                	mov    %esp,%ebp
f0101120:	56                   	push   %esi
f0101121:	53                   	push   %ebx
f0101122:	83 ec 10             	sub    $0x10,%esp
f0101125:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int l = strlen(s);
f0101128:	89 1c 24             	mov    %ebx,(%esp)
f010112b:	e8 68 32 00 00       	call   f0104398 <strlen>
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101130:	ba 00 00 00 00       	mov    $0x0,%edx
    return 0;
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
f0101135:	be 00 00 00 00       	mov    $0x0,%esi
	for (int i=0;i<l;i++){
f010113a:	eb 47                	jmp    f0101183 <Sign2Perm+0x66>
		switch(s[i]){
f010113c:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f010113f:	83 e9 41             	sub    $0x41,%ecx
f0101142:	80 f9 16             	cmp    $0x16,%cl
f0101145:	77 42                	ja     f0101189 <Sign2Perm+0x6c>
f0101147:	0f b6 c9             	movzbl %cl,%ecx
f010114a:	ff 24 8d c0 59 10 f0 	jmp    *-0xfefa640(,%ecx,4)
			case 'P':Perm|=PTE_P;break;
f0101151:	83 ce 01             	or     $0x1,%esi
f0101154:	eb 2c                	jmp    f0101182 <Sign2Perm+0x65>
			case 'W':Perm|=PTE_W;break;
f0101156:	83 ce 02             	or     $0x2,%esi
f0101159:	eb 27                	jmp    f0101182 <Sign2Perm+0x65>
			case 'U':Perm|=PTE_U;break;
f010115b:	83 ce 04             	or     $0x4,%esi
f010115e:	eb 22                	jmp    f0101182 <Sign2Perm+0x65>
			case 'T':Perm|=PTE_PWT;break;
f0101160:	83 ce 08             	or     $0x8,%esi
f0101163:	eb 1d                	jmp    f0101182 <Sign2Perm+0x65>
			case 'C':Perm|=PTE_PCD;break;
f0101165:	83 ce 10             	or     $0x10,%esi
f0101168:	eb 18                	jmp    f0101182 <Sign2Perm+0x65>
			case 'A':Perm|=PTE_A;break;
f010116a:	83 ce 20             	or     $0x20,%esi
f010116d:	eb 13                	jmp    f0101182 <Sign2Perm+0x65>
			case 'D':Perm|=PTE_D;break;
f010116f:	83 ce 40             	or     $0x40,%esi
f0101172:	eb 0e                	jmp    f0101182 <Sign2Perm+0x65>
			case 'I':Perm|=PTE_PS;break;
f0101174:	81 ce 80 00 00 00    	or     $0x80,%esi
f010117a:	eb 06                	jmp    f0101182 <Sign2Perm+0x65>
			case 'G':Perm|=PTE_G;break;
f010117c:	81 ce 00 01 00 00    	or     $0x100,%esi
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
	for (int i=0;i<l;i++){
f0101182:	42                   	inc    %edx
f0101183:	39 c2                	cmp    %eax,%edx
f0101185:	7c b5                	jl     f010113c <Sign2Perm+0x1f>
f0101187:	eb 05                	jmp    f010118e <Sign2Perm+0x71>
			case 'C':Perm|=PTE_PCD;break;
			case 'A':Perm|=PTE_A;break;
			case 'D':Perm|=PTE_D;break;
			case 'I':Perm|=PTE_PS;break;
			case 'G':Perm|=PTE_G;break;
			default:return -1;
f0101189:	be ff ff ff ff       	mov    $0xffffffff,%esi
		}
	}
	return Perm;
}
f010118e:	89 f0                	mov    %esi,%eax
f0101190:	83 c4 10             	add    $0x10,%esp
f0101193:	5b                   	pop    %ebx
f0101194:	5e                   	pop    %esi
f0101195:	5d                   	pop    %ebp
f0101196:	c3                   	ret    

f0101197 <mon_clearpermissions>:
    cprintf("Permission has been updated:\n");
    mon_showmappings(argc-1,argv,tf);
    return 0;
}

int mon_clearpermissions(int argc, char **argv, struct Trapframe *tf){
f0101197:	55                   	push   %ebp
f0101198:	89 e5                	mov    %esp,%ebp
f010119a:	57                   	push   %edi
f010119b:	56                   	push   %esi
f010119c:	53                   	push   %ebx
f010119d:	83 ec 2c             	sub    $0x2c,%esp
f01011a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if(argc!=4){
f01011a3:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f01011a7:	74 11                	je     f01011ba <mon_clearpermissions+0x23>
		cprintf("mon_clearpermissions: The number of parameters is three.\n");
f01011a9:	c7 04 24 78 55 10 f0 	movl   $0xf0105578,(%esp)
f01011b0:	e8 a1 28 00 00       	call   f0103a56 <cprintf>
		return 0;
f01011b5:	e9 65 01 00 00       	jmp    f010131f <mon_clearpermissions+0x188>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f01011ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011c1:	00 
f01011c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01011c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011c9:	8b 43 04             	mov    0x4(%ebx),%eax
f01011cc:	89 04 24             	mov    %eax,(%esp)
f01011cf:	e8 50 34 00 00       	call   f0104624 <strtol>
f01011d4:	89 c6                	mov    %eax,%esi
	if (*errChar){
f01011d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011d9:	80 38 00             	cmpb   $0x0,(%eax)
f01011dc:	74 11                	je     f01011ef <mon_clearpermissions+0x58>
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
f01011de:	c7 04 24 b4 55 10 f0 	movl   $0xf01055b4,(%esp)
f01011e5:	e8 6c 28 00 00       	call   f0103a56 <cprintf>
		return 0;
f01011ea:	e9 30 01 00 00       	jmp    f010131f <mon_clearpermissions+0x188>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f01011ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011f6:	00 
f01011f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01011fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011fe:	8b 43 08             	mov    0x8(%ebx),%eax
f0101201:	89 04 24             	mov    %eax,(%esp)
f0101204:	e8 1b 34 00 00       	call   f0104624 <strtol>
	if (*errChar){
f0101209:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010120c:	80 3a 00             	cmpb   $0x0,(%edx)
f010120f:	74 11                	je     f0101222 <mon_clearpermissions+0x8b>
		cprintf("mon_clearpermissions: The second argument is not a number.\n");
f0101211:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f0101218:	e8 39 28 00 00       	call   f0103a56 <cprintf>
		return 0;
f010121d:	e9 fd 00 00 00       	jmp    f010131f <mon_clearpermissions+0x188>
	}
	if (StartAddr&0x3ff){
f0101222:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0101228:	74 11                	je     f010123b <mon_clearpermissions+0xa4>
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
f010122a:	c7 04 24 d0 4f 10 f0 	movl   $0xf0104fd0,(%esp)
f0101231:	e8 20 28 00 00       	call   f0103a56 <cprintf>
		return 0;
f0101236:	e9 e4 00 00 00       	jmp    f010131f <mon_clearpermissions+0x188>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f010123b:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f010123d:	a9 ff 03 00 00       	test   $0x3ff,%eax
f0101242:	74 11                	je     f0101255 <mon_clearpermissions+0xbe>
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
f0101244:	c7 04 24 0c 50 10 f0 	movl   $0xf010500c,(%esp)
f010124b:	e8 06 28 00 00       	call   f0103a56 <cprintf>
		return 0;
f0101250:	e9 ca 00 00 00       	jmp    f010131f <mon_clearpermissions+0x188>
	}
	if (StartAddr > EndAddr){
f0101255:	39 c6                	cmp    %eax,%esi
f0101257:	76 11                	jbe    f010126a <mon_clearpermissions+0xd3>
		cprintf("mon_clearpermissions: The first parameter is larger than the second parameter.\n");
f0101259:	c7 04 24 2c 56 10 f0 	movl   $0xf010562c,(%esp)
f0101260:	e8 f1 27 00 00       	call   f0103a56 <cprintf>
		return 0;
f0101265:	e9 b5 00 00 00       	jmp    f010131f <mon_clearpermissions+0x188>
	}
	int Perm = Sign2Perm(argv[3]);
f010126a:	8b 43 0c             	mov    0xc(%ebx),%eax
f010126d:	89 04 24             	mov    %eax,(%esp)
f0101270:	e8 a8 fe ff ff       	call   f010111d <Sign2Perm>
	if (Perm == -1){
f0101275:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101278:	75 7c                	jne    f01012f6 <mon_clearpermissions+0x15f>
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
f010127a:	c7 04 24 7c 56 10 f0 	movl   $0xf010567c,(%esp)
f0101281:	e8 d0 27 00 00       	call   f0103a56 <cprintf>
		return 0;
f0101286:	e9 94 00 00 00       	jmp    f010131f <mon_clearpermissions+0x188>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f010128b:	89 f1                	mov    %esi,%ecx
f010128d:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f0101290:	8b 15 8c 29 12 f0    	mov    0xf012298c,%edx
f0101296:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f0101299:	f6 c2 01             	test   $0x1,%dl
f010129c:	74 50                	je     f01012ee <mon_clearpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f010129e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012a4:	89 d1                	mov    %edx,%ecx
f01012a6:	c1 e9 0c             	shr    $0xc,%ecx
f01012a9:	3b 0d 88 29 12 f0    	cmp    0xf0122988,%ecx
f01012af:	72 20                	jb     f01012d1 <mon_clearpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01012b5:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f01012bc:	f0 
f01012bd:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f01012c4:	00 
f01012c5:	c7 04 24 f8 4c 10 f0 	movl   $0xf0104cf8,(%esp)
f01012cc:	e8 c3 ed ff ff       	call   f0100094 <_panic>
f01012d1:	89 f1                	mov    %esi,%ecx
f01012d3:	c1 e9 0a             	shr    $0xa,%ecx
f01012d6:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f01012dc:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f01012e3:	8b 0a                	mov    (%edx),%ecx
f01012e5:	f6 c1 01             	test   $0x1,%cl
f01012e8:	74 04                	je     f01012ee <mon_clearpermissions+0x157>
				*pte = *pte & ~Perm;
f01012ea:	21 c1                	and    %eax,%ecx
f01012ec:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f01012ee:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01012f4:	eb 02                	jmp    f01012f8 <mon_clearpermissions+0x161>
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				*pte = *pte & ~Perm;
f01012f6:	f7 d0                	not    %eax
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f01012f8:	39 fe                	cmp    %edi,%esi
f01012fa:	72 8f                	jb     f010128b <mon_clearpermissions+0xf4>
				*pte = *pte & ~Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f01012fc:	c7 04 24 7a 4d 10 f0 	movl   $0xf0104d7a,(%esp)
f0101303:	e8 4e 27 00 00       	call   f0103a56 <cprintf>
    mon_showmappings(argc-1,argv,tf);
f0101308:	8b 45 10             	mov    0x10(%ebp),%eax
f010130b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010130f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101313:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f010131a:	e8 0c fb ff ff       	call   f0100e2b <mon_showmappings>

    return 0;
}
f010131f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101324:	83 c4 2c             	add    $0x2c,%esp
f0101327:	5b                   	pop    %ebx
f0101328:	5e                   	pop    %esi
f0101329:	5f                   	pop    %edi
f010132a:	5d                   	pop    %ebp
f010132b:	c3                   	ret    

f010132c <mon_setpermissions>:
			default:return -1;
		}
	}
	return Perm;
}
int mon_setpermissions(int argc, char **argv, struct Trapframe *tf){
f010132c:	55                   	push   %ebp
f010132d:	89 e5                	mov    %esp,%ebp
f010132f:	57                   	push   %edi
f0101330:	56                   	push   %esi
f0101331:	53                   	push   %ebx
f0101332:	83 ec 2c             	sub    $0x2c,%esp
f0101335:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=4){
f0101338:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f010133c:	74 11                	je     f010134f <mon_setpermissions+0x23>
		cprintf("mon_setpermissions: The number of parameters is three.\n");
f010133e:	c7 04 24 bc 56 10 f0 	movl   $0xf01056bc,(%esp)
f0101345:	e8 0c 27 00 00       	call   f0103a56 <cprintf>
		return 0;
f010134a:	e9 61 01 00 00       	jmp    f01014b0 <mon_setpermissions+0x184>
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
f010134f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101356:	00 
f0101357:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010135a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010135e:	8b 43 04             	mov    0x4(%ebx),%eax
f0101361:	89 04 24             	mov    %eax,(%esp)
f0101364:	e8 bb 32 00 00       	call   f0104624 <strtol>
f0101369:	89 c6                	mov    %eax,%esi
	if (*errChar){
f010136b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010136e:	80 38 00             	cmpb   $0x0,(%eax)
f0101371:	74 11                	je     f0101384 <mon_setpermissions+0x58>
		cprintf("mon_setpermissions: The first argument is not a number.\n");
f0101373:	c7 04 24 f4 56 10 f0 	movl   $0xf01056f4,(%esp)
f010137a:	e8 d7 26 00 00       	call   f0103a56 <cprintf>
		return 0;
f010137f:	e9 2c 01 00 00       	jmp    f01014b0 <mon_setpermissions+0x184>
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f0101384:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010138b:	00 
f010138c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010138f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101393:	8b 43 08             	mov    0x8(%ebx),%eax
f0101396:	89 04 24             	mov    %eax,(%esp)
f0101399:	e8 86 32 00 00       	call   f0104624 <strtol>
	if (*errChar){
f010139e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01013a1:	80 3a 00             	cmpb   $0x0,(%edx)
f01013a4:	74 11                	je     f01013b7 <mon_setpermissions+0x8b>
		cprintf("mon_setpermissions: The second argument is not a number\n");
f01013a6:	c7 04 24 30 57 10 f0 	movl   $0xf0105730,(%esp)
f01013ad:	e8 a4 26 00 00       	call   f0103a56 <cprintf>
		return 0;
f01013b2:	e9 f9 00 00 00       	jmp    f01014b0 <mon_setpermissions+0x184>
	}
	if (StartAddr&0x3ff){
f01013b7:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f01013bd:	74 11                	je     f01013d0 <mon_setpermissions+0xa4>
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
f01013bf:	c7 04 24 6c 57 10 f0 	movl   $0xf010576c,(%esp)
f01013c6:	e8 8b 26 00 00       	call   f0103a56 <cprintf>
		return 0;
f01013cb:	e9 e0 00 00 00       	jmp    f01014b0 <mon_setpermissions+0x184>
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_setpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
f01013d0:	89 c7                	mov    %eax,%edi
	}
	if (StartAddr&0x3ff){
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
f01013d2:	a9 ff 03 00 00       	test   $0x3ff,%eax
f01013d7:	74 11                	je     f01013ea <mon_setpermissions+0xbe>
		cprintf("mon_setpermissions: The second parameter is not aligned.\n");
f01013d9:	c7 04 24 a8 57 10 f0 	movl   $0xf01057a8,(%esp)
f01013e0:	e8 71 26 00 00       	call   f0103a56 <cprintf>
		return 0;
f01013e5:	e9 c6 00 00 00       	jmp    f01014b0 <mon_setpermissions+0x184>
	}
	if (StartAddr > EndAddr){
f01013ea:	39 c6                	cmp    %eax,%esi
f01013ec:	76 11                	jbe    f01013ff <mon_setpermissions+0xd3>
		cprintf("mon_setpermissions: The first parameter is larger than the second parameter.\n");
f01013ee:	c7 04 24 e4 57 10 f0 	movl   $0xf01057e4,(%esp)
f01013f5:	e8 5c 26 00 00       	call   f0103a56 <cprintf>
		return 0;
f01013fa:	e9 b1 00 00 00       	jmp    f01014b0 <mon_setpermissions+0x184>
	}
	int Perm = Sign2Perm(argv[3]);
f01013ff:	8b 43 0c             	mov    0xc(%ebx),%eax
f0101402:	89 04 24             	mov    %eax,(%esp)
f0101405:	e8 13 fd ff ff       	call   f010111d <Sign2Perm>
	if (Perm == -1){
f010140a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010140d:	75 7a                	jne    f0101489 <mon_setpermissions+0x15d>
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
f010140f:	c7 04 24 34 58 10 f0 	movl   $0xf0105834,(%esp)
f0101416:	e8 3b 26 00 00       	call   f0103a56 <cprintf>
		return 0;
f010141b:	e9 90 00 00 00       	jmp    f01014b0 <mon_setpermissions+0x184>
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
f0101420:	89 f1                	mov    %esi,%ecx
f0101422:	c1 e9 16             	shr    $0x16,%ecx
		if (*pde & PTE_P){
f0101425:	8b 15 8c 29 12 f0    	mov    0xf012298c,%edx
f010142b:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
f010142e:	f6 c2 01             	test   $0x1,%dl
f0101431:	74 50                	je     f0101483 <mon_setpermissions+0x157>
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
f0101433:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101439:	89 d1                	mov    %edx,%ecx
f010143b:	c1 e9 0c             	shr    $0xc,%ecx
f010143e:	3b 0d 88 29 12 f0    	cmp    0xf0122988,%ecx
f0101444:	72 20                	jb     f0101466 <mon_setpermissions+0x13a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101446:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010144a:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0101451:	f0 
f0101452:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
f0101459:	00 
f010145a:	c7 04 24 f8 4c 10 f0 	movl   $0xf0104cf8,(%esp)
f0101461:	e8 2e ec ff ff       	call   f0100094 <_panic>
f0101466:	89 f1                	mov    %esi,%ecx
f0101468:	c1 e9 0a             	shr    $0xa,%ecx
f010146b:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
f0101471:	8d 94 0a 00 00 00 f0 	lea    -0x10000000(%edx,%ecx,1),%edx
			if (*pte & PTE_P){
f0101478:	8b 0a                	mov    (%edx),%ecx
f010147a:	f6 c1 01             	test   $0x1,%cl
f010147d:	74 04                	je     f0101483 <mon_setpermissions+0x157>
				*pte = *pte | Perm;
f010147f:	09 c1                	or     %eax,%ecx
f0101481:	89 0a                	mov    %ecx,(%edx)
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
f0101483:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101489:	39 fe                	cmp    %edi,%esi
f010148b:	72 93                	jb     f0101420 <mon_setpermissions+0xf4>
				*pte = *pte | Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
f010148d:	c7 04 24 7a 4d 10 f0 	movl   $0xf0104d7a,(%esp)
f0101494:	e8 bd 25 00 00       	call   f0103a56 <cprintf>
    mon_showmappings(argc-1,argv,tf);
f0101499:	8b 45 10             	mov    0x10(%ebp),%eax
f010149c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014a4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f01014ab:	e8 7b f9 ff ff       	call   f0100e2b <mon_showmappings>
    return 0;
}
f01014b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01014b5:	83 c4 2c             	add    $0x2c,%esp
f01014b8:	5b                   	pop    %ebx
f01014b9:	5e                   	pop    %esi
f01014ba:	5f                   	pop    %edi
f01014bb:	5d                   	pop    %ebp
f01014bc:	c3                   	ret    
f01014bd:	00 00                	add    %al,(%eax)
	...

f01014c0 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01014c0:	55                   	push   %ebp
f01014c1:	89 e5                	mov    %esp,%ebp
f01014c3:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01014c6:	89 d1                	mov    %edx,%ecx
f01014c8:	c1 e9 16             	shr    $0x16,%ecx
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
f01014cb:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01014ce:	a8 01                	test   $0x1,%al
f01014d0:	74 4d                	je     f010151f <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01014d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014d7:	89 c1                	mov    %eax,%ecx
f01014d9:	c1 e9 0c             	shr    $0xc,%ecx
f01014dc:	3b 0d 88 29 12 f0    	cmp    0xf0122988,%ecx
f01014e2:	72 20                	jb     f0101504 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014e8:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f01014ef:	f0 
f01014f0:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f01014f7:	00 
f01014f8:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01014ff:	e8 90 eb ff ff       	call   f0100094 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101504:	c1 ea 0c             	shr    $0xc,%edx
f0101507:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010150d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101514:	a8 01                	test   $0x1,%al
f0101516:	74 0e                	je     f0101526 <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101518:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010151d:	eb 0c                	jmp    f010152b <check_va2pa+0x6b>
	pgdir = &pgdir[PDX(va)];
	#ifdef DEBUG
	cprintf("(Debug): pgdir %x %x\n",pgdir,va);
	#endif
	if (!(*pgdir & PTE_P))
		return ~0;
f010151f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101524:	eb 05                	jmp    f010152b <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0101526:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f010152b:	c9                   	leave  
f010152c:	c3                   	ret    

f010152d <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010152d:	55                   	push   %ebp
f010152e:	89 e5                	mov    %esp,%ebp
f0101530:	83 ec 18             	sub    $0x18,%esp
f0101533:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101535:	83 3d 64 25 12 f0 00 	cmpl   $0x0,0xf0122564
f010153c:	75 0f                	jne    f010154d <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010153e:	b8 7f 39 12 f0       	mov    $0xf012397f,%eax
f0101543:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101548:	a3 64 25 12 f0       	mov    %eax,0xf0122564
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n>0){
f010154d:	85 d2                	test   %edx,%edx
f010154f:	74 6d                	je     f01015be <boot_alloc+0x91>
		result = nextfree;
f0101551:	a1 64 25 12 f0       	mov    0xf0122564,%eax
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0101556:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f010155d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101563:	89 15 64 25 12 f0    	mov    %edx,0xf0122564
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101569:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010156f:	77 20                	ja     f0101591 <boot_alloc+0x64>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101571:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101575:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f010157c:	f0 
f010157d:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0101584:	00 
f0101585:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010158c:	e8 03 eb ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101591:	81 c2 00 00 00 10    	add    $0x10000000,%edx
		if (PGNUM(PADDR(nextfree))>=npages)
f0101597:	c1 ea 0c             	shr    $0xc,%edx
f010159a:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f01015a0:	72 21                	jb     f01015c3 <boot_alloc+0x96>
			panic("boot_alloc: out of memory");
f01015a2:	c7 44 24 08 c4 62 10 	movl   $0xf01062c4,0x8(%esp)
f01015a9:	f0 
f01015aa:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f01015b1:	00 
f01015b2:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01015b9:	e8 d6 ea ff ff       	call   f0100094 <_panic>
	}
	else{
		result = nextfree;
f01015be:	a1 64 25 12 f0       	mov    0xf0122564,%eax
	}
	// cprintf("boot_alloc %x %d\n",result,n);
	return result;
	// return NULL;
}
f01015c3:	c9                   	leave  
f01015c4:	c3                   	ret    

f01015c5 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01015c5:	55                   	push   %ebp
f01015c6:	89 e5                	mov    %esp,%ebp
f01015c8:	56                   	push   %esi
f01015c9:	53                   	push   %ebx
f01015ca:	83 ec 10             	sub    $0x10,%esp
f01015cd:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01015cf:	89 04 24             	mov    %eax,(%esp)
f01015d2:	e8 11 24 00 00       	call   f01039e8 <mc146818_read>
f01015d7:	89 c6                	mov    %eax,%esi
f01015d9:	43                   	inc    %ebx
f01015da:	89 1c 24             	mov    %ebx,(%esp)
f01015dd:	e8 06 24 00 00       	call   f01039e8 <mc146818_read>
f01015e2:	c1 e0 08             	shl    $0x8,%eax
f01015e5:	09 f0                	or     %esi,%eax
}
f01015e7:	83 c4 10             	add    $0x10,%esp
f01015ea:	5b                   	pop    %ebx
f01015eb:	5e                   	pop    %esi
f01015ec:	5d                   	pop    %ebp
f01015ed:	c3                   	ret    

f01015ee <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01015ee:	55                   	push   %ebp
f01015ef:	89 e5                	mov    %esp,%ebp
f01015f1:	57                   	push   %edi
f01015f2:	56                   	push   %esi
f01015f3:	53                   	push   %ebx
f01015f4:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01015f7:	3c 01                	cmp    $0x1,%al
f01015f9:	19 f6                	sbb    %esi,%esi
f01015fb:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101601:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101602:	8b 15 68 25 12 f0    	mov    0xf0122568,%edx
f0101608:	85 d2                	test   %edx,%edx
f010160a:	75 1c                	jne    f0101628 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f010160c:	c7 44 24 08 d0 5a 10 	movl   $0xf0105ad0,0x8(%esp)
f0101613:	f0 
f0101614:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
f010161b:	00 
f010161c:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101623:	e8 6c ea ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
f0101628:	84 c0                	test   %al,%al
f010162a:	74 4b                	je     f0101677 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010162c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010162f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101632:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101635:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101638:	89 d0                	mov    %edx,%eax
f010163a:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f0101640:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101643:	c1 e8 16             	shr    $0x16,%eax
f0101646:	39 c6                	cmp    %eax,%esi
f0101648:	0f 96 c0             	setbe  %al
f010164b:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010164e:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0101652:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101654:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101658:	8b 12                	mov    (%edx),%edx
f010165a:	85 d2                	test   %edx,%edx
f010165c:	75 da                	jne    f0101638 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010165e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101661:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101667:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010166a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010166d:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010166f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101672:	a3 68 25 12 f0       	mov    %eax,0xf0122568
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101677:	8b 1d 68 25 12 f0    	mov    0xf0122568,%ebx
f010167d:	eb 63                	jmp    f01016e2 <check_page_free_list+0xf4>
f010167f:	89 d8                	mov    %ebx,%eax
f0101681:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f0101687:	c1 f8 03             	sar    $0x3,%eax
f010168a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010168d:	89 c2                	mov    %eax,%edx
f010168f:	c1 ea 16             	shr    $0x16,%edx
f0101692:	39 d6                	cmp    %edx,%esi
f0101694:	76 4a                	jbe    f01016e0 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101696:	89 c2                	mov    %eax,%edx
f0101698:	c1 ea 0c             	shr    $0xc,%edx
f010169b:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f01016a1:	72 20                	jb     f01016c3 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016a7:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f01016ae:	f0 
f01016af:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01016b6:	00 
f01016b7:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f01016be:	e8 d1 e9 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01016c3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01016ca:	00 
f01016cb:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01016d2:	00 
	return (void *)(pa + KERNBASE);
f01016d3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016d8:	89 04 24             	mov    %eax,(%esp)
f01016db:	e8 1a 2e 00 00       	call   f01044fa <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01016e0:	8b 1b                	mov    (%ebx),%ebx
f01016e2:	85 db                	test   %ebx,%ebx
f01016e4:	75 99                	jne    f010167f <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f01016e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01016eb:	e8 3d fe ff ff       	call   f010152d <boot_alloc>
f01016f0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01016f3:	8b 15 68 25 12 f0    	mov    0xf0122568,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01016f9:	8b 0d 90 29 12 f0    	mov    0xf0122990,%ecx
		assert(pp < pages + npages);
f01016ff:	a1 88 29 12 f0       	mov    0xf0122988,%eax
f0101704:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101707:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010170a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010170d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101710:	be 00 00 00 00       	mov    $0x0,%esi
f0101715:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101718:	e9 91 01 00 00       	jmp    f01018ae <check_page_free_list+0x2c0>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010171d:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0101720:	73 24                	jae    f0101746 <check_page_free_list+0x158>
f0101722:	c7 44 24 0c ec 62 10 	movl   $0xf01062ec,0xc(%esp)
f0101729:	f0 
f010172a:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101731:	f0 
f0101732:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
f0101739:	00 
f010173a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101741:	e8 4e e9 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0101746:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101749:	72 24                	jb     f010176f <check_page_free_list+0x181>
f010174b:	c7 44 24 0c 0d 63 10 	movl   $0xf010630d,0xc(%esp)
f0101752:	f0 
f0101753:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010175a:	f0 
f010175b:	c7 44 24 04 59 02 00 	movl   $0x259,0x4(%esp)
f0101762:	00 
f0101763:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010176a:	e8 25 e9 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010176f:	89 d0                	mov    %edx,%eax
f0101771:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101774:	a8 07                	test   $0x7,%al
f0101776:	74 24                	je     f010179c <check_page_free_list+0x1ae>
f0101778:	c7 44 24 0c f4 5a 10 	movl   $0xf0105af4,0xc(%esp)
f010177f:	f0 
f0101780:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101787:	f0 
f0101788:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
f010178f:	00 
f0101790:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101797:	e8 f8 e8 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010179c:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010179f:	c1 e0 0c             	shl    $0xc,%eax
f01017a2:	75 24                	jne    f01017c8 <check_page_free_list+0x1da>
f01017a4:	c7 44 24 0c 21 63 10 	movl   $0xf0106321,0xc(%esp)
f01017ab:	f0 
f01017ac:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01017b3:	f0 
f01017b4:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
f01017bb:	00 
f01017bc:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01017c3:	e8 cc e8 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01017c8:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01017cd:	75 24                	jne    f01017f3 <check_page_free_list+0x205>
f01017cf:	c7 44 24 0c 32 63 10 	movl   $0xf0106332,0xc(%esp)
f01017d6:	f0 
f01017d7:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01017de:	f0 
f01017df:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
f01017e6:	00 
f01017e7:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01017ee:	e8 a1 e8 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01017f3:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01017f8:	75 24                	jne    f010181e <check_page_free_list+0x230>
f01017fa:	c7 44 24 0c 28 5b 10 	movl   $0xf0105b28,0xc(%esp)
f0101801:	f0 
f0101802:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101809:	f0 
f010180a:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
f0101811:	00 
f0101812:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101819:	e8 76 e8 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010181e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101823:	75 24                	jne    f0101849 <check_page_free_list+0x25b>
f0101825:	c7 44 24 0c 4b 63 10 	movl   $0xf010634b,0xc(%esp)
f010182c:	f0 
f010182d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101834:	f0 
f0101835:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
f010183c:	00 
f010183d:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101844:	e8 4b e8 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101849:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010184e:	76 58                	jbe    f01018a8 <check_page_free_list+0x2ba>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101850:	89 c1                	mov    %eax,%ecx
f0101852:	c1 e9 0c             	shr    $0xc,%ecx
f0101855:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101858:	77 20                	ja     f010187a <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010185a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010185e:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0101865:	f0 
f0101866:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010186d:	00 
f010186e:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f0101875:	e8 1a e8 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f010187a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010187f:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101882:	76 27                	jbe    f01018ab <check_page_free_list+0x2bd>
f0101884:	c7 44 24 0c 4c 5b 10 	movl   $0xf0105b4c,0xc(%esp)
f010188b:	f0 
f010188c:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101893:	f0 
f0101894:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f010189b:	00 
f010189c:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01018a3:	e8 ec e7 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01018a8:	46                   	inc    %esi
f01018a9:	eb 01                	jmp    f01018ac <check_page_free_list+0x2be>
		else
			++nfree_extmem;
f01018ab:	43                   	inc    %ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01018ac:	8b 12                	mov    (%edx),%edx
f01018ae:	85 d2                	test   %edx,%edx
f01018b0:	0f 85 67 fe ff ff    	jne    f010171d <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01018b6:	85 f6                	test   %esi,%esi
f01018b8:	7f 24                	jg     f01018de <check_page_free_list+0x2f0>
f01018ba:	c7 44 24 0c 65 63 10 	movl   $0xf0106365,0xc(%esp)
f01018c1:	f0 
f01018c2:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01018c9:	f0 
f01018ca:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
f01018d1:	00 
f01018d2:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01018d9:	e8 b6 e7 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f01018de:	85 db                	test   %ebx,%ebx
f01018e0:	7f 24                	jg     f0101906 <check_page_free_list+0x318>
f01018e2:	c7 44 24 0c 77 63 10 	movl   $0xf0106377,0xc(%esp)
f01018e9:	f0 
f01018ea:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01018f1:	f0 
f01018f2:	c7 44 24 04 6a 02 00 	movl   $0x26a,0x4(%esp)
f01018f9:	00 
f01018fa:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101901:	e8 8e e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101906:	c7 04 24 94 5b 10 f0 	movl   $0xf0105b94,(%esp)
f010190d:	e8 44 21 00 00       	call   f0103a56 <cprintf>
}
f0101912:	83 c4 4c             	add    $0x4c,%esp
f0101915:	5b                   	pop    %ebx
f0101916:	5e                   	pop    %esi
f0101917:	5f                   	pop    %edi
f0101918:	5d                   	pop    %ebp
f0101919:	c3                   	ret    

f010191a <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010191a:	55                   	push   %ebp
f010191b:	89 e5                	mov    %esp,%ebp
f010191d:	53                   	push   %ebx
f010191e:	83 ec 14             	sub    $0x14,%esp
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	size_t i;
	pages[0].pp_ref = 1;
f0101921:	a1 90 29 12 f0       	mov    0xf0122990,%eax
f0101926:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f010192c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	size_t IOPAGE =  PGNUM(IOPHYSMEM);
	size_t EXTPAGE = PGNUM(EXTPHYSMEM);
	size_t FREEPAGE = PGNUM(PADDR(boot_alloc(0)));
f0101932:	b8 00 00 00 00       	mov    $0x0,%eax
f0101937:	e8 f1 fb ff ff       	call   f010152d <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010193c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101941:	77 20                	ja     f0101963 <page_init+0x49>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101943:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101947:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f010194e:	f0 
f010194f:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
f0101956:	00 
f0101957:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010195e:	e8 31 e7 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101963:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0101969:	c1 eb 0c             	shr    $0xc,%ebx
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
f010196c:	83 3d 68 25 12 f0 00 	cmpl   $0x0,0xf0122568
f0101973:	74 24                	je     f0101999 <page_init+0x7f>
f0101975:	c7 44 24 0c 88 63 10 	movl   $0xf0106388,0xc(%esp)
f010197c:	f0 
f010197d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101984:	f0 
f0101985:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f010198c:	00 
f010198d:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101994:	e8 fb e6 ff ff       	call   f0100094 <_panic>
 	assert(npages_basemem == IOPAGE);
f0101999:	81 3d 60 25 12 f0 a0 	cmpl   $0xa0,0xf0122560
f01019a0:	00 00 00 
f01019a3:	74 24                	je     f01019c9 <page_init+0xaf>
f01019a5:	c7 44 24 0c 9f 63 10 	movl   $0xf010639f,0xc(%esp)
f01019ac:	f0 
f01019ad:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f01019bc:	00 
f01019bd:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01019c4:	e8 cb e6 ff ff       	call   f0100094 <_panic>
f01019c9:	b8 08 00 00 00       	mov    $0x8,%eax
f01019ce:	b9 00 00 00 00       	mov    $0x0,%ecx
    for (i = 1; i < IOPAGE; i++) {
        pages[i].pp_ref = 0;
f01019d3:	89 c2                	mov    %eax,%edx
f01019d5:	03 15 90 29 12 f0    	add    0xf0122990,%edx
f01019db:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f01019e1:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f01019e3:	89 c1                	mov    %eax,%ecx
f01019e5:	03 0d 90 29 12 f0    	add    0xf0122990,%ecx
f01019eb:	83 c0 08             	add    $0x8,%eax
	// cprintf("%x %x %x\n",IOPAGE,EXTPAGE,FREEPAGE);
	// cprintf("pages %x\n",pages);
	// cprintf("%x %x %x %x\n",KADDR(IOPAGE<<12),KADDR(EXTPAGE<<12),KADDR(FREEPAGE<<12),KADDR((npages-1)<<12));
	assert(page_free_list == NULL);
 	assert(npages_basemem == IOPAGE);
    for (i = 1; i < IOPAGE; i++) {
f01019ee:	3d 00 05 00 00       	cmp    $0x500,%eax
f01019f3:	75 de                	jne    f01019d3 <page_init+0xb9>
f01019f5:	89 0d 68 25 12 f0    	mov    %ecx,0xf0122568
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
f01019fb:	89 c2                	mov    %eax,%edx
f01019fd:	03 15 90 29 12 f0    	add    0xf0122990,%edx
f0101a03:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f0101a09:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0101a0f:	83 c0 08             	add    $0x8,%eax
    for (i = 1; i < IOPAGE; i++) {
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
f0101a12:	3d 00 08 00 00       	cmp    $0x800,%eax
f0101a17:	75 e2                	jne    f01019fb <page_init+0xe1>
f0101a19:	66 b8 00 01          	mov    $0x100,%ax
f0101a1d:	eb 1a                	jmp    f0101a39 <page_init+0x11f>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
f0101a1f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101a26:	03 15 90 29 12 f0    	add    0xf0122990,%edx
f0101a2c:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f0101a32:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    }
	for (i = IOPAGE; i < EXTPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
f0101a38:	40                   	inc    %eax
f0101a39:	39 d8                	cmp    %ebx,%eax
f0101a3b:	72 e2                	jb     f0101a1f <page_init+0x105>
f0101a3d:	8b 0d 68 25 12 f0    	mov    0xf0122568,%ecx
f0101a43:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0101a4a:	eb 1c                	jmp    f0101a68 <page_init+0x14e>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
        pages[i].pp_ref = 0;
f0101a4c:	89 c2                	mov    %eax,%edx
f0101a4e:	03 15 90 29 12 f0    	add    0xf0122990,%edx
f0101a54:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0101a5a:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f0101a5c:	89 c1                	mov    %eax,%ecx
f0101a5e:	03 0d 90 29 12 f0    	add    0xf0122990,%ecx
	}
	for (i = EXTPAGE; i < FREEPAGE; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
    for (i = FREEPAGE; i < npages; i++) {
f0101a64:	43                   	inc    %ebx
f0101a65:	83 c0 08             	add    $0x8,%eax
f0101a68:	3b 1d 88 29 12 f0    	cmp    0xf0122988,%ebx
f0101a6e:	72 dc                	jb     f0101a4c <page_init+0x132>
f0101a70:	89 0d 68 25 12 f0    	mov    %ecx,0xf0122568
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
	return;
}
f0101a76:	83 c4 14             	add    $0x14,%esp
f0101a79:	5b                   	pop    %ebx
f0101a7a:	5d                   	pop    %ebp
f0101a7b:	c3                   	ret    

f0101a7c <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101a7c:	55                   	push   %ebp
f0101a7d:	89 e5                	mov    %esp,%ebp
f0101a7f:	53                   	push   %ebx
f0101a80:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	// assert(page_free_list != NULL);
	// cprintf("page_alloc %x\n",page_free_list);
	// cprintf("page_alloc %x\n",page_free_list);
	if (page_free_list == NULL)return NULL;
f0101a83:	8b 1d 68 25 12 f0    	mov    0xf0122568,%ebx
f0101a89:	85 db                	test   %ebx,%ebx
f0101a8b:	74 6b                	je     f0101af8 <page_alloc+0x7c>
	struct PageInfo *alloc_page = page_free_list;
	page_free_list = alloc_page->pp_link;
f0101a8d:	8b 03                	mov    (%ebx),%eax
f0101a8f:	a3 68 25 12 f0       	mov    %eax,0xf0122568
	alloc_page->pp_link = NULL;
f0101a94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO){
f0101a9a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101a9e:	74 58                	je     f0101af8 <page_alloc+0x7c>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aa0:	89 d8                	mov    %ebx,%eax
f0101aa2:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f0101aa8:	c1 f8 03             	sar    $0x3,%eax
f0101aab:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101aae:	89 c2                	mov    %eax,%edx
f0101ab0:	c1 ea 0c             	shr    $0xc,%edx
f0101ab3:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f0101ab9:	72 20                	jb     f0101adb <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101abb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101abf:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0101ac6:	f0 
f0101ac7:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101ace:	00 
f0101acf:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f0101ad6:	e8 b9 e5 ff ff       	call   f0100094 <_panic>
		memset(page2kva(alloc_page),'\0',PGSIZE);
f0101adb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ae2:	00 
f0101ae3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101aea:	00 
	return (void *)(pa + KERNBASE);
f0101aeb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101af0:	89 04 24             	mov    %eax,(%esp)
f0101af3:	e8 02 2a 00 00       	call   f01044fa <memset>
	}
	return alloc_page;
}
f0101af8:	89 d8                	mov    %ebx,%eax
f0101afa:	83 c4 14             	add    $0x14,%esp
f0101afd:	5b                   	pop    %ebx
f0101afe:	5d                   	pop    %ebp
f0101aff:	c3                   	ret    

f0101b00 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101b00:	55                   	push   %ebp
f0101b01:	89 e5                	mov    %esp,%ebp
f0101b03:	83 ec 18             	sub    $0x18,%esp
f0101b06:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link !=NULL)
f0101b09:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101b0e:	75 05                	jne    f0101b15 <page_free+0x15>
f0101b10:	83 38 00             	cmpl   $0x0,(%eax)
f0101b13:	74 1c                	je     f0101b31 <page_free+0x31>
		panic("Something went wrong at page_free");
f0101b15:	c7 44 24 08 b8 5b 10 	movl   $0xf0105bb8,0x8(%esp)
f0101b1c:	f0 
f0101b1d:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0101b24:	00 
f0101b25:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101b2c:	e8 63 e5 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0101b31:	8b 15 68 25 12 f0    	mov    0xf0122568,%edx
f0101b37:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101b39:	a3 68 25 12 f0       	mov    %eax,0xf0122568
	return;
}
f0101b3e:	c9                   	leave  
f0101b3f:	c3                   	ret    

f0101b40 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101b40:	55                   	push   %ebp
f0101b41:	89 e5                	mov    %esp,%ebp
f0101b43:	83 ec 18             	sub    $0x18,%esp
f0101b46:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101b49:	8b 50 04             	mov    0x4(%eax),%edx
f0101b4c:	4a                   	dec    %edx
f0101b4d:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101b51:	66 85 d2             	test   %dx,%dx
f0101b54:	75 08                	jne    f0101b5e <page_decref+0x1e>
		page_free(pp);
f0101b56:	89 04 24             	mov    %eax,(%esp)
f0101b59:	e8 a2 ff ff ff       	call   f0101b00 <page_free>
}
f0101b5e:	c9                   	leave  
f0101b5f:	c3                   	ret    

f0101b60 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101b60:	55                   	push   %ebp
f0101b61:	89 e5                	mov    %esp,%ebp
f0101b63:	56                   	push   %esi
f0101b64:	53                   	push   %ebx
f0101b65:	83 ec 10             	sub    $0x10,%esp
f0101b68:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b6b:	8b 45 10             	mov    0x10(%ebp),%eax
	// Fill this function in
	if (!((create == 0) || (create == 1)))
f0101b6e:	83 f8 01             	cmp    $0x1,%eax
f0101b71:	76 1c                	jbe    f0101b8f <pgdir_walk+0x2f>
		panic("pgdir_walk: create is wrong!!!");
f0101b73:	c7 44 24 08 dc 5b 10 	movl   $0xf0105bdc,0x8(%esp)
f0101b7a:	f0 
f0101b7b:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
f0101b82:	00 
f0101b83:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101b8a:	e8 05 e5 ff ff       	call   f0100094 <_panic>
	
	pde_t *pde = &pgdir[PDX(va)];
f0101b8f:	89 f1                	mov    %esi,%ecx
f0101b91:	c1 e9 16             	shr    $0x16,%ecx
f0101b94:	8b 55 08             	mov    0x8(%ebp),%edx
f0101b97:	8d 1c 8a             	lea    (%edx,%ecx,4),%ebx
	if ((*pde & PTE_P) == 0){
f0101b9a:	f6 03 01             	testb  $0x1,(%ebx)
f0101b9d:	75 29                	jne    f0101bc8 <pgdir_walk+0x68>
		if (create == false){
f0101b9f:	85 c0                	test   %eax,%eax
f0101ba1:	74 6b                	je     f0101c0e <pgdir_walk+0xae>
			return NULL;
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0101ba3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101baa:	e8 cd fe ff ff       	call   f0101a7c <page_alloc>
			if (page==NULL) return NULL;
f0101baf:	85 c0                	test   %eax,%eax
f0101bb1:	74 62                	je     f0101c15 <pgdir_walk+0xb5>
			page->pp_ref++;
f0101bb3:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bb7:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f0101bbd:	c1 f8 03             	sar    $0x3,%eax
f0101bc0:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0101bc3:	83 c8 07             	or     $0x7,%eax
f0101bc6:	89 03                	mov    %eax,(%ebx)
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
f0101bc8:	8b 03                	mov    (%ebx),%eax
f0101bca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bcf:	89 c2                	mov    %eax,%edx
f0101bd1:	c1 ea 0c             	shr    $0xc,%edx
f0101bd4:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f0101bda:	72 20                	jb     f0101bfc <pgdir_walk+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101be0:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0101be7:	f0 
f0101be8:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
f0101bef:	00 
f0101bf0:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101bf7:	e8 98 e4 ff ff       	call   f0100094 <_panic>
	return &pgtable[PTX(va)];
f0101bfc:	c1 ee 0a             	shr    $0xa,%esi
f0101bff:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101c05:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101c0c:	eb 0c                	jmp    f0101c1a <pgdir_walk+0xba>
		panic("pgdir_walk: create is wrong!!!");
	
	pde_t *pde = &pgdir[PDX(va)];
	if ((*pde & PTE_P) == 0){
		if (create == false){
			return NULL;
f0101c0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c13:	eb 05                	jmp    f0101c1a <pgdir_walk+0xba>
		}
		else{
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
			if (page==NULL) return NULL;
f0101c15:	b8 00 00 00 00       	mov    $0x0,%eax
			// *pde = page2pa(page) | PTE_SYSCALL;
		}
	}
	pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	return &pgtable[PTX(va)];
}
f0101c1a:	83 c4 10             	add    $0x10,%esp
f0101c1d:	5b                   	pop    %ebx
f0101c1e:	5e                   	pop    %esi
f0101c1f:	5d                   	pop    %ebp
f0101c20:	c3                   	ret    

f0101c21 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101c21:	55                   	push   %ebp
f0101c22:	89 e5                	mov    %esp,%ebp
f0101c24:	57                   	push   %edi
f0101c25:	56                   	push   %esi
f0101c26:	53                   	push   %ebx
f0101c27:	83 ec 2c             	sub    $0x2c,%esp
f0101c2a:	89 c6                	mov    %eax,%esi
f0101c2c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101c2f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// assert(size % PGSIZE == 0);
	if (size % PGSIZE != 0){
f0101c32:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f0101c38:	74 1c                	je     f0101c56 <boot_map_region+0x35>
		panic("boot_map_region: size % PGSIZE != 0");
f0101c3a:	c7 44 24 08 fc 5b 10 	movl   $0xf0105bfc,0x8(%esp)
f0101c41:	f0 
f0101c42:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0101c49:	00 
f0101c4a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101c51:	e8 3e e4 ff ff       	call   f0100094 <_panic>
	}
	if (PTE_ADDR(va) != va)
f0101c56:	89 d1                	mov    %edx,%ecx
f0101c58:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101c5e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101c61:	39 d1                	cmp    %edx,%ecx
f0101c63:	74 1c                	je     f0101c81 <boot_map_region+0x60>
		panic("boot_map_region: va is not page_aligned");
f0101c65:	c7 44 24 08 20 5c 10 	movl   $0xf0105c20,0x8(%esp)
f0101c6c:	f0 
f0101c6d:	c7 44 24 04 bc 01 00 	movl   $0x1bc,0x4(%esp)
f0101c74:	00 
f0101c75:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101c7c:	e8 13 e4 ff ff       	call   f0100094 <_panic>
	if (PTE_ADDR(pa) != pa)
f0101c81:	89 c7                	mov    %eax,%edi
f0101c83:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101c89:	39 c7                	cmp    %eax,%edi
f0101c8b:	74 4b                	je     f0101cd8 <boot_map_region+0xb7>
		panic("boot_map_region: pa is not page_aligned");
f0101c8d:	c7 44 24 08 48 5c 10 	movl   $0xf0105c48,0x8(%esp)
f0101c94:	f0 
f0101c95:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f0101c9c:	00 
f0101c9d:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101ca4:	e8 eb e3 ff ff       	call   f0100094 <_panic>
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f0101ca9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101cb0:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101cb4:	01 d8                	add    %ebx,%eax
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
f0101cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101cba:	89 34 24             	mov    %esi,(%esp)
f0101cbd:	e8 9e fe ff ff       	call   f0101b60 <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101cc2:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f0101cc5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ccb:	0b 55 dc             	or     -0x24(%ebp),%edx
f0101cce:	89 10                	mov    %edx,(%eax)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f0101cd0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101cd6:	eb 0e                	jmp    f0101ce6 <boot_map_region+0xc5>
	if (size % PGSIZE != 0){
		panic("boot_map_region: size % PGSIZE != 0");
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
f0101cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
f0101cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ce0:	83 c8 01             	or     $0x1,%eax
f0101ce3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	if (PTE_ADDR(va) != va)
		panic("boot_map_region: va is not page_aligned");
	if (PTE_ADDR(pa) != pa)
		panic("boot_map_region: pa is not page_aligned");
	for (size_t i = 0;i < size; i +=PGSIZE){
f0101ce6:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101ce9:	72 be                	jb     f0101ca9 <boot_map_region+0x88>
		pte_t *pte = pgdir_walk(pgdir,(void *)va+i,1);
		*pte = PTE_ADDR(pa+i) | perm | PTE_P;
	}
}
f0101ceb:	83 c4 2c             	add    $0x2c,%esp
f0101cee:	5b                   	pop    %ebx
f0101cef:	5e                   	pop    %esi
f0101cf0:	5f                   	pop    %edi
f0101cf1:	5d                   	pop    %ebp
f0101cf2:	c3                   	ret    

f0101cf3 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101cf3:	55                   	push   %ebp
f0101cf4:	89 e5                	mov    %esp,%ebp
f0101cf6:	53                   	push   %ebx
f0101cf7:	83 ec 14             	sub    $0x14,%esp
f0101cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
f0101cfd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d04:	00 
f0101d05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d0f:	89 04 24             	mov    %eax,(%esp)
f0101d12:	e8 49 fe ff ff       	call   f0101b60 <pgdir_walk>
	if (pte == NULL) return NULL;
f0101d17:	85 c0                	test   %eax,%eax
f0101d19:	74 3a                	je     f0101d55 <page_lookup+0x62>
	if (pte_store != NULL)
f0101d1b:	85 db                	test   %ebx,%ebx
f0101d1d:	74 02                	je     f0101d21 <page_lookup+0x2e>
		*pte_store = pte;
f0101d1f:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));
f0101d21:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d23:	c1 e8 0c             	shr    $0xc,%eax
f0101d26:	3b 05 88 29 12 f0    	cmp    0xf0122988,%eax
f0101d2c:	72 1c                	jb     f0101d4a <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101d2e:	c7 44 24 08 70 5c 10 	movl   $0xf0105c70,0x8(%esp)
f0101d35:	f0 
f0101d36:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101d3d:	00 
f0101d3e:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f0101d45:	e8 4a e3 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101d4a:	c1 e0 03             	shl    $0x3,%eax
f0101d4d:	03 05 90 29 12 f0    	add    0xf0122990,%eax
f0101d53:	eb 05                	jmp    f0101d5a <page_lookup+0x67>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir,va,0);
	if (pte == NULL) return NULL;
f0101d55:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store != NULL)
		*pte_store = pte;
	return pa2page(PTE_ADDR(*pte));
}
f0101d5a:	83 c4 14             	add    $0x14,%esp
f0101d5d:	5b                   	pop    %ebx
f0101d5e:	5d                   	pop    %ebp
f0101d5f:	c3                   	ret    

f0101d60 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101d60:	55                   	push   %ebp
f0101d61:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101d63:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d66:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101d69:	5d                   	pop    %ebp
f0101d6a:	c3                   	ret    

f0101d6b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101d6b:	55                   	push   %ebp
f0101d6c:	89 e5                	mov    %esp,%ebp
f0101d6e:	56                   	push   %esi
f0101d6f:	53                   	push   %ebx
f0101d70:	83 ec 20             	sub    $0x20,%esp
f0101d73:	8b 75 08             	mov    0x8(%ebp),%esi
f0101d76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f0101d79:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101d7c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101d80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d84:	89 34 24             	mov    %esi,(%esp)
f0101d87:	e8 67 ff ff ff       	call   f0101cf3 <page_lookup>
	if(page != NULL){
f0101d8c:	85 c0                	test   %eax,%eax
f0101d8e:	74 1d                	je     f0101dad <page_remove+0x42>
		*pte = 0;
f0101d90:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101d93:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(page);
f0101d99:	89 04 24             	mov    %eax,(%esp)
f0101d9c:	e8 9f fd ff ff       	call   f0101b40 <page_decref>
		tlb_invalidate(pgdir, va);
f0101da1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101da5:	89 34 24             	mov    %esi,(%esp)
f0101da8:	e8 b3 ff ff ff       	call   f0101d60 <tlb_invalidate>
	}
	return;
}
f0101dad:	83 c4 20             	add    $0x20,%esp
f0101db0:	5b                   	pop    %ebx
f0101db1:	5e                   	pop    %esi
f0101db2:	5d                   	pop    %ebp
f0101db3:	c3                   	ret    

f0101db4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101db4:	55                   	push   %ebp
f0101db5:	89 e5                	mov    %esp,%ebp
f0101db7:	57                   	push   %edi
f0101db8:	56                   	push   %esi
f0101db9:	53                   	push   %ebx
f0101dba:	83 ec 1c             	sub    $0x1c,%esp
f0101dbd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101dc0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
f0101dc3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101dca:	00 
f0101dcb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dd2:	89 04 24             	mov    %eax,(%esp)
f0101dd5:	e8 86 fd ff ff       	call   f0101b60 <pgdir_walk>
f0101dda:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101ddc:	85 c0                	test   %eax,%eax
f0101dde:	74 48                	je     f0101e28 <page_insert+0x74>
    pp->pp_ref++;
f0101de0:	66 ff 46 04          	incw   0x4(%esi)
    if ((*pte & PTE_P) != 0) {
f0101de4:	f6 00 01             	testb  $0x1,(%eax)
f0101de7:	74 1e                	je     f0101e07 <page_insert+0x53>
        page_remove(pgdir,va);
f0101de9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ded:	8b 45 08             	mov    0x8(%ebp),%eax
f0101df0:	89 04 24             	mov    %eax,(%esp)
f0101df3:	e8 73 ff ff ff       	call   f0101d6b <page_remove>
        tlb_invalidate(pgdir,va);
f0101df8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dff:	89 04 24             	mov    %eax,(%esp)
f0101e02:	e8 59 ff ff ff       	call   f0101d60 <tlb_invalidate>
    }
    *pte = page2pa(pp) | perm | PTE_P;
f0101e07:	8b 55 14             	mov    0x14(%ebp),%edx
f0101e0a:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e0d:	2b 35 90 29 12 f0    	sub    0xf0122990,%esi
f0101e13:	c1 fe 03             	sar    $0x3,%esi
f0101e16:	89 f0                	mov    %esi,%eax
f0101e18:	c1 e0 0c             	shl    $0xc,%eax
f0101e1b:	89 d6                	mov    %edx,%esi
f0101e1d:	09 c6                	or     %eax,%esi
f0101e1f:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101e21:	b8 00 00 00 00       	mov    $0x0,%eax
f0101e26:	eb 05                	jmp    f0101e2d <page_insert+0x79>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,1);
    if (pte == NULL) return -E_NO_MEM;
f0101e28:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir,va);
        tlb_invalidate(pgdir,va);
    }
    *pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101e2d:	83 c4 1c             	add    $0x1c,%esp
f0101e30:	5b                   	pop    %ebx
f0101e31:	5e                   	pop    %esi
f0101e32:	5f                   	pop    %edi
f0101e33:	5d                   	pop    %ebp
f0101e34:	c3                   	ret    

f0101e35 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101e35:	55                   	push   %ebp
f0101e36:	89 e5                	mov    %esp,%ebp
f0101e38:	57                   	push   %edi
f0101e39:	56                   	push   %esi
f0101e3a:	53                   	push   %ebx
f0101e3b:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101e3e:	b8 15 00 00 00       	mov    $0x15,%eax
f0101e43:	e8 7d f7 ff ff       	call   f01015c5 <nvram_read>
f0101e48:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101e4a:	b8 17 00 00 00       	mov    $0x17,%eax
f0101e4f:	e8 71 f7 ff ff       	call   f01015c5 <nvram_read>
f0101e54:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101e56:	b8 34 00 00 00       	mov    $0x34,%eax
f0101e5b:	e8 65 f7 ff ff       	call   f01015c5 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101e60:	c1 e0 06             	shl    $0x6,%eax
f0101e63:	74 08                	je     f0101e6d <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f0101e65:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f0101e6b:	eb 0e                	jmp    f0101e7b <mem_init+0x46>
	else if (extmem)
f0101e6d:	85 f6                	test   %esi,%esi
f0101e6f:	74 08                	je     f0101e79 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0101e71:	81 c6 00 04 00 00    	add    $0x400,%esi
f0101e77:	eb 02                	jmp    f0101e7b <mem_init+0x46>
	else
		totalmem = basemem;
f0101e79:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f0101e7b:	89 f0                	mov    %esi,%eax
f0101e7d:	c1 e8 02             	shr    $0x2,%eax
f0101e80:	a3 88 29 12 f0       	mov    %eax,0xf0122988
	npages_basemem = basemem / (PGSIZE / 1024);
f0101e85:	89 d8                	mov    %ebx,%eax
f0101e87:	c1 e8 02             	shr    $0x2,%eax
f0101e8a:	a3 60 25 12 f0       	mov    %eax,0xf0122560
	// cprintf("%u\n",ext16mem);
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101e8f:	89 f0                	mov    %esi,%eax
f0101e91:	29 d8                	sub    %ebx,%eax
f0101e93:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e97:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101e9b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e9f:	c7 04 24 90 5c 10 f0 	movl   $0xf0105c90,(%esp)
f0101ea6:	e8 ab 1b 00 00       	call   f0103a56 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101eab:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101eb0:	e8 78 f6 ff ff       	call   f010152d <boot_alloc>
f0101eb5:	a3 8c 29 12 f0       	mov    %eax,0xf012298c
	memset(kern_pgdir, 0, PGSIZE);
f0101eba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ec1:	00 
f0101ec2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ec9:	00 
f0101eca:	89 04 24             	mov    %eax,(%esp)
f0101ecd:	e8 28 26 00 00       	call   f01044fa <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101ed2:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101ed7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101edc:	77 20                	ja     f0101efe <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101ede:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ee2:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f0101ee9:	f0 
f0101eea:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
f0101ef1:	00 
f0101ef2:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101ef9:	e8 96 e1 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101efe:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101f04:	83 ca 05             	or     $0x5,%edx
f0101f07:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);
f0101f0d:	a1 88 29 12 f0       	mov    0xf0122988,%eax
f0101f12:	c1 e0 03             	shl    $0x3,%eax
f0101f15:	e8 13 f6 ff ff       	call   f010152d <boot_alloc>
f0101f1a:	a3 90 29 12 f0       	mov    %eax,0xf0122990
	// cprintf("npages: %x\n",npages);
	// cprintf("pages: %x\n",pages);
	memset(pages,0,sizeof(struct PageInfo) * npages);
f0101f1f:	8b 15 88 29 12 f0    	mov    0xf0122988,%edx
f0101f25:	c1 e2 03             	shl    $0x3,%edx
f0101f28:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101f2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101f33:	00 
f0101f34:	89 04 24             	mov    %eax,(%esp)
f0101f37:	e8 be 25 00 00       	call   f01044fa <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101f3c:	e8 d9 f9 ff ff       	call   f010191a <page_init>

	check_page_free_list(1);
f0101f41:	b8 01 00 00 00       	mov    $0x1,%eax
f0101f46:	e8 a3 f6 ff ff       	call   f01015ee <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101f4b:	83 3d 90 29 12 f0 00 	cmpl   $0x0,0xf0122990
f0101f52:	75 1c                	jne    f0101f70 <mem_init+0x13b>
		panic("'pages' is a null pointer!");
f0101f54:	c7 44 24 08 b8 63 10 	movl   $0xf01063b8,0x8(%esp)
f0101f5b:	f0 
f0101f5c:	c7 44 24 04 7d 02 00 	movl   $0x27d,0x4(%esp)
f0101f63:	00 
f0101f64:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101f6b:	e8 24 e1 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101f70:	a1 68 25 12 f0       	mov    0xf0122568,%eax
f0101f75:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101f7a:	eb 03                	jmp    f0101f7f <mem_init+0x14a>
		++nfree;
f0101f7c:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101f7d:	8b 00                	mov    (%eax),%eax
f0101f7f:	85 c0                	test   %eax,%eax
f0101f81:	75 f9                	jne    f0101f7c <mem_init+0x147>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f8a:	e8 ed fa ff ff       	call   f0101a7c <page_alloc>
f0101f8f:	89 c6                	mov    %eax,%esi
f0101f91:	85 c0                	test   %eax,%eax
f0101f93:	75 24                	jne    f0101fb9 <mem_init+0x184>
f0101f95:	c7 44 24 0c d3 63 10 	movl   $0xf01063d3,0xc(%esp)
f0101f9c:	f0 
f0101f9d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101fa4:	f0 
f0101fa5:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
f0101fac:	00 
f0101fad:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101fb4:	e8 db e0 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fc0:	e8 b7 fa ff ff       	call   f0101a7c <page_alloc>
f0101fc5:	89 c7                	mov    %eax,%edi
f0101fc7:	85 c0                	test   %eax,%eax
f0101fc9:	75 24                	jne    f0101fef <mem_init+0x1ba>
f0101fcb:	c7 44 24 0c e9 63 10 	movl   $0xf01063e9,0xc(%esp)
f0101fd2:	f0 
f0101fd3:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0101fda:	f0 
f0101fdb:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
f0101fe2:	00 
f0101fe3:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0101fea:	e8 a5 e0 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ff6:	e8 81 fa ff ff       	call   f0101a7c <page_alloc>
f0101ffb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ffe:	85 c0                	test   %eax,%eax
f0102000:	75 24                	jne    f0102026 <mem_init+0x1f1>
f0102002:	c7 44 24 0c ff 63 10 	movl   $0xf01063ff,0xc(%esp)
f0102009:	f0 
f010200a:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102011:	f0 
f0102012:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
f0102019:	00 
f010201a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102021:	e8 6e e0 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102026:	39 fe                	cmp    %edi,%esi
f0102028:	75 24                	jne    f010204e <mem_init+0x219>
f010202a:	c7 44 24 0c 15 64 10 	movl   $0xf0106415,0xc(%esp)
f0102031:	f0 
f0102032:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102039:	f0 
f010203a:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
f0102041:	00 
f0102042:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102049:	e8 46 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010204e:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102051:	74 05                	je     f0102058 <mem_init+0x223>
f0102053:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102056:	75 24                	jne    f010207c <mem_init+0x247>
f0102058:	c7 44 24 0c cc 5c 10 	movl   $0xf0105ccc,0xc(%esp)
f010205f:	f0 
f0102060:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102067:	f0 
f0102068:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f010206f:	00 
f0102070:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102077:	e8 18 e0 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010207c:	8b 15 90 29 12 f0    	mov    0xf0122990,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102082:	a1 88 29 12 f0       	mov    0xf0122988,%eax
f0102087:	c1 e0 0c             	shl    $0xc,%eax
f010208a:	89 f1                	mov    %esi,%ecx
f010208c:	29 d1                	sub    %edx,%ecx
f010208e:	c1 f9 03             	sar    $0x3,%ecx
f0102091:	c1 e1 0c             	shl    $0xc,%ecx
f0102094:	39 c1                	cmp    %eax,%ecx
f0102096:	72 24                	jb     f01020bc <mem_init+0x287>
f0102098:	c7 44 24 0c 27 64 10 	movl   $0xf0106427,0xc(%esp)
f010209f:	f0 
f01020a0:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01020a7:	f0 
f01020a8:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f01020af:	00 
f01020b0:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01020b7:	e8 d8 df ff ff       	call   f0100094 <_panic>
f01020bc:	89 f9                	mov    %edi,%ecx
f01020be:	29 d1                	sub    %edx,%ecx
f01020c0:	c1 f9 03             	sar    $0x3,%ecx
f01020c3:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01020c6:	39 c8                	cmp    %ecx,%eax
f01020c8:	77 24                	ja     f01020ee <mem_init+0x2b9>
f01020ca:	c7 44 24 0c 44 64 10 	movl   $0xf0106444,0xc(%esp)
f01020d1:	f0 
f01020d2:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01020d9:	f0 
f01020da:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
f01020e1:	00 
f01020e2:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01020e9:	e8 a6 df ff ff       	call   f0100094 <_panic>
f01020ee:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01020f1:	29 d1                	sub    %edx,%ecx
f01020f3:	89 ca                	mov    %ecx,%edx
f01020f5:	c1 fa 03             	sar    $0x3,%edx
f01020f8:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01020fb:	39 d0                	cmp    %edx,%eax
f01020fd:	77 24                	ja     f0102123 <mem_init+0x2ee>
f01020ff:	c7 44 24 0c 61 64 10 	movl   $0xf0106461,0xc(%esp)
f0102106:	f0 
f0102107:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010210e:	f0 
f010210f:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0102116:	00 
f0102117:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010211e:	e8 71 df ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102123:	a1 68 25 12 f0       	mov    0xf0122568,%eax
f0102128:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010212b:	c7 05 68 25 12 f0 00 	movl   $0x0,0xf0122568
f0102132:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010213c:	e8 3b f9 ff ff       	call   f0101a7c <page_alloc>
f0102141:	85 c0                	test   %eax,%eax
f0102143:	74 24                	je     f0102169 <mem_init+0x334>
f0102145:	c7 44 24 0c 7e 64 10 	movl   $0xf010647e,0xc(%esp)
f010214c:	f0 
f010214d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102154:	f0 
f0102155:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f010215c:	00 
f010215d:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102164:	e8 2b df ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102169:	89 34 24             	mov    %esi,(%esp)
f010216c:	e8 8f f9 ff ff       	call   f0101b00 <page_free>
	page_free(pp1);
f0102171:	89 3c 24             	mov    %edi,(%esp)
f0102174:	e8 87 f9 ff ff       	call   f0101b00 <page_free>
	page_free(pp2);
f0102179:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010217c:	89 04 24             	mov    %eax,(%esp)
f010217f:	e8 7c f9 ff ff       	call   f0101b00 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102184:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010218b:	e8 ec f8 ff ff       	call   f0101a7c <page_alloc>
f0102190:	89 c6                	mov    %eax,%esi
f0102192:	85 c0                	test   %eax,%eax
f0102194:	75 24                	jne    f01021ba <mem_init+0x385>
f0102196:	c7 44 24 0c d3 63 10 	movl   $0xf01063d3,0xc(%esp)
f010219d:	f0 
f010219e:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01021a5:	f0 
f01021a6:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f01021ad:	00 
f01021ae:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01021b5:	e8 da de ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01021ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021c1:	e8 b6 f8 ff ff       	call   f0101a7c <page_alloc>
f01021c6:	89 c7                	mov    %eax,%edi
f01021c8:	85 c0                	test   %eax,%eax
f01021ca:	75 24                	jne    f01021f0 <mem_init+0x3bb>
f01021cc:	c7 44 24 0c e9 63 10 	movl   $0xf01063e9,0xc(%esp)
f01021d3:	f0 
f01021d4:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01021db:	f0 
f01021dc:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f01021e3:	00 
f01021e4:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01021eb:	e8 a4 de ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01021f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021f7:	e8 80 f8 ff ff       	call   f0101a7c <page_alloc>
f01021fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021ff:	85 c0                	test   %eax,%eax
f0102201:	75 24                	jne    f0102227 <mem_init+0x3f2>
f0102203:	c7 44 24 0c ff 63 10 	movl   $0xf01063ff,0xc(%esp)
f010220a:	f0 
f010220b:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102212:	f0 
f0102213:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f010221a:	00 
f010221b:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102222:	e8 6d de ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102227:	39 fe                	cmp    %edi,%esi
f0102229:	75 24                	jne    f010224f <mem_init+0x41a>
f010222b:	c7 44 24 0c 15 64 10 	movl   $0xf0106415,0xc(%esp)
f0102232:	f0 
f0102233:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010223a:	f0 
f010223b:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f0102242:	00 
f0102243:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010224a:	e8 45 de ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010224f:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102252:	74 05                	je     f0102259 <mem_init+0x424>
f0102254:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0102257:	75 24                	jne    f010227d <mem_init+0x448>
f0102259:	c7 44 24 0c cc 5c 10 	movl   $0xf0105ccc,0xc(%esp)
f0102260:	f0 
f0102261:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102268:	f0 
f0102269:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f0102270:	00 
f0102271:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102278:	e8 17 de ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010227d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102284:	e8 f3 f7 ff ff       	call   f0101a7c <page_alloc>
f0102289:	85 c0                	test   %eax,%eax
f010228b:	74 24                	je     f01022b1 <mem_init+0x47c>
f010228d:	c7 44 24 0c 7e 64 10 	movl   $0xf010647e,0xc(%esp)
f0102294:	f0 
f0102295:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010229c:	f0 
f010229d:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f01022a4:	00 
f01022a5:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01022ac:	e8 e3 dd ff ff       	call   f0100094 <_panic>
f01022b1:	89 f0                	mov    %esi,%eax
f01022b3:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f01022b9:	c1 f8 03             	sar    $0x3,%eax
f01022bc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022bf:	89 c2                	mov    %eax,%edx
f01022c1:	c1 ea 0c             	shr    $0xc,%edx
f01022c4:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f01022ca:	72 20                	jb     f01022ec <mem_init+0x4b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01022d0:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f01022d7:	f0 
f01022d8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01022df:	00 
f01022e0:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f01022e7:	e8 a8 dd ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01022ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022f3:	00 
f01022f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01022fb:	00 
	return (void *)(pa + KERNBASE);
f01022fc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102301:	89 04 24             	mov    %eax,(%esp)
f0102304:	e8 f1 21 00 00       	call   f01044fa <memset>
	page_free(pp0);
f0102309:	89 34 24             	mov    %esi,(%esp)
f010230c:	e8 ef f7 ff ff       	call   f0101b00 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102311:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102318:	e8 5f f7 ff ff       	call   f0101a7c <page_alloc>
f010231d:	85 c0                	test   %eax,%eax
f010231f:	75 24                	jne    f0102345 <mem_init+0x510>
f0102321:	c7 44 24 0c 8d 64 10 	movl   $0xf010648d,0xc(%esp)
f0102328:	f0 
f0102329:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102330:	f0 
f0102331:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0102338:	00 
f0102339:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102340:	e8 4f dd ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0102345:	39 c6                	cmp    %eax,%esi
f0102347:	74 24                	je     f010236d <mem_init+0x538>
f0102349:	c7 44 24 0c ab 64 10 	movl   $0xf01064ab,0xc(%esp)
f0102350:	f0 
f0102351:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102358:	f0 
f0102359:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f0102360:	00 
f0102361:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102368:	e8 27 dd ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010236d:	89 f2                	mov    %esi,%edx
f010236f:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f0102375:	c1 fa 03             	sar    $0x3,%edx
f0102378:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010237b:	89 d0                	mov    %edx,%eax
f010237d:	c1 e8 0c             	shr    $0xc,%eax
f0102380:	3b 05 88 29 12 f0    	cmp    0xf0122988,%eax
f0102386:	72 20                	jb     f01023a8 <mem_init+0x573>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102388:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010238c:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0102393:	f0 
f0102394:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010239b:	00 
f010239c:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f01023a3:	e8 ec dc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01023a8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01023ae:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01023b4:	80 38 00             	cmpb   $0x0,(%eax)
f01023b7:	74 24                	je     f01023dd <mem_init+0x5a8>
f01023b9:	c7 44 24 0c bb 64 10 	movl   $0xf01064bb,0xc(%esp)
f01023c0:	f0 
f01023c1:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01023c8:	f0 
f01023c9:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
f01023d0:	00 
f01023d1:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01023d8:	e8 b7 dc ff ff       	call   f0100094 <_panic>
f01023dd:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01023de:	39 d0                	cmp    %edx,%eax
f01023e0:	75 d2                	jne    f01023b4 <mem_init+0x57f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01023e2:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01023e5:	89 15 68 25 12 f0    	mov    %edx,0xf0122568

	// free the pages we took
	page_free(pp0);
f01023eb:	89 34 24             	mov    %esi,(%esp)
f01023ee:	e8 0d f7 ff ff       	call   f0101b00 <page_free>
	page_free(pp1);
f01023f3:	89 3c 24             	mov    %edi,(%esp)
f01023f6:	e8 05 f7 ff ff       	call   f0101b00 <page_free>
	page_free(pp2);
f01023fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023fe:	89 04 24             	mov    %eax,(%esp)
f0102401:	e8 fa f6 ff ff       	call   f0101b00 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102406:	a1 68 25 12 f0       	mov    0xf0122568,%eax
f010240b:	eb 03                	jmp    f0102410 <mem_init+0x5db>
		--nfree;
f010240d:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010240e:	8b 00                	mov    (%eax),%eax
f0102410:	85 c0                	test   %eax,%eax
f0102412:	75 f9                	jne    f010240d <mem_init+0x5d8>
		--nfree;
	assert(nfree == 0);
f0102414:	85 db                	test   %ebx,%ebx
f0102416:	74 24                	je     f010243c <mem_init+0x607>
f0102418:	c7 44 24 0c c5 64 10 	movl   $0xf01064c5,0xc(%esp)
f010241f:	f0 
f0102420:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102427:	f0 
f0102428:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f010242f:	00 
f0102430:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102437:	e8 58 dc ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010243c:	c7 04 24 ec 5c 10 f0 	movl   $0xf0105cec,(%esp)
f0102443:	e8 0e 16 00 00       	call   f0103a56 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102448:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010244f:	e8 28 f6 ff ff       	call   f0101a7c <page_alloc>
f0102454:	89 c7                	mov    %eax,%edi
f0102456:	85 c0                	test   %eax,%eax
f0102458:	75 24                	jne    f010247e <mem_init+0x649>
f010245a:	c7 44 24 0c d3 63 10 	movl   $0xf01063d3,0xc(%esp)
f0102461:	f0 
f0102462:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102469:	f0 
f010246a:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0102471:	00 
f0102472:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102479:	e8 16 dc ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010247e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102485:	e8 f2 f5 ff ff       	call   f0101a7c <page_alloc>
f010248a:	89 c6                	mov    %eax,%esi
f010248c:	85 c0                	test   %eax,%eax
f010248e:	75 24                	jne    f01024b4 <mem_init+0x67f>
f0102490:	c7 44 24 0c e9 63 10 	movl   $0xf01063e9,0xc(%esp)
f0102497:	f0 
f0102498:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010249f:	f0 
f01024a0:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f01024a7:	00 
f01024a8:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01024af:	e8 e0 db ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01024b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024bb:	e8 bc f5 ff ff       	call   f0101a7c <page_alloc>
f01024c0:	89 c3                	mov    %eax,%ebx
f01024c2:	85 c0                	test   %eax,%eax
f01024c4:	75 24                	jne    f01024ea <mem_init+0x6b5>
f01024c6:	c7 44 24 0c ff 63 10 	movl   $0xf01063ff,0xc(%esp)
f01024cd:	f0 
f01024ce:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01024d5:	f0 
f01024d6:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f01024dd:	00 
f01024de:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01024e5:	e8 aa db ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01024ea:	39 f7                	cmp    %esi,%edi
f01024ec:	75 24                	jne    f0102512 <mem_init+0x6dd>
f01024ee:	c7 44 24 0c 15 64 10 	movl   $0xf0106415,0xc(%esp)
f01024f5:	f0 
f01024f6:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01024fd:	f0 
f01024fe:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0102505:	00 
f0102506:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010250d:	e8 82 db ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102512:	39 c6                	cmp    %eax,%esi
f0102514:	74 04                	je     f010251a <mem_init+0x6e5>
f0102516:	39 c7                	cmp    %eax,%edi
f0102518:	75 24                	jne    f010253e <mem_init+0x709>
f010251a:	c7 44 24 0c cc 5c 10 	movl   $0xf0105ccc,0xc(%esp)
f0102521:	f0 
f0102522:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102529:	f0 
f010252a:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0102531:	00 
f0102532:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102539:	e8 56 db ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010253e:	8b 15 68 25 12 f0    	mov    0xf0122568,%edx
f0102544:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0102547:	c7 05 68 25 12 f0 00 	movl   $0x0,0xf0122568
f010254e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102558:	e8 1f f5 ff ff       	call   f0101a7c <page_alloc>
f010255d:	85 c0                	test   %eax,%eax
f010255f:	74 24                	je     f0102585 <mem_init+0x750>
f0102561:	c7 44 24 0c 7e 64 10 	movl   $0xf010647e,0xc(%esp)
f0102568:	f0 
f0102569:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102570:	f0 
f0102571:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0102578:	00 
f0102579:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102580:	e8 0f db ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102585:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102588:	89 44 24 08          	mov    %eax,0x8(%esp)
f010258c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102593:	00 
f0102594:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102599:	89 04 24             	mov    %eax,(%esp)
f010259c:	e8 52 f7 ff ff       	call   f0101cf3 <page_lookup>
f01025a1:	85 c0                	test   %eax,%eax
f01025a3:	74 24                	je     f01025c9 <mem_init+0x794>
f01025a5:	c7 44 24 0c 0c 5d 10 	movl   $0xf0105d0c,0xc(%esp)
f01025ac:	f0 
f01025ad:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f01025bc:	00 
f01025bd:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01025c4:	e8 cb da ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01025c9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025d0:	00 
f01025d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025d8:	00 
f01025d9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01025dd:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f01025e2:	89 04 24             	mov    %eax,(%esp)
f01025e5:	e8 ca f7 ff ff       	call   f0101db4 <page_insert>
f01025ea:	85 c0                	test   %eax,%eax
f01025ec:	78 24                	js     f0102612 <mem_init+0x7dd>
f01025ee:	c7 44 24 0c 44 5d 10 	movl   $0xf0105d44,0xc(%esp)
f01025f5:	f0 
f01025f6:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01025fd:	f0 
f01025fe:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102605:	00 
f0102606:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010260d:	e8 82 da ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102612:	89 3c 24             	mov    %edi,(%esp)
f0102615:	e8 e6 f4 ff ff       	call   f0101b00 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010261a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102621:	00 
f0102622:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102629:	00 
f010262a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010262e:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102633:	89 04 24             	mov    %eax,(%esp)
f0102636:	e8 79 f7 ff ff       	call   f0101db4 <page_insert>
f010263b:	85 c0                	test   %eax,%eax
f010263d:	74 24                	je     f0102663 <mem_init+0x82e>
f010263f:	c7 44 24 0c 74 5d 10 	movl   $0xf0105d74,0xc(%esp)
f0102646:	f0 
f0102647:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010264e:	f0 
f010264f:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0102656:	00 
f0102657:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010265e:	e8 31 da ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102663:	8b 0d 8c 29 12 f0    	mov    0xf012298c,%ecx
f0102669:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010266c:	a1 90 29 12 f0       	mov    0xf0122990,%eax
f0102671:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102674:	8b 11                	mov    (%ecx),%edx
f0102676:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010267c:	89 f8                	mov    %edi,%eax
f010267e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0102681:	c1 f8 03             	sar    $0x3,%eax
f0102684:	c1 e0 0c             	shl    $0xc,%eax
f0102687:	39 c2                	cmp    %eax,%edx
f0102689:	74 24                	je     f01026af <mem_init+0x87a>
f010268b:	c7 44 24 0c a4 5d 10 	movl   $0xf0105da4,0xc(%esp)
f0102692:	f0 
f0102693:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010269a:	f0 
f010269b:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f01026a2:	00 
f01026a3:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01026aa:	e8 e5 d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01026af:	ba 00 00 00 00       	mov    $0x0,%edx
f01026b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026b7:	e8 04 ee ff ff       	call   f01014c0 <check_va2pa>
f01026bc:	89 f2                	mov    %esi,%edx
f01026be:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01026c1:	c1 fa 03             	sar    $0x3,%edx
f01026c4:	c1 e2 0c             	shl    $0xc,%edx
f01026c7:	39 d0                	cmp    %edx,%eax
f01026c9:	74 24                	je     f01026ef <mem_init+0x8ba>
f01026cb:	c7 44 24 0c cc 5d 10 	movl   $0xf0105dcc,0xc(%esp)
f01026d2:	f0 
f01026d3:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01026da:	f0 
f01026db:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f01026e2:	00 
f01026e3:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01026ea:	e8 a5 d9 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01026ef:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026f4:	74 24                	je     f010271a <mem_init+0x8e5>
f01026f6:	c7 44 24 0c d0 64 10 	movl   $0xf01064d0,0xc(%esp)
f01026fd:	f0 
f01026fe:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102705:	f0 
f0102706:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f010270d:	00 
f010270e:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102715:	e8 7a d9 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f010271a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010271f:	74 24                	je     f0102745 <mem_init+0x910>
f0102721:	c7 44 24 0c e1 64 10 	movl   $0xf01064e1,0xc(%esp)
f0102728:	f0 
f0102729:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102730:	f0 
f0102731:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0102738:	00 
f0102739:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102740:	e8 4f d9 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102745:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010274c:	00 
f010274d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102754:	00 
f0102755:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102759:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010275c:	89 14 24             	mov    %edx,(%esp)
f010275f:	e8 50 f6 ff ff       	call   f0101db4 <page_insert>
f0102764:	85 c0                	test   %eax,%eax
f0102766:	74 24                	je     f010278c <mem_init+0x957>
f0102768:	c7 44 24 0c fc 5d 10 	movl   $0xf0105dfc,0xc(%esp)
f010276f:	f0 
f0102770:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102777:	f0 
f0102778:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f010277f:	00 
f0102780:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102787:	e8 08 d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010278c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102791:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102796:	e8 25 ed ff ff       	call   f01014c0 <check_va2pa>
f010279b:	89 da                	mov    %ebx,%edx
f010279d:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f01027a3:	c1 fa 03             	sar    $0x3,%edx
f01027a6:	c1 e2 0c             	shl    $0xc,%edx
f01027a9:	39 d0                	cmp    %edx,%eax
f01027ab:	74 24                	je     f01027d1 <mem_init+0x99c>
f01027ad:	c7 44 24 0c 38 5e 10 	movl   $0xf0105e38,0xc(%esp)
f01027b4:	f0 
f01027b5:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01027bc:	f0 
f01027bd:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f01027c4:	00 
f01027c5:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01027cc:	e8 c3 d8 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01027d1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027d6:	74 24                	je     f01027fc <mem_init+0x9c7>
f01027d8:	c7 44 24 0c f2 64 10 	movl   $0xf01064f2,0xc(%esp)
f01027df:	f0 
f01027e0:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01027e7:	f0 
f01027e8:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f01027ef:	00 
f01027f0:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01027f7:	e8 98 d8 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102803:	e8 74 f2 ff ff       	call   f0101a7c <page_alloc>
f0102808:	85 c0                	test   %eax,%eax
f010280a:	74 24                	je     f0102830 <mem_init+0x9fb>
f010280c:	c7 44 24 0c 7e 64 10 	movl   $0xf010647e,0xc(%esp)
f0102813:	f0 
f0102814:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010281b:	f0 
f010281c:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0102823:	00 
f0102824:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010282b:	e8 64 d8 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102830:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102837:	00 
f0102838:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010283f:	00 
f0102840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102844:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102849:	89 04 24             	mov    %eax,(%esp)
f010284c:	e8 63 f5 ff ff       	call   f0101db4 <page_insert>
f0102851:	85 c0                	test   %eax,%eax
f0102853:	74 24                	je     f0102879 <mem_init+0xa44>
f0102855:	c7 44 24 0c fc 5d 10 	movl   $0xf0105dfc,0xc(%esp)
f010285c:	f0 
f010285d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102864:	f0 
f0102865:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f010286c:	00 
f010286d:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102874:	e8 1b d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102879:	ba 00 10 00 00       	mov    $0x1000,%edx
f010287e:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102883:	e8 38 ec ff ff       	call   f01014c0 <check_va2pa>
f0102888:	89 da                	mov    %ebx,%edx
f010288a:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f0102890:	c1 fa 03             	sar    $0x3,%edx
f0102893:	c1 e2 0c             	shl    $0xc,%edx
f0102896:	39 d0                	cmp    %edx,%eax
f0102898:	74 24                	je     f01028be <mem_init+0xa89>
f010289a:	c7 44 24 0c 38 5e 10 	movl   $0xf0105e38,0xc(%esp)
f01028a1:	f0 
f01028a2:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01028a9:	f0 
f01028aa:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f01028b1:	00 
f01028b2:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01028b9:	e8 d6 d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01028be:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01028c3:	74 24                	je     f01028e9 <mem_init+0xab4>
f01028c5:	c7 44 24 0c f2 64 10 	movl   $0xf01064f2,0xc(%esp)
f01028cc:	f0 
f01028cd:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01028d4:	f0 
f01028d5:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f01028dc:	00 
f01028dd:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01028e4:	e8 ab d7 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01028e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028f0:	e8 87 f1 ff ff       	call   f0101a7c <page_alloc>
f01028f5:	85 c0                	test   %eax,%eax
f01028f7:	74 24                	je     f010291d <mem_init+0xae8>
f01028f9:	c7 44 24 0c 7e 64 10 	movl   $0xf010647e,0xc(%esp)
f0102900:	f0 
f0102901:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102908:	f0 
f0102909:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0102910:	00 
f0102911:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102918:	e8 77 d7 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010291d:	8b 15 8c 29 12 f0    	mov    0xf012298c,%edx
f0102923:	8b 02                	mov    (%edx),%eax
f0102925:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010292a:	89 c1                	mov    %eax,%ecx
f010292c:	c1 e9 0c             	shr    $0xc,%ecx
f010292f:	3b 0d 88 29 12 f0    	cmp    0xf0122988,%ecx
f0102935:	72 20                	jb     f0102957 <mem_init+0xb22>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102937:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010293b:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0102942:	f0 
f0102943:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f010294a:	00 
f010294b:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102952:	e8 3d d7 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102957:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010295c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010295f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102966:	00 
f0102967:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010296e:	00 
f010296f:	89 14 24             	mov    %edx,(%esp)
f0102972:	e8 e9 f1 ff ff       	call   f0101b60 <pgdir_walk>
f0102977:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010297a:	83 c2 04             	add    $0x4,%edx
f010297d:	39 d0                	cmp    %edx,%eax
f010297f:	74 24                	je     f01029a5 <mem_init+0xb70>
f0102981:	c7 44 24 0c 68 5e 10 	movl   $0xf0105e68,0xc(%esp)
f0102988:	f0 
f0102989:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102990:	f0 
f0102991:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0102998:	00 
f0102999:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01029a0:	e8 ef d6 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01029a5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01029ac:	00 
f01029ad:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01029b4:	00 
f01029b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01029b9:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f01029be:	89 04 24             	mov    %eax,(%esp)
f01029c1:	e8 ee f3 ff ff       	call   f0101db4 <page_insert>
f01029c6:	85 c0                	test   %eax,%eax
f01029c8:	74 24                	je     f01029ee <mem_init+0xbb9>
f01029ca:	c7 44 24 0c a8 5e 10 	movl   $0xf0105ea8,0xc(%esp)
f01029d1:	f0 
f01029d2:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01029d9:	f0 
f01029da:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01029e1:	00 
f01029e2:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01029e9:	e8 a6 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01029ee:	8b 0d 8c 29 12 f0    	mov    0xf012298c,%ecx
f01029f4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01029f7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01029fc:	89 c8                	mov    %ecx,%eax
f01029fe:	e8 bd ea ff ff       	call   f01014c0 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a03:	89 da                	mov    %ebx,%edx
f0102a05:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f0102a0b:	c1 fa 03             	sar    $0x3,%edx
f0102a0e:	c1 e2 0c             	shl    $0xc,%edx
f0102a11:	39 d0                	cmp    %edx,%eax
f0102a13:	74 24                	je     f0102a39 <mem_init+0xc04>
f0102a15:	c7 44 24 0c 38 5e 10 	movl   $0xf0105e38,0xc(%esp)
f0102a1c:	f0 
f0102a1d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102a24:	f0 
f0102a25:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0102a2c:	00 
f0102a2d:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102a34:	e8 5b d6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102a39:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102a3e:	74 24                	je     f0102a64 <mem_init+0xc2f>
f0102a40:	c7 44 24 0c f2 64 10 	movl   $0xf01064f2,0xc(%esp)
f0102a47:	f0 
f0102a48:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102a4f:	f0 
f0102a50:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0102a57:	00 
f0102a58:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102a5f:	e8 30 d6 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102a64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a6b:	00 
f0102a6c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102a73:	00 
f0102a74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a77:	89 04 24             	mov    %eax,(%esp)
f0102a7a:	e8 e1 f0 ff ff       	call   f0101b60 <pgdir_walk>
f0102a7f:	f6 00 04             	testb  $0x4,(%eax)
f0102a82:	75 24                	jne    f0102aa8 <mem_init+0xc73>
f0102a84:	c7 44 24 0c e8 5e 10 	movl   $0xf0105ee8,0xc(%esp)
f0102a8b:	f0 
f0102a8c:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102a93:	f0 
f0102a94:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0102a9b:	00 
f0102a9c:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102aa3:	e8 ec d5 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102aa8:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102aad:	f6 00 04             	testb  $0x4,(%eax)
f0102ab0:	75 24                	jne    f0102ad6 <mem_init+0xca1>
f0102ab2:	c7 44 24 0c 03 65 10 	movl   $0xf0106503,0xc(%esp)
f0102ab9:	f0 
f0102aba:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102ac1:	f0 
f0102ac2:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0102ac9:	00 
f0102aca:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102ad1:	e8 be d5 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102ad6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102add:	00 
f0102ade:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ae5:	00 
f0102ae6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102aea:	89 04 24             	mov    %eax,(%esp)
f0102aed:	e8 c2 f2 ff ff       	call   f0101db4 <page_insert>
f0102af2:	85 c0                	test   %eax,%eax
f0102af4:	74 24                	je     f0102b1a <mem_init+0xce5>
f0102af6:	c7 44 24 0c fc 5d 10 	movl   $0xf0105dfc,0xc(%esp)
f0102afd:	f0 
f0102afe:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0102b0d:	00 
f0102b0e:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102b15:	e8 7a d5 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102b1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b21:	00 
f0102b22:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b29:	00 
f0102b2a:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102b2f:	89 04 24             	mov    %eax,(%esp)
f0102b32:	e8 29 f0 ff ff       	call   f0101b60 <pgdir_walk>
f0102b37:	f6 00 02             	testb  $0x2,(%eax)
f0102b3a:	75 24                	jne    f0102b60 <mem_init+0xd2b>
f0102b3c:	c7 44 24 0c 1c 5f 10 	movl   $0xf0105f1c,0xc(%esp)
f0102b43:	f0 
f0102b44:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102b4b:	f0 
f0102b4c:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0102b53:	00 
f0102b54:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102b5b:	e8 34 d5 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102b60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b67:	00 
f0102b68:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b6f:	00 
f0102b70:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102b75:	89 04 24             	mov    %eax,(%esp)
f0102b78:	e8 e3 ef ff ff       	call   f0101b60 <pgdir_walk>
f0102b7d:	f6 00 04             	testb  $0x4,(%eax)
f0102b80:	74 24                	je     f0102ba6 <mem_init+0xd71>
f0102b82:	c7 44 24 0c 50 5f 10 	movl   $0xf0105f50,0xc(%esp)
f0102b89:	f0 
f0102b8a:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102b91:	f0 
f0102b92:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0102b99:	00 
f0102b9a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102ba1:	e8 ee d4 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102ba6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102bad:	00 
f0102bae:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102bb5:	00 
f0102bb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102bba:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102bbf:	89 04 24             	mov    %eax,(%esp)
f0102bc2:	e8 ed f1 ff ff       	call   f0101db4 <page_insert>
f0102bc7:	85 c0                	test   %eax,%eax
f0102bc9:	78 24                	js     f0102bef <mem_init+0xdba>
f0102bcb:	c7 44 24 0c 88 5f 10 	movl   $0xf0105f88,0xc(%esp)
f0102bd2:	f0 
f0102bd3:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102bda:	f0 
f0102bdb:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102be2:	00 
f0102be3:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102bea:	e8 a5 d4 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102bef:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102bf6:	00 
f0102bf7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bfe:	00 
f0102bff:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c03:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102c08:	89 04 24             	mov    %eax,(%esp)
f0102c0b:	e8 a4 f1 ff ff       	call   f0101db4 <page_insert>
f0102c10:	85 c0                	test   %eax,%eax
f0102c12:	74 24                	je     f0102c38 <mem_init+0xe03>
f0102c14:	c7 44 24 0c c0 5f 10 	movl   $0xf0105fc0,0xc(%esp)
f0102c1b:	f0 
f0102c1c:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102c23:	f0 
f0102c24:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102c2b:	00 
f0102c2c:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102c33:	e8 5c d4 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102c38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c3f:	00 
f0102c40:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c47:	00 
f0102c48:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102c4d:	89 04 24             	mov    %eax,(%esp)
f0102c50:	e8 0b ef ff ff       	call   f0101b60 <pgdir_walk>
f0102c55:	f6 00 04             	testb  $0x4,(%eax)
f0102c58:	74 24                	je     f0102c7e <mem_init+0xe49>
f0102c5a:	c7 44 24 0c 50 5f 10 	movl   $0xf0105f50,0xc(%esp)
f0102c61:	f0 
f0102c62:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102c69:	f0 
f0102c6a:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0102c71:	00 
f0102c72:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102c79:	e8 16 d4 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102c7e:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102c83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c86:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c8b:	e8 30 e8 ff ff       	call   f01014c0 <check_va2pa>
f0102c90:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c93:	89 f0                	mov    %esi,%eax
f0102c95:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f0102c9b:	c1 f8 03             	sar    $0x3,%eax
f0102c9e:	c1 e0 0c             	shl    $0xc,%eax
f0102ca1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102ca4:	74 24                	je     f0102cca <mem_init+0xe95>
f0102ca6:	c7 44 24 0c fc 5f 10 	movl   $0xf0105ffc,0xc(%esp)
f0102cad:	f0 
f0102cae:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102cb5:	f0 
f0102cb6:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102cbd:	00 
f0102cbe:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102cc5:	e8 ca d3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102cca:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ccf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cd2:	e8 e9 e7 ff ff       	call   f01014c0 <check_va2pa>
f0102cd7:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102cda:	74 24                	je     f0102d00 <mem_init+0xecb>
f0102cdc:	c7 44 24 0c 28 60 10 	movl   $0xf0106028,0xc(%esp)
f0102ce3:	f0 
f0102ce4:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102ceb:	f0 
f0102cec:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102cf3:	00 
f0102cf4:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102cfb:	e8 94 d3 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102d00:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102d05:	74 24                	je     f0102d2b <mem_init+0xef6>
f0102d07:	c7 44 24 0c 19 65 10 	movl   $0xf0106519,0xc(%esp)
f0102d0e:	f0 
f0102d0f:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102d16:	f0 
f0102d17:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0102d1e:	00 
f0102d1f:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102d26:	e8 69 d3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102d2b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d30:	74 24                	je     f0102d56 <mem_init+0xf21>
f0102d32:	c7 44 24 0c 2a 65 10 	movl   $0xf010652a,0xc(%esp)
f0102d39:	f0 
f0102d3a:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102d41:	f0 
f0102d42:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0102d49:	00 
f0102d4a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102d51:	e8 3e d3 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102d56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d5d:	e8 1a ed ff ff       	call   f0101a7c <page_alloc>
f0102d62:	85 c0                	test   %eax,%eax
f0102d64:	74 04                	je     f0102d6a <mem_init+0xf35>
f0102d66:	39 c3                	cmp    %eax,%ebx
f0102d68:	74 24                	je     f0102d8e <mem_init+0xf59>
f0102d6a:	c7 44 24 0c 58 60 10 	movl   $0xf0106058,0xc(%esp)
f0102d71:	f0 
f0102d72:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102d79:	f0 
f0102d7a:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102d81:	00 
f0102d82:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102d89:	e8 06 d3 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102d8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d95:	00 
f0102d96:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102d9b:	89 04 24             	mov    %eax,(%esp)
f0102d9e:	e8 c8 ef ff ff       	call   f0101d6b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102da3:	8b 15 8c 29 12 f0    	mov    0xf012298c,%edx
f0102da9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102dac:	ba 00 00 00 00       	mov    $0x0,%edx
f0102db1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102db4:	e8 07 e7 ff ff       	call   f01014c0 <check_va2pa>
f0102db9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102dbc:	74 24                	je     f0102de2 <mem_init+0xfad>
f0102dbe:	c7 44 24 0c 7c 60 10 	movl   $0xf010607c,0xc(%esp)
f0102dc5:	f0 
f0102dc6:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102dcd:	f0 
f0102dce:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102dd5:	00 
f0102dd6:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102ddd:	e8 b2 d2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102de2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102de7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dea:	e8 d1 e6 ff ff       	call   f01014c0 <check_va2pa>
f0102def:	89 f2                	mov    %esi,%edx
f0102df1:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f0102df7:	c1 fa 03             	sar    $0x3,%edx
f0102dfa:	c1 e2 0c             	shl    $0xc,%edx
f0102dfd:	39 d0                	cmp    %edx,%eax
f0102dff:	74 24                	je     f0102e25 <mem_init+0xff0>
f0102e01:	c7 44 24 0c 28 60 10 	movl   $0xf0106028,0xc(%esp)
f0102e08:	f0 
f0102e09:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102e10:	f0 
f0102e11:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102e18:	00 
f0102e19:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102e20:	e8 6f d2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102e25:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e2a:	74 24                	je     f0102e50 <mem_init+0x101b>
f0102e2c:	c7 44 24 0c d0 64 10 	movl   $0xf01064d0,0xc(%esp)
f0102e33:	f0 
f0102e34:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102e3b:	f0 
f0102e3c:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0102e43:	00 
f0102e44:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102e4b:	e8 44 d2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102e50:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e55:	74 24                	je     f0102e7b <mem_init+0x1046>
f0102e57:	c7 44 24 0c 2a 65 10 	movl   $0xf010652a,0xc(%esp)
f0102e5e:	f0 
f0102e5f:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102e66:	f0 
f0102e67:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0102e6e:	00 
f0102e6f:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102e76:	e8 19 d2 ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102e7b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102e82:	00 
f0102e83:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102e8a:	00 
f0102e8b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102e8f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102e92:	89 0c 24             	mov    %ecx,(%esp)
f0102e95:	e8 1a ef ff ff       	call   f0101db4 <page_insert>
f0102e9a:	85 c0                	test   %eax,%eax
f0102e9c:	74 24                	je     f0102ec2 <mem_init+0x108d>
f0102e9e:	c7 44 24 0c a0 60 10 	movl   $0xf01060a0,0xc(%esp)
f0102ea5:	f0 
f0102ea6:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102ead:	f0 
f0102eae:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0102eb5:	00 
f0102eb6:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102ebd:	e8 d2 d1 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102ec2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ec7:	75 24                	jne    f0102eed <mem_init+0x10b8>
f0102ec9:	c7 44 24 0c 3b 65 10 	movl   $0xf010653b,0xc(%esp)
f0102ed0:	f0 
f0102ed1:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102ed8:	f0 
f0102ed9:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0102ee0:	00 
f0102ee1:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102ee8:	e8 a7 d1 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102eed:	83 3e 00             	cmpl   $0x0,(%esi)
f0102ef0:	74 24                	je     f0102f16 <mem_init+0x10e1>
f0102ef2:	c7 44 24 0c 47 65 10 	movl   $0xf0106547,0xc(%esp)
f0102ef9:	f0 
f0102efa:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102f01:	f0 
f0102f02:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0102f09:	00 
f0102f0a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102f11:	e8 7e d1 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102f16:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102f1d:	00 
f0102f1e:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102f23:	89 04 24             	mov    %eax,(%esp)
f0102f26:	e8 40 ee ff ff       	call   f0101d6b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102f2b:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0102f30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102f33:	ba 00 00 00 00       	mov    $0x0,%edx
f0102f38:	e8 83 e5 ff ff       	call   f01014c0 <check_va2pa>
f0102f3d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f40:	74 24                	je     f0102f66 <mem_init+0x1131>
f0102f42:	c7 44 24 0c 7c 60 10 	movl   $0xf010607c,0xc(%esp)
f0102f49:	f0 
f0102f4a:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102f51:	f0 
f0102f52:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0102f59:	00 
f0102f5a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102f61:	e8 2e d1 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102f66:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102f6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f6e:	e8 4d e5 ff ff       	call   f01014c0 <check_va2pa>
f0102f73:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f76:	74 24                	je     f0102f9c <mem_init+0x1167>
f0102f78:	c7 44 24 0c d8 60 10 	movl   $0xf01060d8,0xc(%esp)
f0102f7f:	f0 
f0102f80:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102f87:	f0 
f0102f88:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0102f8f:	00 
f0102f90:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102f97:	e8 f8 d0 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102f9c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102fa1:	74 24                	je     f0102fc7 <mem_init+0x1192>
f0102fa3:	c7 44 24 0c 5c 65 10 	movl   $0xf010655c,0xc(%esp)
f0102faa:	f0 
f0102fab:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102fb2:	f0 
f0102fb3:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0102fba:	00 
f0102fbb:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102fc2:	e8 cd d0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102fc7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102fcc:	74 24                	je     f0102ff2 <mem_init+0x11bd>
f0102fce:	c7 44 24 0c 2a 65 10 	movl   $0xf010652a,0xc(%esp)
f0102fd5:	f0 
f0102fd6:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0102fdd:	f0 
f0102fde:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0102fe5:	00 
f0102fe6:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0102fed:	e8 a2 d0 ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102ff2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ff9:	e8 7e ea ff ff       	call   f0101a7c <page_alloc>
f0102ffe:	85 c0                	test   %eax,%eax
f0103000:	74 04                	je     f0103006 <mem_init+0x11d1>
f0103002:	39 c6                	cmp    %eax,%esi
f0103004:	74 24                	je     f010302a <mem_init+0x11f5>
f0103006:	c7 44 24 0c 00 61 10 	movl   $0xf0106100,0xc(%esp)
f010300d:	f0 
f010300e:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103015:	f0 
f0103016:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f010301d:	00 
f010301e:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103025:	e8 6a d0 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010302a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103031:	e8 46 ea ff ff       	call   f0101a7c <page_alloc>
f0103036:	85 c0                	test   %eax,%eax
f0103038:	74 24                	je     f010305e <mem_init+0x1229>
f010303a:	c7 44 24 0c 7e 64 10 	movl   $0xf010647e,0xc(%esp)
f0103041:	f0 
f0103042:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103049:	f0 
f010304a:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0103051:	00 
f0103052:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103059:	e8 36 d0 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010305e:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0103063:	8b 08                	mov    (%eax),%ecx
f0103065:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010306b:	89 fa                	mov    %edi,%edx
f010306d:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f0103073:	c1 fa 03             	sar    $0x3,%edx
f0103076:	c1 e2 0c             	shl    $0xc,%edx
f0103079:	39 d1                	cmp    %edx,%ecx
f010307b:	74 24                	je     f01030a1 <mem_init+0x126c>
f010307d:	c7 44 24 0c a4 5d 10 	movl   $0xf0105da4,0xc(%esp)
f0103084:	f0 
f0103085:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010308c:	f0 
f010308d:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0103094:	00 
f0103095:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010309c:	e8 f3 cf ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01030a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01030a7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01030ac:	74 24                	je     f01030d2 <mem_init+0x129d>
f01030ae:	c7 44 24 0c e1 64 10 	movl   $0xf01064e1,0xc(%esp)
f01030b5:	f0 
f01030b6:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01030bd:	f0 
f01030be:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f01030c5:	00 
f01030c6:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01030cd:	e8 c2 cf ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01030d2:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01030d8:	89 3c 24             	mov    %edi,(%esp)
f01030db:	e8 20 ea ff ff       	call   f0101b00 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01030e0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01030e7:	00 
f01030e8:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01030ef:	00 
f01030f0:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f01030f5:	89 04 24             	mov    %eax,(%esp)
f01030f8:	e8 63 ea ff ff       	call   f0101b60 <pgdir_walk>
f01030fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103100:	8b 0d 8c 29 12 f0    	mov    0xf012298c,%ecx
f0103106:	8b 51 04             	mov    0x4(%ecx),%edx
f0103109:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010310f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103112:	8b 15 88 29 12 f0    	mov    0xf0122988,%edx
f0103118:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010311b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010311e:	c1 ea 0c             	shr    $0xc,%edx
f0103121:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103124:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103127:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010312a:	72 23                	jb     f010314f <mem_init+0x131a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010312c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010312f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103133:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f010313a:	f0 
f010313b:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0103142:	00 
f0103143:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010314a:	e8 45 cf ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010314f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103152:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0103158:	39 d0                	cmp    %edx,%eax
f010315a:	74 24                	je     f0103180 <mem_init+0x134b>
f010315c:	c7 44 24 0c 6d 65 10 	movl   $0xf010656d,0xc(%esp)
f0103163:	f0 
f0103164:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010316b:	f0 
f010316c:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0103173:	00 
f0103174:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010317b:	e8 14 cf ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103180:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0103187:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010318d:	89 f8                	mov    %edi,%eax
f010318f:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f0103195:	c1 f8 03             	sar    $0x3,%eax
f0103198:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010319b:	89 c1                	mov    %eax,%ecx
f010319d:	c1 e9 0c             	shr    $0xc,%ecx
f01031a0:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01031a3:	77 20                	ja     f01031c5 <mem_init+0x1390>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031a9:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f01031b0:	f0 
f01031b1:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01031b8:	00 
f01031b9:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f01031c0:	e8 cf ce ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01031c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031cc:	00 
f01031cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01031d4:	00 
	return (void *)(pa + KERNBASE);
f01031d5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031da:	89 04 24             	mov    %eax,(%esp)
f01031dd:	e8 18 13 00 00       	call   f01044fa <memset>
	page_free(pp0);
f01031e2:	89 3c 24             	mov    %edi,(%esp)
f01031e5:	e8 16 e9 ff ff       	call   f0101b00 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01031ea:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01031f1:	00 
f01031f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01031f9:	00 
f01031fa:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f01031ff:	89 04 24             	mov    %eax,(%esp)
f0103202:	e8 59 e9 ff ff       	call   f0101b60 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103207:	89 fa                	mov    %edi,%edx
f0103209:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f010320f:	c1 fa 03             	sar    $0x3,%edx
f0103212:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103215:	89 d0                	mov    %edx,%eax
f0103217:	c1 e8 0c             	shr    $0xc,%eax
f010321a:	3b 05 88 29 12 f0    	cmp    0xf0122988,%eax
f0103220:	72 20                	jb     f0103242 <mem_init+0x140d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103222:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103226:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f010322d:	f0 
f010322e:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0103235:	00 
f0103236:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f010323d:	e8 52 ce ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0103242:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0103248:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010324b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0103251:	f6 00 01             	testb  $0x1,(%eax)
f0103254:	74 24                	je     f010327a <mem_init+0x1445>
f0103256:	c7 44 24 0c 85 65 10 	movl   $0xf0106585,0xc(%esp)
f010325d:	f0 
f010325e:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103265:	f0 
f0103266:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f010326d:	00 
f010326e:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103275:	e8 1a ce ff ff       	call   f0100094 <_panic>
f010327a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010327d:	39 d0                	cmp    %edx,%eax
f010327f:	75 d0                	jne    f0103251 <mem_init+0x141c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103281:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0103286:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010328c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0103292:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103295:	89 0d 68 25 12 f0    	mov    %ecx,0xf0122568

	// free the pages we took
	page_free(pp0);
f010329b:	89 3c 24             	mov    %edi,(%esp)
f010329e:	e8 5d e8 ff ff       	call   f0101b00 <page_free>
	page_free(pp1);
f01032a3:	89 34 24             	mov    %esi,(%esp)
f01032a6:	e8 55 e8 ff ff       	call   f0101b00 <page_free>
	page_free(pp2);
f01032ab:	89 1c 24             	mov    %ebx,(%esp)
f01032ae:	e8 4d e8 ff ff       	call   f0101b00 <page_free>

	cprintf("check_page() succeeded!\n");
f01032b3:	c7 04 24 9c 65 10 f0 	movl   $0xf010659c,(%esp)
f01032ba:	e8 97 07 00 00       	call   f0103a56 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f01032bf:	a1 90 29 12 f0       	mov    0xf0122990,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032c4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032c9:	77 20                	ja     f01032eb <mem_init+0x14b6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032cf:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f01032d6:	f0 
f01032d7:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f01032de:	00 
f01032df:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01032e6:	e8 a9 cd ff ff       	call   f0100094 <_panic>
f01032eb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01032f2:	00 
	return (physaddr_t)kva - KERNBASE;
f01032f3:	05 00 00 00 10       	add    $0x10000000,%eax
f01032f8:	89 04 24             	mov    %eax,(%esp)
f01032fb:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103300:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103305:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f010330a:	e8 12 e9 ff ff       	call   f0101c21 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010330f:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0103314:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103319:	77 20                	ja     f010333b <mem_init+0x1506>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010331b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010331f:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f0103326:	f0 
f0103327:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f010332e:	00 
f010332f:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103336:	e8 59 cd ff ff       	call   f0100094 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
   boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f010333b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103342:	00 
f0103343:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f010334a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010334f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103354:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0103359:	e8 c3 e8 ff ff       	call   f0101c21 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	assert(KERNBASE == 0xf0000000); // 0x100000000 - KERNBASE
	boot_map_region(kern_pgdir,KERNBASE,0x10000000,0x0,PTE_W);
f010335e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103365:	00 
f0103366:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010336d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0103372:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103377:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f010337c:	e8 a0 e8 ff ff       	call   f0101c21 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103381:	8b 1d 8c 29 12 f0    	mov    0xf012298c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0103387:	8b 15 88 29 12 f0    	mov    0xf0122988,%edx
f010338d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103390:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
f0103397:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f010339d:	be 00 00 00 00       	mov    $0x0,%esi
f01033a2:	eb 70                	jmp    f0103414 <mem_init+0x15df>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01033a4:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01033aa:	89 d8                	mov    %ebx,%eax
f01033ac:	e8 0f e1 ff ff       	call   f01014c0 <check_va2pa>
f01033b1:	8b 15 90 29 12 f0    	mov    0xf0122990,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033b7:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01033bd:	77 20                	ja     f01033df <mem_init+0x15aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01033c3:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f01033ca:	f0 
f01033cb:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f01033d2:	00 
f01033d3:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01033da:	e8 b5 cc ff ff       	call   f0100094 <_panic>
f01033df:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01033e6:	39 d0                	cmp    %edx,%eax
f01033e8:	74 24                	je     f010340e <mem_init+0x15d9>
f01033ea:	c7 44 24 0c 24 61 10 	movl   $0xf0106124,0xc(%esp)
f01033f1:	f0 
f01033f2:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01033f9:	f0 
f01033fa:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0103401:	00 
f0103402:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103409:	e8 86 cc ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010340e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103414:	39 f7                	cmp    %esi,%edi
f0103416:	77 8c                	ja     f01033a4 <mem_init+0x156f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0103418:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010341b:	c1 e7 0c             	shl    $0xc,%edi
f010341e:	be 00 00 00 00       	mov    $0x0,%esi
f0103423:	eb 3b                	jmp    f0103460 <mem_init+0x162b>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103425:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
		#ifdef DEBUG
		cprintf("%x %x\n",i,check_va2pa(pgdir, KERNBASE + i));
		#endif
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010342b:	89 d8                	mov    %ebx,%eax
f010342d:	e8 8e e0 ff ff       	call   f01014c0 <check_va2pa>
f0103432:	39 c6                	cmp    %eax,%esi
f0103434:	74 24                	je     f010345a <mem_init+0x1625>
f0103436:	c7 44 24 0c 58 61 10 	movl   $0xf0106158,0xc(%esp)
f010343d:	f0 
f010343e:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103445:	f0 
f0103446:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010344d:	00 
f010344e:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103455:	e8 3a cc ff ff       	call   f0100094 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f010345a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103460:	39 fe                	cmp    %edi,%esi
f0103462:	72 c1                	jb     f0103425 <mem_init+0x15f0>
f0103464:	be 00 80 ff ef       	mov    $0xefff8000,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103469:	bf 00 80 11 f0       	mov    $0xf0118000,%edi
f010346e:	81 c7 00 80 00 20    	add    $0x20008000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103474:	89 f2                	mov    %esi,%edx
f0103476:	89 d8                	mov    %ebx,%eax
f0103478:	e8 43 e0 ff ff       	call   f01014c0 <check_va2pa>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010347d:	8d 14 37             	lea    (%edi,%esi,1),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103480:	39 d0                	cmp    %edx,%eax
f0103482:	74 24                	je     f01034a8 <mem_init+0x1673>
f0103484:	c7 44 24 0c 80 61 10 	movl   $0xf0106180,0xc(%esp)
f010348b:	f0 
f010348c:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103493:	f0 
f0103494:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f010349b:	00 
f010349c:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01034a3:	e8 ec cb ff ff       	call   f0100094 <_panic>
f01034a8:	81 c6 00 10 00 00    	add    $0x1000,%esi
		#endif
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01034ae:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01034b4:	75 be                	jne    f0103474 <mem_init+0x163f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01034b6:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01034bb:	89 d8                	mov    %ebx,%eax
f01034bd:	e8 fe df ff ff       	call   f01014c0 <check_va2pa>
f01034c2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01034c5:	74 24                	je     f01034eb <mem_init+0x16b6>
f01034c7:	c7 44 24 0c c8 61 10 	movl   $0xf01061c8,0xc(%esp)
f01034ce:	f0 
f01034cf:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01034d6:	f0 
f01034d7:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f01034de:	00 
f01034df:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01034e6:	e8 a9 cb ff ff       	call   f0100094 <_panic>
f01034eb:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01034f0:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01034f5:	72 3c                	jb     f0103533 <mem_init+0x16fe>
f01034f7:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01034fc:	76 07                	jbe    f0103505 <mem_init+0x16d0>
f01034fe:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103503:	75 2e                	jne    f0103533 <mem_init+0x16fe>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0103505:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0103509:	0f 85 aa 00 00 00    	jne    f01035b9 <mem_init+0x1784>
f010350f:	c7 44 24 0c b5 65 10 	movl   $0xf01065b5,0xc(%esp)
f0103516:	f0 
f0103517:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010351e:	f0 
f010351f:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0103526:	00 
f0103527:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010352e:	e8 61 cb ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103533:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103538:	76 55                	jbe    f010358f <mem_init+0x175a>
				assert(pgdir[i] & PTE_P);
f010353a:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010353d:	f6 c2 01             	test   $0x1,%dl
f0103540:	75 24                	jne    f0103566 <mem_init+0x1731>
f0103542:	c7 44 24 0c b5 65 10 	movl   $0xf01065b5,0xc(%esp)
f0103549:	f0 
f010354a:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103551:	f0 
f0103552:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f0103559:	00 
f010355a:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103561:	e8 2e cb ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0103566:	f6 c2 02             	test   $0x2,%dl
f0103569:	75 4e                	jne    f01035b9 <mem_init+0x1784>
f010356b:	c7 44 24 0c c6 65 10 	movl   $0xf01065c6,0xc(%esp)
f0103572:	f0 
f0103573:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010357a:	f0 
f010357b:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f0103582:	00 
f0103583:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010358a:	e8 05 cb ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f010358f:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103593:	74 24                	je     f01035b9 <mem_init+0x1784>
f0103595:	c7 44 24 0c d7 65 10 	movl   $0xf01065d7,0xc(%esp)
f010359c:	f0 
f010359d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01035a4:	f0 
f01035a5:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f01035ac:	00 
f01035ad:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01035b4:	e8 db ca ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01035b9:	40                   	inc    %eax
f01035ba:	3d 00 04 00 00       	cmp    $0x400,%eax
f01035bf:	0f 85 2b ff ff ff    	jne    f01034f0 <mem_init+0x16bb>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01035c5:	c7 04 24 f8 61 10 f0 	movl   $0xf01061f8,(%esp)
f01035cc:	e8 85 04 00 00       	call   f0103a56 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01035d1:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035db:	77 20                	ja     f01035fd <mem_init+0x17c8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035e1:	c7 44 24 08 ac 5a 10 	movl   $0xf0105aac,0x8(%esp)
f01035e8:	f0 
f01035e9:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
f01035f0:	00 
f01035f1:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01035f8:	e8 97 ca ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01035fd:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103602:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103605:	b8 00 00 00 00       	mov    $0x0,%eax
f010360a:	e8 df df ff ff       	call   f01015ee <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010360f:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103612:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0103617:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010361a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010361d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103624:	e8 53 e4 ff ff       	call   f0101a7c <page_alloc>
f0103629:	89 c6                	mov    %eax,%esi
f010362b:	85 c0                	test   %eax,%eax
f010362d:	75 24                	jne    f0103653 <mem_init+0x181e>
f010362f:	c7 44 24 0c d3 63 10 	movl   $0xf01063d3,0xc(%esp)
f0103636:	f0 
f0103637:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010363e:	f0 
f010363f:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0103646:	00 
f0103647:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010364e:	e8 41 ca ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0103653:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010365a:	e8 1d e4 ff ff       	call   f0101a7c <page_alloc>
f010365f:	89 c7                	mov    %eax,%edi
f0103661:	85 c0                	test   %eax,%eax
f0103663:	75 24                	jne    f0103689 <mem_init+0x1854>
f0103665:	c7 44 24 0c e9 63 10 	movl   $0xf01063e9,0xc(%esp)
f010366c:	f0 
f010366d:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103674:	f0 
f0103675:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f010367c:	00 
f010367d:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103684:	e8 0b ca ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0103689:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103690:	e8 e7 e3 ff ff       	call   f0101a7c <page_alloc>
f0103695:	89 c3                	mov    %eax,%ebx
f0103697:	85 c0                	test   %eax,%eax
f0103699:	75 24                	jne    f01036bf <mem_init+0x188a>
f010369b:	c7 44 24 0c ff 63 10 	movl   $0xf01063ff,0xc(%esp)
f01036a2:	f0 
f01036a3:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01036aa:	f0 
f01036ab:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f01036b2:	00 
f01036b3:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01036ba:	e8 d5 c9 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f01036bf:	89 34 24             	mov    %esi,(%esp)
f01036c2:	e8 39 e4 ff ff       	call   f0101b00 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01036c7:	89 f8                	mov    %edi,%eax
f01036c9:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f01036cf:	c1 f8 03             	sar    $0x3,%eax
f01036d2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036d5:	89 c2                	mov    %eax,%edx
f01036d7:	c1 ea 0c             	shr    $0xc,%edx
f01036da:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f01036e0:	72 20                	jb     f0103702 <mem_init+0x18cd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036e6:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f01036ed:	f0 
f01036ee:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01036f5:	00 
f01036f6:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f01036fd:	e8 92 c9 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103702:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103709:	00 
f010370a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103711:	00 
	return (void *)(pa + KERNBASE);
f0103712:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103717:	89 04 24             	mov    %eax,(%esp)
f010371a:	e8 db 0d 00 00       	call   f01044fa <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010371f:	89 d8                	mov    %ebx,%eax
f0103721:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f0103727:	c1 f8 03             	sar    $0x3,%eax
f010372a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010372d:	89 c2                	mov    %eax,%edx
f010372f:	c1 ea 0c             	shr    $0xc,%edx
f0103732:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f0103738:	72 20                	jb     f010375a <mem_init+0x1925>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010373a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010373e:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0103745:	f0 
f0103746:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010374d:	00 
f010374e:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f0103755:	e8 3a c9 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010375a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103761:	00 
f0103762:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103769:	00 
	return (void *)(pa + KERNBASE);
f010376a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010376f:	89 04 24             	mov    %eax,(%esp)
f0103772:	e8 83 0d 00 00       	call   f01044fa <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103777:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010377e:	00 
f010377f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103786:	00 
f0103787:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010378b:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0103790:	89 04 24             	mov    %eax,(%esp)
f0103793:	e8 1c e6 ff ff       	call   f0101db4 <page_insert>
	assert(pp1->pp_ref == 1);
f0103798:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010379d:	74 24                	je     f01037c3 <mem_init+0x198e>
f010379f:	c7 44 24 0c d0 64 10 	movl   $0xf01064d0,0xc(%esp)
f01037a6:	f0 
f01037a7:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01037ae:	f0 
f01037af:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f01037b6:	00 
f01037b7:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01037be:	e8 d1 c8 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01037c3:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01037ca:	01 01 01 
f01037cd:	74 24                	je     f01037f3 <mem_init+0x19be>
f01037cf:	c7 44 24 0c 18 62 10 	movl   $0xf0106218,0xc(%esp)
f01037d6:	f0 
f01037d7:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01037de:	f0 
f01037df:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f01037e6:	00 
f01037e7:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01037ee:	e8 a1 c8 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01037f3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01037fa:	00 
f01037fb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103802:	00 
f0103803:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103807:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f010380c:	89 04 24             	mov    %eax,(%esp)
f010380f:	e8 a0 e5 ff ff       	call   f0101db4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103814:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010381b:	02 02 02 
f010381e:	74 24                	je     f0103844 <mem_init+0x1a0f>
f0103820:	c7 44 24 0c 3c 62 10 	movl   $0xf010623c,0xc(%esp)
f0103827:	f0 
f0103828:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010382f:	f0 
f0103830:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0103837:	00 
f0103838:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010383f:	e8 50 c8 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0103844:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103849:	74 24                	je     f010386f <mem_init+0x1a3a>
f010384b:	c7 44 24 0c f2 64 10 	movl   $0xf01064f2,0xc(%esp)
f0103852:	f0 
f0103853:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010385a:	f0 
f010385b:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0103862:	00 
f0103863:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010386a:	e8 25 c8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f010386f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103874:	74 24                	je     f010389a <mem_init+0x1a65>
f0103876:	c7 44 24 0c 5c 65 10 	movl   $0xf010655c,0xc(%esp)
f010387d:	f0 
f010387e:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f0103885:	f0 
f0103886:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f010388d:	00 
f010388e:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f0103895:	e8 fa c7 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010389a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01038a1:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01038a4:	89 d8                	mov    %ebx,%eax
f01038a6:	2b 05 90 29 12 f0    	sub    0xf0122990,%eax
f01038ac:	c1 f8 03             	sar    $0x3,%eax
f01038af:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038b2:	89 c2                	mov    %eax,%edx
f01038b4:	c1 ea 0c             	shr    $0xc,%edx
f01038b7:	3b 15 88 29 12 f0    	cmp    0xf0122988,%edx
f01038bd:	72 20                	jb     f01038df <mem_init+0x1aaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038c3:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f01038ca:	f0 
f01038cb:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01038d2:	00 
f01038d3:	c7 04 24 de 62 10 f0 	movl   $0xf01062de,(%esp)
f01038da:	e8 b5 c7 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01038df:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01038e6:	03 03 03 
f01038e9:	74 24                	je     f010390f <mem_init+0x1ada>
f01038eb:	c7 44 24 0c 60 62 10 	movl   $0xf0106260,0xc(%esp)
f01038f2:	f0 
f01038f3:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01038fa:	f0 
f01038fb:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0103902:	00 
f0103903:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010390a:	e8 85 c7 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010390f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103916:	00 
f0103917:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f010391c:	89 04 24             	mov    %eax,(%esp)
f010391f:	e8 47 e4 ff ff       	call   f0101d6b <page_remove>
	assert(pp2->pp_ref == 0);
f0103924:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103929:	74 24                	je     f010394f <mem_init+0x1b1a>
f010392b:	c7 44 24 0c 2a 65 10 	movl   $0xf010652a,0xc(%esp)
f0103932:	f0 
f0103933:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010393a:	f0 
f010393b:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0103942:	00 
f0103943:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010394a:	e8 45 c7 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010394f:	a1 8c 29 12 f0       	mov    0xf012298c,%eax
f0103954:	8b 08                	mov    (%eax),%ecx
f0103956:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010395c:	89 f2                	mov    %esi,%edx
f010395e:	2b 15 90 29 12 f0    	sub    0xf0122990,%edx
f0103964:	c1 fa 03             	sar    $0x3,%edx
f0103967:	c1 e2 0c             	shl    $0xc,%edx
f010396a:	39 d1                	cmp    %edx,%ecx
f010396c:	74 24                	je     f0103992 <mem_init+0x1b5d>
f010396e:	c7 44 24 0c a4 5d 10 	movl   $0xf0105da4,0xc(%esp)
f0103975:	f0 
f0103976:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f010397d:	f0 
f010397e:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0103985:	00 
f0103986:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f010398d:	e8 02 c7 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0103992:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103998:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010399d:	74 24                	je     f01039c3 <mem_init+0x1b8e>
f010399f:	c7 44 24 0c e1 64 10 	movl   $0xf01064e1,0xc(%esp)
f01039a6:	f0 
f01039a7:	c7 44 24 08 f8 62 10 	movl   $0xf01062f8,0x8(%esp)
f01039ae:	f0 
f01039af:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01039b6:	00 
f01039b7:	c7 04 24 b8 62 10 f0 	movl   $0xf01062b8,(%esp)
f01039be:	e8 d1 c6 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01039c3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01039c9:	89 34 24             	mov    %esi,(%esp)
f01039cc:	e8 2f e1 ff ff       	call   f0101b00 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01039d1:	c7 04 24 8c 62 10 f0 	movl   $0xf010628c,(%esp)
f01039d8:	e8 79 00 00 00       	call   f0103a56 <cprintf>
	// 	cprintf("%x %x %x\n",i,&kern_pgdir[i],KADDR(PTE_ADDR(kern_pgdir[i])));

	// pte_t *pgtable = (pte_t *)KADDR(PTE_ADDR(*pde));
	// cprintf("%x\n",*(int*)0x00400000);
	// cprintf("pages: %x\n",pages);
}
f01039dd:	83 c4 3c             	add    $0x3c,%esp
f01039e0:	5b                   	pop    %ebx
f01039e1:	5e                   	pop    %esi
f01039e2:	5f                   	pop    %edi
f01039e3:	5d                   	pop    %ebp
f01039e4:	c3                   	ret    
f01039e5:	00 00                	add    %al,(%eax)
	...

f01039e8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01039e8:	55                   	push   %ebp
f01039e9:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039eb:	ba 70 00 00 00       	mov    $0x70,%edx
f01039f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01039f3:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01039f4:	b2 71                	mov    $0x71,%dl
f01039f6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01039f7:	0f b6 c0             	movzbl %al,%eax
}
f01039fa:	5d                   	pop    %ebp
f01039fb:	c3                   	ret    

f01039fc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01039fc:	55                   	push   %ebp
f01039fd:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039ff:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a04:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a07:	ee                   	out    %al,(%dx)
f0103a08:	b2 71                	mov    $0x71,%dl
f0103a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a0d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103a0e:	5d                   	pop    %ebp
f0103a0f:	c3                   	ret    

f0103a10 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a10:	55                   	push   %ebp
f0103a11:	89 e5                	mov    %esp,%ebp
f0103a13:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103a16:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a19:	89 04 24             	mov    %eax,(%esp)
f0103a1c:	e8 82 ce ff ff       	call   f01008a3 <cputchar>
	*cnt++;
}
f0103a21:	c9                   	leave  
f0103a22:	c3                   	ret    

f0103a23 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103a23:	55                   	push   %ebp
f0103a24:	89 e5                	mov    %esp,%ebp
f0103a26:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103a29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103a30:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a33:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a37:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a3a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a45:	c7 04 24 10 3a 10 f0 	movl   $0xf0103a10,(%esp)
f0103a4c:	e8 69 04 00 00       	call   f0103eba <vprintfmt>
	return cnt;
}
f0103a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a54:	c9                   	leave  
f0103a55:	c3                   	ret    

f0103a56 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103a56:	55                   	push   %ebp
f0103a57:	89 e5                	mov    %esp,%ebp
f0103a59:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103a5c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a63:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a66:	89 04 24             	mov    %eax,(%esp)
f0103a69:	e8 b5 ff ff ff       	call   f0103a23 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a6e:	c9                   	leave  
f0103a6f:	c3                   	ret    

f0103a70 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103a70:	55                   	push   %ebp
f0103a71:	89 e5                	mov    %esp,%ebp
f0103a73:	57                   	push   %edi
f0103a74:	56                   	push   %esi
f0103a75:	53                   	push   %ebx
f0103a76:	83 ec 10             	sub    $0x10,%esp
f0103a79:	89 c3                	mov    %eax,%ebx
f0103a7b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103a7e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103a81:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103a84:	8b 0a                	mov    (%edx),%ecx
f0103a86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a89:	8b 00                	mov    (%eax),%eax
f0103a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103a8e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0103a95:	eb 77                	jmp    f0103b0e <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0103a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103a9a:	01 c8                	add    %ecx,%eax
f0103a9c:	bf 02 00 00 00       	mov    $0x2,%edi
f0103aa1:	99                   	cltd   
f0103aa2:	f7 ff                	idiv   %edi
f0103aa4:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103aa6:	eb 01                	jmp    f0103aa9 <stab_binsearch+0x39>
			m--;
f0103aa8:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103aa9:	39 ca                	cmp    %ecx,%edx
f0103aab:	7c 1d                	jl     f0103aca <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103aad:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ab0:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0103ab5:	39 f7                	cmp    %esi,%edi
f0103ab7:	75 ef                	jne    f0103aa8 <stab_binsearch+0x38>
f0103ab9:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103abc:	6b fa 0c             	imul   $0xc,%edx,%edi
f0103abf:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0103ac3:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0103ac6:	73 18                	jae    f0103ae0 <stab_binsearch+0x70>
f0103ac8:	eb 05                	jmp    f0103acf <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103aca:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0103acd:	eb 3f                	jmp    f0103b0e <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103acf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103ad2:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0103ad4:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103ad7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0103ade:	eb 2e                	jmp    f0103b0e <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103ae0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0103ae3:	76 15                	jbe    f0103afa <stab_binsearch+0x8a>
			*region_right = m - 1;
f0103ae5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103ae8:	4f                   	dec    %edi
f0103ae9:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103aec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103aef:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103af1:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0103af8:	eb 14                	jmp    f0103b0e <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103afa:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103afd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103b00:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0103b02:	ff 45 0c             	incl   0xc(%ebp)
f0103b05:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103b07:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103b0e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103b11:	7e 84                	jle    f0103a97 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103b13:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0103b17:	75 0d                	jne    f0103b26 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0103b19:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103b1c:	8b 02                	mov    (%edx),%eax
f0103b1e:	48                   	dec    %eax
f0103b1f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103b22:	89 01                	mov    %eax,(%ecx)
f0103b24:	eb 22                	jmp    f0103b48 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103b26:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103b29:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103b2b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103b2e:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103b30:	eb 01                	jmp    f0103b33 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103b32:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103b33:	39 c1                	cmp    %eax,%ecx
f0103b35:	7d 0c                	jge    f0103b43 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103b37:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0103b3a:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0103b3f:	39 f2                	cmp    %esi,%edx
f0103b41:	75 ef                	jne    f0103b32 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103b43:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103b46:	89 02                	mov    %eax,(%edx)
	}
}
f0103b48:	83 c4 10             	add    $0x10,%esp
f0103b4b:	5b                   	pop    %ebx
f0103b4c:	5e                   	pop    %esi
f0103b4d:	5f                   	pop    %edi
f0103b4e:	5d                   	pop    %ebp
f0103b4f:	c3                   	ret    

f0103b50 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103b50:	55                   	push   %ebp
f0103b51:	89 e5                	mov    %esp,%ebp
f0103b53:	57                   	push   %edi
f0103b54:	56                   	push   %esi
f0103b55:	53                   	push   %ebx
f0103b56:	83 ec 4c             	sub    $0x4c,%esp
f0103b59:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103b5f:	c7 03 e5 65 10 f0    	movl   $0xf01065e5,(%ebx)
	info->eip_line = 0;
f0103b65:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103b6c:	c7 43 08 e5 65 10 f0 	movl   $0xf01065e5,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103b73:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103b7a:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103b7d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103b84:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103b8a:	76 12                	jbe    f0103b9e <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103b8c:	b8 29 78 11 f0       	mov    $0xf0117829,%eax
f0103b91:	3d 0d e6 10 f0       	cmp    $0xf010e60d,%eax
f0103b96:	0f 86 a7 01 00 00    	jbe    f0103d43 <debuginfo_eip+0x1f3>
f0103b9c:	eb 1c                	jmp    f0103bba <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0103b9e:	c7 44 24 08 ef 65 10 	movl   $0xf01065ef,0x8(%esp)
f0103ba5:	f0 
f0103ba6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103bad:	00 
f0103bae:	c7 04 24 fc 65 10 f0 	movl   $0xf01065fc,(%esp)
f0103bb5:	e8 da c4 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103bbf:	80 3d 28 78 11 f0 00 	cmpb   $0x0,0xf0117828
f0103bc6:	0f 85 83 01 00 00    	jne    f0103d4f <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103bcc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103bd3:	b8 0c e6 10 f0       	mov    $0xf010e60c,%eax
f0103bd8:	2d 0c 68 10 f0       	sub    $0xf010680c,%eax
f0103bdd:	c1 f8 02             	sar    $0x2,%eax
f0103be0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103be6:	48                   	dec    %eax
f0103be7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103bea:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103bee:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103bf5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103bf8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103bfb:	b8 0c 68 10 f0       	mov    $0xf010680c,%eax
f0103c00:	e8 6b fe ff ff       	call   f0103a70 <stab_binsearch>
	if (lfile == 0)
f0103c05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0103c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103c0d:	85 d2                	test   %edx,%edx
f0103c0f:	0f 84 3a 01 00 00    	je     f0103d4f <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103c15:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0103c18:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103c1e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103c22:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103c29:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103c2c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103c2f:	b8 0c 68 10 f0       	mov    $0xf010680c,%eax
f0103c34:	e8 37 fe ff ff       	call   f0103a70 <stab_binsearch>

	if (lfun <= rfun) {
f0103c39:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103c3c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103c3f:	39 d0                	cmp    %edx,%eax
f0103c41:	7f 3e                	jg     f0103c81 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103c43:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0103c46:	8d b9 0c 68 10 f0    	lea    -0xfef97f4(%ecx),%edi
f0103c4c:	8b 89 0c 68 10 f0    	mov    -0xfef97f4(%ecx),%ecx
f0103c52:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0103c55:	b9 29 78 11 f0       	mov    $0xf0117829,%ecx
f0103c5a:	81 e9 0d e6 10 f0    	sub    $0xf010e60d,%ecx
f0103c60:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0103c63:	73 0c                	jae    f0103c71 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103c65:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103c68:	81 c1 0d e6 10 f0    	add    $0xf010e60d,%ecx
f0103c6e:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103c71:	8b 4f 08             	mov    0x8(%edi),%ecx
f0103c74:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103c77:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103c79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103c7c:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103c7f:	eb 0f                	jmp    f0103c90 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103c81:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c8d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103c90:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103c97:	00 
f0103c98:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c9b:	89 04 24             	mov    %eax,(%esp)
f0103c9e:	e8 3f 08 00 00       	call   f01044e2 <strfind>
f0103ca3:	2b 43 08             	sub    0x8(%ebx),%eax
f0103ca6:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103ca9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103cad:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103cb4:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103cb7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103cba:	b8 0c 68 10 f0       	mov    $0xf010680c,%eax
f0103cbf:	e8 ac fd ff ff       	call   f0103a70 <stab_binsearch>
	if (lline <= rline){
f0103cc4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	}
	else return -1;
f0103cc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline){
f0103ccc:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0103ccf:	7f 7e                	jg     f0103d4f <debuginfo_eip+0x1ff>
		info->eip_line = stabs[lline].n_desc;
f0103cd1:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103cd4:	0f b7 82 12 68 10 f0 	movzwl -0xfef97ee(%edx),%eax
f0103cdb:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103cde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ce1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ce4:	eb 01                	jmp    f0103ce7 <debuginfo_eip+0x197>
f0103ce6:	48                   	dec    %eax
f0103ce7:	89 c6                	mov    %eax,%esi
f0103ce9:	39 c7                	cmp    %eax,%edi
f0103ceb:	7f 26                	jg     f0103d13 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0103ced:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103cf0:	8d 0c 95 0c 68 10 f0 	lea    -0xfef97f4(,%edx,4),%ecx
f0103cf7:	8a 51 04             	mov    0x4(%ecx),%dl
f0103cfa:	80 fa 84             	cmp    $0x84,%dl
f0103cfd:	74 58                	je     f0103d57 <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103cff:	80 fa 64             	cmp    $0x64,%dl
f0103d02:	75 e2                	jne    f0103ce6 <debuginfo_eip+0x196>
f0103d04:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0103d08:	74 dc                	je     f0103ce6 <debuginfo_eip+0x196>
f0103d0a:	eb 4b                	jmp    f0103d57 <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103d0c:	05 0d e6 10 f0       	add    $0xf010e60d,%eax
f0103d11:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103d13:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103d16:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103d19:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103d1e:	39 d1                	cmp    %edx,%ecx
f0103d20:	7d 2d                	jge    f0103d4f <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f0103d22:	8d 41 01             	lea    0x1(%ecx),%eax
f0103d25:	eb 03                	jmp    f0103d2a <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103d27:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103d2a:	39 d0                	cmp    %edx,%eax
f0103d2c:	7d 1c                	jge    f0103d4a <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103d2e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103d31:	40                   	inc    %eax
f0103d32:	80 3c 8d 10 68 10 f0 	cmpb   $0xa0,-0xfef97f0(,%ecx,4)
f0103d39:	a0 
f0103d3a:	74 eb                	je     f0103d27 <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103d3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d41:	eb 0c                	jmp    f0103d4f <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103d48:	eb 05                	jmp    f0103d4f <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103d4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d4f:	83 c4 4c             	add    $0x4c,%esp
f0103d52:	5b                   	pop    %ebx
f0103d53:	5e                   	pop    %esi
f0103d54:	5f                   	pop    %edi
f0103d55:	5d                   	pop    %ebp
f0103d56:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103d57:	6b f6 0c             	imul   $0xc,%esi,%esi
f0103d5a:	8b 86 0c 68 10 f0    	mov    -0xfef97f4(%esi),%eax
f0103d60:	ba 29 78 11 f0       	mov    $0xf0117829,%edx
f0103d65:	81 ea 0d e6 10 f0    	sub    $0xf010e60d,%edx
f0103d6b:	39 d0                	cmp    %edx,%eax
f0103d6d:	72 9d                	jb     f0103d0c <debuginfo_eip+0x1bc>
f0103d6f:	eb a2                	jmp    f0103d13 <debuginfo_eip+0x1c3>
f0103d71:	00 00                	add    %al,(%eax)
	...

f0103d74 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103d74:	55                   	push   %ebp
f0103d75:	89 e5                	mov    %esp,%ebp
f0103d77:	57                   	push   %edi
f0103d78:	56                   	push   %esi
f0103d79:	53                   	push   %ebx
f0103d7a:	83 ec 3c             	sub    $0x3c,%esp
f0103d7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103d80:	89 d7                	mov    %edx,%edi
f0103d82:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d85:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103d88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103d8e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103d91:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103d94:	85 c0                	test   %eax,%eax
f0103d96:	75 08                	jne    f0103da0 <printnum+0x2c>
f0103d98:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103d9b:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103d9e:	77 57                	ja     f0103df7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103da0:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103da4:	4b                   	dec    %ebx
f0103da5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103da9:	8b 45 10             	mov    0x10(%ebp),%eax
f0103dac:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103db0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0103db4:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0103db8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103dbf:	00 
f0103dc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103dc3:	89 04 24             	mov    %eax,(%esp)
f0103dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dcd:	e8 1e 09 00 00       	call   f01046f0 <__udivdi3>
f0103dd2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103dd6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103dda:	89 04 24             	mov    %eax,(%esp)
f0103ddd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103de1:	89 fa                	mov    %edi,%edx
f0103de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103de6:	e8 89 ff ff ff       	call   f0103d74 <printnum>
f0103deb:	eb 0f                	jmp    f0103dfc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103ded:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103df1:	89 34 24             	mov    %esi,(%esp)
f0103df4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103df7:	4b                   	dec    %ebx
f0103df8:	85 db                	test   %ebx,%ebx
f0103dfa:	7f f1                	jg     f0103ded <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103dfc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e00:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103e04:	8b 45 10             	mov    0x10(%ebp),%eax
f0103e07:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e0b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103e12:	00 
f0103e13:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103e16:	89 04 24             	mov    %eax,(%esp)
f0103e19:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e20:	e8 eb 09 00 00       	call   f0104810 <__umoddi3>
f0103e25:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e29:	0f be 80 0a 66 10 f0 	movsbl -0xfef99f6(%eax),%eax
f0103e30:	89 04 24             	mov    %eax,(%esp)
f0103e33:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0103e36:	83 c4 3c             	add    $0x3c,%esp
f0103e39:	5b                   	pop    %ebx
f0103e3a:	5e                   	pop    %esi
f0103e3b:	5f                   	pop    %edi
f0103e3c:	5d                   	pop    %ebp
f0103e3d:	c3                   	ret    

f0103e3e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103e3e:	55                   	push   %ebp
f0103e3f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103e41:	83 fa 01             	cmp    $0x1,%edx
f0103e44:	7e 0e                	jle    f0103e54 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103e46:	8b 10                	mov    (%eax),%edx
f0103e48:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103e4b:	89 08                	mov    %ecx,(%eax)
f0103e4d:	8b 02                	mov    (%edx),%eax
f0103e4f:	8b 52 04             	mov    0x4(%edx),%edx
f0103e52:	eb 22                	jmp    f0103e76 <getuint+0x38>
	else if (lflag)
f0103e54:	85 d2                	test   %edx,%edx
f0103e56:	74 10                	je     f0103e68 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103e58:	8b 10                	mov    (%eax),%edx
f0103e5a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103e5d:	89 08                	mov    %ecx,(%eax)
f0103e5f:	8b 02                	mov    (%edx),%eax
f0103e61:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e66:	eb 0e                	jmp    f0103e76 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103e68:	8b 10                	mov    (%eax),%edx
f0103e6a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103e6d:	89 08                	mov    %ecx,(%eax)
f0103e6f:	8b 02                	mov    (%edx),%eax
f0103e71:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103e76:	5d                   	pop    %ebp
f0103e77:	c3                   	ret    

f0103e78 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103e78:	55                   	push   %ebp
f0103e79:	89 e5                	mov    %esp,%ebp
f0103e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103e7e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103e81:	8b 10                	mov    (%eax),%edx
f0103e83:	3b 50 04             	cmp    0x4(%eax),%edx
f0103e86:	73 08                	jae    f0103e90 <sprintputch+0x18>
		*b->buf++ = ch;
f0103e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e8b:	88 0a                	mov    %cl,(%edx)
f0103e8d:	42                   	inc    %edx
f0103e8e:	89 10                	mov    %edx,(%eax)
}
f0103e90:	5d                   	pop    %ebp
f0103e91:	c3                   	ret    

f0103e92 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103e92:	55                   	push   %ebp
f0103e93:	89 e5                	mov    %esp,%ebp
f0103e95:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103e98:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103e9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e9f:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ea2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ead:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eb0:	89 04 24             	mov    %eax,(%esp)
f0103eb3:	e8 02 00 00 00       	call   f0103eba <vprintfmt>
	va_end(ap);
}
f0103eb8:	c9                   	leave  
f0103eb9:	c3                   	ret    

f0103eba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103eba:	55                   	push   %ebp
f0103ebb:	89 e5                	mov    %esp,%ebp
f0103ebd:	57                   	push   %edi
f0103ebe:	56                   	push   %esi
f0103ebf:	53                   	push   %ebx
f0103ec0:	83 ec 4c             	sub    $0x4c,%esp
f0103ec3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ec6:	8b 75 10             	mov    0x10(%ebp),%esi
f0103ec9:	eb 12                	jmp    f0103edd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103ecb:	85 c0                	test   %eax,%eax
f0103ecd:	0f 84 6b 03 00 00    	je     f010423e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0103ed3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ed7:	89 04 24             	mov    %eax,(%esp)
f0103eda:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103edd:	0f b6 06             	movzbl (%esi),%eax
f0103ee0:	46                   	inc    %esi
f0103ee1:	83 f8 25             	cmp    $0x25,%eax
f0103ee4:	75 e5                	jne    f0103ecb <vprintfmt+0x11>
f0103ee6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0103eea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103ef1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103ef6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103efd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103f02:	eb 26                	jmp    f0103f2a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f04:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103f07:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0103f0b:	eb 1d                	jmp    f0103f2a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f0d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103f10:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103f14:	eb 14                	jmp    f0103f2a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f16:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103f19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103f20:	eb 08                	jmp    f0103f2a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103f22:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103f25:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f2a:	0f b6 06             	movzbl (%esi),%eax
f0103f2d:	8d 56 01             	lea    0x1(%esi),%edx
f0103f30:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103f33:	8a 16                	mov    (%esi),%dl
f0103f35:	83 ea 23             	sub    $0x23,%edx
f0103f38:	80 fa 55             	cmp    $0x55,%dl
f0103f3b:	0f 87 e1 02 00 00    	ja     f0104222 <vprintfmt+0x368>
f0103f41:	0f b6 d2             	movzbl %dl,%edx
f0103f44:	ff 24 95 88 66 10 f0 	jmp    *-0xfef9978(,%edx,4)
f0103f4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103f4e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103f53:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0103f56:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103f5a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103f5d:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103f60:	83 fa 09             	cmp    $0x9,%edx
f0103f63:	77 2a                	ja     f0103f8f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103f65:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103f66:	eb eb                	jmp    f0103f53 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103f68:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f6b:	8d 50 04             	lea    0x4(%eax),%edx
f0103f6e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f71:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f73:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103f76:	eb 17                	jmp    f0103f8f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0103f78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f7c:	78 98                	js     f0103f16 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f7e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103f81:	eb a7                	jmp    f0103f2a <vprintfmt+0x70>
f0103f83:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103f86:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103f8d:	eb 9b                	jmp    f0103f2a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0103f8f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f93:	79 95                	jns    f0103f2a <vprintfmt+0x70>
f0103f95:	eb 8b                	jmp    f0103f22 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103f97:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f98:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103f9b:	eb 8d                	jmp    f0103f2a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103f9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fa0:	8d 50 04             	lea    0x4(%eax),%edx
f0103fa3:	89 55 14             	mov    %edx,0x14(%ebp)
f0103fa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103faa:	8b 00                	mov    (%eax),%eax
f0103fac:	89 04 24             	mov    %eax,(%esp)
f0103faf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103fb2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103fb5:	e9 23 ff ff ff       	jmp    f0103edd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103fba:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fbd:	8d 50 04             	lea    0x4(%eax),%edx
f0103fc0:	89 55 14             	mov    %edx,0x14(%ebp)
f0103fc3:	8b 00                	mov    (%eax),%eax
f0103fc5:	85 c0                	test   %eax,%eax
f0103fc7:	79 02                	jns    f0103fcb <vprintfmt+0x111>
f0103fc9:	f7 d8                	neg    %eax
f0103fcb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103fcd:	83 f8 06             	cmp    $0x6,%eax
f0103fd0:	7f 0b                	jg     f0103fdd <vprintfmt+0x123>
f0103fd2:	8b 04 85 e0 67 10 f0 	mov    -0xfef9820(,%eax,4),%eax
f0103fd9:	85 c0                	test   %eax,%eax
f0103fdb:	75 23                	jne    f0104000 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0103fdd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103fe1:	c7 44 24 08 22 66 10 	movl   $0xf0106622,0x8(%esp)
f0103fe8:	f0 
f0103fe9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fed:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ff0:	89 04 24             	mov    %eax,(%esp)
f0103ff3:	e8 9a fe ff ff       	call   f0103e92 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ff8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103ffb:	e9 dd fe ff ff       	jmp    f0103edd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0104000:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104004:	c7 44 24 08 0a 63 10 	movl   $0xf010630a,0x8(%esp)
f010400b:	f0 
f010400c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104010:	8b 55 08             	mov    0x8(%ebp),%edx
f0104013:	89 14 24             	mov    %edx,(%esp)
f0104016:	e8 77 fe ff ff       	call   f0103e92 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010401b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010401e:	e9 ba fe ff ff       	jmp    f0103edd <vprintfmt+0x23>
f0104023:	89 f9                	mov    %edi,%ecx
f0104025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104028:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010402b:	8b 45 14             	mov    0x14(%ebp),%eax
f010402e:	8d 50 04             	lea    0x4(%eax),%edx
f0104031:	89 55 14             	mov    %edx,0x14(%ebp)
f0104034:	8b 30                	mov    (%eax),%esi
f0104036:	85 f6                	test   %esi,%esi
f0104038:	75 05                	jne    f010403f <vprintfmt+0x185>
				p = "(null)";
f010403a:	be 1b 66 10 f0       	mov    $0xf010661b,%esi
			if (width > 0 && padc != '-')
f010403f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104043:	0f 8e 84 00 00 00    	jle    f01040cd <vprintfmt+0x213>
f0104049:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010404d:	74 7e                	je     f01040cd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f010404f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104053:	89 34 24             	mov    %esi,(%esp)
f0104056:	e8 53 03 00 00       	call   f01043ae <strnlen>
f010405b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010405e:	29 c2                	sub    %eax,%edx
f0104060:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0104063:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0104067:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010406a:	89 7d cc             	mov    %edi,-0x34(%ebp)
f010406d:	89 de                	mov    %ebx,%esi
f010406f:	89 d3                	mov    %edx,%ebx
f0104071:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104073:	eb 0b                	jmp    f0104080 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0104075:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104079:	89 3c 24             	mov    %edi,(%esp)
f010407c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010407f:	4b                   	dec    %ebx
f0104080:	85 db                	test   %ebx,%ebx
f0104082:	7f f1                	jg     f0104075 <vprintfmt+0x1bb>
f0104084:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104087:	89 f3                	mov    %esi,%ebx
f0104089:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f010408c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010408f:	85 c0                	test   %eax,%eax
f0104091:	79 05                	jns    f0104098 <vprintfmt+0x1de>
f0104093:	b8 00 00 00 00       	mov    $0x0,%eax
f0104098:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010409b:	29 c2                	sub    %eax,%edx
f010409d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01040a0:	eb 2b                	jmp    f01040cd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01040a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01040a6:	74 18                	je     f01040c0 <vprintfmt+0x206>
f01040a8:	8d 50 e0             	lea    -0x20(%eax),%edx
f01040ab:	83 fa 5e             	cmp    $0x5e,%edx
f01040ae:	76 10                	jbe    f01040c0 <vprintfmt+0x206>
					putch('?', putdat);
f01040b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01040b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01040bb:	ff 55 08             	call   *0x8(%ebp)
f01040be:	eb 0a                	jmp    f01040ca <vprintfmt+0x210>
				else
					putch(ch, putdat);
f01040c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01040c4:	89 04 24             	mov    %eax,(%esp)
f01040c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01040ca:	ff 4d e4             	decl   -0x1c(%ebp)
f01040cd:	0f be 06             	movsbl (%esi),%eax
f01040d0:	46                   	inc    %esi
f01040d1:	85 c0                	test   %eax,%eax
f01040d3:	74 21                	je     f01040f6 <vprintfmt+0x23c>
f01040d5:	85 ff                	test   %edi,%edi
f01040d7:	78 c9                	js     f01040a2 <vprintfmt+0x1e8>
f01040d9:	4f                   	dec    %edi
f01040da:	79 c6                	jns    f01040a2 <vprintfmt+0x1e8>
f01040dc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01040df:	89 de                	mov    %ebx,%esi
f01040e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01040e4:	eb 18                	jmp    f01040fe <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01040e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01040f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01040f3:	4b                   	dec    %ebx
f01040f4:	eb 08                	jmp    f01040fe <vprintfmt+0x244>
f01040f6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01040f9:	89 de                	mov    %ebx,%esi
f01040fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01040fe:	85 db                	test   %ebx,%ebx
f0104100:	7f e4                	jg     f01040e6 <vprintfmt+0x22c>
f0104102:	89 7d 08             	mov    %edi,0x8(%ebp)
f0104105:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104107:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010410a:	e9 ce fd ff ff       	jmp    f0103edd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010410f:	83 f9 01             	cmp    $0x1,%ecx
f0104112:	7e 10                	jle    f0104124 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0104114:	8b 45 14             	mov    0x14(%ebp),%eax
f0104117:	8d 50 08             	lea    0x8(%eax),%edx
f010411a:	89 55 14             	mov    %edx,0x14(%ebp)
f010411d:	8b 30                	mov    (%eax),%esi
f010411f:	8b 78 04             	mov    0x4(%eax),%edi
f0104122:	eb 26                	jmp    f010414a <vprintfmt+0x290>
	else if (lflag)
f0104124:	85 c9                	test   %ecx,%ecx
f0104126:	74 12                	je     f010413a <vprintfmt+0x280>
		return va_arg(*ap, long);
f0104128:	8b 45 14             	mov    0x14(%ebp),%eax
f010412b:	8d 50 04             	lea    0x4(%eax),%edx
f010412e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104131:	8b 30                	mov    (%eax),%esi
f0104133:	89 f7                	mov    %esi,%edi
f0104135:	c1 ff 1f             	sar    $0x1f,%edi
f0104138:	eb 10                	jmp    f010414a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010413a:	8b 45 14             	mov    0x14(%ebp),%eax
f010413d:	8d 50 04             	lea    0x4(%eax),%edx
f0104140:	89 55 14             	mov    %edx,0x14(%ebp)
f0104143:	8b 30                	mov    (%eax),%esi
f0104145:	89 f7                	mov    %esi,%edi
f0104147:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010414a:	85 ff                	test   %edi,%edi
f010414c:	78 0a                	js     f0104158 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010414e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104153:	e9 8c 00 00 00       	jmp    f01041e4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104158:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010415c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104163:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104166:	f7 de                	neg    %esi
f0104168:	83 d7 00             	adc    $0x0,%edi
f010416b:	f7 df                	neg    %edi
			}
			base = 10;
f010416d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104172:	eb 70                	jmp    f01041e4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104174:	89 ca                	mov    %ecx,%edx
f0104176:	8d 45 14             	lea    0x14(%ebp),%eax
f0104179:	e8 c0 fc ff ff       	call   f0103e3e <getuint>
f010417e:	89 c6                	mov    %eax,%esi
f0104180:	89 d7                	mov    %edx,%edi
			base = 10;
f0104182:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104187:	eb 5b                	jmp    f01041e4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0104189:	89 ca                	mov    %ecx,%edx
f010418b:	8d 45 14             	lea    0x14(%ebp),%eax
f010418e:	e8 ab fc ff ff       	call   f0103e3e <getuint>
f0104193:	89 c6                	mov    %eax,%esi
f0104195:	89 d7                	mov    %edx,%edi
			base = 8;
f0104197:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f010419c:	eb 46                	jmp    f01041e4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010419e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01041a9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01041ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041b0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01041b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01041ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01041bd:	8d 50 04             	lea    0x4(%eax),%edx
f01041c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01041c3:	8b 30                	mov    (%eax),%esi
f01041c5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01041ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01041cf:	eb 13                	jmp    f01041e4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01041d1:	89 ca                	mov    %ecx,%edx
f01041d3:	8d 45 14             	lea    0x14(%ebp),%eax
f01041d6:	e8 63 fc ff ff       	call   f0103e3e <getuint>
f01041db:	89 c6                	mov    %eax,%esi
f01041dd:	89 d7                	mov    %edx,%edi
			base = 16;
f01041df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01041e4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01041e8:	89 54 24 10          	mov    %edx,0x10(%esp)
f01041ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01041ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01041f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01041f7:	89 34 24             	mov    %esi,(%esp)
f01041fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01041fe:	89 da                	mov    %ebx,%edx
f0104200:	8b 45 08             	mov    0x8(%ebp),%eax
f0104203:	e8 6c fb ff ff       	call   f0103d74 <printnum>
			break;
f0104208:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010420b:	e9 cd fc ff ff       	jmp    f0103edd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104210:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104214:	89 04 24             	mov    %eax,(%esp)
f0104217:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010421a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010421d:	e9 bb fc ff ff       	jmp    f0103edd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104222:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104226:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010422d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104230:	eb 01                	jmp    f0104233 <vprintfmt+0x379>
f0104232:	4e                   	dec    %esi
f0104233:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104237:	75 f9                	jne    f0104232 <vprintfmt+0x378>
f0104239:	e9 9f fc ff ff       	jmp    f0103edd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f010423e:	83 c4 4c             	add    $0x4c,%esp
f0104241:	5b                   	pop    %ebx
f0104242:	5e                   	pop    %esi
f0104243:	5f                   	pop    %edi
f0104244:	5d                   	pop    %ebp
f0104245:	c3                   	ret    

f0104246 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104246:	55                   	push   %ebp
f0104247:	89 e5                	mov    %esp,%ebp
f0104249:	83 ec 28             	sub    $0x28,%esp
f010424c:	8b 45 08             	mov    0x8(%ebp),%eax
f010424f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104252:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104255:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104259:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010425c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104263:	85 c0                	test   %eax,%eax
f0104265:	74 30                	je     f0104297 <vsnprintf+0x51>
f0104267:	85 d2                	test   %edx,%edx
f0104269:	7e 33                	jle    f010429e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010426b:	8b 45 14             	mov    0x14(%ebp),%eax
f010426e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104272:	8b 45 10             	mov    0x10(%ebp),%eax
f0104275:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104279:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010427c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104280:	c7 04 24 78 3e 10 f0 	movl   $0xf0103e78,(%esp)
f0104287:	e8 2e fc ff ff       	call   f0103eba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010428c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010428f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104292:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104295:	eb 0c                	jmp    f01042a3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010429c:	eb 05                	jmp    f01042a3 <vsnprintf+0x5d>
f010429e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01042a3:	c9                   	leave  
f01042a4:	c3                   	ret    

f01042a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01042a5:	55                   	push   %ebp
f01042a6:	89 e5                	mov    %esp,%ebp
f01042a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01042ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01042ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042b2:	8b 45 10             	mov    0x10(%ebp),%eax
f01042b5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01042c3:	89 04 24             	mov    %eax,(%esp)
f01042c6:	e8 7b ff ff ff       	call   f0104246 <vsnprintf>
	va_end(ap);

	return rc;
}
f01042cb:	c9                   	leave  
f01042cc:	c3                   	ret    
f01042cd:	00 00                	add    %al,(%eax)
	...

f01042d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01042d0:	55                   	push   %ebp
f01042d1:	89 e5                	mov    %esp,%ebp
f01042d3:	57                   	push   %edi
f01042d4:	56                   	push   %esi
f01042d5:	53                   	push   %ebx
f01042d6:	83 ec 1c             	sub    $0x1c,%esp
f01042d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01042dc:	85 c0                	test   %eax,%eax
f01042de:	74 10                	je     f01042f0 <readline+0x20>
		cprintf("%s", prompt);
f01042e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042e4:	c7 04 24 0a 63 10 f0 	movl   $0xf010630a,(%esp)
f01042eb:	e8 66 f7 ff ff       	call   f0103a56 <cprintf>

	i = 0;
	echoing = iscons(0);
f01042f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01042f7:	e8 c8 c5 ff ff       	call   f01008c4 <iscons>
f01042fc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01042fe:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104303:	e8 ab c5 ff ff       	call   f01008b3 <getchar>
f0104308:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010430a:	85 c0                	test   %eax,%eax
f010430c:	79 17                	jns    f0104325 <readline+0x55>
			cprintf("read error: %e\n", c);
f010430e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104312:	c7 04 24 fc 67 10 f0 	movl   $0xf01067fc,(%esp)
f0104319:	e8 38 f7 ff ff       	call   f0103a56 <cprintf>
			return NULL;
f010431e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104323:	eb 69                	jmp    f010438e <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104325:	83 f8 08             	cmp    $0x8,%eax
f0104328:	74 05                	je     f010432f <readline+0x5f>
f010432a:	83 f8 7f             	cmp    $0x7f,%eax
f010432d:	75 17                	jne    f0104346 <readline+0x76>
f010432f:	85 f6                	test   %esi,%esi
f0104331:	7e 13                	jle    f0104346 <readline+0x76>
			if (echoing)
f0104333:	85 ff                	test   %edi,%edi
f0104335:	74 0c                	je     f0104343 <readline+0x73>
				cputchar('\b');
f0104337:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010433e:	e8 60 c5 ff ff       	call   f01008a3 <cputchar>
			i--;
f0104343:	4e                   	dec    %esi
f0104344:	eb bd                	jmp    f0104303 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104346:	83 fb 1f             	cmp    $0x1f,%ebx
f0104349:	7e 1d                	jle    f0104368 <readline+0x98>
f010434b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104351:	7f 15                	jg     f0104368 <readline+0x98>
			if (echoing)
f0104353:	85 ff                	test   %edi,%edi
f0104355:	74 08                	je     f010435f <readline+0x8f>
				cputchar(c);
f0104357:	89 1c 24             	mov    %ebx,(%esp)
f010435a:	e8 44 c5 ff ff       	call   f01008a3 <cputchar>
			buf[i++] = c;
f010435f:	88 9e 80 25 12 f0    	mov    %bl,-0xfedda80(%esi)
f0104365:	46                   	inc    %esi
f0104366:	eb 9b                	jmp    f0104303 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104368:	83 fb 0a             	cmp    $0xa,%ebx
f010436b:	74 05                	je     f0104372 <readline+0xa2>
f010436d:	83 fb 0d             	cmp    $0xd,%ebx
f0104370:	75 91                	jne    f0104303 <readline+0x33>
			if (echoing)
f0104372:	85 ff                	test   %edi,%edi
f0104374:	74 0c                	je     f0104382 <readline+0xb2>
				cputchar('\n');
f0104376:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010437d:	e8 21 c5 ff ff       	call   f01008a3 <cputchar>
			buf[i] = 0;
f0104382:	c6 86 80 25 12 f0 00 	movb   $0x0,-0xfedda80(%esi)
			return buf;
f0104389:	b8 80 25 12 f0       	mov    $0xf0122580,%eax
		}
	}
}
f010438e:	83 c4 1c             	add    $0x1c,%esp
f0104391:	5b                   	pop    %ebx
f0104392:	5e                   	pop    %esi
f0104393:	5f                   	pop    %edi
f0104394:	5d                   	pop    %ebp
f0104395:	c3                   	ret    
	...

f0104398 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104398:	55                   	push   %ebp
f0104399:	89 e5                	mov    %esp,%ebp
f010439b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010439e:	b8 00 00 00 00       	mov    $0x0,%eax
f01043a3:	eb 01                	jmp    f01043a6 <strlen+0xe>
		n++;
f01043a5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01043a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01043aa:	75 f9                	jne    f01043a5 <strlen+0xd>
		n++;
	return n;
}
f01043ac:	5d                   	pop    %ebp
f01043ad:	c3                   	ret    

f01043ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01043ae:	55                   	push   %ebp
f01043af:	89 e5                	mov    %esp,%ebp
f01043b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01043b4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01043bc:	eb 01                	jmp    f01043bf <strnlen+0x11>
		n++;
f01043be:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043bf:	39 d0                	cmp    %edx,%eax
f01043c1:	74 06                	je     f01043c9 <strnlen+0x1b>
f01043c3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01043c7:	75 f5                	jne    f01043be <strnlen+0x10>
		n++;
	return n;
}
f01043c9:	5d                   	pop    %ebp
f01043ca:	c3                   	ret    

f01043cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01043cb:	55                   	push   %ebp
f01043cc:	89 e5                	mov    %esp,%ebp
f01043ce:	53                   	push   %ebx
f01043cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01043d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01043d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01043da:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01043dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01043e0:	42                   	inc    %edx
f01043e1:	84 c9                	test   %cl,%cl
f01043e3:	75 f5                	jne    f01043da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01043e5:	5b                   	pop    %ebx
f01043e6:	5d                   	pop    %ebp
f01043e7:	c3                   	ret    

f01043e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01043e8:	55                   	push   %ebp
f01043e9:	89 e5                	mov    %esp,%ebp
f01043eb:	53                   	push   %ebx
f01043ec:	83 ec 08             	sub    $0x8,%esp
f01043ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01043f2:	89 1c 24             	mov    %ebx,(%esp)
f01043f5:	e8 9e ff ff ff       	call   f0104398 <strlen>
	strcpy(dst + len, src);
f01043fa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043fd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104401:	01 d8                	add    %ebx,%eax
f0104403:	89 04 24             	mov    %eax,(%esp)
f0104406:	e8 c0 ff ff ff       	call   f01043cb <strcpy>
	return dst;
}
f010440b:	89 d8                	mov    %ebx,%eax
f010440d:	83 c4 08             	add    $0x8,%esp
f0104410:	5b                   	pop    %ebx
f0104411:	5d                   	pop    %ebp
f0104412:	c3                   	ret    

f0104413 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104413:	55                   	push   %ebp
f0104414:	89 e5                	mov    %esp,%ebp
f0104416:	56                   	push   %esi
f0104417:	53                   	push   %ebx
f0104418:	8b 45 08             	mov    0x8(%ebp),%eax
f010441b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010441e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104421:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104426:	eb 0c                	jmp    f0104434 <strncpy+0x21>
		*dst++ = *src;
f0104428:	8a 1a                	mov    (%edx),%bl
f010442a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010442d:	80 3a 01             	cmpb   $0x1,(%edx)
f0104430:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104433:	41                   	inc    %ecx
f0104434:	39 f1                	cmp    %esi,%ecx
f0104436:	75 f0                	jne    f0104428 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104438:	5b                   	pop    %ebx
f0104439:	5e                   	pop    %esi
f010443a:	5d                   	pop    %ebp
f010443b:	c3                   	ret    

f010443c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010443c:	55                   	push   %ebp
f010443d:	89 e5                	mov    %esp,%ebp
f010443f:	56                   	push   %esi
f0104440:	53                   	push   %ebx
f0104441:	8b 75 08             	mov    0x8(%ebp),%esi
f0104444:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104447:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010444a:	85 d2                	test   %edx,%edx
f010444c:	75 0a                	jne    f0104458 <strlcpy+0x1c>
f010444e:	89 f0                	mov    %esi,%eax
f0104450:	eb 1a                	jmp    f010446c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104452:	88 18                	mov    %bl,(%eax)
f0104454:	40                   	inc    %eax
f0104455:	41                   	inc    %ecx
f0104456:	eb 02                	jmp    f010445a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104458:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010445a:	4a                   	dec    %edx
f010445b:	74 0a                	je     f0104467 <strlcpy+0x2b>
f010445d:	8a 19                	mov    (%ecx),%bl
f010445f:	84 db                	test   %bl,%bl
f0104461:	75 ef                	jne    f0104452 <strlcpy+0x16>
f0104463:	89 c2                	mov    %eax,%edx
f0104465:	eb 02                	jmp    f0104469 <strlcpy+0x2d>
f0104467:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104469:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f010446c:	29 f0                	sub    %esi,%eax
}
f010446e:	5b                   	pop    %ebx
f010446f:	5e                   	pop    %esi
f0104470:	5d                   	pop    %ebp
f0104471:	c3                   	ret    

f0104472 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104472:	55                   	push   %ebp
f0104473:	89 e5                	mov    %esp,%ebp
f0104475:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104478:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010447b:	eb 02                	jmp    f010447f <strcmp+0xd>
		p++, q++;
f010447d:	41                   	inc    %ecx
f010447e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010447f:	8a 01                	mov    (%ecx),%al
f0104481:	84 c0                	test   %al,%al
f0104483:	74 04                	je     f0104489 <strcmp+0x17>
f0104485:	3a 02                	cmp    (%edx),%al
f0104487:	74 f4                	je     f010447d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104489:	0f b6 c0             	movzbl %al,%eax
f010448c:	0f b6 12             	movzbl (%edx),%edx
f010448f:	29 d0                	sub    %edx,%eax
}
f0104491:	5d                   	pop    %ebp
f0104492:	c3                   	ret    

f0104493 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104493:	55                   	push   %ebp
f0104494:	89 e5                	mov    %esp,%ebp
f0104496:	53                   	push   %ebx
f0104497:	8b 45 08             	mov    0x8(%ebp),%eax
f010449a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010449d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01044a0:	eb 03                	jmp    f01044a5 <strncmp+0x12>
		n--, p++, q++;
f01044a2:	4a                   	dec    %edx
f01044a3:	40                   	inc    %eax
f01044a4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01044a5:	85 d2                	test   %edx,%edx
f01044a7:	74 14                	je     f01044bd <strncmp+0x2a>
f01044a9:	8a 18                	mov    (%eax),%bl
f01044ab:	84 db                	test   %bl,%bl
f01044ad:	74 04                	je     f01044b3 <strncmp+0x20>
f01044af:	3a 19                	cmp    (%ecx),%bl
f01044b1:	74 ef                	je     f01044a2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01044b3:	0f b6 00             	movzbl (%eax),%eax
f01044b6:	0f b6 11             	movzbl (%ecx),%edx
f01044b9:	29 d0                	sub    %edx,%eax
f01044bb:	eb 05                	jmp    f01044c2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01044bd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01044c2:	5b                   	pop    %ebx
f01044c3:	5d                   	pop    %ebp
f01044c4:	c3                   	ret    

f01044c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01044c5:	55                   	push   %ebp
f01044c6:	89 e5                	mov    %esp,%ebp
f01044c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01044cb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01044ce:	eb 05                	jmp    f01044d5 <strchr+0x10>
		if (*s == c)
f01044d0:	38 ca                	cmp    %cl,%dl
f01044d2:	74 0c                	je     f01044e0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01044d4:	40                   	inc    %eax
f01044d5:	8a 10                	mov    (%eax),%dl
f01044d7:	84 d2                	test   %dl,%dl
f01044d9:	75 f5                	jne    f01044d0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01044db:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01044e0:	5d                   	pop    %ebp
f01044e1:	c3                   	ret    

f01044e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01044e2:	55                   	push   %ebp
f01044e3:	89 e5                	mov    %esp,%ebp
f01044e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01044eb:	eb 05                	jmp    f01044f2 <strfind+0x10>
		if (*s == c)
f01044ed:	38 ca                	cmp    %cl,%dl
f01044ef:	74 07                	je     f01044f8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01044f1:	40                   	inc    %eax
f01044f2:	8a 10                	mov    (%eax),%dl
f01044f4:	84 d2                	test   %dl,%dl
f01044f6:	75 f5                	jne    f01044ed <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01044f8:	5d                   	pop    %ebp
f01044f9:	c3                   	ret    

f01044fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01044fa:	55                   	push   %ebp
f01044fb:	89 e5                	mov    %esp,%ebp
f01044fd:	57                   	push   %edi
f01044fe:	56                   	push   %esi
f01044ff:	53                   	push   %ebx
f0104500:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104503:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104506:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104509:	85 c9                	test   %ecx,%ecx
f010450b:	74 30                	je     f010453d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010450d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104513:	75 25                	jne    f010453a <memset+0x40>
f0104515:	f6 c1 03             	test   $0x3,%cl
f0104518:	75 20                	jne    f010453a <memset+0x40>
		c &= 0xFF;
f010451a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010451d:	89 d3                	mov    %edx,%ebx
f010451f:	c1 e3 08             	shl    $0x8,%ebx
f0104522:	89 d6                	mov    %edx,%esi
f0104524:	c1 e6 18             	shl    $0x18,%esi
f0104527:	89 d0                	mov    %edx,%eax
f0104529:	c1 e0 10             	shl    $0x10,%eax
f010452c:	09 f0                	or     %esi,%eax
f010452e:	09 d0                	or     %edx,%eax
f0104530:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104532:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104535:	fc                   	cld    
f0104536:	f3 ab                	rep stos %eax,%es:(%edi)
f0104538:	eb 03                	jmp    f010453d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010453a:	fc                   	cld    
f010453b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010453d:	89 f8                	mov    %edi,%eax
f010453f:	5b                   	pop    %ebx
f0104540:	5e                   	pop    %esi
f0104541:	5f                   	pop    %edi
f0104542:	5d                   	pop    %ebp
f0104543:	c3                   	ret    

f0104544 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104544:	55                   	push   %ebp
f0104545:	89 e5                	mov    %esp,%ebp
f0104547:	57                   	push   %edi
f0104548:	56                   	push   %esi
f0104549:	8b 45 08             	mov    0x8(%ebp),%eax
f010454c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010454f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104552:	39 c6                	cmp    %eax,%esi
f0104554:	73 34                	jae    f010458a <memmove+0x46>
f0104556:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104559:	39 d0                	cmp    %edx,%eax
f010455b:	73 2d                	jae    f010458a <memmove+0x46>
		s += n;
		d += n;
f010455d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104560:	f6 c2 03             	test   $0x3,%dl
f0104563:	75 1b                	jne    f0104580 <memmove+0x3c>
f0104565:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010456b:	75 13                	jne    f0104580 <memmove+0x3c>
f010456d:	f6 c1 03             	test   $0x3,%cl
f0104570:	75 0e                	jne    f0104580 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104572:	83 ef 04             	sub    $0x4,%edi
f0104575:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104578:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010457b:	fd                   	std    
f010457c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010457e:	eb 07                	jmp    f0104587 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104580:	4f                   	dec    %edi
f0104581:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104584:	fd                   	std    
f0104585:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104587:	fc                   	cld    
f0104588:	eb 20                	jmp    f01045aa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010458a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104590:	75 13                	jne    f01045a5 <memmove+0x61>
f0104592:	a8 03                	test   $0x3,%al
f0104594:	75 0f                	jne    f01045a5 <memmove+0x61>
f0104596:	f6 c1 03             	test   $0x3,%cl
f0104599:	75 0a                	jne    f01045a5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010459b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010459e:	89 c7                	mov    %eax,%edi
f01045a0:	fc                   	cld    
f01045a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045a3:	eb 05                	jmp    f01045aa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01045a5:	89 c7                	mov    %eax,%edi
f01045a7:	fc                   	cld    
f01045a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01045aa:	5e                   	pop    %esi
f01045ab:	5f                   	pop    %edi
f01045ac:	5d                   	pop    %ebp
f01045ad:	c3                   	ret    

f01045ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01045ae:	55                   	push   %ebp
f01045af:	89 e5                	mov    %esp,%ebp
f01045b1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01045b4:	8b 45 10             	mov    0x10(%ebp),%eax
f01045b7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c5:	89 04 24             	mov    %eax,(%esp)
f01045c8:	e8 77 ff ff ff       	call   f0104544 <memmove>
}
f01045cd:	c9                   	leave  
f01045ce:	c3                   	ret    

f01045cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01045cf:	55                   	push   %ebp
f01045d0:	89 e5                	mov    %esp,%ebp
f01045d2:	57                   	push   %edi
f01045d3:	56                   	push   %esi
f01045d4:	53                   	push   %ebx
f01045d5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01045d8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01045db:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01045de:	ba 00 00 00 00       	mov    $0x0,%edx
f01045e3:	eb 16                	jmp    f01045fb <memcmp+0x2c>
		if (*s1 != *s2)
f01045e5:	8a 04 17             	mov    (%edi,%edx,1),%al
f01045e8:	42                   	inc    %edx
f01045e9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01045ed:	38 c8                	cmp    %cl,%al
f01045ef:	74 0a                	je     f01045fb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01045f1:	0f b6 c0             	movzbl %al,%eax
f01045f4:	0f b6 c9             	movzbl %cl,%ecx
f01045f7:	29 c8                	sub    %ecx,%eax
f01045f9:	eb 09                	jmp    f0104604 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01045fb:	39 da                	cmp    %ebx,%edx
f01045fd:	75 e6                	jne    f01045e5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01045ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104604:	5b                   	pop    %ebx
f0104605:	5e                   	pop    %esi
f0104606:	5f                   	pop    %edi
f0104607:	5d                   	pop    %ebp
f0104608:	c3                   	ret    

f0104609 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104609:	55                   	push   %ebp
f010460a:	89 e5                	mov    %esp,%ebp
f010460c:	8b 45 08             	mov    0x8(%ebp),%eax
f010460f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104612:	89 c2                	mov    %eax,%edx
f0104614:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104617:	eb 05                	jmp    f010461e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104619:	38 08                	cmp    %cl,(%eax)
f010461b:	74 05                	je     f0104622 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010461d:	40                   	inc    %eax
f010461e:	39 d0                	cmp    %edx,%eax
f0104620:	72 f7                	jb     f0104619 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104622:	5d                   	pop    %ebp
f0104623:	c3                   	ret    

f0104624 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104624:	55                   	push   %ebp
f0104625:	89 e5                	mov    %esp,%ebp
f0104627:	57                   	push   %edi
f0104628:	56                   	push   %esi
f0104629:	53                   	push   %ebx
f010462a:	8b 55 08             	mov    0x8(%ebp),%edx
f010462d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104630:	eb 01                	jmp    f0104633 <strtol+0xf>
		s++;
f0104632:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104633:	8a 02                	mov    (%edx),%al
f0104635:	3c 20                	cmp    $0x20,%al
f0104637:	74 f9                	je     f0104632 <strtol+0xe>
f0104639:	3c 09                	cmp    $0x9,%al
f010463b:	74 f5                	je     f0104632 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010463d:	3c 2b                	cmp    $0x2b,%al
f010463f:	75 08                	jne    f0104649 <strtol+0x25>
		s++;
f0104641:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104642:	bf 00 00 00 00       	mov    $0x0,%edi
f0104647:	eb 13                	jmp    f010465c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104649:	3c 2d                	cmp    $0x2d,%al
f010464b:	75 0a                	jne    f0104657 <strtol+0x33>
		s++, neg = 1;
f010464d:	8d 52 01             	lea    0x1(%edx),%edx
f0104650:	bf 01 00 00 00       	mov    $0x1,%edi
f0104655:	eb 05                	jmp    f010465c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104657:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010465c:	85 db                	test   %ebx,%ebx
f010465e:	74 05                	je     f0104665 <strtol+0x41>
f0104660:	83 fb 10             	cmp    $0x10,%ebx
f0104663:	75 28                	jne    f010468d <strtol+0x69>
f0104665:	8a 02                	mov    (%edx),%al
f0104667:	3c 30                	cmp    $0x30,%al
f0104669:	75 10                	jne    f010467b <strtol+0x57>
f010466b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010466f:	75 0a                	jne    f010467b <strtol+0x57>
		s += 2, base = 16;
f0104671:	83 c2 02             	add    $0x2,%edx
f0104674:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104679:	eb 12                	jmp    f010468d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010467b:	85 db                	test   %ebx,%ebx
f010467d:	75 0e                	jne    f010468d <strtol+0x69>
f010467f:	3c 30                	cmp    $0x30,%al
f0104681:	75 05                	jne    f0104688 <strtol+0x64>
		s++, base = 8;
f0104683:	42                   	inc    %edx
f0104684:	b3 08                	mov    $0x8,%bl
f0104686:	eb 05                	jmp    f010468d <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104688:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010468d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104692:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104694:	8a 0a                	mov    (%edx),%cl
f0104696:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104699:	80 fb 09             	cmp    $0x9,%bl
f010469c:	77 08                	ja     f01046a6 <strtol+0x82>
			dig = *s - '0';
f010469e:	0f be c9             	movsbl %cl,%ecx
f01046a1:	83 e9 30             	sub    $0x30,%ecx
f01046a4:	eb 1e                	jmp    f01046c4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01046a6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01046a9:	80 fb 19             	cmp    $0x19,%bl
f01046ac:	77 08                	ja     f01046b6 <strtol+0x92>
			dig = *s - 'a' + 10;
f01046ae:	0f be c9             	movsbl %cl,%ecx
f01046b1:	83 e9 57             	sub    $0x57,%ecx
f01046b4:	eb 0e                	jmp    f01046c4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01046b6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01046b9:	80 fb 19             	cmp    $0x19,%bl
f01046bc:	77 12                	ja     f01046d0 <strtol+0xac>
			dig = *s - 'A' + 10;
f01046be:	0f be c9             	movsbl %cl,%ecx
f01046c1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01046c4:	39 f1                	cmp    %esi,%ecx
f01046c6:	7d 0c                	jge    f01046d4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01046c8:	42                   	inc    %edx
f01046c9:	0f af c6             	imul   %esi,%eax
f01046cc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01046ce:	eb c4                	jmp    f0104694 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01046d0:	89 c1                	mov    %eax,%ecx
f01046d2:	eb 02                	jmp    f01046d6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01046d4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01046d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01046da:	74 05                	je     f01046e1 <strtol+0xbd>
		*endptr = (char *) s;
f01046dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046df:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01046e1:	85 ff                	test   %edi,%edi
f01046e3:	74 04                	je     f01046e9 <strtol+0xc5>
f01046e5:	89 c8                	mov    %ecx,%eax
f01046e7:	f7 d8                	neg    %eax
}
f01046e9:	5b                   	pop    %ebx
f01046ea:	5e                   	pop    %esi
f01046eb:	5f                   	pop    %edi
f01046ec:	5d                   	pop    %ebp
f01046ed:	c3                   	ret    
	...

f01046f0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01046f0:	55                   	push   %ebp
f01046f1:	57                   	push   %edi
f01046f2:	56                   	push   %esi
f01046f3:	83 ec 10             	sub    $0x10,%esp
f01046f6:	8b 74 24 20          	mov    0x20(%esp),%esi
f01046fa:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01046fe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104702:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0104706:	89 cd                	mov    %ecx,%ebp
f0104708:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010470c:	85 c0                	test   %eax,%eax
f010470e:	75 2c                	jne    f010473c <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0104710:	39 f9                	cmp    %edi,%ecx
f0104712:	77 68                	ja     f010477c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104714:	85 c9                	test   %ecx,%ecx
f0104716:	75 0b                	jne    f0104723 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104718:	b8 01 00 00 00       	mov    $0x1,%eax
f010471d:	31 d2                	xor    %edx,%edx
f010471f:	f7 f1                	div    %ecx
f0104721:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104723:	31 d2                	xor    %edx,%edx
f0104725:	89 f8                	mov    %edi,%eax
f0104727:	f7 f1                	div    %ecx
f0104729:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010472b:	89 f0                	mov    %esi,%eax
f010472d:	f7 f1                	div    %ecx
f010472f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104731:	89 f0                	mov    %esi,%eax
f0104733:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104735:	83 c4 10             	add    $0x10,%esp
f0104738:	5e                   	pop    %esi
f0104739:	5f                   	pop    %edi
f010473a:	5d                   	pop    %ebp
f010473b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010473c:	39 f8                	cmp    %edi,%eax
f010473e:	77 2c                	ja     f010476c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104740:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0104743:	83 f6 1f             	xor    $0x1f,%esi
f0104746:	75 4c                	jne    f0104794 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104748:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010474a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010474f:	72 0a                	jb     f010475b <__udivdi3+0x6b>
f0104751:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0104755:	0f 87 ad 00 00 00    	ja     f0104808 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010475b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104760:	89 f0                	mov    %esi,%eax
f0104762:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104764:	83 c4 10             	add    $0x10,%esp
f0104767:	5e                   	pop    %esi
f0104768:	5f                   	pop    %edi
f0104769:	5d                   	pop    %ebp
f010476a:	c3                   	ret    
f010476b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010476c:	31 ff                	xor    %edi,%edi
f010476e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104770:	89 f0                	mov    %esi,%eax
f0104772:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104774:	83 c4 10             	add    $0x10,%esp
f0104777:	5e                   	pop    %esi
f0104778:	5f                   	pop    %edi
f0104779:	5d                   	pop    %ebp
f010477a:	c3                   	ret    
f010477b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010477c:	89 fa                	mov    %edi,%edx
f010477e:	89 f0                	mov    %esi,%eax
f0104780:	f7 f1                	div    %ecx
f0104782:	89 c6                	mov    %eax,%esi
f0104784:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104786:	89 f0                	mov    %esi,%eax
f0104788:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010478a:	83 c4 10             	add    $0x10,%esp
f010478d:	5e                   	pop    %esi
f010478e:	5f                   	pop    %edi
f010478f:	5d                   	pop    %ebp
f0104790:	c3                   	ret    
f0104791:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104794:	89 f1                	mov    %esi,%ecx
f0104796:	d3 e0                	shl    %cl,%eax
f0104798:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010479c:	b8 20 00 00 00       	mov    $0x20,%eax
f01047a1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01047a3:	89 ea                	mov    %ebp,%edx
f01047a5:	88 c1                	mov    %al,%cl
f01047a7:	d3 ea                	shr    %cl,%edx
f01047a9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f01047ad:	09 ca                	or     %ecx,%edx
f01047af:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f01047b3:	89 f1                	mov    %esi,%ecx
f01047b5:	d3 e5                	shl    %cl,%ebp
f01047b7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f01047bb:	89 fd                	mov    %edi,%ebp
f01047bd:	88 c1                	mov    %al,%cl
f01047bf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f01047c1:	89 fa                	mov    %edi,%edx
f01047c3:	89 f1                	mov    %esi,%ecx
f01047c5:	d3 e2                	shl    %cl,%edx
f01047c7:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01047cb:	88 c1                	mov    %al,%cl
f01047cd:	d3 ef                	shr    %cl,%edi
f01047cf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01047d1:	89 f8                	mov    %edi,%eax
f01047d3:	89 ea                	mov    %ebp,%edx
f01047d5:	f7 74 24 08          	divl   0x8(%esp)
f01047d9:	89 d1                	mov    %edx,%ecx
f01047db:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01047dd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01047e1:	39 d1                	cmp    %edx,%ecx
f01047e3:	72 17                	jb     f01047fc <__udivdi3+0x10c>
f01047e5:	74 09                	je     f01047f0 <__udivdi3+0x100>
f01047e7:	89 fe                	mov    %edi,%esi
f01047e9:	31 ff                	xor    %edi,%edi
f01047eb:	e9 41 ff ff ff       	jmp    f0104731 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01047f0:	8b 54 24 04          	mov    0x4(%esp),%edx
f01047f4:	89 f1                	mov    %esi,%ecx
f01047f6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01047f8:	39 c2                	cmp    %eax,%edx
f01047fa:	73 eb                	jae    f01047e7 <__udivdi3+0xf7>
		{
		  q0--;
f01047fc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01047ff:	31 ff                	xor    %edi,%edi
f0104801:	e9 2b ff ff ff       	jmp    f0104731 <__udivdi3+0x41>
f0104806:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104808:	31 f6                	xor    %esi,%esi
f010480a:	e9 22 ff ff ff       	jmp    f0104731 <__udivdi3+0x41>
	...

f0104810 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104810:	55                   	push   %ebp
f0104811:	57                   	push   %edi
f0104812:	56                   	push   %esi
f0104813:	83 ec 20             	sub    $0x20,%esp
f0104816:	8b 44 24 30          	mov    0x30(%esp),%eax
f010481a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010481e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104822:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0104826:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010482a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f010482e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0104830:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104832:	85 ed                	test   %ebp,%ebp
f0104834:	75 16                	jne    f010484c <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0104836:	39 f1                	cmp    %esi,%ecx
f0104838:	0f 86 a6 00 00 00    	jbe    f01048e4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010483e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0104840:	89 d0                	mov    %edx,%eax
f0104842:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104844:	83 c4 20             	add    $0x20,%esp
f0104847:	5e                   	pop    %esi
f0104848:	5f                   	pop    %edi
f0104849:	5d                   	pop    %ebp
f010484a:	c3                   	ret    
f010484b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010484c:	39 f5                	cmp    %esi,%ebp
f010484e:	0f 87 ac 00 00 00    	ja     f0104900 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104854:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0104857:	83 f0 1f             	xor    $0x1f,%eax
f010485a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010485e:	0f 84 a8 00 00 00    	je     f010490c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104864:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104868:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010486a:	bf 20 00 00 00       	mov    $0x20,%edi
f010486f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0104873:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104877:	89 f9                	mov    %edi,%ecx
f0104879:	d3 e8                	shr    %cl,%eax
f010487b:	09 e8                	or     %ebp,%eax
f010487d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0104881:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104885:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104889:	d3 e0                	shl    %cl,%eax
f010488b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010488f:	89 f2                	mov    %esi,%edx
f0104891:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104893:	8b 44 24 14          	mov    0x14(%esp),%eax
f0104897:	d3 e0                	shl    %cl,%eax
f0104899:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010489d:	8b 44 24 14          	mov    0x14(%esp),%eax
f01048a1:	89 f9                	mov    %edi,%ecx
f01048a3:	d3 e8                	shr    %cl,%eax
f01048a5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f01048a7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01048a9:	89 f2                	mov    %esi,%edx
f01048ab:	f7 74 24 18          	divl   0x18(%esp)
f01048af:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01048b1:	f7 64 24 0c          	mull   0xc(%esp)
f01048b5:	89 c5                	mov    %eax,%ebp
f01048b7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01048b9:	39 d6                	cmp    %edx,%esi
f01048bb:	72 67                	jb     f0104924 <__umoddi3+0x114>
f01048bd:	74 75                	je     f0104934 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01048bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01048c3:	29 e8                	sub    %ebp,%eax
f01048c5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01048c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01048cb:	d3 e8                	shr    %cl,%eax
f01048cd:	89 f2                	mov    %esi,%edx
f01048cf:	89 f9                	mov    %edi,%ecx
f01048d1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01048d3:	09 d0                	or     %edx,%eax
f01048d5:	89 f2                	mov    %esi,%edx
f01048d7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01048db:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01048dd:	83 c4 20             	add    $0x20,%esp
f01048e0:	5e                   	pop    %esi
f01048e1:	5f                   	pop    %edi
f01048e2:	5d                   	pop    %ebp
f01048e3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01048e4:	85 c9                	test   %ecx,%ecx
f01048e6:	75 0b                	jne    f01048f3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01048e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01048ed:	31 d2                	xor    %edx,%edx
f01048ef:	f7 f1                	div    %ecx
f01048f1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01048f3:	89 f0                	mov    %esi,%eax
f01048f5:	31 d2                	xor    %edx,%edx
f01048f7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01048f9:	89 f8                	mov    %edi,%eax
f01048fb:	e9 3e ff ff ff       	jmp    f010483e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0104900:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104902:	83 c4 20             	add    $0x20,%esp
f0104905:	5e                   	pop    %esi
f0104906:	5f                   	pop    %edi
f0104907:	5d                   	pop    %ebp
f0104908:	c3                   	ret    
f0104909:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010490c:	39 f5                	cmp    %esi,%ebp
f010490e:	72 04                	jb     f0104914 <__umoddi3+0x104>
f0104910:	39 f9                	cmp    %edi,%ecx
f0104912:	77 06                	ja     f010491a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104914:	89 f2                	mov    %esi,%edx
f0104916:	29 cf                	sub    %ecx,%edi
f0104918:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f010491a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010491c:	83 c4 20             	add    $0x20,%esp
f010491f:	5e                   	pop    %esi
f0104920:	5f                   	pop    %edi
f0104921:	5d                   	pop    %ebp
f0104922:	c3                   	ret    
f0104923:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104924:	89 d1                	mov    %edx,%ecx
f0104926:	89 c5                	mov    %eax,%ebp
f0104928:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f010492c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0104930:	eb 8d                	jmp    f01048bf <__umoddi3+0xaf>
f0104932:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104934:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0104938:	72 ea                	jb     f0104924 <__umoddi3+0x114>
f010493a:	89 f1                	mov    %esi,%ecx
f010493c:	eb 81                	jmp    f01048bf <__umoddi3+0xaf>
