
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 20             	sub    $0x20,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800052:	e8 f0 00 00 00       	call   800147 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	29 d0                	sub    %edx,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800070:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800073:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 f6                	test   %esi,%esi
  80007a:	7e 07                	jle    800083 <libmain+0x3f>
		binaryname = argv[0];
  80007c:	8b 03                	mov    (%ebx),%eax
  80007e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800083:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800087:	89 34 24             	mov    %esi,(%esp)
  80008a:	e8 a5 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008f:	e8 08 00 00 00       	call   80009c <exit>
}
  800094:	83 c4 20             	add    $0x20,%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a2:	e8 32 05 00 00       	call   8005d9 <close_all>
	sys_env_destroy(0);
  8000a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ae:	e8 42 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    
  8000b5:	00 00                	add    %al,(%eax)
	...

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7e 28                	jle    80013f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800122:	00 
  800123:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80012a:	00 
  80012b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800132:	00 
  800133:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80013a:	e8 c1 10 00 00       	call   801200 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013f:	83 c4 2c             	add    $0x2c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 02 00 00 00       	mov    $0x2,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_yield>:

void
sys_yield(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 0b 00 00 00       	mov    $0xb,%eax
  800176:	89 d1                	mov    %edx,%ecx
  800178:	89 d3                	mov    %edx,%ebx
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018e:	be 00 00 00 00       	mov    $0x0,%esi
  800193:	b8 04 00 00 00       	mov    $0x4,%eax
  800198:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	89 f7                	mov    %esi,%edi
  8001a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	7e 28                	jle    8001d1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c4:	00 
  8001c5:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8001cc:	e8 2f 10 00 00       	call   801200 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d1:	83 c4 2c             	add    $0x2c,%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7e 28                	jle    800224 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800200:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800207:	00 
  800208:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80020f:	00 
  800210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800217:	00 
  800218:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80021f:	e8 dc 0f 00 00       	call   801200 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800224:	83 c4 2c             	add    $0x2c,%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5f                   	pop    %edi
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	b8 06 00 00 00       	mov    $0x6,%eax
  80023f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	89 df                	mov    %ebx,%edi
  800247:	89 de                	mov    %ebx,%esi
  800249:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024b:	85 c0                	test   %eax,%eax
  80024d:	7e 28                	jle    800277 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800253:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025a:	00 
  80025b:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800262:	00 
  800263:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026a:	00 
  80026b:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800272:	e8 89 0f 00 00       	call   801200 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800277:	83 c4 2c             	add    $0x2c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 08 00 00 00       	mov    $0x8,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 28                	jle    8002ca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8002c5:	e8 36 0f 00 00       	call   801200 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ca:	83 c4 2c             	add    $0x2c,%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	89 df                	mov    %ebx,%edi
  8002ed:	89 de                	mov    %ebx,%esi
  8002ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 28                	jle    80031d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800300:	00 
  800301:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800308:	00 
  800309:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800310:	00 
  800311:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800318:	e8 e3 0e 00 00       	call   801200 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80031d:	83 c4 2c             	add    $0x2c,%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800333:	b8 0a 00 00 00       	mov    $0xa,%eax
  800338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 df                	mov    %ebx,%edi
  800340:	89 de                	mov    %ebx,%esi
  800342:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800344:	85 c0                	test   %eax,%eax
  800346:	7e 28                	jle    800370 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800348:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800353:	00 
  800354:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80035b:	00 
  80035c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800363:	00 
  800364:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80036b:	e8 90 0e 00 00       	call   801200 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800370:	83 c4 2c             	add    $0x2c,%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	57                   	push   %edi
  80037c:	56                   	push   %esi
  80037d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037e:	be 00 00 00 00       	mov    $0x0,%esi
  800383:	b8 0c 00 00 00       	mov    $0xc,%eax
  800388:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800391:	8b 55 08             	mov    0x8(%ebp),%edx
  800394:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
  8003a1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b1:	89 cb                	mov    %ecx,%ebx
  8003b3:	89 cf                	mov    %ecx,%edi
  8003b5:	89 ce                	mov    %ecx,%esi
  8003b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b9:	85 c0                	test   %eax,%eax
  8003bb:	7e 28                	jle    8003e5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d8:	00 
  8003d9:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8003e0:	e8 1b 0e 00 00       	call   801200 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e5:	83 c4 2c             	add    $0x2c,%esp
  8003e8:	5b                   	pop    %ebx
  8003e9:	5e                   	pop    %esi
  8003ea:	5f                   	pop    %edi
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    
  8003ed:	00 00                	add    %al,(%eax)
	...

008003f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800406:	8b 45 08             	mov    0x8(%ebp),%eax
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	e8 df ff ff ff       	call   8003f0 <fd2num>
  800411:	05 20 00 0d 00       	add    $0xd0020,%eax
  800416:	c1 e0 0c             	shl    $0xc,%eax
}
  800419:	c9                   	leave  
  80041a:	c3                   	ret    

0080041b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	53                   	push   %ebx
  80041f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800422:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800427:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800429:	89 c2                	mov    %eax,%edx
  80042b:	c1 ea 16             	shr    $0x16,%edx
  80042e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800435:	f6 c2 01             	test   $0x1,%dl
  800438:	74 11                	je     80044b <fd_alloc+0x30>
  80043a:	89 c2                	mov    %eax,%edx
  80043c:	c1 ea 0c             	shr    $0xc,%edx
  80043f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800446:	f6 c2 01             	test   $0x1,%dl
  800449:	75 09                	jne    800454 <fd_alloc+0x39>
			*fd_store = fd;
  80044b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	eb 17                	jmp    80046b <fd_alloc+0x50>
  800454:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800459:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80045e:	75 c7                	jne    800427 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800460:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800466:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80046b:	5b                   	pop    %ebx
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800474:	83 f8 1f             	cmp    $0x1f,%eax
  800477:	77 36                	ja     8004af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800479:	05 00 00 0d 00       	add    $0xd0000,%eax
  80047e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800481:	89 c2                	mov    %eax,%edx
  800483:	c1 ea 16             	shr    $0x16,%edx
  800486:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80048d:	f6 c2 01             	test   $0x1,%dl
  800490:	74 24                	je     8004b6 <fd_lookup+0x48>
  800492:	89 c2                	mov    %eax,%edx
  800494:	c1 ea 0c             	shr    $0xc,%edx
  800497:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049e:	f6 c2 01             	test   $0x1,%dl
  8004a1:	74 1a                	je     8004bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ad:	eb 13                	jmp    8004c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b4:	eb 0c                	jmp    8004c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004bb:	eb 05                	jmp    8004c2 <fd_lookup+0x54>
  8004bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	53                   	push   %ebx
  8004c8:	83 ec 14             	sub    $0x14,%esp
  8004cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004d8:	39 08                	cmp    %ecx,(%eax)
  8004da:	75 09                	jne    8004e5 <dev_lookup+0x21>
			*dev = devtab[i];
  8004dc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004de:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e3:	eb 35                	jmp    80051a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e5:	42                   	inc    %edx
  8004e6:	8b 04 95 34 20 80 00 	mov    0x802034(,%edx,4),%eax
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	75 e7                	jne    8004d8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	8b 40 48             	mov    0x48(%eax),%eax
  8004fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800503:	c7 04 24 b8 1f 80 00 	movl   $0x801fb8,(%esp)
  80050a:	e8 e9 0d 00 00       	call   8012f8 <cprintf>
	*dev = 0;
  80050f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800515:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80051a:	83 c4 14             	add    $0x14,%esp
  80051d:	5b                   	pop    %ebx
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	83 ec 30             	sub    $0x30,%esp
  800528:	8b 75 08             	mov    0x8(%ebp),%esi
  80052b:	8a 45 0c             	mov    0xc(%ebp),%al
  80052e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800531:	89 34 24             	mov    %esi,(%esp)
  800534:	e8 b7 fe ff ff       	call   8003f0 <fd2num>
  800539:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80053c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	e8 26 ff ff ff       	call   80046e <fd_lookup>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	85 c0                	test   %eax,%eax
  80054c:	78 05                	js     800553 <fd_close+0x33>
	    || fd != fd2)
  80054e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800551:	74 0d                	je     800560 <fd_close+0x40>
		return (must_exist ? r : 0);
  800553:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800557:	75 46                	jne    80059f <fd_close+0x7f>
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx
  80055e:	eb 3f                	jmp    80059f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800560:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800563:	89 44 24 04          	mov    %eax,0x4(%esp)
  800567:	8b 06                	mov    (%esi),%eax
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	e8 53 ff ff ff       	call   8004c4 <dev_lookup>
  800571:	89 c3                	mov    %eax,%ebx
  800573:	85 c0                	test   %eax,%eax
  800575:	78 18                	js     80058f <fd_close+0x6f>
		if (dev->dev_close)
  800577:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80057a:	8b 40 10             	mov    0x10(%eax),%eax
  80057d:	85 c0                	test   %eax,%eax
  80057f:	74 09                	je     80058a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800581:	89 34 24             	mov    %esi,(%esp)
  800584:	ff d0                	call   *%eax
  800586:	89 c3                	mov    %eax,%ebx
  800588:	eb 05                	jmp    80058f <fd_close+0x6f>
		else
			r = 0;
  80058a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80058f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80059a:	e8 8d fc ff ff       	call   80022c <sys_page_unmap>
	return r;
}
  80059f:	89 d8                	mov    %ebx,%eax
  8005a1:	83 c4 30             	add    $0x30,%esp
  8005a4:	5b                   	pop    %ebx
  8005a5:	5e                   	pop    %esi
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	e8 ae fe ff ff       	call   80046e <fd_lookup>
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	78 13                	js     8005d7 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005cb:	00 
  8005cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 49 ff ff ff       	call   800520 <fd_close>
}
  8005d7:	c9                   	leave  
  8005d8:	c3                   	ret    

008005d9 <close_all>:

void
close_all(void)
{
  8005d9:	55                   	push   %ebp
  8005da:	89 e5                	mov    %esp,%ebp
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005e5:	89 1c 24             	mov    %ebx,(%esp)
  8005e8:	e8 bb ff ff ff       	call   8005a8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ed:	43                   	inc    %ebx
  8005ee:	83 fb 20             	cmp    $0x20,%ebx
  8005f1:	75 f2                	jne    8005e5 <close_all+0xc>
		close(i);
}
  8005f3:	83 c4 14             	add    $0x14,%esp
  8005f6:	5b                   	pop    %ebx
  8005f7:	5d                   	pop    %ebp
  8005f8:	c3                   	ret    

008005f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	57                   	push   %edi
  8005fd:	56                   	push   %esi
  8005fe:	53                   	push   %ebx
  8005ff:	83 ec 4c             	sub    $0x4c,%esp
  800602:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800605:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 57 fe ff ff       	call   80046e <fd_lookup>
  800617:	89 c3                	mov    %eax,%ebx
  800619:	85 c0                	test   %eax,%eax
  80061b:	0f 88 e1 00 00 00    	js     800702 <dup+0x109>
		return r;
	close(newfdnum);
  800621:	89 3c 24             	mov    %edi,(%esp)
  800624:	e8 7f ff ff ff       	call   8005a8 <close>

	newfd = INDEX2FD(newfdnum);
  800629:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80062f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	e8 c3 fd ff ff       	call   800400 <fd2data>
  80063d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80063f:	89 34 24             	mov    %esi,(%esp)
  800642:	e8 b9 fd ff ff       	call   800400 <fd2data>
  800647:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80064a:	89 d8                	mov    %ebx,%eax
  80064c:	c1 e8 16             	shr    $0x16,%eax
  80064f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800656:	a8 01                	test   $0x1,%al
  800658:	74 46                	je     8006a0 <dup+0xa7>
  80065a:	89 d8                	mov    %ebx,%eax
  80065c:	c1 e8 0c             	shr    $0xc,%eax
  80065f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800666:	f6 c2 01             	test   $0x1,%dl
  800669:	74 35                	je     8006a0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80066b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800672:	25 07 0e 00 00       	and    $0xe07,%eax
  800677:	89 44 24 10          	mov    %eax,0x10(%esp)
  80067b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800682:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800689:	00 
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800695:	e8 3f fb ff ff       	call   8001d9 <sys_page_map>
  80069a:	89 c3                	mov    %eax,%ebx
  80069c:	85 c0                	test   %eax,%eax
  80069e:	78 3b                	js     8006db <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	c1 ea 0c             	shr    $0xc,%edx
  8006a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006af:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006c4:	00 
  8006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d0:	e8 04 fb ff ff       	call   8001d9 <sys_page_map>
  8006d5:	89 c3                	mov    %eax,%ebx
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	79 25                	jns    800700 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e6:	e8 41 fb ff ff       	call   80022c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f9:	e8 2e fb ff ff       	call   80022c <sys_page_unmap>
	return r;
  8006fe:	eb 02                	jmp    800702 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800700:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800702:	89 d8                	mov    %ebx,%eax
  800704:	83 c4 4c             	add    $0x4c,%esp
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 24             	sub    $0x24,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071d:	89 1c 24             	mov    %ebx,(%esp)
  800720:	e8 49 fd ff ff       	call   80046e <fd_lookup>
  800725:	85 c0                	test   %eax,%eax
  800727:	78 6f                	js     800798 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800729:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800733:	8b 00                	mov    (%eax),%eax
  800735:	89 04 24             	mov    %eax,(%esp)
  800738:	e8 87 fd ff ff       	call   8004c4 <dev_lookup>
  80073d:	85 c0                	test   %eax,%eax
  80073f:	78 57                	js     800798 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800741:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800744:	8b 50 08             	mov    0x8(%eax),%edx
  800747:	83 e2 03             	and    $0x3,%edx
  80074a:	83 fa 01             	cmp    $0x1,%edx
  80074d:	75 25                	jne    800774 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 00                	mov    (%eax),%eax
  800756:	8b 40 48             	mov    0x48(%eax),%eax
  800759:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80075d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800761:	c7 04 24 f9 1f 80 00 	movl   $0x801ff9,(%esp)
  800768:	e8 8b 0b 00 00       	call   8012f8 <cprintf>
		return -E_INVAL;
  80076d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800772:	eb 24                	jmp    800798 <read+0x8c>
	}
	if (!dev->dev_read)
  800774:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800777:	8b 52 08             	mov    0x8(%edx),%edx
  80077a:	85 d2                	test   %edx,%edx
  80077c:	74 15                	je     800793 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80077e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800781:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800788:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff d2                	call   *%edx
  800791:	eb 05                	jmp    800798 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800793:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800798:	83 c4 24             	add    $0x24,%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	57                   	push   %edi
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 1c             	sub    $0x1c,%esp
  8007a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b2:	eb 23                	jmp    8007d7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	29 d8                	sub    %ebx,%eax
  8007b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bf:	01 d8                	add    %ebx,%eax
  8007c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c5:	89 3c 24             	mov    %edi,(%esp)
  8007c8:	e8 3f ff ff ff       	call   80070c <read>
		if (m < 0)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 10                	js     8007e1 <readn+0x43>
			return m;
		if (m == 0)
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	74 0a                	je     8007df <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d5:	01 c3                	add    %eax,%ebx
  8007d7:	39 f3                	cmp    %esi,%ebx
  8007d9:	72 d9                	jb     8007b4 <readn+0x16>
  8007db:	89 d8                	mov    %ebx,%eax
  8007dd:	eb 02                	jmp    8007e1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007df:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007e1:	83 c4 1c             	add    $0x1c,%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5f                   	pop    %edi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 24             	sub    $0x24,%esp
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fa:	89 1c 24             	mov    %ebx,(%esp)
  8007fd:	e8 6c fc ff ff       	call   80046e <fd_lookup>
  800802:	85 c0                	test   %eax,%eax
  800804:	78 6a                	js     800870 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800810:	8b 00                	mov    (%eax),%eax
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 aa fc ff ff       	call   8004c4 <dev_lookup>
  80081a:	85 c0                	test   %eax,%eax
  80081c:	78 52                	js     800870 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800821:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800825:	75 25                	jne    80084c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800827:	a1 04 40 80 00       	mov    0x804004,%eax
  80082c:	8b 00                	mov    (%eax),%eax
  80082e:	8b 40 48             	mov    0x48(%eax),%eax
  800831:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800835:	89 44 24 04          	mov    %eax,0x4(%esp)
  800839:	c7 04 24 15 20 80 00 	movl   $0x802015,(%esp)
  800840:	e8 b3 0a 00 00       	call   8012f8 <cprintf>
		return -E_INVAL;
  800845:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084a:	eb 24                	jmp    800870 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80084c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084f:	8b 52 0c             	mov    0xc(%edx),%edx
  800852:	85 d2                	test   %edx,%edx
  800854:	74 15                	je     80086b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800859:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800860:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	ff d2                	call   *%edx
  800869:	eb 05                	jmp    800870 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80086b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800870:	83 c4 24             	add    $0x24,%esp
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <seek>:

int
seek(int fdnum, off_t offset)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80087c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 e0 fb ff ff       	call   80046e <fd_lookup>
  80088e:	85 c0                	test   %eax,%eax
  800890:	78 0e                	js     8008a0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800892:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
  800898:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	83 ec 24             	sub    $0x24,%esp
  8008a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 b3 fb ff ff       	call   80046e <fd_lookup>
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	78 63                	js     800922 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c9:	8b 00                	mov    (%eax),%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 f1 fb ff ff       	call   8004c4 <dev_lookup>
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	78 4b                	js     800922 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008de:	75 25                	jne    800905 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8008e5:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008e7:	8b 40 48             	mov    0x48(%eax),%eax
  8008ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f2:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8008f9:	e8 fa 09 00 00       	call   8012f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800903:	eb 1d                	jmp    800922 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800905:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800908:	8b 52 18             	mov    0x18(%edx),%edx
  80090b:	85 d2                	test   %edx,%edx
  80090d:	74 0e                	je     80091d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80090f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800912:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	ff d2                	call   *%edx
  80091b:	eb 05                	jmp    800922 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80091d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800922:	83 c4 24             	add    $0x24,%esp
  800925:	5b                   	pop    %ebx
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	53                   	push   %ebx
  80092c:	83 ec 24             	sub    $0x24,%esp
  80092f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800932:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800935:	89 44 24 04          	mov    %eax,0x4(%esp)
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	89 04 24             	mov    %eax,(%esp)
  80093f:	e8 2a fb ff ff       	call   80046e <fd_lookup>
  800944:	85 c0                	test   %eax,%eax
  800946:	78 52                	js     80099a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800948:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800952:	8b 00                	mov    (%eax),%eax
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	e8 68 fb ff ff       	call   8004c4 <dev_lookup>
  80095c:	85 c0                	test   %eax,%eax
  80095e:	78 3a                	js     80099a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800963:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800967:	74 2c                	je     800995 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800969:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80096c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800973:	00 00 00 
	stat->st_isdir = 0;
  800976:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80097d:	00 00 00 
	stat->st_dev = dev;
  800980:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80098d:	89 14 24             	mov    %edx,(%esp)
  800990:	ff 50 14             	call   *0x14(%eax)
  800993:	eb 05                	jmp    80099a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800995:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80099a:	83 c4 24             	add    $0x24,%esp
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009af:	00 
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 88 02 00 00       	call   800c43 <open>
  8009bb:	89 c3                	mov    %eax,%ebx
  8009bd:	85 c0                	test   %eax,%eax
  8009bf:	78 1b                	js     8009dc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c8:	89 1c 24             	mov    %ebx,(%esp)
  8009cb:	e8 58 ff ff ff       	call   800928 <fstat>
  8009d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8009d2:	89 1c 24             	mov    %ebx,(%esp)
  8009d5:	e8 ce fb ff ff       	call   8005a8 <close>
	return r;
  8009da:	89 f3                	mov    %esi,%ebx
}
  8009dc:	89 d8                	mov    %ebx,%eax
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
  8009e5:	00 00                	add    %al,(%eax)
	...

008009e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 10             	sub    $0x10,%esp
  8009f0:	89 c3                	mov    %eax,%ebx
  8009f2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009fb:	75 11                	jne    800a0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a04:	e8 92 12 00 00       	call   801c9b <ipc_find_env>
  800a09:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a15:	00 
  800a16:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a1d:	00 
  800a1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a22:	a1 00 40 80 00       	mov    0x804000,%eax
  800a27:	89 04 24             	mov    %eax,(%esp)
  800a2a:	e8 06 12 00 00       	call   801c35 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a36:	00 
  800a37:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a42:	e8 81 11 00 00       	call   801bc8 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a62:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a71:	e8 72 ff ff ff       	call   8009e8 <fsipc>
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 40 0c             	mov    0xc(%eax),%eax
  800a84:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800a93:	e8 50 ff ff ff       	call   8009e8 <fsipc>
}
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	83 ec 14             	sub    $0x14,%esp
  800aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aaa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ab9:	e8 2a ff ff ff       	call   8009e8 <fsipc>
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 2b                	js     800aed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ac2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ac9:	00 
  800aca:	89 1c 24             	mov    %ebx,(%esp)
  800acd:	e8 d1 0d 00 00       	call   8018a3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ad2:	a1 80 50 80 00       	mov    0x805080,%eax
  800ad7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800add:	a1 84 50 80 00       	mov    0x805084,%eax
  800ae2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aed:	83 c4 14             	add    $0x14,%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	53                   	push   %ebx
  800af7:	83 ec 14             	sub    $0x14,%esp
  800afa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 40 0c             	mov    0xc(%eax),%eax
  800b03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b08:	89 d8                	mov    %ebx,%eax
  800b0a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b10:	76 05                	jbe    800b17 <devfile_write+0x24>
  800b12:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b17:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b27:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b2e:	e8 53 0f 00 00       	call   801a86 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3d:	e8 a6 fe ff ff       	call   8009e8 <fsipc>
  800b42:	85 c0                	test   %eax,%eax
  800b44:	78 53                	js     800b99 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b46:	39 c3                	cmp    %eax,%ebx
  800b48:	73 24                	jae    800b6e <devfile_write+0x7b>
  800b4a:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800b51:	00 
  800b52:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b59:	00 
  800b5a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800b61:	00 
  800b62:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800b69:	e8 92 06 00 00       	call   801200 <_panic>
	assert(r <= PGSIZE);
  800b6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b73:	7e 24                	jle    800b99 <devfile_write+0xa6>
  800b75:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800b7c:	00 
  800b7d:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b84:	00 
  800b85:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800b8c:	00 
  800b8d:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800b94:	e8 67 06 00 00       	call   801200 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 10             	sub    $0x10,%esp
  800ba7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	8b 40 0c             	mov    0xc(%eax),%eax
  800bb0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bb5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc5:	e8 1e fe ff ff       	call   8009e8 <fsipc>
  800bca:	89 c3                	mov    %eax,%ebx
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	78 6a                	js     800c3a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bd0:	39 c6                	cmp    %eax,%esi
  800bd2:	73 24                	jae    800bf8 <devfile_read+0x59>
  800bd4:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800bdb:	00 
  800bdc:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800be3:	00 
  800be4:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800beb:	00 
  800bec:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800bf3:	e8 08 06 00 00       	call   801200 <_panic>
	assert(r <= PGSIZE);
  800bf8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bfd:	7e 24                	jle    800c23 <devfile_read+0x84>
  800bff:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800c1e:	e8 dd 05 00 00       	call   801200 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c27:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c2e:	00 
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	89 04 24             	mov    %eax,(%esp)
  800c35:	e8 e2 0d 00 00       	call   801a1c <memmove>
	return r;
}
  800c3a:	89 d8                	mov    %ebx,%eax
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 20             	sub    $0x20,%esp
  800c4b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c4e:	89 34 24             	mov    %esi,(%esp)
  800c51:	e8 1a 0c 00 00       	call   801870 <strlen>
  800c56:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c5b:	7f 60                	jg     800cbd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c60:	89 04 24             	mov    %eax,(%esp)
  800c63:	e8 b3 f7 ff ff       	call   80041b <fd_alloc>
  800c68:	89 c3                	mov    %eax,%ebx
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	78 54                	js     800cc2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c72:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c79:	e8 25 0c 00 00       	call   8018a3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c81:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c89:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8e:	e8 55 fd ff ff       	call   8009e8 <fsipc>
  800c93:	89 c3                	mov    %eax,%ebx
  800c95:	85 c0                	test   %eax,%eax
  800c97:	79 15                	jns    800cae <open+0x6b>
		fd_close(fd, 0);
  800c99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ca0:	00 
  800ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca4:	89 04 24             	mov    %eax,(%esp)
  800ca7:	e8 74 f8 ff ff       	call   800520 <fd_close>
		return r;
  800cac:	eb 14                	jmp    800cc2 <open+0x7f>
	}

	return fd2num(fd);
  800cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb1:	89 04 24             	mov    %eax,(%esp)
  800cb4:	e8 37 f7 ff ff       	call   8003f0 <fd2num>
  800cb9:	89 c3                	mov    %eax,%ebx
  800cbb:	eb 05                	jmp    800cc2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cbd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cc2:	89 d8                	mov    %ebx,%eax
  800cc4:	83 c4 20             	add    $0x20,%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdb:	e8 08 fd ff ff       	call   8009e8 <fsipc>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    
	...

00800ce4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 10             	sub    $0x10,%esp
  800cec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	89 04 24             	mov    %eax,(%esp)
  800cf5:	e8 06 f7 ff ff       	call   800400 <fd2data>
  800cfa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800cfc:	c7 44 24 04 77 20 80 	movl   $0x802077,0x4(%esp)
  800d03:	00 
  800d04:	89 34 24             	mov    %esi,(%esp)
  800d07:	e8 97 0b 00 00       	call   8018a3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d0c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d0f:	2b 03                	sub    (%ebx),%eax
  800d11:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d17:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d1e:	00 00 00 
	stat->st_dev = &devpipe;
  800d21:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d28:	30 80 00 
	return 0;
}
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 14             	sub    $0x14,%esp
  800d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d41:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d4c:	e8 db f4 ff ff       	call   80022c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d51:	89 1c 24             	mov    %ebx,(%esp)
  800d54:	e8 a7 f6 ff ff       	call   800400 <fd2data>
  800d59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d64:	e8 c3 f4 ff ff       	call   80022c <sys_page_unmap>
}
  800d69:	83 c4 14             	add    $0x14,%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 2c             	sub    $0x2c,%esp
  800d78:	89 c7                	mov    %eax,%edi
  800d7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d7d:	a1 04 40 80 00       	mov    0x804004,%eax
  800d82:	8b 00                	mov    (%eax),%eax
  800d84:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d87:	89 3c 24             	mov    %edi,(%esp)
  800d8a:	e8 51 0f 00 00       	call   801ce0 <pageref>
  800d8f:	89 c6                	mov    %eax,%esi
  800d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d94:	89 04 24             	mov    %eax,(%esp)
  800d97:	e8 44 0f 00 00       	call   801ce0 <pageref>
  800d9c:	39 c6                	cmp    %eax,%esi
  800d9e:	0f 94 c0             	sete   %al
  800da1:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800da4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800daa:	8b 12                	mov    (%edx),%edx
  800dac:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800daf:	39 cb                	cmp    %ecx,%ebx
  800db1:	75 08                	jne    800dbb <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800db3:	83 c4 2c             	add    $0x2c,%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800dbb:	83 f8 01             	cmp    $0x1,%eax
  800dbe:	75 bd                	jne    800d7d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800dc0:	8b 42 58             	mov    0x58(%edx),%eax
  800dc3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800dca:	00 
  800dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dcf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dd3:	c7 04 24 7e 20 80 00 	movl   $0x80207e,(%esp)
  800dda:	e8 19 05 00 00       	call   8012f8 <cprintf>
  800ddf:	eb 9c                	jmp    800d7d <_pipeisclosed+0xe>

00800de1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 1c             	sub    $0x1c,%esp
  800dea:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ded:	89 34 24             	mov    %esi,(%esp)
  800df0:	e8 0b f6 ff ff       	call   800400 <fd2data>
  800df5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800df7:	bf 00 00 00 00       	mov    $0x0,%edi
  800dfc:	eb 3c                	jmp    800e3a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800dfe:	89 da                	mov    %ebx,%edx
  800e00:	89 f0                	mov    %esi,%eax
  800e02:	e8 68 ff ff ff       	call   800d6f <_pipeisclosed>
  800e07:	85 c0                	test   %eax,%eax
  800e09:	75 38                	jne    800e43 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e0b:	e8 56 f3 ff ff       	call   800166 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e10:	8b 43 04             	mov    0x4(%ebx),%eax
  800e13:	8b 13                	mov    (%ebx),%edx
  800e15:	83 c2 20             	add    $0x20,%edx
  800e18:	39 d0                	cmp    %edx,%eax
  800e1a:	73 e2                	jae    800dfe <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e2a:	79 05                	jns    800e31 <devpipe_write+0x50>
  800e2c:	4a                   	dec    %edx
  800e2d:	83 ca e0             	or     $0xffffffe0,%edx
  800e30:	42                   	inc    %edx
  800e31:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e35:	40                   	inc    %eax
  800e36:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e39:	47                   	inc    %edi
  800e3a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e3d:	75 d1                	jne    800e10 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e3f:	89 f8                	mov    %edi,%eax
  800e41:	eb 05                	jmp    800e48 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e48:	83 c4 1c             	add    $0x1c,%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 1c             	sub    $0x1c,%esp
  800e59:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e5c:	89 3c 24             	mov    %edi,(%esp)
  800e5f:	e8 9c f5 ff ff       	call   800400 <fd2data>
  800e64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e66:	be 00 00 00 00       	mov    $0x0,%esi
  800e6b:	eb 3a                	jmp    800ea7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e6d:	85 f6                	test   %esi,%esi
  800e6f:	74 04                	je     800e75 <devpipe_read+0x25>
				return i;
  800e71:	89 f0                	mov    %esi,%eax
  800e73:	eb 40                	jmp    800eb5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e75:	89 da                	mov    %ebx,%edx
  800e77:	89 f8                	mov    %edi,%eax
  800e79:	e8 f1 fe ff ff       	call   800d6f <_pipeisclosed>
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	75 2e                	jne    800eb0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e82:	e8 df f2 ff ff       	call   800166 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e87:	8b 03                	mov    (%ebx),%eax
  800e89:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e8c:	74 df                	je     800e6d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e8e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e93:	79 05                	jns    800e9a <devpipe_read+0x4a>
  800e95:	48                   	dec    %eax
  800e96:	83 c8 e0             	or     $0xffffffe0,%eax
  800e99:	40                   	inc    %eax
  800e9a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800ea4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ea6:	46                   	inc    %esi
  800ea7:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eaa:	75 db                	jne    800e87 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800eac:	89 f0                	mov    %esi,%eax
  800eae:	eb 05                	jmp    800eb5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800eb5:	83 c4 1c             	add    $0x1c,%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 3c             	sub    $0x3c,%esp
  800ec6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ec9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ecc:	89 04 24             	mov    %eax,(%esp)
  800ecf:	e8 47 f5 ff ff       	call   80041b <fd_alloc>
  800ed4:	89 c3                	mov    %eax,%ebx
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	0f 88 45 01 00 00    	js     801023 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ede:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ee5:	00 
  800ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef4:	e8 8c f2 ff ff       	call   800185 <sys_page_alloc>
  800ef9:	89 c3                	mov    %eax,%ebx
  800efb:	85 c0                	test   %eax,%eax
  800efd:	0f 88 20 01 00 00    	js     801023 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800f03:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f06:	89 04 24             	mov    %eax,(%esp)
  800f09:	e8 0d f5 ff ff       	call   80041b <fd_alloc>
  800f0e:	89 c3                	mov    %eax,%ebx
  800f10:	85 c0                	test   %eax,%eax
  800f12:	0f 88 f8 00 00 00    	js     801010 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f18:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f1f:	00 
  800f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2e:	e8 52 f2 ff ff       	call   800185 <sys_page_alloc>
  800f33:	89 c3                	mov    %eax,%ebx
  800f35:	85 c0                	test   %eax,%eax
  800f37:	0f 88 d3 00 00 00    	js     801010 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f40:	89 04 24             	mov    %eax,(%esp)
  800f43:	e8 b8 f4 ff ff       	call   800400 <fd2data>
  800f48:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f4a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f51:	00 
  800f52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5d:	e8 23 f2 ff ff       	call   800185 <sys_page_alloc>
  800f62:	89 c3                	mov    %eax,%ebx
  800f64:	85 c0                	test   %eax,%eax
  800f66:	0f 88 91 00 00 00    	js     800ffd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f6f:	89 04 24             	mov    %eax,(%esp)
  800f72:	e8 89 f4 ff ff       	call   800400 <fd2data>
  800f77:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f7e:	00 
  800f7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f8a:	00 
  800f8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f96:	e8 3e f2 ff ff       	call   8001d9 <sys_page_map>
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 4c                	js     800fed <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800fa1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800faa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800faf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800fb6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fbf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800fc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800fcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fce:	89 04 24             	mov    %eax,(%esp)
  800fd1:	e8 1a f4 ff ff       	call   8003f0 <fd2num>
  800fd6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800fd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 0d f4 ff ff       	call   8003f0 <fd2num>
  800fe3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800feb:	eb 36                	jmp    801023 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800fed:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ff1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff8:	e8 2f f2 ff ff       	call   80022c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801000:	89 44 24 04          	mov    %eax,0x4(%esp)
  801004:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100b:	e8 1c f2 ff ff       	call   80022c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801010:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801013:	89 44 24 04          	mov    %eax,0x4(%esp)
  801017:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101e:	e8 09 f2 ff ff       	call   80022c <sys_page_unmap>
    err:
	return r;
}
  801023:	89 d8                	mov    %ebx,%eax
  801025:	83 c4 3c             	add    $0x3c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103a:	8b 45 08             	mov    0x8(%ebp),%eax
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	e8 29 f4 ff ff       	call   80046e <fd_lookup>
  801045:	85 c0                	test   %eax,%eax
  801047:	78 15                	js     80105e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801049:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104c:	89 04 24             	mov    %eax,(%esp)
  80104f:	e8 ac f3 ff ff       	call   800400 <fd2data>
	return _pipeisclosed(fd, p);
  801054:	89 c2                	mov    %eax,%edx
  801056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801059:	e8 11 fd ff ff       	call   800d6f <_pipeisclosed>
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801063:	b8 00 00 00 00       	mov    $0x0,%eax
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801070:	c7 44 24 04 96 20 80 	movl   $0x802096,0x4(%esp)
  801077:	00 
  801078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107b:	89 04 24             	mov    %eax,(%esp)
  80107e:	e8 20 08 00 00       	call   8018a3 <strcpy>
	return 0;
}
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
  801088:	c9                   	leave  
  801089:	c3                   	ret    

0080108a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	57                   	push   %edi
  80108e:	56                   	push   %esi
  80108f:	53                   	push   %ebx
  801090:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801096:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80109b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010a1:	eb 30                	jmp    8010d3 <devcons_write+0x49>
		m = n - tot;
  8010a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8010a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010a8:	83 fe 7f             	cmp    $0x7f,%esi
  8010ab:	76 05                	jbe    8010b2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010ad:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010b2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010b6:	03 45 0c             	add    0xc(%ebp),%eax
  8010b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bd:	89 3c 24             	mov    %edi,(%esp)
  8010c0:	e8 57 09 00 00       	call   801a1c <memmove>
		sys_cputs(buf, m);
  8010c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c9:	89 3c 24             	mov    %edi,(%esp)
  8010cc:	e8 e7 ef ff ff       	call   8000b8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010d1:	01 f3                	add    %esi,%ebx
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010d8:	72 c9                	jb     8010a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8010da:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8010eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ef:	75 07                	jne    8010f8 <devcons_read+0x13>
  8010f1:	eb 25                	jmp    801118 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8010f3:	e8 6e f0 ff ff       	call   800166 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8010f8:	e8 d9 ef ff ff       	call   8000d6 <sys_cgetc>
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	74 f2                	je     8010f3 <devcons_read+0xe>
  801101:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801103:	85 c0                	test   %eax,%eax
  801105:	78 1d                	js     801124 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801107:	83 f8 04             	cmp    $0x4,%eax
  80110a:	74 13                	je     80111f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80110c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110f:	88 10                	mov    %dl,(%eax)
	return 1;
  801111:	b8 01 00 00 00       	mov    $0x1,%eax
  801116:	eb 0c                	jmp    801124 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	eb 05                	jmp    801124 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801124:	c9                   	leave  
  801125:	c3                   	ret    

00801126 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801132:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801139:	00 
  80113a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80113d:	89 04 24             	mov    %eax,(%esp)
  801140:	e8 73 ef ff ff       	call   8000b8 <sys_cputs>
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <getchar>:

int
getchar(void)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80114d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801154:	00 
  801155:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801163:	e8 a4 f5 ff ff       	call   80070c <read>
	if (r < 0)
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 0f                	js     80117b <getchar+0x34>
		return r;
	if (r < 1)
  80116c:	85 c0                	test   %eax,%eax
  80116e:	7e 06                	jle    801176 <getchar+0x2f>
		return -E_EOF;
	return c;
  801170:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801174:	eb 05                	jmp    80117b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801176:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801183:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118a:	8b 45 08             	mov    0x8(%ebp),%eax
  80118d:	89 04 24             	mov    %eax,(%esp)
  801190:	e8 d9 f2 ff ff       	call   80046e <fd_lookup>
  801195:	85 c0                	test   %eax,%eax
  801197:	78 11                	js     8011aa <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801199:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011a2:	39 10                	cmp    %edx,(%eax)
  8011a4:	0f 94 c0             	sete   %al
  8011a7:	0f b6 c0             	movzbl %al,%eax
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <opencons>:

int
opencons(void)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b5:	89 04 24             	mov    %eax,(%esp)
  8011b8:	e8 5e f2 ff ff       	call   80041b <fd_alloc>
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 3c                	js     8011fd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8011c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011c8:	00 
  8011c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d7:	e8 a9 ef ff ff       	call   800185 <sys_page_alloc>
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 1d                	js     8011fd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8011e0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8011eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 f3 f1 ff ff       	call   8003f0 <fd2num>
}
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    
	...

00801200 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	56                   	push   %esi
  801204:	53                   	push   %ebx
  801205:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801208:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80120b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801211:	e8 31 ef ff ff       	call   800147 <sys_getenvid>
  801216:	8b 55 0c             	mov    0xc(%ebp),%edx
  801219:	89 54 24 10          	mov    %edx,0x10(%esp)
  80121d:	8b 55 08             	mov    0x8(%ebp),%edx
  801220:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801224:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122c:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  801233:	e8 c0 00 00 00       	call   8012f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801238:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123c:	8b 45 10             	mov    0x10(%ebp),%eax
  80123f:	89 04 24             	mov    %eax,(%esp)
  801242:	e8 50 00 00 00       	call   801297 <vcprintf>
	cprintf("\n");
  801247:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  80124e:	e8 a5 00 00 00       	call   8012f8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801253:	cc                   	int3   
  801254:	eb fd                	jmp    801253 <_panic+0x53>
	...

00801258 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 14             	sub    $0x14,%esp
  80125f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801262:	8b 03                	mov    (%ebx),%eax
  801264:	8b 55 08             	mov    0x8(%ebp),%edx
  801267:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80126b:	40                   	inc    %eax
  80126c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80126e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801273:	75 19                	jne    80128e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801275:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80127c:	00 
  80127d:	8d 43 08             	lea    0x8(%ebx),%eax
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	e8 30 ee ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  801288:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80128e:	ff 43 04             	incl   0x4(%ebx)
}
  801291:	83 c4 14             	add    $0x14,%esp
  801294:	5b                   	pop    %ebx
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8012a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012a7:	00 00 00 
	b.cnt = 0;
  8012aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8012c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cc:	c7 04 24 58 12 80 00 	movl   $0x801258,(%esp)
  8012d3:	e8 82 01 00 00       	call   80145a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8012d8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8012e8:	89 04 24             	mov    %eax,(%esp)
  8012eb:	e8 c8 ed ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  8012f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8012fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801301:	89 44 24 04          	mov    %eax,0x4(%esp)
  801305:	8b 45 08             	mov    0x8(%ebp),%eax
  801308:	89 04 24             	mov    %eax,(%esp)
  80130b:	e8 87 ff ff ff       	call   801297 <vcprintf>
	va_end(ap);

	return cnt;
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    
	...

00801314 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	57                   	push   %edi
  801318:	56                   	push   %esi
  801319:	53                   	push   %ebx
  80131a:	83 ec 3c             	sub    $0x3c,%esp
  80131d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801320:	89 d7                	mov    %edx,%edi
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
  801325:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80132e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801331:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801334:	85 c0                	test   %eax,%eax
  801336:	75 08                	jne    801340 <printnum+0x2c>
  801338:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80133b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80133e:	77 57                	ja     801397 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801340:	89 74 24 10          	mov    %esi,0x10(%esp)
  801344:	4b                   	dec    %ebx
  801345:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801349:	8b 45 10             	mov    0x10(%ebp),%eax
  80134c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801350:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801354:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801358:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80135f:	00 
  801360:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801363:	89 04 24             	mov    %eax,(%esp)
  801366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136d:	e8 b2 09 00 00       	call   801d24 <__udivdi3>
  801372:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801376:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80137a:	89 04 24             	mov    %eax,(%esp)
  80137d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801381:	89 fa                	mov    %edi,%edx
  801383:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801386:	e8 89 ff ff ff       	call   801314 <printnum>
  80138b:	eb 0f                	jmp    80139c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80138d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801391:	89 34 24             	mov    %esi,(%esp)
  801394:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801397:	4b                   	dec    %ebx
  801398:	85 db                	test   %ebx,%ebx
  80139a:	7f f1                	jg     80138d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80139c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8013a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013b2:	00 
  8013b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013b6:	89 04 24             	mov    %eax,(%esp)
  8013b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c0:	e8 7f 0a 00 00       	call   801e44 <__umoddi3>
  8013c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013c9:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8013d6:	83 c4 3c             	add    $0x3c,%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013e1:	83 fa 01             	cmp    $0x1,%edx
  8013e4:	7e 0e                	jle    8013f4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013e6:	8b 10                	mov    (%eax),%edx
  8013e8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013eb:	89 08                	mov    %ecx,(%eax)
  8013ed:	8b 02                	mov    (%edx),%eax
  8013ef:	8b 52 04             	mov    0x4(%edx),%edx
  8013f2:	eb 22                	jmp    801416 <getuint+0x38>
	else if (lflag)
  8013f4:	85 d2                	test   %edx,%edx
  8013f6:	74 10                	je     801408 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8013f8:	8b 10                	mov    (%eax),%edx
  8013fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013fd:	89 08                	mov    %ecx,(%eax)
  8013ff:	8b 02                	mov    (%edx),%eax
  801401:	ba 00 00 00 00       	mov    $0x0,%edx
  801406:	eb 0e                	jmp    801416 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801408:	8b 10                	mov    (%eax),%edx
  80140a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80140d:	89 08                	mov    %ecx,(%eax)
  80140f:	8b 02                	mov    (%edx),%eax
  801411:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80141e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801421:	8b 10                	mov    (%eax),%edx
  801423:	3b 50 04             	cmp    0x4(%eax),%edx
  801426:	73 08                	jae    801430 <sprintputch+0x18>
		*b->buf++ = ch;
  801428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142b:	88 0a                	mov    %cl,(%edx)
  80142d:	42                   	inc    %edx
  80142e:	89 10                	mov    %edx,(%eax)
}
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801438:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80143b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143f:	8b 45 10             	mov    0x10(%ebp),%eax
  801442:	89 44 24 08          	mov    %eax,0x8(%esp)
  801446:	8b 45 0c             	mov    0xc(%ebp),%eax
  801449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144d:	8b 45 08             	mov    0x8(%ebp),%eax
  801450:	89 04 24             	mov    %eax,(%esp)
  801453:	e8 02 00 00 00       	call   80145a <vprintfmt>
	va_end(ap);
}
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	57                   	push   %edi
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	83 ec 4c             	sub    $0x4c,%esp
  801463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801466:	8b 75 10             	mov    0x10(%ebp),%esi
  801469:	eb 12                	jmp    80147d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80146b:	85 c0                	test   %eax,%eax
  80146d:	0f 84 6b 03 00 00    	je     8017de <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801473:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801477:	89 04 24             	mov    %eax,(%esp)
  80147a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80147d:	0f b6 06             	movzbl (%esi),%eax
  801480:	46                   	inc    %esi
  801481:	83 f8 25             	cmp    $0x25,%eax
  801484:	75 e5                	jne    80146b <vprintfmt+0x11>
  801486:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80148a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801491:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801496:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80149d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014a2:	eb 26                	jmp    8014ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8014a7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014ab:	eb 1d                	jmp    8014ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014b0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014b4:	eb 14                	jmp    8014ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8014c0:	eb 08                	jmp    8014ca <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8014c2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8014c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ca:	0f b6 06             	movzbl (%esi),%eax
  8014cd:	8d 56 01             	lea    0x1(%esi),%edx
  8014d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014d3:	8a 16                	mov    (%esi),%dl
  8014d5:	83 ea 23             	sub    $0x23,%edx
  8014d8:	80 fa 55             	cmp    $0x55,%dl
  8014db:	0f 87 e1 02 00 00    	ja     8017c2 <vprintfmt+0x368>
  8014e1:	0f b6 d2             	movzbl %dl,%edx
  8014e4:	ff 24 95 00 22 80 00 	jmp    *0x802200(,%edx,4)
  8014eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014ee:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8014f3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8014f6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8014fa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014fd:	8d 50 d0             	lea    -0x30(%eax),%edx
  801500:	83 fa 09             	cmp    $0x9,%edx
  801503:	77 2a                	ja     80152f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801505:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801506:	eb eb                	jmp    8014f3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801508:	8b 45 14             	mov    0x14(%ebp),%eax
  80150b:	8d 50 04             	lea    0x4(%eax),%edx
  80150e:	89 55 14             	mov    %edx,0x14(%ebp)
  801511:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801513:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801516:	eb 17                	jmp    80152f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801518:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80151c:	78 98                	js     8014b6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80151e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801521:	eb a7                	jmp    8014ca <vprintfmt+0x70>
  801523:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801526:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80152d:	eb 9b                	jmp    8014ca <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80152f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801533:	79 95                	jns    8014ca <vprintfmt+0x70>
  801535:	eb 8b                	jmp    8014c2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801537:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801538:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80153b:	eb 8d                	jmp    8014ca <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80153d:	8b 45 14             	mov    0x14(%ebp),%eax
  801540:	8d 50 04             	lea    0x4(%eax),%edx
  801543:	89 55 14             	mov    %edx,0x14(%ebp)
  801546:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80154a:	8b 00                	mov    (%eax),%eax
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801552:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801555:	e9 23 ff ff ff       	jmp    80147d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80155a:	8b 45 14             	mov    0x14(%ebp),%eax
  80155d:	8d 50 04             	lea    0x4(%eax),%edx
  801560:	89 55 14             	mov    %edx,0x14(%ebp)
  801563:	8b 00                	mov    (%eax),%eax
  801565:	85 c0                	test   %eax,%eax
  801567:	79 02                	jns    80156b <vprintfmt+0x111>
  801569:	f7 d8                	neg    %eax
  80156b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80156d:	83 f8 0f             	cmp    $0xf,%eax
  801570:	7f 0b                	jg     80157d <vprintfmt+0x123>
  801572:	8b 04 85 60 23 80 00 	mov    0x802360(,%eax,4),%eax
  801579:	85 c0                	test   %eax,%eax
  80157b:	75 23                	jne    8015a0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80157d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801581:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  801588:	00 
  801589:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80158d:	8b 45 08             	mov    0x8(%ebp),%eax
  801590:	89 04 24             	mov    %eax,(%esp)
  801593:	e8 9a fe ff ff       	call   801432 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801598:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80159b:	e9 dd fe ff ff       	jmp    80147d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8015a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a4:	c7 44 24 08 5d 20 80 	movl   $0x80205d,0x8(%esp)
  8015ab:	00 
  8015ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b3:	89 14 24             	mov    %edx,(%esp)
  8015b6:	e8 77 fe ff ff       	call   801432 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015be:	e9 ba fe ff ff       	jmp    80147d <vprintfmt+0x23>
  8015c3:	89 f9                	mov    %edi,%ecx
  8015c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8015cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ce:	8d 50 04             	lea    0x4(%eax),%edx
  8015d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8015d4:	8b 30                	mov    (%eax),%esi
  8015d6:	85 f6                	test   %esi,%esi
  8015d8:	75 05                	jne    8015df <vprintfmt+0x185>
				p = "(null)";
  8015da:	be d8 20 80 00       	mov    $0x8020d8,%esi
			if (width > 0 && padc != '-')
  8015df:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015e3:	0f 8e 84 00 00 00    	jle    80166d <vprintfmt+0x213>
  8015e9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015ed:	74 7e                	je     80166d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015ef:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015f3:	89 34 24             	mov    %esi,(%esp)
  8015f6:	e8 8b 02 00 00       	call   801886 <strnlen>
  8015fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8015fe:	29 c2                	sub    %eax,%edx
  801600:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801603:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801607:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80160a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80160d:	89 de                	mov    %ebx,%esi
  80160f:	89 d3                	mov    %edx,%ebx
  801611:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801613:	eb 0b                	jmp    801620 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801615:	89 74 24 04          	mov    %esi,0x4(%esp)
  801619:	89 3c 24             	mov    %edi,(%esp)
  80161c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80161f:	4b                   	dec    %ebx
  801620:	85 db                	test   %ebx,%ebx
  801622:	7f f1                	jg     801615 <vprintfmt+0x1bb>
  801624:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801627:	89 f3                	mov    %esi,%ebx
  801629:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80162c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162f:	85 c0                	test   %eax,%eax
  801631:	79 05                	jns    801638 <vprintfmt+0x1de>
  801633:	b8 00 00 00 00       	mov    $0x0,%eax
  801638:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80163b:	29 c2                	sub    %eax,%edx
  80163d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801640:	eb 2b                	jmp    80166d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801642:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801646:	74 18                	je     801660 <vprintfmt+0x206>
  801648:	8d 50 e0             	lea    -0x20(%eax),%edx
  80164b:	83 fa 5e             	cmp    $0x5e,%edx
  80164e:	76 10                	jbe    801660 <vprintfmt+0x206>
					putch('?', putdat);
  801650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801654:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80165b:	ff 55 08             	call   *0x8(%ebp)
  80165e:	eb 0a                	jmp    80166a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801664:	89 04 24             	mov    %eax,(%esp)
  801667:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80166a:	ff 4d e4             	decl   -0x1c(%ebp)
  80166d:	0f be 06             	movsbl (%esi),%eax
  801670:	46                   	inc    %esi
  801671:	85 c0                	test   %eax,%eax
  801673:	74 21                	je     801696 <vprintfmt+0x23c>
  801675:	85 ff                	test   %edi,%edi
  801677:	78 c9                	js     801642 <vprintfmt+0x1e8>
  801679:	4f                   	dec    %edi
  80167a:	79 c6                	jns    801642 <vprintfmt+0x1e8>
  80167c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80167f:	89 de                	mov    %ebx,%esi
  801681:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801684:	eb 18                	jmp    80169e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801686:	89 74 24 04          	mov    %esi,0x4(%esp)
  80168a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801691:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801693:	4b                   	dec    %ebx
  801694:	eb 08                	jmp    80169e <vprintfmt+0x244>
  801696:	8b 7d 08             	mov    0x8(%ebp),%edi
  801699:	89 de                	mov    %ebx,%esi
  80169b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80169e:	85 db                	test   %ebx,%ebx
  8016a0:	7f e4                	jg     801686 <vprintfmt+0x22c>
  8016a2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8016a5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016aa:	e9 ce fd ff ff       	jmp    80147d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016af:	83 f9 01             	cmp    $0x1,%ecx
  8016b2:	7e 10                	jle    8016c4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b7:	8d 50 08             	lea    0x8(%eax),%edx
  8016ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8016bd:	8b 30                	mov    (%eax),%esi
  8016bf:	8b 78 04             	mov    0x4(%eax),%edi
  8016c2:	eb 26                	jmp    8016ea <vprintfmt+0x290>
	else if (lflag)
  8016c4:	85 c9                	test   %ecx,%ecx
  8016c6:	74 12                	je     8016da <vprintfmt+0x280>
		return va_arg(*ap, long);
  8016c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016cb:	8d 50 04             	lea    0x4(%eax),%edx
  8016ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d1:	8b 30                	mov    (%eax),%esi
  8016d3:	89 f7                	mov    %esi,%edi
  8016d5:	c1 ff 1f             	sar    $0x1f,%edi
  8016d8:	eb 10                	jmp    8016ea <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8016da:	8b 45 14             	mov    0x14(%ebp),%eax
  8016dd:	8d 50 04             	lea    0x4(%eax),%edx
  8016e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8016e3:	8b 30                	mov    (%eax),%esi
  8016e5:	89 f7                	mov    %esi,%edi
  8016e7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8016ea:	85 ff                	test   %edi,%edi
  8016ec:	78 0a                	js     8016f8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8016ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016f3:	e9 8c 00 00 00       	jmp    801784 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8016f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016fc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801703:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801706:	f7 de                	neg    %esi
  801708:	83 d7 00             	adc    $0x0,%edi
  80170b:	f7 df                	neg    %edi
			}
			base = 10;
  80170d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801712:	eb 70                	jmp    801784 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801714:	89 ca                	mov    %ecx,%edx
  801716:	8d 45 14             	lea    0x14(%ebp),%eax
  801719:	e8 c0 fc ff ff       	call   8013de <getuint>
  80171e:	89 c6                	mov    %eax,%esi
  801720:	89 d7                	mov    %edx,%edi
			base = 10;
  801722:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801727:	eb 5b                	jmp    801784 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801729:	89 ca                	mov    %ecx,%edx
  80172b:	8d 45 14             	lea    0x14(%ebp),%eax
  80172e:	e8 ab fc ff ff       	call   8013de <getuint>
  801733:	89 c6                	mov    %eax,%esi
  801735:	89 d7                	mov    %edx,%edi
			base = 8;
  801737:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80173c:	eb 46                	jmp    801784 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80173e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801742:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801749:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80174c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801750:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801757:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80175a:	8b 45 14             	mov    0x14(%ebp),%eax
  80175d:	8d 50 04             	lea    0x4(%eax),%edx
  801760:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801763:	8b 30                	mov    (%eax),%esi
  801765:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80176a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80176f:	eb 13                	jmp    801784 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801771:	89 ca                	mov    %ecx,%edx
  801773:	8d 45 14             	lea    0x14(%ebp),%eax
  801776:	e8 63 fc ff ff       	call   8013de <getuint>
  80177b:	89 c6                	mov    %eax,%esi
  80177d:	89 d7                	mov    %edx,%edi
			base = 16;
  80177f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801784:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801788:	89 54 24 10          	mov    %edx,0x10(%esp)
  80178c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80178f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801793:	89 44 24 08          	mov    %eax,0x8(%esp)
  801797:	89 34 24             	mov    %esi,(%esp)
  80179a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179e:	89 da                	mov    %ebx,%edx
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	e8 6c fb ff ff       	call   801314 <printnum>
			break;
  8017a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017ab:	e9 cd fc ff ff       	jmp    80147d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b4:	89 04 24             	mov    %eax,(%esp)
  8017b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017bd:	e9 bb fc ff ff       	jmp    80147d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017cd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017d0:	eb 01                	jmp    8017d3 <vprintfmt+0x379>
  8017d2:	4e                   	dec    %esi
  8017d3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017d7:	75 f9                	jne    8017d2 <vprintfmt+0x378>
  8017d9:	e9 9f fc ff ff       	jmp    80147d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8017de:	83 c4 4c             	add    $0x4c,%esp
  8017e1:	5b                   	pop    %ebx
  8017e2:	5e                   	pop    %esi
  8017e3:	5f                   	pop    %edi
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 28             	sub    $0x28,%esp
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801803:	85 c0                	test   %eax,%eax
  801805:	74 30                	je     801837 <vsnprintf+0x51>
  801807:	85 d2                	test   %edx,%edx
  801809:	7e 33                	jle    80183e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80180b:	8b 45 14             	mov    0x14(%ebp),%eax
  80180e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801812:	8b 45 10             	mov    0x10(%ebp),%eax
  801815:	89 44 24 08          	mov    %eax,0x8(%esp)
  801819:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  801827:	e8 2e fc ff ff       	call   80145a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80182c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80182f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	eb 0c                	jmp    801843 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183c:	eb 05                	jmp    801843 <vsnprintf+0x5d>
  80183e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80184b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80184e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801852:	8b 45 10             	mov    0x10(%ebp),%eax
  801855:	89 44 24 08          	mov    %eax,0x8(%esp)
  801859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801860:	8b 45 08             	mov    0x8(%ebp),%eax
  801863:	89 04 24             	mov    %eax,(%esp)
  801866:	e8 7b ff ff ff       	call   8017e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    
  80186d:	00 00                	add    %al,(%eax)
	...

00801870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
  80187b:	eb 01                	jmp    80187e <strlen+0xe>
		n++;
  80187d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80187e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801882:	75 f9                	jne    80187d <strlen+0xd>
		n++;
	return n;
}
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80188c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80188f:	b8 00 00 00 00       	mov    $0x0,%eax
  801894:	eb 01                	jmp    801897 <strnlen+0x11>
		n++;
  801896:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801897:	39 d0                	cmp    %edx,%eax
  801899:	74 06                	je     8018a1 <strnlen+0x1b>
  80189b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80189f:	75 f5                	jne    801896 <strnlen+0x10>
		n++;
	return n;
}
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018b5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018b8:	42                   	inc    %edx
  8018b9:	84 c9                	test   %cl,%cl
  8018bb:	75 f5                	jne    8018b2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018bd:	5b                   	pop    %ebx
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018ca:	89 1c 24             	mov    %ebx,(%esp)
  8018cd:	e8 9e ff ff ff       	call   801870 <strlen>
	strcpy(dst + len, src);
  8018d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d9:	01 d8                	add    %ebx,%eax
  8018db:	89 04 24             	mov    %eax,(%esp)
  8018de:	e8 c0 ff ff ff       	call   8018a3 <strcpy>
	return dst;
}
  8018e3:	89 d8                	mov    %ebx,%eax
  8018e5:	83 c4 08             	add    $0x8,%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018fe:	eb 0c                	jmp    80190c <strncpy+0x21>
		*dst++ = *src;
  801900:	8a 1a                	mov    (%edx),%bl
  801902:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801905:	80 3a 01             	cmpb   $0x1,(%edx)
  801908:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80190b:	41                   	inc    %ecx
  80190c:	39 f1                	cmp    %esi,%ecx
  80190e:	75 f0                	jne    801900 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801910:	5b                   	pop    %ebx
  801911:	5e                   	pop    %esi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	56                   	push   %esi
  801918:	53                   	push   %ebx
  801919:	8b 75 08             	mov    0x8(%ebp),%esi
  80191c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801922:	85 d2                	test   %edx,%edx
  801924:	75 0a                	jne    801930 <strlcpy+0x1c>
  801926:	89 f0                	mov    %esi,%eax
  801928:	eb 1a                	jmp    801944 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80192a:	88 18                	mov    %bl,(%eax)
  80192c:	40                   	inc    %eax
  80192d:	41                   	inc    %ecx
  80192e:	eb 02                	jmp    801932 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801930:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801932:	4a                   	dec    %edx
  801933:	74 0a                	je     80193f <strlcpy+0x2b>
  801935:	8a 19                	mov    (%ecx),%bl
  801937:	84 db                	test   %bl,%bl
  801939:	75 ef                	jne    80192a <strlcpy+0x16>
  80193b:	89 c2                	mov    %eax,%edx
  80193d:	eb 02                	jmp    801941 <strlcpy+0x2d>
  80193f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801941:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801944:	29 f0                	sub    %esi,%eax
}
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801950:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801953:	eb 02                	jmp    801957 <strcmp+0xd>
		p++, q++;
  801955:	41                   	inc    %ecx
  801956:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801957:	8a 01                	mov    (%ecx),%al
  801959:	84 c0                	test   %al,%al
  80195b:	74 04                	je     801961 <strcmp+0x17>
  80195d:	3a 02                	cmp    (%edx),%al
  80195f:	74 f4                	je     801955 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801961:	0f b6 c0             	movzbl %al,%eax
  801964:	0f b6 12             	movzbl (%edx),%edx
  801967:	29 d0                	sub    %edx,%eax
}
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	53                   	push   %ebx
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801975:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801978:	eb 03                	jmp    80197d <strncmp+0x12>
		n--, p++, q++;
  80197a:	4a                   	dec    %edx
  80197b:	40                   	inc    %eax
  80197c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80197d:	85 d2                	test   %edx,%edx
  80197f:	74 14                	je     801995 <strncmp+0x2a>
  801981:	8a 18                	mov    (%eax),%bl
  801983:	84 db                	test   %bl,%bl
  801985:	74 04                	je     80198b <strncmp+0x20>
  801987:	3a 19                	cmp    (%ecx),%bl
  801989:	74 ef                	je     80197a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80198b:	0f b6 00             	movzbl (%eax),%eax
  80198e:	0f b6 11             	movzbl (%ecx),%edx
  801991:	29 d0                	sub    %edx,%eax
  801993:	eb 05                	jmp    80199a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80199a:	5b                   	pop    %ebx
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019a6:	eb 05                	jmp    8019ad <strchr+0x10>
		if (*s == c)
  8019a8:	38 ca                	cmp    %cl,%dl
  8019aa:	74 0c                	je     8019b8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019ac:	40                   	inc    %eax
  8019ad:	8a 10                	mov    (%eax),%dl
  8019af:	84 d2                	test   %dl,%dl
  8019b1:	75 f5                	jne    8019a8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019c3:	eb 05                	jmp    8019ca <strfind+0x10>
		if (*s == c)
  8019c5:	38 ca                	cmp    %cl,%dl
  8019c7:	74 07                	je     8019d0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8019c9:	40                   	inc    %eax
  8019ca:	8a 10                	mov    (%eax),%dl
  8019cc:	84 d2                	test   %dl,%dl
  8019ce:	75 f5                	jne    8019c5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	57                   	push   %edi
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019e1:	85 c9                	test   %ecx,%ecx
  8019e3:	74 30                	je     801a15 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019eb:	75 25                	jne    801a12 <memset+0x40>
  8019ed:	f6 c1 03             	test   $0x3,%cl
  8019f0:	75 20                	jne    801a12 <memset+0x40>
		c &= 0xFF;
  8019f2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019f5:	89 d3                	mov    %edx,%ebx
  8019f7:	c1 e3 08             	shl    $0x8,%ebx
  8019fa:	89 d6                	mov    %edx,%esi
  8019fc:	c1 e6 18             	shl    $0x18,%esi
  8019ff:	89 d0                	mov    %edx,%eax
  801a01:	c1 e0 10             	shl    $0x10,%eax
  801a04:	09 f0                	or     %esi,%eax
  801a06:	09 d0                	or     %edx,%eax
  801a08:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a0a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a0d:	fc                   	cld    
  801a0e:	f3 ab                	rep stos %eax,%es:(%edi)
  801a10:	eb 03                	jmp    801a15 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a12:	fc                   	cld    
  801a13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a15:	89 f8                	mov    %edi,%eax
  801a17:	5b                   	pop    %ebx
  801a18:	5e                   	pop    %esi
  801a19:	5f                   	pop    %edi
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	57                   	push   %edi
  801a20:	56                   	push   %esi
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a2a:	39 c6                	cmp    %eax,%esi
  801a2c:	73 34                	jae    801a62 <memmove+0x46>
  801a2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a31:	39 d0                	cmp    %edx,%eax
  801a33:	73 2d                	jae    801a62 <memmove+0x46>
		s += n;
		d += n;
  801a35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a38:	f6 c2 03             	test   $0x3,%dl
  801a3b:	75 1b                	jne    801a58 <memmove+0x3c>
  801a3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a43:	75 13                	jne    801a58 <memmove+0x3c>
  801a45:	f6 c1 03             	test   $0x3,%cl
  801a48:	75 0e                	jne    801a58 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a4a:	83 ef 04             	sub    $0x4,%edi
  801a4d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a50:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a53:	fd                   	std    
  801a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a56:	eb 07                	jmp    801a5f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a58:	4f                   	dec    %edi
  801a59:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a5c:	fd                   	std    
  801a5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a5f:	fc                   	cld    
  801a60:	eb 20                	jmp    801a82 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a62:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a68:	75 13                	jne    801a7d <memmove+0x61>
  801a6a:	a8 03                	test   $0x3,%al
  801a6c:	75 0f                	jne    801a7d <memmove+0x61>
  801a6e:	f6 c1 03             	test   $0x3,%cl
  801a71:	75 0a                	jne    801a7d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a73:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a76:	89 c7                	mov    %eax,%edi
  801a78:	fc                   	cld    
  801a79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a7b:	eb 05                	jmp    801a82 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a7d:	89 c7                	mov    %eax,%edi
  801a7f:	fc                   	cld    
  801a80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a82:	5e                   	pop    %esi
  801a83:	5f                   	pop    %edi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	89 04 24             	mov    %eax,(%esp)
  801aa0:	e8 77 ff ff ff       	call   801a1c <memmove>
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	57                   	push   %edi
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  801abb:	eb 16                	jmp    801ad3 <memcmp+0x2c>
		if (*s1 != *s2)
  801abd:	8a 04 17             	mov    (%edi,%edx,1),%al
  801ac0:	42                   	inc    %edx
  801ac1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801ac5:	38 c8                	cmp    %cl,%al
  801ac7:	74 0a                	je     801ad3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ac9:	0f b6 c0             	movzbl %al,%eax
  801acc:	0f b6 c9             	movzbl %cl,%ecx
  801acf:	29 c8                	sub    %ecx,%eax
  801ad1:	eb 09                	jmp    801adc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ad3:	39 da                	cmp    %ebx,%edx
  801ad5:	75 e6                	jne    801abd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801aef:	eb 05                	jmp    801af6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801af1:	38 08                	cmp    %cl,(%eax)
  801af3:	74 05                	je     801afa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801af5:	40                   	inc    %eax
  801af6:	39 d0                	cmp    %edx,%eax
  801af8:	72 f7                	jb     801af1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	8b 55 08             	mov    0x8(%ebp),%edx
  801b05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b08:	eb 01                	jmp    801b0b <strtol+0xf>
		s++;
  801b0a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b0b:	8a 02                	mov    (%edx),%al
  801b0d:	3c 20                	cmp    $0x20,%al
  801b0f:	74 f9                	je     801b0a <strtol+0xe>
  801b11:	3c 09                	cmp    $0x9,%al
  801b13:	74 f5                	je     801b0a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b15:	3c 2b                	cmp    $0x2b,%al
  801b17:	75 08                	jne    801b21 <strtol+0x25>
		s++;
  801b19:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b1a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1f:	eb 13                	jmp    801b34 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b21:	3c 2d                	cmp    $0x2d,%al
  801b23:	75 0a                	jne    801b2f <strtol+0x33>
		s++, neg = 1;
  801b25:	8d 52 01             	lea    0x1(%edx),%edx
  801b28:	bf 01 00 00 00       	mov    $0x1,%edi
  801b2d:	eb 05                	jmp    801b34 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b34:	85 db                	test   %ebx,%ebx
  801b36:	74 05                	je     801b3d <strtol+0x41>
  801b38:	83 fb 10             	cmp    $0x10,%ebx
  801b3b:	75 28                	jne    801b65 <strtol+0x69>
  801b3d:	8a 02                	mov    (%edx),%al
  801b3f:	3c 30                	cmp    $0x30,%al
  801b41:	75 10                	jne    801b53 <strtol+0x57>
  801b43:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b47:	75 0a                	jne    801b53 <strtol+0x57>
		s += 2, base = 16;
  801b49:	83 c2 02             	add    $0x2,%edx
  801b4c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b51:	eb 12                	jmp    801b65 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b53:	85 db                	test   %ebx,%ebx
  801b55:	75 0e                	jne    801b65 <strtol+0x69>
  801b57:	3c 30                	cmp    $0x30,%al
  801b59:	75 05                	jne    801b60 <strtol+0x64>
		s++, base = 8;
  801b5b:	42                   	inc    %edx
  801b5c:	b3 08                	mov    $0x8,%bl
  801b5e:	eb 05                	jmp    801b65 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b60:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b6c:	8a 0a                	mov    (%edx),%cl
  801b6e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b71:	80 fb 09             	cmp    $0x9,%bl
  801b74:	77 08                	ja     801b7e <strtol+0x82>
			dig = *s - '0';
  801b76:	0f be c9             	movsbl %cl,%ecx
  801b79:	83 e9 30             	sub    $0x30,%ecx
  801b7c:	eb 1e                	jmp    801b9c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b7e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b81:	80 fb 19             	cmp    $0x19,%bl
  801b84:	77 08                	ja     801b8e <strtol+0x92>
			dig = *s - 'a' + 10;
  801b86:	0f be c9             	movsbl %cl,%ecx
  801b89:	83 e9 57             	sub    $0x57,%ecx
  801b8c:	eb 0e                	jmp    801b9c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b8e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b91:	80 fb 19             	cmp    $0x19,%bl
  801b94:	77 12                	ja     801ba8 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b96:	0f be c9             	movsbl %cl,%ecx
  801b99:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b9c:	39 f1                	cmp    %esi,%ecx
  801b9e:	7d 0c                	jge    801bac <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801ba0:	42                   	inc    %edx
  801ba1:	0f af c6             	imul   %esi,%eax
  801ba4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801ba6:	eb c4                	jmp    801b6c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801ba8:	89 c1                	mov    %eax,%ecx
  801baa:	eb 02                	jmp    801bae <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801bac:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801bae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bb2:	74 05                	je     801bb9 <strtol+0xbd>
		*endptr = (char *) s;
  801bb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bb7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bb9:	85 ff                	test   %edi,%edi
  801bbb:	74 04                	je     801bc1 <strtol+0xc5>
  801bbd:	89 c8                	mov    %ecx,%eax
  801bbf:	f7 d8                	neg    %eax
}
  801bc1:	5b                   	pop    %ebx
  801bc2:	5e                   	pop    %esi
  801bc3:	5f                   	pop    %edi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    
	...

00801bc8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 10             	sub    $0x10,%esp
  801bd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	75 05                	jne    801be2 <ipc_recv+0x1a>
  801bdd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801be2:	89 04 24             	mov    %eax,(%esp)
  801be5:	e8 b1 e7 ff ff       	call   80039b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801bea:	85 c0                	test   %eax,%eax
  801bec:	79 16                	jns    801c04 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801bee:	85 db                	test   %ebx,%ebx
  801bf0:	74 06                	je     801bf8 <ipc_recv+0x30>
  801bf2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801bf8:	85 f6                	test   %esi,%esi
  801bfa:	74 32                	je     801c2e <ipc_recv+0x66>
  801bfc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c02:	eb 2a                	jmp    801c2e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c04:	85 db                	test   %ebx,%ebx
  801c06:	74 0c                	je     801c14 <ipc_recv+0x4c>
  801c08:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0d:	8b 00                	mov    (%eax),%eax
  801c0f:	8b 40 74             	mov    0x74(%eax),%eax
  801c12:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c14:	85 f6                	test   %esi,%esi
  801c16:	74 0c                	je     801c24 <ipc_recv+0x5c>
  801c18:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1d:	8b 00                	mov    (%eax),%eax
  801c1f:	8b 40 78             	mov    0x78(%eax),%eax
  801c22:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c24:	a1 04 40 80 00       	mov    0x804004,%eax
  801c29:	8b 00                	mov    (%eax),%eax
  801c2b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	57                   	push   %edi
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 1c             	sub    $0x1c,%esp
  801c3e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c44:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c47:	85 db                	test   %ebx,%ebx
  801c49:	75 05                	jne    801c50 <ipc_send+0x1b>
  801c4b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c50:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	89 04 24             	mov    %eax,(%esp)
  801c62:	e8 11 e7 ff ff       	call   800378 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c67:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c6a:	75 07                	jne    801c73 <ipc_send+0x3e>
  801c6c:	e8 f5 e4 ff ff       	call   800166 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c71:	eb dd                	jmp    801c50 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c73:	85 c0                	test   %eax,%eax
  801c75:	79 1c                	jns    801c93 <ipc_send+0x5e>
  801c77:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801c7e:	00 
  801c7f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c86:	00 
  801c87:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  801c8e:	e8 6d f5 ff ff       	call   801200 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801c93:	83 c4 1c             	add    $0x1c,%esp
  801c96:	5b                   	pop    %ebx
  801c97:	5e                   	pop    %esi
  801c98:	5f                   	pop    %edi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	53                   	push   %ebx
  801c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ca7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	c1 e2 07             	shl    $0x7,%edx
  801cb3:	29 ca                	sub    %ecx,%edx
  801cb5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cbb:	8b 52 50             	mov    0x50(%edx),%edx
  801cbe:	39 da                	cmp    %ebx,%edx
  801cc0:	75 0f                	jne    801cd1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cc2:	c1 e0 07             	shl    $0x7,%eax
  801cc5:	29 c8                	sub    %ecx,%eax
  801cc7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ccc:	8b 40 40             	mov    0x40(%eax),%eax
  801ccf:	eb 0c                	jmp    801cdd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cd1:	40                   	inc    %eax
  801cd2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cd7:	75 ce                	jne    801ca7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd9:	66 b8 00 00          	mov    $0x0,%ax
}
  801cdd:	5b                   	pop    %ebx
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801ce6:	89 c2                	mov    %eax,%edx
  801ce8:	c1 ea 16             	shr    $0x16,%edx
  801ceb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cf2:	f6 c2 01             	test   $0x1,%dl
  801cf5:	74 1e                	je     801d15 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cf7:	c1 e8 0c             	shr    $0xc,%eax
  801cfa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d01:	a8 01                	test   $0x1,%al
  801d03:	74 17                	je     801d1c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d05:	c1 e8 0c             	shr    $0xc,%eax
  801d08:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d0f:	ef 
  801d10:	0f b7 c0             	movzwl %ax,%eax
  801d13:	eb 0c                	jmp    801d21 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d15:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1a:	eb 05                	jmp    801d21 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d1c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    
	...

00801d24 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d24:	55                   	push   %ebp
  801d25:	57                   	push   %edi
  801d26:	56                   	push   %esi
  801d27:	83 ec 10             	sub    $0x10,%esp
  801d2a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d2e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d32:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d36:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d3a:	89 cd                	mov    %ecx,%ebp
  801d3c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d40:	85 c0                	test   %eax,%eax
  801d42:	75 2c                	jne    801d70 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d44:	39 f9                	cmp    %edi,%ecx
  801d46:	77 68                	ja     801db0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d48:	85 c9                	test   %ecx,%ecx
  801d4a:	75 0b                	jne    801d57 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d51:	31 d2                	xor    %edx,%edx
  801d53:	f7 f1                	div    %ecx
  801d55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d57:	31 d2                	xor    %edx,%edx
  801d59:	89 f8                	mov    %edi,%eax
  801d5b:	f7 f1                	div    %ecx
  801d5d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d5f:	89 f0                	mov    %esi,%eax
  801d61:	f7 f1                	div    %ecx
  801d63:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d70:	39 f8                	cmp    %edi,%eax
  801d72:	77 2c                	ja     801da0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d74:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d77:	83 f6 1f             	xor    $0x1f,%esi
  801d7a:	75 4c                	jne    801dc8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d7c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d7e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d83:	72 0a                	jb     801d8f <__udivdi3+0x6b>
  801d85:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d89:	0f 87 ad 00 00 00    	ja     801e3c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d8f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d94:	89 f0                	mov    %esi,%eax
  801d96:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    
  801d9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801da0:	31 ff                	xor    %edi,%edi
  801da2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801da4:	89 f0                	mov    %esi,%eax
  801da6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    
  801daf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801db0:	89 fa                	mov    %edi,%edx
  801db2:	89 f0                	mov    %esi,%eax
  801db4:	f7 f1                	div    %ecx
  801db6:	89 c6                	mov    %eax,%esi
  801db8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dba:	89 f0                	mov    %esi,%eax
  801dbc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    
  801dc5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dc8:	89 f1                	mov    %esi,%ecx
  801dca:	d3 e0                	shl    %cl,%eax
  801dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dd0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801dd7:	89 ea                	mov    %ebp,%edx
  801dd9:	88 c1                	mov    %al,%cl
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801de1:	09 ca                	or     %ecx,%edx
  801de3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801de7:	89 f1                	mov    %esi,%ecx
  801de9:	d3 e5                	shl    %cl,%ebp
  801deb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801def:	89 fd                	mov    %edi,%ebp
  801df1:	88 c1                	mov    %al,%cl
  801df3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801df5:	89 fa                	mov    %edi,%edx
  801df7:	89 f1                	mov    %esi,%ecx
  801df9:	d3 e2                	shl    %cl,%edx
  801dfb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dff:	88 c1                	mov    %al,%cl
  801e01:	d3 ef                	shr    %cl,%edi
  801e03:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e05:	89 f8                	mov    %edi,%eax
  801e07:	89 ea                	mov    %ebp,%edx
  801e09:	f7 74 24 08          	divl   0x8(%esp)
  801e0d:	89 d1                	mov    %edx,%ecx
  801e0f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e11:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e15:	39 d1                	cmp    %edx,%ecx
  801e17:	72 17                	jb     801e30 <__udivdi3+0x10c>
  801e19:	74 09                	je     801e24 <__udivdi3+0x100>
  801e1b:	89 fe                	mov    %edi,%esi
  801e1d:	31 ff                	xor    %edi,%edi
  801e1f:	e9 41 ff ff ff       	jmp    801d65 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e24:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e28:	89 f1                	mov    %esi,%ecx
  801e2a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e2c:	39 c2                	cmp    %eax,%edx
  801e2e:	73 eb                	jae    801e1b <__udivdi3+0xf7>
		{
		  q0--;
  801e30:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e33:	31 ff                	xor    %edi,%edi
  801e35:	e9 2b ff ff ff       	jmp    801d65 <__udivdi3+0x41>
  801e3a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e3c:	31 f6                	xor    %esi,%esi
  801e3e:	e9 22 ff ff ff       	jmp    801d65 <__udivdi3+0x41>
	...

00801e44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e44:	55                   	push   %ebp
  801e45:	57                   	push   %edi
  801e46:	56                   	push   %esi
  801e47:	83 ec 20             	sub    $0x20,%esp
  801e4a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e4e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e52:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e56:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e5e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e62:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e64:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e66:	85 ed                	test   %ebp,%ebp
  801e68:	75 16                	jne    801e80 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e6a:	39 f1                	cmp    %esi,%ecx
  801e6c:	0f 86 a6 00 00 00    	jbe    801f18 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e72:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e74:	89 d0                	mov    %edx,%eax
  801e76:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e78:	83 c4 20             	add    $0x20,%esp
  801e7b:	5e                   	pop    %esi
  801e7c:	5f                   	pop    %edi
  801e7d:	5d                   	pop    %ebp
  801e7e:	c3                   	ret    
  801e7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e80:	39 f5                	cmp    %esi,%ebp
  801e82:	0f 87 ac 00 00 00    	ja     801f34 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e88:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801e8b:	83 f0 1f             	xor    $0x1f,%eax
  801e8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e92:	0f 84 a8 00 00 00    	je     801f40 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e98:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e9c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e9e:	bf 20 00 00 00       	mov    $0x20,%edi
  801ea3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ea7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eab:	89 f9                	mov    %edi,%ecx
  801ead:	d3 e8                	shr    %cl,%eax
  801eaf:	09 e8                	or     %ebp,%eax
  801eb1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801eb5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eb9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ebd:	d3 e0                	shl    %cl,%eax
  801ebf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ec3:	89 f2                	mov    %esi,%edx
  801ec5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ec7:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ecb:	d3 e0                	shl    %cl,%eax
  801ecd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ed1:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	d3 e8                	shr    %cl,%eax
  801ed9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801edb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801edd:	89 f2                	mov    %esi,%edx
  801edf:	f7 74 24 18          	divl   0x18(%esp)
  801ee3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ee5:	f7 64 24 0c          	mull   0xc(%esp)
  801ee9:	89 c5                	mov    %eax,%ebp
  801eeb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801eed:	39 d6                	cmp    %edx,%esi
  801eef:	72 67                	jb     801f58 <__umoddi3+0x114>
  801ef1:	74 75                	je     801f68 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ef3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801ef7:	29 e8                	sub    %ebp,%eax
  801ef9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801efb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eff:	d3 e8                	shr    %cl,%eax
  801f01:	89 f2                	mov    %esi,%edx
  801f03:	89 f9                	mov    %edi,%ecx
  801f05:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f07:	09 d0                	or     %edx,%eax
  801f09:	89 f2                	mov    %esi,%edx
  801f0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f0f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f11:	83 c4 20             	add    $0x20,%esp
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f18:	85 c9                	test   %ecx,%ecx
  801f1a:	75 0b                	jne    801f27 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f21:	31 d2                	xor    %edx,%edx
  801f23:	f7 f1                	div    %ecx
  801f25:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f27:	89 f0                	mov    %esi,%eax
  801f29:	31 d2                	xor    %edx,%edx
  801f2b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f2d:	89 f8                	mov    %edi,%eax
  801f2f:	e9 3e ff ff ff       	jmp    801e72 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f34:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f36:	83 c4 20             	add    $0x20,%esp
  801f39:	5e                   	pop    %esi
  801f3a:	5f                   	pop    %edi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
  801f3d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f40:	39 f5                	cmp    %esi,%ebp
  801f42:	72 04                	jb     801f48 <__umoddi3+0x104>
  801f44:	39 f9                	cmp    %edi,%ecx
  801f46:	77 06                	ja     801f4e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f48:	89 f2                	mov    %esi,%edx
  801f4a:	29 cf                	sub    %ecx,%edi
  801f4c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f4e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f50:	83 c4 20             	add    $0x20,%esp
  801f53:	5e                   	pop    %esi
  801f54:	5f                   	pop    %edi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    
  801f57:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f58:	89 d1                	mov    %edx,%ecx
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f60:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f64:	eb 8d                	jmp    801ef3 <__umoddi3+0xaf>
  801f66:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f68:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f6c:	72 ea                	jb     801f58 <__umoddi3+0x114>
  801f6e:	89 f1                	mov    %esi,%ecx
  801f70:	eb 81                	jmp    801ef3 <__umoddi3+0xaf>
