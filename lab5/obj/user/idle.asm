
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 30 80 00 80 	movl   $0x801f80,0x803000
  800041:	1f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 25 01 00 00       	call   80016e <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	83 ec 20             	sub    $0x20,%esp
  800054:	8b 75 08             	mov    0x8(%ebp),%esi
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80005a:	e8 f0 00 00 00       	call   80014f <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006b:	c1 e0 07             	shl    $0x7,%eax
  80006e:	29 d0                	sub    %edx,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 f6                	test   %esi,%esi
  800082:	7e 07                	jle    80008b <libmain+0x3f>
		binaryname = argv[0];
  800084:	8b 03                	mov    (%ebx),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	89 34 24             	mov    %esi,(%esp)
  800092:	e8 9d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800097:	e8 08 00 00 00       	call   8000a4 <exit>
}
  80009c:	83 c4 20             	add    $0x20,%esp
  80009f:	5b                   	pop    %ebx
  8000a0:	5e                   	pop    %esi
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 32 05 00 00       	call   8005e1 <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 42 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	89 cb                	mov    %ecx,%ebx
  800115:	89 cf                	mov    %ecx,%edi
  800117:	89 ce                	mov    %ecx,%esi
  800119:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	7e 28                	jle    800147 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800123:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012a:	00 
  80012b:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  800142:	e8 c1 10 00 00       	call   801208 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800147:	83 c4 2c             	add    $0x2c,%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_yield>:

void
sys_yield(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800196:	be 00 00 00 00       	mov    $0x0,%esi
  80019b:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	89 f7                	mov    %esi,%edi
  8001ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ad:	85 c0                	test   %eax,%eax
  8001af:	7e 28                	jle    8001d9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  8001d4:	e8 2f 10 00 00       	call   801208 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d9:	83 c4 2c             	add    $0x2c,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7e 28                	jle    80022c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	89 44 24 10          	mov    %eax,0x10(%esp)
  800208:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020f:	00 
  800210:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021f:	00 
  800220:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  800227:	e8 dc 0f 00 00       	call   801208 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80022c:	83 c4 2c             	add    $0x2c,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	b8 06 00 00 00       	mov    $0x6,%eax
  800247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 df                	mov    %ebx,%edi
  80024f:	89 de                	mov    %ebx,%esi
  800251:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800253:	85 c0                	test   %eax,%eax
  800255:	7e 28                	jle    80027f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800257:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800262:	00 
  800263:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  80026a:	00 
  80026b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800272:	00 
  800273:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  80027a:	e8 89 0f 00 00       	call   801208 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027f:	83 c4 2c             	add    $0x2c,%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	b8 08 00 00 00       	mov    $0x8,%eax
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7e 28                	jle    8002d2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  8002cd:	e8 36 0f 00 00       	call   801208 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d2:	83 c4 2c             	add    $0x2c,%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	89 df                	mov    %ebx,%edi
  8002f5:	89 de                	mov    %ebx,%esi
  8002f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	7e 28                	jle    800325 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800301:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800308:	00 
  800309:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  800320:	e8 e3 0e 00 00       	call   801208 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800325:	83 c4 2c             	add    $0x2c,%esp
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800336:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	89 df                	mov    %ebx,%edi
  800348:	89 de                	mov    %ebx,%esi
  80034a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	7e 28                	jle    800378 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800350:	89 44 24 10          	mov    %eax,0x10(%esp)
  800354:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80035b:	00 
  80035c:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  800363:	00 
  800364:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036b:	00 
  80036c:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  800373:	e8 90 0e 00 00       	call   801208 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800378:	83 c4 2c             	add    $0x2c,%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800386:	be 00 00 00 00       	mov    $0x0,%esi
  80038b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800390:	8b 7d 14             	mov    0x14(%ebp),%edi
  800393:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800396:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b9:	89 cb                	mov    %ecx,%ebx
  8003bb:	89 cf                	mov    %ecx,%edi
  8003bd:	89 ce                	mov    %ecx,%esi
  8003bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	7e 28                	jle    8003ed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 08 8f 1f 80 	movl   $0x801f8f,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 ac 1f 80 00 	movl   $0x801fac,(%esp)
  8003e8:	e8 1b 0e 00 00       	call   801208 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003ed:	83 c4 2c             	add    $0x2c,%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    
  8003f5:	00 00                	add    %al,(%eax)
	...

008003f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	05 00 00 00 30       	add    $0x30000000,%eax
  800403:	c1 e8 0c             	shr    $0xc,%eax
}
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	89 04 24             	mov    %eax,(%esp)
  800414:	e8 df ff ff ff       	call   8003f8 <fd2num>
  800419:	05 20 00 0d 00       	add    $0xd0020,%eax
  80041e:	c1 e0 0c             	shl    $0xc,%eax
}
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	53                   	push   %ebx
  800427:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80042a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80042f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800431:	89 c2                	mov    %eax,%edx
  800433:	c1 ea 16             	shr    $0x16,%edx
  800436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043d:	f6 c2 01             	test   $0x1,%dl
  800440:	74 11                	je     800453 <fd_alloc+0x30>
  800442:	89 c2                	mov    %eax,%edx
  800444:	c1 ea 0c             	shr    $0xc,%edx
  800447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044e:	f6 c2 01             	test   $0x1,%dl
  800451:	75 09                	jne    80045c <fd_alloc+0x39>
			*fd_store = fd;
  800453:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	eb 17                	jmp    800473 <fd_alloc+0x50>
  80045c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800461:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800466:	75 c7                	jne    80042f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800468:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80046e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800473:	5b                   	pop    %ebx
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80047c:	83 f8 1f             	cmp    $0x1f,%eax
  80047f:	77 36                	ja     8004b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800481:	05 00 00 0d 00       	add    $0xd0000,%eax
  800486:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800489:	89 c2                	mov    %eax,%edx
  80048b:	c1 ea 16             	shr    $0x16,%edx
  80048e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800495:	f6 c2 01             	test   $0x1,%dl
  800498:	74 24                	je     8004be <fd_lookup+0x48>
  80049a:	89 c2                	mov    %eax,%edx
  80049c:	c1 ea 0c             	shr    $0xc,%edx
  80049f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004a6:	f6 c2 01             	test   $0x1,%dl
  8004a9:	74 1a                	je     8004c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8004b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b5:	eb 13                	jmp    8004ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004bc:	eb 0c                	jmp    8004ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c3:	eb 05                	jmp    8004ca <fd_lookup+0x54>
  8004c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	53                   	push   %ebx
  8004d0:	83 ec 14             	sub    $0x14,%esp
  8004d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	eb 0e                	jmp    8004ee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004e0:	39 08                	cmp    %ecx,(%eax)
  8004e2:	75 09                	jne    8004ed <dev_lookup+0x21>
			*dev = devtab[i];
  8004e4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	eb 35                	jmp    800522 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004ed:	42                   	inc    %edx
  8004ee:	8b 04 95 38 20 80 00 	mov    0x802038(,%edx,4),%eax
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	75 e7                	jne    8004e0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	8b 40 48             	mov    0x48(%eax),%eax
  800503:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	c7 04 24 bc 1f 80 00 	movl   $0x801fbc,(%esp)
  800512:	e8 e9 0d 00 00       	call   801300 <cprintf>
	*dev = 0;
  800517:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80051d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800522:	83 c4 14             	add    $0x14,%esp
  800525:	5b                   	pop    %ebx
  800526:	5d                   	pop    %ebp
  800527:	c3                   	ret    

00800528 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 30             	sub    $0x30,%esp
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8a 45 0c             	mov    0xc(%ebp),%al
  800536:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800539:	89 34 24             	mov    %esi,(%esp)
  80053c:	e8 b7 fe ff ff       	call   8003f8 <fd2num>
  800541:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800544:	89 54 24 04          	mov    %edx,0x4(%esp)
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 26 ff ff ff       	call   800476 <fd_lookup>
  800550:	89 c3                	mov    %eax,%ebx
  800552:	85 c0                	test   %eax,%eax
  800554:	78 05                	js     80055b <fd_close+0x33>
	    || fd != fd2)
  800556:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800559:	74 0d                	je     800568 <fd_close+0x40>
		return (must_exist ? r : 0);
  80055b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80055f:	75 46                	jne    8005a7 <fd_close+0x7f>
  800561:	bb 00 00 00 00       	mov    $0x0,%ebx
  800566:	eb 3f                	jmp    8005a7 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800568:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	8b 06                	mov    (%esi),%eax
  800571:	89 04 24             	mov    %eax,(%esp)
  800574:	e8 53 ff ff ff       	call   8004cc <dev_lookup>
  800579:	89 c3                	mov    %eax,%ebx
  80057b:	85 c0                	test   %eax,%eax
  80057d:	78 18                	js     800597 <fd_close+0x6f>
		if (dev->dev_close)
  80057f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800582:	8b 40 10             	mov    0x10(%eax),%eax
  800585:	85 c0                	test   %eax,%eax
  800587:	74 09                	je     800592 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800589:	89 34 24             	mov    %esi,(%esp)
  80058c:	ff d0                	call   *%eax
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	eb 05                	jmp    800597 <fd_close+0x6f>
		else
			r = 0;
  800592:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800597:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a2:	e8 8d fc ff ff       	call   800234 <sys_page_unmap>
	return r;
}
  8005a7:	89 d8                	mov    %ebx,%eax
  8005a9:	83 c4 30             	add    $0x30,%esp
  8005ac:	5b                   	pop    %ebx
  8005ad:	5e                   	pop    %esi
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 ae fe ff ff       	call   800476 <fd_lookup>
  8005c8:	85 c0                	test   %eax,%eax
  8005ca:	78 13                	js     8005df <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005cc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005d3:	00 
  8005d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	e8 49 ff ff ff       	call   800528 <fd_close>
}
  8005df:	c9                   	leave  
  8005e0:	c3                   	ret    

008005e1 <close_all>:

void
close_all(void)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	53                   	push   %ebx
  8005e5:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ed:	89 1c 24             	mov    %ebx,(%esp)
  8005f0:	e8 bb ff ff ff       	call   8005b0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005f5:	43                   	inc    %ebx
  8005f6:	83 fb 20             	cmp    $0x20,%ebx
  8005f9:	75 f2                	jne    8005ed <close_all+0xc>
		close(i);
}
  8005fb:	83 c4 14             	add    $0x14,%esp
  8005fe:	5b                   	pop    %ebx
  8005ff:	5d                   	pop    %ebp
  800600:	c3                   	ret    

00800601 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	57                   	push   %edi
  800605:	56                   	push   %esi
  800606:	53                   	push   %ebx
  800607:	83 ec 4c             	sub    $0x4c,%esp
  80060a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80060d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	8b 45 08             	mov    0x8(%ebp),%eax
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	e8 57 fe ff ff       	call   800476 <fd_lookup>
  80061f:	89 c3                	mov    %eax,%ebx
  800621:	85 c0                	test   %eax,%eax
  800623:	0f 88 e1 00 00 00    	js     80070a <dup+0x109>
		return r;
	close(newfdnum);
  800629:	89 3c 24             	mov    %edi,(%esp)
  80062c:	e8 7f ff ff ff       	call   8005b0 <close>

	newfd = INDEX2FD(newfdnum);
  800631:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800637:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80063a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	e8 c3 fd ff ff       	call   800408 <fd2data>
  800645:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800647:	89 34 24             	mov    %esi,(%esp)
  80064a:	e8 b9 fd ff ff       	call   800408 <fd2data>
  80064f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800652:	89 d8                	mov    %ebx,%eax
  800654:	c1 e8 16             	shr    $0x16,%eax
  800657:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80065e:	a8 01                	test   $0x1,%al
  800660:	74 46                	je     8006a8 <dup+0xa7>
  800662:	89 d8                	mov    %ebx,%eax
  800664:	c1 e8 0c             	shr    $0xc,%eax
  800667:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80066e:	f6 c2 01             	test   $0x1,%dl
  800671:	74 35                	je     8006a8 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800673:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80067a:	25 07 0e 00 00       	and    $0xe07,%eax
  80067f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800683:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800686:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800691:	00 
  800692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800696:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80069d:	e8 3f fb ff ff       	call   8001e1 <sys_page_map>
  8006a2:	89 c3                	mov    %eax,%ebx
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	78 3b                	js     8006e3 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006ab:	89 c2                	mov    %eax,%edx
  8006ad:	c1 ea 0c             	shr    $0xc,%edx
  8006b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006b7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006cc:	00 
  8006cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d8:	e8 04 fb ff ff       	call   8001e1 <sys_page_map>
  8006dd:	89 c3                	mov    %eax,%ebx
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	79 25                	jns    800708 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ee:	e8 41 fb ff ff       	call   800234 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800701:	e8 2e fb ff ff       	call   800234 <sys_page_unmap>
	return r;
  800706:	eb 02                	jmp    80070a <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800708:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80070a:	89 d8                	mov    %ebx,%eax
  80070c:	83 c4 4c             	add    $0x4c,%esp
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5f                   	pop    %edi
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	83 ec 24             	sub    $0x24,%esp
  80071b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800721:	89 44 24 04          	mov    %eax,0x4(%esp)
  800725:	89 1c 24             	mov    %ebx,(%esp)
  800728:	e8 49 fd ff ff       	call   800476 <fd_lookup>
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 6f                	js     8007a0 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	89 44 24 04          	mov    %eax,0x4(%esp)
  800738:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	89 04 24             	mov    %eax,(%esp)
  800740:	e8 87 fd ff ff       	call   8004cc <dev_lookup>
  800745:	85 c0                	test   %eax,%eax
  800747:	78 57                	js     8007a0 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074c:	8b 50 08             	mov    0x8(%eax),%edx
  80074f:	83 e2 03             	and    $0x3,%edx
  800752:	83 fa 01             	cmp    $0x1,%edx
  800755:	75 25                	jne    80077c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800757:	a1 04 40 80 00       	mov    0x804004,%eax
  80075c:	8b 00                	mov    (%eax),%eax
  80075e:	8b 40 48             	mov    0x48(%eax),%eax
  800761:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800765:	89 44 24 04          	mov    %eax,0x4(%esp)
  800769:	c7 04 24 fd 1f 80 00 	movl   $0x801ffd,(%esp)
  800770:	e8 8b 0b 00 00       	call   801300 <cprintf>
		return -E_INVAL;
  800775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077a:	eb 24                	jmp    8007a0 <read+0x8c>
	}
	if (!dev->dev_read)
  80077c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077f:	8b 52 08             	mov    0x8(%edx),%edx
  800782:	85 d2                	test   %edx,%edx
  800784:	74 15                	je     80079b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800786:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800789:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	ff d2                	call   *%edx
  800799:	eb 05                	jmp    8007a0 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80079b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007a0:	83 c4 24             	add    $0x24,%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	57                   	push   %edi
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 1c             	sub    $0x1c,%esp
  8007af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ba:	eb 23                	jmp    8007df <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007bc:	89 f0                	mov    %esi,%eax
  8007be:	29 d8                	sub    %ebx,%eax
  8007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cd:	89 3c 24             	mov    %edi,(%esp)
  8007d0:	e8 3f ff ff ff       	call   800714 <read>
		if (m < 0)
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	78 10                	js     8007e9 <readn+0x43>
			return m;
		if (m == 0)
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	74 0a                	je     8007e7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007dd:	01 c3                	add    %eax,%ebx
  8007df:	39 f3                	cmp    %esi,%ebx
  8007e1:	72 d9                	jb     8007bc <readn+0x16>
  8007e3:	89 d8                	mov    %ebx,%eax
  8007e5:	eb 02                	jmp    8007e9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007e7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007e9:	83 c4 1c             	add    $0x1c,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 24             	sub    $0x24,%esp
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800802:	89 1c 24             	mov    %ebx,(%esp)
  800805:	e8 6c fc ff ff       	call   800476 <fd_lookup>
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 6a                	js     800878 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	89 04 24             	mov    %eax,(%esp)
  80081d:	e8 aa fc ff ff       	call   8004cc <dev_lookup>
  800822:	85 c0                	test   %eax,%eax
  800824:	78 52                	js     800878 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800829:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082d:	75 25                	jne    800854 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80082f:	a1 04 40 80 00       	mov    0x804004,%eax
  800834:	8b 00                	mov    (%eax),%eax
  800836:	8b 40 48             	mov    0x48(%eax),%eax
  800839:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80083d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800841:	c7 04 24 19 20 80 00 	movl   $0x802019,(%esp)
  800848:	e8 b3 0a 00 00       	call   801300 <cprintf>
		return -E_INVAL;
  80084d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800852:	eb 24                	jmp    800878 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800854:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800857:	8b 52 0c             	mov    0xc(%edx),%edx
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 15                	je     800873 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80085e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800861:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800865:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800868:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	ff d2                	call   *%edx
  800871:	eb 05                	jmp    800878 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800873:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800878:	83 c4 24             	add    $0x24,%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <seek>:

int
seek(int fdnum, off_t offset)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800884:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	e8 e0 fb ff ff       	call   800476 <fd_lookup>
  800896:	85 c0                	test   %eax,%eax
  800898:	78 0e                	js     8008a8 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80089a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	83 ec 24             	sub    $0x24,%esp
  8008b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bb:	89 1c 24             	mov    %ebx,(%esp)
  8008be:	e8 b3 fb ff ff       	call   800476 <fd_lookup>
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	78 63                	js     80092a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d1:	8b 00                	mov    (%eax),%eax
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	e8 f1 fb ff ff       	call   8004cc <dev_lookup>
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	78 4b                	js     80092a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008e6:	75 25                	jne    80090d <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8008ed:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008ef:	8b 40 48             	mov    0x48(%eax),%eax
  8008f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800901:	e8 fa 09 00 00       	call   801300 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800906:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090b:	eb 1d                	jmp    80092a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80090d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800910:	8b 52 18             	mov    0x18(%edx),%edx
  800913:	85 d2                	test   %edx,%edx
  800915:	74 0e                	je     800925 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	ff d2                	call   *%edx
  800923:	eb 05                	jmp    80092a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800925:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80092a:	83 c4 24             	add    $0x24,%esp
  80092d:	5b                   	pop    %ebx
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	53                   	push   %ebx
  800934:	83 ec 24             	sub    $0x24,%esp
  800937:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80093a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	e8 2a fb ff ff       	call   800476 <fd_lookup>
  80094c:	85 c0                	test   %eax,%eax
  80094e:	78 52                	js     8009a2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800950:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800953:	89 44 24 04          	mov    %eax,0x4(%esp)
  800957:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095a:	8b 00                	mov    (%eax),%eax
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	e8 68 fb ff ff       	call   8004cc <dev_lookup>
  800964:	85 c0                	test   %eax,%eax
  800966:	78 3a                	js     8009a2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800968:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80096f:	74 2c                	je     80099d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800971:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800974:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80097b:	00 00 00 
	stat->st_isdir = 0;
  80097e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800985:	00 00 00 
	stat->st_dev = dev;
  800988:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80098e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800992:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800995:	89 14 24             	mov    %edx,(%esp)
  800998:	ff 50 14             	call   *0x14(%eax)
  80099b:	eb 05                	jmp    8009a2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80099d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009a2:	83 c4 24             	add    $0x24,%esp
  8009a5:	5b                   	pop    %ebx
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009b7:	00 
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	89 04 24             	mov    %eax,(%esp)
  8009be:	e8 88 02 00 00       	call   800c4b <open>
  8009c3:	89 c3                	mov    %eax,%ebx
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 1b                	js     8009e4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	89 1c 24             	mov    %ebx,(%esp)
  8009d3:	e8 58 ff ff ff       	call   800930 <fstat>
  8009d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8009da:	89 1c 24             	mov    %ebx,(%esp)
  8009dd:	e8 ce fb ff ff       	call   8005b0 <close>
	return r;
  8009e2:	89 f3                	mov    %esi,%ebx
}
  8009e4:	89 d8                	mov    %ebx,%eax
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    
  8009ed:	00 00                	add    %al,(%eax)
	...

008009f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	83 ec 10             	sub    $0x10,%esp
  8009f8:	89 c3                	mov    %eax,%ebx
  8009fa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009fc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a03:	75 11                	jne    800a16 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a0c:	e8 92 12 00 00       	call   801ca3 <ipc_find_env>
  800a11:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a16:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a1d:	00 
  800a1e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a25:	00 
  800a26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2a:	a1 00 40 80 00       	mov    0x804000,%eax
  800a2f:	89 04 24             	mov    %eax,(%esp)
  800a32:	e8 06 12 00 00       	call   801c3d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a3e:	00 
  800a3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a4a:	e8 81 11 00 00       	call   801bd0 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a4f:	83 c4 10             	add    $0x10,%esp
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a62:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 02 00 00 00       	mov    $0x2,%eax
  800a79:	e8 72 ff ff ff       	call   8009f0 <fsipc>
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 06 00 00 00       	mov    $0x6,%eax
  800a9b:	e8 50 ff ff ff       	call   8009f0 <fsipc>
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 14             	sub    $0x14,%esp
  800aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ab7:	ba 00 00 00 00       	mov    $0x0,%edx
  800abc:	b8 05 00 00 00       	mov    $0x5,%eax
  800ac1:	e8 2a ff ff ff       	call   8009f0 <fsipc>
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	78 2b                	js     800af5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ad1:	00 
  800ad2:	89 1c 24             	mov    %ebx,(%esp)
  800ad5:	e8 d1 0d 00 00       	call   8018ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ada:	a1 80 50 80 00       	mov    0x805080,%eax
  800adf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ae5:	a1 84 50 80 00       	mov    0x805084,%eax
  800aea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af5:	83 c4 14             	add    $0x14,%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	83 ec 14             	sub    $0x14,%esp
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
  800b08:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b10:	89 d8                	mov    %ebx,%eax
  800b12:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b18:	76 05                	jbe    800b1f <devfile_write+0x24>
  800b1a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b1f:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b36:	e8 53 0f 00 00       	call   801a8e <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 04 00 00 00       	mov    $0x4,%eax
  800b45:	e8 a6 fe ff ff       	call   8009f0 <fsipc>
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	78 53                	js     800ba1 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b4e:	39 c3                	cmp    %eax,%ebx
  800b50:	73 24                	jae    800b76 <devfile_write+0x7b>
  800b52:	c7 44 24 0c 48 20 80 	movl   $0x802048,0xc(%esp)
  800b59:	00 
  800b5a:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  800b61:	00 
  800b62:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800b69:	00 
  800b6a:	c7 04 24 64 20 80 00 	movl   $0x802064,(%esp)
  800b71:	e8 92 06 00 00       	call   801208 <_panic>
	assert(r <= PGSIZE);
  800b76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b7b:	7e 24                	jle    800ba1 <devfile_write+0xa6>
  800b7d:	c7 44 24 0c 6f 20 80 	movl   $0x80206f,0xc(%esp)
  800b84:	00 
  800b85:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800b94:	00 
  800b95:	c7 04 24 64 20 80 00 	movl   $0x802064,(%esp)
  800b9c:	e8 67 06 00 00       	call   801208 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800ba1:	83 c4 14             	add    $0x14,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 10             	sub    $0x10,%esp
  800baf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 40 0c             	mov    0xc(%eax),%eax
  800bb8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bbd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcd:	e8 1e fe ff ff       	call   8009f0 <fsipc>
  800bd2:	89 c3                	mov    %eax,%ebx
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	78 6a                	js     800c42 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bd8:	39 c6                	cmp    %eax,%esi
  800bda:	73 24                	jae    800c00 <devfile_read+0x59>
  800bdc:	c7 44 24 0c 48 20 80 	movl   $0x802048,0xc(%esp)
  800be3:	00 
  800be4:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  800beb:	00 
  800bec:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800bf3:	00 
  800bf4:	c7 04 24 64 20 80 00 	movl   $0x802064,(%esp)
  800bfb:	e8 08 06 00 00       	call   801208 <_panic>
	assert(r <= PGSIZE);
  800c00:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c05:	7e 24                	jle    800c2b <devfile_read+0x84>
  800c07:	c7 44 24 0c 6f 20 80 	movl   $0x80206f,0xc(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  800c16:	00 
  800c17:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c1e:	00 
  800c1f:	c7 04 24 64 20 80 00 	movl   $0x802064,(%esp)
  800c26:	e8 dd 05 00 00       	call   801208 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c36:	00 
  800c37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3a:	89 04 24             	mov    %eax,(%esp)
  800c3d:	e8 e2 0d 00 00       	call   801a24 <memmove>
	return r;
}
  800c42:	89 d8                	mov    %ebx,%eax
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 20             	sub    $0x20,%esp
  800c53:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c56:	89 34 24             	mov    %esi,(%esp)
  800c59:	e8 1a 0c 00 00       	call   801878 <strlen>
  800c5e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c63:	7f 60                	jg     800cc5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c68:	89 04 24             	mov    %eax,(%esp)
  800c6b:	e8 b3 f7 ff ff       	call   800423 <fd_alloc>
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	85 c0                	test   %eax,%eax
  800c74:	78 54                	js     800cca <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c7a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c81:	e8 25 0c 00 00       	call   8018ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c89:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	e8 55 fd ff ff       	call   8009f0 <fsipc>
  800c9b:	89 c3                	mov    %eax,%ebx
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	79 15                	jns    800cb6 <open+0x6b>
		fd_close(fd, 0);
  800ca1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ca8:	00 
  800ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cac:	89 04 24             	mov    %eax,(%esp)
  800caf:	e8 74 f8 ff ff       	call   800528 <fd_close>
		return r;
  800cb4:	eb 14                	jmp    800cca <open+0x7f>
	}

	return fd2num(fd);
  800cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb9:	89 04 24             	mov    %eax,(%esp)
  800cbc:	e8 37 f7 ff ff       	call   8003f8 <fd2num>
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	eb 05                	jmp    800cca <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cc5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cca:	89 d8                	mov    %ebx,%eax
  800ccc:	83 c4 20             	add    $0x20,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cde:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce3:	e8 08 fd ff ff       	call   8009f0 <fsipc>
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    
	...

00800cec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 10             	sub    $0x10,%esp
  800cf4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	89 04 24             	mov    %eax,(%esp)
  800cfd:	e8 06 f7 ff ff       	call   800408 <fd2data>
  800d02:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d04:	c7 44 24 04 7b 20 80 	movl   $0x80207b,0x4(%esp)
  800d0b:	00 
  800d0c:	89 34 24             	mov    %esi,(%esp)
  800d0f:	e8 97 0b 00 00       	call   8018ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d14:	8b 43 04             	mov    0x4(%ebx),%eax
  800d17:	2b 03                	sub    (%ebx),%eax
  800d19:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d1f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d26:	00 00 00 
	stat->st_dev = &devpipe;
  800d29:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d30:	30 80 00 
	return 0;
}
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	53                   	push   %ebx
  800d43:	83 ec 14             	sub    $0x14,%esp
  800d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d49:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d54:	e8 db f4 ff ff       	call   800234 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d59:	89 1c 24             	mov    %ebx,(%esp)
  800d5c:	e8 a7 f6 ff ff       	call   800408 <fd2data>
  800d61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d6c:	e8 c3 f4 ff ff       	call   800234 <sys_page_unmap>
}
  800d71:	83 c4 14             	add    $0x14,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 2c             	sub    $0x2c,%esp
  800d80:	89 c7                	mov    %eax,%edi
  800d82:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d85:	a1 04 40 80 00       	mov    0x804004,%eax
  800d8a:	8b 00                	mov    (%eax),%eax
  800d8c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d8f:	89 3c 24             	mov    %edi,(%esp)
  800d92:	e8 51 0f 00 00       	call   801ce8 <pageref>
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d9c:	89 04 24             	mov    %eax,(%esp)
  800d9f:	e8 44 0f 00 00       	call   801ce8 <pageref>
  800da4:	39 c6                	cmp    %eax,%esi
  800da6:	0f 94 c0             	sete   %al
  800da9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800dac:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800db2:	8b 12                	mov    (%edx),%edx
  800db4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800db7:	39 cb                	cmp    %ecx,%ebx
  800db9:	75 08                	jne    800dc3 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800dbb:	83 c4 2c             	add    $0x2c,%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800dc3:	83 f8 01             	cmp    $0x1,%eax
  800dc6:	75 bd                	jne    800d85 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800dc8:	8b 42 58             	mov    0x58(%edx),%eax
  800dcb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800dd2:	00 
  800dd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ddb:	c7 04 24 82 20 80 00 	movl   $0x802082,(%esp)
  800de2:	e8 19 05 00 00       	call   801300 <cprintf>
  800de7:	eb 9c                	jmp    800d85 <_pipeisclosed+0xe>

00800de9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 1c             	sub    $0x1c,%esp
  800df2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800df5:	89 34 24             	mov    %esi,(%esp)
  800df8:	e8 0b f6 ff ff       	call   800408 <fd2data>
  800dfd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dff:	bf 00 00 00 00       	mov    $0x0,%edi
  800e04:	eb 3c                	jmp    800e42 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e06:	89 da                	mov    %ebx,%edx
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	e8 68 ff ff ff       	call   800d77 <_pipeisclosed>
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	75 38                	jne    800e4b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e13:	e8 56 f3 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e18:	8b 43 04             	mov    0x4(%ebx),%eax
  800e1b:	8b 13                	mov    (%ebx),%edx
  800e1d:	83 c2 20             	add    $0x20,%edx
  800e20:	39 d0                	cmp    %edx,%eax
  800e22:	73 e2                	jae    800e06 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e27:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e2a:	89 c2                	mov    %eax,%edx
  800e2c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e32:	79 05                	jns    800e39 <devpipe_write+0x50>
  800e34:	4a                   	dec    %edx
  800e35:	83 ca e0             	or     $0xffffffe0,%edx
  800e38:	42                   	inc    %edx
  800e39:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e3d:	40                   	inc    %eax
  800e3e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e41:	47                   	inc    %edi
  800e42:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e45:	75 d1                	jne    800e18 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e47:	89 f8                	mov    %edi,%eax
  800e49:	eb 05                	jmp    800e50 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e50:	83 c4 1c             	add    $0x1c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 1c             	sub    $0x1c,%esp
  800e61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e64:	89 3c 24             	mov    %edi,(%esp)
  800e67:	e8 9c f5 ff ff       	call   800408 <fd2data>
  800e6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e6e:	be 00 00 00 00       	mov    $0x0,%esi
  800e73:	eb 3a                	jmp    800eaf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e75:	85 f6                	test   %esi,%esi
  800e77:	74 04                	je     800e7d <devpipe_read+0x25>
				return i;
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	eb 40                	jmp    800ebd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e7d:	89 da                	mov    %ebx,%edx
  800e7f:	89 f8                	mov    %edi,%eax
  800e81:	e8 f1 fe ff ff       	call   800d77 <_pipeisclosed>
  800e86:	85 c0                	test   %eax,%eax
  800e88:	75 2e                	jne    800eb8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e8a:	e8 df f2 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e8f:	8b 03                	mov    (%ebx),%eax
  800e91:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e94:	74 df                	je     800e75 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e96:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e9b:	79 05                	jns    800ea2 <devpipe_read+0x4a>
  800e9d:	48                   	dec    %eax
  800e9e:	83 c8 e0             	or     $0xffffffe0,%eax
  800ea1:	40                   	inc    %eax
  800ea2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ea6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800eac:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800eae:	46                   	inc    %esi
  800eaf:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eb2:	75 db                	jne    800e8f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800eb4:	89 f0                	mov    %esi,%eax
  800eb6:	eb 05                	jmp    800ebd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ebd:	83 c4 1c             	add    $0x1c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
  800ecb:	83 ec 3c             	sub    $0x3c,%esp
  800ece:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ed1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed4:	89 04 24             	mov    %eax,(%esp)
  800ed7:	e8 47 f5 ff ff       	call   800423 <fd_alloc>
  800edc:	89 c3                	mov    %eax,%ebx
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	0f 88 45 01 00 00    	js     80102b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ee6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800eed:	00 
  800eee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800efc:	e8 8c f2 ff ff       	call   80018d <sys_page_alloc>
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	85 c0                	test   %eax,%eax
  800f05:	0f 88 20 01 00 00    	js     80102b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800f0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f0e:	89 04 24             	mov    %eax,(%esp)
  800f11:	e8 0d f5 ff ff       	call   800423 <fd_alloc>
  800f16:	89 c3                	mov    %eax,%ebx
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	0f 88 f8 00 00 00    	js     801018 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f20:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f27:	00 
  800f28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f36:	e8 52 f2 ff ff       	call   80018d <sys_page_alloc>
  800f3b:	89 c3                	mov    %eax,%ebx
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	0f 88 d3 00 00 00    	js     801018 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f48:	89 04 24             	mov    %eax,(%esp)
  800f4b:	e8 b8 f4 ff ff       	call   800408 <fd2data>
  800f50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f59:	00 
  800f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f65:	e8 23 f2 ff ff       	call   80018d <sys_page_alloc>
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	0f 88 91 00 00 00    	js     801005 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f77:	89 04 24             	mov    %eax,(%esp)
  800f7a:	e8 89 f4 ff ff       	call   800408 <fd2data>
  800f7f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f86:	00 
  800f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f92:	00 
  800f93:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9e:	e8 3e f2 ff ff       	call   8001e1 <sys_page_map>
  800fa3:	89 c3                	mov    %eax,%ebx
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 4c                	js     800ff5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800fa9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800faf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800fbe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800fc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fcc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fd6:	89 04 24             	mov    %eax,(%esp)
  800fd9:	e8 1a f4 ff ff       	call   8003f8 <fd2num>
  800fde:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800fe0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fe3:	89 04 24             	mov    %eax,(%esp)
  800fe6:	e8 0d f4 ff ff       	call   8003f8 <fd2num>
  800feb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800fee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff3:	eb 36                	jmp    80102b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800ff5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ff9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801000:	e8 2f f2 ff ff       	call   800234 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801005:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801008:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801013:	e8 1c f2 ff ff       	call   800234 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801018:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801026:	e8 09 f2 ff ff       	call   800234 <sys_page_unmap>
    err:
	return r;
}
  80102b:	89 d8                	mov    %ebx,%eax
  80102d:	83 c4 3c             	add    $0x3c,%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	89 04 24             	mov    %eax,(%esp)
  801048:	e8 29 f4 ff ff       	call   800476 <fd_lookup>
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 15                	js     801066 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801054:	89 04 24             	mov    %eax,(%esp)
  801057:	e8 ac f3 ff ff       	call   800408 <fd2data>
	return _pipeisclosed(fd, p);
  80105c:	89 c2                	mov    %eax,%edx
  80105e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801061:	e8 11 fd ff ff       	call   800d77 <_pipeisclosed>
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80106b:	b8 00 00 00 00       	mov    $0x0,%eax
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801078:	c7 44 24 04 9a 20 80 	movl   $0x80209a,0x4(%esp)
  80107f:	00 
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	89 04 24             	mov    %eax,(%esp)
  801086:	e8 20 08 00 00       	call   8018ab <strcpy>
	return 0;
}
  80108b:	b8 00 00 00 00       	mov    $0x0,%eax
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80109e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8010a3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010a9:	eb 30                	jmp    8010db <devcons_write+0x49>
		m = n - tot;
  8010ab:	8b 75 10             	mov    0x10(%ebp),%esi
  8010ae:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010b0:	83 fe 7f             	cmp    $0x7f,%esi
  8010b3:	76 05                	jbe    8010ba <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010b5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010be:	03 45 0c             	add    0xc(%ebp),%eax
  8010c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c5:	89 3c 24             	mov    %edi,(%esp)
  8010c8:	e8 57 09 00 00       	call   801a24 <memmove>
		sys_cputs(buf, m);
  8010cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d1:	89 3c 24             	mov    %edi,(%esp)
  8010d4:	e8 e7 ef ff ff       	call   8000c0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010d9:	01 f3                	add    %esi,%ebx
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010e0:	72 c9                	jb     8010ab <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8010e2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8010f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010f7:	75 07                	jne    801100 <devcons_read+0x13>
  8010f9:	eb 25                	jmp    801120 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8010fb:	e8 6e f0 ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801100:	e8 d9 ef ff ff       	call   8000de <sys_cgetc>
  801105:	85 c0                	test   %eax,%eax
  801107:	74 f2                	je     8010fb <devcons_read+0xe>
  801109:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 1d                	js     80112c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80110f:	83 f8 04             	cmp    $0x4,%eax
  801112:	74 13                	je     801127 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801114:	8b 45 0c             	mov    0xc(%ebp),%eax
  801117:	88 10                	mov    %dl,(%eax)
	return 1;
  801119:	b8 01 00 00 00       	mov    $0x1,%eax
  80111e:	eb 0c                	jmp    80112c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
  801125:	eb 05                	jmp    80112c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    

0080112e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80113a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801141:	00 
  801142:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801145:	89 04 24             	mov    %eax,(%esp)
  801148:	e8 73 ef ff ff       	call   8000c0 <sys_cputs>
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <getchar>:

int
getchar(void)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801155:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80115c:	00 
  80115d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801160:	89 44 24 04          	mov    %eax,0x4(%esp)
  801164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116b:	e8 a4 f5 ff ff       	call   800714 <read>
	if (r < 0)
  801170:	85 c0                	test   %eax,%eax
  801172:	78 0f                	js     801183 <getchar+0x34>
		return r;
	if (r < 1)
  801174:	85 c0                	test   %eax,%eax
  801176:	7e 06                	jle    80117e <getchar+0x2f>
		return -E_EOF;
	return c;
  801178:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80117c:	eb 05                	jmp    801183 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80117e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80118b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	e8 d9 f2 ff ff       	call   800476 <fd_lookup>
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 11                	js     8011b2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8011a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011aa:	39 10                	cmp    %edx,(%eax)
  8011ac:	0f 94 c0             	sete   %al
  8011af:	0f b6 c0             	movzbl %al,%eax
}
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <opencons>:

int
opencons(void)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bd:	89 04 24             	mov    %eax,(%esp)
  8011c0:	e8 5e f2 ff ff       	call   800423 <fd_alloc>
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	78 3c                	js     801205 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8011c9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011d0:	00 
  8011d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011df:	e8 a9 ef ff ff       	call   80018d <sys_page_alloc>
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 1d                	js     801205 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8011e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8011f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8011fd:	89 04 24             	mov    %eax,(%esp)
  801200:	e8 f3 f1 ff ff       	call   8003f8 <fd2num>
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    
	...

00801208 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801210:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801213:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801219:	e8 31 ef ff ff       	call   80014f <sys_getenvid>
  80121e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801221:	89 54 24 10          	mov    %edx,0x10(%esp)
  801225:	8b 55 08             	mov    0x8(%ebp),%edx
  801228:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80122c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801230:	89 44 24 04          	mov    %eax,0x4(%esp)
  801234:	c7 04 24 a8 20 80 00 	movl   $0x8020a8,(%esp)
  80123b:	e8 c0 00 00 00       	call   801300 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801240:	89 74 24 04          	mov    %esi,0x4(%esp)
  801244:	8b 45 10             	mov    0x10(%ebp),%eax
  801247:	89 04 24             	mov    %eax,(%esp)
  80124a:	e8 50 00 00 00       	call   80129f <vcprintf>
	cprintf("\n");
  80124f:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  801256:	e8 a5 00 00 00       	call   801300 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80125b:	cc                   	int3   
  80125c:	eb fd                	jmp    80125b <_panic+0x53>
	...

00801260 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	53                   	push   %ebx
  801264:	83 ec 14             	sub    $0x14,%esp
  801267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80126a:	8b 03                	mov    (%ebx),%eax
  80126c:	8b 55 08             	mov    0x8(%ebp),%edx
  80126f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801273:	40                   	inc    %eax
  801274:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80127b:	75 19                	jne    801296 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80127d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801284:	00 
  801285:	8d 43 08             	lea    0x8(%ebx),%eax
  801288:	89 04 24             	mov    %eax,(%esp)
  80128b:	e8 30 ee ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  801290:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801296:	ff 43 04             	incl   0x4(%ebx)
}
  801299:	83 c4 14             	add    $0x14,%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8012a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012af:	00 00 00 
	b.cnt = 0;
  8012b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  8012db:	e8 82 01 00 00       	call   801462 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8012e0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8012e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8012f0:	89 04 24             	mov    %eax,(%esp)
  8012f3:	e8 c8 ed ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  8012f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801306:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130d:	8b 45 08             	mov    0x8(%ebp),%eax
  801310:	89 04 24             	mov    %eax,(%esp)
  801313:	e8 87 ff ff ff       	call   80129f <vcprintf>
	va_end(ap);

	return cnt;
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    
	...

0080131c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 3c             	sub    $0x3c,%esp
  801325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801328:	89 d7                	mov    %edx,%edi
  80132a:	8b 45 08             	mov    0x8(%ebp),%eax
  80132d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801330:	8b 45 0c             	mov    0xc(%ebp),%eax
  801333:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801336:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801339:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80133c:	85 c0                	test   %eax,%eax
  80133e:	75 08                	jne    801348 <printnum+0x2c>
  801340:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801343:	39 45 10             	cmp    %eax,0x10(%ebp)
  801346:	77 57                	ja     80139f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801348:	89 74 24 10          	mov    %esi,0x10(%esp)
  80134c:	4b                   	dec    %ebx
  80134d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801351:	8b 45 10             	mov    0x10(%ebp),%eax
  801354:	89 44 24 08          	mov    %eax,0x8(%esp)
  801358:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80135c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801360:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801367:	00 
  801368:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80136b:	89 04 24             	mov    %eax,(%esp)
  80136e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801371:	89 44 24 04          	mov    %eax,0x4(%esp)
  801375:	e8 b2 09 00 00       	call   801d2c <__udivdi3>
  80137a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80137e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	89 54 24 04          	mov    %edx,0x4(%esp)
  801389:	89 fa                	mov    %edi,%edx
  80138b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138e:	e8 89 ff ff ff       	call   80131c <printnum>
  801393:	eb 0f                	jmp    8013a4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801395:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801399:	89 34 24             	mov    %esi,(%esp)
  80139c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80139f:	4b                   	dec    %ebx
  8013a0:	85 db                	test   %ebx,%ebx
  8013a2:	7f f1                	jg     801395 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8013a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013a8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8013af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013ba:	00 
  8013bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013be:	89 04 24             	mov    %eax,(%esp)
  8013c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	e8 7f 0a 00 00       	call   801e4c <__umoddi3>
  8013cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d1:	0f be 80 cb 20 80 00 	movsbl 0x8020cb(%eax),%eax
  8013d8:	89 04 24             	mov    %eax,(%esp)
  8013db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8013de:	83 c4 3c             	add    $0x3c,%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013e9:	83 fa 01             	cmp    $0x1,%edx
  8013ec:	7e 0e                	jle    8013fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013ee:	8b 10                	mov    (%eax),%edx
  8013f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013f3:	89 08                	mov    %ecx,(%eax)
  8013f5:	8b 02                	mov    (%edx),%eax
  8013f7:	8b 52 04             	mov    0x4(%edx),%edx
  8013fa:	eb 22                	jmp    80141e <getuint+0x38>
	else if (lflag)
  8013fc:	85 d2                	test   %edx,%edx
  8013fe:	74 10                	je     801410 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801400:	8b 10                	mov    (%eax),%edx
  801402:	8d 4a 04             	lea    0x4(%edx),%ecx
  801405:	89 08                	mov    %ecx,(%eax)
  801407:	8b 02                	mov    (%edx),%eax
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
  80140e:	eb 0e                	jmp    80141e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801410:	8b 10                	mov    (%eax),%edx
  801412:	8d 4a 04             	lea    0x4(%edx),%ecx
  801415:	89 08                	mov    %ecx,(%eax)
  801417:	8b 02                	mov    (%edx),%eax
  801419:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801426:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801429:	8b 10                	mov    (%eax),%edx
  80142b:	3b 50 04             	cmp    0x4(%eax),%edx
  80142e:	73 08                	jae    801438 <sprintputch+0x18>
		*b->buf++ = ch;
  801430:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801433:	88 0a                	mov    %cl,(%edx)
  801435:	42                   	inc    %edx
  801436:	89 10                	mov    %edx,(%eax)
}
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801440:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801447:	8b 45 10             	mov    0x10(%ebp),%eax
  80144a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801451:	89 44 24 04          	mov    %eax,0x4(%esp)
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	89 04 24             	mov    %eax,(%esp)
  80145b:	e8 02 00 00 00       	call   801462 <vprintfmt>
	va_end(ap);
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	57                   	push   %edi
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
  801468:	83 ec 4c             	sub    $0x4c,%esp
  80146b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146e:	8b 75 10             	mov    0x10(%ebp),%esi
  801471:	eb 12                	jmp    801485 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801473:	85 c0                	test   %eax,%eax
  801475:	0f 84 6b 03 00 00    	je     8017e6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80147b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801485:	0f b6 06             	movzbl (%esi),%eax
  801488:	46                   	inc    %esi
  801489:	83 f8 25             	cmp    $0x25,%eax
  80148c:	75 e5                	jne    801473 <vprintfmt+0x11>
  80148e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801492:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801499:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80149e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8014a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014aa:	eb 26                	jmp    8014d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ac:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8014af:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014b3:	eb 1d                	jmp    8014d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014b8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014bc:	eb 14                	jmp    8014d2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8014c8:	eb 08                	jmp    8014d2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8014ca:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8014cd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d2:	0f b6 06             	movzbl (%esi),%eax
  8014d5:	8d 56 01             	lea    0x1(%esi),%edx
  8014d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014db:	8a 16                	mov    (%esi),%dl
  8014dd:	83 ea 23             	sub    $0x23,%edx
  8014e0:	80 fa 55             	cmp    $0x55,%dl
  8014e3:	0f 87 e1 02 00 00    	ja     8017ca <vprintfmt+0x368>
  8014e9:	0f b6 d2             	movzbl %dl,%edx
  8014ec:	ff 24 95 00 22 80 00 	jmp    *0x802200(,%edx,4)
  8014f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014f6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8014fb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8014fe:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801502:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801505:	8d 50 d0             	lea    -0x30(%eax),%edx
  801508:	83 fa 09             	cmp    $0x9,%edx
  80150b:	77 2a                	ja     801537 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80150d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80150e:	eb eb                	jmp    8014fb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801510:	8b 45 14             	mov    0x14(%ebp),%eax
  801513:	8d 50 04             	lea    0x4(%eax),%edx
  801516:	89 55 14             	mov    %edx,0x14(%ebp)
  801519:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80151b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80151e:	eb 17                	jmp    801537 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801520:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801524:	78 98                	js     8014be <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801526:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801529:	eb a7                	jmp    8014d2 <vprintfmt+0x70>
  80152b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80152e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801535:	eb 9b                	jmp    8014d2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80153b:	79 95                	jns    8014d2 <vprintfmt+0x70>
  80153d:	eb 8b                	jmp    8014ca <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80153f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801540:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801543:	eb 8d                	jmp    8014d2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801545:	8b 45 14             	mov    0x14(%ebp),%eax
  801548:	8d 50 04             	lea    0x4(%eax),%edx
  80154b:	89 55 14             	mov    %edx,0x14(%ebp)
  80154e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801552:	8b 00                	mov    (%eax),%eax
  801554:	89 04 24             	mov    %eax,(%esp)
  801557:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80155a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80155d:	e9 23 ff ff ff       	jmp    801485 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801562:	8b 45 14             	mov    0x14(%ebp),%eax
  801565:	8d 50 04             	lea    0x4(%eax),%edx
  801568:	89 55 14             	mov    %edx,0x14(%ebp)
  80156b:	8b 00                	mov    (%eax),%eax
  80156d:	85 c0                	test   %eax,%eax
  80156f:	79 02                	jns    801573 <vprintfmt+0x111>
  801571:	f7 d8                	neg    %eax
  801573:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801575:	83 f8 0f             	cmp    $0xf,%eax
  801578:	7f 0b                	jg     801585 <vprintfmt+0x123>
  80157a:	8b 04 85 60 23 80 00 	mov    0x802360(,%eax,4),%eax
  801581:	85 c0                	test   %eax,%eax
  801583:	75 23                	jne    8015a8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801585:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801589:	c7 44 24 08 e3 20 80 	movl   $0x8020e3,0x8(%esp)
  801590:	00 
  801591:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801595:	8b 45 08             	mov    0x8(%ebp),%eax
  801598:	89 04 24             	mov    %eax,(%esp)
  80159b:	e8 9a fe ff ff       	call   80143a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8015a3:	e9 dd fe ff ff       	jmp    801485 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8015a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ac:	c7 44 24 08 61 20 80 	movl   $0x802061,0x8(%esp)
  8015b3:	00 
  8015b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8015bb:	89 14 24             	mov    %edx,(%esp)
  8015be:	e8 77 fe ff ff       	call   80143a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015c6:	e9 ba fe ff ff       	jmp    801485 <vprintfmt+0x23>
  8015cb:	89 f9                	mov    %edi,%ecx
  8015cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8015d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d6:	8d 50 04             	lea    0x4(%eax),%edx
  8015d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8015dc:	8b 30                	mov    (%eax),%esi
  8015de:	85 f6                	test   %esi,%esi
  8015e0:	75 05                	jne    8015e7 <vprintfmt+0x185>
				p = "(null)";
  8015e2:	be dc 20 80 00       	mov    $0x8020dc,%esi
			if (width > 0 && padc != '-')
  8015e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015eb:	0f 8e 84 00 00 00    	jle    801675 <vprintfmt+0x213>
  8015f1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015f5:	74 7e                	je     801675 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015fb:	89 34 24             	mov    %esi,(%esp)
  8015fe:	e8 8b 02 00 00       	call   80188e <strnlen>
  801603:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801606:	29 c2                	sub    %eax,%edx
  801608:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80160b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80160f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801612:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801615:	89 de                	mov    %ebx,%esi
  801617:	89 d3                	mov    %edx,%ebx
  801619:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80161b:	eb 0b                	jmp    801628 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80161d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801621:	89 3c 24             	mov    %edi,(%esp)
  801624:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801627:	4b                   	dec    %ebx
  801628:	85 db                	test   %ebx,%ebx
  80162a:	7f f1                	jg     80161d <vprintfmt+0x1bb>
  80162c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80162f:	89 f3                	mov    %esi,%ebx
  801631:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801637:	85 c0                	test   %eax,%eax
  801639:	79 05                	jns    801640 <vprintfmt+0x1de>
  80163b:	b8 00 00 00 00       	mov    $0x0,%eax
  801640:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801643:	29 c2                	sub    %eax,%edx
  801645:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801648:	eb 2b                	jmp    801675 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80164a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80164e:	74 18                	je     801668 <vprintfmt+0x206>
  801650:	8d 50 e0             	lea    -0x20(%eax),%edx
  801653:	83 fa 5e             	cmp    $0x5e,%edx
  801656:	76 10                	jbe    801668 <vprintfmt+0x206>
					putch('?', putdat);
  801658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80165c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801663:	ff 55 08             	call   *0x8(%ebp)
  801666:	eb 0a                	jmp    801672 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80166c:	89 04 24             	mov    %eax,(%esp)
  80166f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801672:	ff 4d e4             	decl   -0x1c(%ebp)
  801675:	0f be 06             	movsbl (%esi),%eax
  801678:	46                   	inc    %esi
  801679:	85 c0                	test   %eax,%eax
  80167b:	74 21                	je     80169e <vprintfmt+0x23c>
  80167d:	85 ff                	test   %edi,%edi
  80167f:	78 c9                	js     80164a <vprintfmt+0x1e8>
  801681:	4f                   	dec    %edi
  801682:	79 c6                	jns    80164a <vprintfmt+0x1e8>
  801684:	8b 7d 08             	mov    0x8(%ebp),%edi
  801687:	89 de                	mov    %ebx,%esi
  801689:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80168c:	eb 18                	jmp    8016a6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80168e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801692:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801699:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80169b:	4b                   	dec    %ebx
  80169c:	eb 08                	jmp    8016a6 <vprintfmt+0x244>
  80169e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a1:	89 de                	mov    %ebx,%esi
  8016a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016a6:	85 db                	test   %ebx,%ebx
  8016a8:	7f e4                	jg     80168e <vprintfmt+0x22c>
  8016aa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8016ad:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016b2:	e9 ce fd ff ff       	jmp    801485 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016b7:	83 f9 01             	cmp    $0x1,%ecx
  8016ba:	7e 10                	jle    8016cc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8016bf:	8d 50 08             	lea    0x8(%eax),%edx
  8016c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c5:	8b 30                	mov    (%eax),%esi
  8016c7:	8b 78 04             	mov    0x4(%eax),%edi
  8016ca:	eb 26                	jmp    8016f2 <vprintfmt+0x290>
	else if (lflag)
  8016cc:	85 c9                	test   %ecx,%ecx
  8016ce:	74 12                	je     8016e2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8016d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d3:	8d 50 04             	lea    0x4(%eax),%edx
  8016d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d9:	8b 30                	mov    (%eax),%esi
  8016db:	89 f7                	mov    %esi,%edi
  8016dd:	c1 ff 1f             	sar    $0x1f,%edi
  8016e0:	eb 10                	jmp    8016f2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8016e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e5:	8d 50 04             	lea    0x4(%eax),%edx
  8016e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016eb:	8b 30                	mov    (%eax),%esi
  8016ed:	89 f7                	mov    %esi,%edi
  8016ef:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8016f2:	85 ff                	test   %edi,%edi
  8016f4:	78 0a                	js     801700 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8016f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016fb:	e9 8c 00 00 00       	jmp    80178c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801704:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80170b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80170e:	f7 de                	neg    %esi
  801710:	83 d7 00             	adc    $0x0,%edi
  801713:	f7 df                	neg    %edi
			}
			base = 10;
  801715:	b8 0a 00 00 00       	mov    $0xa,%eax
  80171a:	eb 70                	jmp    80178c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80171c:	89 ca                	mov    %ecx,%edx
  80171e:	8d 45 14             	lea    0x14(%ebp),%eax
  801721:	e8 c0 fc ff ff       	call   8013e6 <getuint>
  801726:	89 c6                	mov    %eax,%esi
  801728:	89 d7                	mov    %edx,%edi
			base = 10;
  80172a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80172f:	eb 5b                	jmp    80178c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801731:	89 ca                	mov    %ecx,%edx
  801733:	8d 45 14             	lea    0x14(%ebp),%eax
  801736:	e8 ab fc ff ff       	call   8013e6 <getuint>
  80173b:	89 c6                	mov    %eax,%esi
  80173d:	89 d7                	mov    %edx,%edi
			base = 8;
  80173f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801744:	eb 46                	jmp    80178c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  801746:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801751:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801758:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80175f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801762:	8b 45 14             	mov    0x14(%ebp),%eax
  801765:	8d 50 04             	lea    0x4(%eax),%edx
  801768:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80176b:	8b 30                	mov    (%eax),%esi
  80176d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801772:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801777:	eb 13                	jmp    80178c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801779:	89 ca                	mov    %ecx,%edx
  80177b:	8d 45 14             	lea    0x14(%ebp),%eax
  80177e:	e8 63 fc ff ff       	call   8013e6 <getuint>
  801783:	89 c6                	mov    %eax,%esi
  801785:	89 d7                	mov    %edx,%edi
			base = 16;
  801787:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80178c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801790:	89 54 24 10          	mov    %edx,0x10(%esp)
  801794:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801797:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80179b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80179f:	89 34 24             	mov    %esi,(%esp)
  8017a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017a6:	89 da                	mov    %ebx,%edx
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	e8 6c fb ff ff       	call   80131c <printnum>
			break;
  8017b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017b3:	e9 cd fc ff ff       	jmp    801485 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bc:	89 04 24             	mov    %eax,(%esp)
  8017bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017c5:	e9 bb fc ff ff       	jmp    801485 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017d8:	eb 01                	jmp    8017db <vprintfmt+0x379>
  8017da:	4e                   	dec    %esi
  8017db:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017df:	75 f9                	jne    8017da <vprintfmt+0x378>
  8017e1:	e9 9f fc ff ff       	jmp    801485 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8017e6:	83 c4 4c             	add    $0x4c,%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5f                   	pop    %edi
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	83 ec 28             	sub    $0x28,%esp
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017fd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801801:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801804:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80180b:	85 c0                	test   %eax,%eax
  80180d:	74 30                	je     80183f <vsnprintf+0x51>
  80180f:	85 d2                	test   %edx,%edx
  801811:	7e 33                	jle    801846 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801813:	8b 45 14             	mov    0x14(%ebp),%eax
  801816:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80181a:	8b 45 10             	mov    0x10(%ebp),%eax
  80181d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801821:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801824:	89 44 24 04          	mov    %eax,0x4(%esp)
  801828:	c7 04 24 20 14 80 00 	movl   $0x801420,(%esp)
  80182f:	e8 2e fc ff ff       	call   801462 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801834:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801837:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183d:	eb 0c                	jmp    80184b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801844:	eb 05                	jmp    80184b <vsnprintf+0x5d>
  801846:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801853:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801856:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80185a:	8b 45 10             	mov    0x10(%ebp),%eax
  80185d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	89 44 24 04          	mov    %eax,0x4(%esp)
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	89 04 24             	mov    %eax,(%esp)
  80186e:	e8 7b ff ff ff       	call   8017ee <vsnprintf>
	va_end(ap);

	return rc;
}
  801873:	c9                   	leave  
  801874:	c3                   	ret    
  801875:	00 00                	add    %al,(%eax)
	...

00801878 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80187e:	b8 00 00 00 00       	mov    $0x0,%eax
  801883:	eb 01                	jmp    801886 <strlen+0xe>
		n++;
  801885:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801886:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80188a:	75 f9                	jne    801885 <strlen+0xd>
		n++;
	return n;
}
  80188c:	5d                   	pop    %ebp
  80188d:	c3                   	ret    

0080188e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801894:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801897:	b8 00 00 00 00       	mov    $0x0,%eax
  80189c:	eb 01                	jmp    80189f <strnlen+0x11>
		n++;
  80189e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80189f:	39 d0                	cmp    %edx,%eax
  8018a1:	74 06                	je     8018a9 <strnlen+0x1b>
  8018a3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8018a7:	75 f5                	jne    80189e <strnlen+0x10>
		n++;
	return n;
}
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	53                   	push   %ebx
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018bd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018c0:	42                   	inc    %edx
  8018c1:	84 c9                	test   %cl,%cl
  8018c3:	75 f5                	jne    8018ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018c5:	5b                   	pop    %ebx
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018d2:	89 1c 24             	mov    %ebx,(%esp)
  8018d5:	e8 9e ff ff ff       	call   801878 <strlen>
	strcpy(dst + len, src);
  8018da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018e1:	01 d8                	add    %ebx,%eax
  8018e3:	89 04 24             	mov    %eax,(%esp)
  8018e6:	e8 c0 ff ff ff       	call   8018ab <strcpy>
	return dst;
}
  8018eb:	89 d8                	mov    %ebx,%eax
  8018ed:	83 c4 08             	add    $0x8,%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fe:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801901:	b9 00 00 00 00       	mov    $0x0,%ecx
  801906:	eb 0c                	jmp    801914 <strncpy+0x21>
		*dst++ = *src;
  801908:	8a 1a                	mov    (%edx),%bl
  80190a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80190d:	80 3a 01             	cmpb   $0x1,(%edx)
  801910:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801913:	41                   	inc    %ecx
  801914:	39 f1                	cmp    %esi,%ecx
  801916:	75 f0                	jne    801908 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	8b 75 08             	mov    0x8(%ebp),%esi
  801924:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801927:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80192a:	85 d2                	test   %edx,%edx
  80192c:	75 0a                	jne    801938 <strlcpy+0x1c>
  80192e:	89 f0                	mov    %esi,%eax
  801930:	eb 1a                	jmp    80194c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801932:	88 18                	mov    %bl,(%eax)
  801934:	40                   	inc    %eax
  801935:	41                   	inc    %ecx
  801936:	eb 02                	jmp    80193a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801938:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80193a:	4a                   	dec    %edx
  80193b:	74 0a                	je     801947 <strlcpy+0x2b>
  80193d:	8a 19                	mov    (%ecx),%bl
  80193f:	84 db                	test   %bl,%bl
  801941:	75 ef                	jne    801932 <strlcpy+0x16>
  801943:	89 c2                	mov    %eax,%edx
  801945:	eb 02                	jmp    801949 <strlcpy+0x2d>
  801947:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801949:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80194c:	29 f0                	sub    %esi,%eax
}
  80194e:	5b                   	pop    %ebx
  80194f:	5e                   	pop    %esi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801958:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80195b:	eb 02                	jmp    80195f <strcmp+0xd>
		p++, q++;
  80195d:	41                   	inc    %ecx
  80195e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80195f:	8a 01                	mov    (%ecx),%al
  801961:	84 c0                	test   %al,%al
  801963:	74 04                	je     801969 <strcmp+0x17>
  801965:	3a 02                	cmp    (%edx),%al
  801967:	74 f4                	je     80195d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801969:	0f b6 c0             	movzbl %al,%eax
  80196c:	0f b6 12             	movzbl (%edx),%edx
  80196f:	29 d0                	sub    %edx,%eax
}
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	53                   	push   %ebx
  801977:	8b 45 08             	mov    0x8(%ebp),%eax
  80197a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801980:	eb 03                	jmp    801985 <strncmp+0x12>
		n--, p++, q++;
  801982:	4a                   	dec    %edx
  801983:	40                   	inc    %eax
  801984:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801985:	85 d2                	test   %edx,%edx
  801987:	74 14                	je     80199d <strncmp+0x2a>
  801989:	8a 18                	mov    (%eax),%bl
  80198b:	84 db                	test   %bl,%bl
  80198d:	74 04                	je     801993 <strncmp+0x20>
  80198f:	3a 19                	cmp    (%ecx),%bl
  801991:	74 ef                	je     801982 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801993:	0f b6 00             	movzbl (%eax),%eax
  801996:	0f b6 11             	movzbl (%ecx),%edx
  801999:	29 d0                	sub    %edx,%eax
  80199b:	eb 05                	jmp    8019a2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80199d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8019a2:	5b                   	pop    %ebx
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019ae:	eb 05                	jmp    8019b5 <strchr+0x10>
		if (*s == c)
  8019b0:	38 ca                	cmp    %cl,%dl
  8019b2:	74 0c                	je     8019c0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019b4:	40                   	inc    %eax
  8019b5:	8a 10                	mov    (%eax),%dl
  8019b7:	84 d2                	test   %dl,%dl
  8019b9:	75 f5                	jne    8019b0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019cb:	eb 05                	jmp    8019d2 <strfind+0x10>
		if (*s == c)
  8019cd:	38 ca                	cmp    %cl,%dl
  8019cf:	74 07                	je     8019d8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8019d1:	40                   	inc    %eax
  8019d2:	8a 10                	mov    (%eax),%dl
  8019d4:	84 d2                	test   %dl,%dl
  8019d6:	75 f5                	jne    8019cd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    

008019da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	57                   	push   %edi
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019e9:	85 c9                	test   %ecx,%ecx
  8019eb:	74 30                	je     801a1d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019f3:	75 25                	jne    801a1a <memset+0x40>
  8019f5:	f6 c1 03             	test   $0x3,%cl
  8019f8:	75 20                	jne    801a1a <memset+0x40>
		c &= 0xFF;
  8019fa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019fd:	89 d3                	mov    %edx,%ebx
  8019ff:	c1 e3 08             	shl    $0x8,%ebx
  801a02:	89 d6                	mov    %edx,%esi
  801a04:	c1 e6 18             	shl    $0x18,%esi
  801a07:	89 d0                	mov    %edx,%eax
  801a09:	c1 e0 10             	shl    $0x10,%eax
  801a0c:	09 f0                	or     %esi,%eax
  801a0e:	09 d0                	or     %edx,%eax
  801a10:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a12:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a15:	fc                   	cld    
  801a16:	f3 ab                	rep stos %eax,%es:(%edi)
  801a18:	eb 03                	jmp    801a1d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a1a:	fc                   	cld    
  801a1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a1d:	89 f8                	mov    %edi,%eax
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	57                   	push   %edi
  801a28:	56                   	push   %esi
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a32:	39 c6                	cmp    %eax,%esi
  801a34:	73 34                	jae    801a6a <memmove+0x46>
  801a36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a39:	39 d0                	cmp    %edx,%eax
  801a3b:	73 2d                	jae    801a6a <memmove+0x46>
		s += n;
		d += n;
  801a3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a40:	f6 c2 03             	test   $0x3,%dl
  801a43:	75 1b                	jne    801a60 <memmove+0x3c>
  801a45:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a4b:	75 13                	jne    801a60 <memmove+0x3c>
  801a4d:	f6 c1 03             	test   $0x3,%cl
  801a50:	75 0e                	jne    801a60 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a52:	83 ef 04             	sub    $0x4,%edi
  801a55:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a58:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a5b:	fd                   	std    
  801a5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a5e:	eb 07                	jmp    801a67 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a60:	4f                   	dec    %edi
  801a61:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a64:	fd                   	std    
  801a65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a67:	fc                   	cld    
  801a68:	eb 20                	jmp    801a8a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a6a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a70:	75 13                	jne    801a85 <memmove+0x61>
  801a72:	a8 03                	test   $0x3,%al
  801a74:	75 0f                	jne    801a85 <memmove+0x61>
  801a76:	f6 c1 03             	test   $0x3,%cl
  801a79:	75 0a                	jne    801a85 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a7b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a7e:	89 c7                	mov    %eax,%edi
  801a80:	fc                   	cld    
  801a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a83:	eb 05                	jmp    801a8a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a85:	89 c7                	mov    %eax,%edi
  801a87:	fc                   	cld    
  801a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a8a:	5e                   	pop    %esi
  801a8b:	5f                   	pop    %edi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a94:	8b 45 10             	mov    0x10(%ebp),%eax
  801a97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa5:	89 04 24             	mov    %eax,(%esp)
  801aa8:	e8 77 ff ff ff       	call   801a24 <memmove>
}
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	57                   	push   %edi
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801abb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801abe:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac3:	eb 16                	jmp    801adb <memcmp+0x2c>
		if (*s1 != *s2)
  801ac5:	8a 04 17             	mov    (%edi,%edx,1),%al
  801ac8:	42                   	inc    %edx
  801ac9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801acd:	38 c8                	cmp    %cl,%al
  801acf:	74 0a                	je     801adb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ad1:	0f b6 c0             	movzbl %al,%eax
  801ad4:	0f b6 c9             	movzbl %cl,%ecx
  801ad7:	29 c8                	sub    %ecx,%eax
  801ad9:	eb 09                	jmp    801ae4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801adb:	39 da                	cmp    %ebx,%edx
  801add:	75 e6                	jne    801ac5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801af7:	eb 05                	jmp    801afe <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801af9:	38 08                	cmp    %cl,(%eax)
  801afb:	74 05                	je     801b02 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801afd:	40                   	inc    %eax
  801afe:	39 d0                	cmp    %edx,%eax
  801b00:	72 f7                	jb     801af9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	57                   	push   %edi
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b10:	eb 01                	jmp    801b13 <strtol+0xf>
		s++;
  801b12:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b13:	8a 02                	mov    (%edx),%al
  801b15:	3c 20                	cmp    $0x20,%al
  801b17:	74 f9                	je     801b12 <strtol+0xe>
  801b19:	3c 09                	cmp    $0x9,%al
  801b1b:	74 f5                	je     801b12 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b1d:	3c 2b                	cmp    $0x2b,%al
  801b1f:	75 08                	jne    801b29 <strtol+0x25>
		s++;
  801b21:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b22:	bf 00 00 00 00       	mov    $0x0,%edi
  801b27:	eb 13                	jmp    801b3c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b29:	3c 2d                	cmp    $0x2d,%al
  801b2b:	75 0a                	jne    801b37 <strtol+0x33>
		s++, neg = 1;
  801b2d:	8d 52 01             	lea    0x1(%edx),%edx
  801b30:	bf 01 00 00 00       	mov    $0x1,%edi
  801b35:	eb 05                	jmp    801b3c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b3c:	85 db                	test   %ebx,%ebx
  801b3e:	74 05                	je     801b45 <strtol+0x41>
  801b40:	83 fb 10             	cmp    $0x10,%ebx
  801b43:	75 28                	jne    801b6d <strtol+0x69>
  801b45:	8a 02                	mov    (%edx),%al
  801b47:	3c 30                	cmp    $0x30,%al
  801b49:	75 10                	jne    801b5b <strtol+0x57>
  801b4b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b4f:	75 0a                	jne    801b5b <strtol+0x57>
		s += 2, base = 16;
  801b51:	83 c2 02             	add    $0x2,%edx
  801b54:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b59:	eb 12                	jmp    801b6d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b5b:	85 db                	test   %ebx,%ebx
  801b5d:	75 0e                	jne    801b6d <strtol+0x69>
  801b5f:	3c 30                	cmp    $0x30,%al
  801b61:	75 05                	jne    801b68 <strtol+0x64>
		s++, base = 8;
  801b63:	42                   	inc    %edx
  801b64:	b3 08                	mov    $0x8,%bl
  801b66:	eb 05                	jmp    801b6d <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b68:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b72:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b74:	8a 0a                	mov    (%edx),%cl
  801b76:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b79:	80 fb 09             	cmp    $0x9,%bl
  801b7c:	77 08                	ja     801b86 <strtol+0x82>
			dig = *s - '0';
  801b7e:	0f be c9             	movsbl %cl,%ecx
  801b81:	83 e9 30             	sub    $0x30,%ecx
  801b84:	eb 1e                	jmp    801ba4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b86:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b89:	80 fb 19             	cmp    $0x19,%bl
  801b8c:	77 08                	ja     801b96 <strtol+0x92>
			dig = *s - 'a' + 10;
  801b8e:	0f be c9             	movsbl %cl,%ecx
  801b91:	83 e9 57             	sub    $0x57,%ecx
  801b94:	eb 0e                	jmp    801ba4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b96:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b99:	80 fb 19             	cmp    $0x19,%bl
  801b9c:	77 12                	ja     801bb0 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b9e:	0f be c9             	movsbl %cl,%ecx
  801ba1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801ba4:	39 f1                	cmp    %esi,%ecx
  801ba6:	7d 0c                	jge    801bb4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801ba8:	42                   	inc    %edx
  801ba9:	0f af c6             	imul   %esi,%eax
  801bac:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801bae:	eb c4                	jmp    801b74 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801bb0:	89 c1                	mov    %eax,%ecx
  801bb2:	eb 02                	jmp    801bb6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801bb4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bba:	74 05                	je     801bc1 <strtol+0xbd>
		*endptr = (char *) s;
  801bbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bbf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bc1:	85 ff                	test   %edi,%edi
  801bc3:	74 04                	je     801bc9 <strtol+0xc5>
  801bc5:	89 c8                	mov    %ecx,%eax
  801bc7:	f7 d8                	neg    %eax
}
  801bc9:	5b                   	pop    %ebx
  801bca:	5e                   	pop    %esi
  801bcb:	5f                   	pop    %edi
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    
	...

00801bd0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 10             	sub    $0x10,%esp
  801bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bde:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801be1:	85 c0                	test   %eax,%eax
  801be3:	75 05                	jne    801bea <ipc_recv+0x1a>
  801be5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	e8 b1 e7 ff ff       	call   8003a3 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	79 16                	jns    801c0c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801bf6:	85 db                	test   %ebx,%ebx
  801bf8:	74 06                	je     801c00 <ipc_recv+0x30>
  801bfa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801c00:	85 f6                	test   %esi,%esi
  801c02:	74 32                	je     801c36 <ipc_recv+0x66>
  801c04:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c0a:	eb 2a                	jmp    801c36 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c0c:	85 db                	test   %ebx,%ebx
  801c0e:	74 0c                	je     801c1c <ipc_recv+0x4c>
  801c10:	a1 04 40 80 00       	mov    0x804004,%eax
  801c15:	8b 00                	mov    (%eax),%eax
  801c17:	8b 40 74             	mov    0x74(%eax),%eax
  801c1a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c1c:	85 f6                	test   %esi,%esi
  801c1e:	74 0c                	je     801c2c <ipc_recv+0x5c>
  801c20:	a1 04 40 80 00       	mov    0x804004,%eax
  801c25:	8b 00                	mov    (%eax),%eax
  801c27:	8b 40 78             	mov    0x78(%eax),%eax
  801c2a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c2c:	a1 04 40 80 00       	mov    0x804004,%eax
  801c31:	8b 00                	mov    (%eax),%eax
  801c33:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	57                   	push   %edi
  801c41:	56                   	push   %esi
  801c42:	53                   	push   %ebx
  801c43:	83 ec 1c             	sub    $0x1c,%esp
  801c46:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c4c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c4f:	85 db                	test   %ebx,%ebx
  801c51:	75 05                	jne    801c58 <ipc_send+0x1b>
  801c53:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c58:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c60:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	e8 11 e7 ff ff       	call   800380 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c6f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c72:	75 07                	jne    801c7b <ipc_send+0x3e>
  801c74:	e8 f5 e4 ff ff       	call   80016e <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c79:	eb dd                	jmp    801c58 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	79 1c                	jns    801c9b <ipc_send+0x5e>
  801c7f:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801c86:	00 
  801c87:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c8e:	00 
  801c8f:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  801c96:	e8 6d f5 ff ff       	call   801208 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801c9b:	83 c4 1c             	add    $0x1c,%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5f                   	pop    %edi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	53                   	push   %ebx
  801ca7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801caf:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cb6:	89 c2                	mov    %eax,%edx
  801cb8:	c1 e2 07             	shl    $0x7,%edx
  801cbb:	29 ca                	sub    %ecx,%edx
  801cbd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc3:	8b 52 50             	mov    0x50(%edx),%edx
  801cc6:	39 da                	cmp    %ebx,%edx
  801cc8:	75 0f                	jne    801cd9 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cca:	c1 e0 07             	shl    $0x7,%eax
  801ccd:	29 c8                	sub    %ecx,%eax
  801ccf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cd4:	8b 40 40             	mov    0x40(%eax),%eax
  801cd7:	eb 0c                	jmp    801ce5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cd9:	40                   	inc    %eax
  801cda:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cdf:	75 ce                	jne    801caf <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ce1:	66 b8 00 00          	mov    $0x0,%ax
}
  801ce5:	5b                   	pop    %ebx
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801cee:	89 c2                	mov    %eax,%edx
  801cf0:	c1 ea 16             	shr    $0x16,%edx
  801cf3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cfa:	f6 c2 01             	test   $0x1,%dl
  801cfd:	74 1e                	je     801d1d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cff:	c1 e8 0c             	shr    $0xc,%eax
  801d02:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d09:	a8 01                	test   $0x1,%al
  801d0b:	74 17                	je     801d24 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d0d:	c1 e8 0c             	shr    $0xc,%eax
  801d10:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d17:	ef 
  801d18:	0f b7 c0             	movzwl %ax,%eax
  801d1b:	eb 0c                	jmp    801d29 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d22:	eb 05                	jmp    801d29 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d24:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
	...

00801d2c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d2c:	55                   	push   %ebp
  801d2d:	57                   	push   %edi
  801d2e:	56                   	push   %esi
  801d2f:	83 ec 10             	sub    $0x10,%esp
  801d32:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d36:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d42:	89 cd                	mov    %ecx,%ebp
  801d44:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	75 2c                	jne    801d78 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d4c:	39 f9                	cmp    %edi,%ecx
  801d4e:	77 68                	ja     801db8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d50:	85 c9                	test   %ecx,%ecx
  801d52:	75 0b                	jne    801d5f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d54:	b8 01 00 00 00       	mov    $0x1,%eax
  801d59:	31 d2                	xor    %edx,%edx
  801d5b:	f7 f1                	div    %ecx
  801d5d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d5f:	31 d2                	xor    %edx,%edx
  801d61:	89 f8                	mov    %edi,%eax
  801d63:	f7 f1                	div    %ecx
  801d65:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d67:	89 f0                	mov    %esi,%eax
  801d69:	f7 f1                	div    %ecx
  801d6b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d6d:	89 f0                	mov    %esi,%eax
  801d6f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d78:	39 f8                	cmp    %edi,%eax
  801d7a:	77 2c                	ja     801da8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d7c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d7f:	83 f6 1f             	xor    $0x1f,%esi
  801d82:	75 4c                	jne    801dd0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d84:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d86:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d8b:	72 0a                	jb     801d97 <__udivdi3+0x6b>
  801d8d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d91:	0f 87 ad 00 00 00    	ja     801e44 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d97:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d9c:	89 f0                	mov    %esi,%eax
  801d9e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	5e                   	pop    %esi
  801da4:	5f                   	pop    %edi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    
  801da7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801da8:	31 ff                	xor    %edi,%edi
  801daa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dac:	89 f0                	mov    %esi,%eax
  801dae:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    
  801db7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801db8:	89 fa                	mov    %edi,%edx
  801dba:	89 f0                	mov    %esi,%eax
  801dbc:	f7 f1                	div    %ecx
  801dbe:	89 c6                	mov    %eax,%esi
  801dc0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dc2:	89 f0                	mov    %esi,%eax
  801dc4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dd0:	89 f1                	mov    %esi,%ecx
  801dd2:	d3 e0                	shl    %cl,%eax
  801dd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dd8:	b8 20 00 00 00       	mov    $0x20,%eax
  801ddd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801ddf:	89 ea                	mov    %ebp,%edx
  801de1:	88 c1                	mov    %al,%cl
  801de3:	d3 ea                	shr    %cl,%edx
  801de5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801de9:	09 ca                	or     %ecx,%edx
  801deb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801def:	89 f1                	mov    %esi,%ecx
  801df1:	d3 e5                	shl    %cl,%ebp
  801df3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801df7:	89 fd                	mov    %edi,%ebp
  801df9:	88 c1                	mov    %al,%cl
  801dfb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801dfd:	89 fa                	mov    %edi,%edx
  801dff:	89 f1                	mov    %esi,%ecx
  801e01:	d3 e2                	shl    %cl,%edx
  801e03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e07:	88 c1                	mov    %al,%cl
  801e09:	d3 ef                	shr    %cl,%edi
  801e0b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e0d:	89 f8                	mov    %edi,%eax
  801e0f:	89 ea                	mov    %ebp,%edx
  801e11:	f7 74 24 08          	divl   0x8(%esp)
  801e15:	89 d1                	mov    %edx,%ecx
  801e17:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e19:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e1d:	39 d1                	cmp    %edx,%ecx
  801e1f:	72 17                	jb     801e38 <__udivdi3+0x10c>
  801e21:	74 09                	je     801e2c <__udivdi3+0x100>
  801e23:	89 fe                	mov    %edi,%esi
  801e25:	31 ff                	xor    %edi,%edi
  801e27:	e9 41 ff ff ff       	jmp    801d6d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e2c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e30:	89 f1                	mov    %esi,%ecx
  801e32:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e34:	39 c2                	cmp    %eax,%edx
  801e36:	73 eb                	jae    801e23 <__udivdi3+0xf7>
		{
		  q0--;
  801e38:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e3b:	31 ff                	xor    %edi,%edi
  801e3d:	e9 2b ff ff ff       	jmp    801d6d <__udivdi3+0x41>
  801e42:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e44:	31 f6                	xor    %esi,%esi
  801e46:	e9 22 ff ff ff       	jmp    801d6d <__udivdi3+0x41>
	...

00801e4c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e4c:	55                   	push   %ebp
  801e4d:	57                   	push   %edi
  801e4e:	56                   	push   %esi
  801e4f:	83 ec 20             	sub    $0x20,%esp
  801e52:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e56:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e5a:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e5e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e66:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e6a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e6c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e6e:	85 ed                	test   %ebp,%ebp
  801e70:	75 16                	jne    801e88 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e72:	39 f1                	cmp    %esi,%ecx
  801e74:	0f 86 a6 00 00 00    	jbe    801f20 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e7a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e7c:	89 d0                	mov    %edx,%eax
  801e7e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e80:	83 c4 20             	add    $0x20,%esp
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    
  801e87:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e88:	39 f5                	cmp    %esi,%ebp
  801e8a:	0f 87 ac 00 00 00    	ja     801f3c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e90:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801e93:	83 f0 1f             	xor    $0x1f,%eax
  801e96:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e9a:	0f 84 a8 00 00 00    	je     801f48 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ea0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ea6:	bf 20 00 00 00       	mov    $0x20,%edi
  801eab:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801eaf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eb3:	89 f9                	mov    %edi,%ecx
  801eb5:	d3 e8                	shr    %cl,%eax
  801eb7:	09 e8                	or     %ebp,%eax
  801eb9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ebd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ec1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ec5:	d3 e0                	shl    %cl,%eax
  801ec7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ecb:	89 f2                	mov    %esi,%edx
  801ecd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ecf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ed3:	d3 e0                	shl    %cl,%eax
  801ed5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ed9:	8b 44 24 14          	mov    0x14(%esp),%eax
  801edd:	89 f9                	mov    %edi,%ecx
  801edf:	d3 e8                	shr    %cl,%eax
  801ee1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801ee3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ee5:	89 f2                	mov    %esi,%edx
  801ee7:	f7 74 24 18          	divl   0x18(%esp)
  801eeb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801eed:	f7 64 24 0c          	mull   0xc(%esp)
  801ef1:	89 c5                	mov    %eax,%ebp
  801ef3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ef5:	39 d6                	cmp    %edx,%esi
  801ef7:	72 67                	jb     801f60 <__umoddi3+0x114>
  801ef9:	74 75                	je     801f70 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801efb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801eff:	29 e8                	sub    %ebp,%eax
  801f01:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f03:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f07:	d3 e8                	shr    %cl,%eax
  801f09:	89 f2                	mov    %esi,%edx
  801f0b:	89 f9                	mov    %edi,%ecx
  801f0d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f0f:	09 d0                	or     %edx,%eax
  801f11:	89 f2                	mov    %esi,%edx
  801f13:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f17:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f19:	83 c4 20             	add    $0x20,%esp
  801f1c:	5e                   	pop    %esi
  801f1d:	5f                   	pop    %edi
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f20:	85 c9                	test   %ecx,%ecx
  801f22:	75 0b                	jne    801f2f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f24:	b8 01 00 00 00       	mov    $0x1,%eax
  801f29:	31 d2                	xor    %edx,%edx
  801f2b:	f7 f1                	div    %ecx
  801f2d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f2f:	89 f0                	mov    %esi,%eax
  801f31:	31 d2                	xor    %edx,%edx
  801f33:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f35:	89 f8                	mov    %edi,%eax
  801f37:	e9 3e ff ff ff       	jmp    801e7a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f3c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f3e:	83 c4 20             	add    $0x20,%esp
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    
  801f45:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f48:	39 f5                	cmp    %esi,%ebp
  801f4a:	72 04                	jb     801f50 <__umoddi3+0x104>
  801f4c:	39 f9                	cmp    %edi,%ecx
  801f4e:	77 06                	ja     801f56 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f50:	89 f2                	mov    %esi,%edx
  801f52:	29 cf                	sub    %ecx,%edi
  801f54:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f56:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f58:	83 c4 20             	add    $0x20,%esp
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    
  801f5f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f60:	89 d1                	mov    %edx,%ecx
  801f62:	89 c5                	mov    %eax,%ebp
  801f64:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f68:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f6c:	eb 8d                	jmp    801efb <__umoddi3+0xaf>
  801f6e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f70:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f74:	72 ea                	jb     801f60 <__umoddi3+0x114>
  801f76:	89 f1                	mov    %esi,%ecx
  801f78:	eb 81                	jmp    801efb <__umoddi3+0xaf>
