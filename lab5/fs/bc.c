
#include "fs.h"

#define NBUF 16
typedef struct MyLink{
    struct MyLink *p,*s;
	void *addr;
}MyLink;
void MyLink_init(MyLink *p){p->p=p->s=p;p->addr=0;}
MyLink* MyLink_delete(MyLink *p){p->p->s=p->s;p->s->p=p->p;p->p=p->s=p;return p;}
void MyLink_insert(MyLink *p,MyLink *q,void *addr){
	//cprintf("link %x %x\n",p,q);
	q->p=p;q->s=p->s;p->s=q->s->p=q;q->addr=addr;
}
MyLink buf[NBUF],unused,used;
int nbuf=0,t=0;
int buf_remove(MyLink *l){
	static int count_remove =0;
	count_remove++;
	cprintf("remove %x %x %d\n",l,l->addr,count_remove);
	int r;
	if (uvpt[PGNUM(l->addr)]&PTE_D)flush_block(l->addr);
	if (r=sys_page_unmap(0,l->addr),r<0)
		return r;
	nbuf--;
	// cprintf("fffff  %x %x\n",unused.p,l);
	MyLink_insert(unused.p,MyLink_delete(l),0);
	return 0;
}
int buf_evict(void){
	// cprintf("%x %x\n",&used,used.s);
	int r;
	for (MyLink *l=used.s;l!=&used;){
		void *addr=l->addr;
		if (!(uvpt[PGNUM(addr)]&PTE_A)){
			//cprintf("%x %x %x %x\n",addr,l,buf,&used);
			MyLink* tmp = l->s;
			if((r=buf_remove(l))&&r<0)
				return r;
			l = tmp;
		}else l = l->s;
	}
	if (nbuf==NBUF&&(r=buf_remove(used.s))&&r<0)
		return r;
	return 0;
}
void buf_print_used(void){
	int u=0,un=0;
	static int c=0;
	static float p=0.;
	for (MyLink *l = used.s;l!=&used;l=l->s){
		//cprintf("%x ",l->addr);
		if (uvpt[PGNUM(l->addr)]&PTE_A)u++;
		else un++;
	}cprintf("\n");
	p = p+(float)u/(u+un); c++;
	cprintf("%d %d %d\n",u,u+un,(int)(p/c*1000000000));
}
int buf_alloc(void *addr){
	int r;
	if (addr<diskaddr(2))return 0;
	static int count_alloc=0;
	count_alloc++;
	cprintf("alloc %x %d\n",addr,count_alloc);
	if ((nbuf==NBUF)&&(r=buf_evict())&&r<0)
		return r;
	nbuf++;
	//cprintf("important %x %x\n",&used,&unused);
	MyLink * l = MyLink_delete(unused.s);
	MyLink_insert(used.p,l,addr);
	return 0;
}
void buf_init(void){
	MyLink_init(&unused);MyLink_init(&used);
	for (int i=0;i<NBUF;++i) {
		MyLink_init(&buf[i]);
		MyLink_insert(unused.p,&buf[i],0);
	}
	/*
	cprintf("init:\n");
	for (MyLink *l=unused.s;l!=&unused;l=l->s){
		cprintf("%x ",l);
	}
	cprintf("\n");*/
}
int buf_visit(void){
	int r;
	buf_print_used();
	if (++t<NBUF)return 0;t=0;
	int cused = 0,cunused = 0;
	for (MyLink *l=used.s;l!=&used;l=l->s)cused++;
	for (MyLink *l=unused.s;l!=&unused;l=l->s)cunused++;
	// cprintf("%x %x\n",cused,(cused+cunused));
	for (MyLink *l=used.s;l!=&used;l=l->s){
		void *addr=l->addr;
		if (uvpt[PGNUM(addr)]&PTE_A){
			if (uvpt[PGNUM(addr)]&PTE_D)flush_block(addr);
			if ((r=sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))&&r<0)
				return r;
		}
	}
	return 0;
}
int buf_delete(void*addr){
	for (MyLink *l=used.s;l!=&used;l=l->s){
		if (l->addr==addr){
			MyLink_insert(unused.p,MyLink_delete(l),0);
			return 0;
		}
	}
	return -1;
}

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
		panic("bad block number %08x in diskaddr", blockno);
	return (char*) (DISKMAP + blockno * BLKSIZE);
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
}

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
}

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	// cprintf("pgfault %x\n",utf);
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	// cprintf("bc_pgfault addr: %x\n",addr);
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
		panic("reading non-existent block %08x\n", blockno);

	// Allocate a page in the disk map region, read the contents
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = (void*)ROUNDDOWN(addr,BLKSIZE);
	if ((r = sys_page_alloc(0,addr,PTE_P|PTE_U|PTE_W))<0)
		panic("bc_pgfault: sys_page_alloc (add) is %x\n",addr);
	if ((r = ide_read(blockno * BLKSECTS,addr,BLKSECTS))<0)
		panic("bc_pgfault: ide_raed (blockno) is %x, (addr) is %x\n",blockno,addr);

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
		panic("in bc_pgfault, sys_page_map: %e", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
		panic("reading free block %08x\n", blockno);
// cprintf("check %x %x %x\n",bitmap,addr,blockno);
#ifdef BUF_CACHE_OPEN
	if ((r = buf_alloc(addr))&&r < 0)
		panic("in bc_pgfault, buf_alloc: %e", r);
#endif

}

// Flush the contents of the block containing VA out to disk if
// necessary, then clear the PTE_D bit using sys_page_map.
// If the block is not in the block cache or is not dirty, does
// nothing.
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	//cprintf("flush %x\n",addr);
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	int r;
	addr = (void*)ROUNDDOWN(addr,BLKSIZE);
	if (va_is_mapped(addr)&&va_is_dirty(addr)){
		if ((r = ide_write(blockno * BLKSECTS,addr,BLKSECTS))<0)
			panic("flush_block: ide_write (blockno) is %x, (addr) is %x",blockno,addr);
		if ((r = sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
			panic("flush_block: sys_page_map (addr) is %x\n",addr);
	}
	return;
	panic("flush_block not implemented");
}

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
	flush_block(diskaddr(1));
	assert(va_is_mapped(diskaddr(1)));
	assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
	assert(!va_is_mapped(diskaddr(1)));

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
	flush_block(diskaddr(1));

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
	assert(va_is_mapped(diskaddr(1)));

	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
	assert(!va_is_mapped(diskaddr(1)));

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
	flush_block(diskaddr(1));

	cprintf("block cache is good\n");
}

void
bc_init(void)
{
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();
#ifdef BUF_CACHE_OPEN
	buf_init();
#endif
	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
}