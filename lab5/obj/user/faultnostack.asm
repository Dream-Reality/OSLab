
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 08 04 80 	movl   $0x800408,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 ef 02 00 00       	call   80033d <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 20             	sub    $0x20,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80006a:	e8 f0 00 00 00       	call   80015f <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800088:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80008b:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800090:	85 f6                	test   %esi,%esi
  800092:	7e 07                	jle    80009b <libmain+0x3f>
		binaryname = argv[0];
  800094:	8b 03                	mov    (%ebx),%eax
  800096:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009f:	89 34 24             	mov    %esi,(%esp)
  8000a2:	e8 8d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a7:	e8 08 00 00 00       	call   8000b4 <exit>
}
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ba:	e8 5a 05 00 00       	call   800619 <close_all>
	sys_env_destroy(0);
  8000bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c6:	e8 42 00 00 00       	call   80010d <sys_env_destroy>
}
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    
  8000cd:	00 00                	add    %al,(%eax)
	...

008000d0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	57                   	push   %edi
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000de:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e1:	89 c3                	mov    %eax,%ebx
  8000e3:	89 c7                	mov    %eax,%edi
  8000e5:	89 c6                	mov    %eax,%esi
  8000e7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fe:	89 d1                	mov    %edx,%ecx
  800100:	89 d3                	mov    %edx,%ebx
  800102:	89 d7                	mov    %edx,%edi
  800104:	89 d6                	mov    %edx,%esi
  800106:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	b8 03 00 00 00       	mov    $0x3,%eax
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	89 cb                	mov    %ecx,%ebx
  800125:	89 cf                	mov    %ecx,%edi
  800127:	89 ce                	mov    %ecx,%esi
  800129:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7e 28                	jle    800157 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800133:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013a:	00 
  80013b:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  800152:	e8 e9 10 00 00       	call   801240 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800157:	83 c4 2c             	add    $0x2c,%esp
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 02 00 00 00       	mov    $0x2,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_yield>:

void
sys_yield(void)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800184:	ba 00 00 00 00       	mov    $0x0,%edx
  800189:	b8 0b 00 00 00       	mov    $0xb,%eax
  80018e:	89 d1                	mov    %edx,%ecx
  800190:	89 d3                	mov    %edx,%ebx
  800192:	89 d7                	mov    %edx,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	be 00 00 00 00       	mov    $0x0,%esi
  8001ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	89 f7                	mov    %esi,%edi
  8001bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7e 28                	jle    8001e9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  8001d4:	00 
  8001d5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001dc:	00 
  8001dd:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  8001e4:	e8 57 10 00 00       	call   801240 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e9:	83 c4 2c             	add    $0x2c,%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5f                   	pop    %edi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    

008001f1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	57                   	push   %edi
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ff:	8b 75 18             	mov    0x18(%ebp),%esi
  800202:	8b 7d 14             	mov    0x14(%ebp),%edi
  800205:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7e 28                	jle    80023c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800214:	89 44 24 10          	mov    %eax,0x10(%esp)
  800218:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80021f:	00 
  800220:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  800227:	00 
  800228:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80022f:	00 
  800230:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  800237:	e8 04 10 00 00       	call   801240 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80023c:	83 c4 2c             	add    $0x2c,%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800252:	b8 06 00 00 00       	mov    $0x6,%eax
  800257:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025a:	8b 55 08             	mov    0x8(%ebp),%edx
  80025d:	89 df                	mov    %ebx,%edi
  80025f:	89 de                	mov    %ebx,%esi
  800261:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800263:	85 c0                	test   %eax,%eax
  800265:	7e 28                	jle    80028f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800267:	89 44 24 10          	mov    %eax,0x10(%esp)
  80026b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800272:	00 
  800273:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  80027a:	00 
  80027b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800282:	00 
  800283:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  80028a:	e8 b1 0f 00 00       	call   801240 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80028f:	83 c4 2c             	add    $0x2c,%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	89 df                	mov    %ebx,%edi
  8002b2:	89 de                	mov    %ebx,%esi
  8002b4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 28                	jle    8002e2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002be:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d5:	00 
  8002d6:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  8002dd:	e8 5e 0f 00 00       	call   801240 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e2:	83 c4 2c             	add    $0x2c,%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	89 df                	mov    %ebx,%edi
  800305:	89 de                	mov    %ebx,%esi
  800307:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800309:	85 c0                	test   %eax,%eax
  80030b:	7e 28                	jle    800335 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80030d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800311:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800318:	00 
  800319:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  800320:	00 
  800321:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800328:	00 
  800329:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  800330:	e8 0b 0f 00 00       	call   801240 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800335:	83 c4 2c             	add    $0x2c,%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800346:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800350:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800353:	8b 55 08             	mov    0x8(%ebp),%edx
  800356:	89 df                	mov    %ebx,%edi
  800358:	89 de                	mov    %ebx,%esi
  80035a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80035c:	85 c0                	test   %eax,%eax
  80035e:	7e 28                	jle    800388 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800360:	89 44 24 10          	mov    %eax,0x10(%esp)
  800364:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80036b:	00 
  80036c:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  800373:	00 
  800374:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037b:	00 
  80037c:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  800383:	e8 b8 0e 00 00       	call   801240 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800388:	83 c4 2c             	add    $0x2c,%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800396:	be 00 00 00 00       	mov    $0x0,%esi
  80039b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ae:	5b                   	pop    %ebx
  8003af:	5e                   	pop    %esi
  8003b0:	5f                   	pop    %edi
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	57                   	push   %edi
  8003b7:	56                   	push   %esi
  8003b8:	53                   	push   %ebx
  8003b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c9:	89 cb                	mov    %ecx,%ebx
  8003cb:	89 cf                	mov    %ecx,%edi
  8003cd:	89 ce                	mov    %ecx,%esi
  8003cf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	7e 28                	jle    8003fd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003e0:	00 
  8003e1:	c7 44 24 08 6a 20 80 	movl   $0x80206a,0x8(%esp)
  8003e8:	00 
  8003e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f0:	00 
  8003f1:	c7 04 24 87 20 80 00 	movl   $0x802087,(%esp)
  8003f8:	e8 43 0e 00 00       	call   801240 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003fd:	83 c4 2c             	add    $0x2c,%esp
  800400:	5b                   	pop    %ebx
  800401:	5e                   	pop    %esi
  800402:	5f                   	pop    %edi
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    
  800405:	00 00                	add    %al,(%eax)
	...

00800408 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800408:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800409:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80040e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800410:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  800413:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  800417:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  80041c:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  800420:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  800422:	83 c4 08             	add    $0x8,%esp
	popal
  800425:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  800426:	83 c4 04             	add    $0x4,%esp
	popfl
  800429:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  80042a:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80042d:	c3                   	ret    
	...

00800430 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	05 00 00 00 30       	add    $0x30000000,%eax
  80043b:	c1 e8 0c             	shr    $0xc,%eax
}
  80043e:	5d                   	pop    %ebp
  80043f:	c3                   	ret    

00800440 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800446:	8b 45 08             	mov    0x8(%ebp),%eax
  800449:	89 04 24             	mov    %eax,(%esp)
  80044c:	e8 df ff ff ff       	call   800430 <fd2num>
  800451:	05 20 00 0d 00       	add    $0xd0020,%eax
  800456:	c1 e0 0c             	shl    $0xc,%eax
}
  800459:	c9                   	leave  
  80045a:	c3                   	ret    

0080045b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	53                   	push   %ebx
  80045f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800462:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800467:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800469:	89 c2                	mov    %eax,%edx
  80046b:	c1 ea 16             	shr    $0x16,%edx
  80046e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800475:	f6 c2 01             	test   $0x1,%dl
  800478:	74 11                	je     80048b <fd_alloc+0x30>
  80047a:	89 c2                	mov    %eax,%edx
  80047c:	c1 ea 0c             	shr    $0xc,%edx
  80047f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800486:	f6 c2 01             	test   $0x1,%dl
  800489:	75 09                	jne    800494 <fd_alloc+0x39>
			*fd_store = fd;
  80048b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	eb 17                	jmp    8004ab <fd_alloc+0x50>
  800494:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800499:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80049e:	75 c7                	jne    800467 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004ab:	5b                   	pop    %ebx
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004b4:	83 f8 1f             	cmp    $0x1f,%eax
  8004b7:	77 36                	ja     8004ef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004b9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8004be:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004c1:	89 c2                	mov    %eax,%edx
  8004c3:	c1 ea 16             	shr    $0x16,%edx
  8004c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004cd:	f6 c2 01             	test   $0x1,%dl
  8004d0:	74 24                	je     8004f6 <fd_lookup+0x48>
  8004d2:	89 c2                	mov    %eax,%edx
  8004d4:	c1 ea 0c             	shr    $0xc,%edx
  8004d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004de:	f6 c2 01             	test   $0x1,%dl
  8004e1:	74 1a                	je     8004fd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e6:	89 02                	mov    %eax,(%edx)
	return 0;
  8004e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ed:	eb 13                	jmp    800502 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004f4:	eb 0c                	jmp    800502 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004fb:	eb 05                	jmp    800502 <fd_lookup+0x54>
  8004fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	53                   	push   %ebx
  800508:	83 ec 14             	sub    $0x14,%esp
  80050b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80050e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800511:	ba 00 00 00 00       	mov    $0x0,%edx
  800516:	eb 0e                	jmp    800526 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800518:	39 08                	cmp    %ecx,(%eax)
  80051a:	75 09                	jne    800525 <dev_lookup+0x21>
			*dev = devtab[i];
  80051c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80051e:	b8 00 00 00 00       	mov    $0x0,%eax
  800523:	eb 35                	jmp    80055a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800525:	42                   	inc    %edx
  800526:	8b 04 95 14 21 80 00 	mov    0x802114(,%edx,4),%eax
  80052d:	85 c0                	test   %eax,%eax
  80052f:	75 e7                	jne    800518 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800531:	a1 04 40 80 00       	mov    0x804004,%eax
  800536:	8b 00                	mov    (%eax),%eax
  800538:	8b 40 48             	mov    0x48(%eax),%eax
  80053b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80053f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800543:	c7 04 24 98 20 80 00 	movl   $0x802098,(%esp)
  80054a:	e8 e9 0d 00 00       	call   801338 <cprintf>
	*dev = 0;
  80054f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800555:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80055a:	83 c4 14             	add    $0x14,%esp
  80055d:	5b                   	pop    %ebx
  80055e:	5d                   	pop    %ebp
  80055f:	c3                   	ret    

00800560 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	83 ec 30             	sub    $0x30,%esp
  800568:	8b 75 08             	mov    0x8(%ebp),%esi
  80056b:	8a 45 0c             	mov    0xc(%ebp),%al
  80056e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 b7 fe ff ff       	call   800430 <fd2num>
  800579:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80057c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 26 ff ff ff       	call   8004ae <fd_lookup>
  800588:	89 c3                	mov    %eax,%ebx
  80058a:	85 c0                	test   %eax,%eax
  80058c:	78 05                	js     800593 <fd_close+0x33>
	    || fd != fd2)
  80058e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800591:	74 0d                	je     8005a0 <fd_close+0x40>
		return (must_exist ? r : 0);
  800593:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800597:	75 46                	jne    8005df <fd_close+0x7f>
  800599:	bb 00 00 00 00       	mov    $0x0,%ebx
  80059e:	eb 3f                	jmp    8005df <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a7:	8b 06                	mov    (%esi),%eax
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	e8 53 ff ff ff       	call   800504 <dev_lookup>
  8005b1:	89 c3                	mov    %eax,%ebx
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	78 18                	js     8005cf <fd_close+0x6f>
		if (dev->dev_close)
  8005b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ba:	8b 40 10             	mov    0x10(%eax),%eax
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	74 09                	je     8005ca <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005c1:	89 34 24             	mov    %esi,(%esp)
  8005c4:	ff d0                	call   *%eax
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	eb 05                	jmp    8005cf <fd_close+0x6f>
		else
			r = 0;
  8005ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005da:	e8 65 fc ff ff       	call   800244 <sys_page_unmap>
	return r;
}
  8005df:	89 d8                	mov    %ebx,%eax
  8005e1:	83 c4 30             	add    $0x30,%esp
  8005e4:	5b                   	pop    %ebx
  8005e5:	5e                   	pop    %esi
  8005e6:	5d                   	pop    %ebp
  8005e7:	c3                   	ret    

008005e8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f8:	89 04 24             	mov    %eax,(%esp)
  8005fb:	e8 ae fe ff ff       	call   8004ae <fd_lookup>
  800600:	85 c0                	test   %eax,%eax
  800602:	78 13                	js     800617 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800604:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80060b:	00 
  80060c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 49 ff ff ff       	call   800560 <fd_close>
}
  800617:	c9                   	leave  
  800618:	c3                   	ret    

00800619 <close_all>:

void
close_all(void)
{
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	53                   	push   %ebx
  80061d:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800620:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800625:	89 1c 24             	mov    %ebx,(%esp)
  800628:	e8 bb ff ff ff       	call   8005e8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80062d:	43                   	inc    %ebx
  80062e:	83 fb 20             	cmp    $0x20,%ebx
  800631:	75 f2                	jne    800625 <close_all+0xc>
		close(i);
}
  800633:	83 c4 14             	add    $0x14,%esp
  800636:	5b                   	pop    %ebx
  800637:	5d                   	pop    %ebp
  800638:	c3                   	ret    

00800639 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	57                   	push   %edi
  80063d:	56                   	push   %esi
  80063e:	53                   	push   %ebx
  80063f:	83 ec 4c             	sub    $0x4c,%esp
  800642:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800645:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064c:	8b 45 08             	mov    0x8(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 57 fe ff ff       	call   8004ae <fd_lookup>
  800657:	89 c3                	mov    %eax,%ebx
  800659:	85 c0                	test   %eax,%eax
  80065b:	0f 88 e1 00 00 00    	js     800742 <dup+0x109>
		return r;
	close(newfdnum);
  800661:	89 3c 24             	mov    %edi,(%esp)
  800664:	e8 7f ff ff ff       	call   8005e8 <close>

	newfd = INDEX2FD(newfdnum);
  800669:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80066f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	e8 c3 fd ff ff       	call   800440 <fd2data>
  80067d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80067f:	89 34 24             	mov    %esi,(%esp)
  800682:	e8 b9 fd ff ff       	call   800440 <fd2data>
  800687:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80068a:	89 d8                	mov    %ebx,%eax
  80068c:	c1 e8 16             	shr    $0x16,%eax
  80068f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800696:	a8 01                	test   $0x1,%al
  800698:	74 46                	je     8006e0 <dup+0xa7>
  80069a:	89 d8                	mov    %ebx,%eax
  80069c:	c1 e8 0c             	shr    $0xc,%eax
  80069f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006a6:	f6 c2 01             	test   $0x1,%dl
  8006a9:	74 35                	je     8006e0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8006b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006c9:	00 
  8006ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d5:	e8 17 fb ff ff       	call   8001f1 <sys_page_map>
  8006da:	89 c3                	mov    %eax,%ebx
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	78 3b                	js     80071b <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006e3:	89 c2                	mov    %eax,%edx
  8006e5:	c1 ea 0c             	shr    $0xc,%edx
  8006e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006ef:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800704:	00 
  800705:	89 44 24 04          	mov    %eax,0x4(%esp)
  800709:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800710:	e8 dc fa ff ff       	call   8001f1 <sys_page_map>
  800715:	89 c3                	mov    %eax,%ebx
  800717:	85 c0                	test   %eax,%eax
  800719:	79 25                	jns    800740 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80071b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80071f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800726:	e8 19 fb ff ff       	call   800244 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80072b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80072e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800732:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800739:	e8 06 fb ff ff       	call   800244 <sys_page_unmap>
	return r;
  80073e:	eb 02                	jmp    800742 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800740:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800742:	89 d8                	mov    %ebx,%eax
  800744:	83 c4 4c             	add    $0x4c,%esp
  800747:	5b                   	pop    %ebx
  800748:	5e                   	pop    %esi
  800749:	5f                   	pop    %edi
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	83 ec 24             	sub    $0x24,%esp
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	89 1c 24             	mov    %ebx,(%esp)
  800760:	e8 49 fd ff ff       	call   8004ae <fd_lookup>
  800765:	85 c0                	test   %eax,%eax
  800767:	78 6f                	js     8007d8 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	8b 00                	mov    (%eax),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 87 fd ff ff       	call   800504 <dev_lookup>
  80077d:	85 c0                	test   %eax,%eax
  80077f:	78 57                	js     8007d8 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800784:	8b 50 08             	mov    0x8(%eax),%edx
  800787:	83 e2 03             	and    $0x3,%edx
  80078a:	83 fa 01             	cmp    $0x1,%edx
  80078d:	75 25                	jne    8007b4 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80078f:	a1 04 40 80 00       	mov    0x804004,%eax
  800794:	8b 00                	mov    (%eax),%eax
  800796:	8b 40 48             	mov    0x48(%eax),%eax
  800799:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80079d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a1:	c7 04 24 d9 20 80 00 	movl   $0x8020d9,(%esp)
  8007a8:	e8 8b 0b 00 00       	call   801338 <cprintf>
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b2:	eb 24                	jmp    8007d8 <read+0x8c>
	}
	if (!dev->dev_read)
  8007b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b7:	8b 52 08             	mov    0x8(%edx),%edx
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	74 15                	je     8007d3 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007cc:	89 04 24             	mov    %eax,(%esp)
  8007cf:	ff d2                	call   *%edx
  8007d1:	eb 05                	jmp    8007d8 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007d8:	83 c4 24             	add    $0x24,%esp
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	57                   	push   %edi
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	83 ec 1c             	sub    $0x1c,%esp
  8007e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007f2:	eb 23                	jmp    800817 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	29 d8                	sub    %ebx,%eax
  8007f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ff:	01 d8                	add    %ebx,%eax
  800801:	89 44 24 04          	mov    %eax,0x4(%esp)
  800805:	89 3c 24             	mov    %edi,(%esp)
  800808:	e8 3f ff ff ff       	call   80074c <read>
		if (m < 0)
  80080d:	85 c0                	test   %eax,%eax
  80080f:	78 10                	js     800821 <readn+0x43>
			return m;
		if (m == 0)
  800811:	85 c0                	test   %eax,%eax
  800813:	74 0a                	je     80081f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800815:	01 c3                	add    %eax,%ebx
  800817:	39 f3                	cmp    %esi,%ebx
  800819:	72 d9                	jb     8007f4 <readn+0x16>
  80081b:	89 d8                	mov    %ebx,%eax
  80081d:	eb 02                	jmp    800821 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80081f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800821:	83 c4 1c             	add    $0x1c,%esp
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5f                   	pop    %edi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	83 ec 24             	sub    $0x24,%esp
  800830:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800833:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083a:	89 1c 24             	mov    %ebx,(%esp)
  80083d:	e8 6c fc ff ff       	call   8004ae <fd_lookup>
  800842:	85 c0                	test   %eax,%eax
  800844:	78 6a                	js     8008b0 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800850:	8b 00                	mov    (%eax),%eax
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	e8 aa fc ff ff       	call   800504 <dev_lookup>
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 52                	js     8008b0 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80085e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800861:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800865:	75 25                	jne    80088c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800867:	a1 04 40 80 00       	mov    0x804004,%eax
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	8b 40 48             	mov    0x48(%eax),%eax
  800871:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800875:	89 44 24 04          	mov    %eax,0x4(%esp)
  800879:	c7 04 24 f5 20 80 00 	movl   $0x8020f5,(%esp)
  800880:	e8 b3 0a 00 00       	call   801338 <cprintf>
		return -E_INVAL;
  800885:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088a:	eb 24                	jmp    8008b0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80088c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80088f:	8b 52 0c             	mov    0xc(%edx),%edx
  800892:	85 d2                	test   %edx,%edx
  800894:	74 15                	je     8008ab <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800899:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	ff d2                	call   *%edx
  8008a9:	eb 05                	jmp    8008b0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008b0:	83 c4 24             	add    $0x24,%esp
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008bc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	e8 e0 fb ff ff       	call   8004ae <fd_lookup>
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 0e                	js     8008e0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	83 ec 24             	sub    $0x24,%esp
  8008e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f3:	89 1c 24             	mov    %ebx,(%esp)
  8008f6:	e8 b3 fb ff ff       	call   8004ae <fd_lookup>
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 63                	js     800962 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800902:	89 44 24 04          	mov    %eax,0x4(%esp)
  800906:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800909:	8b 00                	mov    (%eax),%eax
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	e8 f1 fb ff ff       	call   800504 <dev_lookup>
  800913:	85 c0                	test   %eax,%eax
  800915:	78 4b                	js     800962 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80091e:	75 25                	jne    800945 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800920:	a1 04 40 80 00       	mov    0x804004,%eax
  800925:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800927:	8b 40 48             	mov    0x48(%eax),%eax
  80092a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	c7 04 24 b8 20 80 00 	movl   $0x8020b8,(%esp)
  800939:	e8 fa 09 00 00       	call   801338 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80093e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800943:	eb 1d                	jmp    800962 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800945:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800948:	8b 52 18             	mov    0x18(%edx),%edx
  80094b:	85 d2                	test   %edx,%edx
  80094d:	74 0e                	je     80095d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800952:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	ff d2                	call   *%edx
  80095b:	eb 05                	jmp    800962 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80095d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800962:	83 c4 24             	add    $0x24,%esp
  800965:	5b                   	pop    %ebx
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	83 ec 24             	sub    $0x24,%esp
  80096f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800972:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800975:	89 44 24 04          	mov    %eax,0x4(%esp)
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	89 04 24             	mov    %eax,(%esp)
  80097f:	e8 2a fb ff ff       	call   8004ae <fd_lookup>
  800984:	85 c0                	test   %eax,%eax
  800986:	78 52                	js     8009da <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800988:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80098b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800992:	8b 00                	mov    (%eax),%eax
  800994:	89 04 24             	mov    %eax,(%esp)
  800997:	e8 68 fb ff ff       	call   800504 <dev_lookup>
  80099c:	85 c0                	test   %eax,%eax
  80099e:	78 3a                	js     8009da <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009a7:	74 2c                	je     8009d5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009b3:	00 00 00 
	stat->st_isdir = 0;
  8009b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009bd:	00 00 00 
	stat->st_dev = dev;
  8009c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009cd:	89 14 24             	mov    %edx,(%esp)
  8009d0:	ff 50 14             	call   *0x14(%eax)
  8009d3:	eb 05                	jmp    8009da <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009da:	83 c4 24             	add    $0x24,%esp
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009ef:	00 
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 88 02 00 00       	call   800c83 <open>
  8009fb:	89 c3                	mov    %eax,%ebx
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	78 1b                	js     800a1c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	89 1c 24             	mov    %ebx,(%esp)
  800a0b:	e8 58 ff ff ff       	call   800968 <fstat>
  800a10:	89 c6                	mov    %eax,%esi
	close(fd);
  800a12:	89 1c 24             	mov    %ebx,(%esp)
  800a15:	e8 ce fb ff ff       	call   8005e8 <close>
	return r;
  800a1a:	89 f3                	mov    %esi,%ebx
}
  800a1c:	89 d8                	mov    %ebx,%eax
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    
  800a25:	00 00                	add    %al,(%eax)
	...

00800a28 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	83 ec 10             	sub    $0x10,%esp
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a34:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a3b:	75 11                	jne    800a4e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a44:	e8 22 13 00 00       	call   801d6b <ipc_find_env>
  800a49:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a4e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a55:	00 
  800a56:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a5d:	00 
  800a5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a62:	a1 00 40 80 00       	mov    0x804000,%eax
  800a67:	89 04 24             	mov    %eax,(%esp)
  800a6a:	e8 96 12 00 00       	call   801d05 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a76:	00 
  800a77:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a82:	e8 11 12 00 00       	call   801c98 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a87:	83 c4 10             	add    $0x10,%esp
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab1:	e8 72 ff ff ff       	call   800a28 <fsipc>
}
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ace:	b8 06 00 00 00       	mov    $0x6,%eax
  800ad3:	e8 50 ff ff ff       	call   800a28 <fsipc>
}
  800ad8:	c9                   	leave  
  800ad9:	c3                   	ret    

00800ada <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	83 ec 14             	sub    $0x14,%esp
  800ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aef:	ba 00 00 00 00       	mov    $0x0,%edx
  800af4:	b8 05 00 00 00       	mov    $0x5,%eax
  800af9:	e8 2a ff ff ff       	call   800a28 <fsipc>
  800afe:	85 c0                	test   %eax,%eax
  800b00:	78 2b                	js     800b2d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b02:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b09:	00 
  800b0a:	89 1c 24             	mov    %ebx,(%esp)
  800b0d:	e8 d1 0d 00 00       	call   8018e3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b12:	a1 80 50 80 00       	mov    0x805080,%eax
  800b17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b1d:	a1 84 50 80 00       	mov    0x805084,%eax
  800b22:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2d:	83 c4 14             	add    $0x14,%esp
  800b30:	5b                   	pop    %ebx
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	53                   	push   %ebx
  800b37:	83 ec 14             	sub    $0x14,%esp
  800b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	8b 40 0c             	mov    0xc(%eax),%eax
  800b43:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b48:	89 d8                	mov    %ebx,%eax
  800b4a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b50:	76 05                	jbe    800b57 <devfile_write+0x24>
  800b52:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b57:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b67:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b6e:	e8 53 0f 00 00       	call   801ac6 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7d:	e8 a6 fe ff ff       	call   800a28 <fsipc>
  800b82:	85 c0                	test   %eax,%eax
  800b84:	78 53                	js     800bd9 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b86:	39 c3                	cmp    %eax,%ebx
  800b88:	73 24                	jae    800bae <devfile_write+0x7b>
  800b8a:	c7 44 24 0c 24 21 80 	movl   $0x802124,0xc(%esp)
  800b91:	00 
  800b92:	c7 44 24 08 2b 21 80 	movl   $0x80212b,0x8(%esp)
  800b99:	00 
  800b9a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800ba1:	00 
  800ba2:	c7 04 24 40 21 80 00 	movl   $0x802140,(%esp)
  800ba9:	e8 92 06 00 00       	call   801240 <_panic>
	assert(r <= PGSIZE);
  800bae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bb3:	7e 24                	jle    800bd9 <devfile_write+0xa6>
  800bb5:	c7 44 24 0c 4b 21 80 	movl   $0x80214b,0xc(%esp)
  800bbc:	00 
  800bbd:	c7 44 24 08 2b 21 80 	movl   $0x80212b,0x8(%esp)
  800bc4:	00 
  800bc5:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800bcc:	00 
  800bcd:	c7 04 24 40 21 80 00 	movl   $0x802140,(%esp)
  800bd4:	e8 67 06 00 00       	call   801240 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800bd9:	83 c4 14             	add    $0x14,%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 10             	sub    $0x10,%esp
  800be7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
  800bed:	8b 40 0c             	mov    0xc(%eax),%eax
  800bf0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bf5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 03 00 00 00       	mov    $0x3,%eax
  800c05:	e8 1e fe ff ff       	call   800a28 <fsipc>
  800c0a:	89 c3                	mov    %eax,%ebx
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	78 6a                	js     800c7a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c10:	39 c6                	cmp    %eax,%esi
  800c12:	73 24                	jae    800c38 <devfile_read+0x59>
  800c14:	c7 44 24 0c 24 21 80 	movl   $0x802124,0xc(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 08 2b 21 80 	movl   $0x80212b,0x8(%esp)
  800c23:	00 
  800c24:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800c2b:	00 
  800c2c:	c7 04 24 40 21 80 00 	movl   $0x802140,(%esp)
  800c33:	e8 08 06 00 00       	call   801240 <_panic>
	assert(r <= PGSIZE);
  800c38:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c3d:	7e 24                	jle    800c63 <devfile_read+0x84>
  800c3f:	c7 44 24 0c 4b 21 80 	movl   $0x80214b,0xc(%esp)
  800c46:	00 
  800c47:	c7 44 24 08 2b 21 80 	movl   $0x80212b,0x8(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c56:	00 
  800c57:	c7 04 24 40 21 80 00 	movl   $0x802140,(%esp)
  800c5e:	e8 dd 05 00 00       	call   801240 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c67:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c6e:	00 
  800c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c72:	89 04 24             	mov    %eax,(%esp)
  800c75:	e8 e2 0d 00 00       	call   801a5c <memmove>
	return r;
}
  800c7a:	89 d8                	mov    %ebx,%eax
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 20             	sub    $0x20,%esp
  800c8b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c8e:	89 34 24             	mov    %esi,(%esp)
  800c91:	e8 1a 0c 00 00       	call   8018b0 <strlen>
  800c96:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c9b:	7f 60                	jg     800cfd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca0:	89 04 24             	mov    %eax,(%esp)
  800ca3:	e8 b3 f7 ff ff       	call   80045b <fd_alloc>
  800ca8:	89 c3                	mov    %eax,%ebx
  800caa:	85 c0                	test   %eax,%eax
  800cac:	78 54                	js     800d02 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800cae:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb2:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cb9:	e8 25 0c 00 00       	call   8018e3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cce:	e8 55 fd ff ff       	call   800a28 <fsipc>
  800cd3:	89 c3                	mov    %eax,%ebx
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	79 15                	jns    800cee <open+0x6b>
		fd_close(fd, 0);
  800cd9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ce0:	00 
  800ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce4:	89 04 24             	mov    %eax,(%esp)
  800ce7:	e8 74 f8 ff ff       	call   800560 <fd_close>
		return r;
  800cec:	eb 14                	jmp    800d02 <open+0x7f>
	}

	return fd2num(fd);
  800cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 37 f7 ff ff       	call   800430 <fd2num>
  800cf9:	89 c3                	mov    %eax,%ebx
  800cfb:	eb 05                	jmp    800d02 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cfd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800d02:	89 d8                	mov    %ebx,%eax
  800d04:	83 c4 20             	add    $0x20,%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1b:	e8 08 fd ff ff       	call   800a28 <fsipc>
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    
	...

00800d24 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 10             	sub    $0x10,%esp
  800d2c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	89 04 24             	mov    %eax,(%esp)
  800d35:	e8 06 f7 ff ff       	call   800440 <fd2data>
  800d3a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d3c:	c7 44 24 04 57 21 80 	movl   $0x802157,0x4(%esp)
  800d43:	00 
  800d44:	89 34 24             	mov    %esi,(%esp)
  800d47:	e8 97 0b 00 00       	call   8018e3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d4c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d4f:	2b 03                	sub    (%ebx),%eax
  800d51:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d57:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d5e:	00 00 00 
	stat->st_dev = &devpipe;
  800d61:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d68:	30 80 00 
	return 0;
}
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 14             	sub    $0x14,%esp
  800d7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d8c:	e8 b3 f4 ff ff       	call   800244 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d91:	89 1c 24             	mov    %ebx,(%esp)
  800d94:	e8 a7 f6 ff ff       	call   800440 <fd2data>
  800d99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800da4:	e8 9b f4 ff ff       	call   800244 <sys_page_unmap>
}
  800da9:	83 c4 14             	add    $0x14,%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 2c             	sub    $0x2c,%esp
  800db8:	89 c7                	mov    %eax,%edi
  800dba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800dbd:	a1 04 40 80 00       	mov    0x804004,%eax
  800dc2:	8b 00                	mov    (%eax),%eax
  800dc4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800dc7:	89 3c 24             	mov    %edi,(%esp)
  800dca:	e8 e1 0f 00 00       	call   801db0 <pageref>
  800dcf:	89 c6                	mov    %eax,%esi
  800dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd4:	89 04 24             	mov    %eax,(%esp)
  800dd7:	e8 d4 0f 00 00       	call   801db0 <pageref>
  800ddc:	39 c6                	cmp    %eax,%esi
  800dde:	0f 94 c0             	sete   %al
  800de1:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800de4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800dea:	8b 12                	mov    (%edx),%edx
  800dec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800def:	39 cb                	cmp    %ecx,%ebx
  800df1:	75 08                	jne    800dfb <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800df3:	83 c4 2c             	add    $0x2c,%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800dfb:	83 f8 01             	cmp    $0x1,%eax
  800dfe:	75 bd                	jne    800dbd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800e00:	8b 42 58             	mov    0x58(%edx),%eax
  800e03:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800e0a:	00 
  800e0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e13:	c7 04 24 5e 21 80 00 	movl   $0x80215e,(%esp)
  800e1a:	e8 19 05 00 00       	call   801338 <cprintf>
  800e1f:	eb 9c                	jmp    800dbd <_pipeisclosed+0xe>

00800e21 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 1c             	sub    $0x1c,%esp
  800e2a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800e2d:	89 34 24             	mov    %esi,(%esp)
  800e30:	e8 0b f6 ff ff       	call   800440 <fd2data>
  800e35:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e37:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3c:	eb 3c                	jmp    800e7a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e3e:	89 da                	mov    %ebx,%edx
  800e40:	89 f0                	mov    %esi,%eax
  800e42:	e8 68 ff ff ff       	call   800daf <_pipeisclosed>
  800e47:	85 c0                	test   %eax,%eax
  800e49:	75 38                	jne    800e83 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e4b:	e8 2e f3 ff ff       	call   80017e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e50:	8b 43 04             	mov    0x4(%ebx),%eax
  800e53:	8b 13                	mov    (%ebx),%edx
  800e55:	83 c2 20             	add    $0x20,%edx
  800e58:	39 d0                	cmp    %edx,%eax
  800e5a:	73 e2                	jae    800e3e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e6a:	79 05                	jns    800e71 <devpipe_write+0x50>
  800e6c:	4a                   	dec    %edx
  800e6d:	83 ca e0             	or     $0xffffffe0,%edx
  800e70:	42                   	inc    %edx
  800e71:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e75:	40                   	inc    %eax
  800e76:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e79:	47                   	inc    %edi
  800e7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e7d:	75 d1                	jne    800e50 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e7f:	89 f8                	mov    %edi,%eax
  800e81:	eb 05                	jmp    800e88 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e88:	83 c4 1c             	add    $0x1c,%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	83 ec 1c             	sub    $0x1c,%esp
  800e99:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e9c:	89 3c 24             	mov    %edi,(%esp)
  800e9f:	e8 9c f5 ff ff       	call   800440 <fd2data>
  800ea4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ea6:	be 00 00 00 00       	mov    $0x0,%esi
  800eab:	eb 3a                	jmp    800ee7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ead:	85 f6                	test   %esi,%esi
  800eaf:	74 04                	je     800eb5 <devpipe_read+0x25>
				return i;
  800eb1:	89 f0                	mov    %esi,%eax
  800eb3:	eb 40                	jmp    800ef5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800eb5:	89 da                	mov    %ebx,%edx
  800eb7:	89 f8                	mov    %edi,%eax
  800eb9:	e8 f1 fe ff ff       	call   800daf <_pipeisclosed>
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	75 2e                	jne    800ef0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ec2:	e8 b7 f2 ff ff       	call   80017e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ec7:	8b 03                	mov    (%ebx),%eax
  800ec9:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ecc:	74 df                	je     800ead <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ece:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ed3:	79 05                	jns    800eda <devpipe_read+0x4a>
  800ed5:	48                   	dec    %eax
  800ed6:	83 c8 e0             	or     $0xffffffe0,%eax
  800ed9:	40                   	inc    %eax
  800eda:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ede:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800ee4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ee6:	46                   	inc    %esi
  800ee7:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eea:	75 db                	jne    800ec7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800eec:	89 f0                	mov    %esi,%eax
  800eee:	eb 05                	jmp    800ef5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ef5:	83 c4 1c             	add    $0x1c,%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	83 ec 3c             	sub    $0x3c,%esp
  800f06:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800f09:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f0c:	89 04 24             	mov    %eax,(%esp)
  800f0f:	e8 47 f5 ff ff       	call   80045b <fd_alloc>
  800f14:	89 c3                	mov    %eax,%ebx
  800f16:	85 c0                	test   %eax,%eax
  800f18:	0f 88 45 01 00 00    	js     801063 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f1e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f25:	00 
  800f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f34:	e8 64 f2 ff ff       	call   80019d <sys_page_alloc>
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	0f 88 20 01 00 00    	js     801063 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800f43:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f46:	89 04 24             	mov    %eax,(%esp)
  800f49:	e8 0d f5 ff ff       	call   80045b <fd_alloc>
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	85 c0                	test   %eax,%eax
  800f52:	0f 88 f8 00 00 00    	js     801050 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f58:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f5f:	00 
  800f60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6e:	e8 2a f2 ff ff       	call   80019d <sys_page_alloc>
  800f73:	89 c3                	mov    %eax,%ebx
  800f75:	85 c0                	test   %eax,%eax
  800f77:	0f 88 d3 00 00 00    	js     801050 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f80:	89 04 24             	mov    %eax,(%esp)
  800f83:	e8 b8 f4 ff ff       	call   800440 <fd2data>
  800f88:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f8a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f91:	00 
  800f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9d:	e8 fb f1 ff ff       	call   80019d <sys_page_alloc>
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	0f 88 91 00 00 00    	js     80103d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800faf:	89 04 24             	mov    %eax,(%esp)
  800fb2:	e8 89 f4 ff ff       	call   800440 <fd2data>
  800fb7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800fbe:	00 
  800fbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fca:	00 
  800fcb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd6:	e8 16 f2 ff ff       	call   8001f1 <sys_page_map>
  800fdb:	89 c3                	mov    %eax,%ebx
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 4c                	js     80102d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800fe1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fe7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fea:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800ff6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ffc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fff:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801001:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801004:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80100b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80100e:	89 04 24             	mov    %eax,(%esp)
  801011:	e8 1a f4 ff ff       	call   800430 <fd2num>
  801016:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801018:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80101b:	89 04 24             	mov    %eax,(%esp)
  80101e:	e8 0d f4 ff ff       	call   800430 <fd2num>
  801023:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801026:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102b:	eb 36                	jmp    801063 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80102d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801031:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801038:	e8 07 f2 ff ff       	call   800244 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80103d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801040:	89 44 24 04          	mov    %eax,0x4(%esp)
  801044:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104b:	e8 f4 f1 ff ff       	call   800244 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801053:	89 44 24 04          	mov    %eax,0x4(%esp)
  801057:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80105e:	e8 e1 f1 ff ff       	call   800244 <sys_page_unmap>
    err:
	return r;
}
  801063:	89 d8                	mov    %ebx,%eax
  801065:	83 c4 3c             	add    $0x3c,%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801076:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 29 f4 ff ff       	call   8004ae <fd_lookup>
  801085:	85 c0                	test   %eax,%eax
  801087:	78 15                	js     80109e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108c:	89 04 24             	mov    %eax,(%esp)
  80108f:	e8 ac f3 ff ff       	call   800440 <fd2data>
	return _pipeisclosed(fd, p);
  801094:	89 c2                	mov    %eax,%edx
  801096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801099:	e8 11 fd ff ff       	call   800daf <_pipeisclosed>
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8010a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8010b0:	c7 44 24 04 76 21 80 	movl   $0x802176,0x4(%esp)
  8010b7:	00 
  8010b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bb:	89 04 24             	mov    %eax,(%esp)
  8010be:	e8 20 08 00 00       	call   8018e3 <strcpy>
	return 0;
}
  8010c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8010db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010e1:	eb 30                	jmp    801113 <devcons_write+0x49>
		m = n - tot;
  8010e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8010e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010e8:	83 fe 7f             	cmp    $0x7f,%esi
  8010eb:	76 05                	jbe    8010f2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010ed:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010f2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010f6:	03 45 0c             	add    0xc(%ebp),%eax
  8010f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fd:	89 3c 24             	mov    %edi,(%esp)
  801100:	e8 57 09 00 00       	call   801a5c <memmove>
		sys_cputs(buf, m);
  801105:	89 74 24 04          	mov    %esi,0x4(%esp)
  801109:	89 3c 24             	mov    %edi,(%esp)
  80110c:	e8 bf ef ff ff       	call   8000d0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801111:	01 f3                	add    %esi,%ebx
  801113:	89 d8                	mov    %ebx,%eax
  801115:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801118:	72 c9                	jb     8010e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80111a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80112b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80112f:	75 07                	jne    801138 <devcons_read+0x13>
  801131:	eb 25                	jmp    801158 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801133:	e8 46 f0 ff ff       	call   80017e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801138:	e8 b1 ef ff ff       	call   8000ee <sys_cgetc>
  80113d:	85 c0                	test   %eax,%eax
  80113f:	74 f2                	je     801133 <devcons_read+0xe>
  801141:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801143:	85 c0                	test   %eax,%eax
  801145:	78 1d                	js     801164 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801147:	83 f8 04             	cmp    $0x4,%eax
  80114a:	74 13                	je     80115f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80114c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114f:	88 10                	mov    %dl,(%eax)
	return 1;
  801151:	b8 01 00 00 00       	mov    $0x1,%eax
  801156:	eb 0c                	jmp    801164 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801158:	b8 00 00 00 00       	mov    $0x0,%eax
  80115d:	eb 05                	jmp    801164 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80116c:	8b 45 08             	mov    0x8(%ebp),%eax
  80116f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801172:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801179:	00 
  80117a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80117d:	89 04 24             	mov    %eax,(%esp)
  801180:	e8 4b ef ff ff       	call   8000d0 <sys_cputs>
}
  801185:	c9                   	leave  
  801186:	c3                   	ret    

00801187 <getchar>:

int
getchar(void)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80118d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801194:	00 
  801195:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a3:	e8 a4 f5 ff ff       	call   80074c <read>
	if (r < 0)
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 0f                	js     8011bb <getchar+0x34>
		return r;
	if (r < 1)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	7e 06                	jle    8011b6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8011b0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8011b4:	eb 05                	jmp    8011bb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8011b6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	89 04 24             	mov    %eax,(%esp)
  8011d0:	e8 d9 f2 ff ff       	call   8004ae <fd_lookup>
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 11                	js     8011ea <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8011d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011dc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011e2:	39 10                	cmp    %edx,(%eax)
  8011e4:	0f 94 c0             	sete   %al
  8011e7:	0f b6 c0             	movzbl %al,%eax
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <opencons>:

int
opencons(void)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 5e f2 ff ff       	call   80045b <fd_alloc>
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 3c                	js     80123d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801201:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801208:	00 
  801209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801210:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801217:	e8 81 ef ff ff       	call   80019d <sys_page_alloc>
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 1d                	js     80123d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801220:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801226:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801229:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80122b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801235:	89 04 24             	mov    %eax,(%esp)
  801238:	e8 f3 f1 ff ff       	call   800430 <fd2num>
}
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    
	...

00801240 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
  801245:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801248:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80124b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801251:	e8 09 ef ff ff       	call   80015f <sys_getenvid>
  801256:	8b 55 0c             	mov    0xc(%ebp),%edx
  801259:	89 54 24 10          	mov    %edx,0x10(%esp)
  80125d:	8b 55 08             	mov    0x8(%ebp),%edx
  801260:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801264:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	c7 04 24 84 21 80 00 	movl   $0x802184,(%esp)
  801273:	e8 c0 00 00 00       	call   801338 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801278:	89 74 24 04          	mov    %esi,0x4(%esp)
  80127c:	8b 45 10             	mov    0x10(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 50 00 00 00       	call   8012d7 <vcprintf>
	cprintf("\n");
  801287:	c7 04 24 1a 25 80 00 	movl   $0x80251a,(%esp)
  80128e:	e8 a5 00 00 00       	call   801338 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801293:	cc                   	int3   
  801294:	eb fd                	jmp    801293 <_panic+0x53>
	...

00801298 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 14             	sub    $0x14,%esp
  80129f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8012a2:	8b 03                	mov    (%ebx),%eax
  8012a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8012ab:	40                   	inc    %eax
  8012ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8012ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8012b3:	75 19                	jne    8012ce <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8012b5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8012bc:	00 
  8012bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8012c0:	89 04 24             	mov    %eax,(%esp)
  8012c3:	e8 08 ee ff ff       	call   8000d0 <sys_cputs>
		b->idx = 0;
  8012c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8012ce:	ff 43 04             	incl   0x4(%ebx)
}
  8012d1:	83 c4 14             	add    $0x14,%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8012e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012e7:	00 00 00 
	b.cnt = 0;
  8012ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801302:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130c:	c7 04 24 98 12 80 00 	movl   $0x801298,(%esp)
  801313:	e8 82 01 00 00       	call   80149a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801318:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80131e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801322:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801328:	89 04 24             	mov    %eax,(%esp)
  80132b:	e8 a0 ed ff ff       	call   8000d0 <sys_cputs>

	return b.cnt;
}
  801330:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80133e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	e8 87 ff ff ff       	call   8012d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  801350:	c9                   	leave  
  801351:	c3                   	ret    
	...

00801354 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	57                   	push   %edi
  801358:	56                   	push   %esi
  801359:	53                   	push   %ebx
  80135a:	83 ec 3c             	sub    $0x3c,%esp
  80135d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801360:	89 d7                	mov    %edx,%edi
  801362:	8b 45 08             	mov    0x8(%ebp),%eax
  801365:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801368:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801371:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801374:	85 c0                	test   %eax,%eax
  801376:	75 08                	jne    801380 <printnum+0x2c>
  801378:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80137b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80137e:	77 57                	ja     8013d7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801380:	89 74 24 10          	mov    %esi,0x10(%esp)
  801384:	4b                   	dec    %ebx
  801385:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801389:	8b 45 10             	mov    0x10(%ebp),%eax
  80138c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801390:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801394:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801398:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80139f:	00 
  8013a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013a3:	89 04 24             	mov    %eax,(%esp)
  8013a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ad:	e8 42 0a 00 00       	call   801df4 <__udivdi3>
  8013b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013c1:	89 fa                	mov    %edi,%edx
  8013c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c6:	e8 89 ff ff ff       	call   801354 <printnum>
  8013cb:	eb 0f                	jmp    8013dc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8013cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d1:	89 34 24             	mov    %esi,(%esp)
  8013d4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8013d7:	4b                   	dec    %ebx
  8013d8:	85 db                	test   %ebx,%ebx
  8013da:	7f f1                	jg     8013cd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8013dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013f2:	00 
  8013f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801400:	e8 0f 0b 00 00       	call   801f14 <__umoddi3>
  801405:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801409:	0f be 80 a7 21 80 00 	movsbl 0x8021a7(%eax),%eax
  801410:	89 04 24             	mov    %eax,(%esp)
  801413:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801416:	83 c4 3c             	add    $0x3c,%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5f                   	pop    %edi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801421:	83 fa 01             	cmp    $0x1,%edx
  801424:	7e 0e                	jle    801434 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801426:	8b 10                	mov    (%eax),%edx
  801428:	8d 4a 08             	lea    0x8(%edx),%ecx
  80142b:	89 08                	mov    %ecx,(%eax)
  80142d:	8b 02                	mov    (%edx),%eax
  80142f:	8b 52 04             	mov    0x4(%edx),%edx
  801432:	eb 22                	jmp    801456 <getuint+0x38>
	else if (lflag)
  801434:	85 d2                	test   %edx,%edx
  801436:	74 10                	je     801448 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801438:	8b 10                	mov    (%eax),%edx
  80143a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80143d:	89 08                	mov    %ecx,(%eax)
  80143f:	8b 02                	mov    (%edx),%eax
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	eb 0e                	jmp    801456 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801448:	8b 10                	mov    (%eax),%edx
  80144a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80144d:	89 08                	mov    %ecx,(%eax)
  80144f:	8b 02                	mov    (%edx),%eax
  801451:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80145e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801461:	8b 10                	mov    (%eax),%edx
  801463:	3b 50 04             	cmp    0x4(%eax),%edx
  801466:	73 08                	jae    801470 <sprintputch+0x18>
		*b->buf++ = ch;
  801468:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146b:	88 0a                	mov    %cl,(%edx)
  80146d:	42                   	inc    %edx
  80146e:	89 10                	mov    %edx,(%eax)
}
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801478:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80147b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147f:	8b 45 10             	mov    0x10(%ebp),%eax
  801482:	89 44 24 08          	mov    %eax,0x8(%esp)
  801486:	8b 45 0c             	mov    0xc(%ebp),%eax
  801489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	89 04 24             	mov    %eax,(%esp)
  801493:	e8 02 00 00 00       	call   80149a <vprintfmt>
	va_end(ap);
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	57                   	push   %edi
  80149e:	56                   	push   %esi
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 4c             	sub    $0x4c,%esp
  8014a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a6:	8b 75 10             	mov    0x10(%ebp),%esi
  8014a9:	eb 12                	jmp    8014bd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	0f 84 6b 03 00 00    	je     80181e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8014b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014b7:	89 04 24             	mov    %eax,(%esp)
  8014ba:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8014bd:	0f b6 06             	movzbl (%esi),%eax
  8014c0:	46                   	inc    %esi
  8014c1:	83 f8 25             	cmp    $0x25,%eax
  8014c4:	75 e5                	jne    8014ab <vprintfmt+0x11>
  8014c6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8014ca:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8014d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8014d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8014dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014e2:	eb 26                	jmp    80150a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8014e7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014eb:	eb 1d                	jmp    80150a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014f0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014f4:	eb 14                	jmp    80150a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801500:	eb 08                	jmp    80150a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801502:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801505:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150a:	0f b6 06             	movzbl (%esi),%eax
  80150d:	8d 56 01             	lea    0x1(%esi),%edx
  801510:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801513:	8a 16                	mov    (%esi),%dl
  801515:	83 ea 23             	sub    $0x23,%edx
  801518:	80 fa 55             	cmp    $0x55,%dl
  80151b:	0f 87 e1 02 00 00    	ja     801802 <vprintfmt+0x368>
  801521:	0f b6 d2             	movzbl %dl,%edx
  801524:	ff 24 95 e0 22 80 00 	jmp    *0x8022e0(,%edx,4)
  80152b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80152e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801533:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801536:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80153a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80153d:	8d 50 d0             	lea    -0x30(%eax),%edx
  801540:	83 fa 09             	cmp    $0x9,%edx
  801543:	77 2a                	ja     80156f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801545:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801546:	eb eb                	jmp    801533 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801548:	8b 45 14             	mov    0x14(%ebp),%eax
  80154b:	8d 50 04             	lea    0x4(%eax),%edx
  80154e:	89 55 14             	mov    %edx,0x14(%ebp)
  801551:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801553:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801556:	eb 17                	jmp    80156f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801558:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80155c:	78 98                	js     8014f6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80155e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801561:	eb a7                	jmp    80150a <vprintfmt+0x70>
  801563:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801566:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80156d:	eb 9b                	jmp    80150a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80156f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801573:	79 95                	jns    80150a <vprintfmt+0x70>
  801575:	eb 8b                	jmp    801502 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801577:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801578:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80157b:	eb 8d                	jmp    80150a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80157d:	8b 45 14             	mov    0x14(%ebp),%eax
  801580:	8d 50 04             	lea    0x4(%eax),%edx
  801583:	89 55 14             	mov    %edx,0x14(%ebp)
  801586:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80158a:	8b 00                	mov    (%eax),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801592:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801595:	e9 23 ff ff ff       	jmp    8014bd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80159a:	8b 45 14             	mov    0x14(%ebp),%eax
  80159d:	8d 50 04             	lea    0x4(%eax),%edx
  8015a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8015a3:	8b 00                	mov    (%eax),%eax
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	79 02                	jns    8015ab <vprintfmt+0x111>
  8015a9:	f7 d8                	neg    %eax
  8015ab:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8015ad:	83 f8 0f             	cmp    $0xf,%eax
  8015b0:	7f 0b                	jg     8015bd <vprintfmt+0x123>
  8015b2:	8b 04 85 40 24 80 00 	mov    0x802440(,%eax,4),%eax
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	75 23                	jne    8015e0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8015bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015c1:	c7 44 24 08 bf 21 80 	movl   $0x8021bf,0x8(%esp)
  8015c8:	00 
  8015c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d0:	89 04 24             	mov    %eax,(%esp)
  8015d3:	e8 9a fe ff ff       	call   801472 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8015db:	e9 dd fe ff ff       	jmp    8014bd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8015e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e4:	c7 44 24 08 3d 21 80 	movl   $0x80213d,0x8(%esp)
  8015eb:	00 
  8015ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f3:	89 14 24             	mov    %edx,(%esp)
  8015f6:	e8 77 fe ff ff       	call   801472 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015fe:	e9 ba fe ff ff       	jmp    8014bd <vprintfmt+0x23>
  801603:	89 f9                	mov    %edi,%ecx
  801605:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801608:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80160b:	8b 45 14             	mov    0x14(%ebp),%eax
  80160e:	8d 50 04             	lea    0x4(%eax),%edx
  801611:	89 55 14             	mov    %edx,0x14(%ebp)
  801614:	8b 30                	mov    (%eax),%esi
  801616:	85 f6                	test   %esi,%esi
  801618:	75 05                	jne    80161f <vprintfmt+0x185>
				p = "(null)";
  80161a:	be b8 21 80 00       	mov    $0x8021b8,%esi
			if (width > 0 && padc != '-')
  80161f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801623:	0f 8e 84 00 00 00    	jle    8016ad <vprintfmt+0x213>
  801629:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80162d:	74 7e                	je     8016ad <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80162f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801633:	89 34 24             	mov    %esi,(%esp)
  801636:	e8 8b 02 00 00       	call   8018c6 <strnlen>
  80163b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80163e:	29 c2                	sub    %eax,%edx
  801640:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801643:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801647:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80164a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80164d:	89 de                	mov    %ebx,%esi
  80164f:	89 d3                	mov    %edx,%ebx
  801651:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801653:	eb 0b                	jmp    801660 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801655:	89 74 24 04          	mov    %esi,0x4(%esp)
  801659:	89 3c 24             	mov    %edi,(%esp)
  80165c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80165f:	4b                   	dec    %ebx
  801660:	85 db                	test   %ebx,%ebx
  801662:	7f f1                	jg     801655 <vprintfmt+0x1bb>
  801664:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801667:	89 f3                	mov    %esi,%ebx
  801669:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80166c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80166f:	85 c0                	test   %eax,%eax
  801671:	79 05                	jns    801678 <vprintfmt+0x1de>
  801673:	b8 00 00 00 00       	mov    $0x0,%eax
  801678:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80167b:	29 c2                	sub    %eax,%edx
  80167d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801680:	eb 2b                	jmp    8016ad <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801682:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801686:	74 18                	je     8016a0 <vprintfmt+0x206>
  801688:	8d 50 e0             	lea    -0x20(%eax),%edx
  80168b:	83 fa 5e             	cmp    $0x5e,%edx
  80168e:	76 10                	jbe    8016a0 <vprintfmt+0x206>
					putch('?', putdat);
  801690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801694:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80169b:	ff 55 08             	call   *0x8(%ebp)
  80169e:	eb 0a                	jmp    8016aa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8016a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8016aa:	ff 4d e4             	decl   -0x1c(%ebp)
  8016ad:	0f be 06             	movsbl (%esi),%eax
  8016b0:	46                   	inc    %esi
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	74 21                	je     8016d6 <vprintfmt+0x23c>
  8016b5:	85 ff                	test   %edi,%edi
  8016b7:	78 c9                	js     801682 <vprintfmt+0x1e8>
  8016b9:	4f                   	dec    %edi
  8016ba:	79 c6                	jns    801682 <vprintfmt+0x1e8>
  8016bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016bf:	89 de                	mov    %ebx,%esi
  8016c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016c4:	eb 18                	jmp    8016de <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8016c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8016d1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8016d3:	4b                   	dec    %ebx
  8016d4:	eb 08                	jmp    8016de <vprintfmt+0x244>
  8016d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d9:	89 de                	mov    %ebx,%esi
  8016db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016de:	85 db                	test   %ebx,%ebx
  8016e0:	7f e4                	jg     8016c6 <vprintfmt+0x22c>
  8016e2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8016e5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016ea:	e9 ce fd ff ff       	jmp    8014bd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016ef:	83 f9 01             	cmp    $0x1,%ecx
  8016f2:	7e 10                	jle    801704 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f7:	8d 50 08             	lea    0x8(%eax),%edx
  8016fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8016fd:	8b 30                	mov    (%eax),%esi
  8016ff:	8b 78 04             	mov    0x4(%eax),%edi
  801702:	eb 26                	jmp    80172a <vprintfmt+0x290>
	else if (lflag)
  801704:	85 c9                	test   %ecx,%ecx
  801706:	74 12                	je     80171a <vprintfmt+0x280>
		return va_arg(*ap, long);
  801708:	8b 45 14             	mov    0x14(%ebp),%eax
  80170b:	8d 50 04             	lea    0x4(%eax),%edx
  80170e:	89 55 14             	mov    %edx,0x14(%ebp)
  801711:	8b 30                	mov    (%eax),%esi
  801713:	89 f7                	mov    %esi,%edi
  801715:	c1 ff 1f             	sar    $0x1f,%edi
  801718:	eb 10                	jmp    80172a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80171a:	8b 45 14             	mov    0x14(%ebp),%eax
  80171d:	8d 50 04             	lea    0x4(%eax),%edx
  801720:	89 55 14             	mov    %edx,0x14(%ebp)
  801723:	8b 30                	mov    (%eax),%esi
  801725:	89 f7                	mov    %esi,%edi
  801727:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80172a:	85 ff                	test   %edi,%edi
  80172c:	78 0a                	js     801738 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80172e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801733:	e9 8c 00 00 00       	jmp    8017c4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801743:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801746:	f7 de                	neg    %esi
  801748:	83 d7 00             	adc    $0x0,%edi
  80174b:	f7 df                	neg    %edi
			}
			base = 10;
  80174d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801752:	eb 70                	jmp    8017c4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801754:	89 ca                	mov    %ecx,%edx
  801756:	8d 45 14             	lea    0x14(%ebp),%eax
  801759:	e8 c0 fc ff ff       	call   80141e <getuint>
  80175e:	89 c6                	mov    %eax,%esi
  801760:	89 d7                	mov    %edx,%edi
			base = 10;
  801762:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801767:	eb 5b                	jmp    8017c4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801769:	89 ca                	mov    %ecx,%edx
  80176b:	8d 45 14             	lea    0x14(%ebp),%eax
  80176e:	e8 ab fc ff ff       	call   80141e <getuint>
  801773:	89 c6                	mov    %eax,%esi
  801775:	89 d7                	mov    %edx,%edi
			base = 8;
  801777:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80177c:	eb 46                	jmp    8017c4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80177e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801782:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801789:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80178c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801790:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801797:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80179a:	8b 45 14             	mov    0x14(%ebp),%eax
  80179d:	8d 50 04             	lea    0x4(%eax),%edx
  8017a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8017a3:	8b 30                	mov    (%eax),%esi
  8017a5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8017aa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8017af:	eb 13                	jmp    8017c4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8017b1:	89 ca                	mov    %ecx,%edx
  8017b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8017b6:	e8 63 fc ff ff       	call   80141e <getuint>
  8017bb:	89 c6                	mov    %eax,%esi
  8017bd:	89 d7                	mov    %edx,%edi
			base = 16;
  8017bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8017c4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8017c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d7:	89 34 24             	mov    %esi,(%esp)
  8017da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017de:	89 da                	mov    %ebx,%edx
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	e8 6c fb ff ff       	call   801354 <printnum>
			break;
  8017e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017eb:	e9 cd fc ff ff       	jmp    8014bd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f4:	89 04 24             	mov    %eax,(%esp)
  8017f7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017fd:	e9 bb fc ff ff       	jmp    8014bd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801802:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801806:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80180d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801810:	eb 01                	jmp    801813 <vprintfmt+0x379>
  801812:	4e                   	dec    %esi
  801813:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801817:	75 f9                	jne    801812 <vprintfmt+0x378>
  801819:	e9 9f fc ff ff       	jmp    8014bd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80181e:	83 c4 4c             	add    $0x4c,%esp
  801821:	5b                   	pop    %ebx
  801822:	5e                   	pop    %esi
  801823:	5f                   	pop    %edi
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 28             	sub    $0x28,%esp
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801832:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801835:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801839:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80183c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801843:	85 c0                	test   %eax,%eax
  801845:	74 30                	je     801877 <vsnprintf+0x51>
  801847:	85 d2                	test   %edx,%edx
  801849:	7e 33                	jle    80187e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80184b:	8b 45 14             	mov    0x14(%ebp),%eax
  80184e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801852:	8b 45 10             	mov    0x10(%ebp),%eax
  801855:	89 44 24 08          	mov    %eax,0x8(%esp)
  801859:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80185c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801860:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  801867:	e8 2e fc ff ff       	call   80149a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80186c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80186f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801875:	eb 0c                	jmp    801883 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801877:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187c:	eb 05                	jmp    801883 <vsnprintf+0x5d>
  80187e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80188b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80188e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801892:	8b 45 10             	mov    0x10(%ebp),%eax
  801895:	89 44 24 08          	mov    %eax,0x8(%esp)
  801899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	89 04 24             	mov    %eax,(%esp)
  8018a6:	e8 7b ff ff ff       	call   801826 <vsnprintf>
	va_end(ap);

	return rc;
}
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    
  8018ad:	00 00                	add    %al,(%eax)
	...

008018b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bb:	eb 01                	jmp    8018be <strlen+0xe>
		n++;
  8018bd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8018be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8018c2:	75 f9                	jne    8018bd <strlen+0xd>
		n++;
	return n;
}
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8018cc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d4:	eb 01                	jmp    8018d7 <strnlen+0x11>
		n++;
  8018d6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018d7:	39 d0                	cmp    %edx,%eax
  8018d9:	74 06                	je     8018e1 <strnlen+0x1b>
  8018db:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8018df:	75 f5                	jne    8018d6 <strnlen+0x10>
		n++;
	return n;
}
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	53                   	push   %ebx
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018f5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018f8:	42                   	inc    %edx
  8018f9:	84 c9                	test   %cl,%cl
  8018fb:	75 f5                	jne    8018f2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018fd:	5b                   	pop    %ebx
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    

00801900 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	53                   	push   %ebx
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80190a:	89 1c 24             	mov    %ebx,(%esp)
  80190d:	e8 9e ff ff ff       	call   8018b0 <strlen>
	strcpy(dst + len, src);
  801912:	8b 55 0c             	mov    0xc(%ebp),%edx
  801915:	89 54 24 04          	mov    %edx,0x4(%esp)
  801919:	01 d8                	add    %ebx,%eax
  80191b:	89 04 24             	mov    %eax,(%esp)
  80191e:	e8 c0 ff ff ff       	call   8018e3 <strcpy>
	return dst;
}
  801923:	89 d8                	mov    %ebx,%eax
  801925:	83 c4 08             	add    $0x8,%esp
  801928:	5b                   	pop    %ebx
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	8b 55 0c             	mov    0xc(%ebp),%edx
  801936:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801939:	b9 00 00 00 00       	mov    $0x0,%ecx
  80193e:	eb 0c                	jmp    80194c <strncpy+0x21>
		*dst++ = *src;
  801940:	8a 1a                	mov    (%edx),%bl
  801942:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801945:	80 3a 01             	cmpb   $0x1,(%edx)
  801948:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80194b:	41                   	inc    %ecx
  80194c:	39 f1                	cmp    %esi,%ecx
  80194e:	75 f0                	jne    801940 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	8b 75 08             	mov    0x8(%ebp),%esi
  80195c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80195f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801962:	85 d2                	test   %edx,%edx
  801964:	75 0a                	jne    801970 <strlcpy+0x1c>
  801966:	89 f0                	mov    %esi,%eax
  801968:	eb 1a                	jmp    801984 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80196a:	88 18                	mov    %bl,(%eax)
  80196c:	40                   	inc    %eax
  80196d:	41                   	inc    %ecx
  80196e:	eb 02                	jmp    801972 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801970:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801972:	4a                   	dec    %edx
  801973:	74 0a                	je     80197f <strlcpy+0x2b>
  801975:	8a 19                	mov    (%ecx),%bl
  801977:	84 db                	test   %bl,%bl
  801979:	75 ef                	jne    80196a <strlcpy+0x16>
  80197b:	89 c2                	mov    %eax,%edx
  80197d:	eb 02                	jmp    801981 <strlcpy+0x2d>
  80197f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801981:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801984:	29 f0                	sub    %esi,%eax
}
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801990:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801993:	eb 02                	jmp    801997 <strcmp+0xd>
		p++, q++;
  801995:	41                   	inc    %ecx
  801996:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801997:	8a 01                	mov    (%ecx),%al
  801999:	84 c0                	test   %al,%al
  80199b:	74 04                	je     8019a1 <strcmp+0x17>
  80199d:	3a 02                	cmp    (%edx),%al
  80199f:	74 f4                	je     801995 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8019a1:	0f b6 c0             	movzbl %al,%eax
  8019a4:	0f b6 12             	movzbl (%edx),%edx
  8019a7:	29 d0                	sub    %edx,%eax
}
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	53                   	push   %ebx
  8019af:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8019b8:	eb 03                	jmp    8019bd <strncmp+0x12>
		n--, p++, q++;
  8019ba:	4a                   	dec    %edx
  8019bb:	40                   	inc    %eax
  8019bc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8019bd:	85 d2                	test   %edx,%edx
  8019bf:	74 14                	je     8019d5 <strncmp+0x2a>
  8019c1:	8a 18                	mov    (%eax),%bl
  8019c3:	84 db                	test   %bl,%bl
  8019c5:	74 04                	je     8019cb <strncmp+0x20>
  8019c7:	3a 19                	cmp    (%ecx),%bl
  8019c9:	74 ef                	je     8019ba <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8019cb:	0f b6 00             	movzbl (%eax),%eax
  8019ce:	0f b6 11             	movzbl (%ecx),%edx
  8019d1:	29 d0                	sub    %edx,%eax
  8019d3:	eb 05                	jmp    8019da <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8019da:	5b                   	pop    %ebx
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019e6:	eb 05                	jmp    8019ed <strchr+0x10>
		if (*s == c)
  8019e8:	38 ca                	cmp    %cl,%dl
  8019ea:	74 0c                	je     8019f8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019ec:	40                   	inc    %eax
  8019ed:	8a 10                	mov    (%eax),%dl
  8019ef:	84 d2                	test   %dl,%dl
  8019f1:	75 f5                	jne    8019e8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801a00:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801a03:	eb 05                	jmp    801a0a <strfind+0x10>
		if (*s == c)
  801a05:	38 ca                	cmp    %cl,%dl
  801a07:	74 07                	je     801a10 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801a09:	40                   	inc    %eax
  801a0a:	8a 10                	mov    (%eax),%dl
  801a0c:	84 d2                	test   %dl,%dl
  801a0e:	75 f5                	jne    801a05 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	57                   	push   %edi
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801a21:	85 c9                	test   %ecx,%ecx
  801a23:	74 30                	je     801a55 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801a25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a2b:	75 25                	jne    801a52 <memset+0x40>
  801a2d:	f6 c1 03             	test   $0x3,%cl
  801a30:	75 20                	jne    801a52 <memset+0x40>
		c &= 0xFF;
  801a32:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801a35:	89 d3                	mov    %edx,%ebx
  801a37:	c1 e3 08             	shl    $0x8,%ebx
  801a3a:	89 d6                	mov    %edx,%esi
  801a3c:	c1 e6 18             	shl    $0x18,%esi
  801a3f:	89 d0                	mov    %edx,%eax
  801a41:	c1 e0 10             	shl    $0x10,%eax
  801a44:	09 f0                	or     %esi,%eax
  801a46:	09 d0                	or     %edx,%eax
  801a48:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a4a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a4d:	fc                   	cld    
  801a4e:	f3 ab                	rep stos %eax,%es:(%edi)
  801a50:	eb 03                	jmp    801a55 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a52:	fc                   	cld    
  801a53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a55:	89 f8                	mov    %edi,%eax
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5f                   	pop    %edi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	57                   	push   %edi
  801a60:	56                   	push   %esi
  801a61:	8b 45 08             	mov    0x8(%ebp),%eax
  801a64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a6a:	39 c6                	cmp    %eax,%esi
  801a6c:	73 34                	jae    801aa2 <memmove+0x46>
  801a6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a71:	39 d0                	cmp    %edx,%eax
  801a73:	73 2d                	jae    801aa2 <memmove+0x46>
		s += n;
		d += n;
  801a75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a78:	f6 c2 03             	test   $0x3,%dl
  801a7b:	75 1b                	jne    801a98 <memmove+0x3c>
  801a7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a83:	75 13                	jne    801a98 <memmove+0x3c>
  801a85:	f6 c1 03             	test   $0x3,%cl
  801a88:	75 0e                	jne    801a98 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a8a:	83 ef 04             	sub    $0x4,%edi
  801a8d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a90:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a93:	fd                   	std    
  801a94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a96:	eb 07                	jmp    801a9f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a98:	4f                   	dec    %edi
  801a99:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a9c:	fd                   	std    
  801a9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a9f:	fc                   	cld    
  801aa0:	eb 20                	jmp    801ac2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801aa2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801aa8:	75 13                	jne    801abd <memmove+0x61>
  801aaa:	a8 03                	test   $0x3,%al
  801aac:	75 0f                	jne    801abd <memmove+0x61>
  801aae:	f6 c1 03             	test   $0x3,%cl
  801ab1:	75 0a                	jne    801abd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801ab3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801ab6:	89 c7                	mov    %eax,%edi
  801ab8:	fc                   	cld    
  801ab9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801abb:	eb 05                	jmp    801ac2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801abd:	89 c7                	mov    %eax,%edi
  801abf:	fc                   	cld    
  801ac0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801acc:	8b 45 10             	mov    0x10(%ebp),%eax
  801acf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	89 04 24             	mov    %eax,(%esp)
  801ae0:	e8 77 ff ff ff       	call   801a5c <memmove>
}
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	57                   	push   %edi
  801aeb:	56                   	push   %esi
  801aec:	53                   	push   %ebx
  801aed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801af6:	ba 00 00 00 00       	mov    $0x0,%edx
  801afb:	eb 16                	jmp    801b13 <memcmp+0x2c>
		if (*s1 != *s2)
  801afd:	8a 04 17             	mov    (%edi,%edx,1),%al
  801b00:	42                   	inc    %edx
  801b01:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801b05:	38 c8                	cmp    %cl,%al
  801b07:	74 0a                	je     801b13 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801b09:	0f b6 c0             	movzbl %al,%eax
  801b0c:	0f b6 c9             	movzbl %cl,%ecx
  801b0f:	29 c8                	sub    %ecx,%eax
  801b11:	eb 09                	jmp    801b1c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801b13:	39 da                	cmp    %ebx,%edx
  801b15:	75 e6                	jne    801afd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1c:	5b                   	pop    %ebx
  801b1d:	5e                   	pop    %esi
  801b1e:	5f                   	pop    %edi
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	8b 45 08             	mov    0x8(%ebp),%eax
  801b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801b2f:	eb 05                	jmp    801b36 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801b31:	38 08                	cmp    %cl,(%eax)
  801b33:	74 05                	je     801b3a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801b35:	40                   	inc    %eax
  801b36:	39 d0                	cmp    %edx,%eax
  801b38:	72 f7                	jb     801b31 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	8b 55 08             	mov    0x8(%ebp),%edx
  801b45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b48:	eb 01                	jmp    801b4b <strtol+0xf>
		s++;
  801b4a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b4b:	8a 02                	mov    (%edx),%al
  801b4d:	3c 20                	cmp    $0x20,%al
  801b4f:	74 f9                	je     801b4a <strtol+0xe>
  801b51:	3c 09                	cmp    $0x9,%al
  801b53:	74 f5                	je     801b4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b55:	3c 2b                	cmp    $0x2b,%al
  801b57:	75 08                	jne    801b61 <strtol+0x25>
		s++;
  801b59:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b5a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b5f:	eb 13                	jmp    801b74 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b61:	3c 2d                	cmp    $0x2d,%al
  801b63:	75 0a                	jne    801b6f <strtol+0x33>
		s++, neg = 1;
  801b65:	8d 52 01             	lea    0x1(%edx),%edx
  801b68:	bf 01 00 00 00       	mov    $0x1,%edi
  801b6d:	eb 05                	jmp    801b74 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b74:	85 db                	test   %ebx,%ebx
  801b76:	74 05                	je     801b7d <strtol+0x41>
  801b78:	83 fb 10             	cmp    $0x10,%ebx
  801b7b:	75 28                	jne    801ba5 <strtol+0x69>
  801b7d:	8a 02                	mov    (%edx),%al
  801b7f:	3c 30                	cmp    $0x30,%al
  801b81:	75 10                	jne    801b93 <strtol+0x57>
  801b83:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b87:	75 0a                	jne    801b93 <strtol+0x57>
		s += 2, base = 16;
  801b89:	83 c2 02             	add    $0x2,%edx
  801b8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b91:	eb 12                	jmp    801ba5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b93:	85 db                	test   %ebx,%ebx
  801b95:	75 0e                	jne    801ba5 <strtol+0x69>
  801b97:	3c 30                	cmp    $0x30,%al
  801b99:	75 05                	jne    801ba0 <strtol+0x64>
		s++, base = 8;
  801b9b:	42                   	inc    %edx
  801b9c:	b3 08                	mov    $0x8,%bl
  801b9e:	eb 05                	jmp    801ba5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801ba0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  801baa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801bac:	8a 0a                	mov    (%edx),%cl
  801bae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801bb1:	80 fb 09             	cmp    $0x9,%bl
  801bb4:	77 08                	ja     801bbe <strtol+0x82>
			dig = *s - '0';
  801bb6:	0f be c9             	movsbl %cl,%ecx
  801bb9:	83 e9 30             	sub    $0x30,%ecx
  801bbc:	eb 1e                	jmp    801bdc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801bbe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801bc1:	80 fb 19             	cmp    $0x19,%bl
  801bc4:	77 08                	ja     801bce <strtol+0x92>
			dig = *s - 'a' + 10;
  801bc6:	0f be c9             	movsbl %cl,%ecx
  801bc9:	83 e9 57             	sub    $0x57,%ecx
  801bcc:	eb 0e                	jmp    801bdc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801bce:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801bd1:	80 fb 19             	cmp    $0x19,%bl
  801bd4:	77 12                	ja     801be8 <strtol+0xac>
			dig = *s - 'A' + 10;
  801bd6:	0f be c9             	movsbl %cl,%ecx
  801bd9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801bdc:	39 f1                	cmp    %esi,%ecx
  801bde:	7d 0c                	jge    801bec <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801be0:	42                   	inc    %edx
  801be1:	0f af c6             	imul   %esi,%eax
  801be4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801be6:	eb c4                	jmp    801bac <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801be8:	89 c1                	mov    %eax,%ecx
  801bea:	eb 02                	jmp    801bee <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801bec:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801bee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bf2:	74 05                	je     801bf9 <strtol+0xbd>
		*endptr = (char *) s;
  801bf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bf7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bf9:	85 ff                	test   %edi,%edi
  801bfb:	74 04                	je     801c01 <strtol+0xc5>
  801bfd:	89 c8                	mov    %ecx,%eax
  801bff:	f7 d8                	neg    %eax
}
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    
	...

00801c08 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  801c0f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801c16:	75 6f                	jne    801c87 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  801c18:	e8 42 e5 ff ff       	call   80015f <sys_getenvid>
  801c1d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  801c1f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c26:	00 
  801c27:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801c2e:	ee 
  801c2f:	89 04 24             	mov    %eax,(%esp)
  801c32:	e8 66 e5 ff ff       	call   80019d <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  801c37:	85 c0                	test   %eax,%eax
  801c39:	79 1c                	jns    801c57 <set_pgfault_handler+0x4f>
  801c3b:	c7 44 24 08 a0 24 80 	movl   $0x8024a0,0x8(%esp)
  801c42:	00 
  801c43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801c4a:	00 
  801c4b:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  801c52:	e8 e9 f5 ff ff       	call   801240 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801c57:	c7 44 24 04 08 04 80 	movl   $0x800408,0x4(%esp)
  801c5e:	00 
  801c5f:	89 1c 24             	mov    %ebx,(%esp)
  801c62:	e8 d6 e6 ff ff       	call   80033d <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  801c67:	85 c0                	test   %eax,%eax
  801c69:	79 1c                	jns    801c87 <set_pgfault_handler+0x7f>
  801c6b:	c7 44 24 08 c8 24 80 	movl   $0x8024c8,0x8(%esp)
  801c72:	00 
  801c73:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801c7a:	00 
  801c7b:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  801c82:	e8 b9 f5 ff ff       	call   801240 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801c87:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801c8f:	83 c4 14             	add    $0x14,%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    
  801c95:	00 00                	add    %al,(%eax)
	...

00801c98 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 10             	sub    $0x10,%esp
  801ca0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	75 05                	jne    801cb2 <ipc_recv+0x1a>
  801cad:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801cb2:	89 04 24             	mov    %eax,(%esp)
  801cb5:	e8 f9 e6 ff ff       	call   8003b3 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	79 16                	jns    801cd4 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801cbe:	85 db                	test   %ebx,%ebx
  801cc0:	74 06                	je     801cc8 <ipc_recv+0x30>
  801cc2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801cc8:	85 f6                	test   %esi,%esi
  801cca:	74 32                	je     801cfe <ipc_recv+0x66>
  801ccc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801cd2:	eb 2a                	jmp    801cfe <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801cd4:	85 db                	test   %ebx,%ebx
  801cd6:	74 0c                	je     801ce4 <ipc_recv+0x4c>
  801cd8:	a1 04 40 80 00       	mov    0x804004,%eax
  801cdd:	8b 00                	mov    (%eax),%eax
  801cdf:	8b 40 74             	mov    0x74(%eax),%eax
  801ce2:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ce4:	85 f6                	test   %esi,%esi
  801ce6:	74 0c                	je     801cf4 <ipc_recv+0x5c>
  801ce8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ced:	8b 00                	mov    (%eax),%eax
  801cef:	8b 40 78             	mov    0x78(%eax),%eax
  801cf2:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801cf4:	a1 04 40 80 00       	mov    0x804004,%eax
  801cf9:	8b 00                	mov    (%eax),%eax
  801cfb:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 1c             	sub    $0x1c,%esp
  801d0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d14:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801d17:	85 db                	test   %ebx,%ebx
  801d19:	75 05                	jne    801d20 <ipc_send+0x1b>
  801d1b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801d20:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d24:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2f:	89 04 24             	mov    %eax,(%esp)
  801d32:	e8 59 e6 ff ff       	call   800390 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801d37:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d3a:	75 07                	jne    801d43 <ipc_send+0x3e>
  801d3c:	e8 3d e4 ff ff       	call   80017e <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801d41:	eb dd                	jmp    801d20 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801d43:	85 c0                	test   %eax,%eax
  801d45:	79 1c                	jns    801d63 <ipc_send+0x5e>
  801d47:	c7 44 24 08 0a 25 80 	movl   $0x80250a,0x8(%esp)
  801d4e:	00 
  801d4f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801d56:	00 
  801d57:	c7 04 24 1c 25 80 00 	movl   $0x80251c,(%esp)
  801d5e:	e8 dd f4 ff ff       	call   801240 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801d63:	83 c4 1c             	add    $0x1c,%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	53                   	push   %ebx
  801d6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d77:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d7e:	89 c2                	mov    %eax,%edx
  801d80:	c1 e2 07             	shl    $0x7,%edx
  801d83:	29 ca                	sub    %ecx,%edx
  801d85:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d8b:	8b 52 50             	mov    0x50(%edx),%edx
  801d8e:	39 da                	cmp    %ebx,%edx
  801d90:	75 0f                	jne    801da1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801d92:	c1 e0 07             	shl    $0x7,%eax
  801d95:	29 c8                	sub    %ecx,%eax
  801d97:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d9c:	8b 40 40             	mov    0x40(%eax),%eax
  801d9f:	eb 0c                	jmp    801dad <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801da1:	40                   	inc    %eax
  801da2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801da7:	75 ce                	jne    801d77 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801da9:	66 b8 00 00          	mov    $0x0,%ax
}
  801dad:	5b                   	pop    %ebx
  801dae:	5d                   	pop    %ebp
  801daf:	c3                   	ret    

00801db0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	c1 ea 16             	shr    $0x16,%edx
  801dbb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dc2:	f6 c2 01             	test   $0x1,%dl
  801dc5:	74 1e                	je     801de5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801dc7:	c1 e8 0c             	shr    $0xc,%eax
  801dca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801dd1:	a8 01                	test   $0x1,%al
  801dd3:	74 17                	je     801dec <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dd5:	c1 e8 0c             	shr    $0xc,%eax
  801dd8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ddf:	ef 
  801de0:	0f b7 c0             	movzwl %ax,%eax
  801de3:	eb 0c                	jmp    801df1 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801de5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dea:	eb 05                	jmp    801df1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
	...

00801df4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801df4:	55                   	push   %ebp
  801df5:	57                   	push   %edi
  801df6:	56                   	push   %esi
  801df7:	83 ec 10             	sub    $0x10,%esp
  801dfa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801dfe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e02:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e06:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801e0a:	89 cd                	mov    %ecx,%ebp
  801e0c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e10:	85 c0                	test   %eax,%eax
  801e12:	75 2c                	jne    801e40 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e14:	39 f9                	cmp    %edi,%ecx
  801e16:	77 68                	ja     801e80 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e18:	85 c9                	test   %ecx,%ecx
  801e1a:	75 0b                	jne    801e27 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e21:	31 d2                	xor    %edx,%edx
  801e23:	f7 f1                	div    %ecx
  801e25:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e27:	31 d2                	xor    %edx,%edx
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	f7 f1                	div    %ecx
  801e2d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e2f:	89 f0                	mov    %esi,%eax
  801e31:	f7 f1                	div    %ecx
  801e33:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	5e                   	pop    %esi
  801e3d:	5f                   	pop    %edi
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e40:	39 f8                	cmp    %edi,%eax
  801e42:	77 2c                	ja     801e70 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e44:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801e47:	83 f6 1f             	xor    $0x1f,%esi
  801e4a:	75 4c                	jne    801e98 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e4c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e4e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e53:	72 0a                	jb     801e5f <__udivdi3+0x6b>
  801e55:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e59:	0f 87 ad 00 00 00    	ja     801f0c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e5f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e64:	89 f0                	mov    %esi,%eax
  801e66:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e70:	31 ff                	xor    %edi,%edi
  801e72:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e74:	89 f0                	mov    %esi,%eax
  801e76:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e78:	83 c4 10             	add    $0x10,%esp
  801e7b:	5e                   	pop    %esi
  801e7c:	5f                   	pop    %edi
  801e7d:	5d                   	pop    %ebp
  801e7e:	c3                   	ret    
  801e7f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e80:	89 fa                	mov    %edi,%edx
  801e82:	89 f0                	mov    %esi,%eax
  801e84:	f7 f1                	div    %ecx
  801e86:	89 c6                	mov    %eax,%esi
  801e88:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e8a:	89 f0                	mov    %esi,%eax
  801e8c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    
  801e95:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e98:	89 f1                	mov    %esi,%ecx
  801e9a:	d3 e0                	shl    %cl,%eax
  801e9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ea0:	b8 20 00 00 00       	mov    $0x20,%eax
  801ea5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801ea7:	89 ea                	mov    %ebp,%edx
  801ea9:	88 c1                	mov    %al,%cl
  801eab:	d3 ea                	shr    %cl,%edx
  801ead:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801eb1:	09 ca                	or     %ecx,%edx
  801eb3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801eb7:	89 f1                	mov    %esi,%ecx
  801eb9:	d3 e5                	shl    %cl,%ebp
  801ebb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801ebf:	89 fd                	mov    %edi,%ebp
  801ec1:	88 c1                	mov    %al,%cl
  801ec3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801ec5:	89 fa                	mov    %edi,%edx
  801ec7:	89 f1                	mov    %esi,%ecx
  801ec9:	d3 e2                	shl    %cl,%edx
  801ecb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ecf:	88 c1                	mov    %al,%cl
  801ed1:	d3 ef                	shr    %cl,%edi
  801ed3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ed5:	89 f8                	mov    %edi,%eax
  801ed7:	89 ea                	mov    %ebp,%edx
  801ed9:	f7 74 24 08          	divl   0x8(%esp)
  801edd:	89 d1                	mov    %edx,%ecx
  801edf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801ee1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ee5:	39 d1                	cmp    %edx,%ecx
  801ee7:	72 17                	jb     801f00 <__udivdi3+0x10c>
  801ee9:	74 09                	je     801ef4 <__udivdi3+0x100>
  801eeb:	89 fe                	mov    %edi,%esi
  801eed:	31 ff                	xor    %edi,%edi
  801eef:	e9 41 ff ff ff       	jmp    801e35 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ef4:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ef8:	89 f1                	mov    %esi,%ecx
  801efa:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801efc:	39 c2                	cmp    %eax,%edx
  801efe:	73 eb                	jae    801eeb <__udivdi3+0xf7>
		{
		  q0--;
  801f00:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f03:	31 ff                	xor    %edi,%edi
  801f05:	e9 2b ff ff ff       	jmp    801e35 <__udivdi3+0x41>
  801f0a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f0c:	31 f6                	xor    %esi,%esi
  801f0e:	e9 22 ff ff ff       	jmp    801e35 <__udivdi3+0x41>
	...

00801f14 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f14:	55                   	push   %ebp
  801f15:	57                   	push   %edi
  801f16:	56                   	push   %esi
  801f17:	83 ec 20             	sub    $0x20,%esp
  801f1a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f1e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f22:	89 44 24 14          	mov    %eax,0x14(%esp)
  801f26:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801f2a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f2e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f32:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801f34:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f36:	85 ed                	test   %ebp,%ebp
  801f38:	75 16                	jne    801f50 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801f3a:	39 f1                	cmp    %esi,%ecx
  801f3c:	0f 86 a6 00 00 00    	jbe    801fe8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f42:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f44:	89 d0                	mov    %edx,%eax
  801f46:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f48:	83 c4 20             	add    $0x20,%esp
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    
  801f4f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f50:	39 f5                	cmp    %esi,%ebp
  801f52:	0f 87 ac 00 00 00    	ja     802004 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f58:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801f5b:	83 f0 1f             	xor    $0x1f,%eax
  801f5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f62:	0f 84 a8 00 00 00    	je     802010 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f68:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f6c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f6e:	bf 20 00 00 00       	mov    $0x20,%edi
  801f73:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f77:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f7b:	89 f9                	mov    %edi,%ecx
  801f7d:	d3 e8                	shr    %cl,%eax
  801f7f:	09 e8                	or     %ebp,%eax
  801f81:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801f85:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f89:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f8d:	d3 e0                	shl    %cl,%eax
  801f8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f93:	89 f2                	mov    %esi,%edx
  801f95:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f97:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f9b:	d3 e0                	shl    %cl,%eax
  801f9d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fa1:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	d3 e8                	shr    %cl,%eax
  801fa9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801fab:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fad:	89 f2                	mov    %esi,%edx
  801faf:	f7 74 24 18          	divl   0x18(%esp)
  801fb3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801fb5:	f7 64 24 0c          	mull   0xc(%esp)
  801fb9:	89 c5                	mov    %eax,%ebp
  801fbb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fbd:	39 d6                	cmp    %edx,%esi
  801fbf:	72 67                	jb     802028 <__umoddi3+0x114>
  801fc1:	74 75                	je     802038 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fc3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fc7:	29 e8                	sub    %ebp,%eax
  801fc9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fcb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fcf:	d3 e8                	shr    %cl,%eax
  801fd1:	89 f2                	mov    %esi,%edx
  801fd3:	89 f9                	mov    %edi,%ecx
  801fd5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fd7:	09 d0                	or     %edx,%eax
  801fd9:	89 f2                	mov    %esi,%edx
  801fdb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fdf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fe1:	83 c4 20             	add    $0x20,%esp
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fe8:	85 c9                	test   %ecx,%ecx
  801fea:	75 0b                	jne    801ff7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fec:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff1:	31 d2                	xor    %edx,%edx
  801ff3:	f7 f1                	div    %ecx
  801ff5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ff7:	89 f0                	mov    %esi,%eax
  801ff9:	31 d2                	xor    %edx,%edx
  801ffb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ffd:	89 f8                	mov    %edi,%eax
  801fff:	e9 3e ff ff ff       	jmp    801f42 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802004:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802006:	83 c4 20             	add    $0x20,%esp
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    
  80200d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802010:	39 f5                	cmp    %esi,%ebp
  802012:	72 04                	jb     802018 <__umoddi3+0x104>
  802014:	39 f9                	cmp    %edi,%ecx
  802016:	77 06                	ja     80201e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802018:	89 f2                	mov    %esi,%edx
  80201a:	29 cf                	sub    %ecx,%edi
  80201c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80201e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802020:	83 c4 20             	add    $0x20,%esp
  802023:	5e                   	pop    %esi
  802024:	5f                   	pop    %edi
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    
  802027:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802028:	89 d1                	mov    %edx,%ecx
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802030:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802034:	eb 8d                	jmp    801fc3 <__umoddi3+0xaf>
  802036:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802038:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80203c:	72 ea                	jb     802028 <__umoddi3+0x114>
  80203e:	89 f1                	mov    %esi,%ecx
  802040:	eb 81                	jmp    801fc3 <__umoddi3+0xaf>
