
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 63 01 00 00       	call   8001b9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 ef 02 00 00       	call   800359 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 20             	sub    $0x20,%esp
  800080:	8b 75 08             	mov    0x8(%ebp),%esi
  800083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800086:	e8 f0 00 00 00       	call   80017b <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	29 d0                	sub    %edx,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a7:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ac:	85 f6                	test   %esi,%esi
  8000ae:	7e 07                	jle    8000b7 <libmain+0x3f>
		binaryname = argv[0];
  8000b0:	8b 03                	mov    (%ebx),%eax
  8000b2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000bb:	89 34 24             	mov    %esi,(%esp)
  8000be:	e8 71 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c3:	e8 08 00 00 00       	call   8000d0 <exit>
}
  8000c8:	83 c4 20             	add    $0x20,%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    
	...

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000d6:	e8 32 05 00 00       	call   80060d <close_all>
	sys_env_destroy(0);
  8000db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e2:	e8 42 00 00 00       	call   800129 <sys_env_destroy>
}
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    
  8000e9:	00 00                	add    %al,(%eax)
	...

008000ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 c3                	mov    %eax,%ebx
  8000ff:	89 c7                	mov    %eax,%edi
  800101:	89 c6                	mov    %eax,%esi
  800103:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800105:	5b                   	pop    %ebx
  800106:	5e                   	pop    %esi
  800107:	5f                   	pop    %edi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <sys_cgetc>:

int
sys_cgetc(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	57                   	push   %edi
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800110:	ba 00 00 00 00       	mov    $0x0,%edx
  800115:	b8 01 00 00 00       	mov    $0x1,%eax
  80011a:	89 d1                	mov    %edx,%ecx
  80011c:	89 d3                	mov    %edx,%ebx
  80011e:	89 d7                	mov    %edx,%edi
  800120:	89 d6                	mov    %edx,%esi
  800122:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5f                   	pop    %edi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	57                   	push   %edi
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
  80012f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	b9 00 00 00 00       	mov    $0x0,%ecx
  800137:	b8 03 00 00 00       	mov    $0x3,%eax
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	89 cb                	mov    %ecx,%ebx
  800141:	89 cf                	mov    %ecx,%edi
  800143:	89 ce                	mov    %ecx,%esi
  800145:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800147:	85 c0                	test   %eax,%eax
  800149:	7e 28                	jle    800173 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800156:	00 
  800157:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  80015e:	00 
  80015f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800166:	00 
  800167:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  80016e:	e8 c1 10 00 00       	call   801234 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800173:	83 c4 2c             	add    $0x2c,%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5f                   	pop    %edi
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	57                   	push   %edi
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800181:	ba 00 00 00 00       	mov    $0x0,%edx
  800186:	b8 02 00 00 00       	mov    $0x2,%eax
  80018b:	89 d1                	mov    %edx,%ecx
  80018d:	89 d3                	mov    %edx,%ebx
  80018f:	89 d7                	mov    %edx,%edi
  800191:	89 d6                	mov    %edx,%esi
  800193:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5f                   	pop    %edi
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <sys_yield>:

void
sys_yield(void)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	57                   	push   %edi
  80019e:	56                   	push   %esi
  80019f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001aa:	89 d1                	mov    %edx,%ecx
  8001ac:	89 d3                	mov    %edx,%ebx
  8001ae:	89 d7                	mov    %edx,%edi
  8001b0:	89 d6                	mov    %edx,%esi
  8001b2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001b4:	5b                   	pop    %ebx
  8001b5:	5e                   	pop    %esi
  8001b6:	5f                   	pop    %edi
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    

008001b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	57                   	push   %edi
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c2:	be 00 00 00 00       	mov    $0x0,%esi
  8001c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d5:	89 f7                	mov    %esi,%edi
  8001d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	7e 28                	jle    800205 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  8001f0:	00 
  8001f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f8:	00 
  8001f9:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  800200:	e8 2f 10 00 00       	call   801234 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800205:	83 c4 2c             	add    $0x2c,%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5f                   	pop    %edi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    

0080020d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	57                   	push   %edi
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800216:	b8 05 00 00 00       	mov    $0x5,%eax
  80021b:	8b 75 18             	mov    0x18(%ebp),%esi
  80021e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800221:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800224:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022c:	85 c0                	test   %eax,%eax
  80022e:	7e 28                	jle    800258 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800230:	89 44 24 10          	mov    %eax,0x10(%esp)
  800234:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80023b:	00 
  80023c:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  800243:	00 
  800244:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024b:	00 
  80024c:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  800253:	e8 dc 0f 00 00       	call   801234 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800258:	83 c4 2c             	add    $0x2c,%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5e                   	pop    %esi
  80025d:	5f                   	pop    %edi
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026e:	b8 06 00 00 00       	mov    $0x6,%eax
  800273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800276:	8b 55 08             	mov    0x8(%ebp),%edx
  800279:	89 df                	mov    %ebx,%edi
  80027b:	89 de                	mov    %ebx,%esi
  80027d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027f:	85 c0                	test   %eax,%eax
  800281:	7e 28                	jle    8002ab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800283:	89 44 24 10          	mov    %eax,0x10(%esp)
  800287:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80028e:	00 
  80028f:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  800296:	00 
  800297:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029e:	00 
  80029f:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  8002a6:	e8 89 0f 00 00       	call   801234 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ab:	83 c4 2c             	add    $0x2c,%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	89 df                	mov    %ebx,%edi
  8002ce:	89 de                	mov    %ebx,%esi
  8002d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	7e 28                	jle    8002fe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002da:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002e1:	00 
  8002e2:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  8002e9:	00 
  8002ea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f1:	00 
  8002f2:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  8002f9:	e8 36 0f 00 00       	call   801234 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002fe:	83 c4 2c             	add    $0x2c,%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800314:	b8 09 00 00 00       	mov    $0x9,%eax
  800319:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	89 df                	mov    %ebx,%edi
  800321:	89 de                	mov    %ebx,%esi
  800323:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800325:	85 c0                	test   %eax,%eax
  800327:	7e 28                	jle    800351 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800329:	89 44 24 10          	mov    %eax,0x10(%esp)
  80032d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800334:	00 
  800335:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  80033c:	00 
  80033d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800344:	00 
  800345:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  80034c:	e8 e3 0e 00 00       	call   801234 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800351:	83 c4 2c             	add    $0x2c,%esp
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5f                   	pop    %edi
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	57                   	push   %edi
  80035d:	56                   	push   %esi
  80035e:	53                   	push   %ebx
  80035f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800362:	bb 00 00 00 00       	mov    $0x0,%ebx
  800367:	b8 0a 00 00 00       	mov    $0xa,%eax
  80036c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036f:	8b 55 08             	mov    0x8(%ebp),%edx
  800372:	89 df                	mov    %ebx,%edi
  800374:	89 de                	mov    %ebx,%esi
  800376:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800378:	85 c0                	test   %eax,%eax
  80037a:	7e 28                	jle    8003a4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800380:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800387:	00 
  800388:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  80038f:	00 
  800390:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800397:	00 
  800398:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  80039f:	e8 90 0e 00 00       	call   801234 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a4:	83 c4 2c             	add    $0x2c,%esp
  8003a7:	5b                   	pop    %ebx
  8003a8:	5e                   	pop    %esi
  8003a9:	5f                   	pop    %edi
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b2:	be 00 00 00 00       	mov    $0x0,%esi
  8003b7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	57                   	push   %edi
  8003d3:	56                   	push   %esi
  8003d4:	53                   	push   %ebx
  8003d5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003dd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e5:	89 cb                	mov    %ecx,%ebx
  8003e7:	89 cf                	mov    %ecx,%edi
  8003e9:	89 ce                	mov    %ecx,%esi
  8003eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 28                	jle    800419 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003fc:	00 
  8003fd:	c7 44 24 08 ca 1f 80 	movl   $0x801fca,0x8(%esp)
  800404:	00 
  800405:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040c:	00 
  80040d:	c7 04 24 e7 1f 80 00 	movl   $0x801fe7,(%esp)
  800414:	e8 1b 0e 00 00       	call   801234 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800419:	83 c4 2c             	add    $0x2c,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5e                   	pop    %esi
  80041e:	5f                   	pop    %edi
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    
  800421:	00 00                	add    %al,(%eax)
	...

00800424 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	05 00 00 00 30       	add    $0x30000000,%eax
  80042f:	c1 e8 0c             	shr    $0xc,%eax
}
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	e8 df ff ff ff       	call   800424 <fd2num>
  800445:	05 20 00 0d 00       	add    $0xd0020,%eax
  80044a:	c1 e0 0c             	shl    $0xc,%eax
}
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	53                   	push   %ebx
  800453:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800456:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80045b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80045d:	89 c2                	mov    %eax,%edx
  80045f:	c1 ea 16             	shr    $0x16,%edx
  800462:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800469:	f6 c2 01             	test   $0x1,%dl
  80046c:	74 11                	je     80047f <fd_alloc+0x30>
  80046e:	89 c2                	mov    %eax,%edx
  800470:	c1 ea 0c             	shr    $0xc,%edx
  800473:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80047a:	f6 c2 01             	test   $0x1,%dl
  80047d:	75 09                	jne    800488 <fd_alloc+0x39>
			*fd_store = fd;
  80047f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
  800486:	eb 17                	jmp    80049f <fd_alloc+0x50>
  800488:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80048d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800492:	75 c7                	jne    80045b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800494:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80049a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80049f:	5b                   	pop    %ebx
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004a8:	83 f8 1f             	cmp    $0x1f,%eax
  8004ab:	77 36                	ja     8004e3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004ad:	05 00 00 0d 00       	add    $0xd0000,%eax
  8004b2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004b5:	89 c2                	mov    %eax,%edx
  8004b7:	c1 ea 16             	shr    $0x16,%edx
  8004ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004c1:	f6 c2 01             	test   $0x1,%dl
  8004c4:	74 24                	je     8004ea <fd_lookup+0x48>
  8004c6:	89 c2                	mov    %eax,%edx
  8004c8:	c1 ea 0c             	shr    $0xc,%edx
  8004cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004d2:	f6 c2 01             	test   $0x1,%dl
  8004d5:	74 1a                	je     8004f1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004da:	89 02                	mov    %eax,(%edx)
	return 0;
  8004dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e1:	eb 13                	jmp    8004f6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004e8:	eb 0c                	jmp    8004f6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ef:	eb 05                	jmp    8004f6 <fd_lookup+0x54>
  8004f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	53                   	push   %ebx
  8004fc:	83 ec 14             	sub    $0x14,%esp
  8004ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800505:	ba 00 00 00 00       	mov    $0x0,%edx
  80050a:	eb 0e                	jmp    80051a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80050c:	39 08                	cmp    %ecx,(%eax)
  80050e:	75 09                	jne    800519 <dev_lookup+0x21>
			*dev = devtab[i];
  800510:	89 03                	mov    %eax,(%ebx)
			return 0;
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
  800517:	eb 35                	jmp    80054e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800519:	42                   	inc    %edx
  80051a:	8b 04 95 74 20 80 00 	mov    0x802074(,%edx,4),%eax
  800521:	85 c0                	test   %eax,%eax
  800523:	75 e7                	jne    80050c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800525:	a1 04 40 80 00       	mov    0x804004,%eax
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	8b 40 48             	mov    0x48(%eax),%eax
  80052f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800533:	89 44 24 04          	mov    %eax,0x4(%esp)
  800537:	c7 04 24 f8 1f 80 00 	movl   $0x801ff8,(%esp)
  80053e:	e8 e9 0d 00 00       	call   80132c <cprintf>
	*dev = 0;
  800543:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800549:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80054e:	83 c4 14             	add    $0x14,%esp
  800551:	5b                   	pop    %ebx
  800552:	5d                   	pop    %ebp
  800553:	c3                   	ret    

00800554 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	56                   	push   %esi
  800558:	53                   	push   %ebx
  800559:	83 ec 30             	sub    $0x30,%esp
  80055c:	8b 75 08             	mov    0x8(%ebp),%esi
  80055f:	8a 45 0c             	mov    0xc(%ebp),%al
  800562:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800565:	89 34 24             	mov    %esi,(%esp)
  800568:	e8 b7 fe ff ff       	call   800424 <fd2num>
  80056d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800570:	89 54 24 04          	mov    %edx,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	e8 26 ff ff ff       	call   8004a2 <fd_lookup>
  80057c:	89 c3                	mov    %eax,%ebx
  80057e:	85 c0                	test   %eax,%eax
  800580:	78 05                	js     800587 <fd_close+0x33>
	    || fd != fd2)
  800582:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800585:	74 0d                	je     800594 <fd_close+0x40>
		return (must_exist ? r : 0);
  800587:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80058b:	75 46                	jne    8005d3 <fd_close+0x7f>
  80058d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800592:	eb 3f                	jmp    8005d3 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800594:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059b:	8b 06                	mov    (%esi),%eax
  80059d:	89 04 24             	mov    %eax,(%esp)
  8005a0:	e8 53 ff ff ff       	call   8004f8 <dev_lookup>
  8005a5:	89 c3                	mov    %eax,%ebx
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	78 18                	js     8005c3 <fd_close+0x6f>
		if (dev->dev_close)
  8005ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ae:	8b 40 10             	mov    0x10(%eax),%eax
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	74 09                	je     8005be <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005b5:	89 34 24             	mov    %esi,(%esp)
  8005b8:	ff d0                	call   *%eax
  8005ba:	89 c3                	mov    %eax,%ebx
  8005bc:	eb 05                	jmp    8005c3 <fd_close+0x6f>
		else
			r = 0;
  8005be:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ce:	e8 8d fc ff ff       	call   800260 <sys_page_unmap>
	return r;
}
  8005d3:	89 d8                	mov    %ebx,%eax
  8005d5:	83 c4 30             	add    $0x30,%esp
  8005d8:	5b                   	pop    %ebx
  8005d9:	5e                   	pop    %esi
  8005da:	5d                   	pop    %ebp
  8005db:	c3                   	ret    

008005dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 ae fe ff ff       	call   8004a2 <fd_lookup>
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	78 13                	js     80060b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005ff:	00 
  800600:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	e8 49 ff ff ff       	call   800554 <fd_close>
}
  80060b:	c9                   	leave  
  80060c:	c3                   	ret    

0080060d <close_all>:

void
close_all(void)
{
  80060d:	55                   	push   %ebp
  80060e:	89 e5                	mov    %esp,%ebp
  800610:	53                   	push   %ebx
  800611:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800614:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800619:	89 1c 24             	mov    %ebx,(%esp)
  80061c:	e8 bb ff ff ff       	call   8005dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800621:	43                   	inc    %ebx
  800622:	83 fb 20             	cmp    $0x20,%ebx
  800625:	75 f2                	jne    800619 <close_all+0xc>
		close(i);
}
  800627:	83 c4 14             	add    $0x14,%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5d                   	pop    %ebp
  80062c:	c3                   	ret    

0080062d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	57                   	push   %edi
  800631:	56                   	push   %esi
  800632:	53                   	push   %ebx
  800633:	83 ec 4c             	sub    $0x4c,%esp
  800636:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800639:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 57 fe ff ff       	call   8004a2 <fd_lookup>
  80064b:	89 c3                	mov    %eax,%ebx
  80064d:	85 c0                	test   %eax,%eax
  80064f:	0f 88 e1 00 00 00    	js     800736 <dup+0x109>
		return r;
	close(newfdnum);
  800655:	89 3c 24             	mov    %edi,(%esp)
  800658:	e8 7f ff ff ff       	call   8005dc <close>

	newfd = INDEX2FD(newfdnum);
  80065d:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800663:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800666:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800669:	89 04 24             	mov    %eax,(%esp)
  80066c:	e8 c3 fd ff ff       	call   800434 <fd2data>
  800671:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800673:	89 34 24             	mov    %esi,(%esp)
  800676:	e8 b9 fd ff ff       	call   800434 <fd2data>
  80067b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80067e:	89 d8                	mov    %ebx,%eax
  800680:	c1 e8 16             	shr    $0x16,%eax
  800683:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80068a:	a8 01                	test   $0x1,%al
  80068c:	74 46                	je     8006d4 <dup+0xa7>
  80068e:	89 d8                	mov    %ebx,%eax
  800690:	c1 e8 0c             	shr    $0xc,%eax
  800693:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80069a:	f6 c2 01             	test   $0x1,%dl
  80069d:	74 35                	je     8006d4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80069f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8006ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006bd:	00 
  8006be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c9:	e8 3f fb ff ff       	call   80020d <sys_page_map>
  8006ce:	89 c3                	mov    %eax,%ebx
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	78 3b                	js     80070f <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d7:	89 c2                	mov    %eax,%edx
  8006d9:	c1 ea 0c             	shr    $0xc,%edx
  8006dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006e3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006f8:	00 
  8006f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800704:	e8 04 fb ff ff       	call   80020d <sys_page_map>
  800709:	89 c3                	mov    %eax,%ebx
  80070b:	85 c0                	test   %eax,%eax
  80070d:	79 25                	jns    800734 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80070f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800713:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80071a:	e8 41 fb ff ff       	call   800260 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80071f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800722:	89 44 24 04          	mov    %eax,0x4(%esp)
  800726:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80072d:	e8 2e fb ff ff       	call   800260 <sys_page_unmap>
	return r;
  800732:	eb 02                	jmp    800736 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800734:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800736:	89 d8                	mov    %ebx,%eax
  800738:	83 c4 4c             	add    $0x4c,%esp
  80073b:	5b                   	pop    %ebx
  80073c:	5e                   	pop    %esi
  80073d:	5f                   	pop    %edi
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	83 ec 24             	sub    $0x24,%esp
  800747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80074a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80074d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800751:	89 1c 24             	mov    %ebx,(%esp)
  800754:	e8 49 fd ff ff       	call   8004a2 <fd_lookup>
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 6f                	js     8007cc <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800767:	8b 00                	mov    (%eax),%eax
  800769:	89 04 24             	mov    %eax,(%esp)
  80076c:	e8 87 fd ff ff       	call   8004f8 <dev_lookup>
  800771:	85 c0                	test   %eax,%eax
  800773:	78 57                	js     8007cc <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800775:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800778:	8b 50 08             	mov    0x8(%eax),%edx
  80077b:	83 e2 03             	and    $0x3,%edx
  80077e:	83 fa 01             	cmp    $0x1,%edx
  800781:	75 25                	jne    8007a8 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800783:	a1 04 40 80 00       	mov    0x804004,%eax
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	8b 40 48             	mov    0x48(%eax),%eax
  80078d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	c7 04 24 39 20 80 00 	movl   $0x802039,(%esp)
  80079c:	e8 8b 0b 00 00       	call   80132c <cprintf>
		return -E_INVAL;
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a6:	eb 24                	jmp    8007cc <read+0x8c>
	}
	if (!dev->dev_read)
  8007a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ab:	8b 52 08             	mov    0x8(%edx),%edx
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 15                	je     8007c7 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	ff d2                	call   *%edx
  8007c5:	eb 05                	jmp    8007cc <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007cc:	83 c4 24             	add    $0x24,%esp
  8007cf:	5b                   	pop    %ebx
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	57                   	push   %edi
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 1c             	sub    $0x1c,%esp
  8007db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007e6:	eb 23                	jmp    80080b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007e8:	89 f0                	mov    %esi,%eax
  8007ea:	29 d8                	sub    %ebx,%eax
  8007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f3:	01 d8                	add    %ebx,%eax
  8007f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f9:	89 3c 24             	mov    %edi,(%esp)
  8007fc:	e8 3f ff ff ff       	call   800740 <read>
		if (m < 0)
  800801:	85 c0                	test   %eax,%eax
  800803:	78 10                	js     800815 <readn+0x43>
			return m;
		if (m == 0)
  800805:	85 c0                	test   %eax,%eax
  800807:	74 0a                	je     800813 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800809:	01 c3                	add    %eax,%ebx
  80080b:	39 f3                	cmp    %esi,%ebx
  80080d:	72 d9                	jb     8007e8 <readn+0x16>
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	eb 02                	jmp    800815 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800813:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800815:	83 c4 1c             	add    $0x1c,%esp
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5f                   	pop    %edi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	83 ec 24             	sub    $0x24,%esp
  800824:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800827:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	89 1c 24             	mov    %ebx,(%esp)
  800831:	e8 6c fc ff ff       	call   8004a2 <fd_lookup>
  800836:	85 c0                	test   %eax,%eax
  800838:	78 6a                	js     8008a4 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800844:	8b 00                	mov    (%eax),%eax
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	e8 aa fc ff ff       	call   8004f8 <dev_lookup>
  80084e:	85 c0                	test   %eax,%eax
  800850:	78 52                	js     8008a4 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800855:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800859:	75 25                	jne    800880 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80085b:	a1 04 40 80 00       	mov    0x804004,%eax
  800860:	8b 00                	mov    (%eax),%eax
  800862:	8b 40 48             	mov    0x48(%eax),%eax
  800865:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086d:	c7 04 24 55 20 80 00 	movl   $0x802055,(%esp)
  800874:	e8 b3 0a 00 00       	call   80132c <cprintf>
		return -E_INVAL;
  800879:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087e:	eb 24                	jmp    8008a4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800880:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800883:	8b 52 0c             	mov    0xc(%edx),%edx
  800886:	85 d2                	test   %edx,%edx
  800888:	74 15                	je     80089f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800891:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800894:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800898:	89 04 24             	mov    %eax,(%esp)
  80089b:	ff d2                	call   *%edx
  80089d:	eb 05                	jmp    8008a4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80089f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008a4:	83 c4 24             	add    $0x24,%esp
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	e8 e0 fb ff ff       	call   8004a2 <fd_lookup>
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	78 0e                	js     8008d4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	53                   	push   %ebx
  8008da:	83 ec 24             	sub    $0x24,%esp
  8008dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e7:	89 1c 24             	mov    %ebx,(%esp)
  8008ea:	e8 b3 fb ff ff       	call   8004a2 <fd_lookup>
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	78 63                	js     800956 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008fd:	8b 00                	mov    (%eax),%eax
  8008ff:	89 04 24             	mov    %eax,(%esp)
  800902:	e8 f1 fb ff ff       	call   8004f8 <dev_lookup>
  800907:	85 c0                	test   %eax,%eax
  800909:	78 4b                	js     800956 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80090b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800912:	75 25                	jne    800939 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800914:	a1 04 40 80 00       	mov    0x804004,%eax
  800919:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80091b:	8b 40 48             	mov    0x48(%eax),%eax
  80091e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800922:	89 44 24 04          	mov    %eax,0x4(%esp)
  800926:	c7 04 24 18 20 80 00 	movl   $0x802018,(%esp)
  80092d:	e8 fa 09 00 00       	call   80132c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800932:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800937:	eb 1d                	jmp    800956 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800939:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80093c:	8b 52 18             	mov    0x18(%edx),%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 0e                	je     800951 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800946:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80094a:	89 04 24             	mov    %eax,(%esp)
  80094d:	ff d2                	call   *%edx
  80094f:	eb 05                	jmp    800956 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800951:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800956:	83 c4 24             	add    $0x24,%esp
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	83 ec 24             	sub    $0x24,%esp
  800963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800966:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	89 04 24             	mov    %eax,(%esp)
  800973:	e8 2a fb ff ff       	call   8004a2 <fd_lookup>
  800978:	85 c0                	test   %eax,%eax
  80097a:	78 52                	js     8009ce <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80097c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80097f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800986:	8b 00                	mov    (%eax),%eax
  800988:	89 04 24             	mov    %eax,(%esp)
  80098b:	e8 68 fb ff ff       	call   8004f8 <dev_lookup>
  800990:	85 c0                	test   %eax,%eax
  800992:	78 3a                	js     8009ce <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80099b:	74 2c                	je     8009c9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80099d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009a7:	00 00 00 
	stat->st_isdir = 0;
  8009aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009b1:	00 00 00 
	stat->st_dev = dev;
  8009b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c1:	89 14 24             	mov    %edx,(%esp)
  8009c4:	ff 50 14             	call   *0x14(%eax)
  8009c7:	eb 05                	jmp    8009ce <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009ce:	83 c4 24             	add    $0x24,%esp
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009e3:	00 
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 88 02 00 00       	call   800c77 <open>
  8009ef:	89 c3                	mov    %eax,%ebx
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	78 1b                	js     800a10 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fc:	89 1c 24             	mov    %ebx,(%esp)
  8009ff:	e8 58 ff ff ff       	call   80095c <fstat>
  800a04:	89 c6                	mov    %eax,%esi
	close(fd);
  800a06:	89 1c 24             	mov    %ebx,(%esp)
  800a09:	e8 ce fb ff ff       	call   8005dc <close>
	return r;
  800a0e:	89 f3                	mov    %esi,%ebx
}
  800a10:	89 d8                	mov    %ebx,%eax
  800a12:	83 c4 10             	add    $0x10,%esp
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    
  800a19:	00 00                	add    %al,(%eax)
	...

00800a1c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	83 ec 10             	sub    $0x10,%esp
  800a24:	89 c3                	mov    %eax,%ebx
  800a26:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a28:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a2f:	75 11                	jne    800a42 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a38:	e8 92 12 00 00       	call   801ccf <ipc_find_env>
  800a3d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a42:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a49:	00 
  800a4a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a51:	00 
  800a52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a56:	a1 00 40 80 00       	mov    0x804000,%eax
  800a5b:	89 04 24             	mov    %eax,(%esp)
  800a5e:	e8 06 12 00 00       	call   801c69 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a6a:	00 
  800a6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a76:	e8 81 11 00 00       	call   801bfc <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a7b:	83 c4 10             	add    $0x10,%esp
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa5:	e8 72 ff ff ff       	call   800a1c <fsipc>
}
  800aaa:	c9                   	leave  
  800aab:	c3                   	ret    

00800aac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800abd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ac7:	e8 50 ff ff ff       	call   800a1c <fsipc>
}
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 14             	sub    $0x14,%esp
  800ad5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 40 0c             	mov    0xc(%eax),%eax
  800ade:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 05 00 00 00       	mov    $0x5,%eax
  800aed:	e8 2a ff ff ff       	call   800a1c <fsipc>
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 2b                	js     800b21 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800af6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800afd:	00 
  800afe:	89 1c 24             	mov    %ebx,(%esp)
  800b01:	e8 d1 0d 00 00       	call   8018d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b06:	a1 80 50 80 00       	mov    0x805080,%eax
  800b0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b11:	a1 84 50 80 00       	mov    0x805084,%eax
  800b16:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b21:	83 c4 14             	add    $0x14,%esp
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 14             	sub    $0x14,%esp
  800b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 40 0c             	mov    0xc(%eax),%eax
  800b37:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b3c:	89 d8                	mov    %ebx,%eax
  800b3e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b44:	76 05                	jbe    800b4b <devfile_write+0x24>
  800b46:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b4b:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b62:	e8 53 0f 00 00       	call   801aba <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b71:	e8 a6 fe ff ff       	call   800a1c <fsipc>
  800b76:	85 c0                	test   %eax,%eax
  800b78:	78 53                	js     800bcd <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b7a:	39 c3                	cmp    %eax,%ebx
  800b7c:	73 24                	jae    800ba2 <devfile_write+0x7b>
  800b7e:	c7 44 24 0c 84 20 80 	movl   $0x802084,0xc(%esp)
  800b85:	00 
  800b86:	c7 44 24 08 8b 20 80 	movl   $0x80208b,0x8(%esp)
  800b8d:	00 
  800b8e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800b95:	00 
  800b96:	c7 04 24 a0 20 80 00 	movl   $0x8020a0,(%esp)
  800b9d:	e8 92 06 00 00       	call   801234 <_panic>
	assert(r <= PGSIZE);
  800ba2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ba7:	7e 24                	jle    800bcd <devfile_write+0xa6>
  800ba9:	c7 44 24 0c ab 20 80 	movl   $0x8020ab,0xc(%esp)
  800bb0:	00 
  800bb1:	c7 44 24 08 8b 20 80 	movl   $0x80208b,0x8(%esp)
  800bb8:	00 
  800bb9:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800bc0:	00 
  800bc1:	c7 04 24 a0 20 80 00 	movl   $0x8020a0,(%esp)
  800bc8:	e8 67 06 00 00       	call   801234 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800bcd:	83 c4 14             	add    $0x14,%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 10             	sub    $0x10,%esp
  800bdb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	8b 40 0c             	mov    0xc(%eax),%eax
  800be4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800be9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf9:	e8 1e fe ff ff       	call   800a1c <fsipc>
  800bfe:	89 c3                	mov    %eax,%ebx
  800c00:	85 c0                	test   %eax,%eax
  800c02:	78 6a                	js     800c6e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c04:	39 c6                	cmp    %eax,%esi
  800c06:	73 24                	jae    800c2c <devfile_read+0x59>
  800c08:	c7 44 24 0c 84 20 80 	movl   $0x802084,0xc(%esp)
  800c0f:	00 
  800c10:	c7 44 24 08 8b 20 80 	movl   $0x80208b,0x8(%esp)
  800c17:	00 
  800c18:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800c1f:	00 
  800c20:	c7 04 24 a0 20 80 00 	movl   $0x8020a0,(%esp)
  800c27:	e8 08 06 00 00       	call   801234 <_panic>
	assert(r <= PGSIZE);
  800c2c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c31:	7e 24                	jle    800c57 <devfile_read+0x84>
  800c33:	c7 44 24 0c ab 20 80 	movl   $0x8020ab,0xc(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 08 8b 20 80 	movl   $0x80208b,0x8(%esp)
  800c42:	00 
  800c43:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c4a:	00 
  800c4b:	c7 04 24 a0 20 80 00 	movl   $0x8020a0,(%esp)
  800c52:	e8 dd 05 00 00       	call   801234 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c62:	00 
  800c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c66:	89 04 24             	mov    %eax,(%esp)
  800c69:	e8 e2 0d 00 00       	call   801a50 <memmove>
	return r;
}
  800c6e:	89 d8                	mov    %ebx,%eax
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 20             	sub    $0x20,%esp
  800c7f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c82:	89 34 24             	mov    %esi,(%esp)
  800c85:	e8 1a 0c 00 00       	call   8018a4 <strlen>
  800c8a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c8f:	7f 60                	jg     800cf1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c94:	89 04 24             	mov    %eax,(%esp)
  800c97:	e8 b3 f7 ff ff       	call   80044f <fd_alloc>
  800c9c:	89 c3                	mov    %eax,%ebx
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	78 54                	js     800cf6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ca2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cad:	e8 25 0c 00 00       	call   8018d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc2:	e8 55 fd ff ff       	call   800a1c <fsipc>
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	79 15                	jns    800ce2 <open+0x6b>
		fd_close(fd, 0);
  800ccd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cd4:	00 
  800cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd8:	89 04 24             	mov    %eax,(%esp)
  800cdb:	e8 74 f8 ff ff       	call   800554 <fd_close>
		return r;
  800ce0:	eb 14                	jmp    800cf6 <open+0x7f>
	}

	return fd2num(fd);
  800ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce5:	89 04 24             	mov    %eax,(%esp)
  800ce8:	e8 37 f7 ff ff       	call   800424 <fd2num>
  800ced:	89 c3                	mov    %eax,%ebx
  800cef:	eb 05                	jmp    800cf6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cf1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cf6:	89 d8                	mov    %ebx,%eax
  800cf8:	83 c4 20             	add    $0x20,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d05:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0f:	e8 08 fd ff ff       	call   800a1c <fsipc>
}
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    
	...

00800d18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 10             	sub    $0x10,%esp
  800d20:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	89 04 24             	mov    %eax,(%esp)
  800d29:	e8 06 f7 ff ff       	call   800434 <fd2data>
  800d2e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d30:	c7 44 24 04 b7 20 80 	movl   $0x8020b7,0x4(%esp)
  800d37:	00 
  800d38:	89 34 24             	mov    %esi,(%esp)
  800d3b:	e8 97 0b 00 00       	call   8018d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d40:	8b 43 04             	mov    0x4(%ebx),%eax
  800d43:	2b 03                	sub    (%ebx),%eax
  800d45:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d4b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d52:	00 00 00 
	stat->st_dev = &devpipe;
  800d55:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d5c:	30 80 00 
	return 0;
}
  800d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 14             	sub    $0x14,%esp
  800d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d80:	e8 db f4 ff ff       	call   800260 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d85:	89 1c 24             	mov    %ebx,(%esp)
  800d88:	e8 a7 f6 ff ff       	call   800434 <fd2data>
  800d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d98:	e8 c3 f4 ff ff       	call   800260 <sys_page_unmap>
}
  800d9d:	83 c4 14             	add    $0x14,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
  800dac:	89 c7                	mov    %eax,%edi
  800dae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800db1:	a1 04 40 80 00       	mov    0x804004,%eax
  800db6:	8b 00                	mov    (%eax),%eax
  800db8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800dbb:	89 3c 24             	mov    %edi,(%esp)
  800dbe:	e8 51 0f 00 00       	call   801d14 <pageref>
  800dc3:	89 c6                	mov    %eax,%esi
  800dc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc8:	89 04 24             	mov    %eax,(%esp)
  800dcb:	e8 44 0f 00 00       	call   801d14 <pageref>
  800dd0:	39 c6                	cmp    %eax,%esi
  800dd2:	0f 94 c0             	sete   %al
  800dd5:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800dd8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800dde:	8b 12                	mov    (%edx),%edx
  800de0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800de3:	39 cb                	cmp    %ecx,%ebx
  800de5:	75 08                	jne    800def <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800de7:	83 c4 2c             	add    $0x2c,%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800def:	83 f8 01             	cmp    $0x1,%eax
  800df2:	75 bd                	jne    800db1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800df4:	8b 42 58             	mov    0x58(%edx),%eax
  800df7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800dfe:	00 
  800dff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e07:	c7 04 24 be 20 80 00 	movl   $0x8020be,(%esp)
  800e0e:	e8 19 05 00 00       	call   80132c <cprintf>
  800e13:	eb 9c                	jmp    800db1 <_pipeisclosed+0xe>

00800e15 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
  800e1b:	83 ec 1c             	sub    $0x1c,%esp
  800e1e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800e21:	89 34 24             	mov    %esi,(%esp)
  800e24:	e8 0b f6 ff ff       	call   800434 <fd2data>
  800e29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800e30:	eb 3c                	jmp    800e6e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e32:	89 da                	mov    %ebx,%edx
  800e34:	89 f0                	mov    %esi,%eax
  800e36:	e8 68 ff ff ff       	call   800da3 <_pipeisclosed>
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	75 38                	jne    800e77 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e3f:	e8 56 f3 ff ff       	call   80019a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e44:	8b 43 04             	mov    0x4(%ebx),%eax
  800e47:	8b 13                	mov    (%ebx),%edx
  800e49:	83 c2 20             	add    $0x20,%edx
  800e4c:	39 d0                	cmp    %edx,%eax
  800e4e:	73 e2                	jae    800e32 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e53:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e5e:	79 05                	jns    800e65 <devpipe_write+0x50>
  800e60:	4a                   	dec    %edx
  800e61:	83 ca e0             	or     $0xffffffe0,%edx
  800e64:	42                   	inc    %edx
  800e65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e69:	40                   	inc    %eax
  800e6a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e6d:	47                   	inc    %edi
  800e6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e71:	75 d1                	jne    800e44 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e73:	89 f8                	mov    %edi,%eax
  800e75:	eb 05                	jmp    800e7c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e7c:	83 c4 1c             	add    $0x1c,%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 1c             	sub    $0x1c,%esp
  800e8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e90:	89 3c 24             	mov    %edi,(%esp)
  800e93:	e8 9c f5 ff ff       	call   800434 <fd2data>
  800e98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e9a:	be 00 00 00 00       	mov    $0x0,%esi
  800e9f:	eb 3a                	jmp    800edb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ea1:	85 f6                	test   %esi,%esi
  800ea3:	74 04                	je     800ea9 <devpipe_read+0x25>
				return i;
  800ea5:	89 f0                	mov    %esi,%eax
  800ea7:	eb 40                	jmp    800ee9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ea9:	89 da                	mov    %ebx,%edx
  800eab:	89 f8                	mov    %edi,%eax
  800ead:	e8 f1 fe ff ff       	call   800da3 <_pipeisclosed>
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	75 2e                	jne    800ee4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800eb6:	e8 df f2 ff ff       	call   80019a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ebb:	8b 03                	mov    (%ebx),%eax
  800ebd:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ec0:	74 df                	je     800ea1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ec2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ec7:	79 05                	jns    800ece <devpipe_read+0x4a>
  800ec9:	48                   	dec    %eax
  800eca:	83 c8 e0             	or     $0xffffffe0,%eax
  800ecd:	40                   	inc    %eax
  800ece:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ed2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800ed8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800eda:	46                   	inc    %esi
  800edb:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ede:	75 db                	jne    800ebb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ee0:	89 f0                	mov    %esi,%eax
  800ee2:	eb 05                	jmp    800ee9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ee9:	83 c4 1c             	add    $0x1c,%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 3c             	sub    $0x3c,%esp
  800efa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800efd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f00:	89 04 24             	mov    %eax,(%esp)
  800f03:	e8 47 f5 ff ff       	call   80044f <fd_alloc>
  800f08:	89 c3                	mov    %eax,%ebx
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	0f 88 45 01 00 00    	js     801057 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f19:	00 
  800f1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f28:	e8 8c f2 ff ff       	call   8001b9 <sys_page_alloc>
  800f2d:	89 c3                	mov    %eax,%ebx
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	0f 88 20 01 00 00    	js     801057 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800f37:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f3a:	89 04 24             	mov    %eax,(%esp)
  800f3d:	e8 0d f5 ff ff       	call   80044f <fd_alloc>
  800f42:	89 c3                	mov    %eax,%ebx
  800f44:	85 c0                	test   %eax,%eax
  800f46:	0f 88 f8 00 00 00    	js     801044 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f4c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f53:	00 
  800f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f62:	e8 52 f2 ff ff       	call   8001b9 <sys_page_alloc>
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	0f 88 d3 00 00 00    	js     801044 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f74:	89 04 24             	mov    %eax,(%esp)
  800f77:	e8 b8 f4 ff ff       	call   800434 <fd2data>
  800f7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f85:	00 
  800f86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f91:	e8 23 f2 ff ff       	call   8001b9 <sys_page_alloc>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	0f 88 91 00 00 00    	js     801031 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa3:	89 04 24             	mov    %eax,(%esp)
  800fa6:	e8 89 f4 ff ff       	call   800434 <fd2data>
  800fab:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800fb2:	00 
  800fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbe:	00 
  800fbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fca:	e8 3e f2 ff ff       	call   80020d <sys_page_map>
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 4c                	js     801021 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800fd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fde:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fe0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800fea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800fff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801002:	89 04 24             	mov    %eax,(%esp)
  801005:	e8 1a f4 ff ff       	call   800424 <fd2num>
  80100a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80100c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80100f:	89 04 24             	mov    %eax,(%esp)
  801012:	e8 0d f4 ff ff       	call   800424 <fd2num>
  801017:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80101a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101f:	eb 36                	jmp    801057 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801021:	89 74 24 04          	mov    %esi,0x4(%esp)
  801025:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102c:	e8 2f f2 ff ff       	call   800260 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801031:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801034:	89 44 24 04          	mov    %eax,0x4(%esp)
  801038:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103f:	e8 1c f2 ff ff       	call   800260 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801052:	e8 09 f2 ff ff       	call   800260 <sys_page_unmap>
    err:
	return r;
}
  801057:	89 d8                	mov    %ebx,%eax
  801059:	83 c4 3c             	add    $0x3c,%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	89 04 24             	mov    %eax,(%esp)
  801074:	e8 29 f4 ff ff       	call   8004a2 <fd_lookup>
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 15                	js     801092 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80107d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801080:	89 04 24             	mov    %eax,(%esp)
  801083:	e8 ac f3 ff ff       	call   800434 <fd2data>
	return _pipeisclosed(fd, p);
  801088:	89 c2                	mov    %eax,%edx
  80108a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108d:	e8 11 fd ff ff       	call   800da3 <_pipeisclosed>
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801097:	b8 00 00 00 00       	mov    $0x0,%eax
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8010a4:	c7 44 24 04 d6 20 80 	movl   $0x8020d6,0x4(%esp)
  8010ab:	00 
  8010ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 20 08 00 00       	call   8018d7 <strcpy>
	return 0;
}
  8010b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8010cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010d5:	eb 30                	jmp    801107 <devcons_write+0x49>
		m = n - tot;
  8010d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8010da:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010dc:	83 fe 7f             	cmp    $0x7f,%esi
  8010df:	76 05                	jbe    8010e6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010e1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010ea:	03 45 0c             	add    0xc(%ebp),%eax
  8010ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f1:	89 3c 24             	mov    %edi,(%esp)
  8010f4:	e8 57 09 00 00       	call   801a50 <memmove>
		sys_cputs(buf, m);
  8010f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010fd:	89 3c 24             	mov    %edi,(%esp)
  801100:	e8 e7 ef ff ff       	call   8000ec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801105:	01 f3                	add    %esi,%ebx
  801107:	89 d8                	mov    %ebx,%eax
  801109:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80110c:	72 c9                	jb     8010d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80110e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80111f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801123:	75 07                	jne    80112c <devcons_read+0x13>
  801125:	eb 25                	jmp    80114c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801127:	e8 6e f0 ff ff       	call   80019a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80112c:	e8 d9 ef ff ff       	call   80010a <sys_cgetc>
  801131:	85 c0                	test   %eax,%eax
  801133:	74 f2                	je     801127 <devcons_read+0xe>
  801135:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801137:	85 c0                	test   %eax,%eax
  801139:	78 1d                	js     801158 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80113b:	83 f8 04             	cmp    $0x4,%eax
  80113e:	74 13                	je     801153 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801140:	8b 45 0c             	mov    0xc(%ebp),%eax
  801143:	88 10                	mov    %dl,(%eax)
	return 1;
  801145:	b8 01 00 00 00       	mov    $0x1,%eax
  80114a:	eb 0c                	jmp    801158 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80114c:	b8 00 00 00 00       	mov    $0x0,%eax
  801151:	eb 05                	jmp    801158 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801160:	8b 45 08             	mov    0x8(%ebp),%eax
  801163:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801166:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80116d:	00 
  80116e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801171:	89 04 24             	mov    %eax,(%esp)
  801174:	e8 73 ef ff ff       	call   8000ec <sys_cputs>
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <getchar>:

int
getchar(void)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801181:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801188:	00 
  801189:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80118c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801190:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801197:	e8 a4 f5 ff ff       	call   800740 <read>
	if (r < 0)
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 0f                	js     8011af <getchar+0x34>
		return r;
	if (r < 1)
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	7e 06                	jle    8011aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8011a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8011a8:	eb 05                	jmp    8011af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8011aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8011af:	c9                   	leave  
  8011b0:	c3                   	ret    

008011b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	89 04 24             	mov    %eax,(%esp)
  8011c4:	e8 d9 f2 ff ff       	call   8004a2 <fd_lookup>
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 11                	js     8011de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8011cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011d6:	39 10                	cmp    %edx,(%eax)
  8011d8:	0f 94 c0             	sete   %al
  8011db:	0f b6 c0             	movzbl %al,%eax
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <opencons>:

int
opencons(void)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	89 04 24             	mov    %eax,(%esp)
  8011ec:	e8 5e f2 ff ff       	call   80044f <fd_alloc>
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 3c                	js     801231 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8011f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011fc:	00 
  8011fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801200:	89 44 24 04          	mov    %eax,0x4(%esp)
  801204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120b:	e8 a9 ef ff ff       	call   8001b9 <sys_page_alloc>
  801210:	85 c0                	test   %eax,%eax
  801212:	78 1d                	js     801231 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801214:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80121a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80121f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801222:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801229:	89 04 24             	mov    %eax,(%esp)
  80122c:	e8 f3 f1 ff ff       	call   800424 <fd2num>
}
  801231:	c9                   	leave  
  801232:	c3                   	ret    
	...

00801234 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80123c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80123f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801245:	e8 31 ef ff ff       	call   80017b <sys_getenvid>
  80124a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801251:	8b 55 08             	mov    0x8(%ebp),%edx
  801254:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801258:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80125c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801260:	c7 04 24 e4 20 80 00 	movl   $0x8020e4,(%esp)
  801267:	e8 c0 00 00 00       	call   80132c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80126c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801270:	8b 45 10             	mov    0x10(%ebp),%eax
  801273:	89 04 24             	mov    %eax,(%esp)
  801276:	e8 50 00 00 00       	call   8012cb <vcprintf>
	cprintf("\n");
  80127b:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801282:	e8 a5 00 00 00       	call   80132c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801287:	cc                   	int3   
  801288:	eb fd                	jmp    801287 <_panic+0x53>
	...

0080128c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	53                   	push   %ebx
  801290:	83 ec 14             	sub    $0x14,%esp
  801293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801296:	8b 03                	mov    (%ebx),%eax
  801298:	8b 55 08             	mov    0x8(%ebp),%edx
  80129b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80129f:	40                   	inc    %eax
  8012a0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8012a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8012a7:	75 19                	jne    8012c2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8012a9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8012b0:	00 
  8012b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8012b4:	89 04 24             	mov    %eax,(%esp)
  8012b7:	e8 30 ee ff ff       	call   8000ec <sys_cputs>
		b->idx = 0;
  8012bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8012c2:	ff 43 04             	incl   0x4(%ebx)
}
  8012c5:	83 c4 14             	add    $0x14,%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8012d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012db:	00 00 00 
	b.cnt = 0;
  8012de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8012fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801300:	c7 04 24 8c 12 80 00 	movl   $0x80128c,(%esp)
  801307:	e8 82 01 00 00       	call   80148e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80130c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801312:	89 44 24 04          	mov    %eax,0x4(%esp)
  801316:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80131c:	89 04 24             	mov    %eax,(%esp)
  80131f:	e8 c8 ed ff ff       	call   8000ec <sys_cputs>

	return b.cnt;
}
  801324:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801332:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801335:	89 44 24 04          	mov    %eax,0x4(%esp)
  801339:	8b 45 08             	mov    0x8(%ebp),%eax
  80133c:	89 04 24             	mov    %eax,(%esp)
  80133f:	e8 87 ff ff ff       	call   8012cb <vcprintf>
	va_end(ap);

	return cnt;
}
  801344:	c9                   	leave  
  801345:	c3                   	ret    
	...

00801348 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	57                   	push   %edi
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 3c             	sub    $0x3c,%esp
  801351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801354:	89 d7                	mov    %edx,%edi
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80135c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801362:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801365:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801368:	85 c0                	test   %eax,%eax
  80136a:	75 08                	jne    801374 <printnum+0x2c>
  80136c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80136f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801372:	77 57                	ja     8013cb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801374:	89 74 24 10          	mov    %esi,0x10(%esp)
  801378:	4b                   	dec    %ebx
  801379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80137d:	8b 45 10             	mov    0x10(%ebp),%eax
  801380:	89 44 24 08          	mov    %eax,0x8(%esp)
  801384:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801388:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80138c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801393:	00 
  801394:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801397:	89 04 24             	mov    %eax,(%esp)
  80139a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80139d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a1:	e8 b2 09 00 00       	call   801d58 <__udivdi3>
  8013a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013ae:	89 04 24             	mov    %eax,(%esp)
  8013b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013b5:	89 fa                	mov    %edi,%edx
  8013b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013ba:	e8 89 ff ff ff       	call   801348 <printnum>
  8013bf:	eb 0f                	jmp    8013d0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8013c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013c5:	89 34 24             	mov    %esi,(%esp)
  8013c8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8013cb:	4b                   	dec    %ebx
  8013cc:	85 db                	test   %ebx,%ebx
  8013ce:	7f f1                	jg     8013c1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8013d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013e6:	00 
  8013e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013ea:	89 04 24             	mov    %eax,(%esp)
  8013ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f4:	e8 7f 0a 00 00       	call   801e78 <__umoddi3>
  8013f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013fd:	0f be 80 07 21 80 00 	movsbl 0x802107(%eax),%eax
  801404:	89 04 24             	mov    %eax,(%esp)
  801407:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80140a:	83 c4 3c             	add    $0x3c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801415:	83 fa 01             	cmp    $0x1,%edx
  801418:	7e 0e                	jle    801428 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80141a:	8b 10                	mov    (%eax),%edx
  80141c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80141f:	89 08                	mov    %ecx,(%eax)
  801421:	8b 02                	mov    (%edx),%eax
  801423:	8b 52 04             	mov    0x4(%edx),%edx
  801426:	eb 22                	jmp    80144a <getuint+0x38>
	else if (lflag)
  801428:	85 d2                	test   %edx,%edx
  80142a:	74 10                	je     80143c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80142c:	8b 10                	mov    (%eax),%edx
  80142e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801431:	89 08                	mov    %ecx,(%eax)
  801433:	8b 02                	mov    (%edx),%eax
  801435:	ba 00 00 00 00       	mov    $0x0,%edx
  80143a:	eb 0e                	jmp    80144a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80143c:	8b 10                	mov    (%eax),%edx
  80143e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801441:	89 08                	mov    %ecx,(%eax)
  801443:	8b 02                	mov    (%edx),%eax
  801445:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801452:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801455:	8b 10                	mov    (%eax),%edx
  801457:	3b 50 04             	cmp    0x4(%eax),%edx
  80145a:	73 08                	jae    801464 <sprintputch+0x18>
		*b->buf++ = ch;
  80145c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145f:	88 0a                	mov    %cl,(%edx)
  801461:	42                   	inc    %edx
  801462:	89 10                	mov    %edx,(%eax)
}
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80146c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80146f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801473:	8b 45 10             	mov    0x10(%ebp),%eax
  801476:	89 44 24 08          	mov    %eax,0x8(%esp)
  80147a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	8b 45 08             	mov    0x8(%ebp),%eax
  801484:	89 04 24             	mov    %eax,(%esp)
  801487:	e8 02 00 00 00       	call   80148e <vprintfmt>
	va_end(ap);
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
  801494:	83 ec 4c             	sub    $0x4c,%esp
  801497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149a:	8b 75 10             	mov    0x10(%ebp),%esi
  80149d:	eb 12                	jmp    8014b1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	0f 84 6b 03 00 00    	je     801812 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8014a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ab:	89 04 24             	mov    %eax,(%esp)
  8014ae:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8014b1:	0f b6 06             	movzbl (%esi),%eax
  8014b4:	46                   	inc    %esi
  8014b5:	83 f8 25             	cmp    $0x25,%eax
  8014b8:	75 e5                	jne    80149f <vprintfmt+0x11>
  8014ba:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8014be:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8014c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8014ca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8014d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014d6:	eb 26                	jmp    8014fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8014db:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014df:	eb 1d                	jmp    8014fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014e4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014e8:	eb 14                	jmp    8014fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8014f4:	eb 08                	jmp    8014fe <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8014f6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8014f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014fe:	0f b6 06             	movzbl (%esi),%eax
  801501:	8d 56 01             	lea    0x1(%esi),%edx
  801504:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801507:	8a 16                	mov    (%esi),%dl
  801509:	83 ea 23             	sub    $0x23,%edx
  80150c:	80 fa 55             	cmp    $0x55,%dl
  80150f:	0f 87 e1 02 00 00    	ja     8017f6 <vprintfmt+0x368>
  801515:	0f b6 d2             	movzbl %dl,%edx
  801518:	ff 24 95 40 22 80 00 	jmp    *0x802240(,%edx,4)
  80151f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801522:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801527:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80152a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80152e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801531:	8d 50 d0             	lea    -0x30(%eax),%edx
  801534:	83 fa 09             	cmp    $0x9,%edx
  801537:	77 2a                	ja     801563 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801539:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80153a:	eb eb                	jmp    801527 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80153c:	8b 45 14             	mov    0x14(%ebp),%eax
  80153f:	8d 50 04             	lea    0x4(%eax),%edx
  801542:	89 55 14             	mov    %edx,0x14(%ebp)
  801545:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801547:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80154a:	eb 17                	jmp    801563 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80154c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801550:	78 98                	js     8014ea <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801552:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801555:	eb a7                	jmp    8014fe <vprintfmt+0x70>
  801557:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80155a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801561:	eb 9b                	jmp    8014fe <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801567:	79 95                	jns    8014fe <vprintfmt+0x70>
  801569:	eb 8b                	jmp    8014f6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80156b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80156c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80156f:	eb 8d                	jmp    8014fe <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801571:	8b 45 14             	mov    0x14(%ebp),%eax
  801574:	8d 50 04             	lea    0x4(%eax),%edx
  801577:	89 55 14             	mov    %edx,0x14(%ebp)
  80157a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80157e:	8b 00                	mov    (%eax),%eax
  801580:	89 04 24             	mov    %eax,(%esp)
  801583:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801586:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801589:	e9 23 ff ff ff       	jmp    8014b1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80158e:	8b 45 14             	mov    0x14(%ebp),%eax
  801591:	8d 50 04             	lea    0x4(%eax),%edx
  801594:	89 55 14             	mov    %edx,0x14(%ebp)
  801597:	8b 00                	mov    (%eax),%eax
  801599:	85 c0                	test   %eax,%eax
  80159b:	79 02                	jns    80159f <vprintfmt+0x111>
  80159d:	f7 d8                	neg    %eax
  80159f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8015a1:	83 f8 0f             	cmp    $0xf,%eax
  8015a4:	7f 0b                	jg     8015b1 <vprintfmt+0x123>
  8015a6:	8b 04 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%eax
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	75 23                	jne    8015d4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8015b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015b5:	c7 44 24 08 1f 21 80 	movl   $0x80211f,0x8(%esp)
  8015bc:	00 
  8015bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	e8 9a fe ff ff       	call   801466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8015cf:	e9 dd fe ff ff       	jmp    8014b1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8015d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d8:	c7 44 24 08 9d 20 80 	movl   $0x80209d,0x8(%esp)
  8015df:	00 
  8015e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e7:	89 14 24             	mov    %edx,(%esp)
  8015ea:	e8 77 fe ff ff       	call   801466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015f2:	e9 ba fe ff ff       	jmp    8014b1 <vprintfmt+0x23>
  8015f7:	89 f9                	mov    %edi,%ecx
  8015f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8015ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801602:	8d 50 04             	lea    0x4(%eax),%edx
  801605:	89 55 14             	mov    %edx,0x14(%ebp)
  801608:	8b 30                	mov    (%eax),%esi
  80160a:	85 f6                	test   %esi,%esi
  80160c:	75 05                	jne    801613 <vprintfmt+0x185>
				p = "(null)";
  80160e:	be 18 21 80 00       	mov    $0x802118,%esi
			if (width > 0 && padc != '-')
  801613:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801617:	0f 8e 84 00 00 00    	jle    8016a1 <vprintfmt+0x213>
  80161d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801621:	74 7e                	je     8016a1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801623:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801627:	89 34 24             	mov    %esi,(%esp)
  80162a:	e8 8b 02 00 00       	call   8018ba <strnlen>
  80162f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801632:	29 c2                	sub    %eax,%edx
  801634:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801637:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80163b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80163e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801641:	89 de                	mov    %ebx,%esi
  801643:	89 d3                	mov    %edx,%ebx
  801645:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801647:	eb 0b                	jmp    801654 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164d:	89 3c 24             	mov    %edi,(%esp)
  801650:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801653:	4b                   	dec    %ebx
  801654:	85 db                	test   %ebx,%ebx
  801656:	7f f1                	jg     801649 <vprintfmt+0x1bb>
  801658:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80165b:	89 f3                	mov    %esi,%ebx
  80165d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801663:	85 c0                	test   %eax,%eax
  801665:	79 05                	jns    80166c <vprintfmt+0x1de>
  801667:	b8 00 00 00 00       	mov    $0x0,%eax
  80166c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80166f:	29 c2                	sub    %eax,%edx
  801671:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801674:	eb 2b                	jmp    8016a1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801676:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80167a:	74 18                	je     801694 <vprintfmt+0x206>
  80167c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80167f:	83 fa 5e             	cmp    $0x5e,%edx
  801682:	76 10                	jbe    801694 <vprintfmt+0x206>
					putch('?', putdat);
  801684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801688:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80168f:	ff 55 08             	call   *0x8(%ebp)
  801692:	eb 0a                	jmp    80169e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801698:	89 04 24             	mov    %eax,(%esp)
  80169b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80169e:	ff 4d e4             	decl   -0x1c(%ebp)
  8016a1:	0f be 06             	movsbl (%esi),%eax
  8016a4:	46                   	inc    %esi
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	74 21                	je     8016ca <vprintfmt+0x23c>
  8016a9:	85 ff                	test   %edi,%edi
  8016ab:	78 c9                	js     801676 <vprintfmt+0x1e8>
  8016ad:	4f                   	dec    %edi
  8016ae:	79 c6                	jns    801676 <vprintfmt+0x1e8>
  8016b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016b3:	89 de                	mov    %ebx,%esi
  8016b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016b8:	eb 18                	jmp    8016d2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8016ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8016c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8016c7:	4b                   	dec    %ebx
  8016c8:	eb 08                	jmp    8016d2 <vprintfmt+0x244>
  8016ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016cd:	89 de                	mov    %ebx,%esi
  8016cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016d2:	85 db                	test   %ebx,%ebx
  8016d4:	7f e4                	jg     8016ba <vprintfmt+0x22c>
  8016d6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8016d9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016de:	e9 ce fd ff ff       	jmp    8014b1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016e3:	83 f9 01             	cmp    $0x1,%ecx
  8016e6:	7e 10                	jle    8016f8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016eb:	8d 50 08             	lea    0x8(%eax),%edx
  8016ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8016f1:	8b 30                	mov    (%eax),%esi
  8016f3:	8b 78 04             	mov    0x4(%eax),%edi
  8016f6:	eb 26                	jmp    80171e <vprintfmt+0x290>
	else if (lflag)
  8016f8:	85 c9                	test   %ecx,%ecx
  8016fa:	74 12                	je     80170e <vprintfmt+0x280>
		return va_arg(*ap, long);
  8016fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ff:	8d 50 04             	lea    0x4(%eax),%edx
  801702:	89 55 14             	mov    %edx,0x14(%ebp)
  801705:	8b 30                	mov    (%eax),%esi
  801707:	89 f7                	mov    %esi,%edi
  801709:	c1 ff 1f             	sar    $0x1f,%edi
  80170c:	eb 10                	jmp    80171e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80170e:	8b 45 14             	mov    0x14(%ebp),%eax
  801711:	8d 50 04             	lea    0x4(%eax),%edx
  801714:	89 55 14             	mov    %edx,0x14(%ebp)
  801717:	8b 30                	mov    (%eax),%esi
  801719:	89 f7                	mov    %esi,%edi
  80171b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80171e:	85 ff                	test   %edi,%edi
  801720:	78 0a                	js     80172c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801722:	b8 0a 00 00 00       	mov    $0xa,%eax
  801727:	e9 8c 00 00 00       	jmp    8017b8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80172c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801730:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801737:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80173a:	f7 de                	neg    %esi
  80173c:	83 d7 00             	adc    $0x0,%edi
  80173f:	f7 df                	neg    %edi
			}
			base = 10;
  801741:	b8 0a 00 00 00       	mov    $0xa,%eax
  801746:	eb 70                	jmp    8017b8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801748:	89 ca                	mov    %ecx,%edx
  80174a:	8d 45 14             	lea    0x14(%ebp),%eax
  80174d:	e8 c0 fc ff ff       	call   801412 <getuint>
  801752:	89 c6                	mov    %eax,%esi
  801754:	89 d7                	mov    %edx,%edi
			base = 10;
  801756:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80175b:	eb 5b                	jmp    8017b8 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80175d:	89 ca                	mov    %ecx,%edx
  80175f:	8d 45 14             	lea    0x14(%ebp),%eax
  801762:	e8 ab fc ff ff       	call   801412 <getuint>
  801767:	89 c6                	mov    %eax,%esi
  801769:	89 d7                	mov    %edx,%edi
			base = 8;
  80176b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801770:	eb 46                	jmp    8017b8 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  801772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801776:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80177d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801784:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80178b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80178e:	8b 45 14             	mov    0x14(%ebp),%eax
  801791:	8d 50 04             	lea    0x4(%eax),%edx
  801794:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801797:	8b 30                	mov    (%eax),%esi
  801799:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80179e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8017a3:	eb 13                	jmp    8017b8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8017a5:	89 ca                	mov    %ecx,%edx
  8017a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8017aa:	e8 63 fc ff ff       	call   801412 <getuint>
  8017af:	89 c6                	mov    %eax,%esi
  8017b1:	89 d7                	mov    %edx,%edi
			base = 16;
  8017b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8017b8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8017bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017cb:	89 34 24             	mov    %esi,(%esp)
  8017ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017d2:	89 da                	mov    %ebx,%edx
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	e8 6c fb ff ff       	call   801348 <printnum>
			break;
  8017dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017df:	e9 cd fc ff ff       	jmp    8014b1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017f1:	e9 bb fc ff ff       	jmp    8014b1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801801:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801804:	eb 01                	jmp    801807 <vprintfmt+0x379>
  801806:	4e                   	dec    %esi
  801807:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80180b:	75 f9                	jne    801806 <vprintfmt+0x378>
  80180d:	e9 9f fc ff ff       	jmp    8014b1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801812:	83 c4 4c             	add    $0x4c,%esp
  801815:	5b                   	pop    %ebx
  801816:	5e                   	pop    %esi
  801817:	5f                   	pop    %edi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 28             	sub    $0x28,%esp
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801826:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801829:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80182d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801830:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801837:	85 c0                	test   %eax,%eax
  801839:	74 30                	je     80186b <vsnprintf+0x51>
  80183b:	85 d2                	test   %edx,%edx
  80183d:	7e 33                	jle    801872 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80183f:	8b 45 14             	mov    0x14(%ebp),%eax
  801842:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801846:	8b 45 10             	mov    0x10(%ebp),%eax
  801849:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801850:	89 44 24 04          	mov    %eax,0x4(%esp)
  801854:	c7 04 24 4c 14 80 00 	movl   $0x80144c,(%esp)
  80185b:	e8 2e fc ff ff       	call   80148e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801860:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801863:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801869:	eb 0c                	jmp    801877 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80186b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801870:	eb 05                	jmp    801877 <vsnprintf+0x5d>
  801872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80187f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801882:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801886:	8b 45 10             	mov    0x10(%ebp),%eax
  801889:	89 44 24 08          	mov    %eax,0x8(%esp)
  80188d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801890:	89 44 24 04          	mov    %eax,0x4(%esp)
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	89 04 24             	mov    %eax,(%esp)
  80189a:	e8 7b ff ff ff       	call   80181a <vsnprintf>
	va_end(ap);

	return rc;
}
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    
  8018a1:	00 00                	add    %al,(%eax)
	...

008018a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8018af:	eb 01                	jmp    8018b2 <strlen+0xe>
		n++;
  8018b1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8018b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8018b6:	75 f9                	jne    8018b1 <strlen+0xd>
		n++;
	return n;
}
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8018c0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c8:	eb 01                	jmp    8018cb <strnlen+0x11>
		n++;
  8018ca:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018cb:	39 d0                	cmp    %edx,%eax
  8018cd:	74 06                	je     8018d5 <strnlen+0x1b>
  8018cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8018d3:	75 f5                	jne    8018ca <strnlen+0x10>
		n++;
	return n;
}
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	53                   	push   %ebx
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018e9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018ec:	42                   	inc    %edx
  8018ed:	84 c9                	test   %cl,%cl
  8018ef:	75 f5                	jne    8018e6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018fe:	89 1c 24             	mov    %ebx,(%esp)
  801901:	e8 9e ff ff ff       	call   8018a4 <strlen>
	strcpy(dst + len, src);
  801906:	8b 55 0c             	mov    0xc(%ebp),%edx
  801909:	89 54 24 04          	mov    %edx,0x4(%esp)
  80190d:	01 d8                	add    %ebx,%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 c0 ff ff ff       	call   8018d7 <strcpy>
	return dst;
}
  801917:	89 d8                	mov    %ebx,%eax
  801919:	83 c4 08             	add    $0x8,%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	8b 45 08             	mov    0x8(%ebp),%eax
  801927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80192d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801932:	eb 0c                	jmp    801940 <strncpy+0x21>
		*dst++ = *src;
  801934:	8a 1a                	mov    (%edx),%bl
  801936:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801939:	80 3a 01             	cmpb   $0x1,(%edx)
  80193c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80193f:	41                   	inc    %ecx
  801940:	39 f1                	cmp    %esi,%ecx
  801942:	75 f0                	jne    801934 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	8b 75 08             	mov    0x8(%ebp),%esi
  801950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801953:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801956:	85 d2                	test   %edx,%edx
  801958:	75 0a                	jne    801964 <strlcpy+0x1c>
  80195a:	89 f0                	mov    %esi,%eax
  80195c:	eb 1a                	jmp    801978 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80195e:	88 18                	mov    %bl,(%eax)
  801960:	40                   	inc    %eax
  801961:	41                   	inc    %ecx
  801962:	eb 02                	jmp    801966 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801964:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801966:	4a                   	dec    %edx
  801967:	74 0a                	je     801973 <strlcpy+0x2b>
  801969:	8a 19                	mov    (%ecx),%bl
  80196b:	84 db                	test   %bl,%bl
  80196d:	75 ef                	jne    80195e <strlcpy+0x16>
  80196f:	89 c2                	mov    %eax,%edx
  801971:	eb 02                	jmp    801975 <strlcpy+0x2d>
  801973:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801975:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801978:	29 f0                	sub    %esi,%eax
}
  80197a:	5b                   	pop    %ebx
  80197b:	5e                   	pop    %esi
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801984:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801987:	eb 02                	jmp    80198b <strcmp+0xd>
		p++, q++;
  801989:	41                   	inc    %ecx
  80198a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80198b:	8a 01                	mov    (%ecx),%al
  80198d:	84 c0                	test   %al,%al
  80198f:	74 04                	je     801995 <strcmp+0x17>
  801991:	3a 02                	cmp    (%edx),%al
  801993:	74 f4                	je     801989 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801995:	0f b6 c0             	movzbl %al,%eax
  801998:	0f b6 12             	movzbl (%edx),%edx
  80199b:	29 d0                	sub    %edx,%eax
}
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	53                   	push   %ebx
  8019a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8019ac:	eb 03                	jmp    8019b1 <strncmp+0x12>
		n--, p++, q++;
  8019ae:	4a                   	dec    %edx
  8019af:	40                   	inc    %eax
  8019b0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8019b1:	85 d2                	test   %edx,%edx
  8019b3:	74 14                	je     8019c9 <strncmp+0x2a>
  8019b5:	8a 18                	mov    (%eax),%bl
  8019b7:	84 db                	test   %bl,%bl
  8019b9:	74 04                	je     8019bf <strncmp+0x20>
  8019bb:	3a 19                	cmp    (%ecx),%bl
  8019bd:	74 ef                	je     8019ae <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8019bf:	0f b6 00             	movzbl (%eax),%eax
  8019c2:	0f b6 11             	movzbl (%ecx),%edx
  8019c5:	29 d0                	sub    %edx,%eax
  8019c7:	eb 05                	jmp    8019ce <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8019c9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8019ce:	5b                   	pop    %ebx
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019da:	eb 05                	jmp    8019e1 <strchr+0x10>
		if (*s == c)
  8019dc:	38 ca                	cmp    %cl,%dl
  8019de:	74 0c                	je     8019ec <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019e0:	40                   	inc    %eax
  8019e1:	8a 10                	mov    (%eax),%dl
  8019e3:	84 d2                	test   %dl,%dl
  8019e5:	75 f5                	jne    8019dc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019f7:	eb 05                	jmp    8019fe <strfind+0x10>
		if (*s == c)
  8019f9:	38 ca                	cmp    %cl,%dl
  8019fb:	74 07                	je     801a04 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8019fd:	40                   	inc    %eax
  8019fe:	8a 10                	mov    (%eax),%dl
  801a00:	84 d2                	test   %dl,%dl
  801a02:	75 f5                	jne    8019f9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	57                   	push   %edi
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801a15:	85 c9                	test   %ecx,%ecx
  801a17:	74 30                	je     801a49 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801a19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a1f:	75 25                	jne    801a46 <memset+0x40>
  801a21:	f6 c1 03             	test   $0x3,%cl
  801a24:	75 20                	jne    801a46 <memset+0x40>
		c &= 0xFF;
  801a26:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801a29:	89 d3                	mov    %edx,%ebx
  801a2b:	c1 e3 08             	shl    $0x8,%ebx
  801a2e:	89 d6                	mov    %edx,%esi
  801a30:	c1 e6 18             	shl    $0x18,%esi
  801a33:	89 d0                	mov    %edx,%eax
  801a35:	c1 e0 10             	shl    $0x10,%eax
  801a38:	09 f0                	or     %esi,%eax
  801a3a:	09 d0                	or     %edx,%eax
  801a3c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a3e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a41:	fc                   	cld    
  801a42:	f3 ab                	rep stos %eax,%es:(%edi)
  801a44:	eb 03                	jmp    801a49 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a46:	fc                   	cld    
  801a47:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a49:	89 f8                	mov    %edi,%eax
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5f                   	pop    %edi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a5e:	39 c6                	cmp    %eax,%esi
  801a60:	73 34                	jae    801a96 <memmove+0x46>
  801a62:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a65:	39 d0                	cmp    %edx,%eax
  801a67:	73 2d                	jae    801a96 <memmove+0x46>
		s += n;
		d += n;
  801a69:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a6c:	f6 c2 03             	test   $0x3,%dl
  801a6f:	75 1b                	jne    801a8c <memmove+0x3c>
  801a71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a77:	75 13                	jne    801a8c <memmove+0x3c>
  801a79:	f6 c1 03             	test   $0x3,%cl
  801a7c:	75 0e                	jne    801a8c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a7e:	83 ef 04             	sub    $0x4,%edi
  801a81:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a84:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a87:	fd                   	std    
  801a88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a8a:	eb 07                	jmp    801a93 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a8c:	4f                   	dec    %edi
  801a8d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a90:	fd                   	std    
  801a91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a93:	fc                   	cld    
  801a94:	eb 20                	jmp    801ab6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a9c:	75 13                	jne    801ab1 <memmove+0x61>
  801a9e:	a8 03                	test   $0x3,%al
  801aa0:	75 0f                	jne    801ab1 <memmove+0x61>
  801aa2:	f6 c1 03             	test   $0x3,%cl
  801aa5:	75 0a                	jne    801ab1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801aa7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801aaa:	89 c7                	mov    %eax,%edi
  801aac:	fc                   	cld    
  801aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801aaf:	eb 05                	jmp    801ab6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ab1:	89 c7                	mov    %eax,%edi
  801ab3:	fc                   	cld    
  801ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801ac0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aca:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	89 04 24             	mov    %eax,(%esp)
  801ad4:	e8 77 ff ff ff       	call   801a50 <memmove>
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	57                   	push   %edi
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801aea:	ba 00 00 00 00       	mov    $0x0,%edx
  801aef:	eb 16                	jmp    801b07 <memcmp+0x2c>
		if (*s1 != *s2)
  801af1:	8a 04 17             	mov    (%edi,%edx,1),%al
  801af4:	42                   	inc    %edx
  801af5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801af9:	38 c8                	cmp    %cl,%al
  801afb:	74 0a                	je     801b07 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801afd:	0f b6 c0             	movzbl %al,%eax
  801b00:	0f b6 c9             	movzbl %cl,%ecx
  801b03:	29 c8                	sub    %ecx,%eax
  801b05:	eb 09                	jmp    801b10 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801b07:	39 da                	cmp    %ebx,%edx
  801b09:	75 e6                	jne    801af1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5f                   	pop    %edi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801b1e:	89 c2                	mov    %eax,%edx
  801b20:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801b23:	eb 05                	jmp    801b2a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801b25:	38 08                	cmp    %cl,(%eax)
  801b27:	74 05                	je     801b2e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801b29:	40                   	inc    %eax
  801b2a:	39 d0                	cmp    %edx,%eax
  801b2c:	72 f7                	jb     801b25 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	57                   	push   %edi
  801b34:	56                   	push   %esi
  801b35:	53                   	push   %ebx
  801b36:	8b 55 08             	mov    0x8(%ebp),%edx
  801b39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b3c:	eb 01                	jmp    801b3f <strtol+0xf>
		s++;
  801b3e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b3f:	8a 02                	mov    (%edx),%al
  801b41:	3c 20                	cmp    $0x20,%al
  801b43:	74 f9                	je     801b3e <strtol+0xe>
  801b45:	3c 09                	cmp    $0x9,%al
  801b47:	74 f5                	je     801b3e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b49:	3c 2b                	cmp    $0x2b,%al
  801b4b:	75 08                	jne    801b55 <strtol+0x25>
		s++;
  801b4d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b4e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b53:	eb 13                	jmp    801b68 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b55:	3c 2d                	cmp    $0x2d,%al
  801b57:	75 0a                	jne    801b63 <strtol+0x33>
		s++, neg = 1;
  801b59:	8d 52 01             	lea    0x1(%edx),%edx
  801b5c:	bf 01 00 00 00       	mov    $0x1,%edi
  801b61:	eb 05                	jmp    801b68 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b68:	85 db                	test   %ebx,%ebx
  801b6a:	74 05                	je     801b71 <strtol+0x41>
  801b6c:	83 fb 10             	cmp    $0x10,%ebx
  801b6f:	75 28                	jne    801b99 <strtol+0x69>
  801b71:	8a 02                	mov    (%edx),%al
  801b73:	3c 30                	cmp    $0x30,%al
  801b75:	75 10                	jne    801b87 <strtol+0x57>
  801b77:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b7b:	75 0a                	jne    801b87 <strtol+0x57>
		s += 2, base = 16;
  801b7d:	83 c2 02             	add    $0x2,%edx
  801b80:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b85:	eb 12                	jmp    801b99 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b87:	85 db                	test   %ebx,%ebx
  801b89:	75 0e                	jne    801b99 <strtol+0x69>
  801b8b:	3c 30                	cmp    $0x30,%al
  801b8d:	75 05                	jne    801b94 <strtol+0x64>
		s++, base = 8;
  801b8f:	42                   	inc    %edx
  801b90:	b3 08                	mov    $0x8,%bl
  801b92:	eb 05                	jmp    801b99 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b94:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ba0:	8a 0a                	mov    (%edx),%cl
  801ba2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801ba5:	80 fb 09             	cmp    $0x9,%bl
  801ba8:	77 08                	ja     801bb2 <strtol+0x82>
			dig = *s - '0';
  801baa:	0f be c9             	movsbl %cl,%ecx
  801bad:	83 e9 30             	sub    $0x30,%ecx
  801bb0:	eb 1e                	jmp    801bd0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801bb2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801bb5:	80 fb 19             	cmp    $0x19,%bl
  801bb8:	77 08                	ja     801bc2 <strtol+0x92>
			dig = *s - 'a' + 10;
  801bba:	0f be c9             	movsbl %cl,%ecx
  801bbd:	83 e9 57             	sub    $0x57,%ecx
  801bc0:	eb 0e                	jmp    801bd0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801bc2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801bc5:	80 fb 19             	cmp    $0x19,%bl
  801bc8:	77 12                	ja     801bdc <strtol+0xac>
			dig = *s - 'A' + 10;
  801bca:	0f be c9             	movsbl %cl,%ecx
  801bcd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801bd0:	39 f1                	cmp    %esi,%ecx
  801bd2:	7d 0c                	jge    801be0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801bd4:	42                   	inc    %edx
  801bd5:	0f af c6             	imul   %esi,%eax
  801bd8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801bda:	eb c4                	jmp    801ba0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801bdc:	89 c1                	mov    %eax,%ecx
  801bde:	eb 02                	jmp    801be2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801be0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801be2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801be6:	74 05                	je     801bed <strtol+0xbd>
		*endptr = (char *) s;
  801be8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801beb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bed:	85 ff                	test   %edi,%edi
  801bef:	74 04                	je     801bf5 <strtol+0xc5>
  801bf1:	89 c8                	mov    %ecx,%eax
  801bf3:	f7 d8                	neg    %eax
}
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
	...

00801bfc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 10             	sub    $0x10,%esp
  801c04:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	75 05                	jne    801c16 <ipc_recv+0x1a>
  801c11:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801c16:	89 04 24             	mov    %eax,(%esp)
  801c19:	e8 b1 e7 ff ff       	call   8003cf <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	79 16                	jns    801c38 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801c22:	85 db                	test   %ebx,%ebx
  801c24:	74 06                	je     801c2c <ipc_recv+0x30>
  801c26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801c2c:	85 f6                	test   %esi,%esi
  801c2e:	74 32                	je     801c62 <ipc_recv+0x66>
  801c30:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c36:	eb 2a                	jmp    801c62 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c38:	85 db                	test   %ebx,%ebx
  801c3a:	74 0c                	je     801c48 <ipc_recv+0x4c>
  801c3c:	a1 04 40 80 00       	mov    0x804004,%eax
  801c41:	8b 00                	mov    (%eax),%eax
  801c43:	8b 40 74             	mov    0x74(%eax),%eax
  801c46:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c48:	85 f6                	test   %esi,%esi
  801c4a:	74 0c                	je     801c58 <ipc_recv+0x5c>
  801c4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801c51:	8b 00                	mov    (%eax),%eax
  801c53:	8b 40 78             	mov    0x78(%eax),%eax
  801c56:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c58:	a1 04 40 80 00       	mov    0x804004,%eax
  801c5d:	8b 00                	mov    (%eax),%eax
  801c5f:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	57                   	push   %edi
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 1c             	sub    $0x1c,%esp
  801c72:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c78:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c7b:	85 db                	test   %ebx,%ebx
  801c7d:	75 05                	jne    801c84 <ipc_send+0x1b>
  801c7f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c84:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c8c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	89 04 24             	mov    %eax,(%esp)
  801c96:	e8 11 e7 ff ff       	call   8003ac <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c9b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c9e:	75 07                	jne    801ca7 <ipc_send+0x3e>
  801ca0:	e8 f5 e4 ff ff       	call   80019a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801ca5:	eb dd                	jmp    801c84 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	79 1c                	jns    801cc7 <ipc_send+0x5e>
  801cab:	c7 44 24 08 00 24 80 	movl   $0x802400,0x8(%esp)
  801cb2:	00 
  801cb3:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801cba:	00 
  801cbb:	c7 04 24 12 24 80 00 	movl   $0x802412,(%esp)
  801cc2:	e8 6d f5 ff ff       	call   801234 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801cc7:	83 c4 1c             	add    $0x1c,%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5f                   	pop    %edi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	53                   	push   %ebx
  801cd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cd6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cdb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	c1 e2 07             	shl    $0x7,%edx
  801ce7:	29 ca                	sub    %ecx,%edx
  801ce9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cef:	8b 52 50             	mov    0x50(%edx),%edx
  801cf2:	39 da                	cmp    %ebx,%edx
  801cf4:	75 0f                	jne    801d05 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cf6:	c1 e0 07             	shl    $0x7,%eax
  801cf9:	29 c8                	sub    %ecx,%eax
  801cfb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d00:	8b 40 40             	mov    0x40(%eax),%eax
  801d03:	eb 0c                	jmp    801d11 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d05:	40                   	inc    %eax
  801d06:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d0b:	75 ce                	jne    801cdb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d0d:	66 b8 00 00          	mov    $0x0,%ax
}
  801d11:	5b                   	pop    %ebx
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801d1a:	89 c2                	mov    %eax,%edx
  801d1c:	c1 ea 16             	shr    $0x16,%edx
  801d1f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d26:	f6 c2 01             	test   $0x1,%dl
  801d29:	74 1e                	je     801d49 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d2b:	c1 e8 0c             	shr    $0xc,%eax
  801d2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d35:	a8 01                	test   $0x1,%al
  801d37:	74 17                	je     801d50 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d39:	c1 e8 0c             	shr    $0xc,%eax
  801d3c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d43:	ef 
  801d44:	0f b7 c0             	movzwl %ax,%eax
  801d47:	eb 0c                	jmp    801d55 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4e:	eb 05                	jmp    801d55 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    
	...

00801d58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d58:	55                   	push   %ebp
  801d59:	57                   	push   %edi
  801d5a:	56                   	push   %esi
  801d5b:	83 ec 10             	sub    $0x10,%esp
  801d5e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d6e:	89 cd                	mov    %ecx,%ebp
  801d70:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d74:	85 c0                	test   %eax,%eax
  801d76:	75 2c                	jne    801da4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d78:	39 f9                	cmp    %edi,%ecx
  801d7a:	77 68                	ja     801de4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d7c:	85 c9                	test   %ecx,%ecx
  801d7e:	75 0b                	jne    801d8b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d80:	b8 01 00 00 00       	mov    $0x1,%eax
  801d85:	31 d2                	xor    %edx,%edx
  801d87:	f7 f1                	div    %ecx
  801d89:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	89 f8                	mov    %edi,%eax
  801d8f:	f7 f1                	div    %ecx
  801d91:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	f7 f1                	div    %ecx
  801d97:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d99:	89 f0                	mov    %esi,%eax
  801d9b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801da4:	39 f8                	cmp    %edi,%eax
  801da6:	77 2c                	ja     801dd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801da8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801dab:	83 f6 1f             	xor    $0x1f,%esi
  801dae:	75 4c                	jne    801dfc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801db0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801db2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801db7:	72 0a                	jb     801dc3 <__udivdi3+0x6b>
  801db9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801dbd:	0f 87 ad 00 00 00    	ja     801e70 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dc3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dc8:	89 f0                	mov    %esi,%eax
  801dca:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    
  801dd3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dd4:	31 ff                	xor    %edi,%edi
  801dd6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dd8:	89 f0                	mov    %esi,%eax
  801dda:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
  801de3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801de4:	89 fa                	mov    %edi,%edx
  801de6:	89 f0                	mov    %esi,%eax
  801de8:	f7 f1                	div    %ecx
  801dea:	89 c6                	mov    %eax,%esi
  801dec:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    
  801df9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dfc:	89 f1                	mov    %esi,%ecx
  801dfe:	d3 e0                	shl    %cl,%eax
  801e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e04:	b8 20 00 00 00       	mov    $0x20,%eax
  801e09:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e0b:	89 ea                	mov    %ebp,%edx
  801e0d:	88 c1                	mov    %al,%cl
  801e0f:	d3 ea                	shr    %cl,%edx
  801e11:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e15:	09 ca                	or     %ecx,%edx
  801e17:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801e1b:	89 f1                	mov    %esi,%ecx
  801e1d:	d3 e5                	shl    %cl,%ebp
  801e1f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801e23:	89 fd                	mov    %edi,%ebp
  801e25:	88 c1                	mov    %al,%cl
  801e27:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e29:	89 fa                	mov    %edi,%edx
  801e2b:	89 f1                	mov    %esi,%ecx
  801e2d:	d3 e2                	shl    %cl,%edx
  801e2f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e33:	88 c1                	mov    %al,%cl
  801e35:	d3 ef                	shr    %cl,%edi
  801e37:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e39:	89 f8                	mov    %edi,%eax
  801e3b:	89 ea                	mov    %ebp,%edx
  801e3d:	f7 74 24 08          	divl   0x8(%esp)
  801e41:	89 d1                	mov    %edx,%ecx
  801e43:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e45:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e49:	39 d1                	cmp    %edx,%ecx
  801e4b:	72 17                	jb     801e64 <__udivdi3+0x10c>
  801e4d:	74 09                	je     801e58 <__udivdi3+0x100>
  801e4f:	89 fe                	mov    %edi,%esi
  801e51:	31 ff                	xor    %edi,%edi
  801e53:	e9 41 ff ff ff       	jmp    801d99 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e58:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e5c:	89 f1                	mov    %esi,%ecx
  801e5e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e60:	39 c2                	cmp    %eax,%edx
  801e62:	73 eb                	jae    801e4f <__udivdi3+0xf7>
		{
		  q0--;
  801e64:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e67:	31 ff                	xor    %edi,%edi
  801e69:	e9 2b ff ff ff       	jmp    801d99 <__udivdi3+0x41>
  801e6e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e70:	31 f6                	xor    %esi,%esi
  801e72:	e9 22 ff ff ff       	jmp    801d99 <__udivdi3+0x41>
	...

00801e78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e78:	55                   	push   %ebp
  801e79:	57                   	push   %edi
  801e7a:	56                   	push   %esi
  801e7b:	83 ec 20             	sub    $0x20,%esp
  801e7e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e82:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e86:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e8a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e92:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e96:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e98:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e9a:	85 ed                	test   %ebp,%ebp
  801e9c:	75 16                	jne    801eb4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e9e:	39 f1                	cmp    %esi,%ecx
  801ea0:	0f 86 a6 00 00 00    	jbe    801f4c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ea6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ea8:	89 d0                	mov    %edx,%eax
  801eaa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801eac:	83 c4 20             	add    $0x20,%esp
  801eaf:	5e                   	pop    %esi
  801eb0:	5f                   	pop    %edi
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    
  801eb3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801eb4:	39 f5                	cmp    %esi,%ebp
  801eb6:	0f 87 ac 00 00 00    	ja     801f68 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ebc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801ebf:	83 f0 1f             	xor    $0x1f,%eax
  801ec2:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ec6:	0f 84 a8 00 00 00    	je     801f74 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ecc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ed0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ed2:	bf 20 00 00 00       	mov    $0x20,%edi
  801ed7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801edb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801edf:	89 f9                	mov    %edi,%ecx
  801ee1:	d3 e8                	shr    %cl,%eax
  801ee3:	09 e8                	or     %ebp,%eax
  801ee5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ee9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eed:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ef1:	d3 e0                	shl    %cl,%eax
  801ef3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ef7:	89 f2                	mov    %esi,%edx
  801ef9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801efb:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eff:	d3 e0                	shl    %cl,%eax
  801f01:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f05:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f09:	89 f9                	mov    %edi,%ecx
  801f0b:	d3 e8                	shr    %cl,%eax
  801f0d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f0f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f11:	89 f2                	mov    %esi,%edx
  801f13:	f7 74 24 18          	divl   0x18(%esp)
  801f17:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f19:	f7 64 24 0c          	mull   0xc(%esp)
  801f1d:	89 c5                	mov    %eax,%ebp
  801f1f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f21:	39 d6                	cmp    %edx,%esi
  801f23:	72 67                	jb     801f8c <__umoddi3+0x114>
  801f25:	74 75                	je     801f9c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f27:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f2b:	29 e8                	sub    %ebp,%eax
  801f2d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f2f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f33:	d3 e8                	shr    %cl,%eax
  801f35:	89 f2                	mov    %esi,%edx
  801f37:	89 f9                	mov    %edi,%ecx
  801f39:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f3b:	09 d0                	or     %edx,%eax
  801f3d:	89 f2                	mov    %esi,%edx
  801f3f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f43:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f45:	83 c4 20             	add    $0x20,%esp
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f4c:	85 c9                	test   %ecx,%ecx
  801f4e:	75 0b                	jne    801f5b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f50:	b8 01 00 00 00       	mov    $0x1,%eax
  801f55:	31 d2                	xor    %edx,%edx
  801f57:	f7 f1                	div    %ecx
  801f59:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f5b:	89 f0                	mov    %esi,%eax
  801f5d:	31 d2                	xor    %edx,%edx
  801f5f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f61:	89 f8                	mov    %edi,%eax
  801f63:	e9 3e ff ff ff       	jmp    801ea6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f68:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f6a:	83 c4 20             	add    $0x20,%esp
  801f6d:	5e                   	pop    %esi
  801f6e:	5f                   	pop    %edi
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    
  801f71:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f74:	39 f5                	cmp    %esi,%ebp
  801f76:	72 04                	jb     801f7c <__umoddi3+0x104>
  801f78:	39 f9                	cmp    %edi,%ecx
  801f7a:	77 06                	ja     801f82 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f7c:	89 f2                	mov    %esi,%edx
  801f7e:	29 cf                	sub    %ecx,%edi
  801f80:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f82:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f84:	83 c4 20             	add    $0x20,%esp
  801f87:	5e                   	pop    %esi
  801f88:	5f                   	pop    %edi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    
  801f8b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f8c:	89 d1                	mov    %edx,%ecx
  801f8e:	89 c5                	mov    %eax,%ebp
  801f90:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f94:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f98:	eb 8d                	jmp    801f27 <__umoddi3+0xaf>
  801f9a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f9c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fa0:	72 ea                	jb     801f8c <__umoddi3+0x114>
  801fa2:	89 f1                	mov    %esi,%ecx
  801fa4:	eb 81                	jmp    801f27 <__umoddi3+0xaf>
