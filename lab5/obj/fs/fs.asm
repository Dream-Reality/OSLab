
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 ef 21 00 00       	call   802220 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	88 c1                	mov    %al,%cl

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800040:	0f b6 c0             	movzbl %al,%eax
  800043:	89 c3                	mov    %eax,%ebx
  800045:	81 e3 c0 00 00 00    	and    $0xc0,%ebx
  80004b:	83 fb 40             	cmp    $0x40,%ebx
  80004e:	75 ef                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800050:	84 c9                	test   %cl,%cl
  800052:	74 0c                	je     800060 <ide_wait_ready+0x2c>
  800054:	83 e0 21             	and    $0x21,%eax
		return -1;
	return 0;
  800057:	83 f8 01             	cmp    $0x1,%eax
  80005a:	19 c0                	sbb    %eax,%eax
  80005c:	f7 d0                	not    %eax
  80005e:	eb 05                	jmp    800065 <ide_wait_ready+0x31>
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800065:	5b                   	pop    %ebx
  800066:	5d                   	pop    %ebp
  800067:	c3                   	ret    

00800068 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	53                   	push   %ebx
  80006c:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
  800074:	e8 bb ff ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	b0 f0                	mov    $0xf0,%al
  800080:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800081:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800086:	b2 f7                	mov    $0xf7,%dl
  800088:	eb 09                	jmp    800093 <ide_probe_disk1+0x2b>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008a:	43                   	inc    %ebx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008b:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  800091:	74 05                	je     800098 <ide_probe_disk1+0x30>
  800093:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800094:	a8 a1                	test   $0xa1,%al
  800096:	75 f2                	jne    80008a <ide_probe_disk1+0x22>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800098:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009d:	b0 e0                	mov    $0xe0,%al
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000a6:	0f 9e c0             	setle  %al
  8000a9:	0f b6 c0             	movzbl %al,%eax
  8000ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b0:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  8000b7:	e8 d0 22 00 00       	call   80238c <cprintf>
	return (x < 1000);
  8000bc:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000c2:	0f 9e c0             	setle  %al
}
  8000c5:	83 c4 14             	add    $0x14,%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 18             	sub    $0x18,%esp
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d4:	83 f8 01             	cmp    $0x1,%eax
  8000d7:	76 1c                	jbe    8000f5 <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d9:	c7 44 24 08 37 42 80 	movl   $0x804237,0x8(%esp)
  8000e0:	00 
  8000e1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e8:	00 
  8000e9:	c7 04 24 47 42 80 00 	movl   $0x804247,(%esp)
  8000f0:	e8 9f 21 00 00       	call   802294 <_panic>
	diskno = d;
  8000f5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	83 ec 1c             	sub    $0x1c,%esp
  800105:	8b 7d 08             	mov    0x8(%ebp),%edi
  800108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80010b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  80010e:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  800114:	76 24                	jbe    80013a <ide_read+0x3e>
  800116:	c7 44 24 0c 50 42 80 	movl   $0x804250,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 47 42 80 00 	movl   $0x804247,(%esp)
  800135:	e8 5a 21 00 00       	call   802294 <_panic>

	ide_wait_ready(0);
  80013a:	b8 00 00 00 00       	mov    $0x0,%eax
  80013f:	e8 f0 fe ff ff       	call   800034 <ide_wait_ready>
  800144:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800149:	88 d8                	mov    %bl,%al
  80014b:	ee                   	out    %al,(%dx)
  80014c:	b2 f3                	mov    $0xf3,%dl
  80014e:	89 f8                	mov    %edi,%eax
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 08             	shr    $0x8,%eax
  800156:	b2 f4                	mov    $0xf4,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800159:	89 f8                	mov    %edi,%eax
  80015b:	c1 e8 10             	shr    $0x10,%eax
  80015e:	b2 f5                	mov    $0xf5,%dl
  800160:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800161:	a1 00 50 80 00       	mov    0x805000,%eax
  800166:	83 e0 01             	and    $0x1,%eax
  800169:	c1 e0 04             	shl    $0x4,%eax
  80016c:	83 c8 e0             	or     $0xffffffe0,%eax
  80016f:	c1 ef 18             	shr    $0x18,%edi
  800172:	83 e7 0f             	and    $0xf,%edi
  800175:	09 f8                	or     %edi,%eax
  800177:	b2 f6                	mov    $0xf6,%dl
  800179:	ee                   	out    %al,(%dx)
  80017a:	b2 f7                	mov    $0xf7,%dl
  80017c:	b0 20                	mov    $0x20,%al
  80017e:	ee                   	out    %al,(%dx)
  80017f:	eb 24                	jmp    8001a5 <ide_read+0xa9>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800181:	b8 01 00 00 00       	mov    $0x1,%eax
  800186:	e8 a9 fe ff ff       	call   800034 <ide_wait_ready>
  80018b:	85 c0                	test   %eax,%eax
  80018d:	78 1f                	js     8001ae <ide_read+0xb2>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018f:	89 f7                	mov    %esi,%edi
  800191:	b9 80 00 00 00       	mov    $0x80,%ecx
  800196:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019b:	fc                   	cld    
  80019c:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80019e:	4b                   	dec    %ebx
  80019f:	81 c6 00 02 00 00    	add    $0x200,%esi
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	75 d8                	jne    800181 <ide_read+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001ae:	83 c4 1c             	add    $0x1c,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001c8:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001ce:	76 24                	jbe    8001f4 <ide_write+0x3e>
  8001d0:	c7 44 24 0c 50 42 80 	movl   $0x804250,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 47 42 80 00 	movl   $0x804247,(%esp)
  8001ef:	e8 a0 20 00 00       	call   802294 <_panic>

	ide_wait_ready(0);
  8001f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f9:	e8 36 fe ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001fe:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800203:	88 d8                	mov    %bl,%al
  800205:	ee                   	out    %al,(%dx)
  800206:	b2 f3                	mov    $0xf3,%dl
  800208:	89 f0                	mov    %esi,%eax
  80020a:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80020b:	89 f0                	mov    %esi,%eax
  80020d:	c1 e8 08             	shr    $0x8,%eax
  800210:	b2 f4                	mov    $0xf4,%dl
  800212:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800213:	89 f0                	mov    %esi,%eax
  800215:	c1 e8 10             	shr    $0x10,%eax
  800218:	b2 f5                	mov    $0xf5,%dl
  80021a:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021b:	a1 00 50 80 00       	mov    0x805000,%eax
  800220:	83 e0 01             	and    $0x1,%eax
  800223:	c1 e0 04             	shl    $0x4,%eax
  800226:	83 c8 e0             	or     $0xffffffe0,%eax
  800229:	c1 ee 18             	shr    $0x18,%esi
  80022c:	83 e6 0f             	and    $0xf,%esi
  80022f:	09 f0                	or     %esi,%eax
  800231:	b2 f6                	mov    $0xf6,%dl
  800233:	ee                   	out    %al,(%dx)
  800234:	b2 f7                	mov    $0xf7,%dl
  800236:	b0 30                	mov    $0x30,%al
  800238:	ee                   	out    %al,(%dx)
  800239:	eb 24                	jmp    80025f <ide_write+0xa9>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80023b:	b8 01 00 00 00       	mov    $0x1,%eax
  800240:	e8 ef fd ff ff       	call   800034 <ide_wait_ready>
  800245:	85 c0                	test   %eax,%eax
  800247:	78 1f                	js     800268 <ide_write+0xb2>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800249:	89 fe                	mov    %edi,%esi
  80024b:	b9 80 00 00 00       	mov    $0x80,%ecx
  800250:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800255:	fc                   	cld    
  800256:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800258:	4b                   	dec    %ebx
  800259:	81 c7 00 02 00 00    	add    $0x200,%edi
  80025f:	85 db                	test   %ebx,%ebx
  800261:	75 d8                	jne    80023b <ide_write+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800268:	83 c4 1c             	add    $0x1c,%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <MyLink_init>:
#define NBUF 16
typedef struct MyLink{
    struct MyLink *p,*s;
	void *addr;
}MyLink;
void MyLink_init(MyLink *p){p->p=p->s=p;p->addr=0;}
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 40 04             	mov    %eax,0x4(%eax)
  800279:	89 00                	mov    %eax,(%eax)
  80027b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <MyLink_delete>:
MyLink* MyLink_delete(MyLink *p){p->p->s=p->s;p->s->p=p->p;p->p=p->s=p;return p;}
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8b 48 04             	mov    0x4(%eax),%ecx
  80028f:	89 4a 04             	mov    %ecx,0x4(%edx)
  800292:	8b 50 04             	mov    0x4(%eax),%edx
  800295:	8b 08                	mov    (%eax),%ecx
  800297:	89 0a                	mov    %ecx,(%edx)
  800299:	89 40 04             	mov    %eax,0x4(%eax)
  80029c:	89 00                	mov    %eax,(%eax)
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <MyLink_insert>:
void MyLink_insert(MyLink *p,MyLink *q,void *addr){
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	//cprintf("link %x %x\n",p,q);
	q->p=p;q->s=p->s;p->s=q->s->p=q;q->addr=addr;
  8002a9:	89 10                	mov    %edx,(%eax)
  8002ab:	8b 4a 04             	mov    0x4(%edx),%ecx
  8002ae:	89 48 04             	mov    %ecx,0x4(%eax)
  8002b1:	89 01                	mov    %eax,(%ecx)
  8002b3:	89 42 04             	mov    %eax,0x4(%edx)
  8002b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8002b9:	89 50 08             	mov    %edx,0x8(%eax)
}
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <buf_print_used>:
	}
	if (nbuf==NBUF&&(r=buf_remove(used.s))&&r<0)
		return r;
	return 0;
}
void buf_print_used(void){
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 20             	sub    $0x20,%esp
	int u=0,un=0;
	static int c=0;
	static float p=0.;
	for (MyLink *l = used.s;l!=&used;l=l->s){
  8002c6:	a1 50 a0 80 00       	mov    0x80a050,%eax
	if (nbuf==NBUF&&(r=buf_remove(used.s))&&r<0)
		return r;
	return 0;
}
void buf_print_used(void){
	int u=0,un=0;
  8002cb:	be 00 00 00 00       	mov    $0x0,%esi
  8002d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	static int c=0;
	static float p=0.;
	for (MyLink *l = used.s;l!=&used;l=l->s){
  8002d5:	eb 19                	jmp    8002f0 <buf_print_used+0x32>
		//cprintf("%x ",l->addr);
		if (uvpt[PGNUM(l->addr)]&PTE_A)u++;
  8002d7:	8b 50 08             	mov    0x8(%eax),%edx
  8002da:	c1 ea 0c             	shr    $0xc,%edx
  8002dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8002e4:	f6 c2 20             	test   $0x20,%dl
  8002e7:	74 03                	je     8002ec <buf_print_used+0x2e>
  8002e9:	43                   	inc    %ebx
  8002ea:	eb 01                	jmp    8002ed <buf_print_used+0x2f>
		else un++;
  8002ec:	46                   	inc    %esi
}
void buf_print_used(void){
	int u=0,un=0;
	static int c=0;
	static float p=0.;
	for (MyLink *l = used.s;l!=&used;l=l->s){
  8002ed:	8b 40 04             	mov    0x4(%eax),%eax
  8002f0:	3d 4c a0 80 00       	cmp    $0x80a04c,%eax
  8002f5:	75 e0                	jne    8002d7 <buf_print_used+0x19>
		//cprintf("%x ",l->addr);
		if (uvpt[PGNUM(l->addr)]&PTE_A)u++;
		else un++;
	}cprintf("\n");
  8002f7:	c7 04 24 f8 42 80 00 	movl   $0x8042f8,(%esp)
  8002fe:	e8 89 20 00 00       	call   80238c <cprintf>
	p = p+(float)u/(u+un); c++;
  800303:	01 de                	add    %ebx,%esi
  800305:	89 75 f4             	mov    %esi,-0xc(%ebp)
  800308:	db 45 f4             	fildl  -0xc(%ebp)
  80030b:	53                   	push   %ebx
  80030c:	da 3c 24             	fidivrl (%esp)
  80030f:	d8 05 0c a0 80 00    	fadds  0x80a00c
  800315:	d9 15 0c a0 80 00    	fsts   0x80a00c
  80031b:	a1 10 a0 80 00       	mov    0x80a010,%eax
  800320:	40                   	inc    %eax
  800321:	a3 10 a0 80 00       	mov    %eax,0x80a010
	cprintf("%d %d %d\n",u,u+un,(int)(p/c*1000000000));
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	da 34 24             	fidivl (%esp)
  80032c:	8d 64 24 04          	lea    0x4(%esp),%esp
  800330:	d8 0d bc 44 80 00    	fmuls  0x8044bc
  800336:	d9 7d f2             	fnstcw -0xe(%ebp)
  800339:	66 8b 45 f2          	mov    -0xe(%ebp),%ax
  80033d:	b4 0c                	mov    $0xc,%ah
  80033f:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  800343:	d9 6d f0             	fldcw  -0x10(%ebp)
  800346:	db 5c 24 0c          	fistpl 0xc(%esp)
  80034a:	d9 6d f2             	fldcw  -0xe(%ebp)
  80034d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	c7 04 24 72 42 80 00 	movl   $0x804272,(%esp)
  80035c:	e8 2b 20 00 00       	call   80238c <cprintf>
}
  800361:	83 c4 20             	add    $0x20,%esp
  800364:	5b                   	pop    %ebx
  800365:	5e                   	pop    %esi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <buf_init>:
	//cprintf("important %x %x\n",&used,&unused);
	MyLink * l = MyLink_delete(unused.s);
	MyLink_insert(used.p,l,addr);
	return 0;
}
void buf_init(void){
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
  80036d:	83 ec 0c             	sub    $0xc,%esp
	MyLink_init(&unused);MyLink_init(&used);
  800370:	c7 04 24 40 a0 80 00 	movl   $0x80a040,(%esp)
  800377:	e8 f4 fe ff ff       	call   800270 <MyLink_init>
  80037c:	c7 04 24 4c a0 80 00 	movl   $0x80a04c,(%esp)
  800383:	e8 e8 fe ff ff       	call   800270 <MyLink_init>
	for (int i=0;i<NBUF;++i) {
  800388:	be 00 00 00 00       	mov    $0x0,%esi
		MyLink_init(&buf[i]);
  80038d:	8d 04 76             	lea    (%esi,%esi,2),%eax
  800390:	8d 1c 85 60 a0 80 00 	lea    0x80a060(,%eax,4),%ebx
  800397:	89 1c 24             	mov    %ebx,(%esp)
  80039a:	e8 d1 fe ff ff       	call   800270 <MyLink_init>
		MyLink_insert(unused.p,&buf[i],0);
  80039f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003a6:	00 
  8003a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ab:	a1 40 a0 80 00       	mov    0x80a040,%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 e8 fe ff ff       	call   8002a0 <MyLink_insert>
	MyLink_insert(used.p,l,addr);
	return 0;
}
void buf_init(void){
	MyLink_init(&unused);MyLink_init(&used);
	for (int i=0;i<NBUF;++i) {
  8003b8:	46                   	inc    %esi
  8003b9:	83 fe 10             	cmp    $0x10,%esi
  8003bc:	75 cf                	jne    80038d <buf_init+0x25>
	cprintf("init:\n");
	for (MyLink *l=unused.s;l!=&unused;l=l->s){
		cprintf("%x ",l);
	}
	cprintf("\n");*/
}
  8003be:	83 c4 0c             	add    $0xc,%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <buf_delete>:
				return r;
		}
	}
	return 0;
}
int buf_delete(void*addr){
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	83 ec 0c             	sub    $0xc,%esp
  8003cb:	8b 55 08             	mov    0x8(%ebp),%edx
	for (MyLink *l=used.s;l!=&used;l=l->s){
  8003ce:	a1 50 a0 80 00       	mov    0x80a050,%eax
  8003d3:	eb 30                	jmp    800405 <buf_delete+0x40>
		if (l->addr==addr){
  8003d5:	39 50 08             	cmp    %edx,0x8(%eax)
  8003d8:	75 28                	jne    800402 <buf_delete+0x3d>
			MyLink_insert(unused.p,MyLink_delete(l),0);
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	e8 a2 fe ff ff       	call   800284 <MyLink_delete>
  8003e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003e9:	00 
  8003ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ee:	a1 40 a0 80 00       	mov    0x80a040,%eax
  8003f3:	89 04 24             	mov    %eax,(%esp)
  8003f6:	e8 a5 fe ff ff       	call   8002a0 <MyLink_insert>
			return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 0f                	jmp    800411 <buf_delete+0x4c>
		}
	}
	return 0;
}
int buf_delete(void*addr){
	for (MyLink *l=used.s;l!=&used;l=l->s){
  800402:	8b 40 04             	mov    0x4(%eax),%eax
  800405:	3d 4c a0 80 00       	cmp    $0x80a04c,%eax
  80040a:	75 c9                	jne    8003d5 <buf_delete+0x10>
		if (l->addr==addr){
			MyLink_insert(unused.p,MyLink_delete(l),0);
			return 0;
		}
	}
	return -1;
  80040c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <diskaddr>:

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 18             	sub    $0x18,%esp
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80041c:	85 c0                	test   %eax,%eax
  80041e:	74 0f                	je     80042f <diskaddr+0x1c>
  800420:	8b 15 20 a0 80 00    	mov    0x80a020,%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	74 25                	je     80044f <diskaddr+0x3c>
  80042a:	3b 42 04             	cmp    0x4(%edx),%eax
  80042d:	72 20                	jb     80044f <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80042f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800433:	c7 44 24 08 44 43 80 	movl   $0x804344,0x8(%esp)
  80043a:	00 
  80043b:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  800442:	00 
  800443:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  80044a:	e8 45 1e 00 00       	call   802294 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80044f:	05 00 00 01 00       	add    $0x10000,%eax
  800454:	c1 e0 0c             	shl    $0xc,%eax
}
  800457:	c9                   	leave  
  800458:	c3                   	ret    

00800459 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	8b 45 08             	mov    0x8(%ebp),%eax
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  80045f:	89 c2                	mov    %eax,%edx
  800461:	c1 ea 16             	shr    $0x16,%edx
  800464:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80046b:	f6 c2 01             	test   $0x1,%dl
  80046e:	74 0f                	je     80047f <va_is_mapped+0x26>
  800470:	c1 e8 0c             	shr    $0xc,%eax
  800473:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80047a:	83 e0 01             	and    $0x1,%eax
  80047d:	eb 05                	jmp    800484 <va_is_mapped+0x2b>
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  80048c:	c1 e8 0c             	shr    $0xc,%eax
  80048f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800496:	a8 40                	test   $0x40,%al
  800498:	0f 95 c0             	setne  %al
}
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    

0080049d <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 20             	sub    $0x20,%esp
  8004a5:	8b 75 08             	mov    0x8(%ebp),%esi
	//cprintf("flush %x\n",addr);
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8004a8:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  8004ae:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8004b3:	76 20                	jbe    8004d5 <flush_block+0x38>
		panic("flush_block of bad va %08x", addr);
  8004b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004b9:	c7 44 24 08 84 42 80 	movl   $0x804284,0x8(%esp)
  8004c0:	00 
  8004c1:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  8004c8:	00 
  8004c9:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  8004d0:	e8 bf 1d 00 00       	call   802294 <_panic>

	// LAB 5: Your code here.
	int r;
	addr = (void*)ROUNDDOWN(addr,BLKSIZE);
  8004d5:	89 f3                	mov    %esi,%ebx
  8004d7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (va_is_mapped(addr)&&va_is_dirty(addr)){
  8004dd:	89 1c 24             	mov    %ebx,(%esp)
  8004e0:	e8 74 ff ff ff       	call   800459 <va_is_mapped>
  8004e5:	84 c0                	test   %al,%al
  8004e7:	0f 84 b1 00 00 00    	je     80059e <flush_block+0x101>
  8004ed:	89 1c 24             	mov    %ebx,(%esp)
  8004f0:	e8 91 ff ff ff       	call   800486 <va_is_dirty>
  8004f5:	84 c0                	test   %al,%al
  8004f7:	0f 84 a1 00 00 00    	je     80059e <flush_block+0x101>
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	//cprintf("flush %x\n",addr);
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004fd:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  800503:	c1 ee 0c             	shr    $0xc,%esi

	// LAB 5: Your code here.
	int r;
	addr = (void*)ROUNDDOWN(addr,BLKSIZE);
	if (va_is_mapped(addr)&&va_is_dirty(addr)){
		if ((r = ide_write(blockno * BLKSECTS,addr,BLKSECTS))<0)
  800506:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  80050d:	00 
  80050e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800512:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	e8 95 fc ff ff       	call   8001b6 <ide_write>
  800521:	85 c0                	test   %eax,%eax
  800523:	79 24                	jns    800549 <flush_block+0xac>
			panic("flush_block: ide_write (blockno) is %x, (addr) is %x",blockno,addr);
  800525:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800529:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80052d:	c7 44 24 08 68 43 80 	movl   $0x804368,0x8(%esp)
  800534:	00 
  800535:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  80053c:	00 
  80053d:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800544:	e8 4b 1d 00 00       	call   802294 <_panic>
		if ((r = sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  800549:	89 d8                	mov    %ebx,%eax
  80054b:	c1 e8 0c             	shr    $0xc,%eax
  80054e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800555:	25 07 0e 00 00       	and    $0xe07,%eax
  80055a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80055e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800562:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800569:	00 
  80056a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800575:	e8 03 28 00 00       	call   802d7d <sys_page_map>
  80057a:	85 c0                	test   %eax,%eax
  80057c:	79 20                	jns    80059e <flush_block+0x101>
			panic("flush_block: sys_page_map (addr) is %x\n",addr);
  80057e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800582:	c7 44 24 08 a0 43 80 	movl   $0x8043a0,0x8(%esp)
  800589:	00 
  80058a:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  800591:	00 
  800592:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800599:	e8 f6 1c 00 00       	call   802294 <_panic>
	}
	return;
	panic("flush_block not implemented");
}
  80059e:	83 c4 20             	add    $0x20,%esp
  8005a1:	5b                   	pop    %ebx
  8005a2:	5e                   	pop    %esi
  8005a3:	5d                   	pop    %ebp
  8005a4:	c3                   	ret    

008005a5 <buf_visit>:
	for (MyLink *l=unused.s;l!=&unused;l=l->s){
		cprintf("%x ",l);
	}
	cprintf("\n");*/
}
int buf_visit(void){
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
  8005a8:	57                   	push   %edi
  8005a9:	56                   	push   %esi
  8005aa:	53                   	push   %ebx
  8005ab:	83 ec 2c             	sub    $0x2c,%esp
	int r;
	buf_print_used();
  8005ae:	e8 0b fd ff ff       	call   8002be <buf_print_used>
	if (++t<NBUF)return 0;t=0;
  8005b3:	a1 00 a0 80 00       	mov    0x80a000,%eax
  8005b8:	40                   	inc    %eax
  8005b9:	a3 00 a0 80 00       	mov    %eax,0x80a000
  8005be:	83 f8 0f             	cmp    $0xf,%eax
  8005c1:	0f 8e 99 00 00 00    	jle    800660 <buf_visit+0xbb>
  8005c7:	c7 05 00 a0 80 00 00 	movl   $0x0,0x80a000
  8005ce:	00 00 00 
	int cused = 0,cunused = 0;
	for (MyLink *l=used.s;l!=&used;l=l->s)cused++;
  8005d1:	8b 1d 50 a0 80 00    	mov    0x80a050,%ebx
  8005d7:	89 d8                	mov    %ebx,%eax
  8005d9:	eb 03                	jmp    8005de <buf_visit+0x39>
  8005db:	8b 40 04             	mov    0x4(%eax),%eax
  8005de:	3d 4c a0 80 00       	cmp    $0x80a04c,%eax
  8005e3:	75 f6                	jne    8005db <buf_visit+0x36>
	for (MyLink *l=unused.s;l!=&unused;l=l->s)cunused++;
  8005e5:	a1 44 a0 80 00       	mov    0x80a044,%eax
  8005ea:	eb 03                	jmp    8005ef <buf_visit+0x4a>
  8005ec:	8b 40 04             	mov    0x4(%eax),%eax
  8005ef:	3d 40 a0 80 00       	cmp    $0x80a040,%eax
  8005f4:	75 f6                	jne    8005ec <buf_visit+0x47>
  8005f6:	eb 59                	jmp    800651 <buf_visit+0xac>
	// cprintf("%x %x\n",cused,(cused+cunused));
	for (MyLink *l=used.s;l!=&used;l=l->s){
		void *addr=l->addr;
  8005f8:	8b 73 08             	mov    0x8(%ebx),%esi
		if (uvpt[PGNUM(addr)]&PTE_A){
  8005fb:	89 f7                	mov    %esi,%edi
  8005fd:	c1 ef 0c             	shr    $0xc,%edi
  800600:	8b 04 bd 00 00 40 ef 	mov    -0x10c00000(,%edi,4),%eax
  800607:	a8 20                	test   $0x20,%al
  800609:	74 43                	je     80064e <buf_visit+0xa9>
			if (uvpt[PGNUM(addr)]&PTE_D)flush_block(addr);
  80060b:	8b 04 bd 00 00 40 ef 	mov    -0x10c00000(,%edi,4),%eax
  800612:	a8 40                	test   $0x40,%al
  800614:	74 08                	je     80061e <buf_visit+0x79>
  800616:	89 34 24             	mov    %esi,(%esp)
  800619:	e8 7f fe ff ff       	call   80049d <flush_block>
			if ((r=sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))&&r<0)
  80061e:	8b 04 bd 00 00 40 ef 	mov    -0x10c00000(,%edi,4),%eax
  800625:	25 07 0e 00 00       	and    $0xe07,%eax
  80062a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800632:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800639:	00 
  80063a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800645:	e8 33 27 00 00       	call   802d7d <sys_page_map>
  80064a:	85 c0                	test   %eax,%eax
  80064c:	78 17                	js     800665 <buf_visit+0xc0>
	if (++t<NBUF)return 0;t=0;
	int cused = 0,cunused = 0;
	for (MyLink *l=used.s;l!=&used;l=l->s)cused++;
	for (MyLink *l=unused.s;l!=&unused;l=l->s)cunused++;
	// cprintf("%x %x\n",cused,(cused+cunused));
	for (MyLink *l=used.s;l!=&used;l=l->s){
  80064e:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800651:	81 fb 4c a0 80 00    	cmp    $0x80a04c,%ebx
  800657:	75 9f                	jne    8005f8 <buf_visit+0x53>
			if (uvpt[PGNUM(addr)]&PTE_D)flush_block(addr);
			if ((r=sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))&&r<0)
				return r;
		}
	}
	return 0;
  800659:	b8 00 00 00 00       	mov    $0x0,%eax
  80065e:	eb 05                	jmp    800665 <buf_visit+0xc0>
	cprintf("\n");*/
}
int buf_visit(void){
	int r;
	buf_print_used();
	if (++t<NBUF)return 0;t=0;
  800660:	b8 00 00 00 00       	mov    $0x0,%eax
			if ((r=sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))&&r<0)
				return r;
		}
	}
	return 0;
}
  800665:	83 c4 2c             	add    $0x2c,%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <buf_remove>:
	//cprintf("link %x %x\n",p,q);
	q->p=p;q->s=p->s;p->s=q->s->p=q;q->addr=addr;
}
MyLink buf[NBUF],unused,used;
int nbuf=0,t=0;
int buf_remove(MyLink *l){
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	53                   	push   %ebx
  800671:	83 ec 14             	sub    $0x14,%esp
  800674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	static int count_remove =0;
	count_remove++;
  800677:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80067c:	40                   	inc    %eax
  80067d:	a3 08 a0 80 00       	mov    %eax,0x80a008
	cprintf("remove %x %x %d\n",l,l->addr,count_remove);
  800682:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800686:	8b 43 08             	mov    0x8(%ebx),%eax
  800689:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	c7 04 24 9f 42 80 00 	movl   $0x80429f,(%esp)
  800698:	e8 ef 1c 00 00       	call   80238c <cprintf>
	int r;
	if (uvpt[PGNUM(l->addr)]&PTE_D)flush_block(l->addr);
  80069d:	8b 43 08             	mov    0x8(%ebx),%eax
  8006a0:	89 c2                	mov    %eax,%edx
  8006a2:	c1 ea 0c             	shr    $0xc,%edx
  8006a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006ac:	f6 c2 40             	test   $0x40,%dl
  8006af:	74 08                	je     8006b9 <buf_remove+0x4c>
  8006b1:	89 04 24             	mov    %eax,(%esp)
  8006b4:	e8 e4 fd ff ff       	call   80049d <flush_block>
	if (r=sys_page_unmap(0,l->addr),r<0)
  8006b9:	8b 43 08             	mov    0x8(%ebx),%eax
  8006bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c7:	e8 04 27 00 00       	call   802dd0 <sys_page_unmap>
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	78 2c                	js     8006fc <buf_remove+0x8f>
		return r;
	nbuf--;
  8006d0:	ff 0d 04 a0 80 00    	decl   0x80a004
	// cprintf("fffff  %x %x\n",unused.p,l);
	MyLink_insert(unused.p,MyLink_delete(l),0);
  8006d6:	89 1c 24             	mov    %ebx,(%esp)
  8006d9:	e8 a6 fb ff ff       	call   800284 <MyLink_delete>
  8006de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006e5:	00 
  8006e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ea:	a1 40 a0 80 00       	mov    0x80a040,%eax
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 a9 fb ff ff       	call   8002a0 <MyLink_insert>
	return 0;
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8006fc:	83 c4 14             	add    $0x14,%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <buf_evict>:
int buf_evict(void){
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	53                   	push   %ebx
  800706:	83 ec 14             	sub    $0x14,%esp
	// cprintf("%x %x\n",&used,used.s);
	int r;
	for (MyLink *l=used.s;l!=&used;){
  800709:	a1 50 a0 80 00       	mov    0x80a050,%eax
  80070e:	eb 28                	jmp    800738 <buf_evict+0x36>
		void *addr=l->addr;
		if (!(uvpt[PGNUM(addr)]&PTE_A)){
  800710:	8b 50 08             	mov    0x8(%eax),%edx
  800713:	c1 ea 0c             	shr    $0xc,%edx
  800716:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80071d:	f6 c2 20             	test   $0x20,%dl
  800720:	75 13                	jne    800735 <buf_evict+0x33>
			//cprintf("%x %x %x %x\n",addr,l,buf,&used);
			MyLink* tmp = l->s;
  800722:	8b 58 04             	mov    0x4(%eax),%ebx
			if((r=buf_remove(l))&&r<0)
  800725:	89 04 24             	mov    %eax,(%esp)
  800728:	e8 40 ff ff ff       	call   80066d <buf_remove>
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 34                	js     800765 <buf_evict+0x63>
				return r;
			l = tmp;
  800731:	89 d8                	mov    %ebx,%eax
  800733:	eb 03                	jmp    800738 <buf_evict+0x36>
		}else l = l->s;
  800735:	8b 40 04             	mov    0x4(%eax),%eax
	return 0;
}
int buf_evict(void){
	// cprintf("%x %x\n",&used,used.s);
	int r;
	for (MyLink *l=used.s;l!=&used;){
  800738:	3d 4c a0 80 00       	cmp    $0x80a04c,%eax
  80073d:	75 d1                	jne    800710 <buf_evict+0xe>
			if((r=buf_remove(l))&&r<0)
				return r;
			l = tmp;
		}else l = l->s;
	}
	if (nbuf==NBUF&&(r=buf_remove(used.s))&&r<0)
  80073f:	83 3d 04 a0 80 00 10 	cmpl   $0x10,0x80a004
  800746:	75 18                	jne    800760 <buf_evict+0x5e>
  800748:	a1 50 a0 80 00       	mov    0x80a050,%eax
  80074d:	89 04 24             	mov    %eax,(%esp)
  800750:	e8 18 ff ff ff       	call   80066d <buf_remove>
  800755:	85 c0                	test   %eax,%eax
  800757:	7e 0c                	jle    800765 <buf_evict+0x63>
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	eb 05                	jmp    800765 <buf_evict+0x63>
		return r;
	return 0;
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800765:	83 c4 14             	add    $0x14,%esp
  800768:	5b                   	pop    %ebx
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <buf_alloc>:
		else un++;
	}cprintf("\n");
	p = p+(float)u/(u+un); c++;
	cprintf("%d %d %d\n",u,u+un,(int)(p/c*1000000000));
}
int buf_alloc(void *addr){
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	83 ec 14             	sub    $0x14,%esp
  800772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	if (addr<diskaddr(2))return 0;
  800775:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80077c:	e8 92 fc ff ff       	call   800413 <diskaddr>
  800781:	39 d8                	cmp    %ebx,%eax
  800783:	77 60                	ja     8007e5 <buf_alloc+0x7a>
	static int count_alloc=0;
	count_alloc++;
  800785:	a1 14 a0 80 00       	mov    0x80a014,%eax
  80078a:	40                   	inc    %eax
  80078b:	a3 14 a0 80 00       	mov    %eax,0x80a014
	cprintf("alloc %x %d\n",addr,count_alloc);
  800790:	89 44 24 08          	mov    %eax,0x8(%esp)
  800794:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800798:	c7 04 24 b0 42 80 00 	movl   $0x8042b0,(%esp)
  80079f:	e8 e8 1b 00 00       	call   80238c <cprintf>
	if ((nbuf==NBUF)&&(r=buf_evict())&&r<0)
  8007a4:	83 3d 04 a0 80 00 10 	cmpl   $0x10,0x80a004
  8007ab:	75 09                	jne    8007b6 <buf_alloc+0x4b>
  8007ad:	e8 50 ff ff ff       	call   800702 <buf_evict>
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 34                	js     8007ea <buf_alloc+0x7f>
		return r;
	nbuf++;
  8007b6:	ff 05 04 a0 80 00    	incl   0x80a004
	//cprintf("important %x %x\n",&used,&unused);
	MyLink * l = MyLink_delete(unused.s);
  8007bc:	a1 44 a0 80 00       	mov    0x80a044,%eax
  8007c1:	89 04 24             	mov    %eax,(%esp)
  8007c4:	e8 bb fa ff ff       	call   800284 <MyLink_delete>
	MyLink_insert(used.p,l,addr);
  8007c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d1:	a1 4c a0 80 00       	mov    0x80a04c,%eax
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	e8 c2 fa ff ff       	call   8002a0 <MyLink_insert>
	return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 05                	jmp    8007ea <buf_alloc+0x7f>
	p = p+(float)u/(u+un); c++;
	cprintf("%d %d %d\n",u,u+un,(int)(p/c*1000000000));
}
int buf_alloc(void *addr){
	int r;
	if (addr<diskaddr(2))return 0;
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
	nbuf++;
	//cprintf("important %x %x\n",&used,&unused);
	MyLink * l = MyLink_delete(unused.s);
	MyLink_insert(used.p,l,addr);
	return 0;
}
  8007ea:	83 c4 14             	add    $0x14,%esp
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 20             	sub    $0x20,%esp
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("pgfault %x\n",utf);
	void *addr = (void *) utf->utf_fault_va;
  8007fb:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	// cprintf("bc_pgfault addr: %x\n",addr);
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8007fd:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  800803:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800809:	76 2e                	jbe    800839 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80080b:	8b 50 04             	mov    0x4(%eax),%edx
  80080e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800812:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800816:	8b 40 28             	mov    0x28(%eax),%eax
  800819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081d:	c7 44 24 08 c8 43 80 	movl   $0x8043c8,0x8(%esp)
  800824:	00 
  800825:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  80082c:	00 
  80082d:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800834:	e8 5b 1a 00 00       	call   802294 <_panic>
static void
bc_pgfault(struct UTrapframe *utf)
{
	// cprintf("pgfault %x\n",utf);
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800839:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  80083f:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  800842:	a1 20 a0 80 00       	mov    0x80a020,%eax
  800847:	85 c0                	test   %eax,%eax
  800849:	74 25                	je     800870 <bc_pgfault+0x80>
  80084b:	3b 70 04             	cmp    0x4(%eax),%esi
  80084e:	72 20                	jb     800870 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  800850:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800854:	c7 44 24 08 f8 43 80 	movl   $0x8043f8,0x8(%esp)
  80085b:	00 
  80085c:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800863:	00 
  800864:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  80086b:	e8 24 1a 00 00       	call   802294 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = (void*)ROUNDDOWN(addr,BLKSIZE);
  800870:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0,addr,PTE_P|PTE_U|PTE_W))<0)
  800876:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80087d:	00 
  80087e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800882:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800889:	e8 9b 24 00 00       	call   802d29 <sys_page_alloc>
  80088e:	85 c0                	test   %eax,%eax
  800890:	79 20                	jns    8008b2 <bc_pgfault+0xc2>
		panic("bc_pgfault: sys_page_alloc (add) is %x\n",addr);
  800892:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800896:	c7 44 24 08 1c 44 80 	movl   $0x80441c,0x8(%esp)
  80089d:	00 
  80089e:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8008a5:	00 
  8008a6:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  8008ad:	e8 e2 19 00 00       	call   802294 <_panic>
	if ((r = ide_read(blockno * BLKSECTS,addr,BLKSECTS))<0)
  8008b2:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8008b9:	00 
  8008ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008be:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	e8 2f f8 ff ff       	call   8000fc <ide_read>
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	79 24                	jns    8008f5 <bc_pgfault+0x105>
		panic("bc_pgfault: ide_raed (blockno) is %x, (addr) is %x\n",blockno,addr);
  8008d1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8008d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008d9:	c7 44 24 08 44 44 80 	movl   $0x804444,0x8(%esp)
  8008e0:	00 
  8008e1:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8008e8:	00 
  8008e9:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  8008f0:	e8 9f 19 00 00       	call   802294 <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8008f5:	89 d8                	mov    %ebx,%eax
  8008f7:	c1 e8 0c             	shr    $0xc,%eax
  8008fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800901:	25 07 0e 00 00       	and    $0xe07,%eax
  800906:	89 44 24 10          	mov    %eax,0x10(%esp)
  80090a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80090e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800915:	00 
  800916:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800921:	e8 57 24 00 00       	call   802d7d <sys_page_map>
  800926:	85 c0                	test   %eax,%eax
  800928:	79 20                	jns    80094a <bc_pgfault+0x15a>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80092a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092e:	c7 44 24 08 78 44 80 	movl   $0x804478,0x8(%esp)
  800935:	00 
  800936:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  80093d:	00 
  80093e:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800945:	e8 4a 19 00 00       	call   802294 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80094a:	83 3d 1c a0 80 00 00 	cmpl   $0x0,0x80a01c
  800951:	74 2c                	je     80097f <bc_pgfault+0x18f>
  800953:	89 34 24             	mov    %esi,(%esp)
  800956:	e8 28 04 00 00       	call   800d83 <block_is_free>
  80095b:	84 c0                	test   %al,%al
  80095d:	74 20                	je     80097f <bc_pgfault+0x18f>
		panic("reading free block %08x\n", blockno);
  80095f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800963:	c7 44 24 08 bd 42 80 	movl   $0x8042bd,0x8(%esp)
  80096a:	00 
  80096b:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
  800972:	00 
  800973:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  80097a:	e8 15 19 00 00       	call   802294 <_panic>
// cprintf("check %x %x %x\n",bitmap,addr,blockno);
#ifdef BUF_CACHE_OPEN
	if ((r = buf_alloc(addr))&&r < 0)
  80097f:	89 1c 24             	mov    %ebx,(%esp)
  800982:	e8 e4 fd ff ff       	call   80076b <buf_alloc>
  800987:	85 c0                	test   %eax,%eax
  800989:	79 20                	jns    8009ab <bc_pgfault+0x1bb>
		panic("in bc_pgfault, buf_alloc: %e", r);
  80098b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098f:	c7 44 24 08 d6 42 80 	movl   $0x8042d6,0x8(%esp)
  800996:	00 
  800997:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  80099e:	00 
  80099f:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  8009a6:	e8 e9 18 00 00       	call   802294 <_panic>
#endif

}
  8009ab:	83 c4 20             	add    $0x20,%esp
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8009bc:	c7 04 24 f0 07 80 00 	movl   $0x8007f0,(%esp)
  8009c3:	e8 cc 25 00 00       	call   802f94 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8009c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009cf:	e8 3f fa ff ff       	call   800413 <diskaddr>
  8009d4:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8009db:	00 
  8009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8009e6:	89 04 24             	mov    %eax,(%esp)
  8009e9:	e8 c2 20 00 00       	call   802ab0 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8009ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009f5:	e8 19 fa ff ff       	call   800413 <diskaddr>
  8009fa:	c7 44 24 04 f3 42 80 	movl   $0x8042f3,0x4(%esp)
  800a01:	00 
  800a02:	89 04 24             	mov    %eax,(%esp)
  800a05:	e8 2d 1f 00 00       	call   802937 <strcpy>
	flush_block(diskaddr(1));
  800a0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a11:	e8 fd f9 ff ff       	call   800413 <diskaddr>
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 7f fa ff ff       	call   80049d <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800a1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a25:	e8 e9 f9 ff ff       	call   800413 <diskaddr>
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	e8 27 fa ff ff       	call   800459 <va_is_mapped>
  800a32:	84 c0                	test   %al,%al
  800a34:	75 24                	jne    800a5a <bc_init+0xa8>
  800a36:	c7 44 24 0c 15 43 80 	movl   $0x804315,0xc(%esp)
  800a3d:	00 
  800a3e:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800a45:	00 
  800a46:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  800a4d:	00 
  800a4e:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800a55:	e8 3a 18 00 00       	call   802294 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800a5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a61:	e8 ad f9 ff ff       	call   800413 <diskaddr>
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 18 fa ff ff       	call   800486 <va_is_dirty>
  800a6e:	84 c0                	test   %al,%al
  800a70:	74 24                	je     800a96 <bc_init+0xe4>
  800a72:	c7 44 24 0c fa 42 80 	movl   $0x8042fa,0xc(%esp)
  800a79:	00 
  800a7a:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800a81:	00 
  800a82:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  800a89:	00 
  800a8a:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800a91:	e8 fe 17 00 00       	call   802294 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800a96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a9d:	e8 71 f9 ff ff       	call   800413 <diskaddr>
  800aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aad:	e8 1e 23 00 00       	call   802dd0 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800ab2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ab9:	e8 55 f9 ff ff       	call   800413 <diskaddr>
  800abe:	89 04 24             	mov    %eax,(%esp)
  800ac1:	e8 93 f9 ff ff       	call   800459 <va_is_mapped>
  800ac6:	84 c0                	test   %al,%al
  800ac8:	74 24                	je     800aee <bc_init+0x13c>
  800aca:	c7 44 24 0c 14 43 80 	movl   $0x804314,0xc(%esp)
  800ad1:	00 
  800ad2:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800ad9:	00 
  800ada:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  800ae1:	00 
  800ae2:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800ae9:	e8 a6 17 00 00       	call   802294 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800aee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800af5:	e8 19 f9 ff ff       	call   800413 <diskaddr>
  800afa:	c7 44 24 04 f3 42 80 	movl   $0x8042f3,0x4(%esp)
  800b01:	00 
  800b02:	89 04 24             	mov    %eax,(%esp)
  800b05:	e8 d4 1e 00 00       	call   8029de <strcmp>
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	74 24                	je     800b32 <bc_init+0x180>
  800b0e:	c7 44 24 0c 98 44 80 	movl   $0x804498,0xc(%esp)
  800b15:	00 
  800b16:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800b1d:	00 
  800b1e:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  800b25:	00 
  800b26:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800b2d:	e8 62 17 00 00       	call   802294 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800b32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b39:	e8 d5 f8 ff ff       	call   800413 <diskaddr>
  800b3e:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800b45:	00 
  800b46:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800b4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b50:	89 04 24             	mov    %eax,(%esp)
  800b53:	e8 58 1f 00 00       	call   802ab0 <memmove>
	flush_block(diskaddr(1));
  800b58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b5f:	e8 af f8 ff ff       	call   800413 <diskaddr>
  800b64:	89 04 24             	mov    %eax,(%esp)
  800b67:	e8 31 f9 ff ff       	call   80049d <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800b6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b73:	e8 9b f8 ff ff       	call   800413 <diskaddr>
  800b78:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800b7f:	00 
  800b80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b84:	89 1c 24             	mov    %ebx,(%esp)
  800b87:	e8 24 1f 00 00       	call   802ab0 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800b8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b93:	e8 7b f8 ff ff       	call   800413 <diskaddr>
  800b98:	c7 44 24 04 f3 42 80 	movl   $0x8042f3,0x4(%esp)
  800b9f:	00 
  800ba0:	89 04 24             	mov    %eax,(%esp)
  800ba3:	e8 8f 1d 00 00       	call   802937 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800ba8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800baf:	e8 5f f8 ff ff       	call   800413 <diskaddr>
  800bb4:	83 c0 14             	add    $0x14,%eax
  800bb7:	89 04 24             	mov    %eax,(%esp)
  800bba:	e8 de f8 ff ff       	call   80049d <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800bbf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800bc6:	e8 48 f8 ff ff       	call   800413 <diskaddr>
  800bcb:	89 04 24             	mov    %eax,(%esp)
  800bce:	e8 86 f8 ff ff       	call   800459 <va_is_mapped>
  800bd3:	84 c0                	test   %al,%al
  800bd5:	75 24                	jne    800bfb <bc_init+0x249>
  800bd7:	c7 44 24 0c 15 43 80 	movl   $0x804315,0xc(%esp)
  800bde:	00 
  800bdf:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800be6:	00 
  800be7:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  800bee:	00 
  800bef:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800bf6:	e8 99 16 00 00       	call   802294 <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800bfb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c02:	e8 0c f8 ff ff       	call   800413 <diskaddr>
  800c07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c12:	e8 b9 21 00 00       	call   802dd0 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800c17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c1e:	e8 f0 f7 ff ff       	call   800413 <diskaddr>
  800c23:	89 04 24             	mov    %eax,(%esp)
  800c26:	e8 2e f8 ff ff       	call   800459 <va_is_mapped>
  800c2b:	84 c0                	test   %al,%al
  800c2d:	74 24                	je     800c53 <bc_init+0x2a1>
  800c2f:	c7 44 24 0c 14 43 80 	movl   $0x804314,0xc(%esp)
  800c36:	00 
  800c37:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  800c46:	00 
  800c47:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800c4e:	e8 41 16 00 00       	call   802294 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800c53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c5a:	e8 b4 f7 ff ff       	call   800413 <diskaddr>
  800c5f:	c7 44 24 04 f3 42 80 	movl   $0x8042f3,0x4(%esp)
  800c66:	00 
  800c67:	89 04 24             	mov    %eax,(%esp)
  800c6a:	e8 6f 1d 00 00       	call   8029de <strcmp>
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	74 24                	je     800c97 <bc_init+0x2e5>
  800c73:	c7 44 24 0c 98 44 80 	movl   $0x804498,0xc(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800c82:	00 
  800c83:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  800c8a:	00 
  800c8b:	c7 04 24 7c 42 80 00 	movl   $0x80427c,(%esp)
  800c92:	e8 fd 15 00 00       	call   802294 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800c97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c9e:	e8 70 f7 ff ff       	call   800413 <diskaddr>
  800ca3:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800caa:	00 
  800cab:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800cb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb5:	89 04 24             	mov    %eax,(%esp)
  800cb8:	e8 f3 1d 00 00       	call   802ab0 <memmove>
	flush_block(diskaddr(1));
  800cbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800cc4:	e8 4a f7 ff ff       	call   800413 <diskaddr>
  800cc9:	89 04 24             	mov    %eax,(%esp)
  800ccc:	e8 cc f7 ff ff       	call   80049d <flush_block>

	cprintf("block cache is good\n");
  800cd1:	c7 04 24 2f 43 80 00 	movl   $0x80432f,(%esp)
  800cd8:	e8 af 16 00 00       	call   80238c <cprintf>
{
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();
#ifdef BUF_CACHE_OPEN
	buf_init();
  800cdd:	e8 86 f6 ff ff       	call   800368 <buf_init>
#endif
	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800ce2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ce9:	e8 25 f7 ff ff       	call   800413 <diskaddr>
  800cee:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800cf5:	00 
  800cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cfa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800d00:	89 04 24             	mov    %eax,(%esp)
  800d03:	e8 a8 1d 00 00       	call   802ab0 <memmove>
  800d08:	81 c4 24 02 00 00    	add    $0x224,%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    
  800d11:	00 00                	add    %al,(%eax)
	...

00800d14 <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  800d17:	eb 01                	jmp    800d1a <skip_slash+0x6>
		p++;
  800d19:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800d1a:	80 38 2f             	cmpb   $0x2f,(%eax)
  800d1d:	74 fa                	je     800d19 <skip_slash+0x5>
		p++;
	return p;
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800d27:	a1 20 a0 80 00       	mov    0x80a020,%eax
  800d2c:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800d32:	74 1c                	je     800d50 <check_super+0x2f>
		panic("bad file system magic number");
  800d34:	c7 44 24 08 c0 44 80 	movl   $0x8044c0,0x8(%esp)
  800d3b:	00 
  800d3c:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800d43:	00 
  800d44:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  800d4b:	e8 44 15 00 00       	call   802294 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800d50:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800d57:	76 1c                	jbe    800d75 <check_super+0x54>
		panic("file system is too large");
  800d59:	c7 44 24 08 e5 44 80 	movl   $0x8044e5,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  800d70:	e8 1f 15 00 00       	call   802294 <_panic>

	cprintf("superblock is good\n");
  800d75:	c7 04 24 fe 44 80 00 	movl   $0x8044fe,(%esp)
  800d7c:	e8 0b 16 00 00       	call   80238c <cprintf>
}
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    

00800d83 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800d89:	a1 20 a0 80 00       	mov    0x80a020,%eax
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	74 1d                	je     800daf <block_is_free+0x2c>
  800d92:	39 48 04             	cmp    %ecx,0x4(%eax)
  800d95:	76 1c                	jbe    800db3 <block_is_free+0x30>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800d97:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9c:	d3 e0                	shl    %cl,%eax
  800d9e:	c1 e9 05             	shr    $0x5,%ecx
// --------------------------------------------------------------

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
  800da1:	8b 15 1c a0 80 00    	mov    0x80a01c,%edx
  800da7:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  800daa:	0f 95 c0             	setne  %al
  800dad:	eb 06                	jmp    800db5 <block_is_free+0x32>
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800daf:	b0 00                	mov    $0x0,%al
  800db1:	eb 02                	jmp    800db5 <block_is_free+0x32>
  800db3:	b0 00                	mov    $0x0,%al
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 14             	sub    $0x14,%esp
  800dbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800dc1:	85 db                	test   %ebx,%ebx
  800dc3:	75 1c                	jne    800de1 <free_block+0x2a>
		panic("attempt to free zero block");
  800dc5:	c7 44 24 08 12 45 80 	movl   $0x804512,0x8(%esp)
  800dcc:	00 
  800dcd:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800dd4:	00 
  800dd5:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  800ddc:	e8 b3 14 00 00       	call   802294 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800de1:	89 d8                	mov    %ebx,%eax
  800de3:	c1 e8 05             	shr    $0x5,%eax
  800de6:	c1 e0 02             	shl    $0x2,%eax
  800de9:	03 05 1c a0 80 00    	add    0x80a01c,%eax
  800def:	ba 01 00 00 00       	mov    $0x1,%edx
  800df4:	89 d9                	mov    %ebx,%ecx
  800df6:	d3 e2                	shl    %cl,%edx
  800df8:	09 10                	or     %edx,(%eax)
	
#ifdef BUF_CACHE_OPEN
	int r;
	if ((r = sys_page_unmap(0, diskaddr(blockno)))&&r < 0)
  800dfa:	89 1c 24             	mov    %ebx,(%esp)
  800dfd:	e8 11 f6 ff ff       	call   800413 <diskaddr>
  800e02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e0d:	e8 be 1f 00 00       	call   802dd0 <sys_page_unmap>
  800e12:	85 c0                	test   %eax,%eax
  800e14:	79 20                	jns    800e36 <free_block+0x7f>
		panic("free_block: %e", r);
  800e16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1a:	c7 44 24 08 a0 45 80 	movl   $0x8045a0,0x8(%esp)
  800e21:	00 
  800e22:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800e29:	00 
  800e2a:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  800e31:	e8 5e 14 00 00       	call   802294 <_panic>
	extern int buf_delete(void*);
	if ((r=buf_delete(diskaddr(blockno)))&&r<0)
  800e36:	89 1c 24             	mov    %ebx,(%esp)
  800e39:	e8 d5 f5 ff ff       	call   800413 <diskaddr>
  800e3e:	89 04 24             	mov    %eax,(%esp)
  800e41:	e8 7f f5 ff ff       	call   8003c5 <buf_delete>
  800e46:	85 c0                	test   %eax,%eax
  800e48:	79 20                	jns    800e6a <free_block+0xb3>
		panic("free_block: %e", r);
  800e4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4e:	c7 44 24 08 a0 45 80 	movl   $0x8045a0,0x8(%esp)
  800e55:	00 
  800e56:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  800e5d:	00 
  800e5e:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  800e65:	e8 2a 14 00 00       	call   802294 <_panic>

#endif	
	//cprintf("free_block %x\n",blockno);
}
  800e6a:	83 c4 14             	add    $0x14,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 1c             	sub    $0x1c,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	int free_block = 2;
  800e79:	bb 02 00 00 00       	mov    $0x2,%ebx
	while (free_block < super->s_nblocks && !block_is_free(free_block))free_block++;
  800e7e:	eb 01                	jmp    800e81 <alloc_block+0x11>
  800e80:	43                   	inc    %ebx
  800e81:	89 df                	mov    %ebx,%edi
  800e83:	a1 20 a0 80 00       	mov    0x80a020,%eax
  800e88:	8b 70 04             	mov    0x4(%eax),%esi
  800e8b:	39 f3                	cmp    %esi,%ebx
  800e8d:	73 10                	jae    800e9f <alloc_block+0x2f>
  800e8f:	89 1c 24             	mov    %ebx,(%esp)
  800e92:	e8 ec fe ff ff       	call   800d83 <block_is_free>
  800e97:	84 c0                	test   %al,%al
  800e99:	74 e5                	je     800e80 <alloc_block+0x10>
  800e9b:	89 d9                	mov    %ebx,%ecx
  800e9d:	eb 02                	jmp    800ea1 <alloc_block+0x31>
  800e9f:	89 d9                	mov    %ebx,%ecx
	if (free_block == super->s_nblocks)return -E_NO_DISK;
  800ea1:	39 f7                	cmp    %esi,%edi
  800ea3:	74 3d                	je     800ee2 <alloc_block+0x72>
	bitmap[free_block/32] &= ~(1<<(free_block%32));
  800ea5:	89 c8                	mov    %ecx,%eax
  800ea7:	85 c9                	test   %ecx,%ecx
  800ea9:	79 03                	jns    800eae <alloc_block+0x3e>
  800eab:	8d 41 1f             	lea    0x1f(%ecx),%eax
  800eae:	c1 f8 05             	sar    $0x5,%eax
  800eb1:	c1 e0 02             	shl    $0x2,%eax
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	03 15 1c a0 80 00    	add    0x80a01c,%edx
  800ebc:	81 e1 1f 00 00 80    	and    $0x8000001f,%ecx
  800ec2:	79 05                	jns    800ec9 <alloc_block+0x59>
  800ec4:	49                   	dec    %ecx
  800ec5:	83 c9 e0             	or     $0xffffffe0,%ecx
  800ec8:	41                   	inc    %ecx
  800ec9:	be fe ff ff ff       	mov    $0xfffffffe,%esi
  800ece:	d3 c6                	rol    %cl,%esi
  800ed0:	21 32                	and    %esi,(%edx)
	flush_block(&bitmap[free_block/32]);
  800ed2:	03 05 1c a0 80 00    	add    0x80a01c,%eax
  800ed8:	89 04 24             	mov    %eax,(%esp)
  800edb:	e8 bd f5 ff ff       	call   80049d <flush_block>
	return free_block;
  800ee0:	eb 05                	jmp    800ee7 <alloc_block+0x77>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	int free_block = 2;
	while (free_block < super->s_nblocks && !block_is_free(free_block))free_block++;
	if (free_block == super->s_nblocks)return -E_NO_DISK;
  800ee2:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
	flush_block(&bitmap[free_block/32]);
	return free_block;
	
	panic("alloc_block not implemented");
	return -E_NO_DISK;
}
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	83 c4 1c             	add    $0x1c,%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 2c             	sub    $0x2c,%esp
  800efa:	89 c6                	mov    %eax,%esi
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800f01:	8a 45 08             	mov    0x8(%ebp),%al
	// LAB 5: Your code here.
	int r;
	if (filebno >= NDIRECT + NINDIRECT)
  800f04:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800f0a:	77 68                	ja     800f74 <file_block_walk+0x83>
		return -E_INVAL;
	if (filebno >= NDIRECT && f->f_indirect == 0){
  800f0c:	83 fa 09             	cmp    $0x9,%edx
  800f0f:	76 50                	jbe    800f61 <file_block_walk+0x70>
  800f11:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  800f18:	75 70                	jne    800f8a <file_block_walk+0x99>
		if (!alloc)return -E_NOT_FOUND;
  800f1a:	84 c0                	test   %al,%al
  800f1c:	74 5d                	je     800f7b <file_block_walk+0x8a>
		if ((r = alloc_block()) < 0)return r;
  800f1e:	e8 4d ff ff ff       	call   800e70 <alloc_block>
  800f23:	89 c3                	mov    %eax,%ebx
  800f25:	85 c0                	test   %eax,%eax
  800f27:	78 57                	js     800f80 <file_block_walk+0x8f>

		f->f_indirect = r;
  800f29:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
		memset(diskaddr(r),0,BLKSIZE);
  800f2f:	89 04 24             	mov    %eax,(%esp)
  800f32:	e8 dc f4 ff ff       	call   800413 <diskaddr>
  800f37:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f46:	00 
  800f47:	89 04 24             	mov    %eax,(%esp)
  800f4a:	e8 17 1b 00 00       	call   802a66 <memset>
		flush_block(diskaddr(r));
  800f4f:	89 1c 24             	mov    %ebx,(%esp)
  800f52:	e8 bc f4 ff ff       	call   800413 <diskaddr>
  800f57:	89 04 24             	mov    %eax,(%esp)
  800f5a:	e8 3e f5 ff ff       	call   80049d <flush_block>
  800f5f:	eb 29                	jmp    800f8a <file_block_walk+0x99>
	}
	*ppdiskbno = (filebno < NDIRECT)?&f->f_direct[filebno]:(uint32_t*)diskaddr(f->f_indirect)+(filebno - NDIRECT);
  800f61:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  800f68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f6b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f72:	eb 0c                	jmp    800f80 <file_block_walk+0x8f>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	// LAB 5: Your code here.
	int r;
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800f74:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  800f79:	eb 05                	jmp    800f80 <file_block_walk+0x8f>
	if (filebno >= NDIRECT && f->f_indirect == 0){
		if (!alloc)return -E_NOT_FOUND;
  800f7b:	bb f5 ff ff ff       	mov    $0xfffffff5,%ebx
		flush_block(diskaddr(r));
	}
	*ppdiskbno = (filebno < NDIRECT)?&f->f_direct[filebno]:(uint32_t*)diskaddr(f->f_indirect)+(filebno - NDIRECT);
	return 0;
    panic("file_block_walk not implemented");
}
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	83 c4 2c             	add    $0x2c,%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

		f->f_indirect = r;
		memset(diskaddr(r),0,BLKSIZE);
		flush_block(diskaddr(r));
	}
	*ppdiskbno = (filebno < NDIRECT)?&f->f_direct[filebno]:(uint32_t*)diskaddr(f->f_indirect)+(filebno - NDIRECT);
  800f8a:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f90:	89 04 24             	mov    %eax,(%esp)
  800f93:	e8 7b f4 ff ff       	call   800413 <diskaddr>
  800f98:	8d 44 b8 d8          	lea    -0x28(%eax,%edi,4),%eax
  800f9c:	eb ca                	jmp    800f68 <file_block_walk+0x77>

00800f9e <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 14             	sub    $0x14,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800faa:	eb 34                	jmp    800fe0 <check_bitmap+0x42>
		assert(!block_is_free(2+i));
  800fac:	8d 43 02             	lea    0x2(%ebx),%eax
  800faf:	89 04 24             	mov    %eax,(%esp)
  800fb2:	e8 cc fd ff ff       	call   800d83 <block_is_free>
  800fb7:	84 c0                	test   %al,%al
  800fb9:	74 24                	je     800fdf <check_bitmap+0x41>
  800fbb:	c7 44 24 0c 2d 45 80 	movl   $0x80452d,0xc(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  800fda:	e8 b5 12 00 00       	call   802294 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800fdf:	43                   	inc    %ebx
  800fe0:	89 da                	mov    %ebx,%edx
  800fe2:	c1 e2 0f             	shl    $0xf,%edx
  800fe5:	a1 20 a0 80 00       	mov    0x80a020,%eax
  800fea:	3b 50 04             	cmp    0x4(%eax),%edx
  800fed:	72 bd                	jb     800fac <check_bitmap+0xe>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800fef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff6:	e8 88 fd ff ff       	call   800d83 <block_is_free>
  800ffb:	84 c0                	test   %al,%al
  800ffd:	74 24                	je     801023 <check_bitmap+0x85>
  800fff:	c7 44 24 0c 41 45 80 	movl   $0x804541,0xc(%esp)
  801006:	00 
  801007:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  80100e:	00 
  80100f:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  801016:	00 
  801017:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  80101e:	e8 71 12 00 00       	call   802294 <_panic>
	assert(!block_is_free(1));
  801023:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80102a:	e8 54 fd ff ff       	call   800d83 <block_is_free>
  80102f:	84 c0                	test   %al,%al
  801031:	74 24                	je     801057 <check_bitmap+0xb9>
  801033:	c7 44 24 0c 53 45 80 	movl   $0x804553,0xc(%esp)
  80103a:	00 
  80103b:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  801042:	00 
  801043:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  80104a:	00 
  80104b:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  801052:	e8 3d 12 00 00       	call   802294 <_panic>

	cprintf("bitmap is good\n");
  801057:	c7 04 24 65 45 80 00 	movl   $0x804565,(%esp)
  80105e:	e8 29 13 00 00       	call   80238c <cprintf>
}
  801063:	83 c4 14             	add    $0x14,%esp
  801066:	5b                   	pop    %ebx
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  80106f:	e8 f4 ef ff ff       	call   800068 <ide_probe_disk1>
  801074:	84 c0                	test   %al,%al
  801076:	74 0e                	je     801086 <fs_init+0x1d>
		ide_set_disk(1);
  801078:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80107f:	e8 47 f0 ff ff       	call   8000cb <ide_set_disk>
  801084:	eb 0c                	jmp    801092 <fs_init+0x29>
	else
		ide_set_disk(0);
  801086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108d:	e8 39 f0 ff ff       	call   8000cb <ide_set_disk>
	bc_init();
  801092:	e8 1b f9 ff ff       	call   8009b2 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  801097:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80109e:	e8 70 f3 ff ff       	call   800413 <diskaddr>
  8010a3:	a3 20 a0 80 00       	mov    %eax,0x80a020
	check_super();
  8010a8:	e8 74 fc ff ff       	call   800d21 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8010ad:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8010b4:	e8 5a f3 ff ff       	call   800413 <diskaddr>
  8010b9:	a3 1c a0 80 00       	mov    %eax,0x80a01c
	check_bitmap();
  8010be:	e8 db fe ff ff       	call   800f9e <check_bitmap>
	
}
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 28             	sub    $0x28,%esp
	// LAB 5: Your code here.
	// cprintf("file_get_block: find\n");
	// cprintf("%x\n",filebno);
	int r;
	uint32_t *pdiskbno;
	if ((r = file_block_walk(f,filebno,&pdiskbno,true)) < 0)
  8010cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010d2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  8010d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	e8 11 fe ff ff       	call   800ef1 <file_block_walk>
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 46                	js     80112a <file_get_block+0x65>
		return r;
	// cprintf("file_get_block: find\n");
	if (*pdiskbno == 0){
  8010e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e7:	83 38 00             	cmpl   $0x0,(%eax)
  8010ea:	75 1e                	jne    80110a <file_get_block+0x45>
		if ((r = alloc_block()) < 0)
  8010ec:	e8 7f fd ff ff       	call   800e70 <alloc_block>
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 35                	js     80112a <file_get_block+0x65>
			return r;
		*pdiskbno = r;
  8010f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f8:	89 02                	mov    %eax,(%edx)
		flush_block(diskaddr(r));
  8010fa:	89 04 24             	mov    %eax,(%esp)
  8010fd:	e8 11 f3 ff ff       	call   800413 <diskaddr>
  801102:	89 04 24             	mov    %eax,(%esp)
  801105:	e8 93 f3 ff ff       	call   80049d <flush_block>
	}
	// cprintf("file_get_block: find\n");
	*blk = diskaddr(*pdiskbno);
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	8b 00                	mov    (%eax),%eax
  80110f:	89 04 24             	mov    %eax,(%esp)
  801112:	e8 fc f2 ff ff       	call   800413 <diskaddr>
  801117:	8b 55 10             	mov    0x10(%ebp),%edx
  80111a:	89 02                	mov    %eax,(%edx)
#ifdef BUF_CACHE_OPEN
	extern int buf_visit();
	if ((r=buf_visit())&&r<0)
  80111c:	e8 84 f4 ff ff       	call   8005a5 <buf_visit>
  801121:	85 c0                	test   %eax,%eax
  801123:	7e 05                	jle    80112a <file_get_block+0x65>
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
		return r;
#endif
	return 0;
    panic("file_get_block not implemented");
}
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  801138:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  80113e:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  801144:	e8 cb fb ff ff       	call   800d14 <skip_slash>
  801149:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	f = &super->s_root;
  80114f:	a1 20 a0 80 00       	mov    0x80a020,%eax
  801154:	83 c0 08             	add    $0x8,%eax
  801157:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
	dir = 0;
	name[0] = 0;
  80115d:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  801164:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  80116b:	74 0c                	je     801179 <walk_path+0x4d>
		*pdir = 0;
  80116d:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  801173:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  801179:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  80117f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  80118a:	e9 95 01 00 00       	jmp    801324 <walk_path+0x1f8>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  80118f:	46                   	inc    %esi
  801190:	eb 06                	jmp    801198 <walk_path+0x6c>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  801192:	8b b5 4c ff ff ff    	mov    -0xb4(%ebp),%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  801198:	8a 06                	mov    (%esi),%al
  80119a:	3c 2f                	cmp    $0x2f,%al
  80119c:	74 04                	je     8011a2 <walk_path+0x76>
  80119e:	84 c0                	test   %al,%al
  8011a0:	75 ed                	jne    80118f <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  8011a2:	89 f3                	mov    %esi,%ebx
  8011a4:	2b 9d 4c ff ff ff    	sub    -0xb4(%ebp),%ebx
  8011aa:	83 fb 7f             	cmp    $0x7f,%ebx
  8011ad:	0f 8f a6 01 00 00    	jg     801359 <walk_path+0x22d>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8011b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011b7:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  8011bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c1:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  8011c7:	89 14 24             	mov    %edx,(%esp)
  8011ca:	e8 e1 18 00 00       	call   802ab0 <memmove>
		name[path - p] = '\0';
  8011cf:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  8011d6:	00 
		path = skip_slash(path);
  8011d7:	89 f0                	mov    %esi,%eax
  8011d9:	e8 36 fb ff ff       	call   800d14 <skip_slash>
  8011de:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)

		if (dir->f_type != FTYPE_DIR)
  8011e4:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  8011ea:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8011f1:	0f 85 69 01 00 00    	jne    801360 <walk_path+0x234>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  8011f7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8011fd:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801202:	74 24                	je     801228 <walk_path+0xfc>
  801204:	c7 44 24 0c 75 45 80 	movl   $0x804575,0xc(%esp)
  80120b:	00 
  80120c:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  801213:	00 
  801214:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  80121b:	00 
  80121c:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  801223:	e8 6c 10 00 00       	call   802294 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801228:	89 c2                	mov    %eax,%edx
  80122a:	85 c0                	test   %eax,%eax
  80122c:	79 06                	jns    801234 <walk_path+0x108>
  80122e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801234:	c1 fa 0c             	sar    $0xc,%edx
  801237:	89 95 48 ff ff ff    	mov    %edx,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  80123d:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  801244:	00 00 00 
  801247:	eb 62                	jmp    8012ab <walk_path+0x17f>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801249:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  80124f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801253:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  801259:	89 54 24 04          	mov    %edx,0x4(%esp)
  80125d:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  801263:	89 04 24             	mov    %eax,(%esp)
  801266:	e8 5a fe ff ff       	call   8010c5 <file_get_block>
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 4c                	js     8012bb <walk_path+0x18f>
			return r;
		f = (struct File*) blk;
  80126f:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
  801275:	bb 00 00 00 00       	mov    $0x0,%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  80127a:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
  80127d:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  801283:	89 54 24 04          	mov    %edx,0x4(%esp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  801287:	89 34 24             	mov    %esi,(%esp)
  80128a:	e8 4f 17 00 00       	call   8029de <strcmp>
  80128f:	85 c0                	test   %eax,%eax
  801291:	0f 84 81 00 00 00    	je     801318 <walk_path+0x1ec>
  801297:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  80129d:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8012a3:	75 d5                	jne    80127a <walk_path+0x14e>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8012a5:	ff 85 54 ff ff ff    	incl   -0xac(%ebp)
  8012ab:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  8012b1:	39 85 48 ff ff ff    	cmp    %eax,-0xb8(%ebp)
  8012b7:	75 90                	jne    801249 <walk_path+0x11d>
  8012b9:	eb 09                	jmp    8012c4 <walk_path+0x198>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  8012bb:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8012be:	0f 85 a8 00 00 00    	jne    80136c <walk_path+0x240>
  8012c4:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  8012ca:	80 38 00             	cmpb   $0x0,(%eax)
  8012cd:	0f 85 94 00 00 00    	jne    801367 <walk_path+0x23b>
				if (pdir)
  8012d3:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  8012da:	74 0e                	je     8012ea <walk_path+0x1be>
					*pdir = dir;
  8012dc:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  8012e2:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  8012e8:	89 02                	mov    %eax,(%edx)
				if (lastelem)
  8012ea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8012ee:	74 15                	je     801305 <walk_path+0x1d9>
					strcpy(lastelem, name);
  8012f0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fd:	89 14 24             	mov    %edx,(%esp)
  801300:	e8 32 16 00 00       	call   802937 <strcpy>
				*pf = 0;
  801305:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  80130b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  801311:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801316:	eb 54                	jmp    80136c <walk_path+0x240>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  801318:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  80131e:	89 b5 50 ff ff ff    	mov    %esi,-0xb0(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  801324:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  80132a:	80 3a 00             	cmpb   $0x0,(%edx)
  80132d:	0f 85 5f fe ff ff    	jne    801192 <walk_path+0x66>
			}
			return r;
		}
	}

	if (pdir)
  801333:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  80133a:	74 08                	je     801344 <walk_path+0x218>
		*pdir = dir;
  80133c:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  801342:	89 02                	mov    %eax,(%edx)
	*pf = f;
  801344:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  80134a:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  801350:	89 10                	mov    %edx,(%eax)
	return 0;
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
  801357:	eb 13                	jmp    80136c <walk_path+0x240>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  801359:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80135e:	eb 0c                	jmp    80136c <walk_path+0x240>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  801360:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801365:	eb 05                	jmp    80136c <walk_path+0x240>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  801367:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  80136c:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  80137d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801384:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801387:	ba 00 00 00 00       	mov    $0x0,%edx
  80138c:	8b 45 08             	mov    0x8(%ebp),%eax
  80138f:	e8 98 fd ff ff       	call   80112c <walk_path>
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	57                   	push   %edi
  80139a:	56                   	push   %esi
  80139b:	53                   	push   %ebx
  80139c:	83 ec 3c             	sub    $0x3c,%esp
  80139f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013a5:	8b 45 14             	mov    0x14(%ebp),%eax
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8013a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013ab:	8b 93 80 00 00 00    	mov    0x80(%ebx),%edx
  8013b1:	39 c2                	cmp    %eax,%edx
  8013b3:	0f 8e 8a 00 00 00    	jle    801443 <file_read+0xad>
		return 0;

	count = MIN(count, f->f_size - offset);
  8013b9:	29 c2                	sub    %eax,%edx
  8013bb:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8013be:	39 ca                	cmp    %ecx,%edx
  8013c0:	76 03                	jbe    8013c5 <file_read+0x2f>
  8013c2:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  8013c5:	89 c3                	mov    %eax,%ebx
  8013c7:	03 45 d0             	add    -0x30(%ebp),%eax
  8013ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8013cd:	eb 68                	jmp    801437 <file_read+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  8013cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d6:	89 d8                	mov    %ebx,%eax
  8013d8:	85 db                	test   %ebx,%ebx
  8013da:	79 06                	jns    8013e2 <file_read+0x4c>
  8013dc:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8013e2:	c1 f8 0c             	sar    $0xc,%eax
  8013e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ec:	89 04 24             	mov    %eax,(%esp)
  8013ef:	e8 d1 fc ff ff       	call   8010c5 <file_get_block>
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 50                	js     801448 <file_read+0xb2>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  8013ff:	79 07                	jns    801408 <file_read+0x72>
  801401:	48                   	dec    %eax
  801402:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  801407:	40                   	inc    %eax
  801408:	89 c2                	mov    %eax,%edx
  80140a:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80140f:	29 c1                	sub    %eax,%ecx
  801411:	89 c8                	mov    %ecx,%eax
  801413:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801416:	29 f1                	sub    %esi,%ecx
  801418:	89 c6                	mov    %eax,%esi
  80141a:	39 c8                	cmp    %ecx,%eax
  80141c:	76 02                	jbe    801420 <file_read+0x8a>
  80141e:	89 ce                	mov    %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  801420:	89 74 24 08          	mov    %esi,0x8(%esp)
  801424:	03 55 e4             	add    -0x1c(%ebp),%edx
  801427:	89 54 24 04          	mov    %edx,0x4(%esp)
  80142b:	89 3c 24             	mov    %edi,(%esp)
  80142e:	e8 7d 16 00 00       	call   802ab0 <memmove>
		pos += bn;
  801433:	01 f3                	add    %esi,%ebx
		buf += bn;
  801435:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  801437:	89 de                	mov    %ebx,%esi
  801439:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  80143c:	72 91                	jb     8013cf <file_read+0x39>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  80143e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801441:	eb 05                	jmp    801448 <file_read+0xb2>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  801443:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  801448:	83 c4 3c             	add    $0x3c,%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5f                   	pop    %edi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	57                   	push   %edi
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
  801456:	83 ec 3c             	sub    $0x3c,%esp
  801459:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  80145c:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  801462:	3b 45 0c             	cmp    0xc(%ebp),%eax
  801465:	0f 8e 9c 00 00 00    	jle    801507 <file_set_size+0xb7>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  80146b:	05 ff 0f 00 00       	add    $0xfff,%eax
  801470:	89 c7                	mov    %eax,%edi
  801472:	85 c0                	test   %eax,%eax
  801474:	79 06                	jns    80147c <file_set_size+0x2c>
  801476:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
  80147c:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  80147f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801482:	05 ff 0f 00 00       	add    $0xfff,%eax
  801487:	89 c2                	mov    %eax,%edx
  801489:	85 c0                	test   %eax,%eax
  80148b:	79 06                	jns    801493 <file_set_size+0x43>
  80148d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801493:	c1 fa 0c             	sar    $0xc,%edx
  801496:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  801499:	89 d3                	mov    %edx,%ebx
  80149b:	eb 44                	jmp    8014e1 <file_set_size+0x91>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  80149d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8014a7:	89 da                	mov    %ebx,%edx
  8014a9:	89 f0                	mov    %esi,%eax
  8014ab:	e8 41 fa ff ff       	call   800ef1 <file_block_walk>
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 1c                	js     8014d0 <file_set_size+0x80>
		return r;
	if (*ptr) {
  8014b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b7:	8b 00                	mov    (%eax),%eax
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	74 23                	je     8014e0 <file_set_size+0x90>
		free_block(*ptr);
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	e8 f2 f8 ff ff       	call   800db7 <free_block>
		*ptr = 0;
  8014c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8014ce:	eb 10                	jmp    8014e0 <file_set_size+0x90>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  8014d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d4:	c7 04 24 92 45 80 00 	movl   $0x804592,(%esp)
  8014db:	e8 ac 0e 00 00       	call   80238c <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  8014e0:	43                   	inc    %ebx
  8014e1:	39 df                	cmp    %ebx,%edi
  8014e3:	77 b8                	ja     80149d <file_set_size+0x4d>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  8014e5:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  8014e9:	77 1c                	ja     801507 <file_set_size+0xb7>
  8014eb:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	74 12                	je     801507 <file_set_size+0xb7>
		free_block(f->f_indirect);
  8014f5:	89 04 24             	mov    %eax,(%esp)
  8014f8:	e8 ba f8 ff ff       	call   800db7 <free_block>
		f->f_indirect = 0;
  8014fd:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  801504:	00 00 00 
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  801507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150a:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  801510:	89 34 24             	mov    %esi,(%esp)
  801513:	e8 85 ef ff ff       	call   80049d <flush_block>
	return 0;
}
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
  80151d:	83 c4 3c             	add    $0x3c,%esp
  801520:	5b                   	pop    %ebx
  801521:	5e                   	pop    %esi
  801522:	5f                   	pop    %edi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	57                   	push   %edi
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	83 ec 3c             	sub    $0x3c,%esp
  80152e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801531:	8b 5d 14             	mov    0x14(%ebp),%ebx
	off_t pos;
	char *blk;

	// Extend file if necessary
	// cprintf("find\n");
	if (offset + count > f->f_size)
  801534:	8b 45 10             	mov    0x10(%ebp),%eax
  801537:	01 d8                	add    %ebx,%eax
  801539:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80153c:	8b 55 08             	mov    0x8(%ebp),%edx
  80153f:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  801545:	76 7a                	jbe    8015c1 <file_write+0x9c>
		if ((r = file_set_size(f, offset + count)) < 0)
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	89 14 24             	mov    %edx,(%esp)
  80154e:	e8 fd fe ff ff       	call   801450 <file_set_size>
  801553:	85 c0                	test   %eax,%eax
  801555:	79 6a                	jns    8015c1 <file_write+0x9c>
  801557:	eb 72                	jmp    8015cb <file_write+0xa6>
			return r;

	// cprintf("find\n");
	for (pos = offset; pos < offset + count; ) {
		// cprintf("%x\n",pos);
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0){
  801559:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80155c:	89 54 24 08          	mov    %edx,0x8(%esp)
  801560:	89 d8                	mov    %ebx,%eax
  801562:	85 db                	test   %ebx,%ebx
  801564:	79 06                	jns    80156c <file_write+0x47>
  801566:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80156c:	c1 f8 0c             	sar    $0xc,%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801576:	89 0c 24             	mov    %ecx,(%esp)
  801579:	e8 47 fb ff ff       	call   8010c5 <file_get_block>
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 49                	js     8015cb <file_write+0xa6>
			return r;
		}
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  801582:	89 d8                	mov    %ebx,%eax
  801584:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  801589:	79 07                	jns    801592 <file_write+0x6d>
  80158b:	48                   	dec    %eax
  80158c:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  801591:	40                   	inc    %eax
  801592:	89 c2                	mov    %eax,%edx
  801594:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801599:	29 c1                	sub    %eax,%ecx
  80159b:	89 c8                	mov    %ecx,%eax
  80159d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8015a0:	29 f1                	sub    %esi,%ecx
  8015a2:	89 c6                	mov    %eax,%esi
  8015a4:	39 c8                	cmp    %ecx,%eax
  8015a6:	76 02                	jbe    8015aa <file_write+0x85>
  8015a8:	89 ce                	mov    %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  8015aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015b2:	03 55 e4             	add    -0x1c(%ebp),%edx
  8015b5:	89 14 24             	mov    %edx,(%esp)
  8015b8:	e8 f3 14 00 00       	call   802ab0 <memmove>
		pos += bn;
  8015bd:	01 f3                	add    %esi,%ebx
		buf += bn;
  8015bf:	01 f7                	add    %esi,%edi
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	// cprintf("find\n");
	for (pos = offset; pos < offset + count; ) {
  8015c1:	89 de                	mov    %ebx,%esi
  8015c3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  8015c6:	77 91                	ja     801559 <file_write+0x34>
		pos += bn;
		buf += bn;
	}

	// cprintf("find\n");
	return count;
  8015c8:	8b 45 10             	mov    0x10(%ebp),%eax
}
  8015cb:	83 c4 3c             	add    $0x3c,%esp
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	5f                   	pop    %edi
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 20             	sub    $0x20,%esp
  8015db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  8015de:	be 00 00 00 00       	mov    $0x0,%esi
  8015e3:	eb 35                	jmp    80161a <file_flush+0x47>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  8015e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ec:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  8015ef:	89 f2                	mov    %esi,%edx
  8015f1:	89 d8                	mov    %ebx,%eax
  8015f3:	e8 f9 f8 ff ff       	call   800ef1 <file_block_walk>
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 1d                	js     801619 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  8015fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  8015ff:	85 c0                	test   %eax,%eax
  801601:	74 16                	je     801619 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  801603:	8b 00                	mov    (%eax),%eax
  801605:	85 c0                	test   %eax,%eax
  801607:	74 10                	je     801619 <file_flush+0x46>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801609:	89 04 24             	mov    %eax,(%esp)
  80160c:	e8 02 ee ff ff       	call   800413 <diskaddr>
  801611:	89 04 24             	mov    %eax,(%esp)
  801614:	e8 84 ee ff ff       	call   80049d <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801619:	46                   	inc    %esi
  80161a:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  801620:	05 ff 0f 00 00       	add    $0xfff,%eax
  801625:	89 c2                	mov    %eax,%edx
  801627:	85 c0                	test   %eax,%eax
  801629:	79 06                	jns    801631 <file_flush+0x5e>
  80162b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801631:	c1 fa 0c             	sar    $0xc,%edx
  801634:	39 d6                	cmp    %edx,%esi
  801636:	7c ad                	jl     8015e5 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  801638:	89 1c 24             	mov    %ebx,(%esp)
  80163b:	e8 5d ee ff ff       	call   80049d <flush_block>
	if (f->f_indirect)
  801640:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  801646:	85 c0                	test   %eax,%eax
  801648:	74 10                	je     80165a <file_flush+0x87>
		flush_block(diskaddr(f->f_indirect));
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	e8 c1 ed ff ff       	call   800413 <diskaddr>
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 43 ee ff ff       	call   80049d <flush_block>
}
  80165a:	83 c4 20             	add    $0x20,%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	57                   	push   %edi
  801665:	56                   	push   %esi
  801666:	53                   	push   %ebx
  801667:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80166d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801673:	89 04 24             	mov    %eax,(%esp)
  801676:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  80167c:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	e8 a2 fa ff ff       	call   80112c <walk_path>
  80168a:	85 c0                	test   %eax,%eax
  80168c:	0f 84 dc 00 00 00    	je     80176e <file_create+0x10d>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801692:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801695:	0f 85 d8 00 00 00    	jne    801773 <file_create+0x112>
  80169b:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  8016a1:	85 db                	test   %ebx,%ebx
  8016a3:	0f 84 ca 00 00 00    	je     801773 <file_create+0x112>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  8016a9:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  8016af:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8016b4:	74 24                	je     8016da <file_create+0x79>
  8016b6:	c7 44 24 0c 75 45 80 	movl   $0x804575,0xc(%esp)
  8016bd:	00 
  8016be:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  8016c5:	00 
  8016c6:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  8016cd:	00 
  8016ce:	c7 04 24 dd 44 80 00 	movl   $0x8044dd,(%esp)
  8016d5:	e8 ba 0b 00 00       	call   802294 <_panic>
	nblock = dir->f_size / BLKSIZE;
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	79 06                	jns    8016e6 <file_create+0x85>
  8016e0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8016e6:	c1 fa 0c             	sar    $0xc,%edx
  8016e9:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8016ef:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8016f4:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8016fa:	eb 38                	jmp    801734 <file_create+0xd3>
  8016fc:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801700:	89 74 24 04          	mov    %esi,0x4(%esp)
  801704:	89 1c 24             	mov    %ebx,(%esp)
  801707:	e8 b9 f9 ff ff       	call   8010c5 <file_get_block>
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 63                	js     801773 <file_create+0x112>
  801710:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801716:	ba 00 00 00 00       	mov    $0x0,%edx
			if (f[j].f_name[0] == '\0') {
  80171b:	80 38 00             	cmpb   $0x0,(%eax)
  80171e:	75 08                	jne    801728 <file_create+0xc7>
				*file = &f[j];
  801720:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801726:	eb 56                	jmp    80177e <file_create+0x11d>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801728:	42                   	inc    %edx
  801729:	05 00 01 00 00       	add    $0x100,%eax
  80172e:	83 fa 10             	cmp    $0x10,%edx
  801731:	75 e8                	jne    80171b <file_create+0xba>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  801733:	46                   	inc    %esi
  801734:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  80173a:	75 c0                	jne    8016fc <file_create+0x9b>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  80173c:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  801743:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801746:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  80174c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801750:	89 74 24 04          	mov    %esi,0x4(%esp)
  801754:	89 1c 24             	mov    %ebx,(%esp)
  801757:	e8 69 f9 ff ff       	call   8010c5 <file_get_block>
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 13                	js     801773 <file_create+0x112>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801760:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801766:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80176c:	eb 10                	jmp    80177e <file_create+0x11d>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  80176e:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  801773:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5f                   	pop    %edi
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  80177e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801784:	89 44 24 04          	mov    %eax,0x4(%esp)
  801788:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  80178e:	89 04 24             	mov    %eax,(%esp)
  801791:	e8 a1 11 00 00       	call   802937 <strcpy>
	*pf = f;
  801796:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80179c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179f:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8017a1:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8017a7:	89 04 24             	mov    %eax,(%esp)
  8017aa:	e8 24 fe ff ff       	call   8015d3 <file_flush>
	return 0;
  8017af:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b4:	eb bd                	jmp    801773 <file_create+0x112>

008017b6 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8017bd:	bb 01 00 00 00       	mov    $0x1,%ebx
  8017c2:	eb 11                	jmp    8017d5 <fs_sync+0x1f>
		flush_block(diskaddr(i));
  8017c4:	89 1c 24             	mov    %ebx,(%esp)
  8017c7:	e8 47 ec ff ff       	call   800413 <diskaddr>
  8017cc:	89 04 24             	mov    %eax,(%esp)
  8017cf:	e8 c9 ec ff ff       	call   80049d <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8017d4:	43                   	inc    %ebx
  8017d5:	a1 20 a0 80 00       	mov    0x80a020,%eax
  8017da:	3b 58 04             	cmp    0x4(%eax),%ebx
  8017dd:	72 e5                	jb     8017c4 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  8017df:	83 c4 14             	add    $0x14,%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    
  8017e5:	00 00                	add    %al,(%eax)
	...

008017e8 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8017ee:	e8 c3 ff ff ff       	call   8017b6 <fs_sync>
	return 0;
}
  8017f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8017fd:	ba 60 50 80 00       	mov    $0x805060,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  801802:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801807:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80180c:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80180e:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801811:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801817:	40                   	inc    %eax
  801818:	83 c2 10             	add    $0x10,%edx
  80181b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801820:	75 ea                	jne    80180c <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	83 ec 10             	sub    $0x10,%esp
  80182c:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80182f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  801834:	89 d8                	mov    %ebx,%eax
  801836:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  801839:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 11 22 00 00       	call   803a58 <pageref>
  801847:	85 c0                	test   %eax,%eax
  801849:	74 07                	je     801852 <openfile_alloc+0x2e>
  80184b:	83 f8 01             	cmp    $0x1,%eax
  80184e:	75 62                	jne    8018b2 <openfile_alloc+0x8e>
  801850:	eb 27                	jmp    801879 <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801852:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801859:	00 
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	c1 e0 04             	shl    $0x4,%eax
  80185f:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  801865:	89 44 24 04          	mov    %eax,0x4(%esp)
  801869:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801870:	e8 b4 14 00 00       	call   802d29 <sys_page_alloc>
  801875:	85 c0                	test   %eax,%eax
  801877:	78 4b                	js     8018c4 <openfile_alloc+0xa0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801879:	c1 e3 04             	shl    $0x4,%ebx
  80187c:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801882:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801889:	04 00 00 
			*o = &opentab[i];
  80188c:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  80188e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801895:	00 
  801896:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80189d:	00 
  80189e:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  8018a4:	89 04 24             	mov    %eax,(%esp)
  8018a7:	e8 ba 11 00 00       	call   802a66 <memset>
			return (*o)->o_fileid;
  8018ac:	8b 06                	mov    (%esi),%eax
  8018ae:	8b 00                	mov    (%eax),%eax
  8018b0:	eb 12                	jmp    8018c4 <openfile_alloc+0xa0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8018b2:	43                   	inc    %ebx
  8018b3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8018b9:	0f 85 75 ff ff ff    	jne    801834 <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8018bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	57                   	push   %edi
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 1c             	sub    $0x1c,%esp
  8018d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8018d7:	89 fe                	mov    %edi,%esi
  8018d9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8018df:	c1 e6 04             	shl    $0x4,%esi
  8018e2:	8d 9e 60 50 80 00    	lea    0x805060(%esi),%ebx
	// cprintf("%x %x %x\n",pageref(o->o_fd),o->o_fileid,fileid);
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8018e8:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 62 21 00 00       	call   803a58 <pageref>
  8018f6:	83 f8 01             	cmp    $0x1,%eax
  8018f9:	7e 14                	jle    80190f <openfile_lookup+0x44>
  8018fb:	39 be 60 50 80 00    	cmp    %edi,0x805060(%esi)
  801901:	75 13                	jne    801916 <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  801903:	8b 45 10             	mov    0x10(%ebp),%eax
  801906:	89 18                	mov    %ebx,(%eax)
	return 0;
  801908:	b8 00 00 00 00       	mov    $0x0,%eax
  80190d:	eb 0c                	jmp    80191b <openfile_lookup+0x50>
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	// cprintf("%x %x %x\n",pageref(o->o_fd),o->o_fileid,fileid);
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80190f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801914:	eb 05                	jmp    80191b <openfile_lookup+0x50>
  801916:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80191b:	83 c4 1c             	add    $0x1c,%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5f                   	pop    %edi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801930:	8b 45 0c             	mov    0xc(%ebp),%eax
  801933:	8b 00                	mov    (%eax),%eax
  801935:	89 44 24 04          	mov    %eax,0x4(%esp)
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 87 ff ff ff       	call   8018cb <openfile_lookup>
  801944:	85 c0                	test   %eax,%eax
  801946:	78 13                	js     80195b <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  801948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194b:	8b 40 04             	mov    0x4(%eax),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 7d fc ff ff       	call   8015d3 <file_flush>
	return 0;
  801956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	53                   	push   %ebx
  801961:	83 ec 24             	sub    $0x24,%esp
  801964:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801967:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196e:	8b 03                	mov    (%ebx),%eax
  801970:	89 44 24 04          	mov    %eax,0x4(%esp)
  801974:	8b 45 08             	mov    0x8(%ebp),%eax
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 4c ff ff ff       	call   8018cb <openfile_lookup>
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 3f                	js     8019c2 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801986:	8b 40 04             	mov    0x4(%eax),%eax
  801989:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198d:	89 1c 24             	mov    %ebx,(%esp)
  801990:	e8 a2 0f 00 00       	call   802937 <strcpy>
	ret->ret_size = o->o_file->f_size;
  801995:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801998:	8b 50 04             	mov    0x4(%eax),%edx
  80199b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8019a1:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8019a7:	8b 40 04             	mov    0x4(%eax),%eax
  8019aa:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8019b1:	0f 94 c0             	sete   %al
  8019b4:	0f b6 c0             	movzbl %al,%eax
  8019b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c2:	83 c4 24             	add    $0x24,%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	53                   	push   %ebx
  8019cc:	83 ec 24             	sub    $0x24,%esp
  8019cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	int r;
	struct OpenFile *o;
	// cprintf("server_write: %x %x %x %x\n",envid,req->req_fileid,req->req_buf,&o);
	if ((r = openfile_lookup(envid,req->req_fileid,&o)) < 0)
  8019d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d9:	8b 03                	mov    (%ebx),%eax
  8019db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	89 04 24             	mov    %eax,(%esp)
  8019e5:	e8 e1 fe ff ff       	call   8018cb <openfile_lookup>
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 3f                	js     801a2d <serve_write+0x65>
		return r;
	if ((r = file_write(o->o_file,req->req_buf,(req->req_n>PGSIZE)?PGSIZE:req->req_n,o->o_fd->fd_offset)) < 0)
  8019ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f1:	8b 42 0c             	mov    0xc(%edx),%eax
  8019f4:	8b 40 04             	mov    0x4(%eax),%eax
  8019f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8019fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a03:	76 05                	jbe    801a0a <serve_write+0x42>
  801a05:	b8 00 10 00 00       	mov    $0x1000,%eax
  801a0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0e:	83 c3 08             	add    $0x8,%ebx
  801a11:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a15:	8b 42 04             	mov    0x4(%edx),%eax
  801a18:	89 04 24             	mov    %eax,(%esp)
  801a1b:	e8 05 fb ff ff       	call   801525 <file_write>
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 09                	js     801a2d <serve_write+0x65>
		return r;
	// cprintf("find\n");
	o->o_fd->fd_offset += r;
  801a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a27:	8b 52 0c             	mov    0xc(%edx),%edx
  801a2a:	01 42 04             	add    %eax,0x4(%edx)
	// cprintf("serve_write fd_offset: %x\n",o->o_fd->fd_offset);
	return r;
	panic("serve_write not implemented");
}
  801a2d:	83 c4 24             	add    $0x24,%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	53                   	push   %ebx
  801a37:	83 ec 24             	sub    $0x24,%esp
  801a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	int r;
	struct OpenFile *o;
	if ((r = openfile_lookup(envid,req->req_fileid,&o)) < 0)
  801a3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a44:	8b 03                	mov    (%ebx),%eax
  801a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	89 04 24             	mov    %eax,(%esp)
  801a50:	e8 76 fe ff ff       	call   8018cb <openfile_lookup>
  801a55:	85 c0                	test   %eax,%eax
  801a57:	78 30                	js     801a89 <serve_read+0x56>
		return r;
	if ((r = file_read(o->o_file,ret->ret_buf,req->req_n,o->o_fd->fd_offset)) < 0)
  801a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5c:	8b 50 0c             	mov    0xc(%eax),%edx
  801a5f:	8b 52 04             	mov    0x4(%edx),%edx
  801a62:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a66:	8b 53 04             	mov    0x4(%ebx),%edx
  801a69:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a71:	8b 40 04             	mov    0x4(%eax),%eax
  801a74:	89 04 24             	mov    %eax,(%esp)
  801a77:	e8 1a f9 ff ff       	call   801396 <file_read>
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	78 09                	js     801a89 <serve_read+0x56>
		return r;
	o->o_fd->fd_offset += r;
  801a80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a83:	8b 52 0c             	mov    0xc(%edx),%edx
  801a86:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  801a89:	83 c4 24             	add    $0x24,%esp
  801a8c:	5b                   	pop    %ebx
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 24             	sub    $0x24,%esp
  801a96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa0:	8b 03                	mov    (%ebx),%eax
  801aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 1a fe ff ff       	call   8018cb <openfile_lookup>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 15                	js     801aca <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801ab5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abf:	8b 40 04             	mov    0x4(%eax),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 86 f9 ff ff       	call   801450 <file_set_size>
}
  801aca:	83 c4 24             	add    $0x24,%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	53                   	push   %ebx
  801ad4:	81 ec 24 04 00 00    	sub    $0x424,%esp
  801ada:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801add:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801ae4:	00 
  801ae5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae9:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801aef:	89 04 24             	mov    %eax,(%esp)
  801af2:	e8 b9 0f 00 00       	call   802ab0 <memmove>
	path[MAXPATHLEN-1] = 0;
  801af7:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801afb:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801b01:	89 04 24             	mov    %eax,(%esp)
  801b04:	e8 1b fd ff ff       	call   801824 <openfile_alloc>
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	0f 88 f0 00 00 00    	js     801c01 <serve_open+0x131>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801b11:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801b18:	74 32                	je     801b4c <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  801b1a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b24:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801b2a:	89 04 24             	mov    %eax,(%esp)
  801b2d:	e8 2f fb ff ff       	call   801661 <file_create>
  801b32:	85 c0                	test   %eax,%eax
  801b34:	79 36                	jns    801b6c <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801b36:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801b3d:	0f 85 be 00 00 00    	jne    801c01 <serve_open+0x131>
  801b43:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801b46:	0f 85 b5 00 00 00    	jne    801c01 <serve_open+0x131>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801b4c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b56:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	e8 13 f8 ff ff       	call   801377 <file_open>
  801b64:	85 c0                	test   %eax,%eax
  801b66:	0f 88 95 00 00 00    	js     801c01 <serve_open+0x131>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801b6c:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801b73:	74 1a                	je     801b8f <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  801b75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b7c:	00 
  801b7d:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  801b83:	89 04 24             	mov    %eax,(%esp)
  801b86:	e8 c5 f8 ff ff       	call   801450 <file_set_size>
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 72                	js     801c01 <serve_open+0x131>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  801b8f:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b99:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	e8 d0 f7 ff ff       	call   801377 <file_open>
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	78 56                	js     801c01 <serve_open+0x131>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801bab:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801bb1:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801bb7:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801bba:	8b 50 0c             	mov    0xc(%eax),%edx
  801bbd:	8b 08                	mov    (%eax),%ecx
  801bbf:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801bc2:	8b 50 0c             	mov    0xc(%eax),%edx
  801bc5:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  801bcb:	83 e1 03             	and    $0x3,%ecx
  801bce:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801bd1:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd4:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801bda:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801bdc:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801be2:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801be8:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801beb:	8b 50 0c             	mov    0xc(%eax),%edx
  801bee:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf1:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801bf3:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf6:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801bfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c01:	81 c4 24 04 00 00    	add    $0x424,%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801c12:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801c15:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801c18:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801c1f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c23:	a1 44 50 80 00       	mov    0x805044,%eax
  801c28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2c:	89 34 24             	mov    %esi,(%esp)
  801c2f:	e8 18 14 00 00       	call   80304c <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801c34:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801c38:	75 15                	jne    801c4f <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  801c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c41:	c7 04 24 b0 45 80 00 	movl   $0x8045b0,(%esp)
  801c48:	e8 3f 07 00 00       	call   80238c <cprintf>
				whom);
			continue; // just leave it hanging...
  801c4d:	eb c9                	jmp    801c18 <serve+0xe>
		}

		pg = NULL;
  801c4f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801c56:	83 f8 01             	cmp    $0x1,%eax
  801c59:	75 21                	jne    801c7c <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801c5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c62:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c66:	a1 44 50 80 00       	mov    0x805044,%eax
  801c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c72:	89 04 24             	mov    %eax,(%esp)
  801c75:	e8 56 fe ff ff       	call   801ad0 <serve_open>
  801c7a:	eb 3f                	jmp    801cbb <serve+0xb1>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  801c7c:	83 f8 08             	cmp    $0x8,%eax
  801c7f:	77 1e                	ja     801c9f <serve+0x95>
  801c81:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801c88:	85 d2                	test   %edx,%edx
  801c8a:	74 13                	je     801c9f <serve+0x95>
			r = handlers[req](whom, fsreq);
  801c8c:	a1 44 50 80 00       	mov    0x805044,%eax
  801c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c98:	89 04 24             	mov    %eax,(%esp)
  801c9b:	ff d2                	call   *%edx
  801c9d:	eb 1c                	jmp    801cbb <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caa:	c7 04 24 e0 45 80 00 	movl   $0x8045e0,(%esp)
  801cb1:	e8 d6 06 00 00       	call   80238c <cprintf>
			r = -E_INVAL;
  801cb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		// cprintf("serve %x %x %x %x\n",r,req,ARRAY_SIZE(handlers),handlers[req]);
		ipc_send(whom, r, pg, perm);
  801cbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cbe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cc2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801cc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	89 04 24             	mov    %eax,(%esp)
  801cd3:	e8 e1 13 00 00       	call   8030b9 <ipc_send>
		sys_page_unmap(0, fsreq);
  801cd8:	a1 44 50 80 00       	mov    0x805044,%eax
  801cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce8:	e8 e3 10 00 00       	call   802dd0 <sys_page_unmap>
  801ced:	e9 26 ff ff ff       	jmp    801c18 <serve+0xe>

00801cf2 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801cf8:	c7 05 60 90 80 00 03 	movl   $0x804603,0x809060
  801cff:	46 80 00 
	cprintf("FS is running\n");
  801d02:	c7 04 24 06 46 80 00 	movl   $0x804606,(%esp)
  801d09:	e8 7e 06 00 00       	call   80238c <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801d0e:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801d13:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801d18:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801d1a:	c7 04 24 15 46 80 00 	movl   $0x804615,(%esp)
  801d21:	e8 66 06 00 00       	call   80238c <cprintf>

	serve_init();
  801d26:	e8 cf fa ff ff       	call   8017fa <serve_init>
	fs_init();
  801d2b:	e8 39 f3 ff ff       	call   801069 <fs_init>
        fs_test();
  801d30:	e8 07 00 00 00       	call   801d3c <fs_test>
	serve();
  801d35:	e8 d0 fe ff ff       	call   801c0a <serve>
	...

00801d3c <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	53                   	push   %ebx
  801d40:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801d43:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d4a:	00 
  801d4b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801d52:	00 
  801d53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5a:	e8 ca 0f 00 00       	call   802d29 <sys_page_alloc>
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	79 20                	jns    801d83 <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  801d63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d67:	c7 44 24 08 24 46 80 	movl   $0x804624,0x8(%esp)
  801d6e:	00 
  801d6f:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  801d76:	00 
  801d77:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801d7e:	e8 11 05 00 00       	call   802294 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801d83:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801d8a:	00 
  801d8b:	a1 1c a0 80 00       	mov    0x80a01c,%eax
  801d90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d94:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  801d9b:	e8 10 0d 00 00       	call   802ab0 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801da0:	e8 cb f0 ff ff       	call   800e70 <alloc_block>
  801da5:	85 c0                	test   %eax,%eax
  801da7:	79 20                	jns    801dc9 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dad:	c7 44 24 08 41 46 80 	movl   $0x804641,0x8(%esp)
  801db4:	00 
  801db5:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  801dbc:	00 
  801dbd:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801dc4:	e8 cb 04 00 00       	call   802294 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801dc9:	89 c2                	mov    %eax,%edx
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	79 03                	jns    801dd2 <fs_test+0x96>
  801dcf:	8d 50 1f             	lea    0x1f(%eax),%edx
  801dd2:	c1 fa 05             	sar    $0x5,%edx
  801dd5:	c1 e2 02             	shl    $0x2,%edx
  801dd8:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ddd:	79 05                	jns    801de4 <fs_test+0xa8>
  801ddf:	48                   	dec    %eax
  801de0:	83 c8 e0             	or     $0xffffffe0,%eax
  801de3:	40                   	inc    %eax
  801de4:	bb 01 00 00 00       	mov    $0x1,%ebx
  801de9:	88 c1                	mov    %al,%cl
  801deb:	d3 e3                	shl    %cl,%ebx
  801ded:	85 9a 00 10 00 00    	test   %ebx,0x1000(%edx)
  801df3:	75 24                	jne    801e19 <fs_test+0xdd>
  801df5:	c7 44 24 0c 51 46 80 	movl   $0x804651,0xc(%esp)
  801dfc:	00 
  801dfd:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  801e04:	00 
  801e05:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  801e0c:	00 
  801e0d:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801e14:	e8 7b 04 00 00       	call   802294 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801e19:	8b 0d 1c a0 80 00    	mov    0x80a01c,%ecx
  801e1f:	85 1c 11             	test   %ebx,(%ecx,%edx,1)
  801e22:	74 24                	je     801e48 <fs_test+0x10c>
  801e24:	c7 44 24 0c cc 47 80 	movl   $0x8047cc,0xc(%esp)
  801e2b:	00 
  801e2c:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  801e33:	00 
  801e34:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  801e3b:	00 
  801e3c:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801e43:	e8 4c 04 00 00       	call   802294 <_panic>
	cprintf("alloc_block is good\n");
  801e48:	c7 04 24 6c 46 80 00 	movl   $0x80466c,(%esp)
  801e4f:	e8 38 05 00 00       	call   80238c <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5b:	c7 04 24 81 46 80 00 	movl   $0x804681,(%esp)
  801e62:	e8 10 f5 ff ff       	call   801377 <file_open>
  801e67:	85 c0                	test   %eax,%eax
  801e69:	79 25                	jns    801e90 <fs_test+0x154>
  801e6b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801e6e:	74 40                	je     801eb0 <fs_test+0x174>
		panic("file_open /not-found: %e", r);
  801e70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e74:	c7 44 24 08 8c 46 80 	movl   $0x80468c,0x8(%esp)
  801e7b:	00 
  801e7c:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  801e83:	00 
  801e84:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801e8b:	e8 04 04 00 00       	call   802294 <_panic>
	else if (r == 0)
  801e90:	85 c0                	test   %eax,%eax
  801e92:	75 1c                	jne    801eb0 <fs_test+0x174>
		panic("file_open /not-found succeeded!");
  801e94:	c7 44 24 08 ec 47 80 	movl   $0x8047ec,0x8(%esp)
  801e9b:	00 
  801e9c:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801ea3:	00 
  801ea4:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801eab:	e8 e4 03 00 00       	call   802294 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb7:	c7 04 24 a5 46 80 00 	movl   $0x8046a5,(%esp)
  801ebe:	e8 b4 f4 ff ff       	call   801377 <file_open>
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	79 20                	jns    801ee7 <fs_test+0x1ab>
		panic("file_open /newmotd: %e", r);
  801ec7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecb:	c7 44 24 08 ae 46 80 	movl   $0x8046ae,0x8(%esp)
  801ed2:	00 
  801ed3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801eda:	00 
  801edb:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801ee2:	e8 ad 03 00 00       	call   802294 <_panic>
	cprintf("file_open is good\n");
  801ee7:	c7 04 24 c5 46 80 00 	movl   $0x8046c5,(%esp)
  801eee:	e8 99 04 00 00       	call   80238c <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801ef3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801efa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f01:	00 
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	89 04 24             	mov    %eax,(%esp)
  801f08:	e8 b8 f1 ff ff       	call   8010c5 <file_get_block>
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	79 20                	jns    801f31 <fs_test+0x1f5>
		panic("file_get_block: %e", r);
  801f11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f15:	c7 44 24 08 d8 46 80 	movl   $0x8046d8,0x8(%esp)
  801f1c:	00 
  801f1d:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801f24:	00 
  801f25:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801f2c:	e8 63 03 00 00       	call   802294 <_panic>
	if (strcmp(blk, msg) != 0)
  801f31:	c7 44 24 04 0c 48 80 	movl   $0x80480c,0x4(%esp)
  801f38:	00 
  801f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3c:	89 04 24             	mov    %eax,(%esp)
  801f3f:	e8 9a 0a 00 00       	call   8029de <strcmp>
  801f44:	85 c0                	test   %eax,%eax
  801f46:	74 1c                	je     801f64 <fs_test+0x228>
		panic("file_get_block returned wrong data");
  801f48:	c7 44 24 08 34 48 80 	movl   $0x804834,0x8(%esp)
  801f4f:	00 
  801f50:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801f57:	00 
  801f58:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801f5f:	e8 30 03 00 00       	call   802294 <_panic>
	cprintf("file_get_block is good\n");
  801f64:	c7 04 24 eb 46 80 00 	movl   $0x8046eb,(%esp)
  801f6b:	e8 1c 04 00 00       	call   80238c <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f73:	8a 10                	mov    (%eax),%dl
  801f75:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7a:	c1 e8 0c             	shr    $0xc,%eax
  801f7d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f84:	a8 40                	test   $0x40,%al
  801f86:	75 24                	jne    801fac <fs_test+0x270>
  801f88:	c7 44 24 0c 04 47 80 	movl   $0x804704,0xc(%esp)
  801f8f:	00 
  801f90:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  801f97:	00 
  801f98:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801f9f:	00 
  801fa0:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801fa7:	e8 e8 02 00 00       	call   802294 <_panic>
	file_flush(f);
  801fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	e8 1c f6 ff ff       	call   8015d3 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fba:	c1 e8 0c             	shr    $0xc,%eax
  801fbd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801fc4:	a8 40                	test   $0x40,%al
  801fc6:	74 24                	je     801fec <fs_test+0x2b0>
  801fc8:	c7 44 24 0c 03 47 80 	movl   $0x804703,0xc(%esp)
  801fcf:	00 
  801fd0:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  801fd7:	00 
  801fd8:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801fdf:	00 
  801fe0:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  801fe7:	e8 a8 02 00 00       	call   802294 <_panic>
	cprintf("file_flush is good\n");
  801fec:	c7 04 24 1f 47 80 00 	movl   $0x80471f,(%esp)
  801ff3:	e8 94 03 00 00       	call   80238c <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801ff8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fff:	00 
  802000:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802003:	89 04 24             	mov    %eax,(%esp)
  802006:	e8 45 f4 ff ff       	call   801450 <file_set_size>
  80200b:	85 c0                	test   %eax,%eax
  80200d:	79 20                	jns    80202f <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  80200f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802013:	c7 44 24 08 33 47 80 	movl   $0x804733,0x8(%esp)
  80201a:	00 
  80201b:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  802022:	00 
  802023:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  80202a:	e8 65 02 00 00       	call   802294 <_panic>
	assert(f->f_direct[0] == 0);
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  802039:	74 24                	je     80205f <fs_test+0x323>
  80203b:	c7 44 24 0c 45 47 80 	movl   $0x804745,0xc(%esp)
  802042:	00 
  802043:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  80204a:	00 
  80204b:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  802052:	00 
  802053:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  80205a:	e8 35 02 00 00       	call   802294 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80205f:	c1 e8 0c             	shr    $0xc,%eax
  802062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802069:	a8 40                	test   $0x40,%al
  80206b:	74 24                	je     802091 <fs_test+0x355>
  80206d:	c7 44 24 0c 59 47 80 	movl   $0x804759,0xc(%esp)
  802074:	00 
  802075:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  80207c:	00 
  80207d:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  802084:	00 
  802085:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  80208c:	e8 03 02 00 00       	call   802294 <_panic>
	cprintf("file_truncate is good\n");
  802091:	c7 04 24 73 47 80 00 	movl   $0x804773,(%esp)
  802098:	e8 ef 02 00 00       	call   80238c <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80209d:	c7 04 24 0c 48 80 00 	movl   $0x80480c,(%esp)
  8020a4:	e8 5b 08 00 00       	call   802904 <strlen>
  8020a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b0:	89 04 24             	mov    %eax,(%esp)
  8020b3:	e8 98 f3 ff ff       	call   801450 <file_set_size>
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	79 20                	jns    8020dc <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  8020bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020c0:	c7 44 24 08 8a 47 80 	movl   $0x80478a,0x8(%esp)
  8020c7:	00 
  8020c8:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8020cf:	00 
  8020d0:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  8020d7:	e8 b8 01 00 00       	call   802294 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8020dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020df:	89 c2                	mov    %eax,%edx
  8020e1:	c1 ea 0c             	shr    $0xc,%edx
  8020e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020eb:	f6 c2 40             	test   $0x40,%dl
  8020ee:	74 24                	je     802114 <fs_test+0x3d8>
  8020f0:	c7 44 24 0c 59 47 80 	movl   $0x804759,0xc(%esp)
  8020f7:	00 
  8020f8:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  8020ff:	00 
  802100:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  802107:	00 
  802108:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  80210f:	e8 80 01 00 00       	call   802294 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  802114:	8d 55 f0             	lea    -0x10(%ebp),%edx
  802117:	89 54 24 08          	mov    %edx,0x8(%esp)
  80211b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802122:	00 
  802123:	89 04 24             	mov    %eax,(%esp)
  802126:	e8 9a ef ff ff       	call   8010c5 <file_get_block>
  80212b:	85 c0                	test   %eax,%eax
  80212d:	79 20                	jns    80214f <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  80212f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802133:	c7 44 24 08 9e 47 80 	movl   $0x80479e,0x8(%esp)
  80213a:	00 
  80213b:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  802142:	00 
  802143:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  80214a:	e8 45 01 00 00       	call   802294 <_panic>
	strcpy(blk, msg);
  80214f:	c7 44 24 04 0c 48 80 	movl   $0x80480c,0x4(%esp)
  802156:	00 
  802157:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80215a:	89 04 24             	mov    %eax,(%esp)
  80215d:	e8 d5 07 00 00       	call   802937 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  802162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802165:	c1 e8 0c             	shr    $0xc,%eax
  802168:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80216f:	a8 40                	test   $0x40,%al
  802171:	75 24                	jne    802197 <fs_test+0x45b>
  802173:	c7 44 24 0c 04 47 80 	movl   $0x804704,0xc(%esp)
  80217a:	00 
  80217b:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  802182:	00 
  802183:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80218a:	00 
  80218b:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  802192:	e8 fd 00 00 00       	call   802294 <_panic>
	file_flush(f);
  802197:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219a:	89 04 24             	mov    %eax,(%esp)
  80219d:	e8 31 f4 ff ff       	call   8015d3 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8021a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a5:	c1 e8 0c             	shr    $0xc,%eax
  8021a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8021af:	a8 40                	test   $0x40,%al
  8021b1:	74 24                	je     8021d7 <fs_test+0x49b>
  8021b3:	c7 44 24 0c 03 47 80 	movl   $0x804703,0xc(%esp)
  8021ba:	00 
  8021bb:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  8021c2:	00 
  8021c3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8021ca:	00 
  8021cb:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  8021d2:	e8 bd 00 00 00       	call   802294 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021da:	c1 e8 0c             	shr    $0xc,%eax
  8021dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8021e4:	a8 40                	test   $0x40,%al
  8021e6:	74 24                	je     80220c <fs_test+0x4d0>
  8021e8:	c7 44 24 0c 59 47 80 	movl   $0x804759,0xc(%esp)
  8021ef:	00 
  8021f0:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  8021f7:	00 
  8021f8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8021ff:	00 
  802200:	c7 04 24 37 46 80 00 	movl   $0x804637,(%esp)
  802207:	e8 88 00 00 00       	call   802294 <_panic>
	cprintf("file rewrite is good\n");
  80220c:	c7 04 24 b3 47 80 00 	movl   $0x8047b3,(%esp)
  802213:	e8 74 01 00 00       	call   80238c <cprintf>
}
  802218:	83 c4 24             	add    $0x24,%esp
  80221b:	5b                   	pop    %ebx
  80221c:	5d                   	pop    %ebp
  80221d:	c3                   	ret    
	...

00802220 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	56                   	push   %esi
  802224:	53                   	push   %ebx
  802225:	83 ec 20             	sub    $0x20,%esp
  802228:	8b 75 08             	mov    0x8(%ebp),%esi
  80222b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80222e:	e8 b8 0a 00 00       	call   802ceb <sys_getenvid>
  802233:	25 ff 03 00 00       	and    $0x3ff,%eax
  802238:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80223f:	c1 e0 07             	shl    $0x7,%eax
  802242:	29 d0                	sub    %edx,%eax
  802244:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802249:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  80224c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224f:	a3 20 a1 80 00       	mov    %eax,0x80a120
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  802254:	85 f6                	test   %esi,%esi
  802256:	7e 07                	jle    80225f <libmain+0x3f>
		binaryname = argv[0];
  802258:	8b 03                	mov    (%ebx),%eax
  80225a:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  80225f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802263:	89 34 24             	mov    %esi,(%esp)
  802266:	e8 87 fa ff ff       	call   801cf2 <umain>

	// exit gracefully
	exit();
  80226b:	e8 08 00 00 00       	call   802278 <exit>
}
  802270:	83 c4 20             	add    $0x20,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    
	...

00802278 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80227e:	e8 ca 10 00 00       	call   80334d <close_all>
	sys_env_destroy(0);
  802283:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80228a:	e8 0a 0a 00 00       	call   802c99 <sys_env_destroy>
}
  80228f:	c9                   	leave  
  802290:	c3                   	ret    
  802291:	00 00                	add    %al,(%eax)
	...

00802294 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	56                   	push   %esi
  802298:	53                   	push   %ebx
  802299:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80229c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80229f:	8b 1d 60 90 80 00    	mov    0x809060,%ebx
  8022a5:	e8 41 0a 00 00       	call   802ceb <sys_getenvid>
  8022aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8022b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8022b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c0:	c7 04 24 64 48 80 00 	movl   $0x804864,(%esp)
  8022c7:	e8 c0 00 00 00       	call   80238c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8022d3:	89 04 24             	mov    %eax,(%esp)
  8022d6:	e8 50 00 00 00       	call   80232b <vcprintf>
	cprintf("\n");
  8022db:	c7 04 24 f8 42 80 00 	movl   $0x8042f8,(%esp)
  8022e2:	e8 a5 00 00 00       	call   80238c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022e7:	cc                   	int3   
  8022e8:	eb fd                	jmp    8022e7 <_panic+0x53>
	...

008022ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	53                   	push   %ebx
  8022f0:	83 ec 14             	sub    $0x14,%esp
  8022f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8022f6:	8b 03                	mov    (%ebx),%eax
  8022f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8022fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8022ff:	40                   	inc    %eax
  802300:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  802302:	3d ff 00 00 00       	cmp    $0xff,%eax
  802307:	75 19                	jne    802322 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  802309:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  802310:	00 
  802311:	8d 43 08             	lea    0x8(%ebx),%eax
  802314:	89 04 24             	mov    %eax,(%esp)
  802317:	e8 40 09 00 00       	call   802c5c <sys_cputs>
		b->idx = 0;
  80231c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  802322:	ff 43 04             	incl   0x4(%ebx)
}
  802325:	83 c4 14             	add    $0x14,%esp
  802328:	5b                   	pop    %ebx
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    

0080232b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  802334:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80233b:	00 00 00 
	b.cnt = 0;
  80233e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  802345:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  802348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80234f:	8b 45 08             	mov    0x8(%ebp),%eax
  802352:	89 44 24 08          	mov    %eax,0x8(%esp)
  802356:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80235c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802360:	c7 04 24 ec 22 80 00 	movl   $0x8022ec,(%esp)
  802367:	e8 82 01 00 00       	call   8024ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80236c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802372:	89 44 24 04          	mov    %eax,0x4(%esp)
  802376:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80237c:	89 04 24             	mov    %eax,(%esp)
  80237f:	e8 d8 08 00 00       	call   802c5c <sys_cputs>

	return b.cnt;
}
  802384:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80238a:	c9                   	leave  
  80238b:	c3                   	ret    

0080238c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802392:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  802395:	89 44 24 04          	mov    %eax,0x4(%esp)
  802399:	8b 45 08             	mov    0x8(%ebp),%eax
  80239c:	89 04 24             	mov    %eax,(%esp)
  80239f:	e8 87 ff ff ff       	call   80232b <vcprintf>
	va_end(ap);

	return cnt;
}
  8023a4:	c9                   	leave  
  8023a5:	c3                   	ret    
	...

008023a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	57                   	push   %edi
  8023ac:	56                   	push   %esi
  8023ad:	53                   	push   %ebx
  8023ae:	83 ec 3c             	sub    $0x3c,%esp
  8023b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8023b4:	89 d7                	mov    %edx,%edi
  8023b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8023bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8023c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8023c5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	75 08                	jne    8023d4 <printnum+0x2c>
  8023cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8023cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8023d2:	77 57                	ja     80242b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8023d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8023d8:	4b                   	dec    %ebx
  8023d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8023e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023e4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8023e8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8023ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8023f3:	00 
  8023f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8023f7:	89 04 24             	mov    %eax,(%esp)
  8023fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802401:	e8 b2 1b 00 00       	call   803fb8 <__udivdi3>
  802406:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80240a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80240e:	89 04 24             	mov    %eax,(%esp)
  802411:	89 54 24 04          	mov    %edx,0x4(%esp)
  802415:	89 fa                	mov    %edi,%edx
  802417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241a:	e8 89 ff ff ff       	call   8023a8 <printnum>
  80241f:	eb 0f                	jmp    802430 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  802421:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802425:	89 34 24             	mov    %esi,(%esp)
  802428:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80242b:	4b                   	dec    %ebx
  80242c:	85 db                	test   %ebx,%ebx
  80242e:	7f f1                	jg     802421 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  802430:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802434:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802438:	8b 45 10             	mov    0x10(%ebp),%eax
  80243b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80243f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802446:	00 
  802447:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80244a:	89 04 24             	mov    %eax,(%esp)
  80244d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802450:	89 44 24 04          	mov    %eax,0x4(%esp)
  802454:	e8 7f 1c 00 00       	call   8040d8 <__umoddi3>
  802459:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80245d:	0f be 80 87 48 80 00 	movsbl 0x804887(%eax),%eax
  802464:	89 04 24             	mov    %eax,(%esp)
  802467:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80246a:	83 c4 3c             	add    $0x3c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    

00802472 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  802475:	83 fa 01             	cmp    $0x1,%edx
  802478:	7e 0e                	jle    802488 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80247a:	8b 10                	mov    (%eax),%edx
  80247c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80247f:	89 08                	mov    %ecx,(%eax)
  802481:	8b 02                	mov    (%edx),%eax
  802483:	8b 52 04             	mov    0x4(%edx),%edx
  802486:	eb 22                	jmp    8024aa <getuint+0x38>
	else if (lflag)
  802488:	85 d2                	test   %edx,%edx
  80248a:	74 10                	je     80249c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80248c:	8b 10                	mov    (%eax),%edx
  80248e:	8d 4a 04             	lea    0x4(%edx),%ecx
  802491:	89 08                	mov    %ecx,(%eax)
  802493:	8b 02                	mov    (%edx),%eax
  802495:	ba 00 00 00 00       	mov    $0x0,%edx
  80249a:	eb 0e                	jmp    8024aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80249c:	8b 10                	mov    (%eax),%edx
  80249e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8024a1:	89 08                	mov    %ecx,(%eax)
  8024a3:	8b 02                	mov    (%edx),%eax
  8024a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8024aa:	5d                   	pop    %ebp
  8024ab:	c3                   	ret    

008024ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
  8024af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8024b2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8024b5:	8b 10                	mov    (%eax),%edx
  8024b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8024ba:	73 08                	jae    8024c4 <sprintputch+0x18>
		*b->buf++ = ch;
  8024bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024bf:	88 0a                	mov    %cl,(%edx)
  8024c1:	42                   	inc    %edx
  8024c2:	89 10                	mov    %edx,(%eax)
}
  8024c4:	5d                   	pop    %ebp
  8024c5:	c3                   	ret    

008024c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8024cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8024cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8024d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e4:	89 04 24             	mov    %eax,(%esp)
  8024e7:	e8 02 00 00 00       	call   8024ee <vprintfmt>
	va_end(ap);
}
  8024ec:	c9                   	leave  
  8024ed:	c3                   	ret    

008024ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	53                   	push   %ebx
  8024f4:	83 ec 4c             	sub    $0x4c,%esp
  8024f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8024fa:	8b 75 10             	mov    0x10(%ebp),%esi
  8024fd:	eb 12                	jmp    802511 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8024ff:	85 c0                	test   %eax,%eax
  802501:	0f 84 6b 03 00 00    	je     802872 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  802507:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80250b:	89 04 24             	mov    %eax,(%esp)
  80250e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802511:	0f b6 06             	movzbl (%esi),%eax
  802514:	46                   	inc    %esi
  802515:	83 f8 25             	cmp    $0x25,%eax
  802518:	75 e5                	jne    8024ff <vprintfmt+0x11>
  80251a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80251e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  802525:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80252a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  802531:	b9 00 00 00 00       	mov    $0x0,%ecx
  802536:	eb 26                	jmp    80255e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802538:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80253b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80253f:	eb 1d                	jmp    80255e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802541:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  802544:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  802548:	eb 14                	jmp    80255e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80254a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80254d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  802554:	eb 08                	jmp    80255e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  802556:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  802559:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80255e:	0f b6 06             	movzbl (%esi),%eax
  802561:	8d 56 01             	lea    0x1(%esi),%edx
  802564:	89 55 e0             	mov    %edx,-0x20(%ebp)
  802567:	8a 16                	mov    (%esi),%dl
  802569:	83 ea 23             	sub    $0x23,%edx
  80256c:	80 fa 55             	cmp    $0x55,%dl
  80256f:	0f 87 e1 02 00 00    	ja     802856 <vprintfmt+0x368>
  802575:	0f b6 d2             	movzbl %dl,%edx
  802578:	ff 24 95 c0 49 80 00 	jmp    *0x8049c0(,%edx,4)
  80257f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802582:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  802587:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80258a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80258e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  802591:	8d 50 d0             	lea    -0x30(%eax),%edx
  802594:	83 fa 09             	cmp    $0x9,%edx
  802597:	77 2a                	ja     8025c3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  802599:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80259a:	eb eb                	jmp    802587 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80259c:	8b 45 14             	mov    0x14(%ebp),%eax
  80259f:	8d 50 04             	lea    0x4(%eax),%edx
  8025a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8025a5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8025a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8025aa:	eb 17                	jmp    8025c3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8025ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8025b0:	78 98                	js     80254a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8025b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8025b5:	eb a7                	jmp    80255e <vprintfmt+0x70>
  8025b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8025ba:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8025c1:	eb 9b                	jmp    80255e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8025c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8025c7:	79 95                	jns    80255e <vprintfmt+0x70>
  8025c9:	eb 8b                	jmp    802556 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8025cb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8025cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8025cf:	eb 8d                	jmp    80255e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8025d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8025d4:	8d 50 04             	lea    0x4(%eax),%edx
  8025d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8025da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8025de:	8b 00                	mov    (%eax),%eax
  8025e0:	89 04 24             	mov    %eax,(%esp)
  8025e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8025e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8025e9:	e9 23 ff ff ff       	jmp    802511 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8025ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8025f1:	8d 50 04             	lea    0x4(%eax),%edx
  8025f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8025f7:	8b 00                	mov    (%eax),%eax
  8025f9:	85 c0                	test   %eax,%eax
  8025fb:	79 02                	jns    8025ff <vprintfmt+0x111>
  8025fd:	f7 d8                	neg    %eax
  8025ff:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  802601:	83 f8 0f             	cmp    $0xf,%eax
  802604:	7f 0b                	jg     802611 <vprintfmt+0x123>
  802606:	8b 04 85 20 4b 80 00 	mov    0x804b20(,%eax,4),%eax
  80260d:	85 c0                	test   %eax,%eax
  80260f:	75 23                	jne    802634 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  802611:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802615:	c7 44 24 08 9f 48 80 	movl   $0x80489f,0x8(%esp)
  80261c:	00 
  80261d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802621:	8b 45 08             	mov    0x8(%ebp),%eax
  802624:	89 04 24             	mov    %eax,(%esp)
  802627:	e8 9a fe ff ff       	call   8024c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80262c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80262f:	e9 dd fe ff ff       	jmp    802511 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  802634:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802638:	c7 44 24 08 6f 42 80 	movl   $0x80426f,0x8(%esp)
  80263f:	00 
  802640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802644:	8b 55 08             	mov    0x8(%ebp),%edx
  802647:	89 14 24             	mov    %edx,(%esp)
  80264a:	e8 77 fe ff ff       	call   8024c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80264f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802652:	e9 ba fe ff ff       	jmp    802511 <vprintfmt+0x23>
  802657:	89 f9                	mov    %edi,%ecx
  802659:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80265c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80265f:	8b 45 14             	mov    0x14(%ebp),%eax
  802662:	8d 50 04             	lea    0x4(%eax),%edx
  802665:	89 55 14             	mov    %edx,0x14(%ebp)
  802668:	8b 30                	mov    (%eax),%esi
  80266a:	85 f6                	test   %esi,%esi
  80266c:	75 05                	jne    802673 <vprintfmt+0x185>
				p = "(null)";
  80266e:	be 98 48 80 00       	mov    $0x804898,%esi
			if (width > 0 && padc != '-')
  802673:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  802677:	0f 8e 84 00 00 00    	jle    802701 <vprintfmt+0x213>
  80267d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  802681:	74 7e                	je     802701 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  802683:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802687:	89 34 24             	mov    %esi,(%esp)
  80268a:	e8 8b 02 00 00       	call   80291a <strnlen>
  80268f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802692:	29 c2                	sub    %eax,%edx
  802694:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  802697:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80269b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80269e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8026a1:	89 de                	mov    %ebx,%esi
  8026a3:	89 d3                	mov    %edx,%ebx
  8026a5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8026a7:	eb 0b                	jmp    8026b4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8026a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ad:	89 3c 24             	mov    %edi,(%esp)
  8026b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8026b3:	4b                   	dec    %ebx
  8026b4:	85 db                	test   %ebx,%ebx
  8026b6:	7f f1                	jg     8026a9 <vprintfmt+0x1bb>
  8026b8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8026bb:	89 f3                	mov    %esi,%ebx
  8026bd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8026c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026c3:	85 c0                	test   %eax,%eax
  8026c5:	79 05                	jns    8026cc <vprintfmt+0x1de>
  8026c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8026cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8026cf:	29 c2                	sub    %eax,%edx
  8026d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026d4:	eb 2b                	jmp    802701 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8026d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8026da:	74 18                	je     8026f4 <vprintfmt+0x206>
  8026dc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8026df:	83 fa 5e             	cmp    $0x5e,%edx
  8026e2:	76 10                	jbe    8026f4 <vprintfmt+0x206>
					putch('?', putdat);
  8026e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026e8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8026ef:	ff 55 08             	call   *0x8(%ebp)
  8026f2:	eb 0a                	jmp    8026fe <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8026f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026f8:	89 04 24             	mov    %eax,(%esp)
  8026fb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8026fe:	ff 4d e4             	decl   -0x1c(%ebp)
  802701:	0f be 06             	movsbl (%esi),%eax
  802704:	46                   	inc    %esi
  802705:	85 c0                	test   %eax,%eax
  802707:	74 21                	je     80272a <vprintfmt+0x23c>
  802709:	85 ff                	test   %edi,%edi
  80270b:	78 c9                	js     8026d6 <vprintfmt+0x1e8>
  80270d:	4f                   	dec    %edi
  80270e:	79 c6                	jns    8026d6 <vprintfmt+0x1e8>
  802710:	8b 7d 08             	mov    0x8(%ebp),%edi
  802713:	89 de                	mov    %ebx,%esi
  802715:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802718:	eb 18                	jmp    802732 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80271a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80271e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802725:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802727:	4b                   	dec    %ebx
  802728:	eb 08                	jmp    802732 <vprintfmt+0x244>
  80272a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80272d:	89 de                	mov    %ebx,%esi
  80272f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802732:	85 db                	test   %ebx,%ebx
  802734:	7f e4                	jg     80271a <vprintfmt+0x22c>
  802736:	89 7d 08             	mov    %edi,0x8(%ebp)
  802739:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80273b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80273e:	e9 ce fd ff ff       	jmp    802511 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802743:	83 f9 01             	cmp    $0x1,%ecx
  802746:	7e 10                	jle    802758 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  802748:	8b 45 14             	mov    0x14(%ebp),%eax
  80274b:	8d 50 08             	lea    0x8(%eax),%edx
  80274e:	89 55 14             	mov    %edx,0x14(%ebp)
  802751:	8b 30                	mov    (%eax),%esi
  802753:	8b 78 04             	mov    0x4(%eax),%edi
  802756:	eb 26                	jmp    80277e <vprintfmt+0x290>
	else if (lflag)
  802758:	85 c9                	test   %ecx,%ecx
  80275a:	74 12                	je     80276e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80275c:	8b 45 14             	mov    0x14(%ebp),%eax
  80275f:	8d 50 04             	lea    0x4(%eax),%edx
  802762:	89 55 14             	mov    %edx,0x14(%ebp)
  802765:	8b 30                	mov    (%eax),%esi
  802767:	89 f7                	mov    %esi,%edi
  802769:	c1 ff 1f             	sar    $0x1f,%edi
  80276c:	eb 10                	jmp    80277e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80276e:	8b 45 14             	mov    0x14(%ebp),%eax
  802771:	8d 50 04             	lea    0x4(%eax),%edx
  802774:	89 55 14             	mov    %edx,0x14(%ebp)
  802777:	8b 30                	mov    (%eax),%esi
  802779:	89 f7                	mov    %esi,%edi
  80277b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80277e:	85 ff                	test   %edi,%edi
  802780:	78 0a                	js     80278c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  802782:	b8 0a 00 00 00       	mov    $0xa,%eax
  802787:	e9 8c 00 00 00       	jmp    802818 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80278c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802790:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  802797:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80279a:	f7 de                	neg    %esi
  80279c:	83 d7 00             	adc    $0x0,%edi
  80279f:	f7 df                	neg    %edi
			}
			base = 10;
  8027a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8027a6:	eb 70                	jmp    802818 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8027a8:	89 ca                	mov    %ecx,%edx
  8027aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8027ad:	e8 c0 fc ff ff       	call   802472 <getuint>
  8027b2:	89 c6                	mov    %eax,%esi
  8027b4:	89 d7                	mov    %edx,%edi
			base = 10;
  8027b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8027bb:	eb 5b                	jmp    802818 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8027c2:	e8 ab fc ff ff       	call   802472 <getuint>
  8027c7:	89 c6                	mov    %eax,%esi
  8027c9:	89 d7                	mov    %edx,%edi
			base = 8;
  8027cb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8027d0:	eb 46                	jmp    802818 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8027d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8027d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8027dd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8027e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8027e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8027eb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8027ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8027f1:	8d 50 04             	lea    0x4(%eax),%edx
  8027f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8027f7:	8b 30                	mov    (%eax),%esi
  8027f9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8027fe:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  802803:	eb 13                	jmp    802818 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802805:	89 ca                	mov    %ecx,%edx
  802807:	8d 45 14             	lea    0x14(%ebp),%eax
  80280a:	e8 63 fc ff ff       	call   802472 <getuint>
  80280f:	89 c6                	mov    %eax,%esi
  802811:	89 d7                	mov    %edx,%edi
			base = 16;
  802813:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  802818:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80281c:	89 54 24 10          	mov    %edx,0x10(%esp)
  802820:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802823:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80282b:	89 34 24             	mov    %esi,(%esp)
  80282e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802832:	89 da                	mov    %ebx,%edx
  802834:	8b 45 08             	mov    0x8(%ebp),%eax
  802837:	e8 6c fb ff ff       	call   8023a8 <printnum>
			break;
  80283c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80283f:	e9 cd fc ff ff       	jmp    802511 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802844:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802848:	89 04 24             	mov    %eax,(%esp)
  80284b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80284e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  802851:	e9 bb fc ff ff       	jmp    802511 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802856:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80285a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802861:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  802864:	eb 01                	jmp    802867 <vprintfmt+0x379>
  802866:	4e                   	dec    %esi
  802867:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80286b:	75 f9                	jne    802866 <vprintfmt+0x378>
  80286d:	e9 9f fc ff ff       	jmp    802511 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  802872:	83 c4 4c             	add    $0x4c,%esp
  802875:	5b                   	pop    %ebx
  802876:	5e                   	pop    %esi
  802877:	5f                   	pop    %edi
  802878:	5d                   	pop    %ebp
  802879:	c3                   	ret    

0080287a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80287a:	55                   	push   %ebp
  80287b:	89 e5                	mov    %esp,%ebp
  80287d:	83 ec 28             	sub    $0x28,%esp
  802880:	8b 45 08             	mov    0x8(%ebp),%eax
  802883:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802886:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802889:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80288d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802890:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802897:	85 c0                	test   %eax,%eax
  802899:	74 30                	je     8028cb <vsnprintf+0x51>
  80289b:	85 d2                	test   %edx,%edx
  80289d:	7e 33                	jle    8028d2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80289f:	8b 45 14             	mov    0x14(%ebp),%eax
  8028a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8028a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8028b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028b4:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
  8028bb:	e8 2e fc ff ff       	call   8024ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8028c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8028c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8028c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028c9:	eb 0c                	jmp    8028d7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8028cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028d0:	eb 05                	jmp    8028d7 <vsnprintf+0x5d>
  8028d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8028d7:	c9                   	leave  
  8028d8:	c3                   	ret    

008028d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8028d9:	55                   	push   %ebp
  8028da:	89 e5                	mov    %esp,%ebp
  8028dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8028df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8028e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8028e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8028f7:	89 04 24             	mov    %eax,(%esp)
  8028fa:	e8 7b ff ff ff       	call   80287a <vsnprintf>
	va_end(ap);

	return rc;
}
  8028ff:	c9                   	leave  
  802900:	c3                   	ret    
  802901:	00 00                	add    %al,(%eax)
	...

00802904 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802904:	55                   	push   %ebp
  802905:	89 e5                	mov    %esp,%ebp
  802907:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80290a:	b8 00 00 00 00       	mov    $0x0,%eax
  80290f:	eb 01                	jmp    802912 <strlen+0xe>
		n++;
  802911:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802912:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802916:	75 f9                	jne    802911 <strlen+0xd>
		n++;
	return n;
}
  802918:	5d                   	pop    %ebp
  802919:	c3                   	ret    

0080291a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80291a:	55                   	push   %ebp
  80291b:	89 e5                	mov    %esp,%ebp
  80291d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  802920:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802923:	b8 00 00 00 00       	mov    $0x0,%eax
  802928:	eb 01                	jmp    80292b <strnlen+0x11>
		n++;
  80292a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80292b:	39 d0                	cmp    %edx,%eax
  80292d:	74 06                	je     802935 <strnlen+0x1b>
  80292f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  802933:	75 f5                	jne    80292a <strnlen+0x10>
		n++;
	return n;
}
  802935:	5d                   	pop    %ebp
  802936:	c3                   	ret    

00802937 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802937:	55                   	push   %ebp
  802938:	89 e5                	mov    %esp,%ebp
  80293a:	53                   	push   %ebx
  80293b:	8b 45 08             	mov    0x8(%ebp),%eax
  80293e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802941:	ba 00 00 00 00       	mov    $0x0,%edx
  802946:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  802949:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80294c:	42                   	inc    %edx
  80294d:	84 c9                	test   %cl,%cl
  80294f:	75 f5                	jne    802946 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  802951:	5b                   	pop    %ebx
  802952:	5d                   	pop    %ebp
  802953:	c3                   	ret    

00802954 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802954:	55                   	push   %ebp
  802955:	89 e5                	mov    %esp,%ebp
  802957:	53                   	push   %ebx
  802958:	83 ec 08             	sub    $0x8,%esp
  80295b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80295e:	89 1c 24             	mov    %ebx,(%esp)
  802961:	e8 9e ff ff ff       	call   802904 <strlen>
	strcpy(dst + len, src);
  802966:	8b 55 0c             	mov    0xc(%ebp),%edx
  802969:	89 54 24 04          	mov    %edx,0x4(%esp)
  80296d:	01 d8                	add    %ebx,%eax
  80296f:	89 04 24             	mov    %eax,(%esp)
  802972:	e8 c0 ff ff ff       	call   802937 <strcpy>
	return dst;
}
  802977:	89 d8                	mov    %ebx,%eax
  802979:	83 c4 08             	add    $0x8,%esp
  80297c:	5b                   	pop    %ebx
  80297d:	5d                   	pop    %ebp
  80297e:	c3                   	ret    

0080297f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80297f:	55                   	push   %ebp
  802980:	89 e5                	mov    %esp,%ebp
  802982:	56                   	push   %esi
  802983:	53                   	push   %ebx
  802984:	8b 45 08             	mov    0x8(%ebp),%eax
  802987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80298a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80298d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802992:	eb 0c                	jmp    8029a0 <strncpy+0x21>
		*dst++ = *src;
  802994:	8a 1a                	mov    (%edx),%bl
  802996:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802999:	80 3a 01             	cmpb   $0x1,(%edx)
  80299c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80299f:	41                   	inc    %ecx
  8029a0:	39 f1                	cmp    %esi,%ecx
  8029a2:	75 f0                	jne    802994 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8029a4:	5b                   	pop    %ebx
  8029a5:	5e                   	pop    %esi
  8029a6:	5d                   	pop    %ebp
  8029a7:	c3                   	ret    

008029a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8029a8:	55                   	push   %ebp
  8029a9:	89 e5                	mov    %esp,%ebp
  8029ab:	56                   	push   %esi
  8029ac:	53                   	push   %ebx
  8029ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8029b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029b3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8029b6:	85 d2                	test   %edx,%edx
  8029b8:	75 0a                	jne    8029c4 <strlcpy+0x1c>
  8029ba:	89 f0                	mov    %esi,%eax
  8029bc:	eb 1a                	jmp    8029d8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8029be:	88 18                	mov    %bl,(%eax)
  8029c0:	40                   	inc    %eax
  8029c1:	41                   	inc    %ecx
  8029c2:	eb 02                	jmp    8029c6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8029c4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8029c6:	4a                   	dec    %edx
  8029c7:	74 0a                	je     8029d3 <strlcpy+0x2b>
  8029c9:	8a 19                	mov    (%ecx),%bl
  8029cb:	84 db                	test   %bl,%bl
  8029cd:	75 ef                	jne    8029be <strlcpy+0x16>
  8029cf:	89 c2                	mov    %eax,%edx
  8029d1:	eb 02                	jmp    8029d5 <strlcpy+0x2d>
  8029d3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8029d5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8029d8:	29 f0                	sub    %esi,%eax
}
  8029da:	5b                   	pop    %ebx
  8029db:	5e                   	pop    %esi
  8029dc:	5d                   	pop    %ebp
  8029dd:	c3                   	ret    

008029de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8029de:	55                   	push   %ebp
  8029df:	89 e5                	mov    %esp,%ebp
  8029e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8029e7:	eb 02                	jmp    8029eb <strcmp+0xd>
		p++, q++;
  8029e9:	41                   	inc    %ecx
  8029ea:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8029eb:	8a 01                	mov    (%ecx),%al
  8029ed:	84 c0                	test   %al,%al
  8029ef:	74 04                	je     8029f5 <strcmp+0x17>
  8029f1:	3a 02                	cmp    (%edx),%al
  8029f3:	74 f4                	je     8029e9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8029f5:	0f b6 c0             	movzbl %al,%eax
  8029f8:	0f b6 12             	movzbl (%edx),%edx
  8029fb:	29 d0                	sub    %edx,%eax
}
  8029fd:	5d                   	pop    %ebp
  8029fe:	c3                   	ret    

008029ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8029ff:	55                   	push   %ebp
  802a00:	89 e5                	mov    %esp,%ebp
  802a02:	53                   	push   %ebx
  802a03:	8b 45 08             	mov    0x8(%ebp),%eax
  802a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a09:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  802a0c:	eb 03                	jmp    802a11 <strncmp+0x12>
		n--, p++, q++;
  802a0e:	4a                   	dec    %edx
  802a0f:	40                   	inc    %eax
  802a10:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802a11:	85 d2                	test   %edx,%edx
  802a13:	74 14                	je     802a29 <strncmp+0x2a>
  802a15:	8a 18                	mov    (%eax),%bl
  802a17:	84 db                	test   %bl,%bl
  802a19:	74 04                	je     802a1f <strncmp+0x20>
  802a1b:	3a 19                	cmp    (%ecx),%bl
  802a1d:	74 ef                	je     802a0e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802a1f:	0f b6 00             	movzbl (%eax),%eax
  802a22:	0f b6 11             	movzbl (%ecx),%edx
  802a25:	29 d0                	sub    %edx,%eax
  802a27:	eb 05                	jmp    802a2e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802a29:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802a2e:	5b                   	pop    %ebx
  802a2f:	5d                   	pop    %ebp
  802a30:	c3                   	ret    

00802a31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802a31:	55                   	push   %ebp
  802a32:	89 e5                	mov    %esp,%ebp
  802a34:	8b 45 08             	mov    0x8(%ebp),%eax
  802a37:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  802a3a:	eb 05                	jmp    802a41 <strchr+0x10>
		if (*s == c)
  802a3c:	38 ca                	cmp    %cl,%dl
  802a3e:	74 0c                	je     802a4c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802a40:	40                   	inc    %eax
  802a41:	8a 10                	mov    (%eax),%dl
  802a43:	84 d2                	test   %dl,%dl
  802a45:	75 f5                	jne    802a3c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  802a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a4c:	5d                   	pop    %ebp
  802a4d:	c3                   	ret    

00802a4e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802a4e:	55                   	push   %ebp
  802a4f:	89 e5                	mov    %esp,%ebp
  802a51:	8b 45 08             	mov    0x8(%ebp),%eax
  802a54:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  802a57:	eb 05                	jmp    802a5e <strfind+0x10>
		if (*s == c)
  802a59:	38 ca                	cmp    %cl,%dl
  802a5b:	74 07                	je     802a64 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  802a5d:	40                   	inc    %eax
  802a5e:	8a 10                	mov    (%eax),%dl
  802a60:	84 d2                	test   %dl,%dl
  802a62:	75 f5                	jne    802a59 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  802a64:	5d                   	pop    %ebp
  802a65:	c3                   	ret    

00802a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802a66:	55                   	push   %ebp
  802a67:	89 e5                	mov    %esp,%ebp
  802a69:	57                   	push   %edi
  802a6a:	56                   	push   %esi
  802a6b:	53                   	push   %ebx
  802a6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  802a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802a75:	85 c9                	test   %ecx,%ecx
  802a77:	74 30                	je     802aa9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802a79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802a7f:	75 25                	jne    802aa6 <memset+0x40>
  802a81:	f6 c1 03             	test   $0x3,%cl
  802a84:	75 20                	jne    802aa6 <memset+0x40>
		c &= 0xFF;
  802a86:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802a89:	89 d3                	mov    %edx,%ebx
  802a8b:	c1 e3 08             	shl    $0x8,%ebx
  802a8e:	89 d6                	mov    %edx,%esi
  802a90:	c1 e6 18             	shl    $0x18,%esi
  802a93:	89 d0                	mov    %edx,%eax
  802a95:	c1 e0 10             	shl    $0x10,%eax
  802a98:	09 f0                	or     %esi,%eax
  802a9a:	09 d0                	or     %edx,%eax
  802a9c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802a9e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802aa1:	fc                   	cld    
  802aa2:	f3 ab                	rep stos %eax,%es:(%edi)
  802aa4:	eb 03                	jmp    802aa9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802aa6:	fc                   	cld    
  802aa7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802aa9:	89 f8                	mov    %edi,%eax
  802aab:	5b                   	pop    %ebx
  802aac:	5e                   	pop    %esi
  802aad:	5f                   	pop    %edi
  802aae:	5d                   	pop    %ebp
  802aaf:	c3                   	ret    

00802ab0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802ab0:	55                   	push   %ebp
  802ab1:	89 e5                	mov    %esp,%ebp
  802ab3:	57                   	push   %edi
  802ab4:	56                   	push   %esi
  802ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  802ab8:	8b 75 0c             	mov    0xc(%ebp),%esi
  802abb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802abe:	39 c6                	cmp    %eax,%esi
  802ac0:	73 34                	jae    802af6 <memmove+0x46>
  802ac2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802ac5:	39 d0                	cmp    %edx,%eax
  802ac7:	73 2d                	jae    802af6 <memmove+0x46>
		s += n;
		d += n;
  802ac9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802acc:	f6 c2 03             	test   $0x3,%dl
  802acf:	75 1b                	jne    802aec <memmove+0x3c>
  802ad1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802ad7:	75 13                	jne    802aec <memmove+0x3c>
  802ad9:	f6 c1 03             	test   $0x3,%cl
  802adc:	75 0e                	jne    802aec <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802ade:	83 ef 04             	sub    $0x4,%edi
  802ae1:	8d 72 fc             	lea    -0x4(%edx),%esi
  802ae4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  802ae7:	fd                   	std    
  802ae8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802aea:	eb 07                	jmp    802af3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802aec:	4f                   	dec    %edi
  802aed:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802af0:	fd                   	std    
  802af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802af3:	fc                   	cld    
  802af4:	eb 20                	jmp    802b16 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802af6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802afc:	75 13                	jne    802b11 <memmove+0x61>
  802afe:	a8 03                	test   $0x3,%al
  802b00:	75 0f                	jne    802b11 <memmove+0x61>
  802b02:	f6 c1 03             	test   $0x3,%cl
  802b05:	75 0a                	jne    802b11 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802b07:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  802b0a:	89 c7                	mov    %eax,%edi
  802b0c:	fc                   	cld    
  802b0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802b0f:	eb 05                	jmp    802b16 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802b11:	89 c7                	mov    %eax,%edi
  802b13:	fc                   	cld    
  802b14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802b16:	5e                   	pop    %esi
  802b17:	5f                   	pop    %edi
  802b18:	5d                   	pop    %ebp
  802b19:	c3                   	ret    

00802b1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802b1a:	55                   	push   %ebp
  802b1b:	89 e5                	mov    %esp,%ebp
  802b1d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802b20:	8b 45 10             	mov    0x10(%ebp),%eax
  802b23:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  802b31:	89 04 24             	mov    %eax,(%esp)
  802b34:	e8 77 ff ff ff       	call   802ab0 <memmove>
}
  802b39:	c9                   	leave  
  802b3a:	c3                   	ret    

00802b3b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802b3b:	55                   	push   %ebp
  802b3c:	89 e5                	mov    %esp,%ebp
  802b3e:	57                   	push   %edi
  802b3f:	56                   	push   %esi
  802b40:	53                   	push   %ebx
  802b41:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b44:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  802b4f:	eb 16                	jmp    802b67 <memcmp+0x2c>
		if (*s1 != *s2)
  802b51:	8a 04 17             	mov    (%edi,%edx,1),%al
  802b54:	42                   	inc    %edx
  802b55:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  802b59:	38 c8                	cmp    %cl,%al
  802b5b:	74 0a                	je     802b67 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  802b5d:	0f b6 c0             	movzbl %al,%eax
  802b60:	0f b6 c9             	movzbl %cl,%ecx
  802b63:	29 c8                	sub    %ecx,%eax
  802b65:	eb 09                	jmp    802b70 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802b67:	39 da                	cmp    %ebx,%edx
  802b69:	75 e6                	jne    802b51 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802b70:	5b                   	pop    %ebx
  802b71:	5e                   	pop    %esi
  802b72:	5f                   	pop    %edi
  802b73:	5d                   	pop    %ebp
  802b74:	c3                   	ret    

00802b75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802b75:	55                   	push   %ebp
  802b76:	89 e5                	mov    %esp,%ebp
  802b78:	8b 45 08             	mov    0x8(%ebp),%eax
  802b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802b7e:	89 c2                	mov    %eax,%edx
  802b80:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802b83:	eb 05                	jmp    802b8a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  802b85:	38 08                	cmp    %cl,(%eax)
  802b87:	74 05                	je     802b8e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802b89:	40                   	inc    %eax
  802b8a:	39 d0                	cmp    %edx,%eax
  802b8c:	72 f7                	jb     802b85 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802b8e:	5d                   	pop    %ebp
  802b8f:	c3                   	ret    

00802b90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802b90:	55                   	push   %ebp
  802b91:	89 e5                	mov    %esp,%ebp
  802b93:	57                   	push   %edi
  802b94:	56                   	push   %esi
  802b95:	53                   	push   %ebx
  802b96:	8b 55 08             	mov    0x8(%ebp),%edx
  802b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802b9c:	eb 01                	jmp    802b9f <strtol+0xf>
		s++;
  802b9e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802b9f:	8a 02                	mov    (%edx),%al
  802ba1:	3c 20                	cmp    $0x20,%al
  802ba3:	74 f9                	je     802b9e <strtol+0xe>
  802ba5:	3c 09                	cmp    $0x9,%al
  802ba7:	74 f5                	je     802b9e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802ba9:	3c 2b                	cmp    $0x2b,%al
  802bab:	75 08                	jne    802bb5 <strtol+0x25>
		s++;
  802bad:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802bae:	bf 00 00 00 00       	mov    $0x0,%edi
  802bb3:	eb 13                	jmp    802bc8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802bb5:	3c 2d                	cmp    $0x2d,%al
  802bb7:	75 0a                	jne    802bc3 <strtol+0x33>
		s++, neg = 1;
  802bb9:	8d 52 01             	lea    0x1(%edx),%edx
  802bbc:	bf 01 00 00 00       	mov    $0x1,%edi
  802bc1:	eb 05                	jmp    802bc8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802bc3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802bc8:	85 db                	test   %ebx,%ebx
  802bca:	74 05                	je     802bd1 <strtol+0x41>
  802bcc:	83 fb 10             	cmp    $0x10,%ebx
  802bcf:	75 28                	jne    802bf9 <strtol+0x69>
  802bd1:	8a 02                	mov    (%edx),%al
  802bd3:	3c 30                	cmp    $0x30,%al
  802bd5:	75 10                	jne    802be7 <strtol+0x57>
  802bd7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802bdb:	75 0a                	jne    802be7 <strtol+0x57>
		s += 2, base = 16;
  802bdd:	83 c2 02             	add    $0x2,%edx
  802be0:	bb 10 00 00 00       	mov    $0x10,%ebx
  802be5:	eb 12                	jmp    802bf9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802be7:	85 db                	test   %ebx,%ebx
  802be9:	75 0e                	jne    802bf9 <strtol+0x69>
  802beb:	3c 30                	cmp    $0x30,%al
  802bed:	75 05                	jne    802bf4 <strtol+0x64>
		s++, base = 8;
  802bef:	42                   	inc    %edx
  802bf0:	b3 08                	mov    $0x8,%bl
  802bf2:	eb 05                	jmp    802bf9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802bf4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  802bfe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802c00:	8a 0a                	mov    (%edx),%cl
  802c02:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802c05:	80 fb 09             	cmp    $0x9,%bl
  802c08:	77 08                	ja     802c12 <strtol+0x82>
			dig = *s - '0';
  802c0a:	0f be c9             	movsbl %cl,%ecx
  802c0d:	83 e9 30             	sub    $0x30,%ecx
  802c10:	eb 1e                	jmp    802c30 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  802c12:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802c15:	80 fb 19             	cmp    $0x19,%bl
  802c18:	77 08                	ja     802c22 <strtol+0x92>
			dig = *s - 'a' + 10;
  802c1a:	0f be c9             	movsbl %cl,%ecx
  802c1d:	83 e9 57             	sub    $0x57,%ecx
  802c20:	eb 0e                	jmp    802c30 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  802c22:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802c25:	80 fb 19             	cmp    $0x19,%bl
  802c28:	77 12                	ja     802c3c <strtol+0xac>
			dig = *s - 'A' + 10;
  802c2a:	0f be c9             	movsbl %cl,%ecx
  802c2d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802c30:	39 f1                	cmp    %esi,%ecx
  802c32:	7d 0c                	jge    802c40 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  802c34:	42                   	inc    %edx
  802c35:	0f af c6             	imul   %esi,%eax
  802c38:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  802c3a:	eb c4                	jmp    802c00 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  802c3c:	89 c1                	mov    %eax,%ecx
  802c3e:	eb 02                	jmp    802c42 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  802c40:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  802c42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802c46:	74 05                	je     802c4d <strtol+0xbd>
		*endptr = (char *) s;
  802c48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802c4b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802c4d:	85 ff                	test   %edi,%edi
  802c4f:	74 04                	je     802c55 <strtol+0xc5>
  802c51:	89 c8                	mov    %ecx,%eax
  802c53:	f7 d8                	neg    %eax
}
  802c55:	5b                   	pop    %ebx
  802c56:	5e                   	pop    %esi
  802c57:	5f                   	pop    %edi
  802c58:	5d                   	pop    %ebp
  802c59:	c3                   	ret    
	...

00802c5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802c5c:	55                   	push   %ebp
  802c5d:	89 e5                	mov    %esp,%ebp
  802c5f:	57                   	push   %edi
  802c60:	56                   	push   %esi
  802c61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802c62:	b8 00 00 00 00       	mov    $0x0,%eax
  802c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  802c6d:	89 c3                	mov    %eax,%ebx
  802c6f:	89 c7                	mov    %eax,%edi
  802c71:	89 c6                	mov    %eax,%esi
  802c73:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802c75:	5b                   	pop    %ebx
  802c76:	5e                   	pop    %esi
  802c77:	5f                   	pop    %edi
  802c78:	5d                   	pop    %ebp
  802c79:	c3                   	ret    

00802c7a <sys_cgetc>:

int
sys_cgetc(void)
{
  802c7a:	55                   	push   %ebp
  802c7b:	89 e5                	mov    %esp,%ebp
  802c7d:	57                   	push   %edi
  802c7e:	56                   	push   %esi
  802c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802c80:	ba 00 00 00 00       	mov    $0x0,%edx
  802c85:	b8 01 00 00 00       	mov    $0x1,%eax
  802c8a:	89 d1                	mov    %edx,%ecx
  802c8c:	89 d3                	mov    %edx,%ebx
  802c8e:	89 d7                	mov    %edx,%edi
  802c90:	89 d6                	mov    %edx,%esi
  802c92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802c94:	5b                   	pop    %ebx
  802c95:	5e                   	pop    %esi
  802c96:	5f                   	pop    %edi
  802c97:	5d                   	pop    %ebp
  802c98:	c3                   	ret    

00802c99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802c99:	55                   	push   %ebp
  802c9a:	89 e5                	mov    %esp,%ebp
  802c9c:	57                   	push   %edi
  802c9d:	56                   	push   %esi
  802c9e:	53                   	push   %ebx
  802c9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802ca2:	b9 00 00 00 00       	mov    $0x0,%ecx
  802ca7:	b8 03 00 00 00       	mov    $0x3,%eax
  802cac:	8b 55 08             	mov    0x8(%ebp),%edx
  802caf:	89 cb                	mov    %ecx,%ebx
  802cb1:	89 cf                	mov    %ecx,%edi
  802cb3:	89 ce                	mov    %ecx,%esi
  802cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802cb7:	85 c0                	test   %eax,%eax
  802cb9:	7e 28                	jle    802ce3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802cbb:	89 44 24 10          	mov    %eax,0x10(%esp)
  802cbf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802cc6:	00 
  802cc7:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802cce:	00 
  802ccf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802cd6:	00 
  802cd7:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802cde:	e8 b1 f5 ff ff       	call   802294 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802ce3:	83 c4 2c             	add    $0x2c,%esp
  802ce6:	5b                   	pop    %ebx
  802ce7:	5e                   	pop    %esi
  802ce8:	5f                   	pop    %edi
  802ce9:	5d                   	pop    %ebp
  802cea:	c3                   	ret    

00802ceb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802ceb:	55                   	push   %ebp
  802cec:	89 e5                	mov    %esp,%ebp
  802cee:	57                   	push   %edi
  802cef:	56                   	push   %esi
  802cf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802cf1:	ba 00 00 00 00       	mov    $0x0,%edx
  802cf6:	b8 02 00 00 00       	mov    $0x2,%eax
  802cfb:	89 d1                	mov    %edx,%ecx
  802cfd:	89 d3                	mov    %edx,%ebx
  802cff:	89 d7                	mov    %edx,%edi
  802d01:	89 d6                	mov    %edx,%esi
  802d03:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802d05:	5b                   	pop    %ebx
  802d06:	5e                   	pop    %esi
  802d07:	5f                   	pop    %edi
  802d08:	5d                   	pop    %ebp
  802d09:	c3                   	ret    

00802d0a <sys_yield>:

void
sys_yield(void)
{
  802d0a:	55                   	push   %ebp
  802d0b:	89 e5                	mov    %esp,%ebp
  802d0d:	57                   	push   %edi
  802d0e:	56                   	push   %esi
  802d0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802d10:	ba 00 00 00 00       	mov    $0x0,%edx
  802d15:	b8 0b 00 00 00       	mov    $0xb,%eax
  802d1a:	89 d1                	mov    %edx,%ecx
  802d1c:	89 d3                	mov    %edx,%ebx
  802d1e:	89 d7                	mov    %edx,%edi
  802d20:	89 d6                	mov    %edx,%esi
  802d22:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802d24:	5b                   	pop    %ebx
  802d25:	5e                   	pop    %esi
  802d26:	5f                   	pop    %edi
  802d27:	5d                   	pop    %ebp
  802d28:	c3                   	ret    

00802d29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802d29:	55                   	push   %ebp
  802d2a:	89 e5                	mov    %esp,%ebp
  802d2c:	57                   	push   %edi
  802d2d:	56                   	push   %esi
  802d2e:	53                   	push   %ebx
  802d2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802d32:	be 00 00 00 00       	mov    $0x0,%esi
  802d37:	b8 04 00 00 00       	mov    $0x4,%eax
  802d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d42:	8b 55 08             	mov    0x8(%ebp),%edx
  802d45:	89 f7                	mov    %esi,%edi
  802d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802d49:	85 c0                	test   %eax,%eax
  802d4b:	7e 28                	jle    802d75 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  802d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802d51:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802d58:	00 
  802d59:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802d60:	00 
  802d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802d68:	00 
  802d69:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802d70:	e8 1f f5 ff ff       	call   802294 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802d75:	83 c4 2c             	add    $0x2c,%esp
  802d78:	5b                   	pop    %ebx
  802d79:	5e                   	pop    %esi
  802d7a:	5f                   	pop    %edi
  802d7b:	5d                   	pop    %ebp
  802d7c:	c3                   	ret    

00802d7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802d7d:	55                   	push   %ebp
  802d7e:	89 e5                	mov    %esp,%ebp
  802d80:	57                   	push   %edi
  802d81:	56                   	push   %esi
  802d82:	53                   	push   %ebx
  802d83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802d86:	b8 05 00 00 00       	mov    $0x5,%eax
  802d8b:	8b 75 18             	mov    0x18(%ebp),%esi
  802d8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d97:	8b 55 08             	mov    0x8(%ebp),%edx
  802d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802d9c:	85 c0                	test   %eax,%eax
  802d9e:	7e 28                	jle    802dc8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802da0:	89 44 24 10          	mov    %eax,0x10(%esp)
  802da4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802dab:	00 
  802dac:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802db3:	00 
  802db4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802dbb:	00 
  802dbc:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802dc3:	e8 cc f4 ff ff       	call   802294 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802dc8:	83 c4 2c             	add    $0x2c,%esp
  802dcb:	5b                   	pop    %ebx
  802dcc:	5e                   	pop    %esi
  802dcd:	5f                   	pop    %edi
  802dce:	5d                   	pop    %ebp
  802dcf:	c3                   	ret    

00802dd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802dd0:	55                   	push   %ebp
  802dd1:	89 e5                	mov    %esp,%ebp
  802dd3:	57                   	push   %edi
  802dd4:	56                   	push   %esi
  802dd5:	53                   	push   %ebx
  802dd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dde:	b8 06 00 00 00       	mov    $0x6,%eax
  802de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802de6:	8b 55 08             	mov    0x8(%ebp),%edx
  802de9:	89 df                	mov    %ebx,%edi
  802deb:	89 de                	mov    %ebx,%esi
  802ded:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802def:	85 c0                	test   %eax,%eax
  802df1:	7e 28                	jle    802e1b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802df3:	89 44 24 10          	mov    %eax,0x10(%esp)
  802df7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802dfe:	00 
  802dff:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802e06:	00 
  802e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802e0e:	00 
  802e0f:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802e16:	e8 79 f4 ff ff       	call   802294 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802e1b:	83 c4 2c             	add    $0x2c,%esp
  802e1e:	5b                   	pop    %ebx
  802e1f:	5e                   	pop    %esi
  802e20:	5f                   	pop    %edi
  802e21:	5d                   	pop    %ebp
  802e22:	c3                   	ret    

00802e23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802e23:	55                   	push   %ebp
  802e24:	89 e5                	mov    %esp,%ebp
  802e26:	57                   	push   %edi
  802e27:	56                   	push   %esi
  802e28:	53                   	push   %ebx
  802e29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e31:	b8 08 00 00 00       	mov    $0x8,%eax
  802e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e39:	8b 55 08             	mov    0x8(%ebp),%edx
  802e3c:	89 df                	mov    %ebx,%edi
  802e3e:	89 de                	mov    %ebx,%esi
  802e40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802e42:	85 c0                	test   %eax,%eax
  802e44:	7e 28                	jle    802e6e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802e46:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e4a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  802e51:	00 
  802e52:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802e59:	00 
  802e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802e61:	00 
  802e62:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802e69:	e8 26 f4 ff ff       	call   802294 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802e6e:	83 c4 2c             	add    $0x2c,%esp
  802e71:	5b                   	pop    %ebx
  802e72:	5e                   	pop    %esi
  802e73:	5f                   	pop    %edi
  802e74:	5d                   	pop    %ebp
  802e75:	c3                   	ret    

00802e76 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802e76:	55                   	push   %ebp
  802e77:	89 e5                	mov    %esp,%ebp
  802e79:	57                   	push   %edi
  802e7a:	56                   	push   %esi
  802e7b:	53                   	push   %ebx
  802e7c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e84:	b8 09 00 00 00       	mov    $0x9,%eax
  802e89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e8c:	8b 55 08             	mov    0x8(%ebp),%edx
  802e8f:	89 df                	mov    %ebx,%edi
  802e91:	89 de                	mov    %ebx,%esi
  802e93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802e95:	85 c0                	test   %eax,%eax
  802e97:	7e 28                	jle    802ec1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802e99:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e9d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802ea4:	00 
  802ea5:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802eac:	00 
  802ead:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802eb4:	00 
  802eb5:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802ebc:	e8 d3 f3 ff ff       	call   802294 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802ec1:	83 c4 2c             	add    $0x2c,%esp
  802ec4:	5b                   	pop    %ebx
  802ec5:	5e                   	pop    %esi
  802ec6:	5f                   	pop    %edi
  802ec7:	5d                   	pop    %ebp
  802ec8:	c3                   	ret    

00802ec9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802ec9:	55                   	push   %ebp
  802eca:	89 e5                	mov    %esp,%ebp
  802ecc:	57                   	push   %edi
  802ecd:	56                   	push   %esi
  802ece:	53                   	push   %ebx
  802ecf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802ed2:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ed7:	b8 0a 00 00 00       	mov    $0xa,%eax
  802edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802edf:	8b 55 08             	mov    0x8(%ebp),%edx
  802ee2:	89 df                	mov    %ebx,%edi
  802ee4:	89 de                	mov    %ebx,%esi
  802ee6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802ee8:	85 c0                	test   %eax,%eax
  802eea:	7e 28                	jle    802f14 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802eec:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ef0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802ef7:	00 
  802ef8:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802eff:	00 
  802f00:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802f07:	00 
  802f08:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802f0f:	e8 80 f3 ff ff       	call   802294 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802f14:	83 c4 2c             	add    $0x2c,%esp
  802f17:	5b                   	pop    %ebx
  802f18:	5e                   	pop    %esi
  802f19:	5f                   	pop    %edi
  802f1a:	5d                   	pop    %ebp
  802f1b:	c3                   	ret    

00802f1c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802f1c:	55                   	push   %ebp
  802f1d:	89 e5                	mov    %esp,%ebp
  802f1f:	57                   	push   %edi
  802f20:	56                   	push   %esi
  802f21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802f22:	be 00 00 00 00       	mov    $0x0,%esi
  802f27:	b8 0c 00 00 00       	mov    $0xc,%eax
  802f2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  802f2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f35:	8b 55 08             	mov    0x8(%ebp),%edx
  802f38:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802f3a:	5b                   	pop    %ebx
  802f3b:	5e                   	pop    %esi
  802f3c:	5f                   	pop    %edi
  802f3d:	5d                   	pop    %ebp
  802f3e:	c3                   	ret    

00802f3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802f3f:	55                   	push   %ebp
  802f40:	89 e5                	mov    %esp,%ebp
  802f42:	57                   	push   %edi
  802f43:	56                   	push   %esi
  802f44:	53                   	push   %ebx
  802f45:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802f48:	b9 00 00 00 00       	mov    $0x0,%ecx
  802f4d:	b8 0d 00 00 00       	mov    $0xd,%eax
  802f52:	8b 55 08             	mov    0x8(%ebp),%edx
  802f55:	89 cb                	mov    %ecx,%ebx
  802f57:	89 cf                	mov    %ecx,%edi
  802f59:	89 ce                	mov    %ecx,%esi
  802f5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802f5d:	85 c0                	test   %eax,%eax
  802f5f:	7e 28                	jle    802f89 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802f61:	89 44 24 10          	mov    %eax,0x10(%esp)
  802f65:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802f6c:	00 
  802f6d:	c7 44 24 08 7f 4b 80 	movl   $0x804b7f,0x8(%esp)
  802f74:	00 
  802f75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802f7c:	00 
  802f7d:	c7 04 24 9c 4b 80 00 	movl   $0x804b9c,(%esp)
  802f84:	e8 0b f3 ff ff       	call   802294 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802f89:	83 c4 2c             	add    $0x2c,%esp
  802f8c:	5b                   	pop    %ebx
  802f8d:	5e                   	pop    %esi
  802f8e:	5f                   	pop    %edi
  802f8f:	5d                   	pop    %ebp
  802f90:	c3                   	ret    
  802f91:	00 00                	add    %al,(%eax)
	...

00802f94 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802f94:	55                   	push   %ebp
  802f95:	89 e5                	mov    %esp,%ebp
  802f97:	53                   	push   %ebx
  802f98:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802f9b:	83 3d 24 a1 80 00 00 	cmpl   $0x0,0x80a124
  802fa2:	75 6f                	jne    803013 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  802fa4:	e8 42 fd ff ff       	call   802ceb <sys_getenvid>
  802fa9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  802fab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802fb2:	00 
  802fb3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802fba:	ee 
  802fbb:	89 04 24             	mov    %eax,(%esp)
  802fbe:	e8 66 fd ff ff       	call   802d29 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  802fc3:	85 c0                	test   %eax,%eax
  802fc5:	79 1c                	jns    802fe3 <set_pgfault_handler+0x4f>
  802fc7:	c7 44 24 08 ac 4b 80 	movl   $0x804bac,0x8(%esp)
  802fce:	00 
  802fcf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802fd6:	00 
  802fd7:	c7 04 24 05 4c 80 00 	movl   $0x804c05,(%esp)
  802fde:	e8 b1 f2 ff ff       	call   802294 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  802fe3:	c7 44 24 04 24 30 80 	movl   $0x803024,0x4(%esp)
  802fea:	00 
  802feb:	89 1c 24             	mov    %ebx,(%esp)
  802fee:	e8 d6 fe ff ff       	call   802ec9 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  802ff3:	85 c0                	test   %eax,%eax
  802ff5:	79 1c                	jns    803013 <set_pgfault_handler+0x7f>
  802ff7:	c7 44 24 08 d4 4b 80 	movl   $0x804bd4,0x8(%esp)
  802ffe:	00 
  802fff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  803006:	00 
  803007:	c7 04 24 05 4c 80 00 	movl   $0x804c05,(%esp)
  80300e:	e8 81 f2 ff ff       	call   802294 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803013:	8b 45 08             	mov    0x8(%ebp),%eax
  803016:	a3 24 a1 80 00       	mov    %eax,0x80a124
}
  80301b:	83 c4 14             	add    $0x14,%esp
  80301e:	5b                   	pop    %ebx
  80301f:	5d                   	pop    %ebp
  803020:	c3                   	ret    
  803021:	00 00                	add    %al,(%eax)
	...

00803024 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803024:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803025:	a1 24 a1 80 00       	mov    0x80a124,%eax
	call *%eax
  80302a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80302c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80302f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  803033:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  803038:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  80303c:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80303e:	83 c4 08             	add    $0x8,%esp
	popal
  803041:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  803042:	83 c4 04             	add    $0x4,%esp
	popfl
  803045:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  803046:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  803049:	c3                   	ret    
	...

0080304c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80304c:	55                   	push   %ebp
  80304d:	89 e5                	mov    %esp,%ebp
  80304f:	56                   	push   %esi
  803050:	53                   	push   %ebx
  803051:	83 ec 10             	sub    $0x10,%esp
  803054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  803057:	8b 45 0c             	mov    0xc(%ebp),%eax
  80305a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80305d:	85 c0                	test   %eax,%eax
  80305f:	75 05                	jne    803066 <ipc_recv+0x1a>
  803061:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  803066:	89 04 24             	mov    %eax,(%esp)
  803069:	e8 d1 fe ff ff       	call   802f3f <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80306e:	85 c0                	test   %eax,%eax
  803070:	79 16                	jns    803088 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  803072:	85 db                	test   %ebx,%ebx
  803074:	74 06                	je     80307c <ipc_recv+0x30>
  803076:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  80307c:	85 f6                	test   %esi,%esi
  80307e:	74 32                	je     8030b2 <ipc_recv+0x66>
  803080:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  803086:	eb 2a                	jmp    8030b2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  803088:	85 db                	test   %ebx,%ebx
  80308a:	74 0c                	je     803098 <ipc_recv+0x4c>
  80308c:	a1 20 a1 80 00       	mov    0x80a120,%eax
  803091:	8b 00                	mov    (%eax),%eax
  803093:	8b 40 74             	mov    0x74(%eax),%eax
  803096:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  803098:	85 f6                	test   %esi,%esi
  80309a:	74 0c                	je     8030a8 <ipc_recv+0x5c>
  80309c:	a1 20 a1 80 00       	mov    0x80a120,%eax
  8030a1:	8b 00                	mov    (%eax),%eax
  8030a3:	8b 40 78             	mov    0x78(%eax),%eax
  8030a6:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8030a8:	a1 20 a1 80 00       	mov    0x80a120,%eax
  8030ad:	8b 00                	mov    (%eax),%eax
  8030af:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8030b2:	83 c4 10             	add    $0x10,%esp
  8030b5:	5b                   	pop    %ebx
  8030b6:	5e                   	pop    %esi
  8030b7:	5d                   	pop    %ebp
  8030b8:	c3                   	ret    

008030b9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8030b9:	55                   	push   %ebp
  8030ba:	89 e5                	mov    %esp,%ebp
  8030bc:	57                   	push   %edi
  8030bd:	56                   	push   %esi
  8030be:	53                   	push   %ebx
  8030bf:	83 ec 1c             	sub    $0x1c,%esp
  8030c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8030c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8030c8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8030cb:	85 db                	test   %ebx,%ebx
  8030cd:	75 05                	jne    8030d4 <ipc_send+0x1b>
  8030cf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8030d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8030d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8030e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8030e3:	89 04 24             	mov    %eax,(%esp)
  8030e6:	e8 31 fe ff ff       	call   802f1c <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8030eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8030ee:	75 07                	jne    8030f7 <ipc_send+0x3e>
  8030f0:	e8 15 fc ff ff       	call   802d0a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8030f5:	eb dd                	jmp    8030d4 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8030f7:	85 c0                	test   %eax,%eax
  8030f9:	79 1c                	jns    803117 <ipc_send+0x5e>
  8030fb:	c7 44 24 08 13 4c 80 	movl   $0x804c13,0x8(%esp)
  803102:	00 
  803103:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80310a:	00 
  80310b:	c7 04 24 25 4c 80 00 	movl   $0x804c25,(%esp)
  803112:	e8 7d f1 ff ff       	call   802294 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  803117:	83 c4 1c             	add    $0x1c,%esp
  80311a:	5b                   	pop    %ebx
  80311b:	5e                   	pop    %esi
  80311c:	5f                   	pop    %edi
  80311d:	5d                   	pop    %ebp
  80311e:	c3                   	ret    

0080311f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80311f:	55                   	push   %ebp
  803120:	89 e5                	mov    %esp,%ebp
  803122:	53                   	push   %ebx
  803123:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  803126:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80312b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  803132:	89 c2                	mov    %eax,%edx
  803134:	c1 e2 07             	shl    $0x7,%edx
  803137:	29 ca                	sub    %ecx,%edx
  803139:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80313f:	8b 52 50             	mov    0x50(%edx),%edx
  803142:	39 da                	cmp    %ebx,%edx
  803144:	75 0f                	jne    803155 <ipc_find_env+0x36>
			return envs[i].env_id;
  803146:	c1 e0 07             	shl    $0x7,%eax
  803149:	29 c8                	sub    %ecx,%eax
  80314b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803150:	8b 40 40             	mov    0x40(%eax),%eax
  803153:	eb 0c                	jmp    803161 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803155:	40                   	inc    %eax
  803156:	3d 00 04 00 00       	cmp    $0x400,%eax
  80315b:	75 ce                	jne    80312b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80315d:	66 b8 00 00          	mov    $0x0,%ax
}
  803161:	5b                   	pop    %ebx
  803162:	5d                   	pop    %ebp
  803163:	c3                   	ret    

00803164 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  803164:	55                   	push   %ebp
  803165:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  803167:	8b 45 08             	mov    0x8(%ebp),%eax
  80316a:	05 00 00 00 30       	add    $0x30000000,%eax
  80316f:	c1 e8 0c             	shr    $0xc,%eax
}
  803172:	5d                   	pop    %ebp
  803173:	c3                   	ret    

00803174 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  803174:	55                   	push   %ebp
  803175:	89 e5                	mov    %esp,%ebp
  803177:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80317a:	8b 45 08             	mov    0x8(%ebp),%eax
  80317d:	89 04 24             	mov    %eax,(%esp)
  803180:	e8 df ff ff ff       	call   803164 <fd2num>
  803185:	05 20 00 0d 00       	add    $0xd0020,%eax
  80318a:	c1 e0 0c             	shl    $0xc,%eax
}
  80318d:	c9                   	leave  
  80318e:	c3                   	ret    

0080318f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80318f:	55                   	push   %ebp
  803190:	89 e5                	mov    %esp,%ebp
  803192:	53                   	push   %ebx
  803193:	8b 5d 08             	mov    0x8(%ebp),%ebx
  803196:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80319b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80319d:	89 c2                	mov    %eax,%edx
  80319f:	c1 ea 16             	shr    $0x16,%edx
  8031a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8031a9:	f6 c2 01             	test   $0x1,%dl
  8031ac:	74 11                	je     8031bf <fd_alloc+0x30>
  8031ae:	89 c2                	mov    %eax,%edx
  8031b0:	c1 ea 0c             	shr    $0xc,%edx
  8031b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8031ba:	f6 c2 01             	test   $0x1,%dl
  8031bd:	75 09                	jne    8031c8 <fd_alloc+0x39>
			*fd_store = fd;
  8031bf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8031c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8031c6:	eb 17                	jmp    8031df <fd_alloc+0x50>
  8031c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8031cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8031d2:	75 c7                	jne    80319b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8031d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8031da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8031df:	5b                   	pop    %ebx
  8031e0:	5d                   	pop    %ebp
  8031e1:	c3                   	ret    

008031e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8031e2:	55                   	push   %ebp
  8031e3:	89 e5                	mov    %esp,%ebp
  8031e5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8031e8:	83 f8 1f             	cmp    $0x1f,%eax
  8031eb:	77 36                	ja     803223 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8031ed:	05 00 00 0d 00       	add    $0xd0000,%eax
  8031f2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8031f5:	89 c2                	mov    %eax,%edx
  8031f7:	c1 ea 16             	shr    $0x16,%edx
  8031fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803201:	f6 c2 01             	test   $0x1,%dl
  803204:	74 24                	je     80322a <fd_lookup+0x48>
  803206:	89 c2                	mov    %eax,%edx
  803208:	c1 ea 0c             	shr    $0xc,%edx
  80320b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  803212:	f6 c2 01             	test   $0x1,%dl
  803215:	74 1a                	je     803231 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  803217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80321a:	89 02                	mov    %eax,(%edx)
	return 0;
  80321c:	b8 00 00 00 00       	mov    $0x0,%eax
  803221:	eb 13                	jmp    803236 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  803223:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803228:	eb 0c                	jmp    803236 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80322a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80322f:	eb 05                	jmp    803236 <fd_lookup+0x54>
  803231:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  803236:	5d                   	pop    %ebp
  803237:	c3                   	ret    

00803238 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  803238:	55                   	push   %ebp
  803239:	89 e5                	mov    %esp,%ebp
  80323b:	53                   	push   %ebx
  80323c:	83 ec 14             	sub    $0x14,%esp
  80323f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803242:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  803245:	ba 00 00 00 00       	mov    $0x0,%edx
  80324a:	eb 0e                	jmp    80325a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80324c:	39 08                	cmp    %ecx,(%eax)
  80324e:	75 09                	jne    803259 <dev_lookup+0x21>
			*dev = devtab[i];
  803250:	89 03                	mov    %eax,(%ebx)
			return 0;
  803252:	b8 00 00 00 00       	mov    $0x0,%eax
  803257:	eb 35                	jmp    80328e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  803259:	42                   	inc    %edx
  80325a:	8b 04 95 b0 4c 80 00 	mov    0x804cb0(,%edx,4),%eax
  803261:	85 c0                	test   %eax,%eax
  803263:	75 e7                	jne    80324c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  803265:	a1 20 a1 80 00       	mov    0x80a120,%eax
  80326a:	8b 00                	mov    (%eax),%eax
  80326c:	8b 40 48             	mov    0x48(%eax),%eax
  80326f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803273:	89 44 24 04          	mov    %eax,0x4(%esp)
  803277:	c7 04 24 30 4c 80 00 	movl   $0x804c30,(%esp)
  80327e:	e8 09 f1 ff ff       	call   80238c <cprintf>
	*dev = 0;
  803283:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  803289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80328e:	83 c4 14             	add    $0x14,%esp
  803291:	5b                   	pop    %ebx
  803292:	5d                   	pop    %ebp
  803293:	c3                   	ret    

00803294 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  803294:	55                   	push   %ebp
  803295:	89 e5                	mov    %esp,%ebp
  803297:	56                   	push   %esi
  803298:	53                   	push   %ebx
  803299:	83 ec 30             	sub    $0x30,%esp
  80329c:	8b 75 08             	mov    0x8(%ebp),%esi
  80329f:	8a 45 0c             	mov    0xc(%ebp),%al
  8032a2:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8032a5:	89 34 24             	mov    %esi,(%esp)
  8032a8:	e8 b7 fe ff ff       	call   803164 <fd2num>
  8032ad:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8032b0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8032b4:	89 04 24             	mov    %eax,(%esp)
  8032b7:	e8 26 ff ff ff       	call   8031e2 <fd_lookup>
  8032bc:	89 c3                	mov    %eax,%ebx
  8032be:	85 c0                	test   %eax,%eax
  8032c0:	78 05                	js     8032c7 <fd_close+0x33>
	    || fd != fd2)
  8032c2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8032c5:	74 0d                	je     8032d4 <fd_close+0x40>
		return (must_exist ? r : 0);
  8032c7:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8032cb:	75 46                	jne    803313 <fd_close+0x7f>
  8032cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8032d2:	eb 3f                	jmp    803313 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8032d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8032d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032db:	8b 06                	mov    (%esi),%eax
  8032dd:	89 04 24             	mov    %eax,(%esp)
  8032e0:	e8 53 ff ff ff       	call   803238 <dev_lookup>
  8032e5:	89 c3                	mov    %eax,%ebx
  8032e7:	85 c0                	test   %eax,%eax
  8032e9:	78 18                	js     803303 <fd_close+0x6f>
		if (dev->dev_close)
  8032eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032ee:	8b 40 10             	mov    0x10(%eax),%eax
  8032f1:	85 c0                	test   %eax,%eax
  8032f3:	74 09                	je     8032fe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8032f5:	89 34 24             	mov    %esi,(%esp)
  8032f8:	ff d0                	call   *%eax
  8032fa:	89 c3                	mov    %eax,%ebx
  8032fc:	eb 05                	jmp    803303 <fd_close+0x6f>
		else
			r = 0;
  8032fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  803303:	89 74 24 04          	mov    %esi,0x4(%esp)
  803307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80330e:	e8 bd fa ff ff       	call   802dd0 <sys_page_unmap>
	return r;
}
  803313:	89 d8                	mov    %ebx,%eax
  803315:	83 c4 30             	add    $0x30,%esp
  803318:	5b                   	pop    %ebx
  803319:	5e                   	pop    %esi
  80331a:	5d                   	pop    %ebp
  80331b:	c3                   	ret    

0080331c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80331c:	55                   	push   %ebp
  80331d:	89 e5                	mov    %esp,%ebp
  80331f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803325:	89 44 24 04          	mov    %eax,0x4(%esp)
  803329:	8b 45 08             	mov    0x8(%ebp),%eax
  80332c:	89 04 24             	mov    %eax,(%esp)
  80332f:	e8 ae fe ff ff       	call   8031e2 <fd_lookup>
  803334:	85 c0                	test   %eax,%eax
  803336:	78 13                	js     80334b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  803338:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80333f:	00 
  803340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803343:	89 04 24             	mov    %eax,(%esp)
  803346:	e8 49 ff ff ff       	call   803294 <fd_close>
}
  80334b:	c9                   	leave  
  80334c:	c3                   	ret    

0080334d <close_all>:

void
close_all(void)
{
  80334d:	55                   	push   %ebp
  80334e:	89 e5                	mov    %esp,%ebp
  803350:	53                   	push   %ebx
  803351:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  803354:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  803359:	89 1c 24             	mov    %ebx,(%esp)
  80335c:	e8 bb ff ff ff       	call   80331c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  803361:	43                   	inc    %ebx
  803362:	83 fb 20             	cmp    $0x20,%ebx
  803365:	75 f2                	jne    803359 <close_all+0xc>
		close(i);
}
  803367:	83 c4 14             	add    $0x14,%esp
  80336a:	5b                   	pop    %ebx
  80336b:	5d                   	pop    %ebp
  80336c:	c3                   	ret    

0080336d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80336d:	55                   	push   %ebp
  80336e:	89 e5                	mov    %esp,%ebp
  803370:	57                   	push   %edi
  803371:	56                   	push   %esi
  803372:	53                   	push   %ebx
  803373:	83 ec 4c             	sub    $0x4c,%esp
  803376:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  803379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80337c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803380:	8b 45 08             	mov    0x8(%ebp),%eax
  803383:	89 04 24             	mov    %eax,(%esp)
  803386:	e8 57 fe ff ff       	call   8031e2 <fd_lookup>
  80338b:	89 c3                	mov    %eax,%ebx
  80338d:	85 c0                	test   %eax,%eax
  80338f:	0f 88 e1 00 00 00    	js     803476 <dup+0x109>
		return r;
	close(newfdnum);
  803395:	89 3c 24             	mov    %edi,(%esp)
  803398:	e8 7f ff ff ff       	call   80331c <close>

	newfd = INDEX2FD(newfdnum);
  80339d:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8033a3:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8033a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8033a9:	89 04 24             	mov    %eax,(%esp)
  8033ac:	e8 c3 fd ff ff       	call   803174 <fd2data>
  8033b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8033b3:	89 34 24             	mov    %esi,(%esp)
  8033b6:	e8 b9 fd ff ff       	call   803174 <fd2data>
  8033bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8033be:	89 d8                	mov    %ebx,%eax
  8033c0:	c1 e8 16             	shr    $0x16,%eax
  8033c3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8033ca:	a8 01                	test   $0x1,%al
  8033cc:	74 46                	je     803414 <dup+0xa7>
  8033ce:	89 d8                	mov    %ebx,%eax
  8033d0:	c1 e8 0c             	shr    $0xc,%eax
  8033d3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8033da:	f6 c2 01             	test   $0x1,%dl
  8033dd:	74 35                	je     803414 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8033df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8033e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8033eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8033ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8033f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8033f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8033fd:	00 
  8033fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803402:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803409:	e8 6f f9 ff ff       	call   802d7d <sys_page_map>
  80340e:	89 c3                	mov    %eax,%ebx
  803410:	85 c0                	test   %eax,%eax
  803412:	78 3b                	js     80344f <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  803414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803417:	89 c2                	mov    %eax,%edx
  803419:	c1 ea 0c             	shr    $0xc,%edx
  80341c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  803423:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  803429:	89 54 24 10          	mov    %edx,0x10(%esp)
  80342d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803431:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803438:	00 
  803439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80343d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803444:	e8 34 f9 ff ff       	call   802d7d <sys_page_map>
  803449:	89 c3                	mov    %eax,%ebx
  80344b:	85 c0                	test   %eax,%eax
  80344d:	79 25                	jns    803474 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80344f:	89 74 24 04          	mov    %esi,0x4(%esp)
  803453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80345a:	e8 71 f9 ff ff       	call   802dd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80345f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803462:	89 44 24 04          	mov    %eax,0x4(%esp)
  803466:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80346d:	e8 5e f9 ff ff       	call   802dd0 <sys_page_unmap>
	return r;
  803472:	eb 02                	jmp    803476 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  803474:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  803476:	89 d8                	mov    %ebx,%eax
  803478:	83 c4 4c             	add    $0x4c,%esp
  80347b:	5b                   	pop    %ebx
  80347c:	5e                   	pop    %esi
  80347d:	5f                   	pop    %edi
  80347e:	5d                   	pop    %ebp
  80347f:	c3                   	ret    

00803480 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  803480:	55                   	push   %ebp
  803481:	89 e5                	mov    %esp,%ebp
  803483:	53                   	push   %ebx
  803484:	83 ec 24             	sub    $0x24,%esp
  803487:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80348a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80348d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803491:	89 1c 24             	mov    %ebx,(%esp)
  803494:	e8 49 fd ff ff       	call   8031e2 <fd_lookup>
  803499:	85 c0                	test   %eax,%eax
  80349b:	78 6f                	js     80350c <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80349d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8034a7:	8b 00                	mov    (%eax),%eax
  8034a9:	89 04 24             	mov    %eax,(%esp)
  8034ac:	e8 87 fd ff ff       	call   803238 <dev_lookup>
  8034b1:	85 c0                	test   %eax,%eax
  8034b3:	78 57                	js     80350c <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8034b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8034b8:	8b 50 08             	mov    0x8(%eax),%edx
  8034bb:	83 e2 03             	and    $0x3,%edx
  8034be:	83 fa 01             	cmp    $0x1,%edx
  8034c1:	75 25                	jne    8034e8 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8034c3:	a1 20 a1 80 00       	mov    0x80a120,%eax
  8034c8:	8b 00                	mov    (%eax),%eax
  8034ca:	8b 40 48             	mov    0x48(%eax),%eax
  8034cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8034d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034d5:	c7 04 24 74 4c 80 00 	movl   $0x804c74,(%esp)
  8034dc:	e8 ab ee ff ff       	call   80238c <cprintf>
		return -E_INVAL;
  8034e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8034e6:	eb 24                	jmp    80350c <read+0x8c>
	}
	if (!dev->dev_read)
  8034e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8034eb:	8b 52 08             	mov    0x8(%edx),%edx
  8034ee:	85 d2                	test   %edx,%edx
  8034f0:	74 15                	je     803507 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8034f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8034f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8034f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8034fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803500:	89 04 24             	mov    %eax,(%esp)
  803503:	ff d2                	call   *%edx
  803505:	eb 05                	jmp    80350c <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  803507:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80350c:	83 c4 24             	add    $0x24,%esp
  80350f:	5b                   	pop    %ebx
  803510:	5d                   	pop    %ebp
  803511:	c3                   	ret    

00803512 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  803512:	55                   	push   %ebp
  803513:	89 e5                	mov    %esp,%ebp
  803515:	57                   	push   %edi
  803516:	56                   	push   %esi
  803517:	53                   	push   %ebx
  803518:	83 ec 1c             	sub    $0x1c,%esp
  80351b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80351e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803521:	bb 00 00 00 00       	mov    $0x0,%ebx
  803526:	eb 23                	jmp    80354b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  803528:	89 f0                	mov    %esi,%eax
  80352a:	29 d8                	sub    %ebx,%eax
  80352c:	89 44 24 08          	mov    %eax,0x8(%esp)
  803530:	8b 45 0c             	mov    0xc(%ebp),%eax
  803533:	01 d8                	add    %ebx,%eax
  803535:	89 44 24 04          	mov    %eax,0x4(%esp)
  803539:	89 3c 24             	mov    %edi,(%esp)
  80353c:	e8 3f ff ff ff       	call   803480 <read>
		if (m < 0)
  803541:	85 c0                	test   %eax,%eax
  803543:	78 10                	js     803555 <readn+0x43>
			return m;
		if (m == 0)
  803545:	85 c0                	test   %eax,%eax
  803547:	74 0a                	je     803553 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803549:	01 c3                	add    %eax,%ebx
  80354b:	39 f3                	cmp    %esi,%ebx
  80354d:	72 d9                	jb     803528 <readn+0x16>
  80354f:	89 d8                	mov    %ebx,%eax
  803551:	eb 02                	jmp    803555 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  803553:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  803555:	83 c4 1c             	add    $0x1c,%esp
  803558:	5b                   	pop    %ebx
  803559:	5e                   	pop    %esi
  80355a:	5f                   	pop    %edi
  80355b:	5d                   	pop    %ebp
  80355c:	c3                   	ret    

0080355d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80355d:	55                   	push   %ebp
  80355e:	89 e5                	mov    %esp,%ebp
  803560:	53                   	push   %ebx
  803561:	83 ec 24             	sub    $0x24,%esp
  803564:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803567:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80356a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80356e:	89 1c 24             	mov    %ebx,(%esp)
  803571:	e8 6c fc ff ff       	call   8031e2 <fd_lookup>
  803576:	85 c0                	test   %eax,%eax
  803578:	78 6a                	js     8035e4 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80357a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80357d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803581:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803584:	8b 00                	mov    (%eax),%eax
  803586:	89 04 24             	mov    %eax,(%esp)
  803589:	e8 aa fc ff ff       	call   803238 <dev_lookup>
  80358e:	85 c0                	test   %eax,%eax
  803590:	78 52                	js     8035e4 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803595:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803599:	75 25                	jne    8035c0 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80359b:	a1 20 a1 80 00       	mov    0x80a120,%eax
  8035a0:	8b 00                	mov    (%eax),%eax
  8035a2:	8b 40 48             	mov    0x48(%eax),%eax
  8035a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8035a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035ad:	c7 04 24 90 4c 80 00 	movl   $0x804c90,(%esp)
  8035b4:	e8 d3 ed ff ff       	call   80238c <cprintf>
		return -E_INVAL;
  8035b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8035be:	eb 24                	jmp    8035e4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8035c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8035c3:	8b 52 0c             	mov    0xc(%edx),%edx
  8035c6:	85 d2                	test   %edx,%edx
  8035c8:	74 15                	je     8035df <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8035ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8035cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8035d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8035d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8035d8:	89 04 24             	mov    %eax,(%esp)
  8035db:	ff d2                	call   *%edx
  8035dd:	eb 05                	jmp    8035e4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8035df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8035e4:	83 c4 24             	add    $0x24,%esp
  8035e7:	5b                   	pop    %ebx
  8035e8:	5d                   	pop    %ebp
  8035e9:	c3                   	ret    

008035ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8035ea:	55                   	push   %ebp
  8035eb:	89 e5                	mov    %esp,%ebp
  8035ed:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8035f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8035fa:	89 04 24             	mov    %eax,(%esp)
  8035fd:	e8 e0 fb ff ff       	call   8031e2 <fd_lookup>
  803602:	85 c0                	test   %eax,%eax
  803604:	78 0e                	js     803614 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803606:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803609:	8b 55 0c             	mov    0xc(%ebp),%edx
  80360c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80360f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803614:	c9                   	leave  
  803615:	c3                   	ret    

00803616 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  803616:	55                   	push   %ebp
  803617:	89 e5                	mov    %esp,%ebp
  803619:	53                   	push   %ebx
  80361a:	83 ec 24             	sub    $0x24,%esp
  80361d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803620:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803623:	89 44 24 04          	mov    %eax,0x4(%esp)
  803627:	89 1c 24             	mov    %ebx,(%esp)
  80362a:	e8 b3 fb ff ff       	call   8031e2 <fd_lookup>
  80362f:	85 c0                	test   %eax,%eax
  803631:	78 63                	js     803696 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803633:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80363a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80363d:	8b 00                	mov    (%eax),%eax
  80363f:	89 04 24             	mov    %eax,(%esp)
  803642:	e8 f1 fb ff ff       	call   803238 <dev_lookup>
  803647:	85 c0                	test   %eax,%eax
  803649:	78 4b                	js     803696 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80364b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80364e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803652:	75 25                	jne    803679 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  803654:	a1 20 a1 80 00       	mov    0x80a120,%eax
  803659:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80365b:	8b 40 48             	mov    0x48(%eax),%eax
  80365e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803662:	89 44 24 04          	mov    %eax,0x4(%esp)
  803666:	c7 04 24 50 4c 80 00 	movl   $0x804c50,(%esp)
  80366d:	e8 1a ed ff ff       	call   80238c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  803672:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803677:	eb 1d                	jmp    803696 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  803679:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80367c:	8b 52 18             	mov    0x18(%edx),%edx
  80367f:	85 d2                	test   %edx,%edx
  803681:	74 0e                	je     803691 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  803683:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803686:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80368a:	89 04 24             	mov    %eax,(%esp)
  80368d:	ff d2                	call   *%edx
  80368f:	eb 05                	jmp    803696 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  803691:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  803696:	83 c4 24             	add    $0x24,%esp
  803699:	5b                   	pop    %ebx
  80369a:	5d                   	pop    %ebp
  80369b:	c3                   	ret    

0080369c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80369c:	55                   	push   %ebp
  80369d:	89 e5                	mov    %esp,%ebp
  80369f:	53                   	push   %ebx
  8036a0:	83 ec 24             	sub    $0x24,%esp
  8036a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8036a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8036a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8036b0:	89 04 24             	mov    %eax,(%esp)
  8036b3:	e8 2a fb ff ff       	call   8031e2 <fd_lookup>
  8036b8:	85 c0                	test   %eax,%eax
  8036ba:	78 52                	js     80370e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8036bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8036bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036c6:	8b 00                	mov    (%eax),%eax
  8036c8:	89 04 24             	mov    %eax,(%esp)
  8036cb:	e8 68 fb ff ff       	call   803238 <dev_lookup>
  8036d0:	85 c0                	test   %eax,%eax
  8036d2:	78 3a                	js     80370e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8036d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8036db:	74 2c                	je     803709 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8036dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8036e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8036e7:	00 00 00 
	stat->st_isdir = 0;
  8036ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8036f1:	00 00 00 
	stat->st_dev = dev;
  8036f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8036fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8036fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803701:	89 14 24             	mov    %edx,(%esp)
  803704:	ff 50 14             	call   *0x14(%eax)
  803707:	eb 05                	jmp    80370e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  803709:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80370e:	83 c4 24             	add    $0x24,%esp
  803711:	5b                   	pop    %ebx
  803712:	5d                   	pop    %ebp
  803713:	c3                   	ret    

00803714 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803714:	55                   	push   %ebp
  803715:	89 e5                	mov    %esp,%ebp
  803717:	56                   	push   %esi
  803718:	53                   	push   %ebx
  803719:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80371c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803723:	00 
  803724:	8b 45 08             	mov    0x8(%ebp),%eax
  803727:	89 04 24             	mov    %eax,(%esp)
  80372a:	e8 88 02 00 00       	call   8039b7 <open>
  80372f:	89 c3                	mov    %eax,%ebx
  803731:	85 c0                	test   %eax,%eax
  803733:	78 1b                	js     803750 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  803735:	8b 45 0c             	mov    0xc(%ebp),%eax
  803738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80373c:	89 1c 24             	mov    %ebx,(%esp)
  80373f:	e8 58 ff ff ff       	call   80369c <fstat>
  803744:	89 c6                	mov    %eax,%esi
	close(fd);
  803746:	89 1c 24             	mov    %ebx,(%esp)
  803749:	e8 ce fb ff ff       	call   80331c <close>
	return r;
  80374e:	89 f3                	mov    %esi,%ebx
}
  803750:	89 d8                	mov    %ebx,%eax
  803752:	83 c4 10             	add    $0x10,%esp
  803755:	5b                   	pop    %ebx
  803756:	5e                   	pop    %esi
  803757:	5d                   	pop    %ebp
  803758:	c3                   	ret    
  803759:	00 00                	add    %al,(%eax)
	...

0080375c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80375c:	55                   	push   %ebp
  80375d:	89 e5                	mov    %esp,%ebp
  80375f:	56                   	push   %esi
  803760:	53                   	push   %ebx
  803761:	83 ec 10             	sub    $0x10,%esp
  803764:	89 c3                	mov    %eax,%ebx
  803766:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  803768:	83 3d 18 a0 80 00 00 	cmpl   $0x0,0x80a018
  80376f:	75 11                	jne    803782 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803771:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  803778:	e8 a2 f9 ff ff       	call   80311f <ipc_find_env>
  80377d:	a3 18 a0 80 00       	mov    %eax,0x80a018
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  803782:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  803789:	00 
  80378a:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  803791:	00 
  803792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803796:	a1 18 a0 80 00       	mov    0x80a018,%eax
  80379b:	89 04 24             	mov    %eax,(%esp)
  80379e:	e8 16 f9 ff ff       	call   8030b9 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8037a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8037aa:	00 
  8037ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037b6:	e8 91 f8 ff ff       	call   80304c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8037bb:	83 c4 10             	add    $0x10,%esp
  8037be:	5b                   	pop    %ebx
  8037bf:	5e                   	pop    %esi
  8037c0:	5d                   	pop    %ebp
  8037c1:	c3                   	ret    

008037c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8037c2:	55                   	push   %ebp
  8037c3:	89 e5                	mov    %esp,%ebp
  8037c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8037c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8037cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8037ce:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  8037d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037d6:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8037db:	ba 00 00 00 00       	mov    $0x0,%edx
  8037e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8037e5:	e8 72 ff ff ff       	call   80375c <fsipc>
}
  8037ea:	c9                   	leave  
  8037eb:	c3                   	ret    

008037ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8037ec:	55                   	push   %ebp
  8037ed:	89 e5                	mov    %esp,%ebp
  8037ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8037f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8037f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8037f8:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  8037fd:	ba 00 00 00 00       	mov    $0x0,%edx
  803802:	b8 06 00 00 00       	mov    $0x6,%eax
  803807:	e8 50 ff ff ff       	call   80375c <fsipc>
}
  80380c:	c9                   	leave  
  80380d:	c3                   	ret    

0080380e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80380e:	55                   	push   %ebp
  80380f:	89 e5                	mov    %esp,%ebp
  803811:	53                   	push   %ebx
  803812:	83 ec 14             	sub    $0x14,%esp
  803815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803818:	8b 45 08             	mov    0x8(%ebp),%eax
  80381b:	8b 40 0c             	mov    0xc(%eax),%eax
  80381e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803823:	ba 00 00 00 00       	mov    $0x0,%edx
  803828:	b8 05 00 00 00       	mov    $0x5,%eax
  80382d:	e8 2a ff ff ff       	call   80375c <fsipc>
  803832:	85 c0                	test   %eax,%eax
  803834:	78 2b                	js     803861 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803836:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  80383d:	00 
  80383e:	89 1c 24             	mov    %ebx,(%esp)
  803841:	e8 f1 f0 ff ff       	call   802937 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803846:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80384b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803851:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803856:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80385c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803861:	83 c4 14             	add    $0x14,%esp
  803864:	5b                   	pop    %ebx
  803865:	5d                   	pop    %ebp
  803866:	c3                   	ret    

00803867 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803867:	55                   	push   %ebp
  803868:	89 e5                	mov    %esp,%ebp
  80386a:	53                   	push   %ebx
  80386b:	83 ec 14             	sub    $0x14,%esp
  80386e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803871:	8b 45 08             	mov    0x8(%ebp),%eax
  803874:	8b 40 0c             	mov    0xc(%eax),%eax
  803877:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  80387c:	89 d8                	mov    %ebx,%eax
  80387e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  803884:	76 05                	jbe    80388b <devfile_write+0x24>
  803886:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80388b:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  803890:	89 44 24 08          	mov    %eax,0x8(%esp)
  803894:	8b 45 0c             	mov    0xc(%ebp),%eax
  803897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80389b:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  8038a2:	e8 73 f2 ff ff       	call   802b1a <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  8038a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8038ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8038b1:	e8 a6 fe ff ff       	call   80375c <fsipc>
  8038b6:	85 c0                	test   %eax,%eax
  8038b8:	78 53                	js     80390d <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  8038ba:	39 c3                	cmp    %eax,%ebx
  8038bc:	73 24                	jae    8038e2 <devfile_write+0x7b>
  8038be:	c7 44 24 0c c0 4c 80 	movl   $0x804cc0,0xc(%esp)
  8038c5:	00 
  8038c6:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  8038cd:	00 
  8038ce:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8038d5:	00 
  8038d6:	c7 04 24 c7 4c 80 00 	movl   $0x804cc7,(%esp)
  8038dd:	e8 b2 e9 ff ff       	call   802294 <_panic>
	assert(r <= PGSIZE);
  8038e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8038e7:	7e 24                	jle    80390d <devfile_write+0xa6>
  8038e9:	c7 44 24 0c d2 4c 80 	movl   $0x804cd2,0xc(%esp)
  8038f0:	00 
  8038f1:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  8038f8:	00 
  8038f9:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  803900:	00 
  803901:	c7 04 24 c7 4c 80 00 	movl   $0x804cc7,(%esp)
  803908:	e8 87 e9 ff ff       	call   802294 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  80390d:	83 c4 14             	add    $0x14,%esp
  803910:	5b                   	pop    %ebx
  803911:	5d                   	pop    %ebp
  803912:	c3                   	ret    

00803913 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  803913:	55                   	push   %ebp
  803914:	89 e5                	mov    %esp,%ebp
  803916:	56                   	push   %esi
  803917:	53                   	push   %ebx
  803918:	83 ec 10             	sub    $0x10,%esp
  80391b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80391e:	8b 45 08             	mov    0x8(%ebp),%eax
  803921:	8b 40 0c             	mov    0xc(%eax),%eax
  803924:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803929:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80392f:	ba 00 00 00 00       	mov    $0x0,%edx
  803934:	b8 03 00 00 00       	mov    $0x3,%eax
  803939:	e8 1e fe ff ff       	call   80375c <fsipc>
  80393e:	89 c3                	mov    %eax,%ebx
  803940:	85 c0                	test   %eax,%eax
  803942:	78 6a                	js     8039ae <devfile_read+0x9b>
		return r;
	assert(r <= n);
  803944:	39 c6                	cmp    %eax,%esi
  803946:	73 24                	jae    80396c <devfile_read+0x59>
  803948:	c7 44 24 0c c0 4c 80 	movl   $0x804cc0,0xc(%esp)
  80394f:	00 
  803950:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  803957:	00 
  803958:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80395f:	00 
  803960:	c7 04 24 c7 4c 80 00 	movl   $0x804cc7,(%esp)
  803967:	e8 28 e9 ff ff       	call   802294 <_panic>
	assert(r <= PGSIZE);
  80396c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803971:	7e 24                	jle    803997 <devfile_read+0x84>
  803973:	c7 44 24 0c d2 4c 80 	movl   $0x804cd2,0xc(%esp)
  80397a:	00 
  80397b:	c7 44 24 08 5d 42 80 	movl   $0x80425d,0x8(%esp)
  803982:	00 
  803983:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  80398a:	00 
  80398b:	c7 04 24 c7 4c 80 00 	movl   $0x804cc7,(%esp)
  803992:	e8 fd e8 ff ff       	call   802294 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80399b:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  8039a2:	00 
  8039a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8039a6:	89 04 24             	mov    %eax,(%esp)
  8039a9:	e8 02 f1 ff ff       	call   802ab0 <memmove>
	return r;
}
  8039ae:	89 d8                	mov    %ebx,%eax
  8039b0:	83 c4 10             	add    $0x10,%esp
  8039b3:	5b                   	pop    %ebx
  8039b4:	5e                   	pop    %esi
  8039b5:	5d                   	pop    %ebp
  8039b6:	c3                   	ret    

008039b7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8039b7:	55                   	push   %ebp
  8039b8:	89 e5                	mov    %esp,%ebp
  8039ba:	56                   	push   %esi
  8039bb:	53                   	push   %ebx
  8039bc:	83 ec 20             	sub    $0x20,%esp
  8039bf:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8039c2:	89 34 24             	mov    %esi,(%esp)
  8039c5:	e8 3a ef ff ff       	call   802904 <strlen>
  8039ca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8039cf:	7f 60                	jg     803a31 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8039d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039d4:	89 04 24             	mov    %eax,(%esp)
  8039d7:	e8 b3 f7 ff ff       	call   80318f <fd_alloc>
  8039dc:	89 c3                	mov    %eax,%ebx
  8039de:	85 c0                	test   %eax,%eax
  8039e0:	78 54                	js     803a36 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8039e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8039e6:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  8039ed:	e8 45 ef ff ff       	call   802937 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8039f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8039f5:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8039fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8039fd:	b8 01 00 00 00       	mov    $0x1,%eax
  803a02:	e8 55 fd ff ff       	call   80375c <fsipc>
  803a07:	89 c3                	mov    %eax,%ebx
  803a09:	85 c0                	test   %eax,%eax
  803a0b:	79 15                	jns    803a22 <open+0x6b>
		fd_close(fd, 0);
  803a0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803a14:	00 
  803a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a18:	89 04 24             	mov    %eax,(%esp)
  803a1b:	e8 74 f8 ff ff       	call   803294 <fd_close>
		return r;
  803a20:	eb 14                	jmp    803a36 <open+0x7f>
	}

	return fd2num(fd);
  803a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a25:	89 04 24             	mov    %eax,(%esp)
  803a28:	e8 37 f7 ff ff       	call   803164 <fd2num>
  803a2d:	89 c3                	mov    %eax,%ebx
  803a2f:	eb 05                	jmp    803a36 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  803a31:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  803a36:	89 d8                	mov    %ebx,%eax
  803a38:	83 c4 20             	add    $0x20,%esp
  803a3b:	5b                   	pop    %ebx
  803a3c:	5e                   	pop    %esi
  803a3d:	5d                   	pop    %ebp
  803a3e:	c3                   	ret    

00803a3f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803a3f:	55                   	push   %ebp
  803a40:	89 e5                	mov    %esp,%ebp
  803a42:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803a45:	ba 00 00 00 00       	mov    $0x0,%edx
  803a4a:	b8 08 00 00 00       	mov    $0x8,%eax
  803a4f:	e8 08 fd ff ff       	call   80375c <fsipc>
}
  803a54:	c9                   	leave  
  803a55:	c3                   	ret    
	...

00803a58 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803a58:	55                   	push   %ebp
  803a59:	89 e5                	mov    %esp,%ebp
  803a5b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  803a5e:	89 c2                	mov    %eax,%edx
  803a60:	c1 ea 16             	shr    $0x16,%edx
  803a63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803a6a:	f6 c2 01             	test   $0x1,%dl
  803a6d:	74 1e                	je     803a8d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  803a6f:	c1 e8 0c             	shr    $0xc,%eax
  803a72:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803a79:	a8 01                	test   $0x1,%al
  803a7b:	74 17                	je     803a94 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803a7d:	c1 e8 0c             	shr    $0xc,%eax
  803a80:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  803a87:	ef 
  803a88:	0f b7 c0             	movzwl %ax,%eax
  803a8b:	eb 0c                	jmp    803a99 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  803a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  803a92:	eb 05                	jmp    803a99 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803a94:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  803a99:	5d                   	pop    %ebp
  803a9a:	c3                   	ret    
	...

00803a9c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803a9c:	55                   	push   %ebp
  803a9d:	89 e5                	mov    %esp,%ebp
  803a9f:	56                   	push   %esi
  803aa0:	53                   	push   %ebx
  803aa1:	83 ec 10             	sub    $0x10,%esp
  803aa4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  803aaa:	89 04 24             	mov    %eax,(%esp)
  803aad:	e8 c2 f6 ff ff       	call   803174 <fd2data>
  803ab2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  803ab4:	c7 44 24 04 de 4c 80 	movl   $0x804cde,0x4(%esp)
  803abb:	00 
  803abc:	89 34 24             	mov    %esi,(%esp)
  803abf:	e8 73 ee ff ff       	call   802937 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803ac4:	8b 43 04             	mov    0x4(%ebx),%eax
  803ac7:	2b 03                	sub    (%ebx),%eax
  803ac9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  803acf:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  803ad6:	00 00 00 
	stat->st_dev = &devpipe;
  803ad9:	c7 86 88 00 00 00 80 	movl   $0x809080,0x88(%esi)
  803ae0:	90 80 00 
	return 0;
}
  803ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  803ae8:	83 c4 10             	add    $0x10,%esp
  803aeb:	5b                   	pop    %ebx
  803aec:	5e                   	pop    %esi
  803aed:	5d                   	pop    %ebp
  803aee:	c3                   	ret    

00803aef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803aef:	55                   	push   %ebp
  803af0:	89 e5                	mov    %esp,%ebp
  803af2:	53                   	push   %ebx
  803af3:	83 ec 14             	sub    $0x14,%esp
  803af6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803af9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803afd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b04:	e8 c7 f2 ff ff       	call   802dd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803b09:	89 1c 24             	mov    %ebx,(%esp)
  803b0c:	e8 63 f6 ff ff       	call   803174 <fd2data>
  803b11:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b1c:	e8 af f2 ff ff       	call   802dd0 <sys_page_unmap>
}
  803b21:	83 c4 14             	add    $0x14,%esp
  803b24:	5b                   	pop    %ebx
  803b25:	5d                   	pop    %ebp
  803b26:	c3                   	ret    

00803b27 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803b27:	55                   	push   %ebp
  803b28:	89 e5                	mov    %esp,%ebp
  803b2a:	57                   	push   %edi
  803b2b:	56                   	push   %esi
  803b2c:	53                   	push   %ebx
  803b2d:	83 ec 2c             	sub    $0x2c,%esp
  803b30:	89 c7                	mov    %eax,%edi
  803b32:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803b35:	a1 20 a1 80 00       	mov    0x80a120,%eax
  803b3a:	8b 00                	mov    (%eax),%eax
  803b3c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803b3f:	89 3c 24             	mov    %edi,(%esp)
  803b42:	e8 11 ff ff ff       	call   803a58 <pageref>
  803b47:	89 c6                	mov    %eax,%esi
  803b49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b4c:	89 04 24             	mov    %eax,(%esp)
  803b4f:	e8 04 ff ff ff       	call   803a58 <pageref>
  803b54:	39 c6                	cmp    %eax,%esi
  803b56:	0f 94 c0             	sete   %al
  803b59:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  803b5c:	8b 15 20 a1 80 00    	mov    0x80a120,%edx
  803b62:	8b 12                	mov    (%edx),%edx
  803b64:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803b67:	39 cb                	cmp    %ecx,%ebx
  803b69:	75 08                	jne    803b73 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  803b6b:	83 c4 2c             	add    $0x2c,%esp
  803b6e:	5b                   	pop    %ebx
  803b6f:	5e                   	pop    %esi
  803b70:	5f                   	pop    %edi
  803b71:	5d                   	pop    %ebp
  803b72:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  803b73:	83 f8 01             	cmp    $0x1,%eax
  803b76:	75 bd                	jne    803b35 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803b78:	8b 42 58             	mov    0x58(%edx),%eax
  803b7b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  803b82:	00 
  803b83:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803b8b:	c7 04 24 e5 4c 80 00 	movl   $0x804ce5,(%esp)
  803b92:	e8 f5 e7 ff ff       	call   80238c <cprintf>
  803b97:	eb 9c                	jmp    803b35 <_pipeisclosed+0xe>

00803b99 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803b99:	55                   	push   %ebp
  803b9a:	89 e5                	mov    %esp,%ebp
  803b9c:	57                   	push   %edi
  803b9d:	56                   	push   %esi
  803b9e:	53                   	push   %ebx
  803b9f:	83 ec 1c             	sub    $0x1c,%esp
  803ba2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803ba5:	89 34 24             	mov    %esi,(%esp)
  803ba8:	e8 c7 f5 ff ff       	call   803174 <fd2data>
  803bad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803baf:	bf 00 00 00 00       	mov    $0x0,%edi
  803bb4:	eb 3c                	jmp    803bf2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803bb6:	89 da                	mov    %ebx,%edx
  803bb8:	89 f0                	mov    %esi,%eax
  803bba:	e8 68 ff ff ff       	call   803b27 <_pipeisclosed>
  803bbf:	85 c0                	test   %eax,%eax
  803bc1:	75 38                	jne    803bfb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803bc3:	e8 42 f1 ff ff       	call   802d0a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803bc8:	8b 43 04             	mov    0x4(%ebx),%eax
  803bcb:	8b 13                	mov    (%ebx),%edx
  803bcd:	83 c2 20             	add    $0x20,%edx
  803bd0:	39 d0                	cmp    %edx,%eax
  803bd2:	73 e2                	jae    803bb6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803bd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  803bd7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  803bda:	89 c2                	mov    %eax,%edx
  803bdc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  803be2:	79 05                	jns    803be9 <devpipe_write+0x50>
  803be4:	4a                   	dec    %edx
  803be5:	83 ca e0             	or     $0xffffffe0,%edx
  803be8:	42                   	inc    %edx
  803be9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803bed:	40                   	inc    %eax
  803bee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803bf1:	47                   	inc    %edi
  803bf2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803bf5:	75 d1                	jne    803bc8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803bf7:	89 f8                	mov    %edi,%eax
  803bf9:	eb 05                	jmp    803c00 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803bfb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803c00:	83 c4 1c             	add    $0x1c,%esp
  803c03:	5b                   	pop    %ebx
  803c04:	5e                   	pop    %esi
  803c05:	5f                   	pop    %edi
  803c06:	5d                   	pop    %ebp
  803c07:	c3                   	ret    

00803c08 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803c08:	55                   	push   %ebp
  803c09:	89 e5                	mov    %esp,%ebp
  803c0b:	57                   	push   %edi
  803c0c:	56                   	push   %esi
  803c0d:	53                   	push   %ebx
  803c0e:	83 ec 1c             	sub    $0x1c,%esp
  803c11:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803c14:	89 3c 24             	mov    %edi,(%esp)
  803c17:	e8 58 f5 ff ff       	call   803174 <fd2data>
  803c1c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803c1e:	be 00 00 00 00       	mov    $0x0,%esi
  803c23:	eb 3a                	jmp    803c5f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803c25:	85 f6                	test   %esi,%esi
  803c27:	74 04                	je     803c2d <devpipe_read+0x25>
				return i;
  803c29:	89 f0                	mov    %esi,%eax
  803c2b:	eb 40                	jmp    803c6d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803c2d:	89 da                	mov    %ebx,%edx
  803c2f:	89 f8                	mov    %edi,%eax
  803c31:	e8 f1 fe ff ff       	call   803b27 <_pipeisclosed>
  803c36:	85 c0                	test   %eax,%eax
  803c38:	75 2e                	jne    803c68 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803c3a:	e8 cb f0 ff ff       	call   802d0a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803c3f:	8b 03                	mov    (%ebx),%eax
  803c41:	3b 43 04             	cmp    0x4(%ebx),%eax
  803c44:	74 df                	je     803c25 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803c46:	25 1f 00 00 80       	and    $0x8000001f,%eax
  803c4b:	79 05                	jns    803c52 <devpipe_read+0x4a>
  803c4d:	48                   	dec    %eax
  803c4e:	83 c8 e0             	or     $0xffffffe0,%eax
  803c51:	40                   	inc    %eax
  803c52:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  803c56:	8b 55 0c             	mov    0xc(%ebp),%edx
  803c59:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  803c5c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803c5e:	46                   	inc    %esi
  803c5f:	3b 75 10             	cmp    0x10(%ebp),%esi
  803c62:	75 db                	jne    803c3f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803c64:	89 f0                	mov    %esi,%eax
  803c66:	eb 05                	jmp    803c6d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803c68:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803c6d:	83 c4 1c             	add    $0x1c,%esp
  803c70:	5b                   	pop    %ebx
  803c71:	5e                   	pop    %esi
  803c72:	5f                   	pop    %edi
  803c73:	5d                   	pop    %ebp
  803c74:	c3                   	ret    

00803c75 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803c75:	55                   	push   %ebp
  803c76:	89 e5                	mov    %esp,%ebp
  803c78:	57                   	push   %edi
  803c79:	56                   	push   %esi
  803c7a:	53                   	push   %ebx
  803c7b:	83 ec 3c             	sub    $0x3c,%esp
  803c7e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803c81:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803c84:	89 04 24             	mov    %eax,(%esp)
  803c87:	e8 03 f5 ff ff       	call   80318f <fd_alloc>
  803c8c:	89 c3                	mov    %eax,%ebx
  803c8e:	85 c0                	test   %eax,%eax
  803c90:	0f 88 45 01 00 00    	js     803ddb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803c96:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803c9d:	00 
  803c9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
  803ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803cac:	e8 78 f0 ff ff       	call   802d29 <sys_page_alloc>
  803cb1:	89 c3                	mov    %eax,%ebx
  803cb3:	85 c0                	test   %eax,%eax
  803cb5:	0f 88 20 01 00 00    	js     803ddb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803cbb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  803cbe:	89 04 24             	mov    %eax,(%esp)
  803cc1:	e8 c9 f4 ff ff       	call   80318f <fd_alloc>
  803cc6:	89 c3                	mov    %eax,%ebx
  803cc8:	85 c0                	test   %eax,%eax
  803cca:	0f 88 f8 00 00 00    	js     803dc8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803cd0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803cd7:	00 
  803cd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  803cdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803ce6:	e8 3e f0 ff ff       	call   802d29 <sys_page_alloc>
  803ceb:	89 c3                	mov    %eax,%ebx
  803ced:	85 c0                	test   %eax,%eax
  803cef:	0f 88 d3 00 00 00    	js     803dc8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803cf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803cf8:	89 04 24             	mov    %eax,(%esp)
  803cfb:	e8 74 f4 ff ff       	call   803174 <fd2data>
  803d00:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803d02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803d09:	00 
  803d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d15:	e8 0f f0 ff ff       	call   802d29 <sys_page_alloc>
  803d1a:	89 c3                	mov    %eax,%ebx
  803d1c:	85 c0                	test   %eax,%eax
  803d1e:	0f 88 91 00 00 00    	js     803db5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803d24:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d27:	89 04 24             	mov    %eax,(%esp)
  803d2a:	e8 45 f4 ff ff       	call   803174 <fd2data>
  803d2f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  803d36:	00 
  803d37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803d3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803d42:	00 
  803d43:	89 74 24 04          	mov    %esi,0x4(%esp)
  803d47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d4e:	e8 2a f0 ff ff       	call   802d7d <sys_page_map>
  803d53:	89 c3                	mov    %eax,%ebx
  803d55:	85 c0                	test   %eax,%eax
  803d57:	78 4c                	js     803da5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803d59:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803d5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803d62:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803d67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803d6e:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803d74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d77:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803d79:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803d86:	89 04 24             	mov    %eax,(%esp)
  803d89:	e8 d6 f3 ff ff       	call   803164 <fd2num>
  803d8e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803d90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d93:	89 04 24             	mov    %eax,(%esp)
  803d96:	e8 c9 f3 ff ff       	call   803164 <fd2num>
  803d9b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  803d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  803da3:	eb 36                	jmp    803ddb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  803da5:	89 74 24 04          	mov    %esi,0x4(%esp)
  803da9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803db0:	e8 1b f0 ff ff       	call   802dd0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803db5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803db8:	89 44 24 04          	mov    %eax,0x4(%esp)
  803dbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803dc3:	e8 08 f0 ff ff       	call   802dd0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803dc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  803dcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803dd6:	e8 f5 ef ff ff       	call   802dd0 <sys_page_unmap>
    err:
	return r;
}
  803ddb:	89 d8                	mov    %ebx,%eax
  803ddd:	83 c4 3c             	add    $0x3c,%esp
  803de0:	5b                   	pop    %ebx
  803de1:	5e                   	pop    %esi
  803de2:	5f                   	pop    %edi
  803de3:	5d                   	pop    %ebp
  803de4:	c3                   	ret    

00803de5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803de5:	55                   	push   %ebp
  803de6:	89 e5                	mov    %esp,%ebp
  803de8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803deb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803dee:	89 44 24 04          	mov    %eax,0x4(%esp)
  803df2:	8b 45 08             	mov    0x8(%ebp),%eax
  803df5:	89 04 24             	mov    %eax,(%esp)
  803df8:	e8 e5 f3 ff ff       	call   8031e2 <fd_lookup>
  803dfd:	85 c0                	test   %eax,%eax
  803dff:	78 15                	js     803e16 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e04:	89 04 24             	mov    %eax,(%esp)
  803e07:	e8 68 f3 ff ff       	call   803174 <fd2data>
	return _pipeisclosed(fd, p);
  803e0c:	89 c2                	mov    %eax,%edx
  803e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e11:	e8 11 fd ff ff       	call   803b27 <_pipeisclosed>
}
  803e16:	c9                   	leave  
  803e17:	c3                   	ret    

00803e18 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803e18:	55                   	push   %ebp
  803e19:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  803e20:	5d                   	pop    %ebp
  803e21:	c3                   	ret    

00803e22 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803e22:	55                   	push   %ebp
  803e23:	89 e5                	mov    %esp,%ebp
  803e25:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  803e28:	c7 44 24 04 fd 4c 80 	movl   $0x804cfd,0x4(%esp)
  803e2f:	00 
  803e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  803e33:	89 04 24             	mov    %eax,(%esp)
  803e36:	e8 fc ea ff ff       	call   802937 <strcpy>
	return 0;
}
  803e3b:	b8 00 00 00 00       	mov    $0x0,%eax
  803e40:	c9                   	leave  
  803e41:	c3                   	ret    

00803e42 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803e42:	55                   	push   %ebp
  803e43:	89 e5                	mov    %esp,%ebp
  803e45:	57                   	push   %edi
  803e46:	56                   	push   %esi
  803e47:	53                   	push   %ebx
  803e48:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803e53:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803e59:	eb 30                	jmp    803e8b <devcons_write+0x49>
		m = n - tot;
  803e5b:	8b 75 10             	mov    0x10(%ebp),%esi
  803e5e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803e60:	83 fe 7f             	cmp    $0x7f,%esi
  803e63:	76 05                	jbe    803e6a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  803e65:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803e6a:	89 74 24 08          	mov    %esi,0x8(%esp)
  803e6e:	03 45 0c             	add    0xc(%ebp),%eax
  803e71:	89 44 24 04          	mov    %eax,0x4(%esp)
  803e75:	89 3c 24             	mov    %edi,(%esp)
  803e78:	e8 33 ec ff ff       	call   802ab0 <memmove>
		sys_cputs(buf, m);
  803e7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  803e81:	89 3c 24             	mov    %edi,(%esp)
  803e84:	e8 d3 ed ff ff       	call   802c5c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803e89:	01 f3                	add    %esi,%ebx
  803e8b:	89 d8                	mov    %ebx,%eax
  803e8d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803e90:	72 c9                	jb     803e5b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803e92:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803e98:	5b                   	pop    %ebx
  803e99:	5e                   	pop    %esi
  803e9a:	5f                   	pop    %edi
  803e9b:	5d                   	pop    %ebp
  803e9c:	c3                   	ret    

00803e9d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803e9d:	55                   	push   %ebp
  803e9e:	89 e5                	mov    %esp,%ebp
  803ea0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  803ea3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803ea7:	75 07                	jne    803eb0 <devcons_read+0x13>
  803ea9:	eb 25                	jmp    803ed0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803eab:	e8 5a ee ff ff       	call   802d0a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803eb0:	e8 c5 ed ff ff       	call   802c7a <sys_cgetc>
  803eb5:	85 c0                	test   %eax,%eax
  803eb7:	74 f2                	je     803eab <devcons_read+0xe>
  803eb9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  803ebb:	85 c0                	test   %eax,%eax
  803ebd:	78 1d                	js     803edc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803ebf:	83 f8 04             	cmp    $0x4,%eax
  803ec2:	74 13                	je     803ed7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  803ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  803ec7:	88 10                	mov    %dl,(%eax)
	return 1;
  803ec9:	b8 01 00 00 00       	mov    $0x1,%eax
  803ece:	eb 0c                	jmp    803edc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  803ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  803ed5:	eb 05                	jmp    803edc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803ed7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803edc:	c9                   	leave  
  803edd:	c3                   	ret    

00803ede <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803ede:	55                   	push   %ebp
  803edf:	89 e5                	mov    %esp,%ebp
  803ee1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  803ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  803ee7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803eea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803ef1:	00 
  803ef2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803ef5:	89 04 24             	mov    %eax,(%esp)
  803ef8:	e8 5f ed ff ff       	call   802c5c <sys_cputs>
}
  803efd:	c9                   	leave  
  803efe:	c3                   	ret    

00803eff <getchar>:

int
getchar(void)
{
  803eff:	55                   	push   %ebp
  803f00:	89 e5                	mov    %esp,%ebp
  803f02:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803f05:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  803f0c:	00 
  803f0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803f10:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803f1b:	e8 60 f5 ff ff       	call   803480 <read>
	if (r < 0)
  803f20:	85 c0                	test   %eax,%eax
  803f22:	78 0f                	js     803f33 <getchar+0x34>
		return r;
	if (r < 1)
  803f24:	85 c0                	test   %eax,%eax
  803f26:	7e 06                	jle    803f2e <getchar+0x2f>
		return -E_EOF;
	return c;
  803f28:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803f2c:	eb 05                	jmp    803f33 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803f2e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803f33:	c9                   	leave  
  803f34:	c3                   	ret    

00803f35 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803f35:	55                   	push   %ebp
  803f36:	89 e5                	mov    %esp,%ebp
  803f38:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803f3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803f3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f42:	8b 45 08             	mov    0x8(%ebp),%eax
  803f45:	89 04 24             	mov    %eax,(%esp)
  803f48:	e8 95 f2 ff ff       	call   8031e2 <fd_lookup>
  803f4d:	85 c0                	test   %eax,%eax
  803f4f:	78 11                	js     803f62 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f54:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803f5a:	39 10                	cmp    %edx,(%eax)
  803f5c:	0f 94 c0             	sete   %al
  803f5f:	0f b6 c0             	movzbl %al,%eax
}
  803f62:	c9                   	leave  
  803f63:	c3                   	ret    

00803f64 <opencons>:

int
opencons(void)
{
  803f64:	55                   	push   %ebp
  803f65:	89 e5                	mov    %esp,%ebp
  803f67:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803f6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803f6d:	89 04 24             	mov    %eax,(%esp)
  803f70:	e8 1a f2 ff ff       	call   80318f <fd_alloc>
  803f75:	85 c0                	test   %eax,%eax
  803f77:	78 3c                	js     803fb5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803f79:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803f80:	00 
  803f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803f8f:	e8 95 ed ff ff       	call   802d29 <sys_page_alloc>
  803f94:	85 c0                	test   %eax,%eax
  803f96:	78 1d                	js     803fb5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803f98:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803fa1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803fa6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803fad:	89 04 24             	mov    %eax,(%esp)
  803fb0:	e8 af f1 ff ff       	call   803164 <fd2num>
}
  803fb5:	c9                   	leave  
  803fb6:	c3                   	ret    
	...

00803fb8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803fb8:	55                   	push   %ebp
  803fb9:	57                   	push   %edi
  803fba:	56                   	push   %esi
  803fbb:	83 ec 10             	sub    $0x10,%esp
  803fbe:	8b 74 24 20          	mov    0x20(%esp),%esi
  803fc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  803fca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  803fce:	89 cd                	mov    %ecx,%ebp
  803fd0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803fd4:	85 c0                	test   %eax,%eax
  803fd6:	75 2c                	jne    804004 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  803fd8:	39 f9                	cmp    %edi,%ecx
  803fda:	77 68                	ja     804044 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803fdc:	85 c9                	test   %ecx,%ecx
  803fde:	75 0b                	jne    803feb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803fe0:	b8 01 00 00 00       	mov    $0x1,%eax
  803fe5:	31 d2                	xor    %edx,%edx
  803fe7:	f7 f1                	div    %ecx
  803fe9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803feb:	31 d2                	xor    %edx,%edx
  803fed:	89 f8                	mov    %edi,%eax
  803fef:	f7 f1                	div    %ecx
  803ff1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803ff3:	89 f0                	mov    %esi,%eax
  803ff5:	f7 f1                	div    %ecx
  803ff7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803ff9:	89 f0                	mov    %esi,%eax
  803ffb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803ffd:	83 c4 10             	add    $0x10,%esp
  804000:	5e                   	pop    %esi
  804001:	5f                   	pop    %edi
  804002:	5d                   	pop    %ebp
  804003:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  804004:	39 f8                	cmp    %edi,%eax
  804006:	77 2c                	ja     804034 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  804008:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80400b:	83 f6 1f             	xor    $0x1f,%esi
  80400e:	75 4c                	jne    80405c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  804010:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  804012:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  804017:	72 0a                	jb     804023 <__udivdi3+0x6b>
  804019:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80401d:	0f 87 ad 00 00 00    	ja     8040d0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  804023:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  804028:	89 f0                	mov    %esi,%eax
  80402a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80402c:	83 c4 10             	add    $0x10,%esp
  80402f:	5e                   	pop    %esi
  804030:	5f                   	pop    %edi
  804031:	5d                   	pop    %ebp
  804032:	c3                   	ret    
  804033:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  804034:	31 ff                	xor    %edi,%edi
  804036:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  804038:	89 f0                	mov    %esi,%eax
  80403a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80403c:	83 c4 10             	add    $0x10,%esp
  80403f:	5e                   	pop    %esi
  804040:	5f                   	pop    %edi
  804041:	5d                   	pop    %ebp
  804042:	c3                   	ret    
  804043:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  804044:	89 fa                	mov    %edi,%edx
  804046:	89 f0                	mov    %esi,%eax
  804048:	f7 f1                	div    %ecx
  80404a:	89 c6                	mov    %eax,%esi
  80404c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80404e:	89 f0                	mov    %esi,%eax
  804050:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  804052:	83 c4 10             	add    $0x10,%esp
  804055:	5e                   	pop    %esi
  804056:	5f                   	pop    %edi
  804057:	5d                   	pop    %ebp
  804058:	c3                   	ret    
  804059:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80405c:	89 f1                	mov    %esi,%ecx
  80405e:	d3 e0                	shl    %cl,%eax
  804060:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  804064:	b8 20 00 00 00       	mov    $0x20,%eax
  804069:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80406b:	89 ea                	mov    %ebp,%edx
  80406d:	88 c1                	mov    %al,%cl
  80406f:	d3 ea                	shr    %cl,%edx
  804071:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  804075:	09 ca                	or     %ecx,%edx
  804077:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80407b:	89 f1                	mov    %esi,%ecx
  80407d:	d3 e5                	shl    %cl,%ebp
  80407f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  804083:	89 fd                	mov    %edi,%ebp
  804085:	88 c1                	mov    %al,%cl
  804087:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  804089:	89 fa                	mov    %edi,%edx
  80408b:	89 f1                	mov    %esi,%ecx
  80408d:	d3 e2                	shl    %cl,%edx
  80408f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  804093:	88 c1                	mov    %al,%cl
  804095:	d3 ef                	shr    %cl,%edi
  804097:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  804099:	89 f8                	mov    %edi,%eax
  80409b:	89 ea                	mov    %ebp,%edx
  80409d:	f7 74 24 08          	divl   0x8(%esp)
  8040a1:	89 d1                	mov    %edx,%ecx
  8040a3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8040a5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8040a9:	39 d1                	cmp    %edx,%ecx
  8040ab:	72 17                	jb     8040c4 <__udivdi3+0x10c>
  8040ad:	74 09                	je     8040b8 <__udivdi3+0x100>
  8040af:	89 fe                	mov    %edi,%esi
  8040b1:	31 ff                	xor    %edi,%edi
  8040b3:	e9 41 ff ff ff       	jmp    803ff9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8040b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8040bc:	89 f1                	mov    %esi,%ecx
  8040be:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8040c0:	39 c2                	cmp    %eax,%edx
  8040c2:	73 eb                	jae    8040af <__udivdi3+0xf7>
		{
		  q0--;
  8040c4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8040c7:	31 ff                	xor    %edi,%edi
  8040c9:	e9 2b ff ff ff       	jmp    803ff9 <__udivdi3+0x41>
  8040ce:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8040d0:	31 f6                	xor    %esi,%esi
  8040d2:	e9 22 ff ff ff       	jmp    803ff9 <__udivdi3+0x41>
	...

008040d8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8040d8:	55                   	push   %ebp
  8040d9:	57                   	push   %edi
  8040da:	56                   	push   %esi
  8040db:	83 ec 20             	sub    $0x20,%esp
  8040de:	8b 44 24 30          	mov    0x30(%esp),%eax
  8040e2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8040e6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8040ea:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8040ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8040f2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8040f6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8040f8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8040fa:	85 ed                	test   %ebp,%ebp
  8040fc:	75 16                	jne    804114 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8040fe:	39 f1                	cmp    %esi,%ecx
  804100:	0f 86 a6 00 00 00    	jbe    8041ac <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  804106:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  804108:	89 d0                	mov    %edx,%eax
  80410a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80410c:	83 c4 20             	add    $0x20,%esp
  80410f:	5e                   	pop    %esi
  804110:	5f                   	pop    %edi
  804111:	5d                   	pop    %ebp
  804112:	c3                   	ret    
  804113:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  804114:	39 f5                	cmp    %esi,%ebp
  804116:	0f 87 ac 00 00 00    	ja     8041c8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80411c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80411f:	83 f0 1f             	xor    $0x1f,%eax
  804122:	89 44 24 10          	mov    %eax,0x10(%esp)
  804126:	0f 84 a8 00 00 00    	je     8041d4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80412c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  804130:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  804132:	bf 20 00 00 00       	mov    $0x20,%edi
  804137:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80413b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80413f:	89 f9                	mov    %edi,%ecx
  804141:	d3 e8                	shr    %cl,%eax
  804143:	09 e8                	or     %ebp,%eax
  804145:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  804149:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80414d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  804151:	d3 e0                	shl    %cl,%eax
  804153:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  804157:	89 f2                	mov    %esi,%edx
  804159:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80415b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80415f:	d3 e0                	shl    %cl,%eax
  804161:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  804165:	8b 44 24 14          	mov    0x14(%esp),%eax
  804169:	89 f9                	mov    %edi,%ecx
  80416b:	d3 e8                	shr    %cl,%eax
  80416d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80416f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  804171:	89 f2                	mov    %esi,%edx
  804173:	f7 74 24 18          	divl   0x18(%esp)
  804177:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  804179:	f7 64 24 0c          	mull   0xc(%esp)
  80417d:	89 c5                	mov    %eax,%ebp
  80417f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  804181:	39 d6                	cmp    %edx,%esi
  804183:	72 67                	jb     8041ec <__umoddi3+0x114>
  804185:	74 75                	je     8041fc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  804187:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80418b:	29 e8                	sub    %ebp,%eax
  80418d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80418f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  804193:	d3 e8                	shr    %cl,%eax
  804195:	89 f2                	mov    %esi,%edx
  804197:	89 f9                	mov    %edi,%ecx
  804199:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80419b:	09 d0                	or     %edx,%eax
  80419d:	89 f2                	mov    %esi,%edx
  80419f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8041a3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8041a5:	83 c4 20             	add    $0x20,%esp
  8041a8:	5e                   	pop    %esi
  8041a9:	5f                   	pop    %edi
  8041aa:	5d                   	pop    %ebp
  8041ab:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8041ac:	85 c9                	test   %ecx,%ecx
  8041ae:	75 0b                	jne    8041bb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8041b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8041b5:	31 d2                	xor    %edx,%edx
  8041b7:	f7 f1                	div    %ecx
  8041b9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8041bb:	89 f0                	mov    %esi,%eax
  8041bd:	31 d2                	xor    %edx,%edx
  8041bf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8041c1:	89 f8                	mov    %edi,%eax
  8041c3:	e9 3e ff ff ff       	jmp    804106 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8041c8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8041ca:	83 c4 20             	add    $0x20,%esp
  8041cd:	5e                   	pop    %esi
  8041ce:	5f                   	pop    %edi
  8041cf:	5d                   	pop    %ebp
  8041d0:	c3                   	ret    
  8041d1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8041d4:	39 f5                	cmp    %esi,%ebp
  8041d6:	72 04                	jb     8041dc <__umoddi3+0x104>
  8041d8:	39 f9                	cmp    %edi,%ecx
  8041da:	77 06                	ja     8041e2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8041dc:	89 f2                	mov    %esi,%edx
  8041de:	29 cf                	sub    %ecx,%edi
  8041e0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8041e2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8041e4:	83 c4 20             	add    $0x20,%esp
  8041e7:	5e                   	pop    %esi
  8041e8:	5f                   	pop    %edi
  8041e9:	5d                   	pop    %ebp
  8041ea:	c3                   	ret    
  8041eb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8041ec:	89 d1                	mov    %edx,%ecx
  8041ee:	89 c5                	mov    %eax,%ebp
  8041f0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8041f4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8041f8:	eb 8d                	jmp    804187 <__umoddi3+0xaf>
  8041fa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8041fc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  804200:	72 ea                	jb     8041ec <__umoddi3+0x114>
  804202:	89 f1                	mov    %esi,%ecx
  804204:	eb 81                	jmp    804187 <__umoddi3+0xaf>
