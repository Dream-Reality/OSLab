// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line

struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display information about the stack backtrace", mon_backtrace},
	{ "showmappings", "Show physical pages mapped to specific virtual address area", mon_showmappings},
	{ "setpermissions", "Set permissions of specific virtual pages", mon_setpermissions},
	{ "clearpermissions" ,"Clear permissions of specific virtual pages", mon_clearpermissions},
	{ "showvirtualmemory" ,"Show Virtual memory",mon_showvirtualmemory},
	{ "va2pa", "Convert virtual address to physical address", mon_va2pa},
	{ "pa2va", "Convert physical address to virtual address",mon_pa2va},
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	// int x = 1, y = 3, z = 4;
	// cprintf("x %d, y %x, z %d\n", x, y, z);
	// return 0;
	
	// unsigned int i = 0x00646c72;
    // cprintf("H%x Wo%s", 57616, &i);
	// cprintf("x=%d y=%d", 3);

	/*
	cprintf("\033[31mT\033[32mh\033[33mi\033[34ms\033[37m \033[35mi\033[36ms\033[37m \033[37ma\033[37m \033[31mt\033[32me\033[33ms\033[34mt\n");
	cprintf("\033[30;41mThe parameters are: 30 and 41\n");
	cprintf("\033[31;42mThe parameters are: 31 and 42\n");
	cprintf("\033[32;43mThe parameters are: 32 and 43\n");
	cprintf("\033[33;44mThe parameters are: 33 and 44\n");
	cprintf("\033[34;45mThe parameters are: 34 and 45\n");
	cprintf("\033[35;46mThe parameters are: 35 and 46\n");
	cprintf("\033[36;47mThe parameters are: 36 and 47\n");
	cprintf("\033[37;40mThe parameters are: 37 and 40\n");
	*/
	cprintf("Stack backtrace:");
	uint32_t eip;
	struct Eipdebuginfo info;
	for (uint32_t ebp = read_ebp(); ebp; ebp = *((uint32_t *) ebp)){
		eip = *((uint32_t *) ebp + 1);
		debuginfo_eip(eip, &info);
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n         %s:%d: %.*s+%d\n",
		ebp,eip,*((uint32_t *) ebp + 2),
		        *((uint32_t *) ebp + 3),
				*((uint32_t *) ebp + 4),
				*((uint32_t *) ebp + 5),
				*((uint32_t *) ebp + 6),
				info.eip_file,
				info.eip_line,
				info.eip_fn_namelen,
				info.eip_fn_name,
				eip - info.eip_fn_addr);
	}
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}


const char Bit2Sign[9][2] = {{'-','P'},{'-','W'},{'-','U'},{'-','T'},{'-','C'},{'-','A'},{'-','D'},{'-','I'},{'-','G'}};
int 
mon_showmappings(int argc,char **argv,struct Trapframe *tf){
	if(argc!=3){
		cprintf("mon_showmappings: The number of parameters is two.\n");
		return 0;
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showmappings: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
	if (*errChar){
		cprintf("mon_showmappings: The second argument is not a number.\n");
		return 0;
	}
	if (StartAddr&0x3ff){
		cprintf("mon_showmappings: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
		cprintf("mon_showmappings: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
		cprintf("mon_shopmappings: The first parameter is larger than the second parameter.\n");
		return 0;
	}

    cprintf(
        "G: Global             I: PT Attribute Index    D: Dirty\n"
        "A: Accessed           C: Cache Disable         T: Write-Through\n"
        "U: User/Supervisor    W: Writable              P: Present\n"
        "----------------------------------------------------------------------\n"
        "virtual_address        physica_address        GIDACTUWP\n");

	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				char permission[10];
				for (int i = 8 , perm = *pte - PTE_ADDR(*pte); i >= 0; i--,perm>>=1){
					permission[i] = Bit2Sign[8-i][(perm&1)];
				}
				permission[9]='\0';
				cprintf("0x%08x             0x%08x             %s\n",Address,PTE_ADDR(*pte),permission);
				continue;
			}
		}                           
		cprintf("0x%08x             unmapped               --------\n",Address);
	}
    return 0;
}

int Sign2Perm(char *s){
	int l = strlen(s);
	int Perm = 0;
	for (int i=0;i<l;i++){
		switch(s[i]){
			case 'P':Perm|=PTE_P;break;
			case 'W':Perm|=PTE_W;break;
			case 'U':Perm|=PTE_U;break;
			case 'T':Perm|=PTE_PWT;break;
			case 'C':Perm|=PTE_PCD;break;
			case 'A':Perm|=PTE_A;break;
			case 'D':Perm|=PTE_D;break;
			case 'I':Perm|=PTE_PS;break;
			case 'G':Perm|=PTE_G;break;
			default:return -1;
		}
	}
	return Perm;
}
int mon_setpermissions(int argc, char **argv, struct Trapframe *tf){
	if(argc!=4){
		cprintf("mon_setpermissions: The number of parameters is three.\n");
		return 0;
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_setpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
	if (*errChar){
		cprintf("mon_setpermissions: The second argument is not a number\n");
		return 0;
	}
	if (StartAddr&0x3ff){
		cprintf("mon_setpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
		cprintf("mon_setpermissions: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
		cprintf("mon_setpermissions: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_setpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				*pte = *pte | Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
    mon_showmappings(argc-1,argv,tf);
    return 0;
}

int mon_clearpermissions(int argc, char **argv, struct Trapframe *tf){
    if(argc!=4){
		cprintf("mon_clearpermissions: The number of parameters is three.\n");
		return 0;
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_clearpermissions: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
	if (*errChar){
		cprintf("mon_clearpermissions: The second argument is not a number.\n");
		return 0;
	}
	if (StartAddr&0x3ff){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3ff){
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
		cprintf("mon_clearpermissions: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int Perm = Sign2Perm(argv[3]);
	if (Perm == -1){
		cprintf("mon_clearpermissions: The permission bit is not set correctly.\n");
		return 0;
	}
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=PGSIZE){
		pde_t *pde = &kern_pgdir[PDX(Address)];
		if (*pde & PTE_P){
			pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
			if (*pte & PTE_P){
				*pte = *pte & ~Perm;
				continue;
			}
		}
	}
    cprintf("Permission has been updated:\n");
    mon_showmappings(argc-1,argv,tf);

    return 0;
}

int
mon_showvirtualmemory(int argc, char **argv, struct Trapframe *tf){
	if(argc!=3){
		cprintf("mon_showvvirtualmemory: The number of parameters is two.\n");
		return 0;
	}
	char *errChar;
	uintptr_t StartAddr = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_showvvirtualmemory: The first argument is not a number.\n");
		return 0;
	}
	uintptr_t EndAddr = strtol(argv[2],&errChar,0);
	if (*errChar){
		cprintf("mon_showvvirtualmemory: The second argument is not a number.\n");
		return 0;
	}
	if (StartAddr&0x3){
		cprintf("mon_clearpermissions: The first parameter is not aligned.\n");
		return 0;
	}
	if (EndAddr&0x3){
		cprintf("mon_clearpermissions: The second parameter is not aligned.\n");
		return 0;
	}
	if (StartAddr > EndAddr){
		cprintf("mon_showvvirtualmemory: The first parameter is larger than the second parameter.\n");
		return 0;
	}
	int c = 0;
	for (uintptr_t Address = StartAddr;Address < EndAddr; Address+=4){
		switch (c){
			case 0:cprintf("0x%08x   :0x%08x    ",Address,*(int*)Address);break;
			case 1:cprintf("0x%08x    ",*(int*)Address);break;
			case 2:cprintf("0x%08x    ",*(int*)Address);break;
			case 3:cprintf("0x%08x\n",*(int*)Address);break;
		}
		c = (c+1)&3;
	}
	return 0;
}
int
mon_va2pa(int argc, char **argv, struct Trapframe *tf){
	if(argc!=2){
		cprintf("mon_va2pa: The number of parameters is one.\n");
		return 0;
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_va2pa: The argument is not a number.\n");
		return 0;
	}
	pde_t *pde = &kern_pgdir[PDX(Address)];
	if (*pde & PTE_P){
		pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + PTX(Address);
		if (*pte & PTE_P){
			cprintf("The physical address is 0x%08x.\n",PTE_ADDR(*pte)|(Address&0x3ff));
		}
		else 
			cprintf("This is not a valid virtual address.\n");
	}
	else 
		cprintf("This is not a valid virtual address.\n");
	return 0;
}
int
mon_pa2va(int argc, char **argv, struct Trapframe *tf){
	if(argc!=2){
		cprintf("mon_pa2va: The number of parameters is one.\n");
		return 0;
	}
	char *errChar;
	uintptr_t Address = strtol(argv[1], &errChar, 0);
	if (*errChar){
		cprintf("mon_pa2va: The argument is not a number.\n");
		return 0;
	}
	int cnt=0;
	for (int i = 0; i < 1024; i++){
		pde_t *pde = &kern_pgdir[i];
		if (*pde & PTE_P){
			for (int j = 0; j < 1024; j++){
				pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + j;
				if (*pte & PTE_P){
					if (PTE_ADDR(*pte) == PTE_ADDR(Address)){
						if (cnt == 0 )cprintf("The virtual addresses are 0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
						else cprintf(",0x%08x",(i<<PDXSHIFT)|(j<<PTXSHIFT)|PGOFF(Address));
						cnt++;
					}
				}
			}
		}
	}
	if (cnt == 0)
		cprintf("There is no virtual address.\n");
	else cprintf(".\n");
	return 0;
}